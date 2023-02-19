--show the death Table
select *
from Portfolioproject..codeath

--show the vaccinated table
select *
from Portfolioproject..covac

--cases by continents
select continent, sum(total_cases) as Totalcases
from Portfolioproject..codeath 
where continent is not null
group by continent
order by 2

--cases in africa
select A.location, totalcase
from (
select  location,  sum(total_cases) totalcase
from Portfolioproject..codeath 
where continent = 'africa' 
group by location
) A
where totalcase is not null

--another table view
select  location,date, total_cases, new_cases,total_deaths,Population
from Portfolioproject..codeath 
order by 1,2

--looking at total cases vs total deaths
--this shows the likelihood of dying if you contact covid in united state
select  location,date, total_cases,total_deaths,(total_deaths/Total_cases)*100 as Deathpercentage
from Portfolioproject..codeath 
where location like '%states%'
order by 3,5 desc

--this shows the likelihood of dying if you contact covid in nigeria
select  location,date, total_cases,total_deaths,(total_deaths/Total_cases)*100 as Deathpercentage
from Portfolioproject..codeath 
where location like '%nigeria%'
order by 3,5 desc

--looking at total cases vs population
--shows what percentage of population who got covid
select  location,date,population, total_cases,(total_cases/Population)*100 as casespercentage
from Portfolioproject..codeath 
where location like '%states%'
order by 3,5 desc

--in what order of months is united state getting relieved from their highest cases nightmare
select  month(A.date) month ,max( A.casespercentage ) max_casespercentage
from(
select  location,date,population, total_cases,(total_cases/Population)*100 as casespercentage
from Portfolioproject..codeath 
where location like '%states%' 
) A

group by month(date)
order by 2 desc

--loking at countries with highest rate compared to population
select  location,population, max(total_cases) highestinfectioncount,max((total_cases/Population)*100 )as casespercentage
from Portfolioproject..codeath 
where continent is not null
group by location, population
order by 4 desc

--showing countries with the highest death count per population
select  location, max(cast (total_cases as int)) as totaldeathcount
from Portfolioproject..codeath 
where continent is not null
group by location
order by  2 desc

--Breaking things down by continent
select continent, max(cast (total_cases as int)) as totaldeathcount
from Portfolioproject..codeath 
where continent is not null
group by continent
order by  2 desc

--Global numbers
select  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Portfolioproject..codeath 
where continent is not null
group by date
order by  1,2 desc


--show the vaccinated table
select *
from Portfolioproject..covac

--showing the rate of vaccinated peeple to the population
select dea.continent, dea.location,dea.date, dea.population,vac.people_vaccinated,
(vac.people_vaccinated/dea.population)*100 as vaccination_perct
from Portfolioproject..codeath dea
join Portfolioproject..covac vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,6 desc

--loking at rate of vaccination daily
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevac
from Portfolioproject..codeath dea
join Portfolioproject..covac vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--using CTE
with popsvac (continent, location,date,population,new_vac,rollingpeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevac
from Portfolioproject..codeath dea
join Portfolioproject..covac vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *,(rollingpeoplevaccinated/population)*100 rollingpercent
from popsvac

--TEMP TABLE
drop table if exists  #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevac
from Portfolioproject..codeath dea
join Portfolioproject..covac vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *,(rollingpeoplevaccinated/population)*100 rollingpercent
from #percentpopulationvaccinated


--CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS
create view percentpopulationvaccinated as
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevac
from Portfolioproject..codeath dea
join Portfolioproject..covac vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
