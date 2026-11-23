import path from 'node:path'
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import { env } from './config/env.js'
import { authRouter } from './routes/auth.routes.js'
import { dashboardRouter } from './routes/dashboard.routes.js'
import { universityRouter } from './routes/university.routes.js'
import { tenantMetricsRouter } from './routes/tenant-metrics.routes.js'
import { erpRecordRouter } from './routes/erp-record.routes.js'
import { errorHandler, notFound } from './middleware/error-handler.js'

export const app=express()
app.disable('x-powered-by')
app.set('trust proxy',1)
app.use(helmet())
app.use(cors({origin:(origin,callback)=>{const localViteOrigin=/^http:\/\/(localhost|127\.0\.0\.1):517\d+$/.test(origin||'');if(!origin||origin===env.WEB_ORIGIN||localViteOrigin)return callback(null,true);callback(new Error('Origin is not allowed by CORS'))},credentials:false,methods:['GET','POST','PUT','PATCH','DELETE','OPTIONS'],allowedHeaders:['Content-Type','Authorization','X-Tenant-Code','X-Timestamp','X-Signature']}))
app.use(express.json({limit:'1mb'}))
app.use(express.urlencoded({extended:false,limit:'1mb'}))
app.get('/api/v1/health',(_req,res)=>res.json({data:{status:'ok',time:new Date().toISOString()}}))
app.use('/uploads/universities',express.static(path.resolve(process.cwd(),env.UPLOAD_DIR,'universities'),{fallthrough:false,maxAge:'1d',immutable:false}))
app.use('/api/v1/auth',authRouter)
app.use('/api/v1/erp/records',erpRecordRouter)
app.use('/api/v1/tenant-metrics',tenantMetricsRouter)
app.use('/api/v1/platform/dashboard',dashboardRouter)
app.use('/api/v1/platform/universities',universityRouter)
app.use(notFound)
app.use(errorHandler)
