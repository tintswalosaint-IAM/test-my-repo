/**
 * @description Call methods from omniscript metadata
 * @author Alexandr Goryachko
 * @date 2025-02-03
 * SFP-55383
 */
global with sharing class INS_UTIL_OmniProvider implements omnistudio.VlocityOpenInterface, Callable {
    /**
     * Standard Runtime entry point. The legacy OmniScript runtime calls
     * invokeMethod directly through VlocityOpenInterface, while Standard
     * Runtime resolves remote classes through System.Callable.
     */
    global Object call(String methodName, Map<String, Object> args) {
        Map<String, Object> inputMap = args != null && args.get('input') instanceof Map<String, Object>
            ? (Map<String, Object>) args.get('input')
            : new Map<String, Object>();
        Map<String, Object> outMap = args != null && args.get('output') instanceof Map<String, Object>
            ? (Map<String, Object>) args.get('output')
            : new Map<String, Object>();
        Map<String, Object> options = args != null && args.get('options') instanceof Map<String, Object>
            ? (Map<String, Object>) args.get('options')
            : new Map<String, Object>();

        invokeMethod(methodName, inputMap, outMap, options);
        return outMap;
    }

    /**
     * @description constructor to init request data
     * @param methodName
     * @param inputMap map with input data
     * @param outMap map with output data
     * @param options map with options data
     */
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean isSuccess = true;
        try {
            if (methodName == 'logError') {
                logError(inputMap, options);
            } else if (methodName.startsWith('getOmniPicklist')) {
                outMap.put('dependency', INS_SRV_OmniPicklist.callMethod(methodName));
            } else if (methodName == 'getAddressDetails') {
                outMap.put('result', INS_SRV_PortalData.getAddressDetails((String)options.get('portalUserId')));
            } else if (methodName == 'getEmploymentDetails') {
                outMap.put('result', INS_SRV_PortalData.getEmploymentDetails((String)options.get('portalUserId')));
            } else if (methodName == 'getAccountDetails') {
                outMap.put('result', INS_SRV_PortalData.getAccountDetails((String)options.get('portalUserId')));
            }
        } catch (Exception ex) {
            outMap.put('sucess', false);
            outMap.put('result', ex.getMessage());
            inputMap.put('error', ex.getMessage() + '\n' + ex.getStackTraceString());
            logError(inputMap, options);
            isSuccess = false;
        }
        return isSuccess;
    }

    /**
     * @description method to logging error in sbgplatform__rflib_Log__c
     * @param inputMap map with input data
     * @param options map with options data
     */
    private void logError(Map<String, Object> inputMap, Map<String, Object> options) {
        List<String> argumentList = new List<String>{JSON.serialize(inputMap), JSON.serialize(options)};
        sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory()
            .createLogger('INS_UTIL_OmniProvider');
        logger.error('Arguments: inputMap={0}; options={1}', argumentList);
    }
}