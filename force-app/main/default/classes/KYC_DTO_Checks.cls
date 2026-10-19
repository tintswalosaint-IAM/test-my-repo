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
public class KYC_DTO_Checks {
    
    @Auraenabled
    @InvocableVariable(label = 'ID Validation')
    public Boolean idValidation;
    
    @Auraenabled
    @InvocableVariable(label = 'IDV')
    public Boolean idv;
    
    @Auraenabled
    @InvocableVariable(label = 'RAAS')
    public Boolean raas;
	
    @Auraenabled
    @InvocableVariable(label = 'Document Upload')
    public Boolean documentUpload;
    
    /**
    * @description This is Constructor
    * @author Nagendra Mylavarapu | 23-04-2024 
    **/
    public KYC_DTO_Checks(){
        idValidation = false;
        idv = false;
        raas = false;
        documentUpload = false;
    }
    
}