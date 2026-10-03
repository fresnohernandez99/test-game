extends Control

@export var versionLabel: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	versionLabel.text = Constants.get_full_version()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_go_hub_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hub_area.tscn")


func _on_go_options_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_scene.tscn")
