extends Node2D

@onready var interface: CanvasLayer = get_node("Interface")
@onready var health_label: Label = interface.get_node("Health")
@onready var score_label: Label = interface.get_node("Score")
@onready var level_label: Label = interface.get_node("Level")

var kill_count: int = 0 # contador de inimigos mortos

@export var target_kill_count: int # quantidade necessaria de inimigos mortos
@export var current_level: int
@export var next_level_scene_path: String # caminho da proxima cena de nivel
@export var current_level_scene_path: String # caminho da cena de nivel atual

func _ready() -> void:
	# envia para scene path da transition screen o path da cena atual
	transition_screen.scene_path = current_level_scene_path
	# envia para funcao update_health a vida do personagem armazenada na transition screen
	update_health(transition_screen.player_health)
	update_score(transition_screen.player_score)
	set_level()
	

func update_health(new_health: int) -> void: # recebe a vida passada na funcao ready
	# altera o texto da label recebendo o valor passado na funcao ready e converte para string
	health_label.text = "Health: " + str(new_health)


func update_score(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)
	

func set_level() -> void:
	level_label.text = "Level: " + str(current_level)


func increase_kill_count() -> void: # funcao que incrementa o contador de kill
	kill_count += 1 # aumenta o contador em +1
	
	if kill_count == target_kill_count: # condição para trocar de cena
		# scene path da transition screen recebe o caminho do proximo nivel
		transition_screen.scene_path = next_level_scene_path
		# executa a animacao de transicao de cena
		transition_screen.fade_in(true)
		
