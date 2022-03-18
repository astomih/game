local input_vector = {}
local function calc_input_vector()
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
local function is_collisiton(player, before_pos, map, map_draw3ds, map_size_x,
                             map_size_y)
    is_collied = false
    player_aabb = aabb()
    player_aabb.max = vector3(
                          player.drawer.position.x + player.drawer.scale.x *
                              player.model.aabb.max.x,
                          player.drawer.position.y + player.drawer.scale.y *
                              player.model.aabb.max.y, player.drawer.position.z +
                              player.drawer.scale.z * player.model.aabb.max.z);
    player_aabb.min = vector3(
                          player.drawer.position.x + player.drawer.scale.x *
                              player.model.aabb.min.x,
                          player.drawer.position.y + player.drawer.scale.y *
                              player.model.aabb.min.y, player.drawer.position.z +
                              player.drawer.scale.z * player.model.aabb.min.z);
    box_aabb = aabb()
    for i = 1, map_size_x do
        for j = 1, map_size_y do
            if map[i][j] == 1 then
                box_aabb.max = vector3(map_draw3ds[i][j].position.x +
                                           map_draw3ds[i][j].scale.x,
                                       map_draw3ds[i][j].position.y +
                                           map_draw3ds[i][j].scale.y,
                                       map_draw3ds[i][j].position.z +
                                           map_draw3ds[i][j].scale.z);
                box_aabb.min = vector3(map_draw3ds[i][j].position.x -
                                           map_draw3ds[i][j].scale.x,
                                       map_draw3ds[i][j].position.y -
                                           map_draw3ds[i][j].scale.y,
                                       map_draw3ds[i][j].position.z -
                                           map_draw3ds[i][j].scale.z);
                if player_aabb:intersects_aabb(box_aabb) then
                    player.drawer.position = before_pos
                    is_collied = true
                end
            end
        end

    end
    return is_collied
end
local player = {
    drawer = {},
    model = {},
    setup = function(self)
        self.model = model()
        self.model:load("untitled.sim", "player")
        self.drawer = draw3d(tex)
        self.drawer.vertex_name = "player"
        self.drawer.scale = vector3(0.7, 0.7, 0.7)
        self.drawer.position = vector3(-2, 0, 0)
    end,
    update = function(self, map, map_draw3ds, map_size_x, map_size_y)
        speed = 2.0
        calc_input_vector()
        before_pos = vector3(self.drawer.position.x, self.drawer.position.y,
                             self.drawer.position.z)
        self.drawer.position = vector3(
                                   self.drawer.position.x + input_vector.x *
                                       speed * delta_time, self.drawer.position
                                       .y + input_vector.y * speed * delta_time,
                                   0);
        is_collisiton(self, before_pos, map, map_draw3ds, map_size_x, map_size_y)

        if input_vector.x ~= 0 or input_vector.y ~= 0 then
            self.drawer.rotation = vector3(0, 0, -math.atan2(input_vector.x,
                                                             input_vector.y) *
                                               (180.0 / math.pi))
        end
    end,
    draw = function(self) self.drawer:draw() end
}

return player
