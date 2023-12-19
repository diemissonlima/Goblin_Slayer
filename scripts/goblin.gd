extends CharacterBody2D

const ATTACK_AREA: PackedScene = preload("res://scenes/enemy_attack_area.tscn")
const OFFSET: Vector2 = Vector2(0, 31)

var player_ref: CharacterBody2D = null # referencia ao personagem
var can_die: bool = false

@export var move_speed: float = 192.0 # velocidade de movimento
@export var distance_threshold: float = 60.0 # limite de distancia que precisa para o inimigo atacar
@export var health: int = 3
@export var score: int = 1

@onready var dust: GPUParticles2D = get_node("Dust")

@onready var animation: AnimationPlayer = get_node("Animation")
@onready var aux_animation: AnimationPlayer = get_node("AuxAnimation")
@onready var texture: Sprite2D = get_node("Texture")

func _ready() -> void:
	texture.flip_h = true

func _physics_process(_delta: float) -> void:
	if can_die: # se inimigo morrer
		return
	
	# se referência ao personagem for null ou personagem estiver morto nao executa o restante do codigo
	if player_ref == null or player_ref.can_die: 
		velocity = Vector2.ZERO # zera a velocidade de movimento
		animate() # roda pelo menos a animação de idle
		return
	
	# traça uma direção ate o personagem
	var direction: Vector2 = global_position.direction_to(player_ref.global_position)
	# armazena a distância do inimigo até o personagem
	var distance: float = global_position.distance_to(player_ref.global_position)
	
	if distance < distance_threshold: # se distância for menor que limite de distância
		dust.emitting = false
		animation.play("attack") # executa animação de ataque
		return
	
	velocity = direction * move_speed
	move_and_slide()
	animate()
	

func spawn_attack_area() -> void:
	var attack_area = ATTACK_AREA.instantiate()
	attack_area.position = OFFSET
	add_child(attack_area)


func animate() -> void: # lida com as animações
	if velocity.x < 0: # inimigo andando para esquerda
		texture.flip_h = true # flipa o inimigo para a esquerda
	elif velocity.x > 0: # inimigo andando para direita
		texture.flip_h = false # flipa o inimigo para a direita
	
	if velocity != Vector2.ZERO: # Significa que o inimigo esta se movendo
		dust.emitting = true
		animation.play("run") # roda animação de run (correr)
		return
		
	animation.play("idle") # roda a animação de idle (parado)
	
	
# funcao que atualiza a vida do inimigo
func update_health(value: int) -> void: # VALUE é o valor recebido da funcao "on_attack_area_body_entered"
	health -= value # diminui a vida pelo valor recebido
	if health <= 0: # vida do inimigo chega a zero
		can_die = true # flag é configurada para true
		animation.play("death") # roda a animação de morte
		return
	
	aux_animation.play("hit") # toma hit mas nao morre roda a animação de hit
	
	
# sinal que monitora a entrada do personagem na área de detecção
func on_detection_area_body_entered(body) -> void: # BODY é o prórprio personagem
	player_ref = body


# sinal que monitora a saída do personagem na área de detecção
func on_detection_area_body_exited(_body) -> void:
	player_ref = null


func on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"death":
			transition_screen.player_score += score
			
			get_tree().call_group("level", "increase_kill_count")
			get_tree().call_group("level", "update_score", transition_screen.player_score)
			queue_free()
