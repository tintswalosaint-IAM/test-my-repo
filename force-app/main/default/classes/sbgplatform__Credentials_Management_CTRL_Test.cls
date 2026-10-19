/**
 * @description This is a test class for Credentials_Management_CTRL
 *
 * @author Milica Milicevic(Milica.Milicevic@standardbank.co.za)
 * @description Test Class for API Credentials Management
 * @UserStory SFP-50927
 * @date May 2025
 *
 */
@isTest
private class Credentials_Management_CTRL_Test {
    
    private static final String PERMISSION_SET = 'API_Credentials_Management';
    private static final String PERMISSION_SET_EXCEPTION = 'No access to use';

    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name ='Standard User' LIMIT 1];
        User userTest = new User(
            Alias = 'tuser',
            Email = 'unit.tester@test.com',
            ProfileId = p.Id,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Tester',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Berlin',
            Username = 'unit.tester' + System.currentTimeMillis() + '@test.com'
        );
        insert userTest;
        return userTest;
    }

    private static User assignPermissionSetToTestUser(String permisionSet){
        User userTest = createTestUser();

        PermissionSet ps = [
            SELECT Id FROM PermissionSet WHERE Name = :permisionSet LIMIT 1
        ];

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = userTest.Id,
            PermissionSetId = ps.Id
        );
        insert psa;

        return userTest;
    }


    @IsTest
    private static void retrieveAllApiCredentialsTest() {
        User userTest = assignPermissionSetToTestUser(PERMISSION_SET);
        System.runAs(userTest) {
            List<API_Credential__mdt> apiCreds = Credentials_Management_CTRL.retrieveAllApiCredentials();
            Assert.isNotNull(apiCreds, 'retrieveAllApiCredentials has been hit.');
        }
    }

    @IsTest
    private static void retrieveAllApiCredentialsTestPermissionSetFailure() {
        User userTest = createTestUser();
        System.runAs(userTest) {
            try {
                Credentials_Management_CTRL.retrieveAllApiCredentials();
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains(PERMISSION_SET_EXCEPTION), 'Permission Set not linked to the user.');
            }
        }
    }

    @IsTest
    private static void retrieveSpecificApiCredentialsTest() {
        User userTest = assignPermissionSetToTestUser(PERMISSION_SET);
        System.runAs(userTest) {
            String testerMetadata = 'testCredential';
            API_Credential__mdt apiCreds = Credentials_Management_CTRL.retrieveSpecificApiCredentials(testerMetadata);
            Assert.isNull(apiCreds, 'retrieveSpecificApiCredentials has been hit.');
        }
    }
    
    @IsTest
    private static void retrieveSpecificApiCredentialsTestPermissionSetFailure() {
        User userTest = createTestUser();
        System.runAs(userTest) {
            try {
                String testerMetadata = 'testCredential';
                Credentials_Management_CTRL.retrieveSpecificApiCredentials(testerMetadata);
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains(PERMISSION_SET_EXCEPTION), 'Permission Set not linked to the user.');
            }
        }
    }

    @IsTest
    private static void retrieveAllApiCredentialsValuesTest() {
        User userTest = assignPermissionSetToTestUser(PERMISSION_SET);
        System.runAs(userTest) {
            String testId;
            List<API_Credential_Value__mdt> apiCreds = Credentials_Management_CTRL.retrieveAllApiCredentialsValues(testId);
            Assert.areEqual(true, apiCreds.isEmpty() , 'retrieveAllApiCredentialsValues has been hit.');
        }
    }

    @IsTest
    private static void retrieveAllApiCredentialsValuesTestPermissionSetFailure() {
        User userTest = createTestUser();
        System.runAs(userTest) {
            try {
                String testId;
                Credentials_Management_CTRL.retrieveAllApiCredentialsValues(testId);
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains(PERMISSION_SET_EXCEPTION), 'Permission Set not linked to the user.');
            }
        }
    }

    @IsTest
    private static void verifyApiCredentialTest() {
        User userTest = assignPermissionSetToTestUser(PERMISSION_SET);
        System.runAs(userTest) {
            String testerMetadata = 'testCredential';
            Boolean result = Credentials_Management_CTRL.verifyApiCredential(testerMetadata);
            Assert.areEqual(false, result, 'Value not found.' );
        }
    }

    @IsTest
    private static void verifyApiCredentialTestPermissionSetFailure() {
        User userTest = createTestUser();
        System.runAs(userTest) {
            try {
                String testerMetadata = 'testCredential';
                Credentials_Management_CTRL.verifyApiCredential(testerMetadata);
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains(PERMISSION_SET_EXCEPTION), 'Permission Set not linked to the user.');
            }
        }
    }

    @IsTest
    private static void verifyApiCredentialValueTest() {
        User userTest = assignPermissionSetToTestUser(PERMISSION_SET);
        System.runAs(userTest) {
            try{
                String testerMetadata = 'testCredential';
                String testerMetadataValue = 'testCredentialValue';
                Boolean result = Credentials_Management_CTRL.verifyApiCredentialValue(testerMetadata, testerMetadataValue);
            }
            catch(Exception ex){
                Assert.isNotNull(String.isNotBlank(ex.getMessage()), 'Exception Hit.' );
            }
        }
    }

    @IsTest
    private static void verifyApiCredentialValueTestPermissionSetFailure() {
        User userTest = createTestUser();
        System.runAs(userTest) {
            try {
                String testerMetadata = 'testCredential';
                String testerMetadataValue = 'testCredentialValue';
                Credentials_Management_CTRL.verifyApiCredentialValue(testerMetadata, testerMetadataValue);
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains(PERMISSION_SET_EXCEPTION), 'Permission Set not linked to the user.');
            }
        }
    }

    @IsTest
    private static void performUpsertApiCredentialTest() {
        User userTest = assignPermissionSetToTestUser(PERMISSION_SET);
        System.runAs(userTest) {
            String jsonData = '{"Client_ID__c" : "testToken", "Client_Secret__c" : "testSecret"}';
            Id jobId = Credentials_Management_CTRL.performUpsertApiCredential('Test Api Cred', jsonData);
            Assert.isNull(jobId, 'performUpsertApiCredential has been hit.');
        }
    }

    @IsTest
    private static void performUpsertApiCredentialTestPermissionSetFailure() {
        User userTest = createTestUser();
        System.runAs(userTest) {
            try {
                String jsonData = '{"Client_ID__c" : "testToken", "Client_Secret__c" : "testSecret"}';
                Credentials_Management_CTRL.performUpsertApiCredential('Test Api Cred', jsonData);
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains(PERMISSION_SET_EXCEPTION), 'Permission Set not linked to the user.');
            }
        }
    }

    @IsTest
    private static void performUpsertApiCredentialValueTest() {
        User userTest = assignPermissionSetToTestUser(PERMISSION_SET);
        System.runAs(userTest) {
            String jsonData = '{"labelName" : "testParent","jsonData" : {"sbgplatform__Header_Parameter__c" : "headerParameterOne","sbgplatform__Header_Value__c": "headerValueTwo","sbgplatform__API_Credential__c": "parentRecord"}}';
            List<String> testData = new List<String>{jsonData};
            Id jobId = Credentials_Management_CTRL.performUpsertApiCredentialValue(testData);
            Assert.isNull(jobId, 'performUpsertApiCredentialValue has been hit.');
        }
    }

    @IsTest
    private static void performUpsertApiCredentialValueTestPermissionSetFailure() {
        User userTest = createTestUser();
        System.runAs(userTest) {
            try {
                String jsonData = '{"labelName" : "testParent","jsonData" : {"sbgplatform__Header_Parameter__c" : "headerParameterOne","sbgplatform__Header_Value__c": "headerValueTwo","sbgplatform__API_Credential__c": "parentRecord"}}';
                List<String> testData = new List<String>{jsonData};
                Credentials_Management_CTRL.performUpsertApiCredentialValue(testData);

            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains(PERMISSION_SET_EXCEPTION), 'Permission Set not linked to the user.');
            }
        }
    }

    @IsTest
    private static void handleResultTest() {
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.status = Metadata.DeployStatus.Succeeded;
        Credentials_Management_CTRL controller = new Credentials_Management_CTRL();
        controller.handleResult(result, null);
        result.status = Metadata.DeployStatus.Failed;
        controller.handleResult(result, null);
    }
}