import { api, LightningElement, track, wire } from 'lwc';
import sendMessage from '@salesforce/apex/whatsappIntegration.sendMessage';
import getConversations from '@salesforce/apex/whatsappIntegration.getConversations';
import saveConversations from '@salesforce/apex/whatsappIntegration.saveConversations';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';


export default class WhatsappIntegration extends LightningElement {

    @api recordId;
    @track allConvo;
    @track refreshData;
    scrollableDiv;
    render=true;

    subscription = {};
    @api channelName = '/event/whatsappreceivedmessage__e';
 
    connectedCallback() {
        // Register error listener     
        this.registerErrorListener();
        this.handleSubscribe();
    }
 
    // Handles subscribe button click
    handleSubscribe() {
        let one = this;
        // Callback invoked whenever a new event message is received
        let messageCallback = function (response) {
            var obj = JSON.parse(JSON.stringify(response));
            const objData = obj.data.payload;
            one.refreshGetAllConvo();
        };
 
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }
 
    //handle Error
    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }

    renderedCallback() {
        this.scrollableDiv = this.template.querySelector('.slds-scrollable');
        this.scrollDown();
    }

    

    scrollDown() {
        this.scrollableDiv.scrollTop = this.scrollableDiv.scrollHeight;
    }


    @wire(getConversations, { recordId: '$recordId' })
    wiredData(value){
        this.refreshData = value;
        const {data, error} = value;
        if (data) {
            this.render = false;
            this.allConvo = data;
            this.render = true;
            var timeout = setTimeout(()=>{
            this.template.querySelectorAll('div[data-type="Sent"]').forEach(element => {
                element.style = "padding: 5px; margin: 5px; max-width: 60%; width: fit-content; margin-inline-start: auto; overflow-wrap: break-word; background-color: #dcf8c6; position: relative;";
            });
            this.template.querySelectorAll('p[data-id="Sent"]').forEach(element => {
                var style = "position: absolute; bottom: -10px; left: 5px;"
                element.style = style;
            });
            this.template.querySelectorAll('p[data-id="Received"]').forEach(element => {
                var style = "position: absolute; bottom: -10px; right: 5px;"
                element.style = style;
            });
            clearTimeout(timeout);
            }, 50);
        }
        else if (error) {
            console.error('Error:', error);
        }
    }

    saveConvo(msgId){
        saveConversations({ recordId: this.recordId, message: this.message, messageId: msgId})
            .then(result => {
                this.refreshGetAllConvo();
            })
            .catch(error => {
                console.error('Error in saving conversations:', error);
            });
    }

    handleMessageOnchange(event){
        this.message = event.target.value;
    }

    handleSendMessage(){
        // this.dispatchEvent(new CloseActionScreenEvent());
        this.template.querySelector('lightning-input').value = '';
        sendMessage({ recordId: this.recordId, message: this.message})
            .then(result => {
                if (result != 'error') {
                    this.saveConvo(result);
                }
            })
            .catch(error => {
                console.error('Error in sending message:', error);
            });
    }

    refreshGetAllConvo(){
        this.render = false;
        this.allConvo = refreshApex(this.refreshData);
        eval("$A.get('e.force:refreshView').fire();");
        this.render = true;
    }

}