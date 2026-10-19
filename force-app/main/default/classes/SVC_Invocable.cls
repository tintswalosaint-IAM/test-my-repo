/**
 * @description       : 
 * @author            : NAGENDRAPRASAD MYLAVARAPU
 * @last modified on  : 06-19-2024
 * @last modified by  : Jaco de Lange
**/
public class SVC_Invocable implements Callable {
    public Object call(String action, Map<String, Object> params) {
        try{
            switch on action {
                when 'invokeAPI' {
                    return 'API Invoked';
                }
                when 'getFieldData' {
                    Map<String,object> fieldLst = new Map<String,Object>();
                    fieldLst.put('name','TaxStatement');
                    fieldLst.put('type','KYC Files');
                    fieldLst.put('label','Tax Statement');
                    fieldLst.put('recordId',params.get('recordId'));
                    fieldLst.put('required',true);
                    fieldLst.put('multiple',true);
                    fieldLst.put('acceptedFormats',new List<String>{'.jpg','.pdf'});
                    return fieldLst;
                }
            }
        }    
        catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }    
        return null;
    }
}