extends KinematicBody2D
class_name Player

const VEL_Y_MAX := 300
const X_ACC := 1000
const X_DEC := 1200
const X_MAX_SPEED := 150
const WALL_JUMP_SLIPPERY := 0.85
const WALL_JUMP_MUL := 2
const WALL_JUMP_BOUNCE_SPEED := 600
const DASH_SPEED := 500

var is_player_alive = true
var velocity = Vector2()

var coyote_time := false
var wanna_jump := false
var jump_avaiable := true
var dash_avaiable := true
var jump_hold := false
var was_on_floor := false
var wall_jump_left := false
var wall_jump_right := false

var dash_direction
var is_dashing := false
var is_dash_on_air := false

var rng = RandomNumberGenerator.new()

# Jump math: https://youtu.be/IOe1aGY6hXA?si=XO78Hvkm3UpO0b7t
export var jump_height : float = 100;
export var jump_time_to_peak : float = 0.5;
export var jump_time_to_descent : float = 0.45;
onready var jump_velocity : float = -400

func _ready():
	LevelManager.player_start_position = self.position;
	
	LevelManager.connect("respawn_world", self, "on_respawn_world")
	LevelManager.connect("respawn_player", self, "on_respawn_player")
	LevelManager.connect("gravity_flipped", self, "on_gravity_flipped")

func _physics_process(delta):
	
	# GRAVITY
	if !is_on_floor():
		velocity.y += LevelManager.get_gravity(velocity) * delta;
	else:
		velocity.y = 0;
	
	var x_direction = Input.get_axis("ui_left", "ui_right")
	var y_direction = Input.get_axis("ui_up", "ui_down")
	
	if is_player_alive:
		# MOVE
		if x_direction:
			velocity.x += x_direction * X_ACC * delta
		else:
			if velocity.x > 0:
				velocity.x += -X_DEC * delta
				velocity.x = clamp(velocity.x, 0, X_MAX_SPEED);
			elif velocity.x < 0:
				velocity.x += X_DEC * delta
				velocity.x = clamp(velocity.x, -X_MAX_SPEED, 0);
		velocity.x = clamp(velocity.x, -X_MAX_SPEED, X_MAX_SPEED);
		# JUMP
		Jump(delta)
		velocity.y = clamp(velocity.y, -VEL_Y_MAX, VEL_Y_MAX);
		# DASH
		Dash(delta, x_direction, y_direction)
	else:
		velocity.x *= 0.5;
	
	# APPLY VELOCITY
	#print(velocity)
	move_and_slide(velocity, Vector2.UP)
	

func Dash(delta, x_direction, y_direction):
	if Input.is_action_just_pressed("ui_cancel") && dash_avaiable:
		# DASH
		# di default la direzione è avanti
		if x_direction == 0 && y_direction == 0:
			x_direction = 1
		dash_direction = Vector2(x_direction, y_direction).normalized()
		is_dash_on_air = !is_on_floor()
		is_dashing = true
		$Dash_Duration_Timer.start()
		$DashSound.playing = true;
		$Trail.is_active = true
		dash_avaiable = false
		$AnimatedSprite.play("Normal")
	
	if is_dashing:
		velocity = dash_direction * DASH_SPEED
	
	# il dash è disponibile se l'ho eseguito in aria, appena tocco terra
	if is_dash_on_air && is_on_floor():
		dash_avaiable = true;
		$AnimatedSprite.play("Dash_Ready")
	# altrimenti se sono a terra ed è finito il timer di reload
	elif is_on_floor() && !is_dashing && $DashReloadTimer.is_stopped():
		dash_avaiable = true;
		$AnimatedSprite.play("Dash_Ready")

func Jump(delta):
	
	# SALTO A MURO
	WallJump(delta)
	
	if Input.is_action_just_pressed("ui_accept"):
		wanna_jump = true;
		$Jump_Buffer_Timer.start()
	
	# Coyote
	if was_on_floor && !is_on_floor():
		coyote_time = true;
		jump_avaiable = true;
		$Coyote_Time_Timer.start()
	was_on_floor = is_on_floor();
		
	if is_on_floor():
		jump_avaiable = true;
	
	if jump_avaiable:
		if wanna_jump:
			# SALTO
			velocity.y = LevelManager.gravity_sign * jump_velocity
			play_jump_sound()
			jump_avaiable = false;
			jump_hold = true;
			$Jump_Min_Hold_Time.start()
	
	# CADO prima se rilascio il salto, ma non se sto strisciando sul muro
	if !jump_hold && !Input.is_action_pressed("ui_accept"):
		#if !$Left_RayCast.is_colliding() && !$Right_RayCast.is_colliding():
			velocity.y += LevelManager.get_gravity(velocity) * delta;
	
	# se tocco il soffitto cado immediatamente
	if is_on_ceiling():
		velocity.y = 0;
		velocity.y += LevelManager.get_gravity(velocity) * delta;
	
	#print("ja:", jump_avaiable, " wj:" , wanna_jump, " coyote ", coyote_time, " ", $Left_RayCast.is_colliding(), $Right_RayCast.is_colliding());

func WallJump(delta):
	if !is_on_floor():
		if is_on_left_wall():
			if velocity.y * LevelManager.gravity_sign > 0:
				velocity.y *= WALL_JUMP_SLIPPERY;
				play_slide_sound()
			else:
				stop_slide_sound()
			if Input.is_action_just_pressed("ui_accept") && !wall_jump_left:
				# WALL JUMP A DESTRA
				velocity.y = LevelManager.gravity_sign * jump_velocity * WALL_JUMP_MUL
				velocity.x = LevelManager.gravity_sign * WALL_JUMP_BOUNCE_SPEED
				play_jump_sound()
				wall_jump_left = true
				wall_jump_right = false
		
		if is_on_right_wall():
			if velocity.y * LevelManager.gravity_sign > 0:
				velocity.y *= WALL_JUMP_SLIPPERY;
				play_slide_sound()
			else:
				stop_slide_sound()
			if Input.is_action_just_pressed("ui_accept") && !wall_jump_right:
				# WALL JUMP A SINISTRA
				velocity.y = LevelManager.gravity_sign * jump_velocity * WALL_JUMP_MUL
				velocity.x = -1 * LevelManager.gravity_sign * WALL_JUMP_BOUNCE_SPEED
				play_jump_sound()
				wall_jump_right = true
				wall_jump_left = false
				
		if !is_on_left_wall() && !is_on_right_wall():
			stop_slide_sound()
	else:
		wall_jump_right = false
		wall_jump_left = false
		stop_slide_sound()

func is_on_right_wall():
	if LevelManager.gravity_sign:
		return $Right_RayCast.is_colliding()
	else:
		return $Left_RayCast.is_colliding()

func is_on_left_wall():
	if LevelManager.gravity_sign:
		return $Left_RayCast.is_colliding()
	else:
		return $Right_RayCast.is_colliding()

func is_on_floor():
	var g1 = $RaycastGround1.is_colliding()
	var g2 = $RaycastGround2.is_colliding()
	var g3 = $RaycastGround3.is_colliding()
	#print("g1:", g1, " ", "g2:", g2, " ", "g3:", g3, " ")
	return g1 || g2 || g3

func is_on_ceiling():
	var c1 = $RaycastCeiling1.is_colliding()
	var c2 = $RaycastCeiling2.is_colliding()
	var c3 = $RaycastCeiling3.is_colliding()
	#print("c1:", c1, " ", "c2:", c2, " ", "c3:", c3, " ")
	return c1 || c2 || c3

func play_jump_sound():
	$JumpSound.pitch_scale = rng.randf_range(0.8, 1.2)
	if $Jump_Sound_Timer.is_stopped():
		$Jump_Sound_Timer.start()
		$JumpSound.playing = true;

func play_slide_sound():
	if !$SlideSound.playing:
		$SlideSound.playing = true;
func stop_slide_sound():
	if $SlideSound.playing:
		$SlideSound.playing = false;
	
func _on_Jump_Buffer_Timer_timeout():
	wanna_jump = false;

func _on_Coyote_Time_Timer_timeout():
	coyote_time = false;
	jump_avaiable = false;

func _on_Jump_Min_Hold_Time_timeout():
	jump_hold = false;

func _on_End_body_entered(body):
	get_tree().get_nodes_in_group("UI_Stopwatch")[0].stop_timer()
	LevelManager.level_complete()

func _on_DashReloadTimer_timeout():
	$Trail.is_active = false

func _on_Dash_Duration_Timer_timeout():
	is_dashing = false
	$DashReloadTimer.start()

func die():
	# KILL PLAYER
	is_player_alive = false
	$ParticlesDeath.emitting = true
	$DeathSound.playing = true;
	$SlideSound.playing = false;
	$AnimatedSprite.visible = false
	$Trail.is_active = false
	LevelManager.respawn_player_delayed()

func respawn():
	is_player_alive = true
	$ParticlesDeath.emitting = false
	$DeathSound.playing = false;
	$SlideSound.playing = false;
	$AnimatedSprite.visible = true
	$Trail.is_active = false

func on_respawn_world():
	self.position = LevelManager.player_start_position;
	rotation_degrees = 0
	respawn()

func on_respawn_player():
	position = LevelManager.current_checkpoint.global_position;
	respawn()

func on_gravity_flipped():
	if LevelManager.gravity_sign < 0:
		rotation_degrees = 180
	else:
		rotation_degrees = 0
