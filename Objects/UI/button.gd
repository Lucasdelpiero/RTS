extends Button

@export_category("Translation")
@export var key : String = "" : 
	set(value):
		set_text(value)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Signals.sg_translation_update_text.connect(translation_update_text)
	pass

func translation_update_text() -> void:
	print("aaa")
	#set_text(tr(key))
