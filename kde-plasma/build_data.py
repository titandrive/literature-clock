#!/usr/bin/env python3
"""Generate the quote data bundled with the KDE Plasma widget.

Uses the shared native catalogue builder so the widget shows the same quotes
and attributions as the macOS and Windows screensavers. Output is one small QML
file per locale and hour (package/contents/data/<locale>/<HH>.qml), which the
widget loads on demand with Qt.createComponent (Plasma does not allow reading
local files through XMLHttpRequest).
"""
import json
import shutil
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(ROOT / 'scripts'))

from native_quote_catalogues import build_native_catalogues  # noqa: E402

OUT = HERE / 'package/contents/data'


def main():
    catalogues = build_native_catalogues(ROOT)
    names = json.loads((ROOT / 'src/strings/common/translations.json').read_text(encoding='utf-8'))
    if OUT.exists():
        shutil.rmtree(OUT)

    locales = []
    for locale, minutes in catalogues.items():
        hours = defaultdict(dict)
        for minute, quotes in minutes.items():
            # Compact rows: [before, time phrase, after, title, author, sfw]
            hours[minute[:2]][minute] = [
                [q['first'], q['time'], q['last'], q['title'], q['author'], 1 if q['sfw'] else 0]
                for q in quotes
            ]
        folder = OUT / locale
        folder.mkdir(parents=True)
        for hour in (f'{h:02d}' for h in range(24)):
            data = json.dumps(hours.get(hour, {}), ensure_ascii=False, separators=(',', ':'))
            data = data.replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')
            (folder / f'{hour}.qml').write_text(
                'import QtQml\nQtObject {\n    readonly property var quotes: (' + data + ')\n}\n',
                encoding='utf-8')
        label = names.get('en-US', {}).get(locale, locale)
        locales.append({'value': locale, 'text': label})
        print(f'{locale}: {sum(map(len, minutes.values()))} quotes, {len(minutes)} minutes')

    (OUT / 'Locales.qml').write_text(
        'import QtQml\nQtObject {\n    readonly property var list: ('
        + json.dumps(locales, ensure_ascii=True) + ')\n}\n', encoding='utf-8')


if __name__ == '__main__':
    main()
