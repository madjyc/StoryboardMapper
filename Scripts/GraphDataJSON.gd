class_name GraphDataJSON
extends Reference

# Load/save data
var version_major: int
var version_minor: int
var version_subminor: int

var scroll_offset: Vector2
var zoom: float
var use_snap : bool
var snap_distance: int

var graph_bg_color: Color
var img_node_bg_color: Color

var img_nodes: Array # array of GraphNodeData
var connections: Array # array of connections
var com_nodes: Array # array of GraphNodeData


func does_save_exists(path: String) -> bool:
	assert(not path.empty())
	if path.empty():
		return false
	
	var file: = File.new()
	return file.file_exists(path)


func save_graph_data(path: String):
	# Create the output directory if it doesn't already exist.
	var dir_path: String = path.get_base_dir()
	var dir = Directory.new()
	if not dir.dir_exists(dir_path):
		dir.make_dir_recursive(dir_path)
	if not dir.dir_exists(dir_path):
		printerr("Makedir failed")
		return
	
	# Save a JSON file containing all graph data.
	var file = File.new()
	var err: int = file.open(path, File.WRITE)
	if err == OK:
		var data: = {
			"version": [version_major, version_minor, version_subminor],
			"scroll_offset": [scroll_offset.x, scroll_offset.y],
			"zoom": zoom,
			"use_snap": use_snap,
			"snap_distance": snap_distance,
			"graph_bg_color": [graph_bg_color.r, graph_bg_color.g, graph_bg_color.b, graph_bg_color.a],
			"img_node_bg_color": [img_node_bg_color.r, img_node_bg_color.g, img_node_bg_color.b, img_node_bg_color.a],
		}
		
		# img_nodes array of GraphNodeData
		var img_node_array: = []
		for node in img_nodes:
			var node_data: Dictionary = {
				"name": node.name,
				"offset": [node.offset.x, node.offset.y],
				"rect_size": [node.rect_size.x, node.rect_size.y],
				"extra_data": node.extra_data, # Dictionary
			}
			img_node_array.push_back(node_data)
		data["img_nodes"] = img_node_array
		
		# connections array of connections
		var connection_array: = []
		for connection in connections:
			var connection_data: = [connection.from, connection.from_port, connection.to, connection.to_port]
			connection_array.push_back(connection_data)
		data["connections"] = connection_array
		
		# com_nodes array of GraphNodeData
		var com_node_array: = []
		for node in com_nodes:
			var node_data: Dictionary = {
				"name": node.name,
				"offset": [node.offset.x, node.offset.y],
				"rect_size": [node.rect_size.x, node.rect_size.y],
				"extra_data": node.extra_data, # Dictionary
			}
			com_node_array.push_back(node_data)
		data["com_nodes"] = com_node_array
		
		var json_string: = JSON.print(data)
		file.store_string(json_string)
	else:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [path, err])
	file.close()


func load_graph_data(path: String):
	var file = File.new()
	var err: int = file.open(path, File.READ)
	if err == OK:
		var content: String = file.get_as_text()
		var data: Dictionary = JSON.parse(content).result
		var arr: Array
		img_nodes.clear()
		connections.clear()
		com_nodes.clear()
		
		arr = data["version"]
		version_major = arr[0]
		version_minor = arr[1]
		version_subminor = arr[2]
		
		arr = data["scroll_offset"]
		scroll_offset = Vector2(arr[0], arr[1])
		
		zoom = data["zoom"]
		use_snap = data["use_snap"]
		snap_distance = data["snap_distance"]
		
		arr = data["graph_bg_color"]
		graph_bg_color = Color(arr[0], arr[1], arr[2], arr[3])
		
		arr = data["img_node_bg_color"]
		img_node_bg_color = Color(arr[0], arr[1], arr[2], arr[3])
		
		# img_nodes array of GraphNodeData
		var img_node_array: Array = data["img_nodes"]
		for img_node_data in img_node_array:
			var node: = GraphNodeData.new()
			node.name = img_node_data.name
			node.offset = Vector2(img_node_data.offset[0], img_node_data.offset[1])
			node.rect_size = Vector2(img_node_data.rect_size[0], img_node_data.rect_size[1])
			node.extra_data = img_node_data.extra_data # Dictionary
			img_nodes.push_back(node)
		
		# connections array of connections
		var connection_array: Array = data["connections"]
		for connection_data in connection_array:
			var connection: Dictionary
			connection.from = connection_data[0]
			connection.from_port = connection_data[1]
			connection.to = connection_data[2]
			connection.to_port = connection_data[3]
			connections.push_back(connection)
		
		# com_nodes array of GraphNodeData
		var com_node_array: Array = data["com_nodes"]
		for com_node_data in com_node_array:
			var node: = GraphNodeData.new()
			node.name = com_node_data.name
			node.offset = Vector2(com_node_data.offset[0], com_node_data.offset[1])
			node.rect_size = Vector2(com_node_data.rect_size[0], com_node_data.rect_size[1])
			node.extra_data = com_node_data.extra_data # Dictionary
			com_nodes.push_back(node)
	else:
		printerr("Could not open the file %s. Aborting load operation. Error code: %s" % [path, err])
	file.close()
