public class reasignarClienteQAClass  {
	
	//MÉTODO PARA RELLENAR EL DESPLEGABLE
	@AuraEnabled
	public static WrInit initMethodLWC(String leadId){
		
		//Inicializamos la respuesta.
		WrInit respuesta = new WrInit();

		//Rellenamos el desplegable.
		List<WrDesplegable> lDespleLabelValue = new List<WrDesplegable>();
		List<Lead> lCandidatos = [SELECT id, OwnerId, RecordTypeId, recordtype.DeveloperName FROM Lead WHERE Id=: leadId LIMIT 1];

		if(lCandidatos.isEmpty()){
			respuesta.success = false;
			respuesta.mensaje = 'Se ha producido un error';
			return respuesta;
		}

		Lead candidato = lCandidatos[0];

		List<User> lUsers = new List<User>();

		//Si el tipo de registro del candidato es empresa sacaremos los usuarios comercial de venta y administrador del sistema.
		if(candidato.RecordTypeId == Utilidades.obtenerIdRecordId('Lead','Empresa')){
			lUsers = [SELECT Id, Name, Profile.name FROM User WHERE Profile.name = 'Comercial de ventas' OR Profile.name = 'Administrador del sistema'];
		}
		//Si es persona, sacaremos todos los usuarios.
		else if(candidato.RecordTypeId == Utilidades.obtenerIdRecordId('Lead','Persona_Fisica') || String.isBlank(candidato.RecordTypeId)){
			lUsers = [SELECT Id, Name, Profile.name FROM User WHERE Profile.name != null];
		}

		for(User usuario:lUsers){
			WrDesplegable rellenarDesple = new WrDesplegable();
			rellenarDesple.label = usuario.Name;
			rellenarDesple.value = usuario.Id;
			lDespleLabelValue.add(rellenarDesple);			
		}

		respuesta.success = true;
		respuesta.lUsers = lDespleLabelValue;
		return respuesta;
	}

	//MÉTODO PARA ACTUALIZAR EL NUEVO PROPIETARIO
	@AuraEnabled
	public static WrRespuesta actualizarPropietario(String leadId, String userId){
		WrRespuesta respuesta = new WrRespuesta();
		
		List<Lead> lCandidatos = [SELECT id, OwnerId FROM Lead WHERE id =: leadId LIMIT 1];
		
		if(lCandidatos.isEmpty()){
			respuesta.success = false;
			respuesta.mensaje = 'Ha surgido un error';
			return respuesta;
		}
		
		Lead candidato = lCandidatos[0];
		candidato.OwnerId = userId;

		try{
			update candidato;
			respuesta.success = true;
			respuesta.mensaje = 'Se ha guardado correctamente';
		}catch(Exception exc){
			respuesta.success = false;
			respuesta.mensaje = 'Ha surgido el siguiente error '+exc.getMessage();
		}
		
		return respuesta;
	}

	
	public class WrDesplegable{
		@AuraEnabled public String label;
		@AuraEnabled public String value;
	}

	public class WrInit{
		@AuraEnabled public List<WrDesplegable> lUsers;
		@AuraEnabled public Boolean success;
		@AuraEnabled public String mensaje;
	}

	public class WrRespuesta{
		@AuraEnabled public Boolean success;
		@AuraEnabled public String mensaje;
	}
}