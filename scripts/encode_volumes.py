"""Regenerate 25/50/75% MP3 variants from the original sounds/*.mp3 files."""
import argparse
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--ffmpeg", default="ffmpeg", help="Path to FFmpeg executable")
args = parser.parse_args()
sounds = Path(__file__).resolve().parents[1] / "sounds"
sources = sorted(sounds.glob("*.mp3"))
if not sources:
    raise SystemExit("No source MP3s found")
for volume in (25, 50, 75):
    destination = sounds / str(volume)
    destination.mkdir(exist_ok=True)
    for source in sources:
        subprocess.run([
            args.ffmpeg, "-hide_banner", "-loglevel", "error", "-nostdin", "-y",
            "-i", str(source), "-map", "0:a:0", "-vn", "-map_metadata", "-1",
            "-af", f"volume={volume / 100}", "-c:a", "libmp3lame", "-q:a", "2",
            str(destination / source.name),
        ], check=True)
print(f"Encoded {len(sources) * 3} variants. Originals supply 100%; 0% skips playback.")
