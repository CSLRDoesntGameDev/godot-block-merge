extends Control

@onready var blocks: Node2D = %Blocks
@onready var delete_zone: Area2D = %DeleteZone
@onready var clear_hazard: ColorRect = %ClearHazard

var current_block: Block
var drop_position: Vector2

var clear_charge: float = 0
var clear_charge_required: float = 2

func _ready() -> void:
	spawn_block()

func spawn_block() -> void:
	current_block = Block.new()
	blocks.add_child(current_block)
	current_block.po2 = clamp(randi_range(2, CurrentGame.highest_po2-1), 2, 1024)
	current_block.position.x = drop_position.x

func _draw() -> void:
	if is_instance_valid(current_block):
		var rect_pos_x: int = clamp(drop_position.x, 0, size.x-current_block.render_size.x)
		var rect_size := Vector2(current_block.render_size.x, size.y - current_block.position.y)
		var rect := Rect2(Vector2(rect_pos_x, drop_position.y), rect_size)
		draw_rect(rect, Color(.5,.5,.5,.5))

func _process(delta: float) -> void:
	queue_redraw()
	if not is_instance_valid(current_block):
		if blocks.get_child_count() == 0:
			spawn_block()
		
		return
	
	drop_position = get_local_mouse_position() - Vector2(current_block.render_size.x / 2, 0)
	drop_position.y = 16
	
	if not current_block.active:
		current_block.position.x = clamp(drop_position.x, 0, size.x-current_block.render_size.x)
		current_block.position.y = drop_position.y
	
	var overlapping_bodies := delete_zone.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		for body: Node2D in overlapping_bodies:
			if is_instance_valid(body) and body is Block:
				if body.active:
					clear_charge += delta
	else:
		clear_charge = lerp(clear_charge, 0.0, delta)
	
	clear_hazard.color = Color(.5 + ((clear_charge / clear_charge_required) / 2.0),.5,.5,.5)
	
	if clear_charge > clear_charge_required:
		CurrentGame.game_over()
		clear_charge = 0

func _gui_input(event: InputEvent) -> void:
	if not is_instance_valid(current_block): return
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			current_block.active = true
			current_block = null
			
			await get_tree().create_timer(1.0).timeout
			spawn_block()
