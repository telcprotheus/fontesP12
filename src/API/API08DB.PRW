#Include 'protheus.ch'
#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

/*/{Protheus.doc} VENDAS Diaria
Definicao da estrutura do webservice
@author Diogo Barros
@since 26/04/2019
@type class
/*/
User Function API08DB()
Return

WSRESTFUL VENDADIARIA DESCRIPTION "Servico REST para Consulta das Vendas Diaria"
		
	WSDATA DATAVEND  As String // --> String que vamos receber via URL
 
	WSMETHOD GET DESCRIPTION "Retorna as vendas conforme Data informada no parametro ou as vendas do dia."; 
	WSSYNTAX "/VENDADIARIA || /VENDADIARIA/{DATAVEND}"

END WSRESTFUL


/*/ Metodo retorna vendas conforme parametro ou vendas do dia. /*/
WSMETHOD GET WSRECEIVE DATAVEND WSSERVICE VENDADIARIA

	Local _cDataVend  	:= Self:DATAVEND
	Local _aArea		:= GetArea()
	Local _oObjVDt		:= Nil
	Local _cJson		:= ""
	Local _lRet			:= .F.
	

	// --> Define o tipo de retorno do metodo
	::SetContentType("application/json")		
	
	// Se codigo do vendedor estiver preenchido 
	// Busca todas as vendas deste vendedor
	If !Empty(_cDataVend)
		_oObjVDt := VendasDia():ListVendPar(_cDataVend)
	Else
		_oObjVDt := VendasDia():ListVendDia()
	EndIf
	
	If(_oObjVDt == Nil)
		SetRestFault(404, "Não existe vendas para data informada!")
	Else
		// --> Transforma o objeto em uma string json
		_cJson := FWJsonSerialize(_oObjVDt)
		// --> Envia o JSON Gerado para a aplicacao Client
		::SetResponse(_cJson)
		RestArea(_aArea)
		_lRet := .T.
	EndIf

Return(_lRet)