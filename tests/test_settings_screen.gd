extends Node
## Tests for the settings screen.

const SETTINGS_SCENE: PackedScene = preload("res://scenes/settings/settings.tscn")


func test_sliders_reflect_settings(framework: RefCounted) -> void:
	Settings.set_master_volume(0.6)
	Settings.set_music_volume(0.5)
	Settings.set_effects_volume(0.4)
	var screen: SettingsScreen = SETTINGS_SCENE.instantiate()
	add_child(screen)
	var master_slider: HSlider = screen.get_node("%MasterSlider")
	var music_slider: HSlider = screen.get_node("%MusicSlider")
	var effects_slider: HSlider = screen.get_node("%EffectsSlider")
	framework.check_almost_equal(master_slider.value, 0.6, 0.001, "master slider reads Settings")
	framework.check_almost_equal(music_slider.value, 0.5, 0.001, "music slider reads Settings")
	framework.check_almost_equal(effects_slider.value, 0.4, 0.001, "effects slider reads Settings")


func test_slider_change_updates_settings_and_label(framework: RefCounted) -> void:
	Settings.set_master_volume(1.0)
	Settings.set_music_volume(1.0)
	Settings.set_effects_volume(1.0)
	var screen: SettingsScreen = SETTINGS_SCENE.instantiate()
	add_child(screen)
	var master_slider: HSlider = screen.get_node("%MasterSlider")
	var master_label: Label = screen.get_node("%MasterValueLabel")
	master_slider.value = 0.25
	framework.check_almost_equal(
		Settings.master_volume,
		0.25,
		0.001,
		"slider change persists to Settings",
	)
	framework.check_equal(master_label.text, "25%", "master value label updates")
	var music_slider: HSlider = screen.get_node("%MusicSlider")
	var music_label: Label = screen.get_node("%MusicValueLabel")
	music_slider.value = 0.1
	framework.check_almost_equal(
		Settings.music_volume,
		0.1,
		0.001,
		"music slider change persists to Settings",
	)
	framework.check_equal(music_label.text, "10%", "music value label updates")


func test_back_button(framework: RefCounted) -> void:
	var screen: SettingsScreen = SETTINGS_SCENE.instantiate()
	add_child(screen)
	var emitted: Array = []
	screen.back_pressed.connect(
		func() -> void:
			emitted.append(true),
	)
	var back_button: Button = screen.get_node("%BackButton")
	back_button.pressed.emit()
	framework.check_equal(emitted, [true], "back button emits back_pressed")
