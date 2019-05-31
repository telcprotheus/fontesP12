#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function TCFI001D
	(Verifica se usuario tem acesso a movimentar banco)
	@type  Function
	@author Diogo Barros
	@since 31/05/2019
	@see (FINANCEIRO, MOVIMENTOS BANCARIO)
/*/
User Function TCFI001D()
	
	Local   _aArea          :=      GetArea()
	Local   _cBanco         :=      If(Type("ParamIxb")=="A".And.Len(ParamIxb)>0,ParamIxb[1],SA6->A6_COD)
	Local   _cAgencia       :=      If(Type("ParamIxb")=="A".And.Len(ParamIxb)>1,ParamIxb[2],SA6->A6_AGENCIA)
	Local   _cConta         :=      If(Type("ParamIxb")=="A".And.Len(ParamIxb)>2,ParamIxb[3],SA6->A6_NUMCON)
	Local 	_lRet 			:= .F.
	Local 	_cSpUser		:= '000008' // Gaby.Cestari

	// Verifica no cadastro do banco se usuario tem ligacao com o mesmo
	If (_cSpUser == __cUserid)
		_lRet := .T.
	Else	
		DbSelectArea('SA6')
		DbSetOrder(1)
		If DbSeek(xFilial("SA6")+_cBanco+_cAgencia+_cConta)
				If !EMPTY(SA6->A6_USER) .AND. SA6->A6_USER == __cUserid
						_lRet := .T.     
				Endif
		Endif
	EndIf

	// Mostra aviso se usuario nao tem autorização 
	If !(_lRet)
		Aviso("ATENCAO!!!",Alltrim(cUserName)+", voce nao esta autorizado a utilizar este Banco/Agencia/Conta, favor verifique!",{"Ok"})
	EndIf

	RestArea(_aArea)

Return _lRet