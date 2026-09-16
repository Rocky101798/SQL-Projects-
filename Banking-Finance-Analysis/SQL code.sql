------- PHASE 1
-------- ANALYSING CUSTOMERS  
-----------
SELECT * FROM studies101.default.bank_customers;

---CHECKING TOTAL NUMBER OF CUSTOMERS
SELECT COUNT(*) AS Total_customers
FROM studies101.default.bank_customers; 

----CHECKING FOR NULLS AND BLANKS 
SELECT COUNT(*) - COUNT(NULLIF(TRIM(customer_name), '')) AS missing_Name, 
    COUNT(*) - COUNT(NULLIF(TRIM(customer_email), '')) AS Misisng_Emails, 
    COUNT(*) - COUNT(NULLIF(TRIM(phone_number), '')) AS Missing_Numbers, 
    COUNT(*) - COUNT(NULLIF(TRIM(date_of_birth), '')) AS Missing_DOB,
    COUNT(*) - COUNT(NULLIF(TRIM(gender), '')) AS Missing_Gender, 
    COUNT(*) - COUNT(NULLIF(TRIM(city), '')) AS Missing_City, 
    COUNT(*) - COUNT(NULLIF(TRIM(state), '')) AS Missing_State, 
    COUNT(*) - COUNT(NULLIF(TRIM(employment_type), '')) AS Missing_Employment, 
    COUNT(*) - COUNT(NULLIF(TRIM(annual_income), '')) AS Missing_Income, 
    COUNT(*) - COUNT(NULLIF(TRIM(membership_tier), '')) AS Missing_Membership,
    COUNT(*) - COUNT(NULLIF(TRIM(customer_since), '')) AS Missing_Customer_Since, 
    COUNT(*) - COUNT(NULLIF(TRIM(credit_score), '')) AS Missing_Credit_Score, 
    COUNT(*) - COUNT(NULLIF(TRIM(branch), '')) AS Missing_Branch, 
    COUNT(*) - COUNT(NULLIF(TRIM(status), '')) AS Missing_Status
FROM studies101.default.bank_customers;

---Checking for unique values
--------Membership tiers
SELECT TRIM(UPPER(membership_tier)) AS Membership_Tier, 
    COUNT(*) AS Count
FROM studies101.default.bank_customers
GROUP BY TRIM(UPPER(membership_tier))
ORDER BY Count DESC;

-------employment type
SELECT TRIM(INITCAP(employment_type)) AS Employment_Type, 
    COUNT(*) AS Count
FROM studies101.default.bank_customers
GROUP BY TRIM(INITCAP(employment_type))
ORDER BY Count DESC;

----status 
SELECT TRIM(INITCAP(status)) AS Status, 
    COUNT(*) AS Count
FROM studies101.default.bank_customers
GROUP BY TRIM(INITCAP(status))
ORDER BY Count DESC;

------gender 
SELECT TRIM(UPPER(gender)) AS Gender, 
    COUNT(*) AS Count
FROM studies101.default.bank_customers
GROUP BY TRIM(UPPER(gender))
ORDER BY Count DESC;

-----Checking for Credit and income ranges 
SELECT MIN(TRY_CAST(annual_income AS DECIMAL)) AS Min_Income, 
    MAX(TRY_CAST(annual_income AS DECIMAL)) AS Max_Income,
    ROUND(AVG(TRY_CAST(annual_income AS DECIMAL)), 2) AS Average_Income,
    MIN(TRY_CAST(credit_score AS DECIMAL)) AS Min_Credit_Score,
    MAX(TRY_CAST(credit_score AS DECIMAL)) AS Max_Credit_Score, 
    ROUND(AVG(TRY_CAST(credit_score AS DECIMAL)), 2) AS Average_Credit_Score
FROM studies101.default.bank_customers;

----------------
------ANALYZING ACCOUNTS
SELECT * FROM studies101.default.bank_accounts;

-----Count the rows
SELECT COUNT(*) AS Total_Accounts
FROM studies101.default.bank_accounts;

----Checking for nulls and blanks 
SELECT COUNT(*) - COUNT(NULLIF(TRIM(account_type), '')) AS Missing_Account_type, 
    COUNT(*) - COUNT(NULLIF(TRIM(account_status), '')) AS Missing_account_status, 
    COUNT(*) - COUNT(NULLIF(TRIM(open_date), '')) AS Missing_Open_Date,
    COUNT(*) - COUNT(NULLIF(TRIM(balance), '')) AS Missing_Balance, 
    COUNT(*) - COUNT(NULLIF(TRIM(interest_rate), '')) AS Missing_Interest_Rate, 
    COUNT(*) - COUNT(NULLIF(TRIM(branch), '')) AS Missing_Branch, 
    COUNT(*) - COUNT(NULLIF(TRIM(currency), '')) AS Missing_Currency
FROM studies101.default.bank_accounts;

-----CHECKING FOR UNIQUE VALUES
----account_type
SELECT TRIM(INITCAP(account_type)) AS Account_Type , 
    COUNT(*) AS Count
FROM studies101.default.bank_accounts
GROUP BY TRIM(INITCAP(account_type))
ORDER BY Count DESC;

----account_status
SELECT TRIM(UPPER(account_status)) AS Account_Status, 
    COUNT(*) AS Count
FROM studies101.default.bank_accounts
GROUP BY TRIM(UPPER(account_status))
ORDER BY Count DESC;

-----currency
SELECT TRIM(UPPER(currency)) AS Currency, 
    COUNT(*) AS Count
FROM studies101.default.bank_accounts
GROUP BY TRIM(UPPER(currency))
ORDER BY Count DESC;

-----branch
SELECT TRIM(INITCAP(branch)) AS Branch, 
    COUNT(*) AS Count
FROM studies101.default.bank_accounts
GROUP BY TRIM(INITCAP(branch))
ORDER BY Count DESC;

------Balance and interest rate ranges 
SELECT MIN(TRY_CAST(balance AS DECIMAL)) AS Min_Balance, 
    MAX(TRY_CAST(balance AS DECIMAL)) AS Max_Balance,
    ROUND(AVG(TRY_CAST(balance AS DECIMAL)), 2) AS Average_Balance,
    MIN(TRY_CAST(interest_rate AS DECIMAL)) AS Min_Interest_Rate,
    MAX(TRY_CAST(interest_rate AS DECIMAL)) AS Max_Interest_Rate, 
    ROUND(AVG(TRY_CAST(interest_rate AS DECIMAL)), 2) AS Average_Interest_Rate
FROM studies101.default.bank_accounts
WHERE balance IS NOT NULL
AND interest_rate IS NOT NULL;

-------How many accounts per customer 
SELECT Accounts_Per_Customer, 
    COUNT(*) AS Number_of_customers
FROM(
    SELECT customer_id, 
        COUNT(*) AS Accounts_Per_Customer
    FROM studies101.default.bank_accounts
    GROUP BY customer_id
) AS Account_Count
GROUP BY Accounts_Per_Customer
ORDER BY Accounts_Per_Customer DESC;

-----Active and Closed Accounts 
SELECT CASE WHEN TRIM(UPPER(account_status)) = 'ACTIVE' THEN 'Active'
            WHEN TRIM(UPPER(account_status)) = 'CLOSED' THEN 'Closed'
            ELSE 'Unknown'
        END AS Account_Status, 
        COUNT(*) AS Total_Accounts,
        ROUND(AVG(TRY_CAST(balance AS DECIMAL)), 2) AS Average_Balance
FROM studies101.default.bank_accounts
GROUP BY CASE WHEN TRIM(UPPER(account_status)) = 'ACTIVE' THEN 'Active'
            WHEN TRIM(UPPER(account_status)) = 'CLOSED' THEN 'Closed'
            ELSE 'Unknown'
        END
ORDER BY Total_Accounts DESC;
----option 2 with CTE 
WITH labelled AS (
    SELECT CASE
            WHEN UPPER(TRIM(account_status)) = 'ACTIVE' THEN 'Active'
            WHEN UPPER(TRIM(account_status)) = 'CLOSED' THEN 'Closed'
            ELSE 'Unknown'
        END AS account_status,
        TRY_CAST(balance AS DECIMAL) AS balance
    FROM studies101.default.bank_accounts
)

SELECT
    account_status,
    COUNT(*) AS total_accounts,
    ROUND(AVG(balance),2) AS avg_balance
FROM labelled
GROUP BY account_status 
ORDER BY total_accounts DESC;

-------------
------ANALYSING TRANSACTIONS 
SELECT * FROM studies101.default.bank_transactions;

-----Row Count
SELECT COUNT(*) AS Total_Transactions
FROM studies101.default.bank_transactions;

-----checking for nulls and blanks 
SELECT COUNT(*) - COUNT(NULLIF(TRIM(account_id), '')) AS Missing_Account_ID,
    COUNT(*) - COUNT(NULLIF(TRIM(transaction_id), '')) AS Missing_Transaction_ID,
    COUNT(*) - COUNT(NULLIF(TRIM(transaction_type), '')) AS Missing_Transaction_Type, 
    COUNT(*) - COUNT(NULLIF(TRIM(amount), '')) AS Missing_Amount, 
    COUNT(*) - COUNT(NULLIF(TRIM(transaction_date), '')) AS Missing_Transaction_Date,
    COUNT(*) - COUNT(NULLIF(TRIM(channel), '')) AS Missing_Channel, 
    COUNT(*) - COUNT(NULLIF(TRIM(description), '')) AS Missing_Description, 
    COUNT(*) - COUNT(NULLIF(TRIM(status), '')) AS Missing_Status, 
    COUNT(*) - COUNT(NULLIF(TRIM(reference_number), '')) AS Missing_Reference_Number
FROM studies101.default.bank_transactions;

--------CHECKING FOR UNIQUE VALUES
---transaction type
SELECT TRIM(INITCAP(transaction_type)) AS Transaction_Type, 
    COUNT(*) AS Count 
FROM studies101.default.bank_transactions
GROUP BY TRIM(INITCAP(transaction_type))
ORDER BY Count DESC;

----Channel 
SELECT TRIM(INITCAP(channel)) AS Channel, 
    COUNT(*) AS Count
FROM studies101.default.bank_transactions
GROUP BY TRIM(INITCAP(channel))
ORDER BY Count DESC;

----status 
SELECT TRIM(INITCAP(status)) AS Status, 
    COUNT(*) AS Count
FROM studies101.default.bank_transactions
GROUP BY TRIM(INITCAP(status))
ORDER BY Count DESC;

----description 
SELECT COALESCE(NULLIF(TRIM(description), ''), 'No Description') AS Description , 
    COUNT(*) AS Count
FROM studies101.default.bank_transactions
GROUP BY COALESCE(NULLIF(TRIM(description),''), 'No Description')
ORDER BY Count DESC;

-----Amount range
SELECT MIN(TRY_CAST(amount AS DECIMAL)) AS min_amount,
    MAX(TRY_CAST(amount AS DECIMAL)) AS max_amount,
    ROUND(AVG(TRY_CAST(amount AS DECIMAL)), 2) AS avg_amount,
    SUM(TRY_CAST(amount AS DECIMAL)) AS total_amount
FROM studies101.default.bank_transactions
WHERE amount IS NOT NULL
  AND TRIM(amount) != '';

----transaction volume by month 
SELECT
    DATE_FORMAT(transaction_date, 'yyyy-MM') AS transaction_month,
    COUNT(*) AS total_transactions,
    ROUND(SUM(TRY_CAST(amount AS DECIMAL)), 2) AS total_amount
FROM studies101.default.bank_transactions
WHERE amount IS NOT NULL
AND TRIM(amount) != ''
GROUP BY DATE_FORMAT(transaction_date, 'yyyy-MM')
ORDER BY transaction_month ASC;

---Checking for duplicates
---- See how many duplicate transactions exist --==ASK
WITH duplicates AS (
        SELECT account_id,
            transaction_type,
            amount,
            transaction_date,
        COUNT(*) AS occurrences
    FROM studies101.default.bank_transactions
    GROUP BY account_id,
             transaction_type,
             amount,
             transaction_date
    HAVING COUNT(*) > 1
)
SELECT
    COUNT(*) AS duplicate_groups,
    SUM(occurrences - 1) AS rows_to_remove
FROM duplicates;

-- Volume and value per transaction type
SELECT
    CASE
        WHEN UPPER(TRIM(transaction_type)) = 'DEPOSIT'    THEN 'Deposit'
        WHEN UPPER(TRIM(transaction_type)) = 'WITHDRAWAL' THEN 'Withdrawal'
        WHEN UPPER(TRIM(transaction_type)) = 'TRANSFER'   THEN 'Transfer'
        WHEN UPPER(TRIM(transaction_type)) = 'PAYMENT'    THEN 'Payment'
        WHEN UPPER(TRIM(transaction_type)) = 'REFUND'     THEN 'Refund'
        ELSE 'Unknown'
    END AS transaction_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(TRY_CAST(amount AS DECIMAL)), 2) AS total_amount,
    ROUND(AVG(TRY_CAST(amount AS DECIMAL)), 2) AS avg_amount
FROM studies101.default.bank_transactions
WHERE amount IS NOT NULL
  AND TRIM(amount) != ''
GROUP BY CASE
    WHEN UPPER(TRIM(transaction_type)) = 'DEPOSIT'    THEN 'Deposit'
    WHEN UPPER(TRIM(transaction_type)) = 'WITHDRAWAL' THEN 'Withdrawal'
    WHEN UPPER(TRIM(transaction_type)) = 'TRANSFER'   THEN 'Transfer'
    WHEN UPPER(TRIM(transaction_type)) = 'PAYMENT'    THEN 'Payment'
    WHEN UPPER(TRIM(transaction_type)) = 'REFUND'     THEN 'Refund'
    ELSE 'Unknown'
END
ORDER BY total_amount DESC;

-- ============================================================
-- Phase 2: Data Cleaning & Transformation

-- CTE 1: CLEAN CUSTOMERS
-- ============================================================
WITH clean_customers AS (
    SELECT
        customer_id,
         -- Name
        COALESCE(NULLIF(TRIM(INITCAP(customer_name)), ''),'Unknown')AS customer_name,
        -- Email
        COALESCE(NULLIF(LOWER(TRIM(customer_email)), ''),'No Email') AS customer_email,
        -- Phone
        COALESCE(NULLIF(TRIM(phone_number), ''),'No Phone')AS phone_number,
        -- Date of birth
        date_of_birth,
        -- Gender
        CASE
            WHEN UPPER(TRIM(gender)) = 'MALE'   THEN 'Male'
            WHEN UPPER(TRIM(gender)) = 'FEMALE' THEN 'Female'
            ELSE 'Unknown'
        END  AS gender,
        -- City and State
        TRIM(INITCAP(city)) AS city,
        UPPER(TRIM(state))AS state,
        -- Employment type
        CASE
            WHEN UPPER(TRIM(employment_type)) LIKE '%FULL%'     THEN 'Full-Time'
            WHEN UPPER(TRIM(employment_type)) LIKE '%PART%'     THEN 'Part-Time'
            WHEN UPPER(TRIM(employment_type)) LIKE '%SELF%'     THEN 'Self-Employed'
            WHEN UPPER(TRIM(employment_type)) LIKE '%UNEMPLOY%' THEN 'Unemployed'
            WHEN UPPER(TRIM(employment_type)) LIKE '%RETIRE%'   THEN 'Retired'
            ELSE 'Unknown'
        END AS employment_type,
        -- Annual income
        COALESCE(TRY_CAST(annual_income AS DECIMAL), 0) AS annual_income,
        -- Membership tier
        CASE
            WHEN UPPER(TRIM(membership_tier)) LIKE '%PLATINUM%' THEN 'Platinum'
            WHEN UPPER(TRIM(membership_tier)) LIKE '%GOLD%'     THEN 'Gold'
            WHEN UPPER(TRIM(membership_tier)) LIKE '%SILVER%'   THEN 'Silver'
            WHEN UPPER(TRIM(membership_tier)) LIKE '%STANDARD%' THEN 'Standard'
            ELSE 'Unknown'
        END AS membership_tier,
        -- Customer since
        customer_since,
        -- Credit score
        COALESCE(TRY_CAST(credit_score AS INT), 0) AS credit_score,
        -- Branch
        TRIM(INITCAP(branch)) AS branch,
        -- Status
        CASE
            WHEN UPPER(TRIM(status)) = 'ACTIVE'   THEN 'Active'
            WHEN UPPER(TRIM(status)) = 'INACTIVE' THEN 'Inactive'
            ELSE 'Unknown'
        END AS status
    FROM studies101.default.bank_customers
),
-- ============================================================
-- CTE 2: CLEAN ACCOUNTS
-- ============================================================
clean_accounts AS (
    SELECT
        account_id,
        customer_id,
        -- Account type
        CASE
            WHEN UPPER(TRIM(account_type)) LIKE '%SAVING%'    THEN 'Savings'
            WHEN UPPER(TRIM(account_type)) LIKE '%CHECK%'
              OR UPPER(TRIM(account_type)) LIKE '%CHEQ%'      THEN 'Checking'
            WHEN UPPER(TRIM(account_type)) LIKE '%BUSINESS%'  THEN 'Business'
            WHEN UPPER(TRIM(account_type)) LIKE '%INVEST%'    THEN 'Investment'
            WHEN UPPER(TRIM(account_type)) LIKE '%FIXED%'     THEN 'Fixed Deposit'
            ELSE 'Unknown'
        END AS account_type,
        -- Account status
        CASE
            WHEN UPPER(TRIM(account_status)) = 'ACTIVE' THEN 'Active'
            WHEN UPPER(TRIM(account_status)) = 'CLOSED' THEN 'Closed'
            ELSE 'Unknown'
        END AS account_status,
        -- Open date
        open_date,
        -- Balance
        COALESCE(TRY_CAST(balance AS DECIMAL), 0)  AS balance,
        -- Interest rate
        COALESCE(TRY_CAST(interest_rate AS DECIMAL), 0) AS interest_rate,
        -- Branch
        TRIM(INITCAP(branch)) AS branch,
        -- Currency
        UPPER(TRIM(currency)) AS currency
    FROM studies101.default.bank_accounts
),
-- ============================================================
-- CTE 3: CLEAN + DEDUPLICATE TRANSACTIONS
-- ============================================================
clean_transactions AS (
    SELECT
        transaction_id,
        account_id,
        -- Transaction type (catches "Withdrawl" typo)
        CASE
            WHEN UPPER(TRIM(transaction_type)) LIKE '%DEPOSIT%'   THEN 'Deposit'
            WHEN UPPER(TRIM(transaction_type)) LIKE '%WITHDRAW%'  THEN 'Withdrawal'
            WHEN UPPER(TRIM(transaction_type)) LIKE '%TRANSFER%'  THEN 'Transfer'
            WHEN UPPER(TRIM(transaction_type)) LIKE '%PAYMENT%'   THEN 'Payment'
            WHEN UPPER(TRIM(transaction_type)) LIKE '%REFUND%'    THEN 'Refund'
            ELSE 'Unknown'
        END AS transaction_type,
        -- Amount
        COALESCE(TRY_CAST(amount AS DECIMAL), 0) AS amount,
        -- Transaction date
        transaction_date,
        -- Channel
        CASE
            WHEN UPPER(TRIM(channel)) LIKE '%ONLINE%'  THEN 'Online'
            WHEN UPPER(TRIM(channel)) LIKE '%ATM%'     THEN 'ATM'
            WHEN UPPER(TRIM(channel)) LIKE '%BRANCH%'  THEN 'Branch'
            WHEN UPPER(TRIM(channel)) LIKE '%MOBILE%'  THEN 'Mobile'
            ELSE 'Unknown'
        END AS channel,
        -- Description (TRIM before NULLIF to catch whitespace)
        COALESCE(NULLIF(TRIM(description), ''),'No Description') AS description,
        -- Status
        CASE
            WHEN UPPER(TRIM(status)) LIKE '%COMPLET%'  THEN 'Completed'
            WHEN UPPER(TRIM(status)) LIKE '%PENDING%'  THEN 'Pending'
            WHEN UPPER(TRIM(status)) LIKE '%FAIL%'     THEN 'Failed'
            ELSE 'Unknown'
        END  AS status,
        reference_number,
        -- Deduplication
        ROW_NUMBER() OVER (
            PARTITION BY
                account_id,
                UPPER(TRIM(transaction_type)),
                TRIM(amount),
                transaction_date
            ORDER BY transaction_id ASC
        ) AS row_num
    FROM studies101.default.bank_transactions
)
-- ============================================================
-- FINAL SELECT — JOIN all three + calculated columns
-- ============================================================
SELECT
    -- Customer columns
    c.customer_id,
    c.customer_name,
    c.customer_email,
    c.phone_number,
    c.date_of_birth,
    c.gender,
    c.city,
    c.state,
    c.employment_type,
    c.annual_income,
    c.membership_tier,
    c.customer_since,
    c.credit_score,
    c.branch AS customer_branch,
    c.status AS customer_status,

    -- Account columns
    a.account_id,
    a.account_type,
    a.account_status,
    a.open_date,
    a.balance,
    a.interest_rate,
    a.branch AS account_branch,
    a.currency,

    -- Transaction columns
    t.transaction_id,
    t.transaction_type,
    t.amount,
    t.transaction_date,
    t.channel,
    t.description,
    t.status AS transaction_status,
    t.reference_number,

    -- ── Calculated columns ────────────────────────────────────

    -- Customer age
    DATEDIFF(YEAR, c.date_of_birth, CURRENT_DATE()) AS customer_age,

    -- Account age in years
    DATEDIFF(YEAR, a.open_date, CURRENT_DATE()) AS account_age_years,

    -- Net amount (positive for inflows, negative for outflows)
    CASE
        WHEN t.transaction_type IN ('Deposit', 'Refund')
            THEN t.amount
        ELSE -t.amount
    END AS net_amount,

    -- Balance band
    CASE
        WHEN a.balance < 10000                  THEN 'Under $10k'
        WHEN a.balance BETWEEN 10000 AND 100000 THEN '$10K - $100K'
        WHEN a.balance > 100000                 THEN 'Above $100K'
        ELSE 'Unknown'
    END AS balance_band,

    -- Credit tier
    CASE
        WHEN c.credit_score = 0                 THEN 'Unknown'
        WHEN c.credit_score < 580               THEN 'Poor'
        WHEN c.credit_score BETWEEN 580 AND 669 THEN 'Fair'
        WHEN c.credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN c.credit_score >= 740              THEN 'Excellent'
    END AS credit_tier,

    -- Income band
    CASE
        WHEN c.annual_income = 0                    THEN 'Unknown'
        WHEN c.annual_income < 50000                THEN 'Under $50K'
        WHEN c.annual_income BETWEEN 50000 AND 100000 THEN '$50K - $100K'
        WHEN c.annual_income > 100000               THEN 'Above $100K'
    END AS income_band,

    -- Transaction value band
    CASE
        WHEN t.amount < 1000                    THEN 'Small (Under $1K)'
        WHEN t.amount BETWEEN 1000 AND 10000    THEN 'Medium ($1K-$10K)'
        WHEN t.amount > 10000                   THEN 'Large (Above $10K)'
    END AS transaction_band

FROM clean_customers AS c
INNER JOIN clean_accounts AS a ON c.customer_id = a.customer_id
INNER JOIN clean_transactions AS t ON a.account_id = t.account_id
WHERE t.row_num = 1
ORDER BY t.transaction_date DESC;
