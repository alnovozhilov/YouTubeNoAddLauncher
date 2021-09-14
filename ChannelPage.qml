import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2

Page {

    signal updateChannel

    onUpdateChannel: {
        var list = ch.get_videos_info
        for (var i = 0; i < list["videos_urls"].length; i++)
        {
            videos_model.remove(0)
        }
        videos.model.Component.onCompleted()
        header.source = "recourses/headers/" + ch.get_channel_name + ".jpg"
    }

    ListModel {

            id: videos_model

            Component.onCompleted: {

                var list = ch.get_videos_info


                for (var i = 0; i < list["videos_urls"].length; i++)
                {
                    append({url: list["videos_urls"][i],
                            preview_url: list["videos_preview_urls"][i],
                            title: list["videos_titles"][i],
                            length: list["videos_lengths"][i]})
                }
            }
        }

    header: Image {
        id: header
        sourceSize.width: parent.width
        source: "recourses/headers/Kuplinov ► Play.jpg"
    }

    Component {
        id: video_highlight
        Rectangle {
            z: 1
            width: videos.cellWidth; height: videos.cellHeight
            color: "transparent"; radius: 5
            border.width: 3
            border.color: "lightsteelblue"
            x: videos.currentItem.x
            y: videos.currentItem.y
            Behavior on x { SpringAnimation { spring: 3; damping: 0.2 } }
            Behavior on y { SpringAnimation { spring: 3; damping: 0.2 } }
        }
    }

    RowLayout {

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom:parent.bottom
        anchors.top: parent.top
        //anchors.margins: 5

        Rectangle {
            id: r1
            color: "transparent"
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        GridView {
            id: videos

            cellWidth: 285//300
            cellHeight: 200
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: 855
            Layout.minimumWidth: 855


            highlight: video_highlight
            highlightFollowsCurrentItem: false
            focus: true

            model: videos_model


            delegate: Rectangle {

                color: "transparent"

                width: videos.cellWidth
                height: videos.cellHeight

                MouseArea{

                    anchors.fill: parent

                    Image {
                        id: preview
                        source: preview_url
                        sourceSize.height: parent.height - 40


                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right

                            width: time.contentWidth
                            height: 30

                            color: "#800000FF"

                            Text {
                                id: time
                                anchors.fill: parent
                                color: "white"
                                font.pixelSize: 20
                                text: length
                            }
                        }
                    }

                    Text {
                        anchors.top: preview.bottom
                        text: title
                        width:parent.width
                        height:40

                        wrapMode : Text.WordWrap
                    }

                    onClicked: {
                        videos.currentIndex = videos.indexAt(parent.x,parent.y)
                        ch.execVideo(url)
                    }
                }
            }
        }

        Rectangle {
            id:r2
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "transparent"
        }
    }
}