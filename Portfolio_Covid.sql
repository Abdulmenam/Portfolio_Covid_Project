

select * from CovidDeaths
where continent is not null

 
 select location, date,total_cases,new_cases,total_deaths,population
 from CovidDeaths
 order by 1,2

 -- Looking at total cases vs total deaths
 select location, date,total_cases,total_deaths,
 (total_deaths/total_cases)*100 as DeathPercentage 
 from CovidDeaths
 where location like 'Latvia'
 order by 1,2

 -- Looking at total cases vs population
  select location, date,population,total_cases,
 (total_cases/population)*100 as PercentPopulationInfected 
 from CovidDeaths
 --where location like 'Latvia'
 order by 1,2

 -- looking at countries with highest infaction rate compared with population

   select location,population,max(total_cases) as Highestinfectioncount,
    max(total_cases/population)*100 as PercentPopulationInfected 
 from CovidDeaths
 --where location like 'Latvia'
 group by location,population
 order by PercentPopulationInfected desc

 --showing countries with the highest death count per population
    select location,max (cast(total_Deaths as int)) as TotalDeathcount
	from CovidDeaths
 --where location like 'Latvia'
 where continent is not null
 group by location
 order by TotalDeathcount desc
 --Lets break things down by continent

select continent,max (cast(total_Deaths as int)) as TotalDeathcount
from CovidDeaths
 --where location like 'Latvia'
 where continent is not null
 group by continent
 order by TotalDeathcount desc


 -- showing the continent wiht highest deat count per population
 select continent,max (cast(total_Deaths as int)) as TotalDeathcount
from CovidDeaths
 --where location like 'Latvia'
 where continent is not null
 group by continent
 order by TotalDeathcount desc

 --Global Numbers
  select date,sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths
 ,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 from CovidDeaths
 --where location like 'Latvia'
 where continent is not null
 group by date
 order by 1,2

 select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths
 ,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 from CovidDeaths
 --where location like 'Latvia'
 where continent is not null
 --group by date
 order by 1,2

 -- looking at total population vs vaccinations

 select dea.continent,
 dea.location,dea.date,dea.population,vac.new_vaccinations
  ,SUM(convert(bigint,vac.new_vaccinations)) over (partition by 
  dea.location order by dea.location ,dea.date  ) as RollingPeopleVaccinated
  --,RollingPeopleVaccinated/population
 from CovidDeaths dea
 join CovidVaccinations vac
     on dea.Location=vac.location      and dea.date=vac.date
	 where dea.continent is not null
	 order by 1,2
-- CTE
with popvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as (
 select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
  ,SUM(convert(bigint,vac.new_vaccinations)) over (partition by 
  dea.location order by dea.location ,dea.date  ) as RollingPeopleVaccinated
  --,RollingPeopleVaccinated/population
 from CovidDeaths dea join CovidVaccinations vac
     on dea.Location=vac.location      and dea.date=vac.date
	 where dea.continent is not null
	-- order by 1,2
	 )
select *,RollingPeopleVaccinated/population *100
from popvsVac

--Temp table
create table #PercentPopulationVaccinated 
( continent nvarchar(225),
location nvarchar(225),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
  ,SUM(convert(bigint,vac.new_vaccinations)) over (partition by 
  dea.location order by dea.location ,dea.date  ) as RollingPeopleVaccinated
  --,RollingPeopleVaccinated/population
 from CovidDeaths dea join CovidVaccinations vac
     on dea.Location=vac.location      and dea.date=vac.date
	-- where dea.continent is not null
	-- order by 1,2
	select *,RollingPeopleVaccinated/population *100
from #PercentPopulationVaccinated 

-- creating view to store daate for late visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
  ,SUM(convert(bigint,vac.new_vaccinations)) over (partition by 
  dea.location order by dea.location ,dea.date  ) as RollingPeopleVaccinated
  --,RollingPeopleVaccinated/population
 from CovidDeaths dea join CovidVaccinations vac
     on dea.Location=vac.location      and dea.date=vac.date
	 where dea.continent is not null
	-- order by 1,2