import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPortalPrograms from '@salesforce/apex/PortalProgramsHelper.getPortalPrograms'

export default class PortalPrograms extends LightningElement {
    isLoading = false
    error = false
    programs = []

    connectedCallback() {
        this.fetchPortalPrograms()
    }

    get pathname() {
        return window.location.pathname || ''
    }
    get pathnameItems() {
        return this.pathname.split('/')
    }
    get hook() {
        return this.pathnameItems[this.pathnameItems?.length - 1] 
    }

    async fetchPortalPrograms() {
        try {
            this.isLoading = true
            
            this.programs = await getPortalPrograms({
                hook: this.hook
            })
            
        } catch (error) {
            this.error = true
            console.error(error)
        } finally {
            this.isLoading = false
        }
    }
}