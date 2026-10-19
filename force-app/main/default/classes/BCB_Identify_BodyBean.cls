/**
* @description Class used as Wrapper Class to display field info
*
* @author Ruchi Agarwal (agrawalr@stanbic.com)
*
* @date July 2023
*/

public inherited sharing class BCB_Identify_BodyBean {
    /** @description attribute **/
    public String ApiKey{get;set;}
    /** @description attribute **/
    public String Secret{get;set;}
    /** @description attribute **/
    public Body Body{get;set;}
    /** @description attribute **/
    public String Url{get;set;}
    /** @description attribute **/
    public String Method{get;set;}
/**
* @description Class used as Wrapper Class to body 
*
* @author Yashwanth Tikkisetti (yash.tikkisetti@standardbank.co.za)
*
* @date July 2022
*/
    public class Body {
        /** @description attribute **/
        public String ApplicationId{get;set;}
        /** @description attribute **/
        public String IdNumber{get;set;}
        /** @description attribute **/
        public String ClientReference{get;set;}
        /** @description attribute **/
        public Integer DHACheckDisabled{get;set;}
        /** @description attribute **/
        public Integer IDValidationDisabled{get;set;}
    }
/**
* @description Class used as Wrapper Class to Response 
*
* @author Yashwanth Tikkisetti (yash.tikkisetti@standardbank.co.za)
*
* @date July 2022
*/
    public class Response {
        /** @description attribute **/
        public Boolean LivenessFRMatch{get;set;}
        /** @description attribute **/
        public Decimal LivenessFRScore{get;set;}
        /** @description attribute **/
        public String DocumentTypeIDDetected{get;set;}
        /** @description attribute **/
        public List<IdentityImages> IdentityImages{get;set;}
         /** @description attribute **/
        public String DateOfExpiry{get;set;}
           /** @description attribute **/
         public String PersonalNumber{get;set;}
    }
/**
* @description Class used as Wrapper Class to IdentityImages 
*
* @author Yashwanth Tikkisetti (yash.tikkisetti@standardbank.co.za)
*
* @date July 2022
*/
    public class IdentityImages {
        /** @description attribute **/
        public String ID{get;set;}
        /** @description attribute **/
        public String IdentityID{get;set;}
        /** @description attribute **/
        public Blob Image{get;set;}
        /** @description attribute **/
        public ImageType ImageType{get;set;}
    }
/**
* @description Class used as Wrapper Class to ImageType 
*
* @author Yashwanth Tikkisetti (yash.tikkisetti@standardbank.co.za)
*
* @date July 2022
*/
    public class ImageType {
        /** @description attribute **/
        public String Description{get;set;}
        /** @description attribute **/
        public String ID{get;set;}
    }
}