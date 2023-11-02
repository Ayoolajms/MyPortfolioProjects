

Select *
From dbo.CovidDeath
Where continent is not null
Order by 3,4


--Select *
--From dbo.CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeath
Order by 1,2


--Looking at Total Cases Vs Total Deaths

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases), 0))*100 as Deathpercentage
From dbo.CovidDeath
--Where Location = 'united states'
Order by 1,2
-- Shows the likelihood of dying if one contact covid in your country



-- Looking at Total Cases Vs Population

Select Location, date, population, total_cases,  (CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From dbo.CovidDeath
--Where Location = 'united states'
Order by 1,2
-- Shows the percentage of population that got covid


-- Looking at Countries with Highest Infection Rate Compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount,  (MAX(CONVERT(float, total_cases))/NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From dbo.CovidDeath
--Where Location = 'united states'
Group by location, population
Order by PercentPopulationInfected desc
--Shows percentage of population infected in Each Country



--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as INT)) as TotalDeathCount
From dbo.CovidDeath
--Where Location = 'united states'
Where continent is not null
Group by location
Order by TotalDeathCount desc


--BREAKING THNGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
From dbo.CovidDeath
--Where Location = 'united states'
Where continent is not null
Group by continent
Order by TotalDeathCount desc
--Shows the contients with the Highest DeathCount per Population



--Global Numbers
Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as INT)) as Total_deaths,
SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as Deathpercentage
From dbo.CovidDeath
--Where Location = 'united states'
Where continent is not null
--Group by date
Order by 1,2
--Shows Total Cases, Deaths and DeathPercentage of Covid19 in the world


--Looking at Total Population Vs Vaccinations

Select Dea.continent, Dea.location, Dea.date,Dea.population,Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by Dea.location, Dea.date) as RollingpeopleVaccinated
From dbo.CovidDeath Dea join
dbo.CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where Dea.continent is not null
Order by 2,3

-- Using CTE

With PopVsVac (continent, Location, Date, Population, new_vaccinations, RollingpeopleVaccinated)
as 
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by Dea.location, Dea.date) as RollingpeopleVaccinated
From dbo.CovidDeath Dea join
dbo.CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where Dea.continent is not null
)
Select *, (RollingpeopleVaccinated/Population)*100
from PopVsVac


---- TEMP TABLE

Drop Table if exists #PercentPolulationVaccinated
Create Table #PercentPolulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacccinated bigint
)

Insert Into #PercentPolulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by Dea.location, Dea.date) as RollingpeopleVaccinated
From dbo.CovidDeath Dea join
dbo.CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
--Where Dea.continent is not null

Select *, (RollingPeopleVacccinated/Population)*100
from #PercentPolulationVaccinated




-- Creating View to Store data for later visualization

Create view
PercentPolulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by Dea.location, Dea.date) as RollingpeopleVaccinated
From dbo.CovidDeath Dea join
dbo.CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where Dea.continent is not null


Select *
From PercentPolulationVaccinated


Create View TotalDeathCount
as
Select Location, MAX(cast(total_deaths as INT)) as TotalDeathCount
From dbo.CovidDeath
--Where Location = 'united states'
Where continent is not null
Group by location
--Order by TotalDeathCount desc

Select * 
From TotalDeathCount


