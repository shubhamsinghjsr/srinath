import type { RequestHandler } from 'express'
import jwt, { type JwtPayload } from 'jsonwebtoken'
import { env } from '../config/env.js'
import { prisma } from '../db/prisma.js'
import { HttpError } from '../utils/http-error.js'
import { asyncHandler } from '../utils/async-handler.js'

export type AuthUser = { userId: string; email: string; roles: string[]; tokenId: string; accountType: 'PLATFORM' | 'INSTITUTIONAL'; universityId?: string; campusId?: string | null; collegeId?: string | null }

export const requireAuth: RequestHandler = asyncHandler(async (req, _res, next) => {
  const [scheme, token] = (req.header('authorization') || '').split(' ')
  if (scheme !== 'Bearer' || !token) throw new HttpError(401, 'Authentication required')
  let claims: JwtPayload
  try { claims = jwt.verify(token, env.JWT_SECRET) as JwtPayload } catch { throw new HttpError(401, 'Invalid or expired access token') }
  if (typeof claims.sub !== 'string' || typeof claims.jti !== 'string') throw new HttpError(401, 'Invalid access token')
  if (claims.accountType === 'INSTITUTIONAL') {
    const login = await prisma.institutionalLoginLog.findUnique({ where: { tokenId: claims.jti }, include: { user: { include: { userRoles: { include: { role: true } } } } } })
    if (!login?.user || login.revokedAt || !login.user.active || login.user.id !== claims.sub || !login.user.universityId) throw new HttpError(401, 'Session is no longer active')
    req.auth = { userId: login.user.id, email: login.user.email, roles: login.user.userRoles.map(x => x.role.code), tokenId: claims.jti, accountType: 'INSTITUTIONAL', universityId: login.user.universityId, campusId: login.user.campusId, collegeId: login.user.collegeId }
  } else {
    const login = await prisma.platformLoginLog.findUnique({ where: { tokenId: claims.jti }, include: { user: { include: { userRoles: { include: { role: true } } } } } })
    if (!login?.user || login.revokedAt || !login.user.active || login.user.id !== claims.sub) throw new HttpError(401, 'Session is no longer active')
    req.auth = { userId: login.user.id, email: login.user.email, roles: login.user.userRoles.map(x => x.role.code), tokenId: claims.jti, accountType: 'PLATFORM' }
  }
  next()
})

export const requireSuperAdmin: RequestHandler = (req, _res, next) => {
  if (req.auth?.accountType !== 'PLATFORM' || !req.auth.roles.includes('SUPER_ADMIN')) return next(new HttpError(403, 'Super Admin access required'))
  next()
}

export const requireInstitutional: RequestHandler = (req, _res, next) => {
  if (req.auth?.accountType !== 'INSTITUTIONAL') return next(new HttpError(403, 'Institutional account required'))
  next()
}
