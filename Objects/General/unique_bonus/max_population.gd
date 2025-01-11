extends UniqueBonus
class_name MaxPopulationIncrement

@export_range(100, 10_000_000, 100) var max_population_increment : int = 100

func get_modified_province(aProv: Province) -> Province:
	var temp : Province = aProv.duplicate(true)
	temp.max_population += max_population_increment
	return temp

func set_modified_province(aProv: Province) -> void:
	aProv.max_population = aProv.base_max_population + max_population_increment
