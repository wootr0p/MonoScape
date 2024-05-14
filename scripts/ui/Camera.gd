extends Camera2D

export (NodePath) var TargetNodepath = null
var target_node
export (float) var lerpspeed = 0.1
export (Vector2) var pos_offset = Vector2(30, 0)

func _ready():
	target_node  = get_node(TargetNodepath)
	self.position = target_node.position + pos_offset

func _process(delta):
	self.position = lerp(self.position, target_node.position + pos_offset, lerpspeed)
