extends Node2D

const LEVEL_HEIGHT = 192.0

func _process(delta):
	# update camera location
	var player_ypos = abs($PlayerNode.position.y)
	var camera_offset = floor(player_ypos / LEVEL_HEIGHT)
	$Camera.offset.y = -1 * LEVEL_HEIGHT * camera_offset
