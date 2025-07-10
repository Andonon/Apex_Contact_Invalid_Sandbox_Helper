/*
*********************************************************
Apex Class Name     :   Contact_SandboxEmailInvalidBatch
Created Date        :   7/10/2025
@description        :   Test Class for Contact_SandboxEmailInvalidBatch with 94% code coverage (1 line is not tested).
@author             :   Troy Center
Modification Log:
Ver   Date          Author              Case            Modification
1.0   07/10/2025    Troy Center         00405507        Initial Version. 
*********************************************************
*/
@isTest
private class Contact_SandboxEmailInvalidBatch_Test {
    @isTest static void testBatchEmailUpdate() {
        List<Contact> testContacts = new List<Contact>{
            new Contact(FirstName='Test', LastName='One', Email='user1@test.com'),
            new Contact(FirstName='Test', LastName='Two', Email='user2@test.com')
        };
        insert testContacts;

        Test.startTest();
        Database.executeBatch(new Contact_SandboxEmailInvalidBatch(), 200);
        Test.stopTest();

        for (Contact c : [SELECT Email FROM Contact WHERE Id IN :testContacts]) {
            System.assert(c.Email.endsWith('.invalid'), 'Email should end with .invalid');
        }
    }

    @isTest static void testBatchWithTruncation() {
        // Email with 80 characters
        String longEmail = 'averylongemailaddress12345678901234567890787891012345678901234567890@example.com';

        List<Contact> testContacts = new List<Contact>{
            new Contact(FirstName='Test', LastName='One', Email=longEmail),
            new Contact(FirstName='Test', LastName='Two', Email='short@example.com')
        };
        insert testContacts;

        Test.startTest();
        Database.executeBatch(new Contact_SandboxEmailInvalidBatch(), 200);
        Test.stopTest();

        List<Contact> updated = [SELECT Email FROM Contact WHERE Id IN :testContacts];
        for (Contact c : updated) {
            System.assert(c.Email.endsWith('.invalid'), 'Email should end with .invalid');
            System.assert(c.Email.length() <= 80, 'Email should not exceed 80 characters');
        }
    }
}
