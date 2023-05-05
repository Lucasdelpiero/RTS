extends Node2D

# for army
var hovered := []
var selected := []

var provinceWithMouseOver = null 


## Gets in a list the 
func update_army_campaing_selection(data):
	# If the army has the mouse over it, it will be added to a list
	if (data.mouseOverSelf):
		hovered.push_back( data.node )
	# If doesnt have the mouse anymore it will be deleted from the list
	else:
		var temp = hovered.duplicate()
		for i in hovered.size():
			if hovered[i] == data.node:
#				print("a borrarte ameo")
				temp.remove_at(i)
				data.node.set_hovered(false)
		hovered = temp.duplicate()

	if hovered.size() > 0:
		hovered[0].set_hovered(true)
#	for node in hovered:
#		node.set_hovered(true)
	
	update_province_selection(null) # Used to update the provinces to being unhovered

func update_province_selection(data):
	# Updating the function with data == null just updates without adding info
	# If the province doesnt have the mouse over it, it will stop being hovered
	if data != null:
		if data.mouseOverSelf == false :
			data.node.set_hovered(false)
			provinceWithMouseOver.set_hovered(false)
	# If the province has the mouse over it, the province will get stored
		else:
			provinceWithMouseOver = data.node
	
	### PRIORITY FOR ENTITIES TO BEING HOVERED
	# For a province to be considered hovered, there should not be any army currently being hovered
	# and also has to have the mouse over it
	# It needs to be separated from the indentation in "data!= null" so it can updated once the army is unhovered
	if hovered.size() == 0 and provinceWithMouseOver.mouseOverSelf: 
		provinceWithMouseOver.set_hovered(true)
	else:
		provinceWithMouseOver.set_hovered(false)
