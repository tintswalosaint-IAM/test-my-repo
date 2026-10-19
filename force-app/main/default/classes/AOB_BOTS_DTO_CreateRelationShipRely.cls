public class AOB_BOTS_DTO_CreateRelationShipRely {
    
    
    public static String createRelationship(String applicationId,String customerData){
        
        List<Application__c> apps = [select Id,Inflight__c from Application__c where id=:applicationId];
        
        String createBusinessRely=AOB_BOTS_SRV_RelyComply.getInflight(applicationId,'createBusinessRely');
        Map<String,Object> customerMaps;
        if(!String.isEmpty(createBusinessRely)){
            Map<String,Object> createBusinessRelyMaps = (Map<String,object>) JSON.deserializeUntyped(createBusinessRely);
            String createCustomerBusiness=Json.serialize(createBusinessRelyMaps.get('createCustomer'));
            Map<String,Object> createCustomerBusinessMaps = (Map<String,object>) JSON.deserializeUntyped(createCustomerBusiness);
            String customer=Json.serialize(createCustomerBusinessMaps.get('customer'));
            customerMaps = (Map<String,object>) JSON.deserializeUntyped(customer);
        }
        CreateRelationShip cc= new CreateRelationShip();
        Detail de=new Detail();
        Variables var= new Variables();
        Input inp=new Input();
        cc.event='CreateRelationship';
        de.graphql='mutation(\n  $input: CreateCustomerRelationshipInput!\n) {\n\n  createCustomerRelationship(\n    input: $input\n  ) {\n\n    customerRelationship {\n      id,\n      created,\n      object {\n      \tid,\n        businessName\n      },\n      subject {\n        id,\n        firstName,\n        lastName        \n      },\n      role\n    }\n  }\n}';
        inp.nbmobject=(String)customerMaps.get('id');
        inp.subject=customerData;
        inp.role='DIRECTOR';
        
        var.input=inp;
        de.variables=var;
        cc.detail=de;
        String reqbody=Json.serialize(cc);
        reqbody=reqbody.remove('nbm');
        return reqbody;
        
    }
    
    
    public class Variables {
        public Input input;
    }
    
    public class Input {
        public string nbmobject;
        public string subject;
        public string role; 
    }
    
    public class CreateRelationShip{
        public String event;
        public Detail detail;
    }
    
    
    public class Detail {
        public Variables variables;
        public String graphql;
    }
    
}