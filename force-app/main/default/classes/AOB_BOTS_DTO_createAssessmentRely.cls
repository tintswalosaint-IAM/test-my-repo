/**
* @description This class is used as call createAssessmentRely
* @author Dayakar 
* @date Jan 5th 2021
*/
public class AOB_BOTS_DTO_createAssessmentRely {
    
    /**
    * @description This method is used as call the accessToken api
    * @param customerData - String
    * @return String
    */
    public static String creatAssement(String customerData){
        
        createAssessment cc= new createAssessment();
        Detail de=new Detail();
        Variables var= new Variables();
        Input inp=new Input();
        cc.event='CreateAssessment';
        de.graphql='mutation(\n  $input: CreateAssessmentInput!\n) {\n\n  createAssessment(\n    input: $input\n  ) {\n\n    assessment {\n\n      id\n      complete\n      status\n      webhookUrl\n      created\n      customer {\n        id\n        firstName\n        lastName\n      }      \n\n    }\n  }\n}';
        inp.assessmentConfig='bw_business_banking_screening_assessment';
        inp.customer=customerData;
        
        var.input=inp;
        de.variables=var;
        cc.detail=de;
        return Json.serialize(cc);
    }
    
    /**
    * @description wrapper class for Variables
    */
    public class Variables {
        public Input input;
    }
    
    /**
    * @description wrapper class for Input
    */
    public class Input {
        public string assessmentConfig;
        public string customer;
    }
    
    /**
    * @description wrapper class for createAssessment
    */
    public class createAssessment{
        public String event;
        public Detail detail;
    }
    
    /**
    * @description wrapper class for Detail
    */
    public class Detail {
        public Variables variables;
        public String graphql;
    }

}