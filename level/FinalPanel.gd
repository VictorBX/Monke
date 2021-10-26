extends Panel

func on_finished_game():
	visible = true
	$AnimationPlayer.play("FadeIn")
