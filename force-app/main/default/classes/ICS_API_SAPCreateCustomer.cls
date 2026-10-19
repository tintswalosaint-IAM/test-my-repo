/*************************************************************
* @description SFP-43424 Class used to sap create customer
* @autor Ruchi Agarwal
* @date OCT 21 2024
***************************************************************
* Last Modified By  Ruchi Agarwal
* Last Modified Date 21/10/2024
* Last Modified Description: updated to latest Version
***************************************************************
* @Last Modified By  : Ramya Gurram
 * @Last Modified On  : 07-14-2025
 * @Last Modified Reason  : Updated Risk category
 * Story: SFP-49696 
 ***************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 07-11-2025
 * @Modification description : SFP-53863 Updated Country mapping Address Line logic
 *  ***************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 07-11-2025
 * @Modification description : SFP-54552 Updated createPhysicalAddress and createResidentialAddress
 ***************************************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 07-11-2025
 * @Modification description : SFP-54661 updated createSecurityQuestionsCategory logic to get security questions in order and updated for SCA
 * 
 * @Last Modified By 		: Ikyatha Naidu
* @Last Modified On 		: 26-02-2025
* @Modification description : SFP-54515 updated for join account
 ***************************************************************************************
 * @Last Modified By 		: Ikyatha Naidoo
 * @Last Modified On 		: 30-11-2026
 * @Modification description : SFP-57198  
   Update to the class for Joint accounts get a temporary/generated identifier
   Single accounts use existing identifier
 ***************************************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 22-05-2026
 * @Modification description : SFP-57389 updated createDetailedAddress method send to SAP
 ****************************************************************************************
 * @Last Modified By      : Ridhima Saxena
 * @Last Modified On      : 18-06-2026
 * @Modification Description : SFP-57387 & SFP-54306
 * Updated createOrganisationInstance to derive Sector Classification Type based on
 * Sales Code Country using the new getSectorCodeCountry method. Also updated
 * Nationality mapping to send the correct data to SAP.
 * ********************************************************
 * @Last Modified By      : Ridhima Saxena
 * @Last Modified On      : 16-07-2026
 * @Modification Description : SFP-54664 & SFP- 59113 Updated createBankRelations() method and 
 * 							   added getConsentResponseValue() and convertToYN() methods.
 * 							   SFP -52936 createAdditionalData() was updated	
 * @Last Modified By      : Ridhima Saxena
 * @Last Modified On      : 17-08-2026	
 * @Modification Description : SFP-57391 Updated fetchSecurityResponses()to retrieve security question responses.        
*/
public without sharing class ICS_API_SAPCreateCustomer {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_SAPCreateCustomer');
    private static final String SECTOR_ZSEC = 'ZSEC';
    private static final String END_DATE_KEY = 'EndDate';
    private static final String ICS_PARTY_PROFILE = 'ICS_PartyProfile';
    private static final String PARTY_PROFILE_RISK = 'Party Profile Risk';
    private static final String RATING_START_DATE = 'RatingData Start Date';
    private static final String RATING_DATE = 'RatingData Date Of Rating';
    private static final String RATING_ALLOWANCE = 'Rating Allowance';
    private static final String GRADE = 'Grade';
    private static final String TENDENCY = 'Tendency';
    private static final String RATING_COMMENT = 'Rating Comment';
    private static final String END_DATE_RISK = '9999-12-31';
    private static final String GRADE_END_DATE = 'End Date';
    private static final String GRADE_METHOD = 'Grade Method';
    private static final String MARKETING_CONSENT_QUESTION =
    'I would like to be kept informed about products, services and additional benefits that may be of interest to me.';
    
    private ICS_API_SAPCreateCustomer(){}
    public static  Account accData;
    Public static boolean isJoint;
    public static SEL_Account selectorAccount = new SEL_Account();
    public static Map<Id, AOB_ReferencedData__c> AOBReferencedData;
    Public static Map<String, String> AOBReferencedDataMap = new  Map<String, String>();
    // -------------------------------
    // Query Caches
    // -------------------------------
    private static Map<Id, List<ApplicationForm>> accountApplicationFormCache = new Map<Id, List<ApplicationForm>>();
    private static Map<Id, List<ApplicationForm>> opportunityApplicationFormCache = new Map<Id, List<ApplicationForm>>();
    private static Map<Id, PartyProfile> partyProfileCache = new Map<Id, PartyProfile>();
	private static Map<Id, OpportunityLineItem> oppLineItemCache = new Map<Id, OpportunityLineItem>();
    public static string createCustomerRequest(string accountId,boolean isJointInfo) {
        isJoint = isJointInfo;
        List < Account > accDataList = selectorAccount.selectByIds(new set<Id>{accountId});
        if(!accDataList.isEmpty()){
            accData = accDataList[0];
        }
        AOBReferencedData = new Map<Id, AOB_ReferencedData__c>(new SEL_ReferenceData().getChildReferencedData('ICS_SAP_CREATE_CUSTOMER_DATA'));

        for(AOB_ReferencedData__c CurrentAOBReferencedData : AOBReferencedData.values()){
            AOBReferencedDataMap.put(CurrentAOBReferencedData.Name, CurrentAOBReferencedData.AOB_Code__c);
        }
        ICS_DTO_SAPCreateCustomerRequest request = new ICS_DTO_SAPCreateCustomerRequest();
        request.Party = new List<ICS_DTO_SAPCreateCustomerRequest.Party>();
        request.Party.add(createParty());
        String requestBody = json.serialize(request);
        LOGGER.info('SAP Request Body: ' + requestBody);
        return json.serialize(request);
    }
    private static ICS_DTO_SAPCreateCustomerRequest.Party createParty() {

        ICS_DTO_SAPCreateCustomerRequest.Party party = new ICS_DTO_SAPCreateCustomerRequest.Party();
        party.PartyReference = createPartyReference();
        party.BankRelations = createBankRelations();
        party.Reference = createReference();
        Party.PartyRelationships= BuildPartyRelationships();
        party.Person = createPerson();
        party.Associations = createAssociations();
        party.OrganisationInstance = createOrganisationInstance();
        party.AdditionalData = createAdditionalData();
        return party;
    }
    private static final Set<String> RELATIONSHIP_TYPES = new Set<String>{
        'AccountHolder',
            'CorrespondenceRecipient',
            'CardHolder',
            'ContractPartner',
            'Counterparty'
            };
                public static List<ICS_DTO_SAPCreateCustomerRequest.PartyRelationship> buildPartyRelationships() {
                    List<ICS_DTO_SAPCreateCustomerRequest.PartyRelationship> relationships =
                        new List<ICS_DTO_SAPCreateCustomerRequest.PartyRelationship>();

                    String today = String.valueOf(System.today());
                    String endDate = AOBReferencedDataMap.get(END_DATE_KEY);

                    for(String relationType : RELATIONSHIP_TYPES) {
                        ICS_DTO_SAPCreateCustomerRequest.PartyRelationship relationship =
                            createSingleRelationship(relationType, today, endDate);

                        if (relationship != null) {
                            relationships.add(relationship);
                        }
                    }

                    return relationships;
                }

    private static ICS_DTO_SAPCreateCustomerRequest.PartyRelationship createSingleRelationship(
        String relationType,
        String startDate,
        String endDate
    ) {
        String relationshipValue = AOBReferencedDataMap.get(relationType);

        if (String.isNotBlank(relationshipValue)) {
            ICS_DTO_SAPCreateCustomerRequest.PartyRelationship relationship =
                new ICS_DTO_SAPCreateCustomerRequest.PartyRelationship();

            relationship.RelationshipType = relationType;
            relationship.RelationshipValue = relationshipValue;
            relationship.RelationshipStartDate = startDate;
            relationship.RelationshipEndDate = endDate;

            return relationship;
        }

        return null;
    }
    private static ICS_DTO_SAPCreateCustomerRequest.PartyReference createPartyReference() {
        ICS_DTO_SAPCreateCustomerRequest.PartyReference ref = initializePartyReference();
        populatePartyNames(ref);
        populatePartyIdentification(ref);
        populatePartyIdentifierDateTime(ref);
        return ref;
    }

    private static ICS_DTO_SAPCreateCustomerRequest.PartyReference initializePartyReference() {
        ICS_DTO_SAPCreateCustomerRequest.PartyReference ref = new ICS_DTO_SAPCreateCustomerRequest.PartyReference();
        ref.PartyType = determinePartyType();
        ref.PartyPreferredIdentifierFlag = 'true';
        return ref;
    }

    private static String determinePartyType() {
        return isJoint ? 'Joint' : 'Person';
    }

    private static void populatePartyNames(ICS_DTO_SAPCreateCustomerRequest.PartyReference ref) {
        ref.PartyName = new List<ICS_DTO_SAPCreateCustomerRequest.PartyName>();
        addBasicPartyNames(ref);
        if(isJoint) {
            addJointPartyNames(ref);
        }
    }

    private static void addBasicPartyNames(ICS_DTO_SAPCreateCustomerRequest.PartyReference ref) {
        string firstName=accData.FirstName;
        string lastName=accData.LastName;
      
            if(firstName.length() >  29){
                firstName=firstName.substring(0,29);
            }
            if(  lastName.length() > 29){
                 lastName= lastName.substring(0,29);
            }


        
        Map<String, String> nameMap = new Map<String, String>{
            'Initials' => accData.PersonTitle,
                'FirstName' =>firstName,
                'MiddleName' => accData.MiddleName,
                'LastName' => lastName
                };
                    addPartyNamesToReference(ref, nameMap);
    }

    private static void addJointPartyNames(ICS_DTO_SAPCreateCustomerRequest.PartyReference ref) {
        string totalName=constructFullName();
        string groupName1='';
        string groupName2='';
        if(totalName.length() < 40){
            groupName1=totalName;
        }else{
            groupName1=totalName.substring(0,40);
        }
        if(totalName.length() < 80 && totalName.length() > 40){
            groupName2=totalName.substring(40);
        }else if(totalName.length() > 80 ){
            groupName2=totalName.substring(40,80);
        }

        Map<String, String> nameGroupMap = new Map<String, String>{
            'GroupName1' => groupName1,
                'GroupName2' => groupName2,
                'GroupType' => '0009'
                };
                    addPartyNamesToReference(ref, nameGroupMap);
    }
	private static PartyProfile getPartyProfile(Id accId){

        if(!partyProfileCache.containsKey(accId)){
    
           PartyProfile profileData =
                new SEL_PartyProfile().selectByAccountAndRecordType(accId, ICS_PARTY_PROFILE);
    
                partyProfileCache.put(accId, profileData);
            
        }
    
        return partyProfileCache.get(accId);
    }
    private static String constructFullName() {

        if(!accountApplicationFormCache.containsKey(accData.id)){
            SEL_ApplicationForm selAppForm = new SEL_ApplicationForm();
            accountApplicationFormCache.put(
                accData.id,
                selAppForm.selectByAccountId(accData.id)
            );
        }
    
        List<ApplicationForm> appform = accountApplicationFormCache.get(accData.id);
    
        if(appform.isEmpty()){
            return '';
        }
    
        Id oppId = appform[0].OpportunityId;
    
        if(!opportunityApplicationFormCache.containsKey(oppId)){
            SEL_ApplicationForm selAppForm = new SEL_ApplicationForm();
            opportunityApplicationFormCache.put(
                oppId,
                selAppForm.selectByOpportunityId(oppId)
            );
        }
    
        List<ApplicationForm> appforms = opportunityApplicationFormCache.get(oppId);
    
        List<String> namesList = new List<String>();
    
        for(ApplicationForm appf : appforms){
            namesList.add(appf.account.persontitle + ' ' + appf.account.lastName);
        }
    
        return String.join(namesList, ', ');
    }

    private static Boolean checkIsPlatinumOptimum(){

        if(!accountApplicationFormCache.containsKey(accData.id)){
            SEL_ApplicationForm selAppForm = new SEL_ApplicationForm();
            accountApplicationFormCache.put(
                accData.id,
                selAppForm.selectByAccountId(accData.id)
            );
        }
    
        List<ApplicationForm> appform = accountApplicationFormCache.get(accData.id);
    
        if(appform.isEmpty()){
            return false;
        }
    
        Id oppId = appform[0].OpportunityId;
    
        if(!oppLineItemCache.containsKey(oppId)){
    
            SEL_OpportunityLineItem selOppLineItem = new SEL_OpportunityLineItem();
    
            oppLineItemCache.put(
                oppId,
                selOppLineItem.selectByOpportunityId(oppId)
            );
        }
    
        OpportunityLineItem oppLineItem = oppLineItemCache.get(oppId);
    
        return oppLineItem != null && oppLineItem.ProductCode == 'CURR_POPT';
    }
    private static void addPartyNamesToReference(ICS_DTO_SAPCreateCustomerRequest.PartyReference ref, Map<String, String> nameMap) {
        for(String type : nameMap.keySet()) {
            ICS_DTO_SAPCreateCustomerRequest.PartyName name = new ICS_DTO_SAPCreateCustomerRequest.PartyName();
            name.PartyNameType = type;
            name.PartyNameValue = nameMap.get(type);
            ref.PartyName.add(name);
        }
    }

   private static void populatePartyIdentification(ICS_DTO_SAPCreateCustomerRequest.PartyReference ref) {
        ref.PartyIdentification = new List<ICS_DTO_SAPCreateCustomerRequest.PartyIdentification>();
        
        String identifier = resolveIdentifier();
        String identificationType = resolveIdentificationType();
        
        Map<String, String> idMap = createIdentificationMap(identifier, identificationType);
        for(String type : idMap.keySet()) {
            ref.PartyIdentification.add(createPartyIdentification(type, idMap.get(type)));
        }
    }
    
    private static String resolveIdentifier() {
        String guid = generateGUID().substring(0, 5);
        PartyProfile profileData = getPartyProfile(accData.id);
        if (isValidICSPartyProfile(profileData)) {
            return isJoint ? guid : profileData.PrimaryIdentifier;
        }
        
        return '';
    }
    
    private static String resolveIdentificationType() {
        PartyProfile profileData = getPartyProfile(accData.id);
            if (isValidICSPartyProfile(profileData)) {
                return mapIdentificationType(profileData.PrimaryIdentifierType);
            }
        return '';
    }
    
    private static boolean isValidICSPartyProfile(PartyProfile profileData) {
        return profileData.RecordType.Name == 'ICS Party Profile' 
            && profileData.PrimaryIdentifier != null;
    }
    
    private static String mapIdentificationType(String primaryIdentifierType) {
        Map<String, String> typeMap = new Map<String, String>{
            'Passport Number' => 'ZPASS1',
            'Identification Number' => 'ZGOV1'
        };
        return typeMap.containsKey(primaryIdentifierType) ? typeMap.get(primaryIdentifierType) : '';
    }
    private static Map<String, String> createIdentificationMap(String identifier,String identificationType) {
        
    
        return new Map<String, String>{
            'identificationNumber' => identifier,
                'identificationType' => identificationType,
                    'salesforceID'=>accData.id,
                    'reportingCountry'=>getCountryResidency(),
                    'basellType'=>'04',
                    'subaccountType' =>'OFFSHRECLIENT'
                    };
                        }

    private static ICS_DTO_SAPCreateCustomerRequest.PartyIdentification createPartyIdentification(String type, String value) {
        ICS_DTO_SAPCreateCustomerRequest.PartyIdentification pid = new ICS_DTO_SAPCreateCustomerRequest.PartyIdentification();
        pid.PartyIdentificationType = type;
        pid.PartyIdentification = new ICS_DTO_SAPCreateCustomerRequest.IdentificationDetail();
        pid.PartyIdentification.IdentifierValue = new ICS_DTO_SAPCreateCustomerRequest.IdentifierValue();
        pid.PartyIdentification.IdentifierValue.Value = value;
        return pid;
    }

    private static void populatePartyIdentifierDateTime(ICS_DTO_SAPCreateCustomerRequest.PartyReference ref) {
        ref.PartyIdentifierDateTime = new List<ICS_DTO_SAPCreateCustomerRequest.PartyIdentifierDateTime>();
        Map<String, String> dateMap = createDateMap();

        for(String type : dateMap.keySet()) {
            ref.PartyIdentifierDateTime.add(createPartyDateTime(type, dateMap.get(type)));
        }
    }

    private static Map<String, String> createDateMap() {
        return new Map<String, String>{
            'StartDate' => String.valueOf(Date.today()),
                'EndDate' => AOBReferencedDataMap.containsKey(END_DATE_KEY)
                ? AOBReferencedDataMap.get(END_DATE_KEY)
                : null,
                    'RatingDate' => AOBReferencedDataMap.containsKey(END_DATE_KEY)
                    ? AOBReferencedDataMap.get(END_DATE_KEY)
                    : null
                        };
                            }

    private static ICS_DTO_SAPCreateCustomerRequest.PartyIdentifierDateTime createPartyDateTime(String type, String value) {
        ICS_DTO_SAPCreateCustomerRequest.PartyIdentifierDateTime dt = new ICS_DTO_SAPCreateCustomerRequest.PartyIdentifierDateTime();
        dt.IdentifierDateType = type;
        dt.IdentifierDateTime = value;
        return dt; 
    }

   private static ICS_DTO_SAPCreateCustomerRequest.BankRelations createBankRelations() {
            ICS_DTO_SAPCreateCustomerRequest.BankRelations relations = new ICS_DTO_SAPCreateCustomerRequest.BankRelations();
            relations.BankRelationReference = new List<ICS_DTO_SAPCreateCustomerRequest.BankRelationReference>();
        
            Map<String, String> relationMap = new Map<String, String>{
                'INSTRUCTIONS VIA TEL/FAX' => getConsentResponseValue('consent1', 'Y'),
                    'FEE WAIVER' => AOBReferencedDataMap.containsKey('ZBP_MKTG_CONSENT_ID_FRAUD_CHEC') ? AOBReferencedDataMap.get('ZBP_MKTG_CONSENT_ID_FRAUD_CHEC') : null,
                        'ZBP_NO_MKTG_CONSENT_SMS_CONS' => invertYN(getConsentResponseValue(MARKETING_CONSENT_QUESTION, 'N'))
                            };
        
            for(String text : relationMap.keySet()) {
                ICS_DTO_SAPCreateCustomerRequest.BankRelationReference ref = new ICS_DTO_SAPCreateCustomerRequest.BankRelationReference();
                ref.RelationshipType = new ICS_DTO_SAPCreateCustomerRequest.RelationshipType();
                ref.RelationshipType.Text = text;
                ref.RelationshipType.Value = relationMap.get(text);
                relations.BankRelationReference.add(ref);
            }
        
            return relations;
        }
        
        private static String getConsentResponseValue(String assessmentQuestionName, String defaultValue) {
            List<AssessmentQuestionResponse> responses = new SEL_AssesmentQuestionResponse()
                .selectByAccountIdAndAssessmentName(accData.id, assessmentQuestionName);
            if (!responses.isEmpty()) {
                return convertToYN(responses[0].ResponseText);
            }
            return defaultValue;
        }
        
        private static String invertYN(String value) {
            return value == 'Y' ? 'N' : 'Y';
        }
        
        private static String convertToYN(String value) {
            return String.isNotBlank(value) && value.equalsIgnoreCase('false') ? 'N' : 'Y';
        }

    	private static ICS_DTO_SAPCreateCustomerRequest.Reference createReference() {
        ICS_DTO_SAPCreateCustomerRequest.Reference ref = new ICS_DTO_SAPCreateCustomerRequest.Reference();
        if (isJoint) {
            ref = createJointReference();
        } else {
            ref = createIndividualReference();
        }

        List<TaxDetails__c> taxDetails = new SEL_TaxDetails().selectByAccountIds(new Set<Id>{accData.Id});
        ref.PartyTax = new List<ICS_DTO_SAPCreateCustomerRequest.PartyTax>();
        for (TaxDetails__c taxData : taxDetails) {
            ICS_DTO_SAPCreateCustomerRequest.PartyTax tax = new ICS_DTO_SAPCreateCustomerRequest.PartyTax();
            tax.PartyTaxCountry = taxData.Jurisdiction_of_Tax_Residence__c;
            tax.PartyTaxType = 'Personal';
            tax.PartyTaxNumber = taxData.TaxNumber__c;
            ref.PartyTax.add(tax);
        }

        ref.PartyContactPoint = new List<ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint>();
        ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint emailContact = new ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint();
        emailContact.ContactPoint = new ICS_DTO_SAPCreateCustomerRequest.ContactPoint();
        emailContact.ContactPoint.ContactPointType = 'ELECTRONICADDRESS';
        emailContact.ContactPoint.PrefferedCommunicationMethod = 'Email';
        emailContact.ContactPoint.ElectronicAddress = new ICS_DTO_SAPCreateCustomerRequest.ElectronicAddress();
        emailContact.ContactPoint.ElectronicAddress.EmailAddress = accData.PersonEmail;
        ref.PartyContactPoint.add(emailContact);

        List<ContactPointPhone> contactPointPhoneList = new SEL_ContactPointPhone().selectByParentId(accData.Id);
        Map<String, Map<String, String>> phoneContacts = new Map<String, Map<String, String>>();
        for (ContactPointPhone currentContactPointPhone : contactPointPhoneList) {
            Map<String, String> phoneMap = new Map<String, String>();
             if (currentContactPointPhone.isPrimary == true) {
                phoneMap.put('tellePhone', currentContactPointPhone.TelephoneNumber);
                phoneContacts.put('TELEPHONE', phoneMap);
            } else {
                phoneMap.put('cellPhone', currentContactPointPhone.TelephoneNumber);
                phoneContacts.put('CELLPHONE', phoneMap);
            }

        }

        for (String contactType : phoneContacts.keySet()) {
            ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint phoneContact = new ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint();
            phoneContact.ContactPoint = new ICS_DTO_SAPCreateCustomerRequest.ContactPoint();
            phoneContact.ContactPoint.ContactPointType = contactType;
            
            
            phoneContact.ContactPoint.TelephonicAddress = new ICS_DTO_SAPCreateCustomerRequest.TelephonicAddress();

            for (String phoneType : phoneContacts.get(contactType).keySet()) {
                phoneContact.ContactPoint.TelephonicAddress.PhoneType = phoneType;
                phoneContact.ContactPoint.TelephonicAddress.PhoneValue = phoneContacts.get(contactType).get(phoneType);
            }
            ref.PartyContactPoint.add(phoneContact);
        }

        createPreferredLanguageContactPoint(ref);

        return ref;
    }

    private static ICS_DTO_SAPCreateCustomerRequest.Reference createJointReference() {
        ICS_DTO_SAPCreateCustomerRequest.Reference ref = new ICS_DTO_SAPCreateCustomerRequest.Reference();
        String name = constructFullName();
        if (name.length() > 50) {
            ref.PartyNameSalution = name.substring(0, 50);
        } else {
            ref.PartyNameSalution = name;
        }
        return ref;
    }

    private static ICS_DTO_SAPCreateCustomerRequest.Reference createIndividualReference() {
        ICS_DTO_SAPCreateCustomerRequest.Reference ref = new ICS_DTO_SAPCreateCustomerRequest.Reference();
        String name = accData.PersonTitle + ' ' + accData.LastName;
        if (name.length() > 50) {
            ref.PartyNameSalution = name.substring(0, 50);
        } else {
            ref.PartyNameSalution = name;
        }
        return ref;
    }



    private static void createPreferredLanguageContactPoint(ICS_DTO_SAPCreateCustomerRequest.Reference ref) {
        ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint languageContact = new ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint();
        languageContact.ContactPoint = new ICS_DTO_SAPCreateCustomerRequest.ContactPoint();
        languageContact.ContactPoint.ContactPointType = 'PREFERREDLANGUAGE';
        languageContact.ContactPoint.Language = new ICS_DTO_SAPCreateCustomerRequest.Language();
        languageContact.ContactPoint.Language.LanguageCode = 'EN';
        ref.PartyContactPoint.add(languageContact);
        createAddressContactPoints(ref);

    }


    private static void createAddressContactPoints(ICS_DTO_SAPCreateCustomerRequest.Reference ref) {
        addAddressTypeContact(ref);
        addAddressTypeContactDefault(ref);
        // Get party profile info
        PartyProfile profileInfo = getPartyProfile(accData.Id);

        // Get address information
        AddressInfo addressInfo = getAddressInformation(profileInfo);

        // Create and add residential address
        createResidentialAddress(ref, addressInfo.currentAddress);

        // Create and add physical address
        createPhysicalAddress(ref, addressInfo.correspondenceAddress);
    }
    private static void addAddressTypeContact(ICS_DTO_SAPCreateCustomerRequest.Reference ref) {
        ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint addressTypeContact = new ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint();
        addressTypeContact.ContactPoint = new ICS_DTO_SAPCreateCustomerRequest.ContactPoint();
        addressTypeContact.ContactPoint.ContactPointType = 'ADDRESSTYPECODE';
        addressTypeContact.ContactPoint.Address = new ICS_DTO_SAPCreateCustomerRequest.Address();
        addressTypeContact.ContactPoint.Address.AddressType = 'ZPHYS';
        ref.PartyContactPoint.add(addressTypeContact);
    }
    private static void addAddressTypeContactDefault(ICS_DTO_SAPCreateCustomerRequest.Reference ref) {
        ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint addressTypeContact = new ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint();
        addressTypeContact.ContactPoint = new ICS_DTO_SAPCreateCustomerRequest.ContactPoint();
        addressTypeContact.ContactPoint.ContactPointType = 'ADDRESSTYPECODE';
        addressTypeContact.ContactPoint.Address = new ICS_DTO_SAPCreateCustomerRequest.Address();
        addressTypeContact.ContactPoint.Address.AddressType = 'XXDEFAULT';
        ref.PartyContactPoint.add(addressTypeContact);
    }

   

    private class AddressInfo {
        PartyProfileAddress currentAddress;
        PartyProfileAddress correspondenceAddress;
    }

    private static AddressInfo getAddressInformation(PartyProfile profileInfo) {
        SEL_PartyProfileAddress selector = new SEL_PartyProfileAddress();
        AddressInfo info = new AddressInfo();

        List<PartyProfileAddress> currAddressInfoList = selector.selectCurrentAddressByPartyProfileId(profileInfo.id);
        info.currentAddress = currAddressInfoList[0];

        List<PartyProfileAddress> correspondingAddressList = selector.selectByPartyProfileType(profileInfo.id, 'Correspondence Address');
        info.correspondenceAddress = correspondingAddressList.isEmpty() ? info.currentAddress : correspondingAddressList[0];

        return info;
    }
    private static String defaultIfBlank(String value) {
        return String.isBlank(value) ? '.' : value;
    }
   private static void createResidentialAddress(ICS_DTO_SAPCreateCustomerRequest.Reference ref, PartyProfileAddress address) {

        String addressLine1 = defaultIfBlank(
            buildAddressLine(new List<String>{
                address.Apartment_Number__c,
                address.Building_Name__c,
                address.Sub_Building__c,
                address.Street
            })
        );
    
        String addressLine2 = defaultIfBlank(
            buildAddressLine(new List<String>{
                address.Secondary_Street__c,
                address.Neighbourhood__c,
                address.Parish__c
            })
        );
        if(addressLine2.length() > 40){
            addressLine2 = addressLine2.substring(0, 40);
        }
    
        String addressLine3 = defaultIfBlank(
            buildAddressLine(new List<String>{
                address.City,
                address.District__c,
                extractAfterSemicolon(address.Sub_region__c),
                extractAfterSemicolon(address.State)
            })
        );
        if(addressLine3.length() > 40){
            addressLine3 = addressLine3.substring(0, 40);
        }
    
        Map<String, String> countryCodeMap = getCountryCodeMap();
        String countryValue = address.Country;
        if (countryCodeMap != null && countryCodeMap.containsKey(address.Country)) {
            countryValue = toCamelCase(countryCodeMap.get(address.Country));
        }
    
        String addressLine4 = defaultIfBlank(
            buildAddressLine(new List<String>{
                address.PostalCode,
                countryValue
            })
        );
    
        List<String> streetLines = new List<String>{
            addressLine1,
            addressLine2,
            addressLine3,
            addressLine4
        };
    
        Map<String, String> subdivisions = new Map<String, String>{
            'countryCode' => address.Country,
            'Zone' => 'BB'
        };
    
        createDetailedAddress(ref, 'PhysicalAddress', streetLines, address.PostalCode, subdivisions);
    }

   private static void createPhysicalAddress(ICS_DTO_SAPCreateCustomerRequest.Reference ref, PartyProfileAddress address) {
        String addressLine1 = defaultIfBlank(
            buildAddressLine(new List<String>{
                address.Apartment_Number__c,
                address.Building_Name__c,
                address.Sub_Building__c,
                address.Street
            })
        );
    
        String addressLine2 = defaultIfBlank(
            buildAddressLine(new List<String>{
                address.Secondary_Street__c,
                address.Neighbourhood__c,
                address.Parish__c
            })
        );
        if(addressLine2.length() > 40){
            addressLine2 = addressLine2.substring(0, 40);
        }
    
        String addressLine3 = defaultIfBlank(
            buildAddressLine(new List<String>{
                address.City,
                address.District__c,
                extractAfterSemicolon(address.Sub_region__c),
                extractAfterSemicolon(address.State)
            })
        );
        if(addressLine3.length() > 40){
            addressLine3 = addressLine3.substring(0, 40);
        }
    
        Map<String, String> countryCodeMap = getCountryCodeMap();
        String countryValue = address.Country;
        if(countryCodeMap != null && countryCodeMap.containsKey(address.Country)){
            countryValue = toCamelCase(countryCodeMap.get(address.Country));
        }
    
        String addressLine4 = defaultIfBlank(
            buildAddressLine(new List<String>{
                address.PostalCode,
                countryValue
            })
        );
    
        List<String> streetLines = new List<String>{
            addressLine1, addressLine2, addressLine3, addressLine4
        };
    
        Map<String, String> subdivisions = new Map<String, String>{
            'countryCode' => address.Country,
            'Zone' => 'BB'
        };
    
        createDetailedAddress(ref, 'PostalAddress', streetLines, address.PostalCode, subdivisions);
    }
    public static Map<String, String> getCountryCodeMap() {
        Map<String, String> countryCodeMap = new Map<String, String>();
        try {
            Map<String, String> tempMap = ICS_CTRL_PreAppFormCreator.countryCodeMap();
            if (tempMap != null && !tempMap.isEmpty()) {
                for (String key : tempMap.keySet()) {
                    String value = tempMap.get(key);
                    if (key != null && value != null) {
                        countryCodeMap.put(key.trim(), value.trim());
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), 'Error in getCountryCodeMap');
        }
        return countryCodeMap;
    }
    @TestVisible
    private static String toCamelCase(String value) {
        if (String.isBlank(value)) {
            return value;
        }
        
        List<String> words = value.trim().split('\\s+');
        List<String> camelCaseWords = new List<String>();
        
        for (String word : words) {
            if (String.isNotBlank(word)) {
                String camelWord = word.substring(0, 1).toUpperCase() + 
                                word.substring(1).toLowerCase();
                camelCaseWords.add(camelWord);
            }
        }
        
        return String.join(camelCaseWords, ' ');
    }

	private static String buildAddressLine(List<String> fields) {
        List<String> nonEmptyFields = new List<String>();
        
        for (String field : fields) {
            if (String.isNotBlank(field)) {
                nonEmptyFields.add(field.trim());
            }
        }
        
        if (nonEmptyFields.isEmpty()) {
            return '';
        }
        
        String addressLine = String.join(nonEmptyFields, ', ');
        return addressLine.length() > 39 ? addressLine.substring(0, 39) : addressLine;
    }
    private static String extractAfterSemicolon(String value) {
        if (String.isBlank(value)) {
            return value;
        }
        
        // Check if the value contains a semicolon
        if (value.contains(';')) {
            // Split by semicolon and return the part after it
            List<String> parts = value.split(';');
            if (parts.size() > 1) {
                return parts[1].trim();
            }
        }
        
        // If no semicolon, return the original value
        return value;
    }
   /* 
     * SFP-57389 - Added logic to send Addressee details to SAP.
     * Checks whether the application is Single or Joint.
     * For Joint applications, constructFullName() is called to include all applicants' names.
     */
    private static void createDetailedAddress(ICS_DTO_SAPCreateCustomerRequest.Reference ref,
                                              String addressType,
                                              List<String> streetLines,
                                              String postCode,
                                              Map<String, String> subdivisions) {
                                                  ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint addressContact = new ICS_DTO_SAPCreateCustomerRequest.PartyContactPoint();
                                                  addressContact.ContactPoint = new ICS_DTO_SAPCreateCustomerRequest.ContactPoint();
                                                  addressContact.ContactPoint.ContactPointType = addressType;
                                                  addressContact.ContactPoint.Address = new ICS_DTO_SAPCreateCustomerRequest.Address();
                                                  addressContact.ContactPoint.Address.AddressType = addressType;
                                               if (isJoint) {
                                                    String addresseeName = constructFullName();
                                                    addressContact.ContactPoint.Address.Addressee = addresseeName.length() > 50
                                                        ? addresseeName.substring(0, 50)
                                                        : addresseeName;
                                                } else {
                                                    addressContact.ContactPoint.Address.Addressee = accData.Name != null && accData.Name.length() > 50
                                                        ? accData.Name.substring(0, 50)
                                                        : accData.Name;
                                                }

                                                  addressContact.ContactPoint.Address.StreetName = new List<ICS_DTO_SAPCreateCustomerRequest.PartyName>();
                                                  for(Integer i = 0; i < streetLines.size(); i++) {
                                                      ICS_DTO_SAPCreateCustomerRequest.PartyName street = new ICS_DTO_SAPCreateCustomerRequest.PartyName();
                                                      street.PartyNameValue = streetLines[i];
                                                      street.PartyNameType = 'AddressLine' + (i + 1);
                                                      addressContact.ContactPoint.Address.StreetName.add(street);
                                                  }

                                                  addressContact.ContactPoint.Address.PostCode = new ICS_DTO_SAPCreateCustomerRequest.PostCode();
                                                  addressContact.ContactPoint.Address.PostCode.IdentifierValue = new ICS_DTO_SAPCreateCustomerRequest.IdentifierValue();
                                                  addressContact.ContactPoint.Address.PostCode.IdentifierValue.Value = postCode == null ? '0000' : postCode;

                                                  addressContact.ContactPoint.Address.CountrySubDivision = new ICS_DTO_SAPCreateCustomerRequest.CountrySubDivision();
                                                  addressContact.ContactPoint.Address.CountrySubDivision.CountrySubDivision = new List<ICS_DTO_SAPCreateCustomerRequest.CountrySubDivisionDetail>();

                                                  for(String type : subdivisions.keySet()) {
                                                      ICS_DTO_SAPCreateCustomerRequest.CountrySubDivisionDetail subdivision = new ICS_DTO_SAPCreateCustomerRequest.CountrySubDivisionDetail();
                                                      subdivision.CountrySubDivisionType = type;
                                                      subdivision.CountrySubDivisionValue = subdivisions.get(type);
                                                      addressContact.ContactPoint.Address.CountrySubDivision.CountrySubDivision.add(subdivision);
                                                  }

                                                  ref.PartyContactPoint.add(addressContact);
                                              }

    private static ICS_DTO_SAPCreateCustomerRequest.Person createPerson() {
        ICS_DTO_SAPCreateCustomerRequest.Person person = initializePersonBasicInfo();
        setPersonEmploymentProfile(person);
        return person;
    }

     private static String getCountryResidency() {
        return new SEL_PartyProfile()
            .selectByAccountAndRecordType(accData.Id, ICS_PARTY_PROFILE)
            .Country_of_Residence__c;
    }
    private static ICS_DTO_SAPCreateCustomerRequest.Person initializePersonBasicInfo() {
        PartyProfile profileInfo = new SEL_PartyProfile()
            .selectByAccountAndRecordType(accData.Id, ICS_PARTY_PROFILE);

        ICS_DTO_SAPCreateCustomerRequest.Person person = new ICS_DTO_SAPCreateCustomerRequest.Person();


        person.BirthDate = String.valueOf(accData.PersonBirthdate);
        person.Gender = accData.FinServ__Gender__pc;
        person.Title = accData.PersonTitle;
        person.PlaceOfBirth = accData?.Town_City_of_Birth__c;
        person.Citizenship = profileInfo?.WI_CountryOfCitizenship__c;
        person.Nationality = profileInfo?.Country_of_Nationality__c;
        person.Language = 'English';

        return person;
    }


    private static void setPersonEmploymentProfile(ICS_DTO_SAPCreateCustomerRequest.Person person) {
        FinServ__Employment__c employment = getEmploymentDetails();
        if (employment == null) {
            return;
        }
        person.PersonEmploymentProfile = new ICS_DTO_SAPCreateCustomerRequest.PersonEmploymentProfile();
        if(employment.Name.length()>35){
             person.PersonEmploymentProfile.EmployerName = employment.Name.substring(0,34);
        }else{
            person.PersonEmploymentProfile.EmployerName = employment.Name;
        }
        setEmploymentDates(person.PersonEmploymentProfile, employment);
        setEmploymentTypes(person.PersonEmploymentProfile);
        setMarriageStatus(person.PersonEmploymentProfile);
    }


    private static FinServ__Employment__c getEmploymentDetails() {
        Map<Id, FinServ__Employment__c> employmentMap = new Map<Id, FinServ__Employment__c>(
            new SEL_Employment().selectByParentIdAndSectionName(accData.Id, 'Current Employment Details')
        );

        for (FinServ__Employment__c emp : employmentMap.values()) {
            if (emp.Person_Account__c == accData.Id) {
                return emp;
            }
        }
        return null;
    }


    private static void setEmploymentDates(ICS_DTO_SAPCreateCustomerRequest.PersonEmploymentProfile profile,
                                           FinServ__Employment__c employment) {
                                               profile.EmploymentDate = new List<ICS_DTO_SAPCreateCustomerRequest.EmploymentDate>();

                                               // Add start date
                                               if (employment.FinServ__StartDate__c == null) {
                                                   addEmploymentDate(profile, 'StartDate', String.valueOf(date.today()));
                                               }else{
                                                   addEmploymentDate(profile, 'StartDate', String.valueOf(employment.FinServ__StartDate__c));
                                               }

                                               // Add end date if exists
                                               String endDate = AOBReferencedDataMap.get(END_DATE_KEY);
                                               if (String.isNotBlank(endDate)) {
                                                   addEmploymentDate(profile,'EndDate', endDate);
                                               }
                                           }


    private static void addEmploymentDate(ICS_DTO_SAPCreateCustomerRequest.PersonEmploymentProfile profile,
                                          String dateType,
                                          String dateValue) {
                                              ICS_DTO_SAPCreateCustomerRequest.EmploymentDate empDate =
                                                  new ICS_DTO_SAPCreateCustomerRequest.EmploymentDate();
                                              empDate.EmploymentDateType = dateType;
                                              empDate.EmploymentDateTime = dateValue;

                                              profile.EmploymentDate.add(empDate);
                                          }


    private static void setEmploymentTypes(
        ICS_DTO_SAPCreateCustomerRequest.PersonEmploymentProfile profile
    ) {
        profile.Employment = new List<ICS_DTO_SAPCreateCustomerRequest.Employment>();

        Map<String, String> employmentTypes = new Map<String, String>{
            'PartnerCategory' => AOBReferencedDataMap.containsKey('PartnerCategory') ? AOBReferencedDataMap.get('PartnerCategory') : null,
                'PartnerType' => AOBReferencedDataMap.containsKey('PartnerType') ? AOBReferencedDataMap.get('PartnerType') : null,
                    'DataOriginTypeCode' => AOBReferencedDataMap.containsKey('DataOriginTypeCode') ? AOBReferencedDataMap.get('DataOriginTypeCode') : null,
                        'CommunicationTypeCode' => AOBReferencedDataMap.containsKey('CommunicationTypeCode') ? AOBReferencedDataMap.get('CommunicationTypeCode') : null
                            };

                                for (String type : employmentTypes.keySet()) {
                                    String value = employmentTypes.get(type);
                                    if (String.isNotBlank(value)) {
                                        addEmploymentType(profile, type, value);
                                    }
                                }
    }

    private static void addEmploymentType(
        ICS_DTO_SAPCreateCustomerRequest.PersonEmploymentProfile profile,
        String type,
        String value
    ) {
        ICS_DTO_SAPCreateCustomerRequest.Employment emp =
            new ICS_DTO_SAPCreateCustomerRequest.Employment();
        emp.Type = type;
        emp.Value = value;
        profile.Employment.add(emp);
    }

    private static void setMarriageStatus(
        ICS_DTO_SAPCreateCustomerRequest.PersonEmploymentProfile profile
    ) {
        profile.Marriage = new ICS_DTO_SAPCreateCustomerRequest.Marriage();
        profile.Marriage.MaritalStatus = accData.FinServ__MaritalStatus__pc;
    }

    private static ICS_DTO_SAPCreateCustomerRequest.Associations createAssociations() {
        ICS_DTO_SAPCreateCustomerRequest.Associations associations = new ICS_DTO_SAPCreateCustomerRequest.Associations();
        associations.PartyGroupRelationship = new ICS_DTO_SAPCreateCustomerRequest.PartyGroupRelationship();
        associations.PartyGroupRelationship.PartyGroupRelationshipDate = new ICS_DTO_SAPCreateCustomerRequest.PartyGroupRelationshipDate();
        associations.PartyGroupRelationship.PartyGroupRelationshipDate.StartDate =  string.valueof(system.today());
        associations.PartyGroupRelationship.PartyGroupRelationshipDate.EndDate = AOBReferencedDataMap.containsKey(END_DATE_KEY) ? AOBReferencedDataMap.get(END_DATE_KEY) : null;
        return associations;
    }

    private static ICS_DTO_SAPCreateCustomerRequest.OrganisationInstance createOrganisationInstance() {
        ICS_DTO_SAPCreateCustomerRequest.OrganisationInstance orgInstance = new ICS_DTO_SAPCreateCustomerRequest.OrganisationInstance();
        orgInstance.Organisation = new ICS_DTO_SAPCreateCustomerRequest.Organisation();


        orgInstance.Organisation.IndustrySectorClassification = new List<ICS_DTO_SAPCreateCustomerRequest.IndustrySectorClassification>();
        Map<String, String> sectorMap = new Map<String, String>{
            'ZSBO' => AOBReferencedDataMap.containsKey('ZSBO') ? AOBReferencedDataMap.get('ZSBO') : null,
                SECTOR_ZSEC => AOBReferencedDataMap.containsKey(SECTOR_ZSEC) ? AOBReferencedDataMap.get(SECTOR_ZSEC) : null
                    };
        ics_customlabel__mdt metaData=ICS_CTRL_PreAppFormCreator.getLandingPageJSON('Preapplication');
        Map<String, object> jsonData = (Map<String, object>)JSON.deserializeUntyped(metaData.Description__c);
        List<String> countryCodes = ((string)jsonData.get('ics_african_countries')).split(',');
		String salesCodeCountry = getSectorCodeCountry();
        for(String secmap : sectorMap.keySet()) {
            ICS_DTO_SAPCreateCustomerRequest.IndustrySectorClassification sector = new ICS_DTO_SAPCreateCustomerRequest.IndustrySectorClassification();
            sector.SectorClassificationSystem = secmap;

            if(secmap ==SECTOR_ZSEC) {
                if(salesCodeCountry =='ZA') {
                    sector.SectorClassificationType = '1002';
                }

               else if (String.isNotBlank(salesCodeCountry) && countryCodes.contains(salesCodeCountry.toUpperCase())) {
                    sector.SectorClassificationType = '1008';
                } else {
                    sector.SectorClassificationType = '1001';
                }
            } else {
                sector.SectorClassificationType = sectorMap.get(secmap);

            }
            orgInstance.Organisation.IndustrySectorClassification.add(sector);
        }


        orgInstance.Organisation.Status = new ICS_DTO_SAPCreateCustomerRequest.Status();
        orgInstance.Organisation.Status.StatusReason = new ICS_DTO_SAPCreateCustomerRequest.StatusReason();
        orgInstance.Organisation.Status.StatusReason.Text = 'ACTIVE';

        return orgInstance;
    }
     /* SFP-57387 Added getSectorCodeCountry method to derive
     *                              Sales Code Country from the Opportunity associated with
     *                              the Account and determine the appropriate SAP Sector
     *                              Classification Type.*/
      private static String getSectorCodeCountry() {
      	if(!accountApplicationFormCache.containsKey(accData.Id)){
        SEL_ApplicationForm selAppForm = new SEL_ApplicationForm();
            accountApplicationFormCache.put(
                accData.Id,
                selAppForm.selectByAccountId(accData.Id)
            );
        }

        List<ApplicationForm> appForms = accountApplicationFormCache.get(accData.Id);
    
        if(appForms.isEmpty()){
            return null;
        }
    
        Id oppId = appForms[0].OpportunityId;
        Opportunity opp = new SEL_Opportunity().selectById(oppId);
    	return opp != null ? opp.Sales_Code__r.Sales_Code_Country__c : null;
       
    }

    private static ICS_DTO_SAPCreateCustomerRequest.AdditionalData createAdditionalData() {
        ICS_DTO_SAPCreateCustomerRequest.AdditionalData addData = new ICS_DTO_SAPCreateCustomerRequest.AdditionalData();
        addData.CategoryInformation = new ICS_DTO_SAPCreateCustomerRequest.CategoryInformation();
        addData.CategoryInformation.Category = new List<ICS_DTO_SAPCreateCustomerRequest.Category>();
        addData.CategoryInformation.Category.add(createHeaderCategory()); 
 	    if (!isJoint) {
        	addData.CategoryInformation.Category.add(createSecurityQuestionsCategory());
		}
        addData.CategoryInformation.Category.add(createPartyProfileRiskCategory());
        addData.CategoryInformation.Category.add(createPartyProfileRiskCategory1());
        addData.CategoryInformation.Category.add(createPartyProfileRiskCategory3());
        addData.CategoryInformation.Category.add(createPartyProfileRiskCategory4());
        if(checkIsPlatinumOptimum()) {
            addData.CategoryInformation.Category.add(createPartyProfileRiskCategory5());
        }

        if(isJoint == true){
            addData.CategoryInformation.Category.add(createKYCCategory('24'));
        } else {
            addData.CategoryInformation.Category.add(createKYCCategory('22'));
        }

        return addData;
    }
    private static ICS_DTO_SAPCreateCustomerRequest.Category createKYCCategory(string kycValue) {
        ICS_DTO_SAPCreateCustomerRequest.Category securityCat = new ICS_DTO_SAPCreateCustomerRequest.Category();
        securityCat.CategoryItem = 'kyc';
        securityCat.CategoryDetails = new List<ICS_DTO_SAPCreateCustomerRequest.CategoryDetail>();

        Map<String, String> securityQuestions = new Map<String, String>{
            'KYC Jurisdiction' =>'GB',
                'KYC Role' => kycValue,
                'KYC Status' => '1',
                'KYC Verification Date' => string.valueof(date.today()),
                'User Verified' => 'A253297'
                };

                    for(String questionNum : securityQuestions.keySet()) {
                        ICS_DTO_SAPCreateCustomerRequest.CategoryDetail detail = new ICS_DTO_SAPCreateCustomerRequest.CategoryDetail();
                        detail.CategoryType = questionNum;
                        detail.CategoryIdentifierValue = securityQuestions.get(questionNum);
                        securityCat.CategoryDetails.add(detail);
                    }

        return securityCat;
    }
    public static String generateGUID() {
        Blob cryptoBlob = Crypto.generateAesKey(128);
        String hexString = EncodingUtil.convertToHex(cryptoBlob);
        return hexString.substring(0,8) + '-' +
            hexString.substring(8,12) + '-' +
            hexString.substring(12,16) + '-' +
            hexString.substring(16,20) + '-' +
            hexString.substring(20);
    }
    private static ICS_DTO_SAPCreateCustomerRequest.Category createHeaderCategory() {
        ICS_DTO_SAPCreateCustomerRequest.Category headerCat = new ICS_DTO_SAPCreateCustomerRequest.Category();
        headerCat.CategoryItem = 'header';
        headerCat.CategoryDetails = new List<ICS_DTO_SAPCreateCustomerRequest.CategoryDetail>();
        String myGUID = generateGUID();
        Map<String, String> headerDetails = new Map<String, String>{
            'timestamp' => string.valueof(system.now()),
                'correlationID' => myGUID,
                'channelID' => AOBReferencedDataMap.containsKey('channelID') ? AOBReferencedDataMap.get('channelID') : null,
                    'UserID' => AOBReferencedDataMap.containsKey('UserID') ? AOBReferencedDataMap.get('UserID') : null,
                        'referenceID' => AOBReferencedDataMap.containsKey('referenceID') ? AOBReferencedDataMap.get('referenceID') : null,
                            'OriginatingChannel' => AOBReferencedDataMap.containsKey('OriginatingChannel') ? AOBReferencedDataMap.get('OriginatingChannel') : null,
                                'OriginatingProcess' => AOBReferencedDataMap.containsKey('OriginatingProcess') ? AOBReferencedDataMap.get('OriginatingProcess') : null
                                    };

                                        for(String type : headerDetails.keySet()) {
                                            ICS_DTO_SAPCreateCustomerRequest.CategoryDetail detail = new ICS_DTO_SAPCreateCustomerRequest.CategoryDetail();
                                            detail.CategoryType = type;
                                            detail.CategoryIdentifierValue = headerDetails.get(type);
                                            headerCat.CategoryDetails.add(detail);
                                        }
        return headerCat;
    }

    private static ICS_DTO_SAPCreateCustomerRequest.Category createSecurityQuestionsCategory() {
        ICS_DTO_SAPCreateCustomerRequest.Category securityCat = initializeSecurityCategory();

        List<AssessmentQuestionResponse> secResponseInfo = fetchSecurityResponses();
        if (!isValidSecurityResponse(secResponseInfo)) {
            return securityCat;
        }

        Map<String, String> securityQuestions = mapSecurityQuestions(secResponseInfo);
        if (securityQuestions.size() < 4) {
            return new ICS_DTO_SAPCreateCustomerRequest.Category();
        }

        addSecurityQuestionDetails(securityCat, securityQuestions);
        return securityCat;
      }

    private static ICS_DTO_SAPCreateCustomerRequest.Category initializeSecurityCategory() {
        ICS_DTO_SAPCreateCustomerRequest.Category cat = new ICS_DTO_SAPCreateCustomerRequest.Category();
        cat.CategoryItem = 'security-question-answer';
        cat.CategoryDetails = new List<ICS_DTO_SAPCreateCustomerRequest.CategoryDetail>();
        return cat;
    }

    private static List<AssessmentQuestionResponse> fetchSecurityResponses() {
        return new SEL_AssesmentQuestionResponse()
            .selectByAccountIdAndName(accData.id, 'Security Details');
    }

    private static boolean isValidSecurityResponse(List<AssessmentQuestionResponse> responses) {
        return responses != null && responses.size() >= 4;
    }
    
    private static Map<String, String> mapSecurityQuestions(List<AssessmentQuestionResponse> responses) {
        Map<String, String> questionKeyMap = new Map<String, String>{
            'Code word'                  => 'question1',
            'Favourite Colour'           => 'question2',
            'Mother\'s Former Name'      => 'question3',
            'Name of your first School'  => 'question4'
        };
        
        Map<String, String> securityQuestions = new Map<String, String>();
        for (AssessmentQuestionResponse response : responses) {
            String questionText = response.AssessmentQuestion?.QuestionText;
            if (String.isBlank(questionText)) { continue; }
            
            String normalizedText = questionText.replace('\u2018', '\'').replace('\u2019', '\'');
            String questionNum = questionKeyMap.get(normalizedText);
            if (questionNum != null) {
                securityQuestions.put(questionNum, response.ResponseText != null ? response.ResponseText : '');
            }
        }
        return securityQuestions;
    }
    
    private static void addSecurityQuestionDetails(
        ICS_DTO_SAPCreateCustomerRequest.Category securityCat,
        Map<String, String> securityQuestions
    ) {
        for (Integer i = 1; i <= 4; i++) {
            String questionNum = 'question' + i;
            if (securityQuestions.containsKey(questionNum)) {
            ICS_DTO_SAPCreateCustomerRequest.CategoryDetail detail = new ICS_DTO_SAPCreateCustomerRequest.CategoryDetail();
            detail.CategoryType = questionNum;
            detail.CategoryIdentifierValue = securityQuestions.get(questionNum);
            securityCat.CategoryDetails.add(detail);
        	}
        }
    }
    
    private static ICS_DTO_SAPCreateCustomerRequest.Category createPartyProfileRiskCategory5() {
        ICS_DTO_SAPCreateCustomerRequest.Category riskCat = new ICS_DTO_SAPCreateCustomerRequest.Category();
        riskCat.CategoryItem = PARTY_PROFILE_RISK;
        riskCat.CategoryDetails = new List<ICS_DTO_SAPCreateCustomerRequest.CategoryDetail>();

        Map<String, String> riskDetails = new Map<String, String>{
            RATING_START_DATE => String.valueof(date.today()),
                RATING_DATE =>String.valueof(date.today()),
                RATING_ALLOWANCE => 'X',
                GRADE => '140',
                TENDENCY => '++',
                RATING_COMMENT => '',
                GRADE_END_DATE => END_DATE_RISK,
                GRADE_METHOD => 'ZSEG_CODES'
                };
                    for(String type : riskDetails.keySet()) {
                        ICS_DTO_SAPCreateCustomerRequest.CategoryDetail detail = new ICS_DTO_SAPCreateCustomerRequest.CategoryDetail();
                        detail.CategoryType = type;
                        detail.CategoryIdentifierValue = riskDetails.get(type);
                        riskCat.CategoryDetails.add(detail);
                    }

        return riskCat;
    }
    private static ICS_DTO_SAPCreateCustomerRequest.Category createPartyProfileRiskCategory4() {
        ICS_DTO_SAPCreateCustomerRequest.Category riskCat = new ICS_DTO_SAPCreateCustomerRequest.Category();
        riskCat.CategoryItem = PARTY_PROFILE_RISK;
        riskCat.CategoryDetails = new List<ICS_DTO_SAPCreateCustomerRequest.CategoryDetail>();

        Map<String, String> riskDetails = new Map<String, String>{
            RATING_START_DATE => String.valueof(date.today()),
                RATING_DATE =>String.valueof(date.today()),
                RATING_ALLOWANCE => 'X',
                GRADE => '01',
                TENDENCY => '++',
                RATING_COMMENT => '',
                GRADE_END_DATE => END_DATE_RISK,
                GRADE_METHOD => 'ZACC_SEC'
                };

                    for(String type : riskDetails.keySet()) {
                        ICS_DTO_SAPCreateCustomerRequest.CategoryDetail detail = new ICS_DTO_SAPCreateCustomerRequest.CategoryDetail();
                        detail.CategoryType = type;
                        detail.CategoryIdentifierValue = riskDetails.get(type);
                        riskCat.CategoryDetails.add(detail);
                    }

        return riskCat;
    }
    private static ICS_DTO_SAPCreateCustomerRequest.Category createPartyProfileRiskCategory3() {
        ICS_DTO_SAPCreateCustomerRequest.Category riskCat = new ICS_DTO_SAPCreateCustomerRequest.Category();
        riskCat.CategoryItem = PARTY_PROFILE_RISK;
        riskCat.CategoryDetails = new List<ICS_DTO_SAPCreateCustomerRequest.CategoryDetail>();
        SEL_PartyProfile selPartyProfile = new SEL_PartyProfile();
        PartyProfile partyProfileRecord = selPartyProfile.selectByAccountAndRecordType(accData.id,ICS_PARTY_PROFILE);

        SEL_PartyProfileRisk selPartyProfileRisk = new SEL_PartyProfileRisk();

        Set<Id> partyProfileIds = new Set<Id>();
        if (partyProfileRecord != null) {
            partyProfileIds.add(partyProfileRecord.Id);
        }
        List<PartyProfileRisk> selPartyProfileRiskRecords = selPartyProfileRisk.selectByPartyProfileIds(partyProfileIds);
        Map<String, String> riskCategoryToGrade = new Map<String, String>{
            'high' => '09',
            'medium' => '10', 
            'standard' => '11',
                'low'=> '11'
        };
        String gradeValue;
        if (!selPartyProfileRiskRecords.isEmpty()) {
            String riskCategory = selPartyProfileRiskRecords[0].RiskCategory;
            
            if (String.isNotBlank(riskCategory) && riskCategoryToGrade.containsKey(riskCategory.toLowerCase())) {
                gradeValue = riskCategoryToGrade.get(riskCategory.toLowerCase());
            }
        }
            Map<String, String> riskDetails = new Map<String, String>{
                 RATING_START_DATE =>String.valueof(date.today()),
				 RATING_DATE =>String.valueof(date.today()),
                 RATING_ALLOWANCE => 'X',
                 GRADE => gradeValue,
                 TENDENCY => '++',
                 RATING_COMMENT => '',
                 GRADE_END_DATE => END_DATE_RISK,
                 GRADE_METHOD => 'ZCL_RISK_C'
                };

                    for(String type : riskDetails.keySet()) {
                        ICS_DTO_SAPCreateCustomerRequest.CategoryDetail detail = new ICS_DTO_SAPCreateCustomerRequest.CategoryDetail();
                        detail.CategoryType = type;
                        detail.CategoryIdentifierValue = riskDetails.get(type);
                        riskCat.CategoryDetails.add(detail);
                    }

        return riskCat;
    }

    private static ICS_DTO_SAPCreateCustomerRequest.Category createPartyProfileRiskCategory1() {
        ICS_DTO_SAPCreateCustomerRequest.Category riskCat = new ICS_DTO_SAPCreateCustomerRequest.Category();
        riskCat.CategoryItem =PARTY_PROFILE_RISK;
        riskCat.CategoryDetails = new List<ICS_DTO_SAPCreateCustomerRequest.CategoryDetail>();

        Map<String, String> riskDetails = new Map<String, String>{
                RATING_START_DATE=>String.valueof(date.today()),
                RATING_DATE =>String.valueof(date.today()),
                RATING_ALLOWANCE => 'X',
                GRADE => 'DFLT',
                TENDENCY => '++',
                RATING_COMMENT => 'Stay well within your credit limit',
                GRADE_END_DATE => END_DATE_RISK,
                GRADE_METHOD => 'ZCUST_C_GR'
                };
                    for(String type : riskDetails.keySet()) {
                        ICS_DTO_SAPCreateCustomerRequest.CategoryDetail detail = new ICS_DTO_SAPCreateCustomerRequest.CategoryDetail();
                        detail.CategoryType = type;
                        detail.CategoryIdentifierValue = riskDetails.get(type);
                        riskCat.CategoryDetails.add(detail);
                    }

        return riskCat;
    }
    private static ICS_DTO_SAPCreateCustomerRequest.Category createPartyProfileRiskCategory() {
        ICS_DTO_SAPCreateCustomerRequest.Category riskCat = new ICS_DTO_SAPCreateCustomerRequest.Category();
        riskCat.CategoryItem = PARTY_PROFILE_RISK;
        riskCat.CategoryDetails = new List<ICS_DTO_SAPCreateCustomerRequest.CategoryDetail>();

        Map<String, String> riskDetails = new Map<String, String>{
            RATING_START_DATE => String.valueof(date.today()),
                RATING_DATE =>String.valueof(date.today()),
                RATING_ALLOWANCE => 'X',
                GRADE => '01',
                TENDENCY => '++',
                RATING_COMMENT => 'Stay well within your credit limit',
                GRADE_END_DATE => END_DATE_RISK,
                GRADE_METHOD => 'ZREG_CLAS'
                };

                    for(String type : riskDetails.keySet()) {
                        ICS_DTO_SAPCreateCustomerRequest.CategoryDetail detail = new ICS_DTO_SAPCreateCustomerRequest.CategoryDetail();
                        detail.CategoryType = type;
                        detail.CategoryIdentifierValue = riskDetails.get(type);
                        riskCat.CategoryDetails.add(detail);
                    }

        return riskCat;
    }


    public static String generateJSON(string accId) {
        return JSON.serialize(createCustomerRequest(accId,isJoint),true);
    }
    public static ics_customlabel__mdt getCustomMetaData() {
        String developerName = 'Ics_Custom_SAPCreateCustomerData';
        try {
            return [SELECT DeveloperName, Description__c FROM ics_customlabel__mdt WHERE DeveloperName = :developerName LIMIT 1];
        } catch (QueryException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Map < String, String > parseCustomMetadataJson(ics_customlabel__mdt metadata) {
        Map < String, Object > rawMap = (Map < String, Object > ) JSON.deserializeUntyped(metadata.Description__c);
        Map < String, String > stringMap = new Map < String, String > ();
        for (String key: rawMap.keySet()) {
            Object value = rawMap.get(key);
            stringMap.put(key,  String.valueOf(value));
        }
        return stringMap;
    }
}