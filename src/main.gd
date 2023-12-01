extends Node2D

const MAX_SCORE := 69000
const MAX_CUBES := 20
var SPAWN_TIME := 2.0

@onready var cube_spawner = preload("res://things/cube.tscn")
@onready var answer_spawner = preload("res://things/answer.tscn")

@onready var spawn_point : Node2D = $SpawnPoint
@onready var info : GridContainer = $UIBack/Control/AnswerGrid

var won : bool
var t := 0.0
var elapsed := 0.0
var focused_answer : RichTextLabel

func _ready() -> void:
	Autoload.reset()
	Autoload.purge.connect(_purge)
	Autoload.game_over.connect(_game_over)
	
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
		tween.tween_property($UIFore/Credits, "position:y", -900, 10.0)

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
	$UIBack/CountPanel/Count.clear()
	$UIBack/CountPanel/Count.append_text("[center]" + str(_get_cube_count()) + "/" + str(MAX_CUBES))


func _on_button_button_down() -> void:
	get_tree().reload_current_scene()


func _on_texture_button_toggled(button_pressed: bool) -> void:
	$Music.playing = !button_pressed

