class_name BtnProvince
extends Button

# Sends the reference to the province that the button stores 
signal pressed_btn_province(value : Province)

var province : Province = null: 
	set(value):
		if value == null:
			return
		province = value
		text = province.name

func _on_pressed() -> void:
	if province == null:
		push_error("There is no province reference in the button")
		return
	pressed_btn_province.emit(province)
