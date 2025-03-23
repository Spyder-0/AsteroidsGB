Version: <VERSION>
	_        _                 _     _      ____ ____  
   / \   ___| |_ ___ _ __ ___ (_) __| |___ / ___| __ ) 
  / _ \ / __| __/ _ \ '__/ _ \| |/ _` / __| |  _|  _ \ 
 / ___ \\__ \ ||  __/ | | (_) | | (_| \__ \ |_| | |_) |
/_/   \_\___/\__\___|_|  \___/|_|\__,_|___/\____|____/ 

Welcome to AsteroidsGB, thank you for playing!
Your goal is to protect planet Earth from incoming Asteroids, along with your new and improved Buster, blasting away at these space rocks will be a piece of cake!

Credits:
> Software:
- Godot: https://godotengine.org/
- LibreSprite: https://libresprite.github.io/#!/
- JSFXR: https://github.com/chr15m/jsfxr/
- Kdenlive: https://kdenlive.org/en/

> Assets:
- Font: Jimmy Campbell on https://www.dafont.com/jimmy-campbell.d5241
- Music: Ryan Atari on https://www.instagram.com/ryan.atari/

Executing Game:
- For Linux (x86_64):
	- Double click the executable (.x84_64). Or run from the terminal (./AsteroidsGB.x86_64).
	- If the game doesn't launch, open a terminal in the project directory and run this command: chmod +x ./AsteroidsGB.x86_64
	- Alternatively right click the executable and find the permissions option. Toggle the permission that says: Allow executing file as a program. Options may vary with different file managers.
- For Windows (x84_64):
	- Double click the executable (.exe). 
	- If Windows defender smart screen warns about running an unrecognized app, just click: Run anyway.
- For macOS (x84_64 or ARM64):
	- Instead of double clicking the executable (.app), right click then press Open.
	- A prompt will appear stating that Apple cannot check for malicious software, press Open anyway.
	- Since the program is unsigned, macOS can block it from running. And to unblock it, go to System Settings > Privacy & Security > Scroll to where is says "Open Anyway" and click it.

Keyboard Controls:
- General:
	- F11: Toggle Fullscreen (Can be pressed at any time).
- Menu Controls:
	- Arrows: Menu Select.
	- Enter: Menu Confirm.
	- Escape: Menu Back.
	- Mouse: Menu Select and Confirm.
- Game Controls:
	- Arrows or WASD: Ship Movement.
	- Z or X or Space: Buster Shoot.
	- Escape (Double Press): Open Menu.

Controller Bindings:
- Note: A controller icon will be displayed in the top left area of the menu when a controller is detected.
- Menu Controls:
	- D-pad or Left Stick: Menu Select.
	- Right Face Button (Nintendo A, PlayStation Circle, Xbox B): Menu Confirm.
	- Bottom Face Button (Nintendo B, PlayStation Cross, Xbox A): Menu Back.
- Game Controls:
	- D-pad Up: Thrust Forward.
	- Shoulder Buttons or D-pad Side Buttons: Rotate Ship.
	- Right Face Button (Nintendo A, PlayStation Circle, Xbox B): Buster Shoot.
	- Bottom Face Button (Nintendo B, PlayStation Cross, Xbox A): Open Menu.

Release Notes:
- Version 1.0.0 (Changes from Beta):
	- Fixed bugs and optimised code.
	- Balanced existing power-ups and invincibility frames.
	- Power-ups will now blink when almost expiring.
	- Ship now flashes when consuming a power-up.
	- Collecting a power-up while health is full will award points.
	- Laser velocity increased.
	- Improved menu text and added text to the game over screen.
	- Credits sub-menu has been added.
	- Sprite rendering improved (pixel art should look sharper)m and engine rendering switched to Forward+.
	- Added "Anti Power-ups".
	- Added falling meteors.
	- Added music by Ryan Atari.
	- New sound effects, as well as tweaking audio for existing ones.
	- Player can level up when a certain amount of points is reached.
	- Ambient particles added to the background.
	- Player will emit explosion particles upon death.
	- Game can be fullscreened using F11 key.
	- Controller vibration triggered when taking damage.
	- User can open their save directory from the Option Menu.
	- Removed bird.
- Version 1.0.1:
	- Refactored some code.
	- Added seizure warning on boot screen.
	- Adjusted game over screen messages.
	- Splash screen can be skipped by pressing escape key.
	- Reduced score requirement for leveling up.
	- New main menu tips.
- Version 1.0.2:
	- Updated engine version (Godot 4.4).
	- Fixed some particle effects.
- Version 1.0.3:
	- Fixed a typo in the Option Menu.
	- Adjusted (font) credits.
