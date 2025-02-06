select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths 
order by 1,2;

-- total cases vs total deaths
-- show likelihood of dying in thailand

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeaths
where location like '%thai%'

-- total cases vs population
-- show percentage of thailand population got covid

select location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
from CovidDeaths
where location like '%thai%'

-- covid infection rate country ranking

select location, population, MAX(total_cases) as highes_infection_count, max((total_cases/population))*100 as infected_percentage
from CovidDeaths GROUP BY location, population ORDER BY infected_percentage DESC

-- countries with the highest death count per population

select location, max(total_deaths) as total_deaths
from CovidDeaths
GROUP BY location ORDER BY total_deaths DESC

-- breakdown by continet

select continent, max(total_deaths) as total_deaths
from CovidDeaths
GROUP BY continent ORDER BY total_deaths DESC

-- global numbers
WITH cte1 AS (
    SELECT 
        date, 
        SUM(new_cases) AS cases, 
        SUM(new_deaths) AS deaths
    FROM CovidDeaths
    GROUP BY date
)
SELECT 
    *,
    CASE 
        WHEN cases = 0 THEN 0  -- Set death percentage to 0 if cases is 0
        ELSE (deaths / cases) * 100 
    END AS deaths_percentage
FROM cte1;


-- tracking vaccinations
with cte2 as
(select 
    dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_new_vaccinations
from CovidDeaths dea
JOIN CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date)
select *, (total_new_vaccinations/population)*100 as population_vaccinated_percentage from cte2


-- create temp table

IF OBJECT_ID('tempdb..#PopulationVaccinated') IS NOT NULL
    DROP TABLE #PopulationVaccinated;

CREATE TABLE #PopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date date,
    population numeric,
    new_vaccinations numeric,
    total_new_vaccinations numeric,
)

insert into #PopulationVaccinated
select 
    dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_new_vaccinations
from CovidDeaths dea
JOIN CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date

select * from #PopulationVaccinated;


/* create view (for later visualizations)

CREATE VIEW PercentPopulationVaccinated AS
select 
    dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_new_vaccinations
from CovidDeaths dea
JOIN CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date

*/

