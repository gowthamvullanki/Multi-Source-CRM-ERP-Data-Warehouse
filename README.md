# Multi-Source-CRM-ERP-Data-Warehouse
Built a SQL Server data warehouse integrating CRM and ERP data into a single source of truth using Medallion Architecture (Bronze, Silver, Gold). Automated batch ETL with T-SQL stored procedures, cleansed and standardized Silver data, and modeled a Gold Star Schema with surrogate keys and quality checks.

<img width="1050" height="528" alt="image" src="https://github.com/user-attachments/assets/dd400f99-1080-4219-a9e6-946555891aaa" />

# SQL Server Data Warehouse & Analytics Project

## 📌 Project Overview
This project implements a modern end-to-end **Data Warehouse** in **Microsoft SQL Server** using the **Medallion Architecture (Bronze, Silver, Gold)**. It consolidates raw sales, customer, and product data from two disparate enterprise source systems—**CRM** and **ERP**—into a clean, standardized, analytics-ready **Star Schema** serving as a single source of truth for business intelligence and reporting.

---

## 🏗️ Data Architecture
The data pipeline follows a three-layer Medallion Architecture:

1. **Bronze Layer (Raw Ingestion):**
   * Stores raw, untransformed data ingested directly from source CSV files (`CRM` and `ERP`).
   * Uses high-performance `BULK INSERT` operations wrapped in a stored procedure (`bronze.load_bronze`) with execution timing and `TRY...CATCH` error logging.
2. **Silver Layer (Cleansed & Standardized):**
   * Cleanses, deduplicates, and standardizes data from the Bronze layer via `silver.load_silver`.
   * Applies business rules, data type casting, null handling, whitespace trimming, and historical record tracking (`dwh_create_date`).
3. **Gold Layer (Business-Ready Star Schema):**
   * Exposes analytical views modeled into a **Star Schema** (`gold.dim_customers`, `gold.dim_products`, and `gold.fact_sales`).
   * Generates surrogate keys (`ROW_NUMBER()`), resolves cross-source attributes between CRM and ERP, and filters out historical product versions.

---

## 📂 Repository Structure

```text
sql-data-warehouse-project/
├── datasets/
│   ├── source_crm/                  # Raw CRM CSV files (cust_info, prd_info, sales_details)
│   └── source_erp/                  # Raw ERP CSV files (CUST_AZ12, LOC_A101, PX_CAT_G1V2)
├── scripts/
│   ├── bronze/
│   │   ├── ddl_bronze.sql           # DDL scripts to create Bronze tables
│   │   └── proc_load_bronze.sql     # Stored procedure for BULK INSERT ingestion
│   ├── silver/
│   │   ├── ddl_silver.sql           # DDL scripts to create Silver tables
│   │   └── proc_load_silver.sql     # Stored procedure for ETL data cleansing & transformation
│   └── gold/
│       └── ddl_gold.sql             # DDL scripts to create Star Schema views
├── tests/
│   ├── quality_checks_silver.sql    # Data validation & standardization checks for Silver
│   └── quality_checks_gold.sql      # Referential integrity & surrogate key checks for Gold
└── README.md
```

---

## 🔄 Key ETL Transformations (Silver Layer)
* **Deduplication:** Retained only the latest customer record per `cst_id` using `ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC)`.
* **Data Standardization:** Mapped cryptic source codes into business-friendly values (e.g., `M`/`F` → `Male`/`Female`, `S`/`M` → `Single`/`Married`, product line codes `M`/`R`/`S`/`T` → `Mountain`/`Road`/`Other Sales`/`Touring`, country codes `DE`/`US`/`USA` → `Germany`/`United States`).
* **Data Enrichment & Key Parsing:** Split composite product keys (`prd_key`) into category IDs (`cat_id`) and clean product keys, and stripped `NAS` prefixes and hyphens (`-`) from ERP customer IDs to enable cross-system joins.
* **Date & Metric Repair:** Converted integer `YYYYMMDD` dates into valid `DATE` types, derived product end dates (`prd_end_dt`) using `LEAD()`, nullified invalid/future birthdates, and recalculated inconsistent `sls_sales` and `sls_price` values.

---

## ⭐ Gold Layer Data Model (Star Schema)

| Object Name | Type | Description |
| :--- | :--- | :--- |
| **`gold.fact_sales`** | Fact View | Transactional sales metrics (`sales_amount`, `quantity`, `price`) linked to customer and product surrogate keys. |
| **`gold.dim_customers`** | Dimension View | Unified customer profile merging CRM customer details with ERP birthdates and country data. |
| **`gold.dim_products`** | Dimension View | Active product catalog enriched with ERP category, subcategory, and maintenance metadata. |

---

## ✅ Data Quality & Testing
Automated SQL validation scripts in `tests/` verify:
* **Primary & Surrogate Key Integrity:** Ensures zero `NULL` or duplicate keys across Silver tables and Gold dimensions.
* **String Hygiene:** Confirms zero leading/trailing whitespace in text columns.
* **Date & Math Consistency:** Validates chronological date order (`order_date <= ship_date <= due_date`) and enforces `sales = quantity * price`.
* **Star Schema Connectivity:** Verifies zero orphaned foreign keys when joining `gold.fact_sales` to `gold.dim_customers` and `gold.dim_products`.

---

## 🚀 How to Run
1. **Create Database & Schemas:** Create the `DataWarehouse` database along with the `bronze`, `silver`, and `gold` schemas.
2. **Initialize & Load Bronze:** Execute `ddl_bronze.sql`, update the CSV file paths in `proc_load_bronze.sql`, and run `EXEC bronze.load_bronze;`.
3. **Initialize & Load Silver:** Execute `ddl_silver.sql`, compile `proc_load_silver.sql`, and run `EXEC silver.load_silver;`.
4. **Create Gold Views:** Execute `ddl_gold.sql` to build the analytical Star Schema views.
5. **Run Quality Checks:** Execute `quality_checks_silver.sql` and `quality_checks_gold.sql` to confirm all checks return zero anomalies.

---

## 🛠️ Tech Stack
* **Database:** Microsoft SQL Server (T-SQL)
* **Tools:** SQL Server Management Studio (SSMS)
* **Concepts:** Medallion Architecture, Star Schema Dimensional Modeling, Batch ETL, Data Cleansing & Quality Assurance
