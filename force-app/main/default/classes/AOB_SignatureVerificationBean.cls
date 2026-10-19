/**
* @description Bean  Class for dealing with signature api and sending the result to the main container and storing the values in the wrapper
*
*
* @author Amarnath Reddy(amarnath.reddy@stanndardbank.co.za)
* @date june 2022
*/
public without sharing class AOB_SignatureVerificationBean {
    /** @description Body Parameter */
    public BodyInfo Body{get;set;}
    
    /** @description BodyInfo class */
    public class BodyInfo {
        /** @description signatureAddRequest parameter */
        public SignatureAddRequestInfo signatureAddRequest{get;set;}
    }
    
    /** @description SignatureAddRequestInfo class */
    public class SignatureAddRequestInfo {
        /** @description customerNumber parameter */
        public String customerNumber{get;set;}
        /** @description bankIdentifier parameter */
        public String bankIdentifier{get;set;}
        /** @description imageAccessCode parameter */
        public String imageAccessCode{get;set;}
        /** @description signatureFile parameter */
        public String signatureFile{get;set;}
        /** @description pictureFile parameter */
        public String pictureFile{get;set;}
    }

}