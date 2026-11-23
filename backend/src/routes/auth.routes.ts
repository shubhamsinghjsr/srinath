import { Router } from 'express'
import { rateLimit } from 'express-rate-limit'
import { institutionalLoginController, loginController, logoutController, meController } from '../controllers/auth.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { asyncHandler } from '../utils/async-handler.js'

export const authRouter = Router()
const loginLimit = rateLimit({ windowMs: 15 * 60 * 1000, limit: 10, standardHeaders: 'draft-8', legacyHeaders: false, message: { error: 'Too many login attempts. Try again later.' } })
authRouter.post('/login', loginLimit, asyncHandler(loginController))
authRouter.post('/institutional-login', loginLimit, asyncHandler(institutionalLoginController))
authRouter.post('/logout', requireAuth, asyncHandler(logoutController))
authRouter.get('/me', requireAuth, asyncHandler(meController))
