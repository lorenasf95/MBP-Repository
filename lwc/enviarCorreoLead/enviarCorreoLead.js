import {LightningElement, track, api, wire} from 'lwc';
import initLWC from '@salesforce/apex/EnviarCorreoLeadClass.initLoad';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmailToController from '@salesforce/apex/EnviarCorreoLeadClass.sendEmailToController';

export default class EnviarCorreoLead extends LightningElement {

	@track email;
	@api recordId; 
	@track disabledButtons = true;
	@track asuntoEmail;
	@track cuerpoEmail;
	@track isLoading = false;
	@track listadoIdDocumentos = [];
	@track listadoNameDocumentos = [];
	@track mostrarAdjuntos = false;
	
	connectedCallback() {
		this.rellenarEmail();
    }

	get acceptedFormats() {
        return ['.pdf', '.png', '.jpg','.docx','.xlsx'];
    }

	//FUNCIÓN RELLENAR EMAIL.
	rellenarEmail(){
		initLWC({idCandidato : this.recordId})
			.then(result => {
				console.log('qué devuelve el back :',JSON.stringify(result));
				if(result.success == true){
					this.email = result.mailCandidato;
					this.mostrarAdjuntos = result.hayAdjunto;
				}else{
					mostrarToast('Aviso',result.mensaje,'warning')
				}
			})
			.catch(error=> {
				console.log(JSON.stringify(error));
			})
	}

	//FUNCIÓN HABILITAR BOTONES
	habilitarBotones(){
		console.log('##Entramos a habilitar botones');
		//Rescatamos el valor del asunto.
		this.asuntoEmail = this.template.querySelector('.asunto').value;
		console.log('##el valor de asunto email es ', this.asuntoEmail);

		//Rescatamos el valor del cuerpo.
		this.cuerpoEmail = this.template.querySelector('.cuerpo').value;
		console.log('##el valor de cuerpo email es ', this.cuerpoEmail);

		//Si el cuerpo y el valor están rellenos habilitamos los botones.
		if(this.asuntoEmail && this.asuntoEmail.trim().length > 0 && this.cuerpoEmail && this.cuerpoEmail.trim().length > 0 ){
			this.disabledButtons = false;
		}else{
			this.disabledButtons = true;
		}
	}

	//FUNCIÓN PARA BORRAR EL CONTENIDO COMPLETO DEL EMAIL.
	borrarContenidoEmail(){
		console.log('##Entramos en borrar contenido');
		this.template.querySelector('.asunto').value = '';
		this.template.querySelector('.cuerpo').value = '';
	}

	//FUNCIÓN PARA ENVIAR EL EMAIL.
    sendEmailAfterEvent(){
		this.isLoading = true;
		console.log('##Entro primero');
        sendEmailToController({body: this.cuerpoEmail, toSend: this.email, subject: this.asuntoEmail, lIdDocumentos : this.listadoIdDocumentos})
        .then((response) => {
			this.isLoading = false;
			console.log('##La respuesta del back es ',JSON.stringify(response));
            if(response.success == true){
				this.mostrarToast('Éxito',response.mensaje,'success');
				console.log('##Entro por el true');
				//eval("$A.get('e.force:refreshView').fire();");
				location.reload();
			}else{
				console.log('Entramos por el else');
				this.mostrarToast('Error',response.mensaje,'error');
				console.log('salimos del else');
				location.reload();
			}
        })
		.catch(error => {
            console.log(JSON.stringify(error));
			location.reload();
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

	handleUploadFinished(event){
		event.detail.files.forEach((item)=>{
			console.log('item',JSON.stringify(item));
			this.listadoIdDocumentos.push(item.contentVersionId);
			this.listadoNameDocumentos.push(item.name);
		})

		console.log(' lista ' , this.listadoIdDocumentos);
	}
}