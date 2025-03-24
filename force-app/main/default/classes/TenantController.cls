public with sharing class TenantController {
    @AuraEnabled(cacheable=true)
    public static List<Tenant_Management__c> getTenantsWithProperties() {
        return [SELECT Id, Name, Phone_Number__c, Email__c, (SELECT Id, Name,Status__c FROM Property_Managements__r)
                     FROM Tenant_Management__c];
    }
}