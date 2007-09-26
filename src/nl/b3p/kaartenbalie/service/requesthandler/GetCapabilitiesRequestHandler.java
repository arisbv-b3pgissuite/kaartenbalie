/**
 * @(#)GetCapabilitiesRequestHandler.java
 * @author N. de Goeij
 * @version 1.00 2006/12/13
 *
 * Purpose: the function of this class is to create a list of url's which direct to the right servers that
 * have the desired layers for the WMS GetCapabilities request.
 *
 * @copyright 2007 All rights reserved. B3Partners
 */

package nl.b3p.kaartenbalie.service.requesthandler;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URL;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import nl.b3p.wms.capabilities.ServiceProvider;
import nl.b3p.kaartenbalie.core.server.User;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentType;
import org.w3c.dom.Element;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;

public class GetCapabilitiesRequestHandler extends WMSRequestHandler {
    
    private static final Log log = LogFactory.getLog(GetCapabilitiesRequestHandler.class);
    
    // <editor-fold defaultstate="" desc="default GetCapabilitiesRequestHandler() constructor.">
    public GetCapabilitiesRequestHandler() {}
    // </editor-fold>
    
    /** Processes the parameters and creates a DocumentBuilder from the given parameters.
     * This DocumentBuilder will be used to create a XML based String which can be returned to the client.
     *
     * @param parameters Map parameters
     *
     * @return byte[]
     *
     * @throws IOException
     * @exception ParserConfigurationException
     */
    // <editor-fold defaultstate="" desc="getRequest(Map parameters) method.">
    public void getRequest(DataWrapper dw, Map parameters) throws IOException, Exception {
        user = (User) parameters.get(KB_USER);
        url = (String) parameters.get(KB_PERSONAL_URL);
                
        ServiceProvider s = getServiceProvider();
        s.overwriteURL(url);
        
        ByteArrayOutputStream output = null;
        
        /*
         * Create a DocumentBuilderFactory from which a new document can be created
         */
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setValidating(true);
        DocumentBuilder db = dbf.newDocumentBuilder();
        DOMImplementation di = db.getDOMImplementation();

        // <!DOCTYPE WMT_MS_Capabilities SYSTEM "http://schemas.opengeospatial.net/wms/1.1.1/WMS_MS_Capabilities.dtd"
        // [
        // <!ELEMENT VendorSpecificCapabilities EMPTY>
        // ]>  <!-- end of DOCTYPE declaration -->
        URL dtdURL = this.getClass().getResource("/nl/b3p/wms/dtd/capabilities_1_1_1.dtd");
        DocumentType dt = di.createDocumentType("WMT_MS_Capabilities",null,"http://localhost:8084/kaartenbalie_mnp/capabilities_1_1_1.dtd");//dtdURL.toString());
        Document dom = di.createDocument(null, "WMT_MS_Capabilities", dt);
        Element rootElement = dom.getDocumentElement();
        rootElement.setAttribute("version", "1.1.1");
        rootElement = s.toElement(dom, rootElement);
        
        /*
         * Create a new output format to which this document should be translated and
         * serialize the tree to an XML document type
         */
        OutputFormat format = new OutputFormat(dom, CHARSET, true);

        format.setIndenting(true);
        output = new ByteArrayOutputStream();
        XMLSerializer serializer = new XMLSerializer(output, format);
        serializer.serialize(dom);
        
        DOMValidator dv = new DOMValidator();
        dv.parseAndValidate(new ByteArrayInputStream(output.toString().getBytes(CHARSET)));
        
        byte[] data = output.toByteArray();
        dw.setHeader("Content-Disposition", "inline; filename=\"GetCapabilities.xml\";");
        dw.setContentType("application/vnd.ogc.wms_xml");
        dw.write(output);
    }
    // </editor-fold>
}