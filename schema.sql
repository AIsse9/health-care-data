-- Table 1: Hospitals
CREATE TABLE hospitals (
    facility_id VARCHAR(10) PRIMARY KEY,
    facility_name VARCHAR(255),
    state VARCHAR(5),
    city VARCHAR(100)
);

-- Table 2: Conditions
CREATE TABLE conditions (
    condition_id INT AUTO_INCREMENT PRIMARY KEY,
    measure_name VARCHAR(255),
    measure_id VARCHAR(50)
);

-- Table 3: Readmissions (fact table)
CREATE TABLE readmissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    facility_id VARCHAR(10),
    condition_id INT,
    compared_to_national VARCHAR(100),
    predicted_rate DECIMAL(5,2),
    expected_rate DECIMAL(5,2),
    excess_readmission_ratio DECIMAL(6,4),
    number_of_readmissions INT,
    FOREIGN KEY (facility_id) REFERENCES hospitals(facility_id),
    FOREIGN KEY (condition_id) REFERENCES conditions(condition_id)
);