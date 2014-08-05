sailfishsilica-qt5
==================

This is an upload of Jolla's Silica components as shipped
with their Sailfish operating system and SDK.

It is meant as a point of reference for developers.

sanitization
------------

As the sailfishsilica-qt5 package contains a mix of BSD licensed
and proprietary files it would not be suitable for a 1:1 upload.
Thus all files that are not *clearly* BSD licensed were considered
proprietary and replaced by a symlink to this ReadMe.
All BSD licensed files are unaltered and pristine reproductions
of the files contained in the sailfishsilica-qt5 packages shipped
by Jolla

Files that have been removed, according to above policy:
 * usr/lib/qt5/qml/Sailfish/Silica/Keypad.qml
 * usr/lib/qt5/qml/Sailfish/Silica/libsailfishsilicaplugin.so
 * usr/lib/qt5/qml/Sailfish/Silica/ListItem.qml
 * usr/lib/qt5/qml/Sailfish/Silica/OpacityRampEffect.qml
 * usr/lib/qt5/qml/Sailfish/Silica/PanelBackground.qml
 * usr/lib/qt5/qml/Sailfish/Silica/plugins.qmltypes
 * usr/lib/qt5/qml/Sailfish/Silica/qmldir
 * usr/lib/qt5/qml/Sailfish/Silica/private/KeypadButton.qml
 * usr/lib/qt5/qml/Sailfish/Silica/private/ReturnToHomeHintCounter.qml
 * usr/lib/qt5/qml/Sailfish/Silica/private/Wallpaper.qml
 * usr/share/translations/sailfishsilica-qt5_eng_en.qm

note
----

This is only a copy, a mirror of sorts, for Jolla's files, as they
don't have a public repository of their own.
Please contact upstream with any issues, suggestions, problems 
or questions.

Pull requests, questions, etc. directed to this repository or its
owner will be *ignored*.
