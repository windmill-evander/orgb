import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import syncProductsToOrgB from '@salesforce/apex/OrgAAPIClient.syncProducts';

export default class SyncProductButton extends NavigationMixin(LightningElement) {
    @api recordId;
    isLoading = false; 
    handleClick() {
        this.isLoading = true; 
        syncProductsToOrgB() 
            .then(result => { // 이건 그냥 오는거고 배치가 걸리거나 그러면 어떻게 알지?
                console.log(result);
                this.refreshPage(); // when?
            })
            .catch(error => {
                console.error(error);
            });
    }

    refreshPage() {
        window.location.reload();
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId:  this.recordId,
        //         actionName: 'view'
        //     }
        // }, true);
    }
}