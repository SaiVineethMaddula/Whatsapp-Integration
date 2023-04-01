public with sharing class whatsappIntegration {
    
    @AuraEnabled
    public static String sendMessage(String recordId, String message){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://graph.facebook.com/v15.0/<YOUR_APP_ID>/messages');
        req.setHeader('Authorization', 'Bearer <YOUR_ACCESS_TOKEN>');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"messaging_product": "whatsapp", "recipient_type": "individual", "to": "'+[SELECT Id, Whatsapp__c FROM Contact WHERE Id =: recordId][0].Whatsapp__c+'", "type": "text", "text": { "preview_url": false, "body": "'+Message+'" }}');
        HttpResponse res = h.send(req);
        if (res.getStatusCode() == 200) {
            System.debug(res.getBody());
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            List<Object> messagesList = (List<Object>) response.get('messages');
            Map<String, Object> messages = (Map<String, Object>) messagesList[0];
            return (String)messages.get('id');
        }
        else {
            return 'error';
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<Whatsapp_Conversation__c> getConversations(String recordId){
        return [SELECT Id, Message__c, Message_Id__c, Reaction__c, Send_Receive__c, Image__c FROM Whatsapp_Conversation__c WHERE Related_Record_Id__c =: recordId ORDER BY CreatedDate ASC];
    }

    @AuraEnabled
    public static String saveConversations(String recordId, String message, String messageId){
        Whatsapp_Conversation__c wc = new Whatsapp_Conversation__c();
        wc.Message__c = message;
        wc.Related_Record_Id__c = recordId;
        wc.Send_Receive__c = 'Sent';
        wc.Message_Id__c = messageId;
        Insert wc;
        return 'Done';
    }


}