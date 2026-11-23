import { Router } from 'express'
import { archiveRecordController, createRecordController, getRecordController, listRecordsController, updateRecordController } from '../controllers/erp-record.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { asyncHandler } from '../utils/async-handler.js'

export const erpRecordRouter = Router()
erpRecordRouter.use(requireAuth)
erpRecordRouter.get('/', asyncHandler(listRecordsController))
erpRecordRouter.post('/', asyncHandler(createRecordController))
erpRecordRouter.get('/:id', asyncHandler(getRecordController))
erpRecordRouter.patch('/:id', asyncHandler(updateRecordController))
erpRecordRouter.delete('/:id', asyncHandler(archiveRecordController))
