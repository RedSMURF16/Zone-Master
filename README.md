<h1 align="center">Zone Master</h1>

<p align="center">
  <a href="https://www.youtube.com/watch?v=LOLtGZad7hU"><img src="https://img.youtube.com/vi/LOLtGZad7hU/maxresdefault.jpg" alt="Watch on YouTube" width="600"></a>
</p>

## 📝 Description
This plugin adds a fully dynamic, multi-class zone system to Counter-Strike 1.6.
Zones can be placed, managed and configured during gameplay with full runtime control over team access, activation chance, timing, and per-class behavior.
Custom setups are saved per map and automatically loaded on every map start.
- Create and remove zones during gameplay via an in-game menu
- 14 distinct zone classes, each with its own model and dedicated effect: Ammo, Bomb, Clock, Health, Lightning, Mask, Mask2, Shield, Skull, Skull2, Stun, Stun2, Up, and Wings
- Configurable per zone: flags, team access, icon animation (Idle, Spin, Float, Spin-Float), activation chance, activation delay, duration and cooldown
- Ammo zones resupply clip and backpack ammo on a configurable frequency, in relative or absolute amounts
- Bomb zones resupply HE, Flashbang and Smoke grenades with individual per-type limits and optional overflow
- Clock zones alter weapon reload, attack, deploy speed and recoil while inside
- Health and Shield zones restore health or armor over time, each with configurable limits and overflow
- Lightning zones alter player speed, Mask zones control transparency and footstep noise, Mask2 swaps between up to four models via flags
- Skull and Skull2 zones deal periodic damage, with Skull also draining life from nearby targets
- Stun zones apply screen shake and color flash with adjustable FOV, Stun2 delivers timed slaps that can optionally kill
- Up zones apply upward velocity and gravity multipliers, Wings zones grant noclip and/or godmode while inside
- Independent axis scaling with size constraints for precise zone resizing
- Noclip and intuitive ghost preview tracking for natural alignment with grounds and walls

## 💬 Commands
- `say /zm` - Opens the Zone Master menu.
- `say_team /zm` - Opens the Zone Master menu.
- `say /zonemaster` - Opens the Zone Master menu.
- `say_team /zonemaster` - Opens the Zone Master menu.
- `zm_reload` - Reloads the configuration file.
- `zonemaster_reload` - Reloads the configuration file.

## ⚙️ Configuration
```ini
# [Main Settings]
# SETTING_DEFAULT_FLAGS           = Default flags (a - Icon, b - Active Delay, c - Active Duration)
# SETTING_DEFAULT_TEAM            = Default team (0 - Disabled, 1 - Terrorist Only, 2 - CT Only, 3 - Both Teams)
# SETTING_DEFAULT_ANIM            = Default icon animation (0 - Idle, 1 - Spin, 2 - Float, 3 - Spin-Float)
# SETTING_DEFAULT_ACTIVE_CHANCE   = Default chance the zone is active when checked (0.0 - 1.0)
# SETTING_DEFAULT_ACTIVE_DELAY    = Default delay before the zone activates (min - max)
# SETTING_DEFAULT_ACTIVE_DURATION = Default duration the zone stays active (min - max)
# SETTING_DEFAULT_ACTIVE_COOLDOWN = Default cooldown before the zone can reactivate (min - max)
# SETTING_DEFAULT_ICON            = Default path of the zone's icon model
# SETTING_DEFAULT_ICON_SCALE      = Default scale of the floating icon model
# SETTING_DEFAULT_ICON_ALPHA      = Default alpha of the floating icon model (0 - 255)
# SETTING_DEFAULT_CLASS           = Default class (0 - Ammo, 1 - Bomb, 2 - Clock, 3 - Health, 4 - Lightning, 5 - Mask, 6 - Mask2, 7 - Shield, 8 - Skull, 9 - Skull2, 10 - Stun, 11 - Stun2, 12 - Up, 13 - Wings)
# Per-class settings (defined under each [Zone Name] section, depending on MASTER_CLASS):
# AMMO_*       = Clip/backpack ammo refill frequency, amount, mode and overflow
# BOMB_*       = HE/Flashbang/Smoke grenade resupply frequency, amounts, limits and overflow
# CLOCK_*      = Reload, attack, deploy speed and recoil multipliers while inside
# HEALTH_*     = Healing frequency, rate, limit and overflow
# LIGHTNING_*  = Player speed multiplier while inside
# MASK_*       = Player alpha and footstep silencing while inside
# MASK2_*      = Model flag combination (a/b/c/d) used to pick the displayed model
# SHIELD_*     = Armor resupply frequency, amount, limit, overflow, type, absorb and reflect fractions
# SKULL_*      = Periodic damage and life-steal fraction
# SKULL2_*     = Periodic damage frequency, amount, damage type, limit and overflow
# STUN_*       = Screen shake/flash frequency, amplitude, frequency, color range and FOV
# STUN2_*      = Slap frequency, damage, direction (0 - Forward, 1 - Random) and kill toggle
# UP_*         = Upward push and gravity multiplier while inside
# WINGS_*      = Noclip and/or godmode toggle while inside
# MASTER_FLAGS  = a - Icon, b - Active Delay, c - Active Duration
# MASTER_TEAM   = 0 - Disabled, 1 - Terrorist Only, 2 - CT Only, 3 - Both Teams
# MASTER_ANIM   = 0 - Idle, 1 - Spin, 2 - Float, 3 - Spin-Float
# MASTER_CLASS  = 0 - Ammo, 1 - Bomb, 2 - Clock, 3 - Health, 4 - Lightning, 5 - Mask, 6 - Mask2, 7 - Shield, 8 - Skull, 9 - Skull2, 10 - Stun, 11 - Stun2, 12 - Up, 13 - Wings
```

## 🔄 Changelog
```text
* v1.0: Initial release.
```

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20video-FF0000?logo=youtube&logoColor=white)](https://www.youtube.com/watch?v=LOLtGZad7hU)
