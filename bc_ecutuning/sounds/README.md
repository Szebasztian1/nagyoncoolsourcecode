# Sounds

Synthesized variant sounds ship here — swap any for a real recorded clip anytime.
Files referenced by `Config.Sound`:

- Pop & Bang: `pop_deep.wav`, `pop_v8.wav`, `pop_turbo.wav`, `pop_burble.wav`, `pop_sport.wav`, `pop_race.wav`
- Flamethrower: `flame_deep.wav`, `flame_roar.wav`, `flame_jet.wav`, `flame_burst.wav`

Formats CEF/xSound can play: **.wav**, **.ogg**, **.mp3**, **.webm**. Keep them
short so overlapping pops stay crisp. To add or replace a variant, drop the file
here and edit the matching entry in `Config.Sound.pop.variants` /
`Config.Sound.flame.variants`.

## Requirements

Sound is played through **xSound** (3D, heard by nearby players). Install the
free `xsound` resource and `ensure` it before `rota_ecutuning`. Without it the
effects still work, just silently.

## Where to get audio

Any free backfire/pops pack (e.g. the open-source Tuner Exhaust release), or your
own clips. You can also skip local files entirely and point the config fields at a
full URL:

```lua
Config.Sound.popFile = 'https://your-cdn.com/pop.ogg'
```

Resource-relative paths (the default) are served to xSound over
`https://cfx-nui-rota_ecutuning/sounds/<file>` — that is why `sounds/**` is listed
in `fxmanifest.lua` `files{}`.
