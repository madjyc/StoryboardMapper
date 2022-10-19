extends WindowDialog
class_name DisplayDialog


enum {
	PLAYING,
	STOPPED,
}

var window_bounds: = Rect2()
var node_chain: Array = []
var node_chain_index: int = -1
var state: int = STOPPED
var is_looping = false

onready var graph_node = preload("res://Scenes/GraphNode.tscn")
onready var display_rect: = $VBoxContainer/Control/TextureRect
onready var subtitle: = $VBoxContainer/Control/Subtitle
onready var subedit: = $VBoxContainer/HBoxContainer/SubtitleEdit
onready var spinbox: = $VBoxContainer/HBoxContainer/SpinBox
onready var play_timer: = $PlayTimer
onready var audio_player: = $AudioStreamPlayer


func _ready():
	assert(graph_node)
	assert(display_rect)
	assert(subtitle)
	assert(subedit)
	assert(play_timer)
	assert(audio_player)
	move_popup_out_of_the_way()


func init_dialog(first: ImageGraphNode):
	assert(first)
	state = STOPPED
	update_node_chain(first)


# Hack to prevent hidden popups from stealing mouse input.
func move_popup_out_of_the_way():
	var infinite_pos: = Vector2(-1e6, -1e6)
	rect_position = infinite_pos


#func load_image_async(index: int):
#	assert(index >= 0)
#	assert(index < node_chain.size())
#	var node: ImageGraphNode = node_chain[index]
#	assert(node)
#	var img_loader: AsyncImageLoader = AsyncImageLoader
#	assert(img_loader)
#	img_loader.load_image_async(node.img_path)
#
#
#func purge_image_async(index: int):
#	assert(index >= 0)
#	assert(index < node_chain.size())
#	var node: ImageGraphNode = node_chain[index]
#	assert(node)
#	var img_loader: AsyncImageLoader = AsyncImageLoader
#	assert(img_loader)
#	img_loader.purge_image_from_cache(node.img_path)
#
#
#func update_image_cache(index: int):
#	# Unloads 3 frames starting from index.
#	var min_index = max(index - 1, 0)
#	for i in range(min_index, index):
#		purge_image_async(index)
#
#	# Loads 3 frames starting from index.
#	var max_index = min(index + 3, node_chain.size())
#	for i in range(index, max_index):
#		load_image_async(i)


func _on_DisplayDialog_about_to_show():
	assert(node_chain.size())
	#display_node(0)
	play_animation_from_start()


func _on_DisplayDialog_popup_hide():
	stop_animation()
	window_bounds.position = rect_position
	window_bounds.size = rect_size
	move_popup_out_of_the_way()


func _on_PlayButton_pressed():
	toggle_pause_resume_animation()


func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		toggle_pause_resume_animation()


func _on_StopButton_pressed():
	stop_animation()


func _on_FirstButton_pressed():
	pause_animation()
	display_node(0, false)


func _on_LastButton_pressed():
	pause_animation()
	display_node(node_chain.size() - 1, false)


func _on_PrevButton_pressed():
	pause_animation()
	if node_chain_index > 0:
		display_node(node_chain_index - 1, false)


func _on_NextButton_pressed():
	pause_animation()
	if node_chain_index < node_chain.size() - 1:
		display_node(node_chain_index + 1, false)


func _on_LoopButton_toggled(button_pressed: bool):
	is_looping = button_pressed


func _on_PlayTimer_timeout():
	assert(state == PLAYING)
	assert(node_chain_index >= 0)
	
	# Joue le prochain node de la chaine si possible.
	if node_chain_index < node_chain.size() - 1:
		play_node(node_chain_index + 1)
		return

	# On est arrivé à la fin, recommencer ?
	if is_looping:
		play_animation_from_start()
	else:
		stop_animation()


func update_node_chain(first: ImageGraphNode):
	assert(first)
	node_chain_index = -1
	node_chain.clear()
	var node: = first
	while node != null:
		node_chain.push_back(node)
		node = node.next_node


func play_animation_from_start():
	play_node(0)


func toggle_pause_resume_animation():
	assert(node_chain.size())
	match state:
		PLAYING:
			pause_animation()
		STOPPED:
			resume_animation()


func pause_animation():
	state = STOPPED
	spinbox.editable = true
	if not play_timer.is_stopped():
		play_timer.stop()


func resume_animation():
	play_node(node_chain_index)


func stop_animation():
	pause_animation()
	#display_node(0)


func play_node(index: int):
	state = PLAYING
	spinbox.editable = false
	display_node(index, true)
	var node: ImageGraphNode = node_chain[index]
	play_timer.start(node.get_duration())


func refresh():
	assert(node_chain.size())
	assert(node_chain_index >= 0)
	assert(node_chain_index < node_chain.size())
	display_node(node_chain_index, false)


func display_node(index: int, play_sound: bool):
	assert(index >= 0)
	assert(index < node_chain.size())
	assert(display_rect)
	node_chain_index = index
	var node: ImageGraphNode = node_chain[index]
	
	var tex = load_image_from_file(node.img_path)
	display_rect.texture = tex if tex else node.get_thumbnail_texture()
	
	if audio_player.is_playing():
		audio_player.stop()
	if play_sound and node.sound:
		audio_player.stream = node.sound
		audio_player.play()
	
	update_window_title(node.img_path)
	
	subtitle.text = node.get_subtitle()
	subedit.text = node.get_subtitle()
	
	spinbox.set_value(node.get_duration())


func load_image_from_file(path: String) -> ImageTexture:
	var img = Image.new()
	var err = img.load(path)
	if err != OK:
		print("Error loading image ", path, " : ", err)
		return null
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex


func update_window_title(path: String):
	var file_name = path.get_file()
	file_name = file_name.rstrip('.' + file_name.get_extension())
	set_title(file_name)


func _on_SubtitleEdit_text_changed():
	var node: ImageGraphNode = node_chain[node_chain_index]
	assert(node)
	subtitle.text = subedit.text
	node.subedit.text = subedit.text


func _on_SpinBox_value_changed(value):
	var node: ImageGraphNode = node_chain[node_chain_index]
	assert(node)
	if value != node.get_duration():
		assert(state == STOPPED)
		node.spinbox.set_value(value)


func _on_LoadButton_pressed():
	var node: ImageGraphNode = node_chain[node_chain_index]
	assert(node)
	node.open_image_file()


func _on_SoundButton_pressed():
	var node: ImageGraphNode = node_chain[node_chain_index]
	assert(node)
	node.open_sound_file()


func _on_ReloadButton_pressed():
	var node: ImageGraphNode = node_chain[node_chain_index]
	assert(node)
	node.reload_image_file()


func _on_DelSoundButton_pressed():
	var node: ImageGraphNode = node_chain[node_chain_index]
	assert(node)
	node.remove_sound()
