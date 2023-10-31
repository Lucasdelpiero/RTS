extends PanelContainer

signal new_map_selected(type)

func _on_btn_political_map_button_down():
	new_map_selected.emit("political")
	pass # Replace with function body.


func _on_btn_terrain_map_button_down():
	new_map_selected.emit("terrain")
	pass # Replace with function body.
