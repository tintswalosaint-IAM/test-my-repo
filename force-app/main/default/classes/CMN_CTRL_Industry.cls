/**
 * @description       : Controller class for managing and exposing Industry & Sub-Industry data in grouped format.
 * @author            : Ramya Gurram
 * @group             : 
 * @last modified on  : 09-12-2025
 * @last modified by  : Ramya Gurram
**/
public with sharing class CMN_CTRL_Industry {
    
    // Map to hold main industry and its list of sub-industries
    public Map<String, List<SubIndustryWrapper>> mainIndustryToSubIndustries { get; private set; }

    // Map to hold main industry and a sample record for details like Risk Rating, Id, etc.
    public Map<String, CMN_Industry__c> mainIndustryToRecord { get; private set; }

    /**
     * @description Wrapper class to represent sub-industry data
     */
    public class SubIndustryWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String riskRating { get; set; }

        public SubIndustryWrapper(String id, String value, String riskRating) {
            this.id = id;
            this.value = value;
            this.riskRating = riskRating;
        }
    }

    /**
     * @description Constructor initializes the maps
     */
    public CMN_CTRL_Industry() {
        this.mainIndustryToSubIndustries = new Map<String, List<SubIndustryWrapper>>();
        this.mainIndustryToRecord = new Map<String, CMN_Industry__c>();
    }

    /**
     * @description Loads industry data grouped by main industry and sub-industries using the selector.
     *              Populates maps to be used in LWC or JSON responses.
     */
    public void loadGroupedIndustryData() {
        SEL_Industry selectorIndustry = new SEL_Industry();
        List<CMN_Industry__c> industryRecords = selectorIndustry.selectByRecordType(true, 'SBO');
        
        mainIndustryToSubIndustries.clear();
        mainIndustryToRecord.clear();

        for (CMN_Industry__c record : industryRecords) {
            String mainIndustry = record.CMN_MainIndustry__c;

            if (!mainIndustryToSubIndustries.containsKey(mainIndustry)) {
                mainIndustryToSubIndustries.put(mainIndustry, new List<SubIndustryWrapper>());
                mainIndustryToRecord.put(mainIndustry, record);
            }

            if (record.CMN_SubIndustry__c != null) {
                List<SubIndustryWrapper> subList = mainIndustryToSubIndustries.get(mainIndustry);

                Boolean alreadyExists = false;
                for (SubIndustryWrapper wrapper : subList) {
                    if (wrapper.value == record.CMN_SubIndustry__c) {
                        alreadyExists = true;
                        break;
                    }
                }

                if (!alreadyExists) {
                    subList.add(new SubIndustryWrapper(
                        record.Id,
                        record.CMN_SubIndustry__c,
                        record.CMN_RiskRating__c
                    ));
                }

            }
        }
    }

    /**
     * @description Returns list of sub-industries for a given main industry
     * @param mainIndustry The main industry name
     * @return List of SubIndustryWrapper objects for the specified main industry
     */
    public List<SubIndustryWrapper> getSubIndustriesForMain(String mainIndustry) {
        if (mainIndustryToSubIndustries.isEmpty()) {
            loadGroupedIndustryData();
        }
        return mainIndustryToSubIndustries.get(mainIndustry);
    }

    /**
     * @description Returns grouped industry and sub-industry data in JSON format
     *              Useful for LWC usage where JSON structure is easy to consume.
     * @return JSON string representing main industries with their sub-industries and metadata
     */
    public String getGroupedDataAsJSON() {
        if (mainIndustryToSubIndustries.isEmpty()) {
            loadGroupedIndustryData();
        }

        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for (String mainIndustry : mainIndustryToSubIndustries.keySet()) {
            Map<String, Object> industryData = new Map<String, Object>();
            CMN_Industry__c sampleRecord = mainIndustryToRecord.get(mainIndustry);

            industryData.put('mainIndustry', mainIndustry);
            industryData.put('riskRating', sampleRecord.CMN_RiskRating__c);
            industryData.put('Id', sampleRecord.Id);
            industryData.put('subIndustries', mainIndustryToSubIndustries.get(mainIndustry));
            industryData.put('subIndustryCount', mainIndustryToSubIndustries.get(mainIndustry).size());

            result.add(industryData);
        }

        return JSON.serializePretty(result);
    }

    /**
     * @description Fetches industry record(s) for a given Id.
     *              Used when looking up industry name by record Id.
     * @param Id The Id of the industry record (could be sub or main industry)
     * @return List of CMN_Industry__c records matching the Id
     */
    public List<CMN_Industry__c> getIndustryPicklistWithId(String recId) {
        set<string> idSet = new set<string>();
        idSet.add(recId);
        SEL_Industry selectorIndustry = new SEL_Industry();
        return selectorIndustry.selectByRecordTypeIds(true, 'SBO', idSet);
    }
}