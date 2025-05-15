//Your Salesforce org is integrated with an external warehouse system. 
//When an order is marked as "Ready to Ship", how would you notify the external system in a scalable and governor-limit-safe way?


trigger AccountHandler on Account(after Update){
    if(TriggerHandler.firstRun){
        TriggerHandler.updateAccountField(Trigger.oldMap, Trigger.newMap)
    }
}

public class TriggerHandler {
    public static boolean firstRun = true;

    public static void updateAccountField(Map<Id,Account> oldMap, Map<Id,Account> newMap){

        list<Account_Update__e> eventToPublish = new list<Account_Update__e>();

       //newMap.keySet() return the data which has been heat to the trigger for Example Account

        for(Id accId : newMap.keySet()){

            Account oldAcc = oldMap.get(accId);
            Account newAcc = newMap.get(accId);

            if(newAcc.readyToShip__c && !oldAcc.readyToShip__c){
                eventToPublish.add(new Account_Update__e(
                    AccountId__c = accId,
                    readyToShip__c = true
                ))
            }
        }

        if(!eventToPublish.isEmpty()){
            EventBus.publish(eventsToPublish);
        }
    }   
}


// I will use Platform Event-Triggered Flow
// selecting PlatformEvent - Account_Update__e
// Get Account Info there
// And then Action in the flow to make callout as POST an trigger it
