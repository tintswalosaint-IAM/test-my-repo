/**
 * @description       : Helper Class for the AOB_BOTS_SRV_ESB
 * @author            : Nagendraprasad Mylavarapu
 * @last modified on  : 13-09-2024
* @last modified by  : Nagendraprasad Mylavarapu
**/
public without sharing class AOB_BOTS_SRV_ESB_Helper {
    private static sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { Application__c.SObjectType,Application_Participant__c.SObjectType,CMN_WebserviceCallQueue__c.SObjectType });
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_BOTS_SRV_ESB');
    private static final String botswanaCountryCode = 'BW'; 
    private static final String SOCTY = 'SOCTY';
    private static final String number01 = '01';
    private static final String botswanaCountryCurrencyCode = 'BWP';
    private static final String issuedDate = '2018-03-28T00:00:00.000';
    private static final String PreferredIdentificationIndicatorY = 'Y';
    private static final String documentCode = 'D0001';
    private static final String documentDescription = 'Identity Document';
    private static final String documentTypeCode = 'DT000';
    private static final String documentTypeDescription = 'Identification Proof Individual';
    private static final String EASIndicator  = 'EASCustomerAdd'; 
    private static final String customerType  = 'INDIVIDUAL';
    private static final String commentHome = 'Home'; 
    private static final String contactType = 'EMAIL';
    private static final String prefLanguage  = 'en';
    private static final String startDateValue = '2023-01-20';
    private static final String botswanaCountryCallingCode = '267'; 
    private static final String botswanaLocalCode = '267'; 
    private static final String botswanaCityCode = '267'; 
    private static final String number001 = '001';
    private static final String number105 = '105';

    private static Map<String, String> documentTypeMappings = new Map<String, String>{
        'Source of Funds' => 'Financial Data\tSource of Funds',
        'Business Address' => 'KYC Documents\tBusiness Address',
        'Proof Of Identity' => 'KYC Documents\tProof of Identity',
        'Upload Proof of Identity' => 'KYC Documents\tProof of Identity',
        'Proof Of Address'=> 'KYC Documents\tProof of Residence'
    };

    /**
    * @description This method is used as call the searchCorp api
    * @return Integer
    * @param applicationId
    */
    public static Integer searchCorp(String applicationId){
        try{
            Integer responseCode;
            String businessName;   
            Application__c apps = new AOB_BOTS_SEL_Application().selectAppById(applicationId);
            if(apps.AOB_Schema_Code__c=='OD001' || apps.AOB_Schema_Code__c=='OD005'){
                businessName=apps.AOB_BusinessLegalName__c;
            }else{ 
                
                businessName=apps.AOB_GroupName__c;
            } 
            businessName=businessName.replace(' ', '%20');
            AOB_BOTS_API_SearchCorp customerServiceCall = new AOB_BOTS_API_SearchCorp(businessName);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_SearchCorp.SERVICE_NAME);
            customerServiceCall.process(obj);
            AOB_BOTS_SRV_CMNWebserviceCallQueue.newInstance().saveWebserviceCallQueues(new List<CMN_WebserviceCallQueue__c>{obj},uow);

            String appData=customerServiceCall.getResponseBody();
       
            responseCode=customerServiceCall.getResponseStatusCode();
            if(customerServiceCall.getResponseStatusCode()==200){
                Map<String,Object> appDataMaps = (Map<String,object>) JSON.deserializeUntyped(appData);
                String customerdata=Json.serialize(appDataMaps.get('customers'));
                customerdata=customerdata.removeStart('[');
                customerdata=customerdata.removeEnd(']');
                Map<String,Object> uUIDMaps = (Map<String,object>) JSON.deserializeUntyped(customerdata);
                apps.AOB_CIFID__c = (String)uUIDMaps.get('uuid'); 
            }else{
                
                return 200;
            }
            AOB_BOTS_SRV_Application.newInstance().saveApp(new List<Application__c>{apps}, uow);
            uow.commitWork();            
            return responseCode;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.searchCorp',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        } 
    } 


    /**
    * @description This method is used as call the searchCustomer api
    * @author Dayakar
    * @return Integer
    * @param applicationId
    */
    public static Integer searchCustomer(String applicationId){
        try{
            Integer responseCode;
            List<Application_Participant__c> directorDataList = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByapplicationIdandsignatory(applicationId);
            List<Application_Participant__c> updateCIFList= new List<Application_Participant__c>();
            for(Application_Participant__c app:directorDataList){
                String dateobirth; 
                String fullName;
                String firstName;
                String lastName;
                if(app.AOB_DateofBirth__c!=null){
                    dateobirth=String.ValueOf(app.AOB_DateofBirth__c);
                }
                fullName=app.AOB_FullName__c.toUpperCase();
                String[] names = fullName.split(' ');
                if(fullName.contains(' ')){
                    firstName=names[0];
                    lastName=names[1];
                }
                AOB_BOTS_API_SearchCustomer customerServiceCall = new AOB_BOTS_API_SearchCustomer(firstName,lastName,dateobirth);
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_DSX.SERVICE_NAME);
                customerServiceCall.process(obj);
                String appData=customerServiceCall.getResponseBody();
                responseCode=customerServiceCall.getResponseStatusCode();
                if(customerServiceCall.getResponseStatusCode()==200){
                    Map<String,Object> appDataMaps = (Map<String,object>) JSON.deserializeUntyped(appData);
                    String customerdata=Json.serialize(appDataMaps.get('customers'));
                    customerdata=customerdata.removeStart('[');
                    customerdata=customerdata.removeEnd(']');
                    Map<String,Object> uUIDMaps = (Map<String,object>) JSON.deserializeUntyped(customerdata);
                    app.AOB_CIFID__c = (String)uUIDMaps.get('uuid');
                    updateCIFList.add(app);
                    
                }else{
                    
                    return 200;
                }
                
            }
            if(updateCIFList.size()>0){
                AOB_BOTS_SRV_ApplicationParticipant.newInstance().saveAppParticipant(updateCIFList, uow);
                uow.commitWork();  

            }
            return responseCode;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.searchCustomer',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }

    /** @description  method to create advise account for application
    * @param applicationid
    * @return Integer
    */
    public static Integer createAdviseAccount(String applicationid){
        String jsonbody;
        Integer responseCode;
        try {
            Application__c apps = new AOB_BOTS_SEL_Application().selectAppById(applicationid);
            if(apps.AOB_Schema_Code__c=='SOCTY'){
                AOB_BOTS_DTO_AccountAdvise acc= new AOB_BOTS_DTO_AccountAdvise();
                BankInformation bank = new BankInformation();
                AccountInformation accInf= new AccountInformation();
                AccountAdvise addv=new AccountAdvise();
                bank.bankId=botswanaCountryCode;
                accInf.schemeCode=SOCTY;
                addv.customerIdentificationNumber=apps.AOB_CIFID__c;
                addv.accountInformation=accInf;
                accInf.bankInformation=bank;
                acc.accountAdvise=addv;
                jsonbody=Json.serialize(acc);
                AOB_BOTS_API_AccountAdvise customerServiceCall = new AOB_BOTS_API_AccountAdvise(jsonbody);
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_AccountAdvise.SERVICE_NAME);
                customerServiceCall.process(obj);
                AOB_BOTS_SRV_CMNWebserviceCallQueue.newInstance().saveWebserviceCallQueues(new List<CMN_WebserviceCallQueue__c>{obj},uow);
                String appData=customerServiceCall.getResponseBody();
                if(customerServiceCall.getResponseStatusCode()==200){
                    Map<String,Object> appDataMaps = (Map<String,object>) JSON.deserializeUntyped(appData);
                    String accountsAdviseResponse=json.serialize(appDataMaps.get('accountsAdviseResponse'));
                    if(!String.isEmpty(accountsAdviseResponse)){
                        Map<String,Object> accountsAdviseResponseMaps = (Map<String,object>) JSON.deserializeUntyped(accountsAdviseResponse);
                        String accountInformation=json.serialize(accountsAdviseResponseMaps.get('accountInformation'));
                        Map<String,Object> accountInformationMaps = (Map<String,object>) JSON.deserializeUntyped(accountInformation);
                        apps.AOB_Account_Number__c=(String)accountInformationMaps.get('accountNumber');
                        responseCode= customerServiceCall.getResponseStatusCode(); 
                    }
                } else {
                    return 200;
                }
                AOB_BOTS_SRV_Application.newInstance().saveApp(new List<Application__c>{apps}, uow);
                uow.commitWork();
            } else { 
                return 200; 
            }
        } catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.createAdviseAccount',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return responseCode;
    }

    /** @description  class is used as call the esb api Wrapper*/
    public class AOB_BOTS_DTO_AccountAdvise{
        public AccountAdvise accountAdvise;
    }

    /** @description  class is used as call the esb api Wrapper*/
    public class BankInformation {
        public String bankId;
    }

    /** @description  class is used as call the esb api Wrapper*/
    public class AccountAdvise {
        public String customerIdentificationNumber;
        public AccountInformation accountInformation;
    }
    /** @description  class is used as call the esb api Wrapper*/
    public class AccountInformation {
        public String schemeCode;
        public BankInformation bankInformation;
    }
    private static boolean shouldProcessParticipant(Application_Participant__c ap) {
        return ap.Application_Documents__r.size() > 0 && ap.AOB_CIFID__c != null;
    }
        /** @description  class is used as call the esb api Wrapper*/
        public class AOB_BOTS_DTO_DSX{
            public String agent;
            public String country;
            public String cif;
            public List<Documents> documents;
        }
        /** @description  class is used as call the esb api Wrapper*/
        public class Documents {
            public String documentType;
            public String name;
            public String content;
            public string documentExpiryDate;
        }
    

     /**
    * @description This method is used as call the customerDSX api
    * @author Dayakar 
    * @return Integer 
    * @param applicationid
    */    
    public static Integer customerDSX(String applicationid){
        try{
            string jsonBody;
            Integer responseCode;         
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().getCustomerDsxApllications(applicationid);
            AOB_BOTS_DTO_DSX dsx= new AOB_BOTS_DTO_DSX();   
            for(Application_Participant__c ap:appParticpant){
                if(shouldProcessParticipant(ap)){
                    dsx.agent=ap.Application__r.AOB_PrimaryRelationshipManagerID__c;
                    dsx.cif=ap.AOB_CIFID__c;
                    dsx.country=botswanaCountryCode;
                    List<Documents> doclist= getDocumentsForParticipant(ap);     
                    dsx.documents=doclist;
                    jsonbody=Json.serialize(dsx);
                    AOB_BOTS_API_DSX customerServiceCall = new AOB_BOTS_API_DSX(jsonbody);
                    CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_DSX.SERVICE_NAME);
                    customerServiceCall.process(obj);
                    responseCode= customerServiceCall.getResponseStatusCode();
                }else{      
                    responseCode=200;
                }
            }
            return responseCode;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.customerDSX',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    private static List<Documents> getDocumentsForParticipant(Application_Participant__c ap) {
        List<Documents> docList = new List<Documents>();
        for (Application_Document__c doc : ap.Application_Documents__r) {
            if (isDocumentValid(doc)) {
                List<ContentVersion> contentVersions = getContentVersionsForDocument(doc);
                if (!contentVersions.isEmpty()) {
                    Documents newDoc = createDocument(doc, contentVersions[0]);
                    docList.add(newDoc);
                }
            }
        }
        return docList;
    }
    private static boolean isDocumentValid(Application_Document__c doc) {
        return doc.Document_Type__c != null && doc.AOB_DSX__c == true;
    }
    private static List<ContentVersion> getContentVersionsForDocument(Application_Document__c doc) {
        List<ContentDocumentLink> conDocLinks = new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityIdWithLimit(doc.Id);
    
        if (!conDocLinks.isEmpty()) {
            return new SEL_ContentVersion().getDocumentLinkByLinkedEntityIdWithLimit(conDocLinks[0].ContentDocumentId);
        }
    
        return new List<ContentVersion>();
    }
    private static Documents createDocument(Application_Document__c doc, ContentVersion cv) {
        Documents newDoc = new Documents();
        //newDoc.documentType = doc.Document_Type__c;
        String mappedDocumentType = documentTypeMappings.get(doc.Document_Type__c);
        if (mappedDocumentType == null) {
            newDoc.documentType = doc.Document_Type__c; // Use default if no mapping found
        } else {
            newDoc.documentType = mappedDocumentType;
        }
        newDoc.name = cv.Title;
        newDoc.content = EncodingUtil.base64Encode(cv.VersionData);
    
        if (doc.AOB_DateofExpiry__c != null) {
            newDoc.documentExpiryDate = String.valueOf(doc.AOB_DateofExpiry__c);
        }
    
        return newDoc;
    }


    /**
    * @description This method is used as call the svsSignature api
    * @param applicationId
    * @return Integer 
    */
    @AuraEnabled
    public static Integer svsSignature(String applicationId){
        Integer responseCode;
        ContentVersion cv;
        try {            
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().getSvsSignatureApllications(applicationId);
            for(Application_Participant__c ap:appParticpant){
                if(ap.Application_Documents__r.size()>0){
                ContentDocumentLink conDoClist=new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityIdWithLimitOne(ap.Application_Documents__r[0].Id);
                cv = getContentVersionForSvsSignature(cv,conDoClist);
                if(cv!=null && ap.AOB_CIFID__c!=null){
                    AOB_BOTS_DTO_SVS svs= new AOB_BOTS_DTO_SVS();
                    SignatureAddRequest signatureBody= new SignatureAddRequest();
                    Body b= new Body();
                    signatureBody.customerNumber=ap.AOB_CIFID__c;
                    signatureBody.bankIdentifier=botswanaCountryCode;
                    signatureBody.imageAccessCode=number01;
                    signatureBody.signatureFile=EncodingUtil.base64Encode(cv.VersionData); 
                    b.signatureAddRequest=signatureBody;
                    svs.Body=b;
                    String jsonbody=Json.serialize(svs);
                    AOB_BOTS_API_SVS customerServiceCall = new AOB_BOTS_API_SVS(jsonbody);
                    CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_SVS.SERVICE_NAME);
                    customerServiceCall.process(obj);
                    responseCode= customerServiceCall.getResponseStatusCode();
                }
                
                }else{
                    
                    responseCode=200;
                }
            }
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.svsSignature',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }

        return responseCode;  
    }


    private static ContentVersion getContentVersionForSvsSignature(ContentVersion cv,ContentDocumentLink conDoClist){
        if(conDoClist!=null){
            cv= new SEL_ContentVersion().selectSingleContentById(conDoClist.ContentDocumentId);
        }
        return cv;
    }
    /** @description  class is used as call the esb api Wrapper*/
    public class AOB_BOTS_DTO_SVS{  
        public Body Body;
    }
    /** @description  class is used as call the esb api Wrapper*/
    public class SignatureAddRequest {
        public String customerNumber;
        public String bankIdentifier;
        public String imageAccessCode;
        public String signatureFile;
    }
    /** @description  class is used as call the esb api Wrapper*/
    public class Body {
        public SignatureAddRequest signatureAddRequest;
    }
        /**
    * @description This method is used as call the corpDSX api
    * @author Dayakar 
    * @return Integer
    * @param applicationid
    */ 
    public static Integer corpDSX(String applicationid){
        try{
            string jsonBody;
            Integer responseCode;        
            List<Application__c> applicationlist =new AOB_BOTS_SEL_Application().getCorpDsxApllications(applicationId);
            AOB_BOTS_DTO_DSX dsx= new AOB_BOTS_DTO_DSX();
            for(Application__c ap:applicationlist){
                if(ap.Application_Documents__r.size()>0){
                    dsx.agent=ap.AOB_PrimaryRelationshipManagerID__c;
                    dsx.cif=ap.AOB_CIFID__c;
                    dsx.country=botswanaCountryCode;
                    List<Documents> doclist= new List<Documents>();
                    for(Application_Document__c cc:ap.Application_Documents__r){
                        doclist = populateDocumentsList(doclist,cc);
                    }
                    dsx.documents=doclist;
                    jsonbody=Json.serialize(dsx);      
                    AOB_BOTS_API_DSX customerServiceCall = new AOB_BOTS_API_DSX(jsonbody);
                    CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_DSX.SERVICE_NAME);
                    customerServiceCall.process(obj);
                    responseCode= customerServiceCall.getResponseStatusCode();
                }else{             
                    return 200;
                }
            }
            return responseCode;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.corpDSX',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }

    private static List<Documents> populateDocumentsList(List<Documents> docList, Application_Document__c cc) {
        if(cc.Document_Type__c !=null && cc.AOB_DSX__c==true){
            List<ContentDocumentLink> conDocList =new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityIdWithLimit(cc.Id);
            if (!conDocList.isEmpty()) {
                List<ContentVersion> cvList = new SEL_ContentVersion().getDocumentLinkByLinkedEntityIdWithLimit(conDocList[0].ContentDocumentId);
                docList = prepareDocumentsList(docList,cvList,cc);
            }
        }
        return docList;
    }

    private static List<Documents> prepareDocumentsList( List<Documents> docList, List<ContentVersion> cvList, Application_Document__c cc) {
        if (!cvList.isEmpty()) {
            Documents dd = new Documents();
          	String mappedDocumentType = documentTypeMappings.get(cc.Document_Type__c);
            if (mappedDocumentType == null) {
                dd.documentType = cc.Document_Type__c;
            }else{
                dd.documentType = mappedDocumentType;
            }
            dd.name = cvList[0].Title;
            dd.content = EncodingUtil.base64Encode(cvList[0].VersionData);
            if (cc.AOB_DateofExpiry__c != null) {
                dd.documentExpiryDate = String.valueOf(cc.AOB_DateofExpiry__c);
            }
            docList.add(dd);
        }
        return docList;
    }

        /**
    * @description This method is used as call the accountODcreation api
    * @author Dayakar 
    * @return Integer
    * @param applicationid
    */
    public static Integer accountODcreation(String applicationid){
        try{
            Application__c apps = new AOB_BOTS_SEL_Application().selectAppById(applicationid);
            if(apps.AOB_Schema_Code__c=='OD001' || apps.AOB_Schema_Code__c=='OD005'){
                AOB_BOTS_DTO_ODAccountCreationBean accountCreationBeanRecord = new AOB_BOTS_DTO_ODAccountCreationBean();
                AOB_BOTS_DTO_ODAccountCreationBean.AccountTypeInfo accountType = new AOB_BOTS_DTO_ODAccountCreationBean.AccountTypeInfo();
                accountType.schemaCode = apps.AOB_Schema_Code__c; 
                AOB_BOTS_DTO_ODAccountCreationBean.bankInformation bankInfo = new AOB_BOTS_DTO_ODAccountCreationBean.bankInformation();
                bankInfo.bankId = botswanaCountryCode; 
                bankInfo.branchId = apps.AOB_Preferred_Branch__c; 
                AOB_BOTS_DTO_ODAccountCreationBean.ODAcctGeneralInformation acctGeneralInfo = new AOB_BOTS_DTO_ODAccountCreationBean.ODAcctGeneralInformation();
                acctGeneralInfo.despatchMode = '';
                AOB_BOTS_DTO_ODAccountCreationBean.ODAccountAddRqInfo accountAddRq = new AOB_BOTS_DTO_ODAccountCreationBean.ODAccountAddRqInfo();
                accountAddRq.customerNumber     = apps.AOB_CIFID__c;
                accountAddRq.accountType        = accountType;
                accountAddRq.accountCurrency    = botswanaCountryCurrencyCode;
                accountAddRq.bankInfo           = bankInfo;
                accountAddRq.localCalculationFlag   = '';
                AOB_BOTS_DTO_ODAccountCreationBean.ODaccountAddCustomDataInfo accountAddCustomData = new AOB_BOTS_DTO_ODAccountCreationBean.ODaccountAddCustomDataInfo();
                accountAddCustomData.PFNum                  = apps.AOB_PortfolioNumber__c;  
                accountCreationBeanRecord.ODAccountAddRq          = accountAddRq;
                accountCreationBeanRecord.ODAccountAddCustomData  = accountAddCustomData;
                String jsonbody=json.serialize(accountCreationBeanRecord);  
                AOB_BOTS_API_ODAccountCreation customerServiceCall = new AOB_BOTS_API_ODAccountCreation(jsonbody);
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_DSX.SERVICE_NAME);
                customerServiceCall.process(obj);
                String appData=customerServiceCall.getResponseBody();
                if(customerServiceCall.getResponseStatusCode()==200){
                    Map<String,Object> appDataMaps = (Map<String,object>) JSON.deserializeUntyped(appData);
                    String accountsAdviseResponse=json.serialize(appDataMaps.get('ODAccountAddRes'));
                    if(!String.isEmpty(accountsAdviseResponse)){
                        Map<String,Object> accountsAdviseResponseMaps = (Map<String,object>) JSON.deserializeUntyped(accountsAdviseResponse);
                        String accountInformation=json.serialize(accountsAdviseResponseMaps.get('ODaccountNumber'));
                        Map<String,Object> accountInformationMaps = (Map<String,object>) JSON.deserializeUntyped(accountInformation);
                        apps.AOB_Account_Number__c=(String)accountInformationMaps.get('accountNumber');
                    }     
                }
                AOB_BOTS_SRV_Application.newInstance().saveApp(new List<Application__c>{apps}, uow);
                uow.commitWork();  
                Integer responscode= customerServiceCall.getResponseStatusCode();
                return responscode;
            }else{
                return 200;
            }
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.accountODcreation',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }

    /**
    * @description This method is used as call the createCustomer api
    * @return Integer
    * @param applicationid
    */
    public static Integer createCustomer(String applicationid){
        try{
            string jsonBody;
            Integer responscode;
            List<Application_Participant__c> directorDataList = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByapplicationIdandsignatory(applicationId);
            List<Application_Participant__c> updateciflist=new List<Application_Participant__c>();
            for(Application_Participant__c ap:directorDataList){
                if(ap.AOB_CIFID__c==null){ 
                    List<AOB_BOTS_DTO_CorpRetail.Identification> idenlist= new List<AOB_BOTS_DTO_CorpRetail.Identification>();
                    AOB_BOTS_DTO_CorpRetail.Identification identificationRecord = new AOB_BOTS_DTO_CorpRetail.Identification();
                    identificationRecord.identificationType                 = '10'; 
                    identificationRecord.identificationNumber               = ap.AOB_IDNumber__c;
                    identificationRecord.issuingCountry                     = ap.Application__r.AOB_Preferred_Branch__c;
                    identificationRecord.issuedOrganisation                 = ap.Application__r.AOB_IDIssuedOrganization__c;
                    identificationRecord.issuedDate                         = issuedDate; 
                    identificationRecord.expirationDate                     = '31-12-2056'; 
                    identificationRecord.PreferredIdentificationIndicator   = PreferredIdentificationIndicatorY;
                    identificationRecord.documentCode                       = documentCode;
                    identificationRecord.documentDescription                = documentDescription;
                    identificationRecord.documentTypeCode                   = documentTypeCode;
                    identificationRecord.documentTypeDescription            = documentTypeDescription;            
                    idenlist.add(identificationRecord);
                    AOB_BOTS_DTO_CorpRetail.addressTypes typeHomeRecord = new AOB_BOTS_DTO_CorpRetail.addressTypes();
                    typeHomeRecord.addressType  = commentHome;
                    AOB_BOTS_DTO_CorpRetail customerBeanRecord = new AOB_BOTS_DTO_CorpRetail(); 
                    customerBeanRecord.EASIndicator  = EASIndicator; 
                    customerBeanRecord.customerType  = customerType;
                    customerBeanRecord.identification      = idenlist;
                    customerBeanRecord = createCustomerBeanRecord(customerBeanRecord,ap);
                    jsonbody=JSON.serialize(customerBeanRecord);
                    AOB_BOTS_API_CreateCustomer customerServiceCall = new AOB_BOTS_API_CreateCustomer(jsonbody);
                    CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_DSX.SERVICE_NAME);
                    customerServiceCall.process(obj);
                    String appData=customerServiceCall.getResponseBody();
                    if(customerServiceCall.getResponseStatusCode()==200){
                        Map<String,Object> appDataMaps = (Map<String,object>) JSON.deserializeUntyped(appData);
                        ap.AOB_CIFID__c=(String)appDataMaps.get('uuid');
                        updateciflist.add(ap);
                    }
                    responscode= customerServiceCall.getResponseStatusCode();
                }else{
                    return 200;
                }
            }
            if(updateciflist.size()>0){
                AOB_BOTS_SRV_ApplicationParticipant.newInstance().saveAppParticipant(updateCIFList, uow);
                uow.commitWork();  
            }
            return responscode;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.createCustomer',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }

    public static AOB_BOTS_DTO_CorpRetail createCustomerBeanRecord(AOB_BOTS_DTO_CorpRetail customerBeanRecord,Application_Participant__c ap) {
        AOB_BOTS_DTO_CorpRetail.Permits permitsRecord = createPermitsRecord();                    
        AOB_BOTS_DTO_CorpRetail.Misc miscRecord = createMiscRecord();
        AOB_BOTS_DTO_CorpRetail.Addresses addressesRecord = createAddress(ap);
        AOB_BOTS_DTO_CorpRetail.Contacts emailRecord = createEmailRecord(ap, contactType); 
        AOB_BOTS_DTO_CorpRetail.Contacts contactsRecord = createContact('PHONE',ap.CNGCU_Phone__c); 
        AOB_BOTS_DTO_CorpRetail.SourceOfFunds sourceOfFundsRecord = createSourceOfFundsRecord(ap, botswanaCountryCurrencyCode); 
        AOB_BOTS_DTO_CorpRetail.PersonDetails personDetailsRecord =createPersonDetails(ap); 
        AOB_BOTS_DTO_CorpRetail.TaxClassification taxClassificationRecord = createTaxClassificationRecord();
        customerBeanRecord.personDetails = personDetailsRecord;
        customerBeanRecord.residenceCountry    = botswanaCountryCode;
        customerBeanRecord.prefLanguage        = prefLanguage;
        customerBeanRecord.taxClassification    = taxClassificationRecord;
        customerBeanRecord.sourceOfFunds        = new List<AOB_BOTS_DTO_CorpRetail.SourceOfFunds> {sourceOfFundsRecord};                       
        customerBeanRecord.contacts      = new List<AOB_BOTS_DTO_CorpRetail.Contacts> {contactsRecord, emailRecord};              
        customerBeanRecord.permits              = new List<AOB_BOTS_DTO_CorpRetail.Permits> {permitsRecord};
        customerBeanRecord.misc                 = new List<AOB_BOTS_DTO_CorpRetail.Misc> {miscRecord};
        customerBeanRecord.addresses            = new List<AOB_BOTS_DTO_CorpRetail.Addresses> {addressesRecord};
        customerBeanRecord.relManagerLink = ap.application__r.AOB_PrimaryRelationshipManagerID__c;
        customerBeanRecord.responsibleBranch = ap.Application__r.AOB_PortfolioNumber__c;
        customerBeanRecord.authorizationGroup = '';
        customerBeanRecord.gIIN = '';
        customerBeanRecord.mktgSegment = '';
        customerBeanRecord.accessOwnerSegment = '';
        customerBeanRecord.segmentCategory = '';
        customerBeanRecord.minorIndicator = '';
        customerBeanRecord.seniorIndicator = '';
        return customerBeanRecord;
    }
    public static AOB_BOTS_DTO_CorpRetail.Permits createPermitsRecord() {
        AOB_BOTS_DTO_CorpRetail.Permits permitsRecord = new AOB_BOTS_DTO_CorpRetail.Permits();
        permitsRecord.permitType = '';
        permitsRecord.permitNumber = '';
        permitsRecord.effDt = '';
        permitsRecord.expDt = '';
        return permitsRecord;
    }
    public static AOB_BOTS_DTO_CorpRetail.Misc createMiscRecord() {
        AOB_BOTS_DTO_CorpRetail.Misc miscRecord = new AOB_BOTS_DTO_CorpRetail.Misc();
        miscRecord.key = '';
        miscRecord.value = '';
        miscRecord.miscDate = '';
        miscRecord.counterPartyInfo = '';
        miscRecord.distributionChannel = '';
        return miscRecord;
    }
    private static AOB_BOTS_DTO_CorpRetail.Addresses createAddress(Application_Participant__c ap) {
        AOB_BOTS_DTO_CorpRetail.Addresses addressesRecord = new AOB_BOTS_DTO_CorpRetail.Addresses();
        addressesRecord.uuid = '';
        addressesRecord.line1 = ap.AOB_Street__c;
        addressesRecord.line2 = '';
        addressesRecord.line3 = '';
        addressesRecord.city = ap.Botswana_City__c;
        if (ap.Botswana_City__c != null) {
            AOB_ReferencedData__c ar = new AOB_BOTS_SEL_ReferencedData().getReferencedDataByCode(ap.Botswana_City__c);
            addressesRecord.province = ar.AOB_Value__c;
        }
        addressesRecord.postalCode = ap.AOB_PostalCode__c;
        addressesRecord.countryCode = botswanaCountryCode;
        addressesRecord.preferredInd = '';
        addressesRecord.preferredFormat = '';
        addressesRecord.startDate = startDateValue;
        addressesRecord.comment = commentHome;
        if (ap.AOB_AddressValidFrom__c != null) {
            addressesRecord.startDate = String.valueOf(ap.AOB_AddressValidFrom__c);
        }
        AOB_BOTS_DTO_CorpRetail.addressTypes typeHomeRecord = new AOB_BOTS_DTO_CorpRetail.addressTypes();
        typeHomeRecord.addressType = commentHome;
        addressesRecord.addressTypes = new List<AOB_BOTS_DTO_CorpRetail.addressTypes> {typeHomeRecord};
        return addressesRecord;
    }

    private static AOB_BOTS_DTO_CorpRetail.Contacts createContact(String contactType, String value) {
        AOB_BOTS_DTO_CorpRetail.Contacts contactRecord = new AOB_BOTS_DTO_CorpRetail.Contacts();
        contactRecord.contactType = contactType;
        contactRecord.value = value;
        contactRecord.countryCode = botswanaCountryCallingCode;
        contactRecord.localCode = botswanaLocalCode;
        contactRecord.cityCode = botswanaCityCode;
        return contactRecord;
    }
    public static AOB_BOTS_DTO_CorpRetail.SourceOfFunds createSourceOfFundsRecord(Application_Participant__c ap, String currencyCode) {
        AOB_BOTS_DTO_CorpRetail.SourceOfFunds sourceOfFundsRecord = new AOB_BOTS_DTO_CorpRetail.SourceOfFunds();
        sourceOfFundsRecord.sourceFundType = '';
        sourceOfFundsRecord.sourceFundAmount = String.valueOf(ap.AOB_GrossAnnualIncome__c); 
        sourceOfFundsRecord.currencyCode = currencyCode;
        sourceOfFundsRecord.tradeFinanceIndicator = '';
        return sourceOfFundsRecord;
    }

    public static AOB_BOTS_DTO_CorpRetail.PersonDetails createPersonDetails() {
        AOB_BOTS_DTO_CorpRetail.PersonDetails personDetailsRecord = new AOB_BOTS_DTO_CorpRetail.PersonDetails();
        personDetailsRecord.firstName = '';
        personDetailsRecord.lastName = '';
        personDetailsRecord.initials = '';
        personDetailsRecord.otherName = '';
        personDetailsRecord.birthName = '';
        personDetailsRecord.preferredName = '';
        personDetailsRecord.dob = '';
        personDetailsRecord.gender = '';
        personDetailsRecord.title = ''; 
        personDetailsRecord.maritalStatus = '';
        personDetailsRecord.citizenshipCountry = '';
        personDetailsRecord.nationality = '';
        personDetailsRecord.countryOfBirth = ''; 
        personDetailsRecord.ethnicity = '';
        personDetailsRecord.foreignNationalIndicator = '';
        personDetailsRecord.foreignNationalReport = '';
        personDetailsRecord.foreignNationalStatus = '';
        personDetailsRecord.assetClassification = '';
        personDetailsRecord.homeOwnership = '';
        personDetailsRecord.qualification = '';
        personDetailsRecord.maritalPropertyRegime = '';
        personDetailsRecord.dependants = 0;
        personDetailsRecord.dependantsMinor = 0;
        personDetailsRecord.clientType = '';
        personDetailsRecord.studentIndicator = false;
        personDetailsRecord.purgeAllowedIndicator = '';
        personDetailsRecord.digitalBankingIndicator = '';
        return personDetailsRecord;
    }
    public static AOB_BOTS_DTO_CorpRetail.TaxClassification createTaxClassificationRecord() {
        AOB_BOTS_DTO_CorpRetail.TaxClassification taxClassificationRecord = new AOB_BOTS_DTO_CorpRetail.TaxClassification();
        taxClassificationRecord.taxCountry = '';
        taxClassificationRecord.taxRegion = '';
        taxClassificationRecord.taxType = '';
        taxClassificationRecord.taxGroup = '';
        taxClassificationRecord.taxExemptReason = '';
        return taxClassificationRecord;
    }

    public static AOB_BOTS_DTO_CorpRetail.Contacts createEmailRecord(Application_Participant__c ap, String contactType) {
        AOB_BOTS_DTO_CorpRetail.Contacts emailRecord = new AOB_BOTS_DTO_CorpRetail.Contacts();
        emailRecord.contactType = contactType;
        emailRecord.value = ap.CNGCU_Email__c;
        return emailRecord;
    }
    private static AOB_BOTS_DTO_CorpRetail.PersonDetails createPersonDetails(Application_Participant__c ap) {
        AOB_BOTS_DTO_CorpRetail.PersonDetails personDetailsRecord = new AOB_BOTS_DTO_CorpRetail.PersonDetails();
        String fullName = ap.AOB_FullName__c;
        if (fullName.contains(' ')) {
            String[] names = fullName.split(' ');    
            personDetailsRecord.firstName = names[0];
            personDetailsRecord.lastName = names[1];
        } else {
            personDetailsRecord.firstName = '';
            personDetailsRecord.lastName = fullName;
        }
        personDetailsRecord.initials = 'P';
        personDetailsRecord.otherName = fullName;
        personDetailsRecord.birthName = fullName;
        personDetailsRecord.preferredName = fullName;
        if (ap.AOB_DateofBirth__c != null) {
            personDetailsRecord.dob = String.valueOf(ap.AOB_DateofBirth__c);
        }
        personDetailsRecord.gender = ap.AOB_Gender__c;
        personDetailsRecord.title = ap.AOB_Title__c;
        personDetailsRecord.maritalStatus = ap.AOB_MaritalStatus__c;
        personDetailsRecord.citizenshipCountry = botswanaCountryCode;
        personDetailsRecord.nationality = ap.AOB_PrimaryNationality__c;
        personDetailsRecord.countryOfBirth = ap.AOB_PrimaryNationality__c;
        return personDetailsRecord;
    }

    public static AOB_BOTS_DTO_CorpRetail createCustomerBeanRecord(AOB_BOTS_DTO_CorpRetail customerBeanRecord) {
        AOB_BOTS_DTO_CorpRetail.Contacts contactsRecord = createContactsRecord('','');
        AOB_BOTS_DTO_CorpRetail.Contacts emailRecord = createEmailRecord('','');
        AOB_BOTS_DTO_CorpRetail.Misc miscRecord = createMisc();
        AOB_BOTS_DTO_CorpRetail.EmploymentDetails employmentDetailsRecord = createEmploymentDetails(); 
        AOB_BOTS_DTO_CorpRetail.ProminentInfluentialPerson prominentInfluentialPersonRecord = createProminentInfluentialPerson();
        AOB_BOTS_DTO_CorpRetail.CustomerRoles customerRolesRecord = createCustomerRoles();
        AOB_BOTS_DTO_CorpRetail.ComplianceRoles complianceRolesRecord = createComplianceRoles();
        customerBeanRecord.complianceRoles      = new List<AOB_BOTS_DTO_CorpRetail.ComplianceRoles> {complianceRolesRecord};
        customerBeanRecord.employmentDetails    = employmentDetailsRecord;
        customerBeanRecord.prominentInfluentialPerson = prominentInfluentialPersonRecord;
        customerBeanRecord.customerRoles        = new List<AOB_BOTS_DTO_CorpRetail.customerRoles> {customerRolesRecord};
        customerBeanRecord.misc                 = new List<AOB_BOTS_DTO_CorpRetail.Misc> {miscRecord};
        customerBeanRecord.contacts      = new List<AOB_BOTS_DTO_CorpRetail.Contacts> {contactsRecord, emailRecord};
        customerBeanRecord.responsibleBranch    = '';
        customerBeanRecord.authorizationGroup   = '';
        customerBeanRecord.gIIN                 = '';
        customerBeanRecord.minorIndicator       = '';
        customerBeanRecord.seniorIndicator      = '';
        customerBeanRecord.mktgSegment          = number001; 
        customerBeanRecord.segmentCategory      = number105;
        customerBeanRecord.prefLanguage        = prefLanguage;
        customerBeanRecord.residenceCountry    = botswanaCountryCode;
        return customerBeanRecord;
    }
    public static AOB_BOTS_DTO_CorpRetail.Contacts createContactsRecord(String contactType,String value) {
        AOB_BOTS_DTO_CorpRetail.Contacts contactsRecord = new AOB_BOTS_DTO_CorpRetail.Contacts();
        contactsRecord.contactType = contactType;
        contactsRecord.value = value;
        return contactsRecord;
    }

    public static AOB_BOTS_DTO_CorpRetail.Contacts createEmailRecord(String contactType,String emailValue) {
        AOB_BOTS_DTO_CorpRetail.Contacts emailRecord = new AOB_BOTS_DTO_CorpRetail.Contacts();
        emailRecord.contactType = contactType;
        emailRecord.value = emailValue;
        return emailRecord;
    } 
    public static AOB_BOTS_DTO_CorpRetail.Misc createMisc() {
        AOB_BOTS_DTO_CorpRetail.Misc miscRecord = new AOB_BOTS_DTO_CorpRetail.Misc();
        miscRecord.key = '';
        miscRecord.value = '';
        miscRecord.miscDate = '';
        miscRecord.counterPartyInfo = '';
        miscRecord.distributionChannel = 'B'; // Assuming 'B' is a fixed value
        return miscRecord;
    }
    public static AOB_BOTS_DTO_CorpRetail.EmploymentDetails createEmploymentDetails() {
        AOB_BOTS_DTO_CorpRetail.EmploymentDetails employmentDetailsRecord = new AOB_BOTS_DTO_CorpRetail.EmploymentDetails();
        employmentDetailsRecord.orgName = '';
        employmentDetailsRecord.staffIndicator = '';
        employmentDetailsRecord.startDate = '';
        employmentDetailsRecord.endDate = '';
        employmentDetailsRecord.industrialSector = '';
        employmentDetailsRecord.occupation = '';
        employmentDetailsRecord.employmentType = '';
        return employmentDetailsRecord;
    }
    public static AOB_BOTS_DTO_CorpRetail.ProminentInfluentialPerson createProminentInfluentialPerson() {
        AOB_BOTS_DTO_CorpRetail.ProminentInfluentialPerson prominentInfluentialPersonRecord = new AOB_BOTS_DTO_CorpRetail.ProminentInfluentialPerson();
        prominentInfluentialPersonRecord.pipInd = '';
        prominentInfluentialPersonRecord.relatedInd = '';
        prominentInfluentialPersonRecord.name = '';
        prominentInfluentialPersonRecord.relationType = '';
        return prominentInfluentialPersonRecord;
    }
    public static AOB_BOTS_DTO_CorpRetail.ComplianceRoles createComplianceRoles() {
        AOB_BOTS_DTO_CorpRetail.ComplianceRoles complianceRolesRecord = new AOB_BOTS_DTO_CorpRetail.ComplianceRoles();
        complianceRolesRecord.compRole = '';
        complianceRolesRecord.complianceGrade = '';
        complianceRolesRecord.complianceStatus = '';
        complianceRolesRecord.statusReason = '';
        complianceRolesRecord.verifiedBy = '';
        return complianceRolesRecord;
    }

    public static AOB_BOTS_DTO_CorpRetail.CustomerRoles createCustomerRoles() {
        AOB_BOTS_DTO_CorpRetail.CustomerRoles customerRolesRecord = new AOB_BOTS_DTO_CorpRetail.CustomerRoles();
        customerRolesRecord.role = '';
        customerRolesRecord.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        customerRolesRecord.endDate = '';
        return customerRolesRecord;
    }

}