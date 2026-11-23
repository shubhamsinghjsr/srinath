import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { randomUUID } from 'node:crypto'
import type { Request } from 'express'
import { env } from '../config/env.js'
import { prisma } from '../db/prisma.js'
import { HttpError } from '../utils/http-error.js'
import { writeAudit } from './audit.service.js'

export async function login(email: string, password: string, req: Request) {
  const user = await prisma.platformUser.findUnique({ where: { email: email.toLowerCase() }, include: { userRoles: { include: { role: true } } } })
  const valid = Boolean(user && user.active && await bcrypt.compare(password, user.passwordHash))
  const tokenId = randomUUID()
  await prisma.platformLoginLog.create({ data: { userId: user?.id, email: email.toLowerCase(), succeeded: valid, tokenId: valid ? tokenId : null, ipAddress: req.ip, userAgent: req.header('user-agent')?.slice(0, 500) } })
  if (!valid || !user) throw new HttpError(401, 'Email ya password sahi nahi hai, ya account inactive hai')
  if (!user.userRoles.some(item => item.role.code === 'SUPER_ADMIN')) throw new HttpError(403, 'This backend is currently limited to Super Admin access')
  await prisma.platformUser.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } })
  await writeAudit({ req, actorUserId: user.id, action: 'AUTH_LOGIN', entityType: 'PlatformUser', entityId: user.id })
  const token = jwt.sign({ email: user.email, roles: user.userRoles.map(x => x.role.code) }, env.JWT_SECRET, { subject: user.id, jwtid: tokenId, expiresIn: env.JWT_EXPIRES_IN as jwt.SignOptions['expiresIn'] })
  return { token, user: { id: user.id, name: user.name, email: user.email, roles: user.userRoles.map(x => x.role.code), accountType: 'PLATFORM' as const } }
}

export async function logout(userId: string, tokenId: string, req: Request) {
  if (req.auth?.accountType === 'INSTITUTIONAL') {
    await prisma.institutionalLoginLog.updateMany({ where: { userId, tokenId, revokedAt: null }, data: { revokedAt: new Date() } })
    await prisma.tenantAuditLog.create({ data: { universityId: req.auth.universityId!, institutionalUserId: userId, action: 'AUTH_LOGOUT', entityType: 'InstitutionalUser', entityId: userId, ipAddress: req.ip } })
  } else {
    await prisma.platformLoginLog.updateMany({ where: { userId, tokenId, revokedAt: null }, data: { revokedAt: new Date() } })
    await writeAudit({ req, actorUserId: userId, action: 'AUTH_LOGOUT', entityType: 'PlatformUser', entityId: userId })
  }
}

export async function loginInstitutional(universityCode: string, email: string, password: string, req: Request) {
  const university = await prisma.university.findFirst({ where: { code: universityCode.toUpperCase(), status: 'ACTIVE', deletedAt: null } })
  const user = university ? await prisma.institutionalUser.findUnique({ where: { universityId_email: { universityId: university.id, email: email.toLowerCase() } }, include: { userRoles: { include: { role: true } } } }) : null
  const valid = Boolean(user && user.active && await bcrypt.compare(password, user.passwordHash))
  const tokenId = randomUUID()
  await prisma.institutionalLoginLog.create({ data: { userId: user?.id, universityId: university?.id, email: email.toLowerCase(), succeeded: valid, tokenId: valid ? tokenId : null, ipAddress: req.ip } })
  if (!valid || !user || !university) throw new HttpError(401, 'University code, email, or password is incorrect, or account is inactive')
  await prisma.institutionalUser.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } })
  await prisma.tenantAuditLog.create({ data: { universityId: university.id, institutionalUserId: user.id, action: 'AUTH_LOGIN', entityType: 'InstitutionalUser', entityId: user.id, ipAddress: req.ip } })
  const roles = user.userRoles.map(x => x.role.code)
  const token = jwt.sign({ email: user.email, roles, accountType: 'INSTITUTIONAL', universityId: university.id, campusId: user.campusId, collegeId: user.collegeId }, env.JWT_SECRET, { subject: user.id, jwtid: tokenId, expiresIn: env.JWT_EXPIRES_IN as jwt.SignOptions['expiresIn'] })
  return { token, user: { id: user.id, name: user.name, email: user.email, roles, accountType: 'INSTITUTIONAL', university: { id: university.id, code: university.code, name: university.name }, campusId: user.campusId, collegeId: user.collegeId } }
}
