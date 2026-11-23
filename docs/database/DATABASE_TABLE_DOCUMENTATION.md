# Database table inventory

Database: `techcoder_platform`, PostgreSQL 18, `public` schema. Inventory verified after migration `20261119_full_erp_expansion`. The schema contains 98 application tables plus `_prisma_migrations` (99 base tables total). Existing account and audit tables were retained; new ERP tables are currently empty until users add institutional data. Exact live row counts are recorded in `docs/database/LIVE_DATABASE_INVENTORY.md`.

Prisma defines UUID primary keys, foreign keys, unique keys and indexes for entities and list/filter paths. Enums include `UniversityType`, `UniversityStatus`, `ProvisioningStatus`, `SubscriptionStatus`, `LifecycleStatus`, `WorkflowStatus`, `DocumentStatus` and `RecordPriority`. `universityId` is the common tenant key for university-owned tables. Junction tables are called out below with `+`.

## Platform and identity (19 tables)

`platform_users`, `platform_roles`, `platform_permissions`, `platform_user_roles` (+), `platform_role_permissions` (+), `platform_login_logs`, `platform_audit_logs`, `platform_settings`, `subscription_plans`, `university_subscriptions`, `tenant_databases`, `tenant_metrics`, `institutional_users`, `institutional_roles`, `institutional_permissions`, `institutional_user_roles` (+), `institutional_role_permissions` (+), `institutional_login_logs`, `tenant_audit_logs`.

Platform passwords are stored as bcrypt hashes. Institutional users are unique by `(universityId,email)`. Institutional roles are unique by `(universityId,code)`. User-role and role-permission pairs use composite primary keys. Login logs store revocable token IDs and failed attempts. Audit rows are append-oriented and indexed by tenant/time and entity. Platform and tenant audit trails are separate.

## University and academic structure (20 tables)

`universities`, `university_contacts`, `university_addresses`, `university_accreditations`, `university_branding`, `campuses`, `affiliated_colleges`, `faculties`, `departments`, `programmes`, `courses`, `academic_sessions`, `academic_terms`, `academic_calendar_events`, `affiliated_programmes` (+), `affiliation_records`, `university_registrations`, `regulatory_approvals`, `registration_documents`, `university_profile_versions`.

The university registry has a unique generated code and optional unique registration number. Contacts, accreditation and branding are one-to-one. Addresses support multiple types and are unique by `(universityId,addressType)`. Campus and college codes are unique within a university. Departments point to their university and optionally a campus/faculty; programmes point to a department/faculty; courses point to a programme/department. University registrations and regulatory approvals support multiple dated records and supporting documents.

## Governance, quality, communication and configuration (19 tables)

`university_committees`, `committee_members` (+), `hierarchy_positions`, `accreditation_records`, `accreditation_metrics`, `iqac_profiles`, `iqac_members`, `iqac_meetings`, `iqac_action_reports`, `announcements`, `announcement_audiences` (+), `dashboard_widgets`, `dashboard_widget_settings`, `university_settings`, `institutional_documents`, `document_versions`, `approval_workflows`, `approval_requests`, `approval_steps`.

These tables support governance membership, accreditation evidence and metrics, IQAC operations, audience-targeted announcements, role/user widget settings, versioned documents, workflow definitions, approval requests and ordered approval steps. Audience and membership relations use junction rows rather than arrays.

## Student, HR and academic operations (18 tables)

`students`, `student_guardians`, `student_documents`, `employees`, `employee_qualifications`, `employee_experiences`, `employee_leaves`, `payroll_records`, `admission_applications`, `admission_documents`, `attendance_records`, `examinations`, `examination_results`, `fee_structures`, `fee_payments`, `timetable_slots`, `notifications`, `report_jobs`.

Students and employees are tenant-owned and can reference their campus, college, programme/department or academic session. Guardians, documents, qualifications, experience, leave, payment, examination result and application-document rows reference their parent records. Notifications and report jobs can be associated with institutional users.

## Library, facilities, research, placement, learning and support (21 tables)

`library_books`, `library_loans`, `hostel_rooms`, `hostel_allocations`, `transport_routes`, `transport_allocations`, `research_projects`, `research_publications`, `employers`, `placement_drives`, `placement_applications`, `learning_materials`, `assignments`, `assignment_submissions`, `support_tickets`, `support_ticket_comments`, `alumni_profiles`, `inventory_assets`, `vendors`, `purchase_orders`, `purchase_order_items`.

These tables model issue/return, room and transport allocations, research projects/publications, employer drives and student applications, course materials/assignments/submissions, support conversations, alumni, inventory assets and vendor procurement. Parent-child and many-to-many associations use foreign keys and junction/detail tables.

## Flexible module records and migrations

`erp_records` is a flexible, tenant-scoped record store with module code, type, name, reference, category, status and JSON payload. A unique key prevents duplicate non-null references within `(universityId,moduleCode,referenceCode)`. Indexes cover university/module/status/time, university/campus/college/module and university/name. It supports varied long-tail module forms while domain-specific tables above remain normalized.

`_prisma_migrations` is managed by Prisma. All 4 current application migrations are applied. The full ERP migration adds tables, enums, columns and indexes; it does not delete rows or drop tables/columns. It removes only the previous unique index on `university_addresses.universityId` to support multiple address types, after the pre-migration inventory showed that address table was empty. Later migrations add missing institutional login scope columns and database validation checks. Validation migration has a manual reverse script beside its SQL. Backups are stored in the Git-ignored `backups` directory.
