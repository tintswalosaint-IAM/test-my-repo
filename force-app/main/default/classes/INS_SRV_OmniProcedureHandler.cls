/**
 * @description handler that allows to call omniscript procedures from apex
 * @author Alexandr Goryachko
 * @date 2025/01/23
 */
public with sharing class INS_SRV_OmniProcedureHandler {
    /**
     * @description call omniscript procedure
     * @param ipInput input data
     * @param ipOptions additional options
     * @param params for method
     * @return data wrapper
     */
    @AuraEnabled(cacheable=false)
    public static Object callOmniProcedure(Map<String, Object> ipInput, Map<String, Object> ipOptions, Map<String, Object> params) {
        Map<String, Object> ipOutput = new Map<String, Object>();
        String procedureName = String.valueOf(params.get('procedureName'));

        try {
            procedureName = procedureName.length() > 0 ? procedureName : null;
            // Call the IP via runIntegrationService, and save the output to ipOutput
            ipOutput = (Map<String, Object>)omnistudio.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
        } catch (Exception ex) {
            List<String> argumentList = new List<String>{JSON.serialize(params)};
            sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory()
                .createLogger('INS_SRV_OmniProcedureHandler');
            logger.error('Arguments: params{1}', argumentList, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return ipOutput;
    }
}