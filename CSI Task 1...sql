use AdventureWorks2022
go
 --List of all customers
Select * from Sales.Customer

--List of all customers where company name ending in N

SELECT c.CustomerID, c.PersonID, c.StoreID, c.TerritoryID, c.AccountNumber, s.Name AS CompanyName
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';

--List of all customers who live in Berlin  and London

SELECT p.FirstName, p.LastName, a.City
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress ba ON p.BusinessEntityID = ba.BusinessEntityID
JOIN Person.Address a ON ba.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');

--List of all customers who live in UK and USA
SELECT p.FirstName, p.LastName, a.City, sp.Name AS StateProvince, cr.Name AS CountryRegion
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress ba ON p.BusinessEntityID = ba.BusinessEntityID
JOIN Person.Address a ON ba.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');

--List of all products sorted by products name

SELECT ProductID, Name
FROM Production.Product
ORDER BY Name;

--List of all products where products name starts with an A

SELECT * FROM Production.Product
ORDER BY Name;
SELECT * FROM Production.Product
WHERE Name LIKE 'A%';

--List of customer who ever ever placed an order

SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;

--List of customers who lived in london and have bought chai

SELECT DISTINCT p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress ba ON p.BusinessEntityID = ba.BusinessEntityID
JOIN Person.Address a ON ba.AddressID = a.AddressID
WHERE a.City = 'London' AND pr.Name = 'Chai';

--List of customers who never place an order

SELECT p.FirstName, p.LastName
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE soh.CustomerID IS NULL;

--List of customers who never placed an order

SELECT DISTINCT p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE pr.Name = 'Tofu';

--Details of first order of the system

SELECT TOP 1 *
FROM Sales.SalesOrderHeader
ORDER BY OrderDate ASC;
SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

--Find the details of the most expensive order date

SELECT TOP 1 SalesOrderID, OrderDate, TotalDue, CustomerID, ShipToAddressID, BillToAddressID
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

--For each order get the OrderID and Average quantity of iteams in the order

SELECT soh.SalesOrderID, AVG(sod.OrderQty) AS AvgQuantity
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID;
WITH EmployeeHierarchy AS (
    SELECT
        e.BusinessEntityID,
        e.JobTitle,
        e.OrganizationNode,
        p.FirstName,
        p.LastName,
        e.OrganizationLevel
    FROM HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
)
--Get a list of all managers and total numbers of employee who report to them

SELECT
    Manager.FirstName + ' ' + Manager.LastName AS ManagerName,
    COUNT(Employee.BusinessEntityID) AS TotalEmployees
FROM
    EmployeeHierarchy AS Employee
JOIN
    EmployeeHierarchy AS Manager ON Manager.OrganizationNode.GetAncestor(1) = Employee.OrganizationNode
GROUP BY
    Manager.FirstName, Manager.LastName
ORDER BY
    ManagerName;

--Get the OrderID and the total quatity for each that has a total quantity of greater than 300

SELECT soh.SalesOrderID, SUM(sod.OrderQty) AS TotalQuantity
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID
HAVING SUM(sod.OrderQty) > 300;

--List of all orders placed on or after 1996/12/31

SELECT *
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';

--List of all orders shipped to Canada

SELECT soh.SalesOrderID, soh.OrderDate, soh.TotalDue, a.AddressLine1, a.AddressLine2, a.City, sp.Name AS StateProvince, cr.Name AS Country
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';

--List of all orders with order total>200

SELECT SalesOrderID, OrderDate, TotalDue, CustomerID, ShipToAddressID, BillToAddressID
FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;



--List of countries and sales made in each country
SELECT 
    cr.Name AS Country,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Person.BusinessEntityAddress bea ON soh.ShipToAddressID = bea.AddressID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN 
    Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY 
    cr.Name
ORDER BY 
    TotalSales DESC;

--List of Customer contact name and numbers of orders they placed

	SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName;

--List of Customers contactname who have placed more than 3 orders

SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 3;

--List of discontinued products which were ordered between 1/1/1997 and 1/1/1998
SELECT DISTINCT p.*
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.DiscontinuedDate IS NOT NULL
  AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

--List of employee firstname, lastname, supervisor firstname, lastname

 SELECT e.FirstName AS EmployeeFirstName, e.LastName AS EmployeeLastName,
       s.FirstName AS SupervisorFirstName, s.LastName AS SupervisorLastName
FROM HumanResources.Employee emp
LEFT JOIN HumanResources.Employee sup ON emp.OrganizationNode.GetAncestor(1) = sup.OrganizationNode
JOIN Person.Person e ON emp.BusinessEntityID = e.BusinessEntityID
LEFT JOIN Person.Person s ON sup.BusinessEntityID = s.BusinessEntityID;

--List of Employees ID and total sales conducted by employee sql

SELECT e.BusinessEntityID AS EmployeeID, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
GROUP BY e.BusinessEntityID;

--List of employees whose FirstName contains character 'a' sql

SELECT p.FirstName, p.LastName
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE '%a%';

--List of managers who have more than four people reporting to them

SELECT p.FirstName, p.LastName, COUNT(e.BusinessEntityID) AS ReportCount
FROM HumanResources.Employee e
JOIN HumanResources.Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
JOIN Person.Person p ON m.BusinessEntityID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(e.BusinessEntityID) > 4;

--List of Orders and Product Names sql

SELECT soh.SalesOrderID, p.Name AS ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID;

--List of orders placed by the best customer sql

SELECT soh.SalesOrderID, soh.OrderDate, soh.TotalDue
FROM Sales.SalesOrderHeader soh
WHERE soh.CustomerID = (
    SELECT TOP 1 soh.CustomerID
    FROM Sales.SalesOrderHeader soh
    GROUP BY soh.CustomerID
    ORDER BY SUM(soh.TotalDue) DESC
);

--List of orders placed by customers who do not have a Fax number

SELECT soh.SalesOrderID, soh.OrderDate, soh.TotalDue
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
LEFT JOIN Person.PhoneNumberType pnt ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID
WHERE pp.PhoneNumber IS NULL
  AND pnt.Name = 'Fax';

--List of Postal codes where the product Tofu was shipped sql

SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Tofu';

--List of product Names that were shipped to France sql

SELECT DISTINCT p.Name
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';

--List of Product Names and Categories for the supplier 'Specialty Biscuits, Ltd.'

SELECT p.Name AS ProductName, pc.Name AS CategoryName
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.';

--List of products that were never ordered sql

SELECT p.Name
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

--List of products where units in stock is less than 10 and units on order are 0

SELECT p.Name, p.ProductID, ps.Quantity AS QuantityInStock, ps.Quantity AS QuantityOnOrder
FROM Production.Product p
JOIN Production.ProductInventory ps ON p.ProductID = ps.ProductID
WHERE ps.Quantity < 10 AND ps.Quantity = 0;

--List of top 10 countries by sales sql

SELECT TOP 10 cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;

--Number of orders each employee has taken for customers with CustomerIDs between 'A' and 'AO'

SELECT e.BusinessEntityID AS EmployeeID, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE c.AccountNumber BETWEEN 'A' AND 'AO'
GROUP BY e.BusinessEntityID;

--Orderdate of the most expensive order sql

SELECT TOP 1 OrderDate
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

--Product name and total revenue from that product sql

SELECT p.Name AS ProductName, SUM(sod.LineTotal) AS TotalRevenue
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC;

--Supplier ID and number of products offered sql

SELECT pv.BusinessEntityID AS SupplierID, COUNT(pv.ProductID) AS NumberOfProducts
FROM Purchasing.ProductVendor pv
GROUP BY pv.BusinessEntityID;

--Top ten customers based on their business sql

SELECT TOP 10 c.CustomerID, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
GROUP BY c.CustomerID
ORDER BY TotalSales DESC;

--What is the total revenue of the company sql

SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;
