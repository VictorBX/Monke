extends Node2D

func _ready():
	pass # Replace with function body.

func _on_StartArea2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("ui_left_click"):
		$AudioStreamPlayer.play()
		get_tree().change_scene("res://level/level.tscn")
