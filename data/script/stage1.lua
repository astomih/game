local tex = {}
local tiles = {}
local player = {}

-- menu
local menu = {}

function setup()
    tex = texture()
    tex:fill_color(color(1, 1, 1, 1))
    player = draw3d(tex)
    m = model()
    m:load("untitled.sim", "player")
    player.vertex_name = "player"
    player.scale = vector3(1, 1, 1)
    for i = 1, 10 do
        tiles[i] = {}
        for j = 1, 10 do
            tiles[i][j] = draw3d(tex)
            tiles[i][j].position.x = i
            tiles[i][j].position.y = j
        end
    end
    camera.up = vector3(0, 0, 1)
end
function player_update()
    speed = 3.0
    if keyboard:is_key_down(keyUP) then
        player.position = vector3(player.position.x,
                                  player.position.y + delta_time * speed,
                                  player.position.z)
    end
    if keyboard:is_key_down(keyDOWN) then
        player.position = vector3(player.position.x,
                                  player.position.y - delta_time * speed,
                                  player.position.z)
    end

    if keyboard:is_key_down(keyLEFT) then
        player.position = vector3(player.position.x - delta_time * speed,
                                  player.position.y, player.position.z)
    end
    if keyboard:is_key_down(keyRIGHT) then
        player.position = vector3(player.position.x + delta_time * speed,
                                  player.position.y, player.position.z)
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
    for i = 1, 10 do for j = 1, 10 do tiles[i][j]:draw() end end
end
function update()
    player_update()
    camera_update()
    draw()
end
-------------------------------------------------------------------------------------
