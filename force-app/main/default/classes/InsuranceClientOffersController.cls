/***************************************************************************************

@Name of the Component : Insurance Client Offers Controller
@Description : Retrieves top 3 list of recommended actions.
@Author : Kenneth Dlamini
@Created Date : 2024-09-19
/***************************************************************************************
@Last Modified By :
@Last Modified On :
@Modification description: SFP-36986, SFP-36989
***************************************************************************************/
public with sharing class InsuranceClientOffersController {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('InsuranceClientOffersController');
    private static final String PERMISSION_SET_NAME = 'SVC_EnableRecommendedActionPrivileges';

    /**
     * @description Select top 3 open recommended actions for the client based on Case Id
     * @author Kenneth Dlamini | 2024-OCt-04
     * @param recordId
     * @return List<sbgpers__Recommended_Action__c>
     **/
    @AuraEnabled(cacheable=true)
    public static List<sbgpers__Recommended_Action__c> fetchRecommendedActionsByCaseId(Id recordId) 
    {
        if (!hasAccessToRecommendedAction()){
            LOGGER.error('Insufficient privilleges to access this record (InsuranceClientOffersController.fetchRecommendedActionsByCaseId()).');
            throw new QueryException('Insufficient privilleges to access this record (InsuranceClientOffersController.fetchRecommendedActionsByCaseId()).');
        }
        SEL_RecommendedAction recommendationAction = new SEL_RecommendedAction();
        List<sbgpers__Recommended_Action__c> recommendedActions = new List<sbgpers__Recommended_Action__c>();
        try {
            recommendedActions = recommendationAction.selectRecommendedActionsByCaseId(recordId);
        }
        catch (QueryException ex) {
            LOGGER.error('InsuranceClientOffersController.fetchRecommendedActionsByCaseId()', ex);
            throw new AuraHandledException(ex.getMessage());
        }        
        return recommendedActions;
    }

    /**
     * @description Select all available client recommended actions for the client using account Id
     * @author Kenneth Dlamini | 2024-OCt-04
     * @param recordId
     * @return List<sbgpers__Recommended_Action__c>
     **/
    @AuraEnabled(cacheable=true)
    public static List<sbgpers__Recommended_Action__c> fetchRecommendedActionsByAccountId(Id recordId) 
    {
        if (!hasAccessToRecommendedAction()){
            LOGGER.error('Insufficient privilleges to access this record (InsuranceClientOffersController.fetchRecommendedActionsByAccountId()).');
            throw new QueryException('Insufficient privilleges to access this record (InsuranceClientOffersController.fetchRecommendedActionsByAccountId()).');
        }
        SEL_RecommendedAction recommendationAction = new SEL_RecommendedAction();
        List<sbgpers__Recommended_Action__c> recommendedActions = new List<sbgpers__Recommended_Action__c>();
        try {
            recommendedActions = recommendationAction.selectRecommendedActionsByAccountId(recordId);
        }
        catch (QueryException ex) {
            LOGGER.error('InsuranceClientOffersController.fetchRecommendedActionsByAccountId()', ex);
            throw new AuraHandledException(ex.getMessage());
        }        
        return recommendedActions;
    }

    /**
     * @description Select top 3 available pending client recommended actions for the client using account Id
     * @author Kenneth Dlamini | 2025-Jan-15
     * @param recordId
     * @return List<sbgpers__Recommended_Action__c>
     **/
    @AuraEnabled(cacheable=true)
    public static List<sbgpers__Recommended_Action__c> fetchTop3RecommendedActionsByAccountId(Id recordId) 
    {
        if (!hasAccessToRecommendedAction()){
            LOGGER.error('Insufficient privilleges to access this record (InsuranceClientOffersController.fetchTop3RecommendedActionsByAccountId()).');
            throw new QueryException('Insufficient privilleges to access this record (InsuranceClientOffersController.fetchTop3RecommendedActionsByAccountId()).');
        }
        SEL_RecommendedAction recommendationAction = new SEL_RecommendedAction();
        List<sbgpers__Recommended_Action__c> recommendedActions = new List<sbgpers__Recommended_Action__c>();
        try {
            recommendedActions = recommendationAction.selectTop3RecommendedActionsByAccountId(recordId);
        }
        catch (QueryException ex) {
            LOGGER.error('InsuranceClientOffersController.fetchTop3RecommendedActionsByAccountId()', ex);
            throw new AuraHandledException(ex.getMessage());
        }        
        return recommendedActions;
    }

    /**
     * @description Select a recommended action detail record
     * @author Kenneth Dlamini | 2024-OCt-05
     * @param recordId
     * @return sbgpers__Recommended_Action__c
     **/
    @AuraEnabled(cacheable=true)
    public static sbgpers__Recommended_Action__c fetchRecommendedActionById(Id recordId) 
    {
        if (!hasAccessToRecommendedAction()){
            LOGGER.error('Insufficient privilleges to access this record (InsuranceClientOffersController.fetchRecommendedActionById()).');
            throw new QueryException('Insufficient privilleges to access this record (InsuranceClientOffersController.fetchRecommendedActionById()).');
        }
        SEL_RecommendedAction recommendationAction = new SEL_RecommendedAction();
        sbgpers__Recommended_Action__c recommendedAction = new sbgpers__Recommended_Action__c();
        try {
            recommendedAction = recommendationAction.selectRecommendedActionById(recordId);
        }
        catch (QueryException ex) {
            LOGGER.error('InsuranceClientOffersController.fetchRecommendedActionById()', ex);
            throw new AuraHandledException(ex.getMessage());
        }        
        return recommendedAction;
    }

    /*
    * Author: Kenneth Dlamini
    * Date Created: 2024-Sep-19
    * Description: method for updating the client recommendation/offer Record
    * @param sbgpers__Recommended_Action__c
    */
    @AuraEnabled
    public static void updateClientOfferRecord (sbgpers__Recommended_Action__c updateRecommendation){
        try{
            if (hasAccessToRecommendedAction()){
                List<SObject> clientOffer = new List<SObject>{updateRecommendation};
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, clientOffer);
                //secure update
                update securityDecision.getRecords();
            }
            else{
                LOGGER.error('Insufficient privilleges to update this record.');
                //throw createAuraHandledException('updateClientOfferRecord()', 'Insufficient privilleges to update this record.');
                throw new AuraHandledException('Insufficient privilleges to update this record (InsuranceClientOffersController.updateClientOfferRecord()).');
            }   
        }
        catch(Exception ex){
            LOGGER.error('updateClientOfferRecord()[Error Message =' + ex.getMessage() + ']][' + ex + ']');
            throw new AuraHandledException('updateClientOfferRecord():' + ex.getMessage());
        }
    }

    /**
     * Author: Kenneth Dlamini
     * Date Created: 2024-Oct-07
     * Description: Check if logged in user has sufficient privileges to use the object:
     */
    @AuraEnabled(cacheable=true)
    public static Boolean hasAccessToRecommendedAction() {
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        try {
            assignments = [
                SELECT
                    Id
                FROM
                    PermissionSetAssignment
                WHERE
                    AssigneeId =: UserInfo.getUserId()
                AND
                    PermissionSet.Name =: PERMISSION_SET_NAME
            ];
        }
        catch (QueryException ex) {
            LOGGER.error('hasAccessToRecommendedAction()[Logged In User = ' + UserInfo.getUserId() +'][Error Message='+ ex.getMessage() +']', ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return !assignments?.isEmpty();
    }
}