extends AnimatableBody3D

@export var playerTarget: Node3D
@export var triggerArea: Area3D
@export var slideDirection: Vector3 = Vector3.RIGHT
@export var slideDistance: float = 5.2
@export var slideTime: float = 1.2

var isOpen: bool = false
var _closedPosition: Vector3
var _openPosition: Vector3
var _wasInteractKey: bool = false
var _playerInside: bool = false
var _tween: Tween


func _ready() -> void:
	_closedPosition = position
	_openPosition = _closedPosition + slideDirection * slideDistance
	if triggerArea == null:
		push_warning("SlidingDoor: sin 'triggerArea' asignada, la puerta no respondra a E.")
		return
	triggerArea.body_entered.connect(_on_body_entered)
	triggerArea.body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	var pressed := Input.is_key_pressed(KEY_E)
	if pressed and not _wasInteractKey and _playerInside:
		toggle()
	_wasInteractKey = pressed


func toggle() -> void:
	isOpen = not isOpen
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", _openPosition if isOpen else _closedPosition, slideTime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_body_entered(body: Node3D) -> void:
	if body == playerTarget:
		_playerInside = true


func _on_body_exited(body: Node3D) -> void:
	if body == playerTarget:
		_playerInside = false