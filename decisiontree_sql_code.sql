/* Overview of the dataset*/
SELECT * FROM Golf

/* ID3 Algorithm Implementation:
Step 1: Find the Root Node by calculating entropy and information gain of each attribute and choose the one with the most gain
Step 2: Given the Root Node, continue finding the Decision Nodes by repeating the same mechanism */
GO
CREATE PROCEDURE ID3Algo
AS
BEGIN
/** STEP 1: FIND THE ATTRIBUTE FOR ROOT NODE **/
/* Calculate Average Entropy of each attribute */
-- Calculate the frequency of each value
SELECT 'Outlook' Col, * INTO OtherAttribute FROM (SELECT DISTINCT Outlook Val, Golf, COUNT(*) Frequency FROM Golf GROUP BY Outlook, Golf) A
UNION SELECT 'Temperature', * FROM (SELECT DISTINCT Temperature, Golf , COUNT(*) Frequency FROM Golf GROUP BY Temperature, Golf) A
UNION SELECT 'Humidity', * FROM (SELECT DISTINCT Humidity, Golf , COUNT(*) Frequency FROM Golf GROUP BY Humidity, Golf) A
UNION SELECT 'Wind', * FROM (SELECT DISTINCT Wind, Golf , COUNT(*) Frequency FROM Golf GROUP BY Wind, Golf) A

SELECT * FROM OtherAttribute

-- Calculate the total frequency of each value
SELECT DISTINCT Col, Val, SUM(Frequency) AS TotalFreq
INTO #TotalFrequency
FROM OtherAttribute GROUP BY Col, Val

SELECT OtherAttribute.*, #TotalFrequency.TotalFreq INTO AverageEntropy
FROM OtherAttribute
LEFT JOIN #TotalFrequency ON OtherAttribute.Col = #TotalFrequency.Col AND OtherAttribute.Val = #TotalFrequency.Val

SELECT * FROM AverageEntropy

-- Caculate entropy for each values of each attribute
SELECT Col, Val, TotalFreq, -SUM(CAST(Frequency AS FLOAT)/ TotalFreq * LOG(CAST(Frequency AS FLOAT)/ TotalFreq )/LOG(2)) AS AttributeEntropy
INTO #AttributeEntropy
FROM AverageEntropy
GROUP BY Col, Val, TotalFreq

SELECT * FROM #AttributeEntropy

/* Calculate the average information entropy */  
SELECT Col, SUM((CAST(TotalFreq AS FLOAT)/15) * AttributeEntropy) AS AverageInformationEntropy into #AverageInformationEntropy
FROM #AttributeEntropy
GROUP BY Col

SELECT * FROM #AverageInformationEntropy

/* Calculate the gain for each attribute */ 
-- Calculate the Dataset Entropy
SELECT 'Outlook' Col, * INTO Probability FROM (SELECT DISTINCT Outlook Val, COUNT(*) Frequency, 15 Sum FROM Golf GROUP BY Outlook) A
UNION SELECT 'Temperature', * FROM (SELECT DISTINCT Temperature , COUNT(*) Frequency, 15 Sum FROM Golf GROUP BY Temperature) A
UNION SELECT 'Humidity', * FROM (SELECT DISTINCT Humidity , COUNT(*) Frequency, 15 Sum FROM Golf GROUP BY Humidity) A
UNION SELECT 'Wind', * FROM (SELECT DISTINCT Wind , COUNT(*) Frequency, 15 Sum FROM Golf GROUP BY Wind) A
UNION SELECT 'Golf', * FROM (SELECT DISTINCT Golf , COUNT(*) Frequency, 15 Sum FROM Golf GROUP BY Golf) A

SELECT 'Golf' Col, * INTO TargetAttribute FROM (SELECT DISTINCT Golf , COUNT(*) Frequency, 15 Sum FROM Golf GROUP BY Golf) A

--- Calculate the gain
DECLARE @DatasetEntropy VARCHAR(20)
SELECT @DatasetEntropy = -SUM(CAST(Frequency AS FLOAT)/ 15 * LOG(CAST(Frequency AS FLOAT)/ 15)/LOG(2)) FROM TargetAttribute
SELECT Col, @DatasetEntropy - CAST(AverageInformationEntropy AS FLOAT) AS Gain
FROM #AverageInformationEntropy

/* The information gain of attributes are: Humidity - 0.19; Outlook - 0.28; Temperature - 0.06; Wind = 0.02.
Thus, we choose Outlook - the highest-gain attribute as our Decision Tree Root Node */

/** STEP 2: FIND THE ATTRIBUTE FOR DECISION NODE **/
/* Calculate Average Entropy of each attribute */

SELECT * FROM OtherAttribute WHERE Col = 'Outlook'
/* Scenario 1: Outlook = Overcast: When the outlook is Overcast, the Golf value is always Yes. Thus, there is no need to go further. */

/* Scenario 2: Outlook = Sunny*/
-- Filter and save a dataset where Outlook = Sunny
SELECT * INTO OutlookS2
FROM Golf WHERE Outlook = 'Sunny'
SELECT * FROM OutlookS2

-- Calculate Average Entropy of each attribute
SELECT 'Temperature' Col, * INTO OutlookS2Attributes FROM (SELECT DISTINCT Temperature Val, Golf, COUNT(*) Frequency FROM OutlookS2 GROUP BY Temperature, Golf) A
UNION SELECT 'Humidity', * FROM (SELECT DISTINCT Humidity, Golf , COUNT(*) Frequency FROM OutlookS2 GROUP BY Humidity, Golf) A
UNION SELECT 'Wind', * FROM (SELECT DISTINCT Wind, Golf , COUNT(*) Frequency FROM OutlookS2 GROUP BY Wind, Golf) A
SELECT * FROM OutlookS2Attributes

-- Calculate the total frequency of each value
SELECT DISTINCT Col, Val, SUM(Frequency) AS TotalFreq
INTO #OutlookS2Total
FROM OutlookS2Attributes GROUP BY Col, Val
SELECT * FROM #OutlookS2Total

SELECT OutlookS2Attributes.*, #OutlookS2Total.TotalFreq INTO OutlookS2AverageEntropy
FROM OutlookS2Attributes
LEFT JOIN #OutlookS2Total ON OutlookS2Attributes.Col = #OutlookS2Total.Col AND OutlookS2Attributes.Val = #OutlookS2Total.Val

SELECT * FROM OutlookS2AverageEntropy

-- Caculate entropy for each values of each attribute
SELECT Col, Val, TotalFreq, -SUM(CAST(Frequency AS FLOAT)/ TotalFreq * LOG(CAST(Frequency AS FLOAT)/ TotalFreq )/LOG(2)) AS AttributeEntropy
INTO #OutlookS2AttributeEntropy
FROM OutlookS2AverageEntropy
GROUP BY Col, Val, TotalFreq
SELECT * FROM #OutlookS2AttributeEntropy

-- Calculate the average information entropy
SELECT Col, SUM((CAST(TotalFreq AS FLOAT)/15) * AttributeEntropy) AS AverageInformationEntropy into #OutlookS2AverageInformationEntropy
FROM #OutlookS2AttributeEntropy
GROUP BY Col
SELECT * FROM #OutlookS2AverageInformationEntropy

-- Calculate the Dataset Entropy in Scenario 2
SELECT 'Temperature' Col, * INTO OutlookS2Prob FROM (SELECT DISTINCT Temperature Val, COUNT(*) Frequency, 6 Sum FROM OutlookS2 GROUP BY Temperature) A
UNION SELECT 'Humidity', * FROM (SELECT DISTINCT Humidity , COUNT(*) Frequency, 6 Sum FROM OutlookS2 GROUP BY Humidity) A
UNION SELECT 'Wind', * FROM (SELECT DISTINCT Wind , COUNT(*) Frequency, 6 Sum FROM OutlookS2 GROUP BY Wind) A
UNION SELECT 'Golf', * FROM (SELECT DISTINCT Golf , COUNT(*) Frequency, 6 Sum FROM OutlookS2 GROUP BY Golf) A

SELECT 'Golf' Col, * INTO OutlookS2TargetAttribute FROM (SELECT DISTINCT Golf , COUNT(*) Frequency, 6 Sum FROM OutlookS2 GROUP BY Golf) A

SELECT * FROM OutlookS2TargetAttribute

--- Calculate the gain
DECLARE @OutlookS2DatasetEntropy VARCHAR(20)
SELECT @OutlookS2DatasetEntropy = -SUM(CAST(Frequency AS FLOAT)/ 6 * LOG(CAST(Frequency AS FLOAT)/ 6)/LOG(2)) FROM OutlookS2TargetAttribute
SELECT Col, @OutlookS2DatasetEntropy - CAST(AverageInformationEntropy AS FLOAT) AS Gain
FROM #OutlookS2AverageInformationEntropy

/* The information gain of attributes are: Humidity - 0.92; Temperature - 0.78; Wind = 0.57.
Thus, we choose Humidity - the highest-gain attribute as our Decision Node in Scenario 2: Outlook = Sunny */

/* Scenario 3: Outlook = Rainy*/
-- Filter and save a dataset where Outlook = Rainy
SELECT * INTO OutlookS3
FROM Golf WHERE Outlook = 'Rainy'
SELECT * FROM OutlookS3

-- Calculate Average Entropy of each attribute
SELECT 'Temperature' Col, * INTO OutlookS3Attributes FROM (SELECT DISTINCT Temperature Val, Golf, COUNT(*) Frequency FROM OutlookS3 GROUP BY Temperature, Golf) A
UNION SELECT 'Humidity', * FROM (SELECT DISTINCT Humidity, Golf , COUNT(*) Frequency FROM OutlookS3 GROUP BY Humidity, Golf) A
UNION SELECT 'Wind', * FROM (SELECT DISTINCT Wind, Golf , COUNT(*) Frequency FROM OutlookS3 GROUP BY Wind, Golf) A
SELECT * FROM OutlookS3Attributes

-- Calculate the total frequency of each value
SELECT DISTINCT Col, Val, SUM(Frequency) AS TotalFreq
INTO #OutlookS3Total
FROM OutlookS3Attributes GROUP BY Col, Val
SELECT * FROM #OutlookS3Total

SELECT OutlookS3Attributes.*, #OutlookS3Total.TotalFreq INTO OutlookS3AverageEntropy
FROM OutlookS3Attributes
LEFT JOIN #OutlookS3Total ON OutlookS3Attributes.Col = #OutlookS3Total.Col AND OutlookS3Attributes.Val = #OutlookS3Total.Val

SELECT * FROM OutlookS3AverageEntropy

-- Caculate entropy for each values of each attribute
SELECT Col, Val, TotalFreq, -SUM(CAST(Frequency AS FLOAT)/ TotalFreq * LOG(CAST(Frequency AS FLOAT)/ TotalFreq )/LOG(2)) AS AttributeEntropy
INTO #OutlookS3AttributeEntropy
FROM OutlookS3AverageEntropy
GROUP BY Col, Val, TotalFreq
SELECT * FROM #OutlookS3AttributeEntropy

-- Calculate the average information entropy
SELECT Col, SUM((CAST(TotalFreq AS FLOAT)/15) * AttributeEntropy) AS AverageInformationEntropy into #OutlookS3AverageInformationEntropy
FROM #OutlookS3AttributeEntropy
GROUP BY Col

SELECT * FROM #OutlookS3AverageInformationEntropy

-- Calculate the Dataset Entropy in Scenario 3
SELECT 'Temperature' Col, * INTO OutlookS3Prob FROM (SELECT DISTINCT Temperature Val, COUNT(*) Frequency, 5 Sum FROM OutlookS3 GROUP BY Temperature) A
UNION SELECT 'Humidity', * FROM (SELECT DISTINCT Humidity , COUNT(*) Frequency, 5 Sum FROM OutlookS3 GROUP BY Humidity) A
UNION SELECT 'Wind', * FROM (SELECT DISTINCT Wind , COUNT(*) Frequency, 5 Sum FROM OutlookS3 GROUP BY Wind) A
UNION SELECT 'Golf', * FROM (SELECT DISTINCT Golf , COUNT(*) Frequency, 5 Sum FROM OutlookS3 GROUP BY Golf) A

SELECT 'Golf' Col, * INTO OutlookS3TargetAttribute FROM (SELECT DISTINCT Golf , COUNT(*) Frequency, 5 Sum FROM OutlookS3 GROUP BY Golf) A

SELECT * FROM OutlookS3TargetAttribute

--- Calculate the gain
DECLARE @OutlookS3DatasetEntropy VARCHAR(20)
SELECT @OutlookS3DatasetEntropy = -SUM(CAST(Frequency AS FLOAT)/ 5 * LOG(CAST(Frequency AS FLOAT)/ 5)/LOG(2)) FROM OutlookS3TargetAttribute
SELECT Col, @OutlookS3DatasetEntropy - CAST(AverageInformationEntropy AS FLOAT) AS Gain
FROM #OutlookS3AverageInformationEntropy

/* The information gain of attributes are: Humidity - 0.65; Temperature - 0.365 Wind = 097.
Thus, we choose Wind - the highest-gain attribute as our Decision Node in Scenario 3: Outlook = Rainy */

END;

/* EXECUTE PROCEDURE */
EXEC ID3Algo
