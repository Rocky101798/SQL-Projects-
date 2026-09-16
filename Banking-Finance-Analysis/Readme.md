# 🏦 Banking & Finance Analysis

An end-to-end data analytics project covering SQL data cleaning,
transformation and Business Intelligence dashboard development
for a fictional bank — **Bright Motors Banking**.

The project simulates a real-world junior data analyst role:
receiving raw messy data, cleaning it with SQL, and delivering
actionable insights through a professional Power BI dashboard.

---

## 📋 Project Overview

| Detail | Info |
|---|---|
| **Industry** | Banking & Finance |
| **Role Simulated** | Junior Data Analyst |
| **Dataset Size** | 5,600 rows across 3 tables |
| **SQL Platform** | Databricks |
| **BI Tool** | Power BI Desktop |
| **Dashboard Theme** | Navy & Gold — Professional Banking |
| **Techniques Used** | Data Cleaning, CTEs, JOINs, ROW_NUMBER, DAX, Power BI |

---

## 📁 Project Files

| File | Description |
|---|---|
| `bank_customers.csv` | 500 raw customer records — messy, uncleaned |
| `bank_accounts.csv` | 2,000 raw account records — messy, uncleaned |
| `bank_transactions.csv` | 3,100 raw transactions including ~100 duplicates |
| `Project_1.csv` | Final cleaned dataset — 3,000 rows, 38 columns |
| `01_exploration.sql` | Phase 1 — data exploration and profiling queries |
| `02_cleaning.sql` | Phase 2 — full SQL cleaning pipeline |
| `03_analysis.sql` | Phase 3 — DAX measures and analysis queries |
| `BrightMotors_Dashboard.pbix` | Power BI Desktop source file |
| `BrightMotors_Dashboard.pdf` | Dashboard export — PDF format |
| `README.md` | This file |

---

## 🗂️ Dataset Schema

### bank_customers — 500 rows

| Column | Type | Description |
|---|---|---|
| `customer_id` | STRING | Unique ID C0001–C0500 |
| `customer_name` | STRING | Full name — mixed case and spaces |
| `customer_email` | STRING | Email — some missing |
| `phone_number` | STRING | Phone — some missing |
| `date_of_birth` | DATE | Date of birth |
| `gender` | STRING | Inconsistent case |
| `city` | STRING | Mixed case and spaces |
| `state` | STRING | State abbreviation |
| `employment_type` | STRING | Full-Time, FULL-TIME, full-time etc |
| `annual_income` | STRING | Stored as text, some missing |
| `membership_tier` | STRING | Standard, Silver, Gold, Platinum — messy |
| `customer_since` | DATE | Date customer joined |
| `credit_score` | STRING | 300–850, some missing |
| `branch` | STRING | Assigned branch |
| `status` | STRING | Active, Inactive — inconsistent case |

---

### bank_accounts — 2,000 rows

| Column | Type | Description |
|---|---|---|
| `account_id` | STRING | Unique ID A00001–A02000 |
| `customer_id` | STRING | Links to bank_customers |
| `account_type` | STRING | Savings, Checking, Business etc — messy |
| `account_status` | STRING | Active, Closed — inconsistent |
| `open_date` | DATE | Account opening date |
| `balance` | STRING | Stored as text, some missing |
| `interest_rate` | STRING | Some missing |
| `branch` | STRING | Branch holding the account |
| `currency` | STRING | USD — inconsistent case and spaces |

---

### bank_transactions — 3,100 rows

| Column | Type | Description |
|---|---|---|
| `transaction_id` | STRING | Unique transaction ID |
| `account_id` | STRING | Links to bank_accounts |
| `transaction_type` | STRING | Deposit, Withdrawal etc — messy + typos |
| `amount` | STRING | Stored as text, some missing |
| `transaction_date` | DATE | Date of transaction |
| `channel` | STRING | Online, ATM, Branch, Mobile — messy |
| `description` | STRING | Transaction description, some blank |
| `status` | STRING | Completed, Pending, Failed — messy |
| `reference_number` | STRING | Unique reference |

---

## 🔗 Table Relationships

```
bank_customers          bank_accounts           bank_transactions
──────────────          ─────────────           ─────────────────
customer_id  ←───────── customer_id
                        account_id   ←───────── account_id
```

---

## 🧹 Data Quality Issues Found & Fixed

| Issue | Table | Function Applied |
|---|---|---|
| Mixed case names and spaces | customers | `TRIM` + `INITCAP` |
| Missing emails and phones | customers | `NULLIF` + `COALESCE` |
| Inconsistent gender values | customers | `UPPER` + `CASE` |
| Annual income stored as text | customers | `TRY_CAST` |
| Missing credit scores | customers | `COALESCE` |
| Inconsistent membership tier | customers | `CASE` + `LIKE` |
| Inconsistent account types | accounts | `UPPER` + `CASE` |
| Balance stored as text | accounts | `TRY_CAST` |
| Missing interest rates | accounts | `COALESCE` |
| Currency inconsistency | accounts | `UPPER` + `TRIM` |
| ~100 duplicate transactions | transactions | `ROW_NUMBER()` |
| "Withdrawl" typo | transactions | `LIKE '%WITHDRAW%'` |
| Amount stored as text | transactions | `TRY_CAST` |
| Whitespace in description | transactions | `TRIM` before `NULLIF` |
| Inconsistent channel names | transactions | `CASE` + `LIKE` |
| Inconsistent status values | transactions | `CASE` + `UPPER` |

---

## 🏗️ SQL Cleaning Pipeline

```sql
-- CTE 1: Clean customers
WITH clean_customers AS (
    SELECT
        customer_id,
        COALESCE(NULLIF(TRIM(INITCAP(customer_name)),''),
                 'Unknown')                             AS customer_name,
        COALESCE(NULLIF(LOWER(TRIM(customer_email)),''),
                 'No Email')                            AS customer_email,
        CASE
            WHEN UPPER(TRIM(membership_tier))
                 LIKE '%PLATINUM%'                      THEN 'Platinum'
            WHEN UPPER(TRIM(membership_tier))
                 LIKE '%GOLD%'                          THEN 'Gold'
            WHEN UPPER(TRIM(membership_tier))
                 LIKE '%SILVER%'                        THEN 'Silver'
            ELSE 'Standard'
        END                                             AS membership_tier,
        COALESCE(TRY_CAST(annual_income AS DECIMAL), 0) AS annual_income,
        COALESCE(TRY_CAST(credit_score AS INT), 0)      AS credit_score
    FROM bank_customers
),

-- CTE 2: Clean accounts
clean_accounts AS (
    SELECT
        account_id,
        customer_id,
        CASE
            WHEN UPPER(TRIM(account_type))
                 LIKE '%SAVING%'                        THEN 'Savings'
            WHEN UPPER(TRIM(account_type))
                 LIKE '%CHECK%'                         THEN 'Checking'
            ELSE TRIM(INITCAP(account_type))
        END                                             AS account_type,
        COALESCE(TRY_CAST(balance AS DECIMAL), 0)       AS balance,
        COALESCE(TRY_CAST(interest_rate AS DECIMAL), 0) AS interest_rate
    FROM bank_accounts
),

-- CTE 3: Clean + deduplicate transactions
clean_transactions AS (
    SELECT
        transaction_id,
        account_id,
        CASE
            WHEN UPPER(TRIM(transaction_type))
                 LIKE '%WITHDRAW%'                      THEN 'Withdrawal'
            WHEN UPPER(TRIM(transaction_type))
                 LIKE '%DEPOSIT%'                       THEN 'Deposit'
            ELSE TRIM(INITCAP(transaction_type))
        END                                             AS transaction_type,
        COALESCE(TRY_CAST(amount AS DECIMAL), 0)        AS amount,
        transaction_date,
        ROW_NUMBER() OVER (
            PARTITION BY account_id,
                         UPPER(TRIM(transaction_type)),
                         TRIM(amount),
                         transaction_date
            ORDER BY transaction_id ASC
        )                                               AS row_num
    FROM bank_transactions
)

-- Final SELECT: JOIN all three + calculated columns
SELECT
    c.customer_id,
    c.customer_name,
    a.account_id,
    a.account_type,
    a.balance,
    t.transaction_id,
    t.transaction_type,
    t.amount,
    t.transaction_date,
    -- Calculated columns
    DATEDIFF(YEAR, c.date_of_birth,
             CURRENT_DATE())                            AS customer_age,
    CASE
        WHEN c.credit_score >= 740                      THEN 'Excellent'
        WHEN c.credit_score BETWEEN 670 AND 739         THEN 'Good'
        WHEN c.credit_score BETWEEN 580 AND 669         THEN 'Fair'
        WHEN c.credit_score > 0                         THEN 'Poor'
        ELSE 'Unknown'
    END                                                 AS credit_tier
FROM clean_customers       AS c
INNER JOIN clean_accounts  AS a ON c.customer_id = a.customer_id
INNER JOIN clean_transactions AS t ON a.account_id = t.account_id
WHERE t.row_num = 1;
```

---

## 📊 Power BI Dashboard

### Pages

| Page | Purpose | Key Visuals |
|---|---|---|
| **Overview** | High level summary | KPI cards, Monthly trend, Transaction Mix, Branch Revenue, Transaction Health |
| **Customer Analysis** | Customer segmentation | Membership Tier, Credit Tier, Income Band, City distribution |
| **Account Analysis** | Account portfolio | Account Type, Balance Band, Avg Balance, Account Status |
| **Transaction Analysis** | Transaction insights | Type breakdown, Channel split, Status donut, Monthly trend |
| **Branch Performance** | Branch comparison | Revenue, Customers and Transactions per branch |

---

### DAX Measures

```
Core KPIs:
  Total Customers, Total Accounts, Total Transactions
  Total Transaction Value, Avg Transaction Value
  Total Net Flow, Total Balance, Avg Balance

Transaction Measures:
  Total Deposits, Total Withdrawals, Total Payments
  Total Transfers, Total Refunds
  Completed Transactions, Failed Transactions
  Completion Rate %, Failure Rate %

Customer Measures:
  Active Customers, Inactive Customers
  Avg Credit Score, Avg Annual Income
  Gold Tier Customers, Platinum Tier Customers

Account Measures:
  Active Accounts, Closed Accounts
  Avg Interest Rate, Avg Account Age Years

Branch Measures:
  Revenue Per Branch, Customers Per Branch
  Transactions Per Branch
```

---

### Colour Palette

| Element | Hex Code |
|---|---|
| Page Background | `#1C1A19` |
| Card Background | `#2D2B2B` |
| Gold Accent | `#B68235` |
| Light Gold | `#F0D080` |
| Primary Text | `#F8F4F4` |
| Secondary Text | `#8A8888` |
| Positive / Completed | `#5DBE8A` |
| Negative / Failed | `#E07050` |
| Steel Blue | `#4A90D9` |
| Teal | `#2DBDBD` |

---

## 🔍 Key Findings

**Transaction Health**
Only 38.2% of transactions completed successfully.
36.9% failed — almost equal to the completion rate.
This is a critical operational issue requiring immediate
investigation into payment gateway reliability.

**Credit Risk**
47% of customers have Poor credit scores (below 580).
Only 19% have Excellent credit.
Despite 63% of customers earning above $100K annually,
the poor credit profile suggests high debt levels or
limited credit history.

**Channel Preference**
54.9% of transactions are made Online.
Only 13.1% are made at a physical Branch.
The bank should invest further in its digital infrastructure
and consider reducing Branch operating costs.

**Branch Performance**
Mall Branch leads with $8.6M revenue and 52 customers.
Eastside Branch is the lowest at $5.2M and 39 customers.
A 65% revenue gap between top and bottom branch suggests
uneven geographic customer distribution.

**Account Portfolio**
80.55% of accounts are Active — healthy retention rate.
Investment accounts have the highest average balance at $249K.
All 5 account types are evenly distributed at ~20% each —
a well diversified product portfolio.

---

## 💡 Recommendations

**1. Investigate Failed Transactions**
With a 36.9% failure rate, the bank should audit its
payment processing systems, identify failure patterns
by channel and transaction type, and implement
real-time failure alerts.

**2. Credit Risk Strategy**
Introduce credit improvement programmes for the 47%
of customers with Poor scores. Consider offering
secured products to high-income, low-credit customers
to build their credit profiles.

**3. Double Down on Digital**
With 54.9% of transactions Online and only 13.1%
at branches, the bank should accelerate investment
in its mobile and online banking platforms.

**4. Branch Optimisation**
Investigate why Eastside Branch consistently underperforms.
Consider targeted marketing campaigns or product promotions
specific to that branch's demographic.

**5. Membership Tier Upselling**
Standard tier customers (24.43%) represent an upsell
opportunity. A loyalty programme incentivising upgrades
to Silver, Gold or Platinum could increase retention
and revenue per customer.

---

## 👤 Author

**Siphamandla M.**
Junior Data Analyst
Specializing in SQL data cleaning, transformation
and Business Intelligence using Power BI.

---

## 📌 Project Status

✅ Complete — SQL cleaning pipeline, Power BI dashboard
and documentation all finished.
