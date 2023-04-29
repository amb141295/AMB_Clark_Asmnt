import { LightningElement, api, track, wire } from 'lwc';
import getConfigList from '@salesforce/apex/AvailableConfigsController.getConfigs';
import addConfigsToCase from '@salesforce/apex/AvailableConfigsController.addConfigsToCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import refreshCaseConfigs from '@salesforce/messageChannel/refreshCaseConfigs__c';
const columns = [
    { label: 'Label', fieldName: 'Label__c', type: 'text', sortable:true, hideDefaultActions:true },
    { label: 'Type', fieldName: 'Type__c', type: 'text', sortable:true, hideDefaultActions:true },
    { label: 'Amount', fieldName: 'Amount__c', sortable:true, hideDefaultActions:true, type: 'currency', cellAttributes: { alignment: 'left' }, typeAttributes: { currencyCode: 'EUR' } }
];
export default class AvailableConfigs extends LightningElement {
    @api recordId;
    @track error;
    @track columns = columns;
    @track allRecords; //All Cases available for data table    
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track preSelected = [];
    @track selectedRows;

    @wire(MessageContext)
    messageContext;
    
    @wire(getConfigList)
    wopps({error,data}){
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
            this.showTable = true;
        }else{
            this.error = error;
        }       
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
            items.push(item);
        });
        this.selectedRows = items;  
    } 

    
    handleAddConfig(event) {
        let idSet = [];
        this.selectedRows.forEach((item) => {
            idSet.push(item.Id);
        });
        
        addConfigsToCase({configIds : idSet, caseId : this.recordId})
        .then(result => {
            // Refresh other table
            if((result!='' || result!= 'undefined') && result.includes('New configs')){
                this.showToast('success',''+result,'Successfully added configs');
            }
            else if((result!='' || result!= 'undefined') && result.includes('Case is closed')){
                this.showToast('warning',''+result,'Case closed');
                return;
            }
            else{
                this.showToast('info',''+result,'Already exist');
            }
            
            publish(this.messageContext, refreshCaseConfigs, null);
            //this.template.querySelector('c-genric-data-table').selectedItems=[];
        })
        .catch(error => {
            this.error = error;
            this.showToast('error','Cannot add config: '+error.message,'Error occured');
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