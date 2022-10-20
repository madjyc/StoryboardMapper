extends GraphEdit
class_name ImageGraph

#export(NodePath) var popup

const APP_NAME: String = "Storyboard Mapper"
const DEFAULT_FILENAME: String = "Untitled"
const FILE_VERSION: String = "0.1.0-alpha"
const IMG_EXTENSIONS: Array = ["jpg", "jpeg", "png", "bmp"]
const DEFAULT_NODE_SPACING: float = 40.0
const MIN_DRAG_DISTANCE: float = 5.0

var node_bg_color: = Color.black
var custom_node_size: Vector2
var current_path: String
var current_file_name: String
var selected_nodes: Array = []
var copied_nodes: Array = []
var active_node: ImageGraphNode = null

var dragging_selected_nodes: bool = false
var dragged_nodes_initial_offsets_in_graph_space: Array = []
var old_global_mouse_position: Vector2
var nodes_were_dragged: bool = false

onready var graph_node = preload("res://Scenes/GraphNode.tscn")
onready var display_dlg: = $DisplayDialog
onready var image_dlg: = $OpenImgFileDialog
onready var sound_dlg: = $OpenSndFileDialog
onready var open_dlg: = $OpenFileDialog
onready var save_dlg: = $SaveFileDialog
onready var grid_num_cols: = $CanvasLayer/HBoxContainer/GridColsSpinBox
onready var colorpicker: = $CanvasLayer/HBoxContainer/ColorPicker
onready var add_button: = $CanvasLayer/HBoxContainer/AddButton
onready var play_button: = $CanvasLayer/HBoxContainer/PlayButton


func _ready():
	OS.set_low_processor_usage_mode(true) # Economise la batterie des mobiles.
	$CanvasLayer.offset.y = rect_position.y
	current_file_name = DEFAULT_FILENAME
	current_path = ""
	update_main_window_title()
	get_tree().connect("files_dropped", self, "_on_files_dropped")
	move_popups_out_of_the_way()


func _process(_delta):
	# Are we dragging selected nodes?
	if dragging_selected_nodes:
		var global_mouse_position = get_global_mouse_position()
		
		# Considère dragging si ça n'était pas déjà le cas et que la distance de dragging est suffisante.
		if !nodes_were_dragged and global_mouse_position.distance_to(old_global_mouse_position) >= MIN_DRAG_DISTANCE:
			nodes_were_dragged = true
		
		if nodes_were_dragged:
			for i in range(selected_nodes.size()):
				selected_nodes[i].set_offset(get_mouse_position_in_graph_space() - dragged_nodes_initial_offsets_in_graph_space[i])


##########
## EDIT ##
##########

func _on_DebugButton_pressed():
	print("-----------------------------")
	print("Selected: ", selected_nodes)
	print("Copied: ", copied_nodes)
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
	OS.set_window_title(current_file_name + " - " + APP_NAME)


func update_buttons():
	play_button.disabled = selected_nodes.size() != 1


# Hack to prevent hidden popups from stealing mouse input.
func move_popups_out_of_the_way():
	var infinite_pos: = Vector2(-1e6, -1e6)
#	if not display_dlg.visible:
#		display_dlg.rect_position = infinite_pos
	if not image_dlg.visible:
		image_dlg.rect_position = infinite_pos
	if not sound_dlg.visible:
		sound_dlg.rect_position = infinite_pos
	if not open_dlg.visible:
		open_dlg.rect_position = infinite_pos
	if not save_dlg.visible:
		save_dlg.rect_position = infinite_pos
#	var parent = get_parent()
#	assert(parent)
#	if parent.has_method("move_popups_out_of_the_way"):
#		parent.move_popups_out_of_the_way()


func _on_OpenImgFileDialog_popup_hide():
	move_popups_out_of_the_way()


func _on_OpenSndFileDialog_popup_hide():
	move_popups_out_of_the_way()


func _on_SaveFileDialog_popup_hide():
	move_popups_out_of_the_way()


func _on_OpenFileDialog_popup_hide():
	move_popups_out_of_the_way()


func get_grid_num_cols() -> int:
	return grid_num_cols.get_value()


func start_dragging_selected_nodes(pointed_node: ImageGraphNode):
	dragging_selected_nodes = true
	nodes_were_dragged = false
	dragged_nodes_initial_offsets_in_graph_space.clear() # Security
	var global_mouse_position = get_global_mouse_position()
	old_global_mouse_position = global_mouse_position
	for node in selected_nodes:
		var ofs: Vector2 = (global_mouse_position - rect_position - node.rect_position) / zoom
		if is_using_snap():
			ofs = snap_position(ofs)
		dragged_nodes_initial_offsets_in_graph_space.push_back(ofs)


func stop_dragging_selected_nodes() -> bool:
	dragging_selected_nodes = false
	dragged_nodes_initial_offsets_in_graph_space.clear()
	return nodes_were_dragged


func align_horizontally():
	if selected_nodes.size() < 2:
		return
	var master_node: ImageGraphNode = selected_nodes.front()
	var master_node_x: = master_node.offset.x
	for node in selected_nodes:
		node.offset.x = master_node_x


func align_vertically():
	if selected_nodes.size() < 2:
		return
	var master_node: ImageGraphNode = selected_nodes.front()
	var master_node_y: = master_node.offset.y
	for node in selected_nodes:
		node.offset.y = master_node_y


func distribute_row():
	if selected_nodes.size() != 1:
		return
	var node: ImageGraphNode = selected_nodes.front()
	var ofs: Vector2 = node.offset
	while node.next_node:
		ofs.x += node.rect_size.x + DEFAULT_NODE_SPACING
		node = node.next_node
		node.offset = ofs


func distribute_col():
	if selected_nodes.size() != 1:
		return
	var node: ImageGraphNode = selected_nodes.front()
	var ofs: Vector2 = node.offset
	while node.next_node:
		ofs.y += node.rect_size.y + DEFAULT_NODE_SPACING
		node = node.next_node
		node.offset = ofs


func distribute_diag():
	if selected_nodes.size() != 1:
		return
	var node: ImageGraphNode = selected_nodes.front()
	var ofs: Vector2 = node.offset
	while node.next_node:
		ofs.x += node.rect_size.x + DEFAULT_NODE_SPACING
		ofs.y += node.rect_size.y / 2 + DEFAULT_NODE_SPACING
		node = node.next_node
		node.offset = ofs


# Drag and drop de fichiers.
func distribute_grid():
	if selected_nodes.size() != 1:
		return
	var num_cols: int = get_grid_num_cols()
	var node: ImageGraphNode = selected_nodes.front()
	var ofs: Vector2 = node.offset
	var line_start: = ofs.x
	var col = 0
	while node.next_node:
		col += 1
		if col < num_cols:
			ofs.x += node.rect_size.x + DEFAULT_NODE_SPACING
		else:
			col = 0
			ofs.x = line_start
			ofs.y += node.rect_size.y + DEFAULT_NODE_SPACING
		node = node.next_node
		node.offset = ofs


func set_custom_size_from_selected_node():
	if selected_nodes.size() != 1:
		return
	var node = selected_nodes.front()
	custom_node_size = node.rect_size


func set_selected_nodes_to_custom_size():
	if selected_nodes.size() == 0:
		return
	for node in selected_nodes:
		node.rect_size = custom_node_size


#########
## NEW ##
#########

func snap_position(pos: Vector2) -> Vector2:
	var snap = get_snap()
	pos.x = int(pos.x / snap) * snap
	pos.y = int(pos.y / snap) * snap
	return pos


# Convertit un offset dans le viewport (ex: get_global_mouse_position()) dans l'espace du graph.
func convert_viewport_ofs_to_graph_ofs(viewport_pos: Vector2) -> Vector2:
	var ofs = (scroll_offset + viewport_pos) / zoom
	if !is_using_snap():
		return ofs
	return snap_position(ofs)


# Inverse de la conversion ci-dessus.
func convert_graph_ofs_to_viewport_ofs(graph_pos: Vector2) -> Vector2:
	var ofs = graph_pos * zoom - scroll_offset
	return ofs


func get_mouse_position_in_graph_space() -> Vector2:
	return convert_viewport_ofs_to_graph_ofs(get_global_mouse_position() - rect_position)


# Ajoute un nouveau node au graph. Son centre est positionné à l'offset donné.
func add_new_node(ofs: Vector2, select_exclusive: bool = true, autoload: bool = true) -> ImageGraphNode:
	var node = graph_node.instance()
	node.set_offset(ofs - node.rect_size / 2)
	add_child(node, true)
	node.set_bg_color(node_bg_color)
	if select_exclusive:
		select_node_ex(node)
	else:
		#node.selected = true
		select_node_ex(node, false)
	if autoload:
		open_load_image_dialog(node)
	return node


# Ajoute un nouveau node au graph quand l'utilisateur appuie sur le bouton 'Add'.
func _on_AddButton_pressed():
	add_new_node(get_mouse_position_in_graph_space() + Vector2(200, 200))


# Ajoute un nouveau node au graph quand l'utilisateur double-clique sur le graph.
func _on_Graph_gui_input(event):
	if event is InputEventMouseButton and event.doubleclick:
		add_new_node(get_mouse_position_in_graph_space())


# Drag and drop de fichiers.
func _on_files_dropped(files, screen):
	yield(get_tree(),"idle_frame") # hack to get valid mouse position
	deselect_all_nodes()
	var ofs: = get_mouse_position_in_graph_space()
	var line_start: = ofs.x
	var num_cols: int = get_grid_num_cols()
	var col = 0
	var prev_node: ImageGraphNode = null
	for path in files:
		var ext: String = path.get_extension()
		if IMG_EXTENSIONS.has(ext):
			var new_node: ImageGraphNode = add_new_node(ofs, false, false)
			new_node.load_thumbnail_from_file(path)
			
			col += 1
			if col < num_cols:
				ofs.x += new_node.rect_size.x + DEFAULT_NODE_SPACING
			else:
				col = 0
				ofs.x = line_start
				ofs.y += new_node.rect_size.y + DEFAULT_NODE_SPACING
			
			if prev_node:
				# Crée une nouvelle connexion entre les nodes 'prev_node' et 'new_node'.
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
func _find_all_nodes_before_node(node: ImageGraphNode, connections: Dictionary, found_nodes: Array):
	assert(node)
	if not connections.has(node):
		return
	var prev_nodes: Array = connections[node]
	for n in prev_nodes:
		if found_nodes.has(n):
			continue
		found_nodes.push_back(n)
		_find_all_nodes_before_node(n, connections, found_nodes)


func _find_all_nodes_before_selected(connections: Dictionary, found_nodes: Array):
	for node in selected_nodes:
		_find_all_nodes_before_node(node, connections, found_nodes)


func _find_all_nodes_after_node(node: ImageGraphNode, found_nodes: Array):
	assert(node)
	while node.next_node:
		node = node.next_node
		if found_nodes.has(node):
			break
		found_nodes.push_back(node)


func _find_all_nodes_after_selected(found_nodes: Array):
	for node in selected_nodes:
		_find_all_nodes_after_node(node, found_nodes)


func _find_terminating_node(node: ImageGraphNode) -> ImageGraphNode:
	assert(node)
	while node.next_node:
		node = node.next_node
	return node # last node


############
## SELECT ##
############

func get_num_selected_nodes():
	return selected_nodes.size()


func get_num_copied_nodes():
	return copied_nodes.size()


# Sélectionne seulement le node donné du graph.
func select_node_ex(node: ImageGraphNode, exclusive: bool = true):
	assert(node)
	#print("select_node_ex, ", exclusive)
	if exclusive:
		deselect_all_nodes()
	if not node.selected:
		node.set_selected(true) # /!\ N'émet pas de signal.
	if not selected_nodes.has(node):
		selected_nodes.push_back(node)
	update_buttons()


func select_all_nodes():
	selected_nodes.clear()
	for node in get_children():
		if node is ImageGraphNode:# and not node.is_selected():
			node.set_selected(true) # /!\ N'émet pas de signal.
			selected_nodes.push_back(node)
	update_buttons()


# Désélectionne le node donné.
func deselect_node(node: ImageGraphNode):
	#print("deselect_node")
	assert(node)
	if node.selected:
		node.set_selected(false) # /!\ N'émet pas de signal.
	if selected_nodes.has(node):
		selected_nodes.erase(node)
	update_buttons()


# Désélectionne tous les nodes du graph.
func deselect_all_nodes():
	#print("deselect_all_nodes")
	for node in get_children():
		if node is ImageGraphNode and node.is_selected():
			node.set_selected(false) # /!\ N'émet pas de signal.
	selected_nodes.clear()
	update_buttons()


func select_all_nodes_before_selected_nodes():
	if selected_nodes.size() == 0:
		return
	var connections: = _get_connection_info()
	var found_nodes: = []
	_find_all_nodes_before_selected(connections, found_nodes)
	for node in found_nodes:
		select_node_ex(node, false)
	update_buttons()


func select_all_nodes_after_selected_nodes():
	if selected_nodes.size() == 0:
		return
	var found_nodes: = []
	_find_all_nodes_after_selected(found_nodes)
	for node in found_nodes:
		select_node_ex(node, false)
	update_buttons()


func select_all_nodes_flowing_through_selected_nodes():
	if selected_nodes.size() == 0:
		return
	var connections: = _get_connection_info()
	var found_nodes: = []
	_find_all_nodes_before_selected(connections, found_nodes)
	_find_all_nodes_after_selected(found_nodes)
	for node in found_nodes:
		select_node_ex(node, false)
	update_buttons()


func select_all_interconnected_nodes_with_selected_nodes():
	if selected_nodes.size() == 0:
		return
	# Find all terminating nodes from selection.
	var terminators: = []
	for node in selected_nodes:
		var last: = _find_terminating_node(node)
		if not terminators.has(last):
			terminators.push_back(last)
	
	var connections: = _get_connection_info()
	var found_nodes: = terminators.duplicate() # Terminators have to be selected too.
	for node in terminators:
		_find_all_nodes_before_node(node, connections, found_nodes)
	for node in found_nodes:
		select_node_ex(node, false)
	update_buttons()


func _on_Graph_node_selected(node: ImageGraphNode):
	#print("_on_Graph_node_selected")
	if not selected_nodes.has(node):
		selected_nodes.push_back(node)
		update_buttons()


func _on_Graph_node_unselected(node: ImageGraphNode):
	#print("_on_Graph_node_unselected")
	if selected_nodes.has(node):
		selected_nodes.erase(node)
		update_buttons()


#############
## CONNECT ##
#############

func _get_connection_info() -> Dictionary:
	var connections: = {}
	for c in get_connection_list():
		var from_node: ImageGraphNode = get_node(c.from)
		var to_node: ImageGraphNode = get_node(c.to)
		assert(from_node)
		assert(to_node)
		assert(from_node.next_node == to_node)
		if connections.has(to_node):
			connections[to_node].push_back(from_node)
		else:
			connections[to_node] = [from_node] # new array
	return connections


# Supprime toutes les connexions entrantes du node donné.
func remove_node_input_connections(node: ImageGraphNode):
	assert(node)
	for connection in get_connection_list():
		if connection.to == node.name:
			disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
			var from_node: ImageGraphNode = get_node(connection.from)
			assert(from_node)
			from_node.next_node = null


# Supprime la connexion sortante du node donné.
func remove_node_output_connection(node: ImageGraphNode):
	assert(node)
	if node.next_node:
		disconnect_node(node.name, 0, node.next_node.name, 0)
		node.next_node = null


# Supprime toutes les connexions entrantes et sortantes du node donné.
func remove_node_connections(node: ImageGraphNode):
	assert(node)
	remove_node_input_connections(node)
	remove_node_output_connection(node)


# Crée une nouvelle connexion entre les nodes de noms donnés 'from' et 'to'.
func _on_GraphEdit_connection_request(from: String, from_slot: int, to: String, to_slot: int):
	# Récupère les nodes 'from' et 'to' d'après les noms donnés.
	var from_node: ImageGraphNode = get_node(from)
	var to_node: ImageGraphNode = get_node(to)
	assert(from_node)
	assert(to_node)
	
	# Refuse la nouvelle connexion si le node se connecte à lui-même.
	if from == to:
		return
	
	# Refuse la nouvelle connexion si elle existe déjà.
	if from_node.next_node == to_node:
		return
	
	# Crée une nouvelle connexion entre les nodes 'from' et 'to'.
	var err = connect_node(from, from_slot, to, to_slot)
	if err !=  OK:
		print(err)
	
	# Supprime l'ancienne connexion si elle existe.
	if from_node.next_node != null:
		disconnect_node(from, from_slot, from_node.next_node.name, from_node.next_node_slot)
	
	# Assigne le node 'from' comme node suivant du node 'to'.
	from_node.next_node = get_node(to)


# Crée un nouveau node si l'utilisateur traîne et relâche sur le graph une nouvelle connexion sortante depuis un node existant.
func _on_GraphEdit_connection_to_empty(from: String, from_slot: int, release_position: Vector2):
	# Récupère le node 'from' d'après le nom donné.
	var from_node: ImageGraphNode = get_node(from)
	assert(from_node)
	
	# Crée un nouveau node et le connecte.
	var new_node = add_new_node(convert_viewport_ofs_to_graph_ofs(release_position))
	assert(new_node)
	connect_node(from, from_slot, new_node.name, from_slot)
	
	# Supprime l'ancienne connexion si elle existe.
	if from_node.next_node != null:
		disconnect_node(from, from_slot, from_node.next_node.name, from_node.next_node_slot)
	
	# Assigne le nouveau node comme node suivant du node 'from'.
	from_node.next_node = new_node


# Crée un nouveau node si l'utilisateur traîne et relâche sur le graph une nouvelle connexion entrante depuis un node existant.
func _on_GraphEdit_connection_from_empty(to: String, to_slot: int, release_position: Vector2):
	# Récupère le node 'to' d'après le nom donné.
	var to_node: ImageGraphNode = get_node(to)
	assert(to_node)

	# Crée un nouveau node et le connecte.
	var new_node: ImageGraphNode = add_new_node(convert_viewport_ofs_to_graph_ofs(release_position))
	assert(new_node)
	connect_node(new_node.name, to_slot, to, to_slot)
	
	# Assigne le node 'to' comme node suivant du nouveau node.
	new_node.next_node = to_node


func _on_GraphEdit_disconnection_request(from: String, from_slot: int, to: String, to_slot: int):
	# Récupère le node from d'après le nom donné.
	var from_node: ImageGraphNode = get_node(from)
	assert(from_node)

	# Déconnecte le node 'from' du node 'to'.
	disconnect_node(from, from_slot, to, to_slot)
	
	# Assigne null comme node suivant du node 'from'.
	from_node.next_node = null


###############
## DUPLICATE ##
###############

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


func _on_GraphEdit_copy_nodes_request():
	copied_nodes.clear()
	for node in get_children():
		if node is ImageGraphNode and node.is_selected():
			copied_nodes.append(node)
	print("[cop] selected_nodes = ", selected_nodes)
	print("[cop] copied_nodes = ", copied_nodes)


func get_group_center(nodes: Array) -> Vector2:
	assert(nodes)
	assert(nodes.size())
	var sum: = Vector2.ZERO
	for node in nodes:
		sum += node.rect_position
	return sum / nodes.size()


func _on_GraphEdit_paste_nodes_request():
	print("[paste] selected_nodes = ", selected_nodes)
	print("[paste] copied_nodes = ", copied_nodes)
	if copied_nodes.empty():
		return
	var old_group_center: = get_group_center(copied_nodes)
	var old_to_new: = {}
	deselect_all_nodes()
	var new_group_center: Vector2 = get_global_mouse_position() - rect_position
	for old_node in copied_nodes:
		var new_node = duplicate_node(old_node, convert_viewport_ofs_to_graph_ofs(new_group_center + old_node.rect_position - old_group_center))
		select_node_ex(new_node, false)
		old_to_new[old_node] = new_node
	
	# Connecte les nouveaux nodes comme les anciens.
	connect_duplicated_nodes(old_to_new)


func _on_GraphEdit_duplicate_nodes_request():
	if selected_nodes.empty():
		return
	var old_group_center: = get_group_center(selected_nodes)
	var old_to_new: = {}
	var old_nodes = selected_nodes.duplicate()
	#deselect_all_nodes()
	var new_group_center: Vector2 = get_global_mouse_position() - rect_position
	for old_node in old_nodes:
		deselect_node(old_node)
		var new_node = duplicate_node(old_node, convert_viewport_ofs_to_graph_ofs(new_group_center + old_node.rect_position - old_group_center))
		select_node_ex(new_node, false)
		old_to_new[old_node] = new_node
	
	# Connecte les nouveaux nodes comme les anciens.
	connect_duplicated_nodes(old_to_new)


############
## DELETE ##
############

func delete_node(node: ImageGraphNode):
	assert(node)
	remove_node_connections(node)
	deselect_node(node)
	node.queue_free()


func _on_GraphEdit_delete_nodes_request(node_names: Array):
	for node_name in node_names:
		var node = get_node(node_name)
		assert(node)
		deselect_node(node)
		delete_node(node)


###############
## SAVE/LOAD ##
###############

func clear_graph():
	deselect_all_nodes()
	clear_connections()
	var nodes = get_children()
	for node in nodes:
		if node is ImageGraphNode:
			remove_child(node)
			node.queue_free()


func new_file():
	clear_graph()
	current_file_name = DEFAULT_FILENAME
	current_path = ""
	update_main_window_title()


func init_graph(graph_data: GraphData):
	clear_graph()
	
	colorpicker.color = graph_data.node_bg_color
	node_bg_color = graph_data.node_bg_color
	
	# Nodes
	for node_data in graph_data.nodes:
		var new_node: ImageGraphNode = graph_node.instance()
		new_node.set_name(node_data.name)
		new_node.rect_size = node_data.rect_size
		add_child(new_node, true) # /!\ before assigning data
		new_node.offset = node_data.offset
		new_node.set_bg_color(graph_data.node_bg_color)
		new_node.set_extra_data(node_data.extra_data)
	
	# Connexions
	for connection in graph_data.connections:
		var err = connect_node(connection.from, connection.from_port, connection.to, connection.to_port)
		if err != OK:
			print("Error loading graph: ", err)

		var from_node: ImageGraphNode = get_node(connection.from)
		var to_node: ImageGraphNode = get_node(connection.to)
		assert(from_node)
		assert(to_node)
		from_node.next_node = to_node


func load_graph(path: String):
	var dir = Directory.new()
	if not dir.file_exists(path):
		print("File ", path, " doesn't exist")
		return
	
	if ResourceLoader.exists(path):
		var graph_data = ResourceLoader.load(path)
		if graph_data is GraphData:
			if graph_data.version == FILE_VERSION:
				init_graph(graph_data)
			else:
				print("Error, incompatible file version ", graph_data.version)
				return
	
	current_file_name = path.get_file()
	current_path = path
	update_main_window_title()


func save_graph(path: String):
	# Crée et remplit un nouvau GraphData avec les données du grap et de ses nodes.
	var graph_data = GraphData.new()
	assert(graph_data)
	
	# Version number
	graph_data.version = FILE_VERSION
	graph_data.node_bg_color = node_bg_color
	
	# Graph nodes
	for node in get_children():
		if node is ImageGraphNode:
			var node_data = GraphNodeData.new()
			assert(node_data)
			node_data.name = node.name
			node_data.offset = node.offset
			node_data.rect_size = node.rect_size
			node_data.extra_data = node.get_extra_data()
			graph_data.nodes.append(node_data)
	
	# Connexions
	graph_data.connections = get_connection_list()
	
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
	
	current_file_name = path.get_file()
	current_path = path
	update_main_window_title()


func open_file():
	open_dlg.popup_centered()


func save_file():
	if current_path == "":
		save_file_as()
	else:
		save_graph(current_path)


func save_file_as():
	save_dlg.popup_centered()


func _on_OpenFileDialog_file_selected(path):
	move_popups_out_of_the_way()
	#load_graph("user://saves/", "graph.res")
	# étendre ResourceFormatLoader
	load_graph(path)


func _on_SaveFileDialog_file_selected(path):
	move_popups_out_of_the_way()
	#save_graph("user://saves/", "graph.res")
	# étendre ResourceFormatSaver
	save_graph(path)


#############
## ANIMATE ##
#############

func open_load_image_dialog(node: ImageGraphNode):
	assert(node)
	active_node = node
	image_dlg.popup_centered()


func open_load_sound_dialog(node: ImageGraphNode):
	assert(node)
	active_node = node
	sound_dlg.popup_centered()


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
	assert(active_node)
	move_popups_out_of_the_way()
	active_node.load_thumbnail_from_file(path)
	refresh_display_dialog()


func _on_OpenSndFileDialog_file_selected(path):
	assert(active_node)
	move_popups_out_of_the_way()
	active_node.load_sound_from_file(path)
#	refresh_display_dialog()


func play_animation():
	if selected_nodes.size() != 1:
		return
	display_dlg.init_dialog(selected_nodes.front())
	if display_dlg.window_bounds == Rect2():
		display_dlg.popup_centered()
	else:
		display_dlg.popup(display_dlg.window_bounds)


func _on_PlayButton_pressed():
	play_animation()


func _on_ColorPicker_color_changed(color):
	node_bg_color = color
	for node in get_children():
		if node is ImageGraphNode:
			node.set_bg_color(node_bg_color)
