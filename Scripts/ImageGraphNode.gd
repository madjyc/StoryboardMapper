extends GraphNode
class_name ImageGraphNode

const THUMBNAIL_WIDTH: int = 160
const THUMBNAIL_HEIGHT: int = 90

var next_node: ImageGraphNode = null
var next_node_slot: int = 0
var img_path: String
var snd_path: String
var img_texture: ImageTexture = null
var sound: AudioStream = null

var ctrl_key_was_down: bool # Dragging

onready var background: = $VBoxContainer/Control/Background
onready var thumbnail: = $VBoxContainer/Control/Thumbnail
onready var subedit: = $VBoxContainer/SubtitleEdit
onready var spinbox: = $VBoxContainer/HBoxContainer/SpinBox

# Important to know:
#     rect_position is in viewport space, can't be set directly in code (use offset)
#     offset is rect_position in graph space (rect_position is automatically derived from offset)
#     rect_size is in graph space

func _ready():
	assert(background)
	assert(thumbnail)
	assert(subedit)
	assert(spinbox)


# Extra data to be saved
func get_extra_data() -> Dictionary:
	var extra_data = {
			"title": get_title(),
			"img_path": img_path,
			"snd_path": snd_path,
			"subtitle": subedit.text,
			"duration": spinbox.get_value(),
	}
	return extra_data


# Extra data to be loaded
func set_extra_data(extra_data: Dictionary):
	assert(is_inside_tree())
	set_title(extra_data["title"])
	img_path =extra_data["img_path"]
	snd_path = extra_data["snd_path"]
	subedit.text = extra_data["subtitle"]
	spinbox.set_value(extra_data["duration"])
	if not img_path.empty():
		load_thumbnail_from_file(img_path)
	if not snd_path.empty():
		load_sound_from_file(snd_path)


func set_bg_color(color: Color):
	background.color = color


func get_thumbnail_texture():
	return thumbnail.texture


func get_subtitle():
	return subedit.text


func get_duration() -> float:
	return spinbox.get_value()


func _on_GraphNode_resize_request(new_size):
	var graph = get_parent()
	assert(graph is GraphEdit)
	if graph.is_using_snap():
		rect_size = graph.snap_position(new_size)
	else:
		rect_size = new_size


func _on_GraphNode_close_request():
	var graph = get_parent()
	assert(graph is GraphEdit)
	assert(graph.has_method("delete_img_node"))
	graph.delete_img_node(self)


func _on_TextureRect_gui_input(event):
	if not event is InputEventMouseButton:
		return
	
	if event.doubleclick:
		get_parent().play_animation()
		return
	
	if event.get_button_index() == 1:
		var graph: GraphEdit = get_parent()
		if event.pressed:
			assert(graph)
			ctrl_key_was_down = Input.is_key_pressed(KEY_CONTROL)
			if selected:
				if ctrl_key_was_down:
					graph.deselect_node(self)
			else:
				graph.select_img_node(self, !ctrl_key_was_down) # /!\ Ne lance pas de signals.
		
			if selected:
				graph.start_dragging_selected_img_nodes(self)
		else:
			if not graph.stop_dragging_selected_img_nodes():
				if !ctrl_key_was_down:
					graph.select_img_node(self, true) # /!\ Ne lance pas de signals.


func _on_LoadButton_pressed():
	open_image_file()


func _on_SoundButton_pressed():
	open_sound_file()


func _on_DelSoundButton_pressed():
	remove_sound()


func _on_ReloadButton_pressed():
	reload_image_file()
	reload_sound_file()


func update_window_title():
	#set_title(img_path.get_file()) # /!\ Resizes the window!
	var file_name = img_path.get_file()
	file_name = file_name.rstrip('.' + file_name.get_extension())
	set_title(file_name.right(file_name.length() - 25))


func load_thumbnail_from_file(path: String):
	img_path = path
#	texture_rect.texture = load(path)
#	texture_rect.texture.set_flags(Texture.FLAGS_DEFAULT)
	var img = Image.new()
	var err = img.load(path)
	if err != OK:
		print("Error loading image ", path, " : ", err)
		return
	var img_ratio: float = float(img.get_width()) / float(img.get_height())
	img.resize(THUMBNAIL_WIDTH, round(float(THUMBNAIL_WIDTH) / img_ratio), Image.INTERPOLATE_LANCZOS)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	thumbnail.texture = tex
	update_window_title()


func load_sound_from_file(path: String):
	snd_path = path
	#sound = load(path)
	
	var ext: = path.get_extension()
	match ext:
#		"wav":
#			sound = AudioStreamSample.new()
		"mp3":
			sound = AudioStreamMP3.new()
		"ogg":
			sound = AudioStreamOGGVorbis.new()
		_:
			print("Error, unknown sound file extension.")
			return

	var file = File.new()
	file.open(path, File.READ)
	var bytes = file.get_buffer(file.get_len())
	file.close()
	sound.data = bytes


func reload_thumbnail_from_file():
	load_thumbnail_from_file(img_path)


func reload_sound_from_file():
	load_sound_from_file(snd_path)


func remove_sound():
	snd_path = ""
	sound = null


func open_image_file():
	get_parent().open_load_image_dialog(self)


func open_sound_file():
	get_parent().open_load_sound_dialog(self)


func reload_image_file():
	get_parent().reload_node_thumbnail(self)


func reload_sound_file():
	get_parent().reload_node_sound(self)


func _on_GraphNode_offset_changed():
	var graph = get_parent()
	if not graph: # node created but not yet added to the graph
		return
	assert(graph is GraphEdit)
	graph.img_node_offset_changed(self)
