---------------------------------------------
-- Dr. Strangebot World Perception Layer	-
-- by Owen Johnson							-
-- http://owenjohnson.info/cat/defcon       -
--											-----------------------------
-- Holds data about the world including cities, players, allies, etc.	-
-------------------------------------------------------------------------
World ={}

function World.GetOwnCities()
	DebugLog("Getting list of own cities...")
	local allCities= GetCityIDs()
	local hometeam = GetOwnTeamID()
	local myCities = {}
	for i,city in ipairs(allCities) do
		if (hometeam == GetTeamID(city)) then
			table.insert(myCities, city)
		end
	end
	return myCities
end

function World.GetOwnPopulationCenterDefensive()
	local cities = World.GetOwnCities()
	World.popsort(cities)
	local longs = 0
	local lats = 0
	for _, city in ipairs(cities) do
		longs = longs + city:GetLongitude()
		lats = lats + city:GetLatitude()
	end
	Whiteboard.drawCircle(longs / # cities, lats/ # cities , 5)
	Whiteboard.drawCircle(cities[1]:GetLongitude(), cities[1]:GetLatitude(), 5)
	return (((longs / # cities) + cities[1]:GetLongitude())/2), (((lats / # cities) + cities[1]:GetLatitude())/2)
end

function World.GetOwnPopulationCenterAggressive() --returns the coordinates of the population center
	local cities = World.GetOwnCities()
	World.popsort(cities)
	local longs = 0
	local lats = 0
	for _, city in ipairs(cities) do
		longs = longs + city:GetLongitude()
		lats = lats + city:GetLatitude()
	end
	return longs / # cities, lats/ # cities
end

function World.GetTargetCities()
	--DebugLog("Generating Target List...")
	allCities= GetCityIDs()
	hometeam = GetOwnTeamID()
	friendly = GetAllianceID(hometeam)
	badCities = {}
	for i, city in ipairs(allCities) do
		cityTeam = GetTeamID(city)
		if (hometeam ~= cityTeam and friendly ~= GetAllianceID(cityTeam)) then -- it's not ours, it's not our friend's, LET'S NUKE IT!
			table.insert(badCities, city)
		end
	end
	for _,v in ipairs(World.Get("hostile land")) do table.insert(badCities, v) end
	return badCities
end

function World.proxsort(targs, long, lat)
	table.sort(targs, function(a, b) return GetDistance(long, lat, a:GetLongitude(), a:GetLatitude()) < GetDistance(long, lat, b:GetLongitude(), b:GetLatitude())end)
end

function World.popsort(cityList)
	table.sort(cityList, function(a, b) return a:GetCityPopulation() > b:GetCityPopulation() end)
end

function World.isFriendlyTeam(teamID)
	return (GetAllianceID(GetOwnTeamID()) == GetAllianceID(teamID))
end

function World.isFriendlyTerritory(ter)
	team = World.whoIs(ter)
	return World.isFriendlyTeam(team)
end

function World.isEnemyTerritory(ter)
	team = World.whoIs(ter)
	if not team then return false end
	return not World.isFriendlyTeam(team)
end

function World.isEnemy(unit)
	hometeam = GetOwnTeamID()
	friendly = GetAllianceID(hometeam)
	unitTeam = GetTeamID(unit)
	return (hometeam ~= unitTeam and friendly ~= GetAllianceID(unitTeam)) -- it's not ours, it's not our friend's, LET'S NUKE IT!
end

function World.isMyNeighbor(teamID)
	homeland = World.territoryOf(GetOwnTeamID())
	other = World.territoryOf(teamID)
	return World.isAdjacentTerritory(homeland,other)
end

function World.numberOfAllies(teamID)
	alliance = GetAllianceID(teamID)
	allTeams = GetAllTeamIDs()
	count = 0
	for i, team in ipairs(allTeams)
	do
		if (GetAllianceID(team) == alliance) then count = count + 1 end
	end
	return (count - 1) -- -1 to not count self
end

function World.territoryOf(teamID)
	return GetTeamTerritories(teamID)[1] -- caution, only works for games where players have single territories
end

function World.whoIs(territory)
	everyone = GetAllTeamIDs()
	for i,teamID in ipairs(everyone) do
		t_List = GetTeamTerritories(teamID)
		for j,t_check in ipairs(t_List) do
			if (t_check == territory) then
				return teamID
			end
		end
	end
	return false
end -- returns a teamID object

function World.isAdjacentTerritory(ter1, ter2)
	if (ter1 == "Europe")
	then
		return (ter2 == ("Russia" or ter2 == "Africa"))
	elseif (ter1 == "Russia")
	then
		return (ter2 == ("Europe" or ter2 == "SouthAsia"))
	elseif (ter1 == "Africa")
	then
		return (ter2 == ("Europe" or ter2 == "SouthAsia"))
	elseif (ter1 == "SouthAsia")
	then
		return (ter2 == ("Russia" or ter2 == "Africa"))
	elseif (ter1 == "NorthAmerica")
	then
		return (ter2 == "SouthAmerica")
	elseif (ter1 == "SouthAmerica")
	then
		return (ter2 == "NorthAmerica")
	else return false end
end

function World.CountEnemiesNear(long, lat, radius)
	badCities = World.Get("hostile cities")
	local population = 0
	for _, city in ipairs(badCities) do
		if GetDistance(long, lat, city:GetLongitude(), city:GetLatitude()) < radius then
			population = population + cityGetCityPopulation()
		end
	end
	return population
end

function World.GetNearestEnemyCoast(x,y) -- TODO: Don't hardcode sea coordinates.
	bestlong, bestlat, bestdist = 500, 500, 3600
	d = GetSailDistance(x,y, 22, 60)
	if d < bestdist and World.isEnemyTerritory("Europe") then bestlong, bestlat, bestdist = 22, 60, d end
	d = GetSailDistance(x,y, -70, 37)
	if d < bestdist and World.isEnemyTerritory("NorthAmerica") then bestlong, bestlat, bestdist = -70, 37, d end
	d = GetSailDistance(x,y, -145, 40)
	if d < bestdist and World.isEnemyTerritory("NorthAmerica") then bestlong, bestlat, bestdist = -145, 40, d end
	d = GetSailDistance(x,y, -100, 0)
	if d < bestdist and World.isEnemyTerritory("SouthAmerica") then bestlong, bestlat, bestdist = -100, 0, d end
	d = GetSailDistance(x,y, -45, 15)
	if d < bestdist and World.isEnemyTerritory("SouthAmerica") then bestlong, bestlat, bestdist = -45, 15, d end
	d = GetSailDistance(x,y, -10, -10)
	if d < bestdist and World.isEnemyTerritory("Africa") then bestlong, bestlat, bestdist = -10, -10, d end
	d = GetSailDistance(x,y, 60, 0)
	if d < bestdist and World.isEnemyTerritory("Africa") then bestlong, bestlat, bestdist = 60, 0, d end
	d = GetSailDistance(x,y, 85,0 )
	if d < bestdist and World.isEnemyTerritory("SouthAsia") then bestlong, bestlat, bestdist = 85, 0, d end
	d = GetSailDistance(x,y, 133, 24)
	if d < bestdist and World.isEnemyTerritory("SouthAsia") then bestlong, bestlat, bestdist = 133, 24, d end
	d = GetSailDistance(x,y, 60, 85)
	if d < bestdist and World.isEnemyTerritory("Russia") then bestlong, bestlat, bestdist = 60, 85, d end
	--d = GetDistance(x,y, 175, 55)
	--if d < bestdist and World.isEnemyTerritory("Russia") then bestlong, bestlat, bestdist = 175, 55, d end
	return bestlong, bestlat

end

----------------------------
--	Massive Filter Function	\---------------------------
--  It's ugly here, but it makes for poetry elsewhere.	\-----------
--  I'm actually kinda proud of this one. It's near human language.	\
--  Takes a single string as an argument to combine team, type, and	 )
-- 		nuclear capacity into a neat filtered list of your units.	/
--------------------------------------------------------------------
--usage: World.Get("(all|my|hostile) ((land|sea|planes)|(airbase|silo|radar|city|cities|battleship|carrier|sub|fighter|bomber|missile)) [with nukes|empty]")

function World.Get(query)
	local units = {}
	-- first, filter by team status. One of all, own, friendly, or enemy should be included.
	if string.match(query, "my") then
		units = GetOwnUnits()
	elseif string.match(query, "hostile") then
		for i, unit in ipairs(GetAllUnits()) do
			if World.isEnemy(unit) then
				table.insert(units, unit)
			end
		end
	elseif string.match(query, "friendly") then
		for i, unit in ipairs(GetAllUnits()) do
			if World.isFriendlyTeam(unit:GetTeamID()) then
				table.insert(units, unit)
			end
		end
	else
		units = GetAllUnits()
	end

	-- filter by unit type land, sea, air, Silo, AirBase, RadarStation, BattleShip, Carrier, Sub, Fighter, Bomber, missile -- only one of these should be used.
	if string.match(query, "land") then
		landunits = {}
		for i, unit in ipairs(units) do
			if string.match("SiloAirBaseRadarStation", unit:GetUnitType()) then
				table.insert(landunits, unit)
			end
		end
		units = landunits
	elseif string.match(query, "sea") then
		seaunits = {}
		for i, unit in ipairs(units) do
			if string.match("BattleShipCarrierSub", unit:GetUnitType()) then
				table.insert(seaunits, unit)
			end
		end
		units = seaunits
	elseif string.match(query, "planes") then
		airunits = {}
		for i, unit in ipairs(units) do
			if string.match("FighterBomber", unit:GetUnitType()) then
				table.insert(airunits, unit)
			end
		end
		units = airunits
	elseif string.match(query, "silo") then
		typeunit = {}
		for i, unit in ipairs(units) do
			if unit:GetUnitType() == "Silo" then table.insert(typeunit, unit) end
		end
		units= typeunit
	elseif string.match(query, "airbase") then
		typeunit = {}
		for i, unit in ipairs(units) do
			if unit:GetUnitType() == "AirBase" then table.insert(typeunit, unit) end
		end
		units= typeunit
	elseif string.match(query, "radar") then
		typeunit = {}
		for i, unit in ipairs(units) do
			if unit:GetUnitType() == "RadarStation" then table.insert(typeunit, unit) end
		end
		units= typeunit
	elseif string.match(query, "battleship") then
		typeunit = {}
		for i, unit in ipairs(units) do
			if unit:GetUnitType() == "BattleShip" then table.insert(typeunit, unit) end
		end
		units= typeunit
	elseif string.match(query, "carrier") then
		typeunit = {}
		for i, unit in ipairs(units) do
			if unit:GetUnitType() == "Carrier" then table.insert(typeunit, unit) end
		end
		units= typeunit
	elseif string.match(query, "sub") then
		typeunit = {}
		for i, unit in ipairs(units) do
			if unit:GetUnitType() == "Sub" then table.insert(typeunit, unit) end
		end
		units= typeunit
	elseif string.match(query, "fighter") then
		typeunit = {}
		for i, unit in ipairs(units) do
			if unit:GetUnitType() == "Fighter" then table.insert(typeunit, unit) end
		end
		units= typeunit
	elseif string.match(query, "bomber") then
		typeunit = {}
		for i, unit in ipairs(units) do
			if unit:GetUnitType() == "Bomber" then table.insert(typeunit, unit) end
		end
		units= typeunit
	elseif string.match(query, "missle") then
		typeunit = {}
		for i, unit in ipairs(units) do
			if unit:GetUnitType() == "Nuke" then table.insert(typeunit, unit) end
		end
		units= typeunit
	elseif string.match(query, "cit") then
		typeunit = {}
		for _, unit in ipairs(units) do
			if unit:GetUnitType() == "City" then table.insert(typeunit, unit) end
		end
		units = typeunit
	end
	-- filter "with nukes"
	if string.match(query, "with nukes") then
		hasnukes = {}
		for i, unit in ipairs(units) do
			if unit:GetNukeCount() > 0 then table.insert(hasnukes, unit) end
		end
		units = hasnukes
	elseif string.match(query, "empty") then
		hasnonukes = {}
		for _, unit in ipairs(units) do
			if unit:GetNukeCount() == 0 then table.insert(hasnonukes, unit) end
		end
		units = hasnonukes
	end

	--done filtering, send result
	return units
end

function World.GetNearest(query, long, lat)
    local targs = World.Get(query)
    if # targs > 0 then
        World.proxsort(targs, long, lat)
        local target = targs[1]
        return target:GetLongitude(), target:GetLatitude()
    else
        return World.GetNearest("sea",long, lat)
    end
end

function World.GetInRangeOf(query, unit)
    local targs = World.Get(query)
    local inrange = {}
    for i, targ in ipairs() do
        if GetDistance(targ:GetLongitude(), targ:GetLatitude(), unit:GetLongitude(), unit:GetLatitude()) < unit:GetRange() then
            table.insert(targs[i])
        end
    end
    return inrange()
end
        
