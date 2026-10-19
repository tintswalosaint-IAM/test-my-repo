/**
 * @description       : Test class for PER_API_NBA_Service and ALL its related sub-classes 
 * @author            : Derek Hughes
 * @group             : Personalisation
 * @last modified on  : 23-05-2024
 * @last modified by  : Derek Hughes
**/
@isTest(seeAllData=false)
public with sharing class PER_API_NBA_Service_Test {

    @isTest
    private static void testGetSingleResponses() {

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            PER_API_NBA_GetSingleResponses api = new PER_API_NBA_GetSingleResponses();
            List<PER_API_NBA_GetSingleResponses.dto> dto = api.call('UG');

        Test.stopTest();

        Assert.areEqual(1, dto.size(), 'Incorrect number of country results returned');
        Assert.areEqual('UGA', dto[0].countryCode, 'Incorrect country code');
        Assert.areEqual(5, dto[0].responses.size(), 'Incorrect number of responses returned');
    }

    @isTest
    private static void testGetSingleReasons() {

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockSuccess());
        
        Test.startTest();

            PER_API_NBA_GetSingleReasons api = new PER_API_NBA_GetSingleReasons();
            List<PER_API_NBA_GetSingleReasons.dto> dto = api.call('UG');

        Test.stopTest();

        Assert.areEqual(1, dto.size(), 'Incorrect number of country results returned');
        Assert.areEqual('UGA', dto[0].countryCode, 'Incorrect country code');
        Assert.areEqual(5, dto[0].reasonLookup.size(), 'Incorrect number of reasons returned');
    }

    @isTest
    private static void testGetSingleCoap() {

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockSuccess());
        
        Test.startTest();

            PER_API_NBA_GetSingleCoap api = new PER_API_NBA_GetSingleCoap();
            PER_API_NBA_GetSingleCoap.DTO dtoBlank = api.call('UG', '');
            PER_API_NBA_GetSingleCoap.DTO dto = api.call('UG', '10302476842');

        Test.stopTest();

        Assert.areEqual('10302476842', dto.coapProductsAR.cif_num, 'Incorrect CIF number');
        Assert.areEqual('10302476842', dto.coapStatsAR.cif_num, 'Incorrect CIF number');
    }

    @isTest
    private static void testGetSinglePoap() {

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockSuccess());
        
        Test.startTest();

            PER_API_NBA_GetSinglePoap api = new PER_API_NBA_GetSinglePoap();
            PER_API_NBA_GetSinglePoap.DTO dto = api.call('UG', 'E165');

        Test.stopTest();

        Assert.areEqual('E165', dto.PoapProducts.aeNumber, 'Incorrect AE number');
        Assert.areEqual('E165', dto.poapStats.aeNumber, 'Incorrect AE number');
    }
   
    
    @isTest
    private static void testGetSingleConversation() {

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockSuccess());
        
        Test.startTest();

            PER_API_NBA_GetSingleConversations api = new PER_API_NBA_GetSingleConversations();
            CMN_DTO_ConversationsResponse dto = api.call('UG', 'E165');

        Test.stopTest();

        Assert.areEqual(2, dto.clientPortfolioConversationList.size(), 'Incorrect number of conversations');
        Assert.areEqual('000000123456789011', dto.clientPortfolioConversationList[0].leadKey, 'Incorrect Lead Key');
        Assert.areEqual('123456789012', dto.clientPortfolioConversationList[1].identification, 'Incorrect identification number');
    }

    @isTest
    private static void testDtoSetters() {

        Test.startTest();

            CMN_DTO_ConversationsResponse dto = new CMN_DTO_ConversationsResponse();

            dto.totalSize = 1;
            dto.clientPortfolioConversationList = new List<CMN_DTO_ConversationsResponse.Conversation>();
            
            CMN_DTO_ConversationsResponse.Conversation conversation = new CMN_DTO_ConversationsResponse.Conversation();
            conversation.newCustN = 1;
            conversation.customerNumber = 1;
            conversation.clientType = 'Test';
            conversation.clientName = 'Test';
            conversation.identification = 'Test';
            conversation.identifier = 'Test';
            conversation.tier = 'Test';
            conversation.aeNumber = 'Test';

            conversation.conversationId = 'Test';
            conversation.category = 'Test';
            conversation.catPosition = 1;
            conversation.subCategory = 'Test';
            conversation.subCatPosition = 1;
            conversation.detail = 'Test';
            conversation.actionScript = 'Test';
            conversation.contactType = 'Test';
            conversation.response = 'Test';
            conversation.reason = 'Test';
            conversation.additionalInformation = 'Test';
            conversation.expectedRevenue = 1000;
            conversation.futureContactDate = 'Test';
            conversation.leadKey = 'Test   ';
        Test.stopTest();

        Assert.areEqual('Test', conversation.leadKey, 'Lead Key not trimmed');

    }
   
    /**
     * @description mocks a succesful response returned from the API call
     */
    public class MockSuccess implements HttpCalloutMock {
        
        String conversationId1;
        String conversationId2;
        String conversationId3;
        String conversationId4;
        String conversationId5;

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            String body;

            if  (request.getEndpoint().contains('/smart-conversations/conversations-single-responses')) {
                body = 
                    '[{"countryCode":"UGA","responses":['+
                        '{"subCategory": "Customer Retention", "response": "Actioned","futureDate": false},'+
                        '{"subCategory": "Customer Retention", "response": "Could not discuss with client","futureDate": false},'+
                        '{"subCategory": "Customer Retention", "response": "Decided not to discuss","futureDate": false},'+
                        '{"subCategory": "Customer Retention", "response": "Follow-up Required","futureDate": true},'+
                        '{"subCategory": "Customer Retention", "response": "Issue logged","futureDate": false}'+
                    ']}]';
            } 
            else if (request.getEndpoint().contains('/smart-conversations/conversations-single-reasons')) {
                body = 
                    '[{"countryCode":"UGA","reasonLookup":['+
                        '{"response": "Actioned", "reason": "Product taken up", "futureContactDate": false},'+
                        '{"response": "Could not discuss with client", "reason": "Never contact client again", "futureContactDate": false},'+
                        '{"response": "Could not discuss with client", "reason": "Never offer again", "futureContactDate": false},'+
                        '{"response": "Follow-up Required", "reason": "Client not available", "futureContactDate": true},'+
                        '{"response": "Follow-up Required", "reason": "Contact client at future date for suggested product", "futureContactDate": true}'+
                    ']}]';
            } 
            else if (request.getEndpoint().contains('single-coap')) {
                body = 
                    '{'+
                        '"coapStatsAR": {'+
                            '"cif_num": "10302476842",'+
                            '"new_cust_n": 10302476842,'+
                            '"active_customer_ind": "Yes",'+
                            '"primary_customer_ind": "Yes",'+
                            '"tot_oi": 181674,'+
                            '"oi_top20": "Top 20% :No",'+
                            '"avg_ct_book_bal": 5202885,'+
                            '"avg_cr_bal_top20": "Top 20% :No",'+
                            '"avg_dt_book_bal": -10000000,'+
                            '"avg_dt_bal_top20": "Top 20% :No",'+
                            '"dig_mb_status": "Yes",'+
                            '"dig_mb_dt": 1704751200000,'+
                            '"dig_app_status": "Yes",'+
                            '"dig_app_dt": 1704664800000,'+
                            '"dig_ib_status": "Yes",'+
                            '"dig_ib_dt": 1704664800000'+
                        '},'+
                        '"coapProductsAR": {'+
                            '"cif_num": "10302476842",'+
                            '"new_cust_n": 10302476842,'+
                            '"prod1_name": "Personal_Loan",'+
                            '"prod2_name": "Other",'+
                            '"prod3_name": "Credit Card",'+
                            '"prod4_name": "Transaction Accounts",'+
                            '"prod5_name": null,'+
                            '"prod6_name": null,'+
                            '"prod1_cnt": 1,'+
                            '"prod2_cnt": 1,'+
                            '"prod3_cnt": 1,'+
                            '"prod4_cnt": 2,'+
                            '"prod5_cnt": 0,'+
                            '"prod6_cnt": 0,'+
                            '"prod1_bal": -10000000,'+
                            '"prod2_bal": 5202885,'+
                            '"prod3_bal": -22200,'+
                            '"prod4_bal": 123456,'+
                            '"prod5_bal": 0,'+
                            '"prod6_bal": 0'+
                        '},'+
                        '"coapDetailsAR": {'+
                            '"cif_num": "10302476842",'+
                            '"new_cust_n": 10302476842,'+
                            '"first_name": "EDWARD",'+
                            '"last_name": "KABUNDU",'+
                            '"dateofbirth": 542152800000,'+
                            '"gender": "Male",'+
                            '"kyc_flag": "Y",'+
                            '"martl_status": null,'+
                            '"segment": "PB-PERSONAL BANKING",'+
                            '"brnch": "NAKASERO",'+
                            '"sub_segment": "GOLD",'+
                            '"id_type": "IDTYPER79",'+
                            '"id_num": "CM87027103024D",'+
                            '"pref_phn_num": "+256(000)782066609",'+
                            '"pref_cell_num": "+256(000)782066609",'+
                            '"pref_email": "EBKABUNDU@GAMIL.COM",'+
                            '"emplmnt_status": "EMPLOYED FULL TIME - OTHER",'+
                            '"emplr_name": "C SQUARED",'+
                            '"address": "SQUARED UGANDA PLOT 7/11 BUGANDA ROAD KAMPALA",'+
                            '"indstry": "Computer and related activities",'+
                            '"gross_sal": 8800000.0000,'+
                            '"occuptn": "PROFESSIONAL",'+
                            '"staff": "N"'+
                        '},'+
                        '"coapMaturityAR": {'+
                            '"cif_num": "10302476842",'+
                            '"new_cust_n": 10302476842,'+
            
                            '"mat_term_1": 5,'+
                            '"mat_prod_1": "SALARY EARNERS SCHEME NON GUARANTEED, A/C NO:9030024285412",'+
                            '"mat_dt_1": 1724536800000,'+
                            '"mat_book_bal_1": -10000000.0000,'+
                            '"mat_intrnl_acc_num_1": "9030024285412",'+
                            '"mat_accrued_interest_1": 60547.945211,'+
            
                            '"mat_term_2": 3,'+
                            '"mat_prod_2": "REVOLVING CREDI FACILITY",'+
                            '"mat_dt_2": 1764536800000,'+
                            '"mat_book_bal_2": -130000,'+
                            '"mat_intrnl_acc_num_2": "8030024232312",'+
                            '"mat_accrued_interest_2": 2355.98,'+
            
                            '"mat_term_3": 0,'+
                            '"mat_prod_3": null,'+
                            '"mat_dt_3": null,'+
                            '"mat_book_bal_3": null,'+
                            '"mat_intrnl_acc_num_3": null,'+
                            '"mat_accrued_interest_3": null'+
                        '}'+
                    '}';
            }
            else if (request.getEndpoint().contains('single-poap')) {
                body = 
                    '{'+
                        '"poapStats": {'+
                            '"aeNumber": "E165",'+
                            '"portfolio_cd": "E165",'+
                            '"rltnship_mngr_name": null,'+
                            '"avg_ct_book_rm": 10436600248,'+
                            '"avg_dt_book_rm": -9675281454,'+
                            '"tot_oi_rm": 246755120,'+
                            '"tot_nii_rm": 191842850,'+
                            '"tot_nir_rm": 54912270,'+
                            '"active_cnt": 766,'+
                            '"primary_cnt": 441,'+
                            '"dig_mb_cnt": 1072,'+
                            '"dig_ib_cnt": 1349,'+
                            '"dig_app_cnt": 1321'+
                        '},'+
                        '"poapProducts": {'+
                            '"aeNumber": "E165",'+
                            '"portfolio_cd": "E165",'+
                            '"prod1_name_rm": "Card",'+
                            '"prod1_cnt_rm": 88,'+
                            '"prod1_bal_rm": -134057764,'+
                            '"prod2_name_rm": "Current_Account",'+
                            '"prod2_cnt_rm": 667,'+
                            '"prod2_bal_rm": 7134844376,'+
                            '"prod3_name_rm": "Home_Loan",'+
                            '"prod3_cnt_rm": 2,'+
                            '"prod3_bal_rm": -285810579,'+
                            '"prod4_name_rm": "Personal_Loan",'+
                            '"prod4_cnt_rm": 149,'+
                            '"prod4_bal_rm": -5551007664,'+
                            '"prod5_name_rm": "Savings",'+
                            '"prod5_cnt_rm": 122,'+
                            '"prod5_bal_rm": 783497616,'+
                            '"prod6_name_rm": "Other",'+
                            '"prod6_cnt_rm": 542,'+
                            '"prod6_bal_rm": -1320204956'+
                        '}'+
                    '}';
            }
            else if (request.getEndpoint().contains('/smart-conversations/portfolio-single-conversations')) {
                prepareConversationIds();
                body = 
                    '['+
                        '{"customerNumber":213000123, "conversationId":"{1}","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates birthday.","actionScript":"BIRTHDAY","contactType":null,"response":null,"reason":null,"additionalInformation":null,"expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789011"},' + 
                        '{"customerNumber":213000456, "conversationId":"{2}","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates something else.","actionScript":"BIRTHDAY","contactType":null,"response":"testresp","reason":"testreason","additionalInformation":"testinfo","expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789012"}'+
                    ']';
              body = 
                '{"totalSize":4,"clientPortfolioConversationList":[{"newCustN":100001,"conversationId":"' + conversationId1 +'","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates birthday.","actionScript":"BIRTHDAY","contactType":null,"response":"testr_resp","reason":"test_reason","additionalInformation":"test_detes","expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789011"},{"newCustN":100001,"conversationId":"' + conversationId2 +'","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates something else.","actionScript":"BIRTHDAY","contactType":null,"response":"testresp","reason":"testreason","additionalInformation":"testinfo","expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789012"},{"newCustN":100002,"conversationId":"' + conversationId3 +'","clientType":"B","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer wants something.","actionScript":"BIRTHDAY","contactType":null,"response":null,"reason":null,"additionalInformation":null,"expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789013"},{"newCustN":909090909,"conversationId":"' + conversationId4 +'","clientType":"B","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer wants something else.","actionScript":"BIRTHDAY","contactType":"typeA","response":null,"reason":null,"additionalInformation":null,"expectedRevenue":0.0,"futureContactDate":"01-01-1991","leadKey":"000000123456789014"},{"newCustN":123456789,"conversationId":"' + conversationId5 +'","clientType":"P","clientName":"MR TEST REST","identification":"123456789013","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer wants something else.","actionScript":"BIRTHDAY","contactType":"typeA","response":"testresponse","reason":"testreason","additionalInformation":"testdetails","expectedRevenue":0.0,"futureContactDate":"01-01-1991","leadKey":"000000123456789015"}]}';
                  body = body.replace('{1}', conversationId1);
                body = body.replace('{2}', conversationId2);
            }   
            else if (request.getEndpoint().contains('/smart-conversations/conversations-single-nba')) {
                body = 'true';
            }
            else if (request.getEndpoint().contains('/smart-conversations/conversations-single')) {
                prepareConversationIds();
            
                body = 
                '['+
                    '{"conversationId":"{1]","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates birthday.","actionScript":"BIRTHDAY","contactType":null,"response":null,"reason":null,"additionalInformation":null,"expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789011"},'+
                    '{"conversationId":"{2}","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates something else.","actionScript":"BIRTHDAY","contactType":null,"response":"testresp","reason":"testreason","additionalInformation":"testinfo","expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789012"}'+
                ']';

                // body = 
                // '{"totalSize":4,"clientPortfolioConversationList":[{"newCustN":100001,"conversationId":"' + conversationId1 +'","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates birthday.","actionScript":"BIRTHDAY","contactType":null,"response":"testr_resp","reason":"test_reason","additionalInformation":"test_detes","expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789011"},{"newCustN":100001,"conversationId":"' + conversationId2 +'","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates something else.","actionScript":"BIRTHDAY","contactType":null,"response":"testresp","reason":"testreason","additionalInformation":"testinfo","expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789012"},{"newCustN":100002,"conversationId":"' + conversationId3 +'","clientType":"B","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer wants something.","actionScript":"BIRTHDAY","contactType":null,"response":null,"reason":null,"additionalInformation":null,"expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789013"},{"newCustN":909090909,"conversationId":"' + conversationId4 +'","clientType":"B","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer wants something else.","actionScript":"BIRTHDAY","contactType":"typeA","response":null,"reason":null,"additionalInformation":null,"expectedRevenue":0.0,"futureContactDate":"01-01-1991","leadKey":"000000123456789014"},{"newCustN":123456789,"conversationId":"' + conversationId5 +'","clientType":"P","clientName":"MR TEST REST","identification":"123456789013","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer wants something else.","actionScript":"BIRTHDAY","contactType":"typeA","response":"testresponse","reason":"testreason","additionalInformation":"testdetails","expectedRevenue":0.0,"futureContactDate":"01-01-1991","leadKey":"000000123456789015"}]}';

                   
                body = body.replace('{1}', conversationId1);
                body = body.replace('{2}', conversationId2);
            }
            else {
                Assert.fail('Unknown call out path: '+request.getEndpoint());
            }

            response.setStatusCode(CMN_API_Service.HTTP_OK);
            response.setBody(body);

            return response;
        }

        private void prepareConversationIds() {
            Date today = System.today();
            String year = String.valueOf(today.year()).substring(2,4);
            String month = String.valueOf(today.month());
            if (month.length() == 1) {
                month=0+month;
            }
            String day = String.valueOf(today.day());
            if (day.length() == 1) {
                day=0+day;
            }

            conversationId1 = year+month+day+1111;
            conversationId2 = year+month+day+2222;
            conversationId3 = year+month+day+3333;
            conversationId4 = year+month+day+4444;
            conversationId5 = year+month+day+5555;
        }
    }

}