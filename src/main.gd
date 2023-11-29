extends Node2D

const MAX_SCORE := 69000
const MAX_CUBES := 20
var SPAWN_TIME := 2.0

@onready var cube_spawner = preload("res://things/cube.tscn")
@onready var answer_spawner = preload("res://things/answer.tscn")
@onready var known_spawner = preload("res://things/known.tscn")

@onready var spawn_point : Node2D = $SpawnPoint
@onready var info : GridContainer = $CanvasLayer/Control/AnswerGrid

var won : bool
var t := 0.0
var elapsed := 0.0
var focused_answer : RichTextLabel

func _ready() -> void:
	Autoload.purge.connect(_purge)
	Autoload.game_over.connect(_game_over)
	
	var known_info = Autoload.kinds.pick_random()
	Autoload.submit_answer(known_info, known_info.weight)
	
	var kn = known_spawner.instantiate()
	kn.set_kind(known_info)
	
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
		$CanvasLayer/Instructions.visible = false
		$CanvasLayer/WinText.visible = true
		$Floor/Score.visible = true
		$Floor/Score.append_text(str(_score_formula()))

func _shortcut_input(event: InputEvent) -> void:
	
	if (event.keycode == KEY_TAB):
		var first : AnswerField
		var previous : AnswerField
		for a in $CanvasLayer/Control/AnswerGrid.get_children():
			if !(a is AnswerField) or !a.editable:
				continue
			var answer_field = a as AnswerField
			
			if first == null:
				first = answer_field
			
			if (previous != null and previous.focus):
				answer_field.focus = true
				return
			
			previous = answer_field
		
		first.focus = true

func _process(delta: float) -> void:
	t += delta
	elapsed += delta
	
	if (t > SPAWN_TIME):
		t = 0.0
		if (_get_cube_count() < MAX_CUBES):
			_spawn_cube(Autoload.kinds.pick_random())
		if (won):
			for c in $Cubes.get_children():
				c.apply_force(Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 0.0)) * randf_range(30000.0, 50000.0))
		

func _score_formula() -> int:
	return float(MAX_SCORE - (elapsed * 10.0) - (Autoload.exploded_cubes * 100.0)) / float(Autoload.wrong_answers +1)

func _spawn_cube(kind: ElementCube.Kind):
	var cube = cube_spawner.instantiate() as ElementCube
	cube.kind = kind
	
	$Cubes.add_child(cube)
	cube.position = spawn_point.position
	cube.exploded.connect(_update_cube_count, CONNECT_ONE_SHOT)

	_update_cube_count()

func _get_cube_count():
	var count := 0
	
	for c in $Cubes.get_children():
		if !c.has_exploded:
			count += 1
	return count

func _update_cube_count():
	$CanvasLayer/CountPanel/Count.clear()
	$CanvasLayer/CountPanel/Count.append_text("[center]" + str(_get_cube_count()) + "/" + str(MAX_CUBES))
