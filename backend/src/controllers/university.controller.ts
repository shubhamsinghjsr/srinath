import type { Request, Response } from 'express'
import { z } from 'zod'
import { createUniversity, getUniversity, listUniversities, mapUniqueError, setUniversityStatus, softDeleteUniversity, updateUniversity } from '../services/university.service.js'
import { provisionTenantDatabase, tenantDatabaseStatus, verifyTenantDatabase } from '../services/tenant-provisioning.service.js'
import { universityInputSchema, universityStatusSchema } from '../validation/university.schema.js'

const idSchema=z.string().uuid()
const listSchema=z.object({q:z.string().trim().optional(),status:z.string().optional(),type:z.string().optional(),page:z.coerce.number().int().min(1).default(1),limit:z.coerce.number().int().min(1).max(100).default(20),sortBy:z.string().optional(),sortOrder:z.enum(['asc','desc']).default('desc')})
const body=(req:Request)=>universityInputSchema.parse(req.body)

export async function listController(req:Request,res:Response){const query=listSchema.parse(req.query);res.json({data:await listUniversities({...query,sortBy:query.sortBy||'createdAt'})})}
export async function createController(req:Request,res:Response){try{const university=await createUniversity(body(req),req);res.status(201).json({data:university})}catch(error){mapUniqueError(error)}}
export async function getController(req:Request,res:Response){res.json({data:await getUniversity(idSchema.parse(req.params.id))})}
export async function updateController(req:Request,res:Response){try{res.json({data:await updateUniversity(idSchema.parse(req.params.id),body(req),req)})}catch(error){mapUniqueError(error)}}
export async function statusController(req:Request,res:Response){const id=idSchema.parse(req.params.id),input=universityStatusSchema.parse(req.body);res.json({data:await setUniversityStatus(id,input.status,req)})}
export async function activateController(req:Request,res:Response){res.json({data:await setUniversityStatus(idSchema.parse(req.params.id),'ACTIVE',req)})}
export async function suspendController(req:Request,res:Response){res.json({data:await setUniversityStatus(idSchema.parse(req.params.id),'SUSPENDED',req)})}
export async function deleteController(req:Request,res:Response){res.json({data:await softDeleteUniversity(idSchema.parse(req.params.id),req),message:'University deactivated. Tenant database has not been deleted.'})}
export async function provisionController(req:Request,res:Response){res.status(202).json({data:await provisionTenantDatabase(idSchema.parse(req.params.id),req)})}
export async function databaseStatusController(req:Request,res:Response){res.json({data:await tenantDatabaseStatus(idSchema.parse(req.params.id))})}
export async function verifyDatabaseController(req:Request,res:Response){res.json({data:await verifyTenantDatabase(idSchema.parse(req.params.id),req)})}
