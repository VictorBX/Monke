extends CanvasLayer

const MUSIC_INDEX = 1
const SFX_INDEX = 2

func _ready():
	$BackgroundPanel.visible = false
	load_sound_settings()

func did_toggle_settings():
	$BackgroundPanel.visible = !$BackgroundPanel.visible

func _on_MusicVSlider_value_changed(value):
	var volume = value
	if volume <= -24:
		AudioServer.set_bus_mute(MUSIC_INDEX, true)
	else:
		AudioServer.set_bus_mute(MUSIC_INDEX, false)
		AudioServer.set_bus_volume_db(MUSIC_INDEX, volume)

func _on_SFXVSlider_value_changed(value):
	var volume = value
	if volume <= -24:
		AudioServer.set_bus_mute(SFX_INDEX, true)
	else:
		AudioServer.set_bus_mute(SFX_INDEX, false)
		AudioServer.set_bus_volume_db(SFX_INDEX, volume)

func hide_quit():
	$BackgroundPanel/QuitRichTextLabel.hide()
	$BackgroundPanel/SaveAndQuitButton.hide()
	$BackgroundPanel/ResetButton.hide()
	$BackgroundPanel/SaveAndQuitButton.disabled = true
	$BackgroundPanel/ResetButton.disabled = true

func load_sound_settings():
	if AudioServer.is_bus_mute(MUSIC_INDEX):
		$BackgroundPanel/MusicVSlider.value = -24
	else:
		$BackgroundPanel/MusicVSlider.value = AudioServer.get_bus_volume_db(MUSIC_INDEX)
	if AudioServer.is_bus_mute(SFX_INDEX):
		$BackgroundPanel/SFXVSlider.value = -24
	else:
		$BackgroundPanel/SFXVSlider.value = AudioServer.get_bus_volume_db(SFX_INDEX)

func _on_SaveAndQuitButton_pressed():
	get_tree().call_group("level", "did_save_and_quit_game")

func _on_ResetButton_pressed():
	get_tree().call_group("level", "did_reset_game")
