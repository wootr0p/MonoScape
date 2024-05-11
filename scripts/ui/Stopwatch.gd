extends Label

var time : float
var is_active : bool

func _ready():
	LevelManager.connect("respawn_world", self, "on_respawn_world")
	LevelManager.connect("level_complete", self, "on_level_complete")
	LevelManager.connect("slow_timer", self, "on_slow_timer")
	
	is_active = true
	time = 0.0

func _process(delta):
	if is_active:
		time += delta
		text = str(time).pad_decimals(3)

func stop_timer():
	is_active = false
	
func restart_timer():
	time = 0.0
	is_active = true

func on_slow_timer(amount):
	time -= amount;

func on_respawn_world():
	restart_timer()

func on_level_complete():
	if time < LevelManager.record_time:
		LevelManager.record_time = time
		LevelManager.level_win()
