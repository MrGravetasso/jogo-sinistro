extends CharacterBody2D

enum EskeletoState{
	andando,
	atacando,
	morto
}

@onready var sla: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var visão2: RayCast2D = $olhar_chão
@onready var visão: RayCast2D = $olhar_frente
@onready var playerv: RayCast2D = $"olha o player"
@onready var mão: Node2D = $mão

const OSSO_GIRANDO = preload("uid://c8k8xu5cm12c")
const PLAYER = preload("uid://c6u4660mvicrq")

@export var SPEED = 20
@export var direção_do_esqueleto = 1

var pode_atacar = true
var status = EskeletoState
var ataques = 0
var player_esta_vivo = true
var player = PLAYER.instantiate()

func _ready() -> void:
	preparar_andar()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		EskeletoState.andando:
			andar_state(delta)
		EskeletoState.morto:
			morto_state(delta)
		EskeletoState.atacando:
			ataque_state(delta)

	move_and_slide()

func preparar_andar():
	status = EskeletoState.andando
	sla.play("andando")

func preparar_ataque():
	status = EskeletoState.atacando
	sla.play("ataque")
	velocity = Vector2.ZERO
	pode_atacar = true

func preparar_morrer():
	status = EskeletoState.morto
	sla.play("morreu")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED

func andar_state(_delta):
	if sla.frame == 3 or sla.frame == 4:
		velocity.x = SPEED * direção_do_esqueleto
	else:
		velocity.x = 0

	if visão.is_colliding():
		direção_do_esqueleto *= -1
		scale.x *= -1
		return
	if !visão2.is_colliding():
		direção_do_esqueleto *= -1
		scale.x *= -1
		return
	if playerv.is_colliding() and player_esta_vivo:
		preparar_ataque()
		return

func ataque_state(_delta):
	if player.player_morto == true:
		player_esta_vivo = false
		preparar_andar()
		return
	elif sla.frame == 2 and pode_atacar:
		osso()
		pode_atacar = false

func morto_state(_delta):
	velocity = Vector2.ZERO

func matar():
	preparar_morrer()

func osso():
	var projetil = OSSO_GIRANDO.instantiate()
	add_sibling(projetil)
	projetil.position = mão.global_position
	projetil.lado = self.direção_do_esqueleto
	if projetil.lado < 0:
		projetil.anim.flip_h = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if sla.animation == "ataque":
		preparar_andar()
		return
