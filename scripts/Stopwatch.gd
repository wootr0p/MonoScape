extends Label
class_name Stopwatch

var time : float
var is_active : bool

func _ready():
	LevelManager.stopwatch = self;
	
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

func slow_timer(amount):
	time -= amount;
