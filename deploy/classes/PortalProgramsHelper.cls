public with sharing class PortalProgramsHelper {
    
    @AuraEnabled
    public static List<Program> getPortalPrograms(String hook) {

        if (hook == '') { return null; }

        return [
            SELECT Id,
                Name,
                Program_Description__c,
                Program_Purpose__c,
                Status,
                StartDate,
                EndDate,
                Portal_Hook__c,
                Portal_isActive__c	
            FROM Program
            WHERE Portal_isActive__c = true 
                AND Portal_Hook__c =: hook
            WITH SECURITY_ENFORCED
            ORDER BY Portal_Display_Order__c
        ];  
    }

    @AuraEnabled
    public static Program getPortalProgram(String recordId) {

        if (recordId == '') { return null; }

        return [
            SELECT Id,
                Name,
                // Reference_Application__c,
                Program_Description__c,
                Program_Purpose__c,
                Status,
                StartDate,
                EndDate,
                Portal_Hook__c,
                Portal_isActive__c
            FROM Program
            WHERE Id =: recordId
            // AND Portal_isActive__c = true
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];  
    }

    @AuraEnabled
    public static List<AccountContactRelation> getRelatedAccounts() {

       Id userId = UserInfo.getUserId();

        User user = [
            SELECT Id, 
                ContactId,
                IsPortalEnabled
            FROM User 
            WHERE Id =: userId 
            WITH SECURITY_ENFORCED
        ];

        if (!user.isPortalEnabled) {
            // throw (new AuraHandledException('Error').setMessage('User is not portal enabled'));

            AuraHandledException e = new AuraHandledException('Error');
            e.setMessage('User is not portal enabled');
            throw e;
        }

        return [
            SELECT 
                AccountId, 
                Id, 
                ContactId, 
                IsActive, 
                Account_Name__c, 
                Contact_Name__c 
            FROM AccountContactRelation
            WHERE ContactId =: user.ContactId
            AND IsActive = true
            WITH SECURITY_ENFORCED
        ];
    }

    @AuraEnabled
    public static List<Reference_Application__c> getPortalProgramApplications(String recordId) {

        if (recordId == '') { return null; }

        return [
            SELECT Id,
                Name,
                Display_Name__c,
                Portal_Description__c,
                Application_Open_Date__c,
                Application_End_Date__c
            FROM Reference_Application__c
            WHERE Program__c =: recordId            
            AND Portal_isActive__c = true
            WITH SECURITY_ENFORCED
        ];  
    }

    @AuraEnabled
    public static Application__c createPortalProgramApplication(String recordId, String accountId) {

        if (!Schema.SobjectType.Application__c.iscreateable()) {
            throw new AuraHandledException('User does not have permission to create Application Records');
        }

        try {
            Id userId = UserInfo.getUserId();

            User u = [
                SELECT Id,
                    ContactId
                FROM User
                WHERE Id =: userId
                LIMIT 1
            ];

            Reference_Application__c referenceApplication = [
                SELECT Id,
                Program__c
                FROM Reference_Application__c
                WHERE Id =: recordId
                WITH SECURITY_ENFORCED
            ];

            Application__c application = new Application__c();
                // application.Primary_Contact__c = u.ContactId;
                application.Account__c = accountId;
                application.Status__c = 'New';
                application.Program__c = referenceApplication.Program__c;
                application.Reference_Application__c = referenceApplication.Id;
            insert application;

            return application;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}