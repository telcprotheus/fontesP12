#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'Ap5Mail.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} FATA300Z
//Ponto de Entrada MVC para FATA300Z
@author Diogo C. Barros
@since 25/03/2019
@version Protheus 12
@description Buscar os pontos de entrada da Oportunidade para chamada do workflow
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
	Local _cMailVen		:= ''	// Email Vendedor
	Local _cMailSVen	:= ''	// Email Supervisor Vendedor
	Local _cMailPre		:= ''	// Email Pre-Vendedor
	Local _cMailSPre	:= ''	// Email Supervisor Pre-Vendedor

	Local _lEnvVen		:= SuperGetMv("MV_F300VEN",,.T.)
	Local _lEnvSVen		:= SuperGetMv("MV_F300SVE",,.T.)
	Local _lEnvPre		:= SuperGetMv("MV_F300PRE",,.T.)
	Local _lEnvSPre		:= SuperGetMv("MV_F300SPV",,.T.)
	Local _cMailDir		:= SuperGetMv("MV_F300DIR",,"")		// Email Diretoria

	If _aParam <> NIL

		_oObj       := _aParam[1]
		_cIdPonto   := _aParam[2]
		_cIdModel   := _aParam[3]

		If  _cIdPonto == 'MODELPOS'

			_nOperation := _oObj:nOperation

			If _nOperation = MODEL_OPERATION_INSERT .OR. _nOperation = MODEL_OPERATION_UPDATE

				If _nOperation = MODEL_OPERATION_INSERT
					_cAssunto 	:= "Nova Oportunidade Cadastrada"
				EndIf

				If _nOperation = MODEL_OPERATION_UPDATE
					_cAssunto := "Alteração do Status da Oportunidade No.: "					
				EndIf
				
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

			EndIf
			
			// Chama função para enviar email
			Processa({|| fEnvMail(_cAssunto,_cMailTo,_cMailCc)}, "Aguarde...","Processando o envio do E-mail",.T.)

		EndIf

	EndIf

Return _lRet

Static Function fEnvMail(_cAssunto,_cMailCc)

	Local cMsg 		:= ""
	Local cMensagem	:= "Teste Envio de E-mail OPORTUNIDADE"
	Local xRet
	Local oServer, oMessage
	Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.F.)
	Local nPorta 	:= 2323 //465

	Private cMailServer	:= "192.168.1.16" //"mail.telc.com.br"
	Private cMailConta	:= "protheus@telc.com.br"
	Private cUserConta	:= "protheus"
	Private cMailSenha	:= "Protheus@2019"

	/*
	cMailConta := If(cMailConta == NIL,GETMV("MV_RELACNT"),cMailConta)             //Conta utilizada para envio do email
	cMailServer:= If(cMailServer == NIL,GETMV("MV_RELSERV"),cMailServer)           //Servidor SMTP
	cMailSenha := If(cMailSenha == NIL,GETMV("MV_RELPSW"),cMailSenha)             //Senha da conta de e-mail utilizada para envio
	*/

	oMessage:= TMailMessage():New()
	oMessage:Clear()

	oMessage:cDate	 	:= cValToChar( Date() )
	oMessage:cFrom 	 	:= cMailConta
	oMessage:cTo 	 	:= "diogocbarros@hotmail.com;paulo.henrique@telc.com.br"
	oMessage:cCc		:= _cMailCc
	//oMessage:cBcc		:= _cMailCc		//Copia Oculta
	oMessage:cSubject	:= _cAssunto
	oMessage:cBody 	 	:= cMensagem

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
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			alert( cMsg )
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