import {LightningElement, track, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import myAVATAR_Icon from '@salesforce/resourceUrl/imagenAvatar';
import initLWC from '@salesforce/apex/GestionCandidatosClass.datosLeads';
import cambiarEstadoRechazado from '@salesforce/apex/GestionCandidatosClass.estadoRechazado';
import transformarCandidato from '@salesforce/apex/GestionCandidatosClass.transformarLead';


export default class GestionCandidatos extends LightningElement {

	avatarPNG = myAVATAR_Icon;
	@track lCandidatos = [];
	@track lIdCandidatosChecked = [];
	@track isLoading = false;

	/***********/
	/*FUNCIONES*/
	/***********/

	//FUNCIÓN INICIAL
	connectedCallback() {
		this.mostrarCandidatos();
		
    }

	//FUNCIÓN PARA MOSTRAR LOS CANDIDATOS
	mostrarCandidatos(){
		this.isLoading = true;
		initLWC()
			.then(result => {
				console.log('El back devuelve -> ' ,JSON.stringify(result));
				if(result.success == true){
					this.isLoading = false;
					this.lCandidatos = result.lDatosLeads;
				}else{
					this.isLoading = false;
					this.mostrarToast('Aviso',result.mensaje,'warning')
				}
			})
			.catch(error=> {
				this.isLoading = false;
				this.mostrarToast('Error',error.body.message,'error')
				console.log(JSON.stringify(error));
			})
	}

	//FUNCIÓN PARA EL CHECK.
	handleChange(event){
		let valorCheckCandidato = event.detail.checked;
		let idCandidato = event.currentTarget.value;
		let card = event.target.closest(".card");

		//Si está checkeado añadiremos un borde difuminado a la carta del candidato seleccionado y guardaremos su id en una lista.
		if(valorCheckCandidato == true){
			card.classList.add('borde');
			this.lIdCandidatosChecked.push(idCandidato);
			console.log('##Metemos al candidato en la lista: ',JSON.stringify(this.lIdCandidatosChecked));
		}
		//En caso contrario borraremos el borde difuminado y lo sacaremos de la lista.
		else{
			card.classList.remove('borde');
			this.lIdCandidatosChecked = this.lIdCandidatosChecked.filter( idLead => idLead !== idCandidato);
			console.log('##Borramos al candidato de la lista: ',JSON.stringify(this.lIdCandidatosChecked));
		}
		console.log('##Lista de candidatos seleccionados final: ',JSON.stringify(this.lIdCandidatosChecked));
	}

	//FUNCIÓN PARA TRANSFORMAR EL LEAD.
	transformarLead(){
		console.log('Entramos en transformarLead');
		this.isLoading = true;
		transformarCandidato({lIdCandidatos : this.lIdCandidatosChecked})
			.then(result => {
				console.log('El back devuelve -> ' ,JSON.stringify(result));
				if(result.success == true){
					this.isLoading = false;
					this.mostrarToast('Éxito',result.mensaje,'success');
					this.mostrarCandidatos();
				}else{
					this.isLoading = false;
					this.mostrarToast('Aviso',result.mensaje,'error');
				}
			})
			.catch(error=> {
				this.isLoading = false;
				this.mostrarToast('Error',error.body.message,'error')
				console.log(JSON.stringify(error));
			})


	}

	//FUNCIÓN PARA CAMBIAR EL ESTADO A RECHAZADO.
	estadoRechazado(){
		console.log('Entramos en estadoRechazado');

		this.isLoading = true;
		cambiarEstadoRechazado({lIdCandidatos : this.lIdCandidatosChecked})
			.then(result => {
				console.log('El back devuelve -> ' ,JSON.stringify(result));
				if(result.success == true){
					this.isLoading = false;
					this.mostrarToast('Éxito',result.mensaje,'success');
					this.mostrarCandidatos();
				}else{
					this.isLoading = false;
					this.mostrarToast('Aviso',result.mensaje,'error')
				}
			})
			.catch(error=> {
				this.isLoading = false;
				this.mostrarToast('Error',error.body.message,'error')
				console.log(JSON.stringify(error));
			})
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
}