/**
* @Name of the Class : ICS_DTO_CreateUpdateCustomerForCRA_Test
* @description TestContoller used for SBO UK GBG Feature  - SFP-37310  
* @author IKYATHA NAIDU
* @date 18/05/2024
***********************************************************************
* @last modified on  : 28-03-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : SFP-37310 Test class for the  ICS_DTO_CreateUpdateCustomerForCRA
* 
*/
@IsTest
public class ICS_DTO_CreateUpdateCustomerForCRA_Test { 
    @IsTest 
    static void testICS_DTO_CreateUpdateCustomerForCRA() {
      ICS_DTO_CreateUpdateCustomerForCRA response =  createTestDTO();
       Assert.areEqual(true, response != null, 'Response Received');
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA createTestDTO() {
        ICS_DTO_CreateUpdateCustomerForCRA dto = new ICS_DTO_CreateUpdateCustomerForCRA();
        dto.Address = createAddress();
        dto.ContactDetails = createContactDetails();
        dto.CountryProfileId = 'UK';
        dto.CustomerId = 'CUST12345';
        dto.IdentityDocuments = createIdentityDocuments();
        dto.IsExistingCustomer = true;
        dto.PersonalDetails = createPersonalDetails();
        
       
        dto.CardType = 1;
        return dto;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.Address createAddress() {
        ICS_DTO_CreateUpdateCustomerForCRA.Address address = new ICS_DTO_CreateUpdateCustomerForCRA.Address();
        address.Building = 'Building Name';
        address.City = 'City Name';
        address.SubCity = 'SubCity Name';
        address.Country = 'Country Name';
        address.Street = 'Street Name';
        address.SubStreet = 'SubStreet Name';
        address.ZipPostcode = '12345';
        address.StateDistrict = 'StateDistrict Name';
        address.POBox = 'POBox Name';
        address.Region = 'Region Name';
        address.Principality = 'Principality Name';
        address.DpsZipPlus = 'DpsZipPlus';
        address.CedexMailsort = 'CedexMailsort';
        address.Department = 'Department Name';
        address.Company = 'Company Name';
        address.SubBuilding = 'SubBuilding Name';
        address.Premise = 'Premise Name';
        address.AddressLine1 = 'AddressLine1';
        address.AddressLine2 = 'AddressLine2';
        address.AddressLine3 = 'AddressLine3';
        address.AddressLine4 = 'AddressLine4';
        address.AddressLine5 = 'AddressLine5';
        address.AddressLine6 = 'AddressLine6';
        address.AddressLine7 = 'AddressLine7';
        address.AddressLine8 = 'AddressLine8';
        address.FirstYearOfResidence = 2000;
        address.LastYearOfResidence = 2010;
        address.FirstMonthOfResidence = 1;
        address.LastMonthOfResidence = 12;
        return address;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.ContactDetails createContactDetails() {
        ICS_DTO_CreateUpdateCustomerForCRA.ContactDetails contactDetails = new ICS_DTO_CreateUpdateCustomerForCRA.ContactDetails();
        contactDetails.Email = 'test@example.com';
        contactDetails.LandTelephone = createLandTelephone();
        contactDetails.MobileTelephone = createMobileTelephone();
        contactDetails.WorkTelephone = createMobileTelephone();
        return contactDetails;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.LandTelephone createLandTelephone() {
        ICS_DTO_CreateUpdateCustomerForCRA.LandTelephone landTelephone = new ICS_DTO_CreateUpdateCustomerForCRA.LandTelephone();
        landTelephone.ExDirectory = true;
        landTelephone.Number_Z = '0987654321';
        return landTelephone;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.MobileTelephone createMobileTelephone() {
        ICS_DTO_CreateUpdateCustomerForCRA.MobileTelephone mobileTelephone = new ICS_DTO_CreateUpdateCustomerForCRA.MobileTelephone();
        mobileTelephone.Number_Z = '1234567890';
        return mobileTelephone;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.PersonalDetails createPersonalDetails() {
        ICS_DTO_CreateUpdateCustomerForCRA.PersonalDetails personalDetails = new ICS_DTO_CreateUpdateCustomerForCRA.PersonalDetails();
        personalDetails.DateOfBirth = '1990-01-01';
        personalDetails.Forename = 'John';
        personalDetails.Gender = 1;
         personalDetails.Nationality = 'British';
        return personalDetails;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.IdentityDocuments createIdentityDocuments() {
        ICS_DTO_CreateUpdateCustomerForCRA.IdentityDocuments identityDocuments = new ICS_DTO_CreateUpdateCustomerForCRA.IdentityDocuments();
        identityDocuments.Argentina = createArgentina();
        identityDocuments.Australia = createAustralia();
        identityDocuments.Brazil = createBrazil();
        identityDocuments.Canada = createCanada();
        identityDocuments.China = createChina();
        identityDocuments.EuropeanIdentityCard = createEuropeanIdentityCard();
        identityDocuments.IdentityCard = createIdentityCard();
        identityDocuments.India = createIndia();
        identityDocuments.InternationalPassport = createInternationalPassport();
        identityDocuments.Mexico = createMexico();
        identityDocuments.NewZealand = createNewZealand();
        identityDocuments.Spain = createSpain();
        identityDocuments.UK = createUK();
        identityDocuments.US = createUS();
        return identityDocuments;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.Argentina createArgentina() {
        ICS_DTO_CreateUpdateCustomerForCRA.Argentina argentina = new ICS_DTO_CreateUpdateCustomerForCRA.Argentina();
        argentina.DNINumber = createDNINumber();
        argentina.TaxIdentificationNumber = createMobileTelephone();
        return argentina;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.Australia createAustralia() {
        ICS_DTO_CreateUpdateCustomerForCRA.Australia australia = new ICS_DTO_CreateUpdateCustomerForCRA.Australia();
        australia.DrivingLicence = createDrivingLicence();
        australia.Medicare = createMedicare();
        australia.ShortPassport = createShortPassport();
        return australia;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.Brazil createBrazil() {
        ICS_DTO_CreateUpdateCustomerForCRA.Brazil brazil = new ICS_DTO_CreateUpdateCustomerForCRA.Brazil();
        brazil.CPFNumber = createCPFNumber();
        return brazil;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.Canada createCanada() {
        ICS_DTO_CreateUpdateCustomerForCRA.Canada canada = new ICS_DTO_CreateUpdateCustomerForCRA.Canada();
        canada.SocialInsuranceNumber = createCPFNumber();
        return canada;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.China_Z createChina() {
        ICS_DTO_CreateUpdateCustomerForCRA.China_Z china = new ICS_DTO_CreateUpdateCustomerForCRA.China_Z();
        china.ResidentIdentityCard = createCPFNumber();
        return china;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.EuropeanIdentityCard createEuropeanIdentityCard() {
        ICS_DTO_CreateUpdateCustomerForCRA.EuropeanIdentityCard europeanIdentityCard = new ICS_DTO_CreateUpdateCustomerForCRA.EuropeanIdentityCard();
        europeanIdentityCard.CountryOfIssue = 'CountryOfIssue';
        europeanIdentityCard.CountryOfNationality = 'CountryOfNationality';
        europeanIdentityCard.ExpiryDay = 1;
        europeanIdentityCard.ExpiryMonth = 12;
        europeanIdentityCard.ExpiryYear = 2030;
        europeanIdentityCard.Line1 = 'Line1';
        europeanIdentityCard.Line2 = 'Line2';
        europeanIdentityCard.Line3 = 'Line3';
        return europeanIdentityCard;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.IdentityCard createIdentityCard() {
        ICS_DTO_CreateUpdateCustomerForCRA.IdentityCard identityCard = new ICS_DTO_CreateUpdateCustomerForCRA.IdentityCard();
        identityCard.Country = 'Country';
        identityCard.Number_Z = 'ID123456';
        return identityCard;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.India createIndia() {
        ICS_DTO_CreateUpdateCustomerForCRA.India india = new ICS_DTO_CreateUpdateCustomerForCRA.India();
        india.DrivingLicence = createCPFNumber();
        india.Epic = createCPFNumber();
        india.PAN = createCPFNumber();
        return india;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.InternationalPassport createInternationalPassport() {
        ICS_DTO_CreateUpdateCustomerForCRA.InternationalPassport internationalPassport = new ICS_DTO_CreateUpdateCustomerForCRA.InternationalPassport();
        internationalPassport.CountryOfOrigin = 'CountryOfOrigin';
        internationalPassport.ExpiryDay = 1;
        internationalPassport.ExpiryMonth = 12; 
        internationalPassport.ExpiryYear = 2030;
        internationalPassport.IssueDay = 1;
        internationalPassport.IssueMonth = 1;
        internationalPassport.IssueYear = 2010;
        internationalPassport.Number_Z = 'INTL123456';
        internationalPassport.ShortPassportNumber = 'ShortPassportNumber';
        return internationalPassport;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.Mexico createMexico() {
        ICS_DTO_CreateUpdateCustomerForCRA.Mexico mexico = new ICS_DTO_CreateUpdateCustomerForCRA.Mexico();
        mexico.IdentityCard = createCPFNumber();
        return mexico;
}

    private static ICS_DTO_CreateUpdateCustomerForCRA.NewZealand createNewZealand() {
    
        ICS_DTO_CreateUpdateCustomerForCRA.NewZealand newZealand =
            new ICS_DTO_CreateUpdateCustomerForCRA.NewZealand();
    
        newZealand.DrivingLicence = createNZDrivingLicence(); 
    
        return newZealand;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.Spain createSpain() {
        ICS_DTO_CreateUpdateCustomerForCRA.Spain spain = new ICS_DTO_CreateUpdateCustomerForCRA.Spain();
        spain.TaxIDNumber = createCPFNumber();
        return spain;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.UK createUK() {
        ICS_DTO_CreateUpdateCustomerForCRA.UK uk = new ICS_DTO_CreateUpdateCustomerForCRA.UK();
        uk.DrivingLicence = createDrivingLicence();
        uk.NationalInsuranceNumber = createCPFNumber();
        uk.Passport = createPassport();
        return uk;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.US createUS() {
        ICS_DTO_CreateUpdateCustomerForCRA.US us = new ICS_DTO_CreateUpdateCustomerForCRA.US();
        us.DrivingLicense = createDrivingLicence();
        us.SocialSecurity = createCPFNumber();
        return us;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.DNINumber createDNINumber() {
        ICS_DTO_CreateUpdateCustomerForCRA.DNINumber dniNumber = new ICS_DTO_CreateUpdateCustomerForCRA.DNINumber();
        dniNumber.Number_Z = 123456789;
        return dniNumber;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.DrivingLicence createDrivingLicence() {
        ICS_DTO_CreateUpdateCustomerForCRA.DrivingLicence drivingLicence = new ICS_DTO_CreateUpdateCustomerForCRA.DrivingLicence();
        drivingLicence.Number_Z = 'DL123456';
        drivingLicence.State = 'State Name';
        drivingLicence.ExpiryDay = 1;
        drivingLicence.ExpiryMonth = 12;
        drivingLicence.ExpiryYear = 2030;
        drivingLicence.IssueDay = 1;
        drivingLicence.IssueMonth = 1;
        drivingLicence.IssueNumber = 1;
        drivingLicence.IssueYear = 2010;
        drivingLicence.MailSort = 'MailSort';
        drivingLicence.Microfiche = 'Microfiche';
        drivingLicence.Postcode = '12345';
        drivingLicence.VehicleRegistration = 'VehicleRegistration';
        drivingLicence.Version = 'Version';
        drivingLicence.CardNumber = 'CardNumber';
        return drivingLicence;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.Passport createPassport() {
        ICS_DTO_CreateUpdateCustomerForCRA.Passport passport = new ICS_DTO_CreateUpdateCustomerForCRA.Passport();
        passport.Number_Z = 'P123456';
        passport.ExpiryDay = 1;
        passport.ExpiryMonth = 12;
        passport.ExpiryYear = 2030;
        return passport;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber createCPFNumber() {
        ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber cpfNumber = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
        cpfNumber.Number_Z = 'CPF123456';
        return cpfNumber;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.Medicare createMedicare() {
        ICS_DTO_CreateUpdateCustomerForCRA.Medicare medicare = new ICS_DTO_CreateUpdateCustomerForCRA.Medicare();
        medicare.CardColour = 'Green';
        medicare.CardNumber = 'Med123456';
        medicare.ExpiryDay = 1;
        medicare.ExpiryMonth = 12;
        medicare.ExpiryYear = 2030;
        medicare.MiddleNameOnCard = 'MiddleName';
        medicare.ReferenceNumber = 'Ref123';
        medicare.SurnameAtCitizenship = 'Surname';
        return medicare;
    }
    private static ICS_DTO_CreateUpdateCustomerForCRA.NZDrivingLicence createNZDrivingLicence() {

        ICS_DTO_CreateUpdateCustomerForCRA.NZDrivingLicence licence =
            new ICS_DTO_CreateUpdateCustomerForCRA.NZDrivingLicence();
    
        licence.Number_Z = 'NZ123456';
        licence.VehicleRegistration = 'NZREG123';
        licence.Version = '01';
    
        return licence;
    }

    private static ICS_DTO_CreateUpdateCustomerForCRA.ShortPassport createShortPassport() {
        ICS_DTO_CreateUpdateCustomerForCRA.ShortPassport shortPassport = new ICS_DTO_CreateUpdateCustomerForCRA.ShortPassport();
        shortPassport.CountryOfOrigin = 'Australia';
        shortPassport.Number_Z = 'SP123456';
        return shortPassport;
    }

  
}