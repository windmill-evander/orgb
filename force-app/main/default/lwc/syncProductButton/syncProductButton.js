import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import syncProductsToOrgB from '@salesforce/apex/OrgAAPIClient.syncProducts';

export default class SyncProductButton extends NavigationMixin(LightningElement) {
    @api recordId;
    isLoading = false; 
    handleClick() {
        this.isLoading = true; 
        syncProductsToOrgB() 
            .then(result => { // 배치 걸리면 토스트 띄운다? isSyncing 필드를 만든다? isSyncing true면 block?
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