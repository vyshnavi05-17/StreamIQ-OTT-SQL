# StreamIQ — OTT Streaming Analytics Database | SQL

StreamIQ is a portfolio-ready MySQL project that models an OTT streaming platform and demonstrates relational database design, SQL querying, analytics, reusable database objects, and query optimization.

## Project Objective

Build a normalized OTT database that can answer practical business questions around:

- User and profile activity
- Content and episode catalog
- Genres and cast relationships
- Watch history and engagement
- Subscription lifecycle
- Payments and revenue
- Ratings and content performance
- Device usage
- Multi-episode viewing
- Query performance and indexing

## Technology

- MySQL 8.0
- SQL
- Relational database design
- CTEs
- CASE expressions
- Subqueries
- JOINs
- Aggregate functions
- Window functions
- Views
- Stored procedures
- SQL functions
- Triggers
- Indexes
- EXPLAIN

## Database Structure

The database is named `streamiq` and contains 14 tables:

1. `users`
2. `profiles`
3. `devices`
4. `content`
5. `episodes`
6. `genres`
7. `content_genres`
8. `actors`
9. `content_cast`
10. `subscription_plans`
11. `subscriptions`
12. `payments`
13. `watch_history`
14. `ratings`

### Main relationships

```text
USERS
  ├── PROFILES
  │     └── DEVICES
  │
  ├── SUBSCRIPTIONS
  │     └── PAYMENTS
  │
  └── SUBSCRIPTION_PLANS

CONTENT
  ├── EPISODES
  ├── CONTENT_GENRES ── GENRES
  └── CONTENT_CAST ─── ACTORS

PROFILES ── WATCH_HISTORY ── CONTENT
PROFILES ── RATINGS ──────── CONTENT
```

## Project Data

Current verified dataset:

| Entity | Rows |
|---|---:|
| Users | 20 |
| Profiles | 27 |
| Devices | 25 |
| Content | 20 |
| Episodes | 50 |
| Genres | 12 |
| Content-Genre mappings | 59 |
| Actors | 30 |
| Content-Cast mappings | 60 |
| Subscription Plans | 5 |
| Subscriptions | 30 |
| Payments | 55 |
| Watch Sessions | 69 |
| Ratings | 40 |

## Key Verified KPIs

- Total watch sessions: **69**
- Total watch time: **4,084 minutes**
- Overall average completion: **77.59%**
- Active subscriptions: **24**
- Cancelled subscriptions: **6**
- Successful-payment revenue: **₹51,647**
- Subscription cancellation rate: **20.00%**

> The 20% figure is a subscription cancellation rate, not a true customer churn rate, because users can have multiple subscriptions.

## Analytics Covered

### Content performance
The project analyzes:

- Total views
- Total watch minutes
- Average completion
- Average rating
- Rating count
- Engagement classification

The content-performance view separates watch and rating aggregations before joining them to avoid one-to-many join multiplication.

### Engagement
Profiles are analyzed using:

- Watch sessions
- Total watch minutes
- Average session duration
- Average completion
- Unique content watched

### Subscription and revenue
The project analyzes:

- Active vs cancelled subscriptions
- Subscription duration
- Cancellation rate
- Resubscription behavior
- Revenue by subscription plan
- Monthly successful revenue
- Cumulative revenue
- Payment success/failure

### Device analytics

Device-attributed records are analyzed by:

- Device type
- Operating system
- Watch minutes
- Session count
- Average session duration
- Movie vs series usage

Historical watch records with unknown device attribution are not artificially backfilled.

### Episode and viewing behavior

The project includes:

- Episode viewing sessions
- Profiles watching episodes
- Series watched
- Multi-episode viewing within 24 hours
- Strict binge detection using 3+ distinct episodes of the same series within 24 hours

The current dataset has multi-episode viewing windows but no qualifying 3+ episode binge windows.

### Genre analytics

Genre-level analysis includes:

- Views
- Watch minutes
- Average completion
- Average rating

Because content can belong to multiple genres, genre-associated watch minutes can overlap.

## Advanced SQL Concepts

The project demonstrates:

- Multi-table JOINs
- LEFT JOINs
- CTEs
- CASE
- COALESCE
- HAVING
- Date functions
- Subqueries
- Correlated/derived analytical logic
- Window functions
- Ranking
- Running totals
- Time-window analysis
- Conditional aggregation
- Data integrity checks

## Views

Three analytical views are included:

### `vw_content_performance`

Content-level viewing and rating summary.

### `vw_profile_engagement`

Profile-level engagement summary.

### `vw_subscription_revenue`

Subscription-level payment and revenue summary.

## Stored Procedures

Four reusable procedures are included:

- `sp_register_user`
- `sp_record_watch_session`
- `sp_cancel_subscription`
- `sp_record_payment`

They demonstrate parameterized database operations.

## SQL Functions

Three functions are included:

- `fn_calculate_age`
- `fn_calculate_subscription_duration`
- `fn_get_user_engagement`

## Triggers

Two triggers are included:

### `trg_payment_success_activate`
A successful payment activates the related subscription and enables auto-renewal.

### `trg_validate_rating`
Prevents ratings outside the 1–5 range.

## Indexing and Optimization

Indexes created:

```sql
idx_watch_profile_start
    ON watch_history(profile_id, watch_start)

idx_watch_content
    ON watch_history(content_id)

idx_payments_date_status
    ON payments(payment_date, payment_status)
```

An `EXPLAIN` test confirmed that MySQL uses `idx_watch_profile_start` for a profile-based watch-history query ordered by watch start time.

## Repository Structure

```text
StreamIQ-OTT-SQL/
│
├── README.md
│
├── 01_database_design/
│   └── schema.sql
│
├── 02_data/
│   └── insert_data.sql
│
├── 04_basic_queries/
│   └── basic_queries.sql
│
├── 05_advanced_queries/
│   └── advanced_analytics.sql
│
├── 06_views/
│   └── views.sql
│
├── 07_stored_procedures/
│   └── procedures.sql
│
├── 08_functions/
│   └── functions.sql
│
├── 09_triggers/
│   └── triggers.sql
│
├── 10_indexes/
│   └── indexes.sql
│
├── 11_optimization/
│   └── explain_analysis.sql
│
└── 12_documentation/
    └── er_diagram.png
```

## How to Run

### 1. Create the database

```sql
CREATE DATABASE streamiq;
USE streamiq;
```

### 2. Create the tables

Run:

```text
01_database_design/schema.sql
```

### 3. Load the project data

Run:

```text
02_data/insert_data.sql
```

### 4. Run analytical queries

Start with:

```text
04_basic_queries/basic_queries.sql
```

Then run:

```text
05_advanced_queries/advanced_analytics.sql
```

### 5. Create reusable database objects

Run the files in this order:

```text
06_views/views.sql
07_stored_procedures/procedures.sql
08_functions/functions.sql
09_triggers/triggers.sql
10_indexes/indexes.sql
```

### 6. Check optimization

Run:

```text
11_optimization/explain_analysis.sql
```

## Data Integrity Validation

The project includes validation for:

- Orphaned foreign-key references
- Episode/content consistency
- Payment validity
- Payment status values
- Positive payment amounts
- Referential integrity

The verified integrity checks returned zero invalid/orphan records for the tested relationships.

## Portfolio Highlights

This project demonstrates practical SQL beyond simple SELECT statements:

**Design → Build → Populate → Query → Analyze → Automate → Optimize → Validate**

It can be used to demonstrate SQL skills for entry-level roles involving data analysis, reporting, operations, database work, and analytics.

## Resume Project Title

**StreamIQ — OTT Streaming Analytics Database | SQL**

### Resume Description

Designed and implemented a normalized OTT streaming database using SQL, modeling users, profiles, content, viewing history, subscriptions, payments and ratings; developed analytical queries, CTEs, window functions, views, stored procedures, triggers and indexes to analyze engagement, content performance, subscription cancellation and revenue.

## Author

**Pagidirayi Vyshnavi**

B.Tech — Computer Science and Engineering
