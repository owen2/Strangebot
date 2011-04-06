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
		local bogies = World.Get("enemy planes")
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
	bomber:SetActionTarget(targets[1])
end

function micro.seaBattle()

end

function micro.updateBoats()
	if GetGameTick() % 50  == 0 and placed == 1 then
		boids = World.Get("my sea units from hell!")
		for _,boid in ipairs(boids) do
			DebugLog(boid:GetStateTimer())
			if boid:GetStateTimer() == 0 then -- only move if not doing anything useful.
				long1, lat1 = micro.boidFollow(boid, .1, "my sea")
				long2, lat2 = micro.boidSpacing(boid, 3)
				long3, lat3 = micro.boidGoal(boid)

				lat = boid:GetLatitude() + lat1 + lat2 + lat3
				long = boid:GetLongitude() + long1 + long2 + long3

				boid:SetMovementTarget(long, lat)
				if (~IsSea(long, lat)) then
					DebugLog("Bad Sea Coordinate: "..long..","..lat)
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
	if     boid:GetUnitType() == "Sub" then long, lat = World.GetNearestEnemyCoast(boid:GetLongitude(), boid:GetLatitude())
	elseif boid:GetUnitType() == "Carrier" then long, lat = micro.boidFollow(boid, 1, "my subs")
	elseif boid:GetUnitType() == "BattleShip" then long, lat = micro.boidFollow(boid, 1,"my carriers") end
	return (long * .9) - boid:GetLongitude(), (lat * .9) - boid:GetLatitude()
end
--[[
function micro.SubGoal(boid)
	lat, long = World.GetNearestEnemyCoast(boid:GetLatitude(), boid:GetLongitude())
	return (lat - boid:GetLatitude()), (long - boid:GetLongitude())
end

function micro.CarrierGoal(boid)
	local lat = 0
	local long = 0
	local subs = World.Get("my subs")
	for _,sub in ipairs(boids) do
		if boid ~= sub then
			lat = lat + sub:GetLatitude()
			long = long + sub:GetLongitude()
		end
	end

	lat = lat / # subs - 1
	long = long / # subs - 1
	return lat,long
end

function micro.BattleShipGoal(boid)
		local lat = 0
	local long = 0
	local subs = World.Get("my subs")
	for _,sub in ipairs(boids) do
		if boid ~= sub then
			lat = lat + sub:GetLatitude()
			long = long + sub:GetLongitude()
		end
	end

	lat = lat / # subs - 1
	long = long / # subs - 1
	return lat,long
end

function micro.boidGoal_crap(ship)
	local targs = World.Get("Hostile Cities")
	World.popsort(targs)
	local biggest = targs[1]
	lat, long = biggest:GetLatitude(), biggest:GetLongitude()
	return lat  * .5, long * .5
end

]]--
