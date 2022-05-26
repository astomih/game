local is_collision = require "is_collision"
local bombed = sound()
bombed:load("bombed.wav")
local r1 = {}
local r2 = {}
local function decide_pos(map, map_size_x, map_size_y)
    r1 = math.random(1, map_size_x)
    r2 = math.random(1, map_size_y)
    return map[r2][r1] == 1
end
local enemy = function()
    local object = {
        drawer = {},
        speed = 4,
        model = {},
        hp = 100,
        aabb = {},
        is_collision_first = {},
        collision_time = {},
        collision_timer = {},
        get_forward_z = function(drawer)

            return vector2(-math.sin(math.rad(drawer.rotation.z)),
                           math.cos(math.rad(-drawer.rotation.z)))
        end,
        setup = function(self, map, map_size_x, map_size_y)
            self.model = model()
            self.model:load("spider.sim", "enemy")
            self.drawer = draw3d(tex)
            self.drawer.vertex_name = "enemy"
            self.aabb = aabb()
            r1 = 0
            r2 = 0
            while decide_pos(map, map_size_x, map_size_y) == true do end
            self.drawer.position = vector3(r1 * 2, r2 * 2, 1)
            self.drawer.scale = vector3(0.3, 0.3, 0.3)
            self.is_collision_first = true
            self.collision_time = 1.0
            self.collision_timer = 0.0
        end,
        update = function(self, player, map, map_draw3ds, map_size_x, map_size_y)
            self.aabb.max = self.drawer.position:add(
                                self.drawer.scale:mul(self.model.aabb.max))
            self.aabb.min = self.drawer.position:add(
                                self.drawer.scale:mul(self.model.aabb.min))
            self.drawer.rotation = vector3(0, 0,
                                           math.deg(
                                               -math.atan2(
                                                   player.drawer.position.x -
                                                       self.drawer.position.x,
                                                   player.drawer.position.y -
                                                       self.drawer.position.y)))
            local before_pos = self.drawer.position:copy()
            self.drawer.position.x = self.drawer.position.x + delta_time *
                                         self.speed *
                                         self.get_forward_z(self.drawer).x
            if is_collision(self, map, map_draw3ds, map_size_x, map_size_y) then
                self.drawer.position = before_pos
            end
            before_pos = self.drawer.position:copy()
            self.drawer.position.y = self.drawer.position.y + delta_time *
                                         self.speed *
                                         self.get_forward_z(self.drawer).y
            if is_collision(self, map, map_draw3ds, map_size_x, map_size_y) then
                self.drawer.position = before_pos
            end

        end,
        draw = function(self) self.drawer:draw() end,
        player_collision = function(self, player)
            if self.aabb:intersects_aabb(player.aabb) then
                if self.is_collision_first then
                    bombed:play()
                    player.hp = player.hp - 10
                    player.font:render_text(player.hp_font_texture,
                                            "HP:" .. player.hp,
                                            color(1, 1, 1, 1))
                    player.hp_drawer.scale = player.hp_font_texture:size()
                    self.is_collision_first = false
                else
                    self.collision_timer = self.collision_timer + delta_time
                    if self.collision_timer > self.collision_time then
                        bombed:play()
                        player.hp = player.hp - 10
                        player.font:render_text(player.hp_font_texture,
                                                "HP:" .. player.hp,
                                                color(1, 1, 1, 1))
                        player.hp_drawer.scale = player.hp_font_texture:size()
                        self.collision_timer = 0.0
                    end
                end
            else
                self.is_collision_first = true
            end
        end
    }
    return object
end
return enemy
