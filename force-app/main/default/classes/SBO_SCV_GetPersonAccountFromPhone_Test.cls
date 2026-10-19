/**
 * @description Test class for SBO_SCV_GetPersonAccountFromPhone
 * @author Makepositive 
 * @date December 2023
 * User Story : SFP-29277 - Inbound call routing
 */
@isTest
public class SBO_SCV_GetPersonAccountFromPhone_Test {

    @testSetup static void setup() {
        // Create common test accounts
        Id prsnAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account personA = new Account();
        personA.firstname = 'Service';
        personA.lastname = 'cloud';        
        personA.PersonEmail = 'service.cloud@gmail.com';
        personA.ExternalCIFCountry__c = 'OS';
        personA.Phone = '+44-9999999999';
        insert personA;    
    }
    static testmethod void getPersonAccount(){
        
        Test.startTest();
            List<String> listPhones = new List<String>();
            listPhones.add('+44-9999999999');
            List<Account> listAccount = new List<Account>();
            listAccount = SBO_SCV_GetPersonAccountFromPhone.getPersonAccountId(listPhones);
            Assert.areEqual('+44-9999999999',listAccount[0].Phone); 
        Test.stopTest(); 
      }
    
     static testmethod void getPersonAccount1(){
  			Test.startTest(); 
         	List<String> listPhones1 = new List<String>();
            listPhones1.add('+44-9999999911');
            List<Account> listAccount1 = new List<Account>();
                if(SBO_SCV_GetPersonAccountFromPhone.getPersonAccountId(listPhones1)!= null){
                       listAccount1 = SBO_SCV_GetPersonAccountFromPhone.getPersonAccountId(listPhones1);
                }
            Assert.areNotEqual(1,listAccount1.size()); 
        Test.stopTest();
      }
         
    
	}