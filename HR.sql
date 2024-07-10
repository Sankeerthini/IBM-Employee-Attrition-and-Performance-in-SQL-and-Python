USE HR;
GO
CREATE TABLE Employees (
    Age INT,
    Attrition NVARCHAR(50),
    BusinessTravel NVARCHAR(50),
    DailyRate INT,
    Department NVARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField NVARCHAR(50),
    EmployeeCount INT,
    EmployeeNumber INT PRIMARY KEY,
    EnvironmentSatisfaction INT,
    Gender NVARCHAR(50),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole NVARCHAR(50),
    JobSatisfaction INT,
    MaritalStatus NVARCHAR(50),
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 NVARCHAR(50),
    OverTime NVARCHAR(50),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);
GO

-- Create Departments Table
CREATE TABLE Departments(
    DepartmentID INT PRIMARY KEY,
    DepartmentName NVARCHAR(50)
);
GO

-- Insert Data into Departments Table
INSERT INTO Departments (DepartmentID, DepartmentName)
VALUES 
(1, 'Sales'), 
(2, 'Research & Development'), 
(3, 'Human Resources');
GO

-- Attrition Rate by Department
SELECT 
    Department, 
    COUNT(*) AS TotalEmployees, 
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount, 
    (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS AttritionRate 
FROM 
    Employees 
GROUP BY 
    Department;

-- Attrition Rate by OverTime
SELECT 
    OverTime, 
    COUNT(*) AS TotalEmployees, 
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount, 
    (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS AttritionRate 
FROM 
    Employees 
GROUP BY 
    OverTime;

-- Count of Employees by Job Role
SELECT JobRole, COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY JobRole;
GO

-- Average Monthly Income by Department
SELECT Department, AVG(MonthlyIncome) AS AverageMonthlyIncome
FROM Employees
GROUP BY Department
HAVING AVG(MonthlyIncome) > 5000;
GO

-- Average Monthly Income by Job Role
SELECT 
    JobRole, 
    AVG(MonthlyIncome) AS AverageMonthlyIncome 
FROM 
    Employees 
GROUP BY 
    JobRole;

-- Rank Employees by Monthly Income
SELECT EmployeeNumber, Age, MonthlyIncome,
       RANK() OVER (ORDER BY MonthlyIncome DESC) AS IncomeRank
FROM Employees;
GO

-- Top 5 Employees with Highest Monthly Income
SELECT EmployeeNumber, Age, MonthlyIncome
FROM Employees
WHERE MonthlyIncome IN (SELECT TOP 5 MonthlyIncome FROM Employees ORDER BY MonthlyIncome DESC);
GO

-- Average Monthly Income by Department with Window Function for Ranking
WITH DepartmentAvgIncome AS (
    SELECT Department, AVG(MonthlyIncome) AS AverageMonthlyIncome
    FROM Employees
    GROUP BY Department
)
SELECT Department, AverageMonthlyIncome,
       RANK() OVER (ORDER BY AverageMonthlyIncome DESC) AS DepartmentIncomeRank
FROM DepartmentAvgIncome;
GO

-- CTE for Employees with High Job Satisfaction
WITH HighSatisfaction AS (
    SELECT EmployeeNumber, JobSatisfaction, MonthlyIncome
    FROM Employees
    WHERE JobSatisfaction > 3
)
SELECT * FROM HighSatisfaction;
GO

-- Stored Procedure to Get Employees with High Income
CREATE PROCEDURE GetHighIncomeEmployees
AS
BEGIN
    SELECT EmployeeNumber, Age, MonthlyIncome
    FROM Employees
    WHERE MonthlyIncome > 7000;
END;
GO
EXEC GetHighIncomeEmployees;
GO

-- Function to Calculate Annual Income
CREATE FUNCTION CalculateAnnualIncome(@MonthlyIncome INT)
RETURNS INT
AS
BEGIN
    RETURN @MonthlyIncome * 12;
END;
GO
SELECT EmployeeNumber, MonthlyIncome, 
       dbo.CalculateAnnualIncome(MonthlyIncome) AS AnnualIncome
FROM Employees;
GO

-- Trigger to Log Salary Changes
CREATE TRIGGER trg_SalaryChange
ON Employees
AFTER UPDATE
AS
BEGIN
    IF UPDATE(MonthlyIncome)
    BEGIN
        INSERT INTO SalaryChangeLog (EmployeeNumber, OldSalary, NewSalary, ChangeDate)
        SELECT 
            i.EmployeeNumber, 
            d.MonthlyIncome AS OldSalary, 
            i.MonthlyIncome AS NewSalary, 
            GETDATE() AS ChangeDate
        FROM inserted i
        JOIN deleted d ON i.EmployeeNumber = d.EmployeeNumber;
    END
END;
GO

-- Joining Employees with Departments and Calculating Annual Income
WITH EmployeeAnnualIncome AS (
    SELECT e.EmployeeNumber, e.Age, e.Attrition, e.BusinessTravel, e.DailyRate, d.DepartmentName, e.JobRole, e.MonthlyIncome,
           dbo.CalculateAnnualIncome(e.MonthlyIncome) AS AnnualIncome
    FROM Employees e
    JOIN Departments d ON e.Department = d.DepartmentName
)
SELECT * FROM EmployeeAnnualIncome;
GO
