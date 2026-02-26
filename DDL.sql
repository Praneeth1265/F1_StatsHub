-- Circuits
CREATE DATABASE F1;
USE F1;

CREATE TABLE Circuits (
    Circuit_ID INT PRIMARY KEY,
    C_Name VARCHAR(100),
    Country VARCHAR(50),
    Location VARCHAR(100)
);

-- GPs (Grand Prix)
CREATE TABLE GPs (
    GP_ID INT PRIMARY KEY,
    GP_Name VARCHAR(100)
);

-- Seasons
CREATE TABLE Seasons (
    Year INT PRIMARY KEY
);

-- Races
CREATE TABLE Races (
    Race_ID INT PRIMARY KEY,
    Year INT,
    GP_ID INT,
    Circuit_ID INT,
    Laps INT,
    FOREIGN KEY (Year) REFERENCES Seasons(Year),
    FOREIGN KEY (GP_ID) REFERENCES GPs(GP_ID),
    FOREIGN KEY (Circuit_ID) REFERENCES Circuits(Circuit_ID)
);

-- Drivers
CREATE TABLE Drivers (
    Driver_ID INT PRIMARY KEY,
    Forename VARCHAR(50),
    Surname VARCHAR(50),
    DOB DATE,
    Nationality VARCHAR(50)
);

-- Constructors
CREATE TABLE Constructors (
    Constructor_ID INT PRIMARY KEY,
    Con_Name VARCHAR(100),
    Nationality VARCHAR(50)
);

-- Cars
CREATE TABLE Cars (
    Car_ID INT PRIMARY KEY,
    Constructor_ID INT,
    Engine VARCHAR(50),
    Tyres VARCHAR(50),
    FOREIGN KEY (Constructor_ID) REFERENCES Constructors(Constructor_ID)
);

-- Status
CREATE TABLE Status (
    Status_ID INT PRIMARY KEY,
    Status VARCHAR(50)
);

-- Results
CREATE TABLE Results (
    Result_ID INT PRIMARY KEY,
    Race_ID INT,
    Driver_ID INT,
    Constructor_ID INT,
    Car_ID INT,
    Position_Order INT,
    Grid INT,
    Points INT,
    Status_ID INT,
    FOREIGN KEY (Race_ID) REFERENCES Races(Race_ID),
    FOREIGN KEY (Driver_ID) REFERENCES Drivers(Driver_ID),
    FOREIGN KEY (Constructor_ID) REFERENCES Constructors(Constructor_ID),
    FOREIGN KEY (Car_ID) REFERENCES Cars(Car_ID),
    FOREIGN KEY (Status_ID) REFERENCES Status(Status_ID)
);

-- Seasons (10 rows: 2016..2025)
INSERT INTO Seasons (Year) VALUES (2016);
INSERT INTO Seasons (Year) VALUES (2017);
INSERT INTO Seasons (Year) VALUES (2018);
INSERT INTO Seasons (Year) VALUES (2019);
INSERT INTO Seasons (Year) VALUES (2020);
INSERT INTO Seasons (Year) VALUES (2021);
INSERT INTO Seasons (Year) VALUES (2022);
INSERT INTO Seasons (Year) VALUES (2023);
INSERT INTO Seasons (Year) VALUES (2024);
INSERT INTO Seasons (Year) VALUES (2025);

-- Circuits (10)
INSERT INTO Circuits (Circuit_ID, C_Name, Country, Location) VALUES (1, 'Albert Park Circuit', 'Australia', 'Melbourne');
INSERT INTO Circuits (Circuit_ID, C_Name, Country, Location) VALUES (2, 'Shanghai International Circuit', 'China', 'Shanghai');
INSERT INTO Circuits (Circuit_ID, C_Name, Country, Location) VALUES (3, 'Suzuka Circuit', 'Japan', 'Suzuka');
INSERT INTO Circuits (Circuit_ID, C_Name, Country, Location) VALUES (4, 'Bahrain International Circuit', 'Bahrain', 'Sakhir');
INSERT INTO Circuits (Circuit_ID, C_Name, Country, Location) VALUES (5, 'Jeddah Corniche Circuit', 'Saudi Arabia', 'Jeddah');
INSERT INTO Circuits (Circuit_ID, C_Name, Country, Location) VALUES (6, 'Circuit de Monaco', 'Monaco', 'Monte Carlo');
INSERT INTO Circuits (Circuit_ID, C_Name, Country, Location) VALUES (7, 'Silverstone Circuit', 'United Kingdom', 'Silverstone');
INSERT INTO Circuits (Circuit_ID, C_Name, Country, Location) VALUES (8, 'Circuit de Spa-Francorchamps', 'Belgium', 'Stavelot');
INSERT INTO Circuits (Circuit_ID, C_Name, Country, Location) VALUES (9, 'Autodromo Nazionale Monza', 'Italy', 'Monza');
INSERT INTO Circuits (Circuit_ID, C_Name, Country, Location) VALUES (10, 'Yas Marina Circuit', 'United Arab Emirates', 'Abu Dhabi');

-- GPs (10)
INSERT INTO GPs (GP_ID, GP_Name) VALUES (1, 'Australian Grand Prix');
INSERT INTO GPs (GP_ID, GP_Name) VALUES (2, 'Chinese Grand Prix');
INSERT INTO GPs (GP_ID, GP_Name) VALUES (3, 'Japanese Grand Prix');
INSERT INTO GPs (GP_ID, GP_Name) VALUES (4, 'Bahrain Grand Prix');
INSERT INTO GPs (GP_ID, GP_Name) VALUES (5, 'Saudi Arabian Grand Prix');
INSERT INTO GPs (GP_ID, GP_Name) VALUES (6, 'Monaco Grand Prix');
INSERT INTO GPs (GP_ID, GP_Name) VALUES (7, 'British Grand Prix');
INSERT INTO GPs (GP_ID, GP_Name) VALUES (8, 'Belgian Grand Prix');
INSERT INTO GPs (GP_ID, GP_Name) VALUES (9, 'Italian Grand Prix');
INSERT INTO GPs (GP_ID, GP_Name) VALUES (10, 'Abu Dhabi Grand Prix');

-- Races (10)
INSERT INTO Races (Race_ID, Year, GP_ID, Circuit_ID, Laps) VALUES (1, 2025, 1, 1, 58);
INSERT INTO Races (Race_ID, Year, GP_ID, Circuit_ID, Laps) VALUES (2, 2025, 2, 2, 56);
INSERT INTO Races (Race_ID, Year, GP_ID, Circuit_ID, Laps) VALUES (3, 2025, 3, 3, 53);
INSERT INTO Races (Race_ID, Year, GP_ID, Circuit_ID, Laps) VALUES (4, 2025, 4, 4, 57);
INSERT INTO Races (Race_ID, Year, GP_ID, Circuit_ID, Laps) VALUES (5, 2025, 5, 5, 50);
INSERT INTO Races (Race_ID, Year, GP_ID, Circuit_ID, Laps) VALUES (6, 2025, 6, 6, 78);
INSERT INTO Races (Race_ID, Year, GP_ID, Circuit_ID, Laps) VALUES (7, 2025, 7, 7, 52);
INSERT INTO Races (Race_ID, Year, GP_ID, Circuit_ID, Laps) VALUES (8, 2025, 8, 8, 44);
INSERT INTO Races (Race_ID, Year, GP_ID, Circuit_ID, Laps) VALUES (9, 2025, 9, 9, 53);
INSERT INTO Races (Race_ID, Year, GP_ID, Circuit_ID, Laps) VALUES (10, 2025, 10, 10, 58);

-- Drivers (10)
INSERT INTO Drivers (Driver_ID, Forename, Surname, DOB, Nationality) VALUES (1, 'Max', 'Verstappen', '1997-09-30', 'Dutch');
INSERT INTO Drivers (Driver_ID, Forename, Surname, DOB, Nationality) VALUES (2, 'Lando', 'Norris', '1999-11-13', 'British');
INSERT INTO Drivers (Driver_ID, Forename, Surname, DOB, Nationality) VALUES (3, 'Oscar', 'Piastri', '2001-04-06', 'Australian');
INSERT INTO Drivers (Driver_ID, Forename, Surname, DOB, Nationality) VALUES (4, 'Charles', 'Leclerc', '1997-10-16', 'Monegasque');
INSERT INTO Drivers (Driver_ID, Forename, Surname, DOB, Nationality) VALUES (5, 'Lewis', 'Hamilton', '1985-01-07', 'British');
INSERT INTO Drivers (Driver_ID, Forename, Surname, DOB, Nationality) VALUES (6, 'George', 'Russell', '1998-02-15', 'British');
INSERT INTO Drivers (Driver_ID, Forename, Surname, DOB, Nationality) VALUES (7, 'Andrea Kimi', 'Antonelli', '2006-08-25', 'Italian');
INSERT INTO Drivers (Driver_ID, Forename, Surname, DOB, Nationality) VALUES (8, 'Yuki', 'Tsunoda', '2000-05-11', 'Japanese');
INSERT INTO Drivers (Driver_ID, Forename, Surname, DOB, Nationality) VALUES (9, 'Fernando', 'Alonso', '1981-07-29', 'Spanish');
INSERT INTO Drivers (Driver_ID, Forename, Surname, DOB, Nationality) VALUES (10, 'Lance', 'Stroll', '1998-10-29', 'Canadian');

-- Constructors (10)
INSERT INTO Constructors (Constructor_ID, Con_Name, Nationality) VALUES (1, 'McLaren', 'British');
INSERT INTO Constructors (Constructor_ID, Con_Name, Nationality) VALUES (2, 'Ferrari', 'Italian');
INSERT INTO Constructors (Constructor_ID, Con_Name, Nationality) VALUES (3, 'Mercedes', 'German');
INSERT INTO Constructors (Constructor_ID, Con_Name, Nationality) VALUES (4, 'Red Bull Racing', 'Austrian');
INSERT INTO Constructors (Constructor_ID, Con_Name, Nationality) VALUES (5, 'Williams', 'British');
INSERT INTO Constructors (Constructor_ID, Con_Name, Nationality) VALUES (6, 'Aston Martin', 'British');
INSERT INTO Constructors (Constructor_ID, Con_Name, Nationality) VALUES (7, 'Racing Bulls', 'New Zealand');
INSERT INTO Constructors (Constructor_ID, Con_Name, Nationality) VALUES (8, 'Kick Sauber', 'Swiss');
INSERT INTO Constructors (Constructor_ID, Con_Name, Nationality) VALUES (9, 'Haas', 'American');
INSERT INTO Constructors (Constructor_ID, Con_Name, Nationality) VALUES (10, 'Alpine', 'French');

-- Cars (10)
INSERT INTO Cars (Car_ID, Constructor_ID, Engine, Tyres) VALUES (1, 1, 'Mercedes-AMG PU', 'Pirelli');
INSERT INTO Cars (Car_ID, Constructor_ID, Engine, Tyres) VALUES (2, 2, 'Ferrari PU', 'Pirelli');
INSERT INTO Cars (Car_ID, Constructor_ID, Engine, Tyres) VALUES (3, 3, 'Mercedes-AMG PU', 'Pirelli');
INSERT INTO Cars (Car_ID, Constructor_ID, Engine, Tyres) VALUES (4, 4, 'Honda RBPT', 'Pirelli');
INSERT INTO Cars (Car_ID, Constructor_ID, Engine, Tyres) VALUES (5, 5, 'Mercedes-AMG PU', 'Pirelli');
INSERT INTO Cars (Car_ID, Constructor_ID, Engine, Tyres) VALUES (6, 6, 'Mercedes-AMG PU', 'Pirelli');
INSERT INTO Cars (Car_ID, Constructor_ID, Engine, Tyres) VALUES (7, 7, 'Red Bull Powertrains', 'Pirelli');
INSERT INTO Cars (Car_ID, Constructor_ID, Engine, Tyres) VALUES (8, 8, 'Ferrari PU', 'Pirelli');
INSERT INTO Cars (Car_ID, Constructor_ID, Engine, Tyres) VALUES (9, 9, 'Ferrari PU', 'Pirelli');
INSERT INTO Cars (Car_ID, Constructor_ID, Engine, Tyres) VALUES (10, 10, 'Renault/Alpine PU', 'Pirelli');

-- Status (10)
INSERT INTO Status (Status_ID, Status) VALUES (1, 'Finished');
INSERT INTO Status (Status_ID, Status) VALUES (2, '+1 Lap');
INSERT INTO Status (Status_ID, Status) VALUES (3, '+2 Laps');
INSERT INTO Status (Status_ID, Status) VALUES (4, 'Disqualified');
INSERT INTO Status (Status_ID, Status) VALUES (5, 'Retired');
INSERT INTO Status (Status_ID, Status) VALUES (6, 'Accident');
INSERT INTO Status (Status_ID, Status) VALUES (7, 'Engine Failure');
INSERT INTO Status (Status_ID, Status) VALUES (8, 'DNS');
INSERT INTO Status (Status_ID, Status) VALUES (9, 'DNF');
INSERT INTO Status (Status_ID, Status) VALUES (10, 'Lap Down');

-- Results (10)
INSERT INTO Results (Result_ID, Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Points, Status_ID) VALUES (1, 1, 2, 1, 1, 1, 1, 25, 1);
INSERT INTO Results (Result_ID, Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Points, Status_ID) VALUES (2, 2, 1, 4, 4, 1, 2, 25, 1);
INSERT INTO Results (Result_ID, Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Points, Status_ID) VALUES (3, 3, 1, 4, 4, 1, 1, 25, 1);
INSERT INTO Results (Result_ID, Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Points, Status_ID) VALUES (4, 6, 2, 1, 1, 1, 1, 25, 1);
INSERT INTO Results (Result_ID, Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Points, Status_ID) VALUES (5, 7, 2, 1, 1, 1, 3, 25, 1);
INSERT INTO Results (Result_ID, Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Points, Status_ID) VALUES (6, 8, 3, 1, 1, 1, 2, 25, 1);
INSERT INTO Results (Result_ID, Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Points, Status_ID) VALUES (7, 9, 1, 4, 4, 1, 1, 25, 1);
INSERT INTO Results (Result_ID, Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Points, Status_ID) VALUES (8, 4, 4, 2, 2, 2, 4, 18, 1);
INSERT INTO Results (Result_ID, Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Points, Status_ID) VALUES (9, 5, 9, 6, 6, 6, 6, 8, 1);
INSERT INTO Results (Result_ID, Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Points, Status_ID) VALUES (10, 10, 5, 2, 2, 4, 5, 12, 1);