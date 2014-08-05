/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Andrew den Exter <andrew.den.exter@jollamobile.com>
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

SilicaFlickable {
    id: panel

    property bool expanded: open || horizontalAnimation.running || verticalAnimation.running
    property bool open
    property bool moving: horizontalAnimation.running || verticalAnimation.running || mouseArea.drag.active
    property int dock: Dock.Bottom
    property bool _immediate

    function _visibleSize() {
        if (_managedDock == Dock.Left) {
            return panel.x + panel.width - contentX
        } else if (_managedDock == Dock.Top)  {
            return panel.y + panel.height - contentY
        } else if (_managedDock == Dock.Right && panel.parent) {
            return panel.parent.width - panel.x + contentX
        } else if (_managedDock == Dock.Bottom && panel.parent) {
            return panel.parent.height - panel.y + contentY
        } else {
            return 0
        }
    }

    property real visibleSize: _visibleSize()

    property real _lastPos
    property real _direction
    default property alias _data: mouseArea.data

    property int _managedDock: dock
    property bool _isVertical: _managedDock == Dock.Top || _managedDock == Dock.Bottom
    property real _threshold: Math.min(_isVertical ? height / 3 : width / 3, 90)

    function show(immediate) {
        _immediate = !!immediate
        open = true
        _immediate = false
    }

    function hide(immediate) {
        _immediate = !!immediate
        open = false
        _immediate = false
    }

    Component.onCompleted: {
        if (parent === __silica_applicationwindow_instance.contentItem) {
            // The panel is most probably a direct child of ApplicationWindow and should not be
            // parented on a resizing item, i.e. contentItem, but a non-resizing (but still
            // orientation aware) item instead, i.e. _rotatingItem.
            parent = __silica_applicationwindow_instance._rotatingItem
        }
    }

    onDockChanged: {
        _immediate = true
        _managedDock = dock
        _immediate = false
    }

    Binding {
        target: panel
        property: "x"
        value: {
            if (_managedDock == Dock.Left) {
                return open ? 0 : -panel.width
            } else if (_managedDock == Dock.Right && panel.parent) {
                return open ? panel.parent.width - panel.width : panel.parent.width
            } else {
                return 0
            }
        }
        when: horizontalBehavior.enabled || panel._immediate
    }
    Behavior on x {
        id: horizontalBehavior
        enabled: !mouseArea.drag.active && !panel._immediate
        NumberAnimation {
            id: horizontalAnimation
            duration: 500; easing.type: Easing.OutQuad
        }
    }

    Binding {
        target: panel
        property: "y"
        value: {
            if (_managedDock == Dock.Top) {
                return open ? 0 : -panel.height
            } else if (_managedDock == Dock.Bottom && panel.parent) {
                return open ? panel.parent.height - panel.height : panel.parent.height
            } else {
                return 0
            }
        }
        when: verticalBehavior.enabled || panel._immediate
    }
    Behavior on y {
        id: verticalBehavior
        enabled: !mouseArea.drag.active && !panel._immediate
        NumberAnimation {
            id: verticalAnimation
            duration: 500; easing.type: Easing.OutQuad
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        drag {
            target: panel
            minimumX: !panel._isVertical ? mouseArea.drag.maximumX - panel.width : 0
            maximumX: _managedDock == Dock.Right && panel.parent ? panel.parent.width : 0
            minimumY: panel._isVertical ? mouseArea.drag.maximumY - panel.height : 0
            maximumY: _managedDock == Dock.Bottom && panel.parent ? panel.parent.height : 0
            axis: panel._isVertical ? Drag.YAxis : Drag.XAxis
            filterChildren: true
            onActiveChanged: {
                if (!drag.active
                        &&((panel._managedDock == Dock.Left   && panel.x < -panel._threshold && panel._direction <= 0)
                        || (panel._managedDock == Dock.Top    && panel.y < -panel._threshold && panel._direction <= 0)
                        || (panel._managedDock == Dock.Right  && panel.x - drag.minimumX >  panel._threshold && panel._direction >= 0)
                        || (panel._managedDock == Dock.Bottom && panel.y - drag.minimumY >  panel._threshold && panel._direction >= 0))) {
                    panel.open = false
                }
            }
        }

        onPressed: {
            panel._direction = 0
            panel._lastPos = panel._isVertical ? panel.y : panel.x
        }
        onPositionChanged: {
            var pos = panel._isVertical ? panel.y : panel.x
            panel._direction = (_direction + pos - _lastPos) / 2
            panel._lastPos = panel.y
        }
        PanelBackground {
            z: -1

            property bool isPortrait: panel.dock === Dock.Top || panel.dock === Dock.Bottom

            anchors.centerIn: parent
            transformOrigin: Item.Center
            width: isPortrait ? parent.width : parent.height
            height: isPortrait ? parent.height : parent.width

            rotation: {
                switch (panel.dock) {
                case Dock.Top:
                    return 180
                case Dock.Bottom:
                    return 0
                case Dock.Left:
                    return 90
                case Dock.Right:
                    return -90
                }
            }
        }
    }
}
