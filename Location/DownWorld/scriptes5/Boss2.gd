extends KinematicBody2D
var count = 5	
var SpellTime = true
var motion = Vector2()
var wait_count = 100 #замедление мобов
var bullet = preload("res://Location/DownWorld/scenes5/NecroArrow.tscn")
var bullet_speed = 2000
# Called when the node enters the scene tree for the first time.
func _ready():
	$SpellTimer.start(2)
func a_physics_process(delta):	
#	var Player = get_parent().get_parent().get_node("Player")
	
	position += (GlobalVar.Player.position - position)/wait_count
#	look_at(Player.position)

	move_and_collide(motion)
func fire():

#	if SpellTime == true :
#		SpellTime = false

	
		var bullet_instance = bullet.instance()
		bullet_instance.position = get_global_position()
		bullet_instance.rotation_degrees = rotation_degrees
		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed,0).rotated(rotation))	
		get_tree().get_root().call_deferred("add_child",bullet_instance)


func _on_Area2D_body_entered(body):
#	return
	if "Bullet" in body.name:
		count -= 1
		if count < 0:

	
			queue_free()



func _on_SpellTimer_timeout():
	fire() # Replace with function body.
