/***************************************************************************************
@Name of the Class :KYC_DTO_Address_Test
@Description :SFP-40755 Test Class for KYC_DTO_Address.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public class KYC_DTO_Address_Test {
   /**
    * @description test method for KYC_DTO_Address Constructor
    */
    @IsTest
    static void constructorTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        Test.stopTest();
        Assert.areEqual(System.today(), address.endDate, 'endDate should be initialized to today\'s date');
        Assert.isNull(address.type, 'type should be null');
        Assert.isNull(address.startDate, 'startDate should be null');
        Assert.isNull(address.street, 'street should be null');
        Assert.isNull(address.city, 'city should be null');
        Assert.isNull(address.stateCode, 'stateCode should be null');
        Assert.isNull(address.countryCode, 'countryCode should be null');
        Assert.isNull(address.postalCode, 'postalCode should be null');
    }
    
    /**
    * @description test method for KYC_DTO_Address.TypeProperty
    */
    @IsTest
    static void  TypePropertyTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        address.type = 'Residential';
        Test.stopTest();
        Assert.areEqual('Residential', address.type, 'type should be set to Residential');
    }
    
   /**
    * @description test method for KYC_DTO_Address.PrimaryAddressProperty
    */
    @IsTest
    static void  PrimaryAddressPropertyTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        address.primaryAddress = true;
        Test.stopTest();
        Assert.areEqual(true, address.primaryAddress, 'primaryAddress should be set to true');
    }
   /**
    * @description test method for KYC_DTO_Address.StartDateProperty
    */
    @IsTest
    static void StartDatePropertyTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        Date testDate = Date.newInstance(2024, 4, 24);
        address.startDate = testDate;
        Test.stopTest();
        Assert.areEqual(testDate, address.startDate, 'startDate should be set to 2024-04-24');
    }
    
   /**
    * @description test method for KYC_DTO_Address.StreetProperty
    */
    @IsTest
    static void StreetPropertyTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        address.street = '123 Test St';
        Test.stopTest();
        Assert.areEqual('123 Test St', address.street, 'street should be set to 123 Test St');
    }
    /**
    * @description test method for KYC_DTO_Address.CityProperty
    */
    @IsTest
    static void CityPropertyTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        address.city = 'Test City';
        Test.stopTest();
        Assert.areEqual('Test City', address.city, 'city should be set to Test City');
    }
   /**
    * @description test method for KYC_DTO_Address.stateCodeProperty
    */
    @IsTest
    static void testStateCodeProperty() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        address.stateCode = 'CA';
        Test.stopTest();
        Assert.areEqual('CA', address.stateCode, 'stateCode should be set to CA');
    }
    /**
    * @description test method for KYC_DTO_Address.CountryCodeProperty
    */
    @IsTest
    static void CountryCodePropertyTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        address.countryCode = 'US';
        Test.stopTest();
        Assert.areEqual('US', address.countryCode, 'countryCode should be set to US');
    }
    /**
    * @description test method for KYC_DTO_Address.PostalCodeProperty
    */
    @IsTest
    static void PostalCodePropertyTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        address.postalCode = '12345';
        Test.stopTest();
        Assert.areEqual('12345', address.postalCode, 'postalCode should be set to 12345');
    }
    /**
    * @description test method for KYC_DTO_Address.LatitudeProperty
    */
    @IsTest
    static void LatitudePropertyTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        address.latitude = 37.7749;
        Test.stopTest();
        Assert.areEqual(37.7749, address.latitude, 'latitude should be set to 37.7749');
    }
    /**
    * @description test method for KYC_DTO_Address.LongitudeProperty
    */
    @IsTest
    static void LongitudePropertyTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        address.longitude = -122.4194;
        Test.stopTest();
        Assert.areEqual(-122.4194, address.longitude, 'longitude should be set to -122.4194');
    }
   /**
    * @description test method for KYC_DTO_Address.GeoCodeProperty
    */
    @IsTest
    static void GeoCodePropertyTest() {
        Test.startTest();
        KYC_DTO_Address address = new KYC_DTO_Address();
        address.geoCode = 'ABC123';
        Test.stopTest();
        Assert.areEqual('ABC123', address.geoCode, 'geoCode should be set to ABC123');
    }
}