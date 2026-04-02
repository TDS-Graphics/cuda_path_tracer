#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

// CUDA Error Checking Macro (Essential for debugging)
#define CHECK_CUDA_ERROR(err) \
    if (err != cudaSuccess) { \
        fprintf(stderr, "CUDA Error: %s (Line: %d)\n", cudaGetErrorString(err), __LINE__); \
        exit(EXIT_FAILURE); \
    }

// Image Configuration
const int IMG_WIDTH = 1280; // Image width (pixels)
const int IMG_HEIGHT = 720; // Image height (pixels)
const int CHANNELS = 3; // RGB 3 channels

// ===================== Device-only Function (GPU only, cannot be called by CPU) =====================
// Calculates and writes the RGB color for a single pixel (x, y)
__device__ void GenerateGradientPPM(
    unsigned char *d_pixels,
    int x, int y,
    int width, int height
) {
    // Calculate the index of the current pixel in the flat array
    int pixel_idx = (y * width + x) * CHANNELS;

    // Gradient Color Algorithm
    auto r = static_cast<unsigned char>(x * 255.0f / width); // Red: Horizontal gradient (left→right)
    auto g = static_cast<unsigned char>(y * 255.0f / height); // Green: Vertical gradient (top→bottom)
    unsigned char b = 128; // Blue: Fixed value

    // Write pixel data to GPU memory
    d_pixels[pixel_idx + 0] = r;
    d_pixels[pixel_idx + 1] = g;
    d_pixels[pixel_idx + 2] = b;
}

// ===================== Global Kernel (Only entry point callable by CPU) =====================
// Computes thread coordinates and invokes the device-only gradient function
__global__ void KernelMain(
    unsigned char *d_pixels,
    int width,
    int height
) {
    // Calculate pixel coordinates (x: column, y: row)
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    // Boundary check: skip threads outside the image dimensions
    if (x >= width || y >= height) return;

    // Invoke the device-only gradient generation function
    GenerateGradientPPM(d_pixels, x, y, width, height);
}

// Write pixel data to PPM image file (Binary P6 format)
void WritePPM(const char *filename, unsigned char *pixels, int width, int height) {
    FILE *fp = fopen(filename, "wb"); // Write binary mode
    if (!fp) {
        fprintf(stderr, "Error: Failed to open file!\n");
        exit(EXIT_FAILURE);
    }

    // Write PPM header (P6 = binary RGB, 255 = max color value)
    fprintf(fp, "P6\n%d %d\n255\n", width, height);
    // Write raw pixel data
    fwrite(pixels, sizeof(unsigned char), width * height * CHANNELS, fp);

    fclose(fp);
    printf("Gradient image generated successfully: %s\n", filename);
}

// Main Function (CPU Host Code)
int main() {
    // Calculate total memory size for pixel data
    size_t pixel_bytes = IMG_WIDTH * IMG_HEIGHT * CHANNELS * sizeof(unsigned char);

    // Allocate host (CPU) memory
    auto *h_pixels = static_cast<unsigned char *>(malloc(pixel_bytes));
    if (!h_pixels) {
        fprintf(stderr, "Error: Host memory allocation failed!\n");
        exit(EXIT_FAILURE);
    }

    // Allocate device (GPU) memory
    unsigned char *d_pixels;
    CHECK_CUDA_ERROR(cudaMalloc(&d_pixels, pixel_bytes));

    // Configure CUDA grid and block dimensions (2D layout for 2D image)
    dim3 block_size(16, 16); // 16x16 threads per block (CUDA best practice)
    dim3 grid_size(
        (IMG_WIDTH + block_size.x - 1) / block_size.x,
        (IMG_HEIGHT + block_size.y - 1) / block_size.y
    );

    // Launch CUDA kernel on GPU
    printf("Launching CUDA kernel...\n");
    KernelMain<<<grid_size, block_size>>>(d_pixels, IMG_WIDTH, IMG_HEIGHT);

    // Check for kernel launch errors
    CHECK_CUDA_ERROR(cudaGetLastError());
    // Wait for GPU to finish execution
    CHECK_CUDA_ERROR(cudaDeviceSynchronize());

    // Copy processed pixel data from GPU back to CPU
    CHECK_CUDA_ERROR(cudaMemcpy(h_pixels, d_pixels, pixel_bytes, cudaMemcpyDeviceToHost));

    // Generate the final PPM image file
    WritePPM("gradient.ppm", h_pixels, IMG_WIDTH, IMG_HEIGHT);

    // Free allocated memory (GPU first, then CPU)
    CHECK_CUDA_ERROR(cudaFree(d_pixels));
    free(h_pixels);

    return 0;
}
