public with sharing class DSALES_CrearParticipantesPoliza {
    public static final String NOMBRE_CONTRATANTE =DSALES_Utility.getNombreContratante('dsalesNombre');
    public static void crearConductor(String idClienteConductor,String idPoliza){
        InsurancePolicyParticipant nuevoParticipante = new InsurancePolicyParticipant();
        nuevoParticipante.InsurancePolicyId=idPoliza;
        nuevoParticipante.PrimaryParticipantAccountId=idClienteConductor;
        nuevoParticipante.Role=DSALES_Utility.FIGURA_CONDUCTOR;

        if(Schema.sObjectType.InsurancePolicyParticipant.isCreateable()) {
            insert nuevoParticipante;
        }else{
            System.debug('Permisos insuficientes para insertar');
        }
    }
    public static  String busquedaCuentaConductor(DatosConductor conductor,Decimal numeroCliente){
        String idCuenta='';
        if(numeroCliente!=null){
            Account cuenta = [SELECT Id,Name FROM Account WHERE CP_WalletCustomerNumber__c  =:numeroCliente WITH SECURITY_ENFORCED LIMIT 1];
            if(cuenta!=null){
                idCuenta=cuenta.Id;
            }
        }
        else{
            Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName =:conductor.nombre  AND LastName =:conductor.apellidoPaterno AND Suffix =: conductor.apellidoMaterno AND PersonEmail=:conductor.correo WITH SECURITY_ENFORCED LIMIT 1];
            if(cuenta!=null){
                idCuenta=cuenta.Id;
            }
        }
        
        return idCuenta;
    }
    public static void crearParticipantes(List<DSALES_VentaSM.DatosParticipante> participantes, String idPoliza,Boolean enviaContratante){
        List<InsurancePolicyParticipant> listaParticipantes = new List<InsurancePolicyParticipant>();
        Insurancepolicy poliza =[SELECT Id,NameInsuredId FROM Insurancepolicy WHERE Id=:idPoliza WITH SECURITY_ENFORCED LIMIT 1];
        Set<Decimal> listaNumCliente =new  Set<Decimal>();
        Set<String> datosCliente = new Set<String>();
        Set<String> datosClienteApellido = new Set<String>();
        Set<String> correosConAsignacion = new Set<String>();
        DatosConductor conductor = new DatosConductor();
        Decimal valueNumero;
        List<DSALES_VentaSM.DatosParticipante> listaOtrosParticipantes = new List<DSALES_VentaSM.DatosParticipante>();
        for(DSALES_VentaSM.DatosParticipante item: participantes){
            if(item.figura==DSALES_Utility.FIGURA_CONDUCTOR){
                crearConductor(poliza.NameInsuredId,idPoliza);
               /* if(!String.isEmpty(item.numeroCliente)){
                    valueNumero=Decimal.valueOf(item.numeroCliente);
                }
                else{
                   
                    conductor.nombre= item.nombre;
                    conductor.apellidoPaterno=item.apellidoPaterno;
                    conductor.apellidoMaterno=item.apellidoMaterno;
                    conductor.correo=item.correoElectronico;  
                }*/
            }
            else{
                if(enviaContratante=true && item.figura==DSALES_Utility.FIGURA_CONTRATANTE ){
                    listaOtrosParticipantes.add(item);
                }
                else if(item.figura!=DSALES_Utility.FIGURA_CONTRATANTE){
                         listaOtrosParticipantes.add(item);   
                }
            } 
        }
        if(enviaContratante==false){
            crearContratante(idPoliza);
        }
        //String idClienteConductor= busquedaCuentaConductor(conductor, valueNumero);
       // crearConductor(idClienteConductor,idPoliza);
        crearOtrosParticipantes(listaOtrosParticipantes,idPoliza);
        
        
        
    }
    public static void crearOtrosParticipantes(List<DSALES_VentaSM.DatosParticipante> participantes,String idPoliza){
        List<InsurancePolicyParticipant> listaParticipantes = new List<InsurancePolicyParticipant>();
        if(participantes!=null){
           for(DSALES_VentaSM.DatosParticipante item:participantes){
                InsurancePolicyParticipant participante= new InsurancePolicyParticipant();
                participante.InsurancePolicyId=idPoliza;
                participante.dsalesNombre__c=item.nombre;
                participante.dsalesPrimerApellido__c=item.apellidoPaterno;
                participante.dsalesSegundoApellido__c=item.apellidoMaterno;
                participante.Role=item.figura;
                participante.dsalesNumeroTelefono__c=item.telefono;
                participante.dsalesCorreoElectronico__c=item.correoElectronico;
                participante.dsalesGenero__c=item.genero;
                participante.dsalesFechaNacimiento__c=item.fechaNacimiento;
                participante.dsalesRfc__c=item.rfc;
                participante.dsalesCodigoPostal__c=item.codigoPostal;
                participante.dsalesClaveEstado__c=item.codigoEstado;
                participante.dsalesCalle__c=item.calle;
                participante.dsalesNumeroExterior__c=item.numeroExterior;
                participante.RelationshipToInsured=item.relacionConParticipante;
                participante.BeneficiarySharePercentage=Decimal.valueOf(item.porcentaje);
                listaParticipantes.add(participante);
            }
            if(Schema.sObjectType.InsurancePolicyParticipant.isCreateable()) {
                insert listaParticipantes;
            }else{
                System.debug('Permisos insuficientes para insertar');
            }
            
        }

    }
    public static void crearContratante(String idPoliza){
        Account contratante =[SELECT Id FROM Account WHERE FirstName=:NOMBRE_CONTRATANTE WITH SECURITY_ENFORCED LIMIT 1];
        InsurancePolicyParticipant participante = new InsurancePolicyParticipant(
            InsurancePolicyId=idPoliza,
            RelatedParticipantAccountId=contratante.Id,
            Role=DSALES_Utility.FIGURA_CONTRATANTE
        );
        if(Schema.sObjectType.InsurancePolicyParticipant.isCreateable()) {
            insert participante;
        }else{
            System.debug('Permisos insuficientes para insertar');
        }  
    }
    public  class DatosConductor{
        public String nombre{get;set;}
        public String apellidoPaterno {get;set;}
        public String apellidoMaterno {get;set;}
        public String correo{get;set;}
    }

}