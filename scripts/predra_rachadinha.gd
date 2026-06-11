extends AnimatableBody2D

@onready var area_2d: Area2D = $Area2D
@onready var sla: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

var em_cima = false

func _process(_delta: float) -> void:
	if em_cima:
		return

	var corpos = area_2d.get_overlapping_bodies()
	for corpo in corpos:
		var player: CharacterBody2D = corpo
		if player.is_on_floor():
			em_cima = true
			sla.play("rachado")
			timer.start()

func _on_timer_timeout() -> void:
	sla.play("pó")
	collision_layer = 0
	var posição_final = global_position + Vector2.DOWN * 50
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self,"global_position",posição_final,0.5)
	var sumir = create_tween()
	sumir.tween_property(sla,"modulate:a", 0, 0.5)
