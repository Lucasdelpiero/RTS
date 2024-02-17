class_name FlatProduction
extends Resource

## Production of certain resource at a flat rate before applying bonuses
@export_enum("gold", "manpower") var type_produced : String = "gold"
@export_range(0, 1000000,1) var amount : int = 0 
