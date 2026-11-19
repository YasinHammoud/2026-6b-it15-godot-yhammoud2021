# Gameplay Reference

## Core loop

Move around the arena, read the boss's wind-up, dodge into a safe lane, and fire the staff when there is an opening. The prototype currently contains one encounter and is intended for combat iteration.

## Controls

| Input | Action |
| --- | --- |
| WASD | Move |
| Mouse | Aim |
| Hold Left Mouse Button | Fire the staff |
| Space | Dash in the movement direction, or toward the aim direction when standing still |
| Q or Right Mouse Button | Fire the spread ability |
| R | Restart the encounter |

## Player attacks

- **Staff:** Unlimited basic shots, currently about 2.94 shots per second while held.
- **Prototype ability:** Fires five projectiles in a fan and has a two-second cooldown.
- Frost shards briefly slow player movement when they hit; Frost Resistance shortens that slow.
- After defeating the Rimebound Warden, choose one reward:
  - **Frost Blast:** Replaces the prototype ability with a heavy ice bolt that deals 36 damage and slows the boss briefly. Cooldown: 3 seconds.
  - **Frost Resistance:** Reduces incoming damage by 25%; the prototype ability remains available.
- **Dash:** Brief burst of movement with a cooldown.
- Dashing leaves a brief afterimage trail.
- Hits produce a colored impact spark and a very short hit-stop.
- Taking a hit grants a short period of invulnerability.

## Current prototype boss

The Rimebound Warden is the first visual-slice boss prototype. Its current attack sequence and Frost Blast/Frost Resistance reward choice are prototype behavior.

## Planned ice boss: The Rimebound Warden

Frost shards briefly reduce player movement speed on hit. Persistent frost patches are not part of this visual slice yet; if added, they should have a clear ground tell, last briefly, and allow the player to escape by moving off them.

## Current prototype attack sequence

The prototype boss pauses to telegraph each attack. The pattern order repeats:

1. **Aimed fan:** A visible fan of lines marks the target lane. After the warning, the boss fires four aimed volleys of seven projectiles; the enraged phase fires five wider volleys of nine.
2. **Ring with a gap:** A circular warning marks a denser radial burst. The ring still leaves an opening aimed toward where the player was when the warning began.
3. **Rotating spiral:** A small circular warning precedes a longer, faster stream of projectiles that curves around the arena.

Below half health, the boss shortens its warning to about 0.4 seconds and its recovery to one second, then increases projectile count and speed. The normal-phase warning is about 0.5 seconds. Move during the warning to avoid attacks aimed at the previous position. The ring's open side is a deliberate dodge opportunity.

On the first defeat, the Warden dissolves and the player chooses Frost Blast or Frost Resistance. A fresh Warden then appears for a rematch with the selected reward still equipped; player health and the ability cooldown are refreshed for testing. Later defeats automatically start another rematch, so the selected ability can be tested repeatedly without restarting. Press R at any time to reset the entire encounter and reward choice.

## Current encounter tuning

These are prototype values and may change after playtesting:

- Player health: 100.
- Boss health: 300.
- Staff damage: 12 per projectile.
- Staff cadence: one shot every 0.34 seconds.
- Boss becomes enraged at 150 health.
- Ability cooldown: 2 seconds.
- Frost Blast cooldown after selection: 3 seconds.
- Frost Resistance reduces damage by 25%.

## Readability goals

- Wind-ups should provide enough time to react.
- Bright projectiles should remain distinct from the dark arena.
- A pattern should present a dodgeable route, not merely fill the screen.
- Enrage should increase pressure through pattern changes and cadence, not health alone.
