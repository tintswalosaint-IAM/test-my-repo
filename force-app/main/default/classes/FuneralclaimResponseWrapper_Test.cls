/**
 * @description  test class for FuneralclaimResponseWrapper
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param
 * @return
 * @date  Feb 16th 2024
 */
@isTest
public class FuneralclaimResponseWrapper_Test {

    /**
     * @description  test method for FuneralclaimResponseWrapper
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param
     * @return
     * @date  Feb 16th 2024
     */
    @isTest
    static void testFuneralclaimResponseWrapper() {
        FuneralclaimResponseWrapper funeralclaimResponseWrapper = new FuneralclaimResponseWrapper();
        FuneralclaimResponseWrapper.FuneralFNOLResponse funeralFNOLResponse = new FuneralclaimResponseWrapper.FuneralFNOLResponse();

        funeralFNOLResponse.Accepted = true;
        funeralFNOLResponse.Status ='Active';
        funeralFNOLResponse.ClaimEventNumber ='12345';
        FuneralclaimResponseWrapper.Messages messages = new FuneralclaimResponseWrapper.Messages();
        messages.Code = '200';
        messages.Message = 'successful';
        messages.MessageType = 'Success';
        List<FuneralclaimResponseWrapper.Messages> lstMessages = new List<FuneralclaimResponseWrapper.Messages>();
        lstMessages.add(messages);
        funeralFNOLResponse.Messages = lstMessages;
        funeralclaimResponseWrapper.FuneralFNOLResponse = funeralFNOLResponse;
        Assert.areEqual(true, funeralFNOLResponse.Accepted, 'Accepted should be true.');
    }

}