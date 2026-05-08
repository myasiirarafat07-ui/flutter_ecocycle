# EcoCycle Backend

Backend awal untuk fitur akun EcoCycle: register, login, dan profil user login.

## Setup

1. Buat database dari PDM:

```sql
SOURCE ../database/ecocycle_pdm.sql;
```

2. Isi tipe user awal:

```sql
SOURCE database/auth_seed.sql;
```

3. Salin konfigurasi:

```bash
cp .env.example .env
```

4. Sesuaikan `DB_USER`, `DB_PASSWORD`, dan `DB_NAME` di `.env`.

5. Install dependency dan jalankan server:

```bash
npm install
npm run dev
```

## Endpoint

- `GET /health`
- `GET /api/auth/user-types`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`

## Contoh Register

```json
{
  "full_name": "Yasiir Arafat",
  "email": "yasiir@example.com",
  "phone_number": "08123456789",
  "password": "secret123",
  "user_type": "Individual"
}
```

## Contoh Login

```json
{
  "email": "yasiir@example.com",
  "password": "secret123"
}
```
