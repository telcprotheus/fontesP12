#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'Ap5Mail.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'

/*/
{Protheus.doc} TCR001DB
Relatorio Sintetico Oportunidades por Vendedor
@author Diogo C. Barros
@since 27/05/2019
@version Protheus 12
@description Schedule - Relatorio Sintetico Estagios da Oportunidade por Vendedor
@obs #CRM
@type user function
@param
@see
@return
/*/
User Function TCR001DB()

	Local _cQuery		:= ''
	Local _lRet       	:= .T.	
	Local _cIdPonto   	:= ''
	Local _cIdModel   	:= ''
	Local _cAssunto		:= 'Relatorio Sintetico Estagios da Oportunidade por Vendedor'
	Local _cMailCc		:= ''
	Local _nOperation  	:= 0
	Local _cMsg			:= ''
	Local _cAnotac		:= ''
	Local _cMailVen		:= ''	// Email Vendedor
	Local _cMailSVen	:= ''	// Email Supervisor Vendedor
	Local _cMailPre		:= ''	// Email Pre-Vendedor
	Local _cMailSPre	:= ''	// Email Supervisor Pre-Vendedor
	Local dDatSxt		:= DATE()
	Local dDatSeg		:= (DATE() -4)

	Private _lEnvVen		:= SuperGetMv("MV_F300VEN",,.T.)	// Envia Email Vendedor
	Private _lEnvSVen		:= SuperGetMv("MV_F300SVE",,.T.)	// Envia Email Supervisor Vendedor
	Private _lEnvPre		:= SuperGetMv("MV_F300PRE",,.T.)	// Envia Email Pre Venda
	Private _lEnvSPre		:= SuperGetMv("MV_F300SPV",,.T.)	// Envia Email Supervisor Pre Venda
	Private _cMailDir		:= SuperGetMv("MV_F300DIR",,"")		// Envia Email Diretoria
	Private _cAlias			:= GetNextAlias()

	// Busca os galera que irá receber o E-mail
	_cMailCc := "diogocbarros@hotmail.com;paulo.henrique@telc.com.br" //_cfBuscaEmail()

	If EMPTY( _cMailCc )
		_lRet = .F.
	EndIf

	// Monta Query
	If _lRet		
		
		_cQuery +=	"SELECT	AD1_VEND, A3_NREDUZ , AD1_STAGE, AC2_DESCRI, TOTALPORESTAGIO " + CRLF
		_cQuery +=	"FROM (	 " + CRLF
		_cQuery +=	"SELECT	AD1_VEND, A3_NREDUZ ,AD1_STAGE, AC2_DESCRI,COUNT(AD1_STAGE) AS TOTALPORESTAGIO " + CRLF
		_cQuery +=	"FROM " +	RetSqlName('AD1') + " AD1 " + CRLF
		_cQuery +=	"INNER JOIN  " +	RetSqlName('AC2') + " AC2 ON SUBSTRING(AD1_FILIAL,1,4) = AC2_FILIAL AND AD1_PROVEN = AC2_PROVEN AND AD1_STAGE = AC2_STAGE AND AC2.D_E_L_E_T_ = ' '" + CRLF
		_cQuery +=	"INNER JOIN  " +	RetSqlName('SA3') + " SA3 ON A3_FILIAL = SUBSTRING(AD1_FILIAL,1,4) AND A3_COD = AD1_VEND AND SA3.D_E_L_E_T_ = ' '" + CRLF
		_cQuery +=	"WHERE  " + CRLF
		_cQuery +=	"AD1_DATA BETWEEN '"+ DTOS(dDatSeg) +"' AND '"+ DTOS(dDatSxt) + "' " + CRLF
		_cQuery +=  " AND AD1.D_E_L_E_T_ = ' ' " + CRLF
		_cQuery +=	"GROUP BY AD1_VEND, A3_NREDUZ, AD1_STAGE, AC2_DESCRI " + CRLF
		_cQuery +=	") SUBQ1 " + CRLF
		_cQuery +=	"ORDER BY 1,3 " + CRLF

		MemoWrite("C:\temp\"+FunName()+"_"+ProcName()+".TXT",_cQuery)

		If Select(_cAlias)>0
			(_cAlias)->(DbCloseArea())
		Endif

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(_cQuery)),_cAlias,.T.,.T.)

		If (_cAlias)->(!EOF())
			fEnvMail(_cAssunto, _cMailCc)
		Else
			_lRet = .F.
		Endif

	EndIf		
	
Return _lRet


/*/
{Protheus.doc} FATA300Z
Ponto de Entrada MVC para FATA300Z
@author Diogo C. Barros
@since 27/05/2019
@description Envia Email Oportunidade
@obs #CRM
/*/
Static Function fEnvMail(_cAssunto,_cMailCc)

	Local _cInf 	:= ""
	Local _cMsg		:= _cAssunto
	Local xRet
	Local oServer, oMessage
	Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.F.)
	Local nPorta 	:= 2323 //465

	Private cMailServer	:= "192.168.1.16" //"mail.telc.com.br"
	Private cMailConta	:= "protheus@telc.com.br"
	Private cUserConta	:= "protheus"
	Private cMailSenha	:= "Protheus@2019"

	// Chamada Função que monta corpo do email html
	_cMsg := fCriaBody(_cAssunto)

	oMessage:= TMailMessage():New()
	oMessage:Clear()

	oMessage:cDate	 	:= cValToChar( Date() )
	oMessage:cFrom 	 	:= cMailConta
	oMessage:cTo 	 	:=  _cMailCc //"diogocbarros@hotmail.com;paulo.henrique@telc.com.br" //_cMailCc 	// "diogocbarros@hotmail.com;paulo.henrique@telc.com.br"
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
{Protheus.doc} TCR001DB
@description Monta corpo de E-mail
@obs #CRM
/*/
Static Function fCriaBody(_cAssunto)

	Local _cBody := ''
	Local _aVlrStg := ARRAY(11)
	Local _cCodVend := ''
	Local _nCont
	
	_cBody :=' <!DOCTYPE html> '
	_cBody +=' <html> '

	_cBody +=' <head> '
	_cBody +=' <meta http-equiv="Content-Type" '
	_cBody +=' content="text/html; charset=iso-8859-1"> '
	_cBody +=' <meta name="GENERATOR" content="Microsoft FrontPage Express 2.0"> '
	_cBody +=' <title>_cAssunto</title> '
	_cBody +=' </head> '

	_cBody +=' <body bgcolor="#FFFFFF"> '

	_cBody +='     <p><font color="#0000FF" face="Verdana"><b>Relatorio Sintetico Estagios da Oportunidade por Vendedor </b></font></p> '
	_cBody +='     <table border="1" width="845"> '
	_cBody +='         <tr> '
	_cBody +='             <td width="200" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Vendedor</b></font></td> '
	
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Prospect</b></font></td> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Pendente</b></font></td> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Analise</b></font></td> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Revisar</b></font></td> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Negociacao</b></font></td> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Entregar</b></font></td> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Pos-Venda</b></font></td> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Encerrado</b></font></td> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Perdido</b></font></td> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Stand-By</b></font></td> '
	_cBody +='             <td width="100" bgcolor="#99CCFF"><font size="2" face="Verdana"><b>Documentacao</b></font></td> '	
	_cBody +='         </tr> '
	
	DbSelectArea(_cAlias)
	(_cAlias)->(dbgotop())
	While (_cAlias)->(!EOF())

		_cBody +='         <tr> '
		_cBody +='             <td width="200"><font size="2" face="Arial">'+ (_cAlias)->A3_NREDUZ  +'</font></td> '
		_cCodVend := (_cAlias)->(AD1_VEND)
		
		While _cCodVend == (_cAlias)->(AD1_VEND)
			_aVlrStg[VAL((_cAlias)->AD1_STAGE)] := ((_cAlias)->TOTALPORESTAGIO)
			(_cAlias)->(dbSkip())
		EndDo
		
		
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[1] == NIL, '0', Transform(_aVlrStg[1],  '@E 9999'))	 +'</font></td> ' //000001
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[2] == NIL, '0', Transform(_aVlrStg[2],  '@E 9999')) 	 +'</font></td> ' //000002
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[3] == NIL, '0', Transform(_aVlrStg[3],  '@E 9999'))     +'</font></td> ' //000003
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[4] == NIL, '0', Transform(_aVlrStg[4],  '@E 9999')) 	 +'</font></td> ' //000004
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[5] == NIL, '0', Transform(_aVlrStg[5],  '@E 9999')) 	 +'</font></td> ' //000005
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[6] == NIL, '0', Transform(_aVlrStg[6],  '@E 9999'))     +'</font></td> ' //000006
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[7] == NIL, '0', Transform(_aVlrStg[7],  '@E 9999')) 	 +'</font></td> ' //000007
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[8] == NIL, '0', Transform(_aVlrStg[8],  '@E 9999')) 	 +'</font></td> ' //000008
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[9] == NIL, '0', Transform(_aVlrStg[9],  '@E 9999')) 	 +'</font></td> ' //000009
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[10] == NIL, '0',Transform(_aVlrStg[10], '@E 9999'))     +'</font></td> ' //000010
		_cBody +='             <td width="100"><font size="2" face="Arial">'+  IIF(_aVlrStg[11] == NIL, '0',Transform(_aVlrStg[11], '@E 9999'))     +'</font></td> ' //000011

		_cBody +='         </tr> '
		_aVlrStg := ARRAY(11)
	EndDo

	_cBody +='     </table> '
	_cBody +=' </body> '
	_cBody +=' </html> '

Return _cBody