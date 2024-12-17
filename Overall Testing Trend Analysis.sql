--Overall Testing Trend Analysis:

SELECT 
    testdate,
    totaltests,
    positivetests,
    avgtestcost,
    avgprocessingtime,
    (positivetests::float / totaltests * 100) as positivity_rate
FROM vw_dailytestsummary
ORDER BY testdate;