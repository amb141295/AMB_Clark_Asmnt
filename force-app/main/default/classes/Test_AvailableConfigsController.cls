@IsTest
public class Test_AvailableConfigsController {
	@TestSetup
    static void makeData(){
        Account acc = new Account(Name='TestAccount');
        insert acc; 
        
        Contact c = new Contact(AccountId =acc.Id, Firstname='AmolTest', LastName='TestLname1');
        insert c;

        Case testCase = new Case(ContactId=c.Id, AccountId= acc.Id, Status='New');
        insert testCase;

        List<Config__c> confList = new List<Config__c>();
        confList.add(new Config__c(Label__c='TestLb1', Type__c='TestType1', Amount__c=2000));
        confList.add(new Config__c(Label__c='TestLb2', Type__c='TestType2', Amount__c=3000));
        confList.add(new Config__c(Label__c='TestLb3', Type__c='TestType3', Amount__c=4000));
        confList.add(new Config__c(Label__c='TestLb4', Type__c='TestType4', Amount__c=5000));
        insert confList;
    }
    
    @IsTest
    static void testGetConfigsPos(){
        
        Test.startTest();
            AvailableConfigsController.getConfigs();
        Test.stopTest();
        System.assert([SELECT Id FROM Config__c].size()>0);
    }
    
    @IsTest
    static void testGetConfigsNeg(){
        delete [SELECT Id FROM Config__c];
        Test.startTest();
            AvailableConfigsController.getConfigs();
        Test.stopTest();        
    }
    
    @IsTest
    static void testAddConfigsToCase(){
        List<Config__c> conList = [SELECT Id FROM Config__c];
        Case c = [SELECT ID FROM Case LIMIT 1];
        Test.startTest();
        Case_Config__c cc = new Case_Config__c(Label__c='TestLb1', Type__c='TestType1', Amount__c=2000, Case__c=c.Id);
        insert cc;
        AvailableConfigsController.addConfigsToCase(new List<String>{conList[2].Id,conList[0].Id}, c.Id);
        Test.stopTest();
        System.assert([SELECT Id FROM Case_Config__c].size()==2);
    }
    
    @IsTest
    static void testAddConfigsToCaseClosed(){
        Config__c con = [SELECT Id FROM Config__c LIMIT 1];
        Case c = [SELECT Id,Status FROM Case LIMIT 1];
        c.Status = 'Closed';
        update c;
        Case_Config__c cc = new Case_Config__c(Label__c='TestLb1', Type__c='TestType1', Amount__c=2000, Case__c=c.Id);
        insert cc;
        Test.startTest();
		AvailableConfigsController.addConfigsToCase(new List<String>{con.Id}, c.Id);
        Test.stopTest();
        System.assert([SELECT Id FROM Case_Config__c].size()==1);
    }
}