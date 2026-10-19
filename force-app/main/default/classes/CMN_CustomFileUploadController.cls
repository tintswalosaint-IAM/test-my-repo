/**
 * @description       : Controller class for cmn_customFileUpload lwc component to invoke a callable class and create CDL records where necessary
 * @author            : NAGENDRAPRASAD MYLAVARAPU
 * @last modified on  : 06-19-2024
 * @last modified by  : Jaco de Lange
**/
public class CMN_CustomFileUploadController {

    /**
    * @description method to invoke a class which implements callable interface to dynamically invoke a method
    * @author NAGENDRAPRASAD MYLAVARAPU | 02-19-2024
    * @param String className
    * @param String methodName
    * @param String recordId
    * @return object
    **/
    @AuraEnabled
    public static object invoke(String className, String methodName, String recordId){
        object retVal;
        try{
            Type invocableType = Type.forName(className);
            Object invocableInstance = invocableType.newInstance();
            if (invocableInstance instanceof Callable) {
                Map<String,Object> params = new Map<String,Object>{'recordId'=>recordId};
                retVal = ((Callable) invocableInstance).call(methodName, params);
            }
        }
        catch(Exception e){
            AuraHandledException exc = new AuraHandledException(e.getMessage());
            exc.setMessage('Error invoking callable method: '+e.getMessage());
            throw exc;
        }
        return retVal;
    }
}