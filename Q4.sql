SELECT 
    h.facility_name,
    h.state,
    ROUND(AVG(r.excess_readmission_ratio), 4) AS avg_excess_ratio,
    COUNT(c.measure_name) AS conditions_tracked
FROM hospitals h
JOIN readmissions r ON h.facility_id = r.facility_id
JOIN conditions c ON r.condition_id = c.condition_id
WHERE r.excess_readmission_ratio IS NOT NULL
GROUP BY h.facility_id, h.facility_name, h.state
ORDER BY avg_excess_ratio DESC
LIMIT 10;