extends CanvasLayer

const MUSIC_INDEX = 1
const SFX_INDEX = 2

func _ready():
	$BackgroundPanel.visible = false
	$BackgroundPanel/MusicVSlider.value = AudioServer.get_bus_volume_db(MUSIC_INDEX)
	$BackgroundPanel/SFXVSlider.value = AudioServer.get_bus_volume_db(SFX_INDEX)

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
