trigger CreateLeaseOnTenant on Tenant_Management__c (before insert) {
List<Task> TaskList = New List<Task>();
    for(Tenant_Management__c tenant:Trigger.new){
        Task LeaseTask= new Task(Subject = 'Generate Lease Aggrement',
                                WhatId = tenant.id,
                                Status ='Not Started',
                                ActivityDate = System.today(),
                                Priority = 'High',
                                Description = 'Generate Lease Aggrement for this Tenant Property Assignment');
        TaskList.add(LeaseTask);
        
    }
    if(!TaskList.isempty()){
        insert TaskList;
    }
}