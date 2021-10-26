extends AnimatedSprite

var is_left = true

func _ready():
	scale.x = -1 if is_left else 1
	play("default")

func _on_JumpFartAnimatedSprite_animation_finished():
	queue_free()
