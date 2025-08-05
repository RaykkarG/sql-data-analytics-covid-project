SELECT * FROM CovidDeaths
select * from CovidVaccinations

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at total cases vs total deaths in Brazil,
-- death percentage
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	COALESCE(total_deaths,0) AS total_deaths,
	CONCAT(ROUND((COALESCE(total_deaths,0) / total_cases) * 100,2), '%') AS death_percentage,
	population 
FROM CovidDeaths
WHERE location LIKE 'Bra%' AND continent IS NOT NULL
ORDER BY location, date

-- Looking at total cases vs Population
-- Population cases percentage
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	COALESCE(total_deaths,0) AS total_deaths,	-- Data Normalization
	CONCAT(ROUND((COALESCE(total_deaths,0) / total_cases) * 100,2), '%') AS death_percentage, -- Data Normalization
	CONCAT(ROUND((total_cases / population) * 100,2), '%') AS population_infection,	-- Data Normalization
	population 
FROM CovidDeaths
WHERE location LIKE 'Bra%' AND continent IS NOT NULL
ORDER BY location, date


-- Looking at countries with highest infection rate compared to population
SELECT 
	location, 
	population,
	MAX(total_cases) AS highest_infection_count, 
	MAX(total_deaths) AS total_deaths, 	-- Data Normalization
ROUND(MAX((total_cases) / population) * 100,2) AS population_infection
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY population_infection desc

-- Showing counties with the highest deaths count per population
SELECT 
	location, 
	population,
	MAX(CAST(total_deaths AS INT)) AS total_deaths, 	-- Data Normalization
	CONCAT(ROUND(MAX(CAST(total_deaths AS int) / population) * 100, 2), '%') AS population_death
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_deaths desc

-- Showing continents with the highest death count per population
SELECT 
	continent, 
	SUM(population) AS population,
	MAX(CAST(total_deaths AS INT)) AS total_deaths, 	-- Data Normalization
	CONCAT(ROUND(MAX(CAST(total_deaths AS int) / population) * 100, 2), '%') AS population_death
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY total_deaths desc

-- Looking at total population vs vaccinations (Join tables)
SELECT 
    D.continent, 
    D.location, 
    D.date, 
    D.population, 
    V.new_vaccinations,
    SUM(CAST(V.new_vaccinations AS INT)) OVER (PARTITION BY D.location ORDER BY D.date) AS running_total_vaccinations,
    SUM(CAST(V.new_vaccinations AS INT)) OVER (PARTITION BY D.location) AS total_vaccinations
FROM CovidDeaths D
JOIN CovidVaccinations V 
    ON D.location = V.location AND D.date = V.date
WHERE V.new_vaccinations IS NOT NULL
ORDER BY D.location, D.date;

