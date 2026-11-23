# Implementation status

## Implemented

- Additive Prisma schema for the shared PostgreSQL multi-university ERP database: university and campus structure, academic operations, admission, student, HR, attendance, examinations, fees, library, hostel, transport, timetable, research, placement, LMS, support, alumni, inventory, dashboards, documents, notifications, approvals, audit and reports.
- Institutional user/role/permission tables, user-role junctions, scoped institutional login/session history, tenant audit logs and default institutional roles created when a university is registered.
- Super Admin can create a university user with a hashed password; the login screen offers separate Super Admin and university-user sign-in. Institutional sessions are routed to role-filtered workspaces.
- Bcrypt credential storage, JWT platform and institutional login, protected routes, session revocation, role gates and tenant scoping for generic ERP records.
- Super Admin endpoint to create a university-scoped account; it validates that roles/campus/college belong to the university and returns no password hash or plaintext password.
- Generic tenant record list/create/view/update/archive API with validation, campus/college/session ownership checks, module role checks, pagination/search and audit logging.
- Super Admin module record list and generic Add forms now load/save `erp_records` for the explicitly selected university; the selected university is never silently changed when more than one exists.
- Campus Management loads campus records for the selected university and creates rows through university-scoped endpoints. Registering a university immediately refreshes and selects it in the workspace.
- University profile and management APIs, live dashboard APIs, signed aggregate metric ingestion and CSV frontend features that existed before this database expansion.
- Inventory/mapping/API/ER documentation in `docs/database`. Database inventory can be rechecked with `node backend/scripts/inventory-db.mjs`.

## Database migrations and safety

- Primary database remains `techcoder_platform` on the existing PostgreSQL instance.
- All 4 migrations are applied: `20261118_platform_init`, `20261119_full_erp_expansion`, `20261119_institutional_login_scope`, and `20261119_data_validation_checks`.
- `prisma migrate status` reports the schema up to date; Prisma schema-to-database diff returns an empty migration.
- Database currently has 99 public base tables: 98 application tables plus `_prisma_migrations`.
- Existing platform user, roles/permissions, audit history and login history were preserved. No table was dropped/truncated and no records were deleted.
- The full-ERP migration drops only the old unique index on `university_addresses.universityId` to allow multiple address types; that table was empty at the time of migration. Eleven database check constraints validate key date and amount ranges.
- Backups before schema changes are in the Git-ignored `backups` directory, including `techcoder_platform_before_full_erp_20261119.dump` and the later auth-scope backup.

## Verified in this work

- `npx prisma validate --schema backend/prisma/schema.prisma` passed.
- `npm run prisma:deploy` applied the tenant-scope migration successfully.
- `npx prisma migrate status --schema backend/prisma/schema.prisma` reports all migrations applied.
- `npx prisma migrate diff --from-schema-datasource backend/prisma/schema.prisma --to-schema-datamodel backend/prisma/schema.prisma --script` returns an empty migration.
- Latest `npm run build:api` passed.
- Latest `npm run build` passed using the existing Rollup WASM package alias; it reports a large JavaScript bundle warning.
- Dev server started on `http://127.0.0.1:5176/`; the Vite root and API health endpoint both returned HTTP 200.
- Live inventory verified 99 public tables, 191 foreign keys, 278 indexes, 163 unique indexes and 11 newly added ERP check constraints.

## Not complete yet

The React ERP module screens/forms still use demo/local-state flows for affiliated college details, HOD/student dashboard KPIs, dashboard widgets/approvals and several actions. Generic Add/list is database-backed for module record pages, but edit/archive controls and dedicated CRUD services/UI for every normalized table are not connected. Document storage permissions, real approval routing, tenant integration and end-to-end module verification remain follow-up work. Do not treat this as a production-ready ERP yet.

Separate tenant database provisioning routes from the earlier design remain optional and should not be enabled with the shared-database row-tenant architecture until reviewed. Local dev startup requires the configured PostgreSQL service and valid local `.env` settings.
