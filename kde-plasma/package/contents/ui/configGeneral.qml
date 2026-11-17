import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as QtDialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property string cfg_locale
    property string cfg_localeDefault
    property bool cfg_sfwOnly
    property bool cfg_sfwOnlyDefault
    property bool cfg_showAttribution
    property bool cfg_showAttributionDefault
    property bool cfg_highlightTime
    property bool cfg_highlightTimeDefault
    property string cfg_fontFamily
    property string cfg_fontFamilyDefault
    property int cfg_maxFontSize
    property int cfg_maxFontSizeDefault

    readonly property var localeOptions: {
        const options = [{ value: "", text: i18n("System language") }];
        const component = Qt.createComponent(Qt.resolvedUrl("../data/Locales.qml"));
        if (component.status === Component.Ready) {
            const obj = component.createObject(page);
            for (const entry of obj.list) {
                options.push(entry);
            }
            obj.destroy();
        }
        return options;
    }

    QtDialogs.FontDialog {
        id: fontDialog
        title: i18n("Choose a font")
        onAccepted: page.cfg_fontFamily = selectedFont.family
    }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Quote language:")
            model: page.localeOptions
            textRole: "text"
            valueRole: "value"
            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(page.cfg_locale))
            onActivated: page.cfg_locale = currentValue
        }

        QQC2.CheckBox {
            text: i18n("Skip quotes marked not safe for work")
            checked: page.cfg_sfwOnly
            onToggled: page.cfg_sfwOnly = checked
        }

        QQC2.CheckBox {
            text: i18n("Show author and title")
            checked: page.cfg_showAttribution
            onToggled: page.cfg_showAttribution = checked
        }

        QQC2.CheckBox {
            text: i18n("Colour the time with the accent colour")
            checked: page.cfg_highlightTime
            onToggled: page.cfg_highlightTime = checked
        }

        Item { Kirigami.FormData.isSection: true }

        // A button plus the system font dialog: listing every installed font
        // in a ComboBox makes the page take seconds to open.
        Row {
            Kirigami.FormData.label: i18n("Font:")
            spacing: Kirigami.Units.smallSpacing

            QQC2.Button {
                text: page.cfg_fontFamily || i18n("System font (%1)", Kirigami.Theme.defaultFont.family)
                icon.name: "preferences-desktop-font"
                onClicked: {
                    fontDialog.selectedFont = Qt.font({
                        family: page.cfg_fontFamily || Kirigami.Theme.defaultFont.family,
                        pointSize: Kirigami.Theme.defaultFont.pointSize
                    });
                    fontDialog.open();
                }
            }

            QQC2.Button {
                visible: page.cfg_fontFamily !== ""
                icon.name: "edit-undo"
                text: i18n("Use system font")
                display: QQC2.AbstractButton.IconOnly
                QQC2.ToolTip.text: text
                QQC2.ToolTip.visible: hovered
                onClicked: page.cfg_fontFamily = ""
            }
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Largest font size:")
            from: 8
            to: 200
            value: page.cfg_maxFontSize
            onValueModified: page.cfg_maxFontSize = value
            textFromValue: (v) => i18n("%1 px", v)
        }
    }
}
