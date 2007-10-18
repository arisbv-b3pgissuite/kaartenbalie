/*
 * @(#)Userip.java
 * @author N. de Goeij
 * @version 1.00, 25 september 2007
 *
 * @copyright 2007 B3Partners. All rights reserved.
 * B3Partners PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 *
 */

package nl.b3p.kaartenbalie.core.server;

import java.util.Iterator;
import java.util.Set;

public class Userip {
    private Integer id;
    private String ipaddress;
    private User user;
    
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public String getIpaddress() {
        return ipaddress;
    }
    
    public void setIpaddress(String ipaddress) {
        this.ipaddress = ipaddress;
    }
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
    
    public boolean equals(Userip ipaddress) {
        if (ipaddress==null)
            return false;
        return this.getIpaddress().equals(ipaddress.getIpaddress());
    }
    
    public boolean inList(Set addresses) {
        if (addresses==null)
            return false;
        Iterator it = addresses.iterator();
        while (it.hasNext()) {
            Userip setip = (Userip) it.next();
            if(this.equals(setip)) {
                return true;
            }
        }
        return false;
    }
}