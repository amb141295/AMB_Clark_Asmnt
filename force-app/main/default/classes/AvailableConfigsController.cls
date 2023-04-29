/**
 * @description       : Available configs component apex scontroller
 * @author            : Amol B
 * @last modified on  : 04-29-2023
 * @last modified by  : Amol B
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-22-2023   Amol B   Initial Version
**/
public with sharing class AvailableConfigsController {
        
    /**
    * @description Method to fetch all the Configs available
    * @author Amol B | 04-29-2023 
    * @return List<Config__c> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Config__c> getConfigs(){
        try {
            List<Config__c> configList = [SELECT Id, Label__c, Type__c, Amount__c FROM Config__c WITH SECURITY_ENFORCED];
            return configList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Method to add the selected case configs on the case record.
    * @author Amol B | 04-29-2023 
    * @param configIds 
    * @param caseId 
    * @return String 
    **/
    @AuraEnabled
    public static String addConfigsToCase(List<String> configIds, String caseId){
        String retMsg = ''; 
        String existConfigs = '';
        try {
            List<Config__c> selectedConfigs;
            Map<String, Case_Config__c> configLabelToCCMap = new Map<String, Case_Config__c>();
            for(Case_Config__c cc : [select Id, Label__c, Type__c, Case__c, Case__r.Status FROM Case_Config__c WHERE Case__c = :caseId]){
                if(cc.Case__r.Status.equals('Closed')){
                    return 'Case is closed. Cannot add new configs.';
                }
                if(!configLabelToCCMap.containsKey(cc.Label__c)){
                    configLabelToCCMap.put(cc.Label__c, cc);
                }
            }
            if(!configIds.isEmpty()){
                selectedConfigs = [SELECT Id, Label__c, Type__c, Amount__c FROM Config__c WHERE Id IN :configIds WITH SECURITY_ENFORCED];
            }
            List<Case_Config__c> newCaseConfigs = new List<Case_Config__c>();
            for(Config__c con : selectedConfigs){
                if(!configLabelToCCMap.containsKey(con.Label__c)){
                    newCaseConfigs.add(
                        new Case_Config__c(Label__c = con.Label__c, 
                                           Type__c = con.Type__c,
                                           Amount__c = con.Amount__c,
                                           Case__c = caseId)
                    );
                }else{
                    existConfigs += con.Label__c + ',';
                }
            }
            if(!newCaseConfigs.isEmpty()){
                Database.insert(newCaseConfigs, false);
                retMsg = 'New configs added to case.';                
            }
            retMsg += String.isNotBlank(existConfigs) ? '\nFollowing configs already exist on the case: '+existConfigs.removeEnd(',') : '';
            return retMsg;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}