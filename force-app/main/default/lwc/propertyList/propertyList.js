import { LightningElement, wire, track } from 'lwc';
import getProperties from '@salesforce/apex/PropertyController.getProperties';

export default class PropertyList extends LightningElement {
    @track properties = [];
    maxPrice = 5000;
    status = '';
    furnishing = '';
    limitSize = 25;
    offsetValue = 0;

    @wire(getProperties, { limitSize: '$limitSize', offsetValue: '$offsetValue', maxPrice: '$maxPrice', status: '$status', furnishing: '$furnishing' })
    wiredProperties({ error, data }) {
        if (data) {
            this.properties = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleNext() {
        this.offsetValue += this.limitSize;
    }

    handlePrevious() {
        if (this.offsetValue > 0) {
            this.offsetValue -= this.limitSize;
        }
    }

    handleFilterChange(event) {
        const field = event.target.label.toLowerCase().replace(' ', '');
        this[field] = event.target.value;
        this.offsetValue = 0;
    }
}