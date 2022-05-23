import {LightningElement, api, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import initLWC from '@salesforce/apex/EncuestaSatisfaccionGenerica.initLWCMetadata';


export default class EncuestaLeadMDT extends LightningElement {
	@track selectPoints = 0;
	@track promedio = 0;
	@track agradecimiento = false;
	@api recordId; 

	//Encuesta 1
	@track encuesta1= 0;
	@track boton1Disabled = true;


	////////////////////////////
	@track listaPreguntas = [];
	@track cabecera = '';
	@track stepProgreso = [];
	@track currentStep = '1';
	@track pregunta;
	@track mStepPreguntas;
	@track puntuacionByStep = [];


	  /***************/
	 /*  FUNCIONES  */
	/***************/

	connectedCallback() {
		this.metodoInicial();
    }

	//FUNCIÓN RELLENAR EMAIL.
	metodoInicial(){
		console.log('recordId --> ',this.recordId);
		initLWC({recordId : this.recordId})
			.then(result => {
				console.log('### que devuevle el back',JSON.stringify(result));
				if(result.success){
					this.cabecera = result.cabecera;
					this.listaPreguntas = result.lPreguntas;
					this.stepProgreso = result.lProgreso;
					this.mStepPreguntas = result.mPasoPregunta;
					this.mostrarPregunta();
				}
			})
			.catch(error=> {
				console.log(JSON.stringify(error));
			})
	}



	//FUNCION PARA MOSTRAR LA PREGUNTA DEL PASO ACTUAL
	mostrarPregunta(event){
		console.log('mapa -> ' , this.mStepPreguntas);
		console.log('en que paso estamos -> ' , this.currentStep);
		this.pregunta = this.mStepPreguntas[this.currentStep];
		
		console.log('this.pregunta', this.pregunta);


	}


	 //FUNCIÓN PARA ALMACENAR EL VALOR ELEGIDO EN CADA ENCUESTA.
	almacenarPuntuacion(event){
		console.log(this.recordId);
		//Almacenamos el valor de la última puntuación seleccionada.
		this.selectPoints = event.currentTarget.dataset.valor;

		//Preguntamos en que paso estamos.
		this.boton1Disabled = false

		//Recogemos todos los elementos con el fondo cambiado y los eliminamos para que no haya duplicados.
		let divContenedor = this.template.querySelector(".step");
		if(divContenedor){
			console.log('### hijos --> ' + JSON.stringify(divContenedor.children));
			Array.from(divContenedor.children).forEach((elem) => elem.classList.remove('cambiarFondo'));
		}

		//Una vez seleccionada una puntuación cambiamos su color para remarcar que está seleccionada.
		let puntoSeleccionado = event.currentTarget;
		puntoSeleccionado.classList.add("cambiarFondo");
	}

	//FUNCIÓN PARA MOSTRAR LA PRIMERA PESTAÑA
	nextButton(){
		//Preguntamos en que paso estamos.
		this.boton1Disabled = true;
		
		//Almacenamos la puntuación en un array bidemensional ['1',3]
		let array = [this.currentStep,this.selectPoints];

		this.puntuacionByStep.push(array);

		//Pasamos al siguiente elemento.
		this.currentStep =  String(parseInt(this.currentStep)+1);

		//Cambiamos la pregunta.
		this.mostrarPregunta();

		console.log(this.puntuacionByStep);

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
		console.log('### promedio', this.promedio);
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