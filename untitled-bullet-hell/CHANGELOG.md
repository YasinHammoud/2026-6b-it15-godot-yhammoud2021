# Changelog

Notable project changes are recorded here. Entries describe the prototype, not a released build.

## Unreleased

### Changed

- Reduced the held staff fire rate from about 6.25 shots per second to about 2.94 shots per second.
- Increased boss projectile counts and slightly shortened the pauses between attacks for a harder encounter.
- Further increased pattern density and projectile speed with a small reduction to wind-up time; the radial safe gap remains.
- Shortened boss wind-ups to 0.5 seconds normally and 0.4 seconds when enraged.
- Added hit sparks, a short dash afterimage, and brief hit-stop on successful hits.
- Added a boss defeat dissolve and a choice between Frost Blast and Frost Resistance.
- Added ice crystals, broken pillars, and rubble around the arena edges.
- Replaced the previous whimsical boss candidates with a darker, character-driven roster proposal.
- Created and integrated the first original pixel-art visual slice for the player, Rimebound Warden, arena tiles/props, and combat projectiles.
- Frost shard hits now briefly slow the player to support the ice boss's attack identity.
- Added automatic Warden rematches after reward selection so abilities can be tested without resetting the scene.
- Organized project guidance into a README, roadmap, changelog, and gameplay reference.

### Added

- Boss attack wind-up cues before each pattern.
- Three boss attacks: a repeated aimed fan, a radial burst with a player-facing safe gap, and a rotating spiral stream.
- A denser, faster attack phase below half boss health.
- Basic project documentation with run steps, controls, current scope, and upcoming goals.

## Prototype baseline

- Created the Godot 4 top-down arena, player, boss, projectiles, health HUD, and restart loop.
- Added procedural pixel-style arena details, torchlight, and character visuals.
