extends Node2D

const LEVEL_HEIGHT = 192.0
const SAVE_FILE_LOCATION = "user://return_to_monke.save"

var last_camera_offset

func _ready():
	# check for save data
	read_save_data()

func _process(delta):
	# update camera location
	if last_camera_offset == null:
		last_camera_offset = $Camera.offset
	elif last_camera_offset != $Camera.offset:
		last_camera_offset = $Camera.offset
		$HUDCanvasLayer.remove_current_speech()
	var player_ypos = abs($PlayerNode.position.y)
	var camera_offset = floor(player_ypos / LEVEL_HEIGHT)
	$Camera.offset.y = -1 * LEVEL_HEIGHT * camera_offset

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_data()

# Save data
func save_data():
	var save_data = {
		"player_position_x": $PlayerNode.position.x,
		"player_position_y": $PlayerNode.position.y,
		"gameplay_time_seconds": $HUDCanvasLayer.gameplay_time_seconds,
		"why_are_you_here?": "please leave thanks"
	}
	var save_file = File.new()
	save_file.open(SAVE_FILE_LOCATION, File.WRITE)
	save_file.store_line(to_json(save_data))
	save_file.close()

func clear_save_data():
	var save_data = {
		"why_are_you_here?": "please leave thanks"
	}
	var save_file = File.new()
	save_file.open(SAVE_FILE_LOCATION, File.WRITE)
	save_file.store_line(to_json(save_data))
	save_file.close()

func read_save_data():
	var save_file = File.new()
	if save_file.file_exists(SAVE_FILE_LOCATION):
		save_file.open(SAVE_FILE_LOCATION, File.READ)
		while save_file.get_position() < save_file.get_len():
			var node_data = parse_json(save_file.get_line())
			if node_data.has("player_position_x") && node_data.has("player_position_y"):
				$PlayerNode.position = Vector2(node_data["player_position_x"], node_data["player_position_y"])
			if node_data.has("gameplay_time_seconds"):
				$HUDCanvasLayer.gameplay_time_seconds = node_data["gameplay_time_seconds"]
				$HUDCanvasLayer.update_timer()
		save_file.close()

# Game Setting Callbacks
func did_save_and_quit_game():
	save_data()
	get_tree().change_scene("res://level/menu.tscn")
	
func did_reset_game():
	clear_save_data()
	get_tree().change_scene("res://level/menu.tscn")
