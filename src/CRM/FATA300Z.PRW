#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'Ap5Mail.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} FATA300Z
//Ponto de Entrada MVC para FATA300Z
@author Diogo C. Barros
@since 03/04/2019
@version Protheus 12
@description Buscar os pontos de entrada da Oportunidade para chamada de envio email
@obs #CRM
@type user function
@param
@see
@return
/*/
User Function FATA300

	Local _aParam     	:= PARAMIXB
	Local _lRet       	:= .T.	
	Local _oObj       	:= ''
	Local _cIdPonto   	:= ''
	Local _cIdModel   	:= ''
	Local _cAssunto		:= ''
	Local _cMailTo		:= ''
	Local _cMailCc		:= ''
	Local _nOperation  	:= 0
	Local _cMsg			:= ''
	Local _cAnotac		:= ''
	Local _cMailVen		:= ''	// Email Vendedor
	Local _cMailSVen	:= ''	// Email Supervisor Vendedor
	Local _cMailPre		:= ''	// Email Pre-Vendedor
	Local _cMailSPre	:= ''	// Email Supervisor Pre-Vendedor

	Local _lEnvVen		:= SuperGetMv("MV_F300VEN",,.T.)	// Envia Email Vendedor
	Local _lEnvSVen		:= SuperGetMv("MV_F300SVE",,.T.)	// Envia Email Supervisor Vendedor
	Local _lEnvPre		:= SuperGetMv("MV_F300PRE",,.T.)	// Envia Email Pre Venda
	Local _lEnvSPre		:= SuperGetMv("MV_F300SPV",,.T.)	// Envia Email Supervisor Pre Venda
	Local _cMailDir		:= SuperGetMv("MV_F300DIR",,"")		// Envia Email Diretoria
	
	Static _lRetOp
	
	If _aParam <> NIL

		_oObj       := _aParam[1]
		_cIdPonto   := _aParam[2]
		_cIdModel   := _aParam[3]

		If  _cIdPonto == 'MODELPOS'

			_nOperation := _oObj:nOperation

			//Busca Email conforme parametros
			Do Case
				Case _lEnvVen
				_cMailVen := UsrRetMail(_oObj:GetModel("AD1MASTER"):GetValue("AD1_VEND"))
				If !Empty(_cMailVen)
					_cMailCc := _cMailVen
				EndIf

				Case _lEnvSVen
				_cMailSVen := UsrRetMail(Posicione("SA3",1,xFilial("AD1") + AD1->AD1_VEND , "SA3_SUPER"))
				If !Empty(_cMailSVen)
					_cMailCc += ";" + _cMailSVen
				EndIf

				Case _lEnvPre
				_cMailPre := UsrRetMail(_oObj:GetModel("AD1MASTER"):GetValue("AD1_XPREVE"))
				If !Empty(_cMailPre)
					_cMailCc += ";" + _cMailPre
				EndIf

				Case _lEnvSPre
				_cMailSPre := UsrRetMail(Posicione("SA3",1,xFilial("AD1") + AD1->AD1_XPREVE , "SA3_SUPER"))
				If !Empty(_cMailSPre)
					_cMailCc += ";" + _cMailSPre
				EndIf

				Case !Empty(_cMailDir)
				_cMailCc += ";" + _cMailDir
			EndCase

			If _nOperation = MODEL_OPERATION_INSERT
				
				_cAssunto 	:= "Nova Oportunidade Cadastrada"
				Processa({|| fEnvMail(_cAssunto,_cMailCc, _oObj)}, "Aguarde...","Processando o envio do E-mail",.T.)

			ElseIf _nOperation = MODEL_OPERATION_UPDATE
				
				_cAssunto := "Alteração do Status da Oportunidade No.: "
				
				// Verifica se há alteração de estagio
				//_lRetOp := fAltEstOP(_oObj)
				_lRetOp := _oObj:GetModel("AD1MASTER"):IsFieldUpdated("AD1_STAGE")

				// Busca ultima Anotação
				_cAnotac := fBuscAOB(_oObj)

				If _lRetOp
					Processa({|| fEnvMail(_cAssunto,_cMailCc, _oObj, _cAnotac)}, "Aguarde...","Processando o envio do E-mail",.T.)
				EndIf

			EndIf
				
		EndIf

	EndIf

Return _lRet

/*/
{Protheus.doc} FATA300Z
Ponto de Entrada MVC para FATA300Z
@author Diogo C. Barros
@since 03/04/2019
@description Envia Email Oportunidade
@obs #CRM
/*/
Static Function fEnvMail(_cAssunto,_cMailCc, _oObj, _cAnotac)

	Local _cInf 	:= ""
	Local _cMsg		:= _cAssunto
	Local oObj		:= _oObj
	Local xRet
	Local oServer, oMessage
	Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.F.)
	Local nPorta 	:= 2323 //465

	Private cMailServer	:= "192.168.1.16" //"mail.telc.com.br"
	Private cMailConta	:= "protheus@telc.com.br"
	Private cUserConta	:= "protheus"
	Private cMailSenha	:= "Protheus@2019"

	// Chamada Função que monta corpo do email html
	_cMsg := fCriaBody(oObj,_cAssunto, _cAnotac)

	oMessage:= TMailMessage():New()
	oMessage:Clear()

	oMessage:cDate	 	:= cValToChar( Date() )
	oMessage:cFrom 	 	:= cMailConta
	oMessage:cTo 	 	:=  _cMailCc 	// "diogocbarros@hotmail.com;paulo.henrique@telc.com.br"
	//oMessage:cCc		:= _cMailCc		// Copia
	//oMessage:cBcc		:= _cMailCc		// Copia Oculta
	oMessage:cSubject	:= _cAssunto
	oMessage:cBody 	 	:= _cMsg

	oServer := tMailManager():New()

	//Indica se será utilizará a comunicação segura através de SSL/TLS (.T.) ou não (.F.)
	oServer:SetUseTLS( .F. )

	//Inicilizar o servidor
	xRet := oServer:Init( "",cMailServer, cUserConta, cMailSenha,, nPorta)
	If xRet != 0
		Alert("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ) )
		Return
	EndIf

	//Indica o tempo de espera em segundos.
	xRet := oServer:SetSMTPTimeout( 60 )
	If xRet != 0
		Alert("Não foi possível definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	EndIf

	//Indica conexão com servidor SMTP
	xRet := oServer:SMTPConnect()
	If xRet <> 0
		Alert("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		Return
	EndIf

	//Indica autenticação de acesso ao servidor de E-mail
	If lMailAuth
		xRet := oServer:SmtpAuth( cUserConta, cMailSenha )
		If xRet <> 0
			_cInf := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			alert( _cInf )
			oServer:SMTPDisconnect()
			Return
		EndIf
	EndIf

	//Envia E-mail
	xRet := oMessage:Send( oServer )
	If xRet <> 0
		alert("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
	EndIf

	//Disconecta o servidor
	xRet := oServer:SMTPDisconnect()
	If xRet <> 0
		Alert("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	EndIf

Return

/*/
{Protheus.doc} FATA300Z
@description Monta corpo de E-mail
@obs #CRM
/*/
Static Function fCriaBody(_oObj,_cAssunto, _cAnotac)

	Local _cBody := ''
	
	_cBody :=' <!DOCTYPE html> '
	_cBody +=' <html> '

	_cBody +=' <head> '
	_cBody +=' <meta http-equiv="Content-Type" '
	_cBody +=' content="text/html; charset=iso-8859-1"> '
	_cBody +=' <meta name="GENERATOR" content="Microsoft FrontPage Express 2.0"> '
	_cBody +=' <title>_cAssunto</title> '
	_cBody +=' </head> '

	_cBody +=' <body bgcolor="#FFFFFF"> '

	_cBody +='     <p><font color="#0000FF" face="Verdana"><b>Oportunidade</b></font></p> '
	_cBody +='     <table border="1" width="845"> '
	_cBody +='         <tr> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Oportunidade</b></font></td> '
	_cBody +='             <td width="460" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Revisão</b></font></td> '
	_cBody +='             <td width="253" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Descrição</b></font></td> '
	_cBody +='             <td width="110" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Data Inclusão</b></font></td> '
	_cBody +='         </tr> '
	_cBody +='         <tr> '
	_cBody +='             <td width="100"><font size="2" face="Arial">'+ _oObj:GetModel("AD1MASTER"):GetValue("AD1_NROPOR") 	 +'</font></td> '
	_cBody +='             <td width="460"><font size="2" face="Arial">'+ _oObj:GetModel("AD1MASTER"):GetValue("AD1_REVISA") 	 +'</font></td> '
	_cBody +='             <td width="253"><font size="2" face="Arial">'+ _oObj:GetModel("AD1MASTER"):GetValue("AD1_DESCRI") 	 +'</font></td> '
	_cBody +='             <td width="110"><font size="2" face="Arial">'+ DtoC(_oObj:GetModel("AD1MASTER"):GetValue("AD1_DATA"))  +'</font></td> '
	_cBody +='         </tr> '
	_cBody +='     </table> '
	_cBody +='     <p><font color="#0000FF" face="Verdana"><b>Vendedor</b></font></p> '
	_cBody +='     <table border="1" width="846"> '
	_cBody +='         <tr> '
	_cBody +='             <td width="65"  bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Cod.Vendedor</b></font></td> '
	_cBody +='             <td width="222" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Nome Vendedor</b></font></td> '
	_cBody +='             <td width="99"  bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Cod.Pre Vend.</b></font></td> '
	_cBody +='             <td width="32"  bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Nome Pre Vend.</b></font></td> '
	_cBody +='             <td width="99"  bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Data Inicio</b></font></td> '
	_cBody +='         </tr> '
	_cBody +='         <tr> '
	_cBody +='             <td width="65"><font size="2" face="Arial">'+ _oObj:GetModel("AD1MASTER"):GetValue("AD1_VEND") 		+'</font></td> '
	_cBody +='             <td width="222"><font size="2" face="Arial">'+ _oObj:GetModel("AD1MASTER"):GetValue("AD1_NOMVEN") 	+'</font></td> '
	_cBody +='             <td width="99"><font size="2" face="Arial">'+ _oObj:GetModel("AD1MASTER"):GetValue("AD1_XPREVE") 		+'</font></td> '
	_cBody +=' 			   <td width="32"><font size="2" face="Arial">'+ _oObj:GetModel("AD1MASTER"):GetValue("AD1_XNOPRE") 		+'</font></td> '
	_cBody +='             <td width="99"><font size="2" face="Arial">'+ DtoC(_oObj:GetModel("AD1MASTER"):GetValue("AD1_DTINI")) +'</font></td> '
	_cBody +='         </tr> '
	_cBody +='     </table> '
	_cBody +=' 	<p><font color="#0000FF" face="Verdana"><b>Cliente</b></font></p> '
	_cBody +='     <table border="1" width="846"> '
	_cBody +='         <tr> '
	_cBody +='             <td width="65"  bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Cod.Cliente</b></font></td> '
	_cBody +='             <td width="222" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Loja Cliente</b></font></td> '
	_cBody +='             <td width="99"  bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Nome Cliente</b></font></td> '
	_cBody +='         </tr> '
	_cBody +='         <tr> '
	_cBody +='             <td width="65"><font size="2" face="Arial">'+ _oObj:GetModel("AD1MASTER"):GetValue("AD1_CODCLI") 		+'</font></td> '
	_cBody +='             <td width="222"><font size="2" face="Arial">'+ _oObj:GetModel("AD1MASTER"):GetValue("AD1_LOJCLI") 	+'</font></td> '
	_cBody +='             <td width="99"><font size="2" face="Arial">'+ _oObj:GetModel("AD1MASTER"):GetValue("AD1_NOMCLI") 		+'</font></td> '
	_cBody +='         </tr> '
	_cBody +='     </table> '
	_cBody +=' 	<p></p> '
	/*
	_cBody +=' 	<p><font color="#0000FF" face="Verdana"><b>Anotacoes</b></font></p> '
	_cBody +='     <table border="1" width="846"> '
	_cBody +='         <tr> '
	_cBody +='             <td width="65"  bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Ultima Anotacao</b></font></td> '
	_cBody +='         </tr> '
	_cBody +='         <tr> '
	_cBody +='             <td width="65"><font size="2" face="Arial">'+ _cAnotac +'</font></td> '
	_cBody +='         </tr> '
	_cBody +='     </table> '
	_cBody +=' 	<p></p> '
	*/
	_cBody +='     <table border="1" width="275"> '
	_cBody +='         <tr> '
	_cBody +='             <td width="155" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Estagio em %</b></font></td> '
	_cBody +='             <td width="121"><font size="2" face="Arial">'+ cValToChar(_oObj:GetModel("AD1MASTER"):GetValue("AD1_PERCEN"))   	+'</font></td> '
	_cBody +='         </tr> '
	_cBody +='         <tr> '
	_cBody +='             <td width="155" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Receita</b></font></td> '
	_cBody +='             <td width="121"><font size="2" face="Arial">'+ cValtoChar(_oObj:GetModel("AD1MASTER"):GetValue("AD1_VERBA")) +'</font></td> '
	_cBody +='         </tr> '

	_cBody +='     </table> '

	_cBody +=' </body> '
	_cBody +=' </html> '

	//EndIf

Return _cBody


/*/
{Protheus.doc} FATA300Z
@description Busca a ultima anotação referente a Oportunidade.
@obs #CRM
/*/
Static Function fBuscAOB(_oObj)
	
	Local _cRet 	:= ''
	Local _cNrOpor 	:= _oObj:GetModel("AD1MASTER"):GetValue("AD1_NROPOR")
	
	DbSelectArea('AOB')
	AOB->(DbSetOrder(1))
	IF( AIJ->(DbSeek( xFilial('AOB') + _cNrOpor)) )
		//AOB->(DbGoBotton())
		_cRet := AOB->AOB_CONTEU 
	EndIf

Return _cRet