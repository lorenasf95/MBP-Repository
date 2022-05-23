import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import metodoInicial from '@salesforce/apex/reasignarClienteQAClass.initMethodLWC';
import updateOwner from '@salesforce/apex/reasignarClienteQAClass.actualizarPropietario';

export default class ReasignarLeadQA extends LightningElement {
	//Variables para el desplegable.
	@track opciones = [];
	@track valueIdPropietario = '-1';
	@track isLoading = false;
	@api recordId;    

	  /***************/
	 /*  FUNCIONES  */
	/***************/

	 @wire(CurrentPageReference)
	 getStateParameters(currentPageReference) {
		 if (currentPageReference) {
			 this.recordId = currentPageReference.state.recordId;
		 }
	 }

	//FUNCIÓN INICIAL.
	connectedCallback(){
		this.rellenarDesple();
	}

	//FUNCIÓN PARA RELLENAR EL DESPLEGABLE
	rellenarDesple(){
		console.log('Estamos en el registro 2 --> ' , this.recordId);
		metodoInicial({leadId : this.recordId})
			.then(result =>{
				console.log('result', result);
				if(result.success == true){
					this.opciones = result.lUsers;
				}else{
					this.mostrarToast('Error',result.mensaje,'error');
					this.opciones = [];
				}
			})
			.catch(error=> {
				console.log(JSON.stringify(error))
			})
	}

	//FUNCIÓN PARA CERRAR EL MODAL.

	cerrarModal(){
		this.dispatchEvent(new CloseActionScreenEvent());
	}

	//FUNCIÓN PARA ACTUALIZAR EL NUEVO PROPIETARIO SELECCIONADO.
	actualizarPropietario(){
		this.isLoading = true;

		if(this.valueIdPropietario != '-1'){
			updateOwner({leadId : this.recordId, userId : this.valueIdPropietario})
				.then(result =>{
					this.isLoading = false;
					if(result.success == true){
						this.mostrarToast('Éxito',result.mensaje,'success');
					}else if(result.success == false){
						this.mostrarToast('Error',result.mensaje,'error');
					}
				})
				.catch(error=> {
					this.isLoading = false;
					console.log(JSON.stringify(error));
				})
		}else{
			this.isLoading = false;
			this.mostrarToast('Error','Debe seleccionar un nuevo usuario','warning');
		}
	}

	//FUNCIÓN PARA ALMACENAR EL VALUE DEL DESPLEGABLE.
	handleChange(event) {
        this.valueIdPropietario = event.detail.value;
		console.log(this.valueIdPropietario);
    }

	//FUNCIÓN PARA CREAR EL TOAST
	mostrarToast(titulo,mensaje,variante){
		const aviso = new showToastEvent({
			title: titulo,
			message: mensaje,
			variant: variante
		});
		this.dispatchEvent(aviso);

	}
}