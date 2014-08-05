/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: John Brooks <john.brooks@jollamobile.com>
** All rights reserved.
** 
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
** 
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: dialogHeader

    property Item dialog
    property string acceptText: title
    property alias cancelText: cancelLabel.text
    property bool acceptTextVisible

    default property alias _children: headerText.data
    property int _depth: dialog && dialog._depth ? dialog._depth+2 : 1

    property bool _navigatingBack: dialog && dialog._navigationPending === PageNavigation.Back

    property string title: defaultAcceptText
    property alias extraContent: extraContentPlaceholder

    //% "Accept"
    property string defaultAcceptText: qsTrId("components-he-dialog_accept")

    height: Theme.itemSizeLarge
    width: parent ? parent.width : Screen.width

    onAcceptTextChanged: {
        headerText.state = "linked"
    }

    // TODO: Remove top-level BackgroundItem, now here for API compatibility
    down: false
    highlighted: false
    highlightedColor: "transparent"

    Component.onCompleted: {
        if (!dialog)
            dialog = _findDialog()
        if (!dialog)
            console.log("DialogHeader must have a parent Dialog instance")
    }

    function _findDialog() {
        var r = parent
        while (r && !r.hasOwnProperty('__silica_dialog'))
            r = r.parent
        return r
    }

    Label {
        id: cancelLabel

        //% "Cancel"
        text: qsTrId("components-he-dialog_cancel")
        x: (pageStack._pageStackIndicator ? pageStack._pageStackIndicator.width : 0) + Theme.paddingMedium
        font { pixelSize: Theme.fontSizeLarge; family: Theme.fontFamilyHeading }
        anchors.verticalCenter: parent.verticalCenter
        truncationMode: TruncationMode.Fade
        opacity: dialogHeader._navigatingBack ? 1.0 : 0.0
        visible: opacity > 0 // JB#8173
        Behavior on opacity { FadeAnimation { duration: 400 } }
    }
    Item {
        id: extraContentPlaceholder
        anchors {
            left: parent.left
            leftMargin: pageStack._pageStackIndicator && pageStack._pageStackIndicator.leftWidth ? (pageStack._pageStackIndicator.leftWidth + Theme.paddingMedium) : 0
            right: headerText.left
            verticalCenter: parent.verticalCenter
        }
        opacity: dialogHeader._navigatingBack ? 0.0 : 1.0
        Behavior on opacity { FadeAnimation { duration: 400 } }
        visible: opacity > 0
    }
    BackgroundItem {
        id: headerText

        onClicked: { dialog.accept() }

        height: parent.height
        anchors.right: parent.right
        width: headerLabel.width + headerLabel.anchors.rightMargin + Theme.paddingLarge
        opacity: !dialogHeader.dialog || dialogHeader.dialog.canAccept ? 1.0 : 0.3

        Label {
            id: headerLabel
            // The label text can be linked to the dialog activity; initially it is 'Accept'
            text: acceptTextVisible ? acceptText : title
            color: headerText.highlighted ? Theme.highlightColor : Theme.primaryColor
            // Don't allow the label to extend over the page stack indicator
            width: Math.min(implicitWidth, (dialog ? dialog.width : Screen.width) - Theme.pageStackIndicatorWidth * _depth)
            truncationMode: TruncationMode.Fade
            font {
                pixelSize: Theme.fontSizeLarge
                family: Theme.fontFamilyHeading
            }
            anchors {
                right: parent.right
                // |text|pad-large|indicator|pad-large|
                rightMargin: Theme.pageStackIndicatorWidth + Theme.paddingLarge + Theme.paddingMedium
                verticalCenter: parent.verticalCenter
            }
            opacity: dialogHeader._navigatingBack ? 0.0 : 1.0
            Behavior on opacity { FadeAnimation { duration: 400 } }
            visible: opacity > 0 // JB#8173
        }

        // display 'Accept' when user is accepting the dialog
        property real forwardFlickDifference: dialog && dialog.canAccept && dialog.status == PageStatus.Active
                                              ? pageStack._forwardFlickDifference : 0
        onForwardFlickDifferenceChanged: headerText.state = forwardFlickDifference > 0 ? "" : "linked"

        states: State {
            // In "linked" state, the visible header is linked to the acceptText content
            name: "linked"

            PropertyChanges {
                target: dialogHeader
                acceptTextVisible: true
            }
        }

        transitions: Transition {
            SequentialAnimation {
                FadeAnimation { target: headerText; to: 0.0 }
                PropertyAction {
                    target: dialogHeader
                    property: "acceptTextVisible"
                    value: headerText.state === "linked"
                }
                FadeAnimation { target: headerText; to: 1.0}
            }
        }

        Timer {
            id: linkTimer
            interval: 1000
            running: false
            repeat: false
            onTriggered: {
                if (acceptText !== "" && acceptText !== title) {
                    if (pageStack._forwardFlickDifference == 0) {
                        headerText.state = "linked"
                    }
                }
            }
        }

        Connections {
            target: dialog
            onStatusChanged: {
                if (dialog.status == PageStatus.Activating) {
                    headerText.state = ""
                    dialogHeader.acceptTextVisible = false
                } else if (dialog.status == PageStatus.Active) {
                    linkTimer.running = true
                }
            }
            onVisibleChanged: {
                if (dialog.status == PageStatus.Active) {
                    // If visiblity changes while we're active - run the linked-change animation again
                    if (!dialog.visible) {
                        headerText.state = ""
                        dialogHeader.acceptTextVisible = false
                    } else {
                        linkTimer.running = true
                    }
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 400
        }
    }

    // for testing
    function _headerText() {
        return headerLabel.text
    }
}

