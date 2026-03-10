# Godot 2D Game Project - Planning Notes

Date: 2026-03-09

## Game Concept

2D action game with a character running around. Designed to be extensible with:
- Enemies
- Guns / weapons
- Combat system
- Various maps

## Technology Decisions

- **Engine**: Godot 4.3+ (2D is first-class, lightweight, free & open source)
- **Language**: GDScript (recommended over C# for lower friction, better Godot integration, more tutorials)
- **Separate repository** from flyt-platform

## What Claude Can Help With

- Writing GDScript code (movement, physics, state machines, combat, AI)
- Scene structure design (node hierarchy, signals, scene composition)
- Shader code (simple 2D effects)
- Algorithm logic (pathfinding, collision, spawning, AI behavior)
- Iterating on game mechanics incrementally

## Known Limitations for Claude Cooperation

- Cannot run Godot or see the game visually — need descriptions of what's happening
- Cannot create art/sprites — use free asset packs (itch.io, kenney.nl)
- Cannot interact with Godot editor UI — drag-and-drop, inspector, visual signal connections need manual work
- `.tscn` files are text-based and editable but fragile for complex scenes
- Don't touch `.import` or `.gdextension` files (auto-generated)
- Visual debugging requires back-and-forth communication

## Suggested First Milestone

1. Set up Godot project structure
2. CharacterBody2D with basic movement (~20 lines of GDScript)
3. Simple tilemap or placeholder environment
4. Get character moving on screen

## Next Steps

- Create a new repo for the game
- Install Godot 4.3+ if not already installed
- Use /flow or /plan skill to design the initial project structure and kickstart development
