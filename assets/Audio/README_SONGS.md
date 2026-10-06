# SONGS — what is included and how to add the popular hits

## Included right now (9 songs, all BIG/LOUD)

Keepers (your old songs):
- `song_egg.mp3` — "BMO why so pregnant" (kept, ~733 KB)
- `song_horse.mp3` — cowboy / horse song (kept, ~887 KB)
- `song_comealong.mp3` — "Come Along With Me" (restored, ~1.25 MB)

Most-popular placeholders (loud, ~705 KB each):
- `song_pop_bacon_pancakes.wav` — PLACEHOLDER for "Bacon Pancakes"
- `song_pop_oh_bmo.wav` — PLACEHOLDER for "Oh BMO"

4 TALL LARGE songs (loud, ~1.3 MB / ~15 s each):
- `song_big_01_fresh_potatoes.wav` — PLACEHOLDER (Fresh Potatoes slot)
- `song_big_02_island_anthem.wav` — PLACEHOLDER (Island Anthem slot)
- `song_big_03_adventure_theme.wav` — PLACEHOLDER (Adventure Theme slot)
- `song_big_04_bmo_party.wav` — PLACEHOLDER (BMO Party slot)

The Sing player runs at +6 dB (`SONG_VOLUME_DB` in `main.gd`) so all songs sound big.
No-repeat shuffle: every song plays once before any repeats (`song_queue` in `main.gd`).

## How to use your real licensed copies

`main.gd` looks for (in order):
1. `res://assets/Audio/song_egg.mp3`
2. `res://assets/Audio/song_horse.mp3`
3. `res://assets/Audio/song_pop_bacon_pancakes.wav`
4. `res://assets/Audio/song_pop_oh_bmo.wav`

To use official audio you own:
- Export/convert them to `.wav` 16-bit PCM or `.mp3`, then either:
  - (a) overwrite the two `song_pop_*.wav` files (keep the same filenames, delete the `.import` next to them and let Godot re-import), or
  - (b) drop them as `song_bacon_pancakes.mp3` / `song_oh_bmo.mp3` and add those two paths to the `songs` array in `main.gd`.

Missing files are skipped automatically (`ResourceLoader.exists`), so the pet never crashes if a file is absent.

> Copyright: BMO / Adventure Time audio belongs to its owners (Cartoon Network etc.).
> Do not redistribute copyrighted songs without permission. These placeholders exist so you can publish the app immediately and swap in licensed audio locally.
