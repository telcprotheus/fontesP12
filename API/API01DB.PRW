#Include 'protheus.ch'
#include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

/*/{Protheus.doc} FUNCIONARIO
Definicao da estrutura do webservice
@author Diogo Barros
@since 18/02/2019
@type class
/*/
User Function API01DB()	
Return

WSRESTFUL FUNCIONARIO DESCRIPTION "Servico REST para manipulacao de Consulta de Funcionario"
		
	WSDATA CODFUNC  As String // --> String que vamos receber via URL
 
	WSMETHOD GET DESCRIPTION "Retorna o funcionario informado na URL"; 
	WSSYNTAX "/FUNCIONARIO || /FUNCIONARIO/{CODFUNC}" //Disponibilizamos um metodo do tipo GET
 
END WSRESTFUL


/*/ Metodo retorna um funcionario ou uma lista com todos. /*/

WSMETHOD GET WSRECEIVE CODFUNC WSSERVICE FUNCIONARIO

	Local _cCodFunc  	:= Self:CODFUNC
	Local _aArea		:= GetArea()
	Local _oObjFunc		:= Nil
	Local _cStatus		:= ""
	Local _cJson		:= ""
	Local _aInfo		:= {}
	
	// --> Define o tipo de retorno do metodo
	::SetContentType("application/json")
	
	DbSelectArea("SRA")
	SRA->( DbSetOrder(1) )
	
	//QQOut(::aURLParms)	// Mostra msg no appserver
	
	If !Empty(_cCodFunc)
		
		If SRA->( DbSeek( xFilial("SRA") + _cCodFunc ) )		
			_oObjFunc := Funcionario():ListOne(SRA->RA_MAT, SRA->RA_NOME)
		EndIf
				
	Else
		
		dbSelectArea("SRA")
		SRA->( dbSetOrder(1) )
		SRA->( dbGoTop() )
		
		While SRA->( !EOF() )
			aAdd(_aInfo, {SRA->RA_MAT, SRA->RA_NOME})
			SRA->( DbSkip() )
		EndDo
				
		If(Len(_aInfo) > 0)			
			_oObjFunc := Funcionario():ListAll(_aInfo)			
		EndIf
		
	EndIf
	
	// --> Transforma o objeto em uma string json
	_cJson := FWJsonSerialize(_oObjFunc)
	
	// --> Envia o JSON Gerado para a aplicacao Client
	::SetResponse(_cJson)
	RestArea(_aArea)
	
Return(.T.)