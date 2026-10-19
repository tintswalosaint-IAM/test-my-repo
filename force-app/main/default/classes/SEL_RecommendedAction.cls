/***************************************************************************************

@Name of the Component : SEL_RecommendedAction
@Description : Selector class to retrieves top 3 list of recommended actions.
@Author : Kenneth Dlamini
@Created Date : 2024-10-04
/***************************************************************************************
@Last Modified By :
@Last Modified On :
@Modification description: SFP-36986, SFP-36989
***************************************************************************************/
public inherited sharing class SEL_RecommendedAction extends sbgplatform.fflib_SObjectSelector{

    /**
    * @description Default contructor must call super()
    **/
    public SEL_RecommendedAction() {
        super();
    }

    /**
     * @description Defines the default fields to be added to all queries created ny the Query Factory
     * @return List of Schema.SObjectField objects representing the fields
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            sbgpers__Recommended_Action__c.Id, 
            sbgpers__Recommended_Action__c.sbgpers__Category__c,
            sbgpers__Recommended_Action__c.sbgpers__Sub_Category__c, 
            sbgpers__Recommended_Action__c.sbgpers__Status__c, 
            sbgpers__Recommended_Action__c.sbgpers__Reason__c,
            sbgpers__Recommended_Action__c.sbgpers__Response__c,
            sbgpers__Recommended_Action__c.sbgpers__Notes__c,
            sbgpers__Recommended_Action__c.sbgpers__Details__c,
            sbgpers__Recommended_Action__c.sbgpers__Valid_Until__c
        };
    }

    /**
     * @description Returns the object type
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return sbgpers__Recommended_Action__c.SObjectType;
    }

    /**
     * @description Select top 3 open recommended actions for the client
     * @author Kenneth Dlamini | 2024-OCt-04
     * @param recordId
     * @return List<sbgpers__Recommended_Action__c>
     **/
    public List<sbgpers__Recommended_Action__c> selectRecommendedActionsByCaseId(Id recordId) {
        SVC_ClientRecommendationEngineSettings__mdt customSettings = SVC_ClientRecommendationEngineSettings__mdt.getInstance('SVC_LineItemsPerClient');
        Integer numberOfLineItemsToDisplay = Integer.valueOf(customSettings.SVC_NumberOfLinetItemsToDisplay__c); 
        String recordStatus = customSettings.SVC_ActionedRecordStatus__c;
        String systemId = customSettings.SVC_System_ID__c;
        DateTime currentDateTime = Date.today();
        Date currentDate = Date.valueOf(currentDateTime.format('yyyy-MM-dd'));

        Case caseInfo = [SELECT Id, 
            AccountId 
        FROM Case WHERE Id =: recordId 
        WITH SECURITY_ENFORCED];
        List<sbgpers__Recommended_Action__c> recommendedActions = new List<sbgpers__Recommended_Action__c>();
        if (!String.isBlank(caseInfo.AccountId)) {
            recommendedActions =  [
            SELECT Id,
                sbgpers__Category__c,
                sbgpers__Sub_Category__c, 
                sbgpers__Status__c 
            FROM sbgpers__Recommended_Action__c
            WHERE sbgpers__Account__c =: caseInfo.AccountId
            AND sbgpers__Status__c != : recordStatus
            AND sbgpers__External_System_Id__c =: systemId
            AND sbgpers__Valid_Until__c >=:currentDate //current date
            WITH SECURITY_ENFORCED LIMIT : numberOfLineItemsToDisplay
            ];
        }
        
        return recommendedActions;
    }

    /**
     * @description Select all available recommended actions for the client that have been actioned.
     * @author Kenneth Dlamini | 2024-OCt-04
     * @param recordId
     * @return List<sbgpers__Recommended_Action__c>
     **/
    public List<sbgpers__Recommended_Action__c> selectRecommendedActionsByAccountId(Id recordId) {
        SVC_ClientRecommendationEngineSettings__mdt customSettings = SVC_ClientRecommendationEngineSettings__mdt.getInstance('SVC_LineItemsPerClient'); 
        String systemId = customSettings.SVC_System_ID__c;
        String recordStatus = customSettings.SVC_ActionedRecordStatus__c;
        List<sbgpers__Recommended_Action__c> recommendedActions = new List<sbgpers__Recommended_Action__c>();
        if (!String.isBlank(recordId)){
            recommendedActions =  [
            SELECT Id, 
                sbgpers__Category__c,
                sbgpers__Sub_Category__c, 
                sbgpers__Status__c, 
                sbgpers__Reason__c,
                sbgpers__Response__c,
                sbgpers__Notes__c,
                sbgpers__Details__c
            FROM sbgpers__Recommended_Action__c
            WHERE sbgpers__Account__c =: recordId
            AND sbgpers__Status__c = : recordStatus
            AND sbgpers__External_System_Id__c =: systemId
            WITH SECURITY_ENFORCED 
            ORDER BY sbgpers__Status__c DESC 
        ];
        }       
        return recommendedActions;
    }

    /**
     * @description Select top 3 available recommended actions for the client irrespective of status
     * @author Kenneth Dlamini | 2025-Jan-15
     * @param recordId
     * @return List<sbgpers__Recommended_Action__c>
     **/
    public List<sbgpers__Recommended_Action__c> selectTop3RecommendedActionsByAccountId(Id recordId) {
        SVC_ClientRecommendationEngineSettings__mdt customSettings = SVC_ClientRecommendationEngineSettings__mdt.getInstance('SVC_LineItemsPerClient'); 
        Integer numberOfLineItemsToDisplay = Integer.valueOf(customSettings.SVC_NumberOfLinetItemsToDisplay__c);
        String recordStatus = customSettings.SVC_ActionedRecordStatus__c;
        String systemId = customSettings.SVC_System_ID__c;
        DateTime currentDateTime = Date.today();
        Date currentDate = Date.valueOf(currentDateTime.format('yyyy-MM-dd'));
        List<sbgpers__Recommended_Action__c> recommendedActions = new List<sbgpers__Recommended_Action__c>();
        if (!String.isBlank(recordId)){
            recommendedActions =  [
            SELECT Id, 
                sbgpers__Category__c,
                sbgpers__Sub_Category__c, 
                sbgpers__Status__c
            FROM sbgpers__Recommended_Action__c
            WHERE sbgpers__Account__c =: recordId
            AND sbgpers__Status__c != : recordStatus
            AND sbgpers__External_System_Id__c =: systemId
            AND sbgpers__Valid_Until__c >=:currentDate //current date
            WITH SECURITY_ENFORCED LIMIT : numberOfLineItemsToDisplay  
        ];
        }       
        return recommendedActions;
    }

    /**
     * @description Select a recommended action detail for the client
     * @author Kenneth Dlamini | 2024-OCt-05
     * @param recordId
     * @return sbgpers__Recommended_Action__c
     **/
    public sbgpers__Recommended_Action__c selectRecommendedActionById(Id recordId) {
        return  [
            SELECT Id, 
                sbgpers__Category__c,
                sbgpers__Sub_Category__c, 
                sbgpers__Status__c, 
                sbgpers__Reason__c,
                sbgpers__Response__c,
                sbgpers__Notes__c,
                sbgpers__Details__c
            FROM sbgpers__Recommended_Action__c
            WHERE Id =: recordId
            WITH SECURITY_ENFORCED
        ];
    }
}