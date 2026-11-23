-- Add database-level validation to newly introduced, currently empty ERP tables.
ALTER TABLE "academic_sessions" ADD CONSTRAINT "academic_sessions_date_range_check" CHECK ("endDate" >= "startDate");
ALTER TABLE "academic_sessions" ADD CONSTRAINT "academic_sessions_admission_range_check" CHECK ("admissionStart" IS NULL OR "admissionEnd" IS NULL OR "admissionEnd" >= "admissionStart");
ALTER TABLE "examinations" ADD CONSTRAINT "examinations_date_range_check" CHECK ("startDate" IS NULL OR "endDate" IS NULL OR "endDate" >= "startDate");
ALTER TABLE "examination_results" ADD CONSTRAINT "examination_results_marks_nonnegative_check" CHECK ("marksObtained" IS NULL OR "marksObtained" >= 0);
ALTER TABLE "fee_structures" ADD CONSTRAINT "fee_structures_amount_nonnegative_check" CHECK ("amount" >= 0);
ALTER TABLE "fee_payments" ADD CONSTRAINT "fee_payments_amount_positive_check" CHECK ("amount" > 0);
ALTER TABLE "library_books" ADD CONSTRAINT "library_books_copy_counts_check" CHECK ("copiesTotal" >= 0 AND "copiesAvailable" >= 0 AND "copiesAvailable" <= "copiesTotal");
ALTER TABLE "employee_leaves" ADD CONSTRAINT "employee_leaves_date_range_check" CHECK ("endsOn" >= "startsOn");
ALTER TABLE "payroll_records" ADD CONSTRAINT "payroll_records_amounts_nonnegative_check" CHECK ("grossAmount" >= 0 AND "deductions" >= 0 AND "netAmount" >= 0);
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_total_nonnegative_check" CHECK ("totalAmount" >= 0);
ALTER TABLE "purchase_order_items" ADD CONSTRAINT "purchase_order_items_amounts_check" CHECK ("quantity" > 0 AND "unitPrice" >= 0 AND "lineTotal" >= 0);
