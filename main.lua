-----------------------------------------------------
-- Dr. Strangebot									-
-- A lua based agent for Defcon						-
-- by Owen Johnson									-
-- owen@owenjohnson.info							'--------------------
-- latest version at http://github.com/owen2/Strangebot/zipball/master	-
-- This is the skeleton that glues the project up.	,--------------------
-----------------------------------------------------

---------------------------------
--	Enter all of your includes	-
---------------------------------

package.path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require "Whiteboard" -- A library for easier Whiteboard drawing
require "world" -- A perception model for the world to get info from
require "strangelove" -- The higher level strategy code for the AI
require "Multithreading" -- A coroutine queuing library
require "micro" -- Micro level/event handling


---------------------------------
-- Some Global Variables here.	-
---------------------------------
DefconLevel = 0 -- the stage of the game
j = 0 -- a global index for next target in target list
observable = {} -- A table of all observable objects in the world.
placed = 0 -- Whether or not all units have been placed. (keeps spawning routine from running

--map = Graph.readgraph("AI\strangebot\world.graph") -- Created a graph of connected territories and oceans

-- Required by luabot binding. Fires when the agent is selected.
function OnInit()
	SendChat("/name [BOT]Strangebot")
	SendChat("Hi, I'm Owen's bot! See owenjohnson.info/cat/strangebot for more info.")
end

-- Also required. 100ms execution time limit. Use it well.
function OnTick()
	GetAllUnitData(observable) -- update the state of the world
	---------------------------------------------------------
	-- Place for any first tick of defcon __ strategies.	-
	---------------------------------------------------------
	if (DefconLevel ~= GetDefconLevel()) then
		DefconLevel = GetDefconLevel()
		if     (DefconLevel == 5) then RequestGameSpeed(20)
		elseif (DefconLevel == 4) then
		elseif (DefconLevel == 3) then
		elseif (DefconLevel == 2) then
		elseif (DefconLevel == 1) then
		end
	else
		-------------------------------------
		-- Stuff that happens every tick.	-
		-------------------------------------
		if (DefconLevel == 5) then	strangelove.buildHiveByPopulationCenter() end
		if (DefconLevel == 4) then end
		if (DefconLevel == 3) then end
		if (DefconLevel == 2) then end
		if (DefconLevel == 1) then  strangelove.nukepanic() end
	end
	Resume(.05)
end

-- Required function. fires whenever an event happens in the game.
function OnEvent(eventType, sourceID, targetID, unitType, longitude, latitude)
	if (eventType == "CeasedFire") then
		--A team ceased fire to another team.
	elseif (eventType == "Destroyed") then
		--An object has been destroyed.
	elseif (eventType == "Hit") then
		--An object has been hit by a gunshot (ie. from a battleship, fighter etc).
		--local tracker = Instance.ShotTrackers[sourceID:GetTeamID()]
		--tracker.Hit(sourceID, targetID)
	elseif (eventType == "NewVote") then
		--A new vote has been started
		--SendVote(targetID, VoteYes)
		SendVote(sourceID, VoteYes)
	elseif (eventType == "NukeLaunchSilo") then
		--A missile has been launched from a silo at given coordinates.
	elseif (eventType == "NukeLaunchSub") then
		--A missile has been launched from a sub at given coordinates.
	elseif (eventType == "PingCarrier") then
		--A sonar ping from a carrier has been detected (gives object id).
	elseif (eventType == "PingDetection") then
		--An object has been detected by a ping event (reveals type and coordinates).
	elseif (eventType == "PingSub") then
		--A sonar ping from a submarine has been detected (only reveals coordinates).
	elseif (eventType == "SharedRadar") then
		--A team shared its radar with another team.
	elseif (eventType == "TeamRetractedVote") then
		--?
	elseif (eventType == "TeamVoted") then
		--?
	elseif (eventType == "UnceasedFire") then
		--A cease fire agreement has been ended.
	elseif (eventType == "UnsharedRadar") then
		--A team stopped sharing its radar with another team.
	elseif (eventType == "VoteFinishedNo") then
			DebugLog("AllianceVoteFailed.")
			strangelove.makeFriends()
		--A vote finished with no result/change.
	elseif (eventType == "VoteFinishedYes") then
		--A vote finished, and its contents were accepted.
	end
end

-- Documentation says it's required, but it doesn't seem to get called. hmm...
function OnShutdown()
	SendChat("Bye!")
	SendChat("/name [BOT]n00b")
end
