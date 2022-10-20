extends GraphNode
class_name CommentGraphNode


var children: = []
var old_offset: Vector2


func _ready():
	old_offset = offset


func contains_image_node(node: ImageGraphNode):
	return children.has(node)


func add_image_node(node: ImageGraphNode, auto_update: bool):
	if not children.has(node):
		children.push_back(node)
	if auto_update:
		update_size()
	print("children: ", children)
	#var old_position = node.global_position
#	get_parent().remove_child(node)
#	add_child(node)
	#node.set_owner(self)
	#node.global_position = old_position


func remove_image_node(node: ImageGraphNode, auto_update: bool):
	if children.has(node):
		children.erase(node)
	if auto_update:
		update_size()
	print("children: ", children)


func update_size():
	if children.empty():
		return
	var rect: Rect2
	var initialized: = false
	for node in children:
		if initialized:
			var node_rect = Rect2(node.offset, node.rect_size) # graph space
			rect = rect.merge(node_rect)
		else:
			rect = Rect2(node.offset, node.rect_size) # graph space
			initialized = true
	
	set_offset(rect.position - Vector2(24.0, 64.0)) # graph space
	set_size(rect.size + Vector2(24.0 + 24.0, 24.0 + 64.0)) # graph space


func _on_CommentNode_close_request():
	var graph = get_parent()
	assert(graph is GraphEdit)
	assert(graph.has_method("delete_comment_node"))
	graph.delete_comment_node(self)


func _on_AddButton_pressed():
	var graph = get_parent()
	assert(graph is GraphEdit)
	assert(graph.has_method("add_selected_nodes_to_comment_node"))
	graph.add_selected_nodes_to_comment_node(self)


func _on_SubButton_pressed():
	var graph = get_parent()
	assert(graph is GraphEdit)
	assert(graph.has_method("remove_selected_nodes_from_comment_node"))
	graph.remove_selected_nodes_from_comment_node(self)


func _on_CommentNode_resize_request(new_size):
	var graph = get_parent()
	assert(graph is GraphEdit)
	if graph.is_using_snap():
		rect_size = graph.snap_position(new_size)
	else:
		rect_size = new_size


func _on_CommentNode_offset_changed():
	var diff = offset - old_offset
	for node in children:
		assert(node is ImageGraphNode)
		node.offset += diff
	old_offset = offset
