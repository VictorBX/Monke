extends Area2D

var is_available = true

func _ready():
	connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
	if is_available && body.is_in_group("player") :
		get_tree().call_group("player", "did_get_banana", self)
	
func disable_banana():
	is_available = false
	$AnimatedSprite.modulate.a = 0.5

func enable_banana():
	is_available = true
	$AnimatedSprite.modulate.a = 1.0
