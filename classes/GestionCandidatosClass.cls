public class GestionCandidatosClass{
	
	//FUNCIÓN INICIAL PARA RELLENAR LOS DATOS DE CADA CANDIDATO.
	@AuraEnabled
	public static WrapperRespuesta datosLeads(){
		//Sacamos los datos de los leads que estén asignados al id del usuario.
		WrapperRespuesta respuesta = new WrapperRespuesta();
		
		List<Lead> lCandidatos = [SELECT id,FirstName,LastName,Status,CreatedDate FROM Lead WHERE OwnerId =: UserInfo.getUserId()];
		
		if(lCandidatos.isEmpty()){return new WrapperRespuesta(false,'No se han encontrado candidatos asociado al usuario logeado');}
		
		respuesta.success = true;
		respuesta.mensaje = 'Se encontraron los datos de los candidatos con éxito';
		respuesta.lDatosLeads = rellenarListado(lCandidatos);
		return respuesta;
	}

	//FUNCIÓN RELLENAR LISTADO.
	public static List<WrapperDatosLead> rellenarListado(List<Lead> lCandidatos){
		List<WrapperDatosLead> lDatosCandidatos = new List<WrapperDatosLead>();
		//Por cada candidato asignamos los datos y lo añadimos a la lista.
		for(Lead candidato : lCandidatos){
			//Rellenamos los datos del candidato.
			WrapperDatosLead datosCandidato = new WrapperDatosLead();
			datosCandidato.id = candidato.Id;
			datosCandidato.nombre = candidato.FirstName;
			datosCandidato.apellidos = candidato.LastName;
			datosCandidato.fechaCreacion =candidato.CreatedDate.format('dd/MM/yyyy');
			datosCandidato.estado = candidato.Status;
			
			//Llamamos a la función para que modifique la clase del footer en función de su estado.
			asignarClaseCSS(datosCandidato);

			lDatosCandidatos.add(datosCandidato);
		}
		return lDatosCandidatos;
	}

	//FUNCIÓN QUE AÑADE UNA CLASE AL FOOTER PARA ASIGNARLE UN COLOR DEPENDIENDO DE SU ESTADO.
	public static void asignarClaseCSS (WrapperDatosLead candidato){
		candidato.claseFooter = 'slds-modal__footer slds-p-bottom_large ';
		if(candidato.estado == 'Rechazado'){
			candidato.claseFooter += ' rechazado';
		}else if(candidato.estado == 'Aceptado'){
			candidato.claseFooter += ' aceptado';
		}else if(candidato.estado == 'Contactado'){
			candidato.claseFooter += ' contactado';
		}else if(candidato.estado == 'Abierto'){
			candidato.claseFooter += ' abierto';
		}

	}

	//FUNCIÓN PARA MODIFICAR EL ESTADO DEL CANDIDATO A RECHAZADO.
	@AuraEnabled
	public static WrapperRespuesta estadoRechazado(List<String> lIdCandidatos){
		WrapperRespuesta respuesta = new WrapperRespuesta();
		List<Lead> lLeads = [SELECT id FROM Lead WHERE id in: lIdCandidatos];

		if(lLeads.isEmpty()){
			respuesta.success = false;
			respuesta.mensaje = 'Ha ocurrido un error, no se ha encontrado ningún candidato';
			return respuesta;
		}
		
		for(Lead Candidato: lLeads){
			Candidato.Status = 'Rechazado';
		}

		try{update lLeads; return new WrapperRespuesta(true,'Se ha cambiado el estado a rechazado con éxito');}catch(Exception exc){return new WrapperRespuesta(false,'Ha ocurrido el siguiente error al actualizar el estado '+exc.getMessage());}

	}

	@AuraEnabled
	public static WrapperRespuesta transformarLead(List<String> lIdCandidatos){
		WrapperRespuesta respuesta = new WrapperRespuesta();

		Savepoint sp = Database.setSavepoint();

		List<Lead> lLeads = [SELECT id FROM Lead WHERE id in: lIdCandidatos];
		if(lLeads.isEmpty()){
			respuesta.success = false;
			respuesta.mensaje = 'Ha ocurrido un error, no se ha encontrado ningún candidato';
			return respuesta;
		}

		List<Database.LeadConvert>lLeadsToProcess = new List<Database.LeadConvert>();
		for(Lead candidato: lLeads){
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(candidato.id);
			lc.setConvertedStatus('Aceptado');
			lLeadsToProcess.add(lc);
		}

		List<Database.LeadConvertResult> lCR;
		try{lCR = Database.convertLead(lLeadsToProcess);}catch(Exception exc){return new WrapperRespuesta(false,'Ha ocurrido un error al convertir el Lead : ' + exc.getMessage());}

		WrapperRespuesta respuestaTareas = asignarTarea(lCR);

		if(respuestaTareas.success){
			respuesta.success = true;
			respuesta.mensaje = 'Se ha transformado y asignado la tarea con éxito';
		}else{
			respuesta.success = false;
			respuesta.mensaje = 'No se ha transformado ni asignado la tarea';
			Database.rollback(sp);
		}
		
		return respuesta;
	}

	public static WrapperRespuesta asignarTarea(List<Database.LeadConvertResult> lresulCR){
		WrapperRespuesta respuesta = new WrapperRespuesta();

		List<Task> lTareas = new List<Task>();
		
		for(Database.LeadConvertResult leadConverted : lresulCR){
			if(leadConverted.isSuccess()){
				Task tarea = new Task();
				tarea.Subject = 'Llamada de primer contacto';
				tarea.WhoId = leadConverted.getContactId();
				tarea.WhatId = leadConverted.getOpportunityId();
				lTareas.add(tarea);
			}else{return new WrapperRespuesta(false,'Ha habido un error a la hora de realizar la conversión');}

		}
		try{
			insert lTareas;
			respuesta.success = true;
			respuesta.mensaje = 'Se ha creado una nueva tarea con éxito';
		}catch(Exception exc){
			respuesta.success = false;
			respuesta.mensaje = 'Ha ocurrido el siguiente error al crear la tarea '+exc.getMessage();
		}
		return respuesta;
	}

	public class WrapperDatosLead{
		@AuraEnabled public String id;
		@AuraEnabled public String nombre;
		@AuraEnabled public String apellidos;
		@AuraEnabled public String fechaCreacion;
		@AuraEnabled public String estado;
		@AuraEnabled public String url;
		@AuraEnabled public String claseFooter;
	}

	public class WrapperRespuesta{
		@AuraEnabled public Boolean success;
		@AuraEnabled public String mensaje;
		@AuraEnabled public List<WrapperDatosLead> lDatosLeads;

		public WrapperRespuesta(){}

		public WrapperRespuesta(Boolean exito, String motivo){
			this.success = exito;
			this.mensaje = motivo;
		}
	}

}