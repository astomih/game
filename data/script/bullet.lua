local m = model()
m:load("bullet.sim", "bullet")
local function bullet(map_draw3ds)
    local object = {
        speed = 20,
        drawer = {},
        life_time = 0.5,
        current_time = 0,
        setup = function(self, owner)
            self.drawer = draw3d(tex)
            self.drawer.vertex_name = "bullet"
            self.drawer.position = owner.drawer.position
            self.drawer.rotation = owner.drawer.rotation
            self.drawer.scale = vector3(0.5, 0.5, 0.5)
        end,
        update = function(self)
            self.current_time = self.current_time + delta_time
            self.drawer.position.x = self.drawer.position.x + delta_time *
                                         self.speed *
                                         -math.sin(
                                             math.rad(self.drawer.rotation.z))
            self.drawer.position.y = self.drawer.position.y + delta_time *
                                         self.speed *
                                         math.cos(
                                             math.rad(-self.drawer.rotation.z))

            self.drawer:draw()
        end
    }

    return object
end

return bullet

