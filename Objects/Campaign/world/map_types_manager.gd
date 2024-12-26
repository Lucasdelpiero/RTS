extends PanelContainer

signal new_map_selected(type : String)

func _on_btn_political_map_button_down() -> void:
	new_map_selected.emit("political")

func _on_btn_terrain_map_button_down() -> void:
	new_map_selected.emit("terrain")

func _on_btn_religion_map_button_down() -> void:
	new_map_selected.emit("religion")

func _on_btn_culture_map_button_down() -> void:
	new_map_selected.emit("culture")

func _on_btn_loyalty_map_button_down() -> void:
	new_map_selected.emit("loyalty")
