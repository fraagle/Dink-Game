extends Camera2D

#@onready var player: CharacterBody2D = $"../Player"
#@onready var player: CharacterBody2D = $"../../../Player"
@onready var player: CharacterBody2D = $"../Player"

@onready var new_position = player.position


var camera_panning = true
var current_area: Area2D = null
var camera_following = false
var last_position = position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.camera_area_entered.connect(func(area):
		print('area entered')
		
		if camera_following:
			camera_following = false
		
		if camera_panning:
			camera_panning = false
		
		position.y = lerp(last_position.y, area.position.y, 1)
		position.x = lerp(last_position.x, area.position.x, 1)
		
		#position = area.position
		current_area = area
	)
	Events.camera_area_exited.connect(func(area):
		print('left area')
		
		if area == current_area:
			camera_panning = true
			current_area = null
		
	)
	Events.camera_follow_area_entered.connect(func(area):
		print('follow area entered')
		if camera_panning:
			camera_panning = false
		
		camera_following = true
		
		position = area.position
		current_area = area
		
	)
	Events.camera_follow_area_exited.connect(func(area):
		print('follow area exited')
		
		last_position = position
		
		if area == current_area:
			camera_following = false
			camera_panning = true
			current_area = null
		)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	camera_panning_player()
	camera_following_player(_delta)
	

func camera_panning_player():
	if camera_panning:
		position = player.position
		var x = floor(position.x / 512) * 512
		var y = floor(position.y / 320) * 320
		#print(x)	
		
		position = Vector2(x,y)
		

		
# Speed of camera movement (adjust as needed)
var camera_speed = 5.0
var screen_height = 320  # Assuming the screen height is 320
	
func camera_following_player(delta):
	if camera_following:
		print("camera_following")

		# Calculate 4/5 and 1/5 screen height thresholds
		var upward_threshold = current_area.position.y + screen_height * (9 / 10)
		var downward_threshold = current_area.position.y + screen_height * (1 / 10)

		# Get player's position
		var player_y = player.position.y

		# Move camera upwards only if the player reaches 4/5 of the screen
		if player_y < upward_threshold:
			var desired_position_y = player_y - screen_height / 2  # Centers camera on player vertically
			position.y = lerp(position.y, desired_position_y, camera_speed * delta)

		# Move camera downwards only if the player reaches 1/5 of the screen
		elif player_y > downward_threshold:
			var desired_position_y = player_y - screen_height / 2  # Centers camera on player vertically
			position.y = lerp(position.y, desired_position_y, camera_speed * delta)

		## Maintain the horizontal position if needed (optional)
		#var desired_position_x = player.position.x
		#position.x = lerp(position.x, desired_position_x, camera_speed * delta)

		# Update camera limits
		limit_bottom = current_area.position.y + screen_height
	else:
		# Reset camera limits if not following
		limit_top = -1000000
		limit_bottom = 1000000
