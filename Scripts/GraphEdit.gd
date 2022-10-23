extends GraphEdit
class_name ImageGraph

#export(NodePath) var popup

const APP_NAME: String = "Storyboard Mapper"
const DEFAULT_PROJECT_FILENAME: String = "Untitled"
const PROJECT_FILE_VERSION: String = "0.2.0"
const IMAGE_FILE_EXTENSIONS: Array = ["jpg", "jpeg", "png", "bmp"]
const DEFAULT_IMG_NODE_SPACING: float = 40.0
const MIN_DRAG_DISTANCE: float = 5.0
const NEW_NODE_DEFAULT_OFFSET: = Vector2(0.0, 200.0) # graph space

var img_node_bg_color: = Color.black
var custom_img_node_size: Vector2
var project_file_path: String
var project_file_name: String
var selected_img_nodes: Array = [] # array of ImageGraphNode
var selected_com_nodes: Array = [] # array of CommentGraphNode
var active_img_node: ImageGraphNode = null

var dragging_selected_img_nodes: bool = false
var dragged_img_nodes_initial_offsets: Array = [] # offsets are in graph space
var old_global_mouse_position: Vector2 # to allow comparison with get_global_mouse_position() during drag
var dragging_beyond_min_distance: bool = false

onready var imageGraphNode = preload("res://Scenes/ImageGraphNode.tscn")
onready var commentGraphNode = preload("res://Scenes/CommentGraphNode.tscn")

onready var display_dlg: = $DisplayDialog
onready var open_image_file_dlg: = $OpenImgFileDialog
onready var open_sound_file_dlg: = $OpenSndFileDialog
onready var open_project_file_dlg: = $OpenFileDialog
onready var save_project_file_dlg: = $SaveFileDialog
onready var grid_num_columns: = $CanvasLayer/HBoxContainer/GridColsSpinBox
onready var colorpicker: = $CanvasLayer/HBoxContainer/ColorPicker
onready var add_button: = $CanvasLayer/HBoxContainer/AddButton
onready var comment_button: = $CanvasLayer/HBoxContainer/CommentButton
onready var display_button: = $CanvasLayer/HBoxContainer/PlayButton

onready var copy_graph_data = GraphData.new()
onready var copy_group_center: = Vector2.ZERO


func _ready():
	OS.set_low_processor_usage_mode(true) # Saves mobile batteries.
	$CanvasLayer.offset.y = rect_position.y
	project_file_name = DEFAULT_PROJECT_FILENAME
	project_file_path = ""
	update_main_window_title()
	get_tree().connect("files_dropped", self, "_on_files_dropped")
	move_hidden_popups_out_of_the_way()
	update_buttons()


#######################
## SPACE CONVERSIONS ##
#######################

func snap_position(pos: Vector2) -> Vector2:
	var snap = get_snap()
	pos.x = int(pos.x / snap) * snap
	pos.y = int(pos.y / snap) * snap
	return pos


func convert_position_in_viewport_to_offset_in_graph(pos_in_viewport: Vector2) -> Vector2:
	var ofs_in_graph = (scroll_offset + pos_in_viewport) / zoom
	if !is_using_snap():
		return ofs_in_graph
	return snap_position(ofs_in_graph)


func convert_offset_in_graph_to_position_in_viewport(ofs_in_graph: Vector2) -> Vector2:
	var pos_in_viewport = ofs_in_graph * zoom - scroll_offset
	return pos_in_viewport


func convert_global_mouse_position_to_offset_in_graph() -> Vector2:
	return convert_position_in_viewport_to_offset_in_graph(get_global_mouse_position() - rect_position)


##############
## DRAGGING ##
##############

func _process(_delta):
	# Are we dragging selected nodes?
	if dragging_selected_img_nodes:
		var global_mouse_position = get_global_mouse_position()
		
		# To allow dragging image nodes, the dragging distance has to be greater than MIN_DRAG_DISTANCE.
		if !dragging_beyond_min_distance and global_mouse_position.distance_to(old_global_mouse_position) >= MIN_DRAG_DISTANCE:
			dragging_beyond_min_distance = true
		
		if dragging_beyond_min_distance:
			for i in range(selected_img_nodes.size()):
				selected_img_nodes[i].set_offset(convert_global_mouse_position_to_offset_in_graph() - dragged_img_nodes_initial_offsets[i])


func start_dragging_selected_img_nodes(pointed_node: ImageGraphNode):
	dragging_selected_img_nodes = true
	dragging_beyond_min_distance = false
	dragged_img_nodes_initial_offsets.clear() # Security
	
	var global_mouse_position = get_global_mouse_position()
	old_global_mouse_position = global_mouse_position
	
	for node in selected_img_nodes:
		var ofs: Vector2 = (global_mouse_position - rect_position - node.rect_position) / zoom # viewport to graph space
		if is_using_snap():
			ofs = snap_position(ofs)
		dragged_img_nodes_initial_offsets.push_back(ofs)


func stop_dragging_selected_img_nodes() -> bool:
	dragging_selected_img_nodes = false
	dragged_img_nodes_initial_offsets.clear()
	return dragging_beyond_min_distance


##########
## EDIT ##
##########

func _on_DebugButton_pressed():
	print("-----------------------------")
	print("Selected image nodes: ", selected_img_nodes)
	print("Selected comment nodes: ", selected_com_nodes)
#	print("DisplayDialog: ", display_dlg.rect_position)
#	print("ImgFileDlg: ", image_dlg.rect_position)
#	print("OpenFileDialog: ", open_dlg.rect_position)
#	print("SaveFileDialog: ", save_dlg.rect_position)
#	var img_loader: AsyncImageLoader = AsyncImageLoader
#	assert(img_loader)
#	var images: = [
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht020_Prt50_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht020_Prt50_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht020_Prt50_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht020_Prt51_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht020_Prt52_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht021_Prt01_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht021_Prt02_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht021_Prt03_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht021_Prt04_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht022_Prt01_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht022_Prt02_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht022_Prt03_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht023_Prt01_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht024_Prt01_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht024_Prt02_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht024_Prt03_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht025_Prt01_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht025_Prt02_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht025_Prt03_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht026_Prt01_Ver01.png",
#		"G:/COMMON/DATA/JycGimpProjects/Storyboards/Export/DrumsOfTumbalku_Seq001_Sht026_Prt02_Ver01.png",
#	]
#	for path in images:
#		img_loader.load_image_async(path)
#		yield(get_tree().create_timer(0.05), "timeout")
#	yield(get_tree().create_timer(0.2), "timeout")
#	for path in images:
#		var img: = img_loader.fetch_image(path)
#		print("img: ", str(img))


func update_main_window_title():
	OS.set_window_title(project_file_name + " - " + APP_NAME)


func update_buttons():
	display_button.disabled = selected_img_nodes.size() != 1


# Hack to prevent hidden popups from stealing mouse input.
func move_hidden_popups_out_of_the_way():
	var infinite_pos: = Vector2(-1e6, -1e6)
#	if not display_dlg.visible:
#		display_dlg.rect_position = infinite_pos
	if not open_image_file_dlg.visible:
		open_image_file_dlg.rect_position = infinite_pos
	if not open_sound_file_dlg.visible:
		open_sound_file_dlg.rect_position = infinite_pos
	if not open_project_file_dlg.visible:
		open_project_file_dlg.rect_position = infinite_pos
	if not save_project_file_dlg.visible:
		save_project_file_dlg.rect_position = infinite_pos
#	var parent = get_parent()
#	assert(parent)
#	if parent.has_method("move_popups_out_of_the_way"):
#		parent.move_popups_out_of_the_way()


func _on_OpenImgFileDialog_popup_hide():
	move_hidden_popups_out_of_the_way()


func _on_OpenSndFileDialog_popup_hide():
	move_hidden_popups_out_of_the_way()


func _on_SaveFileDialog_popup_hide():
	move_hidden_popups_out_of_the_way()


func _on_OpenFileDialog_popup_hide():
	move_hidden_popups_out_of_the_way()


func get_grid_num_columns() -> int:
	return grid_num_columns.get_value()


func align_horizontally():
	if selected_img_nodes.size() < 2:
		return
	var master_node: ImageGraphNode = selected_img_nodes.front()
	assert(master_node)
	for node in selected_img_nodes:
		node.offset.x = master_node.offset.x


func align_vertically():
	if selected_img_nodes.size() < 2:
		return
	var master_node: ImageGraphNode = selected_img_nodes.front()
	assert(master_node)
	for node in selected_img_nodes:
		node.offset.y = master_node.offset.y


func distribute_row():
	if selected_img_nodes.size() != 1:
		return
	var node: ImageGraphNode = selected_img_nodes.front()
	assert(node)
	var ofs: = node.offset
	while node.next_node:
		ofs.x += node.rect_size.x + DEFAULT_IMG_NODE_SPACING
		node = node.next_node
		node.offset = ofs


func distribute_col():
	if selected_img_nodes.size() != 1:
		return
	var node: ImageGraphNode = selected_img_nodes.front()
	assert(node)
	var ofs: = node.offset
	while node.next_node:
		ofs.y += node.rect_size.y + DEFAULT_IMG_NODE_SPACING
		node = node.next_node
		node.offset = ofs


func distribute_diag():
	if selected_img_nodes.size() != 1:
		return
	var node: ImageGraphNode = selected_img_nodes.front()
	assert(node)
	var ofs: Vector2 = node.offset
	while node.next_node:
		ofs.x += node.rect_size.x + DEFAULT_IMG_NODE_SPACING
		ofs.y += node.rect_size.y / 2 + DEFAULT_IMG_NODE_SPACING
		node = node.next_node
		node.offset = ofs


func distribute_grid():
	if selected_img_nodes.size() != 1:
		return
	var num_cols: = get_grid_num_columns()
	var node: ImageGraphNode = selected_img_nodes.front()
	assert(node)
	var ofs: = node.offset
	var row_ofs_x: = ofs.x
	var col = 0
	while node.next_node:
		col += 1
		if col < num_cols:
			ofs.x += node.rect_size.x + DEFAULT_IMG_NODE_SPACING
		else:
			col = 0
			ofs.x = row_ofs_x
			ofs.y += node.rect_size.y + DEFAULT_IMG_NODE_SPACING
		node = node.next_node
		node.offset = ofs


func store_selected_img_node_as_custom_img_node_size():
	if selected_img_nodes.size() != 1:
		return
	var node = selected_img_nodes.front()
	assert(node)
	custom_img_node_size = node.rect_size


func resize_selected_img_nodes_to_custom_img_node_size():
	if selected_img_nodes.size() == 0:
		return
	for node in selected_img_nodes:
		node.rect_size = custom_img_node_size


############
## CREATE ##
############


# Creates a new image node and adds it to the graph, centered on the given offset (in graph space).
func add_new_image_node(ofs: Vector2, exclusive_select: bool = true, open_image_file: bool = true) -> ImageGraphNode:
	var node = imageGraphNode.instance()
	add_child(node, true) # /!\ before set_offset
	node.set_offset(ofs - node.rect_size / 2)
	node.set_bg_color(img_node_bg_color)
	select_node(node, exclusive_select)
	if open_image_file:
		display_open_image_file_dialog(node)
	return node


func _on_AddButton_pressed():
	add_new_image_node(convert_global_mouse_position_to_offset_in_graph() + NEW_NODE_DEFAULT_OFFSET)


func _on_Graph_gui_input(event):
	# Adds a new node to the graph (centered on mouse position) when user double-clicks on the graph.
	if event is InputEventMouseButton and event.doubleclick:
		add_new_image_node(convert_global_mouse_position_to_offset_in_graph())


# Drag & drop of external files, responds to 'files_dropped' signal.
func _on_files_dropped(files, screen):
	yield(get_tree(),"idle_frame") # hack to get a valid mouse position (doesn't work everytime)
	files.sort() # array of String (absolute file paths)
	deselect_all_nodes()
	var ofs: = convert_global_mouse_position_to_offset_in_graph()
	var line_start: = ofs.x
	var num_cols: int = get_grid_num_columns()
	var col = 0
	var prev_node: ImageGraphNode = null
	for path in files:
		var ext: String = path.get_extension()
		if IMAGE_FILE_EXTENSIONS.has(ext):
			var new_node: ImageGraphNode = add_new_image_node(ofs, false, false)
			new_node.load_thumbnail_from_file(path)
			
			# Organize in grid
			col += 1
			if col < num_cols:
				ofs.x += new_node.rect_size.x + DEFAULT_IMG_NODE_SPACING
			else:
				col = 0
				ofs.x = line_start
				ofs.y += new_node.rect_size.y + DEFAULT_IMG_NODE_SPACING
			
			# Connect to previous node in order
			if prev_node:
				var err = connect_node(prev_node.name, 0, new_node.name, 0)
				if err ==  OK:
					prev_node.next_node = new_node
				else:
					print(err)
			prev_node = new_node


##########
## FIND ##
##########

# Recursive
func _find_all_nodes_before_node(node: ImageGraphNode, sorted_connections: Dictionary, found_nodes: Array):
	assert(node)
	if not sorted_connections.has(node):
		return
	var prev_nodes: Array = sorted_connections[node]
	for n in prev_nodes:
		if found_nodes.has(n):
			continue
		found_nodes.push_back(n)
		_find_all_nodes_before_node(n, sorted_connections, found_nodes)


func _find_all_nodes_before_selected(sorted_connections: Dictionary, found_nodes: Array):
	for node in selected_img_nodes:
		_find_all_nodes_before_node(node, sorted_connections, found_nodes)


func _find_all_nodes_after_node(node: ImageGraphNode, found_nodes: Array):
	assert(node)
	while node.next_node:
		node = node.next_node
		if found_nodes.has(node):
			break
		found_nodes.push_back(node)


func _find_all_nodes_after_selected(found_nodes: Array):
	for node in selected_img_nodes:
		_find_all_nodes_after_node(node, found_nodes)


func _find_terminating_node(node: ImageGraphNode) -> ImageGraphNode:
	assert(node)
	while node.next_node:
		node = node.next_node
	return node


############
## SELECT ##
############

func get_num_selected_img_nodes() -> int:
	return selected_img_nodes.size()


func get_num_selected_com_nodes() -> int:
	return selected_com_nodes.size()


func select_node(node: GraphNode, exclusive: bool):
	assert(node)
	if exclusive:
		deselect_all_nodes()
	if not node.selected:
		node.set_selected(true) # /!\ No signal emitted
	if node is ImageGraphNode and not selected_img_nodes.has(node):
		selected_img_nodes.push_back(node)
	if node is CommentGraphNode and not selected_com_nodes.has(node):
		selected_com_nodes.push_back(node)
	update_buttons()


func select_all_nodes():
	selected_img_nodes.clear()
	selected_com_nodes.clear()
	for node in get_children():
		if node is GraphNode:
			node.set_selected(true) # /!\ No signal emitted
			if node is ImageGraphNode:
				selected_img_nodes.push_back(node)
			if node is CommentGraphNode:
				selected_com_nodes.push_back(node)
	update_buttons()


func deselect_node(node: GraphNode): # image and comment nodes alike
	assert(node)
	if node.selected:
		node.set_selected(false) # /!\ No signal emitted
	if node is ImageGraphNode and selected_img_nodes.has(node):
		selected_img_nodes.erase(node)
	if node is CommentGraphNode and selected_com_nodes.has(node):
		selected_com_nodes.erase(node)
	update_buttons()


func deselect_all_nodes(): # image and comment nodes alike
	for node in get_children():
		if node is GraphNode and node.is_selected():
			node.set_selected(false) # /!\ No signal emitted
	selected_img_nodes.clear()
	selected_com_nodes.clear()
	update_buttons()


func select_all_img_nodes_before_selected_img_nodes():
	if selected_img_nodes.size() == 0:
		return
	var sorted_connections: = get_sorted_connections()
	var found_nodes: = []
	_find_all_nodes_before_selected(sorted_connections, found_nodes)
	for node in found_nodes:
		select_node(node, false)
	update_buttons()


func select_all_img_nodes_after_selected_img_nodes():
	if selected_img_nodes.size() == 0:
		return
	var found_nodes: = []
	_find_all_nodes_after_selected(found_nodes)
	for node in found_nodes:
		select_node(node, false)
	update_buttons()


func select_all_img_nodes_flowing_through_selected_img_nodes():
	if selected_img_nodes.size() == 0:
		return
	var sorted_connections: = get_sorted_connections()
	var found_nodes: = []
	_find_all_nodes_before_selected(sorted_connections, found_nodes)
	_find_all_nodes_after_selected(found_nodes)
	for node in found_nodes:
		select_node(node, false)
	update_buttons()


func select_all_interconnected_img_nodes_with_selected_img_nodes():
	if selected_img_nodes.size() == 0:
		return
	# Find all terminating nodes from selection.
	var terminators: = []
	for node in selected_img_nodes:
		var last: = _find_terminating_node(node)
		if not terminators.has(last):
			terminators.push_back(last)
	
	var sorted_connections: = get_sorted_connections()
	var found_nodes: = terminators.duplicate() # Terminators have to be selected too.
	for node in terminators:
		_find_all_nodes_before_node(node, sorted_connections, found_nodes)
	for node in found_nodes:
		select_node(node, false)
	update_buttons()


func _on_Graph_node_selected(node: GraphNode):
	if node is ImageGraphNode and not selected_img_nodes.has(node):
		selected_img_nodes.push_back(node)
	if node is CommentGraphNode and not selected_com_nodes.has(node):
		selected_com_nodes.push_back(node)
	update_buttons()


func _on_Graph_node_unselected(node: GraphNode):
	if node is ImageGraphNode and selected_img_nodes.has(node):
		selected_img_nodes.erase(node)
	if node is CommentGraphNode and selected_com_nodes.has(node):
		selected_com_nodes.erase(node)
	update_buttons()


#############
## CONNECT ##
#############

# Returns a dictionary of all connections as {to_node: [from_node]}
func get_sorted_connections() -> Dictionary:
	var sorted_connections: = {}
	for c in get_connection_list():
		var from_node: ImageGraphNode = get_node(c.from)
		var to_node: ImageGraphNode = get_node(c.to)
		assert(from_node)
		assert(to_node)
		assert(from_node.next_node == to_node)
		if sorted_connections.has(to_node):
			sorted_connections[to_node].push_back(from_node) # adds to existing array
		else:
			sorted_connections[to_node] = [from_node] # new array
	return sorted_connections


func remove_img_node_input_connections(node: ImageGraphNode):
	assert(node)
	for connection in get_connection_list():
		if connection.to == node.name:
			disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
			var from_node: ImageGraphNode = get_node(connection.from)
			assert(from_node)
			from_node.next_node = null


func remove_img_node_output_connection(node: ImageGraphNode):
	assert(node)
	if node.next_node:
		disconnect_node(node.name, 0, node.next_node.name, 0)
		node.next_node = null


func remove_node_connections(node: ImageGraphNode):
	assert(node)
	remove_img_node_input_connections(node)
	remove_img_node_output_connection(node)


# Creates a new connection between 'from' and 'to' nodes.
func _on_GraphEdit_connection_request(from: String, from_slot: int, to: String, to_slot: int):
	var from_node: ImageGraphNode = get_node(from)
	var to_node: ImageGraphNode = get_node(to)
	assert(from_node)
	assert(to_node)
	
	# No connection to itself
	if from == to:
		return
	
	# Do nothing if connection already exists.
	if from_node.next_node == to_node:
		return
	
	var err = connect_node(from, from_slot, to, to_slot)
	if err !=  OK:
		print(err)
	
	# Delete existing connection.
	if from_node.next_node != null:
		disconnect_node(from, from_slot, from_node.next_node.name, from_node.next_node_slot)
	
	# Reference to_node as from_node's next node.
	from_node.next_node = get_node(to)


# Creates a new connection if user drags out from an existing node's output slot and drops on the graph.
func _on_GraphEdit_connection_to_empty(from: String, from_slot: int, release_position: Vector2):
	var from_node: ImageGraphNode = get_node(from)
	assert(from_node)
	
	var to_node = add_new_image_node(convert_position_in_viewport_to_offset_in_graph(release_position))
	assert(to_node)
	connect_node(from, from_slot, to_node.name, from_slot)
	
	# Delete existing connection.
	if from_node.next_node != null:
		disconnect_node(from, from_slot, from_node.next_node.name, from_node.next_node_slot)
	
	# Reference to_node as from_node's next node.
	from_node.next_node = to_node


# Creates a new connection if user drags out from an existing node's input slot and drops on the graph.
func _on_GraphEdit_connection_from_empty(to: String, to_slot: int, release_position: Vector2):
	var to_node: ImageGraphNode = get_node(to)
	assert(to_node)
	
	var from_node: ImageGraphNode = add_new_image_node(convert_position_in_viewport_to_offset_in_graph(release_position))
	assert(from_node)
	connect_node(from_node.name, to_slot, to, to_slot)
	
	# Reference to_node as from_node's next node.
	from_node.next_node = to_node


func _on_GraphEdit_disconnection_request(from: String, from_slot: int, to: String, to_slot: int):
	var from_node: ImageGraphNode = get_node(from)
	assert(from_node)
	disconnect_node(from, from_slot, to, to_slot)
	from_node.next_node = null


###############
## DUPLICATE ##
###############

func get_num_copied_nodes() -> int:
	return copy_graph_data.img_nodes.size() + copy_graph_data.com_nodes.size()


func duplicate_node(node: ImageGraphNode, ofs: Vector2) -> ImageGraphNode:
	var new_node: ImageGraphNode = node.duplicate()
	if new_node.resizable:
		new_node.rect_size = node.rect_size
	new_node.set_offset(ofs - node.rect_size / 2)
	new_node.img_path = node.img_path
	add_child(new_node, true)
	return new_node


func connect_duplicated_nodes(old_to_new: Dictionary):
	for old_node in old_to_new:
		if old_node.next_node and old_to_new.has(old_node.next_node):
			var node = old_to_new[old_node]
			var next_node = old_to_new[old_node.next_node]
			var err = connect_node(node.name, 0, next_node.name, 0)
			if err !=  OK:
				print(err)
			node.next_node = next_node


func _on_GraphEdit_cut_nodes_request():
	_on_GraphEdit_copy_nodes_request()
	while not selected_img_nodes.empty():
		delete_node(selected_img_nodes.back())
	while not selected_com_nodes.empty():
		delete_node(selected_com_nodes.back())


func _on_GraphEdit_copy_nodes_request():
	if selected_img_nodes.empty() and selected_com_nodes.empty():
		return
	copy_group_center = get_group_center_in_graph_space(selected_img_nodes + selected_com_nodes)
	store_graph_nodes(copy_graph_data, true)


func get_group_center_in_graph_space(nodes: Array) -> Vector2: # offset
	assert(nodes)
	assert(nodes.size())
	var rect: Rect2
	var initialized: = false
	for node in nodes:
		if initialized:
			var node_rect = Rect2(node.offset, node.rect_size) # graph space
			rect = rect.merge(node_rect)
		else:
			rect = Rect2(node.offset, node.rect_size) # graph space
			initialized = true
	return rect.get_center()


func _on_GraphEdit_paste_nodes_request():
	assert(copy_graph_data)
	if copy_graph_data.img_nodes.empty() and copy_graph_data.com_nodes.empty():
		return
	var group_center: Vector2 = convert_position_in_viewport_to_offset_in_graph(get_global_mouse_position() - rect_position)
	build_graph_nodes(copy_graph_data, false, group_center - copy_group_center)


func _on_GraphEdit_duplicate_nodes_request():
	if selected_img_nodes.empty() and selected_com_nodes.empty():
		return
	
	var dup_graph_data = GraphData.new()
	store_graph_nodes(dup_graph_data, true)
	var old_group_center: Vector2 = get_group_center_in_graph_space(selected_img_nodes + selected_com_nodes)
	var new_group_center: Vector2 = convert_position_in_viewport_to_offset_in_graph(get_global_mouse_position() - rect_position)
	build_graph_nodes(dup_graph_data, false, new_group_center - old_group_center)


############
## DELETE ##
############

func delete_node(node: GraphNode):
	assert(node)
	deselect_node(node)
	if node is ImageGraphNode:
		remove_node_connections(node)
		remove_img_node_from_all_com_nodes(node)
	node.queue_free()


func _on_GraphEdit_delete_nodes_request(node_names: Array): # only when selected then pressing [del] button
	for node_name in node_names:
		var node = get_node(node_name)
		assert(node)
		delete_node(node)


#############
## COMMENT ##
#############

# Creates a new comment node and adds it to the graph, centered on the given offset (in graph space) if no image nodes are selected.
func add_new_com_node(ofs: Vector2) -> CommentGraphNode:
	var com_node = commentGraphNode.instance()
	add_child(com_node, true) # /!\ before set_offset
	if selected_img_nodes.size() > 0:
		add_selected_img_nodes_to_com_node(com_node)
	else:
		com_node.set_offset(ofs - com_node.rect_size / 2)
	move_child(com_node, 0)
	return com_node


func add_selected_img_nodes_to_com_node(com_node: CommentGraphNode):
	assert(com_node)
	if selected_img_nodes.empty():
		return
	for img_node in selected_img_nodes:
		if img_node is ImageGraphNode:
			remove_img_node_from_all_com_nodes(img_node)
			com_node.add_img_node(img_node, false) # update size at the end
	com_node.update_size()


func find_com_node_associated_to_node(img_node: ImageGraphNode) -> CommentGraphNode:
	assert(img_node)
	for com_node in get_children():
		if com_node is CommentGraphNode and com_node.has_img_node(img_node):
			return com_node
	return null # no comment node associated to img_node


func remove_img_node_from_all_com_nodes(img_node: ImageGraphNode):
	assert(img_node)
	var com_node: = find_com_node_associated_to_node(img_node)
	if com_node:
		com_node.remove_img_node(img_node, true)


func remove_selected_img_nodes_from_com_node(com_node: CommentGraphNode):
	for img_node in selected_img_nodes:
		if img_node is ImageGraphNode:
			com_node.remove_img_node(img_node, false)
	com_node.update_size()


func img_node_offset_changed(node: ImageGraphNode):
	for com_node in get_children():
		if com_node is CommentGraphNode and com_node.has_img_node(node):
			com_node.update_size()


func _on_CommentButton_pressed():
	add_new_com_node(convert_global_mouse_position_to_offset_in_graph() + NEW_NODE_DEFAULT_OFFSET)


###############
## LOAD/SAVE ##
###############

func clear_graph():
	deselect_all_nodes()
	clear_connections()
	var all_nodes = get_children()
	for node in all_nodes:
		if node is ImageGraphNode or node is CommentGraphNode:
			remove_child(node)
			node.queue_free()


func build_graph_nodes(graph_data: GraphData, keep_names: bool, group_center_diff: Vector2 = Vector2.INF):
	var old_to_new: = {}

	# Image nodes
	for node_data in graph_data.img_nodes:
		var img_node: ImageGraphNode = imageGraphNode.instance()
		if keep_names:
			img_node.set_name(node_data.name)
		img_node.rect_size = node_data.rect_size
		add_child(img_node, true) # /!\ before assigning data
		old_to_new[node_data.name] = img_node.name # same name if keep_names is true
		if group_center_diff == Vector2.INF:
			img_node.offset = node_data.offset
		else:
			img_node.offset = group_center_diff + node_data.offset
		img_node.set_bg_color(graph_data.img_node_bg_color)
		img_node.set_extra_data(node_data.extra_data)
	
	# Connections
	for connection in graph_data.connections:
		var err = connect_node(old_to_new[connection.from], connection.from_port, old_to_new[connection.to], connection.to_port)
		if err != OK:
			print("Error loading graph: ", err)
		
		var from_node: ImageGraphNode = get_node(old_to_new[connection.from])
		var to_node: ImageGraphNode = get_node(old_to_new[connection.to])
		assert(from_node)
		assert(to_node)
		from_node.next_node = to_node
	
	# Comment nodes
	for node_data in graph_data.com_nodes:
		var com_node: CommentGraphNode = commentGraphNode.instance()
		if keep_names:
			com_node.set_name(node_data.name)
		com_node.rect_size = node_data.rect_size
		add_child(com_node, true) # /!\ before assigning data
		move_child(com_node, 0)
		if group_center_diff == Vector2.INF:
			com_node.offset = node_data.offset
		else:
			com_node.offset = group_center_diff + node_data.offset
		com_node.set_extra_data(node_data.extra_data, old_to_new)


func build_graph(graph_data: GraphData):
	clear_graph()
	img_node_bg_color = graph_data.img_node_bg_color
	colorpicker.color = graph_data.img_node_bg_color
	build_graph_nodes(graph_data, true)


func load_graph_from_file(path: String):
	var dir = Directory.new()
	if not dir.file_exists(path):
		print("File ", path, " doesn't exist")
		return
	
	if ResourceLoader.exists(path):
		var graph_data = ResourceLoader.load(path)
		if graph_data is GraphData:
			if graph_data.version == PROJECT_FILE_VERSION:
				build_graph(graph_data)
			else:
				print("Error, incompatible file version ", graph_data.version)
				return
	
	project_file_name = path.get_file()
	project_file_path = path
	update_main_window_title()


func store_graph_nodes(graph_data: GraphData, selected_nodes_only: bool = false):
	assert(graph_data)
	graph_data.img_nodes.clear()
	graph_data.connections.clear()
	graph_data.com_nodes.clear()
	
	# Image nodes
	for node in get_children():
		if node is ImageGraphNode and (!selected_nodes_only or node.selected):
			var node_data = GraphNodeData.new()
			assert(node_data)
			node_data.name = node.name
			node_data.offset = node.offset
			node_data.rect_size = node.rect_size
			node_data.extra_data = node.get_extra_data()
			graph_data.img_nodes.append(node_data)
	
	# Connexions
	var connection_list: = get_connection_list()
	if selected_nodes_only:
		for connection in connection_list:
			if get_node(connection.from).selected and get_node(connection.to).selected:
				graph_data.connections.push_back(connection)
	else:
		graph_data.connections = connection_list
	
	# Comment nodes
	for node in get_children():
		if node is CommentGraphNode and (!selected_nodes_only or node.selected):
			var node_data = GraphNodeData.new()
			assert(node_data)
			node_data.name = node.name
			node_data.offset = node.offset
			node_data.rect_size = node.rect_size
			node_data.extra_data = node.get_extra_data() # /!\ saves all contained image node names
			graph_data.com_nodes.append(node_data)


func store_graph(graph_data: GraphData, selected_nodes_only: bool):
	assert(graph_data)
	graph_data.version = PROJECT_FILE_VERSION
	graph_data.img_node_bg_color = img_node_bg_color
	store_graph_nodes(graph_data, selected_nodes_only)


func save_graph_to_file(path: String):
	var graph_data = GraphData.new()
	assert(graph_data)
	store_graph(graph_data, false)
	
	# Crée le directory s'il n'existe pas.
	var dir_path: String = path.get_base_dir()
	var dir = Directory.new()
	if not dir.dir_exists(dir_path):
		dir.make_dir_recursive(dir_path)
	if not dir.dir_exists(dir_path):
		print("Makedir failed")
		return
	
	# Sauvegarde graph_data dans le directory donné sous le nom donné.
	var err = ResourceSaver.save(path, graph_data)
	if err != OK:
		print("Error saving graph: ", err)
		return
	
	project_file_name = path.get_file()
	project_file_path = path
	update_main_window_title()


func new_project():
	clear_graph()
	project_file_name = DEFAULT_PROJECT_FILENAME
	project_file_path = ""
	update_main_window_title()


func open_project_file():
	open_project_file_dlg.popup_centered()


func save_project_file():
	if project_file_path == "":
		save_project_file_as()
	else:
		save_graph_to_file(project_file_path)


func save_project_file_as():
	save_project_file_dlg.popup_centered()


func _on_OpenFileDialog_file_selected(path):
	load_graph_from_file(path)
	move_hidden_popups_out_of_the_way()


func _on_SaveFileDialog_file_selected(path):
	save_graph_to_file(path)
	move_hidden_popups_out_of_the_way()


#############
## ANIMATE ##
#############

func display_open_image_file_dialog(node: ImageGraphNode):
	assert(node)
	active_img_node = node
	open_image_file_dlg.popup_centered()


func display_open_sound_dialog(node: ImageGraphNode):
	assert(node)
	active_img_node = node
	open_sound_file_dlg.popup_centered()


func reload_node_thumbnail(node: ImageGraphNode):
	assert(node)
	node.reload_thumbnail_from_file()
	refresh_display_dialog()


func reload_node_sound(node: ImageGraphNode):
	assert(node)
	node.reload_sound_from_file()
#	refresh_display_dialog()


func refresh_display_dialog():
	if display_dlg.visible:
		display_dlg.refresh()


func _on_OpenImgFileDialog_file_selected(path):
	assert(active_img_node)
	move_hidden_popups_out_of_the_way()
	active_img_node.load_thumbnail_from_file(path)
	refresh_display_dialog()


func _on_OpenSndFileDialog_file_selected(path):
	assert(active_img_node)
	move_hidden_popups_out_of_the_way()
	active_img_node.load_sound_from_file(path)
#	refresh_display_dialog()


func play_animation():
	if selected_img_nodes.size() != 1:
		return
	display_dlg.init_dialog(selected_img_nodes.front())
	if display_dlg.window_bounds == Rect2():
		display_dlg.popup_centered()
	else:
		display_dlg.popup(display_dlg.window_bounds)


func _on_PlayButton_pressed():
	play_animation()


func _on_ColorPicker_color_changed(color):
	img_node_bg_color = color
	for node in get_children():
		if node is ImageGraphNode:
			node.set_bg_color(color)
