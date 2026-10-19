/**
 * @description Selector class for Sales_Codes__c object.
 * This class provides methods to retrieve Sales_Codes__c records.
 * @author Ofentse Sacha
 * @date 02 November 2023
 * Modification Description : SFP-30363, This class provides methods to retrieve Sales_Codes__c records SBO UK
 */
public inherited sharing class SEL_Sales_Code extends sbgplatform.fflib_SObjectSelector {
      private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(ICS_Constants.ICS_CTRL_PreAppFormCreator);
    
    private static Set<String> fields=new Set<String>{'Name','Id','Sales_Code_Country__c', 'CurrencyIsoCode','Sales_Code_Province__c'};

   

    /**
     * @description Retrieves the SObjectType for Sales_Codes__c.
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return Sales_Codes__c.SObjectType;
    }

    /**
     * @description Retrieves the list of SObjectFields for Sales_Codes__c.
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return Sales_Codes__c.SObjectType.getDescribe().fields.getMap().values();
    }
	/**
     * @description Retrieves a list of Sales_Codes__c records associated with a given Sales_Codes__c Name and Country.
     * @param salesCodeName
     * @param salesCodeCountry
     * @return List<Sales_Codes__c>
     */
    public List<Sales_Codes__c> selectByNameAndSalesCodeCountry(String salesCodeName,string salesCodeCountry) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.selectFields(fields);  
        fieldQueryFactory.setCondition('Name = :salesCodeName and Sales_Code_Country__c =: salesCodeCountry');
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return (List<Sales_Codes__c>) Database.query(query);
    }
    
    public List<Sales_Codes__c> selectByName(String salescode){
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setCondition('Name =:salescode');
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return (List<Sales_Codes__c>) Database.query(query);
    }
  
    /**
     * @description Retrieves a list of Sales_Codes__c records associated with a given Sales_Codes__c ID.
     * @param salesCodeCountry
     * @param salesCodeProvince
     * @param salesCodeSubRegion
     * @return List<Sales_Codes__c>
     */
      public List<Sales_Codes__c> selectByCountryRegion(String salesCodeCountry, String salesCodeProvince, String salesCodeSubRegion) {
    sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.selectFields(fields);  
    
    // Determine if this is a direct journey
    Boolean isDirectJourney = true;
    
    // Erik & Oscar's codes that should be excluded for direct journeys in African countries
    Set<String> africaStaffCodes = getCustomLabelAsset('africa_staff_codes');
    
    // Kay, Kevin & Ronaldo's codes that should be excluded for direct journeys in SA with province/region
      Set<String> saStaffCodes = getCustomLabelAsset('sa_staff_codes');
    
    if(salesCodeCountry == 'ZA') {
        // Base condition for South Africa
        fieldQueryFactory.setCondition('Sales_Code_Country__c = :salesCodeCountry');
        
        // Add province and subregion if provided
        if(String.isNotBlank(salesCodeProvince) || String.isNotBlank(salesCodeSubRegion)) {
            String additionalCondition = '';
            if(String.isNotBlank(salesCodeProvince)) {
                additionalCondition += ' AND Sales_Code_Province__c = :salesCodeProvince';
            }
            if(String.isNotBlank(salesCodeSubRegion)) {
                additionalCondition += ' AND Sales_Code_Sub_Region__c = :salesCodeSubRegion';
            }
            fieldQueryFactory.setCondition(fieldQueryFactory.getCondition() + additionalCondition);
            
            // For direct journeys with province/subregion, exclude Kay, Kevin & Ronaldo's codes
            if (isDirectJourney) {
                fieldQueryFactory.setCondition(fieldQueryFactory.getCondition() + ' AND Name NOT IN :saStaffCodes');
            }
        }
    } else if (isAfricanCountry(salesCodeCountry)) {
        fieldQueryFactory.setCondition('Sales_Code_Country__c = :salesCodeCountry');
        
        // For direct journeys in African countries, exclude Erik & Oscar's codes
        if (isDirectJourney) {
            fieldQueryFactory.setCondition(fieldQueryFactory.getCondition() + ' AND Name NOT IN :africaStaffCodes');
        }
    } else {
        fieldQueryFactory.setCondition('Sales_Code_Country__c = :salesCodeCountry');
    }
    
    String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
    return (List<Sales_Codes__c>) Database.query(query);
}
    
    /**
     * @description Checks if a country is in the African countries list
     * @param countryCode
     * @return Boolean
     */
private Boolean isAfricanCountry(String countryCode) {
   
        // Get the same African countries list from custom label that's used in ICS_CTRL_PreAppFormCreator
        ics_customlabel__mdt labelData = [SELECT Description__c FROM ics_customlabel__mdt 
                                         WHERE DeveloperName = 'Preapplication' LIMIT 1];
        
        Map<string, string> labelInfo = (Map<string, string>)JSON.deserialize(
            labelData.Description__c, Map<string, string>.class);
        
        if (labelInfo.containsKey('ics_african_countries')) {
            Set<String> africanCountries = new Set<String>(
                labelInfo.get('ics_african_countries').split(',')
            );
            return africanCountries.contains(countryCode);
        }
        return false;
   
}    
    /**
 * @description Converts a comma-separated custom label value to a Set<String>
 * @param developerName The developer name of the custom label
 * @return Set<String> The set of values
 */
private Set<String> getCustomLabelAsset(String developerName) {
    Set<String> result = new Set<String>();
  
        List<ics_customlabel__mdt> labels = [
            SELECT Description__c FROM ics_customlabel__mdt 
            WHERE DeveloperName = :developerName LIMIT 1
        ];
        
        if (!labels.isEmpty() && String.isNotBlank(labels[0].Description__c)) {
            // Split the comma-separated values and add to the set
            for (String value : labels[0].Description__c.split(',')) {
                result.add(value.trim());
            }
        }
   
    return result;
}
  
    /**
     * @description Retrieves a list of Sales_Codes__c records associated with a given Sales_Codes__c ID.
     * @param salesCodeId
     * @return List<Sales_Codes__c>
     */
    public List<Sales_Codes__c> selectById(String salesCodeId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.selectFields(fields);  
        fieldQueryFactory.setCondition('Id = :salesCodeId');
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return (List<Sales_Codes__c>) Database.query(query);
    }
}