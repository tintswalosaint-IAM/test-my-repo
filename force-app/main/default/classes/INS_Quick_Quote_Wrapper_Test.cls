/**
 * @description      : SFP-46847: test Class for INS_Quick_Quote_Wrapper 
 * @author           : Irshad
 * @date             : October 2025
 * @LastModifiedBy   : 
 */

@IsTest
public class INS_Quick_Quote_Wrapper_Test {

    @IsTest
    static void testWrapperInstantiation() {
        // QuotePayload
        INS_Quick_Quote_Wrapper.QuotePayload payload = new INS_Quick_Quote_Wrapper.QuotePayload();
        payload.quoteId = 'Q-001';
        payload.channel = 'Online';
        payload.annualBenefitIncrease = 10;
        payload.requestId = 'REQ-001';
        payload.cashBackOption = true;
        payload.consultantCode = 'CONS-123';

        // ProductRules
        INS_Quick_Quote_Wrapper.ProductRules productRules = new INS_Quick_Quote_Wrapper.ProductRules();
        productRules.productId = 'PROD-001';
        productRules.annualBenefitIncrease = 5;
        productRules.waiveWaitingPeriod = true;
        payload.productRules = productRules;

        // Member and Benefit setup
        INS_Quick_Quote_Wrapper.Member member = new INS_Quick_Quote_Wrapper.Member();
        member.firstName = 'John';
        member.lastName = 'Doe';
        member.contactNumber = '1234567890';
        member.email = 'john.doe@test.com';
        member.gender = 'Male';
        member.dateOfBirth = '1990-01-01';
        member.memberType = 'Main';
        member.terminalIllness = false;
        member.recentHospitalisation = false;
        member.hasCoverBeenRefused = false;
        member.idCountryOfIssue = 'ZA';
        member.identityDocumentType = 'ID';
        member.identityNumber = '9001011234089';
        member.maritalStatus = 'Single';
        member.relationship = 'Self';
        member.customerExternalId = 'CUST-001';

        // Benefit + Beneficiaries
        INS_Quick_Quote_Wrapper.Benefit benefit = new INS_Quick_Quote_Wrapper.Benefit();
        benefit.benefitType = 'Funeral';
        benefit.coverAmount = 10000.0;
        benefit.duration = '12M';
        benefit.benefitId = 'BEN-001';
        benefit.benefitAmountValue = 10000.0;
        benefit.benefitFee = 50.0;
        benefit.benefitFrequencyValue = 'Monthly';
        benefit.benefitKey = 'KEY-001';
        benefit.personId = 'PER-001';
        benefit.memberId = 'MEM-001';

        INS_Quick_Quote_Wrapper.Beneficiaries beneficiary = new INS_Quick_Quote_Wrapper.Beneficiaries();
        beneficiary.allocationAmount = 100;
        beneficiary.allocationType = 'Percentage';
        benefit.beneficiaries = new List<INS_Quick_Quote_Wrapper.Beneficiaries>{beneficiary};
        member.benefits = new List<INS_Quick_Quote_Wrapper.Benefit>{benefit};
        payload.members = new List<INS_Quick_Quote_Wrapper.Member>{member};

        // QuoteBenefitRequest
        INS_Quick_Quote_Wrapper.QuoteBenefitRequest qbr = new INS_Quick_Quote_Wrapper.QuoteBenefitRequest();
        qbr.referenceNumber = 'REF-001';
        INS_Quick_Quote_Wrapper.QuoteBenefit qb = new INS_Quick_Quote_Wrapper.QuoteBenefit();
        qb.benefitId = 'BEN-002';
        qb.benefitType = 'Transport';
        qb.benefitAmountValue = 2000.0;
        qb.benefitFee = 25.0;
        qb.benefitFrequencyValue = 'Monthly';
        qb.benefitKey = 'KEY-002';
        qb.personId = 'PER-002';
        qb.memberId = 'MEM-002';
        qbr.benefits = new List<INS_Quick_Quote_Wrapper.QuoteBenefit>{qb};

        // MemberPayload + AddMember
        INS_Quick_Quote_Wrapper.MemberPayload memberPayload = new INS_Quick_Quote_Wrapper.MemberPayload();
        memberPayload.referenceNumber = 'REF-002';
        INS_Quick_Quote_Wrapper.AddMember addMember = new INS_Quick_Quote_Wrapper.AddMember();
        addMember.firstName = 'Jane';
        addMember.surname = 'Smith';
        addMember.identityDocumentType = 'Passport';
        addMember.idNumber = 'A12345';
        addMember.memberType = 'Spouse';
        addMember.bpid = 'BP-001';
        addMember.dateOfBirth = '1992-05-12';
        addMember.memberId = 'MEM-003';
        addMember.gender = 'Female';
        addMember.staff = 'No';
        addMember.relationship = 'Wife';
        addMember.isStaff = 'No';

        INS_Quick_Quote_Wrapper.MemberBenefit mb = new INS_Quick_Quote_Wrapper.MemberBenefit();
        mb.premiumType = 'Standard';
        mb.benefitType = 'Catering';
        mb.prefix = 'CAT';
        mb.benefitKey = 'KEY-003';
        mb.benefitId = 'BEN-003';
        mb.benefitFrequencyValue = 'Monthly';
        mb.benefitFee = 30.0;
        mb.benefitAmountValue = 5000.0;
        addMember.benefits = new List<INS_Quick_Quote_Wrapper.MemberBenefit>{mb};
        memberPayload.members = new List<INS_Quick_Quote_Wrapper.AddMember>{addMember};

        // DeleteMemberPayload
        INS_Quick_Quote_Wrapper.DeleteMemberPayload delPayload = new INS_Quick_Quote_Wrapper.DeleteMemberPayload();
        delPayload.referenceNumber = 'REF-DEL-001';
        INS_Quick_Quote_Wrapper.ItemKey key = new INS_Quick_Quote_Wrapper.ItemKey();
        key.id = 'ITEM-001';
        delPayload.itemKeys = new List<INS_Quick_Quote_Wrapper.ItemKey>{key};

        // AnnualBenefitIncreasePayload
        INS_Quick_Quote_Wrapper.AnnualBenefitIncreasePayload abp = new INS_Quick_Quote_Wrapper.AnnualBenefitIncreasePayload();
        abp.referenceNumber = 'REF-003';
        abp.annualBenefitIncrease = 10;

        // Response
        INS_Quick_Quote_Wrapper.Response res = new INS_Quick_Quote_Wrapper.Response();
        res.totalBenefitAmount = 20000;
        res.totalPremium = 300;
        res.quoteNumber = 'Q-1001';
        res.quoteId = 'QID-1001';
        res.memberId = 'MEM-001';
        res.mainFuneralId = 'FUN-001';
        res.accessToken = 'TOKEN-ABC';
        res.beneficiariesJson = '{"beneficiaries": []}';

        // Beneficiary
        INS_Quick_Quote_Wrapper.Beneficiary b = new INS_Quick_Quote_Wrapper.Beneficiary();
        b.beneficiaryFirstName = 'Adam';
        b.beneficiarySurname = 'Johnson';
        b.beneficiaryId = 'BENEF-001';
        b.beneficiaryRelationship = 'Son';
        b.allocationAmount = 50;
        b.dateOfBirth = '2010-10-10';
        b.gender = 'Male';

        // PremiumBenefitResponse
        INS_Quick_Quote_Wrapper.PremiumBenefitResponse pbr = new INS_Quick_Quote_Wrapper.PremiumBenefitResponse();
        pbr.funeralPremium = 100.0;
        pbr.cateringPremium = 20.0;
        pbr.transportPremium = 15.0;
        pbr.tombStonePremium = 10.0;
        pbr.shoppingPremium = 5.0;
        pbr.radioAnnouncementPremium = 2.0;
        pbr.totalPremium = 152.0;
        pbr.cateringBenefitId = 'CB-001';
        pbr.tombstoneBenefitId = 'TB-001';
        pbr.transportBenefittId = 'TR-001';
        pbr.shoppingBenefitId = 'SP-001';
        pbr.radioAnnouncementBenefitId = 'RA-001';
        pbr.funeralBenefitId = 'FB-001';

        // CashBackBenefitPayload
        INS_Quick_Quote_Wrapper.CashBackBenefitPayload cb = new INS_Quick_Quote_Wrapper.CashBackBenefitPayload();
        cb.referenceNumber = 'REF-004';
        cb.cashBackBenefit = true;

        // Assertions
        Assert.areEqual('Q-001', payload.quoteId,'Quote Number will match');

    }
}