extends KinematicBody2D


var movespeed = 400
var bullet_speed = 2000
var bullet = preload("res://Location/DownWorld/scenes5/FireBall0.tscn")
var count = 20
var hp = 1000
var max_hp = 1000
var heal = 20
var power = 2
func _ready():
	pass
func _physics_process(delta):
	var motion = Vector2()
	
	if Input.is_action_pressed("up"):
		motion.y -= 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1
	if Input.is_action_pressed("right"):
		motion.x += 1

	motion = motion.normalized()
	motion = move_and_slide(motion * movespeed)
	look_at(get_global_mouse_position())	
	if Input.is_action_pressed("fire_action"):
		fire()


func fire():

	if GlobalVar.SpellTime == true and hp > 0:
		GlobalVar.SpellTime = false
		$SpellTimer.start(0.5)
		decrease_hp(power)		
		var bullet_instance = bullet.instance()
		bullet_instance.position = get_global_position()
		bullet_instance.rotation_degrees = rotation_degrees
		bullet_instance.apply_impulse(Vector2(), Vector2(-bullet_speed,0).rotated(rotation-10))	
		get_tree().get_root().call_deferred("add_child",bullet_instance)

#	else:
#		count = 0
func killed():
	get_tree().reload_current_scene()
func increase_hp(val):
	hp += val
	if hp > max_hp:
		hp = max_hp
	GlobalVar.UI.value  = int(hp)	
func decrease_hp(val):
	hp -= val

	if hp < 0:
		killed()
	GlobalVar.UI.value  = int(hp)
func _on_Area2D_body_entered(body):
	if "Heal" in body.name:
		increase_hp(heal)
	if "Enemy" in body.name:
		decrease_hp(15)
	if "HellDog" in body.name:
		decrease_hp(30)
	if "Ghost" in body.name:
		decrease_hp(60)
	if "Boss2" in body.name:
		decrease_hp(150)
	if "Boss" in body.name:
		decrease_hp(200)
	if "Skull" in body.name:
		decrease_hp(200)	
	if "Teleport" in body.name:
		GlobalVar.hp = hp
		get_tree().change_scene("res://Location/DownWorld/scenes5/DungeonLevel2.tscn")	
