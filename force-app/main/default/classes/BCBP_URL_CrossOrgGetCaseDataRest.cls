/***************************************************************************************
@Name of the Component : BCBP_URL_CrossOrgGetCaseDataRest
@Description : Rest Service for getting cases to external systems
@Author : Siarhei Maroz
@Created Date : 17 July 2025
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 18 July 2025
@Modification description: this RestResource class uses to get case by Id or CaseNumber from external services
 User Story: BCBSFSA-290 | BCBSFSA-291
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 06 October 2025
@Modification description: added addCaseComment http put method
 User Story: BCBSFSA-429 | BCBSFSA-641 | BCBSFSA-1765
***************************************************************************************/
@RestResource(urlMapping='/crossOrgGetCaseData/*')
global with sharing class BCBP_URL_CrossOrgGetCaseDataRest {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(BCBP_URL_CrossOrgGetCaseDataRest.class.getName());
    private static sbgplatform.fflib_SObjectUnitOfWork uow =
        (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();

    /**
   * @description Global static method to handle the HTTP PUT request for updating case description field
   * @return BCBP_DTO_CaseResponse
  */
    @HttpPut
    global static BCBP_DTO_CaseResponse addCaseComment() {
        BCBP_DTO_CaseResponse response = new BCBP_DTO_CaseResponse();
        response.errors = new List<String>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            BCBP_DTO_CaseRequest caseData =
                    (BCBP_DTO_CaseRequest)JSON.deserialize(req.requestBody.toString(), BCBP_DTO_CaseRequest.class);

            CaseComment newCaseComment = new CaseComment(
                    ParentId        = caseData.id,
                    CommentBody     = caseData.description,
                    IsPublished     = true
            );

            if (Schema.SobjectType.CaseComment.isCreateable()){
                uow.registerNew(newCaseComment);
                uow.commitWork();
            }

            response.success = true;
            response.message = 'Case updated successfully';
            response.caseId = caseData.id;

        } catch (Exception e) {
            res.statusCode = 400;
            response.success = false;
            response.message = 'Failed to update case: ' + e.getMessage();
            response.errors.add(e.getMessage());

            LOGGER.error(e.getMessage(), new String[] {BCBP_URL_CrossOrgGetCaseDataRest.class.getName(), 'Method: addCaseComment'}, e);
        }

        return response;
    }

    /**
     * @description Global static method to handle the HTTP GET request for getting cases
     * @return BCBP_DTO_CaseResponse
	*/
    @HttpGet
    global static BCBP_DTO_CaseResponse getCase() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        BCBP_DTO_CaseResponse response = new BCBP_DTO_CaseResponse();
        response.errors = new List<String>();
        
        try {

            String caseParameter = req.requestURI.substringAfterLast('/');
            if (String.isBlank(caseParameter)) {
                throw new IllegalArgumentException('No cases found: ' + caseParameter);
            }

            List<Case> caseRecords = new List<Case>();
            try {
                String caseId = Id.valueOf(caseParameter); //check if caseParameter is case Id
                caseRecords = SEL_Case.newInstance().selectCaseById(caseId);
            } catch (StringException e) {
                caseRecords = SEL_Case.newInstance().selectCaseByNumber(caseParameter);
            }

            if (caseRecords.isEmpty()) {
                throw new IllegalArgumentException('No cases found: ' + caseParameter);
            }
            
            response.success = true;
            response.message = 'Case retrieved successfully';
            response.caseRecord = caseRecords.get(0);
            
        } catch (Exception e) {
            res.statusCode = 400;
            response.success = false;
            response.message = 'Failed to retrieve case: ' + e.getMessage();
            response.errors.add(e.getMessage());

            LOGGER.error(e.getMessage(), new String[] {BCBP_URL_CrossOrgGetCaseDataRest.class.getName(), 'Method: getCase'}, e);
        }
        
        return response;
    }
}