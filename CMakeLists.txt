cmake_minimum_required(VERSION 4.2)
project(cuda_path_tracer CUDA)

set(CMAKE_CUDA_STANDARD 20)

add_executable(${PROJECT_NAME} 
        main.cu
        camera.cuh
        common.cuh
)

set_target_properties(${PROJECT_NAME} PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
