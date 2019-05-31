#Include 'protheus.ch'
#include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

User Function API03DBA()
Return

Class Oportunidade
	// AD1->AD1_NROPOR, AD1->AD1_REVISA, AD1_DESCRI, AD1_DATA, AD1_VEND, _cNomVen, AD1_CODCLI, AD1_LOJCLI, _cNomCli
	Data cOpor		As String
	Data cRevi		As String
	Data cDesc		As String
	Data cData		As String
	Data cVend		As String
	Data cDesVend	As String
	Data cCodCli	As String
	Data cLojCli	As String
	Data cDesCli	As String	
	Data aOpor		As Array
	
	Method ListOne(cOpor, cRevi, cDesc, cData, cVend, cDesVend, cCodCli, cLojCli, cDesCli) Constructor
	Method ListAll(aOpor)
	
EndClass


Method ListOne(_cOpor, _cRevi, _cDesc, _cData, _cVend, _cDesVend, _cCodCli, _cLojCli, _cDesCli) Class Oportunidade
	QQOut("Entrou na classe ListOne")
	::cOpor 	:= _cOpor
	::cRevi 	:= _cRevi
	::cDesc 	:= _cDesc
	::cData 	:= _cData
	::cVend 	:= _cVend
	::cDesVend 	:= _cDesVend
	::cCodCli 	:= _cCodCli
	::cLojCli 	:= _cLojCli
	::cDesCli 	:= _cDesCli
Return(Self)


Method ListAll(aList) Class Oportunidade
	QQOut("Entrou na classe ListAll")
	::aOpor	:= aList
Return(Self)