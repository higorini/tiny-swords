extends Node2D


@onready var interface: CanvasLayer = get_node("Interface")
@onready var health_label: Label = interface.get_node("Health")
@onready var score_label: Label = interface.get_node("Score")


@export var target_kill_count: int
@export var next_level_scene_path: String
@export var current_level_scene_path: String


var kill_count: int = 0


func _ready():
	transition_screen.scene_path = current_level_scene_path
	update_health(transition_screen.player_health)
	update_score(transition_screen.player_score)


func update_health(new_health: int) -> void:
	health_label.text = "Hp: " + str(new_health)


func increase_kill_count() -> void:
	kill_count += 1
	
	if kill_count == target_kill_count:
		transition_screen.scene_path = next_level_scene_path
		transition_screen.fade_in(true)


func update_score(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)


func lose_life(actual_life: int) -> void:
	var life_prefix = "Life"
	
	for lives in get_tree().get_nodes_in_group("life"):
		var life_name = lives.name
		
		if life_name.begins_with(life_prefix):
			var life_number = int(life_name.substr(life_prefix.length()))
			if life_number > actual_life:
				lives.queue_free()
