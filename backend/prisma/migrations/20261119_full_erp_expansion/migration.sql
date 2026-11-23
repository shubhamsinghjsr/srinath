-- CreateEnum
CREATE TYPE "LifecycleStatus" AS ENUM ('DRAFT', 'PENDING', 'ACTIVE', 'INACTIVE', 'SUSPENDED', 'ARCHIVED', 'COMPLETED', 'REJECTED', 'SUBMITTED');

-- CreateEnum
CREATE TYPE "WorkflowStatus" AS ENUM ('DRAFT', 'PENDING', 'SUBMITTED', 'IN_REVIEW', 'APPROVED', 'REJECTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "DocumentStatus" AS ENUM ('UPLOADED', 'PENDING_REVIEW', 'VERIFIED', 'REJECTED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "RecordPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "UniversityType" ADD VALUE 'CENTRAL';
ALTER TYPE "UniversityType" ADD VALUE 'STATE';

-- DropIndex
DROP INDEX "university_addresses_universityId_key";

-- AlterTable
ALTER TABLE "campuses" ADD COLUMN     "addressLine" VARCHAR(255),
ADD COLUMN     "campusHead" VARCHAR(160),
ADD COLUMN     "campusType" VARCHAR(60),
ADD COLUMN     "city" VARCHAR(120),
ADD COLUMN     "country" VARCHAR(100),
ADD COLUMN     "email" VARCHAR(255),
ADD COLUMN     "facilities" JSONB,
ADD COLUMN     "phone" VARCHAR(40),
ADD COLUMN     "pinCode" VARCHAR(20),
ADD COLUMN     "state" VARCHAR(120);

-- AlterTable
ALTER TABLE "universities" ADD COLUMN     "about" TEXT,
ADD COLUMN     "alternateContactNumber" VARCHAR(40),
ADD COLUMN     "category" VARCHAR(100),
ADD COLUMN     "chancellorName" VARCHAR(160),
ADD COLUMN     "controllerExamName" VARCHAR(160),
ADD COLUMN     "coreValues" TEXT,
ADD COLUMN     "dateEstablished" TIMESTAMP(3),
ADD COLUMN     "financeOfficerName" VARCHAR(160),
ADD COLUMN     "governingAct" VARCHAR(255),
ADD COLUMN     "governmentNotificationNumber" VARCHAR(100),
ADD COLUMN     "gstNumber" VARCHAR(30),
ADD COLUMN     "institutionalHistory" TEXT,
ADD COLUMN     "institutionalObjectives" TEXT,
ADD COLUMN     "leadershipEmail" VARCHAR(255),
ADD COLUMN     "leadershipPhone" VARCHAR(40),
ADD COLUMN     "legalEntityName" VARCHAR(180),
ADD COLUMN     "mission" TEXT,
ADD COLUMN     "motto" VARCHAR(255),
ADD COLUMN     "notificationDate" TIMESTAMP(3),
ADD COLUMN     "officialFax" VARCHAR(40),
ADD COLUMN     "panNumber" VARCHAR(20),
ADD COLUMN     "recognitionDate" TIMESTAMP(3),
ADD COLUMN     "registrarName" VARCHAR(160),
ADD COLUMN     "tanNumber" VARCHAR(20),
ADD COLUMN     "ugcRecognitionNumber" VARCHAR(100),
ADD COLUMN     "ugcRecognitionStatus" VARCHAR(40),
ADD COLUMN     "viceChancellorName" VARCHAR(160),
ADD COLUMN     "vision" TEXT,
ADD COLUMN     "websiteDescription" TEXT;

-- AlterTable
ALTER TABLE "university_addresses" ADD COLUMN     "addressType" VARCHAR(24) NOT NULL DEFAULT 'REGISTERED',
ADD COLUMN     "block" VARCHAR(120),
ADD COLUMN     "district" VARCHAR(120),
ADD COLUMN     "latitude" DECIMAL(10,7),
ADD COLUMN     "longitude" DECIMAL(10,7);

-- CreateTable
CREATE TABLE "institutional_roles" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "code" VARCHAR(60) NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "description" VARCHAR(255),
    "systemRole" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "institutional_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "institutional_permissions" (
    "id" UUID NOT NULL,
    "code" VARCHAR(120) NOT NULL,
    "description" VARCHAR(255),

    CONSTRAINT "institutional_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "institutional_role_permissions" (
    "roleId" UUID NOT NULL,
    "permissionId" UUID NOT NULL,

    CONSTRAINT "institutional_role_permissions_pkey" PRIMARY KEY ("roleId","permissionId")
);

-- CreateTable
CREATE TABLE "institutional_users" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "collegeId" UUID,
    "name" VARCHAR(160) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "passwordHash" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "lastLoginAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "institutional_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "institutional_user_roles" (
    "userId" UUID NOT NULL,
    "roleId" UUID NOT NULL,

    CONSTRAINT "institutional_user_roles_pkey" PRIMARY KEY ("userId","roleId")
);

-- CreateTable
CREATE TABLE "institutional_login_logs" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenId" VARCHAR(64),
    "succeeded" BOOLEAN NOT NULL,
    "ipAddress" VARCHAR(64),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "institutional_login_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "affiliated_colleges" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "code" VARCHAR(40) NOT NULL,
    "name" VARCHAR(180) NOT NULL,
    "collegeType" VARCHAR(60) NOT NULL,
    "website" VARCHAR(255),
    "principalName" VARCHAR(160),
    "contactPerson" VARCHAR(160),
    "officialEmail" VARCHAR(255),
    "phone" VARCHAR(40),
    "addressLine" VARCHAR(255),
    "district" VARCHAR(120),
    "state" VARCHAR(120),
    "pinCode" VARCHAR(20),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'PENDING',
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "affiliated_colleges_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "faculties" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "code" VARCHAR(40) NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "deanName" VARCHAR(160),
    "description" TEXT,
    "establishedAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "faculties_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "departments" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "facultyId" UUID,
    "code" VARCHAR(40) NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "hodName" VARCHAR(160),
    "contactEmail" VARCHAR(255),
    "contactPhone" VARCHAR(40),
    "description" TEXT,
    "establishedAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "programmes" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "facultyId" UUID,
    "departmentId" UUID NOT NULL,
    "code" VARCHAR(40) NOT NULL,
    "name" VARCHAR(180) NOT NULL,
    "level" VARCHAR(40) NOT NULL,
    "programmeType" VARCHAR(60),
    "durationMonths" INTEGER,
    "totalSemesters" INTEGER,
    "totalCredits" DECIMAL(7,2),
    "eligibility" TEXT,
    "approvedIntake" INTEGER,
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "programmes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "affiliated_programmes" (
    "id" UUID NOT NULL,
    "collegeId" UUID NOT NULL,
    "programmeId" UUID NOT NULL,
    "affiliationId" UUID,
    "approvedIntake" INTEGER,
    "courseLevel" VARCHAR(40),
    "durationMonths" INTEGER,
    "validFrom" TIMESTAMP(3),
    "validUntil" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "affiliated_programmes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "courses" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "programmeId" UUID NOT NULL,
    "departmentId" UUID NOT NULL,
    "code" VARCHAR(40) NOT NULL,
    "name" VARCHAR(180) NOT NULL,
    "semesterNumber" INTEGER,
    "subjectType" VARCHAR(40),
    "theoryCredits" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "practicalCredits" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "tutorialCredits" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "maximumMarks" DECIMAL(7,2),
    "minimumMarks" DECIMAL(7,2),
    "syllabus" TEXT,
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "courses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "academic_sessions" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "code" VARCHAR(40) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "sessionType" VARCHAR(40) NOT NULL DEFAULT 'SEMESTER',
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "admissionStart" TIMESTAMP(3),
    "admissionEnd" TIMESTAMP(3),
    "examinationStart" TIMESTAMP(3),
    "resultDate" TIMESTAMP(3),
    "current" BOOLEAN NOT NULL DEFAULT false,
    "status" "LifecycleStatus" NOT NULL DEFAULT 'DRAFT',
    "remarks" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "academic_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "academic_terms" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "academicSessionId" UUID NOT NULL,
    "code" VARCHAR(40) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "termNumber" INTEGER NOT NULL,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "status" "LifecycleStatus" NOT NULL DEFAULT 'DRAFT',

    CONSTRAINT "academic_terms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "students" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "collegeId" UUID,
    "departmentId" UUID,
    "programmeId" UUID,
    "academicSessionId" UUID,
    "studentNumber" VARCHAR(60) NOT NULL,
    "firstName" VARCHAR(100) NOT NULL,
    "middleName" VARCHAR(100),
    "lastName" VARCHAR(100) NOT NULL,
    "dateOfBirth" TIMESTAMP(3),
    "gender" VARCHAR(30),
    "email" VARCHAR(255),
    "phone" VARCHAR(40),
    "apaarId" VARCHAR(80),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "joinedAt" TIMESTAMP(3),
    "leftAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "students_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "student_guardians" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "relationship" VARCHAR(60) NOT NULL,
    "email" VARCHAR(255),
    "phone" VARCHAR(40),
    "isPrimary" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "student_guardians_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "student_documents" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "documentType" VARCHAR(80) NOT NULL,
    "documentNumber" VARCHAR(100),
    "filePath" VARCHAR(500) NOT NULL,
    "status" "DocumentStatus" NOT NULL DEFAULT 'UPLOADED',
    "expiresAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "student_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employees" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "departmentId" UUID,
    "employeeCode" VARCHAR(60) NOT NULL,
    "firstName" VARCHAR(100) NOT NULL,
    "lastName" VARCHAR(100) NOT NULL,
    "designation" VARCHAR(120),
    "employeeType" VARCHAR(40) NOT NULL DEFAULT 'STAFF',
    "email" VARCHAR(255),
    "phone" VARCHAR(40),
    "joinedAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "employees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_qualifications" (
    "id" UUID NOT NULL,
    "employeeId" UUID NOT NULL,
    "qualification" VARCHAR(160) NOT NULL,
    "institution" VARCHAR(180),
    "subject" VARCHAR(120),
    "year" INTEGER,
    "documentId" UUID,

    CONSTRAINT "employee_qualifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_experiences" (
    "id" UUID NOT NULL,
    "employeeId" UUID NOT NULL,
    "organization" VARCHAR(180) NOT NULL,
    "designation" VARCHAR(120),
    "startDate" TIMESTAMP(3),
    "endDate" TIMESTAMP(3),

    CONSTRAINT "employee_experiences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "university_registrations" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "registrationNumber" VARCHAR(120) NOT NULL,
    "registrationType" VARCHAR(80) NOT NULL,
    "authority" VARCHAR(180),
    "registrationDate" TIMESTAMP(3),
    "approvalDate" TIMESTAMP(3),
    "validFrom" TIMESTAMP(3),
    "validUntil" TIMESTAMP(3),
    "status" "WorkflowStatus" NOT NULL DEFAULT 'DRAFT',
    "referenceNumber" VARCHAR(120),
    "orderNumber" VARCHAR(120),
    "authorizedSignatory" VARCHAR(160),
    "remarks" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "university_registrations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "regulatory_approvals" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "registrationId" UUID,
    "authorityCode" VARCHAR(40) NOT NULL,
    "approvalType" VARCHAR(100) NOT NULL,
    "approvalNumber" VARCHAR(120),
    "issuingAuthority" VARCHAR(180),
    "approvedAt" TIMESTAMP(3),
    "validFrom" TIMESTAMP(3),
    "validUntil" TIMESTAMP(3),
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "status" "WorkflowStatus" NOT NULL DEFAULT 'DRAFT',
    "remarks" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "regulatory_approvals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "registration_documents" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "registrationId" UUID,
    "approvalId" UUID,
    "title" VARCHAR(180) NOT NULL,
    "filePath" VARCHAR(500) NOT NULL,
    "checksum" VARCHAR(128),
    "status" "DocumentStatus" NOT NULL DEFAULT 'UPLOADED',
    "uploadedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "registration_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accreditation_records" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "body" VARCHAR(100) NOT NULL,
    "accreditationType" VARCHAR(80) NOT NULL,
    "accreditationNumber" VARCHAR(120),
    "assessmentCycle" VARCHAR(60),
    "accreditationYear" INTEGER,
    "applicationDate" TIMESTAMP(3),
    "assessmentDate" TIMESTAMP(3),
    "validFrom" TIMESTAMP(3),
    "validUntil" TIMESTAMP(3),
    "grade" VARCHAR(30),
    "score" DECIMAL(6,3),
    "status" "WorkflowStatus" NOT NULL DEFAULT 'DRAFT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "accreditation_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accreditation_metrics" (
    "id" UUID NOT NULL,
    "accreditationId" UUID NOT NULL,
    "departmentId" UUID,
    "criterionNumber" INTEGER NOT NULL,
    "criterionName" VARCHAR(180) NOT NULL,
    "metricNumber" VARCHAR(60) NOT NULL,
    "description" TEXT NOT NULL,
    "metricType" VARCHAR(40) NOT NULL,
    "academicYear" VARCHAR(20),
    "value" JSONB,
    "verificationStatus" "DocumentStatus" NOT NULL DEFAULT 'PENDING_REVIEW',
    "remarks" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "accreditation_metrics_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "iqac_profiles" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "coordinatorName" VARCHAR(160),
    "email" VARCHAR(255),
    "phone" VARCHAR(40),
    "establishedAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "iqac_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "iqac_members" (
    "id" UUID NOT NULL,
    "profileId" UUID NOT NULL,
    "employeeId" UUID,
    "name" VARCHAR(160) NOT NULL,
    "role" VARCHAR(100) NOT NULL,
    "email" VARCHAR(255),
    "active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "iqac_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "iqac_meetings" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "profileId" UUID NOT NULL,
    "meetingNumber" VARCHAR(40),
    "title" VARCHAR(180) NOT NULL,
    "meetingAt" TIMESTAMP(3) NOT NULL,
    "agenda" TEXT,
    "minutes" TEXT,
    "status" "LifecycleStatus" NOT NULL DEFAULT 'DRAFT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "iqac_meetings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "iqac_action_reports" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "profileId" UUID NOT NULL,
    "meetingId" UUID,
    "action" TEXT NOT NULL,
    "owner" VARCHAR(160),
    "dueAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'PENDING',

    CONSTRAINT "iqac_action_reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "affiliation_records" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "collegeId" UUID NOT NULL,
    "affiliationNumber" VARCHAR(120) NOT NULL,
    "affiliationType" VARCHAR(80) NOT NULL,
    "approvalAuthority" VARCHAR(180),
    "approvalReference" VARCHAR(120),
    "affiliationDate" TIMESTAMP(3),
    "validFrom" TIMESTAMP(3),
    "validUntil" TIMESTAMP(3),
    "status" "WorkflowStatus" NOT NULL DEFAULT 'DRAFT',
    "remarks" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "affiliation_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hierarchy_positions" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "parentId" UUID,
    "employeeId" UUID,
    "positionCode" VARCHAR(60) NOT NULL,
    "positionName" VARCHAR(160) NOT NULL,
    "personName" VARCHAR(160),
    "departmentName" VARCHAR(160),
    "officialEmail" VARCHAR(255),
    "contactNumber" VARCHAR(40),
    "appointedAt" TIMESTAMP(3),
    "tenureStart" TIMESTAMP(3),
    "tenureEnd" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "hierarchy_positions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "university_committees" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "code" VARCHAR(60) NOT NULL,
    "name" VARCHAR(180) NOT NULL,
    "committeeType" VARCHAR(80) NOT NULL,
    "chairperson" VARCHAR(160),
    "meetingFrequency" VARCHAR(60),
    "formedAt" TIMESTAMP(3),
    "validUntil" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "university_committees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "committee_members" (
    "committeeId" UUID NOT NULL,
    "employeeId" UUID,
    "name" VARCHAR(160) NOT NULL,
    "role" VARCHAR(80) NOT NULL,
    "email" VARCHAR(255),

    CONSTRAINT "committee_members_pkey" PRIMARY KEY ("committeeId","name")
);

-- CreateTable
CREATE TABLE "university_profile_versions" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "profile" JSONB NOT NULL,
    "createdBy" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "university_profile_versions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "academic_calendar_events" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "academicSessionId" UUID,
    "title" VARCHAR(180) NOT NULL,
    "eventType" VARCHAR(60) NOT NULL,
    "startsAt" TIMESTAMP(3) NOT NULL,
    "endsAt" TIMESTAMP(3),
    "description" TEXT,
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "academic_calendar_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "announcements" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "academicSessionId" UUID,
    "createdById" UUID,
    "code" VARCHAR(60) NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "category" VARCHAR(80) NOT NULL,
    "announcementType" VARCHAR(40) NOT NULL DEFAULT 'GENERAL',
    "description" TEXT NOT NULL,
    "priority" "RecordPriority" NOT NULL DEFAULT 'MEDIUM',
    "publishAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3),
    "status" "WorkflowStatus" NOT NULL DEFAULT 'DRAFT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "announcements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "announcement_audiences" (
    "id" UUID NOT NULL,
    "announcementId" UUID NOT NULL,
    "audienceType" VARCHAR(40) NOT NULL,
    "audienceId" UUID,
    "audienceLabel" VARCHAR(160),

    CONSTRAINT "announcement_audiences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dashboard_widgets" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "code" VARCHAR(80) NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "widgetType" VARCHAR(60) NOT NULL,
    "dataSource" VARCHAR(120) NOT NULL,
    "defaultSize" VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    "refreshSeconds" INTEGER NOT NULL DEFAULT 300,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "dashboard_widgets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dashboard_widget_settings" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "widgetId" UUID NOT NULL,
    "roleId" UUID,
    "userId" UUID,
    "position" INTEGER NOT NULL DEFAULT 0,
    "visible" BOOLEAN NOT NULL DEFAULT true,
    "size" VARCHAR(20),
    "configuration" JSONB,

    CONSTRAINT "dashboard_widget_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "university_settings" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "section" VARCHAR(80) NOT NULL,
    "key" VARCHAR(120) NOT NULL,
    "value" JSONB NOT NULL,
    "sensitive" BOOLEAN NOT NULL DEFAULT false,
    "updatedById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "university_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "institutional_documents" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "accreditationId" UUID,
    "announcementId" UUID,
    "uploadedById" UUID,
    "documentNumber" VARCHAR(100),
    "title" VARCHAR(200) NOT NULL,
    "category" VARCHAR(80) NOT NULL,
    "relatedModule" VARCHAR(80),
    "academicYear" VARCHAR(20),
    "departmentName" VARCHAR(160),
    "currentVersion" INTEGER NOT NULL DEFAULT 1,
    "status" "DocumentStatus" NOT NULL DEFAULT 'UPLOADED',
    "expiresAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "institutional_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "document_versions" (
    "id" UUID NOT NULL,
    "documentId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "filePath" VARCHAR(500) NOT NULL,
    "mimeType" VARCHAR(120),
    "fileSize" BIGINT,
    "checksum" VARCHAR(128),
    "uploadedById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "document_versions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_workflows" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "moduleCode" VARCHAR(80) NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "steps" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "approval_workflows_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_requests" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "workflowId" UUID,
    "requesterId" UUID,
    "moduleCode" VARCHAR(80) NOT NULL,
    "recordId" UUID NOT NULL,
    "status" "WorkflowStatus" NOT NULL DEFAULT 'SUBMITTED',
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "approval_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_steps" (
    "id" UUID NOT NULL,
    "requestId" UUID NOT NULL,
    "stepNumber" INTEGER NOT NULL,
    "approverRole" VARCHAR(80),
    "approverId" UUID,
    "status" "WorkflowStatus" NOT NULL DEFAULT 'PENDING',
    "decisionNote" TEXT,
    "decidedAt" TIMESTAMP(3),

    CONSTRAINT "approval_steps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "recipientId" UUID,
    "channel" VARCHAR(30) NOT NULL DEFAULT 'IN_APP',
    "title" VARCHAR(180) NOT NULL,
    "body" TEXT NOT NULL,
    "readAt" TIMESTAMP(3),
    "deliveredAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "erp_records" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "collegeId" UUID,
    "academicSessionId" UUID,
    "createdById" UUID,
    "moduleCode" VARCHAR(80) NOT NULL,
    "recordType" VARCHAR(100) NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "referenceCode" VARCHAR(100),
    "category" VARCHAR(100),
    "status" VARCHAR(40) NOT NULL DEFAULT 'ACTIVE',
    "payload" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "erp_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tenant_audit_logs" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "institutionalUserId" UUID,
    "action" VARCHAR(120) NOT NULL,
    "entityType" VARCHAR(80) NOT NULL,
    "entityId" VARCHAR(100),
    "metadata" JSONB,
    "ipAddress" VARCHAR(64),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tenant_audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "admission_applications" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "programmeId" UUID NOT NULL,
    "academicSessionId" UUID NOT NULL,
    "studentId" UUID,
    "applicationNumber" VARCHAR(80) NOT NULL,
    "applicantName" VARCHAR(180) NOT NULL,
    "email" VARCHAR(255),
    "phone" VARCHAR(40),
    "dateOfBirth" TIMESTAMP(3),
    "eligibilityStatus" VARCHAR(40) NOT NULL DEFAULT 'PENDING',
    "entranceScore" DECIMAL(8,3),
    "meritRank" INTEGER,
    "counsellingStatus" VARCHAR(40) NOT NULL DEFAULT 'PENDING',
    "seatStatus" VARCHAR(40) NOT NULL DEFAULT 'UNALLOCATED',
    "status" "WorkflowStatus" NOT NULL DEFAULT 'DRAFT',
    "submittedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "admission_applications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "admission_documents" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "applicationId" UUID NOT NULL,
    "documentType" VARCHAR(80) NOT NULL,
    "filePath" VARCHAR(500) NOT NULL,
    "status" "DocumentStatus" NOT NULL DEFAULT 'PENDING_REVIEW',
    "verifiedBy" UUID,
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "admission_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_records" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "studentId" UUID,
    "employeeId" UUID,
    "courseId" UUID,
    "attendanceDate" DATE NOT NULL,
    "status" VARCHAR(24) NOT NULL,
    "source" VARCHAR(40) NOT NULL DEFAULT 'MANUAL',
    "remarks" VARCHAR(500),
    "markedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "examinations" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "academicSessionId" UUID NOT NULL,
    "code" VARCHAR(60) NOT NULL,
    "name" VARCHAR(180) NOT NULL,
    "examinationType" VARCHAR(60) NOT NULL,
    "startDate" TIMESTAMP(3),
    "endDate" TIMESTAMP(3),
    "resultDate" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'DRAFT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "examinations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "examination_results" (
    "id" UUID NOT NULL,
    "examinationId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "courseId" UUID NOT NULL,
    "marksObtained" DECIMAL(8,2),
    "grade" VARCHAR(12),
    "resultStatus" VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    "publishedAt" TIMESTAMP(3),

    CONSTRAINT "examination_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fee_structures" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "programmeId" UUID NOT NULL,
    "code" VARCHAR(60) NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "feeType" VARCHAR(60) NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'INR',
    "dueAt" TIMESTAMP(3),
    "academicYear" VARCHAR(20),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "fee_structures_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fee_payments" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "academicSessionId" UUID,
    "receiptNumber" VARCHAR(80) NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'INR',
    "paymentMethod" VARCHAR(40),
    "providerReference" VARCHAR(120),
    "status" VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    "paidAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "fee_payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "library_books" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "isbn" VARCHAR(24),
    "accessionNumber" VARCHAR(80) NOT NULL,
    "title" VARCHAR(240) NOT NULL,
    "authors" TEXT[],
    "publisher" VARCHAR(180),
    "category" VARCHAR(100),
    "publishedYear" INTEGER,
    "copiesTotal" INTEGER NOT NULL DEFAULT 1,
    "copiesAvailable" INTEGER NOT NULL DEFAULT 1,
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "library_books_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "library_loans" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "bookId" UUID NOT NULL,
    "issuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "dueAt" TIMESTAMP(3) NOT NULL,
    "returnedAt" TIMESTAMP(3),
    "fineAmount" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "status" VARCHAR(30) NOT NULL DEFAULT 'ISSUED',

    CONSTRAINT "library_loans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hostel_rooms" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "building" VARCHAR(120) NOT NULL,
    "roomNumber" VARCHAR(40) NOT NULL,
    "capacity" INTEGER NOT NULL DEFAULT 1,
    "genderPolicy" VARCHAR(30),
    "monthlyFee" DECIMAL(10,2),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "hostel_rooms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hostel_allocations" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "roomId" UUID NOT NULL,
    "bedLabel" VARCHAR(30),
    "allocatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "vacatedAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "hostel_allocations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "transport_routes" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "code" VARCHAR(60) NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "stops" JSONB NOT NULL,
    "vehicleNumber" VARCHAR(40),
    "driverName" VARCHAR(160),
    "monthlyFee" DECIMAL(10,2),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "transport_routes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "transport_allocations" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "routeId" UUID NOT NULL,
    "stopName" VARCHAR(160),
    "startsAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endsAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "transport_allocations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "timetable_slots" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "courseId" UUID NOT NULL,
    "employeeId" UUID,
    "academicYear" VARCHAR(20) NOT NULL,
    "dayOfWeek" INTEGER NOT NULL,
    "periodNumber" INTEGER NOT NULL,
    "room" VARCHAR(80),
    "startsAt" VARCHAR(5),
    "endsAt" VARCHAR(5),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "timetable_slots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "research_projects" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "principalInvestigatorId" UUID,
    "code" VARCHAR(60) NOT NULL,
    "title" VARCHAR(240) NOT NULL,
    "researchArea" VARCHAR(120),
    "fundingSource" VARCHAR(180),
    "grantAmount" DECIMAL(14,2),
    "startsAt" TIMESTAMP(3),
    "endsAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'DRAFT',

    CONSTRAINT "research_projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "research_publications" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "projectId" UUID,
    "title" VARCHAR(240) NOT NULL,
    "publicationType" VARCHAR(60) NOT NULL,
    "journal" VARCHAR(180),
    "doi" VARCHAR(160),
    "publishedAt" TIMESTAMP(3),
    "authors" JSONB NOT NULL,
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "research_publications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employers" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "code" VARCHAR(60) NOT NULL,
    "name" VARCHAR(180) NOT NULL,
    "industry" VARCHAR(100),
    "website" VARCHAR(255),
    "contactName" VARCHAR(160),
    "contactEmail" VARCHAR(255),
    "contactPhone" VARCHAR(40),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "employers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "placement_drives" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "employerId" UUID NOT NULL,
    "code" VARCHAR(60) NOT NULL,
    "roleTitle" VARCHAR(180) NOT NULL,
    "description" TEXT,
    "eligibility" JSONB,
    "packageMin" DECIMAL(12,2),
    "packageMax" DECIMAL(12,2),
    "applicationDeadline" TIMESTAMP(3),
    "driveDate" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'DRAFT',

    CONSTRAINT "placement_drives_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "placement_applications" (
    "id" UUID NOT NULL,
    "driveId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "programmeId" UUID,
    "appliedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "stage" VARCHAR(40) NOT NULL DEFAULT 'APPLIED',
    "offerAmount" DECIMAL(12,2),
    "offeredAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "placement_applications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning_materials" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "programmeId" UUID,
    "courseId" UUID,
    "title" VARCHAR(200) NOT NULL,
    "materialType" VARCHAR(60) NOT NULL,
    "filePath" VARCHAR(500),
    "externalUrl" VARCHAR(500),
    "publishedAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'DRAFT',

    CONSTRAINT "learning_materials_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "assignments" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "programmeId" UUID,
    "courseId" UUID NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "description" TEXT,
    "maxMarks" DECIMAL(8,2),
    "dueAt" TIMESTAMP(3),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'DRAFT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "assignment_submissions" (
    "id" UUID NOT NULL,
    "assignmentId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "filePath" VARCHAR(500),
    "responseText" TEXT,
    "marks" DECIMAL(8,2),
    "feedback" TEXT,
    "status" "LifecycleStatus" NOT NULL DEFAULT 'SUBMITTED',

    CONSTRAINT "assignment_submissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "support_tickets" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "studentId" UUID,
    "assignedEmployeeId" UUID,
    "ticketNumber" VARCHAR(60) NOT NULL,
    "category" VARCHAR(80) NOT NULL,
    "subject" VARCHAR(200) NOT NULL,
    "description" TEXT NOT NULL,
    "priority" "RecordPriority" NOT NULL DEFAULT 'MEDIUM',
    "status" "LifecycleStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "support_tickets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "support_ticket_comments" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "ticketId" UUID NOT NULL,
    "authorId" UUID,
    "body" TEXT NOT NULL,
    "internal" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "support_ticket_comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "alumni_profiles" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "studentId" UUID,
    "alumniNumber" VARCHAR(60) NOT NULL,
    "graduationYear" INTEGER NOT NULL,
    "employer" VARCHAR(180),
    "jobTitle" VARCHAR(120),
    "email" VARCHAR(255),
    "phone" VARCHAR(40),
    "visibility" VARCHAR(24) NOT NULL DEFAULT 'PRIVATE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "alumni_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inventory_assets" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "campusId" UUID,
    "vendorId" UUID,
    "assetCode" VARCHAR(80) NOT NULL,
    "name" VARCHAR(180) NOT NULL,
    "category" VARCHAR(80) NOT NULL,
    "serialNumber" VARCHAR(120),
    "purchasedAt" TIMESTAMP(3),
    "purchaseCost" DECIMAL(14,2),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "inventory_assets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendors" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "code" VARCHAR(60) NOT NULL,
    "name" VARCHAR(180) NOT NULL,
    "taxNumber" VARCHAR(40),
    "email" VARCHAR(255),
    "phone" VARCHAR(40),
    "address" VARCHAR(255),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "vendors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_orders" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "vendorId" UUID NOT NULL,
    "orderNumber" VARCHAR(80) NOT NULL,
    "orderedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expectedAt" TIMESTAMP(3),
    "totalAmount" DECIMAL(14,2) NOT NULL,
    "status" "WorkflowStatus" NOT NULL DEFAULT 'DRAFT',

    CONSTRAINT "purchase_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_order_items" (
    "id" UUID NOT NULL,
    "purchaseOrderId" UUID NOT NULL,
    "itemName" VARCHAR(180) NOT NULL,
    "quantity" DECIMAL(12,3) NOT NULL,
    "unitPrice" DECIMAL(14,2) NOT NULL,
    "lineTotal" DECIMAL(14,2) NOT NULL,

    CONSTRAINT "purchase_order_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_leaves" (
    "id" UUID NOT NULL,
    "employeeId" UUID NOT NULL,
    "leaveType" VARCHAR(60) NOT NULL,
    "startsOn" DATE NOT NULL,
    "endsOn" DATE NOT NULL,
    "reason" TEXT,
    "status" "WorkflowStatus" NOT NULL DEFAULT 'SUBMITTED',
    "reviewedBy" UUID,
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "employee_leaves_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payroll_records" (
    "id" UUID NOT NULL,
    "employeeId" UUID NOT NULL,
    "payrollMonth" VARCHAR(7) NOT NULL,
    "grossAmount" DECIMAL(14,2) NOT NULL,
    "deductions" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "netAmount" DECIMAL(14,2) NOT NULL,
    "status" VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    "paidAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payroll_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "report_jobs" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "requestedById" UUID,
    "reportType" VARCHAR(100) NOT NULL,
    "filters" JSONB,
    "filePath" VARCHAR(500),
    "status" "LifecycleStatus" NOT NULL DEFAULT 'PENDING',
    "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "report_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "institutional_roles_universityId_name_idx" ON "institutional_roles"("universityId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "institutional_roles_universityId_code_key" ON "institutional_roles"("universityId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "institutional_permissions_code_key" ON "institutional_permissions"("code");

-- CreateIndex
CREATE INDEX "institutional_users_universityId_campusId_collegeId_active_idx" ON "institutional_users"("universityId", "campusId", "collegeId", "active");

-- CreateIndex
CREATE UNIQUE INDEX "institutional_users_universityId_email_key" ON "institutional_users"("universityId", "email");

-- CreateIndex
CREATE UNIQUE INDEX "institutional_login_logs_tokenId_key" ON "institutional_login_logs"("tokenId");

-- CreateIndex
CREATE INDEX "institutional_login_logs_userId_createdAt_idx" ON "institutional_login_logs"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "affiliated_colleges_universityId_status_deletedAt_idx" ON "affiliated_colleges"("universityId", "status", "deletedAt");

-- CreateIndex
CREATE INDEX "affiliated_colleges_universityId_name_idx" ON "affiliated_colleges"("universityId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "affiliated_colleges_universityId_code_key" ON "affiliated_colleges"("universityId", "code");

-- CreateIndex
CREATE INDEX "faculties_universityId_status_idx" ON "faculties"("universityId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "faculties_universityId_code_key" ON "faculties"("universityId", "code");

-- CreateIndex
CREATE INDEX "departments_universityId_campusId_status_idx" ON "departments"("universityId", "campusId", "status");

-- CreateIndex
CREATE INDEX "departments_facultyId_idx" ON "departments"("facultyId");

-- CreateIndex
CREATE UNIQUE INDEX "departments_universityId_code_key" ON "departments"("universityId", "code");

-- CreateIndex
CREATE INDEX "programmes_universityId_departmentId_status_idx" ON "programmes"("universityId", "departmentId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "programmes_universityId_code_key" ON "programmes"("universityId", "code");

-- CreateIndex
CREATE INDEX "affiliated_programmes_collegeId_status_validUntil_idx" ON "affiliated_programmes"("collegeId", "status", "validUntil");

-- CreateIndex
CREATE UNIQUE INDEX "affiliated_programmes_collegeId_programmeId_validFrom_key" ON "affiliated_programmes"("collegeId", "programmeId", "validFrom");

-- CreateIndex
CREATE INDEX "courses_universityId_programmeId_semesterNumber_idx" ON "courses"("universityId", "programmeId", "semesterNumber");

-- CreateIndex
CREATE UNIQUE INDEX "courses_universityId_code_key" ON "courses"("universityId", "code");

-- CreateIndex
CREATE INDEX "academic_sessions_universityId_current_status_idx" ON "academic_sessions"("universityId", "current", "status");

-- CreateIndex
CREATE UNIQUE INDEX "academic_sessions_universityId_code_key" ON "academic_sessions"("universityId", "code");

-- CreateIndex
CREATE INDEX "academic_terms_universityId_startDate_endDate_idx" ON "academic_terms"("universityId", "startDate", "endDate");

-- CreateIndex
CREATE UNIQUE INDEX "academic_terms_academicSessionId_code_key" ON "academic_terms"("academicSessionId", "code");

-- CreateIndex
CREATE INDEX "students_universityId_campusId_collegeId_status_idx" ON "students"("universityId", "campusId", "collegeId", "status");

-- CreateIndex
CREATE INDEX "students_universityId_departmentId_programmeId_idx" ON "students"("universityId", "departmentId", "programmeId");

-- CreateIndex
CREATE INDEX "students_universityId_email_idx" ON "students"("universityId", "email");

-- CreateIndex
CREATE UNIQUE INDEX "students_universityId_studentNumber_key" ON "students"("universityId", "studentNumber");

-- CreateIndex
CREATE UNIQUE INDEX "students_universityId_apaarId_key" ON "students"("universityId", "apaarId");

-- CreateIndex
CREATE INDEX "student_guardians_studentId_isPrimary_idx" ON "student_guardians"("studentId", "isPrimary");

-- CreateIndex
CREATE INDEX "student_documents_studentId_documentType_idx" ON "student_documents"("studentId", "documentType");

-- CreateIndex
CREATE INDEX "employees_universityId_departmentId_status_idx" ON "employees"("universityId", "departmentId", "status");

-- CreateIndex
CREATE INDEX "employees_universityId_email_idx" ON "employees"("universityId", "email");

-- CreateIndex
CREATE UNIQUE INDEX "employees_universityId_employeeCode_key" ON "employees"("universityId", "employeeCode");

-- CreateIndex
CREATE INDEX "employee_qualifications_employeeId_year_idx" ON "employee_qualifications"("employeeId", "year");

-- CreateIndex
CREATE INDEX "employee_experiences_employeeId_startDate_idx" ON "employee_experiences"("employeeId", "startDate");

-- CreateIndex
CREATE INDEX "university_registrations_universityId_status_validUntil_idx" ON "university_registrations"("universityId", "status", "validUntil");

-- CreateIndex
CREATE INDEX "university_registrations_universityId_registrationNumber_idx" ON "university_registrations"("universityId", "registrationNumber");

-- CreateIndex
CREATE INDEX "regulatory_approvals_universityId_authorityCode_validUntil_idx" ON "regulatory_approvals"("universityId", "authorityCode", "validUntil");

-- CreateIndex
CREATE INDEX "registration_documents_universityId_status_idx" ON "registration_documents"("universityId", "status");

-- CreateIndex
CREATE INDEX "accreditation_records_universityId_body_status_idx" ON "accreditation_records"("universityId", "body", "status");

-- CreateIndex
CREATE INDEX "accreditation_records_universityId_validUntil_idx" ON "accreditation_records"("universityId", "validUntil");

-- CreateIndex
CREATE INDEX "accreditation_metrics_accreditationId_verificationStatus_idx" ON "accreditation_metrics"("accreditationId", "verificationStatus");

-- CreateIndex
CREATE UNIQUE INDEX "accreditation_metrics_accreditationId_metricNumber_departme_key" ON "accreditation_metrics"("accreditationId", "metricNumber", "departmentId", "academicYear");

-- CreateIndex
CREATE UNIQUE INDEX "iqac_profiles_universityId_key" ON "iqac_profiles"("universityId");

-- CreateIndex
CREATE INDEX "iqac_members_profileId_active_idx" ON "iqac_members"("profileId", "active");

-- CreateIndex
CREATE INDEX "iqac_meetings_universityId_meetingAt_idx" ON "iqac_meetings"("universityId", "meetingAt");

-- CreateIndex
CREATE INDEX "iqac_action_reports_universityId_status_dueAt_idx" ON "iqac_action_reports"("universityId", "status", "dueAt");

-- CreateIndex
CREATE INDEX "affiliation_records_universityId_collegeId_status_validUnti_idx" ON "affiliation_records"("universityId", "collegeId", "status", "validUntil");

-- CreateIndex
CREATE UNIQUE INDEX "affiliation_records_universityId_affiliationNumber_key" ON "affiliation_records"("universityId", "affiliationNumber");

-- CreateIndex
CREATE INDEX "hierarchy_positions_universityId_parentId_status_idx" ON "hierarchy_positions"("universityId", "parentId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "hierarchy_positions_universityId_positionCode_key" ON "hierarchy_positions"("universityId", "positionCode");

-- CreateIndex
CREATE INDEX "university_committees_universityId_status_validUntil_idx" ON "university_committees"("universityId", "status", "validUntil");

-- CreateIndex
CREATE UNIQUE INDEX "university_committees_universityId_code_key" ON "university_committees"("universityId", "code");

-- CreateIndex
CREATE INDEX "committee_members_employeeId_idx" ON "committee_members"("employeeId");

-- CreateIndex
CREATE INDEX "university_profile_versions_universityId_createdAt_idx" ON "university_profile_versions"("universityId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "university_profile_versions_universityId_version_key" ON "university_profile_versions"("universityId", "version");

-- CreateIndex
CREATE INDEX "academic_calendar_events_universityId_startsAt_eventType_idx" ON "academic_calendar_events"("universityId", "startsAt", "eventType");

-- CreateIndex
CREATE INDEX "announcements_universityId_status_publishAt_expiresAt_idx" ON "announcements"("universityId", "status", "publishAt", "expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "announcements_universityId_code_key" ON "announcements"("universityId", "code");

-- CreateIndex
CREATE INDEX "announcement_audiences_audienceType_audienceId_idx" ON "announcement_audiences"("audienceType", "audienceId");

-- CreateIndex
CREATE UNIQUE INDEX "announcement_audiences_announcementId_audienceType_audience_key" ON "announcement_audiences"("announcementId", "audienceType", "audienceId", "audienceLabel");

-- CreateIndex
CREATE UNIQUE INDEX "dashboard_widgets_universityId_code_key" ON "dashboard_widgets"("universityId", "code");

-- CreateIndex
CREATE INDEX "dashboard_widget_settings_universityId_roleId_position_idx" ON "dashboard_widget_settings"("universityId", "roleId", "position");

-- CreateIndex
CREATE INDEX "dashboard_widget_settings_userId_position_idx" ON "dashboard_widget_settings"("userId", "position");

-- CreateIndex
CREATE INDEX "university_settings_universityId_section_idx" ON "university_settings"("universityId", "section");

-- CreateIndex
CREATE UNIQUE INDEX "university_settings_universityId_section_key_key" ON "university_settings"("universityId", "section", "key");

-- CreateIndex
CREATE INDEX "institutional_documents_universityId_relatedModule_category_idx" ON "institutional_documents"("universityId", "relatedModule", "category");

-- CreateIndex
CREATE INDEX "institutional_documents_universityId_status_expiresAt_idx" ON "institutional_documents"("universityId", "status", "expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "document_versions_documentId_version_key" ON "document_versions"("documentId", "version");

-- CreateIndex
CREATE INDEX "approval_workflows_universityId_moduleCode_active_idx" ON "approval_workflows"("universityId", "moduleCode", "active");

-- CreateIndex
CREATE UNIQUE INDEX "approval_workflows_universityId_moduleCode_version_key" ON "approval_workflows"("universityId", "moduleCode", "version");

-- CreateIndex
CREATE INDEX "approval_requests_universityId_status_submittedAt_idx" ON "approval_requests"("universityId", "status", "submittedAt");

-- CreateIndex
CREATE INDEX "approval_requests_universityId_moduleCode_recordId_idx" ON "approval_requests"("universityId", "moduleCode", "recordId");

-- CreateIndex
CREATE INDEX "approval_steps_approverId_status_idx" ON "approval_steps"("approverId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "approval_steps_requestId_stepNumber_key" ON "approval_steps"("requestId", "stepNumber");

-- CreateIndex
CREATE INDEX "notifications_universityId_recipientId_readAt_createdAt_idx" ON "notifications"("universityId", "recipientId", "readAt", "createdAt");

-- CreateIndex
CREATE INDEX "erp_records_universityId_moduleCode_status_createdAt_idx" ON "erp_records"("universityId", "moduleCode", "status", "createdAt");

-- CreateIndex
CREATE INDEX "erp_records_universityId_campusId_collegeId_moduleCode_idx" ON "erp_records"("universityId", "campusId", "collegeId", "moduleCode");

-- CreateIndex
CREATE INDEX "erp_records_universityId_name_idx" ON "erp_records"("universityId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "erp_records_universityId_moduleCode_referenceCode_key" ON "erp_records"("universityId", "moduleCode", "referenceCode");

-- CreateIndex
CREATE INDEX "tenant_audit_logs_universityId_createdAt_idx" ON "tenant_audit_logs"("universityId", "createdAt");

-- CreateIndex
CREATE INDEX "tenant_audit_logs_universityId_entityType_entityId_idx" ON "tenant_audit_logs"("universityId", "entityType", "entityId");

-- CreateIndex
CREATE UNIQUE INDEX "admission_applications_studentId_key" ON "admission_applications"("studentId");

-- CreateIndex
CREATE INDEX "admission_applications_universityId_academicSessionId_statu_idx" ON "admission_applications"("universityId", "academicSessionId", "status");

-- CreateIndex
CREATE INDEX "admission_applications_universityId_programmeId_meritRank_idx" ON "admission_applications"("universityId", "programmeId", "meritRank");

-- CreateIndex
CREATE UNIQUE INDEX "admission_applications_universityId_applicationNumber_key" ON "admission_applications"("universityId", "applicationNumber");

-- CreateIndex
CREATE INDEX "admission_documents_universityId_applicationId_status_idx" ON "admission_documents"("universityId", "applicationId", "status");

-- CreateIndex
CREATE INDEX "attendance_records_universityId_attendanceDate_status_idx" ON "attendance_records"("universityId", "attendanceDate", "status");

-- CreateIndex
CREATE INDEX "attendance_records_studentId_attendanceDate_idx" ON "attendance_records"("studentId", "attendanceDate");

-- CreateIndex
CREATE INDEX "attendance_records_employeeId_attendanceDate_idx" ON "attendance_records"("employeeId", "attendanceDate");

-- CreateIndex
CREATE INDEX "attendance_records_courseId_attendanceDate_idx" ON "attendance_records"("courseId", "attendanceDate");

-- CreateIndex
CREATE INDEX "examinations_universityId_academicSessionId_status_idx" ON "examinations"("universityId", "academicSessionId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "examinations_universityId_code_key" ON "examinations"("universityId", "code");

-- CreateIndex
CREATE INDEX "examination_results_studentId_resultStatus_idx" ON "examination_results"("studentId", "resultStatus");

-- CreateIndex
CREATE UNIQUE INDEX "examination_results_examinationId_studentId_courseId_key" ON "examination_results"("examinationId", "studentId", "courseId");

-- CreateIndex
CREATE INDEX "fee_structures_universityId_programmeId_feeType_idx" ON "fee_structures"("universityId", "programmeId", "feeType");

-- CreateIndex
CREATE UNIQUE INDEX "fee_structures_universityId_code_key" ON "fee_structures"("universityId", "code");

-- CreateIndex
CREATE INDEX "fee_payments_universityId_studentId_status_idx" ON "fee_payments"("universityId", "studentId", "status");

-- CreateIndex
CREATE INDEX "fee_payments_universityId_paidAt_idx" ON "fee_payments"("universityId", "paidAt");

-- CreateIndex
CREATE UNIQUE INDEX "fee_payments_universityId_receiptNumber_key" ON "fee_payments"("universityId", "receiptNumber");

-- CreateIndex
CREATE INDEX "library_books_universityId_isbn_idx" ON "library_books"("universityId", "isbn");

-- CreateIndex
CREATE INDEX "library_books_universityId_title_idx" ON "library_books"("universityId", "title");

-- CreateIndex
CREATE UNIQUE INDEX "library_books_universityId_accessionNumber_key" ON "library_books"("universityId", "accessionNumber");

-- CreateIndex
CREATE INDEX "library_loans_universityId_dueAt_returnedAt_idx" ON "library_loans"("universityId", "dueAt", "returnedAt");

-- CreateIndex
CREATE INDEX "library_loans_studentId_status_idx" ON "library_loans"("studentId", "status");

-- CreateIndex
CREATE INDEX "hostel_rooms_universityId_campusId_status_idx" ON "hostel_rooms"("universityId", "campusId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "hostel_rooms_universityId_campusId_building_roomNumber_key" ON "hostel_rooms"("universityId", "campusId", "building", "roomNumber");

-- CreateIndex
CREATE INDEX "hostel_allocations_universityId_status_allocatedAt_idx" ON "hostel_allocations"("universityId", "status", "allocatedAt");

-- CreateIndex
CREATE INDEX "hostel_allocations_studentId_status_idx" ON "hostel_allocations"("studentId", "status");

-- CreateIndex
CREATE INDEX "transport_routes_universityId_campusId_status_idx" ON "transport_routes"("universityId", "campusId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "transport_routes_universityId_code_key" ON "transport_routes"("universityId", "code");

-- CreateIndex
CREATE INDEX "transport_allocations_universityId_routeId_status_idx" ON "transport_allocations"("universityId", "routeId", "status");

-- CreateIndex
CREATE INDEX "transport_allocations_studentId_status_idx" ON "transport_allocations"("studentId", "status");

-- CreateIndex
CREATE INDEX "timetable_slots_universityId_campusId_academicYear_dayOfWee_idx" ON "timetable_slots"("universityId", "campusId", "academicYear", "dayOfWeek", "periodNumber");

-- CreateIndex
CREATE INDEX "timetable_slots_employeeId_academicYear_dayOfWeek_idx" ON "timetable_slots"("employeeId", "academicYear", "dayOfWeek");

-- CreateIndex
CREATE INDEX "research_projects_universityId_status_endsAt_idx" ON "research_projects"("universityId", "status", "endsAt");

-- CreateIndex
CREATE UNIQUE INDEX "research_projects_universityId_code_key" ON "research_projects"("universityId", "code");

-- CreateIndex
CREATE INDEX "research_publications_universityId_publishedAt_idx" ON "research_publications"("universityId", "publishedAt");

-- CreateIndex
CREATE INDEX "research_publications_universityId_doi_idx" ON "research_publications"("universityId", "doi");

-- CreateIndex
CREATE INDEX "employers_universityId_name_idx" ON "employers"("universityId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "employers_universityId_code_key" ON "employers"("universityId", "code");

-- CreateIndex
CREATE INDEX "placement_drives_universityId_status_applicationDeadline_idx" ON "placement_drives"("universityId", "status", "applicationDeadline");

-- CreateIndex
CREATE UNIQUE INDEX "placement_drives_universityId_code_key" ON "placement_drives"("universityId", "code");

-- CreateIndex
CREATE INDEX "placement_applications_studentId_stage_idx" ON "placement_applications"("studentId", "stage");

-- CreateIndex
CREATE UNIQUE INDEX "placement_applications_driveId_studentId_key" ON "placement_applications"("driveId", "studentId");

-- CreateIndex
CREATE INDEX "learning_materials_universityId_courseId_status_idx" ON "learning_materials"("universityId", "courseId", "status");

-- CreateIndex
CREATE INDEX "learning_materials_universityId_programmeId_idx" ON "learning_materials"("universityId", "programmeId");

-- CreateIndex
CREATE INDEX "assignments_universityId_courseId_dueAt_idx" ON "assignments"("universityId", "courseId", "dueAt");

-- CreateIndex
CREATE INDEX "assignment_submissions_studentId_submittedAt_idx" ON "assignment_submissions"("studentId", "submittedAt");

-- CreateIndex
CREATE UNIQUE INDEX "assignment_submissions_assignmentId_studentId_key" ON "assignment_submissions"("assignmentId", "studentId");

-- CreateIndex
CREATE INDEX "support_tickets_universityId_status_priority_createdAt_idx" ON "support_tickets"("universityId", "status", "priority", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "support_tickets_universityId_ticketNumber_key" ON "support_tickets"("universityId", "ticketNumber");

-- CreateIndex
CREATE INDEX "support_ticket_comments_universityId_ticketId_createdAt_idx" ON "support_ticket_comments"("universityId", "ticketId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "alumni_profiles_studentId_key" ON "alumni_profiles"("studentId");

-- CreateIndex
CREATE INDEX "alumni_profiles_universityId_graduationYear_idx" ON "alumni_profiles"("universityId", "graduationYear");

-- CreateIndex
CREATE UNIQUE INDEX "alumni_profiles_universityId_alumniNumber_key" ON "alumni_profiles"("universityId", "alumniNumber");

-- CreateIndex
CREATE INDEX "inventory_assets_universityId_campusId_category_status_idx" ON "inventory_assets"("universityId", "campusId", "category", "status");

-- CreateIndex
CREATE UNIQUE INDEX "inventory_assets_universityId_assetCode_key" ON "inventory_assets"("universityId", "assetCode");

-- CreateIndex
CREATE INDEX "vendors_universityId_name_idx" ON "vendors"("universityId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "vendors_universityId_code_key" ON "vendors"("universityId", "code");

-- CreateIndex
CREATE INDEX "purchase_orders_universityId_status_orderedAt_idx" ON "purchase_orders"("universityId", "status", "orderedAt");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_orders_universityId_orderNumber_key" ON "purchase_orders"("universityId", "orderNumber");

-- CreateIndex
CREATE INDEX "purchase_order_items_purchaseOrderId_idx" ON "purchase_order_items"("purchaseOrderId");

-- CreateIndex
CREATE INDEX "employee_leaves_employeeId_startsOn_endsOn_status_idx" ON "employee_leaves"("employeeId", "startsOn", "endsOn", "status");

-- CreateIndex
CREATE INDEX "payroll_records_payrollMonth_status_idx" ON "payroll_records"("payrollMonth", "status");

-- CreateIndex
CREATE UNIQUE INDEX "payroll_records_employeeId_payrollMonth_key" ON "payroll_records"("employeeId", "payrollMonth");

-- CreateIndex
CREATE INDEX "report_jobs_universityId_status_requestedAt_idx" ON "report_jobs"("universityId", "status", "requestedAt");

-- CreateIndex
CREATE INDEX "universities_officialEmail_idx" ON "universities"("officialEmail");

-- CreateIndex
CREATE UNIQUE INDEX "university_addresses_universityId_addressType_key" ON "university_addresses"("universityId", "addressType");

-- AddForeignKey
ALTER TABLE "institutional_roles" ADD CONSTRAINT "institutional_roles_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_role_permissions" ADD CONSTRAINT "institutional_role_permissions_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "institutional_roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_role_permissions" ADD CONSTRAINT "institutional_role_permissions_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "institutional_permissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_users" ADD CONSTRAINT "institutional_users_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_users" ADD CONSTRAINT "institutional_users_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_users" ADD CONSTRAINT "institutional_users_collegeId_fkey" FOREIGN KEY ("collegeId") REFERENCES "affiliated_colleges"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_user_roles" ADD CONSTRAINT "institutional_user_roles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "institutional_users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_user_roles" ADD CONSTRAINT "institutional_user_roles_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "institutional_roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_login_logs" ADD CONSTRAINT "institutional_login_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "institutional_users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "affiliated_colleges" ADD CONSTRAINT "affiliated_colleges_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "affiliated_colleges" ADD CONSTRAINT "affiliated_colleges_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "faculties" ADD CONSTRAINT "faculties_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_facultyId_fkey" FOREIGN KEY ("facultyId") REFERENCES "faculties"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "programmes" ADD CONSTRAINT "programmes_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "programmes" ADD CONSTRAINT "programmes_facultyId_fkey" FOREIGN KEY ("facultyId") REFERENCES "faculties"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "programmes" ADD CONSTRAINT "programmes_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "affiliated_programmes" ADD CONSTRAINT "affiliated_programmes_collegeId_fkey" FOREIGN KEY ("collegeId") REFERENCES "affiliated_colleges"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "affiliated_programmes" ADD CONSTRAINT "affiliated_programmes_programmeId_fkey" FOREIGN KEY ("programmeId") REFERENCES "programmes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "affiliated_programmes" ADD CONSTRAINT "affiliated_programmes_affiliationId_fkey" FOREIGN KEY ("affiliationId") REFERENCES "affiliation_records"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "courses" ADD CONSTRAINT "courses_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "courses" ADD CONSTRAINT "courses_programmeId_fkey" FOREIGN KEY ("programmeId") REFERENCES "programmes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "courses" ADD CONSTRAINT "courses_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "academic_sessions" ADD CONSTRAINT "academic_sessions_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "academic_terms" ADD CONSTRAINT "academic_terms_academicSessionId_fkey" FOREIGN KEY ("academicSessionId") REFERENCES "academic_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "academic_terms" ADD CONSTRAINT "academic_terms_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_collegeId_fkey" FOREIGN KEY ("collegeId") REFERENCES "affiliated_colleges"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_programmeId_fkey" FOREIGN KEY ("programmeId") REFERENCES "programmes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_academicSessionId_fkey" FOREIGN KEY ("academicSessionId") REFERENCES "academic_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_guardians" ADD CONSTRAINT "student_guardians_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_documents" ADD CONSTRAINT "student_documents_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_qualifications" ADD CONSTRAINT "employee_qualifications_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "employees"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_experiences" ADD CONSTRAINT "employee_experiences_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "employees"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "university_registrations" ADD CONSTRAINT "university_registrations_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "regulatory_approvals" ADD CONSTRAINT "regulatory_approvals_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "regulatory_approvals" ADD CONSTRAINT "regulatory_approvals_registrationId_fkey" FOREIGN KEY ("registrationId") REFERENCES "university_registrations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "registration_documents" ADD CONSTRAINT "registration_documents_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "registration_documents" ADD CONSTRAINT "registration_documents_registrationId_fkey" FOREIGN KEY ("registrationId") REFERENCES "university_registrations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "registration_documents" ADD CONSTRAINT "registration_documents_approvalId_fkey" FOREIGN KEY ("approvalId") REFERENCES "regulatory_approvals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accreditation_records" ADD CONSTRAINT "accreditation_records_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accreditation_metrics" ADD CONSTRAINT "accreditation_metrics_accreditationId_fkey" FOREIGN KEY ("accreditationId") REFERENCES "accreditation_records"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accreditation_metrics" ADD CONSTRAINT "accreditation_metrics_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "iqac_profiles" ADD CONSTRAINT "iqac_profiles_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "iqac_members" ADD CONSTRAINT "iqac_members_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "iqac_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "iqac_members" ADD CONSTRAINT "iqac_members_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "iqac_meetings" ADD CONSTRAINT "iqac_meetings_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "iqac_meetings" ADD CONSTRAINT "iqac_meetings_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "iqac_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "iqac_action_reports" ADD CONSTRAINT "iqac_action_reports_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "iqac_action_reports" ADD CONSTRAINT "iqac_action_reports_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "iqac_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "iqac_action_reports" ADD CONSTRAINT "iqac_action_reports_meetingId_fkey" FOREIGN KEY ("meetingId") REFERENCES "iqac_meetings"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "affiliation_records" ADD CONSTRAINT "affiliation_records_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "affiliation_records" ADD CONSTRAINT "affiliation_records_collegeId_fkey" FOREIGN KEY ("collegeId") REFERENCES "affiliated_colleges"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hierarchy_positions" ADD CONSTRAINT "hierarchy_positions_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hierarchy_positions" ADD CONSTRAINT "hierarchy_positions_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "hierarchy_positions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "university_committees" ADD CONSTRAINT "university_committees_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "committee_members" ADD CONSTRAINT "committee_members_committeeId_fkey" FOREIGN KEY ("committeeId") REFERENCES "university_committees"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "committee_members" ADD CONSTRAINT "committee_members_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "university_profile_versions" ADD CONSTRAINT "university_profile_versions_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "academic_calendar_events" ADD CONSTRAINT "academic_calendar_events_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "academic_calendar_events" ADD CONSTRAINT "academic_calendar_events_academicSessionId_fkey" FOREIGN KEY ("academicSessionId") REFERENCES "academic_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcements" ADD CONSTRAINT "announcements_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcements" ADD CONSTRAINT "announcements_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcements" ADD CONSTRAINT "announcements_academicSessionId_fkey" FOREIGN KEY ("academicSessionId") REFERENCES "academic_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcements" ADD CONSTRAINT "announcements_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "institutional_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcement_audiences" ADD CONSTRAINT "announcement_audiences_announcementId_fkey" FOREIGN KEY ("announcementId") REFERENCES "announcements"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dashboard_widgets" ADD CONSTRAINT "dashboard_widgets_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dashboard_widget_settings" ADD CONSTRAINT "dashboard_widget_settings_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dashboard_widget_settings" ADD CONSTRAINT "dashboard_widget_settings_widgetId_fkey" FOREIGN KEY ("widgetId") REFERENCES "dashboard_widgets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dashboard_widget_settings" ADD CONSTRAINT "dashboard_widget_settings_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "institutional_roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dashboard_widget_settings" ADD CONSTRAINT "dashboard_widget_settings_userId_fkey" FOREIGN KEY ("userId") REFERENCES "institutional_users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "university_settings" ADD CONSTRAINT "university_settings_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_documents" ADD CONSTRAINT "institutional_documents_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_documents" ADD CONSTRAINT "institutional_documents_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_documents" ADD CONSTRAINT "institutional_documents_accreditationId_fkey" FOREIGN KEY ("accreditationId") REFERENCES "accreditation_records"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_documents" ADD CONSTRAINT "institutional_documents_announcementId_fkey" FOREIGN KEY ("announcementId") REFERENCES "announcements"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institutional_documents" ADD CONSTRAINT "institutional_documents_uploadedById_fkey" FOREIGN KEY ("uploadedById") REFERENCES "institutional_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "document_versions" ADD CONSTRAINT "document_versions_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES "institutional_documents"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflows" ADD CONSTRAINT "approval_workflows_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES "approval_workflows"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_requesterId_fkey" FOREIGN KEY ("requesterId") REFERENCES "institutional_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_requestId_fkey" FOREIGN KEY ("requestId") REFERENCES "approval_requests"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_approverId_fkey" FOREIGN KEY ("approverId") REFERENCES "institutional_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_recipientId_fkey" FOREIGN KEY ("recipientId") REFERENCES "institutional_users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "erp_records" ADD CONSTRAINT "erp_records_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "erp_records" ADD CONSTRAINT "erp_records_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "erp_records" ADD CONSTRAINT "erp_records_collegeId_fkey" FOREIGN KEY ("collegeId") REFERENCES "affiliated_colleges"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "erp_records" ADD CONSTRAINT "erp_records_academicSessionId_fkey" FOREIGN KEY ("academicSessionId") REFERENCES "academic_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "erp_records" ADD CONSTRAINT "erp_records_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "institutional_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tenant_audit_logs" ADD CONSTRAINT "tenant_audit_logs_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tenant_audit_logs" ADD CONSTRAINT "tenant_audit_logs_institutionalUserId_fkey" FOREIGN KEY ("institutionalUserId") REFERENCES "institutional_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admission_applications" ADD CONSTRAINT "admission_applications_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admission_applications" ADD CONSTRAINT "admission_applications_programmeId_fkey" FOREIGN KEY ("programmeId") REFERENCES "programmes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admission_applications" ADD CONSTRAINT "admission_applications_academicSessionId_fkey" FOREIGN KEY ("academicSessionId") REFERENCES "academic_sessions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admission_applications" ADD CONSTRAINT "admission_applications_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admission_documents" ADD CONSTRAINT "admission_documents_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admission_documents" ADD CONSTRAINT "admission_documents_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "admission_applications"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "employees"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "courses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "examinations" ADD CONSTRAINT "examinations_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "examinations" ADD CONSTRAINT "examinations_academicSessionId_fkey" FOREIGN KEY ("academicSessionId") REFERENCES "academic_sessions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "examination_results" ADD CONSTRAINT "examination_results_examinationId_fkey" FOREIGN KEY ("examinationId") REFERENCES "examinations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "examination_results" ADD CONSTRAINT "examination_results_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "examination_results" ADD CONSTRAINT "examination_results_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "courses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fee_structures" ADD CONSTRAINT "fee_structures_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fee_structures" ADD CONSTRAINT "fee_structures_programmeId_fkey" FOREIGN KEY ("programmeId") REFERENCES "programmes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fee_payments" ADD CONSTRAINT "fee_payments_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fee_payments" ADD CONSTRAINT "fee_payments_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fee_payments" ADD CONSTRAINT "fee_payments_academicSessionId_fkey" FOREIGN KEY ("academicSessionId") REFERENCES "academic_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "library_books" ADD CONSTRAINT "library_books_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "library_loans" ADD CONSTRAINT "library_loans_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "library_loans" ADD CONSTRAINT "library_loans_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "library_loans" ADD CONSTRAINT "library_loans_bookId_fkey" FOREIGN KEY ("bookId") REFERENCES "library_books"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hostel_rooms" ADD CONSTRAINT "hostel_rooms_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hostel_rooms" ADD CONSTRAINT "hostel_rooms_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hostel_allocations" ADD CONSTRAINT "hostel_allocations_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hostel_allocations" ADD CONSTRAINT "hostel_allocations_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hostel_allocations" ADD CONSTRAINT "hostel_allocations_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "hostel_rooms"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transport_routes" ADD CONSTRAINT "transport_routes_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transport_routes" ADD CONSTRAINT "transport_routes_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transport_allocations" ADD CONSTRAINT "transport_allocations_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transport_allocations" ADD CONSTRAINT "transport_allocations_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transport_allocations" ADD CONSTRAINT "transport_allocations_routeId_fkey" FOREIGN KEY ("routeId") REFERENCES "transport_routes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetable_slots" ADD CONSTRAINT "timetable_slots_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetable_slots" ADD CONSTRAINT "timetable_slots_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetable_slots" ADD CONSTRAINT "timetable_slots_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "courses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetable_slots" ADD CONSTRAINT "timetable_slots_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "research_projects" ADD CONSTRAINT "research_projects_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "research_projects" ADD CONSTRAINT "research_projects_principalInvestigatorId_fkey" FOREIGN KEY ("principalInvestigatorId") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "research_publications" ADD CONSTRAINT "research_publications_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "research_publications" ADD CONSTRAINT "research_publications_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "research_projects"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employers" ADD CONSTRAINT "employers_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "placement_drives" ADD CONSTRAINT "placement_drives_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "placement_drives" ADD CONSTRAINT "placement_drives_employerId_fkey" FOREIGN KEY ("employerId") REFERENCES "employers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "placement_applications" ADD CONSTRAINT "placement_applications_driveId_fkey" FOREIGN KEY ("driveId") REFERENCES "placement_drives"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "placement_applications" ADD CONSTRAINT "placement_applications_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "placement_applications" ADD CONSTRAINT "placement_applications_programmeId_fkey" FOREIGN KEY ("programmeId") REFERENCES "programmes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning_materials" ADD CONSTRAINT "learning_materials_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning_materials" ADD CONSTRAINT "learning_materials_programmeId_fkey" FOREIGN KEY ("programmeId") REFERENCES "programmes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning_materials" ADD CONSTRAINT "learning_materials_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "courses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_programmeId_fkey" FOREIGN KEY ("programmeId") REFERENCES "programmes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "courses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignment_submissions" ADD CONSTRAINT "assignment_submissions_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "assignments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignment_submissions" ADD CONSTRAINT "assignment_submissions_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "support_tickets" ADD CONSTRAINT "support_tickets_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "support_tickets" ADD CONSTRAINT "support_tickets_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "support_tickets" ADD CONSTRAINT "support_tickets_assignedEmployeeId_fkey" FOREIGN KEY ("assignedEmployeeId") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "support_ticket_comments" ADD CONSTRAINT "support_ticket_comments_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "support_ticket_comments" ADD CONSTRAINT "support_ticket_comments_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES "support_tickets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "alumni_profiles" ADD CONSTRAINT "alumni_profiles_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "alumni_profiles" ADD CONSTRAINT "alumni_profiles_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_assets" ADD CONSTRAINT "inventory_assets_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_assets" ADD CONSTRAINT "inventory_assets_campusId_fkey" FOREIGN KEY ("campusId") REFERENCES "campuses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_assets" ADD CONSTRAINT "inventory_assets_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "vendors"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendors" ADD CONSTRAINT "vendors_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "vendors"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_items" ADD CONSTRAINT "purchase_order_items_purchaseOrderId_fkey" FOREIGN KEY ("purchaseOrderId") REFERENCES "purchase_orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_leaves" ADD CONSTRAINT "employee_leaves_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "employees"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payroll_records" ADD CONSTRAINT "payroll_records_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_jobs" ADD CONSTRAINT "report_jobs_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_jobs" ADD CONSTRAINT "report_jobs_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "institutional_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
