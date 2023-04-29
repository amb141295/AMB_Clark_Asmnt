import { LightningElement, api, track, wire } from 'lwc';
import getCaseConfigList from '@salesforce/apex/CaseConfigsController.getCaseConfigs';
import sendCaseConfigs from '@salesforce/apex/CaseConfigsController.sendCaseConfigs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import refreshCaseConfigs from '@salesforce/messageChannel/refreshCaseConfigs__c';
const columns = [
    { label: 'Label', fieldName: 'Label__c', type: 'text', sortable:true, hideDefaultActions:true },
    { label: 'Type', fieldName: 'Type__c', type: 'text', sortable:true, hideDefaultActions:true },
    { label: 'Amount', fieldName: 'Amount__c', sortable:true, hideDefaultActions:true, type: 'currency', cellAttributes: { alignment: 'left' }, typeAttributes: { currencyCode: 'EUR' } }
];
export default class CaseConfigs extends LightningElement {
    @api recordId;
    @track error;
    @track columns = columns;
    @track allRecords; //All Cases available for data table    
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track preSelected = [];
    @track selectedRows;
    @track disableSend = false;
    subscription = null;
    ccData;

    @wire(getCaseConfigList,{caseId:'$recordId'})
    wireFetch(value){
        this.ccData = value;
        const { data, error } = value;
        
        if(data){
            let records = [];
            for(let i=0; i<data.length; i++){
                let record = {};
                record.rowNumber = ''+(i+1);
                record.caseLink = '/'+data[i].Id;                
                record = Object.assign(record, data[i]);                
                records.push(record);
            }
            this.allRecords = records;
            if(records.length>0){
                this.showTable = true;
            }
            if(records[0].Case__r.Status === 'Closed'){
                this.disableSend = true;
            }
            
        }else{
            this.error = error;
        }       
    }

    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                refreshCaseConfigs,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Handler for message received by component
    handleMessage(message) {
        this.showTable = false;
        return refreshApex(this.ccData);
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail.recordsToDisplay;
        this.preSelected = event.detail.preSelected;
        if(this.recordsToDisplay && this.recordsToDisplay > 0){
            this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
        }else{
            this.rowNumberOffset = 0;
        } 
    }    

    getSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        let selectedRecordIds = [];
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            selectedRecordIds.push(selectedRows[i].Id);
        }     
        this.template.querySelector('c-genric-data-table').handelRowsSelected(selectedRecordIds);        
    }  
 
    handleAllSelectedRows(event) {
        this.selectedRows = [];
        const selectedItems = event.detail;          
        let items = [];
        selectedItems.forEach((item) => {
            this.showActionButton = true;
            items.push(item);
        });
        this.selectedRows = items;  
    } 

    
    sendConfigs(event) {
        sendCaseConfigs({caseId : this.recordId})
        .then(result => {
            this.disableSend = true;
            // Refresh other table
            if((result!='' || result!= 'undefined') && result.includes('sent')){
                this.showToast('success',''+result,'Successfully sent');
            }else{
                this.showToast('error',''+result,'Send failed');
            }            
            //this.template.querySelector('c-genric-data-table').setRecordsOnPage();
        })
        .catch(error => {
            this.error = error;
            this.showToast('error','Cannot add config: '+error.body.message,'Error occured');
        })
    }

    showToast(type, message, title){
        const custToast = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(custToast);
    }
}