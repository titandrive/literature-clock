import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: view

    property var quote: null
    property string minuteKey: ""
    signal nextRequested()

    readonly property string fontFamily: Plasmoid.configuration.fontFamily || "serif"
    readonly property color textColor: Kirigami.Theme.textColor
    readonly property color accentColor: Plasmoid.configuration.highlightTime
        ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor

    function escapeHtml(s) {
        return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
            .replace(/\n/g, "<br>");
    }

    readonly property string quoteHtml: quote
        ? escapeHtml(quote[0])
            + "<b><font color=\"" + accentColor + "\">" + escapeHtml(quote[1]) + "</font></b>"
            + escapeHtml(quote[2])
        : ""

    // Shown when no quote exists for this minute (or none pass the SFW filter).
    readonly property string fallbackText: {
        if (!minuteKey) {
            return "";
        }
        const parts = minuteKey.split(":");
        const d = new Date();
        d.setHours(Number(parts[0]), Number(parts[1]));
        return Qt.formatTime(d, Qt.locale().timeFormat(Locale.ShortFormat));
    }

    MouseArea {
        anchors.fill: parent
        onClicked: view.nextRequested()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        Text {
            id: quoteText
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: view.quote ? view.quoteHtml : view.fallbackText
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
            color: view.textColor
            font.family: view.fontFamily
            font.pixelSize: Plasmoid.configuration.maxFontSize
            fontSizeMode: Text.Fit
            minimumPixelSize: 6
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: view.quote ? Text.AlignLeft : Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            visible: view.quote !== null && Plasmoid.configuration.showAttribution
            text: view.quote
                ? "— " + view.escapeHtml(view.quote[4]) + ", <i>" + view.escapeHtml(view.quote[3]) + "</i>"
                : ""
            textFormat: Text.StyledText
            color: view.textColor
            opacity: 0.75
            font.family: view.fontFamily
            font.pixelSize: Math.max(Kirigami.Theme.smallFont.pixelSize,
                                     Math.min(quoteText.fontInfo.pixelSize * 0.7,
                                              Kirigami.Theme.defaultFont.pixelSize * 1.2))
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }
}
