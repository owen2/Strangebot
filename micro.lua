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
	if GetGameTick() % 50 == 0 then
		boids = World.Get("my sea units from hell!")
		for _,boid in ipairs(boids) do
			DebugLog(boid:GetStateTimer())
			if boid:GetStateTimer() == 0 then -- only move if not doing anything useful.
				lat1, long1 = micro.boidCohesion(boid)
				lat2, long2 = micro.boidSpacing(boid)
				lat3, long3 = micro.boidGoal(boid)

				lat = boid:GetLatitude() + lat1 + lat2 + lat3
				long = boid:GetLongitude() + long1 + long2 + long3

				boid:SetMovementTarget(lat, long)
			end
		end
	end
end

function micro.boidCohesion(boid)
	local lat = 0
	local long = 0
	local boids = World.Get("my other sea units from hell!")
	for _,boid_other in ipairs(boids) do
		if boid ~= boid_other then
			lat = lat + boid_other:GetLatitude()
			long = long + boid_other:GetLongitude()
		end
	end

	lat = lat / # boids - 1
	long = long / # boids - 1
	return lat / 100, long / 100 -- 100 is the rate of travel to center (1%)
end

function micro.boidSpacing(boid)

	local lat = 0
	local long = 0
	local boids = World.Get("my other sea units from hell!")
	for _,boid_other in ipairs(boids) do
		if boid  ~= boid_other then
			if GetDistance(boid:GetLatitude(), boid:GetLongitude(), boid_other:GetLatitude(), boid_other:GetLongitude()) < 3 then
				lat = lat - (boid:GetLatitude() - boid_other:GetLatitude())
				long = long - (boid:GetLongitude() - boid_other:GetLongitude())
			end
		end
	end

	return lat, long

end

function micro.boidGoal(boid)
	lat, long = World.GetNearestEnemyCoast(boid:GetLatitude(), boid:GetLongitude())
	return (lat - boid:GetLatitude()), (long - boid:GetLongitude()) -- We'll try 50%
end
