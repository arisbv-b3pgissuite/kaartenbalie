/*
 * CombineImagesOperation.java
 *
 * Created on October 16, 2007, 9:11 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package nl.b3p.kaartenbalie.core.server.reporting.domain.operations;

import nl.b3p.kaartenbalie.core.server.reporting.domain.requests.ClientRequest;

/**
 *
 * @author Chris Kramer
 */
public class SendDataOperation extends Operation{
    
    private Long dataSize;
    
    public SendDataOperation() {
        super();
    }
    public SendDataOperation(ClientRequest clientRequest) {
        super(clientRequest);
    }

    public Long getDataSize() {
        return dataSize;
    }

    public void setDataSize(Long dataSize) {
        this.dataSize = dataSize;
    }
    
  
    

    
    
}
