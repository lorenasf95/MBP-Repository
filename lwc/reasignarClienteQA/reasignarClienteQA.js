import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import reasignarClienteMethod from '@salesforce/apex/reasignarClienteQAClass.reasignarLead';

export default class ReasignarClienteQA extends LightningElement {
	//Variables para el desplegable.
	@track opciones = [];
	@track value = '-1'

	//Variables para el modal
	@track mostrarModal = false;


	  /***************/
	 /*  FUNCIONES  */
	/***************/
	@api invoke(){
		console.log('test2');
	}

	//FUNCIÓN PARA RELLENAR EL DESPLEGABLE
	rellenarDesple(){
		this.mostrarModal = true;

		//Rellenamos el desplegable.




	}

	guardarSeleccion(){
		

	}

	cerrarModal(){
		this.mostrarModal = false;
	}

	handleChange(event) {
        this.value = event.detail.value;
    }

}