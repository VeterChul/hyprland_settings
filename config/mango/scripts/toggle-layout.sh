#!/usr/bin/env bash
# Переключает макет активного тега: scroller <-> макет по умолчанию.
#
# По умолчанию берём то, что задано в tag.conf:
#   тег 1        scroller (поэтому альтернатива для него — grid)
#   теги 2, 9    fair
#   теги 3-8, 10 grid
#
# Скрипт не хранит состояние: каждый раз смотрит текущий макет через mmsg
# и выбирает противоположный. Поэтому его можно дёргать сколько угодно раз.

set -u

json=$(mmsg get all-tags) || exit 1

tag=$(jq -r '[.all_tags[].tags[] | select(.is_active)][0].index' <<<"$json")
cur=$(jq -r '[.all_tags[].tags[] | select(.is_active)][0].layout' <<<"$json")

if [ -z "$tag" ] || [ "$tag" = "null" ]; then
  exit 1
fi

if [ "$cur" = "S" ]; then
  case "$tag" in
    2|9) target=fair ;;
    *)   target=grid ;;
  esac
else
  target=scroller
fi

mmsg dispatch setlayout,"$target" >/dev/null || exit 1
