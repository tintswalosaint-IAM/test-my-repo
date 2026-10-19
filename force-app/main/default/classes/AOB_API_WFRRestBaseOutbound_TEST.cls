@isTest
public class AOB_API_WFRRestBaseOutbound_TEST {
    
        @isTest
        public static void AOB_API_WFRRestBaseOutbound_Test() {      
            Test.startTest();
            AOB_API_WFRRestBaseOutbound ss = new AOB_API_WFRRestBaseOutbound();
            ss.populateRequestDTO();
            try {
            ss.setHeaders();
            } catch (Exception e) {
                System.debug(e);
            }
            Test.stopTest();
     
         }

}