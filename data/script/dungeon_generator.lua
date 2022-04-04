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
        division_min_number = {},
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
            self.division_min_number = 10
            self.division_max_number = 10
            self:setup(map)
            self:division(map)
            self:make_room(map)
            self:make_corridor(map)
            self:connect_corridor(map)
            for i = 2, self.map_size_y - 1 do
                for j = 2, self.map_size_x - 1 do
                    if map[j][i] == nil then
                        map[j][i] = self.value_wall
                    end
                end
            end

            self:debug(map)
        end,
        setup = function(self, map)
            for y = 1, self.map_size_y do
                map[y] = {}
                for x = 1, self.map_size_x do
                    map[y][x] = self.value_wall
                end
            end
        end,
        division = function(self, map)
            local randomized = 8
            x = 2
            y = 2
            w = self.map_size_x - 2
            h = self.map_size_y - 2
            f1 = true
            f2 = true
            while f1 and f2 do
                if self.map_size_x > x + self.division_min_number then
                    local max = self.division_max_number
                    if x + max >= self.map_size_x - 2 then
                        max = self.division_min_number
                    end
                    w = random:get_int_range(self.division_min_number, max)
                    self.division_map[self.division_map_index] = dungeon_room(x,
                                                                              y,
                                                                              w,
                                                                              h)
                    self.division_map_index = self.division_map_index + 1
                    x = x + w
                else
                    f1 = false
                end

                if self.map_size_y > y + self.division_min_number then
                    local max = self.division_max_number
                    if y + max >= self.map_size_y - 2 then
                        max = self.division_min_number
                    end
                    h = random:get_int_range(self.division_min_number, max)
                    self.division_map[self.division_map_index] = dungeon_room(x,
                                                                              y,
                                                                              w,
                                                                              h)
                    self.division_map_index = self.division_map_index + 1
                    y = y + h
                else
                    f2 = false
                end
            end
        end,
        make_room = function(self, map)
            for d = 1, self.division_map_index - 1 do
                x1 = self.division_map[d].x + 3
                y1 = self.division_map[d].y + 3

                w1 = self.division_map[d].w - 3
                h1 = self.division_map[d].h - 3
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
                    map[self.points[i].y][j] = self.value_corridor
                    map[self.points[i + 1].y][j] = self.value_corridor
                end

                min = math.min(self.points[i].y, self.points[i + 1].y)
                max = math.max(self.points[i].y, self.points[i + 1].y)
                for j = min, max do
                    map[j][self.points[i].x] = self.value_corridor;
                    map[j][self.points[i + 1].y] = self.value_corridor;
                end
            end
        end,
        debug = function(self, map)
            for i = 1, self.map_size_y do
                for j = 1, self.map_size_x do io.write(map[i][j]) end
                print()
            end
        end
    }
    return generator
end

return dungeon_generator
