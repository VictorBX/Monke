extends CanvasLayer

const SCREEN_SIZE = Vector2(1024, 768)
const CAMERA_ZOOM = 4
const MAX_LEVEL_HEIGHT = 2280

var speech_scene
var speech_instance
var speech_creator_id
var player_node

var gameplay_time_seconds = 0
var game_timer: Timer
var game_finished = false

var player_can_restart = false
var restart_timer: Timer

func _ready():
	restart_timer = Timer.new()
	restart_timer.autostart = false
	restart_timer.one_shot = true
	restart_timer.connect("timeout", self, "on_restart_timer_finished")
	add_child(restart_timer)
	
	speech_scene = load("res://gui/speech.tscn")
	player_node = get_tree().get_root().get_node("LevelNode").find_node("PlayerNode")
	update_timer()
	game_timer = Timer.new()
	game_timer.autostart = false
	game_timer.connect("timeout", self, "on_timer_timeout")
	add_child(game_timer)
	game_timer.start(1)
	
func _process(delta):
	if !game_finished:
		var progress = clamp(abs(player_node.position.y)/MAX_LEVEL_HEIGHT * 100, 0, 100)
		$ProgressLabel.text = "%.f%%" % progress
		
	if player_can_restart:
		if Input.is_action_just_pressed("ui_select"):
			get_tree().change_scene("res://level/menu.tscn")

func on_timer_timeout():
	if !game_finished:
		gameplay_time_seconds += 1
		update_timer()
	
func update_timer():
	var minutes = int(gameplay_time_seconds / 60)
	var seconds = gameplay_time_seconds - (minutes * 60)
	var display_minutes = ("0%d" % minutes) if minutes < 10 else ("%d" % minutes)
	var display_seconds = ("0%d" % seconds) if seconds < 10 else ("%d" % seconds)
	$TimerLabel.text = "%s:%s" % [display_minutes, display_seconds]

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

func did_finish_game():
	game_finished = true
	$ProgressLabel.text = "100%"
	$QuestionMark.modulate.a = 0
	$CongratsRichTextLabel.visible = true
	restart_timer.start(5)

func on_restart_timer_finished():
	player_can_restart = true
	$RestartLabel.visible = true
