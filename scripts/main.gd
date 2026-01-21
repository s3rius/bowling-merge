extends Node3D 

# @export var pawn_scene: PackedScene;
@export var pawn_velocity: float = 5.0
@export var pawns_scene: PackedScene
@export var max_pawn_type: int = 3

# Pawn currently held by a player
var active_pawn: Pawn;

# If player holds a finger
var touch_active: bool = false;
var touch_was_active: bool = false;
var ray_from: Vector3;
var ray_to: Vector3;
var playing: bool = true
var score: int = 0

var available_pawns: Array[Node]
var items_box: Array = []

func choose_next_item() -> int:
	var next_item = items_box.pop_back()
	if items_box.size() == 0:
		items_box = range(min(available_pawns.size(), max_pawn_type))
		items_box.shuffle()
	return next_item

func spawn_new() -> void:
	if active_pawn != null:
		return
	var pawn_type = choose_next_item()
	var pawn = available_pawns[pawn_type].duplicate() as Pawn
	pawn.contact_monitor = false
	pawn.max_pawn_type = self.available_pawns.size() - 1
	pawn.disable_pawn_collisions()
	pawn.freeze = true
	pawn.set_pawn_type(pawn_type)
	pawn.position = $SpawnPoint.position
	pawn.connect("merged", _on_pawn_merged)
	self.active_pawn = pawn
	$SpawnedPawns.add_child(pawn)
	$HUD.set_next_item(items_box[-1])

func upgrade_pawn(pawn: Pawn) -> void:
	var new_pawn_type = pawn.pawn_type + 1
	if new_pawn_type >= available_pawns.size():
		return
	var new_pawn = available_pawns[new_pawn_type].duplicate() as Pawn
	pawn.disable_pawn_collisions()
	new_pawn.max_pawn_type = pawn.max_pawn_type
	new_pawn.linear_velocity = pawn.linear_velocity
	new_pawn.position = pawn.position
	new_pawn.set_pawn_type(new_pawn_type)
	new_pawn.connect("merged", _on_pawn_merged)
	new_pawn.enable_pawn_collisions()
	$SpawnPoint.add_child(new_pawn)
	pawn.queue_free()

func _on_pawn_merged(pawn: Pawn) -> void:
	upgrade_pawn(pawn)
	score += pawn.pawn_type * 10
	$HUD.set_score(score)

func load_pawns() -> void:
	var loaded_scene = pawns_scene.instantiate()
	loaded_scene.position = Vector3(0, 0, -10)
	loaded_scene.visible = false
	add_child(loaded_scene)
	available_pawns = loaded_scene.get_children()
	available_pawns.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)
	items_box = range(min(available_pawns.size(), max_pawn_type))

func _ready() -> void:
	load_pawns()
	$Limit.connect("limit_hit", game_over)
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
		ray.exclude=[self.active_pawn]
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

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		go_to_main_menu()
