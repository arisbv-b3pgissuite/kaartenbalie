<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hibernate-mapping PUBLIC 
"-//Hibernate/Hibernate Mapping DTD 3.0//EN"
"http://hibernate.sourceforge.net/hibernate-mapping-3.0.dtd">

<hibernate-mapping>
    <class name="nl.b3p.kaartenbalie.core.server.reporting.domain.ClientRequest" table="rep_clientrequest">
        
         <id name="id" type="int" column="clr_id" >
            <generator class="native"/>
        </id>
        <!-- taken from organization -->
        <set name="serviceProviderRequests" > 
            <key column="spr_clr_id" update="true" not-null="false" /> 
            <one-to-many class="nl.b3p.kaartenbalie.core.server.reporting.domain.ServiceProviderRequest"/> 
        </set>
        
        
        
        
        <property name="clientRequestURI" column="clr_clientRequestURI" length="4000"/>
        <property name="timeStamp" column="clr_timeStamp"/>
        <property name="bytesReceivedFromUser" column="clr_bytesReceivedFromUser"/>
        <property name="bytesSendToUser" column="clr_bytesSendToUser"/>
        <property name="totalResponseTime" column="clr_totalResponseTime"/>        
    </class>
</hibernate-mapping>