# 📊 SQL Projects

A portfolio of end-to-end SQL projects covering data exploration,
cleaning, transformation and analysis — built for real-world
Business Intelligence dashboards using Power BI.

All projects are written in **Databricks SQL** and **Google BigQuery**,
and follow a consistent pipeline structure from raw messy data
to a clean, analysis-ready dataset.

---

## 🛠️ Tools & Platforms

| Tool | Purpose |
|---|---|
| **Databricks** | Primary SQL environment |
| **Google BigQuery** | Secondary SQL environment |
| **Power BI** | Dashboard and visualisation |
| **GitHub** | Version control and portfolio showcase |

---

## 📁 Repository Structure

| Folder | Status | Description |
|---|---|---|
| **Banking-Finance-Analysis** | ✅ Complete | Customer, account and transaction analysis — SQL + Power BI dashboard |
| **Retail-Sales-Analysis** | 🔜 Coming Soon | Sales performance and product insights |
| **Healthcare-Analytics** | 🔜 Coming Soon | Patient admissions and treatment analysis |
| **HR-Workforce-Analysis** | 🔜 Coming Soon | Employee performance and payroll insights |

---

## ✅ Project 1 — Banking & Finance Analysis

**Status: Complete**

A full end-to-end data analytics project simulating a junior
data analyst role at a fictional bank. Raw messy data across
three tables was explored, cleaned and transformed using SQL,
then visualised in a professional Power BI dashboard.

| Detail | Info |
|---|---|
| **Dataset** | 5,600 rows across 3 tables |
| **SQL Platform** | Databricks |
| **BI Tool** | Power BI Desktop |
| **Cleaning Functions** | TRIM, UPPER, INITCAP, NULLIF, COALESCE, TRY_CAST, CASE, ROW_NUMBER |
| **Dashboard Pages** | Overview, Customer Analysis, Account Analysis, Transaction Analysis, Branch Performance |

**Key Findings:**
- 36.9% of transactions failed — a critical operational risk
- 47% of customers have Poor credit scores despite high incomes
- Online channel accounts for 54.9% of all transactions
- Mall Branch leads revenue at $8.6M, Eastside at $5.2M
- 80.55% of accounts are Active — healthy retention rate

📂 [View Project →](./Banking-Finance-Analysis/)

---

## 🧹 SQL Skills Demonstrated

### Cleaning Functions

| Function | Purpose |
|---|---|
| `TRIM()` | Remove leading and trailing whitespace |
| `UPPER()` | Normalize text to uppercase |
| `LOWER()` | Normalize emails and URLs to lowercase |
| `INITCAP()` | Capitalize first letter of each word |
| `NULLIF()` | Convert empty strings to proper NULLs |
| `COALESCE()` | Replace NULLs with fallback values |
| `IFNULL()` | Single fallback NULL replacement |
| `CAST()` | Convert columns to correct data types |
| `TRY_CAST()` | Safe type conversion — Databricks |
| `SAFE_CAST()` | Safe type conversion — BigQuery |
| `CASE` | Standardize inconsistent category values |
| `ROW_NUMBER()` | Identify and remove duplicate rows |

---

### SQL Concepts

| Concept | Description |
|---|---|
| **CTEs** | Single, chained and multi-table pipelines |
| **Window Functions** | ROW_NUMBER, RANK, LAG, LEAD, running totals |
| **JOINs** | INNER, LEFT, two-table and three-table pipelines |
| **Aggregations** | COUNT, SUM, AVG, GROUP BY, HAVING |
| **Deduplication** | ROW_NUMBER with PARTITION BY |
| **Date Functions** | DATEDIFF, DATEADD, EXTRACT, date formatting |
| **Calculated Columns** | Derived metrics built on clean data |

---

## 🏗️ Pipeline Pattern

Every project in this repository follows the same structure:

```sql
-- PHASE 1: Explore the raw data
SELECT * FROM raw_table LIMIT 10;

-- PHASE 2: Clean using CTEs
WITH cleaned AS (
    SELECT
        COALESCE(NULLIF(TRIM(INITCAP(name)), ''),
                 'Unknown')                      AS name,
        COALESCE(NULLIF(LOWER(TRIM(email)), ''),
                 'No Email')                     AS email,
        COALESCE(TRY_CAST(amount AS DECIMAL), 0) AS amount,
        CASE
            WHEN UPPER(status) LIKE '%ACTIVE%'   THEN 'Active'
            ELSE 'Inactive'
        END                                      AS status
    FROM raw_table
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY id, date
            ORDER BY record_id ASC
        ) AS row_num
    FROM cleaned
)

-- PHASE 3: Final SELECT with calculated columns
SELECT
    *,
    amount * 1.15 AS amount_with_tax
FROM deduped
WHERE row_num = 1;
```

---

## 💡 Key Lessons Learned

**Clean before deduplicating**
Dirty values cause `ROW_NUMBER()` to miss true
duplicates. Always clean first so values match
correctly inside `PARTITION BY`.

**Use `TRY_CAST` over `CAST` on real data**
`CAST` crashes on unexpected values. `TRY_CAST`
returns NULL instead, keeping the query running.

**`GROUP BY` must match `SELECT` exactly**
Any transformation in `SELECT` must be repeated
identically in `GROUP BY`, otherwise SQL groups
on the original dirty values.

**`NULL` does not equal `NULL` in `PARTITION BY`**
Wrap nullable columns with `COALESCE` before
using them in `PARTITION BY` so NULL values
match correctly across duplicate rows.

**Only join tables you need**
Always ask which columns you actually need before
writing a JOIN. More joins means more complexity
and more chances for errors.

---

## 👤 Author

**Siphamandla M.**
Junior Data Analyst
Specializing in SQL data cleaning, transformation
and Business Intelligence using Power BI.

---

## 📌 Status

🟢 Active — Project 1 complete. New projects added regularly.
