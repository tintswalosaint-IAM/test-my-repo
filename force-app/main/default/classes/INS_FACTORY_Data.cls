/**
 * @description Factory class to get dynamic data
 * @author Alexandr Goryachko
 * @date 2024/07/26
 */
public with sharing class INS_FACTORY_Data {
    /**
     * @description Get init data for the component
     * @param className name of the handler class
     * @param params parameters of the method
     * @return Wrapper class with data
     */
    @AuraEnabled(cacheable=false)
    public static Object getData(String className, Map<String, Object> params) {
        Object result;
        try {
            Type t = Type.forName(className);
            INS_IData data = (INS_IData)t.newInstance();
            result = data.getData(params);
        } catch (Exception ex) {
            List<String> argumentList = new List<String>{className, JSON.serialize(params)};
            sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory()
                .createLogger('INS_FACTORY_Data');
            logger.error('Arguments: className={0}; recordId={1}', argumentList, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return result;
    }
}