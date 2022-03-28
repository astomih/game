tex = {}
collision_space = {}
collision_space_division = 12
local player = require "player"
local enemy = require "enemy"
local spider = enemy()
local dungeon_generator = require "dungeon_generator"
local world = require "world"
local map = {}
local map_size_x = 40
local map_size_y = 40
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
    for i = 1, collision_space_division + 2 do
        collision_space[i] = {}
        for j = 1, collision_space_division + 2 do
            collision_space[i][j] = {}
        end
    end
    player:setup(map, map_size_x, map_size_y)
    spider:setup(map, map_size_x, map_size_y)
    for y = 1, map_size_y do
        map_draw3ds[y] = {}
        for x = 1, map_size_x do
            map_draw3ds[y][x] = world()
            map_draw3ds[y][x].position.x = x * 2
            map_draw3ds[y][x].position.y = y * 2
            if map[y][x] == 1 then
                map_draw3ds[y][x].position.z = 0.5
                map_draw3ds[y][x].aabb = aabb()
                map_draw3ds[y][x].aabb.max =
                    map_draw3ds[y][x].position:add(map_draw3ds[y][x].scale)
                map_draw3ds[y][x].aabb.min =
                    map_draw3ds[y][x].position:sub(map_draw3ds[y][x].scale)

                box:add(map_draw3ds[y][x].position, map_draw3ds[y][x].rotation,
                        map_draw3ds[y][x].scale)
                local collision_space_x = math.floor(x /
                                                         collision_space_division)
                local collision_space_y = math.floor(y /
                                                         collision_space_division)
                table.insert(
                    collision_space[collision_space_y + 2][collision_space_x + 2],
                    map_draw3ds[y][x])

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
    spider:draw()
    box:draw()
    sprite:draw()
end
function update()
    if player.aabb:intersects_aabb(spider.aabb) then
        player.hp = player.hp - 10
        player.font:render_text(player.hp_font_texture, "hp:" .. player.hp,
                                color(1, 0, 0, 1))
        player.hp_drawer.scale = player.hp_font_texture:size()
        player.hp_drawer.position.x = -300 + player.hp_drawer.scale.x / 4
        player.hp_drawer.position.y = -300
    end
    player:update(map, map_draw3ds, map_size_x, map_size_y)
    spider:update(player, map, map_draw3ds, map_size_x, map_size_y)
    camera_update()
    draw()
end
-------------------------------------------------------------------------------------

