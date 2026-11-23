import bcrypt from 'bcrypt'
import type { Request, Response } from 'express'
import { prisma } from '../db/prisma.js'
import { HttpError } from '../utils/http-error.js'
import { institutionalUserSchema } from '../validation/institutional-user.schema.js'
import { writeAudit } from '../services/audit.service.js'

export async function createInstitutionalUserController(req: Request, res: Response) {
  const universityId = String(req.params.id)
  const input = institutionalUserSchema.parse(req.body)
  const university = await prisma.university.findFirst({ where: { id: universityId, deletedAt: null } })
  if (!university) throw new HttpError(404, 'University not found')
  if (input.campusId) {
    const campus = await prisma.campus.findFirst({ where: { id: input.campusId, universityId, deletedAt: null } })
    if (!campus) throw new HttpError(400, 'Selected campus does not belong to this university')
  }
  if (input.collegeId) {
    const college = await prisma.affiliatedCollege.findFirst({ where: { id: input.collegeId, universityId, deletedAt: null } })
    if (!college) throw new HttpError(400, 'Selected college does not belong to this university')
  }
  if (input.collegeId && input.campusId) {
    const college = await prisma.affiliatedCollege.findFirst({ where: { id: input.collegeId, universityId, campusId: input.campusId } })
    if (!college) throw new HttpError(400, 'Selected college does not belong to this campus')
  }
  const roles = await prisma.institutionalRole.findMany({ where: { universityId, code: { in: input.roleCodes } } })
  if (roles.length !== new Set(input.roleCodes).size) throw new HttpError(400, 'All roles must exist in the selected university')
  const passwordHash = await bcrypt.hash(input.password, 12)
  const user = await prisma.institutionalUser.create({ data: { universityId, campusId: input.campusId ?? null, collegeId: input.collegeId ?? null, name: input.name, email: input.email, passwordHash, userRoles: { create: roles.map(role => ({ roleId: role.id })) } }, include: { userRoles: { include: { role: true } } } })
  await writeAudit({ req, actorUserId: req.auth!.userId, action: 'INSTITUTIONAL_USER_CREATED', entityType: 'InstitutionalUser', entityId: user.id, universityId, metadata: { email: user.email, roleCodes: roles.map(role => role.code) } })
  res.status(201).json({ data: { id: user.id, name: user.name, email: user.email, universityId, campusId: user.campusId, collegeId: user.collegeId, roles: user.userRoles.map(item => item.role.code) } })
}
