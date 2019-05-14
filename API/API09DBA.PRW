#Include 'protheus.ch'
#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

User Function API09DBA()
Return

Class FluxoCaixa
	
	Data dDatDe		As Data
	Data dDatAte	As Data
	Data aInfo		As Array
	
	Method ListFluxo() Constructor
	
EndClass

// Lista Vendas da data conforme parametro
Method ListFluxo(_dDatDe, _dDatAte) Class VendasDia

	Local _cArr := {}
	::dDatDe  := STOD(_dDatDe)
	::dDatAte := STOD(_dDatAte)

	DbSelectArea("SC5")
	SC5->( DbSetOrder(2) )

	If SC5->( DbSeek( xFilial("SC5") + DTOS(::dDat) ) )				
		
		//SC5->( dbGoTop() )
		While (SC5->( !EOF()) .AND. SC5->C5_EMISSAO == ::dDat)
			
			::cNome := Posicione("SA3", 1, xFilial("SA3") + SC5->C5_VEND1, "A3_NREDUZ" )
			::cNome := IIF(Empty(::cNome),"S/N",::cNome)
			
			aAdd(_cArr, { DTOS(SC5->C5_EMISSAO), SC5->C5_NUM, SC5->C5_TIPO, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_CONDPAG, SC5->C5_VEND1, ::cNome })
			
			SC5->( DbSkip() )

		EndDo
	
	Else
		Return (Nil)	// Nao achou Venda na data
	EndIf
	
	If(Len(_cArr) <= 0)
		Return(Nil)		// Achou vendas mas por algum motivo nao populou array
	Else
		::aInfo := _cArr
	EndIf

Return(Self)