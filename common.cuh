#pragma once

#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include <iostream>
#include <map>
#include <string>
#include <vector>

#include <glm/ext/scalar_int_sized.hpp>
#include <glm/ext/vector_float3.hpp>
#include <glm/ext/vector_int2.hpp>
#include <glm/glm.hpp>

#include <uuid/uuid.h>

#define CHECK_CUDA_ERROR(err)                                                                                          \
  do {                                                                                                                 \
    if (err != cudaSuccess) {                                                                                          \
      fprintf(stderr, "CUDA Error: %s (Line: %d)\n", cudaGetErrorString(err), __LINE__);                               \
      exit(EXIT_FAILURE);                                                                                              \
    }                                                                                                                  \
  } while (false)

std::string GenUUID() {
  uuid_t uuid;
  uuid_generate_random(uuid);

  char uuid_str[37];
  uuid_unparse(uuid, uuid_str);

  return std::string(uuid_str);
}
