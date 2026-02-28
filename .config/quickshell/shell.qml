import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

ShellRoot {
  property var apps: [
    {name: "Zen Browser", cmd: "zen-browser"}
  ]

  property string searchText: ""
  property int selectedIndex: 0

  function filterApps() {
    if (searchText === "") return apps;
    return apps.filter(app => app.name.toLowerCase().includes(searchText.toLowerCase()));
  }

  function launchApp(cmd) {
    Hyprland.dispatch("exec " + cmd)
  }

  GlobalShortcut {
    name: "launcher"
    onPressed: launcher.toggle()
  }

  PanelWindow {
    id: topBar

    anchors {
      top: true
      left: true
      right: true
    }

    implicitHeight: 32
    color: "#1e1e2e"

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.rightMargin: 12

      Repeater {
        model: 10

        delegate: Rectangle {
          Layout.preferredWidth: 32
          Layout.preferredHeight: 24
          radius: 4

          property int wsId: index + 1
          property var ws: Hyprland.workspaces.values.find(w => w.id === wsId)

          color: ws && ws.focused ? "#89b4fa" : (ws && ws.urgent ? "#f38ba8" : "transparent")

          Text {
            anchors.centerIn: parent
            text: wsId
            color: ws && ws.focused ? "#1e1e2e" : "#cdd6f4"
            font.pointSize: 12
            font.bold: ws && ws.focused ? true : false
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Hyprland.dispatch(`workspace ${wsId}`)
          }
        }
      }

      Item {
        Layout.fillWidth: true
      }
    }
  }

  FloatingWindow {
    id: launcher

    implicitWidth: 500
    implicitHeight: 60 + Math.min(filterApps().length * 50, 300)

    visible: false

    onVisibleChanged: {
      if (visible) {
        var screen = Quickshell.screens[0]
        x = screen.width / 2 - implicitWidth / 2
        y = screen.height / 2 - implicitHeight / 2

        searchInput.forceActiveFocus()
        searchInput.text = ""
        searchText = ""
        selectedIndex = 0
      }
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12

      Rectangle {
        Layout.preferredHeight: 36
        Layout.fillWidth: true
        radius: 6
        color: "#313244"

        TextInput {
          id: searchInput
          focus: true
          anchors.fill: parent
          anchors.leftMargin: 10
          color: "#cdd6f4"
          font.pointSize: 13
          verticalAlignment: Text.AlignVCenter

          onTextChanged: {
            searchText = text
            selectedIndex = 0
          }

          Keys.onPressed: (event) => {
            var filtered = filterApps()
            if (event.key === Qt.Key_Down) {
              selectedIndex = Math.min(selectedIndex + 1, filtered.length - 1)
              event.accepted = true
            } else if (event.key === Qt.Key_Up) {
              selectedIndex = Math.max(selectedIndex - 1, 0)
              event.accepted = true
            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
              if (filtered.length > 0) {
                launchApp(filtered[selectedIndex].cmd)
                launcher.visible = false
                searchText = ""
                searchInput.text = ""
              }
              event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
              launcher.visible = false
              searchText = ""
              searchInput.text = ""
              event.accepted = true
            }
          }
        }
      }

      ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: filterApps()
        currentIndex: selectedIndex
        clip: true

        delegate: Rectangle {
          width: parent.width
          height: 40
          radius: 6
          color: index === selectedIndex ? "#45475a" : "transparent"

          Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: modelData.name
            color: "#cdd6f4"
            font.pointSize: 13
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              launchApp(modelData.cmd)
              launcher.visible = false
              searchText = ""
              searchInput.text = ""
            }
          }
        }

        highlightFollowsCurrentItem: true
      }
    }

    function toggle() {
      visible = !visible
    }
  }
}
