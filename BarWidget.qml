import QtQuick
import QtQuick.Shapes
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "rubichandrap.flappy"

  readonly property color fg: bar ? bar.barForeground : Color.foreground
  readonly property color cut: bar ? bar.background : Color.bar.background

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    labelVisible: false
    keepSpace: true
    fixedWidth: 26
    tooltipText: "Flappy"
    horizontalMargin: 7.5
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
      id: bird
      width: 16
      height: 12
      anchors.centerIn: parent

      Rectangle {
        width: 5
        height: 4
        x: 0
        y: 5
        radius: 1
        color: root.fg
        rotation: 18
      }

      Rectangle {
        id: body
        width: 13
        height: 10
        x: 2
        y: 1
        radius: height / 2
        color: root.fg
      }

      Rectangle {
        width: 7
        height: 5
        x: body.x + 3
        y: body.y + 4
        radius: 2
        color: root.cut
        rotation: -18
      }

      Rectangle {
        width: 3
        height: 3
        radius: 1.5
        x: body.x + 8
        y: body.y + 3
        color: root.cut
      }

      Shape {
        width: 5
        height: 6
        x: body.x + body.width - 2
        y: body.y + 2.5

        ShapePath {
          fillColor: root.fg
          strokeColor: "transparent"
          startX: 0
          startY: 0
          PathLine { x: 5; y: 3 }
          PathLine { x: 0; y: 6 }
          PathLine { x: 0; y: 0 }
        }
      }
    }
  }
}
