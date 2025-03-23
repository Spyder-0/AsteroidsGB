extends Control

@onready var tip_label: Label = $LogoLabel/TipLabel
@onready var controller_sprite: TextureRect = $ControllerTextureRect
@onready var game_version_label: Label = $BottomLabels/VersionLabel
@onready var high_score_label: Label = $BottomLabels/HighScoreLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var secondary_animation: StringName = "secondary_animation"

var tip_messages: Array[String] = [
	"Use the new and improved dubl-buster™ to turn asteroids into space dust.",
	"Your ship's body can withstand many blows, especially from asteroids - hopefully.",
	"Using Titanium and cutting-edge technology, the new ship is exactly like last year's model.",
	"Controller is supported?",
	"The production cost for your ship was 43 Million Zennys, which is equivalent to about 43 million Dollars.",
	"Our medical team can sort you out in case of an emergency.",
	"So you're the new captain??",
	"You can enable fullscreen mode in the Option Menu.",
	"Use a Cobalt pickaxe to mine Mythril - Oh wait, wrong game.",
	"Also try Asteroids for the Atari!",
	"Find scattered power-ups, as they are vital for space exploration.",
	"Power-ups as well as Anti Power-ups have a chance to drop from large asteroids.",
	"Acceleration power-ups can improve your thruster and handling for a short time.",
	"This game uses autosave...",
	"Small asteroids are pretty fast, so make sure to deal with them first.",
	"Be sure to check your radar for any incoming meteors.",
	"Meteors hit pretty hard, be careful!",
	"Anti power-ups are similar to normal power-ups, but with a twist.",
	"Anti power-ups can award a lot of points, but have unintended side effects...",
	"Power-ups cannot be picked up while the ship regenerates.",
	"Leveling up will destroy all asteroids on the screen.",
	"Collecting health power-ups while at full health will increase your score.",
	"Short on time? Skip the boot animation by pressing ESC.",
	"No AI generated content!"
	] # List of possible messages that can display on the menu.

var game_version: String = ProjectSettings.get_setting("application/config/version") # Get the project version from the engine itself.


func _ready():
	update_labels()
	Globals.reset_player_variables()
	
	# Show a small notification when a controller is detected.
	if Input.get_connected_joypads().size() > 0:
		print("[SYS] [main_menu] Controller detected.")
	
		var controller_tween: Tween = get_tree().create_tween()
		controller_tween.tween_property(controller_sprite, "modulate:a", 1.0, 3.0)

func update_labels():
	tip_label.text = tip_messages.pick_random() # Randomly picks a message from the array to display on the menu.
	game_version_label.text = "v-{ver}".format({"ver": game_version}) # Format and update the label text.
	high_score_label.text = "Hi Score: {hi_score}".format({"hi_score": str(Globals.high_score)}) # Update the high score on the menu.

func play_secondary_animation(): # Function that plays a different animation track. Will be called in the AnimationPlayer.
	animation_player.play(secondary_animation)
