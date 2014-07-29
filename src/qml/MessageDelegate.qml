/*
 * Copyright 2012, 2013, 2014 Canonical Ltd.
 *
 * This file is part of messaging-app.
 *
 * messaging-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * messaging-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Ubuntu.History 0.1
import Ubuntu.Telephony 0.1
import Ubuntu.Content 0.1
import Ubuntu.Contacts 0.1

Item {
    id: messageDelegate

    property alias incoming: bubble.incoming
    property string textColor: incoming ? "#333333" : "white"
    property bool unread: false
    property variant activeAttachment
    property string accountLabel: ""
    property bool selectionMode: false
    property bool selected: false

    signal resend()
    signal itemPressAndHold(QtObject obj)
    signal itemClicked(QtObject obj)

    anchors {
        left: parent ? parent.left : undefined
        right: parent ? parent.right: undefined
        //verticalCenter: parent ? parent.verticalCenter : undefined
    }
    height: attachments.height + bubbleItem.height - (attachments.height > 0 ? units.gu(1) : 0)

//    Rectangle {
//        anchors.fill: parent
//        color: bubbleItem.selectedColor
//        opacity: selected ? 1.0 : 0.0
//        Behavior on opacity {
//            UbuntuNumberAnimation {}
//        }
//        z: -1
//    }

    Column {
        id: attachments
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        //width: units.gu(30)
        height: childrenRect.height
        spacing: units.gu(1)

        Repeater {
            model: textMessageAttachments
            Loader {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: item ? item.height : 0
                source: {
                    if (startsWith(modelData.contentType, "image/")) {
                        return "MMS/MMSImage.qml"
                    } else if (startsWith(modelData.contentType, "video/")) {
                        return "MMS/MMSVideo.qml"
                    } else if (startsWith(modelData.contentType, "application/smil") ||
                              startsWith(modelData.contentType, "application/x-smil")) {
                        console.log("Ignoring SMIL file")
                        return ""
                    } else if (startsWith(modelData.contentType, "text/plain") ) {
                        return "MMS/MMSText.qml"
                    } else if (startsWith(modelData.contentType, "text/vcard") ||
                              startsWith(modelData.contentType, "text/x-vcard")) {
                        return "MMS/MMSContact.qml"
                    } else {
                        console.log("No MMS render for " + modelData.contentType)
                        return "MMS/MMSDefault.qml"
                    }
                }
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        item.attachment = modelData
                        item.incoming = incoming
                        item.timestamp = timestamp
                    }
                }
                Connections {
                    target: item
                    onItemRemoved: {
                        console.log("attachment removed: " + modelData.attachmentId)
                        eventModel.removeEventAttachment(accountId, threadId, eventId, type, modelData.attachmentId)
                    }
                }
                Connections {
                    target: item
                    onItemPressAndHold: {
                        activeAttachment = modelData
                        PopupUtils.open(popoverSaveAttachmentComponent, item)
                    }
                }
                Binding {
                    target: item
                    property: "parentSelected"
                    value: messageDelegate.selected
                }
                Connections {
                    target: item
                    onItemClicked: {
                        if (item.previewer === "") {
                            activeAttachment = modelData
                            PopupUtils.open(popoverSaveAttachmentComponent, item)
                            return
                        }

                        var properties = {}
                        properties["attachment"] = item.attachment
                        mainStack.push(Qt.resolvedUrl(item.previewer), properties)
                    }
                }
            }
        }
    }

    ListItemWithActions {
        id: bubbleItem

        anchors {
            top: attachments.bottom
            topMargin: attachments.height > 0 ? (units.gu(1) * -1) : 0
            left: parent.left
            right: parent.right
        }
        height: bubble.visible ? bubble.height + units.gu(2) : 0
        leftSideAction: Action {
            iconName: "delete"
            text: i18n.tr("Delete")
            onTriggered: {
                eventModel.removeEvent(accountId, threadId, eventId, type)
            }
        }
        z: -1

        selected: messageDelegate.selected
        selectionMode: messageDelegate.selectionMode
        onItemPressAndHold: messageDelegate.itemPressAndHold(bubbleItem)
        onItemClicked: messageDelegate.itemClicked(bubbleItem)

        MessageBubble {
            id: bubble

            anchors {
                top: parent.top
                left: incoming ? parent.left : undefined
                right: incoming ? undefined : parent.right
            }
            visible: (messageText !== "")
            messageText: textMessage !== "" ? textMessage : ""
            messageTimeStamp: timestamp
            messageStatus: textMessageStatus
        }

        ActivityIndicator {
            id: indicator

            height: units.gu(2)
            width: units.gu(2)
            anchors {
                right: bubble.left
                verticalCenter: bubble.verticalCenter
                rightMargin: units.gu(1)
            }
            visible: running && !selectionMode
            // if temporarily failed or unknown status, then show the spinner
            running: (textMessageStatus === HistoryThreadModel.MessageStatusUnknown ||
                      textMessageStatus === HistoryThreadModel.MessageStatusTemporarilyFailed) && !incoming
        }
    }
//        Label {
//            id: accountIndicator
//            anchors {
//                right: bubble.left
//                rightMargin: units.gu(0.5)
//                bottom: bubble.bottom
//            }
//            text: accountLabel
//            visible: !incoming
//            font.pixelSize: FontUtils.sizeToPixels("small")
//            color: "green"
//
//}

        // FIXME: this is just a temporary workaround while we dont have the final design
//        UbuntuShape {
//            id: warningButton
//            color: "yellow"
//            height: units.gu(3)
//            width: units.gu(3)
//            anchors.right: accountIndicator.left
//            anchors.left: undefined
//            anchors.verticalCenter: bubble.verticalCenter
//            anchors.leftMargin: 0
//            anchors.rightMargin: units.gu(1)
//            visible: (textMessageStatus == HistoryThreadModel.MessageStatusPermanentlyFailed) && !incoming && !selectionMode
//            MouseArea {
//                anchors.fill: parent
//                onClicked: PopupUtils.open(popoverComponent, warningButton)
//            }
//            Label {
//                text: "!"
//                color: "black"
//                anchors.centerIn: parent
//            }
//        }
}
