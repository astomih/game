collision_space = {}
brown = {}
fps_mode = true
local player = require "player"
local enemy = require "enemy"
local enemies = {}
local enemy_max_num = 0
local dungeon_generator = require "dungeon_generator/dungeon_generator"
local get_forward = require "get_forward"
local world = require "world"
local text_window = require "text_window"
local map = {}
local map_size_x = 12
local map_size_y = 13
collision_space_division = 5 -- map_size_x / 10 * 2 + 1
-- draw object
local map_draw3ds = {}
local fire_god_drawer = {}
local water_god_drawer = {}
local fire_god_aabb = aabb()
local water_god_aabb = aabb()
local box = {}
local iseki = {}
local sprite = {}
local menu = {}
-- assets
local fire_god_model = model()
local water_god_model = model()
fire_god_model:load("fire_god.sim", "fire_god")
water_god_model:load("water_god.sim", "water_god")
local tree = model()
local music = music()
tree:load("tree.sim", "tree")

local door = model()
local door_drawer = {}
door:load("door.sim", "door")

local text_window_object = text_window()
local god_same_column = false

function setup()
    print("Arrow key: move")
    print("Z: shot")
    print("SEARCH AND DESTROY!")
    music:load("PSYCHO.ogg")
    music:play()
    tex = texture()
    brown = texture()
    tex:fill_color(color(1, 1, 1, 1))
    brown:fill_color(color(0.843, 0.596, 0.043, 1))
    fire_god_drawer = draw3d(tex)
    fire_god_drawer.vertex_name = "fire_god"
    fire_god_drawer.scale = vector3(0.5, 0.5, 0.5)
    fire_god_drawer.position = vector3(3 * 2, 3 * 2, 1)

    water_god_drawer = draw3d(tex)
    water_god_drawer.vertex_name = "water_god"
    water_god_drawer.scale = vector3(0.5, 0.5, 0.5)
    water_god_drawer.position = vector3(10 * 2, 10 * 2, 1)
    water_god_drawer.rotation = vector3(0, 0, 180)
    map = {
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 1, 1, 1, 10, 0, 10, 1, 1, 1, 1, 1},
        {10, 10, 10, 10, 10, 0, 10, 10, 10, 10, 10, 10}
    }
    box = draw3d_instanced(tex)
    box.vertex_name = "tree"

    iseki = draw3d_instanced(tex)
    iseki.vertex_name = "BOX"
    door_drawer = draw3d(tex)
    door_drawer.position = vector3(6 * 2, 12 * 2 - 0.5, 0)
    door_drawer.vertex_name = "door"
    door_drawer.rotation = vector3(0, 0, 90)
    sprite = draw3d_instanced(brown)
    for i = 1, collision_space_division + 2 do
        collision_space[i] = {}
        for j = 1, collision_space_division + 2 do
            collision_space[i][j] = {}
        end
    end
    for i = 1, enemy_max_num do table.insert(enemies, enemy()) end
    player:setup(map, map_size_x, map_size_y - 1)
    for i, v in ipairs(enemies) do v:setup(map, map_size_x, map_size_y) end
    for y = 1, map_size_y do
        map_draw3ds[y] = {}
        for x = 1, map_size_x do
            map_draw3ds[y][x] = world()
            map_draw3ds[y][x].position.x = x * 2
            map_draw3ds[y][x].position.y = y * 2
            sprite:add(map_draw3ds[y][x].position, map_draw3ds[y][x].rotation,
                       map_draw3ds[y][x].scale)
            if map[y][x] == 1 then
                map_draw3ds[y][x].position.z = 0.5
                map_draw3ds[y][x].aabb = aabb()
                map_draw3ds[y][x].aabb.max =
                    map_draw3ds[y][x].position:add(map_draw3ds[y][x].scale)
                map_draw3ds[y][x].aabb.min =
                    map_draw3ds[y][x].position:sub(map_draw3ds[y][x].scale)
                map_draw3ds[y][x].scale = vector3(1, 1, 3)

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
            if map[y][x] == 10 then
                map_draw3ds[y][x].position.z = 0.5
                map_draw3ds[y][x].aabb = aabb()
                map_draw3ds[y][x].aabb.max =
                    map_draw3ds[y][x].position:add(map_draw3ds[y][x].scale)
                map_draw3ds[y][x].aabb.min =
                    map_draw3ds[y][x].position:sub(map_draw3ds[y][x].scale)
                map_draw3ds[y][x].scale = vector3(1, 1, 5)

                iseki:add(map_draw3ds[y][x].position,
                          map_draw3ds[y][x].rotation, map_draw3ds[y][x].scale)
                local collision_space_x = math.floor(x /
                                                         collision_space_division)
                local collision_space_y = math.floor(y /
                                                         collision_space_division)
                table.insert(
                    collision_space[collision_space_y + 2][collision_space_x + 2],
                    map_draw3ds[y][x])

            end
        end
    end
    camera.up = vector3(0, 0, 1)
    text_window_object:setup()
    text_window_object.texts = {"扉が開いたようだ。"}
end

local function camera_update()
    local offset = 5.0
    if fps_mode then
        camera.position = vector3(player.drawer.position.x,
                                  player.drawer.position.y + 0.5,
                                  player.drawer.position.z + 2)
        camera.target = vector3(player.drawer.position.x +
                                    -math.sin(
                                        player.drawer.rotation.z *
                                            (math.pi / 180)) * 90,
                                player.drawer.position.y +
                                    math.cos(
                                        player.drawer.rotation.z *
                                            (math.pi / 180)) * 90,
                                player.drawer.position.z)
    else
        camera.position = vector3(player.drawer.position.x,
                                  player.drawer.position.y - offset,
                                  player.drawer.position.z + offset)
        camera.target = vector3(player.drawer.position.x,
                                player.drawer.position.y + offset,
                                player.drawer.position.z)

    end
    camera:update()
end
local function draw()
    player:draw()
    for i, v in ipairs(enemies) do v:draw() end
    box:draw()
    sprite:draw()
    iseki:draw()
    fire_god_drawer:draw()
    water_god_drawer:draw()
    if god_same_column then
        -- body
        text_window_object:draw()
    end
    door_drawer:draw()
end
function update()
    if god_same_column then
        text_window_object:update()
        door_drawer.rotation.z = 180
        door_drawer.position.x = 6 * 2 + 1
        if text_window_object.is_draw_all_texts then
            change_scene("stage1")
        end
    end
    fire_god_aabb.max = fire_god_drawer.position:add(
                            fire_god_drawer.scale:mul(fire_god_model.aabb.max))
    fire_god_aabb.min = fire_god_drawer.position:add(
                            fire_god_drawer.scale:mul(fire_god_model.aabb.min))
    water_god_aabb.max = water_god_drawer.position:add(
                             water_god_drawer.scale:mul(
                                 water_god_model.aabb.max))
    water_god_aabb.min = water_god_drawer.position:add(
                             water_god_drawer.scale:mul(
                                 water_god_model.aabb.min))

    if keyboard:key_state(keyX) == buttonPRESSED then fps_mode = not fps_mode end
    for i, v in ipairs(player.bullets) do
        for j, w in ipairs(enemies) do
            if v.aabb:intersects_aabb(w.aabb) then
                table.remove(player.bullets, i)
                w.hp = w.hp - 10
                if w.hp < 0 then table.remove(enemies, j) end
                if table.maxn(enemies) <= 0 then
                    change_scene("win_scene")
                end
            end
        end
        if map[math.floor(v.drawer.position.y / 2 + 0.5)][math.floor(v.drawer
                                                                         .position
                                                                         .x / 2 +
                                                                         0.5)] ==
            1 then table.remove(player.bullets, i) end
    end
    local before_pos = player.drawer.position:copy()
    player:update(map, map_draw3ds, map_size_x, map_size_y)
    for i, v in ipairs(enemies) do
        v:update(player, map, map_draw3ds, map_size_x, map_size_y)
        v:player_collision(player)
    end
    if fire_god_aabb:intersects_aabb(player.aabb) then
        player.drawer.position = before_pos
        if keyboard:is_key_down(keySPACE) then
            local v = get_forward(player.drawer)
            fire_god_drawer.position = vector3(
                                           fire_god_drawer.position.x + v.x *
                                               delta_time * 2,
                                           fire_god_drawer.position.y + v.y *
                                               delta_time * 2, 1)
        end
    end
    if water_god_aabb:intersects_aabb(player.aabb) then
        player.drawer.position = before_pos
        if keyboard:is_key_down(keySPACE) then
            local v = get_forward(player.drawer)
            water_god_drawer.position = vector3(
                                            water_god_drawer.position.x + v.x *
                                                delta_time * 2,
                                            water_god_drawer.position.y + v.y *
                                                delta_time * 2, 1)
        end
    end

    if math.floor(fire_god_drawer.position.y) ==
        math.floor(water_god_drawer.position.y) then god_same_column = true end
    camera_update()
    draw()
end
-------------------------------------------------------------------------------------

