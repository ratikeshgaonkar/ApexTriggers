// ### 🎯 **Selective Event Publishing**

// **Q7.**
// You only want to publish a Platform Event when a specific field (`Status__c`) changes on Opportunity. How would you detect the change and ensure the event fires only when necessary?

// > Follow-up: How would this work with bulk updates?


trigger oppHandler on opportunity(after update){
    if(Trigger.isAfter && Trigger.isUpdate){
        TriggerHandler.UpdateOpportunity(Trigger.newMap, Trigger.oldMap);
    }
}

public class TriggerHandler{
    public static void UpdateOpportunity(Map<Id,opportunity> newMap, Map<Id,opportunity> oldMap){
        list<opportunity_update__e> eventToPublish = new list<opportunity_update__e>();

        for(Id oppId : new.keySet()){
            opportunity oppNew = newMap.get(oppId);
            opportunity oppOld = oldMap.get(oppId);

            if(oppNew.Status__c != oppOld.Status__c){
                event.add(opportunity_update__e(
                    readyToShip__c = true
                ));
            }
        }

        if(!eventToPublish.isEmpty()){
            event.publish(eventsToPublish);
        }
    }
}