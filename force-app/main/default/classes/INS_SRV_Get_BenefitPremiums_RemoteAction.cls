/***************************************************************************************
@Name of the Class :INS_SRV_Get_BenefitPremiums_RemoteAction
@Description :SFP-51843:Created
@Author :Irshad 
@Created Date :12/02/2026
***************************************************************************************/
public with sharing class INS_SRV_Get_BenefitPremiums_RemoteAction {

    private static String buildPayloadJson(String quoteId, List<members> memberList, List<benefits> benefitList) {
        requestWrapper reqWrpClass = new requestWrapper();
        reqWrpClass.referenceNumber = quoteId;
        reqWrpClass.thirdPartyPolicy = false;
        reqWrpClass.members = memberList;
        reqWrpClass.benefits = benefitList;

        return JSON.serialize(reqWrpClass, true);
    }

    private class requestWrapper {
        private String referenceNumber;
        private Boolean thirdPartyPolicy;
        private List<members> members;
        private List<benefits> benefits;
    }

    private class members {
        private String gender;
        private Date dateOfBirth;
    }

    private class benefits {
        private String benefitKey;
        private String benefitType;
        private String benefitAmountValue;
        private String benefitFee;
        private String benefitFrequencyValue;
    }
}