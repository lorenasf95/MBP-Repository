@IsTest
public class CasoAPIClassTest  {
	
	@TestSetup
	public static void init(){
		TestSetupClass.cargaInicial();
	}

	@IsTest
	public static void testCasoAPI(){
		//Buscamos un cliente y rellenamos el motivo de rechazo.
		List<Lead> lLeads = [SELECT Id FROM Lead WHERE numDocumento__c = '05199996G' LIMIT 1];
		List<Lead> lLeadsSinProvincia = [SELECT Id FROM Lead WHERE Provincia__c = null LIMIT 1];
		List<Lead> lLeadFallo = [SELECT Id FROM Lead WHERE numDocumento__c = '05154596G' LIMIT 1];

	
		GestionCandidatosClass.transformarLead(new List<String> {lLeads[0].Id});
		
		Test.startTest();
			//Instanciamos una respuesta de la API.
			RestResponse res = new RestResponse();

			//Instanciamos la petición y rellenamos los datos necesarios.
			RestRequest req = new RestRequest();
			req.requestURI = '/nuevoCaso';  //URL de la petición.
			req.httpMethod = 'POST';//HTTP tipo

			List<CasoAPIClass.WrapperResAPI> lDatosAPI = new List<CasoAPIClass.WrapperResAPI>();
			CasoAPIClass.WrapperResAPI datosAPI = new CasoAPIClass.WrapperResAPI();
			datosAPI.idCliente = lLeads[0].Id;
			

			//Llamada con un JSON malo.
			req.requestBody = Blob.valueof(JSON.serialize(datosAPI));//body
			RestContext.request = req;
			RestContext.response = res;
			CasoAPIClass.newCaso();
			
			// Llamada con un JSON válido con motivoCaso vacío.. 
			lDatosAPI.add(datosAPI);
			String jsonEnvio = JSON.serialize(lDatosAPI);
			req.requestBody = Blob.valueof(jsonEnvio);//body
			RestContext.request = req;
			RestContext.response = res;
			CasoAPIClass.newCaso();

			//Llamada con Lead sin transformar para que el IdAccount esté vacío y cubra el control de errores.
			lDatosAPI = new List<CasoAPIClass.WrapperResAPI>();
			datosAPI.idCliente = lLeadFallo[0].Id;
			datosAPI.motivoCaso = 'prueba';
			lDatosAPI.add(datosAPI);
			jsonEnvio = JSON.serialize(lDatosAPI);
			req.requestBody = Blob.valueof(jsonEnvio);//body
			RestContext.request = req;
			RestContext.response = res;
			CasoAPIClass.newCaso();

			// Llamada con un JSON válido con id no válido..
			lDatosAPI = new List<CasoAPIClass.WrapperResAPI>();
			datosAPI.idCliente = 'IDNOVALIDO';
			datosAPI.motivoCaso='No desea recibir información';
			lDatosAPI.add(datosAPI);
			jsonEnvio = JSON.serialize(lDatosAPI);
			req.requestBody = Blob.valueof(jsonEnvio);//body
			RestContext.request = req;
			RestContext.response = res;
			CasoAPIClass.newCaso();

			//Llamada con JSON válido y provincia vacía.
			lDatosAPI = new List<CasoAPIClass.WrapperResAPI>();
			datosAPI.motivoCaso='No desea recibir información';
			datosAPI.idCliente = lLeadsSinProvincia[0].Id;
			lDatosAPI.add(datosAPI);
			jsonEnvio = JSON.serialize(lDatosAPI);
			req.requestBody = Blob.valueof(jsonEnvio);//body
			RestContext.request = req;
			RestContext.response = res;
			CasoAPIClass.newCaso();

			// Llamada con un JSON válido.
			lDatosAPI = new List<CasoAPIClass.WrapperResAPI>();
			datosAPI.motivoCaso='No desea recibir información';
			datosAPI.idCliente = lLeads[0].Id;
			lDatosAPI.add(datosAPI);
			jsonEnvio = JSON.serialize(lDatosAPI);
			req.requestBody = Blob.valueof(jsonEnvio);//body
			RestContext.request = req;
			RestContext.response = res;
			CasoAPIClass.newCaso();

		Test.stopTest();

	}
}