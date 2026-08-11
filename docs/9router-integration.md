# Integrasi 9Router — detail

9Router (port `20128`) = local smart router yang nge-routing request model ke banyak provider (ZenProxy, Freebuff, Pollinations, dll). Copilot ditambahkan sebagai provider `CP/`.

## Arsitektur

```
Client (OpenCode/Claude Code/Hermes)
   │  model=CP/auto
   ▼
9Router (:20128)  ── provider: Copilot (CP) ──►  copilot2api-go (:4141)  ──►  GitHub Copilot
```

## 1. Registrasi provider di 9Router

9Router nyimpen state di SQLite: `%APPDATA%\9router\db\data.sqlite` (atau lokasi appdata masing-masing).

### Node (tabel `providerNodes`)

Setiap provider punya row dengan `data` JSON:

```json
{
  "prefix": "CP",
  "apiType": "openai-compatible-chat",
  "baseUrl": "http://localhost:4141/v1"
}
```

### Connection (tabel `providerConnections`)

```json
{
  "name": "Copilot-apissaj",
  "provider": "<nodeId>",
  "apiKey": "<API_KEY_DARI_WEB_CONSOLE>",
  "isActive": true
}
```

> Wajib: kolom `id` harus diisi format `conn-<uuid>` dan `email` jangan NULL — 9Router nggak load connection yang id/email NULL.

### Model registry (tabel `kv` scope `customModels`)

Model yang muncul di `/v1/models` di-register di sini. Format:

```
key:   customModels/<nodeId>|<modelName>|llm
value: {"providerAlias":"<nodeId>","id":"<modelName>","type":"llm","name":"<modelName>"}
```

Contoh:

```
key:   customModels/openai-compatible-chat-a9aaefc0...|auto|llm
value: {"providerAlias":"openai-compatible-chat-a9aaefc0...","id":"auto","type":"llm","name":"auto"}
```

## 2. Restart 9Router

9Router **cache provider & model registry di memory** — setiap perubahan struktural DB (node/connection/customModels baru) butuh restart:

```bash
# kill server
PID=$(netstat -aon | grep ":20128" | grep LISTENING | awk '{print $5}' | head -1)
taskkill /F /PID $PID
# start via Startup vbs (tray supervisor)
wscript "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\9router.vbs"
```

## 3. Verifikasi

```bash
# model CP/ kebaca?
curl -s http://127.0.0.1:20128/v1/models -H "Authorization: Bearer <9ROUTER_KEY>"
# → CP/auto, CP/claude-opus-5, dst

# request jalan?
curl -s http://127.0.0.1:20128/v1/chat/completions \
  -H "Authorization: Bearer <9ROUTER_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"model":"CP/auto","messages":[{"role":"user","content":"Hello!"}]}'
```

## Pitfalls

- **Insert manual DB kadang nggak cukup** — dashboard Save di 9Router yang "resmi" nulis registry. Insert manual OK selama format persis, tapi pasti restart.
- **Duplikat connection** — kalau dashboard nulis ulang, bisa dobel row. Cek `providerConnections` buat duplikat `provider` + `name`.
- **Port conflict saat verifikasi** — kalau instance copilot2api-go udah jalan, `hermes verify` / boot test kedua bakal EADDRINUSE. Stop instance dulu sebelum verifikasi.
- **PATH copilot CLI** — instance gagal start kalau `copilot` binary nggak ke-resolve (PATH Windows default nggak include `%LOCALAPPDATA%\hermes\node`). Set PATH di `start-copilot.bat`.