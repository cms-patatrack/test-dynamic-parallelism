#include <cuda.h>

#include <cstdio>

#include "cudaCheck.h"

__global__ 
void foo() {
   printf("Hello\n");
}

void fooWrapper() {
  foo<<<1,1>>>();
  cudaCheck(cudaGetLastError());
  cudaCheck(cudaDeviceSynchronize());
}

void doCheck() {
  cudaCheck(cudaDeviceSynchronize());
  cudaCheck(cudaGetLastError());
}
