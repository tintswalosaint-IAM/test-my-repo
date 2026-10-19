/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
public  class BCB_Identify_OCRBean {
	/** @description attribute **/	
    public String ID{get;set;}    
	/** @description attribute **/	
	public cls_FirstName FirstName{get;set;}     
	/** @description attribute **/
	public cls_Surname Surname{get;set;}     
	/** @description attribute **/
	public cls_DocumentTypeDetected DocumentTypeDetected{get;set;}    
	/** @description attribute **/
	public cls_DocumentTypeSelected DocumentTypeSelected{get;set;}     
	/** @description attribute **/
	public cls_IdentityDocumentMetadatas[] IdentityDocumentMetadatas{get;set;}  
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_FirstName {
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_Surname {
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_DocumentTypeDetected {
		/** @description attribute **/	
		public String ID{get;set;}     
		/** @description attribute **/	
		public String Name{get;set;}   
		  /** @description attribute **/
		public String Description{get;set;}     
		/** @description attribute **/	
		public Integer DocType{get;set;}     
		/** @description attribute **/
		public String IssueCountryCode{get;set;}     
		/** @description attribute **/	
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_DocumentTypeSelected {
		/** @description attribute **/	
		public String ID{get;set;}     
		/** @description attribute **/	
		public String Name{get;set;}     
		/** @description attribute **/	
		public String Description{get;set;}     
		/** @description attribute **/	
		public Integer DocType{get;set;}     
		/** @description attribute **/	
		public String IssueCountryCode{get;set;}     	
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_IdentityDocumentMetadatas {
		/** @description attribute **/	
		public String ID{get;set;}     
		/** @description attribute **/	
		public cls_Metadata Metadata{get;set;}     
		/** @description attribute **/
		public String FrontTypeIDDetected{get;set;}    
		/** @description attribute **/	
		public String BackTypeIDDetected{get;set;}     
		/** @description attribute **/	
		public cls_FrontVIZFields FrontVIZFields{get;set;}     
		/** @description attribute **/
		public cls_BackVIZFields BackVIZFields{get;set;}     
		/** @description attribute **/
		public cls_FrontMRZFields FrontMRZFields{get;set;}     
		/** @description attribute **/
		public cls_BackMRZFields BackMRZFields{get;set;}     
		/** @description attribute **/
		public cls_DocumentTypeFront DocumentTypeFront{get;set;}    
		/** @description attribute **/
		public cls_DocumentTypeBack DocumentTypeBack{get;set;}     
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_Metadata {
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_FrontVIZFields {
		/** @description attribute **/	
		public String DocumentNumber{get;set;}    
		 /** @description attribute **/	
		public String LastName{get;set;}     
		/** @description attribute **/	
		public String FirstName{get;set;}     
		/** @description attribute **/	
		public String DateOfExpiry{get;set;}    
		 /** @description attribute **/	
		public String Nationality{get;set;}    
		/** @description attribute **/	
		public String PersonalNumber{get;set;}    
		 /** @description attribute **/	
		public String DateOfBirth{get;set;}    
		 /** @description attribute **/	
		public String Gender{get;set;}    	
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_BackVIZFields {
		/** @description attribute **/	
		public String District{get;set;}     
		/** @description attribute **/	
		public String Location{get;set;}     
		/** @description attribute **/	
		public String MRTD{get;set;}     
		/** @description attribute **/	
		public String SubLocation{get;set;}     
		/** @description attribute **/	
		public String Division{get;set;}     
		/** @description attribute **/	
		public String Village{get;set;}    
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_FrontMRZFields {
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_BackMRZFields {
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_DocumentTypeFront {
		/** @description attribute **/	
		public String ID{get;set;}     
		/** @description attribute **/	
		public String Name{get;set;}     
		/** @description attribute **/	
		public String Description{get;set;}     
		/** @description attribute **/	
		public Integer DocType{get;set;}    
		/** @description attribute **/	
		public String IssueCountryCode{get;set;}     
	}
	/**
* @description Class used as Wrapper Class to body 
*
*@author Sivaprasad
*
* @date July 2022
*/
	public class cls_DocumentTypeBack {
		/** @description attribute **/	
		public String ID{get;set;}     
		/** @description attribute **/	
		public String Name{get;set;}    
		 /** @description attribute **/	
		public String Description{get;set;}     
		/** @description attribute **/	
		public Integer DocType{get;set;}     
		/** @description attribute **/	
		public String IssueCountryCode{get;set;}     
	}
}