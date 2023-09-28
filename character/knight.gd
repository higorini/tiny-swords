extends CharacterBody2D


const AUDIO_TEMPLATE: PackedScene = preload("res://management/audio_template.tscn")


@onready var animation: AnimationPlayer = get_node("Animation")
@onready var texture: Sprite2D = get_node("Texture")
@onready var attack_area_collision: CollisionShape2D = get_node("AttackArea/Collision")
@onready var auxiliar_animation: AnimationPlayer = get_node("AuxiliarAnimation")
@onready var dust: GPUParticles2D = get_node("Dust")


@export var life: int = 3
@export var health: int = 20
@export var move_speed: float = 256.0
@export var damage: int = 1


var can_attack: bool = true
var can_die: bool = false


func _ready() -> void:
	if transition_screen.player_life != 3:
		life = transition_screen.player_life
		get_tree().call_group("level", "lose_life", transition_screen.player_life)
	
	if transition_screen.player_health != 0:
		health = transition_screen.player_health
		return
		
	transition_screen.player_health = health
	transition_screen.player_life = life


func _physics_process(_delta: float) -> void:
	if can_attack == false or can_die:
		return
		
	move()
	animate()
	attack_handler()
	


func move() -> void:
	var direction: Vector2 = get_direction()
	velocity = direction * move_speed
	move_and_slide()


func get_direction() -> Vector2:
	return Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)


func animate() -> void:
	if velocity.x > 0:
		texture.flip_h = false
		attack_area_collision.position.x = 58
		
	if velocity.x < 0:
		texture.flip_h = true
		attack_area_collision.position.x = -58
	
	if velocity != Vector2.ZERO:
		dust.emitting = true
		animation.play("run")
		return
		
	dust.emitting = false
	animation.play("idle")


func attack_handler() -> void:
	if Input.is_action_just_pressed("attack_button") and can_attack:
		can_attack = false
		dust.emitting = false
		animation.play("attack")


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"attack":
			can_attack = true
			
		"death":
			life -= 1
			
			if life > 0:
				get_tree().call_group("level", "lose_life", life)
				transition_screen.fade_in()
				transition_screen.player_life = life
				print(transition_screen.player_life)
				transition_screen.player_health = 0
				transition_screen.player_score = 0
			else:
				transition_screen.scene_path = "res://management/game_over.tscn"
				transition_screen.fade_in()



func _on_attack_area_body_entered(body) -> void:
	body.update_health(damage)


func update_health(value: int) -> void:
	health -= value
	transition_screen.player_health = health
	get_tree().call_group("level", "update_health", health)
	
	if health <= 0:
		can_die = true
		animation.play("death")
		attack_area_collision.set_deferred("disabled", true)
		return
		
	auxiliar_animation.play("hit")


func spawn_sfx(sfx_path: String) -> void:
	var sfx = AUDIO_TEMPLATE.instantiate()
	sfx.sfx_to_play = sfx_path
	add_child(sfx)
