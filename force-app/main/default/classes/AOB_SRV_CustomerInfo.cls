/**
 * @description Service class  for personal information components
 *
 * <p>DPB-1159  DPB-1160</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Jan 15th 2021
 * 
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed SFP-14961 29-06-2022 Gill Lumley   Check for null bpid/bpidguid from Ping before updating unique external fields on account 
 * Changed           23-11-2023 Gill Lumley   Change to use the new rflib logger
 */
public with sharing class AOB_SRV_CustomerInfo {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_CustomerInfo');

    /**
    * @description  makes an api call to get an access token
    * @return access token to authenticate to API calls
    */
    public static String callGetToken(){
        AOB_API_AccessToken customerServiceCall = new AOB_API_AccessToken(AOB_API_AccessTokenBase.HTTP_BODY_SCOPE_CUSTOMER); 
        customerServiceCall.process(CMN_DAL_DataFactory.newWebserviceQueue(AOB_API_AccessToken.SERVICE_NAME)); 
        AOB_API_AccessToken.DTO_Response response=(AOB_API_AccessToken.DTO_Response)customerServiceCall.baseResponseDTO;
        return response.access_token;
    }
    /**
     * @description makes an api call to get an access token
     * @return access token to authenticate to API calls
     */
    public static AOB_DTO_Customers.Customer callGetCustomerAPI() {
        AOB_API_PersonalDetails customerServiceCall = new AOB_API_PersonalDetails();
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_PersonalDetails.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        AOB_API_PersonalDetails.DTO_Response response = (AOB_API_PersonalDetails.DTO_Response) customerServiceCall.baseResponseDTO;
        return response.customer;
    }

    /**
     * @description makes an api call to get an access token
     * @return access token to authenticate to API calls
     */
    @AuraEnabled
    public static String callGetPersonalDetailsMarketingConsents() {
        AOB_API_PersonalDetailsMarketingConsents customerServiceCall = new AOB_API_PersonalDetailsMarketingConsents();
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_PersonalDetailsMarketingConsents.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        String appData=customerServiceCall.getResponseBody();
        Map<String,Object> appDataMaps = (Map<String,object>) JSON.deserializeUntyped(appData);
        String customerdata=Json.serialize(appDataMaps.get('customer'));
        Map<String,Object> cusMap = (Map<String,object>) JSON.deserializeUntyped(customerdata);  
        String mardata;
        if (appData != null && cusMap.get('marketingConsents') != null) {
            mardata=Json.serialize(cusMap.get('marketingConsents'));
        }                
        return mardata;
    }

    /**
     * @description makes an api call to get current customer Source Of Funds
     * @return current customer List of Source Of Funds
     */
    public static List<AOB_DTO_Customers.SourceOfFunds> callGetCustomerAPISOF() {
        AOB_API_PersonalDetailsSOF customerServiceCall = new AOB_API_PersonalDetailsSOF();
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_PersonalDetailsSOF.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        AOB_API_PersonalDetailsSOF.DTO_Response response = (AOB_API_PersonalDetailsSOF.DTO_Response) customerServiceCall.baseResponseDTO;
        return response.sourceOfFunds;
    }

    /**
     * @description makes an api call to get current customer identification info
     * @return customer id number
     */
    public static AOB_DTO_Identifications callGetCustomerAPIIdentifications() {
        AOB_API_PersonalDetailsIdentif customerServiceCall = new AOB_API_PersonalDetailsIdentif();
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_PersonalDetailsIdentif.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        AOB_API_PersonalDetailsIdentif.DTO_Response response = (AOB_API_PersonalDetailsIdentif.DTO_Response) customerServiceCall.baseResponseDTO;
        AOB_DTO_Identifications result = new AOB_DTO_Identifications();
        if (response != null && !response.identifications.isEmpty()) {
            result = response.identifications[0];
        }
        return result;
    }

    /**
     * @description makes an api call to get current customer addresses info
     * @return customer id number
     */
    public static AOB_DTO_Addresses callGetCustomerAPIAddresses() {
        AOB_DTO_Addresses result;
        AOB_API_PersonalDetailsAddress customerServiceCall = new AOB_API_PersonalDetailsAddress();
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_PersonalDetailsAddress.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        AOB_API_PersonalDetailsAddress.DTO_Response response = (AOB_API_PersonalDetailsAddress.DTO_Response) customerServiceCall.baseResponseDTO;
        for (AOB_DTO_Addresses address : response.addresses) {
            for (AOB_DTO_Addresses.Type_Z addType : address.type_Z) {
                if (addType.addressType == '05') {
                    result = address;
                }
            }
        }
        return result;
    }

    /**
     * @description makes an api call to get current customer Employment info
     * @return customer employment DTO
     */
    public static AOB_DTO_Employment callGetCustomerAPIEmployment() {
        AOB_API_PersonalDetailsEmploy customerServiceCall = new AOB_API_PersonalDetailsEmploy();
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_PersonalDetailsEmploy.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        AOB_API_PersonalDetailsEmploy.DTO_Response response = (AOB_API_PersonalDetailsEmploy.DTO_Response) customerServiceCall.baseResponseDTO;
        for (AOB_DTO_Employment job : response.employments) {
            if (Date.valueOf(job.endDate) > Date.Today()) {
                return job;
            }
        }
        AOB_DTO_Employment result = new AOB_DTO_Employment();
        if (response != null && !response.employments.isEmpty()) {
            result = response.employments[0];
        }
        return result;
    }

    /**
     * @description makes an api call to get current customer Employment info
     * @return customer employment DTO
     */
    public static AOB_DTO_PersonalContact callGetCustomerAPIContact() {
        AOB_DTO_PersonalContact personalContact = new AOB_DTO_PersonalContact();

        AOB_API_PersonalDetailsContacts customerServiceCall = new AOB_API_PersonalDetailsContacts();
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_PersonalDetailsContacts.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        AOB_API_PersonalDetailsContacts.DTO_Response response = (AOB_API_PersonalDetailsContacts.DTO_Response) customerServiceCall.baseResponseDTO;
        if (response != null && response.contacts != null) {
            for (Object contact : response.contacts) {
                AOB_DTO_Contacts parsedContact = (AOB_DTO_Contacts) contact;
                if (Date.valueOf(parsedContact.endDate) > Date.Today() && parsedContact.phoneType=='2' && parsedContact.type_Z == AOB_Constants.SAPFIELD_PHONE) {
                    personalContact.phoneNumber = parsedContact.value;
                }
                if (Date.valueOf(parsedContact.endDate) > Date.Today() && parsedContact.type_Z == AOB_Constants.SAPFIELD_EMAIL) {
                    personalContact.email = parsedContact.value;
                }
            }
            if (personalContact.phoneNumber == null && personalContact.phoneNumber2 != null) {
                personalContact.phoneNumber = personalContact.phoneNumber2;
            }
        }
        return personalContact;
    }

    /**
    * @description  makes an api call to get current customer contact info
    * @param fieldsString (containing personal details)
    * @param taxes
    * @param funds
    * @param oldEmployment
    * @param marketing    
    * @return wrapper class containing phone/email of the current customer
    */
    public static Integer maintainCustomer(String fieldsString,List<AOB_DTO_SelectOption> taxes,List<AOB_DTO_SelectOption> funds,String oldEmployment,String marketing)
    {
       // Map<String, Object> fields =(Map<String, object>) JSON.deserializeUntyped(fieldsString);
        AOB_DTO_MaintainCustomer mc= new AOB_DTO_MaintainCustomer(fieldsString,taxes,funds,taxes,funds,oldEmployment,marketing);
        AOB_API_MaintainCustomer customerServiceCall = new AOB_API_MaintainCustomer(mc); 
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_MaintainCustomer.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        return customerServiceCall.getResponseStatusCode(); 
    }

    /**
     * @description makes an api call to get current customer contact info
     * @param fieldsString (containing personal details)
     * @param oldTaxes
     * @param oldFunds
     * @param taxes
     * @param funds
     * @param oldEmployment
     * @param marketing         
     * @return wrapper class containing phone/email of the current customer
     */
    public static Integer maintainCustomer(
        String fieldsString,
        List<AOB_DTO_SelectOption> oldTaxes,
        List<AOB_DTO_SelectOption> oldFunds,
        List<AOB_DTO_SelectOption> taxes,
        List<AOB_DTO_SelectOption> funds,
        String oldEmployment,
        String marketing
    ) {
        //Map<String, Object> fields = (Map<String, object>) JSON.deserializeUntyped(fieldsString); PMD violation - "fields" not used 
        AOB_DTO_MaintainCustomer mc = new AOB_DTO_MaintainCustomer(fieldsString, oldTaxes, oldFunds, taxes, funds, oldEmployment,marketing);
        AOB_API_MaintainCustomer customerServiceCall = new AOB_API_MaintainCustomer(mc);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_MaintainCustomer.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        return customerServiceCall.getResponseStatusCode();
    }

    /**
     * @description saves the info entered by the user in salesforce
     * @param fieldsString json String with API data
     */
    public static void saveCustomerDetails(string fieldsString) {
        Map<String, Object> fields = (Map<String, object>) JSON.deserializeUntyped(fieldsString);
        string applicationId = (String) fields.get(AOB_Constants.APPLICATIONID);
        if (AOB_Application__c.sObjectType.getDescribe().isAccessible()) {
            String decodedJWT=AOB_utils.parseJWT(AOB_utils.getAccessToken());
            Map<String, Object> jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(decodedJWT);
            List<AOB_Application__c> applications = [SELECT id, AOB_Contact__c, AOB_Customer__c FROM AOB_Application__c WHERE id = :applicationId];
            if (!applications.isEmpty()) {
                List<Account> personAccounts = [SELECT id,ExternalIdentifier__c,ExternalCIFId__c,ExternalCIFUUID__c,ExternalSystemId__c,ExternalCIFCountry__c FROM Account WHERE id IN (SELECT AccountId FROM user WHERE id = :UserInfo.getUserId())];
                if (!personAccounts.isEmpty()) {
                    Account personAccount = personAccounts[0];
                    if ((String)jsonMAp.get('bpid') == null){  // SFP-14961
                        if (personAccount.ExternalCIFId__c == null){
                            LOGGER.error('PING bpid null - Account external id fields not updated', new String[] {'AOB_SRV_CustomerInfo.saveCustomerDetails', 'PING bpid null - Account external id fields not updated'});
                        }
                    } else {
                        personAccount.ExternalIdentifier__c = personAccount.ExternalCIFCountry__c +personAccount.ExternalSystemId__c+(String)jsonMAp.get('bpid');
                        personAccount.ExternalCIFId__c=(String)jsonMAp.get('bpid');
                    }
                    if ((String)jsonMAp.get('bpidguid') == null){ // SFP-14961
                        if (personAccount.ExternalCIFUUID__c == null){
                            LOGGER.error('PING bpidguid null - Account external UUID not updated', new String[] {'AOB_SRV_CustomerInfo.saveCustomerDetails', 'PING bpidguid null - Account external UUID not updated'});
                        }
                    } else {
                        personAccount.ExternalCIFUUID__c = AOB_Utils.formatGUID((String)jsonMAp.get('bpidguid'));
                    }
                    if(!String.isBlank((String)fields.get(AOB_Constants.TITLE))){
                        personAccount.personTitle = AOB_Utils.getReferenceData((String)fields.get(AOB_Constants.TITLE),AOB_Constants.TITLE).Name;
                    } 
                    personAccount.firstName = (String) fields.get(AOB_Constants.FIRSTNAME);
                    personAccount.lastName = (String) fields.get(AOB_Constants.SURNAME);
                    personAccount.Nationality__c = (String) fields.get(AOB_Constants.NATIONALITY);
                    personAccount.Citizenship__c = (String) fields.get(AOB_Constants.CITIZENSHIP);
                    //personAccount.Country_Of_Birth__c = (String) fields.get(AOB_Constants.COUNTRYOFBIRTH);
                    //personAccount.Country_Of_Residence__c = (String) fields.get(AOB_Constants.RESIDENCE);

                    //-- Contact details -----
                    personAccount.PersonMobilePhone = (String) fields.get(AOB_Constants.CELLPHONE);
                    personAccount.PersonEmail = (String) fields.get(AOB_Constants.EMAIL);
                    //-- Residential address -----
                    String billingStreet =
                        fields.get(AOB_Constants.STREETNUMBER) +
                        ' ' +
                        fields.get(AOB_Constants.UNITNUMBER) +
                        ' ' +
                        fields.get(AOB_Constants.BUILDINGNAME) +
                        ' ' +
                        fields.get(AOB_Constants.SUBURB);
                    personAccount.BillingStreet = billingStreet.replace('null', '');
                    if(!String.isBlank((String)fields.get(AOB_Constants.PROVINCE))){
                        personAccount.BillingState = AOB_Utils.getReferenceData((String)fields.get(AOB_Constants.PROVINCE),AOB_Constants.PROVINCE).Name;
                    }
                    personAccount.BillingCity = (String) fields.get(AOB_Constants.CITY);
                    personAccount.BillingPostalCode = (String) fields.get(AOB_Constants.POSTALCODE);
                    //---Employment details ----
                    personAccount.EmploymentStatus__c = (String) fields.get(AOB_Constants.EMPLOYMENTTYPE);
                    personAccount.FinServ__CurrentEmployer__pc = (String) fields.get(AOB_Constants.EMPLOYERNAME);
                    personAccount.EmploymentIndustry__c = (String) fields.get(AOB_Constants.INDUSTRY);
                    personAccount.Designation__c = (String) fields.get(AOB_Constants.DESIGNATION);
                    personAccount.FinServ__EmployedSince__pc = fields.get(AOB_Constants.STARTDATE) != null ? Date.valueOf((String) fields.get(AOB_Constants.STARTDATE)) : null;
                    //----Legal Consent-----
                    if (fields.get(AOB_Constants.PUBLICOFF) != null) {
                        personAccount.AOB_ProminentInfluentialPerson__c = Boolean.valueOf(fields.get(AOB_Constants.PUBLICOFF));
                    }
                    if (fields.get(AOB_Constants.PUBLICOFFREL) != null) {
                        personAccount.AOB_RelatedInd__c = Boolean.valueOf(fields.get(AOB_Constants.PUBLICOFFREL));
                    }
                    personAccount.AOB_RelationType__c = (String) fields.get(AOB_Constants.natureOfRelation);
                    personAccount.AOB_PersonsName__c = (string) fields.get(AOB_Constants.NAMEOFRELATION);
                    try {
                        update personAccount;
                    }
                    catch(exception error){
                        LOGGER.error(error.getMessage(), new String[] {'AOB_SRV_CustomerInfo.saveCustomerDetails', error.getMessage()}, error);
                    }
                }
            }
        }
    }

    /**
     * @description saves the IdentityDocument before saveing the info entered by the user in salesforce
     * @param fieldsString json String with API data
     */
    public static void saveIdentificationDocument(String fieldsString) {
        List<Account> accounts = [SELECT id, ExternalCIFUUID__c, ExternalIdentifier__c FROM Account WHERE id IN (SELECT AccountId FROM user WHERE id = :UserInfo.getUserId())];
        final Map<String, Object> fields = (Map<String, object>) JSON.deserializeUntyped(fieldsString);
        final IdentityDocument identificationDoc = new IdentityDocument();
        identificationDoc.IdDocumentType = (String) fields.get(AOB_Constants.IDTYPE);
        identificationDoc.Name = (String) fields.get(AOB_Constants.IDNUMBER);
        identificationDoc.IssuingCountry__c = (String) fields.get(AOB_Constants.ID_ISSUINGCOUNTRY);
        identificationDoc.IssueDate = fields.get(AOB_Constants.ID_ISSUINGDATE) != null ? Date.valueOf((String) fields.get(AOB_Constants.ID_ISSUINGDATE)) : Date.newInstance(1700, 1, 1);
        identificationDoc.RelatedLegalEntityId = accounts[0].Id;
        identificationDoc.ExternalIdentifier__c =
            accounts[0].ExternalIdentifier__c +
            identificationDoc.IdDocumentType +
            identificationDoc.IssuingCountry__c +
            identificationDoc.IssueDate.Year() +
            '-' +
            identificationDoc.IssueDate.Month() +
            '-' +
            identificationDoc.IssueDate.day();
        identificationDoc.ExternalIdentifier__c = identificationDoc.ExternalIdentifier__c.replace('null', '');
        final List<IdentityDocument> identificationDocuments = [
            SELECT Id, IdDocumentType, Name
            FROM IdentityDocument
            WHERE
                (IdDocumentType = :identificationDoc.IdDocumentType
                AND RelatedLegalEntityId = :identificationDoc.RelatedLegalEntityId)
                OR ExternalIdentifier__c = :identificationDoc.ExternalIdentifier__c
        ];
        identificationDoc.Id = !identificationDocuments.isEmpty() ? identificationDocuments[0].Id : null;
        upsert identificationDoc;
    }
}