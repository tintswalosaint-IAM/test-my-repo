/*
 * Class Name      : SEL_INSProductMDT
 * description     : SFP-55927 : Selector class for INS_Products__mdt custom metadata type.
 * Test Class      : SEL_INSProductMDT_TEST
 * Created Date    : Jul 21, 2026
 * Author          : Mahesh Reddy
 */
/**
 * @description Selector class for INS_Products__mdt custom metadata records.
 */
public inherited sharing class SEL_INSProductMDT extends sbgplatform.fflib_SObjectSelector {

    private static Set<String> fields = new Set<String>{'Id', 'Country__c', 'Is_Liberty__c', 'INS_Customer_Brand__c'};

    /**
    * @description Implementation method for INS_Products__mdt Object as part of fflib framweork
    * @return Schema.SObjectType
    */
    public override Schema.SObjectType getSObjectType() {
        return INS_Products__mdt.sObjectType;
    }

    /**
    * @description Method to get list of fields to be part of response
    * @return List<Schema.SObjectField>
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                INS_Products__mdt.Id,
                INS_Products__mdt.Country__c,
                INS_Products__mdt.Is_Liberty__c,
                INS_Products__mdt.INS_Customer_Brand__c
        };
    }

    /**
     * @description   method selectByCountry.
     * @author Mahesh Reddy
    * @param userCountry Country used to filter the products.
    * @param isLibertyUser Indicates whether the user is a Liberty user.
     * @return List<INS_Products__mdt>.
     * @date Aug 04th 2026
     */
    public List<INS_Products__mdt> selectByCountry(String userCountry, Boolean isLibertyUser) {
        
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Country__c = \'' + String.escapeSingleQuotes(userCountry) + '\' AND Is_Liberty__c = ' + isLibertyUser );
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}