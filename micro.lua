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
		for _, base in ipairs(bases) do
			base:SetState(0)
			for _, spots in ipairs(spot) do
				base:SetActionTarget(spot)
			end
		end
	end
end
