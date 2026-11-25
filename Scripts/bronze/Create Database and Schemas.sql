/*
=========================================================
Create Database and Schemas
=========================================================
Script Purpose:
          This Script create a new database named 'DataWarehouse' after checking if already exists
          If the database exists it is dropped and recreated. Additionally, the script sets up three schemas
          within the database: 'bronze', 'silver' and 'gold'.

WARNING:
       Running this Script will drop the entire 'DataWarehouse' Database if it exits.
       All data in the database will be permannently deleted. Proceed with caution and ensure you have proper 
       backups before running this script.
*/

USE master;
Go

---Drop and recreate the 'DataWarehouse' database
IF EXISTS (select 1 from sys.databases where name = 'DataWarehouse')
BEGIN
     ALTER DATABASE DataWarehouse Set SINGLE_USER with ROLLBACK IMMEDIATE;
     DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
Create database DataWarehouse;
go

use DataWarehouse;
go

create schema bronze;
go

create schema silver;
go

create schema gold;
go

