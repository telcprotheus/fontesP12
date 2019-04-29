#Include 'protheus.ch'
#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

User Function API07DBA()
Return

Class VendCondPag
	
	Data cCondPag	As String
	Data cNome		As String
	Data aInfo		As Array
	
	Method ListCondPag(_cCondPag) Constructor
	
EndClass

// Lista Vendas da data conforme parametro
Method ListCondPag(_cCondPag) Class VendCondPag

	Local _cArr := {}
	::cCondPag 	:= _cCondPag
	qqout(::cCondPag)
	qqout(_cCondPag)
	DbSelectArea("SC5")
	SC5->( DbSetOrder(8) )
	qqout("Entrou no method")
	If SC5->( DbSeek( xFilial("SC5") + ::cCondPag ) )				
		qqout("Entrou no If")
		//SC5->( dbGoTop() )
		While (SC5->( !EOF()) .AND. SC5->C5_CONDPAG == ::cCondPag)
			qqout("Entrou no while")
			::cNome := Posicione("SA3", 1, xFilial("SA3") + SC5->C5_VEND1, "A3_NREDUZ" )
			::cNome := IIF(Empty(::cNome),"S/N",::cNome)
			
			aAdd(_cArr, { SC5->C5_CONDPAG, SC5->C5_NUM, SC5->C5_TIPO, SC5->C5_CLIENTE, SC5->C5_LOJACLI, DTOS(SC5->C5_EMISSAO), SC5->C5_VEND1, ::cNome })
			
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