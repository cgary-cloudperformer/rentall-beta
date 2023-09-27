import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecordCreateDefaults, generateRecordInputForCreate, getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import OBJ_ITEMRESERVATION from '@salesforce/schema/ItemReservation__c';
import FIELD_NAME from '@salesforce/schema/ItemReservation__c.Name';
import FIELD_PRODUCTNAME from '@salesforce/schema/ItemReservation__c.ProductName__c';
import FIELD_LOCATIONNAME from '@salesforce/schema/ItemReservation__c.LocationName__c';
import FIELD_INVENTORYITEM from '@salesforce/schema/ItemReservation__c.InventoryItem__c';
import FIELD_QUANTITY from '@salesforce/schema/ItemReservation__c.Quantity__c';
import FIELD_STARTDATE from '@salesforce/schema/ItemReservation__c.StartDate__c';
import FIELD_ENDDATE from '@salesforce/schema/ItemReservation__c.EndDate__c';
import FIELD_UNITPRICE from '@salesforce/schema/ItemReservation__c.PerDayUnitRental__c';
import FIELD_TOTALPRICE from '@salesforce/schema/ItemReservation__c.TotalRental__c';
import FIELD_RENTALSTARTDATE from '@salesforce/schema/Rental__c.StartDate__c';
import FIELD_RENTALENDDATE from '@salesforce/schema/Rental__c.EndDate__c';
import LBL_ITEMRESERVATIONCOUNTLABEL from '@salesforce/label/c.RentAllReservationItemCountLabel';
import LBL_ITEMRESERVATIONSEARCHLABEL from '@salesforce/label/c.RentAllReservationItemSearch';
import getItemReservationsByRentalId from '@salesforce/apex/RentAllRentalInfoService.getItemReservationsByRentalId';
import getItemReservationCountByRentalId from '@salesforce/apex/RentAllRentalInfoService.getItemReservationCountByRentalId';
import findInventoryByName from '@salesforce/apex/RentAllRentalInfoService.findInventoryByName';
import deleteItemReservationsById from '@salesforce/apex/RentAllRentalInfoService.deleteItemReservationsById';

export default class AddEditRentalItems extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api componentName;

    selectedId;
    showAddItemForm = false;
    columnArray = [FIELD_NAME, FIELD_PRODUCTNAME, FIELD_LOCATIONNAME, FIELD_STARTDATE, FIELD_ENDDATE, FIELD_QUANTITY, FIELD_UNITPRICE, FIELD_TOTALPRICE];
    label = {
        reservationCount:LBL_ITEMRESERVATIONCOUNTLABEL,
        reservationItemSearch:LBL_ITEMRESERVATIONSEARCHLABEL
    }
    @wire(getRecordCreateDefaults,{'objectApiName':OBJ_ITEMRESERVATION,'optionalFields':[FIELD_QUANTITY,FIELD_STARTDATE,FIELD_ENDDATE,FIELD_INVENTORYITEM]})
    defaultReservationRecord;
    @wire(getObjectInfo,{'objectApiName':OBJ_ITEMRESERVATION})
    objectInfo;
    @wire(getRecord,{'recordId':'$recordId','layoutTypes':['Full'],'modes':['View'],'optionalFields':[FIELD_RENTALSTARTDATE,FIELD_RENTALENDDATE]})
    recordInfo;
    @wire(getItemReservationsByRentalId,{'recordId':'$recordId'})
    reservationItems;
    @wire(getItemReservationCountByRentalId,{'recordId':'$recordId'})
    lineItemCount;
    /**
     * Handlers for Form Interactions
     */
    handleShowAddItemClick(){
        this.showAddItemForm = !this.showAddItemForm;
    }
    handleInventorySearch(evt){
        var lookupElement = evt.target;
        findInventoryByName(evt.detail).then((results)=>{
            lookupElement.setSearchResults(results);
        }).catch((err)=>{
            lookupElement.errors = [{'id':1,'message':err.body.message}];
        });
    }
    handleInventorySelectionChange(evt){
        let selectedIds = [...evt.detail];
        if(Array.isArray(selectedIds) && selectedIds.length !== 0){
            const lookupCmp = evt.target;
            lookupCmp.errors = [];
            this.selectedId = selectedIds[0];
        }
    }
    handleNewItemCancel(){
        this.handleShowAddItemClick();
    }
    handleNewItemSave(){
        let formIsValid = this.isFormValid();
        if(!formIsValid || !this.hasDefaultReservationInfoData || !this.hasObjectInfoData){
            return null;
        }
        var recordInput = generateRecordInputForCreate(this.defaultReservationRecord.data.record,this.objectInfo.data);
        let inputQuantity, inputStartDate, inputEndDate;
        inputQuantity = this.template.querySelector('.newItemQuantity').value;
        inputStartDate = this.template.querySelector('.newItemStartDate').value;
        inputEndDate = this.template.querySelector('.newItemEndDate').value;
        recordInput.fields.Quantity__c = inputQuantity;
        recordInput.fields.StartDate__c = inputStartDate;
        recordInput.fields.EndDate__c = inputEndDate;
        recordInput.fields.Rental__c = this.recordId;
        recordInput.fields.InventoryItem__c = this.selectedId;
        createRecord(recordInput).then(()=>{
            return Promise.all([refreshApex(this.reservationItems),refreshApex(this.lineItemCount)]);
        }).then(()=>{
            let successEvt = new ShowToastEvent({'title':'Success!','message':'Your Item has been reserved on rental.','variant':'success'});
            this.dispatchEvent(successEvt);
        }).catch((err)=>{
            window.console.error(err);
        })
    }
    handleCellChange(evt){
        window.console.log('Cell Change Event: %s',JSON.stringify(evt.detail.draftValues,null,"\t"));
    }
    handleRowAction(evt){
        window.console.log('Row Action Data: %s',JSON.stringify(evt.detail,null,"\t"));
        let actionName = evt.detail.action.name;
        switch(actionName){
            case 'delete':
                this.removeItemReservation(evt.detail.row.Id);
                break;
            default:
        }
    }
    handleTableUpdateSave(evt){
        window.console.log('Table Save Event: %s',JSON.stringify(evt.detail.draftValues,null,"\t"));
        this.updateItemReservations(evt.detail.draftValues);
    }
    /**
     * Component specific methods (non-handler)
     */
    isFormValid(){
        //get the input and check the validity
        let formInputValidity = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, inputCmp)=>{
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        },true);
        //check the validity of the lookup
        const lookupCmp = this.template.querySelector('c-lookup');
        let selectedInventoryArray = lookupCmp.getSelection();
        if(selectedInventoryArray.length === 0){
            lookupCmp.errors = [{'message':'An item must be selected.'}];
        }
        let errorList = lookupCmp.errors;
        return errorList.length === 0 && formInputValidity;
    }
    updateItemReservations(recordsToUpdate){
        let promiseArray = [];
        if(Array.isArray(recordsToUpdate) && recordsToUpdate.length > 0){
            promiseArray = recordsToUpdate.map( element => {
                let fields = Object.assign({},element);
                let recordInfo = { fields };
                return updateRecord(recordInfo);
            });
            Promise.all(promiseArray).then((updatedArray)=>{
                return Promise.all([refreshApex(this.reservationItems),refreshApex(this.lineItemCount)]);
            }).then(()=>{
                let notificationEvt = new ShowToastEvent({'title':'Reservation Items Updated',
                    'message':'Items have been updated on Rental.','variant':'success'});
                this.dispatchEvent(notificationEvt);
                this.template.querySelector('.itemReservationTable').draftValues = [];
            }).catch((err)=>{
                this.displayErrorMessage(err?.body?.message);
            });
        }
    }
    removeItemReservation(reservationId){
        let reservationIdArray = [];
        reservationIdArray.push(reservationId);
        deleteItemReservationsById({'reservationIds':reservationIdArray}).then(()=>{
            return Promise.all([refreshApex(this.reservationItems),refreshApex(this.lineItemCount)]);
        }).then(()=>{
            let notificationEvt = new ShowToastEvent({'title':'Reservation Item Removed','message':`Reservation Item has been deleted`,'variant':'success'});
            this.dispatchEvent(notificationEvt);
        }).catch((err)=>{
            this.displayErrorMessage(err?.body?.message);
        });
    }
    displayErrorMessage(errMess){
        let errorEvt = new ShowToastEvent({'title':'Error','message':errMess,'variant':'error'});
        this.dispatchEvent(errorEvt);
    }
    /**
     * Getters
     */
    get hasReservationResponse(){
        return this.reservationItems !== undefined && this.reservationItems !== null;
    }
    get hasObjectInfoResponse(){
        return this.objectInfo !== undefined && this.objectInfo !== null;
    }
    get hasRecordInfoResponse(){
        return this.recordInfo !== undefined && this.recordInfo !== null;
    }
    get hasReservationInfoResponse(){
        return this.defaultReservationRecord !== undefined && this.defaultReservationRecord !== null;
    }
    get hasObjectInfoData(){
        return this.hasObjectInfoResponse && this.objectInfo.data !== undefined;
    }
    get hasRecordInfoData(){
        return this.hasRecordInfoResponse && this.recordInfo.data !== undefined;
    }
    get hasDefaultReservationInfoData(){
        return this.hasReservationInfoResponse && this.defaultReservationRecord.data !== undefined;
    }
    get defaultStartDate(){
        if(this.hasRecordInfoData){
            return this.recordInfo.data.fields[FIELD_RENTALSTARTDATE.fieldApiName].value;
        }
        return '';
    }
    get defaultEndDate(){
        if(this.hasRecordInfoData){
            return this.recordInfo.data.fields[FIELD_RENTALENDDATE.fieldApiName].value;
        }
        return '';
    }
    get tableColumns(){
        let columnDisplayArray;
        if(this.hasObjectInfoData){
            columnDisplayArray = this.columnArray.map(columnData => {
                let objectInfoField, columnLabel, columnFieldName, columnDatatype, columnEditable;
                objectInfoField = this.objectInfo.data.fields[columnData.fieldApiName];
                columnLabel = objectInfoField.label;
                columnFieldName = objectInfoField.apiName;
                switch(objectInfoField.dataType){
                    case 'Address':
                        break;
                    case 'Base64':
                        break;
                    case 'Boolean':
                        columnDatatype = 'boolean';
                        break;
                    case 'ComboBox':
                        columnDatatype = 'text';
                        break;
                    case 'ComplexValue':
                        break;
                    case 'Currency':
                        columnDatatype = 'currency';
                        break;
                    case 'Date':
                        columnDatatype = 'date-local';
                        break;
                    case 'DateTime':
                        columnDatatype = 'date';
                        break;
                    case 'Double':
                        columnDatatype = 'number';
                        break;
                    case 'Email':
                        columnDatatype = 'email'
                        break;
                    case 'Int':
                        columnDatatypee = 'number';
                        break;
                    case 'Location':
                        columnDatatype = 'location';
                        break;
                    case 'MultiPicklist':
                        columnDatatype = 'text';
                        break;
                    case 'Percent':
                        columnDatatype = 'percent';
                        break;
                    case 'Phone':
                        columnDatatype = 'phone';
                        break;
                    case 'Picklist':
                        columnDatatype = 'text';
                        break;
                    case 'Reference':
                        columnDatatype = 'text';
                        break;
                    case 'String':
                        columnDatatype = 'text';
                        break;
                    case 'Textarea':
                        columnDatatype = 'text';
                        break;
                    case 'Time':
                        columnDatatype = 'text';
                        break;
                    case 'Url':
                        columnDatatype = 'url';
                        break;
                    default:
                        columnDatatype = 'text';
                        break;
                }
                columnEditable = objectInfoField.updateable;
                return {'label':columnLabel,'fieldName':columnFieldName,'type':columnDatatype,'editable':columnEditable,
                    'sortable':true};
            });
            columnDisplayArray.push({'type':'action','typeAttributes':{'rowActions':[
                {'label':'Delete', 'name':'delete'}
            ],'menuAlignment':'right'}});
        }
        return columnDisplayArray;
    }

    get reservationItemCount(){
        if(this.lineItemCount.data !== undefined){
            return this.lineItemCount.data;
        }
        return 0;
    }

}