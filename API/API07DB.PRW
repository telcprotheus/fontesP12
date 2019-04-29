#Include 'protheus.ch'
#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

/*/{Protheus.doc} VENDAS
Definicao da estrutura do webservice
@author Diogo Barros
@since 29/04/2019
@type class
/*/
User Function API07DB()
Return

WSRESTFUL VENDASPAG DESCRIPTION "Servico REST para Consulta das Vendas por Condicao de Pagamento"
		
	WSDATA CODPAG  As String // --> String que vamos receber via URL
 
	WSMETHOD GET DESCRIPTION "Retorna as vendas conforme condicao de pagamento informado no parametro."; 
	WSSYNTAX "/VENDASPAG/{CODPAG}" 

END WSRESTFUL


/*/ Metodo retorna todas as vendas conforme condicao de pagamento. /*/
WSMETHOD GET WSRECEIVE CODPAG WSSERVICE VENDASPAG

	Local _cCodPag  	:= Self:CODPAG
	Local _aArea		:= GetArea()
	Local _oObjCPag		:= Nil
	//Local _cStatus		:= ""
	Local _cJson		:= ""
	//Local _aInfo		:= {}
	Local _lRet			:= .F.
	

	// --> Define o tipo de retorno do metodo
	::SetContentType("application/json")		
	
	If !Empty(_cCodPag)
		_oObjCPag := VendCondPag():ListCondPag(_cCodPag)
	Else
		SetRestFault(404,"E necessario informar condicao de pagamento!")				
	EndIf
	
	If(_oObjCPag == Nil)
		SetRestFault(404, "As vendas nesta condicao de pagamento nao foram encontradas!")
	Else
		// --> Transforma o objeto em uma string json
		_cJson := FWJsonSerialize(_oObjCPag)
		// --> Envia o JSON Gerado para a aplicacao Client
		::SetResponse(_cJson)
		RestArea(_aArea)
		_lRet := .T.
	EndIf

Return(_lRet)