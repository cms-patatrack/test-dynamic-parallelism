.PHONY: all clean

CUDA_BASE:=/usr/local/cuda-10.1.168

CXX = g++
CXX_FLAGS = -O2 -pthread -fPIC
LD_FLAGS  = -L$(CUDA_BASE)/lib64 -lcudart -lcudadevrt -Wl,-rpath -Wl,$(CUDA_BASE)/lib64

NVCC = $(CUDA_BASE)/bin/nvcc
NVCC_FLAGS = --generate-line-info --source-in-ptx --expt-relaxed-constexpr --expt-extended-lambda -std=c++14 -O2 --cudart=shared -gencode arch=compute_50,code=sm_50 --compiler-options "$(CXX_FLAGS)"


all: test crash

clean:
	rm -f *.o *.so test crash

bar.o: bar.cu
	$(NVCC) $(NVCC_FLAGS) -dc $^ -o $@

bar_dlink.o: bar.o
	$(NVCC) $(NVCC_FLAGS) -dlink $< -o $@

libbar.so: bar.o bar_dlink.o
	$(CXX) $(CXX_FLAGS) --shared $^ $(LD_FLAGS) -o $@

bar_crash.o: bar.cu
	$(NVCC) $(NVCC_FLAGS) -DMAY_CRASH -dc $^ -o $@

bar_crash_dlink.o: bar_crash.o
	$(NVCC) $(NVCC_FLAGS) -dlink $< -o $@

libbar_crash.so: bar_crash.o bar_crash_dlink.o
	$(CXX) $(CXX_FLAGS) --shared $^ $(LD_FLAGS) -o $@

foo.o: foo.cu
	$(NVCC) $(NVCC_FLAGS) -dc foo.cu -o $@

foo_dlink.o: foo.o
	$(NVCC) $(NVCC_FLAGS) -dlink foo.o -o $@

libfoo.so: foo.o foo_dlink.o
	$(CXX) $(CXX_FLAGS) --shared $^ $(LD_FLAGS) -o $@

test: main.cc libfoo.so libbar.so
	$(CXX) $(CXX_FLAGS) $< -L. -lfoo -ldl -Wl,-rpath -Wl,. $(LD_FLAGS) -o $@

crash: main.cc libfoo.so libbar_crash.so
	$(CXX) -DMAY_CRASH $(CXX_FLAGS) $< -L. -lfoo -ldl -Wl,-rpath -Wl,. $(LD_FLAGS) -o $@
