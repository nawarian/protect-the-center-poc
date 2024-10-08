extends Node2D

enum State {
	NEXT_WAVE,
	RUNNING,
	PAUSED,
	GAME_OVER,
}
@onready var state = State.PAUSED

@export var health: int = 10
@export var wave: int = 1

@onready var target: Area2D = $Target
@onready var enemies_container: Node2D = $Enemies
@onready var spawn_left: Area2D = $EnemySpawnLeft
@onready var spawn_right: Area2D = $EnemySpawnRight
@onready var text: RichTextLabel = $RichTextLabel

func _ready() -> void:
	state = State.NEXT_WAVE

func percentage_health(actual, min, max) -> float:
	return float(actual - min) / float(max - min)

func _process(delta: float) -> void:
	var energy_remaining = percentage_health(health, 1, 10)

	var enemies = get_tree().get_nodes_in_group("enemies")
	if len(enemies) == 0:
		state = State.NEXT_WAVE

	if int(energy_remaining * 100) <= 0:
		state = State.GAME_OVER
	
	if state == State.NEXT_WAVE:
		await next_wave()
	elif state == State.GAME_OVER:
		text.text = "FIM DE JOGO"
		get_tree().paused = true
	elif state == State.RUNNING:
		target.modulate.a = max(energy_remaining, 0.0)
		text.text = "Energia: %d%%" % (int(energy_remaining * 100))

func next_wave():
	var enemy_res = load("res://enemy.tscn")
	state = State.RUNNING

	var enemies_in_this_wave = wave * randi_range(1, 2)
	for i in range(enemies_in_this_wave):
		var timer = get_tree().create_timer(1)

		var is_left = randi_range(0, 1) as bool
		var spawn_area = spawn_left if is_left else spawn_right
		var shape = spawn_area.find_child("CollisionShape2D") as CollisionShape2D
		var rect_pos = shape.global_position

		var new_enemy = enemy_res.instantiate() as Enemy
		new_enemy.position = rect_pos
		new_enemy.direction = Enemy.Direction.RIGHT if is_left else Enemy.Direction.LEFT
		new_enemy.health = randi_range(1, 3)
		new_enemy.speed = randf_range(150.0, 250.0)
		new_enemy.connect("hit_target", _on_hit_target)

		get_tree().root.add_child(new_enemy)
		await timer.timeout

	wave += 1

func _on_hit_target():
	health -= 1
