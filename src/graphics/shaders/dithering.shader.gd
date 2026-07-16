


extends Resource
var shader_code: = \
\
\
\
\
\
\
"\r\nshader_type canvas_item;\r\nvoid fragment() {\r\n\tCOLOR.rgb = vec3(fract(sin(dot(SCREEN_UV, vec2(12.9898, 78.233))) * 43758.5453)) * 0.3;\r\n\tCOLOR.a = 0.02;\r\n}\r\n\r\n"