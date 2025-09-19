## SIH-2025 JanMitra Server (JavaScript)

### Setup
- Create a `.env` in this folder based on the keys below (dotfiles may be blocked in this workspace editor):
  - PORT, NODE_ENV
  - SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
  - JWT_SECRET, JWT_EXPIRES_IN
  - CITIZEN_EMAIL, CITIZEN_PASSWORD, CITIZEN_FULL_NAME, CITIZEN_PHONE, CITIZEN_ADDRESS
  - STAFF_EMAIL, STAFF_PASSWORD, STAFF_FULL_NAME, STAFF_PHONE, STAFF_ADDRESS
  - ADMIN_EMAIL, ADMIN_PASSWORD, ADMIN_FULL_NAME, ADMIN_PHONE, ADMIN_ADDRESS

### Install & Run
```bash
cd server
npm install
npm run dev
```

### Database
- Run `scripts/init.sql` in your Supabase SQL editor.


