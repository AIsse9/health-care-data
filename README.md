# Healthcare Quality & Readmissions Analytics

**Author:** Ahmed Isse
**Stack:** Python · MySQL · Power BI
**Data Source:** CMS Hospital Readmissions Reduction Program (HRRP) — FY 2026

---

## Dashboard Preview

![Healthcare Quality & Readmissions Report](dashboard_preview.png)

---

I wanted to answer a question I kept seeing come up in healthcare strategy work: which hospitals and conditions are actually driving poor readmission performance, and where are the biggest gaps between what's expected and what's happening?

The data came from CMS's Hospital Readmissions Reduction Program — 18,330 records across 3,055 facilities. I cleaned it, loaded it into MySQL, wrote the queries, and built the dashboard. Everything is in this repo.

---

## Repository Structure

healthcare-readmissions-analytics/
├── ETL.py                        # Python ETL — loads CMS data into MySQL
├── schema.sql                    # Database schema and table definitions
├── Q1.sql                        # Top 10 states by avg excess readmission ratio
├── Q2.sql                        # Readmissions by condition nationally
├── Q3.sql                        # Hospital performance vs. national average
├── Q4.sql                        # Top 10 worst performing hospitals
├── Q5.sql                        # State + condition predicted vs. expected rate gap
├── Healthcare-readmissions.pbix  # Power BI dashboard file
├── dashboard_preview.png         # Dashboard screenshot
└── README.md
## Database Schema

The CMS file came as one flat structure so I split it into 3 tables. Nothing fancy, just clean normalization so the queries would actually be readable.

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

3,055 hospitals · 6 conditions · 18,330 records

---

## ETL Pipeline

The raw file was a `.numbers` format with `N/A`, `Too Few to Report`, and `NaN` values mixed throughout the numeric columns. Took some work to get it loading cleanly. `ETL.py` handles the parsing, coercion, and insert logic — splits the flat file into the 3 tables and loads with foreign key constraints intact.

```bash
pip install numbers-parser mysql-connector-python pandas
python ETL.py
```

---

## SQL Analysis

**Q1 — Top 10 States by Excess Readmission Ratio**

MA came in noticeably ahead of everyone else. NJ and FL followed. The gap between MA and the rest of the top 10 was wider than I expected going in.

**Q2 — Readmissions by Condition**

Heart Failure at 392K+ — nearly 3x Pneumonia which came in second at 131K. The other four conditions weren't really in the same conversation volume-wise, though Hip/Knee and CABG had higher excess ratios than their volume suggested.

**Q3 — Hospital Performance vs. National Average**

69% of hospitals perform better than the national average which sounds good until you look at where the actual readmission volume is coming from. The headline number is a little misleading.

**Q4 — Highest Risk Hospitals**

Surgical specialty hospitals keep showing up at the top. My read is that narrow condition tracking against a broad national benchmark is probably inflating their ratios — but I didn't dig deep enough into that to say for certain.

**Q5 — Predicted vs. Expected Rate Gap**

Wyoming CABG has the largest gap nationally. I don't have a clean explanation for that one.

---

## Power BI Dashboard

Connects to MySQL directly via MySQL Connector/NET. Four visuals plus KPI cards — built to give a strategy audience the key facts without making them dig for it.

| Visual | Description |
|---|---|
| KPI Cards | Total hospitals, total readmissions, avg excess ratio, conditions tracked |
| Bar Chart | Top 10 states by average excess readmission ratio |
| Bar Chart | Total discharges by clinical condition |
| Donut Chart | Hospital performance vs. national average |
| Table | Top 10 highest risk hospitals |

```dax
Performance Category = 
IF(readmissions[excess_readmission_ratio] < 1, "Better Than National",
IF(readmissions[excess_readmission_ratio] > 1, "Worse Than National",
"Same As National"))
```
