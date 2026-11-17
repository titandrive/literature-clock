import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Current minute as "HH:MM" and the quote chosen for it.
    property string minuteKey: ""
    property var quote: null          // [before, time phrase, after, title, author, sfw]
    property var hourObject: null     // loaded data/<locale>/<HH>.qml
    property string hourKey: ""

    readonly property var availableLocales: {
        const component = Qt.createComponent(Qt.resolvedUrl("../data/Locales.qml"));
        if (component.status !== Component.Ready) {
            console.warn("Literature Clock:", component.errorString());
            return [];
        }
        const obj = component.createObject(root);
        const values = obj.list.map(entry => entry.value);
        obj.destroy();
        return values;
    }

    // Configured language, or the closest match to the system language.
    readonly property string activeLocale: {
        const chosen = Plasmoid.configuration.locale;
        if (chosen && availableLocales.includes(chosen)) {
            return chosen;
        }
        const system = Qt.locale().name.replace("_", "-");
        if (availableLocales.includes(system)) {
            return system;
        }
        const language = system.split("-")[0];
        const preferred = { en: "en-US" };
        if (preferred[language]) {
            return preferred[language];
        }
        const match = availableLocales.find(l => l.split("-")[0] === language);
        return match || "en-US";
    }

    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    readonly property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
        || Plasmoid.formFactor === PlasmaCore.Types.Vertical
    preferredRepresentation: inPanel ? compactRepresentation : fullRepresentation
    toolTipMainText: quote ? quote[4] : ""
    toolTipSubText: quote ? quote[3] : ""

    function pad(n) {
        return n < 10 ? "0" + n : String(n);
    }

    function loadHour(hour) {
        const key = activeLocale + "/" + hour;
        if (key === hourKey) {
            return;
        }
        if (hourObject) {
            hourObject.destroy();
            hourObject = null;
        }
        const component = Qt.createComponent(Qt.resolvedUrl("../data/" + key + ".qml"));
        if (component.status === Component.Ready) {
            hourObject = component.createObject(root);
        } else {
            console.warn("Literature Clock:", component.errorString());
        }
        hourKey = key;
    }

    function pickQuote(force) {
        const now = new Date();
        const hour = pad(now.getHours());
        const key = hour + ":" + pad(now.getMinutes());
        if (key === minuteKey && !force) {
            return;
        }
        loadHour(hour);
        let candidates = (hourObject && hourObject.quotes[key]) || [];
        if (Plasmoid.configuration.sfwOnly) {
            candidates = candidates.filter(q => q[5] === 1);
        }
        if (candidates.length > 1 && quote && key === minuteKey) {
            // Clicking asks for a different quote, not the same one again.
            candidates = candidates.filter(q => q !== quote);
        }
        minuteKey = key;
        quote = candidates.length
            ? candidates[Math.floor(Math.random() * candidates.length)]
            : null;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.pickQuote(false)
    }

    onActiveLocaleChanged: pickQuote(true)
    Connections {
        target: Plasmoid.configuration
        function onSfwOnlyChanged() { root.pickQuote(true); }
    }

    compactRepresentation: MouseArea {
        Layout.minimumWidth: Kirigami.Units.iconSizes.small
        onClicked: root.expanded = !root.expanded

        Kirigami.Icon {
            anchors.fill: parent
            source: Plasmoid.icon
            active: parent.containsMouse
        }
        hoverEnabled: true
    }

    fullRepresentation: QuoteView {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 12
        Layout.minimumHeight: Kirigami.Units.gridUnit * 6
        Layout.preferredWidth: Kirigami.Units.gridUnit * 26
        Layout.preferredHeight: Kirigami.Units.gridUnit * 14

        quote: root.quote
        minuteKey: root.minuteKey
        onNextRequested: root.pickQuote(true)
    }
}
