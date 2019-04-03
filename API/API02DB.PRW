#Include 'protheus.ch'
#include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

/*/{Protheus.doc} Cliente
Definicao da estrutura do webservice para as seguintes APIs:
	* Cliente
	* Prospect
	* Suspect
@author Diogo Barros
@since 09/03/2019
@type class
/*/
User Function API02DB()	
Return

WSRESTFUL CLIENTE DESCRIPTION "Servico REST para manipulacao de Consulta de Clientes"
		
	WSDATA CODCLI  As String // --> String que vamos receber via URL
 
	WSMETHOD GET DESCRIPTION "Retorna o Cliente informado na URL"; 
	WSSYNTAX "/CLIENTE || /CLIENTE/{CODCLI}" //Disponibilizamos um metodo do tipo GET
		
END WSRESTFUL


WSRESTFUL PROSPECT DESCRIPTION "Servico REST para manipulacao de Consulta de Clientes Prospect"
		
	WSDATA CODPROSP  As String // --> String que vamos receber via URL
 
	WSMETHOD GET DESCRIPTION "Retorna o Prospect informado na URL"; 
	WSSYNTAX "/PROSPECT || /PROSPECT/{CODPROSP}" //Disponibilizamos um metodo do tipo GET
		
END WSRESTFUL


WSRESTFUL SUSPECT DESCRIPTION "Servico REST para manipulacao de Consulta de Clientes Suspect"
		
	WSDATA CODSUSP  As String // --> String que vamos receber via URL
 
	WSMETHOD GET DESCRIPTION "Retorna o Suspect informado na URL"; 
	WSSYNTAX "/SUSPECT || /SUSPECT/{CODSUSP}" //Disponibilizamos um metodo do tipo GET
		
END WSRESTFUL	
	
 

/*/{Protheus.doc} Cliente
Metodo para listar um ou todos os clientes	
@author Diogo Barros
@since 09/03/2019
@type method
/*/
WSMETHOD GET WSRECEIVE CODCLI WSSERVICE CLIENTE

	Local _cCodCli  	:= Self:CODCLI
	Local _aArea		:= GetArea()
	Local _oObjCli		:= Nil	
	Local _cJson		:= ""
	Local _aInfo		:= {}
	
	// --> Define o tipo de retorno do metodo
	::SetContentType("application/json")
	
	DbSelectArea("SA1")
	SA1->( DbSetOrder(1) )
	
	//QQOut(::aURLParms)	// Mostra msg no appserver
	
	If !Empty(_cCodCli)
		
		If SA1->( DbSeek( xFilial("SA1") + _cCodCli ) )		
			_oObjCli := Cliente():ListOne(SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NREDUZ,SA1->A1_BAIRRO, SA1->A1_TEL)
		EndIf
				
	Else
		
		dbSelectArea("SA1")
		SA1->( dbSetOrder(1) )
		SA1->( dbGoTop() )
		
		While SA1->( !EOF() )
			aAdd(_aInfo, {SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NREDUZ,SA1->A1_BAIRRO, SA1->A1_TEL})
			SA1->( DbSkip() )
		EndDo
				
		If(Len(_aInfo) > 0)			
			_oObjCli := Cliente():ListAll(_aInfo)
		EndIf
		
	EndIf
	
	// --> Transforma o objeto em uma string json
	_cJson := FWJsonSerialize(_oObjCli)
	
	// --> Envia o JSON Gerado para a aplicacao Client
	::SetResponse(_cJson)
	RestArea(_aArea)
	
Return(.T.)


/*/{Protheus.doc} Cliente
Metodo para listar um ou todos os Prospect	
@author Diogo Barros
@since 09/03/2019
@type method
/*/
WSMETHOD GET WSRECEIVE CODPROSP WSSERVICE PROSPECT

	Local _cCodPrp  	:= Self:CODPROSP
	Local _aArea		:= GetArea()
	Local _oObjPrp		:= Nil	
	Local _cJson		:= ""
	Local _aInfo		:= {}
	
	// --> Define o tipo de retorno do metodo
	::SetContentType("application/json")
	
	DbSelectArea("SUS")
	SUS->( DbSetOrder(1) )
	
	//QQOut(::aURLParms)	// Mostra msg no appserver
	
	If !Empty(_cCodPrp)
		
		If SUS->( DbSeek( xFilial("SUS") + _cCodPrp ) )		
			_oObjPrp := Cliente():ListOne(SUS->US_COD, SUS->US_LOJA, SUS->US_NREDUZ, SUS->US_BAIRRO, SUS->US_TEL)
		EndIf
				
	Else
		
		dbSelectArea("SUS")
		SUS->( dbSetOrder(1) )
		SUS->( dbGoTop() )
		
		While SUS->( !EOF() )
			aAdd(_aInfo, {SUS->US_COD, SUS->US_LOJA, SUS->US_NREDUZ, SUS->US_BAIRRO, SUS->US_TEL})
			SUS->( DbSkip() )
		EndDo
				
		If(Len(_aInfo) > 0)			
			_oObjPrp := Cliente():ListAll(_aInfo)
		EndIf
		
	EndIf
	
	// --> Transforma o objeto em uma string json
	_cJson := FWJsonSerialize(_oObjPrp)
	
	// --> Envia o JSON Gerado para a aplicacao Client
	::SetResponse(_cJson)
	RestArea(_aArea)
	
Return(.T.)


/*/{Protheus.doc} Cliente
Metodo para listar um ou todos os Suspect	
@author Diogo Barros
@since 09/03/2019
@type method
/*/
WSMETHOD GET WSRECEIVE CODSUSP WSSERVICE SUSPECT

	Local _cCodSus  	:= Self:CODSUSP
	Local _aArea		:= GetArea()
	Local _oObjSus		:= Nil	
	Local _cJson		:= ""
	Local _aInfo		:= {}
	
	// --> Define o tipo de retorno do metodo
	::SetContentType("application/json")
	
	DbSelectArea("ACH")
	ACH->( DbSetOrder(1) )
	
	//QQOut(::aURLParms)	// Mostra msg no appserver
	
	If !Empty(_cCodSus)
		
		If ACH->( DbSeek( xFilial("ACH") + _cCodSus ) )		
			_oObjSus := Cliente():ListOne(ACH->ACH_CODIGO, ACH->ACH_LOJA, ACH->ACH_NFANT,ACH->ACH_BAIRRO, ACH->ACH_TEL)
		EndIf
				
	Else
		
		dbSelectArea("ACH")
		ACH->( dbSetOrder(1) )
		ACH->( dbGoTop() )
		
		While ACH->( !EOF() )
			aAdd(_aInfo, {ACH->ACH_CODIGO, ACH->ACH_LOJA, ACH->ACH_NFANT,ACH->ACH_BAIRRO, ACH->ACH_TEL})
			ACH->( DbSkip() )
		EndDo
				
		If(Len(_aInfo) > 0)			
			_oObjSus := Cliente():ListAll(_aInfo)
		EndIf
		
	EndIf
	
	// --> Transforma o objeto em uma string json
	_cJson := FWJsonSerialize(_oObjSus)
	
	// --> Envia o JSON Gerado para a aplicacao Client
	::SetResponse(_cJson)
	RestArea(_aArea)
	
Return(.T.)