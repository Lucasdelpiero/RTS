extends StateIA


# updates score based on the amount of ammo that the archers have
func _update_score(data : DataForStates) -> void:
	var current_ammo : int = 0
	var total_ammo : int = 0

	for archer in data.group_archers:
		var unit_ammo : Array = archer.weapons.get_ammo_data()
		var unit_current_ammo : int = unit_ammo[0]
		var unit_max_ammo : int = unit_ammo[1]
		
		current_ammo += unit_current_ammo
		total_ammo += unit_max_ammo
		print("%s: %s/%s" % [archer.name, unit_current_ammo, unit_max_ammo ])
		pass
	
	if current_ammo == 0:
		score = 0
		return
	
	var num : float = (float(total_ammo) / float(current_ammo)) * 100.0
	print("num: %s" % num)
	score = num
	pass
