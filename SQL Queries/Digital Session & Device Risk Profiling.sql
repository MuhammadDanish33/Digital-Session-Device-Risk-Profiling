Use NovaGroup
--QUERY 1:Session Risk Distribution
SELECT
    CASE
        WHEN SessionRiskScore >= 7 THEN 'High Risk'
        WHEN SessionRiskScore >= 4 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskBand,
    COUNT(SessionID) AS SessionCount,
    ROUND(100.0 * COUNT(SessionID) / SUM(COUNT(SessionID)) OVER(),2) AS PctOfTotal,
    AVG(SessionRiskScore) AS AvgRiskScore
FROM Banking.FactDigitalSession
GROUP BY
    CASE
        WHEN SessionRiskScore >= 7 THEN 'High Risk'
        WHEN SessionRiskScore >= 4 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END
ORDER BY AVG(SessionRiskScore) DESC;
--QUERY 2:Failed Login Pattern Analysis
-- Shows how failed attempts relate to session risk and login success
SELECT
    FailedAttemptsCount,
    COUNT(Banking.FactDigitalsession.SessionID)  AS TotalSessions,
    SUM(CASE WHEN IsSuccessfulLogin = 1
             THEN 1 ELSE 0 END)           AS SuccessfulLogins,
    SUM(CASE WHEN IsSuccessfulLogin = 0
             THEN 1 ELSE 0 END)           AS FailedLogins,
    ROUND(AVG(SessionRiskScore), 2)       AS AvgRiskScore
FROM Banking.FactDigitalSession
GROUP BY FailedAttemptsCount
ORDER BY FailedAttemptsCount DESC;
-- QUERY 3: Failed Login Rate (KPI 2)
SELECT
    ROUND(100.0 * SUM(
    CASE WHEN FailedAttemptsCount > 0 THEN 1 ELSE 0 
    END) / COUNT(*), 2) AS FailedLoginRate_Pct
FROM Banking.FactDigitalSession;
--QUERY 4: High-Risk Country Session Analysis
--Groups sessions by country risk flag and compares risk scores
SELECT
    l.Country,
    l.City,
    l.IsHighRiskCountry,
    COUNT(s.SessionID)                   AS TotalSessions,
    ROUND(AVG(s.SessionRiskScore), 2)    AS AvgSessionRiskScore,
    SUM(CASE WHEN s.IsSuccessfulLogin = 0
             THEN 1 ELSE 0 END)          AS FailedLoginCount
FROM Banking.FactDigitalSession  s
JOIN Banking.DimLocation AS  l
ON s.LocationID = l.LocationID
GROUP BY l.Country, l.City, l.IsHighRiskCountry
ORDER BY l.IsHighRiskCountry DESC,
         TotalSessions         DESC;
-- QUERY 5: High-Risk Country Session Share
SELECT
    ROUND(100.0 * SUM(
    CASE WHEN l.IsHighRiskCountry = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS HighRiskCountrySessionShare_Pct,
    ROUND(AVG(
    CASE WHEN l.IsHighRiskCountry = 1 THEN s.SessionRiskScore END), 2) AS AvgRisk_HighRiskCountry,
    ROUND(AVG(
    CASE WHEN l.IsHighRiskCountry = 0 THEN s.SessionRiskScore END), 2) AS AvgRisk_LowRiskCountry
FROM Banking.FactDigitalSession s
JOIN Banking.DimLocation l ON s.LocationID = l.LocationID;
--QUERY 6: Device Trust vs Session Risk
-- Compares session risk and failed logins between trusted and untrusted devices
SELECT
    d.IsTrustedDevice,
    d.DeviceType,
    COUNT(s.SessionID)                   AS TotalSessions,
    ROUND(AVG(s.SessionRiskScore), 2)    AS AvgSessionRiskScore,
    SUM(s.FailedAttemptsCount)           AS TotalFailedAttempts,
    SUM(CASE WHEN s.SessionRiskScore >= 7
             THEN 1 ELSE 0 END)          AS HighRiskSessions
FROM Banking.FactDigitalSession  s
JOIN Banking.DimDevice           d 
ON s.DeviceID = d.DeviceID
GROUP BY d.IsTrustedDevice, d.DeviceType
ORDER BY d.IsTrustedDevice ASC,
         AvgSessionRiskScore DESC;
-- QUERY 7:% High-Risk Sessions by Device Type (Business Question 1 – device variation)
SELECT
    d.DeviceType,
    COUNT(s.SessionID) AS TotalSessions,
    SUM(CASE WHEN s.SessionRiskScore >= 7 THEN 1 ELSE 0 END) AS HighRiskSessions,
    ROUND(100.0 * SUM(CASE WHEN s.SessionRiskScore >= 7 THEN 1 ELSE 0 END) / COUNT(s.SessionID), 2) AS PctHighRisk
FROM Banking.FactDigitalSession s
JOIN Banking.DimDevice d ON s.DeviceID = d.DeviceID
GROUP BY d.DeviceType
ORDER BY PctHighRisk DESC;
--QUERY 8:    Untrusted Device Confirmed Fraud Rate
-- Joins sessions → customer → account → transaction → alert → case
-- to measure confirmed fraud rate by device trust status
-- Untrusted Device Confirmed Fraud Rate (safer version)
WITH CustomerDeviceFraud AS (
    SELECT
        s.CustomerID,
        d.IsTrustedDevice,
        MAX(CASE WHEN fc.FraudConfirmedFlag = 1 THEN 1 ELSE 0 END) AS HasConfirmedFraud,
        SUM(CASE WHEN fc.FraudConfirmedFlag = 1 THEN fc.LossAmount ELSE 0 END) AS TotalFraudLoss
    FROM Banking.FactDigitalSession s
    JOIN Banking.DimDevice d ON s.DeviceID = d.DeviceID
    LEFT JOIN Banking.DimAccount a ON s.CustomerID = a.CustomerID
    LEFT JOIN Banking.FactTransaction t ON a.AccountID = t.SenderAccountID
    LEFT JOIN Banking.FactFraudAlert fa ON t.TransactionID = fa.TransactionID
    LEFT JOIN Banking.FactCase fc ON fa.AlertID = fc.AlertID
    GROUP BY s.CustomerID, d.IsTrustedDevice
)
SELECT
    IsTrustedDevice,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers,
    SUM(HasConfirmedFraud) AS CustomersWithFraud,
    ROUND(100.0 * SUM(HasConfirmedFraud) / NULLIF(COUNT(DISTINCT CustomerID), 0), 2) AS FraudRate_Pct,
    COALESCE(SUM(TotalFraudLoss), 0) AS TotalLoss
FROM CustomerDeviceFraud
GROUP BY IsTrustedDevice
ORDER BY IsTrustedDevice ASC; 
-- QUERY 9: High-Risk Sessions by Customer Risk Rating Segment
SELECT
    c.RiskRating,          -- change to the real column name
    COUNT(s.SessionID) AS TotalSessions,
    SUM(CASE WHEN s.SessionRiskScore >= 7 THEN 1 ELSE 0 END) AS HighRiskSessions,
    ROUND(100.0 * SUM(CASE WHEN s.SessionRiskScore >= 7 THEN 1 ELSE 0 END) / COUNT(s.SessionID), 2) AS PctHighRisk
FROM Banking.FactDigitalSession s
JOIN Common.Customer  c 
ON s.CustomerID = c.CustomerID
GROUP BY c.RiskRating
ORDER BY HighRiskSessions DESC;