extends PanelContainer

signal new_map_selected(type)

func _on_btn_political_map_button_down():
	new_map_selected.emit("political")

func _on_btn_terrain_map_button_down():
	new_map_selected.emit("terrain")

func _on_btn_religion_map_button_down():
	new_map_selected.emit("religion")

func _on_btn_culture_map_button_down():
	new_map_selected.emit("culture")
