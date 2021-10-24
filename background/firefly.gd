extends Node2D

const FLY_ANIMATIONS = ["fly_1", "fly_2"]

func _ready():
	$AnimationPlayer.play(FLY_ANIMATIONS[rand_range(0, FLY_ANIMATIONS.size() - 1)])
