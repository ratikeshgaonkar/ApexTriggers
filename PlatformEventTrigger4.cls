
// <!-- ### 🕒 **Delayed/Queued Processing**

// **Q6.**
// A client wants to send large batches of leads for processing — but only during off-peak hours (e.g., at night). How would you use Platform Events to queue up lead data and process it asynchronously?

// > Follow-up: Would you combine PE with Batch Apex? -->


// psuedo code

// first creating platformEvent and fields inside it
// Then creating a trigger for that platform event
// and after that platform event stored data add that data in the object
// write on batch apex to get that data and process and schedule that batch apex 

trigger platformEventHandler on lead_processing__e(after insert){
    list<queue_records__c> leadRecords = new list<queue_records__c>();

    for(lead_processing__e evnt : Trigger.new){
        leadRecords.add(new queue_records__c(
            firstName__c = evnt.firstName__c,
            Age__c       = evnt.Age__c,
            status__c    = evnt.status__c
        ));
    }

    if(!leadRecords.isEmpty){
        insert leadRecords;
    }  
}

public class leadBatchable implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext bc){

        list<queue_records__c> lisOfRecords = new list<queue_records__c>();
        lisOfRecords = [SELECT Id, firstName__c, Age__c, status__c FROM queue_records__c WHERE status__c = 'queued'];
    }

    public void execute(Database.BatchableContext bc, list<queue_records__c> scope){
        list<lead> leadToInsert = new list<lead>();

        for(queue_records__c qu : scope){
            leadToInsert.add(new lead(
                firstName = qu.firstName__c,
                Age = qu.Age__c
            ));
        }
        insert leadToInsert;

        update scope;
    }

    public void finish(Database.BatchableContext bc){
        System.debug('finish of processing');
    }
}

public class scheduleApex implement Schedulable{
    public void execute(SchedulableContext bc){
        Database.executeBtch(new leadBatchable(), 200);
    }
}


//To run schedulable Apex

system.schedule('Job to run','CRON_EXPRESSION', new scheduleApex());