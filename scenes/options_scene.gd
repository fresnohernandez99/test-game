extends Control

@export var _720CheckBox: CheckBox
@export var _1080CheckBox: CheckBox
@export var fullScreenCheckButton: CheckButton

const SETTINGS_FILE := "user://settings.cfg"

# Makes checkboxes behave like radio buttons
var resolution_group := ButtonGroup.new()


func _ready() -> void:
	# Configure resolution selection group
	_720CheckBox.button_group = resolution_group
	_1080CheckBox.button_group = resolution_group

	# Load saved settings
	load_settings()

	# Update UI
	sync_ui()

	print("===== OPTIONS MENU READY =====")
	print("Window Size: ", DisplayServer.window_get_size())
	print("Window Mode: ", DisplayServer.window_get_mode())


# Synchronize UI controls with current display state
func sync_ui() -> void:
	var current_size: Vector2i = DisplayServer.window_get_size()

	_720CheckBox.button_pressed = false
	_1080CheckBox.button_pressed = false

	if current_size == Vector2i(1280, 720):
		_720CheckBox.button_pressed = true

	elif current_size == Vector2i(1920, 1080):
		_1080CheckBox.button_pressed = true

	var current_mode: int = DisplayServer.window_get_mode()

	var is_fullscreen := (
		current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN
		or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)

	fullScreenCheckButton.button_pressed = is_fullscreen

	print("UI Sync")
	print("Resolution: ", current_size)
	print("Mode: ", current_mode)
	print("Fullscreen: ", is_fullscreen)


# Save settings to disk
func save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value(
		"display",
		"fullscreen",
		fullScreenCheckButton.button_pressed
	)

	config.set_value(
		"display",
		"width",
		DisplayServer.window_get_size().x
	)

	config.set_value(
		"display",
		"height",
		DisplayServer.window_get_size().y
	)

	var result: int = config.save(SETTINGS_FILE)

	print("Settings saved: ", result)


# Load settings from disk
func load_settings() -> void:
	var config := ConfigFile.new()

	var result: int = config.load(SETTINGS_FILE)

	if result != OK:
		print("Settings file not found. Using defaults.")
		return

	var fullscreen: bool = bool(
		config.get_value("display", "fullscreen", false)
	)

	var width: int = int(
		config.get_value("display", "width", 1920)
	)

	var height: int = int(
		config.get_value("display", "height", 1080)
	)

	print("Loaded Settings")
	print("Width: ", width)
	print("Height: ", height)
	print("Fullscreen: ", fullscreen)

	# Apply resolution first
	DisplayServer.window_set_size(
		Vector2i(width, height)
	)

	# Apply mode after
	if fullscreen:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)


# Apply a new resolution
func apply_resolution(size: Vector2i) -> void:
	print("Applying resolution: ", size)

	# Only resize the OS window when not fullscreen
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(size)

		print("Window resized")

	else:
		print("Fullscreen active. Resolution saved only.")

	print("Window Size: ", DisplayServer.window_get_size())
	print("Viewport Size: ", get_viewport().get_visible_rect().size)

	save_settings()


# 720p selected
func _on_720_check_box_toggled(button_pressed: bool) -> void:
	if not button_pressed:
		return

	apply_resolution(
		Vector2i(1280, 720)
	)


# 1080p selected
func _on_1080_check_box_toggled(button_pressed: bool) -> void:
	if not button_pressed:
		return

	apply_resolution(
		Vector2i(1920, 1080)
	)


# Fullscreen toggled
func _on_full_screen_check_button_toggled(toggled_on: bool) -> void:
	print("Fullscreen toggled: ", toggled_on)

	if toggled_on:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)

	print("Current Mode: ", DisplayServer.window_get_mode())
	print("Window Size: ", DisplayServer.window_get_size())
	print("Viewport Size: ", get_viewport().get_visible_rect().size)

	save_settings()


# Back button
func _on_back_button_pressed() -> void:
	save_settings()

	get_tree().change_scene_to_file(
		"res://scenes/start_scene.tscn"
	)
