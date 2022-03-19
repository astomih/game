#pragma once
#include <Nen/Nen.hpp>
#include <array>
#include <cstddef>
#include <cstdint>
#include <utility>

constexpr std::pair<std::size_t, std::size_t> map_size = std::make_pair(30, 30);

using map_t = std::vector<std::vector<uint32_t>>;
using map_actors_t =
    std::array<std::array<std::uint16_t, map_size.first>, map_size.second>;

enum class map_type : uint32_t {
  wall = 0,
  room = 1,
  road = 2,
};