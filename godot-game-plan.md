# Angela Adventurer - 2D Survival Shooter

## Completed Phases

- **Phase 0**: Project setup, Godot config, folder structure, git repo
- **Phase 1**: Player movement (WASD), mouse aim, camera follow
- **Phase 2**: TileMap world with wall collision
- **Phase 3**: Weapon system (pistol, bullets, ammo, reload)
- **Phase 4**: Enemies (chase AI, spawner, contact damage)
- **Phase 5**: Combat loop (health, loot, HUD, game over, score)
- **Phase 6**: Polish (screen shake, muzzle flash, hit flash shader, pause menu)

---

## Phase 7: More Weapons

**Goal**: Add shotgun and rifle. Weapon base class already exists.

### 7A. Shotgun
- Fires 5 bullets in a spread pattern (±15° arc)
- High damage per pellet, slow fire rate, low ammo
- Short range (bullets have shorter lifetime)

### 7B. Rifle
- Fast fire rate, lower damage per bullet
- Large magazine, longer reload
- Longer bullet range

### 7C. Weapon Switching
- Number keys (1/2/3) to switch weapons
- Player carries all weapons, switches active one
- HUD shows current weapon name

---

## Phase 8: Enemy Variety

**Goal**: Three distinct enemy types with different behaviors.

### 8A. Runner
- Fast speed, low health
- Smaller sprite, harder to hit

### 8B. Tank
- Slow, high health, high contact damage
- Larger sprite

### 8C. Ranged Enemy
- Keeps distance from player
- Shoots projectiles at player (uses EnemyProjectiles layer)
- Flees if player gets too close

### 8D. Spawner Updates
- Weighted random selection of enemy types
- Harder enemies appear as time/waves progress

---

## Phase 9: Wave System

**Goal**: Structured waves with breaks, escalating difficulty.

- Wave counter displayed on HUD
- Each wave spawns a set number of enemies
- Brief rest period between waves (3-5 seconds)
- Enemy count and mix increases each wave
- Boss wave every 5 waves (extra tanky enemy or swarm)

---

## Phase 10: Sound Effects

**Goal**: Audio feedback for all major actions.

- Shooting sound per weapon type
- Enemy hit / death sounds
- Player damage sound
- Loot pickup sound
- UI click sounds
- Background music (looping ambient/action track)
- SoundManager autoload for easy playback

---

## Phase 11: Main Menu

**Goal**: Title screen before gameplay.

- Game title + "Start" / "Quit" buttons
- Transitions to game world on Start
- Settings button (volume sliders) — optional
- Shows high score if saved

---

## Phase 12: Weapon Pickups

**Goal**: Find new weapons on the map or from loot.

- Weapons drop from enemies (rare) or spawn on map
- Walk over to pick up — replaces or adds to inventory
- Visual indicator (floating/bobbing sprite)
- Extends existing loot system with weapon loot type

---

## Phase 13: Minimap

**Goal**: Small minimap showing enemy positions.

- Corner of screen, SubViewport-based
- Shows player (blue dot), enemies (red dots), walls
- Zoomed-out orthographic view

---

## Phase 14: High Score Persistence

**Goal**: Save and display best scores across sessions.

- Save to user:// JSON file
- Track top 5 scores
- Display on game over screen and main menu

---

## Phase 15: Character Sprite Matching Weapon

**Goal**: Player sprite changes based on equipped weapon.

- Use Kenney variants: manBlue_gun.png, manBlue_machine.png, manBlue_hold.png
- Swap Sprite2D texture when weapon changes
- Fixes the "double gun" visual issue

---

## Phase 16: Larger Maps

**Goal**: Bigger arena with more variety.

- Expand tilemap to ~60x40 tiles
- Multiple rooms/areas connected by corridors
- Varied ground textures per area
- More wall obstacles for tactical cover

---

## Technology Notes

- **Engine**: Godot 4.6 (Compatibility renderer)
- **Language**: GDScript
- **Repo**: github.com/michal-angelovic/angela-adventurer
- **Assets**: Kenney Top-Down Shooter, UI Pack, Crosshair Pack (CC0)
- **Architecture**: Component pattern, signals, autoload singletons
- **Collision Layers**: World(1), Player(2), Enemies(3), PlayerProjectiles(4), EnemyProjectiles(5), Loot(6)
