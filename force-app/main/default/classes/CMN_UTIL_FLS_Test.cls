@IsTest
public with sharing class CMN_UTIL_FLS_Test {
  @IsTest
  private static void testupdateRecordWithFLSCheck() {
        
      Account acc = new Account(LastName= 'Mulner',
                                FirstName= 'Jacob',
                                Salutation= 'Mr.',
                                MiddleName= 'Steve',
                                Phone= '276788975',
                                CurrencyIsoCode= 'GBP',
                                PersonEmail= 'mock.mulner@test.com',
                                PersonBirthdate= date.newInstance(1977,1,4)
                                );
        
     insert acc;
      
     Test.startTest();
     acc.LastName = 'Miller';
     acc.FirstName = 'David';
     CMN_UTIL_FLS.updateRecordWithFLSCheck(acc);
	 Account testAccount = [SELECT Id, FirstName, LastName FROM Account LIMIT 1];
     Test.stopTest();
     Assert.areEqual(testAccount.FirstName, 'David', 'Account FirstName updated');
     Assert.areEqual(testAccount.LastName, 'Miller', 'Account LastName updated');
  }

  @IsTest
  private static void insertRecordWithFLSCheck() {
     
      Account acc = new Account(LastName= 'Mulner',
                                FirstName= 'Jacob',
                                Salutation= 'Mr.',
                                MiddleName= 'Steve',
                                Phone= '276788975',
                                CurrencyIsoCode= 'GBP',
                                PersonEmail= 'mock.mulner@test.com',
                                PersonBirthdate= date.newInstance(1977,1,4)
                                );
        
      
     Test.startTest();
     CMN_UTIL_FLS.insertRecordWithFLSCheck(acc);
	 Account testAccount = [SELECT Id, FirstName, LastName FROM Account LIMIT 1];
     Test.stopTest();
     Assert.areEqual(testAccount.FirstName, 'Jacob', 'Account FirstName updated');
     Assert.areEqual(testAccount.LastName, 'Mulner', 'Account LastName updated');
   }

  
}