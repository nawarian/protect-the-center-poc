class_name Enemy
extends CharacterBody2D

signal hit_target

const GRAVITY = 20000.0

@export var health: int = 1
@export var speed: float = 150.0

enum Direction {
	LEFT,
	RIGHT,
}
@export var direction: Direction = Direction.RIGHT

enum State {
	WALK_TOWARDS_TARGET,
	ATTACK_TARGET,
	DEAD,
}
@export var state: State = State.WALK_TOWARDS_TARGET

@onready var button: TouchScreenButton = $TouchScreenButton

func attack():
	state = State.ATTACK_TARGET

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = GRAVITY * delta

	if state == State.WALK_TOWARDS_TARGET:
		velocity.x = (speed * 30 * delta) * (1 if direction == Direction.RIGHT else -1)
	else:
		velocity.x = 0

	move_and_slide()

func _process(delta: float) -> void:
	if health <= 0:
		state = State.DEAD
		visible = false
		queue_free()

	if state == State.ATTACK_TARGET:
		emit_signal("hit_target")
		queue_free()

func _on_touch_screen_button_pressed() -> void:
	pass

func _on_touch_screen_button_released() -> void:
	health -= 1
