public class OpportunityTriggerClass  {

	public static void crearFactura (List<Opportunity> lNew, List<Opportunity> lOld){
		List<Opportunity> lOportunidadesToProcess = new List<Opportunity>();

		//Añadimos a la lista para procesar las oportunidades cuyo estado hayan pasado a 'Closed Won'.
		for(integer i=0; i<lNew.size();i++){
			if(lNew[i].StageName != lOld[i].StageName && lNew[i].StageName == 'Closed Won'){
				lOportunidadesToProcess.add(lNew[i]);
			}
		}

		if(lOportunidadesToProcess.isEmpty()){return;}

		//Creamos un set de id de oportunidad para filtrar la query de lineauctos de oportunidad. 
		Set<String> sIdOpportunity = new set<String>();
		for(Opportunity opor:lOportunidadesToProcess){
			sIdOpportunity.add(opor.Id);
		}

		if(sIdOpportunity.isEmpty()){return;}

		//Buscamos los lineauctos que estén incluidos en el set de oportunidad.
		List<OpportunityLineItem> llineauctos = [SELECT Id,OpportunityId,Quantity,UnitPrice,TotalPrice,Product2.Name FROM OpportunityLineItem WHERE OpportunityId in: sIdOpportunity];

		if(llineauctos.isEmpty()){return;}

		//Creamos un mapa con la id de oportunidad y su listado de lineauctos
		Map<String,List<OpportunityLineItem>> mIdOportunidadListalineauctos = new Map<String,List<OpportunityLineItem>>();
		List<OpportunityLineItem>llineauctosPorOportunidad;
		for(OpportunityLineItem lineaucto: llineauctos){
			//Si el mapa contiene la id de oportunidad cogemos el listado de lineauctos asociado.
			if(mIdOportunidadListalineauctos.containsKey(lineaucto.OpportunityId)){
				llineauctosPorOportunidad = mIdOportunidadListalineauctos.get(lineaucto.OpportunityId);
			}
			//Si no, creamos una nueva lista.
			else{
				llineauctosPorOportunidad = new List<OpportunityLineItem>();
			}
			//Agregamos el lineaucto a la lista y lo metemos en el mapa.
			llineauctosPorOportunidad.add(lineaucto);
			mIdOportunidadListalineauctos.put(lineaucto.OpportunityId,llineauctosPorOportunidad);
		}

		//Por cada oportunidad cerrada se crea una factura.
		List<Factura__c> lFacturas = new List<Factura__c>();
		Map<String,Factura__c> mIdOportunidadFactura = new Map<String,Factura__c>();

		for(Opportunity op:lOportunidadesToProcess){
			//Creamos la factura.
			Factura__c factura = new Factura__c();
			factura.Cuenta__c = op.AccountId;
			factura.Estado__c = 'Pendiente';
			factura.ImporteTotal__c = 0;

			for(OpportunityLineItem linea : mIdOportunidadListalineauctos.get(op.Id)){
				//Incluimos en la factura el total de importe.
				factura.ImporteTotal__c += linea.TotalPrice == null ?  0 : linea.TotalPrice;
			}
			//Agregamos a la lista de facturas la factura.
			lFacturas.add(factura);

			//Creamos un mapa que tenga la relación de oportunidad con la factura.
			mIdOportunidadFactura.put(op.Id,factura);
		}

		//Insertamos la lista de facturas.
		try{
			insert lFacturas;
		}catch(Exception exc){
			System.debug('Ha ocurrido el siguiente error al insertar las facturas '+exc.getMessage());
		}

		//Volvemos a iterar el listado de oportunidades para procesar puesto que ya tenemos el id de la factura.
		List<LineaFactura__c> lLineasFactura = new List<LineaFactura__c>();
		for(Opportunity op:lOportunidadesToProcess){
			if(mIdOportunidadFactura.containsKey(op.Id)){
				//Creamos una línea de factura por cada producto de oportunidad.
				for(OpportunityLineItem linea : mIdOportunidadListalineauctos.get(op.Id)){
					LineaFactura__c lineaFact = new LineaFactura__c();
					lineaFact.Name = linea.Product2.Name +' '+linea.TotalPrice;
					lineaFact.Factura__c = mIdOportunidadFactura.get(op.id).Id;
					lineaFact.Cantidad__c = linea.Quantity;
					lineaFact.ImporteUnitario__c = linea.UnitPrice;
					lineaFact.ImporteTotal__c = linea.TotalPrice;

					//Agregamos la línea de lineaucto a la lista de líneas de facturas.
					lLineasFactura.add(lineaFact);
				}
			}
		}

		//Insertamos la lista de líneas de facturas.
		try{
			insert lLineasFactura;
		}catch(Exception exc){
			System.debug('Ha ocurrido el siguiente error al insertar las líneas de facturas '+exc.getMessage());
		}
	}

}