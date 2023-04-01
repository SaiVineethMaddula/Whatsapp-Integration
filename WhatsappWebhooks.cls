@RestResource(urlMapping = '/whatsappwebhook')
global class WhatsappWebhooks {

    @HttpGet
    global static void doGet() {
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;
        if(request.params.get('hub.verify_token') == '<YOUR_VERIFY_TOKEN_FOR_WEBHOOK>')
            response.responseBody = Blob.valueOf(request.params.get('hub.challenge'));
    }

    @HttpPost
    global static void doPost() {
        String messageType, messageBody, messageFrom, messageReaction, messageId;

        System.debug(Restcontext.request.requestBody.toString());

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(Restcontext.request.requestBody.toString());
        
        List<Object> entryList = (List<Object>) response.get('entry');
        Map<String, Object> entry = (Map<String, Object>) entryList[0];
        
        List<Object> changesList = (List<Object>) entry.get('changes');
        Map<String, Object> changes = (Map<String, Object>) changesList[0];

        Map<String, Object> value = (Map<String, Object>) changes.get('value');

        List<Object> messagesList = (List<Object>) value.get('messages');
        Map<String, Object> messages = (Map<String, Object>) messagesList[0];

        messageType = messages.get('type').toString();
        messageFrom = messages.get('from').toString();

        if (messageType == 'text') {
            Map<String, Object> text = (Map<String, Object>) messages.get('text');
            messageBody = text.get('body').toString();

            messageId = messages.get('id').toString();

            Whatsapp_Conversation__c wc = new Whatsapp_Conversation__c();
            wc.Message__c = messageBody;
            wc.Related_Record_Id__c = [SELECT Id FROM Contact WHERE Whatsapp__c =: messageFrom][0].Id;
            wc.Send_Receive__c = 'Received';
            wc.Message_Id__c = messageId;
            wc.Image__c = false;
            Insert wc;

            whatsappreceivedmessage__e wartm = new whatsappreceivedmessage__e();
            EventBus.publish(wartm);

        }

        else if (messageType == 'reaction') {
            Map<String, Object> reaction = (Map<String, Object>) messages.get('reaction');
            messageReaction = reaction.get('emoji').toString();
            messageId = reaction.get('message_id').toString();

            Whatsapp_Conversation__c wc = [SELECT Id, Reaction__c FROM Whatsapp_Conversation__c WHERE Message_Id__c =: messageId LIMIT 1];
            wc.Reaction__c = messageReaction;
            update wc;

            whatsappreceivedmessage__e warr = new whatsappreceivedmessage__e();
            EventBus.publish(warr);
        }

        else if (messageType == 'image') {
            Map<String, Object> image = (Map<String, Object>) messages.get('image');
            messageBody = image.get('id').toString();

            messageId = messages.get('id').toString();

            Whatsapp_Conversation__c wc = new Whatsapp_Conversation__c();
            wc.Message__c = messageBody;
            wc.Related_Record_Id__c = [SELECT Id FROM Contact WHERE Whatsapp__c =: messageFrom][0].Id;
            wc.Send_Receive__c = 'Received';
            wc.Message_Id__c = messageId;
            wc.Image__c = true;
            Insert wc;

            whatsappreceivedmessage__e warimg = new whatsappreceivedmessage__e();
            EventBus.publish(warimg);
        }
    }

}