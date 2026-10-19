/**
 * @description  test class for QuoteconversionResponseWrapper_Test
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date Nov 07th 2023
 */
@isTest
public class QuoteconversionResponseWrapper_Test 
{
    /**
 * @description  test class for TestValidationResult
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date Nov 07th 2023
 */

    @isTest
    static void TestValidationResult() {
        QuoteconversionResponseWrapper QRW=new QuoteconversionResponseWrapper();
        QuoteconversionResponseWrapper.validationResult validationResult = new QuoteconversionResponseWrapper.validationResult();
        validationResult.isValid = true;
        validationResult.fullValidationMessage = '10';        
        QRW.otpNumber=100;
        QRW.referenceNumber='100';
        QRW.PolicyNumber='Test';
        
        List<string>  message = new List<string>();
        message.add('Item1');
		validationResult.validationMessages = message;
        System.assertEquals(true, validationResult.isValid, 'isDisplay should be true.');
        System.assertEquals('10', validationResult.fullValidationMessage, 'maxItems should be 10.');
    }

    /**
 * @description  test class for testquoteHeader
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * * @date Nov 07th 2023
 */
    
    @isTest
    static void TestquoteHeader() {
        QuoteconversionResponseWrapper.quoteHeader quoteHeader = new QuoteconversionResponseWrapper.quoteHeader();
        quoteHeader.cashBackPremium = 'Active';
        quoteHeader.debitOrderDate = '2023-11-09';
        quoteHeader.cashBackOption = '10';
        quoteHeader.coverEffectiveDate = '2023-11-09';
        quoteHeader.ppol = 'Test';
        quoteHeader.faAgreementNumber = '10';      
        quoteHeader.leadId = 'Lead1';
        quoteHeader.costCenterNumber = '001';
        quoteHeader.requestId = '001';
        quoteHeader.branchCode = '03001';
        quoteHeader.status = 'Active';
        quoteHeader.consultantCode = 'code1';
        quoteHeader.totalPremium = 1000;
        quoteHeader.campaignCode = 'comp1';
         quoteHeader.totalVatAmount = 1000;
         quoteHeader.promoCode = 'pcode';
         quoteHeader.prorataPremium = 1000;
         quoteHeader.waiveWaitingPeriod = true;
         quoteHeader.brokerCommission = 1000;
        quoteHeader.annualBenefitIncrease = 1000;
         quoteHeader.externalReference = 'pcode';
         quoteHeader.referenceNumber = 'ref';
         quoteHeader.waiveWaitingPeriod = true;
         quoteHeader.cashbackBenefit = true;
        quoteHeader.productId = '1000';
         quoteHeader.otpNumber = 1;
         quoteHeader.channel = 'channel';
         quoteHeader.otpDate = '2023-11-09';
         quoteHeader.quoteNumber = '001';
        quoteHeader.saleReferenceId = '1';
         quoteHeader.quoteKey = 'key';
         quoteHeader.quoteId = '001';
         quoteHeader.quoteNumber = '001';
        quoteHeader.headerId = '001';
        
        System.assertEquals('Active', quoteHeader.status, 'Status should be Active.');
        System.assertEquals('001', quoteHeader.quoteId, 'minItems should be 001.');
    }
}