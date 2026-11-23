import { z } from 'zod'

export const institutionalUserSchema = z.object({
  name: z.string().trim().min(2).max(160),
  email: z.email().max(255).transform(value => value.toLowerCase()),
  password: z.string().min(12).max(200),
  campusId: z.uuid().nullable().optional(),
  collegeId: z.uuid().nullable().optional(),
  roleCodes: z.array(z.string().trim().min(2).max(60)).min(1).max(20),
})
