#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function FA070TIT
	O ponto de entrada FA070TIT sera executado apos a confirmacao da baixa do contas a receber.
	@type  Ponto de Entrada
	@author Diogo Barros
	@since 31/05/2019
	@return _lRet, Logico
/*/
User Function FA070TIT()
	
	Local _lRet := If(MovBcobx(cMotBx,.T.),ExecBlock("TCFI001D",.F.,.F.,{cBanco,cAgencia,cConta}),.T.)

Return _lRet