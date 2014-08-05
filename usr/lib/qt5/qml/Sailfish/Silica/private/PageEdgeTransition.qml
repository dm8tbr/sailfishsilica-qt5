/****************************************************************************************
**
** Copyright (C) 2014 Jolla Ltd.
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

Rectangle {
    // Visualizes the edge of the right-most page during page transitions
    property Item stack
    property Item container
    property bool active: container && container.parent
    property bool animating: stack._currentContainer && stack._currentContainer.transitionPartner

    onAnimatingChanged: {
        // find the page that animates from the right
        if (animating) {
            var currentContainer = stack._currentContainer
            var currentIndex = currentContainer.pageStackIndex
            var partnerIndex = currentContainer.transitionPartner.pageStackIndex

            // in most forwardstepping cases the right-most page has higher page index
            if (currentIndex < partnerIndex) {
                container = currentContainer.transitionPartner
            // in wizard case the new page coming from the right is new and doesn't yet have index
            } else if (partnerIndex == -1) {
                container = currentContainer.transitionPartner
            // when accepting a dialog the right-most page is the previous page
            } else if (currentIndex > partnerIndex
                       && currentContainer.containsDialog && currentContainer.lateralOffset < 0) {
                container = currentContainer.transitionPartner
            // when backstepping the right-most page is the current page
            } else {
                container = stack._currentContainer
            }
        } else {
            container = null
        }
    }

    color: Theme.highlightBackgroundColor
    parent: active ? container.parent : null
    anchors.fill: parent ? container : undefined
    opacity: active ? 0.1*Math.min(1.0, 4*Math.abs(container.lateralOffset/Screen.width)) : 0.0
}
