import type { Request, Response } from 'express'
import { z } from 'zod'
import { archiveRecord, createRecord, getRecord, listRecords, updateRecord } from '../services/erp-record.service.js'
import { erpRecordSchema, erpRecordUpdateSchema } from '../validation/erp-record.schema.js'

const querySchema = z.object({ universityId: z.uuid().optional(), moduleCode: z.string().max(80).optional(), status: z.string().max(40).optional(), q: z.string().trim().max(200).optional(), page: z.coerce.number().int().min(1).default(1), limit: z.coerce.number().int().min(1).max(100).default(20) })
const scope = (req: Request) => ({ accountType: req.auth!.accountType, userId: req.auth!.userId, roles: req.auth!.roles, universityId: req.auth!.universityId, campusId: req.auth!.campusId, collegeId: req.auth!.collegeId })

export async function listRecordsController(req: Request, res: Response) { const query = querySchema.parse(req.query); res.json({ data: await listRecords(scope(req), query) }) }
export async function createRecordController(req: Request, res: Response) { const input = erpRecordSchema.parse(req.body); res.status(201).json({ data: await createRecord(scope(req), input, req) }) }
export async function getRecordController(req: Request, res: Response) { res.json({ data: await getRecord(scope(req), String(req.params.id), req.query.universityId ? z.uuid().parse(req.query.universityId) : undefined) }) }
export async function updateRecordController(req: Request, res: Response) { const input = erpRecordUpdateSchema.parse(req.body); res.json({ data: await updateRecord(scope(req), String(req.params.id), input, req, req.query.universityId ? z.uuid().parse(req.query.universityId) : undefined) }) }
export async function archiveRecordController(req: Request, res: Response) { res.json({ data: await archiveRecord(scope(req), String(req.params.id), req, req.query.universityId ? z.uuid().parse(req.query.universityId) : undefined) }) }
