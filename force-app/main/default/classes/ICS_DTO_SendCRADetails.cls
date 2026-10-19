/**
 * @description SFP-32986 Class used as wrapper for ICS_API_SendCRADetails.cls
 * @author Ikyatha Naidu, Swapnil Walse
 * @date 22/04/2024
 ***************************************************** 
 * @last modified on  : 01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @last modified description: Initial Version
 */
public class ICS_DTO_SendCRADetails {
    /**
     * @description CRA details to be sent to Rely Comply via Azure
     */
    public class input{
        public String identifier  {get;set;} 
        public String firstName {get;set;} 
        public String middleName {get;set;} 
        public String lastName {get;set;} 
        public String idDocumentType {get;set;} 
        public String idDocumentCode {get;set;} 
        public Date birthdate {get;set;} 
        public List<requestMap> data {get;set;} 
    }
    /**
     * @description key value pairs to be sent to CRA endpoint
     */
    public class requestMap{
        public String key {get;set;} 
        public String value {get;set;} 
    }
    public input input {get;set;} 
}