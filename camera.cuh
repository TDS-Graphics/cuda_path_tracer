#pragma once

#include "common.cuh"

struct camera {
public:
  camera() { initialize(); }

  void rendering(glm::ivec2 _resolution) {
    resolution = _resolution;
    aspect_ratio = static_cast<float>(resolution.x) / static_cast<float>(resolution.y);
  }

  glm::vec3 position;
  glm::vec3 direction;
  glm::vec3 up;
  glm::vec3 right;
  float fov;
  float aspect_ratio;

private:
  void initialize() {
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

  glm::ivec2 resolution;
};
