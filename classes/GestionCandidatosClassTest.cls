@IsTest
public class GestionCandidatosClassTest  {
	@TestSetup
	public static void init(){
		TestSetupClass.cargaInicial();
	}
	@IsTest
	public static void testGestionCandidatos(){
		//Buscamos varios Leads.
		List<Lead> lLeads = [SELECT id, Status FROM Lead WHERE Status='Abierto' LIMIT 2];

		//Creación de listas de ids para cubrir código.
		List<String> lIdCandidatos = new List<String>();
		List<String> lIdCandidatos2 = new List<String>();
		for(Lead l: lLeads){
			lIdCandidatos.add(l.Id);
		}

		for(Lead l: lLeads){
			if(l.Status == 'Abierto'){
				lIdCandidatos2.add(l.Id);
			}
		}

		//Cambiamos el estado de los lead para cubrir código.
		List<Lead> lLeadsToProcess = [SELECT id,Status FROM Lead WHERE Status='Abierto' LIMIT 2];

		for(Lead can:lLeadsToProcess){
			can.Status = 'Contactado';
		}
		
		update lLeadsToProcess;

		List<Lead> lLeadsToProcess2 = [SELECT id,Status FROM Lead WHERE Status='Abierto' LIMIT 2];
		for(Lead can:lLeadsToProcess2){
			can.Status = 'Aceptado';
		}
		update lLeadsToProcess2;

		List<Lead> lLeadsToProcess3 = [SELECT id,Status FROM Lead WHERE Status='Abierto' LIMIT 2];
		for(Lead can:lLeadsToProcess3){
			can.Status = 'Rechazado';
		}
		update lLeadsToProcess3;

		//Lista vacía para cubrir control de errores.
		List<String> lIdVacia = new List<String>();

		Test.startTest();
			GestionCandidatosClass.datosLeads();
			GestionCandidatosClass.estadoRechazado(lIdCandidatos);
			GestionCandidatosClass.estadoRechazado(lIdVacia);
			GestionCandidatosClass.transformarLead(lIdCandidatos2);
			GestionCandidatosClass.transformarLead(lIdVacia);
		Test.stopTest();

	}


}