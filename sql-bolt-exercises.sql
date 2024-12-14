-- SQL Bolt Exercises

	-- SQL Lesson 1: SELECT queries 101 ------------------------------

-- 1. Find the title of each film 
SELECT Title FROM Movies;


-- 2. Find the director of each film 
SELECT Director FROM Movies;


-- 3. Find the title and director of each film 
SELECT Title, Director FROM Movies;


-- 4. Find the title and year of each film 
SELECT Title, Year FROM Movies;


-- 5. Find all the information about each film 
SELECT * FROM Movies;


	-- SQL Lesson 2: Queries with constraints (Pt. 1) ------------------------------

-- 1. Find the movie with a row id of 6
SELECT Id, Title FROM movies
WHERE Id = 6;


-- 2. Find the movies released in the years between 2000 and 2010 
SELECT Title, Year FROM movies
WHERE Year BETWEEN 2000 AND 2010;


-- 3. Find the movies not released in the years between 2000 and 2010 
SELECT Title, Year FROM movies
WHERE Year NOT BETWEEN 2000 AND 2010;


-- 4. Find the first 5 Pixar movies and their release year
SELECT * FROM movies
WHERE Id <= 5;


	-- SQL Lesson 3: Queries with constraints (Pt. 2) ------------------------------

-- 1. Find all the Toy Story movies 
SELECT * FROM movies
WHERE Title LIKE "Toy Story%";


-- 2. Find all the movies directed by John Lasseter 
SELECT Title, Director
FROM Movies
WHERE Director = "John Lasseter";


-- 3. Find all the movies (and director) not directed by John Lasseter 
SELECT Title, Director
FROM Movies
WHERE Director != "John Lasseter";


-- 4. Find all the WALL-* movies 
SELECT Title, Director
FROM Movies
WHERE Title LIKE "WALL-%";
 

	-- SQL Lesson 4: Filtering and sorting Query results ------------------------------

-- 1. List all directors of Pixar movies (alphabetically), without duplicates 
SELECT DISTINCT Director 
FROM Movies
ORDER BY Director;


-- 2. List the last four Pixar movies released (ordered from most recent to least) 
SELECT Title, Year
FROM Movies
ORDER BY Year DESC
LIMIT 4;


-- 3. List the first five Pixar movies sorted alphabetically 
SELECT Title, Year
FROM Movies
ORDER BY Title
LIMIT 5;


-- 4. List the next five Pixar movies sorted alphabetically 
SELECT Title, Year
FROM Movies
ORDER BY Title
LIMIT 5
OFFSET 5;


	--  SQL Review: Simple SELECT Queries  ------------------------------

-- 1. List all the Canadian cities and their populations  
SELECT City, Country, Population 
FROM North_american_cities
WHERE Country = 'Canada';


-- 2. Order all the cities in the United States by their latitude from north to south 
SELECT City, Latitude, Country
FROM North_american_cities
WHERE Country = 'United States'
ORDER BY Latitude DESC;


-- 3. List all the cities west of Chicago, ordered from west to east 
SELECT City, Longitude
FROM North_american_cities
WHERE Longitude < -87.7
ORDER BY Longitude;


-- 4. List the two largest cities in Mexico (by population) 
SELECT City, Country, Population
FROM North_american_cities
WHERE Country = 'Mexico'
ORDER BY Population DESC
LIMIT 2;


-- 5. List the third and fourth largest cities (by population) in the United States and their population 
SELECT City, Country, Population
FROM North_american_cities
WHERE Country = 'United States'
ORDER BY Population DESC
LIMIT 2
OFFSET 2;


	--  SQL Lesson 6: Multi-table queries with JOINs  ------------------------------
    
-- 1. Find the domestic and international sales for each movie 
SELECT Title, Boxoffice.Domestic_sales, Boxoffice.International_sales
FROM movies
JOIN Boxoffice
ON Movies.Id = Boxoffice.Movie_Id;


-- 2. Show the sales numbers for each movie that did better internationally rather than domestically 
SELECT Title, Boxoffice.Domestic_sales, Boxoffice.International_sales
FROM Movies
JOIN Boxoffice
ON Movies.Id = Boxoffice.Movie_Id
WHERE Boxoffice.International_sales > Boxoffice.Domestic_sales;


-- 3. List all the movies by their ratings in descending order 
SELECT Title, Bx.Rating
FROM Movies
JOIN Boxoffice Bx
ON Movies.Id = Bx.Movie_Id
ORDER BY Bx.Rating DESC;


	--  SQL Lesson 7: OUTER JOINs  ------------------------------
    
-- 1. Find the list of all buildings that have employees 
SELECT DISTINCT Employees.Name, Building_name 
FROM Buildings
LEFT JOIN Employees
ON Buildings.Building_name = Employees.Building
WHERE Name IS NOT NULL;


-- 2. Find the list of all buildings and their capacity 
SELECT Building_name, Capacity 
FROM Buildings;


-- 3. List all buildings and the distinct employee roles in each building (including empty buildings) 
SELECT DISTINCT E.Role, Building_name
FROM Buildings B
LEFT JOIN Employees E
ON B.Building_name = E.Building;
 
  
	--  SQL Lesson 8: A short note on NULLs  ------------------------------
    
-- 1. Find the name and role of all employees who have not been assigned to a building 
SELECT Name, Role 
FROM Employees
WHERE Building IS NULL;


-- 2. Find the names of the buildings that hold no employees 
SELECT DISTINCT Building_name, E.Name 
FROM Buildings B
LEFT JOIN Employees E 
ON B.Building_name = E.Building
WHERE Building IS NULL;

