#pragma once

#include "common.cuh"

class CCamera {
public:
  CCamera() { Initialize(); }

  glm::vec3 position;
  glm::vec3 direction;
  glm::vec3 up;
  glm::vec3 right;
  float fov;
  float aspect_ratio;

private:
  void Initialize() {
    position = {
        0.0f,
        0.0f,
        0.0f,
    };
    direction = {
        0.0f,
        0.0f,
        1.0f,
    };
    up = {
        0.0f,
        1.0f,
        0.0f,
    };
    right = {
        1.0f,
        0.0f,
        0.0f,
    };
    fov = 90.0f;
  }
};
