-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "UniversityType" AS ENUM ('PUBLIC', 'PRIVATE', 'DEEMED', 'AUTONOMOUS', 'OTHER');

-- CreateEnum
CREATE TYPE "UniversityStatus" AS ENUM ('PENDING', 'ACTIVE', 'SUSPENDED', 'INACTIVE');

-- CreateEnum
CREATE TYPE "ProvisioningStatus" AS ENUM ('NOT_STARTED', 'PROVISIONING', 'READY', 'FAILED');

-- CreateEnum
CREATE TYPE "SubscriptionStatus" AS ENUM ('TRIAL', 'ACTIVE', 'PAST_DUE', 'CANCELLED', 'EXPIRED');

-- CreateTable
CREATE TABLE "universities" (
    "id" UUID NOT NULL,
    "code" VARCHAR(24) NOT NULL,
    "name" VARCHAR(180) NOT NULL,
    "shortName" VARCHAR(60),
    "type" "UniversityType" NOT NULL,
    "establishmentYear" INTEGER,
    "registrationNumber" VARCHAR(100),
    "website" VARCHAR(255),
    "officialEmail" VARCHAR(255) NOT NULL,
    "contactNumber" VARCHAR(40) NOT NULL,
    "status" "UniversityStatus" NOT NULL DEFAULT 'PENDING',
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "universities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "university_contacts" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "personName" VARCHAR(160) NOT NULL,
    "designation" VARCHAR(120) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "mobile" VARCHAR(40) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "university_contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "university_addresses" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "addressLine" VARCHAR(255) NOT NULL,
    "city" VARCHAR(120) NOT NULL,
    "state" VARCHAR(120) NOT NULL,
    "country" VARCHAR(100) NOT NULL,
    "pinCode" VARCHAR(20) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "university_addresses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "university_accreditations" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "body" VARCHAR(120),
    "grade" VARCHAR(30),
    "validUntil" TIMESTAMP(3),
    "details" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "university_accreditations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "university_branding" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "logoPath" VARCHAR(500),
    "primaryColor" VARCHAR(12),
    "secondaryColor" VARCHAR(12),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "university_branding_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tenant_databases" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "databaseName" VARCHAR(63) NOT NULL,
    "status" "ProvisioningStatus" NOT NULL DEFAULT 'NOT_STARTED',
    "encryptedConnection" TEXT,
    "lastVerifiedAt" TIMESTAMP(3),
    "lastError" VARCHAR(500),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tenant_databases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "campuses" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "code" VARCHAR(40) NOT NULL,
    "name" VARCHAR(180) NOT NULL,
    "status" VARCHAR(24) NOT NULL DEFAULT 'ACTIVE',
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "campuses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subscription_plans" (
    "id" UUID NOT NULL,
    "code" VARCHAR(40) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "priceMonthly" DECIMAL(12,2) NOT NULL,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'INR',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "subscription_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "university_subscriptions" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "planId" UUID NOT NULL,
    "status" "SubscriptionStatus" NOT NULL DEFAULT 'TRIAL',
    "startsAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endsAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "university_subscriptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "platform_users" (
    "id" UUID NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "passwordHash" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "lastLoginAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "platform_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "platform_roles" (
    "id" UUID NOT NULL,
    "code" VARCHAR(60) NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "description" VARCHAR(255),

    CONSTRAINT "platform_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "platform_permissions" (
    "id" UUID NOT NULL,
    "code" VARCHAR(120) NOT NULL,
    "description" VARCHAR(255),

    CONSTRAINT "platform_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "platform_user_roles" (
    "userId" UUID NOT NULL,
    "roleId" UUID NOT NULL,

    CONSTRAINT "platform_user_roles_pkey" PRIMARY KEY ("userId","roleId")
);

-- CreateTable
CREATE TABLE "platform_role_permissions" (
    "roleId" UUID NOT NULL,
    "permissionId" UUID NOT NULL,

    CONSTRAINT "platform_role_permissions_pkey" PRIMARY KEY ("roleId","permissionId")
);

-- CreateTable
CREATE TABLE "platform_audit_logs" (
    "id" UUID NOT NULL,
    "actorUserId" UUID,
    "universityId" UUID,
    "action" VARCHAR(120) NOT NULL,
    "entityType" VARCHAR(80) NOT NULL,
    "entityId" VARCHAR(100),
    "metadata" JSONB,
    "ipAddress" VARCHAR(64),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "platform_audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "platform_login_logs" (
    "id" UUID NOT NULL,
    "userId" UUID,
    "email" VARCHAR(255) NOT NULL,
    "tokenId" VARCHAR(64),
    "succeeded" BOOLEAN NOT NULL,
    "ipAddress" VARCHAR(64),
    "userAgent" VARCHAR(500),
    "revokedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "platform_login_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tenant_metrics" (
    "id" UUID NOT NULL,
    "universityId" UUID NOT NULL,
    "studentCount" INTEGER NOT NULL,
    "facultyCount" INTEGER NOT NULL,
    "campusCount" INTEGER NOT NULL DEFAULT 0,
    "collectedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "source" VARCHAR(80) NOT NULL,

    CONSTRAINT "tenant_metrics_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "platform_settings" (
    "key" VARCHAR(120) NOT NULL,
    "value" JSONB NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "platform_settings_pkey" PRIMARY KEY ("key")
);

-- CreateIndex
CREATE UNIQUE INDEX "universities_code_key" ON "universities"("code");

-- CreateIndex
CREATE UNIQUE INDEX "universities_registrationNumber_key" ON "universities"("registrationNumber");

-- CreateIndex
CREATE INDEX "universities_status_deletedAt_idx" ON "universities"("status", "deletedAt");

-- CreateIndex
CREATE INDEX "universities_name_idx" ON "universities"("name");

-- CreateIndex
CREATE UNIQUE INDEX "university_contacts_universityId_key" ON "university_contacts"("universityId");

-- CreateIndex
CREATE UNIQUE INDEX "university_addresses_universityId_key" ON "university_addresses"("universityId");

-- CreateIndex
CREATE INDEX "university_addresses_country_state_city_idx" ON "university_addresses"("country", "state", "city");

-- CreateIndex
CREATE UNIQUE INDEX "university_accreditations_universityId_key" ON "university_accreditations"("universityId");

-- CreateIndex
CREATE UNIQUE INDEX "university_branding_universityId_key" ON "university_branding"("universityId");

-- CreateIndex
CREATE UNIQUE INDEX "tenant_databases_universityId_key" ON "tenant_databases"("universityId");

-- CreateIndex
CREATE UNIQUE INDEX "tenant_databases_databaseName_key" ON "tenant_databases"("databaseName");

-- CreateIndex
CREATE INDEX "tenant_databases_status_idx" ON "tenant_databases"("status");

-- CreateIndex
CREATE INDEX "campuses_universityId_deletedAt_idx" ON "campuses"("universityId", "deletedAt");

-- CreateIndex
CREATE UNIQUE INDEX "campuses_universityId_code_key" ON "campuses"("universityId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "subscription_plans_code_key" ON "subscription_plans"("code");

-- CreateIndex
CREATE INDEX "university_subscriptions_status_endsAt_idx" ON "university_subscriptions"("status", "endsAt");

-- CreateIndex
CREATE INDEX "university_subscriptions_universityId_status_idx" ON "university_subscriptions"("universityId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "platform_users_email_key" ON "platform_users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "platform_roles_code_key" ON "platform_roles"("code");

-- CreateIndex
CREATE UNIQUE INDEX "platform_permissions_code_key" ON "platform_permissions"("code");

-- CreateIndex
CREATE INDEX "platform_audit_logs_createdAt_idx" ON "platform_audit_logs"("createdAt");

-- CreateIndex
CREATE INDEX "platform_audit_logs_entityType_entityId_idx" ON "platform_audit_logs"("entityType", "entityId");

-- CreateIndex
CREATE INDEX "platform_audit_logs_universityId_createdAt_idx" ON "platform_audit_logs"("universityId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "platform_login_logs_tokenId_key" ON "platform_login_logs"("tokenId");

-- CreateIndex
CREATE INDEX "platform_login_logs_userId_createdAt_idx" ON "platform_login_logs"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "platform_login_logs_email_createdAt_idx" ON "platform_login_logs"("email", "createdAt");

-- CreateIndex
CREATE INDEX "tenant_metrics_universityId_collectedAt_idx" ON "tenant_metrics"("universityId", "collectedAt" DESC);

-- AddForeignKey
ALTER TABLE "university_contacts" ADD CONSTRAINT "university_contacts_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "university_addresses" ADD CONSTRAINT "university_addresses_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "university_accreditations" ADD CONSTRAINT "university_accreditations_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "university_branding" ADD CONSTRAINT "university_branding_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tenant_databases" ADD CONSTRAINT "tenant_databases_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campuses" ADD CONSTRAINT "campuses_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "university_subscriptions" ADD CONSTRAINT "university_subscriptions_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "university_subscriptions" ADD CONSTRAINT "university_subscriptions_planId_fkey" FOREIGN KEY ("planId") REFERENCES "subscription_plans"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "platform_user_roles" ADD CONSTRAINT "platform_user_roles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "platform_users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "platform_user_roles" ADD CONSTRAINT "platform_user_roles_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "platform_roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "platform_role_permissions" ADD CONSTRAINT "platform_role_permissions_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "platform_roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "platform_role_permissions" ADD CONSTRAINT "platform_role_permissions_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "platform_permissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "platform_audit_logs" ADD CONSTRAINT "platform_audit_logs_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "platform_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "platform_audit_logs" ADD CONSTRAINT "platform_audit_logs_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "platform_login_logs" ADD CONSTRAINT "platform_login_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "platform_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tenant_metrics" ADD CONSTRAINT "tenant_metrics_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

