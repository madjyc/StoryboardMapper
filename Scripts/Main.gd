extends Control

enum {
	FILE_MENU_NEW,
	FILE_MENU_OPEN,
	FILE_MENU_SAVE,
	FILE_MENU_SAVEAS,
	FILE_MENU_SEPARATOR_1,
	FILE_EXPORT_VIDEO,
	FILE_MENU_SEPARATOR_2,
	FILE_MENU_QUIT,
}

enum {
	FILE_RECENT_SUBMENU_URL0,
	FILE_RECENT_SUBMENU_URL1,
	FILE_RECENT_SUBMENU_URL2,
	FILE_RECENT_SUBMENU_URL3,
	FILE_RECENT_SUBMENU_URL4,
	FILE_RECENT_SUBMENU_URL5,
	FILE_RECENT_SUBMENU_URL6,
	FILE_RECENT_SUBMENU_URL7,
	FILE_RECENT_SUBMENU_URL8,
	FILE_RECENT_SUBMENU_URL9,
	FILE_RECENT_SUBMENU_SEPARATOR_1,
	FILE_RECENT_SUBMENU_CLEAR,
}

enum {
	EDIT_MENU_CUT,
	EDIT_MENU_COPY,
	EDIT_MENU_PASTE,
	EDIT_MENU_DUPLICATE,
	EDIT_MENU_SEPARATOR_1,
	EDIT_MENU_ALIGN_HORZ,
	EDIT_MENU_ALIGN_VERT,
	EDIT_MENU_SEPARATOR_2,
	EDIT_MENU_DISTRIB_ROW,
	EDIT_MENU_DISTRIB_COL,
	EDIT_MENU_DISTRIB_DIAG,
	EDIT_MENU_DISTRIB_GRID,
	EDIT_MENU_SEPARATOR_3,
	EDIT_MENU_STORE_SIZE,
	EDIT_MENU_RESIZE_TO_STORED,
	EDIT_MENU_SEPARATOR_4,
	EDIT_MENU_DISCONNECT,
}

enum {
	SELEC_MENU_SELECT_ALL,
	SELEC_MENU_DESELECT_ALL,
	SELEC_MENU_SEPARATOR_1,
	SELEC_MENU_SELECT_BEFORE,
	SELEC_MENU_SELECT_AFTER,
	SELEC_MENU_SELECT_CONNECTED,
	SELEC_MENU_SELECT_GRAPH,
}

enum {
	HELP_MENU_HELP,
	HELP_MENU_FFMPEG,
	HELP_MENU_SEPARATOR_1,
	HELP_MENU_WEBSITE,
	HELP_MENU_SEPARATOR_2,
	HELP_MENU_ABOUT,
}

const APP_NAME: String = "StoryboardMapper"
const DEFAULT_PROJECT_FILENAME: String = "Untitled"

var recent_submenu = PopupMenu.new()
var recent_files: = []
var project_file_path: String
var project_file_name: String

onready var file_menu_button: = $CanvasLayer/HBoxContainer/FileMenuButton
onready var edit_menu_button: = $CanvasLayer/HBoxContainer/EditMenuButton
onready var selec_menu_button: = $CanvasLayer/HBoxContainer/SelecMenuButton
onready var help_menu_button: = $CanvasLayer/HBoxContainer/HelpMenuButton
onready var graph: = $Graph
onready var help_dlg: = $HelpDialog
onready var ffmpeg_dlg: = $FFMpegDialog
onready var about_dlg: = $AboutDialog
onready var open_project_file_dlg: = $OpenFileDialog
onready var save_project_file_dlg: = $SaveFileDialog


func _ready():
	assert(file_menu_button)
	assert(edit_menu_button)
	assert(selec_menu_button)
	assert(help_menu_button)
	assert(graph)
	var popup: PopupMenu
	move_hidden_popups_out_of_the_way()
	
	project_file_name = DEFAULT_PROJECT_FILENAME
	project_file_path = ""
	update_main_window_title()
	
	# --- File Menu ---
	recent_submenu.connect("id_pressed", self, "_on_FileRecentSubmenu_item_pressed")
	recent_submenu.set_name("recent_submenu")
	populate_recent_submenu()

	popup = file_menu_button.get_popup()
	popup.connect("id_pressed", self, "_on_FileMenu_item_pressed")
	popup.add_item("New", FILE_MENU_NEW, KEY_N | KEY_MASK_CTRL)
	popup.add_item("Open...", FILE_MENU_OPEN, KEY_O | KEY_MASK_CTRL)
	popup.add_child(recent_submenu)
	popup.add_submenu_item("Open Recent", "recent_submenu")
	popup.add_item("Save", FILE_MENU_SAVE, KEY_S | KEY_MASK_CTRL)
	popup.add_item("Save As...", FILE_MENU_SAVEAS, KEY_S | KEY_MASK_CTRL | KEY_MASK_SHIFT)
	popup.add_separator()
	popup.add_item("Export to Video", FILE_EXPORT_VIDEO)
	popup.add_separator()
	popup.add_item("Quit", FILE_MENU_QUIT, KEY_Q | KEY_MASK_CTRL)
	
	popup.set_item_tooltip(FILE_EXPORT_VIDEO, "Export sequence to video, starting from selected frame. To enable this option, please download and install FFMpeg as explained in the Help menu.")
	popup.set_item_tooltip(FILE_MENU_QUIT, "C'mon. Really?")
	
	# --- Edit Menu ---
	popup = edit_menu_button.get_popup()
	popup.connect("id_pressed", self, "_on_EditMenu_item_pressed")
	popup.add_item("Cut", EDIT_MENU_CUT, KEY_X | KEY_MASK_CTRL)
	popup.add_item("Copy", EDIT_MENU_COPY, KEY_C | KEY_MASK_CTRL)
	popup.add_item("Paste", EDIT_MENU_PASTE, KEY_V | KEY_MASK_CTRL)
	popup.add_item("Duplicate", EDIT_MENU_DUPLICATE, KEY_D | KEY_MASK_CTRL)
	popup.add_separator()
	popup.add_item("Align Horizontally", EDIT_MENU_ALIGN_HORZ, KEY_X)# | KEY_MASK_CTRL | KEY_MASK_SHIFT)
	popup.add_item("Align Vertically", EDIT_MENU_ALIGN_VERT, KEY_Y)# | KEY_MASK_CTRL | KEY_MASK_SHIFT)
	popup.add_separator()
	popup.add_item("Distribute Horizontally", EDIT_MENU_DISTRIB_ROW, KEY_H)# | KEY_MASK_CTRL | KEY_MASK_SHIFT)
	popup.add_item("Distribute Vertically", EDIT_MENU_DISTRIB_COL, KEY_V)# | KEY_MASK_CTRL | KEY_MASK_SHIFT)
	popup.add_item("Distribute Diagonally", EDIT_MENU_DISTRIB_DIAG, KEY_D)# | KEY_MASK_CTRL | KEY_MASK_SHIFT)
	popup.add_item("Distribute Grid", EDIT_MENU_DISTRIB_GRID, KEY_G)# | KEY_MASK_CTRL | KEY_MASK_SHIFT)
	popup.add_separator()
	popup.add_item("Store Size", EDIT_MENU_STORE_SIZE)#, KEY_G)# | KEY_MASK_CTRL | KEY_MASK_SHIFT)
	popup.add_item("Apply Stored Size", EDIT_MENU_RESIZE_TO_STORED)#, KEY_G)# | KEY_MASK_CTRL | KEY_MASK_SHIFT)
	popup.add_separator()
	popup.add_item("Disconnect", EDIT_MENU_DISCONNECT)
	
	popup.set_item_tooltip(EDIT_MENU_DUPLICATE, "Duplicate selected frames.")
	popup.set_item_tooltip(EDIT_MENU_ALIGN_HORZ, "Align selected frames horizontally.")
	popup.set_item_tooltip(EDIT_MENU_ALIGN_VERT, "Align selected frames vertically.")
	popup.set_item_tooltip(EDIT_MENU_DISTRIB_ROW, "Distribute all frames downstream of the selected frame on a single row.")
	popup.set_item_tooltip(EDIT_MENU_DISTRIB_COL, "Distribute all frames downstream of the selected frame on a single column.")
	popup.set_item_tooltip(EDIT_MENU_DISTRIB_DIAG, "Distribute all frames downstream of the selected frame diagonally.")
	popup.set_item_tooltip(EDIT_MENU_DISTRIB_GRID, "Distribute all frames downstream of the selected frame in columns. The number of columns is defined in the spinbox at the top of the screen.")
	popup.set_item_tooltip(EDIT_MENU_STORE_SIZE, "Store selected frame's size.")
	popup.set_item_tooltip(EDIT_MENU_RESIZE_TO_STORED, "Apply stored size to selected frames.")
	popup.set_item_tooltip(EDIT_MENU_DISCONNECT, "Disconnect selected frames.")
	
	# --- Select Menu ---
	popup = selec_menu_button.get_popup()
	popup.connect("id_pressed", self, "_on_SelecMenu_item_pressed")
	popup.add_item("Select All", SELEC_MENU_SELECT_ALL, KEY_A | KEY_MASK_CTRL)
	popup.add_item("Deselect All", SELEC_MENU_DESELECT_ALL, KEY_A | KEY_MASK_CTRL | KEY_MASK_SHIFT)
	popup.add_separator()
	popup.add_item("Select Before", SELEC_MENU_SELECT_BEFORE, KEY_B)# | KEY_MASK_CTRL)
	popup.add_item("Select After", SELEC_MENU_SELECT_AFTER, KEY_A)# | KEY_MASK_CTRL)
	popup.add_item("Select Connected", SELEC_MENU_SELECT_CONNECTED, KEY_C)# | KEY_MASK_CTRL)
	popup.add_item("Select Graph", SELEC_MENU_SELECT_GRAPH, KEY_I)# | KEY_MASK_CTRL)
	
	popup.set_item_tooltip(SELEC_MENU_SELECT_BEFORE, "Select all frames upstream of the selected frames.")
	popup.set_item_tooltip(SELEC_MENU_SELECT_AFTER, "Select all frames downstream of the selected frames.")
	popup.set_item_tooltip(SELEC_MENU_SELECT_CONNECTED, "Select all frames both upstream and downstream the selected frames.")
	popup.set_item_tooltip(SELEC_MENU_SELECT_GRAPH, "Select all frames in the charts that include the selected frames.")
	
	# --- Help Menu ---
	popup = help_menu_button.get_popup()
	popup.connect("id_pressed", self, "_on_HelpMenu_item_pressed")
	popup.add_item("Quick Guide", HELP_MENU_HELP, KEY_F1)
	popup.add_item("How to install FFMpeg", HELP_MENU_FFMPEG)
	popup.add_separator()
	popup.add_item("Website", HELP_MENU_WEBSITE)
	popup.add_separator()
	popup.add_item("About", HELP_MENU_ABOUT)


func populate_recent_submenu():
	load_recent_paths()
	recent_submenu.clear()
	recent_files.push_back("DrumsOfTumbalku_Seq001_Sht020_Prt50_Ver01.png")
	recent_files.push_back("DrumsOfTumbalku_Seq001_Sht026_Prt03_Ver01.png")
	for i in range(recent_files.size()):
		var url: String = recent_files[i]
		url = url.rstrip('.' + url.get_extension())
		url = url.right(url.length() - 10)
		recent_submenu.add_item(url, i)
	
	recent_submenu.add_separator()
	recent_submenu.add_item("Clear Recent Files")#, FILE_RECENT_SUBMENU_CLEAR)
#	recent_submenu.set_item_tooltip(FILE_RECENT_SUBMENU_CLEAR, "Clear the list of recent files.")


func load_recent_paths():
	pass


func save_path_to_recent(path: String):
	pass


func _on_FileMenuButton_about_to_show():
	var popup: PopupMenu = file_menu_button.get_popup()
	var num_selected: int = graph.get_num_selected_img_nodes()
	var dir = Directory.new()
	popup.set_item_disabled(FILE_EXPORT_VIDEO, num_selected != 1 or not dir.file_exists("res://ffmpeg.exe"))
	
	# Recent files submenu


func _on_FileMenu_item_pressed(item_id: int):
	match item_id:
		FILE_MENU_NEW:
			new_project()
		FILE_MENU_OPEN:
			open_project_file()
		FILE_MENU_SAVE:
			save_project_file()
		FILE_MENU_SAVEAS:
			save_project_file_as()
		FILE_EXPORT_VIDEO:
			graph.display_export_video_file_dialog()
		FILE_MENU_QUIT:
			get_tree().quit()


func _on_FileRecentSubmenu_item_pressed(item_id: int):
	match item_id:
		FILE_RECENT_SUBMENU_CLEAR:
			recent_files.clear()
			populate_recent_submenu()


func _on_EditMenuButton_about_to_show():
	var popup: PopupMenu = edit_menu_button.get_popup()
	var num_selected: int = graph.get_num_selected_img_nodes()
	var num_copied: int = graph.get_num_copied_nodes()
	popup.set_item_disabled(EDIT_MENU_CUT, num_selected == 0)
	popup.set_item_disabled(EDIT_MENU_COPY, num_selected == 0)
	popup.set_item_disabled(EDIT_MENU_PASTE, num_copied == 0)
	popup.set_item_disabled(EDIT_MENU_DUPLICATE, num_selected == 0)
	popup.set_item_disabled(EDIT_MENU_ALIGN_HORZ, num_selected < 2)
	popup.set_item_disabled(EDIT_MENU_ALIGN_VERT, num_selected < 2)
	popup.set_item_disabled(EDIT_MENU_DISTRIB_ROW, num_selected != 1)
	popup.set_item_disabled(EDIT_MENU_DISTRIB_COL, num_selected != 1)
	popup.set_item_disabled(EDIT_MENU_DISTRIB_DIAG, num_selected != 1)
	popup.set_item_disabled(EDIT_MENU_DISTRIB_GRID, num_selected != 1)
	popup.set_item_disabled(EDIT_MENU_STORE_SIZE, num_selected != 1)
	popup.set_item_disabled(EDIT_MENU_RESIZE_TO_STORED, num_selected == 0)


func _on_EditMenu_item_pressed(item_id: int):
	match item_id:
		EDIT_MENU_CUT:
#			#OS.set_clipboard(string)
			graph._on_GraphEdit_cut_nodes_request()
		EDIT_MENU_COPY:
#			#OS.set_clipboard(string)
			#emit_signal("copy_nodes_request")
			graph._on_GraphEdit_copy_nodes_request()
		EDIT_MENU_PASTE:
#			#var str: string = OS.get_clipboard()
			#emit_signal("paste_nodes_request")
			graph._on_GraphEdit_paste_nodes_request()
		EDIT_MENU_DUPLICATE:
			graph._on_GraphEdit_duplicate_nodes_request()
		EDIT_MENU_ALIGN_HORZ:
			graph.align_horizontally()
		EDIT_MENU_ALIGN_VERT:
			graph.align_vertically()
		EDIT_MENU_DISTRIB_ROW:
			graph.distribute_row()
		EDIT_MENU_DISTRIB_COL:
			graph.distribute_col()
		EDIT_MENU_DISTRIB_DIAG:
			graph.distribute_diag()
		EDIT_MENU_DISTRIB_GRID:
			graph.distribute_grid()
		EDIT_MENU_STORE_SIZE:
			graph.store_selected_img_node_as_custom_img_node_size()
		EDIT_MENU_RESIZE_TO_STORED:
			graph.resize_selected_img_nodes_to_custom_img_node_size()
		EDIT_MENU_DISCONNECT:
			graph.remove_selected_img_nodes_connections()


func _on_SelecMenuButton_about_to_show():
	var popup: PopupMenu = selec_menu_button.get_popup()
	var num_selected: int = graph.get_num_selected_img_nodes()
	#popup.set_item_disabled(SELEC_MENU_SELECT_ALL, false)
	popup.set_item_disabled(SELEC_MENU_DESELECT_ALL, num_selected == 0)
	popup.set_item_disabled(SELEC_MENU_SELECT_BEFORE, num_selected == 0)
	popup.set_item_disabled(SELEC_MENU_SELECT_AFTER, num_selected == 0)
	popup.set_item_disabled(SELEC_MENU_SELECT_CONNECTED, num_selected == 0)
	popup.set_item_disabled(SELEC_MENU_SELECT_GRAPH, num_selected == 0)


func _on_SelecMenu_item_pressed(item_id: int):
	match item_id:
		SELEC_MENU_SELECT_ALL:
			graph.select_all_nodes()
		SELEC_MENU_DESELECT_ALL:
			graph.deselect_all_nodes()
		SELEC_MENU_SELECT_BEFORE:
			graph.select_all_img_nodes_before_selected_img_nodes()
		SELEC_MENU_SELECT_AFTER:
			graph.select_all_img_nodes_after_selected_img_nodes()
		SELEC_MENU_SELECT_CONNECTED:
			graph.select_all_img_nodes_flowing_through_selected_img_nodes()
		SELEC_MENU_SELECT_GRAPH:
			graph.select_all_interconnected_img_nodes_with_selected_img_nodes()


func _on_HelpMenu_item_pressed(item_id: int):
	match item_id:
		HELP_MENU_HELP:
			help_dlg.popup_centered()
		HELP_MENU_FFMPEG:
			ffmpeg_dlg.popup_centered()
		HELP_MENU_WEBSITE:
			OS.shell_open("https://github.com/madjyc/StoryboardMapper")
		HELP_MENU_ABOUT:
			about_dlg.popup_centered()


# Hack to prevent hidden popups from stealing mouse input.
func move_hidden_popups_out_of_the_way():
	var infinite_pos: = Vector2(-1e6, -1e6)
	if help_dlg and not help_dlg.visible:
		help_dlg.rect_position = infinite_pos
	if ffmpeg_dlg and not ffmpeg_dlg.visible:
		ffmpeg_dlg.rect_position = infinite_pos
	if about_dlg and not about_dlg.visible:
		about_dlg.rect_position = infinite_pos
	if not open_project_file_dlg.visible:
		open_project_file_dlg.rect_position = infinite_pos
	if not save_project_file_dlg.visible:
		save_project_file_dlg.rect_position = infinite_pos


func _on_HelpDialog_popup_hide():
	move_hidden_popups_out_of_the_way()


func _on_FFMpegDialog_popup_hide():
	move_hidden_popups_out_of_the_way()


func _on_AboutDialog_popup_hide():
	move_hidden_popups_out_of_the_way()


func _on_Label2_meta_clicked(meta):
	OS.shell_open(str(meta))


func update_main_window_title():
	OS.set_window_title(project_file_name + " - " + APP_NAME)


func new_project():
	project_file_name = DEFAULT_PROJECT_FILENAME
	project_file_path = ""
	update_main_window_title()
	graph.clear_graph()


func open_project_file():
	open_project_file_dlg.popup_centered()


func save_project_file():
	if project_file_path == "":
		save_project_file_as()
	else:
		graph.save_graph_to_file(project_file_path)


func save_project_file_as():
	save_project_file_dlg.popup_centered()


func _on_OpenFileDialog_file_selected(path):
	project_file_name = path.get_file()
	project_file_path = path
	update_main_window_title()
	graph.load_graph_from_file(path)


func _on_SaveFileDialog_file_selected(path):
	project_file_name = path.get_file()
	project_file_path = path
	update_main_window_title()
	graph.save_graph_to_file(path)
