/**
 * @Name of the Class : ICS_ContactForm_Controller.cls
 * @description: class used as test class for  ICS_ContactForm_Controller
 * @Author Ikyatha Naidu 
 * @Date 01/06/2024 
 * @Last Modified On  : 25/08/2024 
 * @Last Modified By  : Ikyatha Naidu
 * @Modification Description : Initial Version
 */
@isTest
private class ICS_ContactForm_Controller_Test {
    
      @isTest static void testInitializeAddressFields() {
        // Create an instance of the controller
        ICS_ContactForm_Controller controller = new ICS_ContactForm_Controller();

        // Assert that the addressFields list is initialized with the correct values
        Assert.areEqual(7, controller.addressFields.size(), 'Address fields list should contain 7 items');
        Assert.areEqual('Apartment No., Building Name etc.', controller.addressFields[0].label, 'First address field label should be "Apartment No., Building Name etc."');
        // Add more assertions for other address fields as needed
    }

    @isTest static void testAddressField() {
        // Test the AddressField inner class
        ICS_ContactForm_Controller.AddressField address = 
            new ICS_ContactForm_Controller.AddressField('Test Label', 'Test Value');

       Assert.areEqual('Test Label', address.label, 'AddressField label should be "Test Label"');
        Assert.areEqual('Test Value', address.value, 'AddressField value should be "Test Value"');
    }

    @isTest static void testControllerProperties() {
        // Create an instance of the controller
        ICS_ContactForm_Controller controller = new ICS_ContactForm_Controller();

        // Set values for the controller properties
        controller.componentEmail = 'test@example.com';
        controller.componentAlterPhone = '1234567890';
        controller.componentPhone = '9876543210';
         controller.componentDate = '2024-06-01';
    controller.componentTime = '14:30';
    controller.componentPrevApartmentNo = 'Apt 456';
    controller.componentPrevStreetAddress = '789 Oak Avenue';
    controller.componentPrevSecondStreetAddress = 'Suite 101';
    controller.componentPrevTown = 'Springfield';
    controller.componentPrevCountry = 'United States';
    controller.componentPrevState = 'Illinois';
    controller.componentPrevPostCode = '62701';
    controller.componentPrevDate = '2023-06-01';
    controller.componentPrevTime = '09:45';
    controller.componentCorresAddrSameResidentialAddr = 'No';
    controller.componentCorresApartmentNo = 'Unit 789';
    controller.componentCorresStreetAddress = '321 Pine Street';
    controller.componentCorresSecondStreetAddress = 'Floor 3';
    controller.componentCorresTown = 'Metropolis';
    controller.componentCorresCountry = 'Canada';
    controller.componentCorresState = 'Ontario';
    controller.componentCorresPostCode = 'M5V 2T6';
    controller.componentCorresReltnShipCorresAddr = 'Business';
        // ... set other properties ...

        // Assert that the properties are set correctly
       Assert.areEqual('test@example.com', controller.componentEmail, 'Email should be "test@example.com"');
        Assert.areEqual('1234567890', controller.componentAlterPhone, 'Alternative phone should be "1234567890"');
        Assert.areEqual('9876543210', controller.componentPhone, 'Phone should be "9876543210"');
        Assert.areEqual('2024-06-01', controller.componentDate, 'Date should be "2024-06-01"');
        Assert.areEqual('14:30', controller.componentTime, 'Time should be "14:30"');
        Assert.areEqual('Apt 456', controller.componentPrevApartmentNo, 'Previous apartment number should be "Apt 456"');
        Assert.areEqual('789 Oak Avenue', controller.componentPrevStreetAddress, 'Previous street address should be "789 Oak Avenue"');
        Assert.areEqual('Suite 101', controller.componentPrevSecondStreetAddress, 'Previous second street address should be "Suite 101"');
        Assert.areEqual('Springfield', controller.componentPrevTown, 'Previous town should be "Springfield"');
        Assert.areEqual('United States', controller.componentPrevCountry, 'Previous country should be "United States"');
        Assert.areEqual('Illinois', controller.componentPrevState, 'Previous state should be "Illinois"');
        Assert.areEqual('62701', controller.componentPrevPostCode, 'Previous post code should be "62701"');
        Assert.areEqual('2023-06-01', controller.componentPrevDate, 'Previous date should be "2023-06-01"');
        Assert.areEqual('09:45', controller.componentPrevTime, 'Previous time should be "09:45"');
        Assert.areEqual('No', controller.componentCorresAddrSameResidentialAddr, 'Correspondence address same as residential should be "No"');
        Assert.areEqual('Unit 789', controller.componentCorresApartmentNo, 'Correspondence apartment number should be "Unit 789"');
        Assert.areEqual('321 Pine Street', controller.componentCorresStreetAddress, 'Correspondence street address should be "321 Pine Street"');
        Assert.areEqual('Floor 3', controller.componentCorresSecondStreetAddress, 'Correspondence second street address should be "Floor 3"');
        Assert.areEqual('Metropolis', controller.componentCorresTown, 'Correspondence town should be "Metropolis"');
        Assert.areEqual('Canada', controller.componentCorresCountry, 'Correspondence country should be "Canada"');
        Assert.areEqual('Ontario', controller.componentCorresState, 'Correspondence state should be "Ontario"');
        Assert.areEqual('M5V 2T6', controller.componentCorresPostCode, 'Correspondence post code should be "M5V 2T6"');
        Assert.areEqual('Business', controller.componentCorresReltnShipCorresAddr, 'Correspondence relationship should be "Business"');
        // ... add assertions for other properties ...
    }
}