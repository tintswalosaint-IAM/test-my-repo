/**
 * @description  getting information from INS_Branches__mdt using class SEL_INSBranches.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param.
 * @return.
 * @date Nov 28th 2024
 * 
 * @description : Add inherited sharing declaration as per AppOmni finding
 * @story       : SFP-60091
 * @modified    : Jaco de Lange
 * @date        : 16 September 2026
 */
public inherited sharing class SEL_INSBranches extends sbgplatform.fflib_SObjectSelector {
    
    
    private static Set<String> fields = new Set<String>{'Id','Label','INS_BranchCode__c'};
        
                /**
         * @description   method getSObjectType.
         * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
         * @param.
         * @return INS_Branches__mdt.sObjectType.
         * @date Nov 28th 2024
         */
        
        public override Schema.SObjectType getSObjectType() {
            return INS_Branches__mdt.sObjectType;
        }
    
    	/**
         * @description   method getSObjectFieldList.
         * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
         * @param.
         * @return List<Schema.SObjectField>.
         * @date Nov 28th 2024
         */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
        	INS_Branches__mdt.Id,
            INS_Branches__mdt.Label,
            INS_Branches__mdt.INS_BranchCode__c    
        };
            }
    
   		 /**
         * @description   method selectByCountry.
         * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
         * @param String userCountry.
         * @return List<INS_Branches__mdt>.
         * @date Nov 28th 2024
         */
    public List<INS_Branches__mdt> selectByCountry(String userCountry) {
        
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Country__c=:userCountry' );
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}