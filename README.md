# Combine Sentry Gun – GMod Addon

A faction-aware sentry gun for Garry's Mod.  
Based on [laser-follower-sentry-model](https://github.com/NachinBombin/laser-follower-sentry-model) by Intel/NachinBombin.

## Behavior

| Target | Attacked? |
|---|---|
| Player | ✅ Always |
| Rebel NPCs (`npc_rebel_*`, citizens, etc.) | ✅ Yes |
| Combine NPCs (see list below) | ❌ Never |
| Props / world objects | ❌ Ignored |

### Combine-friendly classes (never attacked)
`npc_combine_s`, `npc_combine_prison_guard`, `npc_metropolice`,
`npc_manhack`, `npc_helicopter`, `npc_combinegunship`, `npc_strider`,
`npc_rollermine`, `npc_cscanner`, `npc_clawscanner`,
`npc_turret_floor`, `npc_turret_ceiling`, `npc_turret_ground`, `combine_mine`

## What changed vs. nsentry

- `CanEngage` uses a hard-coded `COMBINE_FRIENDLY` table instead of a whitelist
- No owner, no E-key toggle, no VGUI whitelist menu
- Spawns directly in `STATE_WATCHING` (active immediately)
- No net messages – zero networking overhead

## Installation

1. Drop `combine_sentry/` into `garrysmod/addons/`
2. The model `models/codbo6/other/sentry.mdl` must be present (same requirement as nsentry)
3. Find the entity under **Combine** in the spawn menu

## Requirements

- Garry's Mod
- The CoD BO6 Sentry model (or replace `CONFIG.MODEL` in `init.lua`)
