#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function FA100TRF
	O ponto de entrada FA100TFR sera executado antes da transferencia 
	e retornara .T. para gravar a transferencia ou .F. em caso contrário.
	@type  Ponto de Entrada
	@author Diogo Barros
	@since 31/05/2019
	@return _lRet, Logico
/*/
User Function FA100TRF()
		
	Local   _cBcoOri	:= ParamIxb[1]     
	Local   _cAgeOri    := ParamIxb[2]
	Local   _cCtaOri    := ParamIxb[3]             
	Local   _cBcoDes    := ParamIxb[4]     
	Local   _cAgeDes    := ParamIxb[5]
	Local   _cCtaDes    := ParamIxb[6]             
	
	// Valida se o usuario tem acesso ao banco origem 
	Local   _lRet	:=	ExecBlock("TCFI001D",.F.,.F.,{_cBcoOri,_cAgeOri,_cCtaOri})

	// Se o usuario tiver acesso ao banco origem valida o banco destino
	If _lRet
		_lRet	:=	ExecBlock("TCFI001D",.F.,.F.,{_cBcoDes,_cAgeDes,_cCtaDes})
	Endif           

Return _lRet