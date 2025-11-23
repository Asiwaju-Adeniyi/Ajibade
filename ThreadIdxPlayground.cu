#include <iostream>
#include <vector>
#include <cstdio> 
#include <cuda_runtime.h>

__global__ void PrintTidKernel(int* PrintId) {
    int Idx = blockIdx.x * blockDim.x + threadIdx.x;
    PrintId[Idx] = Idx;}

__global__ void EvenOddKernel (int* output, int N) {
   int tid = blockIdx.x * blockDim.x + threadIdx.x;
   if (tid < N) {
    if (tid % 2 == 0) {
        output[tid] = 1;
    } else{
        output[tid] = 0;
    }
   }
}

int main() {

      int N = 987;

    int* h_output = new int[N];
    int* d_output;
    cudaMalloc((void**)&d_output, N * sizeof(int));

    int numThreadsPerBlock = 16;
    int numBlocks = (N + numThreadsPerBlock - 1) / numThreadsPerBlock;


    PrintThreadIdx <<<numBlocks, numThreadsPerBlock>>> (d_output);
    cudaMemcpy(h_output, d_output, N * sizeof(int), cudaMemcpyDeviceToHost);

    std::cout << "Thread IDs: " << std::endl;

    for (int i = 0; i < N; i++) {
        std::cout << h_output[i] << std::endl;
    }

    std::cout << std::endl;

    cudaMemcpy(d_output, h_output, N * sizeof(int), cudaMemcpyHostToDevice);
    
    EvenOddKernel<<<numBlocks, numThreadsPerBlock>>> (d_output, N);
    cudaMemcpy(h_output, d_output, N * sizeof(int), cudaMemcpyDeviceToHost);

    std::cout << "Even/Odd Markers: " << std::endl;
   for (int i = 0; i < N; i++) {
        std::cout << h_output[i] << std::endl;
    }

    std::cout << std::endl;

delete[] h_output;
cudaFree(d_output);

return 0;
}
