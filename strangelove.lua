-----------------------------------------
-- strangelove.lua						-
-- Strategy Module for Dr. Strangebot	-
-- by Owen Johnson						-
-- http://owenjohnson.info/cat/strangebot
--										---------------------------------------------
-- This contains all of the high level strategy for the agent. It's fancy....		-
-------------------------------------------------------------------------------------

strangelove = {}

strangelove.personality = "aggressive" -- just for default's sake
-- OR -- ( "aggressive" | "defensive" | "reactive" )

strangelove.nukequeue = Queue.new()

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
end

function strangelove.buildHiveByPopulationCenter()
		if (flag_placed ~= 1) then
			if (strangelove.personality == "defensive") then
				baselong, baselat = World.GetOwnPopulationCenterDefensive()
				radius = 10
			else
				baselong, baselat = World.GetOwnPopulationCenterAggressive()
				radius = 5.1
			end
			Whiteboard.drawCircle(baselong, baselat, 5)
			DebugLog("Hive goes here: "..baselong..", "..baselat)
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
			--PlaceFleet(x+nx, y+ny, unitType)
            local ship = {}
            ship.boattype = unitType
            ship.long = x+nx
            ship.lat  = y+ny
            navy_build_queue.enqueue(ship)
			--Wait(true)
			dx, dy = nx, ny
		end
	--end)
end

function strangelove.buildonce()
    if not navy_build_queue.isEmpty() then
        local ship = navy_build_queue.dequeue()
        PlaceFleet(ship.long, ship.lat, ship.boattype)
    end
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
	if (flag_placed ~= 1) then
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
				--PlaceFleet(long, lat, "BattleShip", "BattleShip", "BattleShip", "BattleShip","BattleShip", "BattleShip")
				strangelove.buildFleet(long, lat,5, "BattleShip")
				strangelove.buildFleet(long, lat,7, "Sub")
				strangelove.buildFleet(long, lat,3, "Carrier")
		elseif GetRemainingUnits("Carrier") > 0 then
			repeat
				lat, long = math.random() * 360 - 180, math.random() * 360 - 180
			until IsValidPlacementLocation(long, lat, "Carrier")
				--PlaceFleet(long, lat, "Carrier", "Carrier", "Carrier", "Carrier", "Carrier", "Carrier")
				strangelove.buildFleet(long, lat,5 ,  "Carrier")
		elseif GetRemainingUnits("Sub") > 0 then
			repeat
				lat, long = math.random() * 360 - 180, math.random() * 360 - 180
			until IsValidPlacementLocation(long, lat, "Sub")
				--PlaceFleet(long, lat, "Sub", "Sub", "Sub", "Sub", "Sub", "Sub")
				strangelove.buildFleet(long, lat,5, "Sub")
		else
			flag_placed = 1
			RequestGameSpeed(20)
		end
	end
end

function strangelove.fillNukeQueue()
    local infrastructure = World.Get("hostile land")
    local long, lat = World.GetOwnPopulationCenterAggressive()
    World.proxsort(infrastructure, long, lat)
    for _, unit in ipairs(infrastructure) do
        strangelove.nukequeue.enqueue(unit)
        strangelove.nukequeue.enqueue(unit) -- i want it in there twice, not a typo
    end
    local targets = World.GetTargetCities()
    World.proxsort(targets, long, lat)
    for _, unit in ipairs(targets) do
        strangelove.nukequeue.enqueue(unit)
    end
end

function strangelove.nukepanic()
	if GetGameTick() % 10 == 0 then
	    if strangelove.siloLaunchCondition() then
		    silos = World.Get("my silos with nukes")
		    for _, silo in ipairs(silos) do
			    silo:SetState(0)
			        if strangelove.nukequeue.isEmpty() then strangelove.fillNukeQueue() end
				    silo:SetActionTarget(strangelove.nukequeue.dequeue())
		    end
        end
		subs = World.Get("my subs")
		for _, sub in ipairs(subs) do
			if sub:GetNukeCount() > 0 then
				--clong, clat = sub:GetLongitude(), sub:GetLatitude()
				--tlong, tlat = World.GetNearestEnemyCoast(clong, clat) --TODO! THIS SUCKS! NEED NEW ALG
				--if GetSailDistance(clong, clat, tlong, tlat) < 20 then
                if strangelove.subLaunchCondition(sub) then
				    local subtargets = World.GetInRangeOf("hostile cities")
                    DebugLog("Number of sub targets in range: ".. # subtargets)
				    World.popsort(subtargets)
				    for i = 1,6 do
                        local target = subtargets[i]
				        sub:SetState(2)
				        sub:SetActionTarget(target)
				        DebugLog("Setting sub target: "..long..", "..lat)
				    end
				end
				--target = targets[j % # targets]
				--j=j+1
				--sub:SetActionTarget(target)
				--end
		    else
				sub:SetState(1)
				flag_silos_free = 1
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
		end
		airbases = World.Get("my carriers with nukes")
		for _,base in ipairs(airbases) do
			World.proxsort(targets, base:GetLongitude(), base:GetLatitude())
			base:SetState(1)
			target = targets[j % # targets]
			j=j+1
			base:SetActionTarget(target)
		end
	end
end

function strangelove.siloLaunchCondition()
    return flag_silos_free == 1
end

function strangelove.subLaunchCondition(sub)
    DebugLog("Subconditions: "..# World.GetInRangeOf("hostile cities",sub).."/6, "..# World.GetInRangeOf("hostile sea",sub).."/0, "..# World.GetInRangeOf("my subs",sub).."/1")
    return # World.GetInRangeOf("hostile cities",sub) >= 6 and # World.GetInRangeOf("hostile sea",sub) == 0 and # World.GetInRangeOf("my subs",sub) > 0
end
