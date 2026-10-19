/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :BCB_RelyComplyBusinessScreeningResponse
@description       :wrapper Class for generic form creation based on database records
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :25-05-2023
@ Modification Description : SFP-26345
***************************************************************************************/
public class BCB_RelyComplyBusinessScreeningResponse {
    /** @description assessmentId */
    public String assessmentId {get;set;}
    /** @description result */
    public String result {get;set;}
    /** @description cases */
    public List<Cases> cases {get;set;}
    
    /** @description wrapper class for cases */
    public class Cases {
        /** @description type */
        public String type {get;set;}
        /** @description name */
        public String name {get;set;}
        /** @description outcome */
        public String outcome {get;set;}
        /** @description failed */
        public Boolean failed {get;set;}
    }
}