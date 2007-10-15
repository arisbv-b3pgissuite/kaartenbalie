<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hibernate-mapping PUBLIC 
"-//Hibernate/Hibernate Mapping DTD 3.0//EN"
"http://hibernate.sourceforge.net/hibernate-mapping-3.0.dtd">

<hibernate-mapping>
    <class name="nl.b3p.kaartenbalie.core.server.reporting.domain.ServiceProviderRequest" table="rep_serviceproviderrequest" discriminator-value="ServerProviderRequest" >
        
        <id name="id" type="int" column="spr_id" >
            <generator class="native"/>
        </id>
        <discriminator column="clr_requestType" type="string" />
        
        <many-to-one name="clientRequest" column="spr_clr_id" update="true" not-null="false"/>        
        
        <property name="bytesSend" column="spr_bytesSend" />
        <property name="bytesReceived" column="spr_bytesReceived" />
        <property name="responseStatus" column="spr_responseStatus" />
        <property name="providerRequestURI" column="spr_providerRequestURI" length="4000"/>   
        <property name="timeStamp" column="spr_timeStamp"/>
        <subclass name="nl.b3p.kaartenbalie.core.server.reporting.domain.WMSRequest" discriminator-value="WMSRequest">
            <property name="wmsVersion" column="spr_wmsVersion"/>
            <subclass name="nl.b3p.kaartenbalie.core.server.reporting.domain.WMSGetMapRequest" discriminator-value="WMSGetMapRequest">
                <property name="srs" column="spr_srs"/>
                <property name="width" column="spr_width"/>
                <property name="height" column="spr_height"/>
                <property name="format" column="spr_format"/>
            </subclass>
            <subclass name="nl.b3p.kaartenbalie.core.server.reporting.domain.WMSGetFeatureInfoRequest" discriminator-value="WMSGetFeatureInfoRequest">
            </subclass>
            <subclass name="nl.b3p.kaartenbalie.core.server.reporting.domain.WMSGetLegendGraphicRequest" discriminator-value="WMSGetLegendGraphicRequest">
            </subclass>
            <subclass name="nl.b3p.kaartenbalie.core.server.reporting.domain.WMSGetCapabilitiesRequest" discriminator-value="WMSGetCapabilitiesRequest">
            </subclass>
        </subclass>
    </class>
</hibernate-mapping>