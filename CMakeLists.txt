cmake_minimum_required(VERSION 4.2)
project(cuda_path_tracer CUDA)

set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

# Debug device and global function is must have
set(CMAKE_CUDA_FLAGS_DEBUG "${CMAKE_CUDA_FLAGS_DEBUG} -G")

find_package(glm REQUIRED)

add_executable(${PROJECT_NAME} 
        main.cu
        camera.cuh
        common.cuh
        scene.cuh
)

set_target_properties(${PROJECT_NAME} PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON
        CUDA_ARCHITECTURES "75"
)

target_link_libraries(${PROJECT_NAME} PRIVATE glm::glm -luuid)
