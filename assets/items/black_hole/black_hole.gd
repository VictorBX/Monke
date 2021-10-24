extends Area2D

func _ready():
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")

func get_size():
	return $CollisionShape2D.shape.extents

func on_body_entered(body):
	if body.is_in_group("player"):
		get_tree().call_group("player", "did_enter_black_hole", self)

func on_body_exited(body):
	if body.is_in_group("player"):
		get_tree().call_group("player", "did_exit_black_hole", self)
