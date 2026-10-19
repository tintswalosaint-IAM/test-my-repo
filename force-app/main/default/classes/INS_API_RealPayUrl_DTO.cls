/**
 * @description DTO class for RealPayUrlRequest, RealPayUrlResponse, and RealPayErrorResponse
 * @author Shamsul Arifeen
 * @date Oct 18th 2024
 */
public class INS_API_RealPayUrl_DTO {

    /**
     * @description wrapper class for RealPayUrlRequest.
     */
    public class RealPayUrlRequest {
        public String identificationType;
        public String identityNumber;
        public String countryOfIssue;
        public String partySourceIdentifier;
        public String firstName;
        public String lastName;
        public String dateOfBirth;
        public String gender;
        public String email;
        public String cellphoneNumber;
        public Address address;
        public Contract contract;
    }

    /**
     * @description Represents the address information for RealPayUrlRequest.
     */
    public class Address {
        public String addressType;
        public String addressLine;
        public String city;
        public String postalCode;
        public String country;
    }

    /**
     * @description Represents the contract details for RealPayUrlRequest.
     */
    public class Contract {
        public String instalmentAmount;
        public Integer numberOfInstalments;
        public String instalmentStartDate;
        public Integer collectionDay;
    }

    /**
     * @description Represents the response data from the RealPay URL generation API.
     */
    public class RealPayUrlResponse {
        public String partySourceIdentifier;
        public String userId;
        public String sessionUrl;
        public String contractSequence;
    }

    /**
     * @description Represents the error response structure for the RealPay API.
     */
    public class RealPayErrorResponse {
        public ErrorDetail error;
    }

    /**
     * @description Represents the details of an error in RealPayErrorResponse.
     */
    public class ErrorDetail {
        public Integer errorCode;
        public String errorDateTime;
        public String errorMessage;
        public String errorDescription;
    }
}