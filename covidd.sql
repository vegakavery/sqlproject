select *
from coviddeaths
order by 3,4

--select *
--from covidvaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths,population
from coviddeaths
order by 1,2

--total cases vs total deaths

select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from coviddeaths
where location = 'india'
order by 1,2

-- total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as casespercentage
from coviddeaths
--where location = 'india'
order by 1,2

--highest infected country
select location, population, max(total_cases) as highestcases, max((total_cases/population))*100 as infectedpercentage
from coviddeaths
--where location = 'india'
group by location, population
order by infectedpercentage desc

--counties with highest death count per population
select location, population, max(cast(total_deaths as int)) as totaldeathcount
from coviddeaths
--where location = 'india'
where continent is not null
group by location, population
order by totaldeathcount desc

-- for continent
--showing continent with highest death count
select continent, max(cast(total_deaths as int)) as totaldeathcount
from coviddeaths
--where location = 'india'
where continent is not null
group by continent
order by totaldeathcount desc

-- global numbers

select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from coviddeaths
--where location = 'india'
where continent is not null
--group by date
order by 1,2

--population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, 
 dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with popVSvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, 
 dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popVSvac

--temp table

drop table if exists #perecentpopulationvaccinated
create table #perecentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)

insert into #perecentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, 
 dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #perecentpopulationvaccinated

--creating view

create view perecentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, 
 dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *
from perecentpopulationvaccinated

