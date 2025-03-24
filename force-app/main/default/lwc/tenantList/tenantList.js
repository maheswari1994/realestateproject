import { LightningElement, wire, track } from 'lwc';
import getTenantsWithProperties from '@salesforce/apex/TenantController.getTenantsWithProperties';

export default class TenantList extends LightningElement {
    @track tenants = [];

    @wire(getTenantsWithProperties)
    wiredTenants({ error, data }) {
        if (data) {
            this.tenants = data;
        } else if (error) {
            console.error(error);
        }
    }
}