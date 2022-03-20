tex = {}
local player = require "player"
local dungeon_generator = require "dungeon_generator"
local world = require "world"
local map = {}
local map_size_x = 20
local map_size_y = 20
-- draw object
local map_draw3ds = {}
local box = {}
local sprite = {}
-- menu
local menu = {}

function setup()
    tex = texture()
    tex:fill_color(color(1, 1, 1, 1))
    map[map_size_y] = {}
    generator = dungeon_generator()
    generator:generate(map, map_size_x, map_size_y)
    box = draw3d_instanced(tex)
    box.vertex_name = "BOX"
    sprite = draw3d_instanced(tex)
    if map[y][x] == nil then map[y][x] = 0 end
    player:setup(map, map_size_x, map_size_y)
    for y = 1, map_size_y do
        map_draw3ds[y] = {}
        for x = 1, map_size_x do
            map_draw3ds[y][x] = world()
            map_draw3ds[y][x].position.x = y * 2
            map_draw3ds[y][x].position.y = x * 2
            if map[y][x] == 1 then
                map_draw3ds[y][x].position.z = 0.5
                box:add(map_draw3ds[y][x].position, map_draw3ds[y][x].rotation,
                        map_draw3ds[y][x].scale)
            end
            if map[y][x] == 0 then
                sprite:add(map_draw3ds[y][x].position,
                           map_draw3ds[y][x].rotation, map_draw3ds[y][x].scale)
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
    box:draw()
    sprite:draw()
end
function update()
    player:update(map, map_draw3ds, map_size_x, map_size_y)
    camera_update()
    draw()
end
-------------------------------------------------------------------------------------

