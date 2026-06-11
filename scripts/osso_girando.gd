extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var speed = 100
var lado = 1

func _process(delta: float) -> void:
	position.x += speed * delta * lado

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
