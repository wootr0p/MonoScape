extends Camera2D

@export var TargetNodepath : NodePath
var target_node
@export var lerpspeed : float = 0.1
@export var pos_offset : Vector2 = Vector2(30, 0)

func _ready():
	target_node  = get_node(TargetNodepath)
	self.position = target_node.position + pos_offset

func _process(delta):
	self.position = lerp(self.position, target_node.position + pos_offset, lerpspeed)
