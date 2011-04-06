-----------------------------------------
-- micro.lua							-
-- Strategy Module for Dr. Strangebot	-
-- by Owen Johnson						-
-- http://owenjohnson.info/cat/strangebot
--										-------------------------
-- This contains all of the micro level Strategy. It's fancy!	-
-----------------------------------------------------------------

micro = {}

function micro.airbaseDefensive()
	if GetGameTick() % 10 == 0 then
		local bases = World.Get("my airbases")
		local bogies = World.Get("hostile planes")
		for _, base in ipairs(bases) do
			base:SetState(0)
			World.proxsort(bogies, base:GetLongitude(), base:GetLatitude())
			base:SetActionTarget(bogies[1])
		end
	end
end

function micro.airbaseScout()
	if GetGameTick() % 50 == 0 then
		local bases = World.Get("my airbases")
		local spots = World.GetTargetCities()

		for _,base in ipairs(bases) do
			World.proxsort(spots, base:GetLatitude(), base:GetLongitude())
			base:SetState(0)
			base:SetActionTarget(spots[j])
		end
	end
end

function micro.bomberBail(bomber)
	targets = World.GetTargetCities()
	World.proxsort(targets, bomber:GetLatitude(), bomber:GetLongitude())
	bomber:SetState(1)
	bomber:SetActionTarget(targets[1])
	DebugLog("Owch My Bomber!")
end

function micro.subBail(sub)
	sub:SetState(1)
	DebugLog("Owch My SUB!")
end

function micro.updateBoats()
	if GetGameTick() % 50  == 0 and flag_placed == 1 then
		boids = World.Get("my sea")
		for _,boid in ipairs(boids) do
			--DebugLog(boid:GetStateTimer())
			if boid:GetStateTimer() == 0 then -- only move if not doing anything useful.
				long1, lat1 = micro.boidFollow(boid, .1, "my sea")
				long2, lat2 = micro.boidSpacing(boid, 6)
				long3, lat3 = micro.boidGoal(boid)

				lat = boid:GetLatitude() + lat1 + lat2 + lat3
				long = boid:GetLongitude() + long1 + long2 + long3

				if IsSea(long, lat) then
					boid:SetMovementTarget(long, lat)
				else
					DebugLog("Bad Sea Coordinate: "..long..","..lat)
					boid:SetMovementTarget(long3, lat3)
					--Whiteboard.DrawCross(long, lat, 1)
				end
			end
		end
	end
end

function micro.boidFollow(boid, rate, query)
	local lat = 0
	local long = 0
	--local boids = World.Get("my other sea units from hell!")
	local boids = World.Get(query)
	for _,boid_other in ipairs(boids) do
		if boid ~= boid_other then
			lat = lat + boid_other:GetLatitude()
			long = long + boid_other:GetLongitude()
		end
	end

	lat = lat / # boids - 1
	long = long / # boids - 1
	return long * rate, lat * rate
end

function micro.boidSpacing(boid, distance)

	local lat = 0
	local long = 0
	local boids = World.Get("my other sea units from hell!")
	for _,boid_other in ipairs(boids) do
		if boid  ~= boid_other then
			if GetDistance(boid:GetLatitude(), boid:GetLongitude(), boid_other:GetLatitude(), boid_other:GetLongitude()) < distance then
				lat = lat - (boid:GetLatitude() - boid_other:GetLatitude())
				long = long - (boid:GetLongitude() - boid_other:GetLongitude())
			end
		end
	end

	return long, lat
end

function micro.boidGoal(boid)
	if     boid:GetUnitType() == "Sub" then long, lat = micro.subGoal(boid)
	elseif boid:GetUnitType() == "Carrier" then long, lat = micro.boidFollow(boid, 1, "my subs")
	elseif boid:GetUnitType() == "BattleShip" then long, lat = micro.BattleShipGoal(boid) end
	return (long) - boid:GetLongitude(), (lat) - boid:GetLatitude()
end

function micro.subGoal(sub)
	if sub:GetNukeCount() > 0 then
		return World.GetNearestEnemyCoast(sub:GetLongitude(), sub:GetLatitude())
	else
		return micro.boidFollow(sub, 1,"hostile sea")
	end
end

function micro.BattleShipGoal(ship)
	if strangelove.personality == "aggressive" then
		return micro.boidFollow(ship, 1,"my carriers")
	else
		return micro.boidFollow(ship, 1, "hostile sea")
	end
end

function micro.assertPersonality()
	if strangelove.personality == "defensive" then
		local subs = World.Get("my sea")
		for _,sub in ipairs(subs) do
			sub:SetState(1)
		end
	end
end
