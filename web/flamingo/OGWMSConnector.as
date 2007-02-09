﻿class OGWMSConnector {
	//meta
	var version:String = "2.0";
	//-----------------------
	private var busy:Boolean = false;
	private var events:Object;
	private static var requestid:Number = 0;
	//-----------------------------------
	function addListener(listener:Object) {
		events.addListener(listener);
	}
	function removeListener(listener:Object) {
		events.removeListener(listener);
	}
	function OGWMSConnector(server:String) {
		events = new Object();
		AsBroadcaster.initialize(events);
	}
	function getCapabilities(url:String, args:Object, obj:Object):String {
		if (args == undefined) {
			var args:Object = new Object();
		}
		args.REQUEST = "GetCapabilities";
		return (this._request(url, args, obj));
	}
	function getMap(url:String, args:Object, obj:Object):String {
		if (args == undefined) {
			var args:Object = new Object();
		}
		args.REQUEST = "GetMap";
		return (this._request(url, args, obj));
	}
	function getFeatureInfo(url:String, args:Object, obj:Object):String {
		if (args == undefined) {
			var args:Object = new Object();
		}
		args.REQUEST = "GetFeatureInfo";
		return (this._request(url, args, obj));
	}
	private function _request(url:String, args:Object, obj:Object):String {
		if (this.busy) {
			this.events.broadcastMessage("onError", "busy processing request...", obj, "OGWMSConnector_"+requestid);
			return;
		}
		var error:String;
		this.busy = true;
		requestid++;
		var reqid:String = "OGWMSConnector_"+requestid;
		var req_url = url;
		for (var arg in args) {
			var req_url = this._changeArgs(req_url, arg, args[arg]);
		}
		this.events.broadcastMessage("onRequest", {requestid:reqid, url:req_url, requesttype:args.REQUEST}, reqid);
		if (args.REQUEST.toUpperCase() == "GETMAP") {
			this.busy = false;
			this.events.broadcastMessage("onGetMap", req_url, obj, reqid);
			this.events.broadcastMessage("onResponse", {requestid:reqid, url:req_url, requesttype:args.REQUEST}, reqid);
		} else {
			var xrequest:XML = new XML();
			xrequest.ignoreWhite = true;
			var thisObj:Object = this;
			xrequest.onLoad = function(success:Boolean) {
				var time = (new Date()-starttime)/1000;
				if (success) {
					if (this.firstChild.nodeName == "ServiceExceptionReport") {
						error = this.firstChild.toString();
						thisObj.events.broadcastMessage("onResponse", {requestid:reqid, requesttype:args.REQUEST, url:req_url, response:this.toString(), error:error, responsetime:time}, reqid);
						thisObj.events.broadcastMessage("onError", this.firstChild.toString(), obj, reqid);
					} else {
						thisObj.events.broadcastMessage("onResponse", {requestid:reqid, requesttype:args.REQUEST, url:req_url, response:this.toString(), responsetime:time}, reqid);
						switch (args.REQUEST.toUpperCase()) {
						case "GETCAPABILITIES" :
							thisObj._processCapabilities(this, obj, reqid);
							break;
						case "GETFEATUREINFO" :
							thisObj._processFeatureInfo(this, obj, reqid);
							break;
						}
					}
				} else {
					error = "connection failed...";
					thisObj.events.broadcastMessage("onResponse", {requestid:reqid, requesttype:args.REQUEST, url:req_url, response:this.toString(), error:error, responsetime:time}, reqid);
					thisObj.events.broadcastMessage("onError", "connection failed...", obj, reqid);
				}
				thisObj.busy = false;
				// do some cleaning
				delete this;
			};
			var starttime:Date = new Date();
			xrequest.load(req_url);
		}
		return (reqid);
	}
	private function _processFeatureInfo(xml:XML, obj, reqid) {
		switch (xml.firstChild.nodeName.toLowerCase()) {
		case "msgmloutput" :
			_process_msGMLOutput(xml, obj, reqid);
			break;
		case "featurecollection" :
			_process_featureCollection(xml, obj, reqid);
			break;
		case "featureinforesponse" :
			_process_featureInfoResponse(xml, obj, reqid);
			break;
		case undefined :
			//var lines = xml.split(String.fromCharCode(13))
			var s:String = xml.toString();
			if (s.indexOf("GetFeatureInfo results:", 0)>=0) {
				_process_getfeatureinforesults(s, obj, reqid);
			} else {
				this.events.broadcastMessage("onError", "cannot parse unknown output format...", obj, reqid);
			}
			break;
		default :
			this.events.broadcastMessage("onError", "cannot parse unknown output format...", obj, reqid);
		}
	}
	private function _process_getfeatureinforesults(s:String, obj, reqid) {
		//GetFeatureInfo results:
		//
		//Layer &apos;EHS_Bos_natuurgebied_2005_V&apos;
		//   Feature 1233: 
		//     OBJECTID = &apos;1233&apos;
		//     OMSCHRIJVING = &apos;Bos- en natuurgebied&apos
		//etc.
		var features:Object = new Object();
		var a:Array;
		var field:String;
		var val:String;
		var layer:String;
		var feature:Object;
		var lines = s.split(newline);
		var line:String;
		for (var i:Number = 1; i<lines.length; i++) {
			line = this.trim(lines[i]);
			if (line.length == 0) {
				continue;
			}
			if (line.indexOf("Layer ") == 0) {
				//layer
				a = line.split(" ");
				layer = this.trimApos(line.substring(6, line.length));
				features[layer] = new Array();
				continue;
			}
			if (line.indexOf("Feature ") == 0) {
				//feature
				feature = new Object();
				features[layer].push(feature);
				continue;
			}
			if (line.indexOf(" = ")>=0) {
				//value
				a = line.split(" = ");
				field = this.trim(a[0]);
				val = this.trimApos(this.trim(a[1]));
				feature[field] = val;
				continue;
			}
		}
		this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
	}
	private function _process_featureInfoResponse(xml:XML, obj, reqid) {
		//ESRI output
		var features:Object = new Object();
		var layer:String;
		var val:String;
		var xfields:Array = xml.firstChild.childNodes;
		for (var i:Number = 0; i<xfields.length; i++) {
			var feature:Object = new Object();
			var layer = xfields[i].attributes._LAYERID_;
			if (layer == undefined) {
				layer = "?";
			}
			for (var attr in xfields[i].attributes) {
				feature[attr] = xfields[i].attributes[attr];
			}
			if (features[layer] == undefined) {
				features[layer] = new Array();
			}
			features[layer].push(feature);
		}
		this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
	}
	private function _process_featureCollection(xml:XML, obj, reqid) {
		//Demis output format
		var features:Object = new Object();
		var layer:String;
		var val:String;
		var xfeatures:Array = xml.firstChild.childNodes;
		for (var i:Number = 0; i<xfeatures.length; i++) {
			switch (xfeatures[i].nodeName.toLowerCase()) {
			case "gml:featuremember" :
				var feature:Object = new Object();
				layer = "";
				var xfeature:Array = xfeatures[i].childNodes;
				for (var j:Number = 0; j<xfeature.length; j++) {
					val = xfeature[j].firstChild.nodeValue;
					switch (xfeature[j].nodeName.toLowerCase()) {
					case "layer" :
						layer = val;
						break;
					default :
						feature[xfeature[j].nodeName] = val;
						break;
					}
				}
				if (features[layer] == undefined) {
					features[layer] = new Array();
				}
				features[layer].push(feature);
				break;
			}
		}
		this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
	}
	private function _process_msGMLOutput(xml:XML, obj, reqid) {
		//Mapserver's output format
		var features:Object = new Object();
		var xOutput:XMLNode = xml.firstChild;
		var nlayers:Number = xOutput.childNodes.length;
		for (var ilayer:Number = 0; ilayer<nlayers; ilayer++) {
			var xlayer:XMLNode = xOutput.childNodes[ilayer];
			var layer:String = xlayer.nodeName.substr(0, xlayer.nodeName.length-"_layer".length);
			if (features[layer] == undefined) {
				features[layer] = new Array();
			}
			var nfeatures:Number = xlayer.childNodes.length;
			for (var ifeature:Number = 0; ifeature<nfeatures; ifeature++) {
				var xfeature:XMLNode = xlayer.childNodes[ifeature];
				var feature:Object = new Object();
				var nfields:Number = xfeature.childNodes.length;
				for (var ifield:Number = 0; ifield<nfields; ifield++) {
					var xfield:XMLNode = xfeature.childNodes[ifield];
					switch (xfield.nodeName.toLowerCase()) {
					case "gml:boundedby" :
						break;
					default :
						var fieldname:String = xfield.nodeName;
						var fieldvalue:String = xfield.firstChild.nodeValue;
						feature[fieldname] = fieldvalue;
						break;
					}
				}
				features[layer].push(feature);
			}
		}
		this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
	}
	private function _processCapabilities(xml:XML, obj, reqid) {
		var service:Object = new Object();
		var layers:Object = new Object();
		var xService = xml.firstChild.childNodes[0];
		for (var i:Number = xService.childNodes.length-1; i>=0; i--) {
			var val:String = xService.childNodes[i].firstChild.nodeValue;
			switch (xService.childNodes[i].nodeName.toLowerCase()) {
			case "name" :
				service.name = val;
				break;
			case "title" :
				service.title = val;
				break;
			case "abstract" :
				service.abstract = val;
				break;
			}
		}
		var xCapability = xml.firstChild.childNodes[1];
		for (var i:Number = xCapability.childNodes.length-1; i>=0; i--) {
			switch (xCapability.childNodes[i].nodeName.toLowerCase()) {
			case "request" :
				break;
			case "exception" :
				break;
			case "layer" :
				layers = this._getLayers(xCapability.childNodes[i], layers);
				break;
			}
		}
		this.events.broadcastMessage("onGetCapabilities", service, layers, obj, reqid);
	}
	private function _getLayers(xml:XML, layers:Object):Object {
		var layer:Object = new Object();
		layer.layers = new Object();
		layer.queryable = false;
		if (xml.attributes.queryable == "1") {
			layer.queryable = true;
		}
		layer.opaque = false;
		if (xml.attributes.opaque == "1") {
			layer.opaque = true;
		}
		layer.nosubsets = false;
		if (xml.attributes.noSubsets == "1") {
			layer.nosubsets = true;
		}
		layer.cascaded = false;
		if (xml.attributes.cascaded == "1") {
			layer.cascaded = true;
		}
		for (var j:Number = xml.childNodes.length; j>=0; j--) {
			switch (xml.childNodes[j].nodeName.toLowerCase()) {
			case "name" :
				layer.name = xml.childNodes[j].firstChild.nodeValue;
				break;
			case "title" :
				layer.title = xml.childNodes[j].firstChild.nodeValue;
				break;
			case "abstract" :
				layer.abstract = xml.childNodes[j].firstChild.nodeValue;
				break;
			case "srs" :
				layer.srs = xml.childNodes[j].firstChild.nodeValue;
				break;
			case "latlonboundingbox" :
				var ext:Object = new Object();
				ext.minx = this._asNumber(xml.childNodes[j].attributes.minx);
				ext.miny = this._asNumber(xml.childNodes[j].attributes.miny);
				ext.maxx = this._asNumber(xml.childNodes[j].attributes.maxx);
				ext.maxy = this._asNumber(xml.childNodes[j].attributes.maxy);
				layer.latlonboundingbox = ext;
				break;
			case "boundingbox" :
				var ext:Object = new Object();
				ext.minx = this._asNumber(xml.childNodes[j].attributes.minx);
				ext.miny = this._asNumber(xml.childNodes[j].attributes.miny);
				ext.maxx = this._asNumber(xml.childNodes[j].attributes.maxx);
				ext.maxy = this._asNumber(xml.childNodes[j].attributes.maxy);
				ext.srs = xml.childNodes[j].attributes.SRS;
				layer.boundingbox = ext;
				break;
			case "scalehint" :
				layer.minscale = this._asNumber(xml.childNodes[j].attributes.min);
				layer.maxscale = this._asNumber(xml.childNodes[j].attributes.max);
				break;
			case "style" :
				var xstyle = xml.childNodes[j];
				for (var k:Number = 0; k<xstyle.childNodes.length; k++) {
					switch (xstyle.childNodes[k].nodeName.toLowerCase()) {
					case "legendurl" :
						var xlegendurl = xstyle.childNodes[k];
						for (var l:Number = 0; l<xlegendurl.childNodes.length; l++) {
							switch (xlegendurl.childNodes[l].nodeName.toLowerCase()) {
							case "onlineresource" :
								layer.legendurl = xlegendurl.childNodes[l].attributes["xlink:href"];
								break;
							}
						}
						break;
					}
				}
				break;
			case "layer" :
				layer.layers = this._getLayers(xml.childNodes[j], layer.layers);
				break;
			}
		}
		layers[layer.name] = layer;
		return (layers);
	}
	private function _changeArgs(url:String, arg:String, val:String):String {
		var p1:Number = url.toLowerCase().indexOf("&"+arg.toLowerCase()+"=", 0);
		if (p1 == -1) {
			var p1:Number = url.toLowerCase().indexOf("?"+arg.toLowerCase()+"=", 0);
			if (p1 == -1) {
				return (url+"&"+arg+"="+val);
			}
			var p2:Number = url.indexOf("&", p1);
			var s1:String = url.substring(0, p1);
			if (p2 == -1) {
				return (s1+"?"+arg+"="+val);
			}
			var s2:String = url.substring(p2, url.length);
			return (s1+"?"+arg+"="+val+s2);
		}
		var p2:Number = url.indexOf("&", p1);
		var s1:String = url.substring(0, p1);
		if (p2 == -1) {
			return (s1+"&"+arg+"="+val);
		}
		var s2:String = url.substring(p2, url.length);
		return (s1+"&"+arg+"="+val+s2);
	}
	private function _asNumber(s:String):Number {
		if (s == undefined) {
			return (undefined);
		}
		if (s.indexOf(",", 0) != -1) {
			var a:Array = s.split(",");
			s = a[0]+"."+a[1];
		}
		return (Number(s));
	}
	private function lTrim(s:String):String {
		var TAB = 9;
		var LINEFEED = 10;
		var CARRIAGE = 13;
		var SPACE = 32;
		var i = 0;
		while (s.charCodeAt(i) == SPACE || s.charCodeAt(i) == CARRIAGE || s.charCodeAt(i) == LINEFEED || s.charCodeAt(i) == TAB) {
			i++;
		}
		return s.substring(i, s.length);
	}
	private function rTrim(s:String):String {
		var TAB = 9;
		var LINEFEED = 10;
		var CARRIAGE = 13;
		var SPACE = 32;
		var i = s.length-1;
		while (s.charCodeAt(i) == SPACE || s.charCodeAt(i) == CARRIAGE || s.charCodeAt(i) == LINEFEED || s.charCodeAt(i) == TAB) {
			i--;
		}
		return s.substring(0, i+1);
	}
	private function trim(s:String):String {
		return lTrim(rTrim(s));
	}
	private function trimApos(s:String):String {
		if (s.substr(0, 6) == "&apos;") {
			s = s.substring(6, s.length);
		}
		if (s.substr(s.length-6, 6) == "&apos;") {
			s = s.substring(0, s.length-6);
		}
		return s;
	}
}
