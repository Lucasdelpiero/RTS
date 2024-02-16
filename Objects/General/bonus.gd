class_name Bonus
extends Resource

@export_enum(
	DEFAULT,
	BONUS_INCOME,
	BONUS_MANPOWER
	) var type_produced = DEFAULT
@export_range(0.0, 9.0, 0.05) var multiplier_bonus : float = 0.1

const DEFAULT = "default"
const BONUS_INCOME = "bonus_income"
const BONUS_MANPOWER = "bonus_manpower"

