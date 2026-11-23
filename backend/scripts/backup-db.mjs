import 'dotenv/config'
import { spawnSync } from 'node:child_process'
import { mkdirSync, statSync } from 'node:fs'
import path from 'node:path'

const connection = new URL(process.env.DATABASE_URL ?? '')
if (!connection.hostname || !connection.pathname) throw new Error('DATABASE_URL is not configured')
const backupDir = path.resolve('backups')
mkdirSync(backupDir, { recursive: true })
const file = path.join(backupDir, `techcoder_platform_before_auth_scope_${new Date().toISOString().replaceAll(':', '').replaceAll('.', '')}.dump`)
const env = { ...process.env, PGPASSWORD: decodeURIComponent(connection.password) }
const args = ['--format=custom', '--no-owner', '--no-privileges', '--host', connection.hostname, '--port', connection.port || '5432', '--username', decodeURIComponent(connection.username), '--dbname', connection.pathname.slice(1), '--file', file]
const result = spawnSync('C:\\Program Files\\PostgreSQL\\18\\bin\\pg_dump.exe', args, { env, encoding: 'utf8' })
if (result.status !== 0) throw new Error(`pg_dump failed with exit code ${result.status}: ${result.stderr.trim()}`)
console.log(`Backup created: ${path.relative(process.cwd(), file)} (${statSync(file).size} bytes)`)
