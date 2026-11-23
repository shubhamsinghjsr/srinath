import { randomBytes } from 'node:crypto'
import type { Request, Response } from 'express'
import { prisma } from '../db/prisma.js'
import { HttpError } from '../utils/http-error.js'
import { writeAudit } from '../services/audit.service.js'
import { campusSchema } from '../validation/campus.schema.js'

export async function listCampusesController(req:Request,res:Response) {
  const universityId=String(req.params.id)
  const university=await prisma.university.findFirst({where:{id:universityId,deletedAt:null},select:{id:true}})
  if(!university)throw new HttpError(404,'University not found')
  const items=await prisma.campus.findMany({where:{universityId,deletedAt:null},orderBy:{name:'asc'}})
  res.json({data:{items}})
}

export async function createCampusController(req:Request,res:Response) {
  const universityId=String(req.params.id),input=campusSchema.parse(req.body)
  const university=await prisma.university.findFirst({where:{id:universityId,deletedAt:null},select:{id:true,name:true}})
  if(!university)throw new HttpError(404,'University not found')
  const code=input.code || `TCU-${randomBytes(3).toString('hex').toUpperCase()}`
  try {
    const campus=await prisma.campus.create({data:{universityId,name:input.name,code,campusType:input.campusType,city:input.city,addressLine:input.addressLine,status:input.status}})
    await writeAudit({req,universityId,action:'CAMPUS_CREATED',entityType:'Campus',entityId:campus.id,metadata:{code:campus.code,name:campus.name}})
    res.status(201).json({data:{...campus,universityName:university.name}})
  } catch(error) {
    if(typeof error==='object'&&error!==null&&'code' in error&&(error as {code?:string}).code==='P2002')throw new HttpError(409,'Campus code already exists for this university')
    throw error
  }
}
