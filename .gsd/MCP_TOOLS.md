# Available MCP Tools

> Read this at the start of every session. These are always available.

## 1. mobile-mcp (iOS Simulator Automation)
- **Server:** `mobile-mcp`
- **Device ID:** `04E43A5F-2FD2-4405-A574-DA757E506951` (iPhone 15 Pro, iOS 18.4)
- **Key tools:**
  - `mobile_take_screenshot` — `{device: "<id>"}` — screenshot as base64
  - `mobile_save_screenshot` — `{device: "<id>", saveTo: "/abs/path.png"}` — save to file
  - `mobile_list_elements_on_screen` — `{device: "<id>"}` — accessibility tree with coordinates
  - `mobile_click_on_screen_at_coordinates` — `{device: "<id>", x: N, y: N}` — tap
  - `mobile_type_keys` — `{device: "<id>", text: "..."}` — type into focused element
  - `mobile_swipe_on_screen` — `{device: "<id>", direction: "up|down|left|right"}`
  - `mobile_launch_app` — `{device: "<id>", packageName: "com.example.bursamotokurye"}`
  - `mobile_list_apps` — `{device: "<id>"}`
- **Usage:** Use for UI testing after `flutter run`. Take screenshot, read elements, tap, type.

## 2. supabase (Database & Backend)
- **Server:** `supabase`
- **Project ref:** `ebxvkbhrxxplauhsntda` (bursa-moto-kurye)
- **Key tools:**
  - `list_tables` — list all tables
  - `execute_sql` — run SELECT/INSERT/UPDATE/DELETE queries
  - `apply_migration` — run DDL (CREATE TABLE, ALTER, etc.)
  - `get_logs` — get project logs by service
  - `list_migrations` — list applied migrations
- **Note:** Supabase MCP has wrong access token binding — use curl with service_role key as primary method:
  ```bash
  SUPABASE_URL=$(grep SUPABASE_URL .env | head -1 | cut -d= -f2)
  SERVICE_KEY=$(grep SUPABASE_SERVICE_ROLE_KEY .env | cut -d= -f2)
  curl -s "${SUPABASE_URL}/rest/v1/<table>?select=*" -H "apikey: ${SERVICE_KEY}" -H "Authorization: Bearer ${SERVICE_KEY}"
  ```

## 3. context7 (Library Documentation)
- **Server:** `context7`
- **Tools:** `resolve-library-id`, `query-docs`
- **Usage:** Look up Flutter/Dart/Supabase/Riverpod docs

## 4. firebase (Not used in this project)
- Available but not needed — Supabase is the backend.

## Key Project Facts
- **Supabase URL:** `https://ebxvkbhrxxplauhsntda.supabase.co`
- **Auth user:** `43ea066b-7085-48fa-a576-b03d72b1c7b6` (mchtsenn16@gmail.com, role=operasyon — but app_users row was deleted for testing)
- **Entry point:** `lib/main_supabase.dart`
- **Run command:** `flutter run -d "<device_id>" --dart-define-from-file=.env lib/main_supabase.dart`
- **Env file:** `.env` contains SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_ACCESS_TOKEN, SUPABASE_SERVICE_ROLE_KEY
- **Flutter app ID:** `com.example.bursamotokurye`
