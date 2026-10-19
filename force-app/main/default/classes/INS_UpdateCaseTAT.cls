/***************************************************************************************

@Name of the Component : INS_UpdateCaseTAT
@Description : The aim is to update the TAT times on the case object.
@Author : Kenneth Dlamini
@Created Date : 2025-04-13
/***************************************************************************************
@Last Modified By :
@Last Modified On :
@Modification description: SFP-46473
***************************************************************************************/
public with sharing class INS_UpdateCaseTAT {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_UpdateCaseTAT');

    /**
     * @description Update TAT values.
     * @author Kenneth Dlamini | 2025-05-13
     * @param caseDetails is the case info that needs to be updated.
     **/
    public static void updateCaseTAT (Case caseDetails){
        try{
            update caseDetails; 
        }
        catch(Exception ex){
            LOGGER.error('updateCaseTAT()[Error Message =' + ex.getMessage() + '][' + ex + ']');
            throw new AuraHandledException('updateCaseTAT():' + ex.getMessage());
        }
    }
}