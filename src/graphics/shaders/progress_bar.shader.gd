


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
"\r\nshader_type canvas_item;\r\nuniform vec2 size = vec2(1898, 14);\r\nuniform float progress = 0.5;\r\nuniform vec4 c1 : hint_color; \r\nuniform vec4 c2 : hint_color; \r\nuniform vec4 c3 : hint_color;\r\nuniform vec4 c4 : hint_color;\r\nconst float PI = 3.14159265359;\r\nconst float t = PI / 6.0;\r\nconst float w = 0.17;\r\nvoid fragment() {\r\n\tfloat offset = TIME * 0.0; \r\n\toffset = progress * 150.0;\r\n\tfloat stripeVal = (cos(((UV.x * size.x - offset) * cos(t) * w) + ((UV.y * size.y - offset) * sin(t) * w)) + 0.6); \r\n\tstripeVal = clamp((stripeVal - 0.5) * 3.0, 0, 1);\r\n\tCOLOR.rgb = mix(c1.rgb, c2.rgb, stripeVal);\r\n\tCOLOR.a = float(progress > UV.x);\r\n}\r\n\r\n"