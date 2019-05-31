#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function F100TOK
	Ponto de Entrada para validar inclusao do movimento
	@type Ponto de Entrada  	
	@author Diogo Barros
	@since 31/05/2019
/*/
User Function F100TOK()
	
	Local _lRet := ExecBlock("TCFI001D",.F.,.F.,{M->E5_BANCO,M->E5_AGENCIA,M->E5_CONTA})

Return _lRet