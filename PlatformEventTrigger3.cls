// ### 🧠 **Bulk-safe Processing**

// **Q2.**
// You have a trigger on the Account object that performs multiple DML operations. 
// To reduce the risk of hitting governor limits, how could you offload this processing using Platform Events? 


// update related Contacts when an Account's 
// Amount__c field is updated, using Platform Events to avoid governor limits and handle bulk updates (batch size = 200).




// Psuedo Code

// Trigger on Account when fields update 
// then the fields in platform event get update and then publish it
// and trigger platform handler will be the subscriber(Listening of that publish)
// Queueable Job Apex class will work for Bulk data.


trigger AccountHandler on Account(after insert){
    if(Trigger.isAfter && Trigger.isInsert){
        TriggerHandler.updateContactRecords(Trigger.newMap);
    }
}


//Publisher
public class TriggerHandler{
    public static void updateContactRecords(Map<Id,Account> newMap){

        public static boolean firstRun= true;

        Set<Id> accList = newMap.keySet();
        list<Account_Update__e> accountUpdatePlatformEvent = new List<Account_Update__e>();

        for(Account acc : accList){
            accountUpdatePlatformEvent.add(Account_Update__e(
                AccountId__c = acc.Id,
                newAmount__c = acc.amount__c
            ))
        }
    }
    if(!accountUpdatePlatformEvent.isEmpty()){
        event.publish(accountUpdatePlatformEvent);
    }
}


//Subscriber
trigger AccountUpdateOnPlatformEvent on Account_Update__e(after insert){
        if(Trigger.isInsert && Trigger.isAfter && firstRun){
            System.enqueueJob(new ProcessAccountUpdateEvent(Trigger.New));
        }

}

//QUeable Job for DML Operation on large Data

public class ProcessAccountUpdateEvent implements Queueable, Database.AllowsCallouts{

    private list<Account_Update__e> eventList;

    //create two things list and set one list is for Account and listofData associate with that account
    list<Id, Integer> listOfData = new list<Id,Integer>();
    set<Id> accountIds = new set<Id>();

    public ProcessAccountUpdateEvent(List<Account_Update__e> event){
        //In this event all platform eventdata would be there with fields in it
        this.eventList = event;
    }

    public void execute(QueueableContext context){

        //looping through platform event 
        for(Account_Update__e eve : eventList){
            Id accId = eve.AccountId__c;
            accountIds.add(accId);
            listOfData.put(accId, eve.amount__c);
        }

        list<Contact> contList = [SELECT Id, AccountId FROM Contact WHERE AccountId IN : accountIds];

        for(Contact con : contList){
            Id accId = con.AccountId;
            con.Amount__c = listOfData.get(accId);
        }

        if(!contList.isEmpty()){
            Update contList;
        }
    }





}


