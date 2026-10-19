/**
 * @description Test class for Producer Selector
 * @author Alexandr Goryachko
 * @date 2024/10/22
 * @Last Modified By : Ihtishaam Mohammoodally
 * @Last Modified On : 18-02-2026
 * @Modification description: Added test method for getProducersByInternalUserId method. User Story: SFP-55981
*/
@isTest
public class SEL_Producer_TEST {
    @testSetup 
    private static void setup() {
        Account acc = WI_DAL_DataFactory.createAccount(null);
        insert acc;

        acc = [SELECT Id,PersonContactId From Account where Id =: acc.Id];
        Producer producer = WI_DAL_DataFactory.createProducer(
            new Map<String, Object>{
                'AccountId' => acc.Id,
                'Name' => 'John Snow',
                'ContactId' => acc.PersonContactId
            }
        );
        insert producer;
        
        Producer currentUserProducer = WI_DAL_DataFactory.createProducer(
            new Map<String, Object>{
                'AccountId' => acc.Id,
                'Name' => 'John Snow',
                'InternalUserId' => UserInfo.getUserId()
            }
        );
        insert currentUserProducer;
    }

    /**
     * @description To check positive retrieve data
     */
    @isTest
    private static void getProducersByAccountNamesTest() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        List<Producer> prds = new SEL_Producer().getProducersByAccountNames(new List<String>{acc.Name});
        Assert.isTrue(prds.size() == 1, 'Error in the selector method');
        Test.stopTest();
    }
    
     /**
     * @description To check positive retrieve data
     */
    @isTest
    private static void getProducersByInternalUserId(){
        Test.startTest();
        Producer existingProducerRecord = new SEL_Producer().getProducersByInternalUserId(UserInfo.getUserId());
        Test.stopTest();
        Assert.isNotNull(existingProducerRecord);
        Assert.areEqual((String)existingProducerRecord.InternalUserId,UserInfo.getUserId());
        
    }
    
}