# Literature Clock for KDE Plasma

A Plasma 6 widget that tells the time with a quote from literature for every minute of the day. It uses the same quote catalogue and attributions as the web clock and the native screensavers.

- On the desktop it shows the current quote, with the time phrase highlighted. Click it for another quote for the same minute.
- In a panel it shows an icon; click it to open the quote in a popup.
- Settings: quote language (14 languages, or follow the system language), skip quotes marked not safe for work, show or hide author and title, accent-colour highlight, font, and largest font size. The text shrinks to fit the widget.
- If a minute has no quote, the widget shows the plain time.

## Build and install

The quote data is generated from `quotes/` and is not committed. From this folder:

```sh
python3 build_data.py
kpackagetool6 -t Plasma/Applet --install package    # first time
kpackagetool6 -t Plasma/Applet --upgrade package    # after changes
```

Then add **Literature Clock** from *Add Widgets…*. After an upgrade, restart Plasma (`plasmashell --replace &`) or remove and re-add the widget to pick up changes.

To try it in a window without adding it to the desktop:

```sh
plasmawindowed io.github.literatureclock.plasma
```

## Data format

`build_data.py` calls the shared `scripts/native_quote_catalogues.py` builder and writes one QML file per language and hour to `package/contents/data/<locale>/<HH>.qml`. Each holds the quotes for that hour as `[before, time phrase, after, title, author, sfw]` rows. The widget loads them with `Qt.createComponent`, because Plasma does not allow reading local files through `XMLHttpRequest`.

## Licence

The widget code is MIT, like the rest of this repository. The quotes come from the earlier Literature Clock projects and keep their upstream terms; see [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md).
