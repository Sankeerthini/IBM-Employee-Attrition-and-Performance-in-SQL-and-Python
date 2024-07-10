BULK INSERT dbo.Employees
FROM '/HR'
WITH 
(
    FORMAT='CSV',
    FIRSTROW=2
);
GO



