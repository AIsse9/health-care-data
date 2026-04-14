SELECT 
    h.state,
    c.measure_name,
    ROUND(AVG(r.predicted_rate), 4) AS avg_predicted_rate,
    ROUND(AVG(r.expected_rate), 4) AS avg_expected_rate,
    ROUND(AVG(r.predicted_rate) - AVG(r.expected_rate), 4) AS rate_gap
FROM hospitals h
JOIN readmissions r ON h.facility_id = r.facility_id
JOIN conditions c ON r.condition_id = c.condition_id
WHERE r.predicted_rate IS NOT NULL 
AND r.expected_rate IS NOT NULL
GROUP BY h.state, c.measure_name
ORDER BY rate_gap DESC
LIMIT 15;