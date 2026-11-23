import { Router } from 'express'
import { overviewController, recentActivitiesController, subscriptionsController, systemHealthController, universityStatisticsController } from '../controllers/dashboard.controller.js'
import { requireAuth, requireSuperAdmin } from '../middleware/auth.js'
import { asyncHandler } from '../utils/async-handler.js'

export const dashboardRouter=Router()
dashboardRouter.use(requireAuth,requireSuperAdmin)
dashboardRouter.get('/overview',asyncHandler(overviewController))
dashboardRouter.get('/university-statistics',asyncHandler(universityStatisticsController))
dashboardRouter.get('/subscriptions',asyncHandler(subscriptionsController))
dashboardRouter.get('/recent-activities',asyncHandler(recentActivitiesController))
dashboardRouter.get('/system-health',asyncHandler(systemHealthController))
