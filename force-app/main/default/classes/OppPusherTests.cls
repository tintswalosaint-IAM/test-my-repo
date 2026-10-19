@isTest
private class OppPusherTests {
private static sObject[] OpptyList;
private static List<Opportunity> testOpptys = new List<Opportunity>();

    static testMethod void myOppUnitTest() {
        // create an oppty
        Opportunity oTestOppty=createOppty('testOppty');
        // set the date to Jan 1 of next year
        Integer myYear = Date.today().year();
        oTestOppty.CloseDate = Date.newInstance(myYear + 1, 1, 1);
        update oTestOppty;
        
        //check the push counter
        Opportunity oReadOppty = [SELECT Id, PushCount__c FROM Opportunity WHERE Id = :oTestOppty.Id];
        System.assertEquals(oReadOppty.PushCount__c, 1, 'Push counter is: ' + oReadOppty.PushCount__c);
        
        // update the close date to the 15th of January
        oTestOppty.CloseDate = Date.newInstance(myYear + 1, 1, 15);
        update oTestOppty;
        oReadOppty = [SELECT Id, PushCount__c FROM Opportunity WHERE Id = :oTestOppty.Id];
        System.assertEquals(oReadOppty.PushCount__c, 1, 'After the first update, the push counter is: ' + oReadOppty.PushCount__c);
        
        // move it out to the following year
        oTestOppty.CloseDate=Date.newInstance(myYear + 2, 1, 1);
        update oTestOppty;
        oReadOppty = [SELECT Id, PushCount__c FROM Opportunity WHERE Id = :oTestOppty.Id];
        System.assertEquals(oReadOppty.PushCount__c, 2, 'After the 2nd update, the push counter is: ' + oReadOppty.PushCount__c);
        
        // don't change the date, no change
        oTestOppty.CloseDate = Date.newInstance(myYear + 2, 1, 1);
        update oTestOppty;
        oReadOppty = [SELECT Id, PushCount__c FROM Opportunity WHERE Id = :oTestOppty.Id];
        System.assertEquals(oReadOppty.PushCount__c, 2, 'After the 3rd update, the push counter is: ' + oReadOppty.PushCount__c + ' (Should be the same)');
    }
    
    private static Opportunity createOppty(String sOppName) {
        // test account
        Account acc = new Account();
        acc.FirstName = 'Tester';
        acc.LastName = 'Tests';
        insert acc;
        // test opportunity
        Opportunity oNewOpp= new Opportunity(
            AccountId = acc.Id,
            Name = sOppName,
            CloseDate = Date.newInstance(2015, 11, 11),
            StageName ='Prospecting'
        );
        insert oNewOpp;
        testOpptys.add(oNewOpp);
        return oNewOpp;
    }
}