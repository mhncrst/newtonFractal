// newton.ispc
// Newton fractal for POLY(z) = z^5 - 1
// Exports: render(width, height, xmin, xmax, ymin, ymax, outRGBA)

export void render(uniform int width,
                   uniform int height,
                   uniform float xmin,
                   uniform float xmax,
                   uniform float ymin,
                   uniform float ymax,
                   uniform uint8 * uniform outRGBA)
{
    uniform int total = width * height;

    // Precompute root positions for z^5 = 1 using uniform temporaries
    uniform float two_pi = 6.28318530717958647692f;
    uniform float root_re[5];
    uniform float root_im[5];
    for (uniform int r = 0; r < 5; ++r) {
        uniform float ang = two_pi * r / 5.0f;
        root_re[r] = cos(ang);
        root_im[r] = sin(ang);
    }

    // Parameters
    uniform int maxIters = 256;
    uniform float tol = 1e-6f;

    foreach (i = 0 ... total) {
        // compute pixel coords
        int px = i % width;
        int py = i / width;

        float u = (px + 0.5f) / (float)width;
        float v = (py + 0.5f) / (float)height;

        // map to complex plane
        float x = xmin + u * (xmax - xmin);
        float y = ymin + v * (ymax - ymin);

        // complex z = x + i*y
        float zr = x;
        float zi = y;

        int iter = 0;
        int whichRoot = -1;
        float smooth = 0.0f;

        for (iter = 0; iter < maxIters; ++iter) {
            // compute z^2
            float zr2 = zr*zr - zi*zi;
            float zi2 = 2.0f*zr*zi;
            // z^4 = (z^2)^2
            float zr4 = zr2*zr2 - zi2*zi2;
            float zi4 = 2.0f*zr2*zi2;
            // z^5 = z * z^4
            float zr5 = zr*zr4 - zi*zi4;
            float zi5 = zr*zi4 + zi*zr4;

            // P = z^5 - 1
            float pr = zr5 - 1.0f;
            float pi = zi5;

            // P' = 5 * z^4
            float dpr = 5.0f * zr4;
            float dpi = 5.0f * zi4;

            // Newton step: z = z - P/P'
            float denom = dpr*dpr + dpi*dpi;
            if (denom == 0.0f) break;
            float qre = (pr*dpr + pi*dpi) / denom;
            float qim = (pi*dpr - pr*dpi) / denom;

            zr = zr - qre;
            zi = zi - qim;

            // test distance to any root
            float bestDist2 = 1e30f;
            int bestIdx = -1;
            for (int r = 0; r < 5; ++r) {
                float dx = zr - root_re[r];
                float dy = zi - root_im[r];
                float d2 = dx*dx + dy*dy;
                if (d2 < bestDist2) {
                    bestDist2 = d2;
                    bestIdx = r;
                }
            }

            if (bestDist2 < tol*tol) {
                whichRoot = bestIdx;
                float absP = sqrt(pr*pr + pi*pi);
                smooth = iter + 1 - log(max(absP, 1e-12f)) / log(2.0f);
                break;
            }
        }

        if (whichRoot == -1) {
            float bestDist2 = 1e30f;
            int bestIdx = 0;
            for (int r = 0; r < 5; ++r) {
                float dx = zr - root_re[r];
                float dy = zi - root_im[r];
                float d2 = dx*dx + dy*dy;
                if (d2 < bestDist2) { bestDist2 = d2; bestIdx = r; }
            }
            whichRoot = bestIdx;
            smooth = maxIters;
        }

        // color palette (five distinct saturated colors)
        int colr[5] = { 255, 0, 255, 255, 255 };
        int colg[5] = {   0, 255, 255, 128,   0 };
        int colb[5] = {   0,   0,   0, 128, 255 };

        float t = smooth / (float)maxIters;
        t = clamp(t, 0.0f, 1.0f);
        float bright = 0.2f + 0.8f * (1.0f - t);

        uint8 r8 = (uint8) (colr[whichRoot] * bright);
        uint8 g8 = (uint8) (colg[whichRoot] * bright);
        uint8 b8 = (uint8) (colb[whichRoot] * bright);

        int idx = 4 * i;
        outRGBA[idx + 0] = r8;
        outRGBA[idx + 1] = g8;
        outRGBA[idx + 2] = b8;
        outRGBA[idx + 3] = (uint8)255;
    }
}
