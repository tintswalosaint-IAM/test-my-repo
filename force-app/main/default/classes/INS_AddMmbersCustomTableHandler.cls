/**
* @description  : Get Picklist Values Custom Fields Dynamically
* @author Shamsul Arifeen
*/
public with sharing class INS_AddMmbersCustomTableHandler {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_AddMmbersCustomTableHandler');

    /**
     * @description class PicklistOption
     *
     * @return.
     */
    public class PicklistOption {
        
        /** 
        * @description label for the picklist
        */
		@AuraEnabled
        public String label { get; set; }
        
        /**
        * @description value for the picklist
        */		
		@AuraEnabled	
        public String value { get; set; }
        
        /**
        * @description Picklist wrapper to return
        */
        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    /**
	* @description  : Get Picklist Values Custom Fields Dynamically
	* @author Shamsul Arifeen
	* @param objectName
    * @param genderFieldName
    * @param relationshipFieldName
    * @param titleFieldName
	* @return Map<String,List<PicklistOption>>
	*/
    @AuraEnabled(cacheable=true)
    public static Map<String, List<PicklistOption>> getPicklistValues(String objectName, String genderFieldName, String relationshipFieldName, String titleFieldName) {
        try{
            Map<String, List<PicklistOption>> picklistData = new Map<String, List<PicklistOption>>();
            
            // Get the picklist values for the Gender field
            Schema.DescribeFieldResult genderFieldDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(genderFieldName).getDescribe();
            List<PicklistOption> genderOptions = new List<PicklistOption>();
            
            for (Schema.PicklistEntry entry : genderFieldDescribe.getPicklistValues()) {
                genderOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
            
            // Get the picklist values for the Relationship field
            Schema.DescribeFieldResult relationshipFieldDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(relationshipFieldName).getDescribe();
            List<PicklistOption> relationshipOptions = new List<PicklistOption>();
            
            for (Schema.PicklistEntry entry : relationshipFieldDescribe.getPicklistValues()) {
                relationshipOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
            
            // Get the picklist values for the Title field
            Schema.DescribeFieldResult titleFieldDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(titleFieldName).getDescribe();
            List<PicklistOption> titleOptions = new List<PicklistOption>();
            
            for (Schema.PicklistEntry entry : titleFieldDescribe.getPicklistValues()) {
                titleOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
            
            // Put the picklist options into the map with field names as keys
            picklistData.put(genderFieldName, genderOptions);
            picklistData.put(relationshipFieldName, relationshipOptions);
            picklistData.put(titleFieldName, titleOptions);
            
            return picklistData;
        } catch (Exception ex){
            LOGGER.error('INS_AddMmbersCustomTableHandler.getPicklistValues', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
	* @description  : processPayload
	* @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
	* @param jsonString
	* @param relation
	* @param childage
	* @return Response
	*/
    //added 25.10.2023
    @AuraEnabled
    public static Response processPayload(String jsonString,String relation,Integer childage){

        try{
            NewProductWrapper wrapper = (NewProductWrapper) JSON.deserialize( jsonString, NewProductWrapper.class);//use this to fetch value from response
            List<String> parentRelations = new List<String>{'mother', 'parent', 'father', 'fatherinlaw', 'motherinlaw'};
            List<String> childRelations = new List<String>{'son', 'daughter', 'child', 'grandchild'};
            List<String> spouseRelations = new List<String>{'spouse'};

            String tempRelation;
            String relationLowerCase =  (!Test.isRunningTest() ? relation.toLowerCase() : relation.toLowerCase());

            if (parentRelations.contains(relationLowerCase)) {
                tempRelation = 'Parent';
            } else if (childRelations.contains(relationLowerCase)) {
                tempRelation = 'Child';
            } else if (spouseRelations.contains(relationLowerCase)) {
                tempRelation = 'Spouse';
            } else {
                tempRelation = 'ExtendedFamily';
            }

            Response responses = new Response();
            for(NewProductWrapper.ProductSections sectionWrap: wrapper.sections){
                if(sectionWrap.Name.toLowerCase()==tempRelation.toLowerCase()){
                    if(sectionWrap.Name.toLowerCase() =='child'){
                        for(NewProductWrapper.ProductItems prodItemWrap : sectionWrap.productItems){
                            if(prodItemWrap.description !=null){
                                List<Integer> ageList = getAgeList(prodItemWrap.description);
                                if(ageList.size() > 0 && ageList.contains(childage)){
                                    for(NewProductWrapper.ChildItems childItemWrap : prodItemWrap.childItems){
                                        switch on childItemWrap.name.deleteWhitespace() {
                                            when 'CateringBenefit' {
                                                responses.cateringMaxVal = childItemWrap.maxValue;
                                                responses.cateringMinVal = childItemWrap.minValue;	
                                            }
                                            when 'TombstoneBenefit' {
                                                responses.tombstoneMaxVal = childItemWrap.maxValue;
                                                responses.tombstoneMinVal = childItemWrap.minValue;	
                                            }
                                            when 'ShoppingBenefit' {
                                                responses.shoppingMaxVal = childItemWrap.maxValue;
                                                responses.shoppingMinVal = childItemWrap.minValue;	
                                            }
                                            when 'Transport', 'Repatriation' {
                                                responses.transportMaxVal = childItemWrap.maxValue;
                                                responses.transportMinVal = childItemWrap.minValue;	
                                            }
                                            when 'RadioAnnouncement', 'Airtime' {
                                                responses.radioMaxVal = childItemWrap.maxValue;
                                                responses.radioMinVal = childItemWrap.minValue;	
                                            }
                                            when 'FuneralBenefit' {
                                                responses.funeralMaxVal = childItemWrap.maxValue;
                                                responses.funeralMinVal = childItemWrap.minValue;    
                                            }
                                        }
                                    }    
                                }    
                            }    
                        }    
                    }
                    else{
                        for(NewProductWrapper.ProductItems prodItemWrap : sectionWrap.productItems){
                            for(NewProductWrapper.ChildItems childItemWrap : prodItemWrap.childItems){
                                switch on childItemWrap.name.deleteWhitespace() {
                                    when 'CateringBenefit' {
                                        responses.cateringMaxVal = childItemWrap.maxValue;
                                        responses.cateringMinVal = childItemWrap.minValue;	
                                    }
                                    when 'TombstoneBenefit' {
                                        responses.tombstoneMaxVal = childItemWrap.maxValue;
                                        responses.tombstoneMinVal = childItemWrap.minValue;	
                                    }
                                    when 'ShoppingBenefit', 'GroceryBenefit' {
                                        responses.shoppingMaxVal = childItemWrap.maxValue;
                                        responses.shoppingMinVal = childItemWrap.minValue;	
                                    }
                                    when 'Transport', 'RepatriationBenefit' {
                                        responses.transportMaxVal = childItemWrap.maxValue;
                                        responses.transportMinVal = childItemWrap.minValue;	
                                    }
                                    when 'RadioAnnouncement', 'AirtimeBenefit' {
                                        responses.radioMaxVal = childItemWrap.maxValue;
                                        responses.radioMinVal = childItemWrap.minValue;	
                                    }
                                    when 'FuneralBenefit' {
                                        responses.funeralMaxVal = childItemWrap.maxValue;
                                        responses.funeralMinVal = childItemWrap.minValue;    
                                    }
                                }
                            }
                        }    
                    }
                    
                }
            }
            return responses;
        } catch (Exception ex){
            LOGGER.error('INS_AddMmbersCustomTableHandler.processPayload', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
     * @description class Response
     */
    //added 25.10.2023
    public class Response{
        
        @AuraEnabled public Integer cateringMaxVal;
        @AuraEnabled public Integer cateringMinVal;
        @AuraEnabled public Integer shoppingMaxVal;
        @AuraEnabled public Integer shoppingMinVal;
        @AuraEnabled public Integer tombstoneMaxVal;
        @AuraEnabled public Integer tombstoneMinVal;
        @AuraEnabled public Integer transportMaxVal;
        @AuraEnabled public Integer transportMinVal;
        @AuraEnabled public Integer radioMaxVal;
        @AuraEnabled public Integer radioMinVal;
        @AuraEnabled public Integer funeralMaxVal;
        @AuraEnabled public Integer funeralMinVal;
    }
    /**
	* @description  : getAgeList
	* @author Shamsul Arifeen
	* @param ageDesc
	* @return List<Integer>
	*/
    public static List<Integer> getAgeList(String ageDesc) {
        // Check if the input is valid and starts with "Child "
        if (String.isBlank(ageDesc) || !ageDesc.startsWith('Child ')) {
            return null;
        }
        
        // Extract the part of the string after "Child "
        String ageRangePart = ageDesc.substringAfter('Child ');
        
        // Split the extracted part to get the age range
        String[] ageRange = ageRangePart.split('-');
        
        if (ageRange.size() != 2) {
            return null; // Invalid format
        }
        
        Integer minAge = Integer.valueOf(ageRange[0]);
        Integer maxAge = Integer.valueOf(ageRange[1]);
        // Generate the list of ages based on the range
        List<Integer> ageList = new List<Integer>();
        for (Integer i = minAge; i <= maxAge; i++) {
            ageList.add(i);
        }
        return ageList;
    }
    
    /**
	* @description  : getUserDetails
	* @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
	* @return User
	*/
    @AuraEnabled
    public static User getUserDetails(){
        try{
            return [select Id,User_Country__c, CompanyName from User where id=:userinfo.getuserid()]; 
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        } 
    }
    
    
}