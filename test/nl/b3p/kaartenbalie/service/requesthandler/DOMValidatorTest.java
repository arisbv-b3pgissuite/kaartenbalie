package nl.b3p.kaartenbalie.service.requesthandler;

import general.B3TestCase;
import general.ByteArrayInputStreamStub;
import general.LocatorStub;
import java.io.ByteArrayInputStream;
import org.junit.*;
import static org.junit.Assert.*;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

/**
 *
 * @author rachelle
 */
public class DOMValidatorTest extends B3TestCase {    
    private ByteArrayInputStreamStub byteArrayInputStreamStub;
    private DOMValidator validator;
    private SAXParseException exception;
    
    public DOMValidatorTest(String name) {
        super(name);
    }
    
    @Before
    @Override
    public void setUp() throws Exception {
        super.setUp();
        
        byte[] buffer                   = new byte[100];
        this.byteArrayInputStreamStub   = new ByteArrayInputStreamStub(buffer);
        this.exception                  = new SAXParseException("Testing exception",new LocatorStub());
                
        this.validator                  = new DOMValidator();
    }
    
    @After
    @Override
     public void tearDown() throws Exception {
        super.setUp();
        
        this.byteArrayInputStreamStub   = null;
        this.validator                  = null;
        this.exception                  = null;
    }

    /**
     * Test of parseAndValidate method, of class DOMValidator.
     */
    @Test
    public void testDOMValidator_ParseAndValidate(){
        try {
            this.validator.parseAndValidate(byteArrayInputStreamStub);
            
            fail("Test schould fail on empty buffer");
            assertTrue(false);
        }
        catch(Exception e){
            /* Empty buffer. expected to fail */
            assertTrue(true);
        }
    }

    /**
     * Test of warning method, of class DOMValidator.
     */
    @Test
    public void testDOMValidator_Warning(){
        try {
            this.validator.warning(this.exception);
            
            fail("Function schould throw a SAXParseException");
            
            assertTrue(false);
        }
        catch(SAXParseException e){
            assertTrue(true);
        }
    }

    /**
     * Test of error method, of class DOMValidator.
     */
    @Test
    public void testDOMValidator_Error(){
        try {
            this.validator.error(this.exception);
            
            fail("Function schould throw a SAXParseException");
            
            assertTrue(false);
        }
        catch(SAXParseException e){
            assertTrue(true);
        }
    }

    /**
     * Test of fatalError method, of class DOMValidator.
     */
    @Test
    public void testDOMValidator_FatalError(){
        try {
            this.validator.fatalError(this.exception);
            
            fail("Function schould throw a SAXException");
            
            assertTrue(false);
        }
        catch(SAXException e){
            assertTrue(true);
        }
    }
}
