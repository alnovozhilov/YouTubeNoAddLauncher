import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
 
ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1000
    height: 640
    title: qsTr("YouTube Launcher")
    color: "gray"

    Connections {
        target: ch

        function onSelectURL(URL) {
            ch.set_channel_url(URL)
            ch.parse_page()
            //ch.thread_parse_page()
            ch.video_parsing()
            youtube_page.updateChannel()
        }
    }

    Component.onCompleted: {
        ch.set_mirror_url("https://invidious.snopyta.org")
        ch.set_channel_url("https://invidious.snopyta.org/channel/UCdKuE7a2QZeHPhDntXVZ91w")
        ch.parse_page()
        ch.video_parsing()
    }

    MainDrawer {
        id: drawer
        width: parent.width / 2
        height: parent.height
        background: Rectangle {
            anchors.fill: parent
            color: "black"
        }
    }

    ChannelPage {
        id: youtube_page
        anchors.fill: parent
    }
}
