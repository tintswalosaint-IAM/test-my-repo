/**
* @description BCB_RelyComplyIndiScreeningResponse class for dealing with account creation api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa(lokesh.bothsa@stanndardbank.co.za)
* @date june 2023
* Story Number : SFP-25770
*/
public class BCB_RelyComplyIndiScreeningResponse {
    /** @description assessmentId */
    public String assessmentId {get;set;}
    /** @description result */
    public String result {get;set;}
    /** @description cases */
    public List<Cases> cases {get;set;}
    
    /** @description  wrapper class for cases */
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