/**
* @description BeanClass for dealing with Customer Register QNA api and sending the result to the main container and storing the values in the wrapper
* @author Amarnath Reddy(amarnath.reddy@standardbank.co.za)
* @date june 2022
*/
public class AOB_CustomerRegister_QNABean {
    /** @description attribute **/
	public CustomerRegisterHeader header{get;set;}
     /** @description attribute **/
    public CustomerRegisterQuestion customerQuestionNA{get;set;}
     /** @description CustomerRegisterHeader is using for CustomerRegister_QNA API request body **/
    public class CustomerRegisterHeader {
         /** @description attribute **/
        public String serviceIdentifier{get;set;}
         /** @description attribute **/
        public String operationFormat{get;set;}
         /** @description attribute **/
        public String channelIdentifier{get;set;}
         /** @description attribute **/
        public String bankIdentifier{get;set;}
         /** @description attribute **/
        public String ipFormat{get;set;}
         /** @description attribute **/
        public Integer loginFlag{get;set;}
         /** @description attribute **/
        public String languageIdentifier{get;set;}
         /** @description attribute **/
        public String isMultirec{get;set;}
         /** @description attribute **/
        public String userPrincipal{get;set;}
         /** @description attribute **/
        public String stateMode{get;set;}
         /** @description attribute **/
        public String formIdentifier{get;set;}
         /** @description attribute **/
        public String accessCode{get;set;}
         /** @description attribute **/
        public String loginType{get;set;}
         /** @description attribute **/
        public String ipAddress{get;set;}
         /** @description attribute **/
        public String deviceIdentifier{get;set;}
         /** @description attribute **/
        public String deviceType{get;set;}
         /** @description attribute **/
        public String machineFingerPrint{get;set;}
    }
     /** @description CustomerRegisterQuestion is using for CustomerRegister_QNA API request body **/
    public class CustomerRegisterQuestion {
         /** @description attribute **/
        public String accountNumber{get;set;}
         /** @description attribute **/
        public Boolean isCoreRequest{get;set;}
         /** @description attribute **/
        public String linkedchannels{get;set;}
         /** @description attribute **/
        public String customerNumber{get;set;}
         /** @description attribute **/
        public String requestIdentity{get;set;}
         /** @description attribute **/
        public List<CustomerRegisterQna> customerRegisterQnaRec{get;set;}                
    }
     /** @description CustomerRegisterQna is using for CustomerRegister_QNA API request body **/
    public class CustomerRegisterQna {
         /** @description attribute **/
        public String selectedIndexArray{get;set;}
         /** @description attribute **/
        public String chosenAnswerArray{get;set;}
         /** @description attribute **/
        public String questionIdentifyArray{get;set;}
    }
}