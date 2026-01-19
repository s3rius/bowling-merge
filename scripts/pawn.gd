extends RigidBody3D

class_name Pawn

var velocity: Vector3 = Vector3.ZERO
var pawn_type: int = 1;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.contact_monitor = true
	self.max_contacts_reported = 10

func set_pawn_type(ptype: int):
	self.pawn_type = ptype
	var scale_factor = 1.0 + (0.4 * self.pawn_type)
	var new_scale = Vector3(scale_factor, 1.0, scale_factor)
	self.mass = ptype * 5
	$Collider.scale = new_scale
	$Mesh.scale = new_scale

func _physics_process(_delta: float) -> void:
	for colliding in get_colliding_bodies():
		var pawn = colliding as Pawn
		if pawn == null:
			continue
		if pawn.pawn_type == self.pawn_type:
			pawn.queue_free()
			self.set_pawn_type(self.pawn_type + 1)
			self.position = self.position + (pawn.position - self.position) / 2.0
