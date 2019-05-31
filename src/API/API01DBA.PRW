#Include 'protheus.ch'
#include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

User Function API01DBA()
Return

Class Funcionario
	
	Data cMat	As String
	Data cNome	As String
	Data aFunc	As Array
	
	Method ListOne(cMat, cNome) Constructor
	Method ListAll(aFunc)
	
EndClass


Method ListOne(cMatric, cNomeFun) Class Funcionario
	QQOut("Entrou na classe ListOne")
	::cMat 	:= cMatric
	::cNome := cNomeFun
Return(Self)


Method ListAll(aList) Class Funcionario
	QQOut("Entrou na classe ListAll")
	::aFunc	:= aList
Return(Self)