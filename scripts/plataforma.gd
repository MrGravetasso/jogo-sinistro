extends AnimatableBody2D

@onready var posição_final: Sprite2D = $Posição_Final
@export var timer = 1

func _ready() -> void:
	posição_final.visible = false

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"global_position",posição_final.global_position,timer)
	tween.tween_property(self,"global_position",global_position,timer)
	tween.set_loops()
