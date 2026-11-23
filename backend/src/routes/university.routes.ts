import { Router } from 'express'
import { activateController, createController, databaseStatusController, deleteController, getController, listController, provisionController, statusController, suspendController, updateController, verifyDatabaseController } from '../controllers/university.controller.js'
import { requireAuth, requireSuperAdmin } from '../middleware/auth.js'
import { universityLogoUpload } from '../middleware/upload.js'
import { asyncHandler } from '../utils/async-handler.js'
import { createInstitutionalUserController } from '../controllers/institutional-user.controller.js'
import { createCampusController, listCampusesController } from '../controllers/campus.controller.js'

export const universityRouter=Router()
universityRouter.use(requireAuth,requireSuperAdmin)
universityRouter.get('/',asyncHandler(listController))
universityRouter.post('/',universityLogoUpload.single('logo'),asyncHandler(createController))
universityRouter.get('/:id',asyncHandler(getController))
universityRouter.put('/:id',universityLogoUpload.single('logo'),asyncHandler(updateController))
universityRouter.patch('/:id/status',asyncHandler(statusController))
universityRouter.post('/:id/activate',asyncHandler(activateController))
universityRouter.post('/:id/suspend',asyncHandler(suspendController))
universityRouter.delete('/:id',asyncHandler(deleteController))
universityRouter.post('/:id/provision-database',asyncHandler(provisionController))
universityRouter.get('/:id/database-status',asyncHandler(databaseStatusController))
universityRouter.post('/:id/verify-database',asyncHandler(verifyDatabaseController))
universityRouter.post('/:id/users',asyncHandler(createInstitutionalUserController))
universityRouter.get('/:id/campuses',asyncHandler(listCampusesController))
universityRouter.post('/:id/campuses',asyncHandler(createCampusController))
