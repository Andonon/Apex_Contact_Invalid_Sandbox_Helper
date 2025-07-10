/*
*********************************************************
Apex Class Name     :   Contact_SandboxEmailInvalidBatch
Created Date        :   7/10/2025
@description        :   Used to update the Contact email address in a sandbox. 
@author             :   Troy Center
Test Class          :   Contact_SandboxEmailInvalidBatch_Test 100% Code Coverage.

  To Run this: Use Developer Console, Execute Anonymous and add these two lines, run. 
    // Default batch size is 200, you can adjust up to 2000
    Contact_SandboxEmailInvalidBatch batch = new Contact_SandboxEmailInvalidBatch();
    Database.executeBatch(batch, 200);

Modification Log:
Ver   Date          Author              Case            Modification
1.0   07/10/2025    Troy Center         00405507        Initial Version. 
*********************************************************
*/
public class Contact_SandboxEmailInvalidBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Only select records with an email to update
        return Database.getQueryLocator(
            'SELECT Id, Email FROM Contact WHERE Email != null'
        );
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        // Confirm Sandbox environment
        if (!Test.isRunningTest() && ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox) {
            System.debug('Not running in a Sandbox. Skipping batch execution.');
            return;
        }

        List<Contact> contactsToUpdate = new List<Contact>();

        for (Contact con : (List<Contact>)scope) {
            String emailLower = con.Email.toLowerCase();
            if (!emailLower.endsWith('.invalid')) {
                String truncatedEmail = con.Email;
                if (truncatedEmail.length() > 72) {
                    truncatedEmail = truncatedEmail.substring(0, 72);
                }
                con.Email = truncatedEmail + '.invalid';
                contactsToUpdate.add(con);
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch job complete.');
    }
}
