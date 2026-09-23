import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false

  readonly property int phaseReady: 0
  readonly property int phasePlaying: 1
  readonly property int phaseDead: 2

  property int phase: phaseReady
  property real birdY: 0
  property real birdV: 0
  property real elapsed: 0
  property int score: 0
  property int best: 0
  property bool isNewBest: false

  readonly property real gameW: 420
  readonly property real gameH: 640
  readonly property real groundH: 28
  readonly property real birdX: 96
  readonly property real birdR: 14
  readonly property real gravity: 1450
  readonly property real flapV: -430
  readonly property real pipeSpeed: 155
  readonly property real pipeW: 72
  readonly property real pipeGap: 168
  readonly property real pipeSpacing: 230
  readonly property real dt: 0.016

  readonly property color background: Color.menu.background
  readonly property color foreground: Color.menu.text
  readonly property color border: Color.menu.border
  readonly property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  readonly property color scrim: Color.menu.scrim
  readonly property color accent: Color.accent
  readonly property color urgent: Color.urgent
  readonly property int cornerRadius: Style.cornerRadius
  readonly property string fontFamily: Style.font.menuFamily

  ListModel { id: pipeModel }

  FileView {
    id: bestFile
    path: Quickshell.env("HOME") + "/.local/state/omarchy/flappy-best.json"
    onLoaded: {
      try {
        var data = JSON.parse(text())
        root.best = Number(data.best) || 0
      } catch (e) {}
    }
  }

  function saveBest() {
    bestFile.setText(JSON.stringify({ best: root.best }) + "\n")
  }

  function open() {
    root.opened = true
    root.resetGame()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
    root.phase = root.phaseReady
  }

  function dismiss() {
    root.close()
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "rubichandrap.flappy")
  }

  function resetGame() {
    root.phase = root.phaseReady
    root.score = 0
    root.isNewBest = false
    root.birdY = root.gameH * 0.4
    root.birdV = 0
    root.elapsed = 0
    pipeModel.clear()
  }

  function flap() {
    if (root.phase === root.phaseDead) root.resetGame()
    if (root.phase === root.phaseReady) root.phase = root.phasePlaying
    if (root.phase === root.phasePlaying) root.birdV = root.flapV
  }

  function die() {
    if (root.phase !== root.phasePlaying) return
    root.phase = root.phaseDead
    root.birdV = 0
    if (root.score > root.best) {
      root.best = root.score
      root.isNewBest = true
      root.saveBest()
    } else {
      root.isNewBest = false
    }
  }

  function spawnPipe() {
    var margin = 48
    var minY = margin + root.pipeGap / 2
    var maxY = root.gameH - root.groundH - margin - root.pipeGap / 2
    var gapY = minY + Math.random() * Math.max(1, maxY - minY)
    pipeModel.append({ x: root.gameW + 8, gapY: gapY, scored: false })
  }

  function circleHitsRect(cx, cy, r, rx, ry, rw, rh) {
    var nx = Math.max(rx, Math.min(cx, rx + rw))
    var ny = Math.max(ry, Math.min(cy, ry + rh))
    var dx = cx - nx
    var dy = cy - ny
    return dx * dx + dy * dy < r * r
  }

  function birdHitsPipe(px, gapY) {
    var topH = gapY - root.pipeGap / 2
    var botY = gapY + root.pipeGap / 2
    var botH = root.gameH - root.groundH - botY
    return circleHitsRect(root.birdX, root.birdY, root.birdR, px, 0, root.pipeW, topH)
      || circleHitsRect(root.birdX, root.birdY, root.birdR, px, botY, root.pipeW, Math.max(0, botH))
  }

  function tick() {
    root.elapsed += root.dt
    root.birdV += root.gravity * root.dt
    root.birdY += root.birdV * root.dt

    var lastX = pipeModel.count > 0 ? pipeModel.get(pipeModel.count - 1).x : -9999
    if (pipeModel.count === 0 || lastX <= root.gameW - root.pipeSpacing)
      root.spawnPipe()

    var floorY = root.gameH - root.groundH
    for (var i = pipeModel.count - 1; i >= 0; i--) {
      var pipe = pipeModel.get(i)
      var nx = pipe.x - root.pipeSpeed * root.dt
      if (nx + root.pipeW < -4) {
        pipeModel.remove(i)
        continue
      }
      pipeModel.setProperty(i, "x", nx)
      if (!pipe.scored && nx + root.pipeW < root.birdX - root.birdR) {
        pipeModel.setProperty(i, "scored", true)
        root.score += 1
      }
      if (root.birdHitsPipe(nx, pipe.gapY)) {
        root.die()
        return
      }
    }

    if (root.birdY - root.birdR < 0 || root.birdY + root.birdR > floorY)
      root.die()
  }

  Timer {
    id: frameTimer
    interval: 16
    repeat: true
    running: root.opened
    onTriggered: {
      if (root.phase === root.phaseReady) {
        root.elapsed += root.dt
        root.birdY = root.gameH * 0.4 + Math.sin(root.elapsed * 3.2) * 9
      } else if (root.phase === root.phasePlaying) {
        root.tick()
      }
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-flappy"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    Item {
      id: keyCatcher
      anchors.fill: parent
      focus: root.opened

      Keys.priority: Keys.BeforeItem
      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
          root.dismiss()
          event.accepted = true
        } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Up || event.key === Qt.Key_W) {
          root.flap()
          event.accepted = true
        } else if (event.key === Qt.Key_R) {
          root.resetGame()
          event.accepted = true
        }
      }
    }

    BorderSurface {
      id: card
      width: root.gameW + 32
      height: root.gameH + 72
      anchors.centerIn: parent
      radius: root.cornerRadius
      color: root.background
      borderSpec: root.borderSpec
      padding: 16

      MouseArea {
        anchors.fill: parent
        onClicked: {}
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset + 8
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: 10

        Item {
          width: parent.width
          height: Style.font.heading

          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "FLAPPY"
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            font.bold: true
          }

          Text {
            id: bestLabel
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: "BEST " + root.best
            color: root.foreground
            opacity: 0.55
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
          }
        }

        Item {
          id: board
          width: root.gameW
          height: root.gameH
          anchors.horizontalCenter: parent.horizontalCenter
          clip: true

          Rectangle {
            anchors.fill: parent
            radius: root.cornerRadius
            color: Color.background

            Gradient {
              GradientStop { position: 0.0; color: Qt.darker(Color.background, 1.25) }
              GradientStop { position: 1.0; color: Color.background }
            }
          }

          Repeater {
            model: pipeModel

            delegate: Item {
              id: pipeItem
              property real pipeX: model.x
              property real gapY: model.gapY

              x: pipeX
              width: root.pipeW
              height: root.gameH - root.groundH

              Rectangle {
                width: root.pipeW
                height: Math.max(0, pipeItem.gapY - root.pipeGap / 2)
                color: root.accent
                opacity: 0.92

                Rectangle {
                  width: root.pipeW + 10
                  height: 22
                  anchors.bottom: parent.bottom
                  anchors.horizontalCenter: parent.horizontalCenter
                  color: root.accent
                  radius: 3
                }
              }

              Rectangle {
                y: pipeItem.gapY + root.pipeGap / 2
                width: root.pipeW
                height: Math.max(0, pipeItem.height - y)
                color: root.accent
                opacity: 0.92

                Rectangle {
                  width: root.pipeW + 10
                  height: 22
                  anchors.top: parent.top
                  anchors.horizontalCenter: parent.horizontalCenter
                  color: root.accent
                  radius: 3
                }
              }
            }
          }

          Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: root.groundH
            color: root.urgent
            opacity: 0.85
          }

          Item {
            id: bird
            x: root.birdX - root.birdR
            y: root.birdY - root.birdR
            width: root.birdR * 2
            height: root.birdR * 2
            rotation: Math.max(-28, Math.min(72, root.birdV / 9))

            Rectangle {
              anchors.fill: parent
              radius: width / 2
              color: root.accent
            }

            Rectangle {
              width: 8
              height: 6
              radius: 2
              x: parent.width - 7
              y: 7
              color: root.urgent
            }

            Rectangle {
              width: 7
              height: 7
              radius: 4
              x: parent.width - 12
              y: 5
              color: root.background
            }

            Rectangle {
              width: 7
              height: 3
              radius: 1
              x: parent.width - 10
              y: 6
              color: Color.foreground
            }
          }

          Column {
            anchors.centerIn: parent
            spacing: 10
            visible: root.phase !== root.phasePlaying

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: root.phase === root.phaseReady ? String(root.score) : String(root.score)
              visible: root.phase === root.phaseDead
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.displayLarge
              font.bold: true
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: root.phase === root.phaseReady ? "Space / click to fly" : "Game over"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: root.phase === root.phaseReady ? Style.font.title : Style.font.heading
              font.bold: root.phase === root.phaseDead
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: root.phase === root.phaseReady
                ? (root.best > 0 ? "Best " + root.best : "Thread the pipes")
                : (root.isNewBest ? "New best!" : "Space / click to retry · Esc to quit")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
            }
          }

          Text {
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.phase === root.phasePlaying
            text: String(root.score)
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.displayLarge
            font.bold: true
          }

          MouseArea {
            anchors.fill: parent
            onPressed: root.flap()
          }
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Space / click flap · R restart · Esc close"
          color: root.foreground
          opacity: 0.55
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }
      }
    }
  }
}
