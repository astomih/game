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
local function is_collision(player, before_pos, map, map_draw3ds, map_size_x,
                            map_size_y)
    is_collied = false
    player_aabb = aabb()
    player_aabb.max = player.drawer.position:add(
                          player.drawer.scale:mul(player.model.aabb.max))
    player_aabb.min = player.drawer.position:add(
                          player.drawer.scale:mul(player.model.aabb.min))
    box_aabb = aabb()
    for i = 1, map_size_x do
        for j = 1, map_size_y do
            if map[i][j] == 1 then
                box_aabb.max = map_draw3ds[i][j].position:add(map_draw3ds[i][j]
                                                                  .scale)
                box_aabb.min = map_draw3ds[i][j].position:sub(map_draw3ds[i][j]
                                                                  .scale)
                if player_aabb:intersects_aabb(box_aabb) then
                    player.drawer.position = before_pos
                    is_collied = true
                end
            end
        end

    end
    return is_collied
end
local speed = 2.0
local function xor(a, b) return (a and not b) or (not a and b) end

local r1 = {}
local r2 = {}
local function decide_pos(map, map_size_x, map_size_y)
    r1 = random:get_int_range(1, map_size_x)
    r2 = random:get_int_range(1, map_size_y)
    return map[r1][r2] == 1
end

local player = {
    drawer = {},
    model = {},
    setup = function(self, map, map_size_x, map_size_y)
        self.model = model()
        self.model:load("untitled.sim", "player")
        self.drawer = draw3d(tex)
        self.drawer.vertex_name = "player"
        r1 = 0
        r2 = 0
        while decide_pos(map, map_size_x, map_size_y) == true do end
        self.drawer.position = vector3(r1 * 2, r2 * 2, 0)
    end,
    update = function(self, map, map_draw3ds, map_size_x, map_size_y)
        calc_input_vector()
        if input_vector.x == 0 and input_vector.y == 0 then return 0 end
        scale = self.drawer.scale.x * 2.0
        before_pos = vector3(self.drawer.position.x, self.drawer.position.y,
                             self.drawer.position.z)
        if input_vector.x ~= 0 and input_vector.y ~= 0 then
            local x = false
            local y = false
            self.drawer.position = self.drawer.position:add(vector3(
                                                                input_vector.x *
                                                                    scale * 2.0 *
                                                                    delta_time /
                                                                    math.sqrt(
                                                                        2.0), 0,
                                                                0))
            x = is_collision(self, before_pos, map, map_draw3ds, map_size_x,
                             map_size_y)
            self.drawer.position = self.drawer.position:add(vector3(0,
                                                                    input_vector.y *
                                                                        scale *
                                                                        2.0 *
                                                                        delta_time /
                                                                        math.sqrt(
                                                                            2.0),
                                                                    0))
            y = is_collision(self, self.drawer.position:copy(), map,
                             map_draw3ds, map_size_x, map_size_y)
            if xor(x, y) then
                if x then
                    self.drawer.position = before_pos
                    self.drawer.position =
                        self.drawer.position:add(vector3(0, input_vector.y *
                                                             scale * 2.0 *
                                                             delta_time, 0))
                    y = is_collision(self, self.drawer.position:copy(), map,
                                     map_draw3ds, map_size_x, map_size_y)
                    if y then
                        self.drawer.position = before_pos
                    end
                end
                if y then
                    self.drawer.position = before_pos
                    self.drawer.position =
                        self.drawer.position:add(vector3(input_vector.x * scale *
                                                             2.0 * delta_time,
                                                         0, 0))
                    x = is_collision(self, self.drawer.position:copy(), map,
                                     map_draw3ds, map_size_x, map_size_y)
                    if x then
                        self.drawer.position = before_pos
                    end
                end

            else
                if x and y then self.drawer.position = before_pos end
            end
        else
            self.drawer.position = self.drawer.position:add(vector3(
                                                                input_vector.x *
                                                                    scale * 2.0 *
                                                                    delta_time,
                                                                0, 0))
            is_collision(self, before_pos, map, map_draw3ds, map_size_x,
                         map_size_y)
            before_pos = self.drawer.position:copy()
            self.drawer.position = self.drawer.position:add(vector3(0,
                                                                    input_vector.y *
                                                                        scale *
                                                                        2.0 *
                                                                        delta_time,
                                                                    0))
            is_collision(self, before_pos, map, map_draw3ds, map_size_x,
                         map_size_y)
        end
        if input_vector.x ~= 0 or input_vector.y ~= 0 then
            self.drawer.rotation = vector3(0, 0, -math.atan2(input_vector.x,
                                                             input_vector.y) *
                                               (180.0 / math.pi))
        end
    end,
    draw = function(self) self.drawer:draw() end
}

return player
