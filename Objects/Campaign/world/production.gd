class_name Production
extends Resource

# Stores the production of the province
# Production amount needs to start at 0 so it can be added time and time again without
# making every resource to 0 every time we create a blank production resource
var gold : int = 0
var manpower : int = 0

var provincial_bonus_income : float = 0.0
var provincial_bonus_soldiers_growth : float = 0.0
