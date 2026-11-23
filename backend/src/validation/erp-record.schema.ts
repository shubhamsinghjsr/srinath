import { z } from 'zod'

export const erpRecordSchema = z.object({
  moduleCode: z.string().trim().min(2).max(80).regex(/^[A-Za-z0-9_-]+$/),
  recordType: z.string().trim().min(2).max(100),
  name: z.string().trim().min(1).max(200),
  referenceCode: z.string().trim().max(100).nullable().optional(),
  category: z.string().trim().max(100).nullable().optional(),
  status: z.string().trim().min(1).max(40).default('ACTIVE'),
  payload: z.record(z.string(), z.unknown()).default({}),
  universityId: z.uuid().optional(),
  campusId: z.uuid().nullable().optional(),
  collegeId: z.uuid().nullable().optional(),
  academicSessionId: z.uuid().nullable().optional(),
})

export const erpRecordUpdateSchema = erpRecordSchema.omit({ moduleCode: true, universityId: true }).partial()
