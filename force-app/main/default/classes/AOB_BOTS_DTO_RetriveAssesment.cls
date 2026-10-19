public class AOB_BOTS_DTO_RetriveAssesment {
    
    public static String RetriveAssement(String customerId){
        
        createAssessment cc= new createAssessment();
        Detail de=new Detail();
        Variables var= new Variables();
        
        cc.event='RetrieveAssessment';
        de.graphql='query($id: String) {\n assessments(id: $id) {\n edges {\n node {\n id\ncomplete\nstatus\nwebhookUrl\ncreated\n updated\n assessmentConfig {\nname\nassessmentType\n }\ncustomer{\nid\n}\nscreenings {\n edges {\n node {\n id\n outcome\n screeningConfig {\n name\n screeningType\n }\ncases {\nedges {\nnode {\nid\n closed\nstate\n outcome\n}\n}\n}\n}\n}\n}\n }\n  }\n }\n}';
        var.id=customerId;
        
        de.variables=var;
        cc.detail=de;
        return Json.serialize(cc);
    }
    
    public class Variables {
        public string id;
    }
    
    
    
    public class createAssessment{
        public String event;
        public Detail detail;
    }
    
    
    public class Detail {
        public Variables variables;
        public String graphql;
    }

}