@RestResource(urlMapping='/nuevoCandidato')
global class LeadAPIClass  {
	
	@HttpPost
	global static void newLead(){
		WrRespuesta respuesta = new WrRespuesta();
		
		//Rescatamos la solicitud de la integración.
		RestRequest req = RestContext.request;
		String body = req.requestBody.toString();

		//Convertimos a texto el cuerpo de la integración.
		WrDatosLead datosLead = (WrDatosLead) JSON.deserialize(body, WrDatosLead.class);

		//Si cualquier campo (excepto teléfono) están vacíos devolvemos un error y no creamos el candidato.
		if(String.isBlank(datosLead.nombre) || String.isBlank(datosLead.apellidos) || String.isBlank(datosLead.email) || String.isBlank(datosLead.provincia) || String.isBlank(datosLead.origen)){
			respuesta.success = false;
			respuesta.mensaje = 'Faltan campos por rellenar, por lo que no se ha podido crear el candidato';
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
			return;
		}

		//Creamos el candidato.
		Lead candidato = new lead();
		candidato.FirstName = datosLead.nombre;
		candidato.LastName = datosLead.apellidos;
		candidato.Phone = datosLead.telefono;
		candidato.Email = datosLead.email;
		candidato.provincia__c = datosLead.provincia;
		candidato.LeadSource = datosLead.origen;
		candidato.Company = datosLead.nombre + ' ' + datosLead.apellidos;
		candidato.numDocumento__c = datosLead.numDocumento;

		//Le asignamos el recordType correspondiente.
		if(datosLead.esEmpresa){
			List<RecordType> lRT = [Select Id From RecordType Where DeveloperName ='Empresa' AND SobjectType = 'Lead'];
			candidato.RecordTypeId = lRT[0].Id;
		}else{
			List<RecordType> lRT = [Select Id From RecordType Where DeveloperName ='Persona_Fisica' AND SobjectType = 'Lead'];
			candidato.RecordTypeId = lRT[0].Id;
		}

		//Insertamos el candidato creado.
		try{
			insert candidato;
		}catch (Exception exc){
			respuesta.success = false;
			respuesta.mensaje = 'Ha ocurrido el siguiente error '+exc.getMessage();
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
			return;
		}

		//Devolvemos la respuesta de éxito al crear al candidato.
		respuesta.success = true;
		respuesta.mensaje = 'Se ha creado el candidato con éxito';
		RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
	}



	public class WrDatosLead{
		public String nombre; //Name
		public String apellidos; //Name
		public String telefono; //phone
		public String email; //email
		public String provincia; //provincia__c
		public String origen; //LeadSource
		public String numDocumento; //numDocumento__c
		public Boolean esEmpresa;
	}

	public class WrRespuesta {
		public Boolean success;
		public String mensaje;
	}

}