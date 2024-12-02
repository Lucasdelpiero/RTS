class_name Bonus
extends Resource

@export_enum(
	BONUS_INCOME,
	BONUS_MANPOWER
	) var type_produced : String = BONUS_INCOME
@export_range(0.0, 9.0, 0.05) var multiplier_bonus : float = 0.1

const BONUS_INCOME = "bonus_income"
const BONUS_MANPOWER = "bonus_manpower"

func copy_bonus(bonus : Bonus) -> Bonus:
	type_produced = bonus.type_produced
	multiplier_bonus = bonus.multiplier_bonus
	return self
