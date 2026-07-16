


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
"\r\nshader_type canvas_item;\r\nuniform vec2 size = vec2(1024); \r\nvoid fragment() {\r\n\tvec2 uvst = floor(UV * size) / size; \r\n\tvec2 pxsize = TEXTURE_PIXEL_SIZE;\r\n\tvec4 tl = texture(TEXTURE, uvst);\r\n\tvec4 tr = texture(TEXTURE, uvst + vec2(0, 1) * pxsize);\r\n\tvec4 bl = texture(TEXTURE, uvst + vec2(1, 0) * pxsize);\r\n\tvec4 br = texture(TEXTURE, uvst + vec2(1, 1) * pxsize);\r\n\tvec4 c = tl; \r\n\tc = mix(c, tr + c, float(tr.a > 0.1));\r\n\tc = mix(c, bl + c, float(bl.a > 0.1));\r\n\tc = mix(c, br + c, float(br.a > 0.1));\r\n\tc /= max(1.0, c.a); \r\n\tCOLOR = c;\r\n\tCOLOR.rgb *= vec3(0.2, 0.2, 0.3) * SCREEN_UV.y + 1.0;\t\r\n}\r\n\r\n"