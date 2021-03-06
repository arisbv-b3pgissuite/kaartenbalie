package nl.b3p.kaartenbalie.service.servlet;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import nl.b3p.commons.services.FileManagerServlet;
import nl.b3p.kaartenbalie.core.server.User;
import nl.b3p.kaartenbalie.core.server.persistence.MyEMFDatabase;
import nl.b3p.kaartenbalie.service.AccessDeniedException;
import nl.b3p.wms.capabilities.Roles;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
  * @author Chris van Lith
 */
public class UpDownloadServlet extends FileManagerServlet {

    protected static Log log = LogFactory.getLog(UpDownloadServlet.class);

    public void init(ServletConfig config) throws ServletException {
        super.init(config);

        if (locationPrefix == null || locationPrefix.isEmpty()) {
            locationPrefix =  MyEMFDatabase.getUpload();
        }
    }

    /**
     * ask general servlet if user may be logged in
     * @param request
     * @param response
     * @throws Exception
     */
    protected void checkPostLogin(HttpServletRequest request, HttpServletResponse response) throws Exception {
        try {
            User user = GeneralServlet.checkLogin(request, null);
            log.debug("Username: " + user == null ? "(null)" : user.getName());
            if (user!= null && !user.checkRole(Roles.ADMIN)
                    && !user.checkRole(Roles.ORG_ADMIN)
                    && !user.checkRole(Roles.THEME_ADMIN)) {
                // not enough rights
                user = null;
            }
            if (user == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access forbidden for Kaartenbalie");
            }
        } catch (AccessDeniedException ex) {
            response.addHeader("WWW-Authenticate","Basic realm=\"Kaartenbalie login\"");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Access denied for Kaartenbalie");
        }
    }

    /**
     * no login required for get
     * @param request
     * @param response
     * @throws Exception
     */
    protected void checkGetLogin(HttpServletRequest request, HttpServletResponse response) throws Exception {
        return;
    }

    /**
     * ask general servlet to create base url
     * @param request
     * @return
     */
    protected static String createBaseUrl(HttpServletRequest request) {

        return GeneralServlet.createBaseUrl(request).toString();
    }
}
