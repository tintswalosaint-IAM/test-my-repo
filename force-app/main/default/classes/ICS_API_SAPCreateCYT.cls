/*************************************************************
 * @description SFP-32986 Class used to send CYT data
 * @autor Rukesh
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By  Rukesh
 * Last Modified Date 21/10/2024
 * Last Modified Description: updated to latest Version
  ***************************************************************
 * Last Modified By  Ridhima Saxena
 * Last Modified Date 07/10/2025
 * Last Modified Description: SFP-52878 updated missing CYT fields in JSON
 ***************************************************************
* Last Modified By  Ridhima Saxena
 * Last Modified Date 31/10/2025
 * Last Modified Description: SFP-52878 updated JSON with missing CYT fields
  ***************************************************************
 * Last Modified By  Ridhima Saxena
 * Last Modified Date 07/11/2025
 * Last Modified Description: SFP-52878 updated CYTID field
***************************************************************************************
*  @Last Modified By 		: Ikyatha Naidu
* @Last Modified On 		: 26-02-2025
* @Modification description : SFP-55521 updated for join account
***************************************************************************************
 * @Last Modified By      : Ridhima Saxena
 * @Last Modified On      : 16-07-2026
 * @Modification Description : SFP-54664 Updated createReference() by removing Tel/Fax 
 */

public without sharing class ICS_API_SAPCreateCYT {
 private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_SAPCreateCYT');
    Public Id accountId;
    Public boolean isJoint;
    public String jsonRequest {
        get;
        private set;
    }
    public ics_customlabel__mdt customMetaData;
    Map < String, string > parsedData = new Map < String, string > ();
    public ICS_API_SAPCreateCYT(Id accId,boolean isJointInfo) {
        this.accountId = accId;
        this.isJoint=isJointInfo;
        this.jsonRequest = generatejsonRequest();
    }
    /**
     * @description Used to get the data of ics_customlabel__mdt based on developer name
     * @param developerName
     * @return ics_customlabel__mdt
     */
    public ics_customlabel__mdt getCustomMetaData() {
        string developerName = 'Ics_Custom_SAPCreateCYTData';
        if (!ics_customlabel__mdt.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Insufficient permissions to access ics_customlabel__mdt');
        }
        try {
            return [SELECT DeveloperName, Description__c FROM ics_customlabel__mdt WHERE DeveloperName =: developerName LIMIT 1];
        } catch (QueryException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Used to  generate json result
     */
    private String generatejsonRequest() {
        customMetaData = getCustomMetaData();
        parsedData = parseCustomMetadataJson(customMetadata);
        ICS_DTO_SAPCreateCYTRequest request = new ICS_DTO_SAPCreateCYTRequest();
        request.Party = new List < ICS_DTO_SAPCreateCYTRequest.Party > ();


        SEL_FinServ_FinancialAccount selFinancialAccount = new SEL_FinServ_FinancialAccount();
        Set<Id> accountIds = new Set<Id>{accountId};
            
		sel_Applicant selectorApplicant = new sel_Applicant();
        SEL_Opportunity selOpp = new SEL_Opportunity();
        List<Opportunity> oppList = selOpp.selectByAccountId(accountId);
        if(isJoint){
             Opportunity opp = oppList[0];
            List<Applicant> applicantInfo = selectorApplicant.selectPrimaryApplicantByOppIds(new List<ID>{ opp.Id });
            SEL_Account selectorAccountjoint = new SEL_Account();
            Account  accDataJoint = selectorAccountjoint.selectById(opp.accountId);
             SEL_Account selectorAccount = new SEL_Account();
            Account  accData = selectorAccount.selectById(applicantInfo[0].accountid);
            ICS_DTO_SAPCreateCYTRequest.Party party = new ICS_DTO_SAPCreateCYTRequest.Party();
            party.PartyReference = createPartyReference(accDataJoint.ExternalCIFId__c);
            party.Reference = createReference(accData.Id	);
            party.AdditionalData = createAdditionalData();
			party.person =createPersonData(applicantInfo[0].accountid);
            if (party.Reference.PartyContactPoint == null) {
                party.Reference.PartyContactPoint = new ICS_DTO_SAPCreateCYTRequest.PartyContactPoint();
            }
            if (party.Reference.PartyContactPoint.ContactPoint == null) {
                party.Reference.PartyContactPoint.ContactPoint = new ICS_DTO_SAPCreateCYTRequest.ContactPoint();
            }
            party.Reference.PartyContactPoint.ContactPoint.ContactPointType = getInstructingtheBank(accData.Id);

            request.Party.add(party);
        }else {
            Account acc=[select id,ExternalCIFId__c from account where id=:accountId];
             ICS_DTO_SAPCreateCYTRequest.Party party = new ICS_DTO_SAPCreateCYTRequest.Party();
            String bpId = acc.ExternalCIFId__c;
            party.PartyReference = createPartyReference(bpId);
            party.Reference = createReference(acc.Id);
            party.AdditionalData = createAdditionalData();
			party.person =createPersonData(acc.Id);
            if (party.Reference.PartyContactPoint == null) {
                party.Reference.PartyContactPoint = new ICS_DTO_SAPCreateCYTRequest.PartyContactPoint();
            }
            if (party.Reference.PartyContactPoint.ContactPoint == null) {
                party.Reference.PartyContactPoint.ContactPoint = new ICS_DTO_SAPCreateCYTRequest.ContactPoint();
            }
            party.Reference.PartyContactPoint.ContactPoint.ContactPointType = getInstructingtheBank(acc.Id);
            request.Party.add(party);
        }
 
        return JSON.serialize(request, true);
    }
    
    /**
     * @description Used to  parse custom metadata json
     */
    private Map < String, String > parseCustomMetadataJson(ics_customlabel__mdt metadata) {
        Map < String, Object > rawMap = (Map < String, Object > ) JSON.deserializeUntyped(metadata.Description__c);
        Map < String, String > stringMap = new Map < String, String > ();

        for (String key: rawMap.keySet()) {
            Object value = rawMap.get(key);
            stringMap.put(key,  String.valueOf(value));
        }

        return stringMap;
    }
    
    private ICS_DTO_SAPCreateCYTRequest.PartyReference createPartyReference(String externalCustomerNumber) {
        ICS_DTO_SAPCreateCYTRequest.PartyReference partyRef = new ICS_DTO_SAPCreateCYTRequest.PartyReference();
        partyRef.PartyIdentification = new List < ICS_DTO_SAPCreateCYTRequest.PartyIdentification > ();

        // Partner Number
        ICS_DTO_SAPCreateCYTRequest.PartyIdentification partnerNumber = new ICS_DTO_SAPCreateCYTRequest.PartyIdentification();
        partnerNumber.PartyIdentificationType = (String) parsedData.get('ics_partnerNumber_partyIdentificationType');
        partnerNumber.PartyIdentification = new ICS_DTO_SAPCreateCYTRequest.PartyIdentificationDetail();
        partnerNumber.PartyIdentification.IdentifierValue = new ICS_DTO_SAPCreateCYTRequest.IdentifierValue();
        partnerNumber.PartyIdentification.IdentifierValue.Value = externalCustomerNumber;
        partyRef.PartyIdentification.add(partnerNumber);

        // Partner Type
        ICS_DTO_SAPCreateCYTRequest.PartyIdentification partnerType = new ICS_DTO_SAPCreateCYTRequest.PartyIdentification();
        partnerType.PartyIdentificationType = parsedData.get('ics_partnerType_partyIdentificationType');
        partnerType.PartyIdentification = new ICS_DTO_SAPCreateCYTRequest.PartyIdentificationDetail();
        partnerType.PartyIdentification.IdentifierValue = new ICS_DTO_SAPCreateCYTRequest.IdentifierValue();
        partnerType.PartyIdentification.IdentifierValue.Value = parsedData.get('ics_partnerType_IdentifierValue');
        partyRef.PartyIdentification.add(partnerType);

        try {
            SEL_PartyProfile selProfile = new SEL_PartyProfile();
            List<PartyProfile> profileList = selProfile.selectByAccountId(new Set<Id>{accountId});

            if (!profileList.isEmpty()) {
                PartyProfile profile = profileList[0];

                if (!String.isBlank(profile.PrimaryIdentifierType) && !String.isBlank(profile.PrimaryIdentifier)) {
                    // Add Passport Number or Identification Number block
                    ICS_DTO_SAPCreateCYTRequest.PartyIdentification profilePartyId = new ICS_DTO_SAPCreateCYTRequest.PartyIdentification();
                    profilePartyId.PartyIdentificationType = profile.PrimaryIdentifierType;

                    profilePartyId.PartyIdentification = new ICS_DTO_SAPCreateCYTRequest.PartyIdentificationDetail();
                    profilePartyId.PartyIdentification.IdentifierValue = new ICS_DTO_SAPCreateCYTRequest.IdentifierValue();
                    profilePartyId.PartyIdentification.IdentifierValue.Value = profile.PrimaryIdentifier;

                    partyRef.PartyIdentification.add(profilePartyId);
                    
                    String identificationType = '';
                    
                    // Determine identificationType based on PrimaryIdentifierType
                    if (profile.PrimaryIdentifierType == 'Passport Number') {
                        identificationType = 'ZPASS1';
                    } else if (profile.PrimaryIdentifierType == 'Identification Number') {
                        identificationType = 'ZGOV1';
                    }
                    
                    // Add identificationType block with ZPASS1 or ZGOV1 value
                    if (!String.isBlank(identificationType)) {
                        ICS_DTO_SAPCreateCYTRequest.PartyIdentification typeId = new ICS_DTO_SAPCreateCYTRequest.PartyIdentification();
                        typeId.PartyIdentificationType = 'identificationType';
                        
                        typeId.PartyIdentification = new ICS_DTO_SAPCreateCYTRequest.PartyIdentificationDetail();
                        typeId.PartyIdentification.IdentifierValue = new ICS_DTO_SAPCreateCYTRequest.IdentifierValue();
                        typeId.PartyIdentification.IdentifierValue.Value = identificationType;
                        
                        partyRef.PartyIdentification.add(typeId);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error fetching PartyProfile identification:' + e.getMessage(), 'createPartyReference');
            throw new AuraHandledException('Error fetching PartyProfile identification:');
        }


        // Party Identifier Date Time
        partyRef.PartyIdentifierDateTime = new ICS_DTO_SAPCreateCYTRequest.PartyIdentifierDateTime();
        partyRef.PartyIdentifierDateTime.IdentifierDateType = parsedData.get('ics_partyRef_PartyIdentifierDateTime');
        // Corrected date formatting
        Date currentDay = Date.today();
        partyRef.PartyIdentifierDateTime.IdentifierDateTime = DateTime.newInstance(currentDay, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');

        return partyRef;
    }
    /**
     * @description To create reference data
     * @param accId accountId
     * @return  ICS_DTO_SAPCreateCYTRequest
     */
    private ICS_DTO_SAPCreateCYTRequest.Reference createReference(String accId) {
        ICS_DTO_SAPCreateCYTRequest.Reference ref = new ICS_DTO_SAPCreateCYTRequest.Reference();
        ref.PartyTax = new List < ICS_DTO_SAPCreateCYTRequest.PartyTax > ();
        
        // Add EU Resident Indicator - FIXED LINE
        ref.PartyCountryClassification = new ICS_DTO_SAPCreateCYTRequest.PartyCountryClassification();
        String countryOfResidence = getCountryResidency();
        ref.PartyCountryClassification.EUResidentFlag = isEUCountry(countryOfResidence) ? 'X' : '';
        SEL_TaxDetails taxDataSel =new SEL_TaxDetails();
        Set<Id> accountIdset = new Set<Id>{accId};
          List < TaxDetails__c > mainTaxDetail = taxDataSel.selectByAccountIds(accountIdset);
        if (!mainTaxDetail.isEmpty()) {
            for (TaxDetails__c taxData: mainTaxDetail) {
                ICS_DTO_SAPCreateCYTRequest.PartyTax partyTax = new ICS_DTO_SAPCreateCYTRequest.PartyTax();
                PartyTax.PartyTaxCountry = taxData.Country__c;
                partyTax.PartyTaxType = parsedData.get('ics_partyTax_PartyTaxType');
                partyTax.PartyTaxNumber = taxData.TIN_IN_Number__c;
                partyTax.PartyTaxJurisdiction = 'IOM';
                
                // CTYID - Valid to (GBIDA) - Expiry date of the CYT information
                SEL_ReferenceData referencedDataSel =new SEL_ReferenceData();
                 List<AOB_ReferencedData__c> referencedDataList = referencedDataSel.getReferencedDataByName('EndDate');
                if (!referencedDataList.isEmpty()) {
                    PartyTax.PartyTaxDateTime = new ICS_DTO_SAPCreateCYTRequest.PartyTaxDateTime();
                    PartyTax.PartyTaxDateTime.TaxDateType = 'CYTID Valid to';
                    if(referencedDataList[0].AOB_Parent__c !=null){
                        PartyTax.PartyTaxDateTime.TaxDateTime = referencedDataList[0].AOB_Code__c;
                    }
                }
                            
                // Do Not Calculate tax (NOCYT) - Tax exempt flag
                PartyTax.PartyTaxExemptFlag = 'X';  // Default value 'X' = Exempt
                
                // Tax Statement Type Indicator (SDART)
                PartyTax.PartyTaxStatement = new ICS_DTO_SAPCreateCYTRequest.PartyTaxStatement();
                PartyTax.PartyTaxStatement.TaxStatementType = 'SDART';
                partyTax.PartyTaxStatement.TaxStatementValue = 'J';
                
                ref.PartyTax.add(PartyTax);
            }
        }
        return ref;
    }
     /**
    * Check if the given country code is an EU country
    * @param countryCode The ISO country code
    * @return true if EU country, false otherwise
    */
    @TestVisible
    private static Boolean isEUCountry(String countryCode) {
        if (String.isBlank(countryCode)) {
            return false;
        }
        
        // Get EU countries from custom metadata
        ics_customlabel__mdt metaData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('Preapplication');
        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(metaData.Description__c);
        
        // Get the EU countries list from metadata
        String euCountriesString = (String)jsonData.get('ics_eu_countries');
        
        if (String.isBlank(euCountriesString)) {
            return false;
        }
        
        // Convert to a set for easy lookup
        List<String> euCountriesList = euCountriesString.split(',');
        Set<String> euCountries = new Set<String>();
        for (String country : euCountriesList) {
            euCountries.add(country.trim().toUpperCase());
        }
        
        return euCountries.contains(countryCode.toUpperCase());
    }
     /**
        * @description Get country of residency from Account
        * @return String country code
        */
        private String getCountryResidency() {
        
            try {
                    PartyProfile profileInfo = new SEL_PartyProfile()
                                .selectByAccountAndRecordType(accountId, 'ICS_PartyProfile');
                            return profileInfo.Country_of_Residence__c;
            } catch (Exception e) {
                LOGGER.error('Error fetching country of residency: ' + e.getMessage(), 'getCountryResidency');
                return '';
            }
        }
     private ICS_DTO_SAPCreateCYTRequest.Person createPersonData(Id accId) {
         ICS_DTO_SAPCreateCYTRequest.Person personData = new ICS_DTO_SAPCreateCYTRequest.Person();
         SEL_Account accData =new SEL_Account();
         Account accRecord = accData.selectById(accId);
         personData.PlaceOfBirth=accRecord.Town_City_of_Birth__c != null 
                             ? accRecord.Town_City_of_Birth__c 
                             : 'Johannesburg'; 
         PersonData.Citizenship =accRecord.FinServ__CountryOfBirth__pc != null 
                             ? accRecord.FinServ__CountryOfBirth__pc 
                             : 'ZA'; 
         return personData;
         
     }
    /**
     * @description To create additional data
     * @return  ICS_DTO_SAPCreateCYTRequest
     */
    private ICS_DTO_SAPCreateCYTRequest.AdditionalData createAdditionalData() {
        ICS_DTO_SAPCreateCYTRequest.AdditionalData addData = new ICS_DTO_SAPCreateCYTRequest.AdditionalData();
        addData.CategoryInformation = new ICS_DTO_SAPCreateCYTRequest.CategoryInformation();
        addData.CategoryInformation.Category = new List < ICS_DTO_SAPCreateCYTRequest.Category > ();

        ICS_DTO_SAPCreateCYTRequest.Category category = new ICS_DTO_SAPCreateCYTRequest.Category();
        category.CategoryItem = parsedData.get('ics_category_CategoryItem');
        category.CategoryDetails = new List < ICS_DTO_SAPCreateCYTRequest.CategoryDetail > ();

        Map < String, String > categoryDetails = new Map < String, String > {
            'timestamp' => '',
            'correlationID' => parsedData.get('ics_category_correlationID'),
            'channelID' => parsedData.get('ics_category_channelID'),
            'UserID' => parsedData.get('ics_category_UserID'),
            'referenceID' => parsedData.get('ics_category_referenceID'),
            'OriginatingChannel' => parsedData.get('ics_category_OriginatingChannel'),
            'OriginatingProcess' => parsedData.get('ics_category_OriginatingProcess')
        };

        for (String key: categoryDetails.keySet()) {
            ICS_DTO_SAPCreateCYTRequest.CategoryDetail detail = new ICS_DTO_SAPCreateCYTRequest.CategoryDetail();
            detail.CategoryType = key;
            detail.CategoryIdentifierValue = categoryDetails.get(key);
            category.CategoryDetails.add(detail);
        }

        addData.CategoryInformation.Category.add(category);
        return addData;
    }
    /* @description To return AssessmentQuestionResponse for instructingBank
     * @param accId accountId
     * @return  ICS_DTO_SAPCreateCYTRequest
     */

    public String getInstructingtheBank(String accountId) {
        SEL_AssesmentQuestionResponse selector = new SEL_AssesmentQuestionResponse();
        List<AssessmentQuestionResponse> responses = selector.selectByAccountIdAndAssessmentName(accountId, 'consent1');
        if (!responses.isEmpty()) {
            return responses[0].ResponseText;
        }
        return 'TRUE'; 
    }

}