<%@include file="/WEB-INF/jsp/taglibs.jsp" %>
<tiles:importAttribute/>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> 

<html:html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>Kaartenbalie</title>
        <link href="<html:rewrite page='/styles/main.css' module='' />" rel="stylesheet" type="text/css">
        <link href="<html:rewrite page='/styles/selectcss' module='' />" type="text/css" rel="stylesheet" />
        <!--[if IE 6]>
        <link href="<html:rewrite page='/styles/main-ie6.css' module='' />" rel="stylesheet" type="text/css">
        <![endif]-->
        <!--[if IE 7]>
        <link href="<html:rewrite page='/styles/main-ie7.css' module='' />" rel="stylesheet" type="text/css">
        <![endif]-->
        <script language="JavaScript" type="text/JavaScript" src="<html:rewrite page='/js/validation.jsp' module=''/>"></script>
        <SCRIPT LANGUAGE="JavaScript" SRC="../js/tabcontainer.js"></SCRIPT>
    </head>
    <body style="background-color:#FFFFFF;">
        
        <tiles:insert definition="common.actionMessages"/>
        <tiles:insert name='content'/>
    </body>
</html:html>
