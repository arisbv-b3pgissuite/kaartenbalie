/*
 * B3P Kaartenbalie is a OGC WMS/WFS proxy that adds functionality
 * for authentication/authorization, pricing and usage reporting.
 *
 * Copyright 2006, 2007, 2008 B3Partners BV
 * 
 * This file is part of B3P Kaartenbalie.
 * 
 * B3P Kaartenbalie is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * B3P Kaartenbalie is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with B3P Kaartenbalie.  If not, see <http://www.gnu.org/licenses/>.
 */

//always call this script after the SWF object script has called the flamingo viewer.

var flamingo = document.getElementById("flamingo");

function flamingo_onInit() {
   //at this moment the flamingo.swf is up and running, so initialize the global flamingo var.
   flamingo =getMovie("flamingo");
}
function getMovie(movieName) {   
   if (navigator.appName.indexOf("Microsoft") != -1) {
            return window[movieName];
   }else {
      return document[movieName];
   }
}
