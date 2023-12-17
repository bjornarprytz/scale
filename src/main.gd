extends Node2D

const MAX_SCORE := 69000
const MAX_CUBES := 25
var SPAWN_TIME := 2.0

@onready var cube_spawner = preload("res://things/cube.tscn")
@onready var answer_spawner = preload("res://things/answer.tscn")
@onready var materialize_effecet_spawner = preload("res://things/materialize_effect.tscn")

@onready var spawn_point : Node2D = $SpawnPoint
@onready var info : HBoxContainer = $UIBack/Control/AnswerGrid
@onready var replication_area : ColorRect = $ReplicationArea
@onready var replicator : Replicator = $Replicator

var won : bool
var t := 0.0
var elapsed := 0.0
var focused_answer : RichTextLabel

func _ready() -> void:
	Autoload.reset()
	Autoload.purge.connect(_purge)
	Autoload.game_over.connect(_game_over)
	
	replicator.replicate.connect(_replicate_cube)
	
	$UIBack/Instructions.append_text(" (" + str(Autoload.MIN_WEIGHT) + "-" + str(Autoload.MAX_WEIGHT) +")")
	
	var known_info = Autoload.kinds.pick_random()
	
	var kn = answer_spawner.instantiate() as AnswerField
	kn.set_kind(known_info, true)
	info.add_child(kn)
	
	for k in Autoload.kinds:
		if (k == known_info):
			continue
		
		var an = answer_spawner.instantiate()
		an.set_kind(k)
		
		info.add_child(an)
		
	_spawn_cube(known_info)

func _purge(kind: ElementCube.Kind):
	for c in $Cubes.get_children():
		if c.kind == kind:
			c.explode()

func _game_over(win: bool):
	won = win
	
	if (win):
		SPAWN_TIME = 0.5
		$UIBack/Instructions.visible = false
		$UIBack/WinText.visible = true
		$UIFore/Score.visible = true
		$UIFore/Restart.visible = true
		$UIFore/Score.append_text(str(_score_formula()))
		
		var tween = create_tween()
		tween.tween_property($UIFore/Credits, "position:y", -1000, 10.0)

func _shortcut_input(event: InputEvent) -> void:
	if (event.keycode == KEY_TAB):
		var first : AnswerField
		for a in $UIBack/Control/AnswerGrid.get_children():
			if !(a is AnswerField) or !a.editable:
				continue
			var answer_field = a as AnswerField
			if (answer_field.focus):
				return
			
			if first == null:
				first = answer_field
		
		first.focus = true

func _process(delta: float) -> void:
	t += delta
	elapsed += delta
	
	if (t > SPAWN_TIME):
		t = 0.0
		var nCubes = _get_cube_count()
		if (nCubes < MAX_CUBES):
			_spawn_cube(_random_kind())
		if (won):
			for c in $Cubes.get_children():
				c.apply_force(Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 0.0)) * randf_range(30000.0, 50000.0))
		

func _random_kind() -> ElementCube.Kind:
	var candidates : Array[ElementCube.Kind] = []
	var cubes = _get_cubes()
	for kind in Autoload.kinds:
		var found_match := false
		for cube in cubes:
			if cube.kind == kind:
				found_match = true
				break
		if !found_match:
			candidates.push_front(kind)
	
	if (candidates.is_empty()):
		return Autoload.kinds.pick_random()
	else:
		return candidates.pick_random()

func _score_formula() -> int:
	return float(MAX_SCORE - (elapsed * 100.0) + (Autoload.exploded_cubes * 100.0))

func _spawn_cube(kind: ElementCube.Kind, placement: Vector2=Vector2.ZERO) -> ElementCube:
	var cube = cube_spawner.instantiate() as ElementCube
	cube.kind = kind
	
	$Cubes.add_child(cube)
	if placement == Vector2.ZERO:
		cube.position = spawn_point.position
	else:
		cube.position = placement
	cube.exploded.connect(_update_cube_count, CONNECT_ONE_SHOT)

	_update_cube_count()
	
	return cube

func _replicate_cube(kind: ElementCube.Kind):
	const MATERIALIZE_DURATION = 1.2
	
	var low_x = replication_area.get_rect().position.x
	var top_x = replication_area.get_rect().position.x + replication_area.get_rect().size.x
	var low_y = replication_area.get_rect().position.y
	var top_y = replication_area.get_rect().position.y + replication_area.get_rect().size.y
	var placement = Vector2(randf_range(low_x, top_x), randf_range(low_y, top_y))
	
	var effect = materialize_effecet_spawner.instantiate() as CPUParticles2D
	effect.emitting = true
	add_child(effect)
	effect.position = placement
	effect.color = kind.color
	
	var cube = _spawn_cube(kind, placement)
	var initial_scale = cube.scale
	
	cube.scale = Vector2.ZERO
	
	var spawn_tween = create_tween().set_parallel()
	spawn_tween.tween_property(cube, "scale", initial_scale, MATERIALIZE_DURATION)
	
	await spawn_tween.finished
	
	$Pop.pitch_scale = randf_range(0.9, 1.1)
	$Pop.play()
	
	cube.linear_velocity = Vector2.ZERO
	effect.queue_free()


func _get_cubes() -> Array[ElementCube]:
	var cubes : Array[ElementCube] = []
	for c in $Cubes.get_children():
		if !c.has_exploded:
			cubes.push_back(c)
	return cubes

func _get_cube_count():
	return _get_cubes().size()

func _update_cube_count():
	$UIBack/CountPanel/Count.clear()
	$UIBack/CountPanel/Count.append_text("[center]" + str(_get_cube_count()) + "/" + str(MAX_CUBES))


func _on_button_button_down() -> void:
	get_tree().reload_current_scene()


func _on_texture_button_toggled(button_pressed: bool) -> void:
	$Music.playing = !button_pressed

