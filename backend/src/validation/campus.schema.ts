import { z } from 'zod'

export const campusSchema = z.object({
  name: z.string().trim().min(2).max(180),
  code: z.preprocess(value => value === '' ? undefined : value, z.string().trim().min(2).max(40).optional()),
  campusType: z.string().trim().min(2).max(60),
  city: z.preprocess(value => value === '' ? undefined : value, z.string().trim().max(120).optional()),
  addressLine: z.preprocess(value => value === '' ? undefined : value, z.string().trim().max(255).optional()),
  status: z.enum(['ACTIVE','INACTIVE']).default('ACTIVE'),
})
