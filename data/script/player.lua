local bullet = require "bullet"
local calc_input_vector = require "calc_input_vector"
local is_collision = require "is_collision"
local input_vector = {}
local speed = 2.0
local function xor(a, b) return (a and not b) or (not a and b) end
local effect = require "effect"
local bullet_type = require "bullet_type"

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

local shadow = require("shadow")

local player = {
    drawer = {},
    model = {},
    bullet_type_tex = {},
    bullet_type_drawer = {},
    bullet_type = bullet_type.fire,
    bullets = {},
    hp = {},
    hp_drawer = {},
    hp_drawer2 = {},
    hp_font = {},
    hp_font_texture = {},
    hp_font_texture2 = {},
    aabb = {},
    bullet_time = {},
    bullet_timer = {},
    efks = {},
    gun_model = {},
    gun_drawer = {},
    shadow = {},
    setup = function(self, map, map_size_x, map_size_y)
        self.gun_model = model()
        self.gun_model:load("gun.sim", "gun")
        self.gun_drawer = draw3d(tex)
        self.gun_drawer.vertex_name = "gun"

        self.bullet_type_tex = texture()
        self.bullet_type_tex:load("fire.png")
        self.bullet_type_drawer = draw2d(self.bullet_type_tex)
        self.bullet_type_drawer.scale = vector2(256, 256)
        self.bullet_type_drawer.position.x = 512
        self.bullet_type_drawer.position.y = 128
        self.model = model()
        self.model:load("untitled.sim", "player")
        self.drawer = draw3d(tex)
        self.drawer.vertex_name = "player"
        self.aabb = aabb()
        self.bullet_time = 0.1
        self.bullet_timer = 0.0
        self.hp = 100

        self.hp_font_texture = texture()
        self.hp_font_texture2 = texture()

        self.hp_drawer = draw2d(self.hp_font_texture)
        self.hp_drawer2 = draw2d(self.hp_font_texture2)
        self.hp_font_texture2:fill_color(color(0.2, 0.2, 0.2, 0.2))
        self.render_text(self)
        r1 = 0
        r2 = 0
        while decide_pos(map, map_size_x, map_size_y) == true do end
        self.drawer.position = vector3(r1 * 2, r2 * 2, 0)
        self.hp_drawer.position.x = 0
        self.hp_drawer.position.y = 300
        self.hp_drawer2.position.x = 0
        self.hp_drawer2.position.y = 300
        self.hp_drawer2.scale = vector2(self.hp * 10.0, 50)
        mouse:hide_cursor(true)
        self.shadow = shadow()
        self.shadow.owner = self.drawer
        self.shadow:setup()
    end,
    horizontal = math.pi,
    vertical = 0.0,
    update = function(self, map, map_draw3ds, map_size_x, map_size_y)

        if keyboard:key_state(keyC) == buttonPRESSED then
            self.bullet_type = self.bullet_type + 1
            if self.bullet_type > 2 then self.bullet_type = 0 end
            if self.bullet_type == bullet_type.fire then
                self.bullet_type_tex:load("fire.png")
            end
            if self.bullet_type == bullet_type.water then
                self.bullet_type_tex:load("water.png")
            end
            if self.bullet_type == bullet_type.grass then
                self.bullet_type_tex:load("grass.png")
            end

        end
        if keyboard:key_state(keyV) == buttonPRESSED then
            self.drawer.rotation.z = self.drawer.rotation.z + 180
        end

        self.aabb.max = self.drawer.position:add(
                            self.drawer.scale:mul(self.model.aabb.max))
        self.aabb.min = self.drawer.position:add(
                            self.drawer.scale:mul(self.model.aabb.min))
        if self.hp <= 0 then change_scene("gameover") end
        input_vector = calc_input_vector()
        if keyboard:is_key_down(keyLSHIFT) then
            speed = 8.0
        else
            speed = 4.0
        end

        -- bullet 
        self.bullet_timer = self.bullet_timer + delta_time
        if mouse:button_state(mouseLEFT) == buttonHELD and self.bullet_timer >
            self.bullet_time then
            local b = bullet(map_draw3ds)
            b:setup(self.gun_drawer)
            b.drawer.rotation.z = b.drawer.rotation.z + 90
            b.type = self.bullet_type
            if b.type == bullet_type.fire then
                b.texture:fill_color(color(1, 0.5, 0.5, 1))
            else
                if b.type == bullet_type.water then
                    b.texture:fill_color(color(0.5, 0.5, 1, 1))
                else
                    b.texture:fill_color(color(0.5, 1, 0.5, 1))
                end
            end
            table.insert(self.bullets, b)
            self.bullet_timer = 0.0
        end
        for i, v in ipairs(self.bullets) do
            v:update()
            if v.current_time > v.life_time then
                local efk = effect()
                efk:setup()
                for j = 1, efk.max_particles do
                    efk.worlds[j].position = v.drawer.position:copy()
                end
                efk:play()
                table.insert(self.efks, efk)
                table.remove(self.bullets, i)
            end
        end
        for i, v in ipairs(self.efks) do
            v:update()
            if v.is_stop then table.remove(self.efks, i) end
        end
        local mpos = mouse:position()
        mouse:set_position(vector2(1280 / 2, 720 / 2))
        mpos.x = 640 - mpos.x
        mpos.y = 360 - mpos.y
        local sikiiti = 8
        self.drawer.rotation.z =
            self.drawer.rotation.z + (mpos.x) * delta_time * sikiiti
        -- if fps_mode then
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
        if input_vector.x ~= 0 then
            local r = self.drawer.rotation:copy()
            if input_vector.x == 1 then r.z = r.z - 90 end
            if input_vector.x == -1 then r.z = r.z + 90 end
            local rot = get_forward_z(r)
            self.drawer.position = self.drawer.position:add(vector3(rot.x *
                                                                        scale *
                                                                        speed *
                                                                        delta_time,
                                                                    0, 0))
            if is_collision(self, map, map_draw3ds, map_size_x, map_size_y) then
                self.drawer.position = before_pos
            end
            before_pos = self.drawer.position:copy()
            self.drawer.position = self.drawer.position:add(vector3(0, rot.y *
                                                                        scale *
                                                                        speed *
                                                                        delta_time,
                                                                    0))
            if is_collision(self, map, map_draw3ds, map_size_x, map_size_y) then
                self.drawer.position = before_pos
            end
        end
        --[[
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
        end--]]

        -- gun
        local r = self.drawer.rotation
        local rot = get_forward_z(r)
        self.gun_drawer.position = vector3(self.drawer.position.x + rot.x,
                                           self.drawer.position.y + 0.5 + rot.y,
                                           0)
        self.gun_drawer.scale = vector3(0.3, 0.3, 0.3)
        self.gun_drawer.rotation = self.drawer.rotation:copy()
        self.gun_drawer.rotation.z = self.gun_drawer.rotation.z - 90
        self.gun_drawer.position.z = 1.5
        self.shadow:update()
    end,
    draw = function(self)
        if not fps_mode then self.drawer:draw() end
        self.hp_drawer:draw()
        self.hp_drawer2:draw()
        self.bullet_type_drawer:draw()
        self.gun_drawer:draw()
        self.shadow:draw()
    end,
    render_text = function(self)
        if self.hp < 20 then
            self.hp_font_texture:fill_color(color(1, 0.6, 0.6, 0.8))
        else
            self.hp_font_texture:fill_color(color(0.6, 1, 0.6, 0.8))
        end
        self.hp_drawer.scale = vector2(self.hp * 10, 50)
    end
}

return player
