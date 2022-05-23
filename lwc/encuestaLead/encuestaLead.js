import {LightningElement, api, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import encuestaGradoSatisfaccion from '@salesforce/apex/EncuestaLead.gradoSatisfaccion';

export default class EncuestaLead extends LightningElement {
	@track selectPoints = 0;
	@track promedio = 0;
	@track agradecimiento = false;
	@track progreso = '1';
	@api recordId; 

	//Encuesta 1
	@track showEncuesta1 = true;
	@track encuesta1= 0;
	@track boton1Disabled = true;

	//Encuesta 2
	@track showEncuesta2 = false;
	@track encuesta2 = 0;
	@track boton2Disabled = true;

	//Encuesta 3
	@track showEncuesta3 = false;
	@track encuesta3 = 0;
	@track botonFinDisabled = true;


	  /***************/
	 /*  FUNCIONES  */
	/***************/

	 //FUNCIÓN PARA ALMACENAR EL VALOR ELEGIDO EN CADA ENCUESTA.
	almacenarPuntuacion(event){
		console.log(this.recordId);
		//Almacenamos el valor de la última puntuación seleccionada.
		this.selectPoints = event.currentTarget.dataset.valor;

		//Preguntamos en que paso estamos.
		if(this.showEncuesta1 == true){ this.boton1Disabled = false } 
		else if(this.showEncuesta2 == true){ this.boton2Disabled = false }
		else if(this.showEncuesta3 == true){ this.botonFinDisabled = false }

		//Recogemos todos los elementos con el fondo cambiado y los eliminamos para que no haya duplicados.
		let divContenedor = this.template.querySelector(".step");
		if(divContenedor){
			console.log('### hijos --> ' + JSON.stringify(divContenedor.children));
			Array.from(divContenedor.children).forEach((elem) => elem.classList.remove('cambiarFondo'));
		}

		//let listadoElementos = this.template.querySelectorAll(".cambiarFondo");
		//Array.from(listadoElementos).forEach((elem) => elem.classList.remove('cambiarFondo'));

		console.log('Valor clickado', this.selectPoints);

		//Una vez seleccionada una puntuación cambiamos su color para remarcar que está seleccionada.
		let puntoSeleccionado = event.currentTarget;
		puntoSeleccionado.classList.add("cambiarFondo");
	}

	//FUNCIÓN PARA MOSTRAR LA PRIMERA PESTAÑA
	primeraPestana(){
		this.progreso= "1";
		this.showEncuesta1 = true;
		this.showEncuesta2 = false;
		this.showEncuesta3 = false;
		this.agradecimiento = false;
		console.log('encuesta 1 --> ',this.encuesta1);
		/*let valorEncuesta1 = this.encuesta1;
		let target = this.template.querySelector(`[data-valor="${valorEncuesta1}"]`);*/
	}

	//FUNCIÓN PARA MOSTRAR LA SEGUNDA PESTAÑA
	segundaPestana(){
		this.encuesta1 = parseInt(this.selectPoints);
		this.showEncuesta1 = false;
		this.showEncuesta2 = true;
		this.showEncuesta3 = false;
		this.agradecimiento = false;
		this.progreso= "2";

	}

	//FUNCIÓN PARA MOSTRAR LA TERCERA PESTAÑA
	terceraPestana(){
		this.encuesta2 = parseInt(this.selectPoints);
		this.showEncuesta1 = false;
		this.showEncuesta2 = false;
		this.showEncuesta3 = true;
		this.agradecimiento = false;
		this.progreso= "3";
	}

	//FUNCIÓN PARA MOSTRAR EL RESULTADO Y ALMACENAR EL PROMEDIO DE LA ENCUESTA 
	finalizarEncuesta(){
		this.encuesta3 = parseInt(this.selectPoints);
		this.showEncuesta1 = false;
		this.showEncuesta2 = false;
		this.showEncuesta3 = false;
		this.agradecimiento = true;

		//Calculamos el promedio y lo almacenamos en el campo grado de satisfacción.
		let numPromedio = (this.encuesta1 + this.encuesta2 + this.encuesta3) / 3;
		this.promedio = Math.round((numPromedio + Number.EPSILON) * 100) / 100; //Number((this.encuesta1 + this.encuesta2 + this.encuesta3) / 3).toFixed(2);
		console.log('### promedio   ', this.promedio);
		this.enviarEncuesta();
	}

	//FUNCIÓN PARA GUARDAR EL PROMEDIO EN EL CAMPO GRADO DE SATISFACCIÓN
	enviarEncuesta(){
		console.log('Entramos en enviarEncuesta');
		encuestaGradoSatisfaccion ({promedio: this.promedio, idCandidato: this.recordId})
			.then(result => {
				console.log('##El back devuelve: ', JSON.stringify(result));
				if(result.success == true){
					this.mostrarToast('Exito',result.mensaje,'success');
				}else if(result.success == false){
					console.log('entra aqui 2');
					this.mostrarToast('Error',result.mensaje,'error');
				}
			})
			.catch(error=> {
				console.log('errooor');
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