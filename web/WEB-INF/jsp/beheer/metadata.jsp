<%@include file="/WEB-INF/jsp/taglibs.jsp" %>

<script type="text/javascript" src="<html:rewrite page='/js/simple_treeview.js' module='' />"></script>

<div class="containerdiv" style="height: 500px;">
    <h1>Beheer Metadata</h1>
    
    <b>Lijst met beschikbare layers:</b>
    
	<div id="tree" class="containerdivFloat">
	</div>

	<div id="editMetadataRoot" class="containerdivBare">
		test2
		&nbsp;
	</div>
		
</div>

<div id="groupDetails" style="margin-top: 10px; height: 10px;" class="containerdiv">
    &nbsp;
	test
</div>

<script type="text/javascript">
    function popUp(url) {
		//voor debuggen:
		window.location = url;
		//dit wil IE7 niet: //IE7 heeft problemen met de title
        //window.open(url, 'Metadata Editor');
		//dit wel?:
		//window.open(url, "", "directories=0, location=0, menubar=0, status=0, toolbar=0, resizable=1, scrollbars=1");
        return false;
    }   
		
	function openMetadataInIFrame(url) {
		var editMetadataRoot = document.getElementById("editMetadataRoot");
		var editMetadataIFrame = document.createElement("iframe");
		editMetadataIFrame.src = url;

		editMetadataIFrame.setAttribute("frameborder", "0");

		editMetadataIFrame.scrolling = "no";
		editMetadataRoot.innerHTML = "";
		editMetadataRoot.appendChild(editMetadataIFrame);		
	}
    
    <c:if test = "${not empty layerList}">
        
        var root = ${layerList};
        function itemClick(item) {
            var DOMItemId = treeview_getDOMItemId(globalTreeOptions["tree"], item.id);        
            treeview_toggleItemChildren(DOMItemId);
        }

        function createLabel(container, item) {
            var div = document.createElement("div");
            div.className = item.type == "layer" ? "layerLabel" : "serviceproviderLabel";
            div.style.height = '18px';
            if(item.type == "layer") {
                var popupLink = document.createElement("a");
                popupLink.onclick = function() {
					newUrl = 'editmetadata.do?edit=submit&id=' + item.id;
					//alert(newUrl);
					//popUp(newUrl);
					openMetadataInIFrame(newUrl);
                }
                popupLink.innerHTML = item.name;
                popupLink.href='#';
                div.appendChild(popupLink);
            } else {
                div.appendChild(document.createTextNode(item.name));
            }
            container.appendChild(div);
        }

        treeview_create({
            "id": "tree",
            "root": root,
            "rootChildrenAsRoots": true,
            "itemLabelCreatorFunction": createLabel,        
            "toggleImages": {
                "collapsed": "<html:rewrite page='/images/treeview/plus.gif' module=''/>",
                "expanded": "<html:rewrite page='/images/treeview/minus.gif' module=''/>",
                "leaf": "<html:rewrite page='/images/treeview/leaft.gif' module=''/>"
            },
            "saveExpandedState": true,
            "saveScrollState": true,
            "expandAll": true
        });
        function reloadLayers(){
            var layersString="";
            var orderLayerBox= document.getElementById("orderLayerBox");
            var orderLayers=orderLayerBox.childNodes;
            for (var i=0; i < orderLayers.length; i++){
                if(layersString.length==0){
                    layersString+=orderLayers[i].name;
                }else{
                    layersString+=","+orderLayers[i].name;
                }
            }                
            //haal de extent op van de mainmap en plaats die in de request
            var e=flamingo.call("mainMap", "getCurrentExtent");
            window.location.href="mapviewer.do?layers="+layersString+"&extent="+e.minx + "," + e.miny + "," + e.maxx + "," + e.maxy;
        } 
        
        function setAllTrue(element){
            setAll(element,true);
            element.onclick= function(){setAllFalse(this);};
            element.innerHTML="&nbsp;Niets";
        }
        function setAllFalse(element){
            setAll(element,false);
            element.onclick= function(){setAllTrue(this);};
            element.innerHTML="&nbsp;Alles";
        }
        
        function setAll(element,checked){
            var item=element.selecteditem;
            if(item && item.children){
                setAllChilds(item.children,checked);
            }
            
        }
        function setAllChilds(children,checked){
            for(var i=0; i < children.length; i++){
                var element=document.getElementById(children[i].id);
                if(element){
                    if (checked && element.checked){
                    }else{
                        element.checked=checked;
                        
                    }
                }
                if (children[i].children){
                    setAllChilds(children[i].children,checked);
                }
            }
        
        }
        //check the selected layers
        <c:if test="${not empty checkedLayers}">
            var layerstring="${checkedLayers}";
            var layers=layerstring.split(",");
            for (var i=0; i < layers.length; i++){
                var element=document.getElementById(layers[i]);
                if (element){
                    element.checked=true;
                    
                }
                
            }
        </c:if>
        function mainMap_onUpdateProgress(){
            setMapInfo();
        }
        function setMapInfo(){
            var e=flamingo.call("mainMap", "getCurrentExtent");
            var s=flamingo.call("mainMap", "getCurrentScale");
            
            var x=Math.round((e.minx+e.maxx)/2);
            var y=Math.round((e.miny+e.maxy)/2);
            document.getElementById("currentScale").innerHTML="Schaal= "+s;
            document.getElementById("currentCoordinates").innerHTML="X= "+x+ " Y= "+y;
        }
        
    </c:if>
</script>    
