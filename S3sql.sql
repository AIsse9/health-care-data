SELECT
    CASE 
        WHEN excess_readmission_ratio < 1.0 THEN 'Better Than National Average'
        WHEN excess_readmission_ratio = 1.0 THEN 'Same As National Average'
        WHEN excess_readmission_ratio > 1.0 THEN 'Worse Than National Average'
    END AS performance_category,
    COUNT(*) AS hospital_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM readmissions
WHERE excess_readmission_ratio IS NOT NULL
GROUP BY performance_category
ORDER BY hospital_count DESC;