#!/usr/bin/env bash

set -eu

# dst=$(basename "$0" .sh).epub
dst=.

doc_title="$(head -n1 readme.md | sed 's/^#\s*//')"

if false; then
  scan_resolution=600
else
  source 030-measure-page-size.txt
fi

if [ "$dst" != "." ] && [ -e "$dst" ]; then
  echo "error: output exists: $dst"
  exit 1
fi

# downscale to 300 dpi
scale=$(python -c "print(300 / $scan_resolution)")

args=(
  hocr-to-epub-fxl
  --output "$dst"
)
if [ "$dst" = "." ]; then
  args+=(
    --output-unpacked
  )
fi
args+=(
  --scale "$scale"
  --image-format avif
  --text-format html
  # --doc-title "$doc_title"
  --doc-title "Tödliches Vermächtnis"
  --doc-subtitle "Wie das Unkrautvernichtungsmittel Glyphosat unsere Gesundheit und Umwelt zerstört"
  --doc-description "Kein anderes Herbizid hat die landwirtschaftliche Massenproduktion so beeinflusst wie Glyphosat.
Dabei wurden schädliche Auswirkungen auf Mensch und Natur jahrzehntelang ignoriert, verleugnet, vertuscht,
kritische Wissenschaftler und Journalisten zum Schweigen gebracht.
Kein Wunder, wird der weltweite Markt doch auf ein Volumen von etwa zehn Milliarden US-Dollar geschätzt
und werden jährlich mindestens eine Million Tonnen des Unkrautvernichters versprüht.

Nun liefert die ehemalige leitende Wissenschaftlerin des Massachusetts Institute of Technology (MIT) Dr. Stephanie Seneff
unumstößliche Beweise für die verheerenden gesundheitlichen und ökologischen Wirkungen der Substanz und belegt,
dass Glyphosat als wesentliche Ursache für die Entstehung von Zivilisationskrankheiten
wie Autismus, Parkinson, Alzheimer, Autoimmun-Erkrankungen und Krebs anzusehen ist,
wobei sich die schädigende Wirkung im Zusammenspiel mit anderen Giftstoffen noch verstärkt."
  --doc-subject "Kriminalität in Wirtschaft & Politik, Mafia & Organisiertes Verbrechen, Erziehung"
  --doc-modified "$(git show -s --format=%cI HEAD)"
  --doc-date 2025-10-20
  --doc-edition 1
  --doc-extent "372 pages"
  --doc-author "Stephanie Seneff"
  --doc-introducer "Jens Wernicke"
  --doc-contributor "Wolfgang Wodarg"
  --doc-translator "Hans-Michael Hackenberg"
  --doc-publisher "Rubikon-Verlag"
  --doc-language de
  --doc-isbn 9783952595480
  --doc-cover-image 070-deskew/373.tiff
  --canonical-url-base https://milahu.github.io/toedliches-vermaechtnis-glyphosat-stephanie-seneff-2025/
)
todo_args+=(
  --doc-title ""
  --doc-subtitle ""
  --doc-description ""
  --doc-subject ""
  --doc-modified "$(git show -s --format=%cI HEAD)"
  --doc-date 2025
  --doc-edition 1
  --doc-extent "123 pages"
  --doc-author ""
  --doc-introducer ""
  --doc-contributor ""
  --doc-translator ""
  --doc-publisher ""
  --doc-language de
  --doc-isbn 0000000000000
  --doc-cover-image 070-deskew/999.tiff
  --canonical-url-base https://milahu.github.io/todo/
)

 printf '>'
for a in "${args[@]}" "$@"; do printf ' %q' "$a"; done
echo ' *-ocr/*.hocr'

"${args[@]}" "$@" *-ocr/*.hocr

if [ "$dst" = "." ]; then
  echo "done ./index.xhtml"
  exit
fi

echo "done $dst"

rm -rf $dst.unzip
mkdir $dst.unzip
cd $dst.unzip
unzip -q ../$dst
cd ..

echo "done $dst.unzip/index.html"
