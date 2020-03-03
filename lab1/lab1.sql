if not exists(select * from sys.databases where name = 'Flights')
    create database Flights;
go


if not exists (select * from sysobjects where name='Passengers' and xtype='U')
	create table  Passengers(
		PassID int not null primary key,
		FirstName varchar(100) not null,
		SecondName varchar(100) not null,
		PassportNumber int check (PassportNumber >=100000000 and PassportNumber <= 999999999)); 
go

bulk insert Passengers
from 'C:\msys64\home\student\DB\lab1\passengers.csv'
with(datafiletype = 'char', firstrow = 0, fieldterminator = ',', rowterminator = '\n');
go

if not exists (select * from sysobjects where name='Airports' and xtype='U')
	create table  Airports(
		AirportID int not null primary key,
		Name varchar(100) not null,
		City varchar(100) not null);
go

bulk insert Airports
from 'C:\msys64\home\student\DB\lab1\airports.csv'
with(datafiletype = 'char', firstrow = 0, fieldterminator = ',', rowterminator = '\n');
go


if not exists (select * from sysobjects where name='Flights' and xtype='U')
	create table  Flights(
		FlightNumber int check (FlightNumber >=10000 and FlightNumber <= 99999) primary key,
		AirportDepartID int not null foreign key references Airports(AirportID),
		AirportArriveID int not null foreign key references Airports(AirportID),
		DepartingTime time,
		ArrivalTime time,
		Company varchar(100) not null); 
go

bulk insert Flights
from 'C:\msys64\home\student\DB\lab1\flights.csv'
with(datafiletype = 'char', firstrow = 0, fieldterminator = ',', rowterminator = '\n');
go

if not exists (select * from sysobjects where name='PF' and xtype='U')
	create table  PF(
		PassID int not null foreign key references Passengers(PassID),
		FlightNumber int not null foreign key references Flights(FlightNumber),
		FlightDate date); 
go

bulk insert PF
from 'C:\msys64\home\student\DB\lab1\pf.csv'
with(datafiletype = 'char', firstrow = 0, fieldterminator = ',', rowterminator = '\n');
go




if not exists(select * from sys.databases where name = 'StudTeach')
    create database StudTeach;
go