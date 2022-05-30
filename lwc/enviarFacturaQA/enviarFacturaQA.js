import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; //Para mostrar el Toast
import { CloseActionScreenEvent } from 'lightning/actions'; //Para cerrar el modal
import { updateRecord } from 'lightning/uiRecordApi'; //Para refrescar los datos.
import { CurrentPageReference } from 'lightning/navigation'; //Para obtener el recordId
import modal from '@salesforce/resourceUrl/modal'; //Para modificar la anchura del modal
import {loadStyle} from 'lightning/platformResourceLoader'; //importar el archivo del modal
import enviarASAP from '@salesforce/apex/EnviarFacturaQAClass.enviarASAPMethod'; //Llamamos al back y hacemos un call out a SAP.


export default class EnviarFacturaQA extends LightningElement {
	//Variables
	@track valueFecha;
	@track isLoading = false;
	@api recordId;  


	  /***************/
	 /*  FUNCIONES  */
	/***************/

	//Obtenemos el id de la factura.
	@wire(CurrentPageReference)
	getStateParameters(currentPageReference) {
		if (currentPageReference) {
			this.recordId = currentPageReference.state.recordId;
			
		}
	}

	//Llamamos al modal css que importamos como recurso estático para que el modal sea más pequeño.
	connectedCallback() {
       Promise.all([
            loadStyle(this, modal)
        ])
    }

	//Llamamos al back una vez pinchan en el botón de Enviar Factura.
	enviarSAP(){
		console.log('Entramos en enviarSAP');
		console.log('##Coge el siguiente id '+this.recordId);
		this.isLoading = true;

		//Si la fecha no está rellena lanzamos un aviso.
		if(this.valueFecha == 'undefined' || this.valueFecha == '' || this.valueFecha == null){
			console.log('Entramos el error por no rellenar la fecha');
			this.isLoading = false;
			this.mostrarToast('Error','Por favor, rellene la fecha de fin de contrato.','warning');
		}
		//Si la fecha está rellena correctamente llamamos al back.
		else{
			console.log('Entramos en la llamada al back, el valor de la fecha es --> ',this.valueFecha);
			enviarASAP({idFactura : this.recordId, fechaFactura : this.valueFecha})
				.then(result =>{
					console.log('##result: ', JSON.stringify(result));

					//Si el back nos responde con éxito mostraremos un mensaje de éxito, cerraremos el modal y actualizaremos los datos de la factura.
					if(result.success == true){
						console.log('El back devuelve success');
						this.mostrarToast('Éxito',result.mensaje,'success');
						this.isLoading = false;
						this.closeQuickAction();
						updateRecord({ fields: { Id: this.recordId } });
					}
					//Si el back responde con un error mostraremos el error y cerraremos el modal.
					else{
						this.mostrarToast('Error',result.mensaje,'error');
						console.log('El back devuelve error');
						this.isLoading = false;
						this.closeQuickAction();
					}
				})
				.catch(error=> {
					console.log(JSON.stringify(error));
					this.isLoading = false;
					this.closeQuickAction();
				})
		}
	}

	//FUNCIÓN PARA ALMACENAR EL VALUE DEL DESPLEGABLE.
	handleChange(event) {
        this.valueFecha = event.detail.value;
		console.log(this.valueFecha);
    }

	//FUNCIÓN PARA CREAR EL TOAST
	mostrarToast(titulo,mensaje,variante){
		const aviso = new ShowToastEvent({
			title: titulo,
			message: mensaje,
			variant: variante
		});
		this.dispatchEvent(aviso);
	}

	//FUNCIÓN PARA CERRAR EL MODAL.
	closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}