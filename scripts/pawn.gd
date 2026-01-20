extends RigidBody3D

class_name Pawn

signal merged

var velocity: Vector3 = Vector3.ZERO
var pawn_type: int = 1;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.contact_monitor = false
	self.max_contacts_reported = 10

func disable_pawn_collisions():
	# Pawn layer
	self.set_collision_layer_value(2, false)
	# Pawn mask
	self.set_collision_mask_value(2, false)

func enable_pawn_collisions():
	# Pawn layer
	self.set_collision_layer_value(2, true)
	# Pawn mask
	self.set_collision_mask_value(2, true)


func set_pawn_type(ptype: int):
	self.pawn_type = ptype
	var scale_factor = 1.0 + (0.4 * self.pawn_type)
	var new_scale = Vector3(scale_factor, 1.0, scale_factor)
	self.mass = ptype * 15
	$Collider.scale = new_scale
	$Mesh.scale = new_scale
	$Mark.text = str(ptype)

func _on_body_entered(body: Node) -> void:
	if body.get_collision_layer_value(2):
		var pawn = body as Pawn
		if pawn.pawn_type == self.pawn_type:
			pawn.queue_free()
			merged.emit(self.pawn_type)
			self.set_pawn_type(self.pawn_type + 1)
			self.position = self.position + (pawn.position - self.position) / 2.0
			return

func start_blinking() -> void:
	$BlinkTimer.start(0.4)

func stop_blinking() -> void:
	$BlinkTimer.stop()
	self.visible = true

func _on_blink_timer_timeout() -> void:
	self.visible = not self.visible
