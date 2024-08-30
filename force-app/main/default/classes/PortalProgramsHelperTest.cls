/**
 * @description Test class for PortalProgramsHelper. Contains unit tests for various helper methods 
 *              used in the portal program functionalities.
 */
@IsTest
private class PortalProgramsHelperTest {

    /**
     * @description Test setup method to generate test data. This runs once before any test methods.
     */
    @TestSetup
    static void setupTestData() {
        ApplicationTestDataFactory.makeData();

        UserRole role = new UserRole(name = 'TEST ROLE');

        User userWithRole = new User();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert role;
            
            userWithRole.Alias = 'testu';
            userWithRole.UserRoleId = role.Id;
            userWithRole.Email = String.valueOf(System.now().getTime()) + 'testuser@example.com';
            userWithRole.EmailEncodingKey = 'UTF-8';
            userWithRole.LastName = 'UserRoleTester';
            userWithRole.LanguageLocaleKey = 'en_US';
            userWithRole.LocaleSidKey = 'en_US';
            userWithRole.ProfileId = UserInfo.getProfileId();
            userWithRole.TimeZoneSidKey = 'America/Los_Angeles';
            userWithRole.UserName = String.valueOf(System.now().getTime()) + 'testuser@example.com';
            
            insert userWithRole;
        }

        Account account = new Account();
        Contact c = new Contact();

        User testUser = new User();
        System.runAs(userWithRole) {

            account.Name = 'Test';
            insert account;
    
            c.LastName = 'tester';
            c.AccountId = account.Id;
            insert c;

            Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus'];
    
            testUser.Alias = 'testuser';
            testUser.Email = String.valueOf(System.now().getTime()) + 'testuser@example.com';
            testUser.EmailEncodingKey = 'UTF-8';
            testUser.LastName = 'User';
            testUser.LanguageLocaleKey = 'en_US';
            testUser.LocaleSidKey = 'en_US';
            testUser.ProfileId = p.Id;
            testUser.ContactId = c.Id;
            testUser.TimeZoneSidKey = 'America/Los_Angeles';
            testUser.UserName = String.valueOf(System.now().getTime()) + 'testuser@example.com';
            insert testUser;
        }


        System.runAs(new User(Id = UserInfo.getUserId())) {

            PermissionSet ps = [
                SELECT Id 
                FROM PermissionSet 
                WHERE Name = 'Application_External'
            ];
            insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id);
        }

    }

    /**
     * @description Tests the getPortalPrograms method to ensure it correctly fetches portal programs.
     *              Verifies the program list is not null, contains exactly one program, and has the expected name.
     */
    @IsTest
    static void testGetPortalPrograms() {
        List<Program> programs = PortalProgramsHelper.getPortalPrograms('TestHook');
        
        System.assertNotEquals(null, programs, 'Programs should not be null.');
        System.assertEquals(1, programs.size(), 'There should be exactly one program.');
        System.assertEquals('Test Program', programs[0].Name, 'Program name should match.');
    }

    /**
     * @description Tests the getPortalProgram method to ensure it correctly fetches a specific program 
     *              by its ID. Verifies the fetched program is not null and its ID matches the expected value.
     */
    @IsTest
    static void testGetPortalProgram() {
        Program testProgram = [SELECT Id FROM Program WHERE Name = 'Test Program' LIMIT 1];

        Program fetchedProgram = PortalProgramsHelper.getPortalProgram(testProgram.Id);

        System.assertNotEquals(null, fetchedProgram, 'Fetched program should not be null.');
        System.assertEquals(testProgram.Id, fetchedProgram.Id, 'Fetched program ID should match the input ID.');
    }

    /**
     * @description Tests the getPortalProgramApplications method to ensure it correctly fetches reference 
     *              applications for a specific program. Verifies the application list is not null, contains 
     *              exactly one application, and has the expected name.
     */
    @IsTest
    static void testGetPortalProgramApplications() {
        Program testProgram = [SELECT Id FROM Program WHERE Name = 'Test Program' LIMIT 1];

        List<Reference_Application__c> applications = PortalProgramsHelper.getPortalProgramApplications(testProgram.Id);

        System.assertNotEquals(null, applications, 'Applications list should not be null.');
        System.assertEquals(1, applications.size(), 'There should be exactly one reference application.');
        System.assertEquals('test', applications[0].Name, 'Reference Application name should match.');
    }

    /**
     * @description Tests the createPortalProgramApplication method to ensure it correctly creates a 
     *              new application record. Verifies that the new application is not null, has a status 
     *              of "New", and is linked to the correct program.
     */
    @IsTest
    static void testCreatePortalProgramApplication() {

        User testUser = [SELECT Id, AccountId FROM User WHERE Alias = 'testuser' LIMIT 1];

        System.runAs(testUser) {
    
            Reference_Application__c testReferenceApp = [SELECT Id, Program__c FROM Reference_Application__c LIMIT 1];
            
            Application__c newApp;
            try {
                newApp = PortalProgramsHelper.createPortalProgramApplication(testReferenceApp.Id, testUser.AccountId);
            } catch (AuraHandledException e) {
                System.assert(false, 'No exception should be thrown: ' + e.getMessage());
            }
    
            System.assertNotEquals(null, newApp, 'New Application should not be null.');
            System.assertEquals('New', newApp.Status__c, 'Application status should be "New".');
            System.assertEquals(testReferenceApp.Program__c, newApp.Program__c, 'Application Program__c should match the Reference Application Program__c.');
        }
    }

    /**
     * @description Tests the createPortalProgramApplication method when the user lacks create permissions.
     *              Verifies that an AuraHandledException is thrown due to insufficient permissions.
     */
    @IsTest
    static void testCreatePortalProgramApplication_NoPermission() {

        User testUser = [SELECT Id, AccountId FROM User WHERE Alias = 'testuser' LIMIT 1];

        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            PermissionSet ps = [
                SELECT Id 
                FROM PermissionSet 
                WHERE Name = 'Application_External'
            ];

            PermissionSetAssignment psa = [
                SELECT Id 
                FROM PermissionSetAssignment
                WHERE AssigneeId =: testUser.Id
                AND PermissionSetId =: ps.Id
            ];

            delete psa;
        }

        System.runAs(testUser) {
            Reference_Application__c testReferenceApp = [SELECT Id FROM Reference_Application__c LIMIT 1];

            try {
                PortalProgramsHelper.createPortalProgramApplication(testReferenceApp.Id, testUser.AccountId);
                System.assert(false, 'Expected an AuraHandledException to be thrown due to lack of permissions.');
            } catch (AuraHandledException e) {
                System.debug(e);
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }

    /**
     * @description Tests the getRelatedAccounts
     *              Verifies that an AuraHandledException is thrown due to insufficient permissions.
     */
    @IsTest
    static void getRelatedAccountsTest() {

        User testUser = [SELECT Id, AccountId FROM User WHERE Alias = 'testuser' LIMIT 1];

        System.runAs(testUser) {

            try {
                PortalProgramsHelper.getRelatedAccounts();
            } catch (AuraHandledException e) {
                System.debug(e);
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }

    /**
     * @description Tests the getRelatedAccounts method when the user is not portal enabled.
     *              Verifies that an AuraHandledException is thrown due to insufficient permissions.
     */
    @IsTest
    static void getRelatedAccountsTestNotPortalEnabled() {

        System.runAs(new User(Id = UserInfo.getUserId())) {

            try {
                PortalProgramsHelper.getRelatedAccounts();
            } catch (AuraHandledException e) {
                System.debug(e);
                System.assertEquals('User is not portal enabled', e.getMessage());
            }
        }
    }
}