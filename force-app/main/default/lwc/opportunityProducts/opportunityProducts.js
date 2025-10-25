// import des modules nécessaires Apex et LWC 
import { LightningElement, api, wire, track } from 'lwc';  
import deleteOpportunityLineItem from '@salesforce/apex/DeleteOpportunityLineItem.deleteOpportunityLineItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; //notifications utilisateur//
import { refreshApex } from '@salesforce/apex'; 
import getOpportunityLineItems from '@salesforce/apex/OpportunityProductsController.getOpportunityLineItems';
import updateProductStockFromOpportunity from '@salesforce/apex/ProductStockUpdater.updateProductStockFromOpportunity';
import ISADMIN from '@salesforce/customPermission/Admin';
import { subscribe } from 'lightning/empApi';  // permet de s'abonner aux événements de la plateforme

// Import des labels pour utiliser dans  l'UI multilingue //
import ProductName from '@salesforce/label/c.Product_Name';
import Quantity from '@salesforce/label/c.Quantity';
import UnitPrice from '@salesforce/label/c.Unit_Price';
import TotalPrice from '@salesforce/label/c.Total_Price';
import QuantityInStock from '@salesforce/label/c.Quantity_In_Stock';
import DeleteLabel from '@salesforce/label/c.Delete_Label';
import SeeProduct from '@salesforce/label/c.See_Product';
import QuantityErrorMessage from '@salesforce/label/c.Quantity_Error_Message';
import ContactAdminMessage from '@salesforce/label/c.Contact_Admin_Message';
import OpportunityProducts from '@salesforce/label/c.Opportunity_Products';
import OpportunityUpdateError from '@salesforce/label/c.Opportunity_Update_Error';
import NoProductMessage from '@salesforce/label/c.No_Product_Message';

export default class opportunityProducts extends LightningElement {
    @api recordId; // Id de l'opportunité actuelle//
    @track opportunityLineItems; // Pour stocker les lignes de produits//
    @track error; // Pour stocker les erreurs éventuelles//
    @track isLoading = false; // Indique si une opération est en cours//
    @track hasQuantityIssues = false; // Indique si des problèmes de quantité sont détectés//
    @api channelRefreshEvent = '/event/RefreshEvent__e'; // Canal pour les événements de rafraîchissement//
    hasItems = false; // Indique si des produits sont présents//
    isadmin = ISADMIN; // Vérifie si l'utilisateur a le profil Admin//
    wiredProductsResult; // Pour stocker le résultat de l'appel Apex//
  // Permet d'utiliser les labels importés dans le html //
    label = {
        productName: ProductName,
        quantity: Quantity,
        unitPrice: UnitPrice,
        totalPrice: TotalPrice,
        quantityInStock: QuantityInStock,
        deleteLabel: DeleteLabel,
        seeProduct: SeeProduct,
        quantityErrorMessage: QuantityErrorMessage,
        contactAdminMessage: ContactAdminMessage,
        opportunityProducts: OpportunityProducts,
        opportunityUpdateError: OpportunityUpdateError,
        noProductsMessage: NoProductMessage,
    };
// vue des colonnes du tableau selon le profil Admin et inclu le bouton voir le produit//
    columns = [];
    columnsAdmin = [
        { label: ProductName, fieldName: 'ProductName' },
        { label: UnitPrice, fieldName: 'UnitPrice', type: 'currency' },
        { label: TotalPrice, fieldName: 'TotalPrice', type: 'currency' },
        { label: Quantity, fieldName: 'Quantity', type: 'number', cellAttributes: { class: { fieldName: 'quantityColor' } } },
        { label: QuantityInStock, fieldName: 'QuantityInStock__c', type: 'number', editable: true, cellAttributes: { class: { fieldName: 'stockColor' } } },
        {
            label: DeleteLabel,
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:delete',
                name: 'delete',
                variant: 'neutral',
                alternativeText: DeleteLabel
            }
        },
        {
            label: SeeProduct,
            type: 'button',
            typeAttributes: {
                label: SeeProduct,
                iconName: 'utility:preview',
                name: 'view',
                variant: 'brand'
            }
        }
    ];
    // vue des colonnes du tableau selon le profil Commercial et ne voit pas le bouton voir le produit//
    columnsCommercial = [
        { label: ProductName, fieldName: 'ProductName' },
        { label: UnitPrice, fieldName: 'UnitPrice', type: 'currency' },
        { label: TotalPrice, fieldName: 'TotalPrice', type: 'currency' },
        { label: Quantity, fieldName: 'Quantity', type: 'number', cellAttributes: { class: { fieldName: 'quantityColor' } } },
        { label: QuantityInStock, fieldName: 'QuantityInStock__c', type: 'number', cellAttributes: { class: { fieldName: 'stockColor' } } },
        {
            label: DeleteLabel,
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:delete',
                name: 'delete',
                variant: 'neutral',
                alternativeText: DeleteLabel
            }
        }
    ];
    // choisit les colonnes à afficher en fonction du profil utilisateur lors de l'initialisation du composant//
    connectedCallback() {
        this.columns = this.isadmin ? this.columnsAdmin : this.columnsCommercial;
        this.handleSubscribeRefreshEvent(); // S'abonne aux événements de rafraîchissement//
    }

    handleSubscribeRefreshEvent() {
        const self = this; // Référence au contexte du composant//
        const messageCallback = function (response) { // Fonction de rappel pour gérer les messages reçus//
            self.handleRecalculateStock(); // Rafraîchit le stock lorsque l'événement est reçu//
        };

        subscribe(this.channelRefreshEvent, -1, messageCallback).then(response => { // S'abonne au canal d'événements//
            this.subscriptionRefreshEvent = response; // Stocke la référence de l'abonnement pour une utilisation future//
        });
    }
 // Récupère les lignes de produits associées à l'opportunité via Apex//
    @wire(getOpportunityLineItems, { opportunityId: '$recordId' }) 
    wiredProducts(result) {
        this.wiredProductsResult = result;
        const { data, error } = result;
        if (data) {
            const productUsageMap = new Map(); // Map pour suivre l'utilisation des produits//
            data.forEach(item => { // Calcule la quantité totale utilisée pour chaque produit//
                const productId = item.Product2Id;
                const quantity = item.Quantity;
                if (productUsageMap.has(productId)) {
                    productUsageMap.set(productId, productUsageMap.get(productId) + quantity);
                } else {
                    productUsageMap.set(productId, quantity);
                }
            });
            // Mappe les données pour inclure les informations de stock et les couleurs conditionnelles//
            const mappedData = data.map(item => {
                const productId = item.Product2Id;
                const stockQty = item.Product2.QuantityInStock__c;
                const quantityUsed = data
                    .filter(oli => oli.Product2Id === productId && oli.Id !== item.Id) // Exclut la ligne actuelle//
                    .reduce((sum, oli) => sum + oli.Quantity, 0); // Quantité utilisée dans les autres lignes//
                const quantityRemaining = stockQty - quantityUsed; // Quantité restante après utilisation//
                const quantity = item.Quantity;
                const isEnough = quantityRemaining >= quantity;
                return {
                    Id: item.Id,
                    ProductId: item.Product2Id,
                    ProductName: item.Product2.Name,
                    UnitPrice: item.UnitPrice,
                    TotalPrice: item.TotalPrice,
                    Quantity: quantity,
                    QuantityInStock__c: item.Diff_quantite_stock__c,
                    quantityColor: isEnough ? 'slds-text-color_success' : 'slds-text-color_error slds-theme_shade slds-theme_alert-texture',
                    stockColor: quantityRemaining <= 0 ? 'slds-text-color_error slds-theme_shade slds-theme_alert-texture' : 'slds-text-color_success'
                };
            });

            
            this.hasQuantityIssues = mappedData.some(item => item.quantityColor.includes('slds-text-color_error'));

            if (this.hasQuantityIssues) {
                this.showToast(
                    'Warning',
                    `${this.label.quantityErrorMessage}\n${this.label.contactAdminMessage}`,
                    
                );
            }

            this.opportunityLineItems = mappedData;
            this.hasItems = mappedData.length > 0;

            if (!this.hasItems) {
                this.showToast('Info', this.label.noProductsMessage, 'info');
            }

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.opportunityLineItems = undefined;
            this.hasItems = false;
        }
    }
    // Supprime une ligne de produit et met à jour le stock//
    async handledeleteProductline(productlineID) {
        this.isLoading = true;
        try {
            await deleteOpportunityLineItem({ oliId: productlineID });
            this.showToast('Success', 'Row deleted successfully', 'success');
            await refreshApex(this.wiredProductsResult);
            await this.handleRecalculateStock();
        } catch (error) {
            this.showToast('Erreur', 'Erreur lors de la suppression', 'error');
            console.error(error);
        } finally {
            this.isLoading = false;
            window.location.reload();
        }
    }
    // Ouvre les détails du produit dans une nouvelle fenêtre//
    viewProductDetails(productId) {
        window.open(`/lightning/r/Product2/${productId}/view`, '_blank');
    }
    // Gère les actions de ligne dans le tableau (voir, supprimer, recalculer le stock)//
    async handleRowAction(event) { 
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'view':
                this.viewProductDetails(row.ProductId);
                break;
            case 'delete':
                this.handledeleteProductline(row.Id);
                break;
            case 'RecalculateStock':
                await this.handleRecalculateStock();
                break;
            default:
                console.warn('Action inconnue :', actionName);
        }
    }
    // Recalcule le stock des produits en fonction des lignes d'opportunité//
    async handleRecalculateStock() {
        try {
            await refreshApex(this.wiredProductsResult);
            this.showToast('Success', 'Stock recalculated successfully');
        } catch (error) {
            this.showToast('Erreur', this.label.opportunityUpdateError, 'error');
            console.error(error);
        }
    }
 // Affiche une notification toast à l'utilisateur//
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
