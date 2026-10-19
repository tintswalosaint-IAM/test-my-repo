/***************************************************************************************
@ Author            : Jyothsna.datla@standardbank.co.za
@ Date              : 19-02-2026
@ Name of the Class : SEL_FHQ_Question_Configuration
@ Description       : Selector class used to fetch FHQ Question Configuration
                      Custom Metadata records using fflib selector framework.
@ Last Modified By  : Jyothsna.datla@standardbank.co.za
@ Last Modified On  : 19-02-2026
@ Modification Description :
1.0   Feb 2026      Jyothsna.datla@standardbank.co.za     Initial Creation(PPBSF-291)
***************************************************************************************/
public inherited sharing class SEL_FHQ_Question_Configuration 
    extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description Default fields to be selected for FHQ Question Configuration metadata.
     *              These fields are reused across selector methods to ensure consistency.
     */
    private static Set<String> fields = new Set<String>{
        'DeveloperName',
        'Display_Order__c',
        'Grid_Label__c',
        'Include_In_Total__c',
        'Question_Text__c',
        'Record_Type__c',
        'Value_Type__c'
    };

     /**
     * @description Returns the SObjectType for the Custom Metadata
     *              FHQ_Question_Configuration__mdt.
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return FHQ_Question_Configuration__mdt.SObjectType;
    }

     /**
     * @description Returns the default list of fields to be queried
     *              when this selector is used.
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            FHQ_Question_Configuration__mdt.DeveloperName,
            FHQ_Question_Configuration__mdt.Display_Order__c,
            FHQ_Question_Configuration__mdt.Grid_Label__c,
            FHQ_Question_Configuration__mdt.Include_In_Total__c,
            FHQ_Question_Configuration__mdt.Question_Text__c,
            FHQ_Question_Configuration__mdt.Record_Type__c,
            FHQ_Question_Configuration__mdt.Value_Type__c
        };
    }

       /**
     * @description Retrieves all FHQ Question Configuration metadata records
     *              ordered by Display_Order__c in ascending order.
     *              Used when full configuration needs to be loaded.
     * @return List<FHQ_Question_Configuration__mdt>
     */
    public List<FHQ_Question_Configuration__mdt> selectAll() {

    sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory();
    queryFactory.selectFields(fields);

    queryFactory.setOrdering(
        'Display_Order__c',
        sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING
    );

    return Database.query(queryFactory.toSOQL());
}

       /**
     * @description Retrieves FHQ Question Configuration metadata records
     *              filtered by the specified Record_Type__c value.
     *              Used when configuration varies per record type.
     * @param recordType The Record_Type__c value used for filtering.
     * @return List<FHQ_Question_Configuration__mdt>
     */
    public List<FHQ_Question_Configuration__mdt> selectByRecordType(String recordType) {

        sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition('Record_Type__c = :recordType');
        queryFactory.selectFields(fields);

        return Database.query(queryFactory.toSOQL());
    }

      /**
     * @description Retrieves only FHQ Question Configuration metadata records
     *              where Include_In_Total__c is set to true.
     *              Used for total calculation logic in FHQ processing.
     * @return List<FHQ_Question_Configuration__mdt>
     */
    public List<FHQ_Question_Configuration__mdt> selectIncludedInTotal() {

        sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition('Include_In_Total__c = true');
        queryFactory.selectFields(fields);

        return Database.query(queryFactory.toSOQL());
    }
}