extends RigidBody2D
class_name ElementCube

signal exploded()

class Kind:
	var color : Color
	var weight : int
	var stability : int
	var bounce : float

@export var damageMultiplier = 0.1  # You can adjust this value to control the damage

var kind : Kind:
	set(value):
		kind = value
		$Color.modulate = kind.color
		$Explosion.modulate = kind.color
		physics_material_override.bounce = kind.bounce
		if (Autoload.correct_answers.has(kind)):
			_reveal_weight()
		else:
			Autoload.correct_guess.connect(_check_correct)

@onready var shrapnel_spawner = preload("res://things/shrapnel.tscn")
@onready var boom : CPUParticles2D = $Explosion
@onready var shape : CollisionShape2D = $Shape
@onready var light : PointLight2D = $Light
@onready var break_effects = [preload("res://things/glass-breaking-93803.mp3"), preload("res://things/glass-shatter-3-100155.mp3")]

var prev_pos : Vector2
var momentum : Vector2
var held : bool
var hovered : bool
var has_exploded : bool

func _check_correct(guessed_kind: ElementCube.Kind):
	if guessed_kind == kind:
		_reveal_weight()
		Autoload.correct_guess.disconnect(_check_correct)

func _reveal_weight():
	$Weight.clear()
	$Weight.append_text("[center]"+str(kind.weight))
	$Weight.modulate = Autoload.get_contrast(kind.color)

func _physics_process(delta: float) -> void:
	var vp_rect = get_viewport_rect().grow(60.0)
	var my_rect = $Color.get_global_rect()
	if (!vp_rect.encloses(my_rect)):
		explode()
		return
	
	if (!held):
		return
	
	if (prev_pos != Vector2.ZERO):
		momentum = (global_position - prev_pos) * 50000.0 * delta
	prev_pos = global_position
	global_position = get_global_mouse_position()

func _on_RigidBody2D_body_entered(body: Node):
	if body is RigidBody2D or body is StaticBody2D:
		var damage = get_collision_energy() * damageMultiplier

		apply_damage(damage)

func explode():
	if (has_exploded):
		return
	has_exploded = true
	
	for n in randi_range(1, 4):
		_make_shrapnel()
	
	$Color.visible = false
	$Weight.visible = false
	$Effect.stream = break_effects.pick_random()
	$Effect.pitch_scale = randf_range(0.9, 1.1)
	$Effect.play()
	
	for b in get_colliding_bodies():
		if b is ElementCube:
			b.sleeping = false
	
	set_deferred("freeze", true)
	shape.set_deferred("disabled", true)
	
	boom.emitting = true
	Autoload.exploded_cubes += 1
	exploded.emit()
	
	await get_tree().create_timer(boom.lifetime).timeout
	
	queue_free()

func _make_shrapnel():
	var shrapnel = shrapnel_spawner.instantiate() as Shrapnel
	get_tree().root.call_deferred("add_child", shrapnel)
	shrapnel.set_deferred("global_position", global_position)
	shrapnel.set_deferred("modulate", kind.color)
	shrapnel.call_deferred("apply_force", Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 0.0)) * randf_range(3000.0, 5000.0))
	shrapnel.call_deferred("apply_torque", randf() * 200.0)

func apply_damage(amount):
	if (amount > 30):
		explode()


func get_collision_energy() -> float:
	var impulse = linear_velocity * mass
	
	return impulse.length()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var was_held = held
		held = hovered and event.is_pressed()
		
		if (held):
			freeze = true
		else:
			freeze = false
			if was_held:
				apply_force(momentum) # Throw

func _on_mouse_entered() -> void:
	hovered = true
	light.visible = true

func _on_mouse_exited() -> void:
	hovered = false
	light.visible = false
