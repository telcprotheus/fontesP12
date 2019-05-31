#Include 'protheus.ch'
#include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

/*/{Protheus.doc} Oportunidade
Definicao da estrutura do webservice
@author Diogo Barros
@since 11/03/2019
@type class
/*/
User Function API03DB()	
Return

WSRESTFUL OPORTUNIDADE DESCRIPTION "Servico REST para manipulacao de Consulta de OPORTUNIDADE"
	//CodOpor,cRevisa,cDescri,cUser,cVend,cNomVen,cProVen,cStage,cPrior,cStatus
	WSDATA CodOpor	As String	 
	WSDATA cRevisa	As String
	WSDATA cDescri	As String	
	WSDATA cUser	As String
	WSDATA cVend	As String
	WSDATA cNomVen	As String
	WSDATA cProVen	As String
	WSDATA cStage	As String
	WSDATA cPrior	As String
	WSDATA cStatus	As String
						
	WSMETHOD GET DESCRIPTION "Retorna o Oportunidade informado na URL" WSSYNTAX "/OPORTUNIDADE || /OPORTUNIDADE/{CODOPOR}"
	WSMETHOD POST DESCRIPTION "Insere uma nova Oportunidade" WSSYNTAX "/OPORTUNIDADE"
	WSMETHOD PUT DESCRIPTION "Altera uma nova Oportunidade" //WSSYNTAX "/OPORTUNIDADE/{CODOPOR}"
 
END WSRESTFUL


/*/ Metodo retorna uma Oportunidade ou uma lista com todos. /*/
WSMETHOD GET WSRECEIVE CodOpor WSSERVICE OPORTUNIDADE

	Local _cCodOpor  	:= Self:CodOpor
	Local _aArea		:= GetArea()
	Local _oObjOpor		:= Nil
	Local _cStatus		:= ""
	Local _cJson		:= ""
	Local _aInfo		:= {}
	Local _cNomCli		:= ""
	Local _cNomVen		:= ""
	Local _cData		:= ""
	
	// --> Define o tipo de retorno do metodo
	::SetContentType("application/json")
	
	DbSelectArea("AD1")
	AD1->( DbSetOrder(1) )
	
	//QQOut(::aURLParms)	// Mostra msg no appserver
	
	If !Empty(_cCodOpor)
		
		If AD1->( DbSeek( xFilial("AD1") + _cCodOpor ) )
			_cNomCli  := Posicione("SA1", 1, xFilial("SA1") + AD1->AD1_CODCLI + AD1->AD1_LOJCLI, "A1_NREDUZ")
			_cNomVen  := Posicione("SA3", 1, xFilial("SA3") + AD1->AD1_VEND, "A3_NOME")
			_cData	  := Dtos(AD1_DATA)
			_oObjOpor := Oportunidade():ListOne(AD1->AD1_NROPOR, AD1->AD1_REVISA, AD1_DESCRI, _cData, AD1_VEND, _cNomVen, AD1_CODCLI, AD1_LOJCLI, _cNomCli)
		EndIf
				
	Else
		
		dbSelectArea("AD1")
		AD1->( dbSetOrder(1) )
		AD1->( dbGoTop() )
		
		While AD1->( !EOF() )
			_cNomCli  := Posicione("SA1", 1, xFilial("SA1") + AD1->AD1_CODCLI + AD1->AD1_LOJCLI, "A1_NREDUZ")
			_cNomVen  := Posicione("SA3", 1, xFilial("SA3") + AD1->AD1_VEND, "A3_NOME")
			_cData	  := Dtos(AD1_DATA)
			aAdd(_aInfo, {AD1->AD1_NROPOR, AD1->AD1_REVISA, AD1_DESCRI, _cData, AD1_VEND, _cNomVen, AD1_CODCLI, AD1_LOJCLI, _cNomCli})
			AD1->( DbSkip() )
		EndDo
				
		If(Len(_aInfo) > 0)			
			_oObjOpor := Oportunidade():ListAll(_aInfo)			
		EndIf
		
	EndIf
	
	// --> Transforma o objeto em uma string json
	_cJson := FWJsonSerialize(_oObjOpor)
	
	// --> Envia o JSON Gerado para a aplicacao Client
	::SetResponse(_cJson)
	RestArea(_aArea)
	
Return(.T.)


/*/ 
Metodo Para Inserir Uma Nova Oportunidade. 
As propriedades da classe receberão os valores enviados por querystring
Exemplo: http://localhost:8080/OPORTUNIDADE?CodOpor=000001&cRevisa=01&cDescri=Teste
/*/
WSMETHOD POST WSRECEIVE CodOpor,cRevisa,cDescri,cUser,cVend,cProVen,cStage,cPrior,cStatus WSSERVICE OPORTUNIDADE

	Local _lPost 	:= .T.
	Local _cBody	:= ""
	Local _oJson	:= Nil
	Local _cCodOpor	:= Self:CodOpor
	Local _cRevisa	:= Self:cRevisa
	Local _cDescri	:= Self:cDescri
	Local _cUser	:= Self:cUser
	Local _cVend	:= Self:cVend
	Local _cProVen	:= Self:cProVen
	Local _cStage	:= Self:cStage
	Local _cPrior	:= Self:cPrior
	Local _cStatus	:= Self:cStatus
	
	// Recupera o body da requisição
	_cBody := ::GetContent()
	QQOut("Resultado do _cBody")
	QQOut(_cBody)
	
	If !Empty(_cBody)
		
		FWJsonDeserialize(_cBody,@_oJson)
		QQOut("Resultado do _cBody Apos Deserialize")
		
		// Chamada de funcao automatica para Inserir Operação
		_lPost := fFt300DB(3,_CodOpor,_cRevisa,_cDescri,_cUser,_cVend)
		If _lPost
			QQOUT("Oportunidade:" + _CodOpor + " Revisao: " + _cRevisa + " criada com sucesso.")
			::SetResponse('{"N.Oportunidade": ' + _cCodOpor + ', " Revisao": ' + _cRevisa + '," Criada com Sucesso!"}')
		Else
			QQOut("Erro ao incluir Oportunidade: " + _cCodOpor + " Revisao: " + _cRevisa)
			::SetResponse('{"Erro ao incluir Oportunidade": ' + _cCodOpor + ', " Revisao": ' + _cRevisa + '," "}')
		EndIf
	Else
		QQOut("cBody Vazio")
	EndIf
	
Return _lPost
  
/*/ Metodo Para Alterar Uma Oportunidade. /*/
WSMETHOD PUT WSSERVICE OPORTUNIDADE
	
	Local _lPut := .T.
	Local _cBody	:= ""
	  
	// Exemplo de retorno de erro
	QQOut(::aURLParms)
	If Len(::aURLParms) == 0
	   SetRestFault(400, "É necessário informar um ID")
	   _lPut := .F.
	Else
	   // recupera o body da requisição
	   _cBody := ::GetContent()
	   QQOut(_cBody)
	   // insira aqui o código para operação de atualização
	   // exemplo de retorno de um objeto JSON
	   //::SetResponse('{"id":' + ::aURLParms[1] + ', "name":"sample"}')
	EndIf
	
Return _lPut


/*/{Protheus.doc} Oportunidade
Chamada de rotina automatica para Inserir Oportunidade(AD1)
@author Diogo Barros
@since 14/03/2019
@type Static Function
/*/
Static Function fFt300DB(nOper,_CodOpor,_cRevisa,_cDescri,_cUser,_cVend)

	Local _aCabec		:= {}
	Local _lRet			:= .T.
	Local _lTodosSim	:= .F.
	Private lMsErroAuto := .f.
	
	QQOUT("Chamada msexecauto, operacao:")
	QQOUT(nOper)

	dbSelectArea("AD1")
	dbSetOrder(1)
	
	_cNomVen := Posicione("SA3",1,xFilial("SA3")+_cVend,"A3_NREDUZ")
	
	If !dbSeek(xFilial("AD1")+_cCodOpor+_cRevisa) // Monta o array com as informacoes para a gravacao 
		_aCabec := 	{	{ "AD1_FILIAL"  		     , xFilial("AD1")                  	, NIL },;				
						{ "AD1_NROPOR"  		     , _cCodOpor                       	, NIL },;   				
						{ "AD1_REVISA"  		     , _cRevisa	                       	, NIL },;				
						{ "AD1_DESCRI"  		     , _cDescri			            	, NIL },;				
						{ "AD1_DATA  " 			     , DATE()                       	, NIL },;				
						{ "AD1_HORA  " 			     , TIME()                       	, NIL },;				
						{ "AD1_USER  " 			     , _cUser                       	, NIL },;				
						{ "AD1_VEND  " 			     , _cVend                         	, NIL },;				
						{ "AD1_NOMVEN"   			 , _cNomVen	                    	, NIL },; 				
						{ "AD1_DTINI "   			 , DATE()	                    	, NIL },; 				
						{ "AD1_PROVEN"   			 , "01"		                    	, NIL },; 				
						{ "AD1_STAGE "   			 , "01"		                    	, NIL },; 				
						{ "AD1_MOEDA "   			 , 1		                    	, NIL },; 				
						{ "AD1_PRIOR "   			 , "1"		                    	, NIL },; 				
						{ "AD1_STATUS"   			 , "1"		                    	, NIL };
					}
		//Gravacao da oportunidade
		MSExecAuto({|x,y|FATA300(x,y)},nOper,_aCabec)
		If lMsErroAuto
			DisarmTransaction()
			//MostraErro()
			QQOut("Erro MsExecAuto FATA300 cOdOpor: " + _cCodOpor + " Revisao: " + _cRevisa)
			_lRet := .F.
		Else
			_lRet := .T.
		EndIf
		
	Else
		_lRet := .F.
	EndIf 
	
Return _lRet