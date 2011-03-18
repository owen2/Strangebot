-----------------------------------------
-- strangelove.lua						-
-- Strategy Module for Dr. Strangebot	-
-- by Owen Johnson						-
-- http://owenjohnson.info/cat/strangebot
--										---------------------------------------------
-- This contains all of the high level strategy for the agent. It's fancy....		-
-- uses martin's coroutine wrapper. Thanks! see Multithreading.lua for more details	-
-------------------------------------------------------------------------------------

strangelove = {}

strangelove.personality = "aggressive" -- just for default's sake
-- OR -- ( "aggressive" | "defensive" | "reactive" )

function strangelove.makeFriends()
	RequestAlliance(GetAllianceID(strangelove.getBestAlly()))
end

function strangelove.getBestAlly()
	bestscore = -1
	bestteam = nil
	for i,team in ipairs(GetAllTeamIDs())
	do
		score = strangelove.allyUsefulness(team)
		if (score > bestscore)
			then bestscore, bestteam = score, team
			DebugLog("Best ally so far is"..GetTeamName(team).." SCORE: "..score)
		else
			DebugLog(GetTeamName(team).." is not a good ally. SCORE: "..score)
		end
	end
	return bestteam
end

function strangelove.allyUsefulness(team) -- return probability that ally will be useful
	usefulness = 1.0
	if (team == GetOwnTeamID()) -- Don't ask yourself for alliance
		then DebugLog(GetTeamName(team).." is self") return 0 end
	if (string.match(GetTeamName(team),"[CPU]")) -- Don't ask the original CPU player for alliance, it will ignore you.
		then DebugLog(GetTeamName(team).." is cpu") return 0 end
	if (not World.isMyNeighbor(team)) -- neighbors make for a good ally
	then
		DebugLog(GetTeamName(team).." is not a neighbor")
		usefulness = .75 * usefulness end
	usefulness = (World.numberOfAllies(team)+1) * usefulness-- Make biggest alliance highest priority
	return usefulness
end

function strangelove.buildBoats()
	strangelove.buildStuffRandom()
	--strangelove.sendBoats()
end

function strangelove.buildHiveByPopulationCenter()
		if (placed ~= 1) then
			if (strangelove.personality == "defensive") then
				baselong, baselat = World.GetOwnPopulationCenterDefensive()
				radius = 10
			else
				baselong, baselat = World.GetOwnPopulationCenterDefensive()
				radius = 5.1
			end
			Whiteboard.drawCircle(baselong, baselat, 5)
			DebugLog("baselong, baselat: "..baselong..", "..baselat)
			PlaceStructure(baselong, baselat, "RadarStation")
			strangelove.buildRing(baselong, baselat, radius, "Silo")
		end
end

function strangelove.buildFleet(x, y, radius, unitType)
	--NewThread(function(x, y, radius, unitType)
		local theta_step = math.pi * 2 / 6
		local sin1, cos1 = math.sin(theta_step), math.cos(theta_step)
		local dx = radius
		local dy = 0
		for i = 0, 6 do
			local nx = cos1 * dx - sin1 * dy
			local ny = sin1 * dx + cos1 * dy
			PlaceFleet(x+nx, y+ny, unitType)
			--Wait(true)
			dx, dy = nx, ny
		end
	--end)
end

function strangelove.buildRing(x, y, radius, unitType)
	--NewThread(function(x,y,radius. unitType)
		local theta_step = math.pi * 2 / 6
		local sin, cos = math.sin(theta_step), math.cos(theta_step)
		local dx = radius
		local dy = 0
		for i = 0, 6 do
			local nx = cos * dx - sin * dy
			local ny = sin * dx + cos * dy
			PlaceStructure(x + nx, y + ny, unitType)
			--Wait(true)
			WhiteboardDraw(x + dx, y + dy, x + nx, y + ny)
			dx, dy = nx, ny
		end
	--end)
end

function strangelove.buildStuffRandom()
	if (placed ~= 1) then
		if GetRemainingUnits("Silo") > 0 then
			DebugLog(GetRemainingUnits("Silo").." silos left")
			repeat
				lat, long = math.random() * 360 - 180, math.random() * 360 - 180
				--long, lat = GetLongitude(myCities[i]), GetLatitude(myCities[i])
			until (IsValidPlacementLocation(long, lat, "Silo"))
				PlaceStructure(long, lat, "Silo")
		end
		if GetRemainingUnits("RadarStation") > 0 then
			repeat
				lat, long = math.random() * 360 - 180, math.random() * 360 - 180
			until (IsValidPlacementLocation(long, lat, "RadarStation"))
				PlaceStructure(long, lat, "RadarStation")
		end
		if GetRemainingUnits("AirBase") > 0 then
			repeat
				lat, long = math.random() * 360 - 180, math.random() * 360 - 180
			until (IsValidPlacementLocation(long, lat, "AirBase"))
				PlaceStructure(long, lat, "AirBase")
		end
		if GetRemainingUnits("BattleShip") > 0 then
			repeat
				lat, long = math.random() * 360 - 180, math.random() * 360 - 180
			until IsValidPlacementLocation(long, lat, "BattleShip")
				PlaceFleet(long, lat, "BattleShip", "BattleShip", "BattleShip", "BattleShip","BattleShip", "BattleShip")
				--strangelove.buildFleet(long, lat, 3, "BattleShip")
		elseif GetRemainingUnits("Carrier") > 0 then
			repeat
				lat, long = math.random() * 360 - 180, math.random() * 360 - 180
			until IsValidPlacementLocation(long, lat, "Carrier")
				PlaceFleet(long, lat, "Carrier", "Carrier", "Carrier", "Carrier", "Carrier", "Carrier")
				--strangelove.buildFleet(long, lat,3 ,  "Carrier")
		elseif GetRemainingUnits("Sub") > 0 then
			repeat
				lat, long = math.random() * 360 - 180, math.random() * 360 - 180
			until IsValidPlacementLocation(long, lat, "Sub")
				PlaceFleet(long, lat, "Sub", "Sub", "Sub", "Sub", "Sub", "Sub")
				--strangelove.buildFleet(long, lat,3, "Sub")
		else
			--strangelove.moveBoats()
			placed= 1
		end
	end
end

function strangelove.nukepanic()
	local targets = World.GetTargetCities()
	if GetGameTick() % 10 == 0 then
		silos = World.Get("my silos with nukes")
		for _, silo in ipairs(silos) do
			silo:SetState(0)
				World.proxsort(targets, silo:GetLongitude(), silo:GetLatitude())
				target = targets[j % # targets]
				j=j+1
				silo:SetActionTarget(target)
		end
		subs = World.Get("my subs with nukes")
		for _, sub in ipairs(subs) do
			clong, clat = sub:GetLongitude(), sub:GetLatitude()
			tlong, tlat = World.GetNearestEnemyCoast(clong, clat)
			--DebugLog(clong.." "..clat.." "..tlong.." "..tlat)
			if GetDistance(clong, clat, tlong, tlat) < 20 then
				sub:SetState(2)
				target = targets[j % # targets]
				j=j+1
				sub:SetActionTarget(target)
			else
				sub:SetMovementTarget(tlong, tlat)
			end
		end
		airbases = World.Get("my airbases with nukes")
		targets = World.Get("hostile land")

		for _,base in ipairs(airbases) do
			World.proxsort(targets, base:GetLongitude(), base:GetLatitude())
			base:SetState(1)
			target = targets[j % # targets]
			j=j+1
			base:SetActionTarget(target)
			--DebugLog("Told airbase to launch.")
		end
		airbases = World.Get("my carriers with nukes")
		for _,base in ipairs(airbases) do
			World.proxsort(targets, base:GetLongitude(), base:GetLatitude())
			base:SetState(1)
			target = targets[j % # targets]
			j=j+1
			base:SetActionTarget(target)
			--DebugLog("Told airbase to launch.")
		end
	end
end

function strangelove.sendBoats()
	local scoremode = GetOptionValue("ScoreMode")
	if scoremode == 1 or string.match("NorthAmerica SouthAmerica Africa",World.territoryOf(GetOwnTeamID())) then
		strangelove.moveBoatsDefensive()
	else
		strangelove.moveBoatsAgressive()
	end
end

function strangelove.moveBoatsDefensive() -- move subs to assault position, keep carriers and BattleShips on home coast
	local boats = World.Get("my subs")
	for _, sub in ipairs(boats) do
		x,y = World.GetNearestEnemyCoast(sub:GetLongitude(), sub:GetLatitude())
		sub:SetMovementTarget(x + ((math.random() * 10) - 5), y + ((math.random() * 10) - 5))
	end
	boats = World.Get("my carriers")
	for _, carrier in ipairs(boats) do
		carrier:SetState(2)
	end
end

function strangelove.moveBoatsAgressive() -- move all boats to assault position for sea battle and naval nuking
	units = World.Get("my sea units")
	for _, unit in ipairs(units) do
		x, y = World.GetNearestEnemyCoast(unit:GetLongitude(),unit:GetLatitude())
		unit:SetMovementTarget(x + ((math.random() * 10) - 5),y + ((math.random() * 10) - 5))
	end
end


