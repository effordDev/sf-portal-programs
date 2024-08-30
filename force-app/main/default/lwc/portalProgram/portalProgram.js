import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// import getPortalProgram from '@salesforce/apex/PortalProgramsHelper.getPortalProgram'
// import createPortalProgramApplication from '@salesforce/apex/PortalProgramsHelper.createPortalProgramApplication'


export default class PortalProgram extends NavigationMixin(LightningElement) {
    @api recordId 

    init = false
    isLoading = false
    error = false

    // async connectedCallback() {
    //     if (!this.recordId) { return }
    //     this.init = true

    //     this.fetchPortalProgram()

    //     this.init = false
    // }

    _program = {}
    @api get program() {
        return this._program        
    }
    set program(value) {
        this._program = Object.assign({}, value)
    }

    get name() {
        return this.program?.Name
    }
    get description() {
        return this.program?.Program_Description__c || ''
    }
    get purpose() {
        return this.program?.Program_Purpose__c || ''
    }

    get btnLabel() {
        return'More Information'
    }
    get btnVariant() {
        return 'brand' 
    }

    // async fetchPortalProgram() {
    //     try {
    //         this.isLoading = true

    //         this._program = await getPortalProgram({
    //             recordId: this.recordId
    //         })

    //         console.log(this.program)

    //     } catch (error) {
    //         this.error = true
    //         console.error(error)
    //     } finally {
    //         this.isLoading = false
    //     }
    // }

    async handleBtnClick() {

        try {
            this.isLoading = true

            // if (this.recordId) {
            //     console.log('apply now')
    
            //     const app = await createPortalProgramApplication({
            //         recordId: this.recordId
            //     })
    
            //     this[NavigationMixin.Navigate]({
            //         type: 'standard__recordPage',
            //         attributes: {
            //             recordId: app.Id,
            //             actionName: 'view',
            //         },
            //     });
    
            // } else {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.program.Id,
                        actionName: 'view',
                    },
                });
            // }
        } catch (error) {
            console.error(error)
        } finally {
            this.isLoading = false
        }
        
    }
}