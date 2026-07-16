


extends Resource
var shader_code: = \
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
"\r\nshader_type canvas_item;\r\nconst float size = 8192.0;\r\nconst float board_size = 2048.0;\r\nconst float origin = 3072.0;\r\nconst float PI = 3.14159265359;\r\nconst float triangle_ratio = 0.866025403784438; \r\nuniform vec4 color_primary: hint_color = vec4(0.23, 0.28, 0.35, 1.0);\r\nuniform vec4 color_secondary: hint_color = vec4(0.2, 0.2, 0.3, 1.0);\r\nuniform vec4 color_grid: hint_color;\r\nuniform float zoom = 1.0;\r\nuniform float amount = 128.0;\r\nconst float gridscale = 128.0;\r\nuniform float is_grid_visible = 1.0;\r\nuniform float elapsed_time = 0.0;\r\nfloat rand(vec2 coords){\r\n    return fract(sin(dot(coords, vec2(12.9898, 78.233))) * 43758.5453);\r\n}\r\nfloat get_triangle_grid(vec2 uv, float time) {\r\n    uv = vec2(uv.y, uv.x); \r\n    uv.y /= triangle_ratio;\r\n    vec2 triangle_uv = floor(uv);\r\n    triangle_uv.x *= 2.0;\r\n    float mod_y = floor(mod(triangle_uv.y, 2.0));\r\n    vec2 shape = vec2(fract(uv.x + mod_y * 0.5) - 0.5, fract(uv.y));\r\n    if (shape.y > abs(shape.x) * 2.0) {\r\n        triangle_uv.x += shape.x < 0.0 ? 1.0 : -1.0;\r\n    }\r\n    if (shape.x >= 0.0 && mod_y == 0.0) {\r\n        triangle_uv.x += 2.0;\r\n    }\r\n    return rand(triangle_uv) < 0.9 ? rand(triangle_uv) * 0.5 : sin(mod(time * rand(triangle_uv), PI) * 2.0) * 0.5 + 0.0;\r\n}\r\nvoid fragment() {\r\n\tconst float scale = 1600.0;\r\n\tconst float contrast = 0.6; \r\n\tfloat value = get_triangle_grid(UV * scale, elapsed_time + 548455.0) * contrast;\r\n    vec3 triangle_grid = mix(color_primary.rgb, color_secondary.rgb, value);\r\n\tfloat pxsize = (gridscale / size) * 1.5; \r\n\tfloat smoothness = 1.0 * pxsize; \r\n\tfloat thickness = 1.5 * pxsize;\r\n\tfloat gridsize = 6.0 * pxsize;\r\n\tsmoothness *= mix(1.0, zoom * 5.0, float(zoom < 0.15)); \r\n\tthickness *= mix(1.0, 1.5, float(zoom > 1.5)); \r\n\tvec2 wave = sin(fract(UV * amount) * PI);\r\n\tvec2 line = smoothstep(thickness - smoothness, thickness + smoothness, wave);\r\n\tvec2 mask = smoothstep(gridsize - smoothness, gridsize + smoothness, wave);\r\n\tfloat grid = 1.0 - min(max(line.x, mask.y), max(line.y, mask.x));\r\n\tCOLOR.rgb = vec3(grid);\r\n\tvec2 uv_scaled = UV * size;\r\n\tfloat tpx = 7.0; \r\n\tfloat end = origin + board_size;\r\n\tfloat board_mask = float(uv_scaled.x > origin && uv_scaled.x < end);\r\n\tboard_mask *= float(uv_scaled.y > origin && uv_scaled.y < end);\r\n\tfloat grid_mask = float(uv_scaled.x > origin + tpx && uv_scaled.x < end - tpx);\r\n\tgrid_mask *= float(uv_scaled.y > origin + tpx && uv_scaled.y < end - tpx);\r\n\tCOLOR.rgb = vec3(triangle_grid * 0.5) * clamp(board_mask + 0.9, 0, 1);\r\n\tCOLOR.rgb = mix(COLOR.rgb, color_grid.rgb, float(is_grid_visible) * grid * grid_mask);\r\n\tCOLOR.rgb *= vec3(0.1, 0.1, 0.2) * SCREEN_UV.y + 1.0;\r\n\tCOLOR.a = min(1.0, sin(UV.x * 3.14) * 2.0) * min(1.0, sin(UV.y * PI) * 2.0);\r\n}\r\n\r\n"