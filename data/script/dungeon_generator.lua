local function dungeon_room(_x, _y, _w, _h)
    local object = {x = _x, y = _y, w = _w, h = _h}
    return object
end
local function point_t(_x, _y)
    local object = {x = _x, y = _y}
    return object
end
local function dungeon_generator()
    local generator = {
        division_min_number = 1,
        division_max_number = {},
        division_map = {},
        division_map_index = 1,
        rooms = {},
        rooms_index = 1,
        points = {},
        points_index = 1,
        value_wall = 1,
        value_room = 0,
        value_corridor = 0,
        map_size_x = {},
        map_size_y = {},

        generate = function(self, map, mx, my)
            self.map_size_x = mx
            self.map_size_y = my
            self.division_max_number = mx
            self:setup(map)
            self:division(map)
            self:make_room(map)
            self:make_corridor(map)
            self:connect_corridor(map)
        end,
        setup = function(self, map)
            for y = 1, self.map_size_y do
                map[y] = {}
                for x = 1, self.map_size_x do
                    map[y][x] = 0
                    map[1][x] = 1
                    map[self.map_size_y][x] = 1
                    map[y][1] = 1
                    map[y][self.map_size_x] = 1
                end
            end
        end,
        division = function(self, map)
            local randomized = random:get_int_range(self.division_min_number,
                                                    self.division_max_number)
            x = 2
            y = 2
            w = self.map_size_x - 2
            h = self.map_size_y - 2
            is_horizontal = true
            for i = 1, randomized do
                if (is_horizontal) then
                    self:division_horizontal(map, x, y, w, h)
                else
                    self:division_vertical(map, x, y, w, h)
                    is_horizontal = not is_horizontal;
                end
            end
            -- prepare
            for i = x, x + w do
                for j = y, y + h do map[j][i] = self.value_wall end
            end
        end,
        division_horizontal = function(self, map, x, y, w, h)
            x1 = random:get_int_range(x + ((x + w) / 2), w)
            self.division_map[self.division_map_index] = dungeon_room(x, y,
                                                                      x1 - x, h)
            self.division_map_index = self.division_map_index + 1
            for i = x1, w do
                for j = y, y + h do map[j][i] = self.value_wall end
            end
            w = x1
        end,
        division_vertical = function(self, map, x, y, w, h)
            y1 = random:get_int_range(y + ((y + h) / 2), h)
            self.division_map[self.division_map_index] =
                dungeon_room(x, y1, w, h - y1)
            self.division_map_index = self.division_map_index + 1
            for i = x, x + w do
                for j = y1, h do map[j][i] = self.value_wall end
            end
            h = y1
        end,
        make_room = function(self, map)
            for d = 1, self.division_map_index - 1 do
                x1 = random:get_int_range(self.division_map[d].x,
                                          self.division_map[d].x +
                                              self.division_map[d].w)
                y1 = random:get_int_range(self.division_map[d].y,
                                          self.division_map[d].y +
                                              self.division_map[d].h)
                w1 = random:get_int_range(1, self.division_map[d].w)
                h1 = random:get_int_range(1, self.division_map[d].h)
                if (x1 + w1) > self.map_size_x - 1 then
                    w1 = self.map_size_x - 1 - x1
                end
                if (y1 + h1) > self.map_size_y - 1 then
                    h1 = self.map_size_y - 1 - y1
                end
                room = dungeon_room(x1, y1, w1, h1)
                for i = x1, x1 + w1 do
                    for j = y1, y1 + h1 do
                        map[j][i] = self.value_room
                    end
                end
                self.rooms[self.rooms_index] = room
                self.rooms_index = self.rooms_index + 1
            end
        end,
        make_corridor = function(self, map)
            for index = 1, self.rooms_index - 2 do
                local point = random:get_int_range(self.rooms[index + 1].y,
                                                   self.rooms[index + 1].y +
                                                       self.rooms[index + 1].h)
                if point > self.map_size_y then
                    point = self.map_size_y
                end
                if point < 1 then point = 1 end

                target = random:get_int_range(self.rooms[index].x,
                                              self.rooms[index].x +
                                                  self.rooms[index].w)
                min = math.min(self.division_map[index].x, target)
                if min < 1 then min = 1 end
                max = math.max(self.division_map[index].x, target)
                if (max > self.map_size_x - 1) then
                    max = self.map_size_x - 1
                end
                for i = min, max do
                    map[point][i] = value_corridor
                end
                target = random:get_int_range(self.rooms[index].y,
                                              self.rooms[index].y +
                                                  self.rooms[index].h);
                min = math.min(point, target)
                max = math.max(point, target)
                if (min < 1) then min = 1 end
                if (max > self.map_size_y - 1) then
                    max = self.map_size_y - 1
                end
                for i = min, max do
                    map[i][self.rooms[index].x] = self.value_corridor
                end
                self.points[self.points_index] =
                    point_t(self.rooms[index].x, point)
                self.points_index = self.points_index + 1
            end
        end,

        connect_corridor = function(self, map)
            for i = 1, self.points_index - 2 do
                local min = math.min(self.points[i].x, self.points[i + 1].x)
                local max = math.max(self.points[i].x, self.points[i + 1].x)
                for j = min, max do
                    if (min == self.points[i].x) then
                        map[self.points[i].y][j] = self.value_corridor
                    else
                        map[self.points[i + 1].y][j] = self.value_corridor
                    end
                end

                min = math.min(self.points[i].y, self.points[i + 1].y)
                max = math.max(self.points[i].y, self.points[i + 1].y)
                for j = min, max do
                    if (min == self.points[i].y) then
                        map[j][self.points[i].x] = self.value_corridor;
                    else
                        map[j][self.points[i + 1].y] = self.value_corridor;
                    end
                end
            end
        end
    }
    return generator
end

return dungeon_generator
