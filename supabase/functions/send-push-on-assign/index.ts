// Supabase Edge Function: send-push-on-assign
//
// Trigger: siparisler tablosunda INSERT veya UPDATE (Database Webhook)
// Behavior: yeni `kurye_id` atandıysa → kurye user_id → user_devices.fcm_token →
// FCM HTTP v1 API ile push notification gönder.
//
// Env (supabase secrets set ...):
//   FCM_PROJECT_ID                — Firebase project ID (örn. kuryem-prod)
//   FCM_SERVICE_ACCOUNT_JSON      — Firebase service account JSON (string)
//   SUPABASE_URL                  — otomatik set (Edge Functions runtime)
//   SUPABASE_SERVICE_ROLE_KEY     — otomatik set (Edge Functions runtime)

// deno-lint-ignore-file no-explicit-any
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';

interface WebhookPayload {
  type: 'INSERT' | 'UPDATE' | 'DELETE';
  table: string;
  schema: string;
  record: Record<string, any> | null;
  old_record: Record<string, any> | null;
}

interface ServiceAccount {
  project_id: string;
  private_key: string;
  private_key_id: string;
  client_email: string;
}

const FCM_PROJECT_ID = Deno.env.get('FCM_PROJECT_ID')!;
const FCM_SERVICE_ACCOUNT_JSON = Deno.env.get('FCM_SERVICE_ACCOUNT_JSON')!;
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const sa: ServiceAccount = JSON.parse(FCM_SERVICE_ACCOUNT_JSON);
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

// ---------- OAuth2 access token (cached per cold-start) ----------
let cachedToken: { token: string; expiresAt: number } | null = null;

async function getAccessToken(): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) {
    return cachedToken.token;
  }

  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT', kid: sa.private_key_id };
  const claim = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };

  const enc = (obj: unknown) =>
    btoa(JSON.stringify(obj))
      .replace(/=/g, '')
      .replace(/\+/g, '-')
      .replace(/\//g, '_');

  const signInput = `${enc(header)}.${enc(claim)}`;
  const key = await importPrivateKey(sa.private_key);
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(signInput),
  );
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
  const jwt = `${signInput}.${sigB64}`;

  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  if (!tokenRes.ok) {
    throw new Error(`token exchange failed: ${tokenRes.status} ${await tokenRes.text()}`);
  }
  const { access_token, expires_in } = await tokenRes.json();
  cachedToken = { token: access_token, expiresAt: Date.now() + expires_in * 1000 };
  return access_token;
}

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const pkcs8 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const der = Uint8Array.from(atob(pkcs8), (c) => c.charCodeAt(0));
  return await crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

// ---------- FCM send + cleanup ----------
async function sendToToken(
  accessToken: string,
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<{ ok: boolean; shouldDelete: boolean; error?: string }> {
  const url = `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`;
  const message = {
    token,
    notification: { title, body },
    data,
    apns: {
      headers: { 'apns-priority': '10' },
      payload: {
        aps: { sound: 'default', badge: 1, 'content-available': 1 },
      },
    },
    android: {
      priority: 'HIGH',
      notification: { channel_id: 'orders', sound: 'default' },
    },
  };
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ message }),
  });
  if (res.ok) return { ok: true, shouldDelete: false };
  const errText = await res.text();
  // FCM v1: invalid/unregistered token errors → kalıcı, sil
  const shouldDelete =
    res.status === 404 ||
    errText.includes('UNREGISTERED') ||
    errText.includes('INVALID_ARGUMENT');
  return { ok: false, shouldDelete, error: `${res.status} ${errText}` };
}

// ---------- Handler ----------
Deno.serve(async (req) => {
  try {
    const payload = (await req.json()) as WebhookPayload;
    if (payload.table !== 'siparisler') {
      return new Response('ignored: wrong table', { status: 200 });
    }

    const newKuryeId = payload.record?.kurye_id ?? null;
    const oldKuryeId = payload.old_record?.kurye_id ?? null;

    // Guard: yalnızca yeni atama veya kurye değişimi
    if (!newKuryeId) return new Response('ignored: no kurye_id', { status: 200 });
    if (payload.type === 'UPDATE' && oldKuryeId === newKuryeId) {
      return new Response('ignored: kurye unchanged', { status: 200 });
    }

    const siparisId = payload.record?.id;
    if (!siparisId) return new Response('ignored: no siparis id', { status: 200 });

    // kurye → user_id
    const { data: kurye, error: kuryeErr } = await supabase
      .from('kuryeler')
      .select('user_id, ad')
      .eq('id', newKuryeId)
      .maybeSingle();
    if (kuryeErr || !kurye) {
      console.error('kurye lookup failed', kuryeErr, newKuryeId);
      return new Response('kurye not found', { status: 200 });
    }

    // user_id → tokens
    const { data: devices, error: devErr } = await supabase
      .from('user_devices')
      .select('fcm_token, platform')
      .eq('user_id', kurye.user_id);
    if (devErr) {
      console.error('user_devices lookup failed', devErr);
      return new Response('device lookup failed', { status: 500 });
    }
    if (!devices || devices.length === 0) {
      console.log(`no devices for user=${kurye.user_id} (kurye=${newKuryeId})`);
      return new Response('no devices', { status: 200 });
    }

    const accessToken = await getAccessToken();
    const title = 'Yeni iş';
    const body = 'Size yeni bir sipariş atandı';
    const data = { siparis_id: String(siparisId), type: 'new_order' };

    const results = await Promise.all(
      devices.map((d) => sendToToken(accessToken, d.fcm_token, title, body, data)),
    );

    let sent = 0;
    const toDelete: string[] = [];
    results.forEach((r, i) => {
      if (r.ok) sent++;
      else {
        console.error(`fcm error token=${i}`, r.error);
        if (r.shouldDelete) toDelete.push(devices[i].fcm_token);
      }
    });

    if (toDelete.length > 0) {
      await supabase.from('user_devices').delete().in('fcm_token', toDelete);
      console.log(`cleaned ${toDelete.length} invalid tokens`);
    }

    return new Response(
      JSON.stringify({ siparis_id: siparisId, sent, total: devices.length, cleaned: toDelete.length }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('handler error', err);
    return new Response(`error: ${(err as Error).message}`, { status: 500 });
  }
});
