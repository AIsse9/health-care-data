import os
import pandas as pd
import numpy as np
from numbers_parser import Document
import mysql.connector

# ---- STEP 1: Load the Numbers file ----
doc = Document('FY_2026_Hospital_Readmissions_Reduction_Program_Hospital.numbers')
sheet = doc.sheets[0]
table = sheet.tables[0]

rows = list(table.iter_rows())
headers = [str(cell.value) for cell in rows[0]]
data = [[str(cell.value) for cell in row] for row in rows[1:]]

df = pd.DataFrame(data, columns=headers)

# ---- STEP 2: Clean ----
df.columns = df.columns.str.strip()

# Replace suppressed / missing values with None
df.replace(['N/A', 'None', 'Too Few to Report', 'nan'], None, inplace=True)

# Coerce numeric columns
numeric_cols = [
    'Excess Readmission Ratio',
    'Predicted Readmission Rate',
    'Expected Readmission Rate',
    'Number of Discharges',
    'Number of Readmissions'
]
for col in numeric_cols:
    df[col] = pd.to_numeric(df[col], errors='coerce')

df['Facility ID'] = df['Facility ID'].str.replace('.0', '', regex=False)

# Convert NaN to None for MySQL
df = df.where(pd.notnull(df), None)

# ---- STEP 3: Split into 3 tables ----
hospitals = df[['Facility ID', 'Facility Name', 'State']].drop_duplicates(subset='Facility ID')

conditions = df[['Measure Name']].drop_duplicates().reset_index(drop=True)
conditions.index += 1
conditions_map = {name: idx for idx, name in conditions['Measure Name'].items()}
df['condition_id'] = df['Measure Name'].map(conditions_map)

# ---- STEP 4: Load into MySQL ----
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password=os.environ.get('MYSQL_PW', ''),
    database='healthcare_readmissions'
)
cursor = conn.cursor()

print("Loading hospitals...")
for _, row in hospitals.iterrows():
    cursor.execute("""
        INSERT IGNORE INTO hospitals (facility_id, facility_name, state)
        VALUES (%s, %s, %s)
    """, (row['Facility ID'], row['Facility Name'], row['State']))

print("Loading conditions...")
for name, idx in conditions_map.items():
    cursor.execute("""
        INSERT IGNORE INTO conditions (condition_id, measure_name)
        VALUES (%s, %s)
    """, (idx, name))

def clean_val(v):
    if v is None:
        return None
    try:
        if isinstance(v, float) and np.isnan(v):
            return None
    except (TypeError, ValueError):
        pass
    return v

print("Loading readmissions...")
for _, row in df.iterrows():
    cursor.execute("""
        INSERT INTO readmissions 
        (facility_id, condition_id, excess_readmission_ratio, 
         predicted_rate, expected_rate, number_of_readmissions, number_of_discharges)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (
        clean_val(row['Facility ID']),
        clean_val(row['condition_id']),
        clean_val(row['Excess Readmission Ratio']),
        clean_val(row['Predicted Readmission Rate']),
        clean_val(row['Expected Readmission Rate']),
        clean_val(row['Number of Readmissions']),
        clean_val(row['Number of Discharges'])
    ))

conn.commit()
cursor.close()
conn.close()

print("Done. All data loaded.")
