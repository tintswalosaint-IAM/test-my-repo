/**
 * @description Outbound Data Transfer Objects (DTOs) for the PRX Questionnaire REST API.
 *              Represents the response payload returned to Mall Org after processing a
 *              questionnaire submission, including per-category financial activity scores.
 *              Used for JSON serialisation of the REST response body in
 *              PRX_REST_QuestionnaireResponse.
 *
 * Ver       Date         Author                              Modification       
   1.0      JAN 2026   Taimoor.Shaik@standardbank.co.za     Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119, 172, 270)
 */
global with sharing class PRX_DTO_QuestionnaireResponse {

    /**
     * @description Top-level response wrapper serialised as the JSON response body.
     *              Communicates success status, message, record count, and activity scores.
     */
    global class ResponseWrapper {
        /** @description True when the operation completed without errors. */
        public Boolean success;
        /** @description Human-readable outcome or error message for the caller. */
        public String message;
        /** @description Count of CMN_Question_Response__c records successfully persisted. */
        public Integer recordsSaved;
        /** @description List of financial activity scores derived from the assessment. */
        public List<ActivityDTO> activities;

        /**
         * @description Initialises the response wrapper in a safe default failed state.
         *              Callers must set success = true explicitly on full completion.
         */
        public ResponseWrapper() {
            this.success = false;
            this.message = '';
            this.recordsSaved = 0;
        }
    }

    /**
     * @description Represents a single financial activity and its calculated score percentage.
     *              Activities that have no computable percentage (e.g. General) use the
     *              single-argument constructor.
     */
    global class ActivityDTO {
        /** @description Display name of the financial activity (e.g. Expenses, Insurance). */
        public String activityName;
        /** @description Calculated score percentage for this activity (null when not applicable). */
        public Decimal activityPercent;

        /**
         * @description Constructs an ActivityDTO that carries a calculated score percentage.
         * @param name Display name of the activity
         * @param percent Calculated score percentage value (0-100)
         */
        public ActivityDTO(String name, Decimal percent) {
            this.activityName = name;
            this.activityPercent = percent;
        }

        /**
         * @description Constructs an ActivityDTO without a score percentage.
         *              Used for general or placeholder activities such as General.
         * @param name Display name of the activity
         */
        public ActivityDTO(String name) {
            this.activityName = name;
        }
    }
}