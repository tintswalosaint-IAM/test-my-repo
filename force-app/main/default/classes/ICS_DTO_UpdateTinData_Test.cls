/**
* @description  Test class for ICS_DTO_UpdateTinData to verify tax information data transfer object functionality
* This class tests the creation, modification, and validation of tax-related information
* including TIN numbers, tax residency status, and country-specific tax data.
* Story: SFP-37310
* @author Ramya Gurram
* @date 15/10/2024
* @last modified on  :16/10/2024
* @last modified by  :  Ramya Gurram
* @Modification Description : Enhanced documentation and test coverage
*/
@IsTest
private class ICS_DTO_UpdateTinData_Test {
    // Static variables for consistent test data across methods
    private static final String TEST_BP_ID = 'BP123456';
    private static final String TEST_CONTACT_ID = 'CON789012';
    private static ICS_DTO_UpdateTinData testDto;
    
    /**
     * @description TestSetup method to initialize common test data
     * Creates a base DTO instance with standard tax information that can be used
     * across different test methods. This ensures consistency in test data and
     * reduces code duplication.
     */
    @TestSetup
    static void setupTestData() {
        testDto = new ICS_DTO_UpdateTinData();
        testDto.bpId = TEST_BP_ID;
        testDto.contactId = TEST_CONTACT_ID;
        testDto.taxInfo = new List<ICS_DTO_UpdateTinData.TaxInfo>();

        // Initialize standard tax information record
        ICS_DTO_UpdateTinData.TaxInfo taxInfo = new ICS_DTO_UpdateTinData.TaxInfo();
        taxInfo.mainTaxResidency = 'Yes';
        taxInfo.country = 'United States';
        taxInfo.tinNumber = '123-45-6789';
        taxInfo.taxExemptReason = 'Not Applicable';
        
        testDto.taxInfo.add(taxInfo);
    }

    /**
     * @description Tests the basic creation and validation of a DTO instance
     * Verifies that:
     * - DTO properties are correctly set and retrieved
     * - Tax information is properly stored and accessible
     * - All fields maintain their expected values
     * This test ensures the fundamental functionality of the DTO class
     */
    @IsTest
    static void testCreateDTOInstance() {
        // Arrange - Create new DTO instance with test data
        ICS_DTO_UpdateTinData dto = new ICS_DTO_UpdateTinData();
        dto.bpId = TEST_BP_ID;
        dto.contactId = TEST_CONTACT_ID;
        dto.taxInfo = new List<ICS_DTO_UpdateTinData.TaxInfo>();

        // Create and populate tax information
        ICS_DTO_UpdateTinData.TaxInfo taxInfo = new ICS_DTO_UpdateTinData.TaxInfo();
        taxInfo.mainTaxResidency = 'Yes';
        taxInfo.country = 'United States';
        taxInfo.tinNumber = '123-45-6789';
        taxInfo.taxExemptReason = 'Not Applicable';

        dto.taxInfo.add(taxInfo);

        // Assert - Verify all properties maintain expected values
        Assert.areEqual(TEST_BP_ID, dto.bpId, 'bpId should match the set value');
        Assert.areEqual(TEST_CONTACT_ID, dto.contactId, 'contactId should match the set value');
        Assert.areEqual(1, dto.taxInfo.size(), 'taxInfo list should contain one element');

        ICS_DTO_UpdateTinData.TaxInfo resultTaxInfo = dto.taxInfo[0];
        Assert.areEqual('Yes', resultTaxInfo.mainTaxResidency, 'mainTaxResidency should match the set value');
        Assert.areEqual('United States', resultTaxInfo.country, 'country should match the set value');
        Assert.areEqual('123-45-6789', resultTaxInfo.tinNumber, 'tinNumber should match the set value');
        Assert.areEqual('Not Applicable', resultTaxInfo.taxExemptReason, 'taxExemptReason should match the set value');
    }
    
    /**
     * @description Tests the ability to handle multiple tax information entries
     * Verifies that:
     * - Multiple tax info records can be added to single DTO
     * - Each tax info record maintains distinct values
     * - The system correctly handles primary vs secondary tax residencies
     * - List operations work as expected with multiple entries
     */
    @IsTest
    static void testMultipleTaxInfoEntries() {
        // Arrange - Initialize DTO with multiple tax entries
        ICS_DTO_UpdateTinData dto = new ICS_DTO_UpdateTinData();
        dto.bpId = 'BP987654';
        dto.contactId = 'CON321098';
        dto.taxInfo = new List<ICS_DTO_UpdateTinData.TaxInfo>();

        // Act - Create multiple tax info records for different countries
        List<String> countries = new List<String>{'United States', 'Canada', 'United Kingdom'};
        for (Integer i = 0; i < 3; i++) {
            ICS_DTO_UpdateTinData.TaxInfo taxInfo = new ICS_DTO_UpdateTinData.TaxInfo();
            taxInfo.mainTaxResidency = (i == 0) ? 'Yes' : 'No';
            taxInfo.country = countries[i];
            taxInfo.tinNumber = 'TIN' + (i + 1);
            taxInfo.taxExemptReason = 'Reason' + (i + 1);
            dto.taxInfo.add(taxInfo);
        }

        // Assert - Verify multiple entries are handled correctly
        Assert.areEqual(3, dto.taxInfo.size(), 'taxInfo list should contain three elements');
        Assert.areEqual('Yes', dto.taxInfo[0].mainTaxResidency, 'First entry should have mainTaxResidency as Yes');
        Assert.areEqual('No', dto.taxInfo[1].mainTaxResidency, 'Second entry should have mainTaxResidency as No');
        Assert.areEqual('United Kingdom', dto.taxInfo[2].country, 'Third entry should have correct country value');
        Assert.areEqual('TIN3', dto.taxInfo[2].tinNumber, 'Third entry should have correct TIN value');
    }

    /**
     * @description Tests the default state and null handling of the DTO
     * Verifies that:
     * - New DTO instances have expected null values
     * - System properly handles null values without errors
     * - Default state meets requirements for further processing
     */
    @IsTest
    static void testNullValues() {
        // Arrange & Act - Create new DTO without setting any values
        ICS_DTO_UpdateTinData dto = new ICS_DTO_UpdateTinData();

        // Assert - Verify proper handling of null values
        Assert.areEqual(null, dto.bpId, 'bpId should be null by default');
        Assert.areEqual(null, dto.contactId, 'contactId should be null by default');
        Assert.areEqual(null, dto.taxInfo, 'taxInfo should be null by default');
    }
    
    /**
     * @description Tests the ability to modify existing tax information
     * Verifies that:
     * - Tax information can be updated after initial creation
     * - Changes to specific fields don't affect other fields
     * - Updates are properly persisted in the DTO
     * - System maintains data integrity during modifications
     */
    @IsTest
    static void testTaxInfoModification() {
        // Arrange - Create DTO with initial tax information
        ICS_DTO_UpdateTinData dto = new ICS_DTO_UpdateTinData();
        dto.taxInfo = new List<ICS_DTO_UpdateTinData.TaxInfo>();

        ICS_DTO_UpdateTinData.TaxInfo taxInfo = new ICS_DTO_UpdateTinData.TaxInfo();
        taxInfo.mainTaxResidency = 'Yes';
        taxInfo.country = 'France';
        taxInfo.tinNumber = 'FR123456';
        taxInfo.taxExemptReason = 'None';

        dto.taxInfo.add(taxInfo);

        // Act - Modify specific fields in the tax information
        dto.taxInfo[0].country = 'Germany';
        dto.taxInfo[0].tinNumber = 'DE789012';

        // Assert - Verify modifications while ensuring other fields remain unchanged
        Assert.areEqual('Germany', dto.taxInfo[0].country, 'Country should be updated to Germany');
        Assert.areEqual('DE789012', dto.taxInfo[0].tinNumber, 'TIN number should be updated');
        Assert.areEqual('Yes', dto.taxInfo[0].mainTaxResidency, 'mainTaxResidency should remain unchanged');
        Assert.areEqual('None', dto.taxInfo[0].taxExemptReason, 'taxExemptReason should remain unchanged');
    }
}