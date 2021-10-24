extends Area2D

const MONKE_SPEECH = [
	"Me monke me eat gold banana top me monke",
	"gold banana top me want me monke eat gold banana"
]

func _ready():
	connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
	if body.is_in_group("player"):
		var speech_position = Vector2(
			position.x - 50,
			position.y - 30
		)
		get_tree().call_group("hud", "display_speech", MONKE_SPEECH, get_instance_id(), speech_position)
