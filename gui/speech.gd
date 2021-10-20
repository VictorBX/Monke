extends Area2D

const MAX_DELAY_BEFORE_UPDATE = 0.1

var text_timer
var text : Array
var current_text_index = 0
var current_delay_time = 0
var did_begin_displaying_text = false
var did_finish_current_text = false
var did_finish_displaying_text = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel.modulate.a = 0.75
	text_timer = Timer.new()
	text_timer.autostart = false
	text_timer.connect("timeout", self, "on_timer_finished")
	add_child(text_timer)
	start(["Me monke me banana top monke want banana top", "me want banana", "top"])
	
func _process(delta):
	if did_begin_displaying_text && !did_finish_current_text:
		current_delay_time += delta
		if current_delay_time >= MAX_DELAY_BEFORE_UPDATE:
			current_delay_time = 0
			$Panel/Label.percent_visible += visibility_amount_for_current_text()
			if $Panel/Label.percent_visible >= 1:
				did_finish_current_text = true
				text_timer.stop()
				text_timer.start(3.0)

func start(text: Array):
	self.text = text
	if !text.empty() && !did_begin_displaying_text:
		current_text_index = 0
		current_delay_time = 0
		$Panel/Label.percent_visible = 0
		$Panel/Label.text = text[current_text_index]
		did_begin_displaying_text = true
		did_finish_current_text = false
		did_finish_displaying_text = false

func stop():
	$Panel/Label.percent_visible = 0
	$Panel/Label.text = ""
	queue_free()

func on_timer_finished():
	did_finish_current_text = false
	if current_text_index + 1 > text.size() - 1:
		did_finish_displaying_text = true
	else:
		current_delay_time = 0
		current_text_index += 1
		$Panel/Label.percent_visible = 0
		$Panel/Label.text = text[current_text_index]

func visibility_amount_for_current_text():
	return 1.0/text[current_text_index].length()
