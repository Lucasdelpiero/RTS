extends Marker2D
class_name HurtBoxComponent

func get_areas() -> Array[HurtBox] :
	return get_children() as Array[HurtBox]
