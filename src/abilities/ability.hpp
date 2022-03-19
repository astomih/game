#pragma once

#include <cstdint>
class ability {
public:
  ability() = default;
  ability(int32_t hp, int32_t attack, int32_t defence, int32_t speed)
      : hp(hp), attack(attack), defence(defence), speed(speed) {}
  ~ability() = default;
  void initialize(int32_t hp, int32_t attack, int32_t defence, int32_t speed) {
    this->hp = hp;
    this->attack = attack;
    this->defence = defence;
    this->speed = speed;
  }

  bool add_damage(int32_t damage) {
    hp -= damage;
    return hp < 0;
  }

private:
  int32_t hp;
  int32_t attack;
  int32_t defence;
  int32_t speed;
};
