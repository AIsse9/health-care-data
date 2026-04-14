# Healthcare Quality & Readmissions Analytics

**Author:** Ahmed Isse  
**Stack:** Python · MySQL · Power BI  
**Data Source:** CMS Hospital Readmissions Reduction Program (HRRP) — FY 2026  

---

## Dashboard Preview

![Healthcare Quality & Readmissions Report](dashboard_preview.png)

---

## Project Overview

End-to-end healthcare analytics pipeline built on real CMS data. A Python ETL script ingests and normalizes 18,330 hospital readmission records into a MySQL database across 3 relational tables. Five analytical SQL queries surface key insights, which are then visualized in a Power BI dashboard designed for healthcare strategy stakeholders.

**Business Question:** Which hospitals, states, and conditions have the worst 30-day readmission rates — and what patterns exist across the national dataset?

---

## Repository Structure

```
healthcare-readmissions-analytics/
├── load_data.py                  # Python ETL — loads CMS data into MySQL
├── schema.sql                    # Database schema and table definitions
├── Q1.sql                        # Top 10 states by avg excess readmission ratio
├── Q2.sql                        # Readmissions by condition nationally
├── Q3.sql                        # Hospital performance vs. national average
├── Q4.sql                        # Top 10 worst performing hospitals
├── Q5.sql                        # State + condition predicted vs. expected rate gap
├── dashboard_preview.png         # Power BI dashboard screenshot
└── README.md
```
---

## Database Schema

Three normalized tables with foreign key constraints:

```sql
hospitals (
    facility_id     VARCHAR(10)   PRIMARY KEY,
    facility_name   VARCHAR(255),
    state           VARCHAR(5)
)

conditions (
    condition_id    INT           PRIMARY KEY AUTO_INCREMENT,
    measure_name    VARCHAR(255)
)

readmissions (
    id                          INT           PRIMARY KEY AUTO_INCREMENT,
    facility_id                 VARCHAR(10)   FK → hospitals,
    condition_id                INT           FK → conditions,
    excess_readmission_ratio    DECIMAL(6,4),
    predicted_rate              DECIMAL(5,2),
    expected_rate               DECIMAL(5,2),
    number_of_readmissions      INT,
    number_of_discharges        INT
)
```

**Data volume:** 3,055 hospitals · 6 conditions · 18,330 readmission records

---

## ETL Pipeline

`load_data.py` handles the full ingestion workflow:

1. Parses the raw CMS `.numbers` file using `numbers-parser`
2. Cleans and coerces numeric fields — handles `N/A`, `Too Few to Report`, and `NaN` values
3. Splits the flat file into 3 normalized tables
4. Loads into MySQL via `mysql-connector-python` with foreign key integrity

```bash
pip install numbers-parser mysql-connector-python pandas
python load_data.py
```

---

## SQL Analysis

### Q1 — Top 10 States by Excess Readmission Ratio
Identifies which states have the highest average readmission burden across all facilities.  
**Finding:** Massachusetts, New Jersey, and Florida rank highest nationally.

### Q2 — Readmissions by Condition
Aggregates total readmissions and average excess ratio by clinical condition.  
**Finding:** Heart Failure drives the most readmissions at 392K+, followed by Pneumonia at 131K.

### Q3 — Hospital Performance vs. National Average
Uses CASE WHEN logic to categorize each hospital as better, worse, or same as national benchmark.  
**Finding:** 69% of hospitals perform better than the national average.

### Q4 — Highest Risk Hospitals
Ranks hospitals by average excess readmission ratio across all tracked conditions.  
**Finding:** Surgical specialty hospitals dominate the top 10 highest-risk list.

### Q5 — Predicted vs. Expected Rate Gap by State & Condition
Surfaces where actual performance diverges most from model expectations.  
**Finding:** Wyoming CABG and Massachusetts AMI show the largest rate gaps.

---

## Power BI Dashboard

Connected directly to MySQL via MySQL Connector/NET.

| Visual | Description |
|---|---|
| KPI Cards | Total hospitals, total readmissions, avg excess ratio, conditions tracked |
| Bar Chart | Top 10 states by average excess readmission ratio |
| Bar Chart | Total discharges by clinical condition |
| Donut Chart | Hospital performance vs. national average |
| Table | Top 10 highest risk hospitals |

**DAX Calculated Column:**
