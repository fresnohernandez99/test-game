extends Node3D

@export var moveSpeed: float = 6.0
@export var acceleration: float = 14.0
@export var jumpImpulse: float = 5.0
@export var standHeight: float = 2.0
@export var crouchHeight: float = 1.0

@onready var body: RigidBody3D = get_parent() as RigidBody3D
@onready var bodyVisual: MeshInstance3D = body.get_node("TestVisual")
@onready var bodyShape: CollisionShape3D = body.get_node("TestCollision")

var isCrouching: bool = false
var _wasJump: bool = false


func _ready() -> void:
	body.linear_damp = 0.0
	body.angular_damp = 8.0
	body.axis_lock_angular_x = true
	body.axis_lock_angular_z = true


func _physics_process(delta: float) -> void:
	_updateCrouch()
	_applyMovement(delta)
	var jumpPressed := Input.is_key_pressed(KEY_SPACE)
	if jumpPressed and not _wasJump:
		_tryJump()
	_wasJump = jumpPressed


func _applyMovement(delta: float) -> void:
	var inputVector := Vector2(
		float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
		float(Input.is_key_pressed(KEY_W)) - float(Input.is_key_pressed(KEY_S))
	)

	var targetVelocity := Vector2.ZERO
	if inputVector != Vector2.ZERO:
		var direction := _inputDirection(inputVector)
		if direction == Vector3.ZERO:
			return
		targetVelocity = Vector2(direction.x, direction.z) * moveSpeed

	var currentVelocity := Vector2(body.linear_velocity.x, body.linear_velocity.z)
	var weight := clampf(acceleration * delta, 0.0, 1.0)
	var newVelocity := currentVelocity.lerp(targetVelocity, weight)
	body.linear_velocity.x = newVelocity.x
	body.linear_velocity.z = newVelocity.y


func _inputDirection(inputVector: Vector2) -> Vector3:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return Vector3.ZERO

	var cameraForward := -camera.global_transform.basis.z
	cameraForward.y = 0.0
	if cameraForward.length() < 0.001:
		return Vector3.ZERO
	cameraForward = cameraForward.normalized()

	var cameraRight := camera.global_transform.basis.x
	cameraRight.y = 0.0
	cameraRight = cameraRight.normalized()

	return (cameraRight * inputVector.x + cameraForward * inputVector.y).normalized()


func _tryJump() -> void:
	if not _isOnFloor():
		return
	body.apply_central_impulse(Vector3.UP * jumpImpulse * body.mass)


func _isOnFloor() -> bool:
	var shape := bodyShape.shape as CapsuleShape3D
	var reach := shape.height * 0.5 + 0.2
	var params := PhysicsRayQueryParameters3D.create(
		body.global_position,
		body.global_position - Vector3.UP * reach
	)
	params.exclude = [body.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(params).size() > 0


func _updateCrouch() -> void:
	var nowCrouching := Input.is_key_pressed(KEY_C)
	if nowCrouching == isCrouching:
		return
	isCrouching = nowCrouching

	var shape := bodyShape.shape as CapsuleShape3D
	var mesh := bodyVisual.mesh as CapsuleMesh
	var targetHeight := crouchHeight if isCrouching else standHeight
	var heightDelta := targetHeight - shape.height
	shape.height = targetHeight
	mesh.height = targetHeight
	body.global_position.y += heightDelta * 0.5
