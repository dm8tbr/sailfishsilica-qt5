/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Martin Jones <martin.jones@jollamobile.com>
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
import "private/Util.js" as Util

Item {
    id: placeholder
    property Item flickable
    property alias text: mainLabel.text
    property alias hintText: hintLabel.text
    property real verticalOffset

    // stay centered in screen
    y: (flickable ? flickable.originY : 0) + (__silica_applicationwindow_instance._rotatingItem.height - height) / 2 + verticalOffset
    width: (flickable ? flickable.width : screen.width)
    height: mainLabel.height + hintLabel.height
    anchors.horizontalCenter: parent.horizontalCenter
    enabled: false
    opacity: enabled ? 1.0 : 0

    onEnabledChanged: {
        if (enabled && !_content) {
            _content = activeContent.createObject(placeholder)
        }
    }

    property Item _content
    property alias _mainLabel: mainLabel
    property alias _hintLabel: hintLabel

    Behavior on opacity { FadeAnimation { duration: 300 } }

    InfoLabel { id: mainLabel }
    Text {
        id: hintLabel
        x: Theme.paddingLarge
        anchors.top: mainLabel.bottom
        width: parent.width - 2*Theme.paddingLarge
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        font {
            pixelSize: Theme.fontSizeLarge
            family: Theme.fontFamilyHeading
        }
        color: Theme.highlightColor
        opacity: 0.4
    }

    Component {
        // content we don't need until we're active
        id: activeContent
        PulleyAnimationHint {
            flickable: placeholder.flickable
            width: parent.width
            height: width
            anchors.centerIn: parent
        }
    }

    Component.onCompleted: {
        var item = Util.findFlickable(placeholder)
        if (item) {
            flickable = item
            parent = item.contentItem
        } else {
            console.log("ViewPlaceholder requires a SilicaFlickable parent")
        }
    }
}
