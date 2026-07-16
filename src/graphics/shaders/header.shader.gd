


extends Resource
var shader_code: = \
\
\
\
\
\
\
\
"\r\nshader_type canvas_item;\r\nuniform vec4 color : hint_color;\r\nvoid fragment() {\r\n\tvec4 screen = textureLod(SCREEN_TEXTURE, SCREEN_UV, 3);\r\n\tCOLOR.rgb = mix(screen.rgb, color.rgb, 0.95);\r\n}\r\n\r\n"