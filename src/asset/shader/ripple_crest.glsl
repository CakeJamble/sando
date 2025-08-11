extern number time;      // seconds since ripple start
extern number speed;     // how fast crest moves across
extern number amplitude; // vertical displacement in pixels
extern number width;     // width of the crest in texture coords (0–1)
extern number startX;    // ripple start position (0–1)
extern number dir;       // 1 for left->right, -1 for right->left

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
{
    // Calculate crest position based on time and speed
    float crestX = startX + dir * time * speed;

    // Distance from current pixel to crest position
    float dist = uv.x - crestX;

    // If within crest width, displace vertically
    if (abs(dist) < width)
    {
        // normalized distance [ -1 .. 1 ]
        float norm = dist / width;

        // Smooth bulge shape (1 at center, 0 at edges)
        float bulge = 1.0 - norm * norm; // parabolic falloff
        float offset = bulge * amplitude / love_ScreenSize.y;

        uv.y += offset;
    }

    return Texel(texture, uv) * color;
}
