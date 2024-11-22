Select *
FROM PortfolioProject..CovidDeath
Where continent is not null
Order by 3,4;

--Select *
--FROM PortfolioProject..CovidVaccination
--Order by 3,4;


--Select the Data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
Where continent is not null
order by 1,2;

-- Looking at Total Cases Vs Tota Deaths
-- Shows Likelihood of Dying if you contract covid in your country 

Select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases, 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
Where continent is not null
order by 1,2;

Select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases, 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
Where location like '%united arab%'
And continent is not null
order by 1,2;

-- Looking at the Total Cases Vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeath
--Where location like '%united arab%'
order by 1,2;

-- Looking at countries with highest Infection Rate Compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeath
--Where location like '%united arab%'
Group By location, population
order by PercentagePopulationInfected desc

-- Showing Countries with the Highest Death Count per Population

Select location, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeath
Where continent is not null
Group By location
order by TotalDeathCount desc


-- Lets Break it down by Continent
-- Showing Continents with the Highest Death Count per Population
  
Select continent, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeath
Where continent is not null
Group By continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
--Where location like '%united arab%'
Where continent is not null
and new_cases != 0
--Group By date
order by 1,2;


-- Looking for Total Population Vs Vaccination

Select *
From PortfolioProject..CovidVaccination
Where continent is not null
Order by 3,4

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select * ,(RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using TEMP TABLE to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * ,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to Store Data for later Visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated