-- Tests for bfs.lua
local BFS = require 'bfs'

local total, pass = 0, 0

local function dec(str, len)
    return #str < len and str .. (('.'):rep(len - #str)) or str:sub(1, len)
end

local function same(t, p, comp)
    for k, v in ipairs(t) do if not comp(v, p[k]) then return false end end
    return true
end

local function run(message, f)
    total = total + 1
    local ok, err = pcall(f)
    if ok then pass = pass + 1 end
    local status = ok and 'PASSED' or 'FAILED'
    print(('%02d. %68s: %s'):format(total, dec(message, 68), status))
end

run('Testing linear graph', function()
    local comp = function(a, b) return a.value == b end
    local ln_handler = require 'handlers.linear_handler'
    ln_handler.init(-2, 5)
    local bfs = BFS(ln_handler)
    local start, goal = ln_handler.getNode(0), ln_handler.getNode(5)
    assert(same(bfs:findPath(start, goal), {0, 1, 2, 3, 4, 5}, comp))

    start, goal = ln_handler.getNode(-2), ln_handler.getNode(2)
    assert(same(bfs:findPath(start, goal), {-2, -1, 0, 1, 2}, comp))
end)

run('Testing grid graph', function()
    local comp = function(a, b) return a.x == b[1] and a.y == b[2] end
    local gm_handler = require 'handlers.gridmap_handler'
    local bfs = BFS(gm_handler)
    local map = {{0, 0, 0, 0, 0}, {0, 1, 1, 1, 1}, {0, 0, 0, 0, 0}}
    gm_handler.init(map)

    gm_handler.diagonal = false
    local start, goal = gm_handler.getNode(1, 1), gm_handler.getNode(5, 3)
    assert(same(bfs:findPath(start, goal),
                {{1, 1}, {1, 2}, {1, 3}, {2, 3}, {3, 3}, {4, 3}, {5, 3}}, comp))

    gm_handler.diagonal = true
    assert(same(bfs:findPath(start, goal),
                {{1, 1}, {1, 2}, {2, 3}, {3, 3}, {4, 3}, {5, 3}}, comp))
end)

run('Testing point graph', function()
    local comp = function(a, b) return a.x == b[1] and a.y == b[2] end
    local pg_handler = require 'handlers.point_graph_handler'
    local bfs = BFS(pg_handler)

    pg_handler.addNode('a')
    pg_handler.addNode('b')
    pg_handler.addNode('c')
    pg_handler.addNode('d')
    pg_handler.addEdge('a', 'b')
    pg_handler.addEdge('a', 'c')
    pg_handler.addEdge('b', 'd')

    local comp = function(a, b) return a.name == b end
    local start, goal = pg_handler.getNode('a'), pg_handler.getNode('d')
    assert(same(bfs:findPath(start, goal), {'a', 'b', 'd'}, comp))
end)

print(('-'):rep(80))
print(('Total : %02d: Pass: %02d - Failed : %02d - Success: %.2f %%'):format(
          total, pass, total - pass, (pass * 100 / total)))
