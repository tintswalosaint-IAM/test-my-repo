/***************************************************************************************
@Name of the Component : BCBP_DTO_CaseRequest
@Description : wrapper class to form requests for Rest Service
@Author : Siarhei Maroz
@Created Date : 06 October 2025
 User Story: BCBSFSA-429 | BCBSFSA-641
***************************************************************************************/
global class BCBP_DTO_CaseRequest {
        public String id;
        public String subject;
        public String description;
        public String origin;
        public String priority;
        public String contactId;
        public String accountId;
        public String category;
        public String subCategory;
        public String client;
        public String name;
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public String country;
        public String type;
        public Map<String, Object> customFields;
    }