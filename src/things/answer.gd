extends Panel
class_name AnswerField


var my_kind : ElementCube.Kind
var is_submitting : bool

@onready var text_edit : TextEdit = $Answer/H/TextEdit
@onready var submit : Button = $Answer/H2/Submit
@onready var clear : Button = $Answer/H2/Clear
@onready var sheen : ColorRect = $Answer/H2/Submit/Sheen
@onready var color_cube : ColorRect = $Answer/H/CubeColor

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

func _ready() -> void:
	clear.button_down.connect(_clear)
	submit.button_down.connect(_submit)
	text_edit.text_changed.connect(_on_text_input)

func _clear():
	Autoload.purge.emit(my_kind)

func _submit():
	if (is_submitting):
		return
	
	text_edit.editable = false
	submit.disabled = true
	is_submitting = true

	var tween = create_tween()
	
	if (Autoload.submit_answer(my_kind, int(text_edit.text))):
		submit.text = "Solved!"
		tween.tween_property(self, "self_modulate", Color.WHITE, 0.08)
		tween.set_parallel()
		tween.tween_property(sheen, "position:x", 150.0, 0.3)
		tween.tween_property(self, "self_modulate", Color.LAWN_GREEN, 0.5)
		await tween.finished
	else:
		Autoload.purge.emit(my_kind)
		
		var penalty = float((Autoload.wrong_answers)) * 5.0
		tween.tween_method(_set_submit_text_countdown, penalty, 0.0, penalty)
		
		await tween.finished
		text_edit.editable = true
		text_edit.clear()
		submit.disabled = false
		submit.text = "Submit"
	
	is_submitting = false

func _set_submit_text_countdown(t: float):
	submit.text = "%0.1f" % t

func _on_text_input():
	var final_text = ""
	var should_submit = text_edit.text.ends_with('\n')

	var regex = RegEx.new()
	regex.compile("[0-9]")

	var regex_match = regex.search_all(text_edit.text)
	if regex_match:
		for i in range(0,regex_match.size()):
			final_text += regex_match[i].get_string()

	if final_text.length() > 2:
		final_text = final_text.substr(0, 2)

	text_edit.text = final_text
	text_edit.set_caret_column(final_text.length())
	
	if should_submit and text_edit.text.length() > 0:
		_submit()

func set_kind(kind: ElementCube.Kind):
	$Answer/H/CubeColor.modulate = kind.color
	my_kind = kind
