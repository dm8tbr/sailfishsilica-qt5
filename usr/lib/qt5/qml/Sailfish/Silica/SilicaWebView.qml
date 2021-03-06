/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jollamobile.com>
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
import QtQuick.Window 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "private"
import "private/FastScrollAnimation.js" as FastScroll
import "private/Util.js" as Utils

WebView {
    id: webView

    // Property quickScrollEnabled deprecated. Use quickScroll instead.
    property alias quickScrollEnabled: quickScrollItem.quickScroll
    property alias quickScroll: quickScrollItem.quickScroll
    property Item pullDownMenu
    property Item pushUpMenu
    readonly property bool pulleyMenuActive: pullDownMenu != null && pullDownMenu.active || pushUpMenu != null && pushUpMenu.active
    property bool overridePageStackNavigation
    property QtObject _scrollAnimation
    property bool _pulleyDimmerActive: pullDownMenu && pullDownMenu._activeDimmer || pushUpMenu && pushUpMenu._activeDimmer

    // SilicaWebView extras
    property Component header
    property Item _headerItem
    property Page _page
    property bool _cookiesEnabled: true

    // Part of experimental API
    property Item _webPage: webView.experimental.page

    function scrollToTop() {
        FastScroll.scrollToTop(webView)
    }
    function scrollToBottom() {
        FastScroll.scrollToBottom(webView)
    }

    onHeaderChanged: webView.experimental.header = header
    experimental.onHeaderItemChanged: {
        _headerItem = webView.experimental.headerItem
        if (_headerItem) {
            _headerItem.parent = headerContent
        }
    }

    boundsBehavior: (pullDownMenu && pullDownMenu._activationPermitted) || (pushUpMenu && pushUpMenu._activationPermitted) ? Flickable.DragOverBounds : Flickable.StopAtBounds

    // Experimental API usage
    experimental.useDefaultContentItemSize: false

    // Column handles height of web content and width read from web page
    // For still unknown reason pulley menu cannot be opened when contentHeight == height
    // Due to Bug #7857, cleanup + 1px when bug is fixed
    contentHeight: contentColumn.height + 1
    contentWidth: Math.floor(Math.max(webView.width, _webPage.width))

    experimental.preferredMinimumContentsWidth: Screen.width
    experimental.deviceWidth: Screen.width
    experimental.deviceHeight: Screen.height
    experimental.preferences.cookiesEnabled: _cookiesEnabled

    // Binding contentWidth: Math.max(webView.width, _webPage.width) doesn't work.
    // So, break intial bindings when geometry of web page changes.
    Connections {
        target: _webPage
        onWidthChanged: contentWidth = Math.floor(Math.max(webView.width, _webPage.width))
    }

    Rectangle {
        id: headerBackground
        x: webView.contentX
        width: webView.contentWidth
        height: _headerItem ? _headerItem.height : 0

        color: Theme.rgba(Theme.highlightColor, 0.3)
    }

    Rectangle {
        x: webView.contentX
        anchors.top: headerBackground.bottom

        width: webView.contentWidth
        height: Math.max(webView.contentHeight, _page.height) - headerBackground.height
        color: webView.experimental.transparentBackground ? "transparent" : "white"
    }

    Column {
        id : contentColumn
        width: _webPage ? Math.floor(Math.max(webView.width, _webPage.width)) : webView.width
        objectName: "contentColumn"

        Item {
            id: headerContent
            x: webView.contentX
            width: webView.width
            height: childrenRect.height
        }
    }

    BoundsBehavior { flickable: webView }
    QuickScroll {
        id: quickScrollItem
        flickable: webView
    }

    states: State {
        name: "disableNavigation"
        when: !overridePageStackNavigation && _page != null && (!(webView.atXBeginning && webView.atXEnd) || webView.pulleyMenuActive || webView.moving)
        PropertyChanges {
            target: _page
            backNavigation: false
            forwardNavigation: !_page._belowTop
        }
    }

    Component.onCompleted: {
        _webPage.parent = contentColumn
        _page = Utils.findPage(webView)
        if (!_page) {
            console.log("No parent Page found. A SilicaWebView should be declared inside a Page, \
               as SilicaWebView overrides back and forward navigation bindings defined in Page.")
        }
    }
}
