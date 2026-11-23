-- Manual rollback for migration.sql (execute only if the checks must be reverted).
ALTER TABLE "purchase_order_items" DROP CONSTRAINT "purchase_order_items_amounts_check";
ALTER TABLE "purchase_orders" DROP CONSTRAINT "purchase_orders_total_nonnegative_check";
ALTER TABLE "payroll_records" DROP CONSTRAINT "payroll_records_amounts_nonnegative_check";
ALTER TABLE "employee_leaves" DROP CONSTRAINT "employee_leaves_date_range_check";
ALTER TABLE "library_books" DROP CONSTRAINT "library_books_copy_counts_check";
ALTER TABLE "fee_payments" DROP CONSTRAINT "fee_payments_amount_positive_check";
ALTER TABLE "fee_structures" DROP CONSTRAINT "fee_structures_amount_nonnegative_check";
ALTER TABLE "examination_results" DROP CONSTRAINT "examination_results_marks_nonnegative_check";
ALTER TABLE "examinations" DROP CONSTRAINT "examinations_date_range_check";
ALTER TABLE "academic_sessions" DROP CONSTRAINT "academic_sessions_admission_range_check";
ALTER TABLE "academic_sessions" DROP CONSTRAINT "academic_sessions_date_range_check";
