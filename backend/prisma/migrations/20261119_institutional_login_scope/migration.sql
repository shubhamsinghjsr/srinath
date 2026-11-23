-- Correct the initial institutional login-log shape. The table is empty in
-- the inspected database; existing user sessions, if any, keep their rows.
ALTER TABLE "institutional_login_logs" DROP CONSTRAINT "institutional_login_logs_userId_fkey";

ALTER TABLE "institutional_login_logs"
  ADD COLUMN "email" VARCHAR(255),
  ADD COLUMN "universityId" UUID,
  ALTER COLUMN "userId" DROP NOT NULL;

UPDATE "institutional_login_logs" log
SET "email" = COALESCE(user_row."email", 'unknown@invalid.local'),
    "universityId" = user_row."universityId"
FROM "institutional_users" user_row
WHERE log."userId" = user_row."id";

ALTER TABLE "institutional_login_logs"
  ALTER COLUMN "email" SET NOT NULL;

CREATE INDEX "institutional_login_logs_email_createdAt_idx" ON "institutional_login_logs"("email", "createdAt");
CREATE INDEX "institutional_login_logs_universityId_createdAt_idx" ON "institutional_login_logs"("universityId", "createdAt");

ALTER TABLE "institutional_login_logs"
  ADD CONSTRAINT "institutional_login_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "institutional_users"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT "institutional_login_logs_universityId_fkey" FOREIGN KEY ("universityId") REFERENCES "universities"("id") ON DELETE SET NULL ON UPDATE CASCADE;
