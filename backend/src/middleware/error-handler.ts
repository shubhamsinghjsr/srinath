import type { ErrorRequestHandler, RequestHandler } from 'express'
import { Prisma } from '@prisma/client'
import { ZodError } from 'zod'
import multer from 'multer'
import { HttpError } from '../utils/http-error.js'

export const notFound:RequestHandler=(req,_res,next)=>next(new HttpError(404,`Route not found: ${req.method} ${req.path}`))

export const errorHandler:ErrorRequestHandler=(error,req,res,_next)=>{
  if(error instanceof ZodError)return res.status(422).json({error:'Validation failed',details:error.issues.map(issue=>({field:issue.path.join('.'),message:issue.message}))})
  if(error instanceof multer.MulterError)return res.status(error.code==='LIMIT_FILE_SIZE'?413:400).json({error:error.message})
  if(error instanceof HttpError)return res.status(error.statusCode).json({error:error.message,details:error.details})
  if(error instanceof Prisma.PrismaClientKnownRequestError){
    if(error.code==='P2002')return res.status(409).json({error:'A record with one of these unique fields already exists'})
    if(error.code==='P2025')return res.status(404).json({error:'Requested record was not found'})
    if(error.code==='P2003')return res.status(409).json({error:'This record is referenced by other records'})
  }
  if(error instanceof Prisma.PrismaClientInitializationError)return res.status(503).json({error:'Database connection failed. Check that PostgreSQL is running and the database credentials in .env are correct.'})
  console.error(JSON.stringify({level:'error',message:error instanceof Error?error.message:'Unknown error',method:req.method,path:req.path}))
  return res.status(500).json({error:'Internal server error'})
}
