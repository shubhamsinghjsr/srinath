import 'dotenv/config'
import pg from 'pg'

const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 1 })
try {
  const { rows } = await pool.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name")
  for (const { table_name } of rows) {
    const quoted = '"' + table_name.replaceAll('"', '""') + '"'
    const result = await pool.query(`SELECT count(*)::int AS count FROM public.${quoted}`)
    console.log(`${table_name}\t${result.rows[0].count}`)
  }
  const foreignKeys = await pool.query("SELECT count(*)::int AS count FROM information_schema.table_constraints WHERE table_schema = 'public' AND constraint_type = 'FOREIGN KEY'")
  const indexes = await pool.query("SELECT count(*)::int AS count FROM pg_indexes WHERE schemaname = 'public'")
  const uniqueIndexes = await pool.query("SELECT count(*)::int AS count FROM pg_indexes WHERE schemaname = 'public' AND indexdef ILIKE 'CREATE UNIQUE INDEX%'")
  const checkConstraints = await pool.query("SELECT count(*)::int AS count FROM pg_constraint WHERE contype = 'c' AND conname IN ('academic_sessions_date_range_check','academic_sessions_admission_range_check','examinations_date_range_check','examination_results_marks_nonnegative_check','fee_structures_amount_nonnegative_check','fee_payments_amount_positive_check','library_books_copy_counts_check','employee_leaves_date_range_check','payroll_records_amounts_nonnegative_check','purchase_orders_total_nonnegative_check','purchase_order_items_amounts_check')")
  console.log(`SUMMARY\tpublic_tables=${rows.length}\tforeign_keys=${foreignKeys.rows[0].count}\tindexes=${indexes.rows[0].count}\tunique_indexes=${uniqueIndexes.rows[0].count}\tERP_check_constraints=${checkConstraints.rows[0].count}`)
} finally {
  await pool.end()
}
