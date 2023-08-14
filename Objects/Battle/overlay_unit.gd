extends PanelContainer
class_name OverlayUnit

@onready var troopsCount : Label = %TroopsCount
@onready var unitName : Label = %UnitName

func update_data(data : OverlayUnitData):
	troopsCount.text = "%s/%s" % [data.troops_number, data.tropps_max_number]
	unitName.text = data.unit_name
	var margin = Vector2(size.x * 0.05, size.y * 0.9)
	margin.x = 0
	margin.y = size.y
	var min_margin = 10
	var new_pos = get_global_mouse_position() - margin
	var border_x = get_window().size.x
	if new_pos.x + size.x > border_x:
		new_pos.x = border_x - size.x - min_margin
	new_pos.y = max(min_margin, new_pos.y)
	global_position = new_pos
	pass

func get_data_from_unit(unit : Unit):
	var overlay_data = OverlayUnitData.new()
	overlay_data.troops_number = unit.troops_number
	overlay_data.tropps_max_number = unit.troops_number_max
	overlay_data.unit_name = unit.name
	return overlay_data
