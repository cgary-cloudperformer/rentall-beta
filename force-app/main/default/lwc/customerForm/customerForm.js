import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OBJ_ACCOUNT from '@salesforce/schema/Account';
import OBJ_CONTACT from '@salesforce/schema/Contact';
import LBL_CF_STEP1 from '@salesforce/label/c.RentAllCustomerFormStep1';
import LBL_CF_STEP2 from '@salesforce/label/c.RentAllCustomerFormStep2';
import LBL_CF_STEP1_TITLE from '@salesforce/label/c.RentAllCustomerFormStep1Title';

export default class CustomerForm extends LightningElement {



    label = {
        'ProgressStep1':LBL_CF_STEP1,
        'ProgressStep2':LBL_CF_STEP2
    }
    currentStep = 'step1';
    selectedAccountType;

    @wire(getObjectInfo,{objectApiName: OBJ_ACCOUNT})
    accountInfo;
    @wire(getObjectInfo,{objectApiName: OBJ_CONTACT})
    contactInfo;

    handleAcocuntTypeSelection(evt){
        this.selectedAccountType = evt.target.value;
    }
    handleStep1NextClick(){
        this.currentStep = 'step2';
    }

    get showCustomerSelection(){
        return this.currentStep === 'step1';
    }
    get showCustomerCreation(){
        return this.currentStep === 'step2';
    }
    get showCreatePersonalCustomerForm(){
        return this.selectedAccountType === 'person'
    }
    get hasSelectedAccountType(){
        return this.selectedAccountType !== undefined && this.selectedAccountType !== null;
    }
    get hasNoSelectedAccountType(){
        return !this.hasSelectedAccountType;
    }
    get customerSelectionOptions(){
        return [
            {'label':'Business Customer','value':'business'},
            {'label':'Recreational Customer','value':'person'}
        ];
    }
    get step1Title(){
        return LBL_CF_STEP1_TITLE;
    }
}