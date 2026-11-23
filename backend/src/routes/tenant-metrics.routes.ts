import { createHmac, timingSafeEqual } from 'node:crypto'
import { Router } from 'express'
import { z } from 'zod'
import { env } from '../config/env.js'
import { prisma } from '../db/prisma.js'
import { writeAudit } from '../services/audit.service.js'
import { HttpError } from '../utils/http-error.js'

export const tenantMetricsRouter=Router()
const metricsSchema=z.object({students:z.number().int().min(0).max(10_000_000),faculty:z.number().int().min(0).max(1_000_000),campuses:z.number().int().min(0).max(100_000)}).strict()
tenantMetricsRouter.post('/',async(req,res)=>{
  if(!env.TENANT_METRICS_INGEST_SECRET)throw new HttpError(503,'Tenant metrics ingestion is not configured')
  const code=req.header('x-tenant-code')||'',timestamp=req.header('x-timestamp')||'',signature=req.header('x-signature')||''
  const seconds=Number(timestamp)
  if(!code||!Number.isInteger(seconds)||Math.abs(Date.now()/1000-seconds)>300)throw new HttpError(401,'Invalid or expired tenant metrics signature')
  const metrics=metricsSchema.parse(req.body)
  const signed=`${timestamp}.${code}.${metrics.students}.${metrics.faculty}.${metrics.campuses}`
  const expected=createHmac('sha256',env.TENANT_METRICS_INGEST_SECRET).update(signed).digest()
  let received:Buffer
  try{received=Buffer.from(signature,'hex')}catch{throw new HttpError(401,'Invalid tenant metrics signature')}
  if(received.length!==expected.length||!timingSafeEqual(received,expected))throw new HttpError(401,'Invalid tenant metrics signature')
  const university=await prisma.university.findFirst({where:{code:code.toUpperCase(),deletedAt:null,status:'ACTIVE',tenantDatabase:{is:{status:'READY'}}},select:{id:true,code:true}})
  if(!university)throw new HttpError(404,'Active university with a verified tenant database was not found')
  const record=await prisma.tenantMetric.create({data:{universityId:university.id,studentCount:metrics.students,facultyCount:metrics.faculty,campusCount:metrics.campuses,source:'signed-tenant-agent'}})
  await writeAudit({req,universityId:university.id,action:'TENANT_METRICS_RECEIVED',entityType:'TenantMetric',entityId:record.id,metadata:{studentCount:record.studentCount,facultyCount:record.facultyCount,campusCount:record.campusCount}})
  res.status(201).json({data:{accepted:true,universityCode:university.code,collectedAt:record.collectedAt}})
})
