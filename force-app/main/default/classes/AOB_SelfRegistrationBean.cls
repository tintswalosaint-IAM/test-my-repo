/**
* @description BeanClass for dealing with Self Registration api and sending the result to the main container and storing the values in the wrapper
*
*
* @author Amarnath Reddy(amarnath.reddy@standardbank.co.za)
* @date june 2022
*/

public inherited sharing class AOB_SelfRegistrationBean {
    /** @description header parameter */
    public HeaderInfo header{get;set;}
    /** @description body parameter */
    public BodyInfo body{get;set;}
    /** @description qna parameter */
    public QNAReponse qna{get;set;}
    /** @description headerInfo wrapper class */
    public class HeaderInfo{
        /** @description serviceIdentifier parameter */
        public String serviceIdentifier{get;set;}
        /** @description operationFormat parameter */
        public String operationFormat{get;set;}
        /** @description channelIdentifier parameter */
        public String channelIdentifier{get;set;}
        /** @description bankIdentifier parameter */
        public String bankIdentifier{get;set;}
        /** @description ipFormat parameter */
        public String ipFormat{get;set;}
        /** @description loginFlag parameter */
        public Integer loginFlag{get;set;}
        /** @description languageIdentifier parameter */
        public String languageIdentifier{get;set;}
        /** @description isMultirec parameter */
        public String isMultirec{get;set;}
        /** @description userPrincipal parameter */
        public String userPrincipal{get;set;}
        /** @description stateMode parameter */
        public String stateMode{get;set;}
        /** @description formIdentifier parameter */
        public String formIdentifier{get;set;}
        /** @description accessCode parameter */
        public String accessCode{get;set;}
        /** @description loginType parameter */
        public String loginType{get;set;}
        /** @description ipAddress parameter */
        public String ipAddress{get;set;}
        /** @description deviceIdentifier parameter */
        public String deviceIdentifier{get;set;}
        /** @description deviceType parameter */
        public String deviceType{get;set;}
        /** @description machineFingerPrint parameter */
        public String machineFingerPrint{get;set;}  
    }

    /** @description bodyInfo inner class */
    public class BodyInfo {
        /** @description AccountNumber parameter */
        public String AccountNumber{get;set;}
        /** @description AccountIndicator parameter */
        public String AccountIndicator{get;set;}
    }

    /** @description Response inner class */
    public class Response {
        /** @description customLoginQNAResponse parameter */
        public QNAReponse customLoginQNAResponse{get;set;}
        /** @description status parameter */
        public String status{get;set;}
        /** @description ErrorDescription parameter */
        public String ErrorDescription{get;set;}
    }

    /** @description QNAReponse inner class */
    public class QNAReponse {
        /** @description userIdentity parameter */
        public String userIdentity{get;set;}
        /** @description Status parameter */
        public String Status{get;set;}
        /** @description StatusCode parameter */
        public String StatusCode{get;set;}
        /** @description Questions parameter */
        public List<Questions> Questions{get;set;}
    }

    /** @description Questions inner class */
    public class Questions {
        /** @description questionIdentifier parameter */
        public String questionIdentifier{get;set;}
        /** @description questionDescription parameter */
        public String questionDescription{get;set;}
        /** @description answer parameter */
        public String answer{get;set;}
    }
}