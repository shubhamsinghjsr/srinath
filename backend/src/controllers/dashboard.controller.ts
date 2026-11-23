import type { Request, Response } from 'express'
import { overview, recentActivities, subscriptionsOverview, systemHealth, universityStatistics } from '../services/dashboard.service.js'

export async function overviewController(_req:Request,res:Response){res.json({data:await overview()})}
export async function universityStatisticsController(req:Request,res:Response){const months=Math.max(1,Math.min(Number(req.query.months)||12,36));res.json({data:await universityStatistics(months)})}
export async function subscriptionsController(_req:Request,res:Response){res.json({data:await subscriptionsOverview()})}
export async function recentActivitiesController(req:Request,res:Response){const limit=Math.max(1,Math.min(Number(req.query.limit)||20,100));res.json({data:await recentActivities(limit)})}
export async function systemHealthController(_req:Request,res:Response){res.json({data:await systemHealth()})}
