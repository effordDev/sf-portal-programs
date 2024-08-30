import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getRelatedAccounts from '@salesforce/apex/PortalProgramsHelper.getRelatedAccounts'
import createPortalProgramApplication from '@salesforce/apex/PortalProgramsHelper.createPortalProgramApplication'

export default class PortalProgramApplication extends NavigationMixin(LightningElement) {
    //reference application
    @api application = {} 
    @api accountContactRelations = []

    selectedAccountId = ''

    showAccountContactRelations = false
    isLoading = false

    get id() {
        return this.application?.Id || ''
    }
    get name() {
        return this.application?.Name || ''
    }
    get displayName() {
        return this.application?.Display_Name__c || ''
    }
    get description() {
        return this.application?.Portal_Description__c || ''
    }
    get openDate() {
        return this.application?.Application_Open_Date__c || ''
    }
    get openDateTime() {
        return new Date(this.openDate)?.getTime()
    }
    get endDate() {
        return this.application?.Application_End_Date__c || ''
    }
    get endDateTime() {
        return new Date(this.endDate)?.getTime()
    }
    get today() {
        return new Date(new Date().toISOString().split('T')[0]).getTime() 
    }
    get showApplyNowBtn() {
        if (this.openDateTime && this.endDateTime) {
            return (new Date(this.openDateTime) <= this.today && new Date(this.endDateTime) >= this.today )
        }
        return true
    }
    get selectedAccountName() {
        return this.accountContactRelations.find(item => item.AccountId === this.selectedAccountId)?.Account_Name__c || ''
    }
    get cols() {
        return [
            { 
                type: 'text',
                label: 'Account Name',
                fieldName: 'Account_Name__c',
            },
            { 
                type: 'boolean',
                label: 'Primary Contact',
                fieldName: 'Primary_Contact__c',
            },
            { 
                type: 'boolean',
                label: 'Primary Signatory',
                fieldName: 'Primary_Signatory__c',
            }
        ]
    }

    get createApplicationBtnLabel(){
        return `Create Application for ${this.selectedAccountName}`
    }  

    handleRowSelection(event) {
        // console.log(JSON.parse(JSON.stringify(event.detail.selectedRows)))

        this.selectedAccountId = event.detail.selectedRows[0]?.AccountId || ''
    }

    handleSubmit() {
        this.handleApplyNowClick()
    }

    async fetchRelatedAccounts() {
        this.accountContactRelations = await getRelatedAccounts()
    }

    async handleApplyNowClick() {

        if (!this.id) { return }

        try {

            if (this.accountContactRelations.length === 1) {
                this.selectedAccountId = this.accountContactRelations[0].AccountId
            }
            
            if (!this.selectedAccountId) {
                this.showAccountContactRelations = true
                return
            }
            
            this.showAccountContactRelations = false

            this.isLoading = true

            const app = await createPortalProgramApplication({
                recordId: this.id,
                accountId: this.selectedAccountId
            })
  
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: app.Id,
                    actionName: 'view',
                },
            });

        } catch (error) {
            console.error(error)
            this.isLoading = false
        }
    }

    handleCancel() {
        this.showAccountContactRelations = false
        this.selectedAccountId = ''
    }
}