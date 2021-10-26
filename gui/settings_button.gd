extends Node2D

func _on_QuestionMark_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("ui_left_click"):
		$AudioStreamPlayer.play()
		get_tree().call_group("settings", "did_toggle_settings")
