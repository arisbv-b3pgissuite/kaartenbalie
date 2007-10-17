// 3/8/07 Erik van de Pol

// Rewritten variant of "generic_dhtml.vbs" by Eric Compas (2/3/05).
// Rewritten in javascript and working in most W3C compliant browsers.


// some global settings

// section highlighting - border && background shading 
// colors and flags (set to false to not use)
var SHADE_COLOR = "#FFFBDF";
var USE_SHADE = false;
var BORDER_COLOR = "#ccc";
var USE_BORDER = true;

// menu image offset (distance away from image that's
// clicked on to show menu)
var MENU_X_OFFSET = 3;
var MENU_Y_OFFSET = 3;


// Show popup window that's embedded in code
function showMenu(event) {
	var element = getTarget(event);
	element = element.parentNode;
	var firstElem = element;
	//debug("showMenu");

	while (element.tagName.toLowerCase() != "span" && element.tagName.toLowerCase() != "html")
		element = element.parentNode;
	
	//current value
	var list;
	var listFound = false;
	for (var i in element.childNodes) {
		list = element.childNodes[i];
		if (list.nodeType == Node.ELEMENT_NODE && list.tagName.toLowerCase() == "ul") {
			listFound = true;
			break;
		}
	}

	if (!listFound) {
		alert("Cannot locate menu to display.");
		return;
	}

	// already displayed?
	if (list.style.visibility == "visible") {
		list.style.visibility = "hidden";
		return;
	}

	// get image to use for positioning
	var image;
	var imageFound = false;
	for (var i in element.childNodes) {
		image = element.childNodes[i];
		if (image.nodeType == Node.ELEMENT_NODE && image.tagName.toLowerCase() == "img") {
			imageFound = true;
			break;
		}
	}

	if (!imageFound) {
		alert("Cannot locate menu image.");
		return;
	}
	
	// show menu
	//list.style.left = image.offsetLeft + MENU_X_OFFSET;
	//list.style.top = image.offsetTop + MENU_Y_OFFSET;
	_showMenu(list);
	//list.onmouseout = hideMenu;	
}


// 2/05 Eric Compas;
// Hide popup menu;
function hideMenu(event) {
	var element = getTarget(event);
	//debug("hideMenu");
	//debug("element.tagName.toLowerCase(): " + element.tagName.toLowerCase());
	// test if not IE:
	if (event != null && event != "" && event.currentTarget != null && event.currentTarget != "") {
		// do w3c event model test:
		var node = event.currentTarget;
		var inside = false;
		//debug("event.target: " + element.tagName);
		//debug("event.currentTarget: " + event.currentTarget.tagName);		
		while (node.tagName.toLowerCase() != "html") {
			node = node.parentNode;
			//debug("element: " + element.tagName);
			//debug("searching node: " + node.tagName);
			if (node == element)
				inside = true;
		}
		//debug("inside: " + inside);
		if (element.tagName.toLowerCase() == "ul" && !inside) {// && !element.contains(event.currentTarget)) {
			_hideMenu(element);	
		}
	}
}

function keepMenu(event) {
	//debug("keepMenu");
	//var element = getTarget(event);
	//_showMenu(element);
	showMenu(event);
	//if (element.style.display != "none")
}

function hideMenuIE(event) {
	var element = getTarget(event);
	//debug("hideMenuIE");
	//debug("element.tagName.toLowerCase(): " + element.tagName.toLowerCase());
	if (element.tagName.toLowerCase() == "ul") {
		_hideMenu(element);		
	}
}

function _showMenu(element) {
	//debug("show");
	//element.style.visibility = "visible";	
	element.style.display = "inline";		
}

function _hideMenu(element) {
	//debug("hide");
	//element.style.visibility = "hidden";	
	element.style.display = "none";		
}
// 12/8/2004 Eric Compas
//
// Description:
//   Expand/collapse the contents of the specified folder (div tag)
//   Assumes:
//  1) that script is called by A tag
//  2) that DIV to be shown or hidden is first DIV child of 
//     anchor's parent
//  3) that plus and minus images (if images are used) are
//     defined somewhere in the document with id= "minus_img"
//     and "plus_img"
//
// Arguments:
//   nodeRef = reference to the object calling the routine
function expandNode(pElem) {
	// get elements (anchor and child div)
	var pFolderAnchor = pElem.parentNode.getElementsByTagName("a")[0];
	var pChildDiv = pElem.parentNode.getElementsByTagName("div")[0];
	if (pFolderAnchor == null || pChildDiv == null) {
		// error encountered;
		alert("Error encountered expanding/collapsing this section.");
		return;
	}

	// switch folder content display or hide
	var sDisplay = pChildDiv.style.display;
	if (sDisplay == "none") {
		pChildDiv.style.display = "block";
	}
	else {
		pChildDiv.style.display = "none";
	}

	// switch plus/minus text or plus/minus images

	// get first img child (must be + or - image)
	var pCurrentIMG;
	//for (var childIndex in pFolderAnchor.childNodes) {
	for (var i = 0; i < pFolderAnchor.childNodes.length; i++) {
		pCurrentIMG = pFolderAnchor.childNodes[i];
		if (pCurrentIMG.nodeType == 1 && pCurrentIMG.tagName.toLowerCase() == "img") {
			// switch images
			var pNewIMG;			
			if (sDisplay == "none") {
				pNewIMG = document.getElementById("minus_img").cloneNode(true);
			}
			else {
				pNewIMG = document.getElementById("plus_img").cloneNode(true);
			}

			if (pNewIMG == null) {
				alert("No image to switch found");
				return;
			}
			pFolderAnchor.replaceChild(pNewIMG, pCurrentIMG);
			break;
		}
	}

}


// 12/8/2004 Eric Compas
//
// Description:
//   Expand/collapse all the folder (div tags) in the current document.
//   Expands/collapses div tags with class="folder"
//
// Arguments:
//   expand = true, expands all
//          = false, collapses all
/*
function expandAll(bExpand) {
	//On Error Resume Next;
 
	// get all div elements in document and loop through them
	var pDIVElements = document.getElementsByTagName("div");

	//var i;
	//var pElem;
	//For i = 0 To pDIVElements.length - 1;
	for (var childIndex in pDIVElements) {
		var pElem = pDIVElements[childIndex];
		//pElem = pDIVElements.item(i);
		if (pElem.className == "folder") {
			// current div element's anchor and content div
			pFolderAnchor = pElem.getElementsByTagName("a")[0];
			pChildDiv = pElem.getElementsByTagName("div")[0];
			if (pFolderAnchor != null && pChildDiv != null) {
				// switch folder content display or hide
				if (bExpand)
					pChildDiv.style.display = "block";
				else
					pChildDiv.style.display = "none";

				// switch plus/minus text or plus/minus images

				// image first child?
				if (pFolderAnchor.childNodes[0].tagName == "IMG") {
					pCurrentIMG = pFolderAnchor.getElementsByTagName("img")[0];
					
					// switch images
					if (bExpand)
						pNewIMG = document.getElementById("minus_img").cloneNode(true);
					else
						pNewIMG = document.getElementById("plus_img").cloneNode(true);

					pFolderAnchor.replaceChild(pNewIMG, pCurrentIMG);
				}
				else {
					// switch text
					if (bExpand)
						sSymbol = "-";
					else
						sSymbol = "+";

					pFolderAnchor.childNodes[0].innerText = sSymbol;
				}
			}
			else {
				// error encountered - skip this folder
			}
		}
	}
	//Next;
}*/