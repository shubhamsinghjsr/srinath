const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:4000/api/v1'

export type PlatformUser = { id: string; name: string; email: string; roles: string[]; accountType?: 'PLATFORM'|'INSTITUTIONAL'; university?: {id:string;code:string;name:string}; campusId?:string|null; collegeId?:string|null }
export type PlatformUniversity = {
  id: string; code: string; name: string; shortName?: string | null; type: string; establishmentYear?: number | null
  registrationNumber?: string | null; website?: string | null; officialEmail: string; contactNumber: string; status: string
  createdAt: string; contact?: { personName: string; designation: string; email: string; mobile: string } | null
  address?: { addressLine: string; city: string; state: string; country: string; pinCode: string } | null
  accreditation?: { body?: string | null; grade?: string | null; validUntil?: string | null; details?: string | null } | null
  branding?: { logoPath?: string | null; primaryColor?: string | null; secondaryColor?: string | null } | null
  tenantDatabase?: { databaseName: string; status: string; lastVerifiedAt?: string | null; lastError?: string | null } | null
}

export function getToken() { return sessionStorage.getItem('tcu-platform-token') }
export function setPlatformSession(token: string, user: PlatformUser) { sessionStorage.setItem('tcu-platform-token', token); sessionStorage.setItem('tcu-platform-user', JSON.stringify(user)) }
export function clearPlatformSession() { sessionStorage.removeItem('tcu-platform-token'); sessionStorage.removeItem('tcu-platform-user') }
export function getPlatformUser(): PlatformUser | null { try { return JSON.parse(sessionStorage.getItem('tcu-platform-user') || 'null') } catch { return null } }

export async function platformRequest<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = new Headers(options.headers)
  const token = getToken()
  if (token) headers.set('Authorization', `Bearer ${token}`)
  if (!(options.body instanceof FormData) && options.body) headers.set('Content-Type', 'application/json')
  const response = await fetch(`${API_BASE}${path}`, { ...options, headers })
  const body = await response.json().catch(() => ({})) as { data?: T; error?: string; message?: string }
  if (!response.ok) {
    if (response.status === 401) { clearPlatformSession(); window.dispatchEvent(new Event('platform-session-expired')) }
    throw new Error(body.error || body.message || `Request failed (${response.status})`)
  }
  return body.data as T
}

export async function loginPlatform(email: string, password: string) {
  return platformRequest<{ token: string; user: PlatformUser }>('/auth/login', { method: 'POST', body: JSON.stringify({ email, password }) })
}

export async function loginInstitutional(universityCode:string,email:string,password:string) {
  return platformRequest<{token:string;user:PlatformUser}>('/auth/institutional-login',{method:'POST',body:JSON.stringify({universityCode,email,password})})
}
