cmake_minimum_required(VERSION 4.2)
project(cuda_path_tracer CUDA)

set(CMAKE_CUDA_STANDARD 20)

add_executable(cuda_path_tracer main.cu)

set_target_properties(cuda_path_tracer PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)
