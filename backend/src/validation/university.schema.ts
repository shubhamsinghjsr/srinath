import { z } from 'zod'

const optionalText = (max: number) => z.preprocess(v => v === '' ? undefined : v, z.string().trim().max(max).optional())
const optionalYear = z.preprocess(v => v === '' || v == null ? undefined : Number(v), z.number().int().min(1500).max(new Date().getFullYear()).optional())

export const universityInputSchema = z.object({
  name: z.string().trim().min(2).max(180),
  shortName: optionalText(60),
  type: z.enum(['CENTRAL','STATE','PUBLIC','PRIVATE','DEEMED','AUTONOMOUS','OTHER']),
  establishmentYear: optionalYear,
  registrationNumber: optionalText(100),
  website: z.preprocess(v => v === '' || v == null ? undefined : v, z.url().max(255).optional()),
  officialEmail: z.email().max(255),
  contactNumber: z.string().trim().min(7).max(40),
  contactPersonName: z.string().trim().min(2).max(160),
  contactPersonDesignation: z.string().trim().min(2).max(120),
  contactPersonEmail: z.email().max(255),
  contactPersonMobile: z.string().trim().min(7).max(40),
  addressLine: z.string().trim().min(3).max(255),
  city: z.string().trim().min(2).max(120),
  state: z.string().trim().min(2).max(120),
  country: z.string().trim().min(2).max(100),
  pinCode: z.string().trim().min(3).max(20),
  accreditationBody: optionalText(120),
  accreditationGrade: optionalText(30),
  accreditationValidUntil: z.preprocess(v => v === '' || v == null ? undefined : new Date(String(v)), z.date().optional()),
  accreditationDetails: optionalText(5000),
  primaryColor: z.preprocess(v => v === '' ? undefined : v, z.string().regex(/^#[0-9a-fA-F]{6}$/).optional()),
  secondaryColor: z.preprocess(v => v === '' ? undefined : v, z.string().regex(/^#[0-9a-fA-F]{6}$/).optional()),
}).strict()

export const universityStatusSchema = z.object({ status: z.enum(['ACTIVE','SUSPENDED','INACTIVE','PENDING']) })
