#pragma once

#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include <iostream>
#include <string>

#define CHECK_CUDA_ERROR(err)                                                                                          \
  if (err != cudaSuccess) {                                                                                            \
    fprintf(stderr, "CUDA Error: %s (Line: %d)\n", cudaGetErrorString(err), __LINE__);                                 \
    exit(EXIT_FAILURE);                                                                                                \
  }