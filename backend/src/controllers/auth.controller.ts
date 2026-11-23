import type { Request, Response } from 'express'
import { prisma } from '../db/prisma.js'
import { institutionalLoginSchema, loginSchema } from '../validation/auth.schema.js'
import { login, loginInstitutional, logout } from '../services/auth.service.js'

export async function loginController(req: Request, res: Response) {
  const input = loginSchema.parse(req.body)
  res.json({ data: await login(input.email, input.password, req) })
}

export async function logoutController(req: Request, res: Response) {
  await logout(req.auth!.userId, req.auth!.tokenId, req)
  res.status(204).end()
}

export async function institutionalLoginController(req: Request, res: Response) {
  const input = institutionalLoginSchema.parse(req.body)
  res.json({ data: await loginInstitutional(input.universityCode, input.email, input.password, req) })
}

export async function meController(req: Request, res: Response) {
  if (req.auth!.accountType === 'INSTITUTIONAL') {
    const user = await prisma.institutionalUser.findUnique({ where: { id: req.auth!.userId }, include: { userRoles: { include: { role: true } }, university: { select: { id: true, code: true, name: true } } } })
    return res.json({ data: user && { id: user.id, name: user.name, email: user.email, roles: user.userRoles.map(x => x.role.code), accountType: 'INSTITUTIONAL', university: user.university, campusId: user.campusId, collegeId: user.collegeId } })
  }
  const user = await prisma.platformUser.findUnique({ where: { id: req.auth!.userId }, include: { userRoles: { include: { role: true } } } })
  res.json({ data: user && { id: user.id, name: user.name, email: user.email, roles: user.userRoles.map(x => x.role.code), accountType: 'PLATFORM' } })
}
