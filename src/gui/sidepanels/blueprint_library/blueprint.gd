


extends Resource
class_name Blueprint
enum DATA_BLOCK{
	LAYER_LOGIC = 0, 
	LAYER_DECO_ON = 1, 
	LAYER_DECO_OFF = 2, 
	NAME = 1024, 
	DESCRIPTION = 1025, 
	TAGS = 1026, 
}
const MAX_DATA_BLOCKS = 6
const COMPRESSION_MODE: = File.COMPRESSION_ZSTD
var bpname: = ""
var layers: = [null, null, null]
var description: = ""
var tags: = PoolStringArray()
var thumbnail: = PoolByteArray()
var width: = 0
var height: = 0
var is_thumbnail_ok: = false
var error_msg: = ""
func public_get_copy() -> Resource:
	var copy: = self.duplicate()
	if copy.public_create_from_string(public_get_string_full()) == OK:
		pass
	return copy
func public_create_from_selection(p_selection_layers: Array) -> void :
	error_msg = ""
	width = p_selection_layers[0].get_width()
	height = p_selection_layers[0].get_height()
	for layer_idx in 3:
		if p_selection_layers[layer_idx] == null:
			layers[layer_idx] = null
			continue
		var img_data: PoolByteArray = p_selection_layers[layer_idx].duplicate().get_data()
		var img_data_compressed: = img_data.compress(COMPRESSION_MODE)
		var bytes_buffer_size: = int2bytes(img_data.size(), 4)
		layers[layer_idx] = bytes_buffer_size + img_data_compressed
func public_create_from_string(p_blueprint: String) -> int:
	error_msg = "Invalid blueprint."
	p_blueprint = p_blueprint.strip_edges()
	p_blueprint = p_blueprint.strip_escapes()
	if p_blueprint.empty():
		error_msg = "Invalid blueprint."
		return FAILED
	if p_blueprint.begins_with("KLUv/"):
		return bp_load_legacy(p_blueprint)
	elif p_blueprint.begins_with("VCB+"):
		pass
	else:
		error_msg = "Invalid blueprint."
		return FAILED
	var variant = Marshalls.base64_to_raw(p_blueprint)
	if not variant is PoolByteArray:
		error_msg = "Blueprint corrupted: invalid Base64."
		return FAILED
	var compressed_data: PoolByteArray = variant
	if compressed_data.empty():
		error_msg = "Blueprint corrupted: invalid Base64."
		return FAILED
	if compressed_data.size() <= 16:
		error_msg = "Blueprint corrupted: data missing."
		return FAILED
	var version: = bytes2int(compressed_data, 3, 3)
	if not version == 0:
		error_msg = "Incompatible blueprint version."
		return FAILED
	var integrity_hash: = bytes2int(compressed_data, 6, 6)
	if not integrity_hash == bytes2int(p_blueprint.right(16).sha1_buffer(), 0, 6):
		error_msg = "Blueprint corrupted: checksum failed."
		return FAILED
	var new_width: = bytes2int(compressed_data, 12, 4)
	var new_height: = bytes2int(compressed_data, 16, 4)
	var new_layers: = [null, null, null]
	var new_name: = ""
	var new_description: = ""
	var new_tags: = PoolStringArray()
	var offset: = 20
	var is_logic_layer_included: = false
	for i in MAX_DATA_BLOCKS:
		var block_size: = bytes2int(compressed_data, offset, 4)
		var layer_id: = bytes2int(compressed_data, offset + 4, 4)
		var buffer_size: = bytes2int(compressed_data, offset + 8, 4)
		if (block_size < 12) or (buffer_size == 0):
			offset += block_size
			if offset >= compressed_data.size():
				break
			continue
		var block_buffer: = compressed_data.subarray(offset + 12, offset + block_size - 1)
		match layer_id:
			DATA_BLOCK.LAYER_LOGIC:
				new_layers[0] = compressed_data.subarray(offset + 8, offset + 11) + block_buffer
				is_logic_layer_included = true
			DATA_BLOCK.LAYER_DECO_ON:
				new_layers[1] = compressed_data.subarray(offset + 8, offset + 11) + block_buffer
			DATA_BLOCK.LAYER_DECO_OFF:
				new_layers[2] = compressed_data.subarray(offset + 8, offset + 11) + block_buffer
			DATA_BLOCK.NAME:
				var decompressed_data = block_buffer.decompress(buffer_size, COMPRESSION_MODE)
				new_name = decompressed_data.get_string_from_utf8()
			DATA_BLOCK.DESCRIPTION:
				var decompressed_data = block_buffer.decompress(buffer_size, COMPRESSION_MODE)
				new_description = decompressed_data.get_string_from_utf8()
			DATA_BLOCK.TAGS:
				var decompressed_data = block_buffer.decompress(buffer_size, COMPRESSION_MODE)
				new_tags = tags_string_to_array(decompressed_data.get_string_from_utf8())
		offset += block_size
		if offset >= compressed_data.size():
			break
	if not is_logic_layer_included:
		error_msg = "Invalid blueprint: logic layer missing."
		return FAILED
	width = new_width
	height = new_height
	layers = new_layers
	bpname = new_name if bpname.empty() else bpname
	description = new_description
	tags = new_tags
	error_msg = ""
	return OK
func public_get_string_minimal() -> String:
	var bytes_metadata: = PoolByteArray()
	bytes_metadata.append_array(int2bytes(width, 4))
	bytes_metadata.append_array(int2bytes(height, 4))
	var bytes_body: = PoolByteArray()
	bytes_body.append_array(bytes_metadata)
	bytes_body.append_array(get_layers_bytes())
	var base64_body: String = Marshalls.raw_to_base64(bytes_body)
	var bytes_header: = PoolByteArray()
	bytes_header.append_array(int2bytes(5513342, 3))
	bytes_header.append_array(int2bytes(0, 3))
	bytes_header.append_array(base64_body.sha1_buffer().subarray(0, 5))
	var base64_header: String = Marshalls.raw_to_base64(bytes_header)
	return (base64_header + base64_body)
func public_get_string_full() -> String:
	var bytes_metadata: = PoolByteArray()
	bytes_metadata.append_array(int2bytes(width, 4))
	bytes_metadata.append_array(int2bytes(height, 4))
	var bytes_text_blocks: = PoolByteArray()
	var index: = 1024
	for text_block in [bpname, description, tags_array_to_string(tags)]:
		if text_block.empty():
			index += 1
			continue
		var text_data: PoolByteArray = text_block.to_utf8()
		var bytes_buffer_size: = int2bytes(text_data.size(), 4)
		var text_data_compressed: = text_data.compress(COMPRESSION_MODE)
		var bytes_layer_id: = int2bytes(index, 4)
		var bytes_block_size: = int2bytes(text_data_compressed.size() + 12, 4)
		bytes_text_blocks.append_array(bytes_block_size)
		bytes_text_blocks.append_array(bytes_layer_id)
		bytes_text_blocks.append_array(bytes_buffer_size)
		bytes_text_blocks.append_array(text_data_compressed)
		index += 1
	var bytes_body: = PoolByteArray()
	bytes_body.append_array(bytes_metadata)
	bytes_body.append_array(get_layers_bytes())
	bytes_body.append_array(bytes_text_blocks)
	var base64_body: String = Marshalls.raw_to_base64(bytes_body)
	var bytes_header: = PoolByteArray()
	bytes_header.append_array(int2bytes(5513342, 3))
	bytes_header.append_array(int2bytes(0, 3))
	bytes_header.append_array(base64_body.sha1_buffer().subarray(0, 5))
	var base64_header: String = Marshalls.raw_to_base64(bytes_header)
	return (base64_header + base64_body)
func public_get_error_message() -> String:
	return error_msg
func public_get_layers() -> Array:
	var img_layers: = []
	for layer_idx in 3:
		if layers[layer_idx] == null:
			img_layers.append(null)
			continue
		var buffer_data: PoolByteArray = layers[layer_idx].subarray(4, layers[layer_idx].size() - 1)
		var buffer_size: = bytes2int(layers[layer_idx], 0, 4)
		var decompressed_data = buffer_data.decompress(buffer_size, COMPRESSION_MODE)
		var img = Image.new()
		img.create_from_data(width, height, false, Image.FORMAT_RGBA8, decompressed_data)
		img_layers.append(img)
	return img_layers
func public_set_bpname(p_name: String) -> void :
	bpname = p_name
func public_get_bpname() -> String:
	return bpname
func public_set_description(p_description: String) -> void :
	description = p_description
func public_get_description() -> String:
	return description
func public_set_tags(p_tags: PoolStringArray) -> void :
	tags = p_tags
func public_get_tags() -> PoolStringArray:
	return tags
func public_get_thumbnail() -> ImageTexture:
	var decompressed_data: = thumbnail.decompress(256 * 256 * 4, COMPRESSION_MODE)
	var img: = Image.new()
	img.create_from_data(256, 256, false, Image.FORMAT_RGBA8, decompressed_data)
	var tex: = ImageTexture.new()
	tex.create_from_image(img)
	return tex
func public_has_thumbnail() -> bool:
	return is_thumbnail_ok
func public_generate_thumbnail() -> void :
	var longest_side: = int(max(width, height))
	var side_length: = 1
	while side_length < longest_side:
		side_length <<= 1
	var square: = Image.new()
	square.create(side_length, side_length, false, Image.FORMAT_RGBA8)
	var images: = public_get_layers()
	var logic_layer: Image = images[0]
	var offset: = (Vector2(side_length, side_length) / 2) - (Vector2(width, height) / 2)
	square.blit_rect(logic_layer, Rect2(0, 0, width, height), offset)
	if side_length >= 512:
		square.blit_rect_mask(logic_layer, logic_layer, Rect2(1, 1, width, height), offset)
	square.resize(256, 256, Image.INTERPOLATE_NEAREST)
	thumbnail = square.get_data().compress(COMPRESSION_MODE)
	is_thumbnail_ok = true
func public_delete_thumbnail() -> void :
	pass
func bp_load_legacy(p_blueprint: String) -> int:
	var INT_BYTES: = 8
	var variant = Marshalls.base64_to_raw(p_blueprint)
	if not variant is PoolByteArray:
		error_msg = "Invalid legacy blueprint."
		return FAILED
	if variant.size() == 0:
		error_msg = "Invalid legacy blueprint."
		return FAILED
	if variant.size() < INT_BYTES * 3:
		error_msg = "Corrupted legacy blueprint."
		return FAILED
	var compressed_data: PoolByteArray = variant
	var footer: = compressed_data.subarray( - 4 * INT_BYTES, - 1)
	var metadata: int = bytes2var(footer.subarray( - 1 * INT_BYTES, - 1))
	var buffer_size: int = bytes2var(footer.subarray( - 2 * INT_BYTES, - 1 * INT_BYTES - 1))
	var new_width: int = bytes2var(footer.subarray( - 3 * INT_BYTES, - 2 * INT_BYTES - 1))
	var new_height: int = bytes2var(footer.subarray( - 4 * INT_BYTES, - 3 * INT_BYTES - 1))
	if not (metadata & 65535) == 0:
		error_msg = "Corrupted legacy blueprint."
		return FAILED
	if not (metadata & (1 << 16)):
		error_msg = "Invalid blueprint: logic layer missing."
		return FAILED
	compressed_data.resize(compressed_data.size() - INT_BYTES * 4)
	var new_logic_layer: = int2bytes(buffer_size, 4) + compressed_data
	width = new_width
	height = new_height
	layers = [new_logic_layer, null, null]
	description = ""
	tags = PoolStringArray()
	thumbnail = PoolByteArray()
	return OK
func get_layers_bytes() -> PoolByteArray:
	var bytes_blocks: = PoolByteArray()
	var index: = 0
	var is_missing_decoration: bool = (layers[1] == null) or (layers[2] == null)
	for selection_img in layers:
		var img_data_compressed: PoolByteArray = selection_img.subarray(4, selection_img.size() - 1)
		var bytes_buffer_size: PoolByteArray = selection_img.subarray(0, 3)
		var bytes_layer_id: = int2bytes(index, 4)
		var bytes_block_size: = int2bytes(img_data_compressed.size() + 12, 4)
		bytes_blocks.append_array(bytes_block_size)
		bytes_blocks.append_array(bytes_layer_id)
		bytes_blocks.append_array(bytes_buffer_size)
		bytes_blocks.append_array(img_data_compressed)
		index += 1
		if is_missing_decoration:
			break
	return bytes_blocks
func int2bytes(p_int: int, p_bytes: int) -> PoolByteArray:
	var bytearray: = PoolByteArray()
	for i in p_bytes:
		bytearray.append((p_int >> ((p_bytes - i - 1) * 8)) & 255)
	return bytearray
func bytes2int(p_bytearray: PoolByteArray, p_offset: int, p_bytes: int) -> int:
	var sum: = 0
	for i in p_bytes:
		sum += p_bytearray[p_offset + i] << ((p_bytes - i - 1) * 8)
	return sum
static func tags_array_to_string(tags_array: PoolStringArray) -> String:
	var tags_string: = ""
	for tag in tags_array:
		tag = tag.strip_escapes()
		tag = tag.strip_edges()
		tags_string += tag + ", "
	tags_string = tags_string.left(tags_string.length() - 2)
	return tags_string
static func tags_string_to_array(tags_string: String) -> PoolStringArray:
	var tags_array: = PoolStringArray()
	for tag in tags_string.split(",", false):
		tag = tag.strip_escapes()
		tag = tag.strip_edges()
		if tag != "":
			tags_array.append(tag)
	return tags_array
