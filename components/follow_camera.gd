extends Node3D

@export var target: Node3D
@export var distance: float = 4.0
@export var height: float = 2.2
@export var sensitivity: float = 0.003
@export var followSpeed: float = 10.0
@export var minPitch: float = -30.0
@export var maxPitch: float = 60.0

var yaw: float = 0.0
var pitch: float = 20.0


func _ready() -> void:
	if target == null:
		push_warning("FollowCamera: sin target asignado.")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseMotion):
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var motion := event as InputEventMouseMotion
	yaw -= motion.relative.x * sensitivity
	pitch = clampf(pitch + motion.relative.y * sensitivity, minPitch, maxPitch)


func _process(delta: float) -> void:
	if target == null:
		return

	var pivot := target.global_position + Vector3.UP * height
	var rotationBasis := Basis.from_euler(Vector3(deg_to_rad(pitch), deg_to_rad(yaw), 0.0))
	var desiredPosition := pivot - rotationBasis.z * distance

	global_position = global_position.lerp(desiredPosition, 1.0 - exp(-followSpeed * delta))
	look_at(pivot, Vector3.UP)
