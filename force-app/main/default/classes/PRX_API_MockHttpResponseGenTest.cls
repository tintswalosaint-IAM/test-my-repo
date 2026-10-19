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
public class PRX_API_MockHttpResponseGenTest implements HttpCalloutMock {
    /**
     * @description Responds to an HTTP request based on the request endpoint.
     * @param req The HTTP request.
     * @return The HTTP response.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();

            String responseBody = '{'+
		'   \"hostHeaderInfo\":{'+
		'      \"responseCode\":\"000\",'+
		'      \"responseMessage\":\"SUCCESS\"'+
		'   },'+
		'   \"modules\":['+
		'      {'+
		'         \"id\":3,'+
		'         \"uid\":\"a293ed74-e50a-4d06-91e7-2f4bcc2c1ca0\",'+
		'         \"title\":\"OTHER\",'+
		'         \"dateCreated\":null,'+
		'         \"order\":3,'+
		'         \"sections\":['+
		'            {'+
		'               \"id\":22,'+
		'               \"uid\":\"2664c975-1502-4b5a-ab4d-902af6cbcfa1\",'+
		'               \"title\":\"Perx Financial Health Quiz\",'+
		'               \"icon\":\"/api/Image?directory=icons&fileName=icn_shield_plus.svg\",'+
		'               \"subtitle\":\"How are your financial habits today impacting your future\",'+
		'               \"text\":\"Your financial health score is\",'+
		'               \"legendText\":null,'+
		'               \"legendBy\":null,'+
		'               \"viewActivityCount\":2,'+
		'               \"viewActivityCompleted\":2,'+
		'               \"formula\":\"(A31 + A32 + A33 + A34 + A35) / 5\",'+
		'               \"formulaResult\":0,'+
		'               \"activities\":['+
		'                  {'+
		'                     \"id\":30,'+
		'                     \"uid\":\"e9d20342-4ec4-4956-82d8-fea826929323\",'+
		'                     \"title\":\"General\",'+
		'                     \"text\":\"Get to know you\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_people_1_nametag.svg\",'+
		'                     \"duration\":180.0,'+
		'                     \"completionMessage\":\"You have completed this activity\",'+
		'                     \"completionTitle\":\"Well done\",'+
		'                     \"completionImage\":null,'+
		'                     \"completionAnimation\":\"/api/Image?directory=icons&fileName=gif_success.gif\",'+
		'                     \"sectionUid\":\"2664c975-1502-4b5a-ab4d-902af6cbcfa1\",'+
		'                     \"questionCount\":1,'+
		'                     \"viewQuestionCount\":2,'+
		'                     \"answerCount\":0,'+
		'                     \"viewAnswerCount\":2,'+
		'                     \"formulaResult\":null,'+
		'                     \"order\":20000,'+
		'                     \"questions\":['+
		'                        {'+
		'                           \"id\":79,'+
		'                           \"uid\":\"7a90abae-6545-4807-9709-2b4b77e100ed\",'+
		'                           \"title\":\"How do you feel about your current financial situation?\",'+
		'                           \"order\":20010,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Choice\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"\\\",\\n  \\\"label\\\": \\\"Make a Choice\\\",\\n  \\\"options\\\": [\\n    \\\"Very Financially Unhealthy\\\",\\n    \\\"Financially Unhealthy\\\",\\n    \\\"Somewhat Healthy\\\",\\n    \\\"Financially Healthy\\\",\\n    \\\"Financially Thriving\\\"\\n  ]\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"a910c99d-b66f-4043-bceb-edafb87c7164\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":3,'+
		'                           \"nextQuestionConditionDescription\":\"End\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        }'+
		'                     ],'+
		'                     \"nodes\":['+
		'                        {'+
		'                           \"id\":44,'+
		'                           \"uid\":\"a910c99d-b66f-4043-bceb-edafb87c7164\",'+
		'                           \"order\":20000,'+
		'                           \"title\":\"General\",'+
		'                           \"successText\":\"Complete\",'+
		'                           \"failedText\":\"Incomplete\",'+
		'                           \"icon\":\"/api/Image?directory=icons&fileName=icn_people_1_nametag.svg\",'+
		'                           \"activityId\":30,'+
		'                           \"activityUid\":\"e9d20342-4ec4-4956-82d8-fea826929323\",'+
		'                           \"summary\":null,'+
		'                           \"success\":null,'+
		'                           \"displayText\":null'+
		'                        }'+
		'                     ],'+
		'                     \"formula\":null'+
		'                  },'+
		'                  {'+
		'                     \"id\":32,'+
		'                     \"uid\":\"3df91723-a69e-4b11-8f2f-def70ad98a74\",'+
		'                     \"title\":\"Expenses Management\",'+
		'                     \"text\":\"Ensure you are spending less than what you are earning every month.\\nIt’s hard to save any money if you are overspending. \\nAnd spending more than you earn is an easy way to accumulate debt.\\n Expenses exceeding income may indicate a need for guidance in financial planning/budgeting. \\nDid you know? With a Standard Bank account, you can track your income and expenses with the ‘Money Movements’ add-on on your Banking App. \\nOur experts can help you understand where you stand financially and determine what adjustments need to be made.\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_tag_special_1.svg\",'+
		'                     \"duration\":45.0,'+
		'                     \"completionMessage\":\"You have completed this activity\",'+
		'                     \"completionTitle\":\"Well done\",'+
		'                     \"completionImage\":null,'+
		'                     \"completionAnimation\":\"/api/Image?directory=icons&fileName=gif_success.gif\",'+
		'                     \"sectionUid\":\"2664c975-1502-4b5a-ab4d-902af6cbcfa1\",'+
		'                     \"questionCount\":1,'+
		'                     \"viewQuestionCount\":2,'+
		'                     \"answerCount\":0,'+
		'                     \"viewAnswerCount\":2,'+
		'                     \"formulaResult\":null,'+
		'                     \"order\":20100,'+
		'                     \"questions\":['+
		'                        {'+
		'                           \"id\":80,'+
		'                           \"uid\":\"8032bf79-bdec-49af-ae74-913a6506d451\",'+
		'                           \"title\":\"Select what best describes your spending habits over the last year.\",'+
		'                           \"order\":20100,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Choice\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"\\\",\\n  \\\"label\\\": \\\"Make a Choice\\\",\\n  \\\"options\\\": [\\n    \\\"I spend much less than my income\\\",\\n    \\\"I spend a little more than my income\\\",\\n    \\\"I spend about equal to my income\\\",\\n    \\\"I spend slightly more than my income\\\",\\n    \\\"I spend much more than my income\\\"\\n  ]\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"48dd94ca-4b7d-4185-b4c3-37d6cb21f280\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":3,'+
		'                           \"nextQuestionConditionDescription\":\"End\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        }'+
		'                     ],'+
		'                     \"nodes\":['+
		'                        {'+
		'                           \"id\":46,'+
		'                           \"uid\":\"48dd94ca-4b7d-4185-b4c3-37d6cb21f280\",'+
		'                           \"order\":20100,'+
		'                           \"title\":\"Expenses\",'+
		'                           \"successText\":\"Complete\",'+
		'                           \"failedText\":\"Incomplete\",'+
		'                           \"icon\":\"/api/Image?directory=icons&fileName=icn_tag_special_1.svg\",'+
		'                           \"activityId\":32,'+
		'                           \"activityUid\":\"3df91723-a69e-4b11-8f2f-def70ad98a74\",'+
		'                           \"summary\":null,'+
		'                           \"success\":null,'+
		'                           \"displayText\":null'+
		'                        }'+
		'                     ],'+
		'                     \"formula\":\"(\\r\\n\\tcase\\r\\n\\t\\twhen (R80) <= 0 then 1\\r\\n\\t\\twhen (R80) > 100 then 100\\r\\n\\t\\telse (R80)\\r\\n\\tend\\r\\n)\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":33,'+
		'                     \"uid\":\"a1567a39-d026-42ed-a102-c11626ec63f6\",'+
		'                     \"title\":\"Personal Debt\",'+
		'                     \"text\":\"Your Personal Debt score compares how much you owe each month to how much you earn. \\nIf most of your budget goes towards debt, meeting your financial goals can be difficult. \\nToo much debt may indicate a lack of financial awareness and could also lead to a debt spiral. \\nRemember, your personal debt score also affects your credit score. This is therefore an important score for loan seekers. \\nDid you know? With a Standard Bank Account, you get monthly updates of your credit score with the ‘Credit Score’ add-on on your banking app.\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_loan.svg\",'+
		'                     \"duration\":0.0,'+
		'                     \"completionMessage\":\"You have completed this activity\",'+
		'                     \"completionTitle\":\"Well done\",'+
		'                     \"completionImage\":null,'+
		'                     \"completionAnimation\":\"/api/Image?directory=icons&fileName=gif_success.gif\",'+
		'                     \"sectionUid\":\"2664c975-1502-4b5a-ab4d-902af6cbcfa1\",'+
		'                     \"questionCount\":7,'+
		'                     \"viewQuestionCount\":0,'+
		'                     \"answerCount\":0,'+
		'                     \"viewAnswerCount\":0,'+
		'                     \"formulaResult\":null,'+
		'                     \"order\":20300,'+
		'                     \"questions\":['+
		'                        {'+
		'                           \"id\":115,'+
		'                           \"uid\":\"5df8ca28-bcd4-465b-ac26-0b0c417e281e\",'+
		'                           \"title\":\"Make a selection below:\",'+
		'                           \"order\":20310,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Choice\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"\\\",\\n  \\\"label\\\": \\\"Make a Choice\\\",\\n  \\\"options\\\": [\\n    \\\"I own a home and am paying a bond\\\",\\n    \\\"I own a home, fully paid off\\\",\\n    \\\"I am renting\\\",\\n    \\\"None of the above\\\"\\n  ]\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"39e543ce-13eb-45f6-a7ee-c2eb16568415\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":2,'+
		'                           \"nextQuestionConditionDescription\":\"Special\",'+
		'                           \"nextQuestionConditionMap\":\"{\\\"I own a home and am paying a bond\\\": 81, \\\"I own a home, fully paid off\\\": 116, \\\"I am renting\\\": 81, \\\"None of the above\\\": 116}\"'+
		'                        },'+
		'                        {'+
		'                           \"id\":81,'+
		'                           \"uid\":\"d70c44df-af00-41c7-9449-df0db39f0572\",'+
		'                           \"title\":\"How much do you contribute to your home loan or rent each month?\",'+
		'                           \"order\":20320,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Currency\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"Answer as a value/number format  e.g. 1 or 1000\\\",\\n  \\\"label\\\": \\\"Amount\\\"\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.*)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"39e543ce-13eb-45f6-a7ee-c2eb16568415\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":1,'+
		'                           \"nextQuestionConditionDescription\":\"Default\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        },'+
		'                        {'+
		'                           \"id\":116,'+
		'                           \"uid\":\"7e244439-1e7d-4bab-b7d2-e00f8eb289d0\",'+
		'                           \"title\":\"Make a selection below:\",'+
		'                           \"order\":20330,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Choice\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"\\\",\\n  \\\"label\\\": \\\"Make a Choice\\\",\\n  \\\"options\\\": [\\n    \\\"I own a car which I am currently paying off\\\",\\n    \\\"I own a car, fully paid off\\\",\\n    \\\"I do not own a car\\\"\\n  ]\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"39e543ce-13eb-45f6-a7ee-c2eb16568415\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":2,'+
		'                           \"nextQuestionConditionDescription\":\"Special\",'+
		'                           \"nextQuestionConditionMap\":\"{\\\"I own a car which I am currently paying off\\\": 82, \\\"I own a car, fully paid off\\\": 83, \\\"I do not own a car\\\": 83}\"'+
		'                        },'+
		'                        {'+
		'                           \"id\":82,'+
		'                           \"uid\":\"b5b8f806-5891-478a-98e1-276a32c731af\",'+
		'                           \"title\":\"How much do you spend on your vehicle repayments per month?\",'+
		'                           \"order\":20340,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Currency\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"Answer as a value/number format  e.g. 1 or 1000\\\",\\n  \\\"label\\\": \\\"Amount\\\"\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.*)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"39e543ce-13eb-45f6-a7ee-c2eb16568415\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":1,'+
		'                           \"nextQuestionConditionDescription\":\"Default\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        },'+
		'                        {'+
		'                           \"id\":83,'+
		'                           \"uid\":\"4dccf42d-dc13-49b2-a335-f6f137baa393\",'+
		'                           \"title\":\"On average how much do you pay towards paying off other debt each month e.g. credit card repayments, store credit etc.?\",'+
		'                           \"order\":20359,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Currency\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"Answer as a value/number format  e.g. 1 or 1000\\\",\\n  \\\"label\\\": \\\"Amount\\\"\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"39e543ce-13eb-45f6-a7ee-c2eb16568415\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":1,'+
		'                           \"nextQuestionConditionDescription\":\"Default\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        },'+
		'                        {'+
		'                           \"id\":84,'+
		'                           \"uid\":\"7125ec51-875c-4296-95d4-9c6fd7f43990\",'+
		'                           \"title\":\"Budgeting is key to a financially fit future. To help us to understand your current contraints, please confirm your total monthly earnings before tax and deductions?\",'+
		'                           \"order\":20360,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Currency\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"Answer as a round total, format e.g. 0 or 15000\\\",\\n  \\\"label\\\": \\\"Amount\\\"\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"39e543ce-13eb-45f6-a7ee-c2eb16568415\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":1,'+
		'                           \"nextQuestionConditionDescription\":\"Default\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        },'+
		'                        {'+
		'                           \"id\":102,'+
		'                           \"uid\":\"5d53909d-fac0-4772-a173-87c51b9c82e7\",'+
		'                           \"title\":\"To further understand your current constraints, please confirm your net monthly earnings after tax and deductions?\",'+
		'                           \"order\":20370,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Currency\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"Answer as a round total, format e.g. 0 or 15000\\\",\\n  \\\"label\\\": \\\"Amount\\\"\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"39e543ce-13eb-45f6-a7ee-c2eb16568415\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":3,'+
		'                           \"nextQuestionConditionDescription\":\"End\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        }'+
		'                     ],'+
		'                     \"nodes\":['+
		'                        {'+
		'                           \"id\":47,'+
		'                           \"uid\":\"39e543ce-13eb-45f6-a7ee-c2eb16568415\",'+
		'                           \"order\":20300,'+
		'                           \"title\":\"Personal Debt\",'+
		'                           \"successText\":\"Complete\",'+
		'                           \"failedText\":\"Incomplete\",'+
		'                           \"icon\":\"/api/Image?directory=icons&fileName=icn_house.svg\",'+
		'                           \"activityId\":33,'+
		'                           \"activityUid\":\"a1567a39-d026-42ed-a102-c11626ec63f6\",'+
		'                           \"summary\":null,'+
		'                           \"success\":null,'+
		'                           \"displayText\":null'+
		'                        }'+
		'                     ],'+
		'                     \"formula\":\"(\\r\\n\\tcase\\r\\n\\t\\twhen 100-(((Q81+Q82+Q83)/Q84)*100) <= 0 then 1\\r\\n\\t\\twhen 100-(((Q81+Q82+Q83)/Q84)*100) > 100 then 100\\r\\n\\t\\telse 100-(((Q81+Q82+Q83)/Q84)*100)\\r\\n\\tend\\r\\n)\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":34,'+
		'                     \"uid\":\"b69ef34a-f98f-4f01-a844-994a0ae924e4\",'+
		'                     \"title\":\"Insurance\",'+
		'                     \"text\":\"Insurance is a way to manage your risk. When you buy insurance, you purchase protection against unexpected financial losses.\\nThose who don’t insure core assets or their income can experience substantial loss in accumulated wealth when something goes wrong. \\nInsurance mitigates this risk and also helps make sure loved ones are provided for. \\nAn insurance pay-out could reduce your expenses in the long run and help you maintain your and your family’s financial security. \\nGet the right cover for you, your family and your assets so that if something unexpected happens, you don’t have to bear the financial impact.\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_people_hand_1.svg\",'+
		'                     \"duration\":45.0,'+
		'                     \"completionMessage\":\"You have completed this activity\",'+
		'                     \"completionTitle\":\"Well done\",'+
		'                     \"completionImage\":null,'+
		'                     \"completionAnimation\":\"/api/Image?directory=icons&fileName=gif_success.gif\",'+
		'                     \"sectionUid\":\"2664c975-1502-4b5a-ab4d-902af6cbcfa1\",'+
		'                     \"questionCount\":2,'+
		'                     \"viewQuestionCount\":2,'+
		'                     \"answerCount\":0,'+
		'                     \"viewAnswerCount\":2,'+
		'                     \"formulaResult\":null,'+
		'                     \"order\":20400,'+
		'                     \"questions\":['+
		'                        {'+
		'                           \"id\":88,'+
		'                           \"uid\":\"7f00368e-032e-410b-bb07-cfa1b702247d\",'+
		'                           \"title\":\"What insurance cover do you currently have?\",'+
		'                           \"order\":20410,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Multiple Checkboxes\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{ \\\"pretext\\\": \\\"\\\",\\n \\\"label\\\":\\\"Select all that apply\\\",\\\"options\\\":[\\\"Health insurance/medical aid\\\",\\\"Life cover\\\",\\\"Disability cover\\\",\\\"Critical illness\\\",\\\"Alternative income protection\\\",\\\"Funeral policy\\\",\\\"Home and buildings\\\",\\\"Household contents\\\",\\\"Vehicle Insurance\\\",\\\"I do not have insurance\\\",\\\"Other\\\"]}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.*)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"7299094f-e85b-4cc2-877b-df6650080073\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":1,'+
		'                           \"nextQuestionConditionDescription\":\"Default\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        },'+
		'                        {'+
		'                           \"id\":89,'+
		'                           \"uid\":\"ee2c9d7c-dffe-4bb6-b87a-59398a328730\",'+
		'                           \"title\":\"Do you feel confident that the insurance policies you have will cover you and your family in the event of theft, an accident, untimely death, injury, illness or disability?\",'+
		'                           \"order\":20412,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Choice\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"\\\",\\n  \\\"label\\\": \\\"Make a Choice\\\",\\n  \\\"options\\\": [\\n    \\\"Very confident\\\",\\n    \\\"Fairly confident\\\",\\n    \\\"Somewhat confident\\\",\\n    \\\"Only slightly confident\\\",\\n    \\\"Not at all confident\\\"\\n  ]\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"7299094f-e85b-4cc2-877b-df6650080073\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":\"Insurance\",'+
		'                           \"nextQuestionConditionType\":3,'+
		'                           \"nextQuestionConditionDescription\":\"End\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        }'+
		'                     ],'+
		'                     \"nodes\":['+
		'                        {'+
		'                           \"id\":48,'+
		'                           \"uid\":\"7299094f-e85b-4cc2-877b-df6650080073\",'+
		'                           \"order\":20400,'+
		'                           \"title\":\"Insurance\",'+
		'                           \"successText\":\"Complete\",'+
		'                           \"failedText\":\"Incomplete\",'+
		'                           \"icon\":\"/api/Image?directory=icons&fileName=icn_people_hand_1.svg\",'+
		'                           \"activityId\":34,'+
		'                           \"activityUid\":\"b69ef34a-f98f-4f01-a844-994a0ae924e4\",'+
		'                           \"summary\":null,'+
		'                           \"success\":null,'+
		'                           \"displayText\":null'+
		'                        }'+
		'                     ],'+
		'                     \"formula\":\"(\\r\\n\\tcase\\r\\n\\t\\twhen (R89) <= 0 then 1\\r\\n\\t\\twhen (R89) > 100 then 100\\r\\n\\t\\telse (R89)\\r\\n\\tend\\r\\n)\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":31,'+
		'                     \"uid\":\"aac509a3-40e2-4a11-ba6e-ce64c14cd464\",'+
		'                     \"title\":\"Emergency Fund\",'+
		'                     \"text\":\"Create an emergency fund by setting money aside that you can access if an unplanned expense occurs. \\nAn emergency could include many life events, such as job loss, major health expenses or home repairs to name a few. \\nHaving an emergency fund reduces your need to borrow money in the event of an emergency.\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_coins_hand_1.svg\",'+
		'                     \"duration\":360.0,'+
		'                     \"completionMessage\":\"You have completed this activity\",'+
		'                     \"completionTitle\":\"Well done\",'+
		'                     \"completionImage\":null,'+
		'                     \"completionAnimation\":\"/api/Image?directory=icons&fileName=gif_success.gif\",'+
		'                     \"sectionUid\":\"2664c975-1502-4b5a-ab4d-902af6cbcfa1\",'+
		'                     \"questionCount\":1,'+
		'                     \"viewQuestionCount\":8,'+
		'                     \"answerCount\":0,'+
		'                     \"viewAnswerCount\":8,'+
		'                     \"formulaResult\":null,'+
		'                     \"order\":20500,'+
		'                     \"questions\":['+
		'                        {'+
		'                           \"id\":93,'+
		'                           \"uid\":\"5e81a6a5-2df0-41cf-98a2-4aee8be99dbe\",'+
		'                           \"title\":\"How many months worth of savings do you have stored up in an \'emergency fund\' or savings account?\",'+
		'                           \"order\":20525,'+
		'                           \"text\":\"E.g. cash/funds available (not debt) immediately in case of an emergency\",'+
		'                           \"type\":\"Choice\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"\\\",\\n  \\\"label\\\": \\\"Make a Choice\\\",\\n  \\\"options\\\": [\\n    \\\"0-3 weeks\\\",\\n    \\\"1-2 months\\\",\\n    \\\"3 months\\\",\\n    \\\"4-5 months\\\",\\n    \\\"More than 6 months\\\"\\n  ]\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"6f6e0820-9dfe-4f71-bae8-ecfef6e45eb5\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":\"Save\",'+
		'                           \"nextQuestionConditionType\":3,'+
		'                           \"nextQuestionConditionDescription\":\"End\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        }'+
		'                     ],'+
		'                     \"nodes\":['+
		'                        {'+
		'                           \"id\":45,'+
		'                           \"uid\":\"6f6e0820-9dfe-4f71-bae8-ecfef6e45eb5\",'+
		'                           \"order\":20500,'+
		'                           \"title\":\"Emergency Fund\",'+
		'                           \"successText\":\"Complete\",'+
		'                           \"failedText\":\"Incomplete\",'+
		'                           \"icon\":\"/api/Image?directory=icons&fileName=icn_coins_hand_1.svg\",'+
		'                           \"activityId\":31,'+
		'                           \"activityUid\":\"aac509a3-40e2-4a11-ba6e-ce64c14cd464\",'+
		'                           \"summary\":null,'+
		'                           \"success\":null,'+
		'                           \"displayText\":null'+
		'                        }'+
		'                     ],'+
		'                     \"formula\":\"(\\r\\n\\tcase\\r\\n\\t\\twhen (R93) <= 0 then 1\\r\\n\\t\\twhen (R93) > 100 then 100\\r\\n\\t\\telse (R93)\\r\\n\\tend\\r\\n)\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":35,'+
		'                     \"uid\":\"0a7e8d69-935d-4573-a5b5-b9f345e83d3e\",'+
		'                     \"title\":\"Retirement Target\",'+
		'                     \"text\":\"Make regular savings contributions while you are working to provide an income when you reach retirement age. \\nIt’s important to start preparing for retirement so that you’ll have a nest egg to fund your golden years when you aren’t earning an income anymore. \\nThe sooner you start saving toward retirement, the more money you’ll have when you get there. \\nThere are different savings options for retirement, such as a pension fund, provident fund or retirement annuity. \\nSpeak to a Standard Bank consultant to find out what your options are and which is right for you.\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_graph_grow_1.svg\",'+
		'                     \"duration\":30.0,'+
		'                     \"completionMessage\":\"You have completed this activity\",'+
		'                     \"completionTitle\":\"Well done\",'+
		'                     \"completionImage\":null,'+
		'                     \"completionAnimation\":\"/api/Image?directory=icons&fileName=gif_success.gif\",'+
		'                     \"sectionUid\":\"2664c975-1502-4b5a-ab4d-902af6cbcfa1\",'+
		'                     \"questionCount\":4,'+
		'                     \"viewQuestionCount\":1,'+
		'                     \"answerCount\":1,'+
		'                     \"viewAnswerCount\":1,'+
		'                     \"formulaResult\":0,'+
		'                     \"order\":20600,'+
		'                     \"questions\":['+
		'                        {'+
		'                           \"id\":94,'+
		'                           \"uid\":\"cffc1b55-006f-4760-93b7-5f30afc26481\",'+
		'                           \"title\":\"How much do you contribute to your retirement savings each month?\",'+
		'                           \"order\":20610,'+
		'                           \"text\":\"Annuities, Unit Trusts, etc.\",'+
		'                           \"type\":\"Currency\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"Answer as a value/number format  e.g. 1 or 1000\\\",\\n  \\\"label\\\": \\\"Amount\\\"\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"6e0a5c03-25d5-4757-a496-67d3504841cf\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":1,'+
		'                           \"nextQuestionConditionDescription\":\"Default\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        },'+
		'                        {'+
		'                           \"id\":95,'+
		'                           \"uid\":\"cae8e299-404a-4dcb-889b-e0a92253fbe7\",'+
		'                           \"title\":\"How much do you currently have saved (in total) towards your retirement (only include pension funds, provident funds and retirement annuities)?\",'+
		'                           \"order\":20620,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Currency\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"Answer as a value/number format  e.g. 1 or 1000\\\",\\n  \\\"label\\\": \\\"Amount\\\"\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"6e0a5c03-25d5-4757-a496-67d3504841cf\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":1,'+
		'                           \"nextQuestionConditionDescription\":\"Default\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        },'+
		'                        {'+
		'                           \"id\":91,'+
		'                           \"uid\":\"ed4f4c26-92bb-4f6c-8ddd-fb13ac19f88a\",'+
		'                           \"title\":\"Do you currently have a signed will?\",'+
		'                           \"order\":20630,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Choice\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"\\\",\\n  \\\"label\\\": \\\"Make a Choice\\\",\\n  \\\"options\\\": [\\n    \\\"YES\\\",\\n    \\\"NO\\\"\\n  ]\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"6e0a5c03-25d5-4757-a496-67d3504841cf\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":1,'+
		'                           \"nextQuestionConditionDescription\":\"Default\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        },'+
		'                        {'+
		'                           \"id\":122,'+
		'                           \"uid\":\"6258e17d-5d6a-4760-938a-a424d9b1958b\",'+
		'                           \"title\":\"What is your age?\",'+
		'                           \"order\":20640,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Number\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"\\\",\\n  \\\"label\\\": \\\"Age\\\"\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.+)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"6e0a5c03-25d5-4757-a496-67d3504841cf\",'+
		'                           \"answer\":\"52\",'+
		'                           \"status\":\"success\",'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":3,'+
		'                           \"nextQuestionConditionDescription\":\"End\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        }'+
		'                     ],'+
		'                     \"nodes\":['+
		'                        {'+
		'                           \"id\":49,'+
		'                           \"uid\":\"6e0a5c03-25d5-4757-a496-67d3504841cf\",'+
		'                           \"order\":20600,'+
		'                           \"title\":\"Retirement Target\",'+
		'                           \"successText\":\"Complete\",'+
		'                           \"failedText\":\"Incomplete\",'+
		'                           \"icon\":\"/api/Image?directory=icons&fileName=icn_graph_grow_1.svg\",'+
		'                           \"activityId\":35,'+
		'                           \"activityUid\":\"0a7e8d69-935d-4573-a5b5-b9f345e83d3e\",'+
		'                           \"summary\":null,'+
		'                           \"success\":null,'+
		'                           \"displayText\":null'+
		'                        }'+
		'                     ],'+
		'                     \"formula\":\"(\\r\\n\\tcase\\r\\n\\t\\twhen ((F1,Q95,Q94,Q122 / ((Q102 * 12) / 0.04)))*100 <= 0 then 1\\r\\n\\t\\twhen ((F1,Q95,Q94,Q122 / ((Q102 * 12) / 0.04)))*100 > 100 then 100\\r\\n\\t\\telse ((F1,Q95,Q94,Q122 / ((Q102 * 12) / 0.04)))*100\\r\\n\\tend\\r\\n)\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":38,'+
		'                     \"uid\":\"5380aeb8-1d9e-4184-849f-4d1b50eb3d63\",'+
		'                     \"title\":\"Support\",'+
		'                     \"text\":\"We are here to help\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_people_1_nametag.svg\",'+
		'                     \"duration\":60.0,'+
		'                     \"completionMessage\":\"A Standard Bank Consultant will be in touch soon\",'+
		'                     \"completionTitle\":\"Thank you\",'+
		'                     \"completionImage\":null,'+
		'                     \"completionAnimation\":\"/api/Image?directory=icons&fileName=gif_success.gif\",'+
		'                     \"sectionUid\":\"2664c975-1502-4b5a-ab4d-902af6cbcfa1\",'+
		'                     \"questionCount\":1,'+
		'                     \"viewQuestionCount\":2,'+
		'                     \"answerCount\":0,'+
		'                     \"viewAnswerCount\":2,'+
		'                     \"formulaResult\":null,'+
		'                     \"order\":20700,'+
		'                     \"questions\":['+
		'                        {'+
		'                           \"id\":96,'+
		'                           \"uid\":\"cb7199b6-158e-4090-95ef-6abf58d16167\",'+
		'                           \"title\":\"What additional support do you need to reach your financial goals?\",'+
		'                           \"order\":20710,'+
		'                           \"text\":\"\",'+
		'                           \"type\":\"Multiple Checkboxes\",'+
		'                           \"questionIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"config\":\"{\\n  \\\"pretext\\\": \\\"\\\",\\n  \\\"label\\\": \\\"Select all that apply\\\",\\n  \\\"options\\\": [\\n    \\\"Budgeting\\\",\\n    \\\"Debt management\\\",\\n    \\\"Retirement planning\\\",\\n    \\\"Insurance\\\",\\n    \\\"Wills and estate planning\\\",\\n    \\\"Savings and Investments\\\",\\n    \\\"Other\\\"\\n  ]\\n}\",'+
		'                           \"nodeIcon\":\"/api/Image?directory=icons&fileName=icn_people_profile.svg\",'+
		'                           \"successRule\":\"(.*)\",'+
		'                           \"activityNodeId\":null,'+
		'                           \"activityNodeUid\":\"c882dd9d-7f96-4d10-86e8-7e053e90b3a8\",'+
		'                           \"answer\":null,'+
		'                           \"richText\":null,'+
		'                           \"nextQuestionConditionType\":3,'+
		'                           \"nextQuestionConditionDescription\":\"End\",'+
		'                           \"nextQuestionConditionMap\":null'+
		'                        }'+
		'                     ],'+
		'                     \"nodes\":['+
		'                        {'+
		'                           \"id\":53,'+
		'                           \"uid\":\"c882dd9d-7f96-4d10-86e8-7e053e90b3a8\",'+
		'                           \"order\":20700,'+
		'                           \"title\":\"Support\",'+
		'                           \"successText\":\"Complete\",'+
		'                           \"failedText\":\"Incomplete\",'+
		'                           \"icon\":\"/api/Image?directory=icons&fileName=icn_people_1_nametag.svg\",'+
		'                           \"activityId\":38,'+
		'                           \"activityUid\":\"5380aeb8-1d9e-4184-849f-4d1b50eb3d63\",'+
		'                           \"summary\":null,'+
		'                           \"success\":null,'+
		'                           \"displayText\":null'+
		'                        }'+
		'                     ],'+
		'                     \"formula\":null'+
		'                  }'+
		'               ],'+
		'               \"nodes\":['+
		'                  {'+
		'                     \"id\":44,'+
		'                     \"uid\":\"a910c99d-b66f-4043-bceb-edafb87c7164\",'+
		'                     \"order\":20000,'+
		'                     \"title\":\"General\",'+
		'                     \"successText\":\"Complete\",'+
		'                     \"failedText\":\"Incomplete\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_people_1_nametag.svg\",'+
		'                     \"activityId\":30,'+
		'                     \"activityUid\":\"e9d20342-4ec4-4956-82d8-fea826929323\",'+
		'                     \"summary\":null,'+
		'                     \"success\":null,'+
		'                     \"displayText\":null'+
		'                  },'+
		'                  {'+
		'                     \"id\":45,'+
		'                     \"uid\":\"6f6e0820-9dfe-4f71-bae8-ecfef6e45eb5\",'+
		'                     \"order\":20500,'+
		'                     \"title\":\"Emergency Fund\",'+
		'                     \"successText\":\"Complete\",'+
		'                     \"failedText\":\"Incomplete\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_coins_hand_1.svg\",'+
		'                     \"activityId\":31,'+
		'                     \"activityUid\":\"aac509a3-40e2-4a11-ba6e-ce64c14cd464\",'+
		'                     \"summary\":null,'+
		'                     \"success\":null,'+
		'                     \"displayText\":null'+
		'                  },'+
		'                  {'+
		'                     \"id\":46,'+
		'                     \"uid\":\"48dd94ca-4b7d-4185-b4c3-37d6cb21f280\",'+
		'                     \"order\":20100,'+
		'                     \"title\":\"Expenses\",'+
		'                     \"successText\":\"Complete\",'+
		'                     \"failedText\":\"Incomplete\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_tag_special_1.svg\",'+
		'                     \"activityId\":32,'+
		'                     \"activityUid\":\"3df91723-a69e-4b11-8f2f-def70ad98a74\",'+
		'                     \"summary\":null,'+
		'                     \"success\":null,'+
		'                     \"displayText\":null'+
		'                  },'+
		'                  {'+
		'                     \"id\":47,'+
		'                     \"uid\":\"39e543ce-13eb-45f6-a7ee-c2eb16568415\",'+
		'                     \"order\":20300,'+
		'                     \"title\":\"Personal Debt\",'+
		'                     \"successText\":\"Complete\",'+
		'                     \"failedText\":\"Incomplete\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_house.svg\",'+
		'                     \"activityId\":33,'+
		'                     \"activityUid\":\"a1567a39-d026-42ed-a102-c11626ec63f6\",'+
		'                     \"summary\":null,'+
		'                     \"success\":null,'+
		'                     \"displayText\":null'+
		'                  },'+
		'                  {'+
		'                     \"id\":48,'+
		'                     \"uid\":\"7299094f-e85b-4cc2-877b-df6650080073\",'+
		'                     \"order\":20400,'+
		'                     \"title\":\"Insurance\",'+
		'                     \"successText\":\"Complete\",'+
		'                     \"failedText\":\"Incomplete\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_people_hand_1.svg\",'+
		'                     \"activityId\":34,'+
		'                     \"activityUid\":\"b69ef34a-f98f-4f01-a844-994a0ae924e4\",'+
		'                     \"summary\":null,'+
		'                     \"success\":null,'+
		'                     \"displayText\":null'+
		'                  },'+
		'                  {'+
		'                     \"id\":49,'+
		'                     \"uid\":\"6e0a5c03-25d5-4757-a496-67d3504841cf\",'+
		'                     \"order\":20600,'+
		'                     \"title\":\"Retirement Target\",'+
		'                     \"successText\":\"Complete\",'+
		'                     \"failedText\":\"Incomplete\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_graph_grow_1.svg\",'+
		'                     \"activityId\":35,'+
		'                     \"activityUid\":\"0a7e8d69-935d-4573-a5b5-b9f345e83d3e\",'+
		'                     \"summary\":null,'+
		'                     \"success\":null,'+
		'                     \"displayText\":null'+
		'                  },'+
		'                  {'+
		'                     \"id\":53,'+
		'                     \"uid\":\"c882dd9d-7f96-4d10-86e8-7e053e90b3a8\",'+
		'                     \"order\":20700,'+
		'                     \"title\":\"Support\",'+
		'                     \"successText\":\"Complete\",'+
		'                     \"failedText\":\"Incomplete\",'+
		'                     \"icon\":\"/api/Image?directory=icons&fileName=icn_people_1_nametag.svg\",'+
		'                     \"activityId\":38,'+
		'                     \"activityUid\":\"5380aeb8-1d9e-4184-849f-4d1b50eb3d63\",'+
		'                     \"summary\":null,'+
		'                     \"success\":null,'+
		'                     \"displayText\":null'+
		'                  }'+
		'               ],'+
		'               \"learn\":['+
		'                  {'+
		'                     \"id\":455,'+
		'                     \"order\":2,'+
		'                     \"type\":\"banner\",'+
		'                     \"detail\":\"\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":456,'+
		'                     \"order\":20,'+
		'                     \"type\":\"h1\",'+
		'                     \"detail\":\"Welcome To Your Financial Health Quiz\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":457,'+
		'                     \"order\":30,'+
		'                     \"type\":\"subtitle\",'+
		'                     \"detail\":\"How are your financial habits today impacting your future?\\r\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":465,'+
		'                     \"order\":32,'+
		'                     \"type\":\"spacer\",'+
		'                     \"detail\":\"\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":464,'+
		'                     \"order\":34,'+
		'                     \"type\":\"paragraph\",'+
		'                     \"detail\":\"\",'+
		'                     \"extraConfig\":\"[\\n  {\\n    \\\"text\\\": \\\"Standard Bank is here to help you unlock key insights about how your current financial health may influence your future. In a few easy steps, see if you are financially prepared for whatever the future holds.\\\",\\n    \\\"format\\\": \\\"none\\\"\\n  }\\n]\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":460,'+
		'                     \"order\":37,'+
		'                     \"type\":\"spacer\",'+
		'                     \"detail\":\"\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":462,'+
		'                     \"order\":40,'+
		'                     \"type\":\"h2\",'+
		'                     \"detail\":\"Activities\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":568,'+
		'                     \"order\":42,'+
		'                     \"type\":\"subtitle\",'+
		'                     \"detail\":\"The Quiz will guide you through several activities\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":459,'+
		'                     \"order\":50,'+
		'                     \"type\":\"activity\",'+
		'                     \"detail\":\"32\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":541,'+
		'                     \"order\":52,'+
		'                     \"type\":\"activity\",'+
		'                     \"detail\":\"33\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":542,'+
		'                     \"order\":54,'+
		'                     \"type\":\"activity\",'+
		'                     \"detail\":\"34\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":543,'+
		'                     \"order\":56,'+
		'                     \"type\":\"activity\",'+
		'                     \"detail\":\"31\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":544,'+
		'                     \"order\":58,'+
		'                     \"type\":\"activity\",'+
		'                     \"detail\":\"35\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":461,'+
		'                     \"order\":72,'+
		'                     \"type\":\"spacer\",'+
		'                     \"detail\":\"\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":463,'+
		'                     \"order\":80,'+
		'                     \"type\":\"table\",'+
		'                     \"detail\":\"3\",'+
		'                     \"extraConfig\":\"{\\n  \\\"items\\\": [\\n    {\\n      \\\"icon\\\": \\\"/api/Image?directory=icons&fileName=icn_hourglass.svg\\\",\\n      \\\"paragraph\\\": [\\n        {\\n          \\\"text\\\": \\\"Under 5 Minutes\\\",\\n          \\\"format\\\": \\\"bold\\\"\\n        }\\n      ],\\n      \\\"align\\\": \\\"center\\\",\\n      \\\"width\\\": 0.33\\n    },\\n    {\\n      \\\"icon\\\": \\\"/api/Image?directory=icons&fileName=icn_people_hand 1.svg\\\",\\n      \\\"paragraph\\\": [\\n        {\\n          \\\"text\\\": \\\"No Obligations\\\",\\n          \\\"format\\\": \\\"bold\\\"\\n        }\\n      ],\\n      \\\"align\\\": \\\"center\\\",\\n      \\\"width\\\": 0.34\\n    },\\n    {\\n      \\\"icon\\\": \\\"/api/Image?directory=icons&fileName=icn_shield_plus 1.svg\\\",\\n      \\\"paragraph\\\": [\\n        {\\n          \\\"text\\\": \\\"Secure\\\",\\n          \\\"format\\\": \\\"bold\\\"\\n        }\\n      ],\\n      \\\"align\\\": \\\"center\\\",\\n      \\\"width\\\": 0.33\\n    }\\n  ]\\n}\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":467,'+
		'                     \"order\":140,'+
		'                     \"type\":\"spacer\",'+
		'                     \"detail\":\"\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":567,'+
		'                     \"order\":200,'+
		'                     \"type\":\"h2\",'+
		'                     \"detail\":\"Perx Financial Health Quiz T&C\'s\",'+
		'                     \"extraConfig\":\"\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":566,'+
		'                     \"order\":210,'+
		'                     \"type\":\"paragraph\",'+
		'                     \"detail\":\"\",'+
		'                     \"extraConfig\":\"[\\r\\n  {\\r\\n    \\\"text\\\": \\\"Before completing the financial health check, please read these terms carefully. If you do not accept the terms, please do not proceed with the financial health check. \\\\n1. Your participation in the financial health check is voluntary and you may stop at any point. \\\\n2. You acknowledge that incorrect or incomplete information provided may lead to incorrect or misleading results. \\\\n3. We will use the information you provide to compile your financial health results. We will process your personal information in terms of applicable data legislation and our privacy statement which can be found on our website (https://www.standardbank.co.za/southafrica/personal/aboutus/legal/privacy-statement). \\\\n4. The financial health results should be interpreted with the assistance of a Standard Bank Representative/Liberty Advisor. Any financial decisions taken following such a discussion should be made in consultation with a qualified professional. \\\\n5. Standard Bank and its subsidiaries, representatives or partners cannot be held liable for any loss or damage (including direct, indirect, consequential, incidental and exemplary loss or damages), arising out of decisions made by you or a third party based on the financial health results. \\\\n6. A Standard Bank representative will contact you to discuss your results upon completion of this financial health check.\\\",\\r\\n    \\\"format\\\": \\\"none\\\"\\r\\n  }\\r\\n]\"'+
		'                  },'+
		'                  {'+
		'                     \"id\":466,'+
		'                     \"order\":999,'+
		'                     \"type\":\"next\",'+
		'                     \"detail\":\"0\",'+
		'                     \"extraConfig\":\"{\\n  \\\"caption\\\": \\\"Go back to\\\",\\n  \\\"title\\\": \\\"Home\\\"\\n}\"'+
		'                  }'+
		'               ],'+
		'               \"moduleUid\":\"a293ed74-e50a-4d06-91e7-2f4bcc2c1ca0\",'+
		'               \"totalDuration\":30.0,'+
		'               \"userDuration\":30.0,'+
		'               \"totalProgress\":0.0'+
		'            }'+
		'         ],'+
		'         \"viewSectionCount\":null,'+
		'         \"sectionsCount\":null,'+
		'         \"viewSectionCompleted\":null,'+
		'         \"sectionsCompleted\":null,'+
		'         \"completed\":false,'+
		'         \"attempted\":false,'+
		'         \"contentSectionCount\":null,'+
		'         \"contentSectionName\":null'+
		'      }'+
		'   ]'+
		'}'; 
        req.setEndpoint('https://api-gatewaynp.standardbank.co.za/npextorg/extnonprod/questionnaire/CC10F219-6F34-4573-B65F-FAF971CDCE84?reference='+UserInfo.getUserId());
            res.setHeader('Content-Type', 'application/json');
         
            res.setBody(responseBody);
            res.setStatusCode(200);
        System.debug('res '+res);
        
        
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