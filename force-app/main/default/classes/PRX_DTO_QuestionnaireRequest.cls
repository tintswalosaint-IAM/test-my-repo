/**
 * @description Inbound Data Transfer Objects (DTOs) for the PRX Questionnaire REST API.
 *              Represents the request payload structure received from Mall Org, containing
 *              respondent metadata and individual question response entries.
 *              Used for JSON deserialisation of the inbound REST request body in
 *              PRX_REST_QuestionnaireResponse.
 * Ver       Date         Author                              Modification       
   1.0      JAN 2026   Taimoor.Shaik@standardbank.co.za     Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119, 172, 270)
 */
global with sharing class PRX_DTO_QuestionnaireRequest {

    /**
     * @description Top-level wrapper deserialised from the inbound JSON request body.
     *              Contains respondent identity fields and the list of question responses.
     */
    global class RequestWrapper {
        /** @description List of individual question responses submitted by the respondent. */
        public List<QuestionResponse> responses;
        /** @description Salesforce User ID or external identifier of the respondent. */
        public String userId;
        /** @description Indicates whether the questionnaire submission is fully completed. */
        public Boolean isCompleted;
        /** @description Person Account ID type (e.g. National ID, Passport). */
        public String idType;
        /** @description Person Account ID or Passport number of the respondent. */
        public String idNumber;
        /** @description Ping identity provider ID for the respondent. */
        public String pingId;
        /** @description Date of birth in DD-MM-YYYY format, as received from Mall Org. */
        public String dob;
        /** @description Assessment start datetime in ISO 8601 UTC format (Z suffix). */
        public String startTime;
        /** @description Full name of the user who submitted the assessment. */
        public String name;
    }

    /**
     * @description Represents a single question-response pair within the request payload.
     *              Supports standard, currency, and conditional-input question types.
     */
    global class QuestionResponse {
        /** @description Optional Salesforce Record ID of the question (fallback when order is absent). */
        public String questionId;
        /** @description Display text of the question as shown to the respondent. */
        public String questionText;
        /** @description Text value of the selected or entered answer. */
        public String value;
        /** @description Question type discriminator used for numeric conversion (e.g. Currency). */
        public String type;
        /** @description One-based order position of the question in the questionnaire. */
        public Integer order;
        /** @description Category grouping for this question, provided by Mall Org directly. */
        public String category;
        /** @description Numeric value entered via a conditional input field (e.g. a custom amount). */
        public Decimal conditionalValue;
        /** @description True when this question has an active conditional numeric input field. */
        public Boolean hasConditionalInput;
    }
}