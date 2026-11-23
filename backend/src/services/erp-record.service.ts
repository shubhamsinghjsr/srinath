import { Prisma } from '@prisma/client'
import type { Request } from 'express'
import { prisma } from '../db/prisma.js'
import { HttpError } from '../utils/http-error.js'
import { writeAudit } from './audit.service.js'
import type { erpRecordSchema, erpRecordUpdateSchema } from '../validation/erp-record.schema.js'
import type { z } from 'zod'

type Scope = { accountType: 'PLATFORM' | 'INSTITUTIONAL'; userId: string; roles: string[]; universityId?: string; campusId?: string | null; collegeId?: string | null }
type Input = z.infer<typeof erpRecordSchema>
type Update = z.infer<typeof erpRecordUpdateSchema>

function assertModuleAccess(scope: Scope, moduleCode: string) {
  if (scope.accountType === 'PLATFORM' || scope.roles.some(role => ['UNIVERSITY_ADMIN', 'SUPER_ADMIN'].includes(role))) return
  const code = moduleCode.toUpperCase()
  const grants: Record<string, string[]> = {
    REGISTRAR: ['UNIVERSITY', 'REGISTRATION', 'ACCREDITATION', 'AFFILIATION', 'ADMISSION', 'STUDENT', 'CERTIFICATE', 'ANNOUNCEMENT', 'DOCUMENT', 'ACADEMIC', 'APPROVAL'],
    HOD: ['ACADEMIC', 'ATTENDANCE', 'EXAM', 'STUDENT', 'PROGRAMME', 'PROGRAM', 'COURSE', 'DEPARTMENT', 'FACULTY', 'TIMETABLE', 'LMS', 'ASSIGNMENT', 'RESEARCH', 'SUPPORT'],
    FACULTY: ['ACADEMIC', 'ATTENDANCE', 'EXAM', 'STUDENT', 'TIMETABLE', 'LMS', 'ASSIGNMENT', 'RESEARCH', 'SUPPORT'],
    STUDENT: ['STUDENT', 'PROFILE', 'LIBRARY', 'SUPPORT', 'FEE', 'PLACEMENT', 'ALUMNI', 'LMS', 'ASSIGNMENT', 'CERTIFICATE', 'NOTIFICATION', 'ATTENDANCE', 'EXAM', 'TIMETABLE', 'HOSTEL', 'TRANSPORT'],
    FINANCE: ['FEE', 'FINANCE', 'PAYROLL', 'PURCHASE', 'INVENTORY', 'REPORT'],
    LIBRARIAN: ['LIBRARY', 'STUDENT', 'REPORT'],
    ADMISSION_OFFICER: ['ADMISSION', 'STUDENT', 'DOCUMENT', 'REPORT'],
    EXAM_CONTROLLER: ['EXAM', 'STUDENT', 'ATTENDANCE', 'ACADEMIC', 'REPORT'],
  }
  const allowed = scope.roles.flatMap(role => grants[role] ?? [])
  if (!allowed.some(keyword => code.includes(keyword))) throw new HttpError(403, 'Your role is not permitted to access this module')
}

function scopeWhere(scope: Scope, universityId?: string): Prisma.ErpRecordWhereInput {
  if (scope.accountType === 'PLATFORM') {
    if (!universityId) throw new HttpError(400, 'universityId is required for platform users')
    return { universityId }
  }
  if (!scope.universityId) throw new HttpError(403, 'University scope is missing from this account')
  const where: Prisma.ErpRecordWhereInput = { universityId: scope.universityId }
  if (scope.collegeId) where.collegeId = scope.collegeId
  else if (scope.campusId) where.OR = [{ campusId: scope.campusId }, { campusId: null, collegeId: null }]
  return where
}

async function verifyReferences(universityId: string, campusId?: string | null, collegeId?: string | null, academicSessionId?: string | null) {
  if (campusId && !await prisma.campus.findFirst({ where: { id: campusId, universityId, deletedAt: null }, select: { id: true } })) throw new HttpError(400, 'Campus does not belong to this university')
  if (collegeId && !await prisma.affiliatedCollege.findFirst({ where: { id: collegeId, universityId, deletedAt: null }, select: { id: true, campusId: true } })) throw new HttpError(400, 'College does not belong to this university')
  if (collegeId && campusId) {
    const college = await prisma.affiliatedCollege.findFirst({ where: { id: collegeId, universityId }, select: { campusId: true } })
    if (college?.campusId && college.campusId !== campusId) throw new HttpError(400, 'College does not belong to this campus')
  }
  if (academicSessionId && !await prisma.academicSession.findFirst({ where: { id: academicSessionId, universityId }, select: { id: true } })) throw new HttpError(400, 'Academic session does not belong to this university')
}

export async function listRecords(scope: Scope, query: { universityId?: string; moduleCode?: string; status?: string; q?: string; page: number; limit: number }) {
  if (scope.accountType === 'INSTITUTIONAL' && !query.moduleCode) throw new HttpError(400, 'moduleCode is required for institutional searches')
  if (query.moduleCode) assertModuleAccess(scope, query.moduleCode)
  const where: Prisma.ErpRecordWhereInput = scopeWhere(scope, query.universityId)
  if (query.moduleCode) where.moduleCode = query.moduleCode
  if (query.status) where.status = query.status
  if (query.q) where.AND = [...(where.AND ? (Array.isArray(where.AND) ? where.AND : [where.AND]) : []), { OR: [{ name: { contains: query.q, mode: 'insensitive' } }, { referenceCode: { contains: query.q, mode: 'insensitive' } }] }]
  const [items, total] = await Promise.all([prisma.erpRecord.findMany({ where, orderBy: { updatedAt: 'desc' }, skip: (query.page - 1) * query.limit, take: query.limit }), prisma.erpRecord.count({ where })])
  return { items, pagination: { page: query.page, limit: query.limit, total, pages: Math.ceil(total / query.limit) } }
}

export async function createRecord(scope: Scope, input: Input, req: Request) {
  assertModuleAccess(scope, input.moduleCode)
  const universityId = scope.accountType === 'INSTITUTIONAL' ? scope.universityId! : input.universityId
  if (!universityId) throw new HttpError(400, 'universityId is required')
  if (scope.accountType === 'INSTITUTIONAL' && ((scope.collegeId && input.collegeId && input.collegeId !== scope.collegeId) || (scope.campusId && input.campusId && input.campusId !== scope.campusId))) throw new HttpError(403, 'Cannot create a record outside your assigned scope')
  let campusId = input.campusId ?? null
  if (scope.accountType === 'INSTITUTIONAL') {
    if (scope.campusId) campusId = scope.campusId
    else if (scope.collegeId) {
      const college = await prisma.affiliatedCollege.findFirst({ where: { id: scope.collegeId, universityId }, select: { campusId: true } })
      if (input.campusId && college?.campusId !== input.campusId) throw new HttpError(403, 'Cannot create a record outside your assigned college')
      campusId = college?.campusId ?? null
    }
  }
  const collegeId = scope.accountType === 'INSTITUTIONAL' ? (scope.collegeId ?? input.collegeId ?? null) : input.collegeId ?? null
  await verifyReferences(universityId, campusId, collegeId, input.academicSessionId)
  const record = await prisma.erpRecord.create({ data: { universityId, campusId, collegeId, academicSessionId: input.academicSessionId ?? null, createdById: scope.accountType === 'INSTITUTIONAL' ? scope.userId : null, moduleCode: input.moduleCode.toUpperCase(), recordType: input.recordType, name: input.name, referenceCode: input.referenceCode ?? null, category: input.category ?? null, status: input.status, payload: input.payload as Prisma.InputJsonValue } })
  await writeAudit({ req, actorUserId: scope.accountType === 'PLATFORM' ? scope.userId : undefined, action: 'ERP_RECORD_CREATED', entityType: 'ErpRecord', entityId: record.id, universityId, metadata: { moduleCode: record.moduleCode } })
  return record
}

export async function getRecord(scope: Scope, id: string, universityId?: string) {
  const record = await prisma.erpRecord.findFirst({ where: { AND: [scopeWhere(scope, universityId), { id }] } })
  if (!record) throw new HttpError(404, 'Record not found')
  assertModuleAccess(scope, record.moduleCode)
  return record
}

export async function updateRecord(scope: Scope, id: string, input: Update, req: Request, universityId?: string) {
  const prior = await getRecord(scope, id, universityId)
  if (scope.accountType === 'INSTITUTIONAL') {
    if (scope.collegeId && input.collegeId && input.collegeId !== scope.collegeId) throw new HttpError(403, 'Cannot move a record outside your assigned college')
    if (scope.campusId && input.campusId && input.campusId !== scope.campusId) throw new HttpError(403, 'Cannot move a record outside your assigned campus')
    if (scope.collegeId && input.campusId) {
      const college = await prisma.affiliatedCollege.findFirst({ where: { id: scope.collegeId, universityId: prior.universityId }, select: { campusId: true } })
      if (college?.campusId !== input.campusId) throw new HttpError(403, 'Cannot move a record outside your assigned college')
    }
  }
  const campusId = input.campusId === undefined ? prior.campusId : input.campusId
  const collegeId = input.collegeId === undefined ? prior.collegeId : input.collegeId
  const sessionId = input.academicSessionId === undefined ? prior.academicSessionId : input.academicSessionId
  await verifyReferences(prior.universityId, campusId, collegeId, sessionId)
  const record = await prisma.erpRecord.update({ where: { id }, data: { name: input.name, recordType: input.recordType, referenceCode: input.referenceCode, category: input.category, status: input.status, payload: input.payload as Prisma.InputJsonValue | undefined, campusId, collegeId, academicSessionId: sessionId } })
  await writeAudit({ req, actorUserId: scope.accountType === 'PLATFORM' ? scope.userId : undefined, action: 'ERP_RECORD_UPDATED', entityType: 'ErpRecord', entityId: id, universityId: prior.universityId, metadata: { moduleCode: prior.moduleCode } })
  return record
}

export async function archiveRecord(scope: Scope, id: string, req: Request, universityId?: string) {
  const prior = await getRecord(scope, id, universityId)
  const record = await prisma.erpRecord.update({ where: { id }, data: { status: 'ARCHIVED' } })
  await writeAudit({ req, actorUserId: scope.accountType === 'PLATFORM' ? scope.userId : undefined, action: 'ERP_RECORD_ARCHIVED', entityType: 'ErpRecord', entityId: id, universityId: prior.universityId })
  return record
}
