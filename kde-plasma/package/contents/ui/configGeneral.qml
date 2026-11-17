import QtQuick
import QtQuick.Controls as QQC2
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

    readonly property var fontOptions: [i18n("Default serif")].concat(Qt.fontFamilies())

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

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Font:")
            model: page.fontOptions
            Component.onCompleted: {
                const i = page.cfg_fontFamily ? find(page.cfg_fontFamily) : 0;
                currentIndex = i >= 0 ? i : 0;
            }
            onActivated: page.cfg_fontFamily = currentIndex === 0 ? "" : currentText
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
