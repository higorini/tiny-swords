extends CharacterBody2D


const ATTACK_AREA: PackedScene = preload("res://goblin/enemy_attack_area.tscn")
const OFFSET: Vector2 = Vector2(0, 31)
const AUDIO_TEMPLATE: PackedScene = preload("res://management/audio_template.tscn")


@onready var animation: AnimationPlayer = get_node("Animation")
@onready var texture: Sprite2D = get_node("Texture")
@onready var auxiliar_animation: AnimationPlayer = get_node("AuxiliarAnimation")
@onready var nav_agent: = $NavigationAgent2D as NavigationAgent2D
@onready var dust: GPUParticles2D = get_node("Dust")


@export var move_speed: float = 192.0
@export var distance_threshold: float = 40.0
@export var score: int = 1


var player_ref: CharacterBody2D = null
var health: int = 4
var can_die: bool = false


func _physics_process(_delta: float) -> void:
	if can_die:
		return
	
	if player_ref == null or player_ref.can_die:
		velocity = Vector2.ZERO
		animate()
		return
	
	var direction: = to_local(nav_agent.get_next_path_position()).normalized()
	var distance: float = global_position.distance_to(player_ref.global_position) - distance_threshold
	
	if distance <= distance_threshold:
		animation.play("attack")
		dust.emitting = false
		return
	
	velocity = direction * move_speed
	move_and_slide()
	animate()


func _on_detection_area_body_entered(body):
	player_ref = body


func _on_detection_area_body_exited(_body):
	player_ref = null


func animate() -> void:
	if velocity.x > 0:
		texture.flip_h = false

		
	if velocity.x < 0:
		texture.flip_h = true

	if velocity != Vector2.ZERO:
		dust.emitting = true
		animation.play("run")
		return
		
	dust.emitting = false
	animation.play("idle")


func update_health(value: int) -> void:
	health -= value
	
	if health <= 0:
		transition_screen.player_score += score
		get_tree().call_group("level", "update_score", transition_screen.player_score)
		can_die = true
		animation.play("death")
		return
		
	auxiliar_animation.play("hit")


func _on_animation_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		get_tree().call_group("level", "increase_kill_count")
		queue_free()


func spawn_attack_area() -> void:
	var attack_area = ATTACK_AREA.instantiate()
	attack_area.position = OFFSET
	add_child(attack_area)


func make_path() -> void:
	nav_agent.target_position = player_ref.global_position


func _on_timer_timeout():
	if player_ref != null:
		make_path()


func spawn_sfx(sfx_path: String) -> void:
	var sfx = AUDIO_TEMPLATE.instantiate()
	sfx.sfx_to_play = sfx_path
	add_child(sfx)
