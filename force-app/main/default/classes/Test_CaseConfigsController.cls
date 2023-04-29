/**
 * @description       : Test class for CaseConfigController
 * @author            : Amol B
 * @last modified on  : 04-29-2023
 * @last modified by  : Amol B
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-29-2023   Amol B   Initial Version
**/
@IsTest
public class Test_CaseConfigsController {
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
        insert confList;

    }
    
    @IsTest
    static void testGetCaseConfigPositive(){
        Case c = [SELECT ID FROM Case LIMIT 1];
        Case_Config__c cc = new Case_Config__c(Label__c='TestLb1', Type__c='TestType1', Amount__c=2000, Case__c=c.Id);
        insert cc;
        Test.startTest();
            CaseConfigsController.getCaseConfigs(String.valueOf(c.Id));
        Test.stopTest();
        System.assert([SELECT Id FROM Case_Config__c].size()>0);
    }
    
    @IsTest
    static void testGetCaseConfigNegative(){
        Case c = [SELECT ID FROM Case LIMIT 1];
        Test.startTest();
        delete [SELECT ID FROM Case_Config__c];
        CaseConfigsController.getCaseConfigs(String.valueOf(c.Id)+'hkashf');
        Test.stopTest();
        
    }

    @IsTest
    static void testsendCaseConfigsNegative(){
        Case c = [SELECT ID FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CaseConfigControllerMock(false));
        Test.startTest();
        CaseConfigsController.sendCaseConfigs(String.valueOf(c.Id));
        Test.stopTest();
        
    }
    
    @IsTest
    static void testsendCaseConfigsPositive(){
        Case c = [SELECT ID FROM Case LIMIT 1];
        Case_Config__c cc = new Case_Config__c(Label__c='TestLb1', Type__c='TestType1', Amount__c=2000, Case__c=c.Id);
        insert cc;
        Test.setMock(HttpCalloutMock.class, new CaseConfigControllerMock(true));
        Test.startTest();
        CaseConfigsController.sendCaseConfigs(String.valueOf(c.Id));
        Test.stopTest();
        Case cs = [SELECT ID,Status FROM Case LIMIT 1];
        System.assertEquals('Closed',cs.Status);
    }
}