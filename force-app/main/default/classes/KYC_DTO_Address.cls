/***************************************************************************************
@Name of the Class :KYC_DTO_Address
@Description : SFP-38773 This is wrapper class for converting input into Salesforce Object
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public class KYC_DTO_Address {

    @Auraenabled
    @InvocableVariable(label = 'Type')
    public string type;
    
    @Auraenabled
    @InvocableVariable(label = 'Primary Address')
    public boolean primaryAddress;
    
    @Auraenabled
    @InvocableVariable(label = 'Start Date')
    public date startDate;
    
    @Auraenabled
    @InvocableVariable(label = 'End Date')
    public date endDate;
    
    @Auraenabled
    @InvocableVariable(label = 'Street')
    public string street;
    
    @Auraenabled
    @InvocableVariable(label = 'City')
    public string city;
    
    @Auraenabled
    @InvocableVariable(label = 'State Code')
    public string stateCode;
    
    @Auraenabled
    @InvocableVariable(label = 'Country Code')
    public string countryCode;
    
    @Auraenabled
    @InvocableVariable(label = 'Postal Code')
    public string postalCode;
    
    @Auraenabled
    @InvocableVariable(label = 'Latitude')
    public double latitude;
    
    @Auraenabled
    @InvocableVariable(label = 'Longitude')
    public double longitude;
    
    @Auraenabled
    @InvocableVariable(label = 'Geo Code')
    public string geoCode;

    /**
    * @description Constructor method
    * @author Nagendra Mylavarapu | 24-04-2024 
    **/
    public KYC_DTO_Address(){
        this.endDate = System.today();
  }
  
}