import 'dotenv/config'
import bcrypt from 'bcrypt'
import { prisma } from '../src/db/prisma.js'

const email=process.env.ADMIN_EMAIL?.trim().toLowerCase()
const password=process.env.ADMIN_PASSWORD
if(!email||!password||password.length<12||password==='SET_A_UNIQUE_PASSWORD_BEFORE_SEEDING')throw new Error('Set a unique ADMIN_EMAIL and ADMIN_PASSWORD (12+ characters) in .env before running the secure seed')
const adminEmail=email
const adminPassword=password

async function main(){
  const role=await prisma.platformRole.upsert({where:{code:'SUPER_ADMIN'},update:{name:'Super Admin'},create:{code:'SUPER_ADMIN',name:'Super Admin',description:'Platform-wide administrative access'}})
  const permissions=['platform.dashboard.read','platform.universities.read','platform.universities.write','platform.universities.provision','platform.audit.read']
  for(const code of permissions){
    const permission=await prisma.platformPermission.upsert({where:{code},update:{},create:{code,description:`Permission: ${code}`}})
    await prisma.platformRolePermission.upsert({where:{roleId_permissionId:{roleId:role.id,permissionId:permission.id}},update:{},create:{roleId:role.id,permissionId:permission.id}})
  }
  const passwordHash=await bcrypt.hash(adminPassword,12)
  const user=await prisma.platformUser.upsert({where:{email:adminEmail},update:{},create:{name:'Platform Super Admin',email:adminEmail,passwordHash,active:true,userRoles:{create:{roleId:role.id}}}})
  await prisma.platformUserRole.upsert({where:{userId_roleId:{userId:user.id,roleId:role.id}},update:{},create:{userId:user.id,roleId:role.id}})
  console.info(`Seeded Super Admin account ${adminEmail}. Password was read from environment and was not printed.`)
}
main().catch(error=>{console.error(error);process.exitCode=1}).finally(async()=>prisma.$disconnect())
