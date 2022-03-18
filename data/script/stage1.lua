tex = {}
local player = require "player"
local map = {}
local map_draw3ds = {}
local map_size_x = 10
local map_size_y = 10
-- menu
local menu = {}

function setup()
    tex = texture()
    tex:fill_color(color(1, 1, 1, 1))
    player:setup()
    map[map_size_y] = {}
    for y = 1, map_size_y do
        map[y] = {}
        for x = 1, map_size_x do
            map[1][x] = 1
            map[map_size_y][x] = 1
            map[y][1] = 1
            map[y][map_size_x] = 1
        end
    end
    for y = 1, map_size_y do
        map_draw3ds[y] = {}
        for x = 1, map_size_x do
            map_draw3ds[y][x] = draw3d(tex)
            map_draw3ds[y][x].position.x = y
            map_draw3ds[y][x].position.y = x
            if map[y][x] == 1 then
                map_draw3ds[y][x].vertex_name = "BOX"
                map_draw3ds[y][x].position.z = 0.5
            end
        end
    end
    camera.up = vector3(0, 0, 1)
end

local function camera_update()
    offset = 5.0
    camera.position = vector3(player.drawer.position.x,
                              player.drawer.position.y - offset,
                              player.drawer.position.z + offset)
    camera.target = vector3(player.drawer.position.x,
                            player.drawer.position.y + offset,
                            player.drawer.position.z)
    camera:update()
end
local function draw()
    player:draw()
    for y = 1, map_size_y do
        for x = 1, map_size_x do map_draw3ds[y][x]:draw() end
    end
end
function update()
    player:update(map, map_draw3ds, map_size_x, map_size_y)
    camera_update()
    draw()
end
-------------------------------------------------------------------------------------

