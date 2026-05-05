# My personal dot files repo 

## Prerequisite  
+ stow
+ git  

## Usage
```bash
stow sway # only link Sway/Wayland config
stow fontconfig # only link font fallback config
stow kitty # only link Kitty terminal config
stow i3 # only link legacy i3/X11 config
stow */ # link everything
```

## Font fallback

Firefox needs CJK/emoji fonts after a fresh install:

```bash
yay -S --needed noto-fonts noto-fonts-cjk noto-fonts-emoji
stow fontconfig
fc-cache -fv
```

## Sway monitor profiles

On NVIDIA machines, start Sway with the managed wrapper instead of plain `sway`:

```bash
start-sway
```

The wrapper exports NVIDIA/wlroots variables before launching `sway --unsupported-gpu`.

Sway uses `kanshi` for automatic monitor profiles. The config lives at:

```bash
sway/.config/kanshi/config
```

Use this to check connector names when adding a new monitor/dock:

```bash
swaymsg -t get_outputs
```

## Rofi launcher

The Sway target also manages Rofi for `Super+d` application launching:

```bash
stow --restow sway
swaymsg reload
```

Config files:

```bash
sway/.config/rofi/config.rasi
```

## Audio AUX routing

The Sway target provides a PipeWire/PulseAudio virtual output named `AUX`:

```bash
audio-setup
```

Use `pavucontrol` -> Playback to move an app, such as Spotify or Firefox, to `AUX`. `AUX` is looped back to the current default output so you can still hear it.

Remove it for the current session:

```bash
audio-setup unload
```

### AUX usage guide

The AUX setup is for separating app audio, similar to a simple Voicemeeter AUX bus.

What `audio-setup` creates:

- `AUX`: a virtual output/sink
- `AUX.monitor`: a monitor source for anything playing into AUX
- `AUX to Default Output`: a loopback so AUX audio is still heard on your current default speakers/headphones

Typical workflow:

1. Start your apps, for example Spotify, Firefox, Discord.
2. Open `pavucontrol`.
3. Go to the **Playback** tab.
4. For the app you want separated, choose **AUX** as its output.
5. Keep your normal speakers/headphones as the default output.

Useful commands:

```bash
# Create AUX for this session
audio-setup

# Remove AUX for this session
audio-setup unload

# Show current outputs
pactl list short sinks

# Show PipeWire graph/status
wpctl status
```

Example routing ideas:

- Spotify -> `AUX`
- Firefox -> physical speakers/headphones
- Discord -> physical speakers/headphones

Because AUX is looped back to the default output, putting Spotify on AUX does **not** mute it. It just gives Spotify its own controllable virtual bus that can later be routed, recorded, filtered, or mixed separately.

If you change your physical default output after AUX is created, rerun:

```bash
audio-setup unload
audio-setup
```

This recreates the AUX loopback to the new default output.
