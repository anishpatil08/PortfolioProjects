--SELECT * 
--FROM PortfolioProject.dbo.covidVaccinations
--order by 3,4

SELECT * 
FROM PortfolioProject.dbo.covidDeaths
order by 3,4

SELECT location,date ,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

--looking at total cases vs total deadths
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / NULLIF(total_cases, 0)) * 100 AS death_percentage
FROM PortfolioProject.dbo.covidDeaths
where location like '%india%'
order by 1,2

--total cases vs population
--show what percentage of population got Covid

SELECT 
    location,
    date,
    total_cases,
    population,
    (total_cases / NULLIF(population, 0)) * 100 AS death_percentage
FROM PortfolioProject.dbo.covidVaccinations
--where country like '%india%'
order by 1,2

--  LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARING TO POPULATION
SELECT 
    location,
    population,
   MAX(total_cases)as Highest_Infection_count,
    MAX((total_cases /(population)) * 100 )AS InfectedPopulations
FROM PortfolioProject.dbo.CovidDeaths
--where country like '%india%'
group by location, population 
order by InfectedPopulations desc

---looking for countries with highest deadth count per population

SELECT 
    location,
    population,
   MAX(cast(total_deaths as int ))as highest_death,
    MAX((total_deaths /(population)) * 100 )AS deathPercentage
FROM PortfolioProject.dbo.covidDeaths
--where country like '%states%'4
where continent is not null
group by location, population 
order by deathPercentage desc


--lets brak down by continent


--this is showing continent with highest death counts

select continent ,max(cast(Total_deaths as int )) as totalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by totalDeathCount desc

--global numbers
SELECT
    sum(new_cases) as totalCases,SUM(cast(new_deaths as int)) as totalDeaths,sum(cast(new_deaths as int)) /sum(new_cases)*100 as death_percentage
FROM PortfolioProject.dbo.covidDeaths
where continent is not null
--where location like '%india%'
--group by date
order by 1,2
--looking total population vs vacination

select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CAST(vac.new_vaccinations as int))over (Partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccinated,
--(rollingPeopleVaccinated/population )*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location 
and  dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte 
with PopVsVac(Continent,location,date ,population ,new_vaccinations,rollingPeopleVaccinated)
as(
select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CAST(vac.new_vaccinations as int))over (Partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location 
and  dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingPeopleVaccinated/population )*100
from PopVsVac

--temp table
drop  table if exists #PercentopulationVaccinated
create table #PercentopulationVaccinated(

continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric

)

insert into #PercentopulationVaccinated
select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CAST(vac.new_vaccinations as int))over (Partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location 
and  dea.date=vac.date
----where dea.continent is not null

select * ,(rollingPeopleVaccinated/population)*100
from #PercentopulationVaccinated

--creating view for later visualization
 drop view PercentopulationVaccinated;
 create view  PercentopulationVaccinated as
 select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CAST(vac.new_vaccinations as int))over (Partition by dea.location order by 
dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location 
and  dea.date=vac.date
where dea.continent is not null

SELECT TOP 10 *
FROM dbo.PercentopulationVaccinated;