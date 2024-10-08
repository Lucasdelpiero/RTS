extends Marker2D
class_name HurtBoxComponent

func get_areas() -> Array[HurtBox] :
	var temp : Array = get_children() 
	var casted : Array[HurtBox]
	casted.assign(get_children())
	return casted
