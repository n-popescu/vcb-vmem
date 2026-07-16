


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
"\r\nshader_type canvas_item;\r\nuniform float zoom = 1.0;\r\nuniform float steps = 21;\r\nuniform float depth_factor = 1.0;\r\nvoid fragment() {\r\n\tCOLOR = texture(TEXTURE, UV);\r\n\tvec2 depth = vec2(0.385) * vec2(TEXTURE_PIXEL_SIZE.x, -TEXTURE_PIXEL_SIZE.y) * depth_factor;\r\n\tvec4 brightness = vec4(0.5, 0.5, 0.6, 0.55);\r\n\tvec4 wall = COLOR;\r\n\tfor (int i = 0; i < int(round(steps)); i++) {\r\n\t\tvec2 depth_uv = UV + (depth / steps) * float(i + 1);\r\n\t\tvec4 c = mix(texture(TEXTURE, depth_uv), vec4(0), float(depth_uv.x > 1.0 || depth_uv.y < 0.0));\r\n\t\twall = mix(c * brightness * (1.0 - float(i) / (steps * 2.0)), wall, wall.a);\r\n\t\twall.a = ceil(wall.a);\r\n\t}\r\n\tvec2 shadow_depth = vec2(0.525) * vec2(TEXTURE_PIXEL_SIZE.x, -TEXTURE_PIXEL_SIZE.y) * depth_factor;\r\n\tfloat shadow_opacity = 0.21;\r\n\tfloat shadow = 0.0;\r\n\tfor (int i = 0; i < int(round(steps)); i++) {\r\n\t\tvec2 depth_uv = UV + (shadow_depth / steps) * (float(i) + steps);\r\n\t\tfloat s = mix(texture(TEXTURE, depth_uv).a, 0.0, float(depth_uv.x > 1.0 || depth_uv.y < 0.0));\r\n\t\tshadow += s * (shadow_opacity / steps);\r\n\t}\r\n\tCOLOR = mix(wall, vec4(0), 1.0 - wall.a);\r\n\tCOLOR.rgb += vec3(0, 0, 0.05) * (1.0 - COLOR.a);\r\n\tCOLOR.a = mix(shadow, 1.0, COLOR.a);\r\n\tCOLOR.rgb *= vec3(0.2, 0.2, 0.3) * SCREEN_UV.y + 1.0;\r\n}\r\n\r\n"