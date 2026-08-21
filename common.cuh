#pragma once

#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include <iostream>
#include <string>

#include <glm/ext/vector_float3.hpp>
#include <glm/glm.hpp>

#define CHECK_CUDA_ERROR(err)                                                                                          \
  do {                                                                                                                 \
    if (err != cudaSuccess) {                                                                                          \
      fprintf(stderr, "CUDA Error: %s (Line: %d)\n", cudaGetErrorString(err), __LINE__);                               \
      exit(EXIT_FAILURE);                                                                                              \
    }                                                                                                                  \
  } while (false)
