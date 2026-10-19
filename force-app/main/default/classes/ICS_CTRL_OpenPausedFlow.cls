/**
 * @description Controller to get paused flow for currenct recordf
 * @date December 2022
 */
public with sharing class ICS_CTRL_OpenPausedFlow {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_OpenPausedFlow');
    /**
     * @description This method is used to get a id of paused flow
     * @param objectName 
     * @param groupName name of fields group/section
     * @return flow record id
     */
    @AuraEnabled(cacheable=false)
    public static String getPausedFlowId(Id recordId) {
        List<FlowRecordRelation> interviews =      
            [SELECT ParentId
                        FROM FlowRecordRelation 
                        WHERE RelatedRecordId = :recordId];

        if (interviews.isEmpty()) {
            return null; // early out
        }
        LOGGER.info('interviews>>> ' + interviews.get(0).ParentId);
        // Return the ID for the first interview in the list.
        return interviews.get(0).ParentId;
    }
}