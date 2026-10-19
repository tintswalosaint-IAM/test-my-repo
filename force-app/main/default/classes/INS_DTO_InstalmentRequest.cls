/**
 * @description       : DTO class for the payment collection request and response
 * @author            : Jaco de Lange
 * @group             : IAM : SFP-48886 - Premium Collection Gateway - Initiate payment collection via Mobility
 * @created date      : 07-01-2025
 * @last modified     : Jaco de Lange : 20-10-2025
 * @Modification      : SFP-53852 - Add the productId to the instalment request class
 *                    : Add additional parameters to the InstalmentResponse class
**/
public class INS_DTO_InstalmentRequest {
    public List<InstalmentResponse> instalmentResponse{get;set;}

    public class InstalmentRequest {
        public String paymentReferenceId{get;set;}
        public String paymentCollectionType{get;set;}
        public String contractNumber{get;set;}
        public String cellphoneNumber{get;set;}
        public String instalmentAmount{get;set;}
        public String productId{get;set;}
    }
    public class InstalReq {
        public InstalmentRequest instalmentRequest{get;set;}
    }
    public class InstalmentResponse {
        public String contractNumber{get;set;}
        public String contractSequence{get;set;}
        public String merchantRequestID{get;set;}
        public String checkoutRequestID{get;set;}
        public String instalmentAmount{get;set;}
        public String instalmentReferenceNumber{get;set;}
        public String responseMessage{get;set;}
        public String instalmentStatus{get;set;}
    }
}