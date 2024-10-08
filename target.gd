extends Area2D

@onready var anim: AnimationPlayer = $HeartbeatPlayer

func _ready() -> void:
	anim.play("heartbeat")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.attack()
