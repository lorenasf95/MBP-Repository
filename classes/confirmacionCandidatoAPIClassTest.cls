@IsTest
public class confirmacionCandidatoAPIClassTest  {

	@TestSetup
	public static void init(){
		TestSetupClass.cargaInicial();
	}

	@IsTest
	public static void testConfirmacionCandidatoAPI(){
		//Buscamos un cliente y rellenamos el motivo de rechazo.
		List<Lead> lLeads = [SELECT Id,Name,Status,Motivo_Rechazo__c,numDocumento__c FROM Lead WHERE numDocumento__c != null LIMIT 1];
		
		Test.startTest();
			//Instanciamos una respuesta de la API.
			RestResponse res = new RestResponse();

			//Instanciamos la petición y rellenamos los datos necesarios.
			RestRequest req = new RestRequest();
			req.requestURI = '/confirmacionCandidato';  //URL de la petición.
			req.httpMethod = 'POST';//HTTP tipo

			

			//Llamada con un JSON malo.
			confirmacionCandidatoAPIClass.WrDatosAPI datosAPIMalo = new confirmacionCandidatoAPIClass.WrDatosAPI();
			List<Lead> lLeadsVacio = new List<Lead>();
			datosAPIMalo.numDocumento = lLeads[0].numDocumento__c;
			datosAPIMalo.motivoRechazo = 'Ha solicitado dejar de ser cliente';
			datosAPIMalo.aceptacion = false;
			String jsonEnvio = JSON.serialize(datosAPIMalo);
			req.requestBody = Blob.valueof(JSON.serialize(lLeadsVacio));//body
			RestContext.request = req;
			RestContext.response = res;
			System.debug('## Llamada con lista vacía');
			confirmacionCandidatoAPIClass.doPost();

			//Llamada con un JSON válido con numDocumento vacío..
			confirmacionCandidatoAPIClass.WrDatosAPI datosAPINumVacio = new confirmacionCandidatoAPIClass.WrDatosAPI();
			datosAPINumVacio.numDocumento = null;
			datosAPINumVacio.motivoRechazo = '';
			datosAPINumVacio.aceptacion = true;
			String jsonEnvio1 = JSON.serialize(datosAPINumVacio);
			req.requestBody = Blob.valueof(jsonEnvio1);//body
			RestContext.request = req;
			RestContext.response = res;
			System.debug('## Llamada con numDOc null');
			confirmacionCandidatoAPIClass.doPost();

			// Llamada con un JSON válido con aceptación rechazada.
			confirmacionCandidatoAPIClass.WrDatosAPI datosAPINumVacioRechazado = new confirmacionCandidatoAPIClass.WrDatosAPI();
			datosAPINumVacioRechazado.numDocumento = lLeads[0].numDocumento__c;
			datosAPINumVacioRechazado.motivoRechazo = 'Prueba rechazado';
			datosAPINumVacioRechazado.aceptacion = false;
			String jsonEnvio2 = JSON.serialize(datosAPINumVacioRechazado);
			req.requestBody = Blob.valueof(jsonEnvio2);//body
			RestContext.request = req;
			RestContext.response = res;
			System.debug('## Llamada con motivo rechazo y aceptación false');
			confirmacionCandidatoAPIClass.doPost();

			// Llamada con un JSON válido y aceptación válida.
			confirmacionCandidatoAPIClass.WrDatosAPI datosAPI = new confirmacionCandidatoAPIClass.WrDatosAPI();
			datosAPI.numDocumento = lLeads[0].numDocumento__c;
			datosAPI.motivoRechazo = null;
			datosAPI.aceptacion = true;
			String jsonEnvio3 = JSON.serialize(datosAPI);
			req.requestBody = Blob.valueof(jsonEnvio3);//body
			RestContext.request = req;
			RestContext.response = res;
			System.debug('## Llamada con aceptación válida');
			confirmacionCandidatoAPIClass.doPost();

		Test.stopTest();

	}
}