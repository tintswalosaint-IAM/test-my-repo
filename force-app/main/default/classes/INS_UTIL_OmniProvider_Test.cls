/**
 * @description tests for omniscript connection class
 * Covers both the legacy invokeMethod and Callable.call entry points.
 * @author Alexandr Goryachko
 * @date 2025/02/03
 */
@IsTest
public class INS_UTIL_OmniProvider_Test {
    @TestSetup
    private static void testSetup() {
        Profile portalProfile = [
            SELECT Id FROM Profile
            WHERE Name = 'AOB_Community Authenticated Customer'
                AND UserLicense.Name = 'Customer Community Plus Login' LIMIT 1
        ];
        User adminUser = [
            SELECT Id 
            FROM User 
            WHERE Profile.Name = 'System Administrator' 
                AND IsActive = true
                AND UserRoleId != null
            LIMIT 1
        ];
        String personContactId;
        System.runAs(adminUser) {
            Account acc = new Account(
                RecordTypeId = Schema.SObjectType.Account
                    .getRecordTypeInfosByDeveloperName()
                    .get('Person_Account_Prospect').getRecordTypeId(),
                FirstName = 'Jane',
                LastName = 'Smith',
                PersonEmail = 'jane@test.com',
                PersonBirthdate = Date.newInstance(1995,5,5),
                CMN_IdentityNumber__pc = 'EXIST123'
            );
            insert acc;
            personContactId = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id].PersonContactId;
        
            PartyProfile partyProfile = new PartyProfile(
                RecordTypeId = Schema.SObjectType.PartyProfile
                    .getRecordTypeInfosByDeveloperName().get('Insurance_Individual')
                    .getRecordTypeId(),
                AccountId = acc.Id,
                Name = 'Test'
            ); 
            insert partyProfile;

            insert new PartyProfileAddress(
                Name = 'test',
                PartyProfileId = partyProfile.Id
            );

            insert new TaxDetails__c(
                Name = 'Tax Captured - Platinum Life Onboarding',
                Account__c = acc.Id,
                TaxNumber__c = '123456789',
                Country__c = 'ZA'
            );
        }

        System.runAs(adminUser) {
            User portalUser = new User(
                Alias = 'portal',
                Email='randomportal@standardbank.co.za',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Portal PLI',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = portalProfile.Id,
                ContactId = personContactId,
                TimeZoneSidKey ='America/Los_Angeles',
                UserName ='randomportaluser@standardbank.co.za'
            );
            insert portalUser;
            assignPermSetGroups(portalUser);
        }
    }

    private static void assignPermSetGroups(User u) {
        List<String> permSetGroupApiName = new List<String>{
            'Platinum_Life_Partners_and_Agents',
            'Platinum_Life_Self_Service_Permissions',
            'Platinum_Life_Self_Service'
        };
        List<PermissionSetGroup> permSetGroups = [
            SELECT Id, DeveloperName, Status
            FROM PermissionSetGroup
            WHERE DeveloperName IN :permSetGroupApiName
        ];
        for (PermissionSetGroup item : permSetGroups) {
            if (item.Status != 'Updated') {
                Test.calculatePermissionSetGroup(item.Id);
            }
        }
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
        for (PermissionSetGroup ps : permSetGroups) {
            psa.add(
                new PermissionSetAssignment(
                    PermissionSetGroupId = ps.Id,
                    AssigneeId = u.Id
                )
            );
        }
        insert psa;
    }

    @IsTest
    private static void getOmniPicklistPositive() {
        String methodName = 'getOmniPicklistSource';
        Map<String, Object> inputMap = new Map<String, Object>{};
        Map<String, Object> options = new Map<String, Object>{};
        Map<String, Object> outMap = new Map<String, Object>();
        Test.startTest();
            INS_UTIL_OmniProvider util = new INS_UTIL_OmniProvider();
            Boolean isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);
            Assert.isTrue(isSuccess, 'Expected true but got false in logError method');
            Assert.isTrue(outMap.containsKey('dependency'), 'There is no dependencies map');
            methodName = 'getOmniPicklistEmpType';
            isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);
            Assert.isTrue(isSuccess, 'Expected true but got false in logError method');
            Assert.isTrue(outMap.containsKey('dependency'), 'There is no dependencies map');
            methodName = 'getOmniPicklistOccupation';
            isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);
            Assert.isTrue(isSuccess, 'Expected true but got false in logError method');
            Assert.isTrue(outMap.containsKey('dependency'), 'There is no dependencies map');
        Test.stopTest();
    }

    @IsTest
    private static void callCallableEntryPoint() {
        INS_UTIL_OmniProvider util = new INS_UTIL_OmniProvider();
        Map<String, Object> inputMap = new Map<String, Object>{'value' => 'test'};
        Map<String, Object> outMap = new Map<String, Object>{'existing' => true};
        Map<String, Object> options = new Map<String, Object>{'source' => 'test'};
        Map<String, Object> args = new Map<String, Object>{
            'input' => inputMap,
            'output' => outMap,
            'options' => options
        };

        Test.startTest();
            Object result = util.call('getOmniPicklistSource', args);
        Test.stopTest();

        Assert.areEqual(outMap, (Map<String, Object>) result, 'call should return the supplied output map');
        Assert.isTrue(outMap.containsKey('existing'), 'Existing output values should be preserved');
        Assert.isTrue(outMap.containsKey('dependency'), 'Callable dispatch should populate dependency');

        Assert.isTrue(
            ((Map<String, Object>) util.call('unsupportedMethod', null)).isEmpty(),
            'Null args should use empty maps'
        );

        Map<String, Object> invalidArgs = new Map<String, Object>{
            'input' => 'invalid',
            'output' => 'invalid',
            'options' => 'invalid'
        };
        Assert.isTrue(
            ((Map<String, Object>) util.call('unsupportedMethod', invalidArgs)).isEmpty(),
            'Non-map args should use empty maps'
        );
    }

    @IsTest
    private static void getOmniPicklistException() {
        String methodName = 'getOmniPicklistWrongName';
        Map<String, Object> inputMap = new Map<String, Object>{};
        Map<String, Object> options = new Map<String, Object>{};
        Map<String, Object> outMap = new Map<String, Object>();
        Test.startTest();
            INS_UTIL_OmniProvider util = new INS_UTIL_OmniProvider();
            Boolean isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);
            Assert.isFalse(isSuccess, 'Expected false but got true in logError method');
        Test.stopTest();
        List<sbgplatform__rflib_Log__c> logs = [SELECT Id FROM sbgplatform__rflib_Log__c];
        Assert.isFalse(logs.isEmpty(), 'Logs records were not created');
    }

    @IsTest
    private static void getDetailsPositive() {
        String methodName = 'getAccountDetails';
        User portalUser = [SELECT Id FROM User WHERE LastName = 'Portal PLI'];
        Map<String, Object> inputMap = new Map<String, Object>{};
        Map<String, Object> options = new Map<String, Object>{
            'portalUserId' => portalUser.Id
        };
        Map<String, Object> outMap = new Map<String, Object>();
        Test.startTest();
            INS_UTIL_OmniProvider util = new INS_UTIL_OmniProvider();
            Boolean isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);
            String response = JSON.serialize(outMap.get('result'));
            Assert.isTrue(isSuccess, 'Expects successfull response in getAccountDetails');
            Assert.isTrue(response.containsIgnoreCase('Account'), 'Account was not found');
            methodName = 'getEmploymentDetails';
            isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);
            response = JSON.serialize(outMap.get('result'));
            Assert.isTrue(isSuccess, 'Expects successfull response in getEmploymentDetails');
            Assert.isTrue(response.containsIgnoreCase('PartyProfile'), 'PartyProfile was not found');
            methodName = 'getAddressDetails';
            isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);
            response = JSON.serialize(outMap.get('result'));
            Assert.isTrue(isSuccess, 'Expects successfull response in getAddressDetails');
            Assert.isTrue(response.containsIgnoreCase('PartyProfileAddress'), 'PartyProfileAddress was not found');
        Test.stopTest();
    }

    @IsTest
    private static void getTaxDetailsForLoggedInUserPositive() {
        User portalUser = [SELECT Id FROM User WHERE LastName = 'Portal PLI'];
        System.runAs(portalUser) {
            Test.startTest();
                List<TaxDetails__c> taxList = INS_SRV_PortalData.getTaxDetailsForLoggedInUser();
                Assert.isTrue(taxList.size() > 0, 'Expects tax records');
            Test.stopTest();
        }
    }
}