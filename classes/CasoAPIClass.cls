@RestResource(urlMapping='/nuevoCaso')
global class CasoAPIClass  {

	@HttpPost
	global static void newCaso(){
		Utilidades.InfoRespuesta respuesta = new Utilidades.InfoRespuesta();
		
		//Rescatamos la solicitud de la integración.
		RestRequest req = RestContext.request;
		String body = req.requestBody.toString();

		//Convertimos a texto el cuerpo de la integración.
		List<WrapperResAPI> lDatosCasos;
		try{
			lDatosCasos = (List<WrapperResAPI>) JSON.deserialize(body, List<WrapperResAPI>.class);
		}catch(Exception exc){
			respuesta.success = false;
			respuesta.mensaje = 'No se ha recibido un JSON en el formato correcto.';
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
			return;
		}

		//Control de errores
		for(WrapperResAPI datoCaso : lDatosCasos){
			if(String.isEmpty(datoCaso.idCliente) || String.isEmpty(datoCaso.motivoCaso)){
				respuesta.success = false;
				respuesta.mensaje = 'Hay campos vacíos que tiene que enviar relleno.';
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
				return;
			}
		}

		Set<String> sIdClientes = new Set<String>();
		Map<String,String> mIdClienteAsunto = new Map<String,String>();
		for(WrapperResAPI datoCaso : lDatosCasos){
			sIdClientes.add(datoCaso.idCliente);
			mIdClienteAsunto.put(datoCaso.idCliente, datoCaso.motivoCaso);
		}

		List<Lead> lLeads = [SELECT Id, Name, ConvertedAccountId, ConvertedContactId, ConvertedAccount.Name, toLabel(Provincia__c), Phone, Email, OwnerId FROM Lead WHERE Id in: sIdClientes];
		
		//Control de errores
		if(lLeads.isEmpty()){
			respuesta.success = false;
			respuesta.mensaje = 'Los ids facilitados no se corresponden con los de la base de datos.';
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
			return;
		}
		
		Set<String> sProvincias = new Set<String>();
		for(Lead l: lLeads){
			if(l.Provincia__c == null){
				respuesta.success = false;
				respuesta.mensaje = 'El campo provincia de los ids facilitados están vacías.';
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
				return;
			}

		}

		List<ConfiguracionGeneral__mdt> lConfig;
		lConfig = !Test.isRunningTest() ? [SELECT id,Sede__c,TiempoLimiteCasos__c FROM ConfiguracionGeneral__mdt WHERE Sede__c in:sProvincias] : new List<ConfiguracionGeneral__mdt> { new ConfiguracionGeneral__mdt ( Sede__c = 'Madrid', TiempoLimiteCasos__c = 24)} ;

		Map<String,Integer> mSedeTiempoLimite = new Map<String,Integer>();

		for(ConfiguracionGeneral__mdt c: lConfig){
			mSedeTiempoLimite.put(c.Sede__c, Integer.valueOf(c.TiempoLimiteCasos__c));
		}

		//Le asignamos el recordType correspondiente.
		List<RecordType> lRT = [Select Id From RecordType Where DeveloperName ='TicketWeb' AND SobjectType = 'Case'];
		List<Case> lCasos = new List<Case>();
				
		for(Lead candidato: lLeads){
			//Por cada lead creamos un caso.
			Case caso = crearCaso(candidato, mIdClienteAsunto, mSedeTiempoLimite);
			caso.RecordTypeId = lRT[0].Id;
			//Si los campos 'AccountId' o 'Subject' están sin rellenar devolveremos un error puesto que son obligatorios.
			System.debug('El id de la cuenta del lead no transformado vale '+caso.AccountId);
			if(String.isBlank(caso.AccountId) || String.isBlank(caso.Subject)){
				respuesta.success = false;
				respuesta.mensaje = 'Faltan campos obligatorios por rellenar';
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
				return;
			}
			lCasos.add(caso);
		}

		//Insertamos los casos nuevos.
		try{
			insert lCasos;
		}catch (Exception exc){
			respuesta.success = false;
			respuesta.mensaje = 'Ha ocurrido el siguiente error '+exc.getMessage();
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
			return;
		}

		//Devolvemos la respuesta de éxito al crear el caso.
		respuesta.success = true;
		respuesta.mensaje = 'Se ha realizado la operación con éxito';
		RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respuesta));
	}

	public static Case crearCaso(Lead candidato, Map<String,String> mIdClienteAsunto, Map<String,Integer> mSedeTiempoLimite){
		Case caso = new Case();
		caso.OwnerId = candidato.OwnerId;
		caso.ContactId = candidato.ConvertedContactId;
		caso.AccountId = candidato.ConvertedAccountId;
		caso.Subject = mIdClienteAsunto.get(candidato.Id);

		//Incluimos la fecha y hora límite para resolver el caso en base a la provincia del cliente.
		Datetime ahora = Datetime.now();
		Integer tiempo = mSedeTiempoLimite.get(candidato.Provincia__c); //null
		caso.TiempoLimite__c = ahora.addHours(tiempo);
		return caso;
	}

	public class WrapperResAPI{
		public String idCliente;
		public String motivoCaso;
	}
}