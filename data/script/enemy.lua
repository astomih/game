local enemy = function()
    local object = {
        drawer = {},
        model = {},
        setup = function(self, map)
            self.model = model()
            self.model.load("spider.sim", "spider")
            self.drawer = draw3d(tex)
            self.drawer.vertex_name = "spider"
        end,
        update = function() end
    }
    return object
end
