# Module to database mapping

The schema is centralized in `techcoder_platform`. Tables with `universityId` belong to a tenant. This maps module areas to normalized storage; current dedicated API/UI completion is documented in `DATABASE_ARCHITECTURE.md`.

| ERP area | Primary tables |
|---|---|
| Platform and Super Admin | `platform_users`, `platform_roles`, `platform_permissions`, `platform_settings`, `platform_login_logs`, `platform_audit_logs` |
| University registration/profile | `universities`, `university_contacts`, `university_addresses`, `university_branding`, `university_accreditations`, `university_registrations`, `regulatory_approvals`, `registration_documents`, `university_profile_versions` |
| Campus and affiliated colleges | `campuses`, `affiliated_colleges`, `affiliation_records`, `affiliated_programmes` |
| Academic structure and sessions | `faculties`, `departments`, `programmes`, `courses`, `academic_sessions`, `academic_terms`, `academic_calendar_events` |
| Accreditation, NAAC and IQAC | `accreditation_records`, `accreditation_metrics`, `iqac_profiles`, `iqac_members`, `iqac_meetings`, `iqac_action_reports` |
| Governance and university hierarchy | `university_committees`, `committee_members`, `hierarchy_positions`, `approval_workflows`, `approval_requests`, `approval_steps` |
| Announcements, dashboards and settings | `announcements`, `announcement_audiences`, `dashboard_widgets`, `dashboard_widget_settings`, `university_settings`, `notifications` |
| Users, roles and tenant audit | `institutional_users`, `institutional_roles`, `institutional_permissions`, `institutional_user_roles`, `institutional_role_permissions`, `institutional_login_logs`, `tenant_audit_logs` |
| Documents | `institutional_documents`, `document_versions`, `student_documents`, `admission_documents`, `registration_documents` |
| Admission and student records | `admission_applications`, `admission_documents`, `students`, `student_guardians`, `student_documents` |
| Faculty, HR and payroll | `employees`, `employee_qualifications`, `employee_experiences`, `employee_leaves`, `payroll_records`, `attendance_records` |
| Examination, fees and timetable | `examinations`, `examination_results`, `fee_structures`, `fee_payments`, `timetable_slots`, `attendance_records` |
| Library, hostel and transport | `library_books`, `library_loans`, `hostel_rooms`, `hostel_allocations`, `transport_routes`, `transport_allocations` |
| Research and placement | `research_projects`, `research_publications`, `employers`, `placement_drives`, `placement_applications` |
| LMS, student support and alumni | `learning_materials`, `assignments`, `assignment_submissions`, `support_tickets`, `support_ticket_comments`, `alumni_profiles` |
| Inventory and procurement | `inventory_assets`, `vendors`, `purchase_orders`, `purchase_order_items` |
| Reports and long-tail module forms | `report_jobs`, `erp_records` |

`erp_records` includes `universityId`, optional campus/college/session links, module code/type, common searchable fields, status and a JSON payload for varying fields. It is suitable for flexible module forms while a dedicated normalized model/service is added. It does not mean every module UI is currently connected or that JSON replaces relational workflows.

## Current dashboard data sources

| Dashboard metric | Source |
|---|---|
| University counts | `universities`, excluding soft-deleted rows. |
| Campus counts | `campuses`; platform may fall back to latest aggregate `tenant_metrics`. |
| Students/faculty counts | Latest tenant aggregate `tenant_metrics` snapshot; missing coverage is returned. |
| Subscriptions | `university_subscriptions` joined to `subscription_plans`. |
| Recent activity | `platform_audit_logs`. Institutional actions use `tenant_audit_logs`. |

## Tenant scoping

Institutional users are selected by `(universityId,email)`. Role assignments must refer to a role belonging to the same university. User provisioning validates campus, college and roles against the university. The generic record API derives university/campus/college scope from the JWT-backed database session and validates foreign references before writing. Normalized module endpoints still need to apply the same scoping rule as they are implemented.
