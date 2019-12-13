# Instructions

  * edit the [Makefile](Makefile) to point `CUDA_BASE` to a CUDA installation (e.g. `CUDA_BASE = /usr/local/cuda')
  * run `make` to build all binaries:
    ```bash
    $ make
    /usr/local/cuda/bin/nvcc --generate-line-info --source-in-ptx --expt-relaxed-constexpr --expt-extended-lambda -std=c++14 -O2 --cudart=shared -gencode arch=compute_50,code=sm_50 --compiler-options "-O2 -pthread -fPIC" -dc foo.cu -o foo.o
    /usr/local/cuda/bin/nvcc --generate-line-info --source-in-ptx --expt-relaxed-constexpr --expt-extended-lambda -std=c++14 -O2 --cudart=shared -gencode arch=compute_50,code=sm_50 --compiler-options "-O2 -pthread -fPIC" -dlink foo.o -o foo_dlink.o
    g++ -O2 -pthread -fPIC --shared foo.o foo_dlink.o -L/usr/local/cuda/lib64 -lcudart -lcudadevrt -Wl,-rpath -Wl,/usr/local/cuda/lib64 -o libfoo.so
    /usr/local/cuda/bin/nvcc --generate-line-info --source-in-ptx --expt-relaxed-constexpr --expt-extended-lambda -std=c++14 -O2 --cudart=shared -gencode arch=compute_50,code=sm_50 --compiler-options "-O2 -pthread -fPIC" -dc bar.cu -o bar.o
    /usr/local/cuda/bin/nvcc --generate-line-info --source-in-ptx --expt-relaxed-constexpr --expt-extended-lambda -std=c++14 -O2 --cudart=shared -gencode arch=compute_50,code=sm_50 --compiler-options "-O2 -pthread -fPIC" -dlink bar.o -o bar_dlink.o
    g++ -O2 -pthread -fPIC --shared bar.o bar_dlink.o -L/usr/local/cuda/lib64 -lcudart -lcudadevrt -Wl,-rpath -Wl,/usr/local/cuda/lib64 -o libbar.so
    g++ -O2 -pthread -fPIC main.cc -L. -lfoo -ldl -Wl,-rpath -Wl,. -L/usr/local/cuda/lib64 -lcudart -lcudadevrt -Wl,-rpath -Wl,/usr/local/cuda/lib64 -o test
    /usr/local/cuda/bin/nvcc --generate-line-info --source-in-ptx --expt-relaxed-constexpr --expt-extended-lambda -std=c++14 -O2 --cudart=shared -gencode arch=compute_50,code=sm_50 --compiler-options "-O2 -pthread -fPIC" -DMAY_CRASH -dc bar.cu -o bar_crash.o
    /usr/local/cuda/bin/nvcc --generate-line-info --source-in-ptx --expt-relaxed-constexpr --expt-extended-lambda -std=c++14 -O2 --cudart=shared -gencode arch=compute_50,code=sm_50 --compiler-options "-O2 -pthread -fPIC" -dlink bar_crash.o -o bar_crash_dlink.o
    g++ -O2 -pthread -fPIC --shared bar_crash.o bar_crash_dlink.o -L/usr/local/cuda/lib64 -lcudart -lcudadevrt -Wl,-rpath -Wl,/usr/local/cuda/lib64 -o libbar_crash.so
    g++ -DMAY_CRASH -O2 -pthread -fPIC main.cc -L. -lfoo -ldl -Wl,-rpath -Wl,. -L/usr/local/cuda/lib64 -lcudart -lcudadevrt -Wl,-rpath -Wl,/usr/local/cuda/lib64 -o crash
    ```
  * run `test`:
    ```
    $ ./test
    Hello
    Loaded
    bar
    ```
  * run `crash`:
    ```
    $ ./crash
    Hello
    Loaded
    bar.cu, line 24: cudaErrorInvalidDeviceFunction: invalid device function
    ```

# Description

`main()` does

  * call `fooWrapper()` from foo.cc, which in turns launches a CUDA kernel `foo<<<1,1>>>()`
  * dynamically loads a shared library libbar.so
  * upon loading, libbar.so calls `wrapper()` which in turn calls a CUDA kernel `bar<<<1,1>>>()`
  * if, inside libbar.so, there is another kernel that makes use of dynamic parallelism (e.g. it calls
    `bar<<<1,1>>>()` and `cudaDeviceSynchronize()`), the call to `bar<<<1,1>>>()` will fail
     **even if the kernel with dynamic parallelism is never called**
