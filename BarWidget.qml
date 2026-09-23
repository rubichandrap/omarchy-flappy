import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "rubichandrap.flappy"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    tooltipText: "Flappy"
    horizontalMargin: 7.5
    onPressed: function(pressedButton) {
      if (!root.bar) return
      if (pressedButton === Qt.RightButton) return
      root.bar.run("omarchy-shell shell toggle rubichandrap.flappy '{}'")
    }
  }
}
