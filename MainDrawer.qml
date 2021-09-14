import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2

Drawer {

    Component {
        id: highlight
        Rectangle {
            z: 1
            width: channels_grid.cellWidth; height: channels_grid.cellHeight
            color: "transparent"; radius: 5
            border.width: 3
            border.color: "lightsteelblue"
            x: channels_grid.currentItem.x
            y: channels_grid.currentItem.y
            Behavior on x { SpringAnimation { spring: 3; damping: 0.2 } }
            Behavior on y { SpringAnimation { spring: 3; damping: 0.2 } }
        }
    }

    TextField {
        id: channel_field

        anchors.top: parent.top
        anchors.left: parent.left
    
        width: parent.width * 0.9
        placeholderText: qsTr("Enter channel URL")
    
    }

    function update_channels() {
        var count = channels_model.count
        for (var i = 0; i < count; i++)
        {
            channels_model.remove(0)   
        } 
        channels_grid.model.Component.onCompleted()
    }

    Rectangle {
        id: add_button
        anchors.left: channel_field.right
        anchors.right: parent.right
        color:"blue"
        width: parent.width * 0.1
        height: 40
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.debug("OK")

                ch.insert_channel(channel_field.text)

                console.debug("OK")
                drawer.update_channels()
            }
        }
    }


    GridView {
        id: channels_grid
        anchors.top: channel_field.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 5

        cellWidth: parent.width - anchors.margins*2
        cellHeight: 50

        highlight: highlight
        highlightFollowsCurrentItem: false
        focus: true

        model: ListModel {
            id: channels_model
            Component.onCompleted: {
                var channels_list = ch.select_all_channels
                for (var i = 0; i < channels_list.length; i++)
                {
                    append({title: channels_list[i][1],
                            avatar_url: "recourses/avatars/" + channels_list[i][1] + ".jpg"})
                }
            }
        }

        delegate: Rectangle {

            color: "gray"
        
            width: parent.width
            height: channels_grid.cellHeight

            MouseArea{

                anchors.fill: parent

                RowLayout {

                    id: channel_row
                    anchors.fill: parent
                    spacing: 5
                    anchors.margins: 5

                    Image {

                        source: avatar_url
                        sourceSize.width: 40
                        sourceSize.height: 40
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: title
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {

                        color: "red"
                        width: 40
                        height: 40
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                ch.delete_channel(title)
                                drawer.update_channels()
                            }
                        }
                    }
                }

                onClicked: {
                    channels_grid.currentIndex = channels_grid.indexAt(parent.x,parent.y)
                    ch.set_channel_name(title)
                    ch.select_channel_url(title)
                }
            }
        }
    }
}