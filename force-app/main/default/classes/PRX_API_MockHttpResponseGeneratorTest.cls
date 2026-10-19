/***************************************************************************************
@ Author            :prem.lingala@standardbank.co.za
@ Date              :Mar 2024
@ Name of the Class :PRX_API_MockHttpResponseGeneratorTest
@description       :This Apex class, PRX_API_MockHttpResponseGeneratorTest, is designed to  
                     generate mock HTTP responses for testing HTTP callouts in the context
                     of Salesforce Apex unit tests. It implements the HttpCalloutMock interface
                     to provide custom responses based on the endpoint of the HTTP request.

                      Key Features:
                      - Implements HttpCalloutMock to simulate HTTP responses during unit testing.
                      - Generates specific responses based on different request endpoints.

                      The class includes the following mock responses:
                      1. For the endpoint 'https://api-gatewaynp.standardbank.co.za/npextorg/extnonprod/questionnaire/answer':
                         - Simulates a successful response with sample JSON data representing an activity and questions.

                      2. For the endpoint 'https://api-gatewaynp.standardbank.co.za/npextorg/extnonprod/sysauth/oauth2/token':
                         - Simulates a successful response with an access token and relevant metadata.

                      3. For the endpoint 'https://api-gatewaynp.standardbank.co.za/npextorg/extnonprod/questionnaire/CC10F219-6F34-4573-B65F-FAF971CDCE84':
                         - Simulates a successful response with JSON data representing user history information.

                      4. For the endpoint 'https://api-gatewaynp.standardbank.co.za/npextorg/extnonprod/questionnaire/CC10F219-6F34-4573-B65F-FAF971CDCE84?reference=0053L0000046SgbQAE':
                         - Simulates a successful response with JSON data representing user history information for a specific reference.

                      5. For any other endpoint:
                         - Simulates a generic successful response with a standard host header info.

                      Note: The class includes inner classes representing the structure of the JSON responses,
                            such as UserHistoryResponse, HostHeaderInfo, Module, Section, Activity, and Question.
@ Last Modified By  :prem.lingala@standardbank.co.za
@ Last Modified On  :Mar 2024
@ Jira Ticket : SFP-29221  
* ---------------------------------------------------------------------------
*version   Date               Developer                  Description
* ---------------------------------------------------------------------------
  1.0    Mar 2024   prem.lingala@standardbank.co.za    60.0
***************************************************************************************/
@isTest
public class PRX_API_MockHttpResponseGeneratorTest implements HttpCalloutMock {
    /**
     * @description Responds to an HTTP request based on the request endpoint.
     * @param req The HTTP request.
     * @return The HTTP response.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
        if(req.getEndpoint() == 'https://api-gatewaynp.standardbank.co.za/npextorg/extnonprod/questionnaire/answer'){
                             

            String responseBody = '{'+
                '    "hostHeaderInfo": {'+
                '        "responseCode": "000",'+
                '        "responseMessage": "SUCCESS"'+
                '    },'+
                '    "activity": {'+
                '        "id": 31,'+
                '        "uid": "aac509a3-40e2-4a11-ba6e-ce64c14cd464",'+
                '        "title": "4 Emergency Fund",'+
                '        "text": "How do you budget?",'+
                '        "icon": "icn_cash_notes",'+
                '        "duration": 360.0,'+
                '        "completionMessage": "You can now budget",'+
                '        "completionTitle": "Yay!!",'+
                '        "completionImage": "img_bulb",'+
                '        "completionAnimation": "gif_success",'+
                '        "sectionUid": "2664c975-1502-4b5a-ab4d-902af6cbcfa1",'+
                '        "questionCount": 1,'+
                '        "viewQuestionCount": 8,'+
                '        "answerCount": 1,'+
                '        "viewAnswerCount": 8,'+
                '        "formulaResult": 20,'+
                '        "order": 50,'+
                '        "questions": null,'+
                '        "nodes": null,'+
                '        "formula": "(R93)"'+
                '    },'+
                '    "questions": ['+
                '        {'+
                '            "id": 93,'+
                '            "uid": "5e81a6a5-2df0-41cf-98a2-4aee8be99dbe",'+
                '            "title": "How many months worth of savings do you have stored up in an \'emergency fund\' or savings account e.g. cash/funds available (not debt) immediately in case of an emergency?",'+
                '            "order": 1100,'+
                '            "text": "",'+
                '            "type": "Choice",'+
                '            "questionIcon": "icn_star",'+
                '            "config": "{\"options\":[\"0-3 weeks\",\"1-2 months\",\"3 months\",\"4-5 months\",\"More than 6 months\"]}",'+
                '            "nodeIcon": "icn_view_list",'+
                '            "successRule": "(.*)",'+
                '            "activityNodeId": 45,'+
                '            "activityNodeUid": "6f6e0820-9dfe-4f71-bae8-ecfef6e45eb5",'+
                '            "answer": "0-3 weeks",'+
                '            "status": "success",'+
                '            "richText": null,'+
                '            "nextQuestionConditionType": 1,'+
                '            "nextQuestionConditionDescription": "Default",'+
                '            "nextQuestionConditionMap": null'+
                '        }'+
                '    ],'+
                '    "nodes": ['+
                '        {'+
                '            "id": 45,'+
                '            "uid": "6f6e0820-9dfe-4f71-bae8-ecfef6e45eb5",'+
                '            "order": 1040,'+
                '            "title": "4 Emergency Fund",'+
                '            "successText": "Complete",'+
                '            "failedText": "Incomplete",'+
                '            "icon": "icn_people_3",'+
                '            "activityId": 31,'+
                '            "activityUid": "aac509a3-40e2-4a11-ba6e-ce64c14cd464",'+
                '            "summary": null,'+
                '            "success": true,'+
                '            "displayText": null'+
                '        }'+
                '    ]'+
                '}';  
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(200);
        }else if(req.getEndpoint() == 'https://api-gatewaynp.standardbank.co.za/npextorg/extnonprod/sysauth/oauth2/token'){
            
            String responseBody = '{'+
                '    "token_type": "Bearer",'+
                '    "access_token": "AAIgNzdhZTExMjY0OTg2MzExYzU1MjE5MmQ5MmU1NzRhYmE9yhWSp5qNn-xrxyGPwJo1WYOVQr9n2yhN6kMtjmnQWt9a-08lqqHxDupfuQndO8oRBYaf7x4vKUHpVPVk8mnpIxEJ-mfdkMGnu75D3zV2EZ31fKOi8y0AZZ4K5UCaNGQTl9Ad10L0kAOava32kA-f",'+
                '    "scope": "vas",'+
                '    "expires_in": 7200,'+
                '    "consented_on": 1704896595,'+
                '    "metadata": "error on metadata url"'+
                '}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(200);
        }else if(req.getEndpoint() == 'https://api-gatewaynp.standardbank.co.za/npextorg/extnonprod/questionnaire/CC10F219-6F34-4573-B65F-FAF971CDCE84' || req.getEndpoint() == 'https://api-gatewaynp.standardbank.co.za/npextorg/extnonprod/questionnaire/CC10F219-6F34-4573-B65F-FAF971CDCE84?reference='+UserInfo.getUserId()){  
                        

            List<Activity> activities = new List<Activity>();
            Activity activity1 = new Activity();
            activity1.id = 30;
            activity1.title = 'General';
            activity1.formulaResult = 0;
            List<Question> questions1 = new List<Question>();
            Question question1 = new Question();
            question1.id = 79;
            question1.title = 'How do you feel about your current financial situation?';
            question1.type = 'Choice';
            question1.config = '{"options":["Very Financially Unhealthy","Financially Unhealthy","Somewhat Healthy","Financially Healthy","Financially Thriving"]}';
            question1.answer = 'Somewhat Healthy';
            questions1.add(question1);
            activity1.questions = questions1;
            activities.add(activity1);            
            List<Section> sections = new List<Section>();
            Section section = new Section();
            section.id = 22;
            section.formulaResult = 174;
            section.activities = activities;
            sections.add(section);            
            List<Module> modules = new List<Module>();
            Module module = new Module();
            module.id = 3;
            module.sections = sections;
            modules.add(module);            
            UserHistoryResponse userHistoryResponse = new UserHistoryResponse();
            userHistoryResponse.modules = modules;            
            String responseBody = JSON.serialize(userHistoryResponse);            
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('https://api-gatewaynp.standardbank.co.za/npextorg/extnonprod/experience/LeadandOpportunityManagement/v2')){
                                    

            String responseBody = '{"LeadGenerationResponse":{"id":"00Q3M000007btlgUAA","message":"Lead successfully created on Salesforce"}}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(200);
        }
        else{
            String responseBody = '{' +
                '  "hostHeaderInfo": {' +
                '    "responseCode": "000",' +
                '    "responseMessage": "SUCCESS"' +
                '  }' +
                '}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(200);
        }
        return res;
    }
     /**
     * @description Inner class representing the structure of the JSON response for user history information.
     */
    public class UserHistoryResponse {
        public List<Module> modules;
    }
    /**
     * @description Inner class representing the structure of the JSON response for module information.
     */
    public class Module {
        public Integer id;
        public List<Section> sections;
    }
     /**
     * @description Inner class representing the structure of the JSON response for section information.
     */
    public class Section {
        public Integer id;
        public Integer formulaResult;
        public List<Activity> activities;
    }
   /**
     * @description Inner class representing the structure of the JSON response for activity information.
     */    
    public class Activity {
        public Integer id;
        public String title;
        public Integer formulaResult;
        public List<Question> questions;
    }
     /**
     * @description Inner class representing the structure of the JSON response for question information.
     */
    public class Question {
        public Integer id;
        public String title;
        public String text;
        public String type;
        public String config;
        public String answer;
    }
}