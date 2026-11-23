import { randomBytes } from 'node:crypto'
import { Prisma, type UniversityStatus } from '@prisma/client'
import type { Request } from 'express'
import { prisma } from '../db/prisma.js'
import { HttpError } from '../utils/http-error.js'
import { writeAudit } from './audit.service.js'
import type { z } from 'zod'
import type { universityInputSchema } from '../validation/university.schema.js'

type UniversityInput = z.infer<typeof universityInputSchema>
type UniversityRequest = Request & { file?: Express.Multer.File }
const includeRelations = { contact: true, addresses: true, accreditation: true, branding: true, tenantDatabase: { select: { databaseName: true, status: true, lastVerifiedAt: true, lastError: true } } } as const

function serializeUniversity<T extends { addresses: { addressType: string }[] }>(university: T) {
  return { ...university, address: university.addresses.find(address => address.addressType === 'REGISTERED') ?? university.addresses[0] ?? null }
}

function registrationCode() { return `TCU-${randomBytes(4).toString('hex').toUpperCase()}` }
function getLogoPath(req: UniversityRequest) { return req.file ? `/uploads/universities/${req.file.filename}` : undefined }

function createRelations(input: UniversityInput, req: UniversityRequest) {
  return {
    contact: { create: { personName: input.contactPersonName, designation: input.contactPersonDesignation, email: input.contactPersonEmail, mobile: input.contactPersonMobile } },
    addresses: { create: { addressLine: input.addressLine, city: input.city, state: input.state, country: input.country, pinCode: input.pinCode, addressType: 'REGISTERED' } },
    accreditation: { create: { body: input.accreditationBody, grade: input.accreditationGrade, validUntil: input.accreditationValidUntil, details: input.accreditationDetails } },
    branding: { create: { logoPath: getLogoPath(req), primaryColor: input.primaryColor, secondaryColor: input.secondaryColor } },
    tenantDatabase: { create: { databaseName: `pending_${randomBytes(6).toString('hex')}`, status: 'NOT_STARTED' as const } },
  }
}

export async function listUniversities(query: { q?: string; status?: string; type?: string; page: number; limit: number; sortBy: string; sortOrder: 'asc'|'desc' }) {
  const where: Prisma.UniversityWhereInput = { deletedAt: null }
  if (query.q) where.OR = [{ name: { contains: query.q, mode: 'insensitive' } }, { code: { contains: query.q, mode: 'insensitive' } }, { officialEmail: { contains: query.q, mode: 'insensitive' } }]
  if (query.status && ['PENDING','ACTIVE','SUSPENDED','INACTIVE'].includes(query.status)) where.status = query.status as UniversityStatus
  if (query.type && ['CENTRAL','STATE','PUBLIC','PRIVATE','DEEMED','AUTONOMOUS','OTHER'].includes(query.type)) where.type = query.type as UniversityInput['type']
  const allowedSort = ['name','code','createdAt','updatedAt','status'] as const
  const sortBy = allowedSort.includes(query.sortBy as typeof allowedSort[number]) ? query.sortBy as typeof allowedSort[number] : 'createdAt'
  const [items,total] = await Promise.all([
    prisma.university.findMany({ where, include: includeRelations, orderBy: { [sortBy]: query.sortOrder }, skip: (query.page-1)*query.limit, take: query.limit }),
    prisma.university.count({ where }),
  ])
  return { items: items.map(serializeUniversity), pagination: { page: query.page, limit: query.limit, total, pages: Math.ceil(total/query.limit) } }
}

export async function createUniversity(input: UniversityInput, req: UniversityRequest) {
  const defaultRoles = [
    ['UNIVERSITY_ADMIN', 'University Administrator'], ['REGISTRAR', 'Registrar'], ['HOD', 'Head of Department'],
    ['FACULTY', 'Faculty'], ['STUDENT', 'Student'], ['FINANCE', 'Finance Officer'], ['LIBRARIAN', 'Librarian'],
    ['ADMISSION_OFFICER', 'Admission Officer'], ['EXAM_CONTROLLER', 'Controller of Examinations'],
  ] as const
  const university = await prisma.university.create({ data: { ...{
    code: registrationCode(), name: input.name, shortName: input.shortName, type: input.type,
    establishmentYear: input.establishmentYear, registrationNumber: input.registrationNumber,
    website: input.website, officialEmail: input.officialEmail.toLowerCase(), contactNumber: input.contactNumber,
  }, ...createRelations(input, req), institutionalRoles: { create: defaultRoles.map(([code, name]) => ({ code, name, systemRole: true })) } }, include: includeRelations })
  await writeAudit({ req, universityId: university.id, action: 'UNIVERSITY_CREATED', entityType: 'University', entityId: university.id, metadata: { code: university.code, name: university.name } })
  return serializeUniversity(university)
}

export async function getUniversity(id: string) {
  const university = await prisma.university.findFirst({ where: { id, deletedAt: null }, include: includeRelations })
  if (!university) throw new HttpError(404, 'University not found')
  return serializeUniversity(university)
}

export async function updateUniversity(id: string, input: UniversityInput, req: UniversityRequest) {
  await getUniversity(id)
  const university = await prisma.university.update({
    where: { id },
    data: {
      name: input.name, shortName: input.shortName, type: input.type, establishmentYear: input.establishmentYear,
      registrationNumber: input.registrationNumber, website: input.website, officialEmail: input.officialEmail.toLowerCase(), contactNumber: input.contactNumber,
      contact: { upsert: { create: { personName: input.contactPersonName, designation: input.contactPersonDesignation, email: input.contactPersonEmail, mobile: input.contactPersonMobile }, update: { personName: input.contactPersonName, designation: input.contactPersonDesignation, email: input.contactPersonEmail, mobile: input.contactPersonMobile } } },
      addresses: { upsert: { where: { universityId_addressType: { universityId: id, addressType: 'REGISTERED' } }, create: { addressLine: input.addressLine, city: input.city, state: input.state, country: input.country, pinCode: input.pinCode, addressType: 'REGISTERED' }, update: { addressLine: input.addressLine, city: input.city, state: input.state, country: input.country, pinCode: input.pinCode } } },
      accreditation: { upsert: { create: { body: input.accreditationBody, grade: input.accreditationGrade, validUntil: input.accreditationValidUntil, details: input.accreditationDetails }, update: { body: input.accreditationBody, grade: input.accreditationGrade, validUntil: input.accreditationValidUntil, details: input.accreditationDetails } } },
      branding: { upsert: { create: { logoPath: getLogoPath(req), primaryColor: input.primaryColor, secondaryColor: input.secondaryColor }, update: { ...(getLogoPath(req) ? { logoPath: getLogoPath(req) } : {}), primaryColor: input.primaryColor, secondaryColor: input.secondaryColor } } },
    }, include: includeRelations,
  })
  await writeAudit({ req, universityId: id, action: 'UNIVERSITY_UPDATED', entityType: 'University', entityId: id })
  return serializeUniversity(university)
}

export async function setUniversityStatus(id: string, status: UniversityStatus, req: Request) {
  await getUniversity(id)
  const university = await prisma.university.update({ where: { id }, data: { status }, include: includeRelations })
  await writeAudit({ req, universityId: id, action: `UNIVERSITY_${status}`, entityType: 'University', entityId: id })
  return serializeUniversity(university)
}

export async function softDeleteUniversity(id: string, req: Request) {
  await getUniversity(id)
  const university = await prisma.university.update({ where: { id }, data: { status: 'INACTIVE', deletedAt: new Date() }, include: includeRelations })
  await writeAudit({ req, universityId: id, action: 'UNIVERSITY_SOFT_DELETED', entityType: 'University', entityId: id, metadata: { tenantDatabasePreserved: true } })
  return serializeUniversity(university)
}

export function mapUniqueError(error: unknown): never {
  if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') throw new HttpError(409, 'University registration number or generated code already exists')
  throw error
}
