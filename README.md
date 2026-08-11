# copilot2api-go-setup

Setup lengkap **copilot2api-go** (GitHub Copilot → OpenAI/Anthropic-compatible API server) di Windows — dari clone, OAuth device flow, sampai integrasi 9Router.

Repo ini berisi **dokumentasi + template setup** yang aman dipublikasikan (tanpa secret, tanpa token, tanpa akun).

## Apa itu copilot2api-go?

Turn **GitHub Copilot subscription** into an OpenAI/Anthropic-compatible API server. Usable with Claude Code, Codex, OpenCode, atau client OpenAI-compatible lainnya.

- Repo asli: [`StarryKira/copilot2api-go`](https://github.com/StarryKira/copilot2api-go)
- Proxy: port `4141` (OpenAI `/v1/chat/completions`, `/v1/messages` Anthropic)
- Web console: port `3000` (kelola akun, pool mode, rate limit)

## Quickstart (Windows)

### 1. Prasyarat

- [Go](https://go.dev/dl/) ≥ 1.22
- [Node.js](https://nodejs.org/) (buat `@github/copilot` CLI)
- GitHub Copilot subscription aktif (Pro / Pro+ / Max)

### 2. Clone & build

```bash
git clone --depth 1 https://github.com/StarryKira/copilot2api-go.git
cd copilot2api-go
go build -o copilot-go.exe .
```

### 3. Install Copilot CLI (dibutuhkan instance)

```bash
npm install -g @github/copilot
```

### 4. Jalankan server

```bash
copilot-go.exe --web-port 3000 --proxy-port 4141
```

### 5. Login akun Copilot

1. Buka `http://localhost:3000` (web console)
2. Setup admin account (username + password)
3. **Add account** → pilih **GitHub OAuth (device flow)**
4. Buka `https://github.com/login/device`, masukkan code yang ditampilkan
5. Approve akses → akun connect, instance auto-start

### 6. Test

```bash
# OpenAI-compatible
curl http://localhost:4141/v1/chat/completions \
  -H "Authorization: Bearer <API_KEY_DARI_CONSOLE>" \
  -H "Content-Type: application/json" \
  -d '{"model":"auto","messages":[{"role":"user","content":"Hello!"}]}'

# Anthropic-compatible
curl http://localhost:4141/v1/messages \
  -H "Authorization: Bearer <API_KEY_DARI_CONSOLE>" \
  -H "Content-Type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"auto","messages":[{"role":"user","content":"Hello!"}],"max_tokens":100}'
```

## Integrasi 9Router

9Router = smart router OpenAI-compatible local (port 20128). Tambah Copilot sebagai provider:

```
Prefix:  CP
BaseURL: http://localhost:4141/v1
API Key: (dari web console copilot2api-go)
Model:   auto, claude-opus-5, claude-sonnet-5, gpt-5.6-sol, dst.
```

Lalu panggil model via `CP/<model>` di client mana pun yang point ke 9Router:

```bash
curl http://127.0.0.1:20128/v1/chat/completions \
  -H "Authorization: Bearer <9ROUTER_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"model":"CP/auto","messages":[{"role":"user","content":"Hello!"}]}'
```

> Catatan: model registry 9Router = tabel `kv` scope `customModels` (DB SQLite). Nambah model = nambah entry `customModels/<nodeId>|<model>` + restart 9Router (cache memory).

## Model & Pricing

GitHub Copilot Pro ($10/bulan) = **1.500 AI credits/bulan** (1.000 base + 500 flex). 1 credit = $0.01. Setiap request dipotong dari budget ini berdasarkan model + token.

| Model | Pricing (per 1M token in/out) | Estimasi request/bulan (chat normal) |
|---|---|---|
| `auto` (GPT-5 mini, hemat) | $0.25 / $2.00 | ~7.500 |
| `gemini-3.6-flash` | $1.50 / $7.50 | ~1.500 |
| `claude-sonnet-5` | $2.00 / $10.00 | ~1.150 |
| `gpt-5.6-sol` (premium) | $5.00 / $30.00 | ~430 |
| `claude-opus-5` (premium) | $5.00 / $25.00 | ~460 |

**Model `auto`** = GitHub Auto Model Selection: route task ke model paling efisien secara real-time (task complexity + system health). Hemat credits, anti rate-limit, +10% diskon untuk paid plan.

## Autostart (Windows)

Template di [`templates/`](templates/):

- `start-copilot.bat` — set PATH (buat `copilot` CLI) + start binary + log
- `autostart.vbs` — jalankan batch hidden di boot (taruh di `shell:startup`)

## Struktur repo

```
copilot2api-go-setup/
├── README.md              ← ini
├── docs/
│   └── 9router-integration.md
└── templates/
    ├── start-copilot.bat
    └── autostart.vbs
```

## ⚠️ Keamanan

- **JANGAN commit**: `accounts.json`, `admin.json`, `copilot-go.log`, `*.exe`
- API key akun tersimpan di `~/.local/share/copilot-api/` (LUAR repo)
- Device flow OAuth token scoped ke Copilot app — bisa di-revoke kapan pun dari GitHub settings
- Rate limit copilot2api-go default **disabled** (`RATE_LIMIT_RPM` env kosong) — set via web console kalau perlu

## Lisensi

Template & dokumentasi: MIT. Produk asli: `StarryKira/copilot2api-go` (MIT).