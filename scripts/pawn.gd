extends RigidBody3D

class_name Pawn

signal merged

var velocity: Vector3 = Vector3.ZERO
var pawn_type: int = 1;
var blink_timer: Timer
var max_pawn_type: int = 5;
var mergeable: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.contact_monitor = true
	self.max_contacts_reported = 100
	self.axis_lock_angular_z = true
	self.axis_lock_angular_x = true
	self.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	self.center_of_mass = Vector3(0, 0.0, 0)
	self.scale = Vector3(1,1,1)
	$CollisionShape3D.scale = Vector3(1.1, 1.1, 1.1)
	self.mass = 1
	self.blink_timer = Timer.new()
	add_child(self.blink_timer)

	# self.connect("body_entered", _on_body_entered)
	self.blink_timer.connect("timeout", _on_blink_timer_timeout)

func disable_pawn_collisions():
	self.mergeable = false
	# Pawn layer
	self.set_collision_layer_value(2, false)
	# Pawn mask
	self.set_collision_mask_value(2, false)

func enable_pawn_collisions():
	self.mergeable = true
	# Pawn layer
	self.set_collision_layer_value(2, true)
	# Pawn mask
	self.set_collision_mask_value(2, true)


func set_pawn_type(ptype: int):
	self.pawn_type = ptype
	self.mass = (ptype + 1) * 15

func _physics_process(_delta: float) -> void:
	if not mergeable:
		return
	if self.pawn_type == max_pawn_type:
		return
	for body in self.get_colliding_bodies():
		# Other pawn entered
		if body.get_collision_layer_value(2):
			# If we're on a maximum pawn type, do nothing
			var pawn = body as Pawn
			if pawn.pawn_type == self.pawn_type and (pawn.position.z > self.position.z or pawn.position.x > self.position.x):
				pawn.queue_free()
				merged.emit(self)
				self.position = self.position + (pawn.position - self.position) / 2.0
				return


func start_blinking() -> void:
	self.blink_timer.start(0.4)

func stop_blinking() -> void:
	self.blink_timer.stop()
	self.visible = true

func _on_blink_timer_timeout() -> void:
	self.visible = not self.visible
