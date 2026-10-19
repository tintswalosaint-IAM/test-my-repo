/**
 *  @description wrapper class  FuneralclaimResponseWrapper for INS_Funeral_Claims.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * 
 *
 * @date Feb 19th 2024
 */
public class FuneralclaimResponseWrapper {
    public FuneralFNOLResponse FuneralFNOLResponse {get;set;}
	
    /**
     * @description Class Messages.
     */
    public class Messages {
        public String MessageType {get;set;}
        public String Code {get;set;}
        public String Message {get;set;}
	}
    /**
     * @description Class FuneralFNOLResponse.
     */
	public class FuneralFNOLResponse {
        public Boolean Accepted {get;set;}
        public String Status {get;set;}
        public list<Messages> Messages {get;set;}
        public String ClaimEventNumber {get;set;}
	}
}