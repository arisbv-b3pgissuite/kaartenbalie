/**
 * @(#)ServerAction.java
 * @author N. de Goeij
 * @version 1.00 2006/10/02
 *
 * Purpose: a Struts action class defining all the Action for the ServiceProvider view.
 *
 * @copyright 2007 All rights reserved. B3Partners
 */

package nl.b3p.kaartenbalie.struts;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import nl.b3p.commons.services.FormUtils;
import nl.b3p.kaartenbalie.core.server.Organization;
import nl.b3p.kaartenbalie.core.server.ServiceProvider;
import nl.b3p.kaartenbalie.core.server.User;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForward;
import org.apache.struts.validator.DynaValidatorForm;
import org.hibernate.HibernateException;
import org.hibernate.Session;

public class ServerActionDemo extends ServerAction {

    /* forward name="success" path="" */
    private final static String SUCCESS = "success";
    
    /** Execute method which handles all executable requests.
     *
     * @param mapping The ActionMapping used to select this instance.
     * @param form The DynaValidatorForm bean for this request.
     * @param request The HTTP Request we are processing.
     * @param response The HTTP Response we are processing.
     *
     * @return an Actionforward object.
     *
     * @throws Exception
     */
    // <editor-fold defaultstate="" desc="execute(ActionMapping mapping, DynaValidatorForm dynaForm, HttpServletRequest request, HttpServletResponse response) method.">
    public ActionForward unspecified(ActionMapping mapping, DynaValidatorForm dynaForm, HttpServletRequest request, HttpServletResponse response) throws Exception {
        String userid = (String) request.getParameter("userid");
        ActionForward action = super.unspecified(mapping, dynaForm, request, response);
        dynaForm.set("userid", userid);
        return action;
    }
    // </editor-fold>
    
    /** Method for saving a new service provider from input of a user.
     *
     * @param mapping The ActionMapping used to select this instance.
     * @param form The DynaValidatorForm bean for this request.
     * @param request The HTTP Request we are processing.
     * @param response The HTTP Response we are processing.
     *
     * @return an Actionforward object.
     *
     * @throws Exception
     */
    // <editor-fold defaultstate="" desc="save(ActionMapping mapping, DynaValidatorForm dynaForm, HttpServletRequest request, HttpServletResponse response) method.">
    public ActionForward save(ActionMapping mapping, DynaValidatorForm dynaForm, HttpServletRequest request, HttpServletResponse response) throws Exception {
        //if invalid
        if (!isTokenValid(request)) {
            prepareMethod(dynaForm, request, EDIT, LIST);
            addAlternateMessage(mapping, request, TOKEN_ERROR_KEY);
            return getAlternateForward(mapping, request);
        }
        
        // nieuwe default actie op delete zetten
        Session sess = getHibernateSession();
        //validate and check for errors
        ActionErrors errors = dynaForm.validate(mapping, request);
        if(!errors.isEmpty()) {
            addMessages(request, errors);
            prepareMethod(dynaForm, request, EDIT, LIST);
            addAlternateMessage(mapping, request, VALIDATION_ERROR_KEY);
            return getAlternateForward(mapping, request);
        }
        
        Integer id = FormUtils.StringToInteger(dynaForm.getString("id"));
        ServiceProvider serviceProvider = getServiceProvider(dynaForm,request,true);
                
        if (null == serviceProvider) {
            prepareMethod(dynaForm, request, LIST, EDIT);
            addAlternateMessage(mapping, request, NOTFOUND_ERROR_KEY);
            return getAlternateForward(mapping, request);
        }
        
        WMSCapabilitiesReader wms = new WMSCapabilitiesReader(serviceProvider);
        String url = dynaForm.getString("serviceProviderUrl");
        
        //check this URL, if no parameters are given, fill them in yourself with the standard options
        //Split eerst in twee delen, namelijk daar waar het vraagteken zich bevindt
        String [] urls = url.split("\\?");
        url = urls[0] + "?";
        
        boolean req = false, version = false, service = false;        
        String [] params = urls[1].split("&");
        for (int i = 0; i < params.length; i++) {
            String [] paramValue = params[i].split("=");
            if (!paramValue[0].equalsIgnoreCase("REQUEST") &&
                !paramValue[0].equalsIgnoreCase("VERSION") &&
                !paramValue[0].equalsIgnoreCase("SERVICE")) {
                url += paramValue[0] + "=" + paramValue[1] + "&";
            }
        }
        
        url += "REQUEST=GetCapabilities&VERSION=1.1.1&SERVICE=WMS";
        
        try {
            serviceProvider = wms.getProvider(url);
        } catch (Exception e) {
            request.setAttribute("message", "De opgegeven URL is onjuist. Probeert u het alstublieft opnieuw.");
            return getAlternateForward(mapping, request);
        }
        
        populateServerObject(dynaForm, serviceProvider);
                
        String userid = dynaForm.getString("userid");
        
        User user = null;
        try {
            user = getUser(dynaForm, request, false, new Integer(Integer.parseInt(userid)));
        } catch (Exception e) {
            request.setAttribute("message", "U dient zich eerst te registreren voordat u een WMS server toe kunt voegen.");
            return getAlternateForward(mapping, request);
        }
        
        Organization org = user.getOrganization();
        org.setOrganizationLayer(serviceProvider.getLayers());
        
        sess.saveOrUpdate(serviceProvider);
        sess.saveOrUpdate(org);
        sess.flush();
        
        dynaForm.set("id", "");
        dynaForm.set("serviceProviderGivenName", "");
        dynaForm.set("serviceProviderUrl", "");
        dynaForm.set("serviceProviderUpdatedDate", "");
        dynaForm.set("serviceProviderReviewed", "");
        
        return mapping.findForward("nextPage");
    }
    // </editor-fold>
    
    /** Method which returns the user with a specified id.
     *
     * @param form The DynaValidatorForm bean for this request.
     * @param request The HTTP Request we are processing.
     * @param createNew A boolean which indicates if a new object has to be created.
     * @param id An Integer indicating which organization id has to be searched for.
     *
     * @return a User object.
     */
    // <editor-fold defaultstate="" desc="getUser(DynaValidatorForm dynaForm, HttpServletRequest request, boolean createNew, Integer id) method.">
    private User getUser(DynaValidatorForm dynaForm, HttpServletRequest request, boolean createNew, Integer id) throws HibernateException {
        Session session = getHibernateSession();
        User user = null;
        
        if(null == id && createNew) {
            user = new User();
        } else if (null != id) {
            user = (User)session.load(User.class, new Integer(id.intValue()));
        }
        return user;
    }
    // </editor-fold>
    
    /** Method for deleting a serviceprovider selected by a user.
     *
     * @param mapping The ActionMapping used to select this instance.
     * @param form The DynaValidatorForm bean for this request.
     * @param request The HTTP Request we are processing.
     * @param response The HTTP Response we are processing.
     *
     * @return an Actionforward object.
     *
     * @throws Exception
     */
    // <editor-fold defaultstate="" desc="delete(ActionMapping mapping, DynaValidatorForm dynaForm, HttpServletRequest request, HttpServletResponse response) method.">
    public ActionForward delete(ActionMapping mapping, DynaValidatorForm dynaForm, HttpServletRequest request, HttpServletResponse response) throws Exception {
        return null;
    }
    // </editor-fold>
}