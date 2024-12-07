class_name Bonus
extends Resource

@export_enum(
	BONUS_INCOME,
	BONUS_MANPOWER,
	BONUS_LOYALTY
	) var type_produced : String = BONUS_INCOME
@export_range(-100, 100, 5) var multiplier_bonus : int = 0


const BONUS_INCOME = "bonus_income"
const BONUS_MANPOWER = "bonus_manpower"
const BONUS_LOYALTY = "bonus_loyalty"

func copy_bonus(bonus : Bonus) -> Bonus:
	type_produced = bonus.type_produced
	multiplier_bonus = bonus.multiplier_bonus
	return self
