import { prisma } from '../db/prisma.js'

export async function overview() {
  const [totalUniversities, activeUniversities, inactiveUniversities, universities, subscriptionGroups] = await Promise.all([
    prisma.university.count({ where: { deletedAt: null } }),
    prisma.university.count({ where: { deletedAt: null, status: 'ACTIVE' } }),
    prisma.university.count({ where: { deletedAt: null, status: { in: ['INACTIVE','SUSPENDED'] } } }),
    prisma.university.findMany({ where: { deletedAt: null }, select: { id: true, _count: { select: { campuses: { where: { deletedAt: null } } } }, metrics: { orderBy: { collectedAt: 'desc' }, take: 1, select: { studentCount: true, facultyCount: true, campusCount: true } } } }),
    prisma.universitySubscription.groupBy({ by: ['status'], _count: { _all: true } }),
  ])
  const totalStudents = universities.reduce((sum, university) => sum + (university.metrics[0]?.studentCount ?? 0), 0)
  const totalFaculty = universities.reduce((sum, university) => sum + (university.metrics[0]?.facultyCount ?? 0), 0)
  const metricCampusTotal = universities.reduce((sum, university) => sum + (university.metrics[0]?.campusCount ?? 0), 0)
  const metricUniversityCount = universities.filter(university => university.metrics.length > 0).length
  const campusFallback = universities.filter(university => university.metrics.length === 0).reduce((sum, university) => sum + university._count.campuses, 0)
  const resolvedCampusTotal = metricCampusTotal + campusFallback
  return {
    totalUniversities, activeUniversities, inactiveUniversities,
    totalCampuses: resolvedCampusTotal,
    totalStudents, totalFaculty,
    subscriptions: subscriptionGroups.reduce<Record<string, number>>((result, group) => { result[group.status] = group._count._all; return result }, {}),
    metricsCoverage: { universitiesWithVerifiedMetrics: metricUniversityCount, totalUniversities },
  }
}

export async function universityStatistics(months = 12) {
  const since = new Date()
  since.setMonth(since.getMonth() - (months - 1), 1)
  const records = await prisma.university.findMany({ where: { deletedAt: null, createdAt: { gte: since } }, select: { createdAt: true } })
  const counts = new Map<string, number>()
  for (const record of records) {
    const key = `${record.createdAt.getFullYear()}-${String(record.createdAt.getMonth()+1).padStart(2,'0')}`
    counts.set(key, (counts.get(key) || 0) + 1)
  }
  return Array.from({ length: months }, (_, index) => {
    const date = new Date(since.getFullYear(), since.getMonth()+index, 1)
    const key = `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}`
    return { month: key, registrations: counts.get(key) || 0 }
  })
}

export async function subscriptionsOverview() {
  const records = await prisma.universitySubscription.findMany({ where: { university: { deletedAt: null } }, include: { plan: { select: { code: true, name: true, priceMonthly: true, currency: true } }, university: { select: { id: true, name: true, code: true } } }, orderBy: { createdAt: 'desc' }, take: 100 })
  const grouped = await prisma.universitySubscription.groupBy({ by: ['status'], _count: { _all: true } })
  return { totals: grouped.reduce<Record<string, number>>((result, item) => { result[item.status] = item._count._all; return result }, {}), items: records }
}

export async function recentActivities(limit = 20) {
  return prisma.platformAuditLog.findMany({ take: limit, orderBy: { createdAt: 'desc' }, include: { actor: { select: { id: true, name: true, email: true } }, university: { select: { id: true, name: true, code: true } } } })
}

export async function systemHealth() {
  let database: 'healthy'|'unavailable' = 'healthy'
  try { await prisma.$queryRaw`SELECT 1` } catch { database = 'unavailable' }
  const tenantStates = await prisma.tenantDatabase.groupBy({ by: ['status'], _count: { _all: true } }).catch(() => [])
  return { checkedAt: new Date().toISOString(), database, api: 'healthy', tenantDatabases: tenantStates.reduce<Record<string,number>>((result,row)=>{result[row.status]=row._count._all;return result},{}), queue: 'not_configured', backup: 'not_configured' }
}
