#Include 'protheus.ch'
#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

User Function API08DBA()
Return

Class VendasDia
	
	Data dDat	As Data
	Data cNome	As String
	Data aInfo	As Array
	
	Method ListVendPar(_dDatPar) Constructor
	Method ListVendDia()
	
EndClass

// Lista Vendas da data conforme parametro
Method ListVendPar(_dDatPar) Class VendasDia

	Local _cArr := {}
	::dDat := STOD(_dDatPar)

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

// Lista Vendas do dia atual
Method ListVendDia() Class VendasDia

	Local _cArr := {}
	Local _dDatHj := Date()
	::dDat := _dDatHj

	dbSelectArea("SC5")
	SC5->( dbSetOrder(2) )

	If SC5->( DbSeek( xFilial("SC5") + DTOS(::dDat) ) )		

		//SC5->( dbGoTop() )		
		While SC5->( !EOF() .AND. C5_EMISSAO == ::dDat)

			::cNome := Posicione("SA3", 1, xFilial("SA3") + SC5->C5_VEND1, "A3_NREDUZ" )
			::cNome := IIF(Empty(::cNome),"S/N",::cNome)

			aAdd(_cArr, { DTOS(SC5->C5_EMISSAO), SC5->C5_NUM, SC5->C5_TIPO, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_CONDPAG, SC5->C5_VEND1, ::cNome })

			SC5->( DbSkip() )

		EndDo
	
	Else
		Return (Nil) 	// Nao achou Venda na data
	EndIf
	
	If(Len(_cArr) <= 0)
		Return(Nil) 	// Achou vendas mas por algum motivo nao populou array
	Else
		::aInfo := _cArr
	EndIf
	
Return(Self)