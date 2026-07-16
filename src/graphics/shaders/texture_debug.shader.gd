


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
"\r\nshader_type canvas_item;\r\nbool bapprox_eq_vec4(vec4 a, vec4 b) { \r\n\treturn all(lessThan(abs(a - b), vec4(0.001)));\r\n}\r\nvoid fragment() {\r\n\tvec4 c = texture(TEXTURE, UV);\r\n\tfloat a = float(bapprox_eq_vec4(c, vec4(0)));\r\n\tCOLOR = mix(c, vec4(1, 0, 0, 1), a);\r\n}\r\n\r\n"