# SBU Dining System — ISE 503 Project · Spring 2026

A full-stack relational database application modeling Stony Brook University's campus dining system.

**Stack:** PostgreSQL · Node.js / Express · React (Vite + Tailwind CSS)

---

## Project Structure

```
.
├── db/
│   ├── schema.sql          # PostgreSQL-compatible DDL (CREATE TABLE)
│   └── seed.sql            # Sample data — ~45 rows/table, 545 total
├── backend/                # Express REST API
│   ├── server.js
│   ├── db.js               # PostgreSQL connection pool
│   ├── .env                # DB credentials (copy from .env.example)
│   └── routes/
│       ├── stats.js        # Dashboard KPIs
│       ├── analytics.js    # 10 complex SQL queries
│       ├── diningHalls.js
│       ├── menuItems.js
│       ├── students.js
│       ├── dailyMenu.js
│       ├── reviews.js
│       └── transactions.js
├── frontend/               # React SPA
│   ├── vite.config.js      # Proxies /api → :3001
│   └── src/
│       ├── App.jsx
│       ├── components/     # Layout, Sidebar
│       └── pages/          # Dashboard, DiningHalls, MenuItems, DailyMenu,
│                           #   Students, Reviews, Analytics
├── 01_create_tables.sql    # Original DDL (MySQL/SQLite compatible)
├── 02_insert_data.sql      # Original seed data
└── 03_queries.sql          # 10 complex queries (original)
```

---

## Quick Start

### 1 — Create the PostgreSQL database

```bash
createdb sbu_dining
psql sbu_dining -f db/schema.sql
psql sbu_dining -f db/seed.sql
```

> If you use a password or different username, edit `backend/.env` first.

### 2 — Configure the backend

```bash
# Edit DB credentials if needed
nano backend/.env
```

Default `.env`:
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sbu_dining
DB_USER=postgres
DB_PASSWORD=
PORT=3001
```

### 3 — Start the backend

```bash
cd backend
npm install        # already done if you cloned fresh
npm run dev        # nodemon (auto-restart) — or: npm start
```

The API runs on **http://localhost:3001**

### 4 — Start the frontend

```bash
cd frontend
npm install        # already done if you cloned fresh
npm run dev
```

Open **http://localhost:5173** in your browser.

---

## Deployment (Neon + Render + Vercel — all free)

### Step 1 — Database on Neon

1. Sign up at [neon.tech](https://neon.tech) → **Create Project** → name it `sbu-dining`
2. Copy the **Connection String** (looks like `postgresql://user:pass@ep-xxx.neon.tech/neondb?sslmode=require`)
3. Open the Neon **SQL Editor** and run both files:
   ```sql
   -- paste contents of db/schema.sql, then:
   -- paste contents of db/seed.sql
   ```

### Step 2 — Backend on Render

1. Go to [render.com](https://render.com) → **New → Web Service**
2. Connect your GitHub repo, set **Root Directory** → `backend`
3. Settings:
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Environment:** Node
4. Add **Environment Variables:**
   | Key | Value |
   |-----|-------|
   | `DATABASE_URL` | (paste your Neon connection string) |
   | `NODE_ENV` | `production` |
   | `PORT` | `10000` |
5. Deploy → copy the service URL e.g. `https://sbu-dining-api.onrender.com`

### Step 3 — Frontend on Vercel

1. Go to [vercel.com](https://vercel.com) → **New Project** → import your GitHub repo
2. Set **Root Directory** → `frontend`
3. Add **Environment Variable:**
   | Key | Value |
   |-----|-------|
   | `VITE_API_URL` | `https://sbu-dining-api.onrender.com` |
4. Deploy → your app is live at `https://your-project.vercel.app`

> **Note:** Render's free tier spins down after 15 min of inactivity. The first request after sleep takes ~30s. Upgrade to a paid tier ($7/mo) to keep it always-on.



| Endpoint | Description |
|---|---|
| `GET /api/stats` | Dashboard KPIs (counts, revenue, avg rating) |
| `GET /api/dining-halls` | All 8 halls with station count & avg rating |
| `GET /api/menu-items` | Menu with filters: `?vegan=true&gluten_free=true&category=Entree` |
| `GET /api/daily-menu` | Menu by date/period: `?date=2026-04-20&period=Lunch` |
| `GET /api/daily-menu/dates` | List all available serve dates |
| `GET /api/students` | Students with meal plan & spending info |
| `GET /api/reviews` | Reviews with optional `?hall_id=` or `?item_id=` |
| `GET /api/transactions` | Transactions with optional filters |
| `GET /api/analytics/meta` | Metadata for all 10 queries |
| `GET /api/analytics/:id` | Run query 1–10, returns columns + rows |

---

## The 10 Analytical Queries

| # | Title | SQL Techniques |
|---|---|---|
| 1 | Top 5 Students by Spend | 3-way JOIN, aggregation, ORDER BY, LIMIT |
| 2 | Most Popular Menu Items | Multi-aggregation, ranking |
| 3 | Hall Ratings (≥ 3 reviews) | GROUP BY + HAVING |
| 4 | Vegan + GF Allergen-Free Items | LEFT JOIN + IS NULL anti-join |
| 5 | Supervisor Analysis | Self-join, wage gap |
| 6 | Revenue by Hall × Payment Method | Two-key GROUP BY |
| 7 | Students Who Visited 3+ Halls | COUNT(DISTINCT) + HAVING |
| 8 | Daily Menu with Allergen Warnings | 6-way JOIN + STRING_AGG |
| 9 | Dead Menu Items | Double LEFT JOIN anti-join |
| 10 | High-Investment Students | Scalar subqueries + nested aggregation |

All queries are runnable live from the **Analytics** page in the UI.

---

## Database Schema (12 tables, 545 rows)

| Table | Rows |
|---|---|
| MealPlan | 5 |
| DiningHall | 8 |
| Student | 35 |
| Employee | 35 |
| Station | 30 |
| MenuItem | 45 |
| Allergen | 10 |
| ItemAllergen | 60 |
| DailyMenu | 75 |
| DiningTransaction | 65 |
| TransactionItem | 132 |
| Review | 45 |
| **Total** | **545** |

---

## Frontend Pages

| Page | Description |
|---|---|
| Dashboard | KPI cards + top spenders, popular items, hall ratings |
| Dining Halls | Cards + table view of all 8 halls |
| Menu Items | Filterable table (category, vegan/GF/vegetarian, search) |
| Daily Menu | Date + meal period picker, grouped by hall → station |
| Students | Filterable table with meal plan & spending info |
| Reviews | Feed with rating distribution + filter by hall/item |
| Analytics | Run any of the 10 complex queries, view results live |
