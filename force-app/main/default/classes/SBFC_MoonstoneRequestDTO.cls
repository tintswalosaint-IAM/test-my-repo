/**
 * @description       : DTO used to construct and serialize the request payload for the Moonstone Disclosure API, including customer details and disclosure configuration parameters.
 * @Created Date      : 01-16-2026
 * author             : Gigyasu Jain
 * @group             : 
 * @last modified by  : Gigyasu Jain
**/
public class SBFC_MoonstoneRequestDTO {

    public String fspNo;
    public String fileType;
    public Params params;
    public String notifyByEmail;

    
    public class Params {
        public String cust_name;
        public String id_no;
        public String c_code;
        public Integer chk_one;
        public Integer chk_two;
        public String policy;
        public Integer hub_sign;
        public Integer manual_sign;
        public String email_inpt;
        public String finalName;
        public String finalIdNo;
        
    }
 
}