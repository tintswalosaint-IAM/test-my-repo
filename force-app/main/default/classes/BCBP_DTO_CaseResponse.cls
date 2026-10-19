/***************************************************************************************
@Name of the Component : BCBP_DTO_CaseResponse
@Description : wrapper class to form responses for Rest Service
@Author : Siarhei Maroz
@Created Date : 17 July 2025
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 17 July 2025
@Modification description: this class was created to keep callout responses for
 httpGet methods for BCBP_URL_CrossOrgCasesRest and BCBP_URL_CrossOrgGetCaseDataRest classes
 User Story: BCBSFSA-290 | BCBSFSA-291
***************************************************************************************/
global with sharing class BCBP_DTO_CaseResponse {
    public Boolean success;
    public String message;
    public String caseId;
    public String caseNumber;
    public Case caseRecord;
    public List<String> errors;
}