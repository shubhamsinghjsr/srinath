export type Campus = { name: string; code: string; university: string; students: number; faculty: number; departments: number; programs: number; status: 'Active' | 'Review' }
export const campuses: Campus[] = [
  { name: 'TechCoder Main Campus', code: 'TCU-001', university: 'TechCoder University', students: 8240, faculty: 412, departments: 18, programs: 42, status: 'Active' },
  { name: 'North Valley Institute', code: 'TCU-002', university: 'TechCoder University', students: 5620, faculty: 286, departments: 14, programs: 31, status: 'Active' },
  { name: 'Lakeside College of Engineering', code: 'TCU-003', university: 'TechCoder University', students: 4180, faculty: 208, departments: 12, programs: 26, status: 'Active' },
  { name: 'Pioneer School of Management', code: 'TCU-004', university: 'TechCoder University', students: 2360, faculty: 126, departments: 8, programs: 16, status: 'Review' },
  { name: 'Greenfield Arts & Science', code: 'TCU-005', university: 'TechCoder University', students: 3870, faculty: 194, departments: 11, programs: 23, status: 'Active' },
  { name: 'TechCoder Medical Sciences', code: 'TCU-006', university: 'TechCoder University', students: 1940, faculty: 168, departments: 9, programs: 12, status: 'Active' },
]
export const approvals = [
  { id: 'APR-2048', name: 'Aarav Mehta', detail: 'B.Tech Computer Science', type: 'Admission Approval', date: 'Today, 10:42 AM', status: 'Pending' },
  { id: 'APR-2047', name: 'Ananya Sharma', detail: 'Scholarship · Merit Award', type: 'Scholarship Approval', date: 'Today, 09:18 AM', status: 'Pending' },
  { id: 'APR-2046', name: 'Dr. Rohan Kapoor', detail: 'Faculty · Leave request', type: 'Faculty Leave', date: 'Yesterday', status: 'Pending' },
  { id: 'APR-2045', name: 'Isha Patel', detail: 'Semester 4 · Document check', type: 'Document Verification', date: 'Nov 16, 2026', status: 'Pending' },
  { id: 'APR-2044', name: 'Kabir Nair', detail: 'Finance · Fee refund', type: 'Fee Refund Request', date: 'Nov 16, 2026', status: 'Pending' },
]
export const monthly = [
  { month: 'Jan', applications: 380, admitted: 290, rejected: 34 }, { month: 'Feb', applications: 420, admitted: 318, rejected: 42 }, { month: 'Mar', applications: 510, admitted: 394, rejected: 40 }, { month: 'Apr', applications: 460, admitted: 347, rejected: 38 }, { month: 'May', applications: 610, admitted: 472, rejected: 52 }, { month: 'Jun', applications: 720, admitted: 548, rejected: 61 }, { month: 'Jul', applications: 640, admitted: 502, rejected: 47 }, { month: 'Aug', applications: 810, admitted: 626, rejected: 68 }, { month: 'Sep', applications: 740, admitted: 566, rejected: 55 }, { month: 'Oct', applications: 920, admitted: 718, rejected: 72 }, { month: 'Nov', applications: 860, admitted: 674, rejected: 64 }, { month: 'Dec', applications: 680, admitted: 520, rejected: 49 },
]
export const distribution = [{ name: 'UG', value: 46, fill: '#6366f1' }, { name: 'PG', value: 24, fill: '#06b6d4' }, { name: 'Diploma', value: 13, fill: '#f59e0b' }, { name: 'B.Ed / M.Ed', value: 9, fill: '#8b5cf6' }, { name: 'Research', value: 8, fill: '#10b981' }]
export const activities = [
  { title: 'New university registered', body: 'Meridian Institute of Technology was added to the network.', time: '10:42 AM', color: 'violet' },
  { title: 'Campus created', body: 'North Valley Institute · TCU-007', time: '09:18 AM', color: 'blue' },
  { title: 'Admission received', body: '48 new applications for the 2026–27 session.', time: 'Yesterday', color: 'green' },
  { title: 'Fee payment received', body: '₹18.4L collected across 126 transactions.', time: 'Yesterday', color: 'amber' },
  { title: 'Examination results published', body: 'B.Tech Semester VI · Main Campus', time: 'Nov 15', color: 'rose' },
]
