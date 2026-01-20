extends Node3D 

@export var pawn_scene: PackedScene;
@export var pawn_velocity: float = 5.0

# Pawn currently held by a player
var active_pawn: Pawn;

# If player holds a finger
var touch_active: bool = false;
var touch_was_active: bool = false;
var ray_from: Vector3;
var ray_to: Vector3;
var playing: bool = true
var score: int = 0

var items_box: Array[int] = [1, 2, 3]

func choose_next_item() -> int:
	var next_item = items_box.pop_back()
	if items_box.size() == 0:
		items_box = [1, 2, 3]
		items_box.shuffle()
	return next_item

func spawn_new() -> void:
	if active_pawn != null:
		return
	var spawn_point: Node3D = get_node("SpawnPoint") as Node3D
	var pawn = pawn_scene.instantiate() as Pawn
	var next_item = choose_next_item()
	pawn.set_pawn_type(next_item)
	pawn.contact_monitor = false
	pawn.disable_pawn_collisions()
	pawn.freeze = true
	pawn.position = spawn_point.position
	pawn.connect("merged", _on_pawn_merged)
	self.active_pawn = pawn
	var pawns: Node3D = $Pawns
	pawns.add_child(pawn)
	next_item = randi_range(1, 3)
	$HUD.set_next_item(items_box[-1])

func _on_pawn_merged(pawn_type: int) -> void:
	score += pawn_type * 10
	$HUD.set_score(score)

func _ready() -> void:
	$Limit.connect("limit_hit", game_over)
	get_tree().get_root().connect("go_back_request", go_to_main_menu)
	items_box.shuffle()
	$HUD.set_score(0)

# # Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.active_pawn == null:
		spawn_new()

func _physics_process(_delta: float) -> void:
	# We map to a point on a plane to make active_pawn follow 
	# touch gesture.
	if self.touch_active:
		if not self.ray_from || not self.ray_to:
			return
		var direct_state = self.get_world_3d().direct_space_state
		var ray = PhysicsRayQueryParameters3D.create(self.ray_from,self.ray_to)
		ray.exclude=[self.active_pawn, $Board/RightStopper, $Board/LeftStopper, $Board/ForwardStopper]
		var intersects = direct_state.intersect_ray(ray)
		if not intersects:
			return
		self.active_pawn.position.x = intersects.position.x
		return 
	# Touch was just released 
	if self.touch_was_active:
		self.active_pawn.linear_velocity= Vector3(0.0, 0.0, self.pawn_velocity)
		self.active_pawn.freeze = false
		self.active_pawn.contact_monitor = true
		self.active_pawn.enable_pawn_collisions()
		self.active_pawn = null
		self.touch_was_active = false
		return

func game_over() -> void:
	playing = false
	$GameOverPopUp.show()

func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func _input(event: InputEvent) -> void:
	if active_pawn == null:
		return
	if playing == false:
		return
	var camera: Camera3D = $MainCamera;
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		# We remember rays for the next call of physics_process,
		self.ray_from = camera.project_ray_origin(event.position)
		self.ray_to = self.ray_from + camera.project_ray_normal(event.position) * 100
		self.touch_active = true
		if event is InputEventScreenTouch:
			if not event.pressed:
				self.touch_was_active = true
				self.touch_active = false
