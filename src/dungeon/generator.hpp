#ifndef UTILIS_DUNGEON_GENERATOR_HPP
#define UTILIS_DUNGEON_GENERATOR_HPP
#include "Math/Random.hpp"
#include <Nen.hpp>
#include <cstdint>
#include <vector>

class dungeon_room {
public:
  dungeon_room() = default;
  ~dungeon_room() = default;
  int x, y, w, h;

private:
};
struct division_room_t {
  division_room_t() = default;
  division_room_t(int x, int y, int w, int h) : x(x), y(y), w(w), h(h) {}

  int x, y, w, h;
};
struct point_t {
  point_t() = default;
  point_t(int x, int y) : x(x), y(y) {}
  int x, y;
};
template <typename T> class dungeon_generator {
public:
  dungeon_generator() = default;
  ~dungeon_generator() = default;
  void set_wall_value(T wall_value) { this->value_wall = wall_value; }
  void set_room_value(T room_value) { this->value_room = room_value; }
  void set_corridor_value(T corridor_value) {
    this->value_corridor = corridor_value;
  }
  void generate(std::vector<std::vector<T>> &map) {
    map_size_x = static_cast<T>(map.size() - 1);
    map_size_y = static_cast<T>(map[0].size() - 1);
    // std::cout << "division" << std::endl;
    division(map);
    // std::cout << "room" << std::endl;
    make_room(map);
    // std::cout << "corridor" << std::endl;
    make_corridor(map);
    // std::cout << "connect" << std::endl;
    connect_corridor(map);
    // fill_around(map);
  }

private:
  void division(std::vector<std::vector<T>> &map) {
    int randomized =
        nen::random::GetIntRange(division_min_number, division_max_number);
    int x = 1, y = 1, w = map_size_x - 1, h = map_size_y - 1;
    bool is_horizontal = true;
    for (size_t i = 0; i < randomized - 1; i++) {
      if (is_horizontal)
        division_horizontal(map, x, y, w, h);
      else
        division_vertical(map, x, y, w, h);

      is_horizontal = !is_horizontal;

      for (int i = x; i <= x + w; i++) {
        for (int j = y; j <= y + h; j++) {
          map[j][i] = value_wall;
        }
      }
    }
  }
  void division_horizontal(std::vector<std::vector<T>> &map, int &x, int &y,
                           int &w, int &h) {
    int x1 = nen::random::GetIntRange(x + ((x + w) / 2), w);
    division_map.emplace_back(division_room_t(x1, y, w - x1, h));
    for (int i = x1; i <= w; i++) {
      for (int j = y; j <= y + h; j++) {
        map[j][i] = value_wall;
      }
    }
    w = x1;
  }
  void division_vertical(std::vector<std::vector<T>> &map, int &x, int &y,
                         int &w, int &h) {
    int y1 = nen::random::GetIntRange(y + ((y + h) / 2), h);
    division_map.emplace_back(division_room_t(x, y1, w, h - y1));
    for (int i = x; i <= x + w; i++) {
      for (int j = y1; j <= h; j++) {
        map[j][i] = value_wall;
      }
    }
    h = y1;
  }
  void make_room(std::vector<std::vector<T>> &map) {
    rooms.reserve(division_map.size());
    for (int d = 0; d < division_map.size(); d++) {
      T x1 = nen::random::GetIntRange(division_map[d].x,
                                      division_map[d].x + division_map[d].w);
      T y1 = nen::random::GetIntRange(division_map[d].y,
                                      division_map[d].y + division_map[d].h);
      T w1 = nen::random::GetIntRange(1, division_map[d].w);
      T h1 = nen::random::GetIntRange(1, division_map[d].h);
      if (x1 + w1 > map_size_x - 1)
        w1 = map_size_x - x1 - 1;
      if (y1 + h1 > map_size_y - 1)
        h1 = map_size_y - y1 - 1;
      dungeon_room room;
      room.x = x1;
      room.y = y1;
      room.w = w1;
      room.h = h1;
      for (int i = x1; i <= x1 + w1; i++) {
        for (int j = y1; j <= y1 + h1; j++) {
          if (i > map_size_x - 1 || j > map_size_y - 1)
            continue;
          map[j][i] = value_room;
        }
      }
      rooms.push_back(room);
    }
  }
  void make_corridor(std::vector<std::vector<T>> &map) {
    for (size_t i = 0; i < rooms.size() - 1; i++) {
      corridor_implemental(map, i);
    }
  }
  void corridor_implemental(std::vector<std::vector<T>> &map, int index) {
    int point = nen::random::GetIntRange(
        rooms.at(index + 1).y, rooms.at(index + 1).y + rooms.at(index + 1).h);
    if (point > map_size_y - 1)
      point = map_size_y;
    if (point < 1)
      point = 1;

    int target = nen::random::GetIntRange(rooms[index].x,
                                          rooms[index].x + rooms[index].w);
    int min = std::min(division_map[index].x, target);
    if (min < 1)
      min = 1;
    int max = std::max(division_map[index].x, target);
    if (max > map_size_x - 1)
      max = map_size_x - 1;
    for (int i = min; i <= max; i++) {
      map.at(point).at(i) = value_corridor;
    }
    target = nen::random::GetIntRange(rooms[index].y,
                                      rooms[index].y + rooms[index].h);
    min = std::min(point, target);
    max = std::max(point, target);
    if (min < 1)
      min = 1;
    if (max > map_size_y - 1)
      max = map_size_y - 1;
    for (int i = min; i <= max; i++) {
      map.at(i).at(rooms[index].x) = value_corridor;
    }
    points.push_back(point_t(rooms[index].x, point));
  }

  void connect_corridor(std::vector<std::vector<T>> &map) {
    for (int i = 0; i < points.size() - 1; i++) {
      int min = std::min(points[i].x, points[i + 1].x);
      int max = std::max(points[i].x, points[i + 1].x);
      for (int j = min; j <= max; j++) {
        if (min == points[i].x)
          map[points[i].y][j] = value_corridor;
        else
          map[points[i + 1].y][j] = value_corridor;
      }
      min = std::min(points[i].y, points[i + 1].y);
      max = std::max(points[i].y, points[i + 1].y);
      for (int j = min; j <= max; j++) {
        if (min == points[i].y)
          map[j][points[i].x] = value_corridor;
        else
          map[j][points[i + 1].y] = value_corridor;
      }
    }
  }

  void fill_around(std::vector<std::vector<T>> &map) {
    for (int i = 0; i < map_size_x; i++) {
      for (int j = 0; j < map_size_y; j++) {
        map[0][i] = value_wall;
        map[map_size_y - 1][i] = value_wall;
        map[j][0] = value_wall;
        map[j][map_size_x - 1] = value_wall;
      }
    }
  }

  std::int32_t division_max_number = 10;
  std::int32_t division_min_number = 10;
  std::vector<division_room_t> division_map;
  std::vector<dungeon_room> rooms;
  std::vector<point_t> points;
  int map_size_x;
  int map_size_y;
  int room_size_min;
  int room_size_max;
  // values
  T value_wall = 0;
  T value_room = 1;
  T value_corridor = 1;
};
#endif