extends Resource
class_name HurtboxData

var areas : Array[HurtBox] = []
var targetArea : Area2D = null
var target : Unit = null
var meleePoint : Marker2D = null

func set_data(area : HurtBox) -> HurtboxData:
	areas = area.get_hurtbox_group()
	targetArea = area
	meleePoint = area.meleePoint
	target = areas[0].owner as Unit
	
	return self

	#var areas : Array= aTargetArea.get_hurtbox_group()
	#var hurtbox_data : HurtboxData = HurtboxData.new()
	#hurtbox_data.areas = areas
	#hurtbox_data.targetArea = aTargetArea
	#hurtbox_data.target = areas[0].owner
