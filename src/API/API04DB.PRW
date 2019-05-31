#Include 'protheus.ch'
#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

/*/{Protheus.doc} VENDAS
Definicao da estrutura do webservice
@author Diogo Barros
@since 24/04/2019
@type class
/*/
User Function API04DB()
Return

WSRESTFUL VENDAS DESCRIPTION "Servico REST para Consulta das Vendas [Total || Por Vendedor]"
		
	WSDATA CODVEND  As String // --> String que vamos receber via URL
 
	WSMETHOD GET DESCRIPTION "Retorna as vendas conforme parametro informado na URL, caso informe o codigo do vendedor busca apenas as vendas do mesmo."; 
	WSSYNTAX "/VENDAS || /VENDAS/{CODVEND}" 

END WSRESTFUL


/*/ Metodo retorna todas as vendas ou todas as vendas por vendedor. /*/
WSMETHOD GET WSRECEIVE CODVEND WSSERVICE VENDAS

	Local _cCodVend  	:= Self:CODVEND
	Local _aArea		:= GetArea()
	Local _oObjVend		:= Nil
	//Local _cStatus		:= ""
	Local _cJson		:= ""
	//Local _aInfo		:= {}
	Local _lRet			:= .F.
	

	// --> Define o tipo de retorno do metodo
	::SetContentType("application/json")		
	
	// Se codigo do vendedor estiver preenchido 
	// Busca todas as vendas deste vendedor
	If !Empty(_cCodVend)
		_oObjVend := Vendas():ListOne(_cCodVend)				
	Else
		_oObjVend := Vendas():ListAll()			
	EndIf
	qqout(_oObjVend)
	If(_oObjVend == Nil)
		SetRestFault(404, "Código do Vendedor ou Lista de Vendas não Encontrado!")
	Else
		// --> Transforma o objeto em uma string json
		_cJson := FWJsonSerialize(_oObjVend)
		// --> Envia o JSON Gerado para a aplicacao Client
		::SetResponse(_cJson)
		RestArea(_aArea)
		_lRet := .T.
	EndIf

Return(_lRet)