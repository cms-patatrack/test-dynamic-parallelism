#include <iostream>

#include <dlfcn.h>

void fooWrapper();
void doCheck();

int main() {
  fooWrapper();
#ifdef MAY_CRASH
  dlopen("libbar_crash.so", RTLD_LAZY|RTLD_GLOBAL);
#else
  dlopen("libbar.so", RTLD_LAZY|RTLD_GLOBAL);
#endif
  doCheck();
  return 0;
}
