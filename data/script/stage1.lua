collision_space = {}
brown = {}
fps_mode = true

local player = require "player"
local enemy = require "enemy"
local enemies = {}
local enemy_max_num = 10
local dungeon_generator = require "dungeon_generator/dungeon_generator"
local world = require "world"
local map = {}
local map_size_x = 50
local map_size_y = 50
collision_space_division = map_size_x / 10 * 2 + 1
-- draw object
local map_draw3ds = {}
local box = {}
local sprite = {}
local menu = {}
local stair = {}
-- assets
local tree = model()
local music = music()
local iseki_wall = texture()
local bright = 0.6
local dark = 0.5
if now_stage == 1 then
    iseki_wall:fill_color(color(dark, bright, dark, 1))
else
    if now_stage == 2 then
        iseki_wall:fill_color(color(bright, dark, dark, 1))
    else
        if now_stage == 3 then
            iseki_wall:fill_color(color(dark, dark, bright, 1))
        end
    end

end
tree:load("tree.sim", "tree")
local stair_model = model()
stair_model:load("stair.sim", "stair")

local menu = require("menu")
local menu_object = menu()

function setup()
    menu_object:setup()
    print("Arrow key: move")
    print("Z: shot")
    print("SEARCH AND DESTROY!")
    print(now_stage)
    music:load("BGM01.wav")
    music:play()
    tex = texture()
    brown = texture()
    tex:fill_color(color(1, 1, 1, 1))
    brown:fill_color(color(0.843, 0.596, 0.043, 1))
    generator = dungeon_generator()
    generator:generate(map, map_size_x, map_size_y)
    box = draw3d_instanced(iseki_wall)
    box.vertex_name = "BOX"
    sprite = draw3d_instanced(iseki_wall)
    sprite.is_draw_depth = false
    stair = draw3d(tex)
    stair.vertex_name = "stair"
    for i = 1, collision_space_division + 2 do
        collision_space[i] = {}
        for j = 1, collision_space_division + 2 do
            collision_space[i][j] = {}
        end
    end
    for i = 1, enemy_max_num do table.insert(enemies, enemy()) end
    player:setup(map, map_size_x, map_size_y)
    for i, v in ipairs(enemies) do v:setup(map, map_size_x, map_size_y) end
    for y = 1, map_size_y do
        map_draw3ds[y] = {}
        for x = 1, map_size_x do
            map_draw3ds[y][x] = world()
            map_draw3ds[y][x].position.x = x * 2
            map_draw3ds[y][x].position.y = y * 2
            sprite:add(map_draw3ds[y][x].position, map_draw3ds[y][x].rotation,
                       map_draw3ds[y][x].scale)
            map_draw3ds[y][x].position.z = 3.5
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
            if map[y][x] == 2 then
                stair.position.x = x * 2
                stair.position.y = y * 2
                stair.position.z = 1000
            end
            if map[y][x] == 3 then
                player.drawer.position.x = x * 2
                player.drawer.position.y = y * 2
            end
        end
    end
    camera.up = vector3(0, 0, 1)
end

local function camera_update()
    local offset = 4.0
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
        camera.position = vector3(player.drawer.position.x +
                                      math.sin(
                                          player.drawer.rotation.z *
                                              (math.pi / 180)) * offset,
                                  player.drawer.position.y -
                                      math.cos(
                                          player.drawer.rotation.z *
                                              (math.pi / 180)) * offset,
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

    end
    camera:update()
end
local function draw()
    player:draw()
    for i, v in ipairs(enemies) do v:draw() end
    box:draw()
    sprite:draw()
    stair:draw()
    menu_object:draw()
end
function update()
    if now_stage == 4 then change_scene("boss_stage") end
    light_eye(vector3(0, 2, -10))
    light_at(vector3(0, 0, 0))
    light_width(200)
    light_height(200)
    menu_object:update()
    if not menu_object.hide then
        draw()
        return
    end
    if keyboard:key_state(keyX) == buttonPRESSED then fps_mode = not fps_mode end
    for i, v in ipairs(player.bullets) do
        for j, w in ipairs(enemies) do
            if v.aabb:intersects_aabb(w.aabb) then
                local efk = effect()
                efk:setup()
                for k = 1, efk.max_particles do
                    efk.worlds[k].position = w.drawer.position:copy()
                end
                efk:play()
                table.insert(player.efks, efk)

                table.remove(player.bullets, i)
                if v.type == bullet_type.fire then
                    w.hp = w.hp - 12
                else
                    if v.type == bullet_type.water then
                        w.hp = w.hp - 8
                    else
                        w.hp = w.hp - 10
                    end
                end
                if w.hp < 0 then table.remove(enemies, j) end
                if table.maxn(enemies) <= 0 then
                    stair.position.z = 0

                end
            end
        end
        if map[math.floor(v.drawer.position.y / 2 + 0.5)][math.floor(v.drawer
                                                                         .position
                                                                         .x / 2 +
                                                                         0.5)] ==
            1 then table.remove(player.bullets, i) end
    end
    player:update(map, map_draw3ds, map_size_x, map_size_y)
    for i, v in ipairs(enemies) do
        v:update(player, map, map_draw3ds, map_size_x, map_size_y)
        v:player_collision(player)
    end
    if map[math.floor(player.drawer.position.y / 2 + 0.5)][math.floor(
        player.drawer.position.x / 2 + 0.5)] == 2 then

        if keyboard:key_state(keySPACE) == buttonPRESSED and stair.position.z ==
            0 then
            now_stage = now_stage + 1
            change_scene("stage1")
        end
    end
    camera_update()
    draw()
end
-------------------------------------------------------------------------------------

