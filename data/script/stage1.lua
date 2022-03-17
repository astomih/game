local tex = {}
local player = {}
local map = {}
local map_draw3ds = {}
local map_size_x = 10
local map_size_y = 10

local input_vector = {}

-- menu
local menu = {}

function setup()
    tex = texture()
    tex:fill_color(color(1, 1, 1, 1))
    player = draw3d(tex)
    m = model()
    m:load("untitled.sim", "player")
    player.vertex_name = "player"
    player.scale = vector3(0.7, 0.7, 0.7)

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
    for i = 1, map_size_y do
        map_draw3ds[i] = {}
        for j = 1, map_size_x do
            map_draw3ds[i][j] = draw3d(tex)
            map_draw3ds[i][j].position.x = i
            map_draw3ds[i][j].position.y = j
            if map[i][j] == 1 then
                map_draw3ds[i][j].vertex_name = "BOX"
                map_draw3ds[i][j].position.z = 0.5

            end
        end
    end
    camera.up = vector3(0, 0, 1)
end
function calc_input_vector()
    input_vector = vector3(0, 0, 0)
    if keyboard:is_key_down(keyUP) then
        input_vector.y = input_vector.y + 1.0;
    end
    if keyboard:is_key_down(keyDOWN) then
        input_vector.y = input_vector.y - 1.0;
    end

    if keyboard:is_key_down(keyLEFT) then
        input_vector.x = input_vector.x - 1.0;
    end
    if keyboard:is_key_down(keyRIGHT) then
        input_vector.x = input_vector.x + 1.0;
    end

end
function player_update()
    speed = 2.0
    calc_input_vector()

    player.position = vector3(player.position.x + input_vector.x * speed *
                                  delta_time,
                              player.position.y + input_vector.y * speed *
                                  delta_time, 0);

    if input_vector.x ~= 0 or input_vector.y ~= 0 then
        player.rotation = vector3(0, 0, -math.atan2(input_vector.x,
                                                    input_vector.y) *
                                      (180.0 / math.pi))
    end

end

function camera_update()
    offset = 5.0
    camera.position = vector3(player.position.x, player.position.y - offset,
                              player.position.z + offset)
    camera.target = vector3(player.position.x, player.position.y + offset,
                            player.position.z)
    camera:update()
end
function draw()
    player:draw()
    for y = 1, map_size_y do
        for x = 1, map_size_x do map_draw3ds[y][x]:draw() end
    end
end
function update()
    player_update()
    camera_update()
    draw()
end
-------------------------------------------------------------------------------------

