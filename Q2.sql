SELECT 
    c.measure_name,
    SUM(r.number_of_readmissions) AS total_readmissions,
    ROUND(AVG(r.excess_readmission_ratio), 4) AS avg_excess_ratio
FROM conditions c
JOIN readmissions r ON c.condition_id = r.condition_id
WHERE r.number_of_readmissions IS NOT NULL
GROUP BY c.measure_name
ORDER BY total_readmissions DESC;