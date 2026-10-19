/*************************************************************
 * @description SFP-32986 Class used to send relation data
 *
 * @autor Ridhima
 *
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By  Ridhima
 * Last Modified Date 21/10/2024
 * Last Modified Description: Initial Version
 * @Last Modified By 		: Ikyatha Naidu
* @Last Modified On 		: 26-02-2025
* @Modification description : SFP-55521 updated for join account
***************************************************************************************
 */
public without sharing class ICS_API_SAPCreateRelation {
    private static final String END_DATE = '9999-12-31';
    Public  List<String> SBO_IOM_ROLES ; 
    Public  List<String> SBO_AR_SA_ROLES;
    Public  boolean isJoint;
    public String   accountId;
    Public Map<String, String> parsedData;

    public String jsonRequest { get; private set; }
	public String opportunityId;

    public ICS_API_SAPCreateRelation(String accId,boolean isJointInfo) {
          isJoint = isJointInfo; 
		SBO_IOM_ROLES = new List<String>(); 
        SBO_AR_SA_ROLES = new List<String>();
        this.accountId = accId;
        ics_customlabel__mdt customMetaData = getCustomMetaData();
        this.parsedData = parseCustomMetadataJson(customMetaData);
        
        this.jsonRequest = generateJsonRequest();
    }


    private ics_customlabel__mdt getCustomMetaData() {
        if (!ics_customlabel__mdt.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Insufficient permissions to access ics_customlabel__mdt');
        }
        try {
            return [SELECT DeveloperName, Description__c FROM ics_customlabel__mdt WHERE DeveloperName = 'Ics_Custom_SAPCreateRelationData' LIMIT 1];
        } catch (QueryException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private String generateJsonRequest() {
        SBO_AR_SA_ROLES= parsedData.get('ics_Roles').split(',');
        SBO_IOM_ROLES = parsedData.get('ics_iomRoles').split(',');
        ICS_DTO_SAP_CreateRelationRequest request = new ICS_DTO_SAP_CreateRelationRequest();
        request.Party = new List<ICS_DTO_SAP_CreateRelationRequest.Party>();

        ICS_DTO_SAP_CreateRelationRequest.Party party = new ICS_DTO_SAP_CreateRelationRequest.Party();
        party.PartyReference = createPartyReference();
        party.Associations = createAssociations();
        party.AdditionalData = createAdditionalData();

        request.Party.add(party);

        return JSON.serialize(request, true);
    }
	/**
     * @description To fetch Bp id
     * @param accId accountId
     * @return  this returns Bp id
     */
    private String fetchBpId(String accId) {
        String bpId = null;
        SEL_Account selectorAccount = new SEL_Account();
        Account  accData = selectorAccount.selectById(accId);
        bpId = accData.ExternalCIFId__c	;

        return bpId;
    }
    private ICS_DTO_SAP_CreateRelationRequest.PartyReference createPartyReference() {
      
       
        
        ICS_DTO_SAP_CreateRelationRequest.PartyReference partyRef = new ICS_DTO_SAP_CreateRelationRequest.PartyReference();
        partyRef.PartyIdentification = new List<ICS_DTO_SAP_CreateRelationRequest.PartyIdentification>();
		
          String bpId = fetchBpId(accountId);
        
       
			 Opportunity opp = queryOpportunity();
        	List<Applicationform> formList =[select id from ApplicationForm where opportunityId=:opp.id ];
        // Partner Number 2
        sel_Applicant selectorApplicant = new sel_Applicant();
        List<Applicant>applicantInfo = selectorApplicant.selectPrimaryApplicantByOppIds(new List<ID>{opp.id});
        if(formList.size()>1){	
            
        ICS_DTO_SAP_CreateRelationRequest.PartyIdentification partnerNumber1 = new ICS_DTO_SAP_CreateRelationRequest.PartyIdentification();
        partnerNumber1.PartyIdentificationType = 'partnerNumber2';
        partnerNumber1.PartyIdentification = new ICS_DTO_SAP_CreateRelationRequest.PartyIdentificationDetail();
        partnerNumber1.PartyIdentification.IdentifierValue = new ICS_DTO_SAP_CreateRelationRequest.IdentifierValue();
        partnerNumber1.PartyIdentification.IdentifierValue.Value =applicantInfo[0].partyprofile.AccountId;
        partyRef.PartyIdentification.add(partnerNumber1);
            if(isJoint){
                 ICS_DTO_SAP_CreateRelationRequest.PartyIdentification partnerNumber2 = new ICS_DTO_SAP_CreateRelationRequest.PartyIdentification();
            partnerNumber2.PartyIdentificationType = 'partnerNumber1';
            partnerNumber2.PartyIdentification = new ICS_DTO_SAP_CreateRelationRequest.PartyIdentificationDetail();
            partnerNumber2.PartyIdentification.IdentifierValue = new ICS_DTO_SAP_CreateRelationRequest.IdentifierValue();
            partnerNumber2.PartyIdentification.IdentifierValue.Value = opp.RM_AE_Code__c;
            partyRef.PartyIdentification.add(partnerNumber2);
            } else{
            ICS_DTO_SAP_CreateRelationRequest.PartyIdentification partnerNumber2 = new ICS_DTO_SAP_CreateRelationRequest.PartyIdentification();
            partnerNumber2.PartyIdentificationType = 'partnerNumber1';
            partnerNumber2.PartyIdentification = new ICS_DTO_SAP_CreateRelationRequest.PartyIdentificationDetail();
            partnerNumber2.PartyIdentification.IdentifierValue = new ICS_DTO_SAP_CreateRelationRequest.IdentifierValue();
            partnerNumber2.PartyIdentification.IdentifierValue.Value = bpId;
            partyRef.PartyIdentification.add(partnerNumber2);
            }
        }else{
              ICS_DTO_SAP_CreateRelationRequest.PartyIdentification partnerNumber1 = new ICS_DTO_SAP_CreateRelationRequest.PartyIdentification();
        partnerNumber1.PartyIdentificationType = 'partnerNumber2';
        partnerNumber1.PartyIdentification = new ICS_DTO_SAP_CreateRelationRequest.PartyIdentificationDetail();
        partnerNumber1.PartyIdentification.IdentifierValue = new ICS_DTO_SAP_CreateRelationRequest.IdentifierValue();
        partnerNumber1.PartyIdentification.IdentifierValue.Value =bpId;
        partyRef.PartyIdentification.add(partnerNumber1);
        
            ICS_DTO_SAP_CreateRelationRequest.PartyIdentification partnerNumber2 = new ICS_DTO_SAP_CreateRelationRequest.PartyIdentification();
            partnerNumber2.PartyIdentificationType = 'partnerNumber1';
            partnerNumber2.PartyIdentification = new ICS_DTO_SAP_CreateRelationRequest.PartyIdentificationDetail();
            partnerNumber2.PartyIdentification.IdentifierValue = new ICS_DTO_SAP_CreateRelationRequest.IdentifierValue();
            partnerNumber2.PartyIdentification.IdentifierValue.Value =opp.RM_AE_Code__c;
            partyRef.PartyIdentification.add(partnerNumber2);
        }

        return partyRef;
    }

    public ICS_DTO_SAP_CreateRelationRequest.Associations createAssociations() {
        ICS_DTO_SAP_CreateRelationRequest.Associations associations = new ICS_DTO_SAP_CreateRelationRequest.Associations();
        associations.PartyRelationship = new List<ICS_DTO_SAP_CreateRelationRequest.PartyRelationship>();
        
        Opportunity opp = queryOpportunity();
        String userRole = opp.owner?.UserRole?.Name;
        
        // Add relationships based on conditions
       
       if (hasMultipleApplicationForms(opp.Id) && !isJoint) {
             associations.PartyRelationship.add(addRelationship('ics_category_Joint'));
        }else{
            if (isIOMRole(userRole)) {
                associations.PartyRelationship.add(addRelationship('ics_category_OM'));
            }
            if (isARSARole(userRole)) {
                associations.PartyRelationship.add(addRelationship('ics_category_3rdParty'));
            }
        }
        
        return associations;
    }
    
    
    private Opportunity queryOpportunity() {
        sel_applicationform appSelector = new sel_applicationform();
        List<Applicationform> formDataList = appSelector.selectByAccountId(accountId);
        Opportunity oppData = new Opportunity();
        if(formDataList.size()>0){
            oppData=[select id ,owner.UserRole.Name,RM_AE_Code__c from opportunity where id=: formDataList[0].opportunityId];
        }
        
        return oppData;
    }
    
    private Boolean hasMultipleApplicationForms(Id opportunityId) {
        SEL_ApplicationForm applicationFormSelector = new SEL_ApplicationForm();
        List<ApplicationForm> formList = applicationFormSelector.selectByOpportunityId(opportunityId);
        return formList.size() > 1;
    }
    
    private  ICS_DTO_SAP_CreateRelationRequest.PartyRelationship addRelationship(String relationshipCategory) {
          ICS_DTO_SAP_CreateRelationRequest.PartyRelationship relationship = 
                    new ICS_DTO_SAP_CreateRelationRequest.PartyRelationship();
                    
                relationship.PartyPartyRelationshipType = '';
                relationship.PartyPartyRelationshipValues = parsedData.get(relationshipCategory);
                relationship.PartyRelationshipStartDate = String.valueOf(Date.today());
                relationship.PartyRelationshipEndDate = END_DATE;
                
                
                return relationship;
    }
    
    private Boolean isIOMRole(String roleName) {
        return SBO_IOM_ROLES.contains(roleName);
    }
    
    private Boolean isARSARole(String roleName) {
        return SBO_AR_SA_ROLES.contains(roleName);
    }
    public static String generateGUID() {
    Blob cryptoBlob = Crypto.generateAesKey(128);
    String hexString = EncodingUtil.convertToHex(cryptoBlob);
    String guid = hexString.substring(0,8) + '-' +
                 hexString.substring(8,12) + '-' +
                 hexString.substring(12,16) + '-' +
                 hexString.substring(16,20) + '-' +
                 hexString.substring(20);
    return guid;
}
	/**
     * @description To create additional data
     * @return  ICS_DTO_SAPCreateCYTRequest
     */
    private ICS_DTO_SAP_CreateRelationRequest.AdditionalData createAdditionalData() {
        ICS_DTO_SAP_CreateRelationRequest.AdditionalData addData = new ICS_DTO_SAP_CreateRelationRequest.AdditionalData();
        addData.CategoryInformation = new ICS_DTO_SAP_CreateRelationRequest.CategoryInformation();
        addData.CategoryInformation.Category = new List < ICS_DTO_SAP_CreateRelationRequest.Category > ();

        ICS_DTO_SAP_CreateRelationRequest.Category category = new ICS_DTO_SAP_CreateRelationRequest.Category();
        category.CategoryItem = parsedData.get('ics_category_CategoryItem');
        category.CategoryDetails = new List < ICS_DTO_SAP_CreateRelationRequest.CategoryDetail > ();
		string guid = generateGUID();
        Map < String, String > categoryDetails = new Map < String, String > {
            'timestamp' => DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'),
            'correlationID' => guid,
            'channelID' => parsedData.get('ics_category_channelID'),
            'UserID' => parsedData.get('ics_category_UserID'),
            'referenceID' => parsedData.get('ics_category_referenceID'),
            'OriginatingChannel' => parsedData.get('ics_category_OriginatingChannel'),
            'OriginatingProcess' => parsedData.get('ics_category_OriginatingProcess')
        };

        for (String key: categoryDetails.keySet()) {
            ICS_DTO_SAP_CreateRelationRequest.CategoryDetail detail = new ICS_DTO_SAP_CreateRelationRequest.CategoryDetail();
            detail.CategoryType = key;
            detail.CategoryIdentifierValue = categoryDetails.get(key);
            category.CategoryDetails.add(detail);
        }

        addData.CategoryInformation.Category.add(category);
        return addData;
    }


    private Map<String, String> parseCustomMetadataJson(ics_customlabel__mdt metadata) {
        Map<String, Object> rawMap = (Map<String, Object>) JSON.deserializeUntyped(metadata.Description__c);
        Map<String, String> stringMap = new Map<String, String>();

        for (String key : rawMap.keySet()) {
            Object value = rawMap.get(key);
            stringMap.put(key, String.valueOf(value));
        }

        return stringMap;
    }
}