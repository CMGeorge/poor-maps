/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import "."

Page {
    id: page
    allowedOrientations: ~Orientation.PortraitInverse
    property bool loading: true
    property string title: ""
    SilicaListView {
        id: listView
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: visible ? nameLabel.height + statLabel.height : 0
            menu: contextMenu
            ListItemLabel {
                id: nameLabel
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                height: implicitHeight + Theme.paddingMedium
                text: model.name
                verticalAlignment: Text.AlignBottom
            }
            ListItemLabel {
                id: statLabel
                anchors.top: nameLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight + Theme.paddingMedium
                // model.count negative during operations, see page.purge.
                text: model.count < 0 ? "· · ·" : model.count + " tiles · " + model.size
                verticalAlignment: Text.AlignTop
            }
            RemorseItem { id: remorse }
            ContextMenu {
                id: contextMenu
                MenuItem {
                    text: "Remove older than one week"
                    onClicked: remorse.execute(listItem, "Removing", function() {
                        page.purge(model.index, model.directory, 7);
                    });
                }
                MenuItem {
                    text: "Remove older than one month"
                    onClicked: remorse.execute(listItem, "Removing", function() {
                        page.purge(model.index, model.directory, 30);
                    });
                }
                MenuItem {
                    text: "Remove older than three months"
                    onClicked: remorse.execute(listItem, "Removing", function() {
                        page.purge(model.index, model.directory, 90);
                    });
                }
                MenuItem {
                    text: "Remove older than six months"
                    onClicked: remorse.execute(listItem, "Removing", function() {
                        page.purge(model.index, model.directory, 180);
                    });
                }
                MenuItem {
                    text: "Remove older than one year"
                    onClicked: remorse.execute(listItem, "Removing", function() {
                        page.purge(model.index, model.directory, 365);
                    });
                }
                MenuItem {
                    text: "Remove all"
                    onClicked: remorse.execute(listItem, "Removing", function() {
                        page.purge(model.index, model.directory, 0);
                        listItem.visible = false;
                    });
                }
            }
            ListView.onRemove: animateRemoval(listItem);
            onClicked: listItem.showMenu();
        }
        header: PageHeader { title: page.title }
        model: ListModel {}
        VerticalScrollDecorator {}
    }
    BusyModal {
        id: busy
        running: page.loading
    }
    Component.onCompleted: {
        page.loading = true;
        page.title = "";
        busy.text = "Calculating";
        page.populate();
    }
    function populate(query) {
        // Load cache use statistics from the Python backend.
        listView.model.clear();
        py.call("poor.cache.stat", [], function(results) {
            if (results && results.length > 0) {
                page.title = "Map Tile Cache"
                for (var i = 0; i < results.length; i++)
                    listView.model.append(results[i]);
            } else {
                page.title = "";
                busy.error = "No cache, or error";
            }
            page.loading = false;
        });
    }
    function purge(index, directory, max_age) {
        // Remove tiles in cache and recalculate statistics.
        listView.model.setProperty(index, "count", -1);
        py.call("poor.cache.purge_directory", [directory, max_age], function(result) {
            py.call("poor.cache.stat_directory", [directory], function(result) {
                listView.model.setProperty(index, "count", result.count);
                listView.model.setProperty(index, "size", result.size);
            });
        });
    }
}
