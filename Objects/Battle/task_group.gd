extends UnitsManagement
class_name TaskGroup

var group  = []
var enemy_group_focused  = []
var marker_to_follow = null

enum Task {FOLLOW_MARKER, HOLD, ADVANCE, SKIRMISH, MELEE, FLEE}

var task = Task.FOLLOW_MARKER
