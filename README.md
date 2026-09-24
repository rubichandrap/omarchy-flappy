# omarchy-flappy

Flappy Bird minigame for the [Omarchy](https://omarchy.org/) shell.

Bar widget launches a themed overlay: Space / click to flap, R to restart, Esc
to close. High score persists in `~/.local/state/omarchy/flappy-best.json`.

## Install

```sh
cp -r rubichandrap.flappy ~/.config/omarchy/plugins/
omarchy plugin validate ~/.config/omarchy/plugins/rubichandrap.flappy
omarchy plugin enable rubichandrap.flappy
omarchy restart shell
```

Or from git:

```sh
omarchy plugin add git@github.com:rubichandrap/omarchy-flappy.git --enable
omarchy restart shell
```

Open with the 󰊠 bar button, or:

```sh
omarchy-shell shell toggle rubichandrap.flappy '{}'
```

## Controls

| Input | Action |
|-------|--------|
| Space / click | Flap |
| R | Restart |
| Esc | Close |

## Customize

Edit `~/.config/omarchy/plugins/rubichandrap.flappy/Flappy.qml` — colors track
the active Omarchy theme (`Color.accent`, `Color.menu.*`). Saving hot-reloads;
if the overlay misbehaves, `omarchy restart shell`.
