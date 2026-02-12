uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
uniform sampler2D texture1;

// --- API PARAMETERS ---
uniform float u_refractionAmount;
uniform float u_refractionHeight;

// --- 1. SDF SHAPES ---
float sdRoundedBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

// --- 2. MAP FUNCTION ---
float map(vec2 p) {
    vec2 mouseP = (mouse.xy - 0.5 * resolution.xy) / resolution.y;
    float dBox = sdRoundedBox(p, vec2(0.7, 0.18), 0.18);
    float dMouse = length(p - mouseP) - 0.15;
    return smin(dBox, dMouse, 0.2);
}

// --- 3. HEIGHT MAP ---
float getHeight(vec2 p) {
    float d = map(p);
    return smoothstep(0.0, u_refractionHeight, -d);
}

void main(void) {
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec2 p = (gl_FragCoord.xy - 0.5 * resolution.xy) / resolution.y;

    float d = map(p);

    // Normal Calculation
    vec2 e = vec2(0.002, 0.0);
    float h = getHeight(p);
    float h_x = getHeight(p + e.xy) - h;
    float h_y = getHeight(p + e.yx) - h;
    vec3 normal = normalize(vec3(-h_x * 8.0, -h_y * 8.0, 1.0));

    // Bevel Mask
    float bevelMask = (1.0 - smoothstep(0.95, 1.0, h)) * step(d, 0.0);

    // --- 4. REFRACTION FIX ---
    vec2 refractOffset = normal.xy * u_refractionAmount * bevelMask;

    // REMOVED THE CLAMP (This was causing grey edges)
    vec2 finalUV = uv + refractOffset;

    // Sample Texture
    vec3 texColor = texture2D(texture1, finalUV).rgb;

    // --- 5. COLOR BOOST (Fixes "Whitish" look) ---
    // If we are on the bevel, boost saturation slightly to counteract washout
    if (bevelMask > 0.0) {
        vec3 gray = vec3(dot(texColor, vec3(0.299, 0.587, 0.114)));
        texColor = mix(gray, texColor, 1.2); // 1.2 = 20% more saturated
    }

    // --- 6. LIGHTING TUNED ---
    vec4 color = vec4(texColor, 1.0);

    // Specular (Keep this sharp white)
    vec3 lightDir = normalize(vec3(-0.5, 1.0, 0.5));
    float spec = pow(max(dot(normal, lightDir), 0.0), 30.0);

    // Rim Light (Reduced intensity to avoid "fog")
    // Multiplied by 0.3 instead of 0.5
    float rim = pow(max(dot(normal, vec3(0.0, -1.0, 0.2)), 0.0), 4.0) * 0.3;

    // Apply lighting
    color.rgb += (spec + rim) * bevelMask;

    // REMOVED the "white tint" line (color.rgb += vec3(0.1) * bevelMask)
    // This was literally just adding white to the liquid. Gone now.

    if (d > 0.0) {
        color = texture2D(texture1, uv);
    }

    gl_FragColor = color;
}
