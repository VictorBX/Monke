extends Node2D

const LEVEL_HEIGHT = 192.0
var last_camera_offset

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
