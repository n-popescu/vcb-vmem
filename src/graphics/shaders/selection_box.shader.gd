


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
"\r\nshader_type canvas_item;\r\nuniform float opacity = 0.2;\r\nuniform float width = 1.0;\r\nuniform vec2 size = vec2(0);\r\nuniform float zoom = 1.0;\r\nuniform bool is_move = false;\r\nvoid fragment() {\r\n\tfloat PI = 3.14159265359;\r\n\tfloat t = PI / 4.0;\t\r\n\tfloat w = 0.8 * (1.0 / zoom);\r\n\tfloat offset = TIME * 10.0 * zoom * float(is_move);\r\n\tfloat stripeVal = round(cos(((UV.x * size.x - offset) * cos(t) * w) + ((UV.y * size.y - offset) * sin(t) * w)) + 0.5); \r\n\tstripeVal = clamp(stripeVal, 0, 1);\r\n\tfloat border = 0.0;\r\n\tborder += float(UV.x * size.x > size.x - width * zoom);\r\n\tborder += float(UV.x * size.x < width * zoom);\r\n\tborder += float(UV.y * size.y > size.y - width * zoom);\r\n\tborder += float(UV.y * size.y < width * zoom);\r\n\tborder = clamp(border, 0, 1);\r\n\tfloat border_inv = 1.0 - border;\r\n\tfloat alpha = clamp((opacity * 0.0) + (border), 0, 1);\r\n\tCOLOR = vec4(vec3(stripeVal), alpha);\r\n}\r\n\r\n"