-- =====================================================================
-- ISE 503 Course Project — Spring 2026
-- SBU Dining System — 10 Complex Queries (with joins)
-- =====================================================================
-- Run AFTER 01_create_tables.sql and 02_insert_data.sql
-- Each query uses 2+ JOINs and demonstrates aggregation, subqueries,
-- self-joins, outer joins, set operations, or HAVING filters.
-- =====================================================================


-- =====================================================================
-- QUERY 1
-- Top 5 students by total dining spend, including their meal plan.
-- Joins: Student × DiningTransaction × MealPlan
-- Demonstrates: 3-way join, aggregation, ORDER BY, LIMIT.
-- =====================================================================
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name           AS student_name,
    mp.plan_name                                 AS meal_plan,
    COUNT(t.transaction_id)                      AS num_transactions,
    ROUND(SUM(t.amount), 2)                      AS total_spent
FROM Student s
JOIN DiningTransaction t ON s.student_id = t.student_id
JOIN MealPlan mp         ON s.plan_id    = mp.plan_id
GROUP BY s.student_id, s.first_name, s.last_name, mp.plan_name
ORDER BY total_spent DESC
LIMIT 5;


-- =====================================================================
-- QUERY 2
-- Top 10 most popular menu items by total quantity sold,
-- with revenue and category.
-- Joins: MenuItem × TransactionItem × DiningTransaction
-- Demonstrates: 3-way join, multiple aggregations, ORDER BY.
-- =====================================================================
SELECT
    mi.item_id,
    mi.item_name,
    mi.category,
    SUM(ti.quantity)                              AS total_sold,
    COUNT(DISTINCT t.transaction_id)              AS appears_in_transactions,
    ROUND(SUM(ti.quantity * ti.item_price), 2)    AS total_revenue
FROM MenuItem mi
JOIN TransactionItem ti  ON mi.item_id        = ti.item_id
JOIN DiningTransaction t ON ti.transaction_id = t.transaction_id
GROUP BY mi.item_id, mi.item_name, mi.category
ORDER BY total_sold DESC, total_revenue DESC
LIMIT 10;


-- =====================================================================
-- QUERY 3
-- Average rating and review count per dining hall — only halls
-- with at least 3 reviews. Sorted by best rated.
-- Joins: DiningHall × Review
-- Demonstrates: aggregation, GROUP BY, HAVING filter.
-- =====================================================================
SELECT
    dh.hall_id,
    dh.hall_name,
    dh.location,
    COUNT(r.review_id)              AS num_reviews,
    ROUND(AVG(r.rating), 2)         AS avg_rating,
    MIN(r.rating)                   AS lowest_rating,
    MAX(r.rating)                   AS highest_rating
FROM DiningHall dh
JOIN Review r ON dh.hall_id = r.hall_id
WHERE r.hall_id IS NOT NULL
GROUP BY dh.hall_id, dh.hall_name, dh.location
HAVING COUNT(r.review_id) >= 3
ORDER BY avg_rating DESC, num_reviews DESC;


-- =====================================================================
-- QUERY 4
-- Find vegan AND gluten-free menu items that contain no allergens.
-- Useful for students with severe dietary restrictions.
-- Joins: MenuItem × ItemAllergen (LEFT)
-- Demonstrates: LEFT JOIN, IS NULL pattern, multi-condition filter.
-- =====================================================================
SELECT
    mi.item_id,
    mi.item_name,
    mi.category,
    mi.calories,
    mi.price
FROM MenuItem mi
LEFT JOIN ItemAllergen ia ON mi.item_id = ia.item_id
WHERE mi.is_vegan = 1
  AND mi.is_gluten_free = 1
  AND ia.allergen_id IS NULL
ORDER BY mi.category, mi.item_name;


-- =====================================================================
-- QUERY 5
-- Employees who supervise others: list each supervisor with their
-- subordinate count, average subordinate wage, and dining hall.
-- Joins: Employee SELF-JOIN × DiningHall
-- Demonstrates: self-join, aggregation, multiple joins.
-- =====================================================================
SELECT
    sup.employee_id                                         AS supervisor_id,
    sup.first_name || ' ' || sup.last_name                  AS supervisor_name,
    sup.role                                                AS supervisor_role,
    dh.hall_name                                            AS hall_name,
    COUNT(sub.employee_id)                                  AS subordinate_count,
    ROUND(AVG(sub.hourly_wage), 2)                          AS avg_subordinate_wage,
    ROUND(sup.hourly_wage - AVG(sub.hourly_wage), 2)        AS wage_gap
FROM Employee sup
JOIN Employee sub  ON sup.employee_id = sub.supervisor_id
JOIN DiningHall dh ON sup.hall_id     = dh.hall_id
GROUP BY sup.employee_id, sup.first_name, sup.last_name,
         sup.role, sup.hourly_wage, dh.hall_name
ORDER BY subordinate_count DESC, supervisor_name;


-- =====================================================================
-- QUERY 6
-- Revenue per dining hall broken down by payment method.
-- Helps identify which halls rely most on meal swipes vs cash/card.
-- Joins: DiningHall × DiningTransaction
-- Demonstrates: aggregation across two grouping keys.
-- =====================================================================
SELECT
    dh.hall_name,
    t.payment_method,
    COUNT(t.transaction_id)         AS num_transactions,
    ROUND(SUM(t.amount), 2)         AS total_revenue,
    ROUND(AVG(t.amount), 2)         AS avg_transaction_value
FROM DiningHall dh
JOIN DiningTransaction t ON dh.hall_id = t.hall_id
GROUP BY dh.hall_name, t.payment_method
ORDER BY dh.hall_name, total_revenue DESC;


-- =====================================================================
-- QUERY 7
-- Students who have eaten at 3 or more distinct dining halls,
-- with their total spend and number of unique halls visited.
-- Joins: Student × DiningTransaction × MealPlan
-- Demonstrates: COUNT(DISTINCT ...), HAVING, 3-way join.
-- =====================================================================
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name        AS student_name,
    s.major,
    mp.plan_name                              AS meal_plan,
    COUNT(DISTINCT t.hall_id)                 AS distinct_halls_visited,
    COUNT(t.transaction_id)                   AS total_transactions,
    ROUND(SUM(t.amount), 2)                   AS total_spent
FROM Student s
JOIN DiningTransaction t ON s.student_id = t.student_id
JOIN MealPlan mp         ON s.plan_id    = mp.plan_id
GROUP BY s.student_id, s.first_name, s.last_name, s.major, mp.plan_name
HAVING COUNT(DISTINCT t.hall_id) >= 3
ORDER BY distinct_halls_visited DESC, total_spent DESC;


-- =====================================================================
-- QUERY 8
-- Full daily menu for 2026-04-20 with allergen warnings: each item
-- shown with its station, dining hall, dietary flags, and a list of
-- allergens (or "None" if allergen-free).
-- Joins: DailyMenu × Station × DiningHall × MenuItem × ItemAllergen × Allergen (LEFT)
-- Demonstrates: 6-way join, LEFT JOIN, GROUP_CONCAT, COALESCE.
-- =====================================================================
-- NOTE: GROUP_CONCAT works in SQLite/MySQL.
-- For PostgreSQL, replace with STRING_AGG(a.allergen_name, ', ').
SELECT
    dh.hall_name,
    st.station_name,
    dm.meal_period,
    mi.item_name,
    mi.category,
    mi.price,
    CASE WHEN mi.is_vegan = 1 THEN 'V' WHEN mi.is_vegetarian = 1 THEN 'VG' ELSE '' END
        || CASE WHEN mi.is_gluten_free = 1 THEN ' GF' ELSE '' END  AS dietary_tags,
    COALESCE(GROUP_CONCAT(a.allergen_name, ', '), 'None')          AS allergens
FROM DailyMenu dm
JOIN Station st       ON dm.station_id  = st.station_id
JOIN DiningHall dh    ON st.hall_id     = dh.hall_id
JOIN MenuItem mi      ON dm.item_id     = mi.item_id
LEFT JOIN ItemAllergen ia ON mi.item_id = ia.item_id
LEFT JOIN Allergen a      ON ia.allergen_id = a.allergen_id
WHERE dm.serve_date = '2026-04-20'
GROUP BY dh.hall_name, st.station_name, dm.meal_period,
         mi.item_name, mi.category, mi.price,
         mi.is_vegan, mi.is_vegetarian, mi.is_gluten_free
ORDER BY dh.hall_name, dm.meal_period, st.station_name, mi.item_name;


-- =====================================================================
-- QUERY 9
-- Menu items that have NEVER been ordered AND have no reviews
-- (candidates for menu removal).
-- Joins: MenuItem × TransactionItem (LEFT) × Review (LEFT)
-- Demonstrates: LEFT JOIN with IS NULL anti-join pattern.
-- =====================================================================
SELECT
    mi.item_id,
    mi.item_name,
    mi.category,
    mi.price
FROM MenuItem mi
LEFT JOIN TransactionItem ti ON mi.item_id = ti.item_id
LEFT JOIN Review r           ON mi.item_id = r.item_id
WHERE ti.transaction_id IS NULL
  AND r.review_id IS NULL
ORDER BY mi.category, mi.item_name;


-- =====================================================================
-- QUERY 10
-- Students on a meal plan more expensive than the average plan price,
-- who have also spent more than 75% of all students' average spend.
-- Highlights "high investment" students whose actual usage justifies it.
-- Joins: Student × MealPlan × DiningTransaction; with subqueries.
-- Demonstrates: scalar subqueries in WHERE/HAVING, aggregation, joins.
-- =====================================================================
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name                       AS student_name,
    s.class_year,
    mp.plan_name                                             AS meal_plan,
    mp.price                                                 AS plan_price,
    ROUND(SUM(t.amount), 2)                                  AS total_spent,
    COUNT(t.transaction_id)                                  AS num_transactions,
    ROUND(AVG(t.amount), 2)                                  AS avg_transaction
FROM Student s
JOIN MealPlan mp         ON s.plan_id    = mp.plan_id
JOIN DiningTransaction t ON s.student_id = t.student_id
WHERE mp.price > (SELECT AVG(price) FROM MealPlan)
GROUP BY s.student_id, s.first_name, s.last_name,
         s.class_year, mp.plan_name, mp.price
HAVING SUM(t.amount) > 0.75 * (
        SELECT AVG(student_total)
        FROM (
            SELECT SUM(amount) AS student_total
            FROM DiningTransaction
            GROUP BY student_id
        ) AS per_student_totals
    )
ORDER BY total_spent DESC;
