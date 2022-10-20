extends ColorRect
class_name CommentRect


var children: = []
var old_rect: Rect2


func _ready():
	old_rect = get_rect()


func contains_image_node(node: ImageGraphNode):
	return children.has(node)


func add_image_node(node: ImageGraphNode, auto_update: bool):
	if not children.has(node):
		children.push_back(node)
	if auto_update:
		update_size()
	print("children: ", children)


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
			rect = rect.merge(node.get_rect())
		else:
			rect = node.get_rect()
			initialized = true
	rect = rect.grow_individual (24.0, 64.0, 24.0, 24.0)
	if rect_position != rect.position:
		rect_position = rect.position
	if rect_size != rect.size:
		rect_size = rect.size


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


func _on_CloseButton_pressed():
	var graph = get_parent()
	assert(graph is GraphEdit)
	assert(graph.has_method("delete_comment_node"))
	graph.delete_comment_node(self)
