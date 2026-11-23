import type { Request } from 'express'
import { prisma } from '../db/prisma.js'

export async function writeAudit(input: {
  req?: Request
  actorUserId?: string | null
  universityId?: string | null
  action: string
  entityType: string
  entityId?: string | null
  metadata?: Record<string, unknown>
}) {
  if (input.req?.auth?.accountType === 'INSTITUTIONAL') {
    const universityId = input.universityId ?? input.req.auth.universityId
    if (!universityId) throw new Error('Tenant audit requires a university scope')
    await prisma.tenantAuditLog.create({
      data: {
        universityId,
        institutionalUserId: input.req.auth.userId,
        action: input.action,
        entityType: input.entityType,
        entityId: input.entityId ?? null,
        metadata: input.metadata as object | undefined,
        ipAddress: input.req.ip,
      },
    })
    return
  }
  await prisma.platformAuditLog.create({
    data: {
      actorUserId: input.actorUserId ?? input.req?.auth?.userId ?? null,
      universityId: input.universityId ?? null,
      action: input.action,
      entityType: input.entityType,
      entityId: input.entityId ?? null,
      metadata: input.metadata as object | undefined,
      ipAddress: input.req?.ip,
    },
  })
}
