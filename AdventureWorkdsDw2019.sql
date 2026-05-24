------------------------------sales_yearly_trend------------------------------
select Dd.CalendarYear  as [Year] , sum(Fi.SalesAmount) as [Total Sale] from FactInternetSales Fi
join DimDate Dd
on Fi.ShipDateKey = Dd.DateKey
group by Dd.CalendarYear
order by Year
------------------------------top_product_subcategories_sales------------------------------
select top 10 EnglishProductSubcategoryName as [Product name] , 
SUM(Fi.SalesAmount) as [Total Sale]
from DimProductSubcategory Dps
join DimProduct Dp
on Dp.ProductSubcategoryKey = Dps.ProductSubcategoryKey
join FactInternetSales Fi 
on Fi.ProductKey = Dp.ProductKey
group by EnglishProductSubcategoryName
order by [Total Sale] desc
------------------------------sales_category_share_analysis------------------------------
with my_Cte01 as
(
select distinct(Dpc.EnglishProductCategoryName) as [Category] , 
sum(Fi.SalesAmount)  as [Total Sale]
from FactInternetSales Fi
join DimProduct Dp
on Dp.ProductKey = Fi.ProductKey
join DimProductSubcategory Dps
on Dp.ProductSubcategoryKey = Dps.ProductSubcategoryKey
join DimProductCategory Dpc 
on Dps.ProductCategoryKey = Dpc.ProductCategoryKey
group by Dpc.EnglishProductCategoryName
)
select Category , [Total Sale] , [Total Sale]/SUM([Total Sale]) over() as [Share of Total] from my_Cte01 
group by Category , [Total Sale]
order by [Share of Total] desc
------------------------------profit_margin_analysis------------------------------
with my_cte01 as
(
select * ,  (SalesAmount - (TotalProductCost + TaxAmt + Freight) )  as [Profit]
  from FactInternetSales
 )
 select * , Profit / SalesAmount as [Profit Margine] from my_cte01
 order by [Profit Margine] desc
 ------------------------------monthly_sales_trend_2012_2013------------------------------
 select D.CalendarYear as [Year] , D.EnglishMonthName  as [Month] ,
 SUM(Fi.SalesAmount) as [Total Sale] from DimDate D
 join FactInternetSales Fi
 on D.DateKey = Fi.ShipDateKey
 where D.CalendarYear in (2012 , 2013)

 group by D.CalendarYear , D.EnglishMonthName
 order by D.CalendarYear

 select * from DimDate
  ------------------------------employee_sales_performance------------------------------
select  De.EmployeeKey , CONCAT(De.FirstName , ' ', De.LastName) as [Full Name] , 
Dt.SalesTerritoryCountry as [Country] ,  SUM(Fi.SalesAmount)  as [Total Sale]
from FactInternetSales Fi
join DimSalesTerritory Dt
on Fi.SalesTerritoryKey = Dt.SalesTerritoryKey
join DimEmployee De 
on De.SalesTerritoryKey = Dt.SalesTerritoryKey
where De.Status is not Null
group by De.EmployeeKey , Dt.SalesTerritoryCountry , De.FirstName , De.LastName
order by Country , [Total Sale] desc
------------------------------customer_acquisition_trend------------------------------
with my_Cte01 as (
select CustomerKey , CONCAT(FirstName , ' ' , LastName) as [Full Name], 
min(year(DateFirstPurchase)) as [First year Purchase] ,
MIN(MONTH(DateFirstPurchase)) as [First Month Purchase]
from DimCustomer
group by CustomerKey, FirstName , LastName
) 
select [First year Purchase] , [First Month Purchase] , 
SUM(CustomerKey) as [New Customers]
from my_Cte01
group by [First year Purchase] , [First Month Purchase]
order by [First year Purchase] , [First Month Purchase]
------------------------------top_customers_by_region------------------------------
with my_cte01 as
(
select Dc.CustomerKey , CONCAT(Dc.FirstName ,  ' ' ,Dc.LastName ) as [Full Name] , 
Dg.EnglishCountryRegionName as [Country Region] , SUM(Fi.SalesAmount) as [Total Sale]
from DimCustomer Dc
join FactInternetSales Fi
on Dc.CustomerKey = Fi.CustomerKey
join DimGeography Dg
on Dc.GeographyKey = Dg.GeographyKey
group by Dc.CustomerKey , Dc.FirstName , Dc.LastName , Dg.EnglishCountryRegionName
),
my_cte02 as(
select * ,
RANK() over(partition by [Country Region]   order by [Total Sale] desc) as [Rank] from my_cte01 
)
select * from my_cte02
where Rank<=10
------------------------------employee_profit_contribution------------------------------
with my_cte01 as
(
select * ,  (SalesAmount - (TotalProductCost + TaxAmt + Freight) )  as [Profit]
  from FactInternetSales
 ) , 
 my_Cte02 as
 ( 
select * , Profit / SalesAmount as [Profit Margine] from my_cte01
 )
select De.EmployeeKey , CONCAT(De.FirstName , ' ', De.LastName) as [Full Name] , 
Dt.SalesTerritoryCountry as [Country],SUM(mc2.[Profit Margine]) as [Profit Margine] 
from my_cte02 mc2

 join DimSalesTerritory Dt
 on Dt.SalesTerritoryKey = mc2.SalesTerritoryKey
 join DimEmployee De
 on De.SalesTerritoryKey = Dt.SalesTerritoryKey
 group by De.EmployeeKey   ,De.FirstName , De.LastName 
  , Dt.SalesTerritoryCountry 
  order by Country , [Profit Margine] desc
-------------------------  delivery -------------------------
------------------------------average_delivery_time------------------------------
SELECT AVG(DATEDIFF(day, OrderDate, ShipDate)) AS [Delivery Average]
FROM FactInternetSales
------------------------------delayed_shipments_analysis------------------------------
select DATEDIFF(DAY , OrderDate , ShipDate) as [delayed ship] from  FactInternetSales
where ShipDate> DueDate
------------------------------freight_cost_by_region------------------------------
select Dg.EnglishCountryRegionName , AVG(Fi.Freight) as [Freight] from FactInternetSales Fi
join DimCustomer Dc
on Dc.CustomerKey = Fi.CustomerKey
join DimGeography Dg
on Dg.GeographyKey = Dc.GeographyKey
group by Dg.EnglishCountryRegionName 
order by Freight desc
