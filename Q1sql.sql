SELECT 
    h.state,
    ROUND(AVG(r.excess_readmission_ratio), 4) AS avg_excess_ratio,
    COUNT(DISTINCT h.facility_id) AS hospital_count
FROM hospitals h
JOIN readmissions r ON h.facility_id = r.facility_id
WHERE r.excess_readmission_ratio IS NOT NULL
GROUP BY h.state
ORDER BY avg_excess_ratio DESC
LIMIT 10;