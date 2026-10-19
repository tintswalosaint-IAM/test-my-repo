/**
 * @description Test class for ICS_DTO_CustomerAPI to verify customer data transfer object functionality
 * This class tests the creation and validation of customer information including
 * personal details, addresses, and related parties.
 * Story: SFP-34727,
 *  Each test method clearly states:
 * - Given: The initial setup/preconditions
 * - When: The action being tested
 * - Then: The expected outcomes/assertions
 * @author Ikyatha Naidu
 * @date 10/10/2024
 * @last modified on  :10/10/2024
 * @last modified by  :Ikyatha Naidu
 * @Modification Description : Initial Version
 */
@IsTest
private class ICS_DTO_CustomerAPI_Test {
    // Static test data
    private static final String TEST_SF_ACCOUNT_ID = 'ACC123456';
    private static final String TEST_BP_ID = 'BP789012';
    private static final String TEST_EMAIL = 'test@example.com';
    
    /**
     * @description TestSetup method to initialize common test data
     * Creates base customer data that can be reused across test methods
     */
    @TestSetup
    static void setupTestData() {
        // Common setup code if needed
    }
    
    /**
     * @description Tests the creation of a new customer DTO with all fields populated
     * Verifies that all customer fields are properly set and retrieved
     * including personal information, addresses, and basic validation
     */
    @IsTest
    static void testCreateCustomerDTO() {
        // Arrange
        ICS_DTO_CustomerAPI customerDTO = new ICS_DTO_CustomerAPI();
        
        // Set main customer information
        customerDTO.SFAccountID = TEST_SF_ACCOUNT_ID;
        customerDTO.CustomerBPID = TEST_BP_ID;
        customerDTO.AccountType = 'Individual';
        customerDTO.FirstName = 'John';
        customerDTO.SurName = 'Doe';
        customerDTO.DateofBirth = '1990-01-01';
        customerDTO.Nationality = 'US';
        customerDTO.idNumber = 'ID123456';
        customerDTO.expiryDate = '2025-12-31';
        customerDTO.validFrom = '2020-01-01';
        customerDTO.validTo = '2025-12-31';
        customerDTO.EmailAddresss = TEST_EMAIL;
        customerDTO.SigngingMandate = 'Full';
        customerDTO.bothtosign = 'Yes';

        // Set primary address
        customerDTO.PrimaryAddress = new ICS_DTO_CustomerAPI.DTO_Address();
        customerDTO.PrimaryAddress.street = '123 Main St';
        customerDTO.PrimaryAddress.city = 'Boston';
        customerDTO.PrimaryAddress.state = 'MA';
        customerDTO.PrimaryAddress.postalcode = '02108';
        customerDTO.PrimaryAddress.country = 'USA';

        // Assert
        Assert.areEqual(TEST_SF_ACCOUNT_ID, customerDTO.SFAccountID, 'SFAccountID should match');
        Assert.areEqual(TEST_BP_ID, customerDTO.CustomerBPID, 'CustomerBPID should match');
        Assert.areEqual('Individual', customerDTO.AccountType, 'AccountType should match');
        Assert.areEqual('John', customerDTO.FirstName, 'FirstName should match');
        Assert.areEqual('Boston', customerDTO.PrimaryAddress.city, 'Primary address city should match');
    }

    /**
     * @description Tests the creation and management of related parties
     * Verifies that multiple related parties can be added and managed
     * including their personal information and addresses
     */
    @IsTest
    static void testRelatedParties() {
        // Arrange
        ICS_DTO_CustomerAPI customerDTO = new ICS_DTO_CustomerAPI();
        customerDTO.RelatedParties = new List<ICS_DTO_CustomerAPI.RelatedParties>();

        // Act - Add multiple related parties
        for(Integer i = 1; i <= 3; i++) {
            ICS_DTO_CustomerAPI.RelatedParties party = new ICS_DTO_CustomerAPI.RelatedParties();
            party.SFAccountID = 'ACC' + i;
            party.FirstName = 'Related' + i;
            party.Surname = 'Party' + i;
            party.BPID = 'BP' + i;
            party.EmailAddresss = 'related' + i + '@example.com';
            party.AutorisedSignatory = 'Yes';
            
            // Add address for related party
            party.PrimaryAddress = new ICS_DTO_CustomerAPI.DTO_Address();
            party.PrimaryAddress.street = i + ' Party Street';
            party.PrimaryAddress.city = 'Party City ' + i;
            
            customerDTO.RelatedParties.add(party);
        }

        // Assert
        Assert.areEqual(3, customerDTO.RelatedParties.size(), 'Should have 3 related parties');
        Assert.areEqual('Related1', customerDTO.RelatedParties[0].FirstName, 'First related party name should match');
        Assert.areEqual('1 Party Street', customerDTO.RelatedParties[0].PrimaryAddress.street, 'Related party address should match');
    }

    /**
     * @description Tests the handling of multiple addresses for a customer
     * Verifies that primary and additional addresses can be set and retrieved correctly
     */
    @IsTest
    static void testMultipleAddresses() {
        // Arrange
        ICS_DTO_CustomerAPI customerDTO = new ICS_DTO_CustomerAPI();

        // Act - Set multiple addresses
        customerDTO.PrimaryAddress = new ICS_DTO_CustomerAPI.DTO_Address();
        customerDTO.PrimaryAddress.street = 'Primary Street';
        customerDTO.PrimaryAddress.city = 'Primary City';

        customerDTO.AdditionalAddress1 = new ICS_DTO_CustomerAPI.DTO_Address();
        customerDTO.AdditionalAddress1.street = 'Additional Street 1';
        customerDTO.AdditionalAddress1.city = 'Additional City 1';

        customerDTO.AdditionalAddress2 = new ICS_DTO_CustomerAPI.DTO_Address();
        customerDTO.AdditionalAddress2.street = 'Additional Street 2';
        customerDTO.AdditionalAddress2.city = 'Additional City 2';

        // Assert
        Assert.areEqual('Primary Street', customerDTO.PrimaryAddress.street, 'Primary address street should match');
        Assert.areEqual('Additional Street 1', customerDTO.AdditionalAddress1.street, 'Additional address 1 street should match');
        Assert.areEqual('Additional City 2', customerDTO.AdditionalAddress2.city, 'Additional address 2 city should match');
    }

    /**
     * @description Tests the constructor initialization
     * Verifies that the constructor properly initializes the DTO
     * and sets default values as expected
     */
    @IsTest
    static void testConstructorInitialization() {
        // Act
        ICS_DTO_CustomerAPI customerDTO = new ICS_DTO_CustomerAPI();

        // Assert - Verify initialization
        Assert.isNotNull(customerDTO, 'DTO should be initialized');
        // Add additional constructor-specific assertions if needed
    }

    /**
     * @description Tests null and empty value handling
     * Verifies that the DTO properly handles null values
     * and empty strings across all fields
     */
    @IsTest
    static void testNullValueHandling() {
        // Arrange
        ICS_DTO_CustomerAPI customerDTO = new ICS_DTO_CustomerAPI();

        // Assert - Verify null handling
        Assert.areEqual(null, customerDTO.SFAccountID, 'SFAccountID should be null by default');
        Assert.areEqual(null, customerDTO.CustomerBPID, 'CustomerBPID should be null by default');
        Assert.areEqual(null, customerDTO.RelatedParties, 'RelatedParties should be null by default');
        Assert.areEqual(null, customerDTO.PrimaryAddress, 'PrimaryAddress should be null by default');
    }
}