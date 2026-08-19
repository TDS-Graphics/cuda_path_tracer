#include "common.cuh"

// Image Configuration
const int CHANNELS = 3; // RGB 3 channels

// ===================== Device-only Function =====================

__device__ void CalculatePixel(float3 *color, int2 resolution, int2 uv) {
  color->x = uv.x / static_cast<float>(resolution.x - 1);
  color->y = uv.y / static_cast<float>(resolution.y - 1);
  color->z = 0.5;
}

__device__ void CalculatePPM(unsigned char *d_pixels, int2 resolution, int2 uv) {
  // Calculate the index of the current pixel in the flat array
  int pixel_idx = (uv.y * resolution.x + uv.x) * CHANNELS;

  float3 pixel_color{};
  CalculatePixel(&pixel_color, resolution, uv);

  d_pixels[pixel_idx + 0] = pixel_color.x * 255.999;
  d_pixels[pixel_idx + 1] = pixel_color.y * 255.999;
  d_pixels[pixel_idx + 2] = pixel_color.z * 255.999;
}

// ===================== Global Kernel =====================

__global__ void KernelMain(unsigned char *d_pixels, int width, int height) {
  int x = blockIdx.x * blockDim.x + threadIdx.x;
  int y = blockIdx.y * blockDim.y + threadIdx.y;

  if (x >= width || y >= height)
    return;

  CalculatePPM(d_pixels, {width, height}, {x, y});
}

void WritePPM(const char *filename, unsigned char *pixels, int width, int height) {
  FILE *fp = fopen(filename, "wb");
  if (!fp) {
    fprintf(stderr, "Error: Failed to open file!\n");
    exit(EXIT_FAILURE);
  }

  fprintf(fp, "P6\n%d %d\n255\n", width, height);
  fwrite(pixels, sizeof(unsigned char), width * height * CHANNELS, fp);

  fclose(fp);
  printf("PPM image generated successfully: %s\n", filename);
}

int main(int argc, char *argv[]) {
  if (argc != 4) {
    std::cerr << "Usage: " << argv[0] << " <image-name> <width> <height>\n";
    return -1;
  }
  const unsigned int IMG_WIDTH = std::stoul(argv[2]);
  const unsigned int IMG_HEIGHT = std::stoul(argv[3]);
  const auto IMG_NAME = argv[1] == nullptr ? "unname" : std::string(argv[1]);

  size_t pixel_bytes = IMG_WIDTH * IMG_HEIGHT * CHANNELS * sizeof(unsigned char);

  // Allocate host memory
  auto *h_pixels = static_cast<unsigned char *>(malloc(pixel_bytes));
  if (!h_pixels) {
    fprintf(stderr, "Error: Host memory allocation failed!\n");
    exit(EXIT_FAILURE);
  }

  // Allocate device memory
  unsigned char *d_pixels = nullptr;
  CHECK_CUDA_ERROR(cudaMalloc(&d_pixels, pixel_bytes));

  // Configure CUDA grid and block dimensions
  dim3 thread_per_block(16, 16);
  dim3 grid_size((IMG_WIDTH + thread_per_block.x - 1) / thread_per_block.x,
                 (IMG_HEIGHT + thread_per_block.y - 1) / thread_per_block.y);

  // Launch CUDA kernel on GPU
  printf("Launching CUDA kernel...\n");
  KernelMain<<<grid_size, thread_per_block>>>(d_pixels, IMG_WIDTH, IMG_HEIGHT);

  CHECK_CUDA_ERROR(cudaGetLastError());

  // Wait for GPU to finish execution
  CHECK_CUDA_ERROR(cudaDeviceSynchronize());

  // Copy processed pixel data from GPU back to CPU
  CHECK_CUDA_ERROR(cudaMemcpy(h_pixels, d_pixels, pixel_bytes, cudaMemcpyDeviceToHost));

  // Generate the final PPM image file
  WritePPM(IMG_NAME.c_str(), h_pixels, IMG_WIDTH, IMG_HEIGHT);

  // Free allocated memory
  CHECK_CUDA_ERROR(cudaFree(d_pixels));
  free(h_pixels);

  return 0;
}
