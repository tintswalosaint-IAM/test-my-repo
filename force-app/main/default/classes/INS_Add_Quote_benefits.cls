/**INS_Add_Quote_benefits
 * @description Class for add benefits to the main insured
 * @author Shams Ul Arifeen
 * @date October 2023
 * @LastModified: April, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-56396
 * @LastModifiedReason: API Code Remediation
 * lastModifiedby     : Vic Wafula
 * lastModifiedDate   : 09/10/2026
 * description        : SFP-51404 Accept Frequency from Flow and use to generate Premium
 */
public with sharing class INS_Add_Quote_benefits extends sbgplatform.ApiService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('INS_Add_Quote_benefits');
    private static final String PATH_BASE = '/life-quoting/quotes/';
    private static final String PATH_SUFFIX = '/benefits';
    private static final String NAMED_CREDENTIAL = 'CHNW_IAM_INS_SBSAGatewayN';

    public INS_Add_Quote_benefits() {
        super(NAMED_CREDENTIAL);
    }

    /**
     * @description Quote-scoped Bearer + x-iam-country (see INS_Cash_Back_Benefit for pattern).
     */
    public override HttpRequest prepareHttpRequest(String path, String method, Object requestBody, String contentType) {
        HttpRequest req = super.prepareHttpRequest(path, method, requestBody, contentType);
        req.setHeader('Authorization', 'Bearer ' + INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote));
        req.setHeader('x-iam-country', INS_Quote_Helper.CLIENT_COUNTRY_SA);
        req.setHeader('accept', sbgplatform.ApiService.CONTENT_TYPE_APPLICATION_JSON);
        return req;
    }

    /**
     * @description Invokable method called from a flow to add benefits to the Main Insured.
     * @param requests
     * @return INS_Quick_Quote_Wrapper.PremiumBenefitResponse
     */
    @InvocableMethod(
        label='Create Quote Benefits'
        description='Called from a flow to add benefits to the main insured'
        category='Quote benefits'
    )
    public static List<INS_Quick_Quote_Wrapper.PremiumBenefitResponse> createQuoteBenefits(
        List<BenefitsWrapper> requests
    ) {
        deleteQuoteBenefits(requests);
        List<INS_Quick_Quote_Wrapper.PremiumBenefitResponse> returnResponse = new List<INS_Quick_Quote_Wrapper.PremiumBenefitResponse>();
        for (BenefitsWrapper request : requests) {
            if (request.showPremium) {
                INS_Quick_Quote_Wrapper.QuoteBenefitRequest payload = new INS_Quick_Quote_Wrapper.QuoteBenefitRequest();
                payload.referenceNumber = request.quoteNumber;
                payload.benefits = buildBenefitsList(request);

                try {
                    String path = PATH_BASE + request.quoteNumber + PATH_SUFFIX;
                    String responseBody = (String) new INS_Add_Quote_benefits().post(path, JSON.serialize(payload));
                    returnResponse = extractPremiumFromApiResponse(responseBody);
                } catch (Exception ex) {
                    LOGGER.error(
                        'INS_Add_Quote_benefits.createQuoteBenefits:Some Un-Handled Exception Occurred',
                        new List<String>{ 'INS_Add_Quote_benefits.createQuoteBenefits', ex.getMessage() }
                    );
                    throw new INS_CustomException(ex.getMessage());
                }
            }
        }
        return returnResponse;
    }

    /**
     * @description Builds the list of QuoteBenefit entries from a single BenefitsWrapper request.
     * @param request BenefitsWrapper
     * @return List<INS_Quick_Quote_Wrapper.QuoteBenefit>
     */
    private static List<INS_Quick_Quote_Wrapper.QuoteBenefit> buildBenefitsList(BenefitsWrapper request) {
        List<INS_Quick_Quote_Wrapper.QuoteBenefit> benefits = new List<INS_Quick_Quote_Wrapper.QuoteBenefit>();

        if (request.cateringBenefit != 0 && request.cateringBenefit != null) {
            benefits.add(
                INS_Quote_Helper.createBenefit('7.MAINMEMBERCATERINGBENEFIT', request.cateringBenefit, request.memberId, request.premiumFrequency)
            );
        }
        if (request.tombStoneBenefit != 0 && request.tombStoneBenefit != null) {
            String key = (request.country == INS_Quote_Helper.CLIENT_COUNTRY_KE)
                ? '203.MAINADVERTISEMENTBENEFIT'
                : '3.MAINMEMBERTOMBSTONEBENEFIT';
            benefits.add(INS_Quote_Helper.createBenefit(key, request.tombStoneBenefit, request.memberId, request.premiumFrequency));
        }
        if (request.funeralBenefit != 0 && request.funeralBenefit != null) {
            benefits.add(INS_Quote_Helper.createBenefit('1.MAINFUNERAL', request.funeralBenefit, request.memberId, request.premiumFrequency));
        }
        if (request.shoppingBenefit != 0 && request.shoppingBenefit != null) {
            benefits.add(
                INS_Quote_Helper.createBenefit('5.MAINMEMBERGROCERYBENEFIT', request.shoppingBenefit, request.memberId, request.premiumFrequency)
            );
        }
        if (request.radioAnnouncementBenefit != 0 && request.radioAnnouncementBenefit != null) {
            String key = (request.country == INS_Quote_Helper.CLIENT_COUNTRY_KE)
                ? '206.MAINAIRTIMEBENEFIT'
                : '23.MAINAIRTIME';
            benefits.add(INS_Quote_Helper.createBenefit(key, request.radioAnnouncementBenefit, request.memberId, request.premiumFrequency));
        }
        if (request.transportBenefit != 0 && request.transportBenefit != null) {
            benefits.add(
                INS_Quote_Helper.createBenefit('28.MAINREPATRIATION', request.transportBenefit, request.memberId, request.premiumFrequency)
            );
        }
        return benefits;
    }

    /**
     * @description Method to delete benefits of the Main Insured.
     * @param requests List of BenefitsWrapper records
     */
    public static void deleteQuoteBenefits(List<BenefitsWrapper> requests) {
        List<INS_Quick_Quote_Wrapper.itemKey> benefitsIds = new List<INS_Quick_Quote_Wrapper.itemKey>();
        INS_Quick_Quote_Wrapper.DeleteMemberPayload payload = new INS_Quick_Quote_Wrapper.DeleteMemberPayload();

        for (BenefitsWrapper request : requests) {
            addItemKeyIfPresent(benefitsIds, request.mainMember.Funeral_Benefit_Id__c);
            addItemKeyIfPresent(benefitsIds, request.mainMember.Catering_Benefit_Id__c);
            addItemKeyIfPresent(benefitsIds, request.mainMember.Tombstone_Benefit_Id__c);
            addItemKeyIfPresent(benefitsIds, request.mainMember.Shopping_Benefit_Id__c);
            addItemKeyIfPresent(benefitsIds, request.mainMember.Transport_Benefit_Id__c);
            addItemKeyIfPresent(benefitsIds, request.mainMember.Radio_Announcement_benefit_Id__c);
        }
        payload.referenceNumber = requests[0].quoteNumber;
        payload.itemKeys = benefitsIds;

        try {
            String path = PATH_BASE + requests[0].quoteNumber + PATH_SUFFIX;
            new INS_Add_Quote_benefits().patch(path, JSON.serialize(payload));
        } catch (Exception ex) {
            LOGGER.error(
                'INS_Add_Quote_benefits.deleteQuoteBenefits:Some Un-Handled Exception Occurred',
                new List<String>{ 'INS_Add_Quote_benefits.deleteQuoteBenefits', ex.getMessage() }
            );
            throw new INS_CustomException(ex.getMessage());
        }
    }

    /**
     * @description Appends an ItemKey to the list when the supplied id is non-null.
     * @param benefitsIds Target list of item keys
     * @param id Id to wrap and append
     */
    private static void addItemKeyIfPresent(List<INS_Quick_Quote_Wrapper.itemKey> benefitsIds, String id) {
        if (id != null) {
            INS_Quick_Quote_Wrapper.itemKey item = new INS_Quick_Quote_Wrapper.itemKey();
            item.id = id;
            benefitsIds.add(item);
        }
    }

    /**
     * @description Helper method to extract premium from API response
     * @param jsonResponse Raw JSON response body
     * @return List of PremiumBenefitResponse
     */
    public static List<INS_Quick_Quote_Wrapper.PremiumBenefitResponse> extractPremiumFromApiResponse(
        String jsonResponse
    ) {
        List<INS_Quick_Quote_Wrapper.PremiumBenefitResponse> premiumResponses = new List<INS_Quick_Quote_Wrapper.PremiumBenefitResponse>();
        Decimal totalPremium = 0;

        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        List<Object> benefits = (List<Object>) jsonMap.get('benefits');

        INS_Quick_Quote_Wrapper.PremiumBenefitResponse response = new INS_Quick_Quote_Wrapper.PremiumBenefitResponse();
        for (Object benefit : benefits) {
            Map<String, Object> benefitMap = (Map<String, Object>) benefit;
            String benefitType = (String) benefitMap.get('benefitType');
            Decimal premium = (Decimal) benefitMap.get('premium');
            if (benefitType == 'MAINMEMBERCATERINGBENEFIT') {
                response.cateringBenefitId = (String) benefitMap.get('benefitId');
                response.cateringPremium = premium;
            } else if (benefitType == 'MAINMEMBERTOMBSTONEBENEFIT' || benefitType == 'MAINADVERTISEMENTBENEFIT') {
                response.tombstoneBenefitId = (String) benefitMap.get('benefitId');
                response.tombstonePremium = premium;
            } else if (benefitType == 'MAINFUNERAL') {
                response.funeralBenefitId = (String) benefitMap.get('benefitId');
                response.funeralPremium = premium;
            } else if (benefitType == 'MAINREPATRIATION') {
                response.transportBenefittId = (String) benefitMap.get('benefitId');
                response.transportPremium = premium;
            } else if (benefitType == 'MAINAIRTIME' || benefitType == 'MAINAIRTIMEBENEFIT') {
                response.radioAnnouncementBenefitId = (String) benefitMap.get('benefitId');
                response.radioAnnouncementPremium = premium;
            } else if (benefitType == 'MAINMEMBERGROCERYBENEFIT') {
                response.shoppingBenefitId = (String) benefitMap.get('benefitId');
                response.shoppingPremium = premium;
            }
            totalPremium += premium;
        }
        response.totalPremium = totalPremium;
        premiumResponses.add(response);
        return premiumResponses;
    }

    /**
     * @description AuraEnabled method called from a LWC add or edit benefits to the Main Insured.
     * @param jsonString serialized payload containing benefit details
     * @return Response wrapper with id and premium
     */
    @AuraEnabled
    public static Response editQuoteBenefits(String jsonString) {
        Map<String, Object> benefitMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String benefitKey = (String) benefitMap.get('benefitKey');
        Integer benefitAmount = Integer.valueOf(benefitMap.get('benefitAmount'));
        String memberId = (String) benefitMap.get('memberId');
        String quoteNumber = (String) benefitMap.get(INS_Quote_Helper.quoteNumber);
        String benefitId = (String) benefitMap.get('benefitId');
        String premiumFrequency = (String) benefitMap.get('premiumFrequency');

        Response result = new Response();
        INS_Quick_Quote_Wrapper.QuoteBenefitRequest payload = new INS_Quick_Quote_Wrapper.QuoteBenefitRequest();
        payload.referenceNumber = quoteNumber;

        List<INS_Quick_Quote_Wrapper.QuoteBenefit> benefits = new List<INS_Quick_Quote_Wrapper.QuoteBenefit>();
        benefits.add(createEditedBenefitPayload(benefitKey, benefitAmount, memberId, benefitId,premiumFrequency));
        payload.benefits = benefits;

        try {
            String path = PATH_BASE + quoteNumber + PATH_SUFFIX;
            String serializedPayload = JSON.serialize(payload);
            String responseBody = (benefitId != null)
                ? (String) new INS_Add_Quote_benefits().put(path, serializedPayload)
                : (String) new INS_Add_Quote_benefits().post(path, serializedPayload);
            result = handleSuccessResponse(responseBody, benefitKey);
        } catch (Exception ex) {
            LOGGER.error(
                'INS_Add_Quote_benefits.editQuoteBenefits:Some Un-Handled Exception Occurred',
                new List<String>{ 'INS_Add_Quote_benefits.editQuoteBenefits', ex.getMessage() }
            );
            throw new AuraHandledException(ex.getMessage());
        }
        return result;
    }

    /**
     * @description Helper method to extract a specific premium from API response
     * @param jsonResponse Raw JSON response body
     * @param benefitKey benefit key to match
     * @return Response
     */
    public static Response handleSuccessResponse(String jsonResponse, String benefitKey) {
        Response result = new Response();
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        List<Object> benefits = (List<Object>) jsonMap.get('benefits');

        for (Object benefit : benefits) {
            Map<String, Object> benefitMap = (Map<String, Object>) benefit;
            Decimal premium = (Decimal) benefitMap.get('premium');
            String benefitType = (String) benefitMap.get('benefitType');
            if (benefitKey.substringAfter('.') == benefitType) {
                result.benefitId = (String) benefitMap.get('benefitId');
                result.benefitPremium = premium;
            }
        }
        return result;
    }

    /**
     * @description Helper method to create a QuoteBenefit object for a specific benefit type from LWC
     * @param benefitType benefit key
     * @param benefitAmount amount value
     * @param memberId member id
     * @param benefitId existing benefit id (nullable)
     * @return INS_Quick_Quote_Wrapper.QuoteBenefit
     */
    private static INS_Quick_Quote_Wrapper.QuoteBenefit createEditedBenefitPayload(
        String benefitType,
        Double benefitAmount,
        String memberId,
        String benefitId,
        String premiumFrequency
    ) {
        INS_Quick_Quote_Wrapper.QuoteBenefit benefit = new INS_Quick_Quote_Wrapper.QuoteBenefit();
        benefit.benefitId = (benefitId != null) ? benefitId : '';
        benefit.benefitType = benefitType.substringAfter('.');
        benefit.benefitAmountValue = (benefitAmount != null) ? benefitAmount : 0;
        benefit.benefitKey = benefitType;
        benefit.personId = '';
        benefit.benefitFee = 0.0;
        benefit.benefitFrequencyValue = premiumFrequency;
        benefit.memberId = memberId;
        return benefit;
    }

    /**
     * @description Method to delete benefits of the Main Insured from LWC.
     * @param jsonString serialized payload containing benefit id and quote number
     * @return Boolean indicating success
     */
    @AuraEnabled
    public static Boolean deleteBenefits(String jsonString) {
        Boolean isBenefitSuccessfullyAdded = true;
        Map<String, Object> benefitMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String quoteNumber = (String) benefitMap.get(INS_Quote_Helper.quoteNumber);
        String benefitId = (String) benefitMap.get('benefitId');

        INS_Quick_Quote_Wrapper.DeleteMemberPayload payload = new INS_Quick_Quote_Wrapper.DeleteMemberPayload();
        List<INS_Quick_Quote_Wrapper.ItemKey> benefitsIds = new List<INS_Quick_Quote_Wrapper.ItemKey>();
        INS_Quick_Quote_Wrapper.ItemKey itemKey = new INS_Quick_Quote_Wrapper.ItemKey();
        itemKey.id = benefitId;
        benefitsIds.add(itemKey);
        payload.referenceNumber = quoteNumber;
        payload.itemKeys = benefitsIds;

        try {
            String path = PATH_BASE + quoteNumber + PATH_SUFFIX;
            new INS_Add_Quote_benefits().patch(path, JSON.serialize(payload));
        } catch (Exception ex) {
            isBenefitSuccessfullyAdded = false;
            LOGGER.error(
                'INS_Add_Quote_benefits.deleteBenefits:Some Un-Handled Exception Occurred',
                new List<String>{ 'INS_Add_Quote_benefits.deleteBenefits', ex.getMessage() }
            );
            throw new AuraHandledException(ex.getMessage());
        }
        return isBenefitSuccessfullyAdded;
    }

    /**
     * @description Wrapper Class to pass in the createQuoteBenefits.
     */
    public class BenefitsWrapper {
        @InvocableVariable(label='Show Premium')
        public Boolean showPremium;
        @InvocableVariable(label='CateringBenefit')
        public Double cateringBenefit;
        @InvocableVariable(label='TombStoneBenefit')
        public Double tombStoneBenefit;
        @InvocableVariable(label='TransportBenefit')
        public Double transportBenefit;
        @InvocableVariable(label='ShoppingBenefit')
        public Double shoppingBenefit;
        @InvocableVariable(label='FuneralBenefit')
        public Double funeralBenefit;
        @InvocableVariable(label='RadioAnnouncementBenefit')
        public Double radioAnnouncementBenefit;
        @InvocableVariable(label='QuoteNumber')
        public String quoteNumber;
        @InvocableVariable(label='Main MemberId')
        public String memberId;
        @InvocableVariable(label='Main Member')
        public InsurancePolicyParticipant mainMember;
        @InvocableVariable(label='User Country')
        public String country;
        @InvocableVariable(label='Premium Frequency')
        public String premiumFrequency;
    }

    /**
     * @description Wrapper Class to return benefit name, id and premium to LWC.
     */
    public class Response {
        @AuraEnabled
        public String benefitId;
        @AuraEnabled
        public Integer benefitName;
        @AuraEnabled
        public Decimal benefitPremium;
    }

    /**
     * @description Mocks a successful response returned from the Add Quote Benefits API
     */
    @testVisible
    private class AddQuoteBenefitsSuccessMock implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setStatus('OK');
            response.setHeader('Content-Type', 'application/json');
            response.setBody(
                '{"benefits":[{"benefitType":"MAINMEMBERCATERINGBENEFIT","premium":100.0,"benefitId":"cb-1"},' +
                    '{"benefitType":"MAINMEMBERTOMBSTONEBENEFIT","premium":200.0,"benefitId":"tb-1"},' +
                    '{"benefitType":"MAINREPATRIATION","premium":150.0,"benefitId":"rp-1"},' +
                    '{"benefitType":"MAINMEMBERGROCERYBENEFIT","premium":120.0,"benefitId":"gb-1"},' +
                    '{"benefitType":"MAINFUNERAL","premium":250.0,"benefitId":"fn-1"},' +
                    '{"benefitType":"MAINAIRTIME","premium":80.0,"benefitId":"at-1"}]}'
            );
            return response;
        }
    }

    /**
     * @description Mocks a failed response returned from the Add Quote Benefits API
     */
    @testVisible
    private class AddQuoteBenefitsFailureMock implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR);
            response.setStatus('Internal Server Error');
            response.setBody('');
            return response;
        }
    }
}