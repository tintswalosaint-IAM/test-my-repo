/**
* @class Name        : INS_API_AuthRegistrationHandlerPing_Test
* @description       : Test class for INS_API_AuthRegistrationHandlerPing
* story              : SFP-53279
* @author            : Jaco de Lange
* @date              : 10-10-2025
**/
@IsTest
public with sharing class INS_API_AuthRegistrationHandlerPing_Test {
    private final static String KEY_NETWORK = INS_CTRL_AuthRegistrationHandler.KEY_NETWORK;
    private final static String KEY_NETWORK_ID = 'networkId';
    private final static String KEY_EMAIL = 'email';
    private final static String KEY_CELLPHONE = 'cellphonenumber';
    private final static String KEY_DATE_OF_BIRTH = 'dateofbirth';
    private final static String KEY_FIRST_NAME = 'first_name';
    private final static String KEY_LAST_NAME = 'last_name';
    private final static String KEY_ID = 'id';
    private final static String KEY_DSA_NETWORK_ID = 'DSA';

    @IsTest
    static void extractUserData() {
        // Ping most fields come in user data map
        String identifier = '12345';
        String firstName = 'Walter';
        String lastName = 'White';
        String email = 'ww@gmail.com';
        String network = 'myNetwork';
        String cellphone = '1112223333';
        String dateOfBirth = '17/01/1975';
        Map<String, String> attributes = new Map<String, String>{
                KEY_ID => identifier,
                KEY_FIRST_NAME => firstName,
                KEY_LAST_NAME => lastName,
                KEY_CELLPHONE => cellphone,
                KEY_DATE_OF_BIRTH => dateOfBirth,
                KEY_NETWORK => network
        };

        Auth.UserData userData = new Auth.UserData(null,null,null,null,email,null,
            null,null,null,null,attributes);

        INS_API_AuthRegistrationHandlerPing authRegistrationHandlerPing = new MockRegistrationHandler();

        INS_CTRL_AuthRegistrationHandler.UserDataWrapper userDataWrapper = authRegistrationHandlerPing.extractUserData(
                userData
        );
        Assert.areEqual(true,(identifier ==userDataWrapper.id),'user data wrapper not null');
    }

    @IsTest
    static void findContactForUserFound() {
        INS_API_AuthRegistrationHandlerPing authRegistrationHandler = new MockRegistrationHandler();

        String salesAgentRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Sales_Agent_Contact').getRecordTypeId();

        String firstName = 'Steve';
        String lastName = 'Jones';
        String email = 'steve.jones@gmail.com';
        String pingId = '12345';

        Contact contact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Ping_Id__c = pingId,
                RecordTypeId = salesAgentRecTypeId
        );
        insert contact;

        INS_CTRL_AuthRegistrationHandler.UserDataWrapper userDataWrapper =
                (INS_CTRL_AuthRegistrationHandler.UserDataWrapper) JSON.deserialize(
                    JSON.serialize(new Map<String, Object>{
                        KEY_ID => pingId,
                        KEY_EMAIL => email,
                        KEY_NETWORK_ID => KEY_DSA_NETWORK_ID
        }),
        INS_CTRL_AuthRegistrationHandler.UserDataWrapper.class);

        Contact foundContact = authRegistrationHandler.findContactForUser(null, userDataWrapper);
       
        Contact reFetchedContact = [SELECT FirstName, LastName, Email
                FROM Contact
                WHERE Id = :foundContact.Id
        ];
        Assert.areEqual(true,(reFetchedContact.FirstName ==firstName),'contact not found');
    }

    class MockRegistrationHandler extends INS_API_AuthRegistrationHandlerPing {
        public override INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForCreate(Contact contact, UserDataWrapper userDataWrapper) {
            return null;
        }
        public override INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForUpdate(Contact contact) {
            return null;
        }
    }
    
    @IsTest
    static void findContactForUserFound_PersonContact() {
        INS_API_AuthRegistrationHandlerPing authRegistrationHandler = new MockRegistrationHandler();
    
        String email = 'person@gmail.com';
    
        Account acc = new Account(
            LastName = 'PersonAccount',
            PersonEmail = email,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        insert acc;
    
        INS_CTRL_AuthRegistrationHandler.UserDataWrapper userDataWrapper =
            (INS_CTRL_AuthRegistrationHandler.UserDataWrapper) JSON.deserialize(
                JSON.serialize(new Map<String, Object>{
                    KEY_EMAIL => email,
                    KEY_NETWORK_ID => KEY_DSA_NETWORK_ID
                }),
                INS_CTRL_AuthRegistrationHandler.UserDataWrapper.class
            );
    
        Test.startTest();
        Contact foundContact = authRegistrationHandler.findContactForUser(null, userDataWrapper);
        Test.stopTest();
    
        System.assertNotEquals(null, foundContact);
    }

    @IsTest
    static void findContactForUser_NotFound() {
        INS_API_AuthRegistrationHandlerPing authRegistrationHandler = new MockRegistrationHandler();
    
        INS_CTRL_AuthRegistrationHandler.UserDataWrapper userDataWrapper =
            (INS_CTRL_AuthRegistrationHandler.UserDataWrapper) JSON.deserialize(
                JSON.serialize(new Map<String, Object>{
                    KEY_EMAIL => 'notfound@gmail.com',
                    KEY_NETWORK_ID => KEY_DSA_NETWORK_ID
                }),
                INS_CTRL_AuthRegistrationHandler.UserDataWrapper.class
            );
    
        Test.startTest();
        Contact foundContact = authRegistrationHandler.findContactForUser(null, userDataWrapper);
        Test.stopTest();
    
        System.assertEquals(null, foundContact);
    }

    @IsTest
    static void findContactForUser_QueryException() {
        INS_API_AuthRegistrationHandlerPing authRegistrationHandler = new MockRegistrationHandler();
    
        INS_CTRL_AuthRegistrationHandler.UserDataWrapper userDataWrapper =
            (INS_CTRL_AuthRegistrationHandler.UserDataWrapper) JSON.deserialize(
                JSON.serialize(new Map<String, Object>{
                    KEY_EMAIL => null,
                    KEY_NETWORK_ID => KEY_DSA_NETWORK_ID
                }),
                INS_CTRL_AuthRegistrationHandler.UserDataWrapper.class
            );
    
        Test.startTest();
        Contact result = authRegistrationHandler.findContactForUser(null, userDataWrapper);
        Test.stopTest();
    
        System.assertEquals(null, result);
    }

    @IsTest
    static void findContactForUser_GenericException() {
        INS_API_AuthRegistrationHandlerPing handler = new MockRegistrationHandler();
    
        INS_CTRL_AuthRegistrationHandler.UserDataWrapper userDataWrapper =
            (INS_CTRL_AuthRegistrationHandler.UserDataWrapper) JSON.deserialize(
                JSON.serialize(new Map<String, Object>{
                    KEY_EMAIL => true,
                    KEY_NETWORK_ID => 'DSA'
                }),
                INS_CTRL_AuthRegistrationHandler.UserDataWrapper.class
            );
    
        Test.startTest();
        Contact result = handler.findContactForUser(null, userDataWrapper);
        Test.stopTest();
    
        System.assertEquals(null, result);
    }
}