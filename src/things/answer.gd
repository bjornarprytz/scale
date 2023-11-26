extends VBoxContainer


var my_kind
@onready var text_edit : TextEdit = $H/TextEdit

func _ready() -> void:
	$Button.button_down.connect(_click)
	text_edit.text_changed.connect(_guard_text)

func _click():
	Autoload.purge.emit(my_kind)

func _guard_text():
	var final_text = ""

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
	
	if (my_kind.weight == int(final_text)):
		$Button.modulate = Color.GREEN
		$Button.text = ":)"
		$Button.button_down.disconnect(_click)
		text_edit.editable = false

func set_kind(kind: ElementCube.Kind):
	$H/ColorRect.color = kind.color
	my_kind = kind
