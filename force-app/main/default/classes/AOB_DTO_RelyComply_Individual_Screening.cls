/***************************************************************************************
@ Author            :Jagadish Thummala (thummalaj@stanbic.com).
@ Date              :July 2024
@ Name of the Class :AOB_DTO_RelyComply_Individual_Screening
@ Description       :Parser class to deserilize the response for AOB_RelyComply_Individual_Screening API.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :15-07-2024
@ Modification Description : SFP-31036
***************************************************************************************/
public with sharing class AOB_DTO_RelyComply_Individual_Screening {
     /** @description assessmentId */
     public String assessmentId {get;set;}
     /** @description result */
     public String result {get;set;}
     /** @description cases */
     public list<cases> cases{get;set;}

     public class cases{
        /** @description name */
		public String name{get;set;}
        /** @description outcome */
		public String outcome{get;set;}
        /** @description failed */
		public Boolean failed{get;set;}
        /** @description type */
		public String type{get;set;}
	}
    
     public  class individualScreening{
        /** @description attribute identifier */
        public String identifier {get;set;}
        /** @description firstName */
        public String firstName {get;set;}
        /** @description lastName */
        public String lastName {get;set;}
        /** @description nationality */
        public String nationality {get;set;}
        /** @description residence */
        public String residence {get;set;}
        /** @description birthDate */
        public String birthDate {get;set;}
        /** @description clientType */
        public String clientType {get;set;}
        /** @description occupationCategory */
        public String occupationCategory {get;set;}
        /** @description bankProduct */
        public String bankProduct {get;set;}
    }
}