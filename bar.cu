#include <cstdio>
#include <iostream>

#include <cuda.h>
#include <cuda_runtime.h>

#include "cudaCheck.h"

__global__
void bar() {
  printf("bar\n");
}

#ifdef MAY_CRASH
__global__
void crash() {
  bar<<<1,1>>>();
  cudaDeviceSynchronize();
}
#endif  // MAY_CRASH

void wrapper() {
  bar<<<1,1>>>();
  cudaCheck(cudaGetLastError());
  cudaDeviceSynchronize();
  cudaCheck(cudaGetLastError());
}

struct Me {

  Me() {
   std::cout << "Loaded" << std::endl;
   wrapper();
  }

};

Me me;
