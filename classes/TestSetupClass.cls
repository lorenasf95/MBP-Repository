public class TestSetupClass  {

	public static void cargaInicial(){

		//Creo candidatos
		List<Lead> lLeads = new List<Lead>();
		
		Lead candidato1 = new Lead();
		candidato1.FirstName = 'Paco';
		candidato1.LastName = 'Pérez';
		candidato1.Company = 'ClienteWeb';
		candidato1.Status = 'Abierto';
		candidato1.Provincia__c = '28';
		candidato1.Email = 'asdqwfqwfefv@mbp.com';
		candidato1.numDocumento__c = '05154596G';
		lLeads.add(candidato1);

		Lead candidato2 = new Lead();
		candidato2.FirstName = 'Marta';
		candidato2.LastName = 'García';
		candidato2.Company = 'ClienteWeb';
		candidato2.Status = 'Rechazado';
		candidato2.Provincia__c = '41';
		candidato2.Email = 'rrwetergewfefv@mbp.com';
		candidato2.numDocumento__c = '05154596L';
		lLeads.add(candidato2);

		Lead candidato3 = new Lead();
		candidato3.FirstName = 'Pedro';
		candidato3.LastName = 'Martínez';
		candidato3.Company = 'ClienteWeb';
		candidato3.Status = 'Contactado';
		candidato3.Provincia__c = '48';
		candidato3.Email = 'hhhhjiojihjhfwhi@mbp.com';
		candidato3.numDocumento__c = '05154596Y';
		lLeads.add(candidato3);

		Lead candidato4 = new Lead();
		candidato4.FirstName = 'Pedro';
		candidato4.LastName = 'Martínez';
		candidato4.Company = 'ClienteWeb';
		candidato4.Status = 'Aceptado';
		candidato4.Email = 'qwijerwqijerwqqqqq@mbp.com';
		candidato4.numDocumento__c = '05154596S';
		lLeads.add(candidato4);

		Lead candidato5= new Lead();
		candidato5.FirstName = 'Clara';
		candidato5.LastName = 'Pérez';
		candidato5.Company = 'ClienteWeb';
		candidato5.Status = 'Abierto';
		candidato5.numDocumento__c = '05154596L';
		lLeads.add(candidato5);

		Lead candidato6 = new Lead();
		candidato6.FirstName = 'Roberto';
		candidato6.LastName = 'Pérez';
		candidato6.Company = 'ClienteWeb';
		candidato6.Status = 'Abierto';
		candidato6.numDocumento__c = '05154596R';
		lLeads.add(candidato6);

		Lead candidato7 = new Lead();
		candidato7.FirstName = 'Sandra';
		candidato7.LastName = 'Pérez';
		candidato7.Company = 'ClienteWeb';
		candidato7.Status = 'Abierto';
		candidato7.numDocumento__c = '05154596M';
		lLeads.add(candidato7);

		Lead candidato8 = new Lead();
		candidato8.FirstName = 'Blanca';
		candidato8.LastName = 'Pérez';
		candidato8.Company = 'ClienteWeb';
		candidato8.Status = 'Abierto';
		candidato8.numDocumento__c = '05155596P';
		lLeads.add(candidato8);

		Lead candidato9 = new Lead();
		candidato9.FirstName = 'Laura';
		candidato9.LastName = 'Pérez';
		candidato9.Company = 'ClienteWeb';
		candidato9.Status = 'Abierto';
		candidato9.numDocumento__c = '05154596T';
		lLeads.add(candidato9);

		Lead candidato10 = new Lead();
		candidato10.FirstName = 'Guillermo';
		candidato10.LastName = 'Pérez';
		candidato10.Company = 'ClienteWeb';
		candidato10.Status = 'Abierto';
		candidato10.numDocumento__c = '05154596F';
		lLeads.add(candidato10);

		Lead candidato11 = new Lead();
		candidato11.FirstName = 'Lucas';
		candidato11.LastName = 'Pérez';
		candidato11.Company = 'ClienteWeb';
		candidato11.Status = 'Aceptado';
		candidato11.Provincia__c = '28';
		candidato11.Email = 'asqwfefv@mbp.com';
		candidato11.numDocumento__c = '05199996G';
		lLeads.add(candidato11);

		Lead candidato12 = new Lead();
		candidato12.FirstName = 'Joaquin';
		candidato12.LastName = 'Reyes';
		candidato12.Company = 'ClienteWeb';
		candidato12.Status = 'Aceptado';
		candidato12.Provincia__c = '28';
		candidato12.Email = 'jreyes@mbp.com';
		candidato12.numDocumento__c = '13245678L';
		lLeads.add(candidato12);

		insert lLeads;

		

		//Creo cuentas



		//Creo xxx






	}
	


}