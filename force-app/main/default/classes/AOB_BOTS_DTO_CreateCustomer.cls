/**
 * @description DTO class for CreateCustomer
 *
 * @author Dayakar Deekonda
 *
 * @date Jun 6th 2023
 */
public class AOB_BOTS_DTO_CreateCustomer {
    
    /**
    * @description this method is to create customer
    * @param applicationId  - Id of the Community
    * @return String 
    */
    public static String createCustomer(String applicationId){
        List<Application_Participant__c> Directordatalist = [select Id,Application__r.AOB_TertiarySICCode__c,AOB_Occupation__c,AOB_IDNumber__c,Application__c,Application__r.Entity_Type_Sub_Category__c,Application__r.AOB_PresenceinCountry__c,AOB_Role__c,CNGCU_Email__c,AOB_FullName__c,AOB_External_GUID__c from Application_Participant__c where Application__c =:applicationId];
        String presenceCountry;
        if(String.isEmpty(presenceCountry)){
            if(Directordatalist[0].Application__r.AOB_PresenceinCountry__c=='Local Company'){
                
                presenceCountry='Resident';
                
            }if(Directordatalist[0].Application__r.AOB_PresenceinCountry__c=='Foreign Company'){
                
                presenceCountry='Non-Resident';
                
            }
        }
        AOB_ReferencedData__c rference=[SELECT AOB_Code__c,AOB_CountryCode__c,AOB_ProductCategory__c,Name FROM AOB_ReferencedData__c where AOB_CountryCode__c=:presenceCountry and Name=:Directordatalist[0].Application__r.Entity_Type_Sub_Category__c limit 1];
        List<Application_Participant__c> updatelist= new List<Application_Participant__c>();
        CreateCustomer cc= new CreateCustomer();
        Detail de=new Detail();
        Variables var= new Variables();
        Input inp=new Input();
        List<Customers> customerslist= new List<Customers>();
        cc.event='CreateCustomer';
        de.graphql='mutation ($input: BulkCustomerUpsertMutationInput!) {\n  upsertCustomers(input: $input) {\n    customers {\n      created\n      customer {\n        id\n        identifier\n      }\n    }\n  }\n}\n';
        
        
        
        for(Application_Participant__c app:Directordatalist){
            String name=app.AOB_FullName__c;
            String[] names = name.split(' ');    
            Customers cust= new Customers();
            String guid=AOB_Utils.generateGUID();
            cust.identifier=guid;
            app.AOB_External_GUID__c=guid;
            cust.type='individual';
            if(name.contains(' ')){
                cust.firstName=names[0];
                cust.lastName=names[1];
            }else{
                cust.firstName=name;
                cust.lastName=name;  
            }
            
            cust.idDocumentType='GENERIC_ID';
            cust.idDocumentCode=app.AOB_IDNumber__c;
            cust.nationality='BW';
            cust.residence='BW';
            
            
            List<DataValue> dvlist=new List<DataValue>();
            
            DataValue dv= new DataValue();
            dv.key='sbg_client_type_code';
            if(rference!=null){
                dv.value=rference.AOB_Code__c;
            }
            dvlist.add(dv);
            
            DataValue dv2= new DataValue();
            dv2.key='sbg_product';
            dv2.value='Transactional';
            dvlist.add(dv2);
            
            
            DataValue dv1= new DataValue();
            dv1.key='sbg_occupation_category';
            dv1.value=app.AOB_Occupation__c;
            dvlist.add(dv1);
            
            cust.data=dvlist;
            
            customerslist.add(cust);
            updatelist.add(app);
        }
        
        inp.customers=customerslist;
        var.input=inp;
        de.variables=var;
        cc.detail=de;
        Data d= new Data();
        d.jsonbody=cc;
        d.applist=updatelist;
        
        return json.serialize(d);
    }
    
    /*
    * @description Variables class
    */
    public class Variables {
        public Input input;
    }
    
    /*
    * @description Input class
    */
    public class Input {
        public List<Customers> customers;
    }
    
    /*
    * @description DataValue class
    */
    Public Class DataValue{
        public String key;
        public String value;
    }
    
    /*
    * @description CreateCustomer class
    */
    public class CreateCustomer{
        public String event;
        public Detail detail;
    }
    /*
    * @description Customers class
    */
    public class Customers {
        public String identifier;
        public String type;
        public String firstName;
        public String lastName;
        public String idDocumentType;
        public String idDocumentCode;
        public String nationality;
        public String residence;
        public String birthdate;
        public List<DataValue> data;
    }
    
    /*
    * @description Detail class
    */
    public class Detail {
        public Variables variables; 
        public String graphql;
    } 
    
    /*
     * @description Data class
     */
    public class Data{
        
        public CreateCustomer jsonbody;
        public List<Application_Participant__c> applist;
    }
    
    
}