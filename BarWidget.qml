import QtQuick
import QtQuick.Shapes
import qs.Commons
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
    text: ""
    labelVisible: false
    keepSpace: true
    fixedWidth: 32
    tooltipText: "Flappy"
    horizontalMargin: 6
    onPressed: function(pressedButton) {
      if (!root.bar) return
      if (pressedButton === Qt.RightButton) return
      root.bar.run("omarchy-shell shell toggle rubichandrap.flappy '{}'")
    }
  }

  Item {
    anchors.fill: parent
    enabled: false

    Item {
      width: 22
      height: 14
      anchors.centerIn: parent

      Rectangle {
        width: 6
        height: 5
        x: 0
        y: 5
        radius: 1
        color: Qt.darker(Color.accent, 1.25)
        rotation: 16
      }

      Rectangle {
        id: body
        width: 17
        height: 13
        x: 2
        y: 1
        radius: height / 2
        color: Color.accent
      }

      Rectangle {
        width: 8
        height: 5
        x: body.x + 4
        y: body.y + 5
        radius: height / 2
        color: Qt.darker(Color.accent, 1.3)
        rotation: -12
      }

      Rectangle {
        id: eye
        width: 5
        height: 5
        radius: width / 2
        x: body.x + 11
        y: body.y + 2
        color: "#ffffff"
      }

      Rectangle {
        width: 2
        height: 2
        radius: 1
        x: eye.x + 2.5
        y: eye.y + 2
        color: "#1b1b1b"
      }

      Shape {
        width: 5
        height: 7
        x: body.x + body.width - 2
        y: body.y + 4

        ShapePath {
          fillColor: Color.urgent
          strokeColor: "transparent"
          startX: 0
          startY: 0.5
          PathLine { x: 5; y: 3.5 }
          PathLine { x: 0; y: 6.5 }
          PathLine { x: 0; y: 0.5 }
        }
      }
    }
  }
}
