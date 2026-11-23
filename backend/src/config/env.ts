import 'dotenv/config'
import { z } from 'zod'

const schema = z.object({
  DATABASE_URL: z.string().url(),
  POSTGRES_ADMIN_URL: z.string().url().optional(),
  TENANT_CONFIG_ENCRYPTION_KEY: z.string().optional(),
  TENANT_METRICS_INGEST_SECRET: z.string().min(32).optional(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('8h'),
  ADMIN_EMAIL: z.string().email().optional(),
  ADMIN_PASSWORD: z.string().min(12).optional(),
  API_PORT: z.coerce.number().int().positive().default(4000),
  WEB_ORIGIN: z.string().url().default('http://localhost:5173'),
  UPLOAD_DIR: z.string().default('backend/uploads'),
})

const parsed = schema.safeParse(process.env)
if (!parsed.success) {
  const problems = parsed.error.issues.map(issue => `${issue.path.join('.')}: ${issue.message}`).join('\n')
  throw new Error(`Invalid backend environment configuration:\n${problems}`)
}

export const env = parsed.data
