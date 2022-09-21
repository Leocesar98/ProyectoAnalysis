SELECT * from PortfolioPoject..covidDeath
where continent is not null
order by 3,4

--SELECT * from PortfolioPoject..covidVaccionation
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioPoject..covidDeath
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths

--Mostrar la posibilidad de morir si te contagias de covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioPoject..covidDeath
Where location like '%argentina%'
order by 1,2

--Buscar Total Cases vs Population
--mostraria el porcentage de popilation que tuvo covid en argentina
Select Location, date, total_cases, population, (total_cases/population)*100 as PoblacionInfectada
From PortfolioPoject..covidDeath
Where location like '%argentina%'
order by 1,2

--Cual es el pais con mayor infectados comparados con population
Select Location,population, MAX(total_cases)as MayorInfectados, MAX((total_cases/population))*100 as PorcentajePoblacionInfectada
From PortfolioPoject..covidDeath
--Where location like '%argentina%'
where continent is not null
group by location, population
order by PorcentajePoblacionInfectada desc


--Paises con mayor cantidad de muertos por poblacion

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioPoject..covidDeath
Where location like '%argentina%'
--where continent is not null
group by location
order by TotalDeathCount desc

--Que pasa si quiero ver solo continentes con mayor cantidad de muertes?
Select location, MAX(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioPoject..covidDeath
where continent is null
Group by location
order by TotalDeathcount desc

--Que pasa si pido por continente y no por locacion? 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioPoject..covidDeath
where continent is not null
Group by continent
order by TotalDeathcount desc

--Numeros GLOBALES por dia

Select date, SUM(new_cases) as  casosNuevos, SUM(cast(new_deaths as int)) NuevasMuertes,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioPoject..covidDeath
where continent is not null
Group By date
order by 1,2

--Numeros GLOBALES TOTALES

Select SUM(new_cases) as casosNuevos, SUM(cast(new_deaths as int)) NuevasMuertes,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioPoject..covidDeath
where continent is not null
order by 1,2

-- Ver la cantidad de Vacunados en la Poblacion mundial
--Joins
--Muestra los nuevos vacunados por dia!
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.date) as sumaTotalxDia 
from PortfolioPoject..covidDeath as dea
Join PortfolioPoject..covidVaccionation as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
--CTE OR TEMP table

--CTE
with populationvsVaccination (Continent, location, date, population, new_vaccinations, sumaTotalxDia)
as --Tener en cuenta que al hacer un CTE tenemos que tener la misma cantidad de columnas en la tabla 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
	dea.date) as sumaTotalxDia 
from PortfolioPoject..covidDeath as dea
Join PortfolioPoject..covidVaccionation as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (sumaTotalxDia/population)*100
From populationvsVaccination

-- Comparando con la TEMP TABLE
DROP Table if exists #PorcentPopulationVaccinated
Create Table #PorcentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
SumaTotalxDia numeric
)
Insert into #PorcentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as sumaTotalxDia 
from PortfolioPoject..covidDeath as dea
Join PortfolioPoject..covidVaccionation as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (sumaTotalxDia/Population)*100
From #PorcentPopulationVaccinated




--Create a view multiple times if possible to store data for later visualizations

Create View PorcentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as sumaTotalxDia 
from PortfolioPoject..covidDeath as dea
Join PortfolioPoject..covidVaccionation as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PorcentPopulationVaccinated
