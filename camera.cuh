#pragma once

#include "common.cuh"

struct camera {
public:
  camera() { initialize(); }

  void rendering(int2 _resolution) {
    resolution = _resolution;
    aspect_ratio = static_cast<float>(resolution.x) / static_cast<float>(resolution.y);
  }

  float3 position;
  float3 direction;
  float3 up;
  float3 right;
  float fov;
  float aspect_ratio;

private:
  void initialize() {
    position = {0.0f, 0.0f, 0.0f};
    direction = {0.0f, 0.0f, 1.0f};
    up = {0.0f, 1.0f, 0.0f};
    right = {1.0f, 0.0f, 0.0f};
    fov = 90.0f;
  }

  int2 resolution;
};
