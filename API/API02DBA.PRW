#Include 'protheus.ch'
#include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

User Function API02DBA()
Return

Class Cliente
	
	Data cCod	As String
	Data cLoja	As String
	Data cNome	As String
	Data cEnd	As String
	Data cTel	As String
	Data aInfo	As Array
	
	Method ListOne(cCod,cLoja,cNome,cEnd,cTel) Constructor
	Method ListAll(aInfo)
	
EndClass


Method ListOne(_cCod,_cLoja,_cNome,_cEnd,_cTel) Class Cliente
	QQOut("Entrou na classe ListOne")
	::cCod 	:= _cCod
	::cLoja	:= _cLoja
	::cNome := _cNome
	::cEnd 	:= _cEnd
	::cTel 	:= _cTel
Return(Self)


Method ListAll(aList) Class Cliente
	QQOut("Entrou na classe ListAll")
	::aInfo	:= aList
Return(Self)