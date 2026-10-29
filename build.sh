#!/usr/bin/env bash
# Збирає сайт у папку site/: гра + 3D-моделі.
# Корови: з публічного репо Vladimir-VF/nestado (зафіксований коміт).
# Природа: Quaternius Stylized Nature MegaKit, ліцензія CC0 (opengameart.org).
set -euo pipefail
COWS_SHA=89652d3a871b86b7257a2c9279d1d8d9ca020a84
KIT_URL=https://opengameart.org/sites/default/files/stylized_nature_megakitstandard.zip
GT="npx --yes @gltf-transform/cli@4.1.1"
rm -rf site work && mkdir -p site/assets work
cp index.html README.md site/
touch site/.nojekyll
for c in pryima sonia vilna; do
  curl -fsSL -o "site/assets/cow_$c.glb" "https://raw.githubusercontent.com/Vladimir-VF/nestado/$COWS_SHA/$c.glb"
done
curl -fsSL -o work/kit.zip "$KIT_URL"
unzip -q work/kit.zip 'glTF/*' -d work
NAMES="CommonTree_1 CommonTree_2 CommonTree_3 Pine_1 TwistedTree_1 Bush_Common Bush_Common_Flowers Flower_3_Group Flower_4_Group Clover_1 Clover_2 Grass_Common_Short Grass_Wispy_Short Mushroom_Common Rock_Medium_1 Rock_Medium_2 Pebble_Round_1 Fern_1 Plant_1 RockPath_Round_Small_1"
python3 - "$NAMES" <<'PY'
import json,sys
for n in sys.argv[1].split():
    p=f'work/glTF/{n}.gltf';d=json.load(open(p))
    for m in d['materials']: m.pop('normalTexture',None)
    json.dump(d,open(p,'w'))
PY
for n in $NAMES; do
  size=512; case $n in Grass*|Clover*|Pebble*) size=256;; esac
  $GT optimize "work/glTF/$n.gltf" "site/assets/$n.glb" --compress quantize --texture-compress webp --texture-size $size --simplify false --join false --instance false >/dev/null
done
ls -la site/assets
du -sh site
