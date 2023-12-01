extends Panel
class_name AnswerField


var my_kind : ElementCube.Kind
var is_submitting : bool
var is_known : bool

@onready var text_edit : LineEdit = $Answer/H/TextEdit
@onready var submit : Button = $Answer/H2/Submit
@onready var clear : Button = $Answer/H2/Clear
@onready var sheen : ColorRect = $Sheen
@onready var color_cube : ColorRect = $Answer/H/CubeColor
@onready var cooldown : TextureProgressBar = $Answer/H2/Submit/Cooldown

@onready var correct_effect = preload("res://things/correct-2-46134.mp3")
@onready var wrong_effect = preload("res://things/wrong-47985.mp3")

var editable: bool:
	get:
		return text_edit.editable

var focus : bool:
	get:
		return text_edit.has_focus()
	set(value):
		if (value):
			text_edit.grab_focus()
		else:
			text_edit.release_focus()

func set_kind(kind: ElementCube.Kind, known := false):
	$Answer/H/CubeColor.modulate = kind.color
	my_kind = kind
	is_known = known
	$Answer/H/TextEdit.modulate = Autoload.get_contrast(kind.color)

func _force_correct():
	$Answer/H/TextEdit.text = str(my_kind.weight)
	_submit(str(my_kind.weight))


func _ready() -> void:
	clear.button_down.connect(_clear)
	submit.button_down.connect(_submit)
	text_edit.text_changed.connect(_on_text_input)
	text_edit.text_submitted.connect(_submit)
	
	if (is_known):
		_force_correct()

func _clear():
	Autoload.purge.emit(my_kind)

func _submit(text: String):
	if (is_submitting):
		return
	
	text_edit.editable = false
	submit.disabled = true
	is_submitting = true

	var tween = create_tween()
	
	if (Autoload.submit_answer(my_kind, int(text))):
		tween.tween_property(self, "self_modulate", Color.WHITE, 0.08)
		tween.set_parallel()
		tween.tween_property(sheen, "position:x", 200.0, 0.4)
		tween.tween_property(self, "self_modulate", Color.LAWN_GREEN, 0.5)
		text_edit.focus_mode = Control.FOCUS_NONE
		$Effect.stream = correct_effect
		$Effect.play()
		await tween.finished
	else:
		Autoload.purge.emit(my_kind)
		
		$Answer/H2/Submit/Icon.visible = false
		var penalty = float((Autoload.wrong_answers)) * 5.0
		cooldown.value = 100
		cooldown.visible = true
		tween.tween_property(cooldown, "value", 0, penalty)
		$Effect.stream = wrong_effect
		$Effect.play()
		await tween.finished
		text_edit.editable = true
		text_edit.clear()
		cooldown.visible = false
		$Answer/H2/Submit/Icon.visible = true
		submit.disabled = false
	
	is_submitting = false

func _set_submit_text_countdown(t: float):
	submit.text = "%0.1f" % t

func _on_text_input(new_text : String):
	var final_text = ""

	var regex = RegEx.new()
	regex.compile("[0-9]")

	var regex_match = regex.search_all(new_text)
	if regex_match:
		for i in range(0,regex_match.size()):
			final_text += regex_match[i].get_string()

	if final_text.length() > 2:
		final_text = final_text.substr(0, 2)

	text_edit.text = final_text
	text_edit.set_caret_column(final_text.length())

func _on_submit_pressed() -> void:
	_submit(text_edit.text)
