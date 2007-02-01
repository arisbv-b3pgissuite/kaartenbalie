/**
 * @(#)WMSRequestHandler.java
 * @author N. de Goeij
 * @version 1.00 2006/12/13
 *
 * Purpose: Superclass of all the WMS request classes. Subclasses which belong to this superclass are:
 * - GetCapabilitiesRequestHandler
 * - GetMapRequestHandler
 * - GetFeatureInfoRequestHandler
 * - GetLegendGraphicRequestHandler
 * - GetStylesRequestHandler
 * - DescribeLayerRequestHandler
 *
 * @copyright 2007 All rights reserved. B3Partners
 */

package nl.b3p.kaartenbalie.service.requesthandler;

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Component;
import java.awt.Frame;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.imageio.ImageIO;
import nl.b3p.kaartenbalie.core.KBConstants;
import nl.b3p.kaartenbalie.core.server.Layer;
import nl.b3p.kaartenbalie.core.server.ServiceDomainResource;
import nl.b3p.kaartenbalie.core.server.ServiceProvider;
import nl.b3p.kaartenbalie.core.server.Organization;
import nl.b3p.kaartenbalie.core.server.User;
import nl.b3p.kaartenbalie.service.MyDatabase;
import org.hibernate.Session;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Transaction;

public abstract class WMSRequestHandler implements RequestHandler, KBConstants {
    
    private static final Log log = LogFactory.getLog(WMSRequestHandler.class);
    protected User user;
    protected String url;
    
    public WMSRequestHandler() { }
    
    // TODO:
    // De onderstaande methode maakt gebruik van een stuk code dat controleert welke van de opgevraagde ServiceProviders
    // de minste aantal capabilities heeft. Dit stukje code moet ofwel aangepast worden zodat het programma zelf uitzoekt
    // welke capability bij welke provider wel of niet mogelijk is, of ze moet er helemaal uitgehaald worden.
    // Niet alleen moet er gecontroleerd worden welke de minste capabilities heeft, maar daarnaast moet er ook gecontroleerd
    // worden of de capabilities dan wel allemaal gelijk zijn aan elkaar, dus eigenlijk moet er gekeken worden naar het mini
    // male aanbod van allemaal dezelfde capabilities.
    // Dit stukje code moet vervolgens ook dusdanig gecommentarieerd worden.
    
    /** Creates a List of ServiceProviders recieved from the Database.
     * If the boolean is set to true, this method creates a single ServiceProvider in a List which holds again all
     * layers supported by the kaartenbalie. Otherwise if the boolean is set to false the method will get each single
     * ServiceProvider from the database and stores these seperatly, with their own layers, in the List.
     *
     * @param combine boolean wether to combine the serviceproviders or not
     * @return a list of the serviceproviders
     */
    // <editor-fold defaultstate="collapsed" desc="getServiceProviders(boolean combine) method.">
    protected List getServiceProviders(boolean combine) {
        
        Session sess = MyDatabase.currentSession();
        //sess.createQuery("from Layer l left join fetch l.latLonBoundingBox left join fetch l.attribution").list();
        //Set dbLayers = user.getOrganization().getOrganizationLayer();
        User dbUser = null;
        Set <Layer> layers = new HashSet <Layer>();
        ServiceProvider sp = null;
        List <ServiceProvider> sps = new ArrayList <ServiceProvider>();
        
        Transaction tx = sess.beginTransaction();
        try {
            dbUser = (User)sess.createQuery("from User u where " +
                    "lower(u.id) = lower(:userid)").setParameter("userid", user.getId()).uniqueResult();
        
        
        Set dbLayers = dbUser.getOrganization().getOrganizationLayer();

        if (dbLayers==null)
            return null;
        
        //Initialize a couple of variables
        
        
        int shortestCapabilities = 7;
        
        
        Iterator it = dbLayers.iterator();
        while (it.hasNext()) {
            Layer dbLayer = (Layer)it.next();
            if(null == dbLayer.getParent()) {
                ServiceProvider testSP = (ServiceProvider)(dbLayer.getServiceProvider());
                                
                ServiceProvider cloneSP = (ServiceProvider)(testSP.clone());
                Layer cloneLayer = (Layer)dbLayer.clone();
                
                cloneSP.setLayers(null);
                cloneSP.addLayer(cloneLayer);
                
                if (combine) {
                    int size = cloneSP.getDomainResource().size();
                    // TODO
                    // wat gebeurt hier???
                    if (size < shortestCapabilities) {
                        shortestCapabilities = size;
                        sp = cloneSP;
                        sp.setLayers(null);
                    }
                    layers.add(cloneLayer);
                } else {
                    sps.add(cloneSP);
                }
            }
        }
        
        } finally {
            tx.commit();
        }
        
        if (combine) {
            Layer layer = new Layer();
            layer.setLayers(layers);
            sp.addLayer(layer);
            sps.add(sp);
        }
        return sps;
    }
    // </editor-fold>
    
    // TODO:
    // De functie heeft nog geen manier voor het toepassen van de juiste encoding.
    // Deze moet nog geimplementeerd worden.        
    
    
    /** Creates a byte array of a given String.
     * @param xml string representing the xml document
     * @return byte array of the recieved data
     *
     * @throws IOException
     */
    // <editor-fold defaultstate="collapsed" desc="getOnlineData(String xml) method.">
    protected static byte[] getOnlineData(String xml) throws IOException {
        return xml.getBytes(CHARSET_UTF8);
    }
    // </editor-fold>
    
    /** Creates a byte array of a given StringBuffer array with urls. Each of the url will be used for a connection to 
     * the ServiceProvider which this url holds.
     *
     * @param urls StringBuffer with the urls where kaartenbalie should connect to to recieve the requested data.
     * @return byte[]
     *
     * @throws IOException
     */
    // <editor-fold defaultstate="collapsed" desc="getOnlineData(StringBuffer [] urls) method.">
    protected static byte[] getOnlineData(ArrayList urls) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        BufferedImage [] bi = null;
        
        /* To save time, this method checks first if the ArrayList contains more then one url
         * If it contains only one url then the method doesn't have to load the image into the G2D
         * environment, which saves a lot of time and capacity because it doesn't have to decode
         * and recode the image.
         */
        if (urls.size() > 1) {
            bi = new BufferedImage [urls.size()];
            
            for (int i = 0; i < urls.size(); i++) {
                String url = ((StringBuffer)urls.get(i)).toString();
                URL u = new URL(url);
                bi[i] = ImageIO.read(u);
            }
            
            Frame f = new Frame();
            f.setVisible(true);
            Image image = f.createImage(bi[0].getWidth(), bi[0].getHeight());
            Graphics graphics = image.getGraphics();
            f.setVisible(false);
            Graphics2D g2 = (Graphics2D) graphics;
            
            BufferedImage buffImg = new BufferedImage(bi[0].getWidth(), bi[0].getHeight(), BufferedImage.TYPE_INT_ARGB);
            Graphics2D gbi = buffImg.createGraphics();

            // Clears the previously drawn image.
            g2.setColor(Color.white);
            g2.fillRect(0, 0, bi[0].getWidth(), bi[0].getHeight());

            gbi.drawImage(bi[0], 0, 0, null);
            gbi.setComposite(AlphaComposite.getInstance(AlphaComposite.DST_OVER, 1.0f));
            
            for (int i = 1; i < urls.size(); i++) {
                gbi.drawImage(bi[i], 0, 0, null);
            }

            ImageIO.write(buffImg, "png", baos);
            
            
            
            /* For each url in the ArrayList a new BufferedImage is created in order to lay those
             * images over eachother and combine them into one image
             *            
            for (int i = 0; i < urls.size(); i++) {
                String url = ((StringBuffer)urls.get(i)).toString();
                URL u = new URL(url);
                bi[i] = ImageIO.read(u);
                ByteArrayOutputStream baosTest = new ByteArrayOutputStream();
                ImageIO.write(bi[i], "png", baosTest);
                byte [] byteTest = baosTest.toByteArray();
                String test = new String (byteTest);
                System.out.println("New incoming picture converted to a byte Array. Size of the incoming pictute is : " + test.length());
            }
            //Test of the incoming pictures.....
            
            
                    
            /* After creating the BufferedImages, a Graphics 2D environment is set up in which the images
             * can be projected over eachother.
             * An AlphaComposite.SRC_OVER, 1.0f is used to let transparent parts of the tops layers be totally transparent.
             *
            Graphics2D g = bi[0].createGraphics();
            
            bi[0].isAlphaPremultiplied();
            
            AlphaComposite ac = (AlphaComposite) g.getComposite();
            ac.getAlpha();
            
            g.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 1.0f));
            
            /* Each of the layers recieved from a different url is projected on top of the previous layers
             * NOTICE that a new image is projected over the previous images. So we start with BufferedImage 0
             * project image 1 over it, etc, etc.
             *
            for (int i = 1; i < urls.size(); i++) {
                if(bi[i] != null) {
                    g.drawImage(bi[i], (bi[i-1].getWidth()-bi[i].getWidth())/2, (bi[i-1].getHeight()-bi[i].getHeight())/2, null);
                    
                }
            }
            
            Component c = new Component();
            
            Graphics2D g2d = bi[0].createGraphics();
            g2d.create();
            g.dispose();
            ImageIO.write(bi[0], "png", baos);
            ImageIO.write(bi[0], "png", new File("test.png"));//(bi[0], "png", baos); */
        } else {
            String url = ((StringBuffer)urls.get(0)).toString();
            
            /*
             * Because only one url is defined, the images don't have to be loaded into a
             * BufferedImage. The data recieved from the url can be directly transported to the client.
             */
            URL u = new URL(url);
            HttpURLConnection con = (HttpURLConnection) u.openConnection();
            
            BufferedInputStream bis = null;
            try {
                bis = new BufferedInputStream(con.getInputStream());
                byte[] buffer = new byte[8192];
                int read;
                while ((read = bis.read()) > -1) {
                    baos.write(read);
                }
            } finally {
                if (bis!=null)
                    bis.close();
            }
        }
        return baos.toByteArray();
    }
    // </editor-fold>
    
    /** Tries to find a specified layer given for a certain ServiceProvider.
     *
     * @param layers the set with layers which the method has to surch through
     * @param l the layer to be found
     * @param s the ServiceProvider which the layer belongs to
     *
     * @return string with the name of the found layer or null if no layer was found
     */
    // <editor-fold defaultstate="collapsed" desc="findLayer(Set layers, String l, ServiceProvider s) method.">
    protected String findLayer(Set layers, String l, ServiceProvider s) {
        if (layers==null || layers.isEmpty())
            return null;
        
        Iterator it = layers.iterator();
        while (it.hasNext()) {
            Layer layer = (Layer) it.next();
            String identity = layer.getId() + "_" + layer.getName();
            if(identity.equalsIgnoreCase(l) && layer.getServiceProvider().getId().equals(s.getId()))
                return layer.getName();
            
            String foundLayer = findLayer(layer.getLayers(), l, s);
            if (foundLayer != null)
                return foundLayer;
        }
        
        return null;
    }
    // </editor-fold>
    
    /** Builds a Stringbuffer of the layers found in the database and compared with the requested layers.
     * @param serviceProvider ServiceProvider to which the layers belong
     * @param layer string array with layersto be found and added to the list
     *
     * @return string with all the request layers
     */
    // <editor-fold defaultstate="collapsed" desc="calcFormattedLayers(ServiceProvider serviceProvider, String[] layer) method.">
    protected String calcFormattedLayers(ServiceProvider serviceProvider, String[] layer) {
        if (serviceProvider==null)
            return null;
        Set spLayers = serviceProvider.getLayers();
        if (spLayers==null || spLayers.size()==0)
            return null;
        StringBuffer requestedLayers = null;
        for (int i = 0; i < layer.length; i++) {
            String foundLayer = findLayer(spLayers, layer[i], serviceProvider);
            if (foundLayer==null)
                continue;
            if (requestedLayers==null)
                requestedLayers = new StringBuffer();
            else
                requestedLayers.append(",");
            requestedLayers.append(foundLayer);
        }
        if (requestedLayers==null)
            return null;
        return requestedLayers.toString();
    }
    // </editor-fold>
    
    
    
    protected String findLayer(String layerToBeFound, Set layers) {
        if (layers==null || layers.isEmpty())
            return null;
        
        Iterator it = layers.iterator();
        while (it.hasNext()) {
            Layer layer = (Layer) it.next();
            String identity = layer.getId() + "_" + layer.getName();
            if(identity.equalsIgnoreCase(layerToBeFound))
                return layer.getName();
            
            String foundLayer = findLayer(layerToBeFound, layer.getLayers());
            if (foundLayer != null)
                return foundLayer;
        }        
        return null;
    }    
    
    /** Checks wether a post or get url is available for an incomming request.
     * @param serviceProvider ServiceProvider to which the request belongs
     * @param request String with the specified request
     * @return stringbuffer with the url found in the database for this specific request
     */
    // <editor-fold defaultstate="collapsed" desc="calcRequestUrl(ServiceProvider serviceProvider, String request) method.">
    protected StringBuffer calcRequestUrl(ServiceProvider serviceProvider, String request) {
        Set domain = serviceProvider.getDomainResource();
        Iterator domainIter = domain.iterator();
        while (domainIter.hasNext()) {
            ServiceDomainResource sdr = (ServiceDomainResource)domainIter.next();
            if(sdr.getDomain().equalsIgnoreCase(request)) {
                if(sdr.getPostUrl() != null) {
                    return new StringBuffer(sdr.getPostUrl());
                } else {
                    return new StringBuffer(sdr.getGetUrl());
                }
            }
        }
        return null;
    }
    // </editor-fold>
    
    /** Processes the parameters and creates a byte array with the needed information.
     *
     * @param parameters Map parameters
     *
     * @return byte[]
     *
     * @throws IOException
     */
    // <editor-fold defaultstate="collapsed" desc="abstract getRequest(Map params) method, overriding the getRequest(Map params) declared in the interface.">
    public abstract byte[] getRequest(Map <String, Object> params) throws IOException;
    // </editor-fold>
    
    // <editor-fold defaultstate="collapsed" desc="getter methods.">
    public User getUser() {
        return user;
    }
    
    public String getUrl() {
        return url;
    }
    // </editor-fold>
}