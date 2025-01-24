extends Resource
class_name DiplomacyRelationship

# The class stores the data related relationship from the nation that has the
# diplomacy_nation resource with the nation stored in this diplomacy_relationship

# diplomacy_nation holds a diplomacy_relationship for each nation it has a relation

var nation_tag : String = ""
var relations : int = 0

# Status of the country with the country (at war, vassal, neutral) 
var status : Status = Status.NEUTRAL

enum Status  {
	NEUTRAL,
	AT_WAR,
	VASSAL,
	OVERLORD
} 
