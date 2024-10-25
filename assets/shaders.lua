step_shader = [[

uniform number shade;
uniform number shade_r;
uniform number shade_g;
uniform number shade_b;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 pixel = Texel(texture, texture_coords);
    pixel = mix(pixel, vec4(shade_r, shade_g, shade_b, pixel.a), 1-shade);
    return pixel;
}

]]