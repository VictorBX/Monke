extends Area2D

var idle_timer: Timer
var shine_amount = 0

func _ready():
	connect("body_entered", self, "on_body_entered")
	
	$AnimatedSprite.play("idle")
	idle_timer = Timer.new()
	idle_timer.autostart = false
	idle_timer.one_shot = true
	idle_timer.connect("timeout", self, "on_idle_timer_finished")
	add_child(idle_timer)
	idle_timer.start(5)
	
	$AnimatedSprite.connect("animation_finished", self, "on_animation_finished")

func on_body_entered(body):
	if body.is_in_group("player") :
		get_tree().call_group("hud", "did_finish_game")
		get_tree().call_group("player", "on_finished_game")
		get_tree().call_group("final_screen", "on_finished_game")
		queue_free()

func on_idle_timer_finished():
	$AnimatedSprite.play("shine")

func on_animation_finished():
	if $AnimatedSprite.animation == "shine":
		shine_amount += 1
		if shine_amount >= 2:
			shine_amount = 0
			$AnimatedSprite.play("idle")
			idle_timer.start(5)
		else:
			$AnimatedSprite.frame = 0
			$AnimatedSprite.play("shine")

