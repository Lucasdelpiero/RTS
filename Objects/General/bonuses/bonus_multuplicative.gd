extends Bonus
class_name BonusMultiplicative

@export_enum(
	BONUS_INCOME,
	BONUS_MANPOWER,
	BONUS_LOYALTY,
	BONUS_RELIGION_CONVERSION
	) var type_produced : String = BONUS_INCOME
@export_range(-100, 100, 5) var multiplier_bonus : int = 0


const BONUS_INCOME = "bonus_income"
const BONUS_MANPOWER = "bonus_manpower"
const BONUS_LOYALTY = "bonus_loyalty"
const BONUS_RELIGION_CONVERSION = "bonus_religion_conversion"
