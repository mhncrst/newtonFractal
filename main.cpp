

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include "newton_ispc.h"

#include <vector>
#include <iostream>
#include <cstdint>

extern "C" void render(int32_t width, int32_t height, float xmin, float xmax, float ymin, float ymax, uint8_t * outRGBA);

int main() {
    const int width  = 1024;
    const int height = 1024;

    // Bounds to render
    const float xmin = -2.0f;
    const float xmax =  2.0f;
    const float ymin = -2.0f;
    const float ymax =  2.0f;

    std::vector<uint8_t> rgba(width * height * 4);

    // Call the ISPC-render function generated in newton_ispc.h
    // Signature: render(int32_t width, int32_t height, float xmin, float xmax, float ymin, float ymax, uint8_t * outRGBA);
    render(width, height, xmin, xmax, ymin, ymax, rgba.data());

    // Write PNG
    if (!stbi_write_png("out.png", width, height, 4, rgba.data(), width * 4)) {
        std::cerr << "Failed to write out.png\n";
        return 1;
    }

    std::cout << "Wrote out.png\n";
    return 0;
}
