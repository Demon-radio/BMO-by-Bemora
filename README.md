# BMO by Bemora — Desktop Pet (Godot 4.3)

Fan-made BMO desktop pet, presented/packaged by **Bemora**.

- Transparent always-on-top buddy that walks, sleeps, laughs, follows your mouse.
- Right-click = menu (`Follow mouse`, `Sing a Song`).
- **Sing a Song = non-repeating jukebox**: shuffles all available songs, never repeats until every song has played once (shuffle-bag in `main.gd`: `song_queue` + `get_next_song()`).
- **Songs are BIG/LOUD**: sing player runs at +6 dB (`SONG_VOLUME_DB`), placeholders generated near 0 dBFS.

## Songs (9 — all big/loud, never repeats)

Kept / restored:
- `assets/Audio/song_egg.mp3` — "BMO why so pregnant"
- `assets/Audio/song_horse.mp3` — cowboy/horse
- `assets/Audio/song_comealong.mp3` — "Come Along With Me" (~1.25 MB)

Popular (placeholders — replace with your licensed copies, see `assets/Audio/README_SONGS.md`):
- `assets/Audio/song_pop_bacon_pancakes.wav` — stands in for "Bacon Pancakes"
- `assets/Audio/song_pop_oh_bmo.wav` — stands in for "Oh BMO"

4 tall large songs (loud ~1.3 MB placeholders):
- `assets/Audio/song_big_01_fresh_potatoes.wav`
- `assets/Audio/song_big_02_island_anthem.wav`
- `assets/Audio/song_big_03_adventure_theme.wav`
- `assets/Audio/song_big_04_bmo_party.wav`

Old/unused songs were removed (backup on the author's Desktop in `BMO-OLD-BACKUP/`).

## Controls

- Left-click BMO: pick up / put down (drag while held)
- Shift+Left-click: pet (hearts)
- Right-click: menu
- `Sing a Song` toggles singing; song auto-advances to the next unplayed song when one finishes.

## Run from source

1. Install Godot 4.3 (GL Compatibility).
2. Open this folder in Godot, open `node_2d.tscn` (main scene), press F5.

## Build the EXE (easy for users)

PowerShell (from this folder):

```powershell
.\tools\export_windows.ps1
```

This exports `Windows Desktop` preset to `../BMO-by-Bemora-Release/BMO-by-Bemora.exe` (outside the repo, next to the project folder) with the `.pck` next to it. Zip that folder and share it — users just unzip and double-click the EXE, no Godot needed.

Need export templates first: Godot Editor → Manage Export Templates → Download, or `godot --headless --export-pack` setup. See `tools/export_windows.ps1`.

## Publish to GitHub

```bash
cd "C:\Users\asd\Downloads\New folder"
git init -b main
git add .
git commit -m "BMO by Bemora: non-repeating loud jukebox, 2 keepers + 2 popular placeholders"
gh auth login
gh repo create BMO-by-Bemora --public --source=. --push
```

## Credits / legal

- BMO / Adventure Time © Cartoon Network / Turner. This is an unofficial fan project, no affiliation.
- Presentation/packaging: Bemora.
- Do not bundle copyrighted songs in a public release without rights — use the placeholders or your own audio.
