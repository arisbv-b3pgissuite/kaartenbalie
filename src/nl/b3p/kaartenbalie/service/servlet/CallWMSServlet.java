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
package nl.b3p.kaartenbalie.service.servlet;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.security.NoSuchAlgorithmException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.NoResultException;
import javax.persistence.NonUniqueResultException;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import nl.b3p.commons.services.FormUtils;
import nl.b3p.kaartenbalie.core.server.User;
import nl.b3p.kaartenbalie.core.server.b3pLayering.ExceptionLayer;
import nl.b3p.kaartenbalie.core.server.monitoring.DataMonitoring;
import nl.b3p.kaartenbalie.core.server.persistence.MyEMFDatabase;
import nl.b3p.kaartenbalie.service.AccessDeniedException;
import nl.b3p.kaartenbalie.service.ProviderException;
import nl.b3p.kaartenbalie.service.requesthandler.DOMValidator;
import nl.b3p.kaartenbalie.service.requesthandler.DataWrapper;
import nl.b3p.kaartenbalie.service.requesthandler.DescribeLayerRequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.GetCapabilitiesRequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.GetFeatureInfoRequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.GetLegendGraphicRequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.GetMapRequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.MetadataRequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.ProxyRequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.RequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.TextToImage;
import nl.b3p.kaartenbalie.service.requesthandler.WFSDescribeFeatureTypeRequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.WFSGetCapabilitiesRequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.WFSGetFeatureRequestHandler;
import nl.b3p.kaartenbalie.service.requesthandler.WFSTransactionRequestHandler;
import nl.b3p.ogc.utils.KBConfiguration;
import nl.b3p.ogc.utils.KBCrypter;
import nl.b3p.ogc.utils.OGCConstants;
import nl.b3p.ogc.utils.OGCRequest;
import nl.b3p.ogc.utils.OgcWfsClient;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.httpclient.Credentials;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.HttpVersion;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScope;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.StringRequestEntity;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;
import org.exolab.castor.xml.ValidationException;
import org.w3c.dom.CDATASection;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentType;
import org.w3c.dom.Element;
import org.xml.sax.SAXException;

public class CallWMSServlet extends HttpServlet {

    private static Log log = null;
    public static final long serialVersionUID = 24362462L;
    public static String CAPABILITIES_DTD = null;
    public static String EXCEPTION_DTD = null;
    public static String DESCRIBELAYER_DTD = null;

    /** Initializes the servlet.
     * Turns the logging of the servlet on.
     *
     * @param config ServletConfig config
     *
     * @throws ServletException
     */
    // <editor-fold defaultstate="" desc="init(ServletConfig config) method.">
    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        // Zet de logger
        log = LogFactory.getLog(this.getClass());
        log.info("Initializing Call WMS Servlet");
    }
    // </editor-fold>

    /** Processes the incoming request and calls the various methods to create the right output stream.
     *
     * @param request servlet request
     * @param response servlet response
     *
     * @throws ServletException
     * @throws IOException
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        long startTime = System.currentTimeMillis();

        StringBuffer baseUrl = createBaseUrl(request);
        if (CAPABILITIES_DTD == null) {
            CAPABILITIES_DTD = baseUrl.toString() + "/dtd/capabilities_1_1_1.dtd";
        }
        if (EXCEPTION_DTD == null) {
            EXCEPTION_DTD = baseUrl.toString() + "/dtd/exception_1_1_1.dtd";
        }
        if (DESCRIBELAYER_DTD == null) {
            DESCRIBELAYER_DTD = baseUrl.toString() + "/dtd/WMS_DescribeLayerResponse.dtd";
        }

        DataWrapper data = new DataWrapper(request, response);

        Object identity = null;
        EntityManager em = null;
        EntityTransaction tx = null;
        try {
            identity = MyEMFDatabase.createEntityManager(MyEMFDatabase.MAIN_EM);
            log.debug("Getting entity manager ......");
            em = MyEMFDatabase.getEntityManager(MyEMFDatabase.MAIN_EM);
            tx = em.getTransaction();
            tx.begin();

            DataMonitoring rr = new DataMonitoring();
            data.setRequestReporting(rr);

            String serviceName = OGCConstants.WMS_SERVICE_WMS;

            try {
                OGCRequest ogcrequest = calcOGCRequest(request);
                data.setOgcrequest(ogcrequest);

                String serviceParam = ogcrequest.getParameter(OGCConstants.SERVICE);
                if (serviceParam != null || !"".equals(serviceParam)) {
                    serviceName = serviceParam;
                }

                String iUrl = ogcrequest.getUrl();
                rr.startClientRequest(iUrl, iUrl.getBytes().length, startTime, request.getRemoteAddr(), request.getMethod());

                User user = checkLogin(request);
                ogcrequest.checkRequestURL();

                rr.setUserAndOrganization(user, user.getMainOrganization());
                data.setHeader("X-Kaartenbalie-User", user.getUsername());

                parseRequestAndData(data, user);

            } catch (ProviderException pex) {
                log.error("Error while communicating with provider: " + pex.getLocalizedMessage());
                rr.setClientRequestException(pex);
                handleRequestException(pex, data);
            } catch (AccessDeniedException adex) {
                log.error("Error while logging in: " + adex.getLocalizedMessage());
                rr.setClientRequestException(adex);
                handleRequestException(adex, data);
            } catch (Exception ex) {
                log.error("Error while handling request: ", ex);
                rr.setClientRequestException(ex);
                handleRequestException(ex, data);
            } finally {
                rr.endClientRequest(serviceName, data.getOperation(), data.getContentLength(), System.currentTimeMillis() - startTime);
            }
            tx.commit();
        } catch (Exception ex) {
            log.error("Error creating EntityManager: ", ex);
            try {
                tx.rollback();
            } catch (Exception ex2) {
                log.error("Error trying to rollback: ", ex2);
            }
            handleRequestException(ex, data);
        } finally {
            log.debug("Closing entity manager .....");
            MyEMFDatabase.closeEntityManager(identity, MyEMFDatabase.MAIN_EM);
        }
    }

    /**
     *
     * @param request
     * @return
     * @throws java.io.UnsupportedEncodingException
     * @throws javax.xml.parsers.ParserConfigurationException
     * @throws org.xml.sax.SAXException
     * @throws java.io.IOException
     * @throws org.exolab.castor.xml.ValidationException
     * @throws java.lang.Exception
     */
    protected OGCRequest calcOGCRequest(HttpServletRequest request) throws UnsupportedEncodingException, ParserConfigurationException, SAXException, IOException, ValidationException, Exception {
        OGCRequest ogcrequest = null;

        StringBuffer baseUrl = createBaseUrl(request);
        String iUrl = completeUrl(baseUrl, request).toString();

        if (request.getMethod().equalsIgnoreCase("GET")) {
            ogcrequest = new OGCRequest(iUrl);
            log.info("Incoming Get URL: " + iUrl);
        } else if (request.getMethod().equalsIgnoreCase("POST")
                && request.getParameter(OGCConstants.SERVICE) != null
                && request.getParameter(OGCConstants.SERVICE).equalsIgnoreCase(OGCConstants.WMS_SERVICE_WMS)) {
            ogcrequest = new OGCRequest(iUrl);
            Enumeration params = request.getParameterNames();
            while (params.hasMoreElements()) {
                String paramName = (String) params.nextElement();
                String paramValue = request.getParameter(paramName);
                //Parameters zijn niet UTF8.
                if (paramName.equalsIgnoreCase("onload") || paramName.equalsIgnoreCase("ondata") || paramName.equalsIgnoreCase("loadmovie") || paramName.equalsIgnoreCase("oldloadmovie")) {
                    //do nothing
                } else {
                    ogcrequest.addOrReplaceParameter(paramName, paramValue);
                }
            }
            if (ogcrequest.getParameter(OGCRequest.WMS_PARAM_SLD_BODY) != null) {
                //<Name>demo_gemeenten_2006</Name>
                String sld_body = ogcrequest.getParameter(OGCRequest.WMS_PARAM_SLD_BODY);
                if (ogcrequest.getParameter(OGCRequest.WMS_PARAM_LAYERS) != null) {
                    String[] layersArray = ogcrequest.getParameter(OGCRequest.WMS_PARAM_LAYERS).split(",");
                    for (int i = 0; i < layersArray.length; i++) {
                        if (layersArray[i].indexOf("_") > -1 && layersArray[i].indexOf("_") < layersArray[i].length() - 1) {
                            String newLayer = layersArray[i].substring(layersArray[i].indexOf("_") + 1);
                            sld_body = sld_body.replaceAll("(?i)name>" + layersArray[i] + "<", "Name>" + newLayer + "<");
                        }
                    }
                }
                ogcrequest.addOrReplaceParameter(OGCRequest.WMS_PARAM_SLD_BODY, URLEncoder.encode(sld_body, "UTF-8"));
            }
            log.info("Incoming POST converted to GET URL: " + ogcrequest.getUrlWithNonOGCparams());
        } else {
            log.info("Incoming POST URL (content follows): " + iUrl);

//            ByteArrayOutputStream baos = new ByteArrayOutputStream();
//            int bytesRead = 0;
//            while ((bytesRead = request.getInputStream().read()) != -1) {
//                baos.write(bytesRead);
//            }
//            log.info("Incoming POST content: \n" + baos.toString());

            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            dbf.setNamespaceAware(true);
            dbf.setValidating(false);
            DocumentBuilder builder = dbf.newDocumentBuilder();
            Document doc = builder.parse(request.getInputStream());
            ogcrequest = new OGCRequest(doc.getDocumentElement(), baseUrl.toString());
            log.info("Incoming POST content: \n" + OgcWfsClient.elementToString(doc.getDocumentElement()));
        }
        ogcrequest.setHttpMethod(request.getMethod());
        return ogcrequest;
    }

    public static StringBuffer createBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = KBConfiguration.KB_SERVICES_CONTEXT_PATH;
        if (contextPath == null || contextPath.length() == 0) {
            contextPath = request.getContextPath();
        }

        StringBuffer theUrl = new StringBuffer();
        if (KBConfiguration.KB_SERVICES_SERVER_URI != null && KBConfiguration.KB_SERVICES_SERVER_URI.length() > 5) {
            theUrl.append(KBConfiguration.KB_SERVICES_SERVER_URI);
        } else {
            theUrl.append(scheme);
            theUrl.append("://");
            theUrl.append(serverName);
            if ((scheme.equals("http") && serverPort != 80) || (scheme.equals("https") && serverPort != 443)) {
                theUrl.append(":");
                theUrl.append(serverPort);
            }
        }
        theUrl.append(contextPath);
        return theUrl;
    }

    private StringBuffer requestUrl(StringBuffer baseUrl, HttpServletRequest request) {
        String servletPath = request.getServletPath();
        String pathInfo = request.getPathInfo();

        if (servletPath != null && servletPath.length() != 0) {
            baseUrl.append(servletPath);
        }
        if (pathInfo != null && pathInfo.length() != 0) {
            baseUrl.append(pathInfo);
        }
        return baseUrl;
    }

    private StringBuffer completeUrl(StringBuffer baseUrl, HttpServletRequest request) {
        baseUrl = requestUrl(baseUrl, request);
        String queryString = request.getQueryString();

        if (queryString != null && queryString.length() != 0) {
            baseUrl.append("?");
            baseUrl.append(queryString);
        }
        return baseUrl;
    }

    private String extractCode(HttpServletRequest request) {
        String code = request.getPathInfo();
        int pos = code.indexOf("/");
        if (pos < 0) {
            return code;
        }
        code = code.substring(pos + 1);
        pos = code.indexOf("/");
        if (pos < 0) {
            return code;
        }
        code = code.substring(0, pos);
        return code;
    }

    private void handleRequestException(Exception ex, DataWrapper data) throws IOException {
        OGCRequest ogcrequest = data.getOgcrequest();

        if (ogcrequest == null) {
            data.setContentType(OGCConstants.WMS_PARAM_EXCEPTION_XML);
            handleRequestExceptionAsXML(ex, data);
        } else if (ogcrequest.getParameter(OGCConstants.SERVICE) != null
                && ogcrequest.getParameter(OGCConstants.SERVICE).equals(OGCConstants.WFS_SERVICE_WFS)) {
            data.setContentType(OGCConstants.WMS_PARAM_EXCEPTION_XML);
            handleRequestExceptionAsXML(ex, data);
        } else {
            String exType = "";
            if (ogcrequest.containsParameter(OGCConstants.WMS_PARAM_EXCEPTIONS)) {
                exType = ogcrequest.getParameter(OGCConstants.WMS_PARAM_EXCEPTIONS);
            }
            String requestparam = "";
            if (ogcrequest.containsParameter(OGCConstants.REQUEST)) {
                requestparam = ogcrequest.getParameter(OGCConstants.REQUEST);
            }
            if ((requestparam.equalsIgnoreCase(OGCConstants.WMS_REQUEST_GetMap)
                    || requestparam.equalsIgnoreCase(OGCConstants.WMS_REQUEST_GetLegendGraphic))
                    && (exType.equalsIgnoreCase(OGCConstants.WMS_PARAM_EXCEPTION_INIMAGE)
                    || exType.equalsIgnoreCase(OGCConstants.WMS_PARAM_SHORT_EXCEPTION_INIMAGE))
                    && ogcrequest.containsParameter(OGCConstants.WMS_PARAM_FORMAT)
                    && ogcrequest.containsParameter(OGCConstants.WMS_PARAM_WIDTH)
                    && ogcrequest.containsParameter(OGCConstants.WMS_PARAM_HEIGHT)) {
                data.setContentType(ogcrequest.getParameter(OGCConstants.WMS_PARAM_FORMAT));
                handleRequestExceptionAsImage(ex, data);
            } else {
                data.setContentType(OGCConstants.WMS_PARAM_EXCEPTION_XML);
                handleRequestExceptionAsXML(ex, data);
            }
        }
    }

    private void handleRequestExceptionAsImage(Exception ex, DataWrapper data) throws IOException {
        String message = ex.getMessage();
        try {
            ExceptionLayer el = new ExceptionLayer();
            Map parameterMap = new HashMap();
            parameterMap.put("type", ex.getClass());
            parameterMap.put("transparant", Boolean.TRUE);
            parameterMap.put("message", message);
            parameterMap.put("stacktrace", ex.getStackTrace());
            el.sendImage(data, el.drawImage(data.getOgcrequest(), parameterMap));
        } catch (Exception e) {
            log.error("error handling exception: ", e);
            TextToImage tti = new TextToImage();
            try {
                tti.createImage(message, data);
            } catch (Exception lex) {
                log.error("error creating error-image: ", lex);
            }
        }
    }

    private void handleRequestExceptionAsXML(Exception ex, DataWrapper data) throws IOException {
        ByteArrayOutputStream output = null;
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setValidating(false);
        DocumentBuilder db = null;
        try {
            db = dbf.newDocumentBuilder();
        } catch (Exception e) {
            log.error("error: ", e);
            throw new IOException("Exception occured during creation of error message: " + e);
        }

        DOMImplementation di = db.getDOMImplementation();

        // <!DOCTYPE ServiceExceptionReport SYSTEM "http://schemas.opengeospatial.net/wms/1.1.1/exception_1_1_1.dtd"
        // <!-- end of DOCTYPE declaration -->
        DocumentType dt = di.createDocumentType("ServiceExceptionReport", null, CallWMSServlet.EXCEPTION_DTD);
        Document dom = di.createDocument(null, "ServiceExceptionReport", dt);
        Element rootElement = dom.getDocumentElement();
        rootElement.setAttribute("version", "1.1.1");

        Element serviceExceptionElement = dom.createElement("ServiceException");

        String exceptionName = ex.getClass().getName();
        String message = ex.getMessage();
        Throwable cause = ex.getCause();

        serviceExceptionElement.setAttribute("code", exceptionName);
        CDATASection cdata = null;
        if (cause != null) {
            cdata = dom.createCDATASection(message + " - " + cause);
        } else {
            cdata = dom.createCDATASection(message);
        }

        serviceExceptionElement.appendChild(cdata);
        rootElement.appendChild(serviceExceptionElement);

        OutputFormat format = new OutputFormat(dom);
        format.setIndenting(true);
        output = new ByteArrayOutputStream();
        XMLSerializer serializer = new XMLSerializer(output, format);
        serializer.serialize(dom);

        DOMValidator dv = new DOMValidator();
        try {
            dv.parseAndValidate(new ByteArrayInputStream(output.toString().getBytes(KBConfiguration.CHARSET)));
        } catch (Exception e) {
            log.error("error: ", e);
            throw new IOException("Exception occured during validation of error message: " + e);
        }

        data.setHeader("Content-Disposition", "inline; filename=\"ServiceException.xml\";");
        data.write(output);
    }

    /** Checks if an user is allowed to make any requests.
     * Therefore there is checked if a user is logged in or if a user is using a private unique IP address.
     *
     * @param parameters The parameters of a given request
     *
     * @return Map with the same parameters and same key all in uppercase
     */
    // <editor-fold defaultstate="" desc="getUpperCaseParameterMap(Map parameters) method.">
    private Map getUpperCaseParameterMap(Map parameters) {
        Map newParameterMap = new HashMap();
        Set paramKeySet = parameters.keySet();
        Iterator keySetIterator = paramKeySet.iterator();
        while (keySetIterator.hasNext()) {
            String key = (String) keySetIterator.next();
            String value = ((String[]) parameters.get(key))[0];

            String caseInsensitiveKey = key.toUpperCase();
            String caseInsensitiveValue = value.toUpperCase();

            newParameterMap.put(caseInsensitiveKey, caseInsensitiveValue);
        }
        return newParameterMap;
    }
    // </editor-fold>

    /** Checks if an user is allowed to make any requests.
     * Therefore there is checked if a user is logged in or if a user is using a private unique IP address.
     *
     * @param request servlet request
     *
     * @return user object
     *
     * @throws NoSuchAlgorithmException
     * @throws UnsupportedEncodingException
     * @throws AccessDeniedException
     * @throws Exception
     */
    protected User checkLogin(HttpServletRequest request) throws NoSuchAlgorithmException, UnsupportedEncodingException, AccessDeniedException, Exception {
        log.debug("Getting entity manager ......");
        EntityManager em = MyEMFDatabase.getEntityManager(MyEMFDatabase.MAIN_EM);

        User user = null;
        String code = extractCode(request);

        // checken of user gewoon ingelogd is
        if (user == null) {
            user = (User) request.getUserPrincipal();
            if (user != null) {
                String userCode = user.getPersonalURL();
                if (code != null && userCode != null && !code.equals(userCode)) {
                    // verkeerde user
                    user = null;
                }
            }
            if (user != null) {
                log.info("Cookie accepted for login, username: " + user.getName());
            }
        }


        if (user == null) {

            // probeer eerst personal url, checken op token in url
            try {
                log.debug("Check code for login: " + code);

                user = (User) em.createQuery(
                        "from User u where "
                        + "u.personalURL = :personalURL").setParameter("personalURL", code).getSingleResult();
                em.flush();


            } catch (NonUniqueResultException nue) {
                log.error("More than one person found for this url (to be fixed in database), trying next method.");
                user = null;
            } catch (NoResultException nre) {
                log.debug("Personal url not found, trying next method.");
                user = null;
            }
 
            if (user != null) {
                java.util.Date date = user.getTimeout();
                if (date.getTime() <= (new java.util.Date().getTime())) {
                    log.debug("Personal URL key has expired, trying next method.");
                    user = null;
                }
            }

            if (user != null) {
                String remoteaddress = request.getRemoteAddr();
                boolean validip = false;

                Set ipaddresses = user.getIps();
                Iterator it = ipaddresses.iterator();
                while (it.hasNext()) {
                    String ipaddress = (String) it.next();
                    if (ipaddress.equalsIgnoreCase(remoteaddress)
                            || ipaddress.equalsIgnoreCase("0.0.0.0")
                            || ipaddress.equalsIgnoreCase("::")) {
                        validip = true;
                        break;
                    }
                }

                if (!validip) {
                    log.debug("Personal URL not usuable for this IP address, trying next method");
                    user = null;
                }
            }
            if (user != null) {
                log.info("Personal URL accepted for login, username: " + user.getName());
            }
        }

        // probeer preemptive basic login
        if (user == null) {
            // attempt to dig out authentication info only if the user has not yet been authenticated
            String authorizationHeader = request.getHeader("Authorization");
            if (authorizationHeader != null) {
                String decoded = decodeBasicAuthorizationString(authorizationHeader);
                String username = parseUsername(decoded);
                String password = parsePassword(decoded);

                String encpw = null;
                try {
                    encpw = KBCrypter.encryptText(password);
                } catch (Exception ex) {
                    log.error("error encrypting password: ", ex);
                }
                try {
                    user = (User) em.createQuery(
                            "from User u where "
                            + "lower(u.username) = lower(:username) "
                            + "and u.password = :password").setParameter("username", username).setParameter("password", encpw).getSingleResult();
                    em.flush();
                } catch (NonUniqueResultException nue) {
                    log.error("More than one person found for these credentials (to be fixed in database), trying next method.");
                    user = null;
                } catch (NoResultException nre) {
                    user = null;
                    log.debug("No results using encrypted password, trying next method");
                }

                // extra check voor oude non-encrypted passwords
                if (user == null) {
                    try {
                        user = (User) em.createQuery(
                                "from User u where "
                                + "lower(u.username) = lower(:username) "
                                + "and lower(u.password) = lower(:password)").setParameter("username", username).setParameter("password", password).getSingleResult();

                        // Volgende keer dus wel encrypted
                        user.setPassword(encpw);
                        em.merge(user);
                        em.flush();
                        log.debug("Cleartext password now encrypted!");
                    } catch (NonUniqueResultException nue) {
                        log.error("More than one person found for these (cleartext) credentials (to be fixed in database), trying next method.");
                        user = null;
                    } catch (NoResultException nre) {
                        log.debug("No results using cleartext password, trying next method.");
                    }
                }
            }
            if (user != null) {
                log.info("Basic authentication accepted for login, username: " + user.getName());
            }
        }

        // hebben we nu een user?
        if (user == null) {
            throw new AccessDeniedException("Authorisation required for this service! No credentials found in Personal url, Authentication header or Cookie, Giving up! ");
        }

        return user;
    }

    /** Parses any incoming request and redirects this request to the right handler.
     *
     * @param parameters map with the given parameters
     *
     * @return byte array with the requested data
     *
     * @throws IllegalArgumentException
     * @throws UnsupportedOperationException
     * @throws IOException
     */
    public void parseRequestAndData(DataWrapper data, User user) throws IllegalArgumentException, UnsupportedOperationException, IOException, Exception {
        String request = data.getOgcrequest().getParameter(OGCConstants.REQUEST);
        String service = data.getOgcrequest().getParameter(OGCConstants.SERVICE);

        RequestHandler requestHandler = null;
        if (service != null && service.length() > 0) {
            if (service.equalsIgnoreCase(OGCConstants.NONOGC_SERVICE_PROXY)) {
                requestHandler = new ProxyRequestHandler();
            } else if (service.equalsIgnoreCase(OGCConstants.NONOGC_SERVICE_METADATA)) {
                requestHandler = new MetadataRequestHandler();
            } else if (service.equalsIgnoreCase(OGCConstants.WMS_SERVICE_WMS)) {
                if (request.equalsIgnoreCase(OGCConstants.WMS_REQUEST_GetCapabilities)) {
                    requestHandler = new GetCapabilitiesRequestHandler();
                }
            } else if (service.equalsIgnoreCase(OGCConstants.WFS_SERVICE_WFS)) {
                if (request.equalsIgnoreCase(OGCConstants.WFS_REQUEST_GetCapabilities)) {
                    requestHandler = new WFSGetCapabilitiesRequestHandler();
                }
            }
        }

        if (requestHandler == null) {
            if (request.equalsIgnoreCase(OGCConstants.WMS_REQUEST_GetMap)) {
                requestHandler = new GetMapRequestHandler();
                service = OGCConstants.WMS_SERVICE_WMS;
            } else if (request.equalsIgnoreCase(OGCConstants.WMS_REQUEST_GetFeatureInfo)) {
                requestHandler = new GetFeatureInfoRequestHandler();
                service = OGCConstants.WMS_SERVICE_WMS;
            } else if (request.equalsIgnoreCase(OGCConstants.WMS_REQUEST_GetLegendGraphic)) {
                requestHandler = new GetLegendGraphicRequestHandler();
                service = OGCConstants.WMS_SERVICE_WMS;
            } else if (request.equalsIgnoreCase(OGCConstants.WMS_REQUEST_DescribeLayer)) {
                requestHandler = new DescribeLayerRequestHandler();
                service = OGCConstants.WMS_SERVICE_WMS;
            } else if (request.equalsIgnoreCase(OGCConstants.WFS_REQUEST_DescribeFeatureType)) {
                requestHandler = new WFSDescribeFeatureTypeRequestHandler();
                service = OGCConstants.WFS_SERVICE_WFS;
            } else if (request.equalsIgnoreCase(OGCConstants.WFS_REQUEST_GetFeature)) {
                requestHandler = new WFSGetFeatureRequestHandler();
                service = OGCConstants.WFS_SERVICE_WFS;
            } else if (request.equalsIgnoreCase(OGCConstants.WFS_REQUEST_Transaction)) {
                requestHandler = new WFSTransactionRequestHandler();
                service = OGCConstants.WFS_SERVICE_WFS;
            }
        }

        if (requestHandler == null) {
            throw new UnsupportedOperationException("Request " + request + " is not suported!");
        }

        data.setOperation(request);
        data.setService(service);
        requestHandler.getRequest(data, user);
    }

    /** Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /** Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /** Returns a short description of the servlet.
     */
    @Override
    public String getServletInfo() {
        return "CallWMSServlet info";
    }

    /**
     * Parse the username out of the BASIC authorization header string.
     * @param decoded
     * @return username parsed out of decoded string
     */
    private String parseUsername(String decoded) {
        if (decoded == null) {
            return null;
        } else {
            int colon = decoded.indexOf(':');
            if (colon < 0) {
                return null;
            } else {
                return decoded.substring(0, colon).trim();
            }
        }
    }

    /**
     * Parse the password out of the decoded BASIC authorization header string.
     * @param decoded
     * @return password parsed out of decoded string
     */
    private String parsePassword(String decoded) {
        if (decoded == null) {
            return null;
        } else {
            int colon = decoded.indexOf(':');
            if (colon < 0) {
                return (null);
            } else {
                return decoded.substring(colon + 1).trim();
            }
        }
    }

    /**
     * Decode the BASIC authorization string.
     *
     * @param authorization
     * @return decoded string
     */
    private String decodeBasicAuthorizationString(String authorization) {
        if (authorization == null || !authorization.toLowerCase().startsWith("basic ")) {
            return null;
        } else {
            authorization = authorization.substring(6).trim();
            // Decode and parse the authorization credentials
            return new String(Base64.decodeBase64(authorization.getBytes()));
        }
    }

    public static void main(String[] args) throws UnsupportedEncodingException, IOException, ParserConfigurationException, SAXException {
        HttpClient client = new HttpClient();
        client.getParams().setParameter("http.protocol.version", HttpVersion.HTTP_1_0);
        client.getHttpConnectionManager().getParams().setConnectionTimeout(10000);
        client.getParams().setAuthenticationPreemptive(true);
        Credentials defaultcreds = new UsernamePasswordCredentials("Beheerder", "***REMOVED***");
        AuthScope authScope = new AuthScope("localhost", 8084);
        client.getState().setCredentials(authScope, defaultcreds);

        HttpMethod method = null;


        // POST
        String postUrl = "http://localhost:8084/kaartenbalie/services/";
        String postBody = "<GetFeature xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.opengis.net/wfs\" xsi:schemaLocation=\"http://www.opengis.net/wfs ../wfs/1.1.0/WFS.xsd\" version=\"1.0.0\" service=\"WFS\"><Query typeName=\"app:Bestemmingsplangebied\"  /></GetFeature>";
//        xmlns:app=\"http://bla\"
        method = new PostMethod(postUrl);
        //work around voor ESRI post Messages
        //method.setRequestEntity(new StringRequestEntity(body, "text/xml", "UTF-8"));
        ((PostMethod) method).setRequestEntity(new StringRequestEntity(postBody, null, null));


        // GET
//        String getUrl = "http://localhost:8084/kaartenbalie/services/";
//        method = new GetMethod(getUrl);

        int status = client.executeMethod(method);
        if (status == HttpStatus.SC_OK) {
            InputStream is = method.getResponseBodyAsStream();
            InputStream isx = null;
            byte[] bytes = null;
            int len = 1;
            byte[] buffer = new byte[2024];
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            while ((len = is.read(buffer, 0, buffer.length)) > 0) {
                bos.write(buffer, 0, len);
            }
            bytes = bos.toByteArray();
            System.out.println(new String(bytes));
            isx = new ByteArrayInputStream(bytes);

            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            dbf.setNamespaceAware(true);
            DocumentBuilder builder = dbf.newDocumentBuilder();
            Document doc = builder.parse(isx);
            System.out.println("parse klaar");
        }

        System.out.println("klaar");
    }
}
