# SBU Dining System — ISE 503 Project

A relational database modeling Stony Brook University's campus dining system: meal plans, dining halls, food stations, menu items, students, employees, transactions, allergens, and reviews.

## Project structure

| File | Description |
|---|---|
| `00_design_document.md` | Schema design document (entities, relationships, constraints) |
| `01_create_tables.sql` | DDL — CREATE TABLE statements with all constraints |
| `02_insert_data.sql` | DML — sample data, ~45 rows per table |
| `03_queries.sql` | 10 complex SQL queries with multi-table joins |
| `README.md` | This file |

## Database statistics

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

Average ≈ **45 rows per table**.

## How to run

The SQL is portable and runs on **MySQL 8.0+, PostgreSQL, SQLite, MariaDB**.

### MySQL / MariaDB

```bash
mysql -u root -p
```
```sql
CREATE DATABASE sbu_dining;
USE sbu_dining;
SOURCE 01_create_tables.sql;
SOURCE 02_insert_data.sql;
SOURCE 03_queries.sql;
```

### PostgreSQL

```bash
createdb sbu_dining
psql sbu_dining
```
```sql
\i 01_create_tables.sql
\i 02_insert_data.sql
\i 03_queries.sql
```

> **Note for PostgreSQL:** in Query 8, replace `GROUP_CONCAT(a.allergen_name, ', ')` with `STRING_AGG(a.allergen_name, ', ')`. Replace `||` string concatenation works as-is.

### SQLite

```bash
sqlite3 sbu_dining.db
```
```sql
.read 01_create_tables.sql
.read 02_insert_data.sql
.read 03_queries.sql
```

## Validation

The full schema, data, and all 10 queries have been tested end-to-end on SQLite 3.45 (the `BOOLEAN` and `CHECK` syntax is portable across the listed DBs).

## Note on the table name `DiningTransaction`

The conceptual entity is "Transaction," but `TRANSACTION` is a reserved word in MySQL, PostgreSQL, and SQLite. The table is therefore named `DiningTransaction` to avoid the need for backticks/quotes.

## The 10 queries

1. **Top 5 spenders** — `Student × DiningTransaction × MealPlan` aggregation.
2. **Most popular menu items** — `MenuItem × TransactionItem × DiningTransaction` ranking by quantity sold.
3. **Hall ratings (≥3 reviews)** — `DiningHall × Review` with `HAVING` filter.
4. **Vegan + GF + allergen-free items** — `LEFT JOIN` anti-pattern.
5. **Supervisor analysis** — recursive self-join on `Employee` with wage gap.
6. **Revenue by hall × payment method** — two-key grouping.
7. **Students who tried 3+ halls** — `COUNT(DISTINCT)` with `HAVING`.
8. **Daily menu with allergen warnings** — 6-way join with `GROUP_CONCAT`.
9. **Dead menu items** — never ordered, never reviewed (anti-join).
10. **High-investment students** — nested subqueries and aggregation.
