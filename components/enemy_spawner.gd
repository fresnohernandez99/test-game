extends Node3D

@export var enemyScene: PackedScene
@export var spawnPoints: Array[Marker3D]
@export var spawnKey: Key = KEY_T
@export var maxEnemies: int = 10

var _wasSpawnKey: bool = false
var _spawnCount: int = 0


func _process(_delta: float) -> void:
	var pressed := Input.is_key_pressed(spawnKey)
	if pressed and not _wasSpawnKey:
		_spawnEnemy()
	_wasSpawnKey = pressed


func _spawnEnemy() -> void:
	if enemyScene == null:
		push_warning("EnemySpawner: no scene assigned to 'enemyScene'.")
		return
	if spawnPoints.is_empty():
		push_warning("EnemySpawner: no spawn points assigned.")
		return
	if _spawnCount >= maxEnemies:
		push_warning("EnemySpawner: max enemies reached.")
		return

	var point: Marker3D = spawnPoints.pick_random()
	var enemy := enemyScene.instantiate()
	add_sibling(enemy)
	enemy.global_position = point.global_position
	_spawnCount += 1
	print("EnemySpawner: spawned %d/%d" % [_spawnCount, maxEnemies])
