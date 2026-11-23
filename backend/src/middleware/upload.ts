import { mkdirSync } from 'node:fs'
import { randomUUID } from 'node:crypto'
import path from 'node:path'
import multer from 'multer'
import { env } from '../config/env.js'
import { HttpError } from '../utils/http-error.js'

const logoDirectory=path.resolve(process.cwd(),env.UPLOAD_DIR,'universities')
mkdirSync(logoDirectory,{recursive:true})
const allowed=new Set(['image/png','image/jpeg','image/webp'])

export const universityLogoUpload=multer({
  storage:multer.diskStorage({destination:logoDirectory,filename:(_req,file,cb)=>{const ext=file.mimetype==='image/png'?'.png':file.mimetype==='image/webp'?'.webp':'.jpg';cb(null,`${Date.now()}-${randomUUID()}${ext}`)}}),
  limits:{fileSize:4*1024*1024,files:1},
  fileFilter:(_req,file,cb)=>allowed.has(file.mimetype)?cb(null,true):cb(new HttpError(415,'Logo must be a PNG, JPEG, or WebP image')),
})
