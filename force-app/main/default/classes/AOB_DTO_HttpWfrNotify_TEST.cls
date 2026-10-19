/**
 * @description The REST Web Service DTO Test Class
 *
 * <p>SFP-11823</p>
 *
 * @author Mark Bailey (mark.bailey2@standardbank.co.za)
 *
 * @date May 17th 2022
 */
@isTest
public class AOB_DTO_HttpWfrNotify_TEST {
  @isTest
  static void testParse() {
    AOB_DTO_HttpWfrNotify.WfrNotify wfr = new AOB_DTO_HttpWfrNotify.WfrNotify();
    wfr.wfrStatus = 'Verification Passed';
    System.assertEquals(wfr.wfrStatus, 'Verification Passed', 'WFR Status should be Passed');
    wfr.wfrMessage = '2022.05.03.16.32.58 Success';
    System.assertEquals(wfr.wfrMessage, '2022.05.03.16.32.58 Success', 'WFR Message should have a value');
    wfr.wfrErrorCode = '0';
    System.assertEquals(wfr.wfrErrorCode, '0', 'WFR Error Code should be 0');
    String json = '{"wfrStatus":"Verification Passed","wfrMessage":"2022.05.03.16.32.58 Success","wfrErrorCode":"0"}';
    AOB_DTO_HttpWfrNotify obj = AOB_DTO_HttpWfrNotify.parse(json);
    System.assert(obj != null, 'Object should not be null');
  }
}