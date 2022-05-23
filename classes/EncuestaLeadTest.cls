@IsTest
public class EncuestaLeadTest  {

	@TestSetup
	public static void cargaInicial(){
		TestSetupClass.cargaInicial();
	}

	@IsTest
	public static void verificarEncuestas(){
		
		List<Lead> lLeads = [SELECT Id FROM Lead LIMIT 1];

		EncuestaLead.gradoSatisfaccion(null, null);
		EncuestaLead.gradoSatisfaccion(3, lLeads[0].Id);
	}
}