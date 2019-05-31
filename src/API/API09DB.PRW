#Include 'protheus.ch'
#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

/*/{Protheus.doc} Fluxo de Caixa
Definicao da estrutura do webservice
@author Diogo Barros
@since 30/04/2019
@type class
/*/
User Function API09DB()
Return

WSRESTFUL FLUXOCAIXA DESCRIPTION "Servico REST para Consulta do Fluxo de Caixa"
		
	WSDATA DATADE   As String 
	WSDATA DATAATE  As String 
 
	WSMETHOD GET DESCRIPTION "Retorna o Fluxo de Caixa dentro do periodo informado via parametro";
	WSSYNTAX "/FLUXOCAIXA/{DATADE}/{DATAATE}"

END WSRESTFUL


/*/ Metodo retorna fluxo de caixa conforme periodo. /*/
WSMETHOD GET WSRECEIVE DATADE,DATAATE WSSERVICE FLUXOCAIXA

	Local _cDataDe  	:= Self:DATADE
	Local _cDataAte  	:= Self:DATAATE
	Local _aArea		:= GetArea()
	Local _oObjFLC		:= Nil
	Local _cJson		:= ""
	Local _lRet			:= .F.
	

	// --> Define o tipo de retorno do metodo
	::SetContentType("application/json")		
	
	If Empty(_cDataDe)
		SetRestFault(404, "Preiodo inicial precisa ser informado!")
	ElseIf Empty(_cDataAte)
		SetRestFault(404, "Preiodo final precisa ser informado!")
	Else
		_oObjFLC := FluxoCaixa():ListFluxo(_cDataDe,_cDataAte)
	EndIf
	
	If(_oObjFLC == Nil)
		SetRestFault(404, "Não existe Fluxo de Caixa para periodo ou periodo nao foi informado!")
	Else
		// --> Transforma o objeto em uma string json
		_cJson := FWJsonSerialize(_oObjFLC)
		// --> Envia o JSON Gerado para a aplicacao Client
		::SetResponse(_cJson)
		RestArea(_aArea)
		_lRet := .T.
	EndIf

Return(_lRet)