/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Joona Petrell <joona.petrell@jollamobile.com>
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
import ".."

Item {
    property real itemWidth: Theme.pageStackIndicatorWidth
    property real maxOpacity: root.opacity
    property bool animatingPosition

    height: row.height
    width: row.width ? row.x + row.width : 0

    property real leftWidth: enabled ? width + (_dialogAtTop ? 0 : activePageIndicator.width) : 0

    enabled: root.backNavigation || root.forwardNavigation
    visible: enabled && (maxOpacity > 0)
    opacity: enabled ? Math.min(maxOpacity, root.opacity) : 0.0
    Behavior on opacity { FadeAnimation {} }

    BackgroundItem {
        id: backgroundItem
        height: parent.height
        width: parent.width + (root._dialogAtTop ? Theme.paddingMedium : Theme.itemSizeExtraSmall)
        onClicked: root.navigateBack()
    }
    Row {
        id: row
        x: Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        Repeater {
            property Item currentContainer: root._currentContainer
            property int inactiveCount: currentContainer ? inactiveLevels() : 0

            function inactiveLevels() {
                var levels = currentContainer.pageStackIndex
                if (root._dialogAtTop) {
                    // If the stack top is a Dialog, it doesn't count as a level
                    levels--
                } else if (currentContainer.attachedContainer !== null) {
                    levels += 2
                }
                return levels
            }

            model: enabled ? Math.max((root.backNavigation || root.depth > 1 ? 1 : 0), inactiveCount) : 0

            Item {
                width: itemWidth; height: Theme.itemSizeLarge
                GlassItem {
                    anchors.centerIn: parent
                    dimmed: true
                    falloffRadius: 0.075
                    radius: 1.0
                    color: backgroundItem.down ? Theme.highlightColor : Theme.primaryColor
                }
            }
        }
    }

    Item {
        id: previousPageIndicator

        property Item container: root._previousContainer

        property real normalPosition: (container ? (width * container.pageStackIndex) + Theme.paddingMedium : 0)
        x: container ? container.lateralOffset + normalPosition : 0

        height: Theme.itemSizeLarge
        width: itemWidth

        // Do not show when dialog acceptance return is active
        visible: container !== null && container !== root._currentContainer && (root.currentPage !== null && root.currentPage._navigation !== PageNavigation.Forward)

        GlassItem {
            anchors.centerIn: parent
            color: backgroundItem.down ? Theme.highlightColor : Theme.primaryColor
        }
    }

    Item {
        id: activePageIndicator

        property bool dialogActivated

        property Item container: root._currentContainer
        property Item page: container ? container.page : null
        property int pageStatus: page ? page.status : PageStatus.Inactive

        property bool containsDialog: container !== null && container.containsDialog
        property bool activatingDialog: containsDialog && page !== null && (page.status < PageStatus.Active) && (page._navigation == PageNavigation.None)

        function lowerStackLevels() {
            var levels

            if (container) {
                levels = container.pageStackIndex

                if (containsDialog) {
                    // Don't count the dialog - it moves the predecessor's active index
                    --levels

                    if (page._forwardDestination) {
                        if (page._forwardDestinationAction === PageStackAction.Pop) {
                            var returnContainer = root._findContainer(function(stackPage) {
                                return (stackPage === page._forwardDestination)
                            })
                            if (returnContainer) {
                                // We will return to this page's level
                                levels = returnContainer.pageStackIndex
                            }
                        } else if (page._forwardDestinationAction === PageStackAction.Push) {
                            // Another level will be added for the new page
                            levels += 2
                        } else {
                            levels += 1
                        }
                    }
                }
            }

            return Math.max(levels, 0)
        }

        property real normalPosition: (lowerStackLevels() * width) + Theme.paddingMedium
        property real dialogPosition: (root.currentPage ? root.currentPage.width : root.width) - width - Theme.paddingLarge

        // Account for the fact that the dialog return animation must travel less than the entire width
        property real positionFactor: container ? ((container.width - (dialogPosition - normalPosition)) / container.width) : 0
        property real returnOffset: containsDialog ? Math.max(positionFactor * -container.lateralOffset, 0) : 0

        property real xOffset: shiftAnimation.enabled || dialogActivated ? (dialogPosition + returnOffset) : normalPosition

        property bool dialogSuccessor
        property bool dialogTransitionActive

        property Item transitionPartner: container ? container.transitionPartner : null
        onTransitionPartnerChanged: {
            if (container && container.containsDialog) {
                if (transitionPartner) {
                    dialogSuccessor = transitionPartner.containsDialog
                    dialogTransitionActive = dialogSuccessor
                } else {
                    dialogSuccessor = false
                    dialogTransitionActive = false
                }
            }
        }

        // During a dialog-to-dialog transition, fix the intended location to the right side
        x: dialogTransitionActive ? dialogPosition : (container ? container.lateralOffset + xOffset : 0)

        height: Theme.itemSizeLarge
        width: itemWidth

        // Do not show when an transition involving an 'attached' page is active
        opacity: container && (container.lateralOffset === 0 || (!container.attached && (!transitionPartner || !transitionPartner.attached))) ? parent.opacity : 0

        onPageStatusChanged: {
            if (containsDialog) {
                if (pageStatus === PageStatus.Inactive) {
                    dialogActivated = false
                } else if (pageStatus === PageStatus.Activating || pageStatus === PageStatus.Active) {
                    dialogActivated = true
                }
            } else {
                dialogActivated = false
            }

            if (pageStatus === PageStatus.Inactive) {
                dialogSuccessor = false
            }
            if (pageStatus === PageStatus.Active) {
                // The new page is active; transition has completed
                dialogTransitionActive = false
            }
        }

        GlassItem {
            color: backgroundItem.down && !root._dialogAtTop ? Theme.highlightColor : Theme.primaryColor
            anchors.centerIn: parent
            radius: 0.2
            falloffRadius: 0.2
        }

        Behavior on opacity {
            FadeAnimation { duration: 100 }
        }
        Behavior on x {
            id: shiftAnimation
            enabled: activePageIndicator.activatingDialog || activePageIndicator.dialogSuccessor
            NumberAnimation {
                duration: _transitionDuration
                easing.type: Easing.InOutQuad
                onRunningChanged: {
                    animatingPosition = running
                }
            }
        }
    }

    // Map the indicator onto the page - we can't have the page as the parent, because we must remain opaque when the page is faded
    property Item _page: root.currentPage
    transform: [ Rotation {
        angle: _page ? _page.rotation : 0
    }, Translate {
        x: (_page && (_page.orientation == Orientation.Landscape || _page.orientation == Orientation.PortraitInverted)) ? root._effectiveWidth : 0
        y: (_page && (_page.orientation == Orientation.PortraitInverted || _page.orientation == Orientation.LandscapeInverted)) ? root._effectiveHeight : 0
    } ]
}
