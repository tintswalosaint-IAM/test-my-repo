/**
 * @description      : This class add, update or delete the member of quote
 * @author           : Shams Ul Arifeen
 * @date             : October 2023
 */
public with sharing class INS_Create_Quote_Members {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('INS_Create_Quote_Members');

    // Hardcoding Premium frequency sent with every member benefit to avoid compilation error
    private static final String PREMIUM_FREQUENCY_MONTHLY = 'MONTHLY';

    /**
     * @description       : AuraEnabled method to create quote members.
     * @author            : Shams Ul Arifeen
     * @param  member
     * @param  quoteNumber
     * @param  isUpdate
     * @return            : InsurancePolicyParticipant
     **/
    @AuraEnabled
    public static InsurancePolicyParticipant createQuoteMembers(
        InsurancePolicyParticipant member,
        String quoteNumber,
        Boolean isUpdate,
        String userCountry
    ) {
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse response = new HttpResponse();

        // Create a list to store INS_Quick_Quote_Wrapper.AddMember objects
        List<INS_Quick_Quote_Wrapper.AddMember> memberList = new List<INS_Quick_Quote_Wrapper.AddMember>();
        List<INS_Quick_Quote_Wrapper.MemberBenefit> benefits = new List<INS_Quick_Quote_Wrapper.MemberBenefit>();
        InsurancePolicyParticipant returnList = new InsurancePolicyParticipant();
        // Iterate through applicants and create AddMember objects
        if (member.RelationshipToInsured != 'Main Member') {
            INS_Quick_Quote_Wrapper.AddMember memberObj = new INS_Quick_Quote_Wrapper.AddMember();
            // Populate memberObj with member details
            Datetime dateOfBirth = member.BirthDate__c;
            memberObj.firstName = member.FirstName__c;
            memberObj.surname = member.LastName__c;
            memberObj.gender = member.Gender__c;
            memberObj.memberId = (isUpdate) ? member.Member_Id__c : '';
            memberObj.dateOfBirth = dateOfBirth.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            memberObj.idNumber = member.IdentityNumber__c;
            memberObj.bpid = '';
            memberObj.staff = 'true';
            memberObj.identityDocumentType = 'SAIDENTITYDOCUMENT';
            memberObj.isStaff = 'false';
            if (member.RelationshipToInsured == 'SPOUSE') {
                memberObj.memberType = 'SPOUSE';
                memberObj.relationship = member.RelationshipToInsured;

                //SPOUSECATERINGBENEFIT
                if (member.Catering__c != 0 && member.Catering__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit cateringBenefit = INS_Quote_Helper.createMemberBenefit(
                        '8.SPOUSECATERINGBENEFIT',
                        member.Catering__c,
                        member.Catering_Benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(cateringBenefit);
                }

                // SPOUSETOMBSTONEBENEFIT
                if (member.Tombstone__c != 0 && member.Tombstone__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit tombstoneBenefit = new INS_Quick_Quote_Wrapper.MemberBenefit();
                    if (userCountry == INS_Quote_Helper.CLIENT_COUNTRY_KE) {
                        tombstoneBenefit = INS_Quote_Helper.createMemberBenefit(
                            '204.SPOUSEADVERTISEMENTBENEFIT',
                            member.Tombstone__c,
                            member.Tombstone_Benefit_Id__c,
                            PREMIUM_FREQUENCY_MONTHLY
                        );
                    } else {
                        tombstoneBenefit = INS_Quote_Helper.createMemberBenefit(
                            '4.SPOUSETOMBSTONEBENEFIT',
                            member.Tombstone__c,
                            member.Tombstone_Benefit_Id__c,
                            PREMIUM_FREQUENCY_MONTHLY
                        );
                    }
                    benefits.add(tombstoneBenefit);
                }
                // SPOUSEAIRTIME
                if (member.Radio_Announcement__c != 0 && member.Radio_Announcement__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit radioAnnouncementBenefitBenefit = new INS_Quick_Quote_Wrapper.MemberBenefit();
                    if (userCountry == INS_Quote_Helper.CLIENT_COUNTRY_KE) {
                        radioAnnouncementBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                            '303.SPOUSEAIRTIMEBENEFIT',
                            member.Radio_Announcement__c,
                            member.Radio_Announcement_benefit_Id__c,
                            PREMIUM_FREQUENCY_MONTHLY
                        );
                    } else {
                        radioAnnouncementBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                            '24.SPOUSEAIRTIME',
                            member.Radio_Announcement__c,
                            member.Radio_Announcement_benefit_Id__c,
                            PREMIUM_FREQUENCY_MONTHLY
                        );
                    }
                    benefits.add(radioAnnouncementBenefitBenefit);
                }
                // SPOUSEFUNERALBENEFIT
                if (member.funeral_Cover__c != 0 && member.funeral_Cover__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit funeralBenefit = INS_Quote_Helper.createMemberBenefit(
                        '2.SPOUSEFUNERAL',
                        member.funeral_Cover__c,
                        member.Funeral_Benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(funeralBenefit);
                }
                // SPOUSEREPATRIATION
                if (member.Transport__c != 0 && member.Transport__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit transportBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                        '29.SPOUSEREPATRIATION',
                        member.Transport__c,
                        member.Transport_Benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(transportBenefitBenefit);
                }
                // SPOUSEGROCERYBENEFIT
                if (member.Shopping__c != 0 && member.Shopping__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit shoppingBenefit = INS_Quote_Helper.createMemberBenefit(
                        '6.SPOUSEGROCERYBENEFIT',
                        member.Shopping__c * 6,
                        member.Shopping_Benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(shoppingBenefit);
                }
                memberObj.benefits = benefits;
            } else if (
                member.RelationshipToInsured == 'SON' ||
                member.RelationshipToInsured == 'DAUGHTER' ||
                member.RelationshipToInsured == 'CHILD'
            ) {
                memberObj.memberType = 'CHILD';
                memberObj.relationship = member.RelationshipToInsured;

                // CHILDRADIOANNOUNCEMENT
                if (member.Radio_Announcement__c != 0 && member.Radio_Announcement__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit radioAnnouncementBenefitBenefit = new INS_Quick_Quote_Wrapper.MemberBenefit();
                    if (userCountry == INS_Quote_Helper.CLIENT_COUNTRY_KE) {
                        radioAnnouncementBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                            '102.CHILDAIRTIMEBENEFIT',
                            member.Radio_Announcement__c,
                            member.Radio_Announcement_benefit_Id__c,
                            PREMIUM_FREQUENCY_MONTHLY
                        );
                    } else if (userCountry == INS_Quote_Helper.CLIENT_COUNTRY_ZA) {
                        radioAnnouncementBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                            '26.CHILDAIRTIME',
                            member.Radio_Announcement__c,
                            member.Radio_Announcement_benefit_Id__c,
                            PREMIUM_FREQUENCY_MONTHLY
                        );
                    } else {
                        radioAnnouncementBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                            '12.CHILDRADIOANNOUNCEMENT',
                            member.Radio_Announcement__c,
                            member.Radio_Announcement_benefit_Id__c,
                            PREMIUM_FREQUENCY_MONTHLY
                        );
                    }
                    benefits.add(radioAnnouncementBenefitBenefit);
                }
                // CHILDEFUNERALBENEFIT
                if (member.funeral_Cover__c != 0 && member.funeral_Cover__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit funeralBenefit = INS_Quote_Helper.createMemberBenefit(
                        '10.CHILDFUNERAL',
                        member.funeral_Cover__c,
                        member.Funeral_Benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(funeralBenefit);
                }
                // CHILDREPATRIATIONBENEFIT
                if (member.Transport__c != 0 && member.Transport__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit transportBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                        '31.CHILDREPATRIATION',
                        member.Transport__c,
                        member.Transport_Benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(transportBenefitBenefit);
                }
                memberObj.benefits = benefits;
            } else if (
                member.RelationshipToInsured == 'FATHER' ||
                member.RelationshipToInsured == 'MOTHER' ||
                member.RelationshipToInsured == 'FATHERINLAW' ||
                member.RelationshipToInsured == 'MOTHERINLAW'
            ) {
                memberObj.memberType = 'PARENT';
                memberObj.relationship = member.RelationshipToInsured;

                // PARENTAIRTIME
                if (member.Radio_Announcement__c != 0 && member.Radio_Announcement__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit radioAnnouncementBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                        '25.PARENTAIRTIME',
                        member.Radio_Announcement__c,
                        member.Radio_Announcement_benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(radioAnnouncementBenefitBenefit);
                }

                // PARENTFUNERALBENEFIT
                if (member.funeral_Cover__c != 0 && member.funeral_Cover__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit funeralBenefit = INS_Quote_Helper.createMemberBenefit(
                        '9.PARENTFUNERAL',
                        member.funeral_Cover__c,
                        member.Funeral_Benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(funeralBenefit);
                }

                // PARENTREPATRIATIONBENEFIT
                if (member.Transport__c != 0 && member.Transport__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit transportBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                        '30.PARENTREPATRIATION',
                        member.Transport__c,
                        member.Transport_Benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(transportBenefitBenefit);
                }
                memberObj.benefits = benefits;
            } else {
                memberObj.memberType = 'EXTENDEDFAMILY';
                memberObj.relationship = member.RelationshipToInsured;

                // EXTENDEDFAMILYAIRTIME
                if (member.Radio_Announcement__c != 0 && member.Radio_Announcement__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit radioAnnouncementBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                        '27.EXTENDEDFAMILYAIRTIME',
                        member.Radio_Announcement__c,
                        member.Radio_Announcement_benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(radioAnnouncementBenefitBenefit);
                }

                // EXTENDEDFAMILYFUNERALBENEFIT
                if (member.funeral_Cover__c != 0 && member.funeral_Cover__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit funeralBenefit = INS_Quote_Helper.createMemberBenefit(
                        '11.EXTENDEDFAMILYBENEFIT',
                        member.funeral_Cover__c,
                        member.Funeral_Benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(funeralBenefit);
                }

                // EXTENDEDFAMILYREPATRIATION
                if (member.Transport__c != 0 && member.Transport__c != null) {
                    INS_Quick_Quote_Wrapper.MemberBenefit transportBenefitBenefit = INS_Quote_Helper.createMemberBenefit(
                        '32.EXTENDEDFAMILYREPATRIATION',
                        member.Transport__c,
                        member.Transport_Benefit_Id__c,
                        PREMIUM_FREQUENCY_MONTHLY
                    );
                    benefits.add(transportBenefitBenefit);
                }
                memberObj.benefits = benefits;
            }
            memberList.add(memberObj);
        }

        // Create the request payload using INS_Quick_Quote_Wrapper
        if (memberList.size() > 0) {
            INS_Quick_Quote_Wrapper.MemberPayload payload = new INS_Quick_Quote_Wrapper.MemberPayload();
            payload.members = memberList;
            payload.referenceNumber = quoteNumber;

            // Serialize the payload to JSON
            String payloadJson = JSON.serialize(payload);
           
            // Get OAuth access token from OAuthHelper class
            String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);
            httpRequest.setEndpoint(
                'callout:INS_Quote_Named_Credentials' + '/life-quoting/quotes/' + quoteNumber + '/members'
            );
            if (isUpdate) {
                httpRequest.setMethod(INS_Quote_Helper.HTTP_METHOD_PUT);
            } else {
                httpRequest.setMethod(INS_Quote_Helper.HTTP_METHOD_POST);
            }
            httpRequest.setHeader(INS_Quote_Helper.HEADER_CONTENT_TYPE, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(INS_Quote_Helper.HEADER_ACCEPT, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setTimeout(60000);
            httpRequest.setHeader(
                INS_Quote_Helper.HEADER_AUTHORIZATION,
                INS_Quote_Helper.AUTHORIZATION_TYPE_BEARER + accessToken
            );
            httpRequest.setHeader(INS_Quote_Helper.HEADER_CLIENT_COUNTRY, INS_Quote_Helper.CLIENT_COUNTRY_SA);
            httpRequest.setBody(payloadJson);
            // Send HTTP request
            Http http = new Http();
            try {
                response = http.send(httpRequest);
                if (response.getStatusCode() == 200) {
                    // Handle successful response
                    returnList = handleSuccessfulResponse(response, member);
                } else {
                    // Handle error response
                    throw new INS_CustomException(response.getBody());
                }
            } catch (Exception ex) {
                LOGGER.error('INS_Create_Quote_Members.createQuoteMembers', ex);
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return returnList;
    }

    /**
     * @description       : AuraEnabled method to delete quote members.
     * @author            : Shams Ul Arifeen
     * @param  memberId
     * @param  quoteNumber
     **/
    @AuraEnabled
    public static void deleteQuoteMembers(String memberId, String quoteNumber) {
        // Create a list to store INS_Quick_Quote_Wrapper.AddMember objects
        List<INS_Quick_Quote_Wrapper.itemKey> memberKeysList = new List<INS_Quick_Quote_Wrapper.itemKey>();

        // Create the request payload using INS_Quick_Quote_Wrapper
        INS_Quick_Quote_Wrapper.DeleteMemberPayload payload = new INS_Quick_Quote_Wrapper.DeleteMemberPayload();
        payload.referenceNumber = quoteNumber;

        // Create the ItemKey object and add it to the list
        INS_Quick_Quote_Wrapper.itemKey itemKey = new INS_Quick_Quote_Wrapper.itemKey();
        itemKey.id = memberId;
        memberKeysList.add(itemKey);

        // Serialize the payload to JSON
        if (!memberKeysList.isEmpty()) {
            payload.itemKeys = memberKeysList;
            String payloadJson = JSON.serialize(payload);
          
            // Get OAuth access token from OAuthHelper class
            String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);

            HttpRequest httpRequest = new HttpRequest();
            HttpResponse response = new HttpResponse();

            httpRequest.setEndpoint(
                'callout:INS_Quote_Named_Credentials' + '/life-quoting/quotes/' + quoteNumber + '/members'
            );
            httpRequest.setMethod(INS_Quote_Helper.HTTP_METHOD_PATCH);
            httpRequest.setHeader(INS_Quote_Helper.HEADER_CONTENT_TYPE, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(INS_Quote_Helper.HEADER_ACCEPT, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setTimeout(60000);
            httpRequest.setHeader(
                INS_Quote_Helper.HEADER_AUTHORIZATION,
                INS_Quote_Helper.AUTHORIZATION_TYPE_BEARER + accessToken
            );
            httpRequest.setHeader(INS_Quote_Helper.HEADER_CLIENT_COUNTRY, INS_Quote_Helper.CLIENT_COUNTRY_SA);
            httpRequest.setBody(payloadJson);
            try {
                // Send HTTP request
                Http http = new Http();
                response = http.send(httpRequest);
                if (response.getStatusCode() != 200) {
                    throw new INS_CustomException(response.getBody());
                }
            } catch (Exception ex) {
                LOGGER.error('INS_Create_Quote_Members.deleteQuoteMembers', ex);
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }

    /**
     * @description       : Handles successful API response.
     * @author            : Shams Ul Arifeen
     * @param  response
     * @param  member
     * @return            : InsurancePolicyParticipant
     **/
    private static InsurancePolicyParticipant handleSuccessfulResponse(
        HttpResponse response,
        InsurancePolicyParticipant member
    ) {
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> membersList = (List<Object>) responseMap.get('members');
        for (Object memberObj : membersList) {
            Decimal premiumAmount = 0.00;
            Map<String, Object> memberMap = (Map<String, Object>) memberObj;
            String memberId = (String) memberMap.get('memberId');
            String idNumber = (String) memberMap.get('idNumber');
            if (member.IdentityNumber__c == idNumber) {
                member.Member_Id__c = memberId;
                List<Object> benefits = (List<Object>) memberMap.get('benefits');
                for (Object benefitObj : benefits) {
                    Map<String, Object> benefitMap = (Map<String, Object>) benefitObj;
                    String benefitType = (String) benefitMap.get('benefitType');
                    // Map premium data based on benefit type
                    if (benefitType.contains('CATERING')) {
                        member.Catering_Benefit_Id__c = (String) benefitMap.get('benefitId');
                    } else if (benefitType.contains('TOMBSTONE') || benefitType.contains('ADVERTISEMENT')) {
                        member.Tombstone_Benefit_Id__c = (String) benefitMap.get('benefitId');
                    } else if (benefitType.contains('FUNERAL') || benefitType == 'EXTENDEDFAMILYBENEFIT') {
                        member.Funeral_Benefit_Id__c = (String) benefitMap.get('benefitId');
                    } else if (benefitType.contains('REPATRIATION')) {
                        member.Transport_Benefit_Id__c = (String) benefitMap.get('benefitId');
                    } else if (benefitType.contains('AIRTIME') || benefitType.contains('RADIOANNOUNCEMENT')) {
                        member.Radio_Announcement_benefit_Id__c = (String) benefitMap.get('benefitId');
                    } else if (benefitType.contains('GROCERYBENEFIT')) {
                        member.Shopping_Benefit_Id__c = (String) benefitMap.get('benefitId');
                    }
                    premiumAmount += (Decimal) benefitMap.get('premium');
                }

                member.Monthly_Premium__c = premiumAmount;
            }
        }
        return member;
    }
}