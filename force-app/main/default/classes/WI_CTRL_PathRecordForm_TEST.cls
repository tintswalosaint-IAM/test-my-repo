/**
 * @description Test class of LWC controller
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/02/07
 */
@isTest
public class WI_CTRL_PathRecordForm_TEST {

    @testSetup 
    private static void setup() {
        Account acc = WI_DAL_DataFactory.createAccount(null);
        insert acc;

        Opportunity opp = WI_DAL_DataFactory.createOpportunity(
            new Map<String, Object>{
                'AccountId' => acc.Id
            }
        );
        insert opp;

        Product2 prod = WI_DAL_DataFactory.createProduct(
            new Map<String, Object>{
                'Family' => 'Banking'
            }
        );
        insert prod;

        PricebookEntry standardPrice = WI_DAL_DataFactory.createPricebookEntry(
            new Map<String, Object>{
                'Product2Id' => prod.Id
            }
        );
        insert standardPrice;

        OpportunityLineItem oppProd = WI_DAL_DataFactory.createOpportunityLineItem(
            new Map<String, Object>{
                'OpportunityId' => opp.Id,
                'Product2Id' => prod.Id,
                Schema.OpportunityLineItem.WI_Status__c.getDescribe().getName() => 'Setup'
            }
        );
        insert oppProd;
    }

    /**
     * @description To check retrieve data
     */
    @isTest
    private static void getUpdateDataTest() {
        String objectApi = Schema.OpportunityLineItem.getSObjectType().getDescribe().getName();
        String parentFieldApi = Schema.OpportunityLineItem.Product_Family__c.getDescribe().getName();
        String stageFieldApi = Schema.OpportunityLineItem.WI_Status__c.getDescribe().getName();
        OpportunityLineItem oppProd = [SELECT Id FROM OpportunityLineItem LIMIT 1];

        Test.startTest();
        WI_CTRL_PathRecordForm.DataResponse response = WI_CTRL_PathRecordForm.getData(
            objectApi, 
            parentFieldApi, 
            stageFieldApi, 
            oppProd.Id
        );
        Assert.isTrue(response.isSuccess, 'Wrong get response');
        oppProd.WI_Status__c = 'Initiation';
        response = WI_CTRL_PathRecordForm.updateData(
            oppProd
        );
        Assert.isTrue(response.isSuccess, 'Wrong update response');
        Test.stopTest();
    }

    @isTest
    private static void getDataExceptionTest() {
        String objectApi = Schema.OpportunityLineItem.getSObjectType().getDescribe().getName();
        String parentFieldApi = Schema.OpportunityLineItem.Product_Family__c.getDescribe().getName();
        String stageFieldApi = Schema.OpportunityLineItem.WI_Status__c.getDescribe().getName();

        Test.startTest();
        WI_CTRL_PathRecordForm.DataResponse response = WI_CTRL_PathRecordForm.getData(
            objectApi, 
            parentFieldApi, 
            stageFieldApi, 
            null
        );
        Assert.isFalse(response.isSuccess, 'Success response');
        Test.stopTest();
    }
}