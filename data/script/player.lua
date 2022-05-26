local bullet = require "bullet"
local calc_input_vector = require "calc_input_vector"
local is_collision = require "is_collision"
local input_vector = {}
local speed = 2.0
local function xor(a, b) return (a and not b) or (not a and b) end

local r1 = {}
local r2 = {}
local function decide_pos(map, map_size_x, map_size_y)
    r1 = math.random(1, map_size_x)
    r2 = math.random(1, map_size_y)
    return map[r2][r1] == 1
end
local function get_forward_z(rotation)

    return vector2(-math.sin(math.rad(rotation.z)),
                   math.cos(math.rad(-rotation.z)))
end

local player = {
    drawer = {},
    model = {},
    bullets = {},
    hp = {},
    hp_drawer = {},
    hp_font = {},
    hp_font_texture = {},
    aabb = {},
    bullet_time = {},
    bullet_timer = {},
    setup = function(self, map, map_size_x, map_size_y)
        self.model = model()
        self.model:load("untitled.sim", "player")
        self.drawer = draw3d(tex)
        self.drawer.vertex_name = "player"
        self.aabb = aabb()
        self.bullet_time = 0.1
        self.bullet_timer = 0.0
        self.hp = 100

        self.hp_font_texture = texture()
        self.hp_drawer = draw2d(self.hp_font_texture)
        self.font = font()
        self.font:load(DEFAULT_FONT, 64)
        self.font:render_text(self.hp_font_texture, "HP:" .. self.hp,
                              color(1, 1, 1, 1))
        self.hp_drawer.scale = self.hp_font_texture:size()
        r1 = 0
        r2 = 0
        while decide_pos(map, map_size_x, map_size_y) == true do end
        self.drawer.position = vector3(r1 * 2, r2 * 2, 0)
        self.hp_drawer.position.x = -1280 / 2 + 50 + self.hp_drawer.scale.x / 4
        self.hp_drawer.position.y = -300
    end,
    update = function(self, map, map_draw3ds, map_size_x, map_size_y)
        self.aabb.max = self.drawer.position:add(
                            self.drawer.scale:mul(self.model.aabb.max))
        self.aabb.min = self.drawer.position:add(
                            self.drawer.scale:mul(self.model.aabb.min))
        if self.hp <= 0 then change_scene("gameover") end
        input_vector = calc_input_vector()
        if keyboard:is_key_down(keyLSHIFT) then
            speed = 4.0
        else
            speed = 2.0
        end

        -- bullet 
        self.bullet_timer = self.bullet_timer + delta_time
        if keyboard:is_key_down(keyZ) and self.bullet_timer > self.bullet_time then
            local b = bullet(map_draw3ds)
            b:setup(self)
            table.insert(self.bullets, b)
            self.bullet_timer = 0.0
        end
        for i, v in ipairs(self.bullets) do
            v:update()
            if v.current_time > v.life_time then
                table.remove(self.bullets, i)
            end
        end
        if fps_mode then
            scale = self.drawer.scale.x * 2.0
            before_pos = vector3(self.drawer.position.x, self.drawer.position.y,
                                 self.drawer.position.z)
            if input_vector.y ~= 0 then
                local rot = get_forward_z(self.drawer.rotation)
                self.drawer.position = self.drawer.position:add(vector3(
                                                                    input_vector.y *
                                                                        rot.x *
                                                                        scale *
                                                                        speed *
                                                                        delta_time,
                                                                    0, 0))
                if is_collision(self, map, map_draw3ds, map_size_x, map_size_y) then
                    self.drawer.position = before_pos
                end
                before_pos = self.drawer.position:copy()
                self.drawer.position = self.drawer.position:add(vector3(0,
                                                                        input_vector.y *
                                                                            rot.y *
                                                                            scale *
                                                                            speed *
                                                                            delta_time,
                                                                        0))
                if is_collision(self, map, map_draw3ds, map_size_x, map_size_y) then
                    self.drawer.position = before_pos
                end
            end
            if input_vector.x ~= 0 or input_vector.y ~= 0 then
                self.drawer.rotation.z =
                    self.drawer.rotation.z + math.deg(math.sin(-input_vector.x)) *
                        delta_time * 2
            end
        else
            if input_vector.x == 0 and input_vector.y == 0 then
                return 0
            end
            scale = self.drawer.scale.x * 2.0
            before_pos = vector3(self.drawer.position.x, self.drawer.position.y,
                                 self.drawer.position.z)
            if input_vector.x ~= 0 and input_vector.y ~= 0 then
                local x = false
                local y = false
                self.drawer.position = self.drawer.position:add(vector3(
                                                                    input_vector.x *
                                                                        scale *
                                                                        speed *
                                                                        delta_time /
                                                                        math.sqrt(
                                                                            2.0),
                                                                    0, 0))
                x = is_collision(self, map, map_draw3ds, map_size_x, map_size_y)
                if x then self.drawer.position = before_pos end
                self.drawer.position = self.drawer.position:add(vector3(0,
                                                                        input_vector.y *
                                                                            scale *
                                                                            speed *
                                                                            delta_time /
                                                                            math.sqrt(
                                                                                2.0),
                                                                        0))
                y = is_collision(self, map, map_draw3ds, map_size_x, map_size_y)
                if xor(x, y) then
                    if x then
                        self.drawer.position = before_pos
                        self.drawer.position =
                            self.drawer.position:add(vector3(0,
                                                             input_vector.y *
                                                                 scale * speed *
                                                                 delta_time, 0))
                        y = is_collision(self, map, map_draw3ds, map_size_x,
                                         map_size_y)
                        if y then
                            self.drawer.position = before_pos
                        end
                    end
                    if y then
                        self.drawer.position = before_pos
                        self.drawer.position =
                            self.drawer.position:add(vector3(input_vector.x *
                                                                 scale * speed *
                                                                 delta_time, 0,
                                                             0))
                        x = is_collision(self, map, map_draw3ds, map_size_x,
                                         map_size_y)
                        if x then
                            self.drawer.position = before_pos
                        end
                    end

                else
                    if x and y then
                        self.drawer.position = before_pos
                    end
                end
            else
                self.drawer.position = self.drawer.position:add(vector3(
                                                                    input_vector.x *
                                                                        scale *
                                                                        speed *
                                                                        delta_time,
                                                                    0, 0))
                if is_collision(self, map, map_draw3ds, map_size_x, map_size_y) then
                    self.drawer.position = before_pos
                end
                before_pos = self.drawer.position:copy()
                self.drawer.position = self.drawer.position:add(vector3(0,
                                                                        input_vector.y *
                                                                            scale *
                                                                            speed *
                                                                            delta_time,
                                                                        0))
                if is_collision(self, map, map_draw3ds, map_size_x, map_size_y) then
                    self.drawer.position = before_pos
                end
            end
            if input_vector.x ~= 0 or input_vector.y ~= 0 then
                self.drawer.rotation = vector3(0, 0, -math.atan2(input_vector.x,
                                                                 input_vector.y) *
                                                   (180.0 / math.pi))
            end
        end
    end,
    draw = function(self)
        if not fps_mode then self.drawer:draw() end
        self.hp_drawer:draw()
    end
}

return player
