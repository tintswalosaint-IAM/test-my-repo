/**
 * @description Allows to get portal user data
 * @author Alexandr Goryachko
 * @date 2025-02-06
 * SFP-55622
 */
public without sharing class INS_SRV_PortalData {
    private static final sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('INS_SRV_PortalData');
    private INS_SRV_PortalData() {}

    /**
     * @description get user address details
     * @param userId 
     * @return `Map<String, Object>` response with data
     */    
    public static Map<String, Object> getAddressDetails(String userId) {
        Map<String, Object> result = new Map<String, Object>();
        User user = new SEL_User().selectUserById(userId);
        if (user.ContactId == null) {
            return result;
        }
        List<PartyProfile> pp = new SEL_PartyProfile()
            .selectByAccountId(user.Contact.AccountId);
        List<PartyProfileAddress> ppa = new SEL_PartyProfileAddress()
            .selectByPartyProfileIds((new Map<Id, PartyProfile>(pp)).keySet());
        Map<String, String> countryByCode = getPicklistValueLabelMap(Schema.PartyProfile.WI_CountryOfCitizenship__c);
        result = new Map<String, Object>{
            'pp' => pp.isEmpty() ? null : pp[0],
            'residence' => pp.isEmpty() ? null : countryByCode.get(pp[0].WI_IdentificationDocumentIssuingCountry__c),
            'citizen' => pp.isEmpty() ? null : countryByCode.get(pp[0].WI_CountryOfCitizenship__c),
            'secondCitizen' => pp.isEmpty() ? null : countryByCode.get(pp[0].Second_Country_of_Nationality__c),
            'ppa' => ppa.isEmpty() ? null : ppa[0]
        };
        return result;
    }

    /**
     * @description get user employment details
     * @param userId 
     * @return `Map<String, Object>` response with data
     */    
    public static Map<String, Object> getEmploymentDetails(String userId) {
        Map<String, Object> result = new Map<String, Object>();
        User user = new SEL_User().selectUserById(userId);
        if (user.ContactId == null) {
            return result;
        }
        List<PartyProfile> pp = new SEL_PartyProfile()
            .selectByAccountId(user.Contact.AccountId);
        Account acc = new SEL_Account()
            .selectById(user.Contact.AccountId);
        Map<String, String> businessByValue = getPicklistValueLabelMap(Schema.Account.NatureofBusiness__c);
        result = new Map<String, Object>{
            'pp' => pp.isEmpty() ? null : pp[0],
            'acc' => acc,
            'business' => acc == null ? null : businessByValue.get(acc.NatureofBusiness__c)
        };
        return result;
    }

    /**
     * @description get user account details
     * @param userId 
     * @return `Map<String, Object>` response with data
     */    
    public static Map<String, Object> getAccountDetails(String userId) {
        Map<String, Object> result = new Map<String, Object>();
        User user = new SEL_User().selectUserById(userId);
        if (user.ContactId == null) {
            return result;
        }
        Account acc = new SEL_Account()
            .selectById(user.Contact.AccountId);
        result = new Map<String, Object>{
            'acc' => acc
        };
        return result;
    }

    /**
     * @description gets picklist map
     * @param field 
     * @return `Map<String, String>` label by name
     */
    public static Map<String, String> getPicklistValueLabelMap(Schema.sObjectField field) {
        Map<String, String> valueLabelMap = new Map<String, String>();
        List<Schema.PicklistEntry> pickListValues = field.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : pickListValues) {
            valueLabelMap.put(entry.getValue(), entry.getLabel());
        }
        return valueLabelMap;
    }

    /**
     * @description Get tax details for the logged in user
     * @author Vershley Joyejob
     * @date 15-10-2025
     * @return List<TaxDetails__c> List of tax details for the user
     */
    @AuraEnabled(cacheable=true)
    public static List<TaxDetails__c> getTaxDetailsForLoggedInUser() {
        List<TaxDetails__c> taxList = new List<TaxDetails__c>();
        try {
            User currentUser = new SEL_User().selectUserById(UserInfo.getUserId());  
            if (currentUser.ContactId == null) {
                return taxList;
            }
            taxList = new SEL_TaxDetails().selectByAccountIds(new Set<Id>{currentUser.Contact.AccountId});
        } catch(Exception e) {
            logger.error(e.getMessage(), new String[]{'INS_SRV_PortalData.getTaxDetailsForLoggedInUser', e.getMessage()}, e);
            throw new AuraHandledException('Failed to get tax details: ' + e.getMessage());
        }
        return taxList;
    }
}