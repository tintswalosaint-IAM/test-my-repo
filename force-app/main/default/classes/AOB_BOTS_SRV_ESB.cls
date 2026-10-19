/**
* @description This class is used as call the esb api
* @author Dayakar 
* @date Jan 5th 2021
* @last modified on  : 09-09-2024
* @last modified by  : Nagendraprasad Mylavarapu
* @ Modification Description : used new field AOB_DateofExpiry__c and added condition for AOB_DateofExpiry__c
*/

public without sharing class AOB_BOTS_SRV_ESB {
    private static sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { Application__c.SObjectType,Application_Participant__c.SObjectType,CMN_WebserviceCallQueue__c.SObjectType });
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_BOTS_SRV_ESB');
    private static final String botswanaCountryCode = 'BW'; 
    private static final String botswanaCountryCurrencyCode = 'BWP';
    private static final String botswanaCountryCallingCode = '267'; 
    private static final String botswanaLocalCode = '267'; 
    private static final String botswanaCityCode = '267'; 
    private static final String commentHome = 'Home';  
    private static final String addressTypeMail = 'Mailing'; 
    private static final String contactType = 'EMAIL';
    private static final String contactTypePhone = 'PHONE';
    private static final String customerType  = 'INDIVIDUAL';
    private static final String prefLanguage  = 'en';
    private static final String accessOwnerSegment = 'Preferential Banking';
    private static final String startDate = '2023-04-03T00:00:00.000';
    private static final String issuedDate = '2018-03-28T00:00:00.000';
    private static final String expirationDate = '9999-12-31T00:00:00.000'; 
    private static final String documentCodeD0701 = 'D0701';
    private static final String documentDescriptionTaxRegisterationCert = 'Tax registration certificate';
    private static final String documentTypeCodeDT112  = 'DT112';
    private static final String documentTypeDescriptionIPUCA = 'Indentification Proof Unlisted Cat A';
    private static final String sourcofFundTypeBP = 'Business Proceeds';
    private static final String sourcofFundTypeGC = 'Group Contribution';
    private static final String orgEstablishDt = '2010-10-01T00:00:00.000Z';
    private static final String legalForm = '022';
    private static final String purgeAllowedIndicator = 'y';
    private static final String tradeFinanceIndicator = 'N';
    private static final String number001 = '001';
    private static final String number105 = '105';
    private static final Integer number0 = 0;
    private static final String PreferredIdentificationIndicatorY = 'Y';
    private static Map<String, String> documentTypeMappings = new Map<String, String>{
        'Source of Funds' => 'Financial Data\tSource of Funds',
        'Business Address' => 'KYC Documents\tBusiness Address',
        'Proof Of Identity' => 'KYC Documents\tProof of Identity',
        'Proof Of Address'=> 'KYC Documents\tProof of Residence'    
    };

    /**
    * @description This method is used as call the customerDSX api
    * @author Dayakar 
    * @date Jan 5th 2021
    * @return Integer 
    * @param applicationid
    */    
    @AuraEnabled 
    public static Integer customerDSX(String applicationid){
        try{
            return AOB_BOTS_SRV_ESB_Helper.customerDSX(applicationid);
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.customerDSX',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
    * @description This method is used as call the corpDSX api
    * @author Dayakar 
    * @date Jan 5th 2021
    * @return Integer
    * @param applicationid
    */ 
    @AuraEnabled
    public static Integer corpDSX(String applicationid){
        try{
            return AOB_BOTS_SRV_ESB_Helper.corpDSX(applicationid);
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.corpDSX',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
    * @description This method is used as call the accountODcreation api
    * @author Dayakar 
    * @date Jan 5th 2021
    * @return Integer
    * @param applicationid
    */
    @AuraEnabled
    public static Integer accountODcreation(String applicationid){
        try{
            return AOB_BOTS_SRV_ESB_Helper.accountODcreation(applicationid);
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.accountODcreation',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
    * @description This method is used as call the searchCustomer api
    * @author Dayakar 
    * @date Jan 5th 2021
    * @return Integer
    * @param applicationId
    */
    @AuraEnabled
    public static Integer searchCustomer(String applicationId){
        try{
            return AOB_BOTS_SRV_ESB_Helper.searchCustomer(applicationId);
        } catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.searchCustomer',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
    * @description This method is used as call the searchCorp api
    * @return Integer
    * @param applicationId
    */
    @AuraEnabled
    public static Integer searchCorp(String applicationId){
        try{
            return AOB_BOTS_SRV_ESB_Helper.searchCorp(applicationId);
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.searchCorp'+documentTypeMappings,ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        } 
    } 

    /**
    * @description This method is used as call the createCustomer api
    * @return Integer
    * @param applicationid
    */
    @AuraEnabled 
    public static Integer createCustomer(String applicationid){
        try{
            return AOB_BOTS_SRV_ESB_Helper.createCustomer(applicationid);
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.createCustomer',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }

    private static List<AOB_BOTS_DTO_CorpRetail.relatedParties> createRelatedPartiesList(List<Application_Participant__c> directorDataList) {
        List<AOB_BOTS_DTO_CorpRetail.relatedParties> partiesList = new List<AOB_BOTS_DTO_CorpRetail.relatedParties>();
        for (Application_Participant__c ap : directorDataList) {
            AOB_BOTS_DTO_CorpRetail.relatedParties party = new AOB_BOTS_DTO_CorpRetail.relatedParties();
            String fullName = ap.AOB_FullName__c;
            if (fullName.contains(' ')) {
                String[] names = fullName.split(' ');
                party.firstName = names[0];
                party.lastName = names[1];
            } else {
                party.firstName = '';
                party.lastName = fullName;
            }
            party.partyId = ap.AOB_CIFID__c;
            party.relatedType = ap.AOB_Title__c;
            party.signatoryIndicator = (ap.AOB_Director__c && !ap.AOB_Signatory__c) ? 'N' : 'Y';
            partiesList.add(party);
        }
        return partiesList;
    }
    private static AOB_BOTS_DTO_CorpRetail.Addresses createMailingAddressRecord(Application__c apps,AOB_BOTS_DTO_CorpRetail.addressTypes typeMailingRecord) {
        AOB_BOTS_DTO_CorpRetail.Addresses mailingAddRecord = new AOB_BOTS_DTO_CorpRetail.Addresses();
        mailingAddRecord.uuid = '';
        mailingAddRecord.line1 = apps.AOB_Street__c;
        mailingAddRecord.line2 = '';
        mailingAddRecord.line3 = '';
        mailingAddRecord.city = apps.AOB_BotswanaCity__c;
        
        if (apps.AOB_BotswanaCity__c != null) {
            AOB_ReferencedData__c ar = new AOB_BOTS_SEL_ReferencedData().getReferencedDataByCode(apps.AOB_BotswanaCity__c);
            mailingAddRecord.province = ar.AOB_Value__c;
        }
        
        mailingAddRecord.postalCode = apps.AOB_PostalCode__c;
        mailingAddRecord.countryCode = botswanaCountryCode;
        mailingAddRecord.preferredInd = '';
        mailingAddRecord.preferredFormat = '';
        mailingAddRecord.comment = '';
        
        if (apps.AOB_AddressValidFrom__c != null) {
            mailingAddRecord.startDate = startDate; // Adjust the start date accordingly
        }
        
        mailingAddRecord.addressTypes = new List<AOB_BOTS_DTO_CorpRetail.addressTypes> {typeMailingRecord}; // Assuming typeMailingRecord is already defined
        return mailingAddRecord;
    }
    private static AOB_BOTS_DTO_CorpRetail.Addresses createAddressesRecord(Application__c apps,AOB_BOTS_DTO_CorpRetail.addressTypes typeHomeRecord) {
        AOB_BOTS_DTO_CorpRetail.Addresses addressesRecord = new AOB_BOTS_DTO_CorpRetail.Addresses();
        addressesRecord.uuid = '';
        addressesRecord.line1 = apps.AOB_Street__c;
        addressesRecord.line2 = '';
        addressesRecord.line3 = apps.AOB_PortfolioNumber__c;
        addressesRecord.city = apps.AOB_BotswanaCity__c;
        
        if (apps.AOB_BotswanaCity__c != null) {
            AOB_ReferencedData__c ar = new AOB_BOTS_SEL_ReferencedData().getReferencedDataByCode(apps.AOB_BotswanaCity__c);
            addressesRecord.province = ar.AOB_Value__c;
        }
        
        addressesRecord.postalCode = apps.AOB_PostalCode__c;
        addressesRecord.countryCode = botswanaCountryCode;
        addressesRecord.preferredInd = '';
        addressesRecord.preferredFormat = '';
        addressesRecord.comment = commentHome;
        addressesRecord.startDate = startDate; // Adjust the start date accordingly
        addressesRecord.addressTypes = new List<AOB_BOTS_DTO_CorpRetail.addressTypes> {typeHomeRecord}; // Assuming typeHomeRecord is already defined
        return addressesRecord;
    }
    private static String getSourceAmount(Application_Participant__c apppart) {
        String sourceAmount = null;
        if (apppart.AOB_MonthlyNetIncome__c != null) {
            sourceAmount = String.valueOf(apppart.AOB_MonthlyNetIncome__c);
        }
        return sourceAmount;
    }

    public static String setBusinessName(Application__c apps) {
        String businessName;
        if ((apps.AOB_Schema_Code__c == 'OD001' || apps.AOB_Schema_Code__c == 'OD005') && 
            (apps.AOB_BCCEntityType__c != 'Sole Proprietor' || apps.AOB_BCCEntityType__c != 'Partnership')) {
            if (apps.AOB_BCCEntityType__c == 'Sole Proprietor' || apps.AOB_BCCEntityType__c == 'Partnership') {
                businessName = apps.AOB_BusinessLegalName__c;
            } else {                    
                businessName = apps.AOB_BusinessLegalName__c;
            }
        } else if (apps.AOB_BCCEntityType__c == 'Sole Proprietor' || apps.AOB_BCCEntityType__c == 'Partnership') {
            businessName = apps.AOB_BusinessLegalName__c;
        } else {
            businessName = apps.AOB_GroupName__c;
        }
        return businessName;
    }
    public static String setIdentificationNumber(Application__c apps) {
        String identificationNum;
        if ((apps.AOB_Schema_Code__c == 'OD001' || apps.AOB_Schema_Code__c == 'OD005') && 
            (apps.AOB_BCCEntityType__c != 'Sole Proprietor' || apps.AOB_BCCEntityType__c != 'Partnership')) {
            if (apps.AOB_BCCEntityType__c == 'Sole Proprietor' || apps.AOB_BCCEntityType__c == 'Partnership') {
                identificationNum = apps.AOB_BusinessLegalName__c;
            } else {                    
                identificationNum = apps.AOB_RegistrationNumber__c;
            }
        } else if (apps.AOB_BCCEntityType__c == 'Sole Proprietor' || apps.AOB_BCCEntityType__c == 'Partnership') {
            identificationNum = apps.AOB_BusinessLegalName__c;
        } else {
            identificationNum = apps.AOB_GroupName__c;
        }
        return identificationNum;

    }
    public static String setTurnover(Application__c apps,List<Application_Participant__c> directorDataList) {
        String turnover;
        if ((apps.AOB_Schema_Code__c == 'OD001' || apps.AOB_Schema_Code__c == 'OD005') &&
        (apps.AOB_BCCEntityType__c != 'Sole Proprietor' || apps.AOB_BCCEntityType__c != 'Partnership')) {
            turnover = String.valueOf(apps.AOB_GrossAnnualTurnover__c);
        } else {
            for (Application_Participant__c dec : directorDataList) {
                if (dec.AOB_KeyContactPerson__c) {
                    turnover = String.valueOf(dec.AOB_GrossAnnualIncome__c);
                }
            }
        }
        return turnover;
    }
    public static String setSourceOfFunds(Application__c apps) {
        String sourcofFundType;
        if ((apps.AOB_Schema_Code__c == 'OD001' || apps.AOB_Schema_Code__c == 'OD005') &&
        (apps.AOB_BCCEntityType__c != 'Sole Proprietor' || apps.AOB_BCCEntityType__c != 'Partnership')) {
            sourcofFundType = sourcofFundTypeBP;
        } else if (apps.AOB_BCCEntityType__c == 'Sole Proprietor' || apps.AOB_BCCEntityType__c == 'Partnership') {
            sourcofFundType = sourcofFundTypeBP;
        } else {
            sourcofFundType = sourcofFundTypeGC;
        }
        return sourcofFundType;
    }

    /**
    * @description This method is used as call the createCorp api
    * @return Integer
    * @param applicationid
    */
    @AuraEnabled
    public static Integer createCorp(String applicationid){
        try{
            string jsonBody;
            Integer responseCode;
            
            Application__c apps = new AOB_BOTS_SEL_Application().selectAppById(applicationid);
            List<Application_Participant__c> directorDataList = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByapplicationIdandsignatory(applicationId);

            
            if(apps.AOB_CIFID__c==null){
                
                AOB_BOTS_DTO_CorpRetail.Contacts contactsRecord = new AOB_BOTS_DTO_CorpRetail.Contacts();
                contactsRecord.contactType  = contactType;
                contactsRecord.value        = directorDataList[0].CNGCU_Email__c;
                
                AOB_BOTS_DTO_CorpRetail.Contacts phoneRecord = new AOB_BOTS_DTO_CorpRetail.Contacts();
                phoneRecord.contactType  = contactTypePhone;
                phoneRecord.value        = directorDataList[0].CNGCU_Phone__c;
                phoneRecord.countryCode=botswanaCountryCallingCode;
                phoneRecord.localCode=botswanaLocalCode;
                phoneRecord.cityCode=botswanaCityCode;
                
                AOB_BOTS_DTO_CorpRetail.CustomerRoles customerRolesRecord = new AOB_BOTS_DTO_CorpRetail.CustomerRoles();
                customerRolesRecord.role                = '';
                customerRolesRecord.startDate           = ''; 
                customerRolesRecord.endDate             = '';
                
                AOB_BOTS_DTO_CorpRetail.addressTypes typeHomeRecord = new AOB_BOTS_DTO_CorpRetail.addressTypes();
                typeHomeRecord.addressType  = commentHome;
                
                AOB_BOTS_DTO_CorpRetail.Addresses addressesRecord = createAddressesRecord(apps,typeHomeRecord);
                    
                AOB_BOTS_DTO_CorpRetail.AddressTypes typeMailingRecord = new AOB_BOTS_DTO_CorpRetail.AddressTypes();
                typeMailingRecord.addressType  = addressTypeMail;
                
                AOB_BOTS_DTO_CorpRetail.Addresses mailingAddRecord = createMailingAddressRecord(apps,typeMailingRecord);
                
                
                AOB_BOTS_DTO_CorpRetail customerBeanRecord = new AOB_BOTS_DTO_CorpRetail(); 
                customerBeanRecord.contacts      = new List<AOB_BOTS_DTO_CorpRetail.Contacts> {contactsRecord,phoneRecord};
                customerBeanRecord.customerRoles        = new List<AOB_BOTS_DTO_CorpRetail.customerRoles> {customerRolesRecord};
                customerBeanRecord.addresses            = new List<AOB_BOTS_DTO_CorpRetail.Addresses> {addressesRecord, mailingAddRecord};
                customerBeanRecord = createCustomerBeanRecordForCreateCustomer(customerBeanRecord,apps,directorDataList);
                customerBeanRecord.finacleSectors=createFinaclelist(apps);
                jsonbody=JSON.serialize(customerBeanRecord);
                AOB_BOTS_API_CreateCorp customerServiceCall = new AOB_BOTS_API_CreateCorp(jsonbody);
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_DSX.SERVICE_NAME);
                customerServiceCall.process(obj);
                AOB_BOTS_SRV_CMNWebserviceCallQueue.newInstance().saveWebserviceCallQueues(new List<CMN_WebserviceCallQueue__c>{obj},uow);
                String appData=customerServiceCall.getResponseBody();
                apps = updateApplicationCIFID(appData, apps,customerServiceCall);
                responseCode= customerServiceCall.getResponseStatusCode();                
            }else{
                return 200;
            }
            AOB_BOTS_SRV_Application.newInstance().saveApp(new List<Application__c>{apps}, uow);
            uow.commitWork();
            return responseCode; 
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.createCorp',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }    
    public static List<AOB_BOTS_DTO_CorpRetail.finacleSectors>  createFinaclelist(Application__c apps){
        List<AOB_BOTS_DTO_CorpRetail.finacleSectors> finaclelist= new List<AOB_BOTS_DTO_CorpRetail.finacleSectors>();    
        AOB_BOTS_DTO_CorpRetail.finacleSectors finacle=new AOB_BOTS_DTO_CorpRetail.finacleSectors();    
        finacle.classificationCode=apps.AOB_ReturnsClassificationCode__c;
        finacle.primaryClassificationCode=apps.AOB_Sector__c;
        finacle.secondaryClassificationCode=apps.AOB_Subsector__c;
        finacle.tertiarycClassificationCode=apps.AOB_TertiarySICCode__c;
        finacle.sarbCodecClassificationCode=apps.AOB_IndustryClassificationSARBCode__c; 
        finaclelist.add(finacle);
        return finaclelist;
    }
    public static AOB_BOTS_DTO_CorpRetail.OrgDetails  createOrgDetails(Application__c apps,List<Application_Participant__c> directorDataList ){
        String businessName = setBusinessName(apps);
        String turnover = setTurnover(apps,directorDataList);
        AOB_BOTS_DTO_CorpRetail.OrgDetails orgDetailsRecord = new AOB_BOTS_DTO_CorpRetail.OrgDetails();
        orgDetailsRecord.legalName      = businessName;
        orgDetailsRecord.companyName    = businessName;
        orgDetailsRecord.legalForm      = legalForm;
        orgDetailsRecord.orgEstablishDt = orgEstablishDt;
        orgDetailsRecord.numEmployees   = 0;
        orgDetailsRecord.fiscalYearEnd  = orgEstablishDt;
        orgDetailsRecord.ownership      = '';
        orgDetailsRecord.description=apps.AOB_Notes__c;
        orgDetailsRecord.turnover=turnover;
        return orgDetailsRecord;
    }
    public static List<AOB_BOTS_DTO_CorpRetail.Identification> createIdentificationListRecord(String idenficationNum){
        List<AOB_BOTS_DTO_CorpRetail.Identification> idenlist= new List<AOB_BOTS_DTO_CorpRetail.Identification>();
        AOB_BOTS_DTO_CorpRetail.Identification identificationRecord = new AOB_BOTS_DTO_CorpRetail.Identification();
        identificationRecord.identificationNumber               = idenficationNum;
        identificationRecord.issuingCountry                     = botswanaCountryCode;
        identificationRecord.issuedOrganisation                 = '';
        identificationRecord.issuedDate                         = issuedDate;
        identificationRecord.expirationDate                     = expirationDate; 
        identificationRecord.PreferredIdentificationIndicator   = PreferredIdentificationIndicatorY;
        identificationRecord.documentCode                       = documentCodeD0701;
        identificationRecord.documentDescription                = documentDescriptionTaxRegisterationCert;
        identificationRecord.documentTypeCode                   = documentTypeCodeDT112;
        identificationRecord.documentTypeDescription            = documentTypeDescriptionIPUCA;
        idenlist.add(identificationRecord);  
        return idenlist;
    }
    public static AOB_BOTS_DTO_CorpRetail createPersonDetailsRecord(List<Application_Participant__c> directorDataList,AOB_BOTS_DTO_CorpRetail customerBeanRecord,Application__c apps){
        String sourceAmount;
        String sourcofFundType = setSourceOfFunds(apps);
        AOB_BOTS_DTO_CorpRetail.PersonDetails personDetailsRecord = new AOB_BOTS_DTO_CorpRetail.PersonDetails();
        for(Application_Participant__c apppart:directorDataList){
            if(apppart.AOB_KeyContactPerson__c==true){
                personDetailsRecord.firstName   = apppart.AOB_FullName__c;
                personDetailsRecord.lastName    = '';
                personDetailsRecord.initials    = '';
                personDetailsRecord.otherName   = '';
                personDetailsRecord.birthName   = '';
                personDetailsRecord.preferredName   = '';
                personDetailsRecord.dob         = '';
                personDetailsRecord.gender      = '';
                personDetailsRecord.title       = ''; 
                personDetailsRecord.maritalStatus   = '';
                personDetailsRecord.citizenshipCountry  = '';
                personDetailsRecord.nationality         = '';
                personDetailsRecord.countryOfBirth      = ''; 
                personDetailsRecord.ethnicity   = '';
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
                sourceAmount=getSourceAmount(apppart);
            }
        }
        personDetailsRecord.studentIndicator = false;
        personDetailsRecord.purgeAllowedIndicator = purgeAllowedIndicator;
        personDetailsRecord.digitalBankingIndicator = purgeAllowedIndicator;
        customerBeanRecord.personDetails = personDetailsRecord; 
        AOB_BOTS_DTO_CorpRetail.SourceOfFunds sourceOfFundsRecord = createSourceOfFunds(sourcofFundType, sourceAmount, botswanaCountryCurrencyCode, tradeFinanceIndicator);
        customerBeanRecord.sourceOfFunds        = new List<AOB_BOTS_DTO_CorpRetail.SourceOfFunds> {sourceOfFundsRecord};

        return customerBeanRecord;
    }


    public static AOB_BOTS_DTO_CorpRetail createCustomerBeanRecordForCreateCustomer(AOB_BOTS_DTO_CorpRetail customerBeanRecord,Application__c apps,List<Application_Participant__c> directorDataList ) {
        String idenficationNum = setIdentificationNumber(apps);
        customerBeanRecord = createPersonDetailsRecord(directorDataList,customerBeanRecord,apps);
        AOB_BOTS_DTO_CorpRetail.ProminentInfluentialPerson prominentInfluentialPersonRecord =AOB_BOTS_SRV_ESB_Helper.createProminentInfluentialPerson();
        AOB_BOTS_DTO_CorpRetail.IndustrialSectors industrialSectorsRecord = createIndustrialSectorsRecord();
        AOB_BOTS_DTO_CorpRetail.TaxClassification taxClassificationRecord = createTaxClassification(PreferredIdentificationIndicatorY);
        AOB_BOTS_DTO_CorpRetail.EmploymentDetails employmentDetailsRecord = AOB_BOTS_SRV_ESB_Helper.createEmploymentDetails();
        AOB_BOTS_DTO_CorpRetail.ComplianceRoles complianceRolesRecord = createComplianceRolesRecord();
        AOB_BOTS_DTO_CorpRetail.Permits permitsRecord = createPermits(); 
        AOB_BOTS_DTO_CorpRetail.Misc miscRecord = AOB_BOTS_SRV_ESB_Helper.createMiscRecord();
        AOB_BOTS_DTO_CorpRetail.TaxDetails taxDetailsRecord = createTaxDetails('Na', '', '');              
        AOB_BOTS_DTO_CorpRetail.MktgConsents mktgConsentsRecord = new AOB_BOTS_DTO_CorpRetail.MktgConsents();
        mktgConsentsRecord.consentCode  = '';
        mktgConsentsRecord.consentStatus= true;
        customerBeanRecord.mktgConsents         = new List<AOB_BOTS_DTO_CorpRetail.mktgConsents> {mktgConsentsRecord};
        customerBeanRecord.taxDetails           = new List<AOB_BOTS_DTO_CorpRetail.taxDetails> {taxDetailsRecord};
        customerBeanRecord.complianceRoles      = new List<AOB_BOTS_DTO_CorpRetail.ComplianceRoles> {complianceRolesRecord};
        customerBeanRecord.prominentInfluentialPerson = prominentInfluentialPersonRecord;
        customerBeanRecord.employmentDetails    = employmentDetailsRecord;
        customerBeanRecord.relManagerLink      = apps.AOB_PrimaryRelationshipManagerID__c;
        customerBeanRecord.responsibleBranch    = apps.AOB_Preferred_Branch__c;
        customerBeanRecord.gIIN                 = '';
        customerBeanRecord.minorIndicator       = '';
        customerBeanRecord.seniorIndicator      = '';
        customerBeanRecord.authorizationGroup   = '';
        customerBeanRecord.EASIndicator  = ''; 
        customerBeanRecord.customerType  = customerType;
        customerBeanRecord.mktgSegment          = number001; 
        customerBeanRecord.segmentCategory      = number105;
        customerBeanRecord.prefLanguage        = prefLanguage;
        customerBeanRecord.residenceCountry    = botswanaCountryCode;
        customerBeanRecord.accessOwnerSegment   = accessOwnerSegment;
        customerBeanRecord.permits              = new List<AOB_BOTS_DTO_CorpRetail.Permits> {permitsRecord};
        customerBeanRecord.misc                 = new List<AOB_BOTS_DTO_CorpRetail.Misc> {miscRecord};
        customerBeanRecord.industrialSectors    = new List<AOB_BOTS_DTO_CorpRetail.IndustrialSectors> {industrialSectorsRecord};
        customerBeanRecord.taxClassification    = taxClassificationRecord;
        List<AOB_BOTS_DTO_CorpRetail.RelatedParties> listsrelated= createRelatedPartiesList(directorDataList);
        customerBeanRecord.relatedParties=listsrelated;                
        customerBeanRecord.orgDetails    = createOrgDetails(apps,directorDataList);
        customerBeanRecord.identification      = createIdentificationListRecord(idenficationNum);
        return customerBeanRecord;
    }

    private static Application__c updateApplicationCIFID(String appData, Application__c apps,AOB_BOTS_API_CreateCorp customerServiceCall) {
        if (customerServiceCall.getResponseStatusCode() == 200) {
            Map<String, Object> appDataMaps = (Map<String, Object>) JSON.deserializeUntyped(appData);
            apps.AOB_CIFID__c = (String) appDataMaps.get('uuid');
        }
        return apps;
    }

    /**
    * @description This method is used as call the svsSignature api
    * @param applicationId
    * @return Integer 
    */
    @AuraEnabled
    public static Integer svsSignature(String applicationId){
        try {             
            return AOB_BOTS_SRV_ESB_Helper.svsSignature(applicationId);
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.svsSignature',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static AOB_BOTS_DTO_CorpRetail.PersonDetails createPersonDetailsRecord(Application_Participant__c ap, Integer number0) {
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
        personDetailsRecord.maritalStatus = ap.AOB_MaritalStatus__c;
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
        personDetailsRecord.dependants = number0;
        personDetailsRecord.dependantsMinor = number0;
        personDetailsRecord.clientType = '';
        personDetailsRecord.studentIndicator = false;
        personDetailsRecord.purgeAllowedIndicator = '';
        personDetailsRecord.digitalBankingIndicator = '';
        return personDetailsRecord;
    }

    public static AOB_BOTS_DTO_CorpRetail.OrgDetails createOrgDetailsRecord(Integer number0) {
        AOB_BOTS_DTO_CorpRetail.OrgDetails orgDetailsRecord = new AOB_BOTS_DTO_CorpRetail.OrgDetails();
        orgDetailsRecord.legalName = '';
        orgDetailsRecord.companyName = '';
        orgDetailsRecord.legalForm = '';
        orgDetailsRecord.orgEstablishDt = '';
        orgDetailsRecord.numEmployees = number0;
        orgDetailsRecord.fiscalYearEnd = '';
        orgDetailsRecord.ownership = '';
        return orgDetailsRecord;
    }

    public static AOB_BOTS_DTO_CorpRetail.ComplianceRoles createComplianceRolesRecord() {
        AOB_BOTS_DTO_CorpRetail.ComplianceRoles complianceRolesRecord = new AOB_BOTS_DTO_CorpRetail.ComplianceRoles();
        complianceRolesRecord.compRole = '';
        complianceRolesRecord.complianceGrade = '';
        complianceRolesRecord.complianceStatus = '';
        complianceRolesRecord.statusReason = '';
        complianceRolesRecord.verifiedBy = '';
        
        return complianceRolesRecord;
    }   
    public static AOB_BOTS_DTO_CorpRetail.Identification createIdentificationRecord(String issuedDate) {
        AOB_BOTS_DTO_CorpRetail.Identification identificationRecord = new AOB_BOTS_DTO_CorpRetail.Identification();
        identificationRecord.identificationType                 = ''; 
        identificationRecord.identificationNumber               = '';
        identificationRecord.issuingCountry                     = '';
        identificationRecord.issuedOrganisation                 = issuedDate;
        identificationRecord.issuedDate                         = ''; 
        identificationRecord.expirationDate                     = ''; 
        identificationRecord.PreferredIdentificationIndicator   = '';
        identificationRecord.documentCode                       = '';
        identificationRecord.documentDescription                = '';
        identificationRecord.documentTypeCode                   = '';
        identificationRecord.documentTypeDescription            = '';
        
        return identificationRecord;
    }   
    
    public static AOB_BOTS_DTO_CorpRetail.Addresses createMailingAddressRecord(String preferredInd,String comment,String startDate,List<AOB_BOTS_DTO_CorpRetail.addressTypes> addressTypes) {
        AOB_BOTS_DTO_CorpRetail.Addresses mailingAddRecord = new AOB_BOTS_DTO_CorpRetail.Addresses();
        mailingAddRecord.uuid            = '';
        mailingAddRecord.line1           = '';
        mailingAddRecord.line2           = '';
        mailingAddRecord.line3           = '';
        mailingAddRecord.city            = '';
        mailingAddRecord.province        = '';
        mailingAddRecord.postalCode      = '';
        mailingAddRecord.countryCode     = '';
        mailingAddRecord.preferredInd = preferredInd;
        mailingAddRecord.preferredFormat = '';
        mailingAddRecord.comment         = comment;
        mailingAddRecord.startDate = startDate;
        mailingAddRecord.addressTypes = addressTypes;
        
        return mailingAddRecord;
    }

    /**
* @description This method is used as call the updateCustomer api
* @param applicationid
* @return Integer
*/
    @AuraEnabled
    public static Integer updateCustomer(String applicationid){
        try{
            string jsonBody;
            String uuid;
            Integer responscode;
            List<Application_Participant__c> directorDataList =  new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationid);
            List<Application_Participant__c> updateciflist=new List<Application_Participant__c>();
            for(Application_Participant__c ap:directorDataList){
                if(ap.AOB_CIFID__c==null){
                    return 200;                    
                }else{
                    uuid=ap.AOB_CIFID__c;
                    AOB_BOTS_DTO_CorpRetail.PersonDetails personDetailsRecord =createPersonDetailsRecord(ap, number0);
                    List<AOB_BOTS_DTO_CorpRetail.Identification> idenlist= new List<AOB_BOTS_DTO_CorpRetail.Identification>();
                    AOB_BOTS_DTO_CorpRetail.Identification identificationRecord = createIdentificationRecord(issuedDate);
                    identificationRecord.documentTypeDescription = '';

                    AOB_BOTS_DTO_CorpRetail.Misc miscRecord = new AOB_BOTS_DTO_CorpRetail.Misc();
                    miscRecord.key  = 'Type';
                    miscRecord.value= '';
                    miscRecord.miscDate  = '';
                    miscRecord.counterPartyInfo= '';
                    miscRecord.distributionChannel  = 'B';
                    AOB_BOTS_DTO_CorpRetail customerBeanRecord = new AOB_BOTS_DTO_CorpRetail(); 
                    customerBeanRecord.customerType  = customerType;
                    customerBeanRecord.personDetails = personDetailsRecord;
                    customerBeanRecord.identification      = idenlist;
                    customerBeanRecord.residenceCountry    = botswanaCountryCode;
                    customerBeanRecord.relManagerLink      = ap.application__r.AOB_PrimaryRelationshipManagerID__c;
                    customerBeanRecord.prefLanguage        = prefLanguage;
                    customerBeanRecord.misc                 = new List<AOB_BOTS_DTO_CorpRetail.Misc> {miscRecord};
                    customerBeanRecord = createCustomerBeanRecordForUpdateCustomer(customerBeanRecord);
                    jsonbody=JSON.serialize(customerBeanRecord);
                    AOB_BOTS_API_UpdateCustomer customerServiceCall = new AOB_BOTS_API_UpdateCustomer(jsonbody,uuid);
                    CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_DSX.SERVICE_NAME);
                    customerServiceCall.process(obj);
                    responscode= customerServiceCall.getResponseStatusCode();
                    return responscode;

                }
            }
            if(updateciflist.size()>0){
                AOB_BOTS_SRV_ApplicationParticipant.newInstance().saveAppParticipant(updateCIFList, uow);
                uow.commitWork();  
            }
            return 200;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.updateCustomer',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }


    public static AOB_BOTS_DTO_CorpRetail createCustomerBeanRecordForUpdateCustomer(AOB_BOTS_DTO_CorpRetail customerBeanRecord) {
        AOB_BOTS_DTO_CorpRetail.TaxDetails taxDetailsRecord = createTaxDetails('','','');
        AOB_BOTS_DTO_CorpRetail.MktgConsents mktgConsentsRecord = new AOB_BOTS_DTO_CorpRetail.MktgConsents();
        mktgConsentsRecord.consentCode  = '';
        mktgConsentsRecord.consentStatus= true;
        AOB_BOTS_DTO_CorpRetail.CustomerRoles customerRolesRecord = AOB_BOTS_SRV_ESB_Helper.createCustomerRoles();
        AOB_BOTS_DTO_CorpRetail.Contacts contactsRecord = AOB_BOTS_SRV_ESB_Helper.createContactsRecord('','');
        AOB_BOTS_DTO_CorpRetail.Contacts emailRecord = AOB_BOTS_SRV_ESB_Helper.createEmailRecord(contactType,'');
        AOB_BOTS_DTO_CorpRetail.ComplianceRoles complianceRolesRecord = createComplianceRolesRecord();                    
        AOB_BOTS_DTO_CorpRetail.ProminentInfluentialPerson prominentInfluentialPersonRecord = AOB_BOTS_SRV_ESB_Helper.createProminentInfluentialPerson();
        AOB_BOTS_DTO_CorpRetail.OrgDetails orgDetailsRecord = createOrgDetailsRecord(number0);
        AOB_BOTS_DTO_CorpRetail.EmploymentDetails employmentDetailsRecord = AOB_BOTS_SRV_ESB_Helper.createEmploymentDetails();
        AOB_BOTS_DTO_CorpRetail.IndustrialSectors industrialSectorsRecord = createIndustrialSectorsRecord();
        AOB_BOTS_DTO_CorpRetail.TaxClassification taxClassificationRecord = new AOB_BOTS_DTO_CorpRetail.TaxClassification();
        taxClassificationRecord.taxCountry      = '';
        taxClassificationRecord.taxRegion       = '';
        taxClassificationRecord.taxType         = '';
        taxClassificationRecord.taxGroup        = '';
        taxClassificationRecord.taxExemptReason = '';
        AOB_BOTS_DTO_CorpRetail.SourceOfFunds sourceOfFundsRecord = new AOB_BOTS_DTO_CorpRetail.SourceOfFunds();
        sourceOfFundsRecord.sourceFundType              = '';
        sourceOfFundsRecord.sourceFundAmount            = ''; 
        sourceOfFundsRecord.currencyCode                = botswanaCountryCurrencyCode;
        sourceOfFundsRecord.tradeFinanceIndicator       = '';

        AOB_BOTS_DTO_CorpRetail.Permits permitsRecord = createPermits();
        customerBeanRecord.orgDetails    = orgDetailsRecord;
        customerBeanRecord.mktgConsents         = new List<AOB_BOTS_DTO_CorpRetail.mktgConsents> {mktgConsentsRecord};
        customerBeanRecord.sourceOfFunds        = new List<AOB_BOTS_DTO_CorpRetail.SourceOfFunds> {sourceOfFundsRecord};
        customerBeanRecord.complianceRoles      = new List<AOB_BOTS_DTO_CorpRetail.ComplianceRoles> {complianceRolesRecord};
        customerBeanRecord.prominentInfluentialPerson = prominentInfluentialPersonRecord;
        customerBeanRecord.contacts      = new List<AOB_BOTS_DTO_CorpRetail.Contacts> {contactsRecord, emailRecord};
        customerBeanRecord.industrialSectors    = new List<AOB_BOTS_DTO_CorpRetail.IndustrialSectors> {industrialSectorsRecord};
        customerBeanRecord.taxClassification    = taxClassificationRecord;
        customerBeanRecord.permits              = new List<AOB_BOTS_DTO_CorpRetail.Permits> {permitsRecord};
        customerBeanRecord.taxDetails           = new List<AOB_BOTS_DTO_CorpRetail.taxDetails> {taxDetailsRecord};
        customerBeanRecord.customerRoles        = new List<AOB_BOTS_DTO_CorpRetail.customerRoles> {customerRolesRecord};
        customerBeanRecord.employmentDetails    = employmentDetailsRecord;
        customerBeanRecord.EASIndicator  = ''; 
        customerBeanRecord.responsibleBranch    = '';
        customerBeanRecord.authorizationGroup   = '';
        customerBeanRecord.gIIN                 = '';
        customerBeanRecord.mktgSegment          = ''; 
        customerBeanRecord.accessOwnerSegment   = '';
        customerBeanRecord.segmentCategory      = '';
        customerBeanRecord.minorIndicator       = '';
        customerBeanRecord.seniorIndicator      = '';
        customerBeanRecord = updateMailingDetails(customerBeanRecord);
        return customerBeanRecord;
    }

    public static AOB_BOTS_DTO_CorpRetail updateMailingDetails(AOB_BOTS_DTO_CorpRetail customerBeanRecord) {
        AOB_BOTS_DTO_CorpRetail.addressTypes typeHomeRecord = new AOB_BOTS_DTO_CorpRetail.addressTypes();
        typeHomeRecord.addressType  = '';
        AOB_BOTS_DTO_CorpRetail.Addresses addressesRecord = new AOB_BOTS_DTO_CorpRetail.Addresses();
        addressesRecord.uuid            = '';
        addressesRecord.line1           = '';
        addressesRecord.line2           = '';
        addressesRecord.line3           = '';
        addressesRecord.city            = '';
        addressesRecord.province        = '';
        addressesRecord.postalCode      = '';
        addressesRecord.countryCode     = botswanaCountryCode;
        addressesRecord.preferredInd    = '';
        addressesRecord.preferredFormat = '';
        addressesRecord.comment         = commentHome;
        addressesRecord.startDate       = '';
        
        addressesRecord.addressTypes    = new List<AOB_BOTS_DTO_CorpRetail.addressTypes> {typeHomeRecord};
        AOB_BOTS_DTO_CorpRetail.AddressTypes typeMailingRecord = new AOB_BOTS_DTO_CorpRetail.AddressTypes();
        typeMailingRecord.addressType  = '';

        AOB_BOTS_DTO_CorpRetail.Addresses mailingAddRecord = createMailingAddressRecord(tradeFinanceIndicator,addressTypeMail,Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'),new List<AOB_BOTS_DTO_CorpRetail.addressTypes> {typeMailingRecord});                        
        customerBeanRecord.addresses            = new List<AOB_BOTS_DTO_CorpRetail.Addresses> {addressesRecord, mailingAddRecord};

        return customerBeanRecord;
    }
    private static AOB_BOTS_DTO_CorpRetail.Addresses createMailingAddRecord(Application__c apps) {
        AOB_BOTS_DTO_CorpRetail.AddressTypes typeMailingRecord = new AOB_BOTS_DTO_CorpRetail.AddressTypes();
        typeMailingRecord.addressType  = '';
        AOB_BOTS_DTO_CorpRetail.Addresses mailingAddRecord = new AOB_BOTS_DTO_CorpRetail.Addresses();
        mailingAddRecord.uuid            = '';
        mailingAddRecord.line1           = '';
        mailingAddRecord.line2           = '';
        mailingAddRecord.line3           = '';
        mailingAddRecord.city            = '';
        mailingAddRecord.province        = '';
        mailingAddRecord.postalCode      = '';
        mailingAddRecord.countryCode     = '';
        mailingAddRecord.preferredInd    = tradeFinanceIndicator;
        mailingAddRecord.preferredFormat = '';
        mailingAddRecord.comment         = '';
        if(apps.AOB_AddressValidFrom__c!=null){
            mailingAddRecord.startDate       = String.valueOf(apps.AOB_AddressValidFrom__c); 
        }
        mailingAddRecord.addressTypes    = new List<AOB_BOTS_DTO_CorpRetail.addressTypes> {typeMailingRecord};
        Return mailingAddRecord; 
    }
    private static List<AOB_BOTS_DTO_CorpRetail.Identification> createIdenlist(Application__c apps) {
        List<Application_Document__c> apdoclist = new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdApplication(apps.Id);
        List<AOB_BOTS_DTO_CorpRetail.Identification> idenlist= new List<AOB_BOTS_DTO_CorpRetail.Identification>();
        for(Application_Document__c apd:apdoclist){
            AOB_BOTS_DTO_CorpRetail.Identification identificationRecord = new AOB_BOTS_DTO_CorpRetail.Identification();
            identificationRecord.identificationType                 = ''; 
            identificationRecord.identificationNumber               = apps.AOB_RegistrationNumber__c;
            identificationRecord.issuingCountry                     = '';
            identificationRecord.issuedOrganisation                 = '';
            if(apps.CreatedDate!=null){
                identificationRecord.issuedDate                         = issuedDate;
            }
            identificationRecord.expirationDate                     = ''; 
            identificationRecord.PreferredIdentificationIndicator   = '';
            identificationRecord.documentCode                       = apd.AOB_DocumentCode__c;
            identificationRecord.documentDescription                = apd.AOB_DocumentCodeDescription__c;
            identificationRecord.documentTypeCode                   = apd.Document_Type__c;
            identificationRecord.documentTypeDescription            = apd.AOB_DocumentTypeDescription__c;
            idenlist.add(identificationRecord);    
        }        
        Return idenlist;
    }


    private static AOB_BOTS_DTO_CorpRetail.OrgDetails createOrgDetails(Application__c app) {
        AOB_BOTS_DTO_CorpRetail.OrgDetails orgDetailsRecord = new AOB_BOTS_DTO_CorpRetail.OrgDetails();
        orgDetailsRecord.legalName = '';
        orgDetailsRecord.companyName = app.AOB_BusinessLegalName__c;
        orgDetailsRecord.legalForm = '';
        orgDetailsRecord.orgEstablishDt = '';
        orgDetailsRecord.numEmployees = 0;  // Assuming number0 is intended to be 0
        orgDetailsRecord.fiscalYearEnd = '';
        orgDetailsRecord.ownership = '';
        return orgDetailsRecord;
    }
    
    private static AOB_BOTS_DTO_CorpRetail.Addresses createAddresses(Application__c apps, AOB_BOTS_DTO_CorpRetail.addressTypes typeHomeRecord, String botswanaCountryCode, String commentHome) {
        AOB_BOTS_DTO_CorpRetail.Addresses addressesRecord = new AOB_BOTS_DTO_CorpRetail.Addresses();
        addressesRecord.uuid = '';
        addressesRecord.line1 = apps.AOB_Street__c;
        addressesRecord.line2 = '';
        addressesRecord.line3 = '';
        addressesRecord.city = apps.AOB_City__c;
        addressesRecord.province = apps.AOB_State__c;
        addressesRecord.postalCode = apps.AOB_PostalCode__c;
        addressesRecord.countryCode = botswanaCountryCode;
        addressesRecord.preferredInd = '';
        addressesRecord.preferredFormat = '';
        addressesRecord.comment = commentHome;
        addressesRecord.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        addressesRecord.addressTypes = new List<AOB_BOTS_DTO_CorpRetail.addressTypes> { typeHomeRecord };
        return addressesRecord;
    }
    
    private static AOB_BOTS_DTO_CorpRetail.TaxClassification createTaxClassification(String preferredIdentificationIndicatorY) {
        AOB_BOTS_DTO_CorpRetail.TaxClassification taxClassificationRecord = new AOB_BOTS_DTO_CorpRetail.TaxClassification();
        taxClassificationRecord.taxCountry = '';
        taxClassificationRecord.taxRegion = '';
        taxClassificationRecord.taxType = '';
        taxClassificationRecord.taxGroup = '';
        taxClassificationRecord.taxExemptReason = preferredIdentificationIndicatorY;
        return taxClassificationRecord;
    }
    private static AOB_BOTS_DTO_CorpRetail.Permits createPermits() {
        AOB_BOTS_DTO_CorpRetail.Permits permitsRecord = new AOB_BOTS_DTO_CorpRetail.Permits();
        permitsRecord.permitType = '';
        permitsRecord.permitNumber = '';
        permitsRecord.effDt = '';
        permitsRecord.expDt = '';
        return permitsRecord;
    }

    private static AOB_BOTS_DTO_CorpRetail.TaxDetails createTaxDetails(String taxType, String taxNumber, String provisionalTaxPayerInd) {
        AOB_BOTS_DTO_CorpRetail.TaxDetails taxDetailsRecord = new AOB_BOTS_DTO_CorpRetail.TaxDetails();
        taxDetailsRecord.taxType = taxType;
        taxDetailsRecord.taxNumber = taxNumber;
        taxDetailsRecord.provisionalTaxPayerInd = provisionalTaxPayerInd;
        return taxDetailsRecord;
    }
    private static AOB_BOTS_DTO_CorpRetail.SourceOfFunds createSourceOfFunds(String sourceFundType, String sourceFundAmount, String currencyCode, String tradeFinanceIndicator) {
        AOB_BOTS_DTO_CorpRetail.SourceOfFunds sourceOfFundsRecord = new AOB_BOTS_DTO_CorpRetail.SourceOfFunds();
        sourceOfFundsRecord.sourceFundType = sourceFundType;
        sourceOfFundsRecord.sourceFundAmount = sourceFundAmount;
        sourceOfFundsRecord.currencyCode = currencyCode;
        sourceOfFundsRecord.tradeFinanceIndicator = tradeFinanceIndicator;
        return sourceOfFundsRecord;
    }
    public static AOB_BOTS_DTO_CorpRetail.IndustrialSectors createIndustrialSectorsRecord() {
        AOB_BOTS_DTO_CorpRetail.IndustrialSectors industrialSectorsRecord = new AOB_BOTS_DTO_CorpRetail.IndustrialSectors();
        industrialSectorsRecord.industrialClassificationSystem = '';
        industrialSectorsRecord.industrialSector = '';
        return industrialSectorsRecord;
    }
    public static AOB_BOTS_DTO_CorpRetail.MktgConsents createMktgConsentsRecord() {
        AOB_BOTS_DTO_CorpRetail.MktgConsents mktgConsentsRecord = new AOB_BOTS_DTO_CorpRetail.MktgConsents();
        mktgConsentsRecord.consentCode = '';
        mktgConsentsRecord.consentStatus = true;
        return mktgConsentsRecord;
    }

    public static List<AOB_BOTS_DTO_CorpRetail.relatedParties> updateCustomerBeanWithRelatedParties(List<Application_Participant__c> directorDataList) {
        List<AOB_BOTS_DTO_CorpRetail.relatedParties> listsrelated = new List<AOB_BOTS_DTO_CorpRetail.relatedParties>();
        
        for(Application_Participant__c ap:directorDataList){
            String fullName = ap.AOB_FullName__c;
            AOB_BOTS_DTO_CorpRetail.relatedParties party= new AOB_BOTS_DTO_CorpRetail.relatedParties();
            if(fullName.contains(' ')) {
                String[] names = fullName.split(' ');
                party.firstName=names[1];
                party.lastName=names[0];
            }else{
                party.firstName='';
                party.lastName=fullName;
            }
            party.partyId=ap.AOB_CIFID__c;
            party.relatedType=ap.AOB_Title__c;
            listsrelated.add(party);
        }
        return listsrelated;
    }
    public static AOB_BOTS_DTO_CorpRetail initializeCustomerBean(String customerType, AOB_BOTS_DTO_CorpRetail.PersonDetails personDetailsRecord, AOB_BOTS_DTO_CorpRetail.OrgDetails orgDetailsRecord) {
        // Create a new instance of AOB_BOTS_DTO_CorpRetail
        AOB_BOTS_DTO_CorpRetail customerBeanRecord = new AOB_BOTS_DTO_CorpRetail();
        
        // Set the properties
        customerBeanRecord.EASIndicator = ''; 
        customerBeanRecord.customerType = customerType;
        customerBeanRecord.personDetails = personDetailsRecord;
        customerBeanRecord.orgDetails = orgDetailsRecord;
        
        // Return the initialized record
        return customerBeanRecord;
    }
    
    /**
    * @description This method is used as call the updateCorp api 
    * @param applicationid
    * @return Integer 
    */
    
    @AuraEnabled
    public static Integer updateCorp(String applicationid){
        try{
            string jsonBody;
            String uuid;
            Integer responseCode;
            Application__c apps =new AOB_BOTS_SEL_Application().selectAppById(applicationid);
            List<Application_Participant__c> directorDataList = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationid); 
            uuid=apps.AOB_CIFID__c;
            if(apps.AOB_CIFID__c==null){
                return 200;
            }else{
                AOB_BOTS_DTO_CorpRetail.PersonDetails personDetailsRecord = AOB_BOTS_SRV_ESB_Helper.createPersonDetails();
                AOB_BOTS_DTO_CorpRetail.OrgDetails orgDetailsRecord = createOrgDetails(apps);                
                List<AOB_BOTS_DTO_CorpRetail.Identification> idenlist= createIdenlist(apps);
                AOB_BOTS_DTO_CorpRetail.SourceOfFunds sourceOfFundsRecord = createSourceOfFunds('', '', botswanaCountryCurrencyCode, tradeFinanceIndicator);
                AOB_BOTS_DTO_CorpRetail.TaxDetails taxDetailsRecord = createTaxDetails('Na', '', '');
                AOB_BOTS_DTO_CorpRetail.addressTypes typeHomeRecord = new AOB_BOTS_DTO_CorpRetail.addressTypes();
                typeHomeRecord.addressType  = commentHome;
                AOB_BOTS_DTO_CorpRetail.Addresses addressesRecord = createAddresses(apps, typeHomeRecord, botswanaCountryCode, commentHome);                    
                AOB_BOTS_DTO_CorpRetail.Addresses mailingAddRecord = createMailingAddRecord(apps);
                AOB_BOTS_DTO_CorpRetail.MktgConsents mktgConsentsRecord = createMktgConsentsRecord();
                AOB_BOTS_DTO_CorpRetail.IndustrialSectors industrialSectorsRecord = createIndustrialSectorsRecord();
                AOB_BOTS_DTO_CorpRetail.TaxClassification taxClassificationRecord = createTaxClassification(PreferredIdentificationIndicatorY);
                AOB_BOTS_DTO_CorpRetail.Permits permitsRecord = createPermits();
                AOB_BOTS_DTO_CorpRetail customerBeanRecord = initializeCustomerBean(customerType, personDetailsRecord, orgDetailsRecord); 
                customerBeanRecord.identification      = idenlist;
                customerBeanRecord.relManagerLink      = apps.AOB_PrimaryRelationshipManagerID__c;
                customerBeanRecord.sourceOfFunds        = new List<AOB_BOTS_DTO_CorpRetail.SourceOfFunds> {sourceOfFundsRecord};
                customerBeanRecord.taxDetails           = new List<AOB_BOTS_DTO_CorpRetail.taxDetails> {taxDetailsRecord};
                customerBeanRecord.addresses            = new List<AOB_BOTS_DTO_CorpRetail.Addresses> {addressesRecord, mailingAddRecord};
                customerBeanRecord.mktgConsents         = new List<AOB_BOTS_DTO_CorpRetail.mktgConsents> {mktgConsentsRecord};
                customerBeanRecord.industrialSectors    = new List<AOB_BOTS_DTO_CorpRetail.IndustrialSectors> {industrialSectorsRecord};
                customerBeanRecord.permits              = new List<AOB_BOTS_DTO_CorpRetail.Permits> {permitsRecord};
                customerBeanRecord.taxClassification    = taxClassificationRecord;
                customerBeanRecord.accessOwnerSegment   = accessOwnerSegment;
                customerBeanRecord.relatedParties=updateCustomerBeanWithRelatedParties(directorDataList);
                customerBeanRecord = AOB_BOTS_SRV_ESB_Helper.createCustomerBeanRecord(customerBeanRecord);
                jsonbody=JSON.serialize(customerBeanRecord);
                AOB_BOTS_API_UpdateCorp customerServiceCall = new AOB_BOTS_API_UpdateCorp(jsonbody,uuid);
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_UpdateCorp.SERVICE_NAME);
                customerServiceCall.process(obj);
                AOB_BOTS_SRV_CMNWebserviceCallQueue.newInstance().saveWebserviceCallQueues(new List<CMN_WebserviceCallQueue__c>{obj},uow);
                responseCode= customerServiceCall.getResponseStatusCode();
            }
            AOB_BOTS_SRV_Application.newInstance().saveApp(new List<Application__c>{apps}, uow); 
            uow.commitWork();
            return responseCode;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.updateCorp',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }


    /** @description  method to create advise account for application
    * @param applicationid
    * @return Integer
    */
    @AuraEnabled
    public static Integer createAdviseAccount(String applicationid){
        try {
            return AOB_BOTS_SRV_ESB_Helper.createAdviseAccount(applicationid);
        } catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_ESB.createAdviseAccount',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
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
           
}