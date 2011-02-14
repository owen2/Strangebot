-- Written by Martin
-- martindevans@gmail.com
-- http://martindevans.appspot.com/blog
-- adapted for strangebot by Owen Johnson


require "Queue"

local allottedTime
local startTime
local taskQueue = Queue.new()

Multithreading = {}

Wait = function(forceWait)
	if (forceWait) then
		coroutine.yield()
	elseif (os.clock() - startTime >= allottedTime) then
		coroutine.yield()
	end
end

NewThread = function(f)
	taskQueue.enqueue(coroutine.create(f))
end

Resume = function(allotted)
	allottedTime = allotted or 0.0002

	while (allottedTime > 0) do
		task = taskQueue.peek()
		if (task ~= nil) then
			if (coroutine.status(task) == "dead") then
				if (taskQueue.dequeue() ~= task) then
					error("Dequeue dead task does not equal this instance!")
				end
			else
				startTime = os.clock()
				assert(coroutine.resume(task))
				allottedTime = allottedTime - (os.clock() - startTime)
			end
		else
			break
		end
	end
end
