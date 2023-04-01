# Whatsapp-Integration
Whatsapp Integration With Salesforce

# This integration is to send & receive a text & reaction type message from salesforce. No other types such as image, audio, contact, message status like sent, delivered, read are not handled in this.

Initially Whatsapp Integration needs few things to be setup before writing any code in salesforce.
- We have to create a new account in developers.facebook.com in order to use Meta's API
- Create a new app in that account for Whatsapp Business Integration
- Make sure a new App Role is created with admin profile and give that role full rights to the created app
- Now get into the Getting Started from the left side bar. Ref pic "Dashboard"
- We can find the temporary access token there which is valid upto 23 hrs, create a permanent access token if required. In this integration I am using permanent token.
- Since this is a free account we can add upto 5 test numbers to which we can send message and receive messages from
- Ref pic "Whatsapp Access Token"
- Then we have to create a REST Web Service in apex which will be used as Webhook to receive messages and all other notifications from the client/customer to the Salesforce environment and the set the link & secret code
- Ref pic "Whatsapp Webhooks"


Lets get Started!!

1. Apex class "whatsappIntegration" - It includes 3 methods:
      - sendMessage - HTTP Callout to the Whatsapp Cloud API to send a Message from the Whatsapp LWC Component
      - getConversations - Fetch all the stored conversations and display it in the screen
      - saveConversations - Save the sent and received text messages into an object
2. Apex class "WhatsappWebhooks" - It is a REST Web Service has two HTTP Methods:
      - @HTTPGET - To send/receive verify token
      - @HTTPPOST - To receive all the messages and reactions sent from the client/customer and handle the received messages.
3. LWC component "whatsappIntegrationLWC" - HTML, JS & CSS files with same name to handle the UI

# Note: There are two other things that I can't add files for.
#       1. Salesforce Custom Object "Whatsapp_Conversation__c" to store the conversation history
#       2. Platform Event "whatsappreceivedmessage__e" to refresh and display the message on screen
#       3. Custom Field in Contact Object "Whatsapp__c" to store the whatsapp number with country code




YOUR_APP_ID, YOUR_ACCESS_TOKEN, YOUR_VERIFY_TOKEN_FOR_WEBHOOK, YOUR_PHONE_NUMBER_ID - These are used in the code to mention that it has to be referred as per your account.
