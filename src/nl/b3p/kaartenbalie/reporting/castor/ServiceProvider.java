/*
 * This class was automatically generated with 
 * <a href="http://www.castor.org">Castor 1.0.2</a>, using an XML
 * Schema.
 * $Id$
 */

package nl.b3p.kaartenbalie.reporting.castor;

  //---------------------------------/
 //- Imported classes and packages -/
//---------------------------------/

import org.exolab.castor.xml.Marshaller;
import org.exolab.castor.xml.Unmarshaller;

/**
 * Class ServiceProvider.
 * 
 * @version $Revision$ $Date$
 */
public class ServiceProvider implements java.io.Serializable {


      //--------------------------/
     //- Class/Member Variables -/
    //--------------------------/

    /**
     * Field _name
     */
    private java.lang.String _name;

    /**
     * Field _count
     */
    private int _count;

    /**
     * keeps track of state for field: _count
     */
    private boolean _has_count;

    /**
     * Field _durationAvg
     */
    private long _durationAvg;

    /**
     * keeps track of state for field: _durationAvg
     */
    private boolean _has_durationAvg;

    /**
     * Field _durationMax
     */
    private long _durationMax;

    /**
     * keeps track of state for field: _durationMax
     */
    private boolean _has_durationMax;

    /**
     * Field _bytesReceivedSum
     */
    private int _bytesReceivedSum;

    /**
     * keeps track of state for field: _bytesReceivedSum
     */
    private boolean _has_bytesReceivedSum;

    /**
     * Field _bytesSentSum
     */
    private int _bytesSentSum;

    /**
     * keeps track of state for field: _bytesSentSum
     */
    private boolean _has_bytesSentSum;


      //----------------/
     //- Constructors -/
    //----------------/

    public ServiceProvider() 
     {
        super();
    } //-- nl.b3p.kaartenbalie.reporting.castor.ServiceProvider()


      //-----------/
     //- Methods -/
    //-----------/

    /**
     * Method deleteBytesReceivedSum
     * 
     */
    public void deleteBytesReceivedSum()
    {
        this._has_bytesReceivedSum= false;
    } //-- void deleteBytesReceivedSum() 

    /**
     * Method deleteBytesSentSum
     * 
     */
    public void deleteBytesSentSum()
    {
        this._has_bytesSentSum= false;
    } //-- void deleteBytesSentSum() 

    /**
     * Method deleteCount
     * 
     */
    public void deleteCount()
    {
        this._has_count= false;
    } //-- void deleteCount() 

    /**
     * Method deleteDurationAvg
     * 
     */
    public void deleteDurationAvg()
    {
        this._has_durationAvg= false;
    } //-- void deleteDurationAvg() 

    /**
     * Method deleteDurationMax
     * 
     */
    public void deleteDurationMax()
    {
        this._has_durationMax= false;
    } //-- void deleteDurationMax() 

    /**
     * Returns the value of field 'bytesReceivedSum'.
     * 
     * @return int
     * @return the value of field 'bytesReceivedSum'.
     */
    public int getBytesReceivedSum()
    {
        return this._bytesReceivedSum;
    } //-- int getBytesReceivedSum() 

    /**
     * Returns the value of field 'bytesSentSum'.
     * 
     * @return int
     * @return the value of field 'bytesSentSum'.
     */
    public int getBytesSentSum()
    {
        return this._bytesSentSum;
    } //-- int getBytesSentSum() 

    /**
     * Returns the value of field 'count'.
     * 
     * @return int
     * @return the value of field 'count'.
     */
    public int getCount()
    {
        return this._count;
    } //-- int getCount() 

    /**
     * Returns the value of field 'durationAvg'.
     * 
     * @return long
     * @return the value of field 'durationAvg'.
     */
    public long getDurationAvg()
    {
        return this._durationAvg;
    } //-- long getDurationAvg() 

    /**
     * Returns the value of field 'durationMax'.
     * 
     * @return long
     * @return the value of field 'durationMax'.
     */
    public long getDurationMax()
    {
        return this._durationMax;
    } //-- long getDurationMax() 

    /**
     * Returns the value of field 'name'.
     * 
     * @return String
     * @return the value of field 'name'.
     */
    public java.lang.String getName()
    {
        return this._name;
    } //-- java.lang.String getName() 

    /**
     * Method hasBytesReceivedSum
     * 
     * 
     * 
     * @return boolean
     */
    public boolean hasBytesReceivedSum()
    {
        return this._has_bytesReceivedSum;
    } //-- boolean hasBytesReceivedSum() 

    /**
     * Method hasBytesSentSum
     * 
     * 
     * 
     * @return boolean
     */
    public boolean hasBytesSentSum()
    {
        return this._has_bytesSentSum;
    } //-- boolean hasBytesSentSum() 

    /**
     * Method hasCount
     * 
     * 
     * 
     * @return boolean
     */
    public boolean hasCount()
    {
        return this._has_count;
    } //-- boolean hasCount() 

    /**
     * Method hasDurationAvg
     * 
     * 
     * 
     * @return boolean
     */
    public boolean hasDurationAvg()
    {
        return this._has_durationAvg;
    } //-- boolean hasDurationAvg() 

    /**
     * Method hasDurationMax
     * 
     * 
     * 
     * @return boolean
     */
    public boolean hasDurationMax()
    {
        return this._has_durationMax;
    } //-- boolean hasDurationMax() 

    /**
     * Method isValid
     * 
     * 
     * 
     * @return boolean
     */
    public boolean isValid()
    {
        try {
            validate();
        }
        catch (org.exolab.castor.xml.ValidationException vex) {
            return false;
        }
        return true;
    } //-- boolean isValid() 

    /**
     * Method marshal
     * 
     * 
     * 
     * @param out
     */
    public void marshal(java.io.Writer out)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        
        Marshaller.marshal(this, out);
    } //-- void marshal(java.io.Writer) 

    /**
     * Method marshal
     * 
     * 
     * 
     * @param handler
     */
    public void marshal(org.xml.sax.ContentHandler handler)
        throws java.io.IOException, org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        
        Marshaller.marshal(this, handler);
    } //-- void marshal(org.xml.sax.ContentHandler) 

    /**
     * Sets the value of field 'bytesReceivedSum'.
     * 
     * @param bytesReceivedSum the value of field 'bytesReceivedSum'
     */
    public void setBytesReceivedSum(int bytesReceivedSum)
    {
        this._bytesReceivedSum = bytesReceivedSum;
        this._has_bytesReceivedSum = true;
    } //-- void setBytesReceivedSum(int) 

    /**
     * Sets the value of field 'bytesSentSum'.
     * 
     * @param bytesSentSum the value of field 'bytesSentSum'.
     */
    public void setBytesSentSum(int bytesSentSum)
    {
        this._bytesSentSum = bytesSentSum;
        this._has_bytesSentSum = true;
    } //-- void setBytesSentSum(int) 

    /**
     * Sets the value of field 'count'.
     * 
     * @param count the value of field 'count'.
     */
    public void setCount(int count)
    {
        this._count = count;
        this._has_count = true;
    } //-- void setCount(int) 

    /**
     * Sets the value of field 'durationAvg'.
     * 
     * @param durationAvg the value of field 'durationAvg'.
     */
    public void setDurationAvg(long durationAvg)
    {
        this._durationAvg = durationAvg;
        this._has_durationAvg = true;
    } //-- void setDurationAvg(long) 

    /**
     * Sets the value of field 'durationMax'.
     * 
     * @param durationMax the value of field 'durationMax'.
     */
    public void setDurationMax(long durationMax)
    {
        this._durationMax = durationMax;
        this._has_durationMax = true;
    } //-- void setDurationMax(long) 

    /**
     * Sets the value of field 'name'.
     * 
     * @param name the value of field 'name'.
     */
    public void setName(java.lang.String name)
    {
        this._name = name;
    } //-- void setName(java.lang.String) 

    /**
     * Method unmarshal
     * 
     * 
     * 
     * @param reader
     * @return ServiceProvider
     */
    public static nl.b3p.kaartenbalie.reporting.castor.ServiceProvider unmarshal(java.io.Reader reader)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        return (nl.b3p.kaartenbalie.reporting.castor.ServiceProvider) Unmarshaller.unmarshal(nl.b3p.kaartenbalie.reporting.castor.ServiceProvider.class, reader);
    } //-- nl.b3p.kaartenbalie.reporting.castor.ServiceProvider unmarshal(java.io.Reader) 

    /**
     * Method validate
     * 
     */
    public void validate()
        throws org.exolab.castor.xml.ValidationException
    {
        org.exolab.castor.xml.Validator validator = new org.exolab.castor.xml.Validator();
        validator.validate(this);
    } //-- void validate() 

}
