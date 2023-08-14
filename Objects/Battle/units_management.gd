extends Node
class_name UnitsManagement
@onready var margin_between_units = 214 # Margin used to distance units from each other once ordered to move

func get_face_to_formation_angle(value):
	return value + PI / 2

func get_average_position(array : Array) -> Vector2:
	if array.size() == 0:
		return Vector2.ZERO
	var average_position = Vector2.ZERO
	for i in array.size():
		average_position += array[i].global_position
	average_position /= array.size()
	return average_position 

func get_organized_units(aUnits, angle_formation = 0.0):
	var comparation = [] # Array used to sort the new order for the units in the array
	var average_position = Vector2.ZERO # Average position of army
	
	if aUnits.size() == 0:
		return
	# Gets the average position from all units, which is used to get which units are more in the left, right, etc than the others
	for i in aUnits.size():
		average_position += aUnits[i].global_position
	average_position /= aUnits.size()
	
	# From the average position gets the distance in the x axis and y axis, these are weighted with the angle of the dragging action
	# ex: if the new position is a line created mostly along the x axis, the x axis weight will be more important for the value in the positioning compared to the y axis
	# This allow the unit in first unit in the left to be the one in the left, the one that is in a higher position be higher in the new formation, etc
	# The organization is from lower value to higher value
	for i in aUnits.size():
		var unit = aUnits[i].global_position
		var to_unit_angle = average_position.angle_to_point(unit)
		var distance = average_position.distance_to(unit)
		# Value to compare who has to go in the most left flank and right flank
		# In the x_value the gets the distance in the x axis and is weighted using the angle of the mouse dragging, this weight having more importance as the 
		# new formation angle goes more along the x axis. The same for the y axis
		var x_value =   cos(to_unit_angle)  * distance * cos(angle_formation) 
		var y_value =   sin(to_unit_angle)  * distance *  sin(angle_formation)
		var value = x_value + y_value
		
		# Add the reference to the unit and the value to compare
		comparation.push_back([aUnits[i], value])
	
	# Array will be sorted from lower to higher using the value for the positioning
	comparation.sort_custom(func(a, b) : return a[1] < b[1])
	
	# New array organized, getting only the reference to the unit to be positioned
	var new_arr = []
	for i in comparation.size():
		new_arr.push_back(comparation[i][0])
	
	return new_arr
