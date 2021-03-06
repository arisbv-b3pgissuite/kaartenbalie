<%--
B3P Kaartenbalie is a OGC WMS/WFS proxy that adds functionality
for authentication/authorization, pricing and usage reporting.

Copyright 2007-2011 B3Partners BV.

This program is distributed under the terms
of the GNU General Public License.

You should have received a copy of the GNU General Public License
along with this software. If not, see http://www.gnu.org/licenses/gpl.html

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--%>
<%@include file="/WEB-INF/jsp/taglibs.jsp" %>

<c:set var="form" value="${roleForm.map}"/>
<c:set var="action" value="${form.action}"/>
<c:set var="mainid" value="${form.id}"/>

<c:set var="save" value="${action == 'save'}"/>
<c:set var="delete" value="${action == 'delete'}"/>

<script type="text/javascript" src="<html:rewrite page='/js/beheerJS.js' module='' />"></script>

<html:javascript formName="roleForm" staticJavascript="false"/>
<html:form action="/role" onsubmit="return validateRoleForm(this)" focus="name">
    <html:hidden property="action"/>
    <html:hidden property="alt_action"/>
    <html:hidden property="id" />

    <div class="containerdiv">
        <H1><fmt:message key="beheer.role.title" /></H1>

        <c:choose>
            <c:when test="${!empty roleslist}">
                <table id="server_table" class="dataTable">
                    <thead>
                        <tr>
                            <th style="width: 100%;" class="no-filter"><fmt:message key="beheer.role.name" /></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="nRole" varStatus="status" items="${roleslist}">
                            <c:choose>
                                <c:when test="${nRole.protectedRole}">
                                    <c:set var="link" value="" />
                                </c:when>
                                <c:otherwise>
                                    <c:url var="link" value="/beheer/role.do?edit=submit&id=${nRole.id}" />
                                </c:otherwise>
                            </c:choose>
                            <c:set var="id_selected" value='' />
                            <c:if test="${nRole.id == mainid}"><c:set var="id_selected" value=' class="row_selected"' /></c:if>
                            <tr data-link="${link}"${id_selected}>
                                <td>
                                    <c:choose>
                                        <c:when test="${nRole.protectedRole}">
                                            <c:out value="${nRole.role}"/> - <fmt:message key="beheer.role.protected" />
                                        </c:when>
                                        <c:otherwise>
                                            <html:link page="/role.do?edit=submit&id=${nRole.id}">
                                                <c:out value="${nRole.role}"/>
                                            </html:link>
                                        </c:otherwise>
                                    </c:choose>
                                    <input type="hidden" name="link" value="${link}" /><input type="hidden" name="selected" value="${id_selected}" />
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <fmt:message key="beheer.role.geenbeschikbaar" />
            </c:otherwise>
        </c:choose>
    </div>
    <div id="groupDetails" style="clear: left; padding-top: 15px;" class="containerdiv">
        <c:choose>
            <c:when test="${action != 'list'}">
                <div class="serverDetailsClass">
                    <table>
                        <tr>
                            <td><B><fmt:message key="beheer.rol.name"/>:</B></td>
                            <td><html:text property="name" size="50" /></td>
                        </tr>
                    </table>

                    <div class="knoppen">
                        
                        <c:choose>
                            <c:when test="${save || delete}">
                                <html:submit property="confirm" accesskey="o" styleClass="knop">
                                    <fmt:message key="button.ok"/>
                                </html:submit>
                            </c:when>
                            <c:when test="${not empty mainid}">
                                <html:submit property="save" accesskey="s" styleClass="knop">
                                    <fmt:message key="button.update"/>
                                </html:submit>
                                <html:submit property="deleteConfirm" accesskey="d" styleClass="knop" onclick="bCancel=true">
                                    <fmt:message key="button.remove"/>
                                </html:submit>
                            </c:when>
                            <c:otherwise>
                                <html:submit property="save" accesskey="s" styleClass="knop">
                                    <fmt:message key="button.save"/>
                                </html:submit>
                            </c:otherwise>
                        </c:choose>
                        <html:cancel accesskey="c" styleClass="knop" onclick="bCancel=true">
                            <fmt:message key="button.cancel"/>
                        </html:cancel>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <html:hidden property="name"/>
                <div class="knoppen">
                    <html:submit property="create" accesskey="n" styleClass="knop" onclick="bCancel=true">
                        <fmt:message key="button.new"/>
                    </html:submit>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div id="groupDetails" style="clear: left; padding-top: 15px;" class="containerdiv">
        &nbsp;
    </div>

</html:form>
