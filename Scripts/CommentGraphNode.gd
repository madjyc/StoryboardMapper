extends GraphNode
class_name CommentGraphNode

const DEFAULT_SIZE: = Vector2(230.0, 80.0) # graph space
const LEFT_MARGIN: = 16.0 # graph space
const TOP_MARGIN: = 80.0 # graph space
const RIGHT_MARGIN: = 16.0 # graph space
const BOTTOM_MARGIN: = 16.0 # graph space
const FOCUS_COLOR_LIGHTEN: = 0.5

var img_nodes: = [] # array of ImageGraphNode
var old_offset: Vector2

onready var colorpicker: = $VBoxContainer/HBoxContainer/HBoxContainer2/ColorPicker
onready var user_text: = $VBoxContainer/UserText

# Important to know:
#     rect_position is in viewport space, can't be set directly in code (use offset)
#     offset is rect_position in graph space (rect_position is automatically derived from offset)
#     rect_size is in graph space

func _ready():
	assert(colorpicker)
	assert(user_text)
	old_offset = offset
	set_color(colorpicker.color)


func _exit_tree():
	purge_img_nodes(false)


#func get_lowest_img_nodes_position_in_parent() -> int:
#	if img_nodes.empty():
#		return -1
#	var min_index: int = img_nodes.front().get_position_in_parent()
#	for node in img_nodes:
#		if min_index > node.get_position_in_parent():
#			min_index = node.get_position_in_parent()
#	return min_index


# Extra data to be saved
func get_extra_data() -> Dictionary:
	var extra_data = {
			"title": get_title(),
			"color": colorpicker.color,
			"text": user_text.text,
			"img_node_names": [] # filled hereafter
	}
	for node in img_nodes:
		extra_data["img_node_names"].push_back(node.name)
	
	return extra_data


# Extra data to be loaded
func set_extra_data(extra_data: Dictionary, old_to_new: Dictionary, update_size: bool = true):
	assert(is_inside_tree())
	set_title(extra_data["title"])
	set_color(extra_data["color"])
	user_text.text = extra_data["text"]
	img_nodes.clear()
	for node_name in extra_data["img_node_names"]:
		if old_to_new.has(node_name): # user might have copied a comment node without all of its image nodes
			img_nodes.push_back(get_node("../" + old_to_new[node_name]))
	if update_size:
		update_size_options()
		update_size()


func set_color(color: Color):
	colorpicker.color = color
	
	var custom_styles: StyleBox
	
	# Normal
	custom_styles = get("custom_styles/comment")
	custom_styles.bg_color = color
	custom_styles.border_color = color

	# Focused
	custom_styles = get("custom_styles/commentfocus")
	var focus_color: Color = color.lightened(FOCUS_COLOR_LIGHTEN)
	custom_styles.bg_color = focus_color
	custom_styles.border_color = focus_color


func _on_ColorPicker_color_changed(color):
	set_color(color)


func has_no_img_node() -> bool:
	return img_nodes.empty()


func has_img_node(node: ImageGraphNode):
	return img_nodes.has(node)


func add_img_node(node: ImageGraphNode, update_size: bool):
	if not img_nodes.has(node):
		img_nodes.push_back(node)
	update_size_options()
	if update_size:
		update_size()


func remove_img_node(node: ImageGraphNode, update_size: bool):
	if img_nodes.has(node):
		img_nodes.erase(node)
	update_size_options()
	if update_size:
		update_size()


func purge_img_nodes(update_size: bool):
	img_nodes.clear()
	update_size_options()
	if update_size:
		update_size()


func update_size_options():
	if img_nodes.empty():
		resizable = true
		user_text.size_flags_vertical = SIZE_EXPAND_FILL
	else:
		resizable = false
		user_text.size_flags_vertical = SIZE_FILL


func update_size():
	if img_nodes.empty():
		set_size(DEFAULT_SIZE) # graph space
		
	else:
		var rect: Rect2
		var initialized: = false
		for node in img_nodes:
			if initialized:
				var node_rect = Rect2(node.offset, node.rect_size) # graph space
				rect = rect.merge(node_rect)
			else:
				rect = Rect2(node.offset, node.rect_size) # graph space
				initialized = true
		
		set_offset(rect.position - Vector2(LEFT_MARGIN, TOP_MARGIN)) # graph space
		set_size(rect.size + Vector2(LEFT_MARGIN + RIGHT_MARGIN, TOP_MARGIN + BOTTOM_MARGIN)) # graph space


func _on_CommentNode_resize_request(new_size):
	if not img_nodes.empty():
		return
	var graph = get_parent()
	assert(graph is GraphEdit)
	if graph.is_using_snap():
		rect_size = graph.snap_position(new_size)
	else:
		rect_size = new_size


func _on_CommentNode_close_request():
	var graph = get_parent()
	assert(graph is GraphEdit)
	graph.delete_node(self)


func _on_AddButton_pressed():
	var graph = get_parent()
	assert(graph is GraphEdit)
	graph.add_selected_img_nodes_to_com_node(self)


func _on_SubButton_pressed():
	var graph = get_parent()
	assert(graph is GraphEdit)
	graph.remove_selected_img_nodes_from_com_node(self)


func _on_CommentNode_offset_changed():
	var diff = offset - old_offset
	for img_node in img_nodes:
		assert(img_node is ImageGraphNode)
		img_node.offset += diff
	old_offset = offset


func _on_CommentNode_dragged(from, to):
	if img_nodes.size() > 0:
		update_size()
