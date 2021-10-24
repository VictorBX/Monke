extends CanvasLayer

const SCREEN_SIZE = Vector2(1024, 768)
const CAMERA_ZOOM = 4

var speech_scene
var speech_instance
var speech_creator_id

func _ready():
	speech_scene = load("res://gui/speech.tscn")

func display_speech(speech: Array, creator_id: int, position: Vector2):
	if speech_instance != null:
		if speech_creator_id == creator_id:
			return
		else:
			remove_current_speech()
		
	var speech_bubble = speech_scene.instance()
	speech_instance = speech_bubble
	speech_creator_id = creator_id
		
	# normalize position to hud space
	var normalized_position = Vector2(
		position.x,
		fmod(position.y, -SCREEN_SIZE.y/CAMERA_ZOOM)
	)
	var hud_position = Vector2(
		normalized_position.x * CAMERA_ZOOM,
		SCREEN_SIZE.y - (normalized_position.y * CAMERA_ZOOM * -1)
	)
	speech_bubble.position = hud_position
	speech_bubble.start(speech)
	add_child(speech_bubble)

func remove_current_speech():
	if speech_instance != null:
		speech_instance.queue_free()
		speech_instance = null
		speech_creator_id = null
