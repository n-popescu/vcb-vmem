


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
"\r\nshader_type canvas_item;\r\nuniform sampler2D smp_vdisplay;\r\nuniform float is_valid = 1.0;\r\nuniform float is_render_texture = 0.0;\r\nuniform vec2 size = vec2(4, 4);\r\nuniform float flip_x_axis = 0.0;\r\nvoid fragment() {\r\n\tfloat check = mod(floor(UV.x * size.x) + floor(UV.y * size.y), 2);\r\n\tfloat blink = (sin(TIME * 10.0) + 1.0) / 2.0;\r\n\tvec3 editing_ok = mix(vec3(0.08, 0.095, 0.12), vec3(0.1, 0.12, 0.15), check);\r\n\tvec3 editing_invalid = mix(vec3(0.5, 0.1, 0.1), vec3(0.7, 0.1, 0.1), blink);\r\n\tvec3 editor_color = mix(editing_invalid, editing_ok, is_valid);\r\n\tvec2 uv = mix(UV, vec2(1.0 - UV.x, UV.y), flip_x_axis);\r\n\tvec3 vdisplay_tex = texture(smp_vdisplay, uv).rgb;\r\n\tCOLOR = vec4(mix(editor_color, vdisplay_tex, is_render_texture), 1.0);\r\n}\r\n\r\n"