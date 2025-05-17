// ### 🧾 **Event Size Limit Challenge**

// **Q8.**
// Platform Events have limits on payload size and published events per hour. How would you handle large-volume publishing when sending thousands of records with detailed information?

// > Follow-up: Would you break up the data? Use external queues?

// Psuedo code

// make a payload in trigger 
// and add that payload in some of the object Batch Apex add that payload in PE
// Make http request



trigger sponsorshipRecord on sponsorship__c(after insert, after update){

    //Making a new object to add all data with childId, sponsorship Id and payload data
    list<sponsorship_Event_Queue__c> queueRecords = new list<sponsorship_Event_Queue__c>();

    for(sponsorship__c spo : Trigger.New){
        if(!spo.isEmpty()){
            //creation of payload data
            String payloadData = JSON.serialize(new Map<String,Object>{
                'sponsorshipId' => spo.Id,
                'ChildId' => spo.child__c,
                'Amount' =>  spo.amount__c,
                'location' => spo.location
            });
            //After creating this payload it would look like 
            // {
            //     "SponsorshipId": "a01ABC123456789",
            //     "ChildId": "a02XYZ987654321",
            //     "DonorName": "Alice Johnson",
            //     "Amount": 50.0,
            //     "Notes": "Monthly donation"
            // }       
        }

        queueRecords.add(new sponsorship_Event_Queue__c(
            childIdSponsorship__c = spo.Id,
            payload__c = payloadData      //its long text area field so data would be store in single field 
        ));
    }

    if(!queueRecords.isEmpty()){
        insert queueRecords;
    } 
}

global class processingBatch implements schedulable{

    public void execute(SchedulableContext scope){

        list<platFormEventRecordChild__e> eventToPublish = new list<platFormEventRecordChild__e>();

        list<sponsorship_Event_Queue__c> allRecords = [SELECT Id, childIdSponsorship__c, payload__c FROM sponsorship_Event_Queue__c 
                                                        WHERE processed__c = false LIMIT 100];

        for(sponsorship_Event_Queue__c sc : allRecords){
            eventToPublish.add(new platFormEventRecordChild__e(
                sponsorshipRecord = sc.childIdSponsorship__c,
                payloadData = sc.payload__c,
            ))
        }
        if(!eventToPublish.isEmpty()){
            event.publish(eventToPublish);
        }     
    }
}


//If I want jsonData to external services how can i do that

//Make one json Data

String jsonData = JSON.serialize(new Map<String,Object>{
    'sponsorshipId' => cs.Id //this cs.Id would be coming from any lopp I have not added
    'opportunityId' => cs.oppId,
    'cardData' => cardId
});

HttpRequest req = new HttpRequest();
req.setEndpoint(/v/customer);
req.setMethod('POST');
req.Header('Content-Type','application/json');
req.setBody(jsonData);


Http http = new Http();
try{
    HttpResponse res = http.send(req);
    system.debug('response',res.getBody());
}

