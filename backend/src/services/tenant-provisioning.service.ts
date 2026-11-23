import { randomBytes, createCipheriv, createDecipheriv } from 'node:crypto'
import { Client } from 'pg'
import type { Request } from 'express'
import { env } from '../config/env.js'
import { prisma } from '../db/prisma.js'
import { HttpError } from '../utils/http-error.js'
import { writeAudit } from './audit.service.js'

function encryptionKey() {
  if (!env.TENANT_CONFIG_ENCRYPTION_KEY) throw new HttpError(503, 'Tenant connection encryption is not configured')
  const key=Buffer.from(env.TENANT_CONFIG_ENCRYPTION_KEY,'base64')
  if(key.length!==32)throw new HttpError(503,'TENANT_CONFIG_ENCRYPTION_KEY must decode to exactly 32 bytes')
  return key
}

function encryptConfiguration(value:string) {
  const iv=randomBytes(12),cipher=createCipheriv('aes-256-gcm',encryptionKey(),iv)
  const ciphertext=Buffer.concat([cipher.update(value,'utf8'),cipher.final()])
  return `v1:${iv.toString('base64')}:${cipher.getAuthTag().toString('base64')}:${ciphertext.toString('base64')}`
}

function decryptConfiguration(value:string) {
  const [version,ivText,tagText,dataText]=value.split(':')
  if(version!=='v1'||!ivText||!tagText||!dataText)throw new HttpError(500,'Stored tenant configuration has an unsupported format')
  const decipher=createDecipheriv('aes-256-gcm',encryptionKey(),Buffer.from(ivText,'base64'))
  decipher.setAuthTag(Buffer.from(tagText,'base64'))
  return Buffer.concat([decipher.update(Buffer.from(dataText,'base64')),decipher.final()]).toString('utf8')
}

const ident=(value:string)=>`"${value.replaceAll('"','""')}"`
const literal=(value:string)=>`'${value.replaceAll("'","''")}'`
const tenantDatabaseName=(code:string)=>`techcoder_${code.toLowerCase().replace(/[^a-z0-9]/g,'_')}`.slice(0,63)

async function postgresClient(connectionString:string,database?:string) {
  const url=new URL(connectionString)
  if(database)url.pathname=`/${database}`
  const client=new Client({connectionString:url.toString(),connectionTimeoutMillis:7000,query_timeout:10000})
  await client.connect()
  return client
}

export async function provisionTenantDatabase(universityId:string,req:Request) {
  if(!env.POSTGRES_ADMIN_URL)throw new HttpError(503,'POSTGRES_ADMIN_URL is required for tenant provisioning')
  const university=await prisma.university.findFirst({where:{id:universityId,deletedAt:null},include:{tenantDatabase:true}})
  if(!university)throw new HttpError(404,'University not found')
  if(university.tenantDatabase?.status==='PROVISIONING')throw new HttpError(409,'Tenant database provisioning is already running')
  if(university.tenantDatabase?.status==='READY')return await verifyTenantDatabase(universityId,req)
  const databaseName=tenantDatabaseName(university.code)
  const roleName=`${databaseName.slice(0,42)}_${randomBytes(4).toString('hex')}_app`
  const password=randomBytes(36).toString('base64url')
  await prisma.tenantDatabase.upsert({where:{universityId},create:{universityId,databaseName,status:'PROVISIONING'},update:{databaseName,status:'PROVISIONING',lastError:null}})
  let admin:Client|undefined
  try {
    admin=await postgresClient(env.POSTGRES_ADMIN_URL)
    const existing=await admin.query('SELECT 1 FROM pg_database WHERE datname = $1',[databaseName])
    if(existing.rowCount)throw new HttpError(409,'A database with the generated tenant name already exists; manual review is required')
    await admin.query(`CREATE ROLE ${ident(roleName)} LOGIN PASSWORD ${literal(password)} NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT`)
    await admin.query(`CREATE DATABASE ${ident(databaseName)} OWNER ${ident(roleName)}`)
    const tenantUrl=new URL(env.POSTGRES_ADMIN_URL)
    tenantUrl.username=roleName;tenantUrl.password=password;tenantUrl.pathname=`/${databaseName}`
    const verification=await postgresClient(tenantUrl.toString())
    try { await verification.query('SELECT 1') } finally { await verification.end() }
    const encryptedConnection=encryptConfiguration(tenantUrl.toString())
    const updated=await prisma.tenantDatabase.update({where:{universityId},data:{databaseName,status:'READY',encryptedConnection,lastVerifiedAt:new Date(),lastError:null}})
    await writeAudit({req,universityId,action:'TENANT_DATABASE_PROVISIONED',entityType:'TenantDatabase',entityId:updated.id,metadata:{databaseName,status:'READY'}})
    return {status:updated.status,databaseName:updated.databaseName,lastVerifiedAt:updated.lastVerifiedAt}
  } catch(error) {
    const message=error instanceof Error?error.message:'Unknown provisioning error'
    await prisma.tenantDatabase.update({where:{universityId},data:{status:'FAILED',lastError:message.slice(0,490)}}).catch(()=>undefined)
    await writeAudit({req,universityId,action:'TENANT_DATABASE_PROVISIONING_FAILED',entityType:'TenantDatabase',metadata:{databaseName,error:message.slice(0,300)}}).catch(()=>undefined)
    throw error
  } finally { await admin?.end().catch(()=>undefined) }
}

export async function verifyTenantDatabase(universityId:string,req?:Request) {
  const record=await prisma.tenantDatabase.findUnique({where:{universityId}})
  if(!record)throw new HttpError(404,'Tenant database has not been provisioned')
  if(!record.encryptedConnection)throw new HttpError(409,'Tenant database connection configuration is not available')
  let client:Client|undefined
  try {
    client=await postgresClient(decryptConfiguration(record.encryptedConnection))
    await client.query('SELECT 1')
    const lastVerifiedAt=new Date()
    const updated=await prisma.tenantDatabase.update({where:{id:record.id},data:{status:'READY',lastVerifiedAt,lastError:null}})
    if(req)await writeAudit({req,universityId,action:'TENANT_DATABASE_CONNECTION_VERIFIED',entityType:'TenantDatabase',entityId:record.id})
    return {status:updated.status,databaseName:updated.databaseName,lastVerifiedAt:updated.lastVerifiedAt}
  } catch(error) {
    const message=error instanceof Error?error.message:'Tenant connection failed'
    const updated=await prisma.tenantDatabase.update({where:{id:record.id},data:{status:'FAILED',lastError:message.slice(0,490)}})
    if(req)await writeAudit({req,universityId,action:'TENANT_DATABASE_CONNECTION_FAILED',entityType:'TenantDatabase',entityId:record.id,metadata:{error:message.slice(0,250)}})
    return {status:updated.status,databaseName:updated.databaseName,lastVerifiedAt:updated.lastVerifiedAt,error:'Tenant database connection failed'}
  } finally { await client?.end().catch(()=>undefined) }
}

export async function tenantDatabaseStatus(universityId:string) {
  const record=await prisma.tenantDatabase.findUnique({where:{universityId},select:{databaseName:true,status:true,lastVerifiedAt:true,lastError:true,updatedAt:true}})
  if(!record)throw new HttpError(404,'Tenant database record not found')
  return record
}
