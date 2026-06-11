extends Area2D

@export var proxima_fase = ""

func _on_body_entered(_body: Node2D) -> void:
	call_deferred("nova_fase")

func nova_fase():
	get_tree().change_scene_to_file("res://fases/" + proxima_fase + ".tscn")
