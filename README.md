# Newton Fractal Visualization

This project generates a Newton fractal for the equation z^5 - 1 = 0 using ISPC for parallel computation and C++ for orchestration. Each pixel represents a complex starting point and is colored based on which root it converges to and how quickly.

The fractal is rendered using Newton's method and saved as a PNG image. The code uses stb_image_write for image output and CMake for building.

Files included:
main.cpp - C++ driver
newton.ispc - ISPC kernel
CMakeLists.txt - Build configuration
stb_image_write.h - Image writer

To build:
Use CMake with NMake Makefiles and run the resulting executable to produce out.png
