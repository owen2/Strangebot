--------------------------------------------------------,
-- Graph Library Module									|
-- Owen Johnson											|
-- Heavily based on the examples in Programming in Lua	|
-- http://www.lua.org/pil/								|
-- http://owenjohnson.info								|
--------------------------------------------------------'

Graph = {}

function Graph.readgraph(filename)
	io.input(filename)
	local graph={}
	for line in io.lines() do
		local a, b = string.match(line, "(%S+)%s+(%S+)") -- we are reading from a text file, splitting on the space and creating an arc between the two named nodes.
		Graph.addEdge(graph, a,b, true)
	end
	return graph
end

function Graph.getNodeByName(graph, name)
	if not graph[name] then graph[name] = {name = name, adj = {}} end -- if it doesn't exist, create it
	return graph[name]
end

function Graph.addEdge(graph,a,b, bidirectional) -- Add an edge by node names. If either or both nodes don't exist, they will be created.
	near = Graph.getNodeByName(graph, a) -- gets the node with that name, creates one if it doesn't exist.
	far = Graph.getNodeByName(graph, b)
	near.adj[far] = true
	if bidirectional then far.adj[near] = true end
end

function Graph.findPath(curr,to, path, visited)
	path = path or {}
	visited = visited or {}
	if visited[curr] then
		return nil
	end
	visited[curr] = true
	path[#path+1] = curr
	if curr == to then
		return path
	end
	for node in pairs(curr.adj) do
		local p = Graph.findPath(node, to , path, visited)
		if p then return p end
	end
	path[#path] = nil
end

function Graph.printpath(path)
	for i=1, #path do
		print(path[i].name)
	end
end

world = Graph.readgraph("world.graph")
na = Graph.getNodeByName(world, "NorthAmerica")
ru = Graph.getNodeByName(world, "Russia")
path = Graph.findPath(na, ru)
Graph.printpath(path)
