@RestResource(urlMapping='/confirmacionCandidato')
global class confirmacionCandidatoAPIClass  {

	@HttpPost
	global static void doPost(){
		WrRespuesta respuesta = new WrRespuesta();
		
		//Rescatamos la solicitud de la integración.
		RestRequest req = RestContext.request;
		String body = req.requestBody.toString();

		//Convertimos a texto el cuerpo de la integración.
		WrDatosAPI datosConfirmarLead;
		try{	        
			datosConfirmarLead = (WrDatosAPI) JSON.deserialize(body, WrDatosAPI.class);
		}
		catch (Exception exc){
			respuesta.mensaje = 'Error al deserializar el JSON de entrada';
			respuesta.success = false;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
			return;
		}

		respuesta = confirmarCandidato(datosConfirmarLead);
		RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
	}

	public static WrRespuesta confirmarCandidato(WrDatosAPI datosLeadAPI){
		WrRespuesta respuesta = new WrRespuesta();
		
		List<Lead> lCandidatos = [SELECT Id,Name,Status,Motivo_Rechazo__c,numDocumento__c FROM Lead WHERE numDocumento__c=:datosLeadAPI.numDocumento LIMIT 1];
		System.debug('### lCandidatos --> ' + JSON.serialize(lCandidatos));
		if(lCandidatos.isEmpty()){return new WrRespuesta(false,'No tiene relleno el número de documento');}

		Lead candidato = lCandidatos[0];

		//Si el Lead ha sido aceptado lo movemos al estado aceptado.
		if(datosLeadAPI.aceptacion){
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(candidato.id);
			lc.setConvertedStatus('Aceptado');
			try{Database.LeadConvertResult lcr = Database.convertLead(lc);}catch(Exception exc){return new WrRespuesta(false,'Ha ocurrido un error al convertir el Lead : ' + exc.getMessage());}

			respuesta.success = true;
			respuesta.mensaje = 'Ha sido aprobada y convertida en cuenta con éxito';
		}
		//Si el Lead ha sido rechazado lo movemos al estado rechazado.
		else{
			candidato.Status ='Rechazado';
			candidato.Motivo_Rechazo__c = datosLeadAPI.motivoRechazo;
			respuesta.success = true;
			respuesta.mensaje = 'Ha sido rechazada con éxito';
		}


		try{update candidato;}catch(Exception exc){ return new WrRespuesta(false,'Ha surgido el siguiente error '+exc.getMessage());}

		return respuesta;
	}


	public class WrDatosAPI{
		public String numDocumento;
		public String motivoRechazo;
		public Boolean aceptacion; 
	}

	public class WrRespuesta {
		Boolean success;
		String mensaje;

		public WrRespuesta(){}

		public WrRespuesta(Boolean exito, String motivo){
			this.success = exito;
			this.mensaje = motivo;
		}
	}
}