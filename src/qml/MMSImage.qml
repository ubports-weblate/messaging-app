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
import Ubuntu.Components.ListItems 0.1 as ListItem

ListItem.Empty {
    id: imageDelegate
    property var attachment
    property bool incoming
    anchors.left: parent.left
    anchors.right: parent.right

    removable: true
    confirmRemoval: true
    height: bubble.height
    clip: true
    showDivider: false
    highlightWhenPressed: false
    BorderImage {
        id: bubble
        anchors.left: imageDelegate.incoming ? parent.left : undefined
        anchors.leftMargin: units.gu(1)
        anchors.right: imageDelegate.incoming ? undefined : parent.right
        anchors.rightMargin: units.gu(1)
        anchors.top: parent.top
        width: image.width + units.gu(3)
        height: image.height + units.gu(2)

        function selectBubble() {
            var fileName = "assets/conversation_";
            if (incoming) {
                fileName += "incoming.sci";
            } else {
                fileName += "outgoing.sci";
            }
            return fileName;
        }

        source: selectBubble()

        Image {
            id: image
            anchors.right: imageDelegate.incoming ? undefined : parent.right
            anchors.rightMargin: imageDelegate.incoming ? undefined : units.gu(2)
            anchors.left: !imageDelegate.incoming ? undefined : parent.left
            anchors.leftMargin: !imageDelegate.incoming ? undefined : units.gu(2)
            anchors.topMargin: units.gu(1)
            anchors.top: parent.top
            height: sourceSize.height < units.gu(20) ? sourceSize.height : units.gu(20)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            source: attachment.filePath
        }
    }
}
