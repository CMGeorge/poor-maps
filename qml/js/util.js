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

/*
 * Calculations below between longitude/latitude coordinates,
 * Mercator-projected coordinates and pixel positions on screen
 * assume a spherical Mercator map canvas.
 *
 * http://en.wikipedia.org/wiki/Mercator_projection
 * http://wiki.openstreetmap.org/wiki/Mercator
 */

function deg2rad(deg) {
    // Convert degrees to radians.
    return deg / 180 * Math.PI;
}

function eucd(x1, y1, x2, y2) {
    // Calculate euclidean distance.
    var xd = x2 - x1;
    var yd = y2 - y1;
    return Math.sqrt(xd*xd + yd*yd);
}

function median(x) {
    // Calculate the median of numeric array.
    if (x.length === 0) return NaN;
    if (x.length === 1) return x[0];
    x = x.slice();
    x.sort(function(a, b) {
        return a-b;
    });
    var i = Math.floor(x.length / 2);
    if (x.length % 2 === 1)
        return x[i];
    return (x[i-1] + x[i]) / 2;
}

function rad2deg(rad) {
    // Convert radians to degrees.
    return rad / Math.PI * 180;
}

function siground(x, n) {
    // Round x to n significant digits.
    var mult = Math.pow(10, n - Math.floor(Math.log(x) / Math.LN10) - 1);
    return Math.round(x * mult) / mult;
}

function xcoord2xpos(x, xmin, xmax, width) {
    // Convert X-coordinate to pixel X-position on screen.
    return Math.round((x - xmin) * (width / (xmax - xmin)));
}

function xpos2xcoord(x, xmin, xmax, width) {
    // Convert screen pixel X-position to X-coordinate.
    return xmin + (x / (width / (xmax - xmin)));
}

function ycoord2ymercator(y) {
    // Convert Y-coordinate to Mercator projected Y-coordinate.
    return Math.log(Math.tan(Math.PI/4 + deg2rad(y)/2));
}

function ycoord2ypos(y, ymin, ymax, height) {
    // Convert Y-coordinate to pixel Y-position on screen.
    ymin = ycoord2ymercator(ymin);
    ymax = ycoord2ymercator(ymax);
    return Math.round((ymax - ycoord2ymercator(y)) * (height / (ymax - ymin)));
}

function ymercator2ycoord(y) {
    // Convert Mercator projected Y-coordinate to Y-coordinate.
    return rad2deg(2 * Math.atan(Math.exp(y)) - Math.PI/2);
}

function ypos2ycoord(y, ymin, ymax, height) {
    // Convert screen pixel Y-position to Y-coordinate.
    ymin = ymercator2ycoord(ymin);
    ymax = ymercator2ycoord(ymax);
    return (ymin + (ymercator2ycoord(y) / (height / (ymax - ymin))));
}
