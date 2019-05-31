#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RwMake.ch"

User Function FATA01PA(_cExec, _aParam)
	Local _xRet
	Local _aArea	:= GetArea()

	If _cExec == "001"
		_cFilDoc	:= _aParam[01]
		_cNumDoc	:= _aParam[02]
		_cSerie		:= _aParam[03]
		_cCliFor	:= _aParam[04]
		_cLoja		:= _aParam[05]
		_cEntSai	:= "S"
		_xRet	:= fTxtNSerie(_cFilDoc, _cNumDoc, _cSerie, _cCliFor, _cLoja, _cEntSai)
	ElseIf _cExec == "002"
		_xRet := fTlaOrdemF()
	EndIF

	RestArea(_aArea)

Return(_xRet)



Static Function fTxtNSerie(_cFilDoc, _cNumDoc, _cSerie, _cCliFor, _cLoja, _cEntSai)

	Local _cRet		:= ""
	Local _cChvSZ0	:= _cFilDoc+_cEntSai+_cNumDoc+_cSerie+_cCliFor+_cLoja
	Local _cItem	:= ""
	Local _cObs		:= ""

	DbSelectArea("SZ0")
	DbSetOrder(01)
	SZ0->(DbGoTop())

	If SZ0->(DbSeek(_cChvSZ0))
		_cRet := "Número(s) de Série"
		While SZ0->(!EOF()) .And. _cChvSZ0 == SZ0->(Z0_FILIAL+Z0_ENTSAI+Z0_DOC+Z0_SERIE+Z0_CLIFOR+Z0_LJACF)
			_cItem	:= SZ0->Z0_ITEM
			_cRet+=" - IT"+AllTrim(SZ0->Z0_ITEM)+" = "
			While SZ0->(!EOF()) .AND. _cChvSZ0 == SZ0->(Z0_FILIAL+Z0_ENTSAI+Z0_DOC+Z0_SERIE+Z0_CLIFOR+Z0_LJACF) .AND. _cItem == SZ0->Z0_ITEM
				IF !EMPTY(SZ0->Z0_NSERIE)
					_cRet+=AllTrim(SZ0->Z0_NSERIE)+";"
				EndIf
				IF !EMPTY(SZ0->Z0_OBS)
					_cObs += AllTrim(SZ0->Z0_OBS)+". "
				EndIf
				SZ0->(DbSkip())
			EndDO
		EndDo
		_cRet += _cObs
	EndIF

Return(_cRet)



Static Function fTlaOrdemF

	Local _lRet := .F.
	Local _lConfirm := .F.
	Local _oDlgOFornec,oSay1,oSay2,oSay3,oSay4,oGet5,oGet6,oGet7,oGet8,oSBtn9,oSBtn10

	Local _cSerie		:= SF2->F2_SERIE
	Local _cNDoc		:= SF2->F2_DOC
	Local _cCliente		:= ""
	Local _cOrdFornec	:= SF2->F2_ORDFORN

	DbSelectArea("SA1")
	DbSetOrder(01)
	SA1->(DbGoTop())
	If SA1->(DbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
		_cCliente := SA1->A1_COD+" / "+SA1->A1_LOJA+" - "+SA1->A1_NOME
	EndIF

	_oDlgOFornec := MSDIALOG():Create()
	_oDlgOFornec:cName := "_oDlgOFornec"
	_oDlgOFornec:cCaption := "Ordem de Fornecimento"
	_oDlgOFornec:nLeft := 0
	_oDlgOFornec:nTop := 0
	_oDlgOFornec:nWidth := 560
	_oDlgOFornec:nHeight := 250
	_oDlgOFornec:lShowHint := .F.
	_oDlgOFornec:lCentered := .T.

	oSay1 := TSAY():Create(_oDlgOFornec)
	oSay1:cName := "oSay1"
	oSay1:cCaption := "Documento"
	oSay1:nLeft := 10
	oSay1:nTop := 40
	oSay1:nWidth := 65
	oSay1:nHeight := 17
	oSay1:lShowHint := .F.
	oSay1:lReadOnly := .F.
	oSay1:Align := 0
	oSay1:lVisibleControl := .T.
	oSay1:lWordWrap := .F.
	oSay1:lTransparent := .F.

	oSay2 := TSAY():Create(_oDlgOFornec)
	oSay2:cName := "oSay2"
	oSay2:cCaption := "Série"
	oSay2:nLeft := 10
	oSay2:nTop := 10
	oSay2:nWidth := 65
	oSay2:nHeight := 17
	oSay2:lShowHint := .F.
	oSay2:lReadOnly := .F.
	oSay2:Align := 0
	oSay2:lVisibleControl := .T.
	oSay2:lWordWrap := .F.
	oSay2:lTransparent := .F.

	oSay3 := TSAY():Create(_oDlgOFornec)
	oSay3:cName := "oSay3"
	oSay3:cCaption := "Cliente"
	oSay3:nLeft := 10
	oSay3:nTop := 70
	oSay3:nWidth := 65
	oSay3:nHeight := 17
	oSay3:lShowHint := .F.
	oSay3:lReadOnly := .F.
	oSay3:Align := 0
	oSay3:lVisibleControl := .T.
	oSay3:lWordWrap := .F.
	oSay3:lTransparent := .F.

	oSay4 := TSAY():Create(_oDlgOFornec)
	oSay4:cName := "oSay4"
	oSay4:cCaption := "Ordem de Fornecimento"
	oSay4:nLeft := 10
	oSay4:nTop := 100
	oSay4:nWidth := 120
	oSay4:nHeight := 17
	oSay4:lShowHint := .F.
	oSay4:lReadOnly := .F.
	oSay4:Align := 0
	oSay4:lVisibleControl := .T.
	oSay4:lWordWrap := .F.
	oSay4:lTransparent := .F.

	oGet5 := TGET():Create(_oDlgOFornec)
	oGet5:cName := "oGet5"
	oGet5:nLeft := 90
	oGet5:nTop := 10
	oGet5:nWidth := 45
	oGet5:nHeight := 21
	oGet5:lShowHint := .F.
	oGet5:lReadOnly := .T.
	oGet5:Align := 0
	oGet5:cVariable := "_cSerie"
	oGet5:bSetGet := {|u| If(PCount()>0,_cSerie:=u,_cSerie) }
	oGet5:lVisibleControl := .T.
	oGet5:lPassword := .F.
	oGet5:lHasButton := .F.

	oGet6 := TGET():Create(_oDlgOFornec)
	oGet6:cName := "oGet6"
	oGet6:nLeft := 90
	oGet6:nTop := 40
	oGet6:nWidth := 80
	oGet6:nHeight := 21
	oGet6:lShowHint := .F.
	oGet6:lReadOnly := .T.
	oGet6:Align := 0
	oGet6:cVariable := "_cNDoc"
	oGet6:bSetGet := {|u| If(PCount()>0,_cNDoc:=u,_cNDoc) }
	oGet6:lVisibleControl := .T.
	oGet6:lPassword := .F.
	oGet6:lHasButton := .F.

	oGet7 := TGET():Create(_oDlgOFornec)
	oGet7:cName := "oGet7"
	oGet7:nLeft := 90
	oGet7:nTop := 70
	oGet7:nWidth := 439
	oGet7:nHeight := 21
	oGet7:lShowHint := .F.
	oGet7:lReadOnly := .T.
	oGet7:Align := 0
	oGet7:cVariable := "_cCliente"
	oGet7:bSetGet := {|u| If(PCount()>0,_cCliente:=u,_cCliente) }
	oGet7:lVisibleControl := .T.
	oGet7:lPassword := .F.
	oGet7:lHasButton := .F.

	oGet8 := TGET():Create(_oDlgOFornec)
	oGet8:cName := "oGet8"
	oGet8:nLeft := 10
	oGet8:nTop := 130
	oGet8:nWidth := 522
	oGet8:nHeight := 21
	oGet8:lShowHint := .F.
	oGet8:lReadOnly := .F.
	oGet8:Align := 0
	oGet8:cVariable := "_cOrdFornec"
	oGet8:bSetGet := {|u| If(PCount()>0,_cOrdFornec:=u,_cOrdFornec) }
	oGet8:lVisibleControl := .T.
	oGet8:lPassword := .F.
	oGet8:lHasButton := .F.

	oSBtn9 := SBUTTON():Create(_oDlgOFornec)
	oSBtn9:cName := "oSBtn9"
	oSBtn9:cCaption := "Ok"
	oSBtn9:nLeft := 480
	oSBtn9:nTop := 170
	oSBtn9:nWidth := 52
	oSBtn9:nHeight := 22
	oSBtn9:lShowHint := .F.
	oSBtn9:lReadOnly := .F.
	oSBtn9:Align := 0
	oSBtn9:lVisibleControl := .T.
	oSBtn9:nType := 1
	oSBtn9:bAction := {|| _lConfirm := .T., Close(_oDlgOFornec) }

	oSBtn10 := SBUTTON():Create(_oDlgOFornec)
	oSBtn10:cName := "oSBtn10"
	oSBtn10:cCaption := "oSBtn10"
	oSBtn10:nLeft := 410
	oSBtn10:nTop := 170
	oSBtn10:nWidth := 52
	oSBtn10:nHeight := 22
	oSBtn10:lShowHint := .F.
	oSBtn10:lReadOnly := .F.
	oSBtn10:Align := 0
	oSBtn10:lVisibleControl := .T.
	oSBtn10:nType := 2
	oSBtn10:bAction := {|| _lConfirm := .F., Close(_oDlgOFornec) }

	_oDlgOFornec:Activate()

	If _lConfirm
		If RecLock("SF2", .F.)
			REPLACE F2_ORDFORN WITH _cOrdFornec
			SF2->(MsUnLock())
		EndIf
	EndIF

	_lRet := _lConfirm

Return(_lRet)