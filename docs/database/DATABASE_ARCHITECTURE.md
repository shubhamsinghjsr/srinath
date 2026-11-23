# Database architecture

## Tenancy and ownership

`techcoder_platform` is the primary PostgreSQL database for the platform and its university tenants. Tenant-owned entities carry `universityId`; campus and college records also carry their parent university, and institutional users receive a university plus optional campus/college assignment. The API derives tenant scope from the signed institutional session. Super Admin platform routes are kept separate from institutional routes.

Each university can own multiple campuses, affiliated colleges, departments, programmes and courses. Junction tables model many-to-many role permissions, user roles, committee membership, announcement audiences, programme affiliations and similar relationships. Module-specific tables cover core workflows. `erp_records` is a tenant-scoped flexible record store for module forms whose fields vary by module; it is not a replacement for normalized student, finance, HR or academic entities.

## Identity and access

Platform identities live in `platform_users` and use platform role/permission tables. University identities live in `institutional_users`, `institutional_roles`, `institutional_permissions` and their junction tables. Passwords are bcrypt hashes. Session rows are recorded separately in platform and institutional login logs and are revocable. The API validates the institutional login session on each protected request and scopes ERP record reads/writes by university, and by assigned campus or college where present. Super Admin account provisioning for a university validates campus, college and role ownership.

## Integrity and audit

UUID primary keys, foreign keys, unique keys and list/filter indexes are declared in Prisma. Registration identifiers are unique within their university where appropriate. Cascading deletes are limited to dependent junction/child rows; university ownership uses restrictive references. User-facing deletion should archive or deactivate records. `platform_audit_logs` stores platform actions, and `tenant_audit_logs` stores institutional actions. Login attempt records retain failed attempts even when the user cannot be identified.

## Runtime and operations

React/Vite calls the Express API at `http://localhost:4000/api/v1`. Prisma connects to the existing central database using `DATABASE_URL`; secrets stay in environment variables. The central database migration is additive and reversible in the sense that the initial full-ERP migration only creates new types/tables/indexes, adds nullable/defaulted columns, and replaces the unique university-address index with a `(universityId,addressType)` index. It does not drop tables/columns, truncate or delete records. A pre-change PostgreSQL dump is stored in the ignored `backups` directory.

Legacy tenant database provisioning endpoints remain available from the earlier platform design. They are optional and are not required for the shared-database tenant model described here. Do not enable separate-database provisioning until its operational and authorization design is reviewed for this architecture.

## Delivery boundary

The schema, authentication paths, university user provisioning, tenant-scoped generic ERP record API, generic Super Admin module record list/create flow, and selected-university campus creation/listing are implemented. Affiliated college details and several React ERP workflows still use demo/local state, including role-profile simulation, student KPIs, dashboards and approvals. Edit/delete workflows and dedicated APIs for every normalized table are not connected yet. The schema is ready for those module-specific service and UI integrations, but this is not yet a production-complete ERP.
