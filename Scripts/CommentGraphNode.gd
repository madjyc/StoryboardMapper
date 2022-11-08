extends GraphNode
class_name CommentGraphNode

const DEFAULT_SIZE: = Vector2(230.0, 80.0) # graph space
const LEFT_MARGIN: = 16.0 # graph space
const TOP_MARGIN: = 120.0 # graph space
const RIGHT_MARGIN: = 16.0 # graph space
const BOTTOM_MARGIN: = 16.0 # graph space
const MAX_ICONBUTTON_COUNT: = 6
const TITLEBAR_V_FACTOR: = 1.4
const BG_ALPHA: = 0.75
const BORDER_ALPHA: = 0.95

var img_nodes: = [] # array of ImageGraphNode
var old_offset: Vector2
var is_clicked: = false

onready var iconButton = preload("res://Scenes/IconButton.tscn")

onready var iconbutton_container: = $VBoxContainer/HBoxContainer/HBoxContainer/IconBtnContainer
onready var colorpicker: = $VBoxContainer/HBoxContainer/HBoxContainer2/ColorPicker
onready var user_text: = $VBoxContainer/UserText

# Important to know:
#     rect_position is in viewport space, can't be set directly in code (use offset)
#     offset is rect_position in graph space (rect_position is automatically derived from offset)
#     rect_size is in graph space

func _ready():
	assert(iconbutton_container)
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
		"img_node_names": [], # filled below
		"icon_buttons": [], # filled below
	}
	
	for node in img_nodes:
		extra_data["img_node_names"].push_back(node.name)
	
	for icon_button in iconbutton_container.get_children():
		assert(icon_button is IconButton)
		extra_data["icon_buttons"].push_back(icon_button.get_selected_id())
	
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
	
	for selected_id in extra_data["icon_buttons"]:
		var icon_button = iconButton.instance()
		iconbutton_container.add_child(icon_button)
		icon_button.select(selected_id)
	
	if update_size:
		update_size_options()
		if not img_nodes.empty():
			update_rect()


func set_color(color: Color):
	colorpicker.color = color
	
	var custom_styles: StyleBox = get("custom_styles/comment")
	custom_styles.bg_color = color.from_hsv(color.h, color.s, color.v, BG_ALPHA)
	custom_styles.border_color = color.from_hsv(color.h, color.s, color.v * TITLEBAR_V_FACTOR, BORDER_ALPHA)


func _on_ColorPicker_color_changed(color):
	set_color(color)


func has_no_img_node() -> bool:
	return img_nodes.empty()


func has_img_node(node: ImageGraphNode):
	return img_nodes.has(node)


func add_img_node(node: ImageGraphNode, update_rect: bool):
	if not img_nodes.has(node):
		img_nodes.push_back(node)
	update_size_options()
	if update_rect:
		update_rect()


func remove_img_node(node: ImageGraphNode, update_rect: bool):
	if img_nodes.has(node):
		img_nodes.erase(node)
	update_size_options()
	if update_rect:
		update_rect()


func purge_img_nodes(update_rect: bool):
	img_nodes.clear()
	update_size_options()
	if update_rect:
		update_rect()


func update_size_options():
	if img_nodes.empty():
		resizable = true
		user_text.size_flags_vertical = SIZE_EXPAND_FILL
	else:
		resizable = false
		user_text.size_flags_vertical = SIZE_FILL


func update_rect():
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
	get_parent().delete_node(self)


func _on_AddButton_pressed():
	get_parent().add_selected_img_nodes_to_com_node(self)


func _on_SubButton_pressed():
	get_parent().remove_selected_img_nodes_from_com_node(self)


func _on_CommentNode_gui_input(event):
	if not event is InputEventMouseButton:
		return
	
	if event.get_button_index() == 1:
		is_clicked = event.pressed


func _on_CommentNode_offset_changed():
	if is_clicked:
		var diff = offset - old_offset
		for img_node in img_nodes:
			assert(img_node is ImageGraphNode)
			if not img_node.selected: # selected nodes move by themselves
				img_node.offset += diff
	old_offset = offset


func _on_CommentNode_dragged(from, to):
	if img_nodes.size() > 0:
		update_rect()


func _on_NewIconButton_pressed():
	if iconbutton_container.get_child_count() >= MAX_ICONBUTTON_COUNT:
		return
	
	var icon_button = iconButton.instance()
	iconbutton_container.add_child(icon_button)


func _on_DelIconButton_pressed():
	if iconbutton_container.get_child_count() == 0:
		return
	
	var icon_button = iconbutton_container.get_child(iconbutton_container.get_child_count()-1)
	assert(icon_button is IconButton)
	iconbutton_container.remove_child(icon_button)
