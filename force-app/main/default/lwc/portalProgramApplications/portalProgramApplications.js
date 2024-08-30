import { api, LightningElement } from 'lwc';
import getPortalProgramApplications from '@salesforce/apex/PortalProgramsHelper.getPortalProgramApplications'
import getRelatedAccounts from '@salesforce/apex/PortalProgramsHelper.getRelatedAccounts'
export default class PortalProgramApplications extends LightningElement {
    @api recordId
    applications = []
    accountContactRelations = []

    isLoading = false
    error = false

    connectedCallback() {
        this.getPortalPrograms()
        this.fetchRelatedAccounts()
    }

    async getPortalPrograms() {
        try {
            this.isLoading = true
            
            const result = await getPortalProgramApplications({
                recordId: this.recordId
            })
            console.log(result)
            // console.log(JSON.stringify(result))

            this.applications = result

            // console.log(JSON.parse(JSON.stringify(result)))
            
        } catch (error) {
            this.error = true
            console.error(error)
        } finally {
            this.isLoading = false
        }
    }

    async fetchRelatedAccounts() {
        try {
            this.isLoading = true

            this.accountContactRelations = await getRelatedAccounts()
    
            console.log('accountContactRelations');
            
            console.log(JSON.parse(JSON.stringify(this.accountContactRelations)))

        } catch (error) {
            console.error(error)
        } finally {
            this.isLoading = false
        }
    }
}