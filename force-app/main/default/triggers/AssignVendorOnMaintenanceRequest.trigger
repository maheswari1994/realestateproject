trigger AssignVendorOnMaintenanceRequest on Maintenance_Request__c (before insert) {

    
    Map<Id, Integer> vendorWorkloadMap = new Map<Id, Integer>();

    
    List<Vendor_Management__c> vendors = [SELECT Id FROM Vendor_Management__c];

    if (vendors.isEmpty()) {
        
        for (Maintenance_Request__c request : Trigger.new) {
            request.addError('No vendors available for assignment.');
        }
        return;
    }

    
    List<Maintenance_Request__c> existingRequests = [
        SELECT Vendor__c
        FROM Maintenance_Request__c
        WHERE Vendor__c IN :vendors
    ];

   
    for (Maintenance_Request__c request : existingRequests) {
        if (vendorWorkloadMap.containsKey(request.Vendor__c)) {
            vendorWorkloadMap.put(request.Vendor__c, vendorWorkloadMap.get(request.Vendor__c) + 1);
        } else {
            vendorWorkloadMap.put(request.Vendor__c, 1);
        }
    }

    
    for (Vendor_Management__c vendor : vendors) {
        if (!vendorWorkloadMap.containsKey(vendor.Id)) {
            vendorWorkloadMap.put(vendor.Id, 0);
        }
    }

    for (Maintenance_Request__c request : Trigger.new) {
        if (request.Vendor__c == null) {
            
            Id leastBusyVendorId = null;
            Integer leastWorkload = null; 
            for (Id vendorId : vendorWorkloadMap.keySet()) {
                if (leastWorkload == null || vendorWorkloadMap.get(vendorId) < leastWorkload) {
                    leastWorkload = vendorWorkloadMap.get(vendorId);
                    leastBusyVendorId = vendorId;
                }
            }

           
            system.debug('leastBusyVendorId-->'+leastBusyVendorId);
            request.Vendor__c = leastBusyVendorId;
             system.debug('request-->'+request);
           
            vendorWorkloadMap.put(leastBusyVendorId, vendorWorkloadMap.get(leastBusyVendorId) + 1);
        }
    }
}