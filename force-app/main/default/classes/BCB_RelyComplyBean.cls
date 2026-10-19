/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :BCB_RelyComplyBean
@description       :wrapper Class for generic form creation based on database records
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :25-05-2023
@ Modification Description : SFP-26345
***************************************************************************************/
public class BCB_RelyComplyBean {
    /** @description wrapper class for individualScreening */
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
    /** @description wrapper class for businessScreening */
    public class businessScreening{
        /** @description identifier */
        public String identifier {get;set;}
        /** @description businessName */
        public String businessName {get;set;}
        /** @description nationality */
        public String nationality {get;set;}
        /** @description residence */
        public String residence {get;set;}
        /** @description birthdate */
        public String birthdate {get;set;}
        /** @description clientType */
        public String clientType {get;set;}
        /** @description industryId */
        public String industryId {get;set;}
        /** @description onApprovedExchange */
        public Boolean onApprovedExchange {get;set;}
        /** @description ownerIsBeneficiary */
        public Boolean ownerIsBeneficiary {get;set;}
        /** @description industryId */
        public string bankProduct {get;set;}
    }
}