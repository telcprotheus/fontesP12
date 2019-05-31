#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL INVENTARIO DESCRIPTION "Recebe os dados coletados no inventario"
	WSMETHOD POST DESCRIPTION "Recebe os dados coletados no inventario" WSSYNTAX "/Inventario/"
END WSRESTFUL

WSMETHOD POST WSSERVICE INVENTARIO
	Local lRet       := .T.
	Local cBody
	Local oParseJSON := Nil
	Local aVetor     := {}
	Local aLog
	Local nI
	Private lMsErroAuto    := .F.   
	
	::SetContentType("application/json")
	
	cBody := ::GetContent()
	
	FWJsonDeserialize(cBody, @oParseJSON)
	
	aVetor := {;
    	{"B7_FILIAL" , PADR(oParseJSON:Filial,   TAMSX3("B7_FILIAL")[1]),   Nil},;
        {"B7_COD",     PADR(oParseJSON:Produto,  TAMSX3("B7_COD")[1]),      Nil},;
        {"B7_NUMSERI", PADR(oParseJSON:Serie,    TAMSX3("B7_NUMSERI")[1]),  Nil},;
        {"B7_LOTCTL",  PADR(oParseJSON:Lote,     TAMSX3("B7_LOTCTL")[1]),   Nil},;
		{"B7_LOCALIZ", PADR(oParseJSON:endereco, TAMSX3("B7_LOCALIZ")[1]),  Nil},;
		{"B7_DATA",    Date(),                                              Nil},;
		{"B7_QUANT",   val(oParseJSON:Qtd),  		   					    Nil},;
        {"B7_QTSEGUM", val(oParseJSON:Qtd2), 		   					    Nil},;
		{"B7_TIPO",    PADR(oParseJSON:Tipo, 	 TAMSX3("B7_TIPO")[1]),     Nil},;
		{"B7_NUMLOTE", PADR(oParseJSON:SubLote,  TAMSX3("B7_NUMLOTE")[1]),  Nil},;
		{"B7_OK", 	   PADR(oParseJSON:Marca,    TAMSX3("B7_OK")[1]),  		Nil},;
		{"B7_ESCOLHA", PADR(oParseJSON:Escolha,  TAMSX3("B7_ESCOLHA")[1]),  Nil},;
		{"B7_CODUNI",  PADR(oParseJSON:CodUni,   TAMSX3("B7_CODUNI")[1]),   Nil},;
        {"B7_IDUNI",   PADR(oParseJSON:IdUni,  	 TAMSX3("B7_IDUNI")[1]),  	Nil} }
	
	MSExecAuto({|x,y,z| mata270(x,y,z)},aVetor,.T.,3)
	
	If lMsErroAuto
		aLog := GetAutoGRLog()
		For nI := 1 To Len(aLog)
			//cErro += (aLog[nI] + CRLF)
			conout(aLog[nI])
		Next nI
    	lRet := .F.
    	
    	SetRestFault(500, "Erro ao processar requisição")
	Else
    	::SetResponse('{"success":"true"}')
	EndIf
	
Return(lRet)