/**
 * @File Name         : SEL_Individual_Test.cls
 * @Description       : This class tests the functionality of the SEL_Individual class, including methods for retrieving SObject fields, verifying SObject types, finding participants by ID, and selecting individuals by identity numbers.
* @Author : Raymond Magezi Ssebyala
 * @Author            : Raymond Magezi Ssebyala
 * @Last Modified By  : Raymond Magezi Ssebyala
 * @Last Modified On  : November 19, 2024
 * @Modification Log  :
 * =============================================================================
 * Ver | Date          | Author                     | Modification
 * =============================================================================
 * 1.0 | November 19, 2024 | Raymond Magezi Ssebyala | Initial Version
 **/

 @IsTest
 private class SEL_Individual_Test {
 
     @TestSetup
     static void setupTestData() {
         // Create test Application__c
         Application__c application = new Application__c();
         insert application;
 
         // Create test Application_Participant__c
         Application_Participant__c participant = new Application_Participant__c(
             Application__c = application.Id,
             AOB_Card_Number__c = 'Test Card Number'
         );
         insert participant;
 
         // Create test Individuals
         List<Individual> individuals = new List<Individual>();
         for (Integer i = 0; i < 3; i++) {
             individuals.add(new Individual(
                 FirstName = 'FirstName' + i,
                 LastName = 'LastName' + i,
                 National_Identity_Number__c = 'ID' + i,
                 Application_Participant__c = participant.Id
             ));
         }
         insert individuals;
     }
 
     @IsTest
     static void testGetSObjectType() {
         SEL_Individual selector = new SEL_Individual();
         Test.startTest();
         Schema.SObjectType sObjectType = selector.getSObjectType();
         Test.stopTest();
         Assert.areEqual(Individual.SObjectType, sObjectType, 'The returned SObjectType should be Individual.SObjectType.');
     }
 
     @IsTest
     static void testGetSObjectFieldList() {
         SEL_Individual selector = new SEL_Individual();
         Test.startTest();
         List<Schema.SObjectField> sObjectFieldList = selector.getSObjectFieldList();
         Test.stopTest();
         Assert.isNotNull(sObjectFieldList, 'The field list should not be null.');
         Assert.isTrue(sObjectFieldList.size() > 0, 'The field list should not be empty.');
 
         Map<String, Schema.SObjectField> fieldMap = Individual.SObjectType.getDescribe().fields.getMap();
         for (Schema.SObjectField field : sObjectFieldList) {
             Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' should exist in Individual field map.');
         }
     }
 
     @IsTest
     static void testSelectByApplicationParticipant() {
         Application_Participant__c participant = [SELECT Id FROM Application_Participant__c LIMIT 1];
         SEL_Individual selector = new SEL_Individual();
         Test.startTest();
         List<Individual> individuals = selector.selectByApplicationParticipant(participant.Id);
         Test.stopTest();
         Assert.isNotNull(individuals, 'The Individual list should not be null.');
         Assert.areEqual(3, individuals.size(), 'Expected 3 Individuals associated with the participant.');
     }
 
     @IsTest
     static void testSelectByApplicationParticipantWithInvalidId() {
         SEL_Individual selector = new SEL_Individual();
         Test.startTest();
         List<Individual> individuals = selector.selectByApplicationParticipant(null);
         Test.stopTest();
         Assert.isTrue(individuals.isEmpty(), 'The Individual list should be empty for a null participant ID.');
     }
 
     @IsTest
     static void testSelectByNationalIdentityNumbers() {
         Set<String> identityNumbers = new Set<String>{'ID0', 'ID1'};
         SEL_Individual selector = new SEL_Individual();
         Test.startTest();
         List<Individual> individuals = selector.selectByNationalIdentityNumbers(identityNumbers);
         Test.stopTest();
         Assert.isNotNull(individuals, 'The Individual list should not be null.');
         Assert.areEqual(2, individuals.size(), 'Expected 2 Individuals with the given identity numbers.');
     }
 
     @IsTest
     static void testSelectByNationalIdentityNumbersWithInvalidNumbers() {
         Set<String> identityNumbers = new Set<String>{'InvalidID'};
         SEL_Individual selector = new SEL_Individual();
         Test.startTest();
         List<Individual> individuals = selector.selectByNationalIdentityNumbers(identityNumbers);
         Test.stopTest();
         Assert.isTrue(individuals.isEmpty(), 'The Individual list should be empty for invalid identity numbers.');
     }
 }