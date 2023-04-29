/**
 * @description       : Case config component controller
 * @author            : Amol B
 * @last modified on  : 04-29-2023
 * @last modified by  : Amol B
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-27-2023   Amol B   Initial Version
**/
public with sharing class CaseConfigsController {

    /**
    * @description Method to get all the case configs related to the case.
    * @author Amol B | 04-29-2023 
    * @param caseId 
    * @return List<Case_Config__c> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Case_Config__c> getCaseConfigs(String caseId){
        try {
            List<Case_Config__c> caseConfigList = [SELECT Id, Label__c, Type__c, Amount__c, Case__r.Status FROM Case_Config__c WHERE Case__c = :caseId WITH SECURITY_ENFORCED];
            return caseConfigList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Method to send teh case congfigs to an external web service address.
    * @author Amol B | 04-29-2023 
    * @param caseId 
    * @return String 
    **/
    @AuraEnabled
    public static String sendCaseConfigs(String caseId){        
        try{
            if(String.isNotBlank(caseId) && caseId instanceOf Id){
                
                DataWrapper dw = new DataWrapper();
                List<Case_Config__c> ccList = [SELECT Id, Label__c, Type__c, Amount__c, Case__c, Case__r.Status FROM Case_Config__c WHERE Case__c = :caseId WITH SECURITY_ENFORCED];
                if(!ccList.isEmpty()){
                    dw.caseId = caseId;
                    dw.status = 'Closed';
                }
                List<CaseConfig> ccWrpList = new List<CaseConfig>();
                for(Case_Config__c cc : ccList){
                    ccWrpList.add(new CaseConfig(cc.Label__c, cc.Type__c, cc.Amount__c));
                }
                dw.caseConfigs = ccWrpList;

                HttpResponse res = sendRequest(dw);
                if(res.getStatusCode() == 200){
                    update new Case(Id=caseId,Status='Closed');
                    return 'Case configs sent!!';                    
                }else{
                    return 'Send failed! ' + res.getStatusCode() +': '+res.getStatus();
                }
            } 
            return null;           
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    /**
     * @description : Wrapper class for generating JSON
     * */
    private class DataWrapper {
        String caseId;
        String status;
        List<CaseConfig> caseConfigs = new List<CaseConfig>();
    }

    /**
     * @description : Wrapper class for Case config lis
     * */
    private class CaseConfig{
        String label;
        String type;
        Decimal amount;

        private CaseConfig(String labl, String typ, Decimal amt){
            this.label = labl;
            this.type = typ;
            this.amount = amt;
        }
    }

    /**
    * @description Method to send the Http request
    * @author Amol B | 04-29-2023 
    * @param dw 
    * @return HttpResponse 
    **/
    private static HttpResponse sendRequest(DataWrapper dw){
        HttpRequest req = new HttpRequest();        
        req.setMethod('POST');
        req.setEndpoint('https://clarkdemo.requestcatcher.com/test');
        req.setBody(JSON.serialize(dw));
        // Instantiate a new Http object
        Http h = new Http();
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        return res;
    }
}