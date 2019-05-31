#Include 'protheus.ch'
#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "FileIo.CH"

User Function API04DBA()
Return

Class Vendas
	
	Data cVend	As String
	Data cNome	As String
	Data aInfo	As Array
	
	Method ListOne() Constructor
	Method ListAll()
	
EndClass

// Lista Todas as vendas do vendedor exclusivo
Method ListOne(_cVend) Class Vendas

	Local _cArr := {}
	::cVend := _cVend

	DbSelectArea("SC5")
	SC5->( DbSetOrder(7) )

	If SC5->( DbSeek( xFilial("SC5") + ::cVend ) )

		::cNome := Posicione("SA3", 1, xFilial("SA3") + ::cVend, "A3_NREDUZ" )
		::cNome := IIF(Empty(::cNome),"S/N",::cNome)

		SC5->( dbGoTop() )		
		While SC5->( !EOF() )
			aAdd(_cArr, {SC5->C5_VEND1, ::cNome, SC5->C5_NUM, SC5->C5_TIPO, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_CONDPAG, SC5->C5_EMISSAO })
			SC5->( DbSkip() )
		EndDo
	
	Else
		Return (Nil)
	EndIf
	
	If(Len(_cArr) <= 0)
		Return(Nil)
	Else
		::aInfo := _cArr
	EndIf

Return(Self)

// Lista todas as vendas
Method ListAll() Class Vendas

	Local _cArr := {}

	//::aInfo := _aInfo
	qqout("Entrou na classe ListALl")
	dbSelectArea("SC5")
	SC5->( dbSetOrder(1) )
	SC5->( dbGoTop() )

	While SC5->( !EOF() )
		
		::cNome := Posicione("SA3", 1, xFilial("SA3") + SC5->C5_VEND1, "A3_NREDUZ" )
		::cNome := IIF(Empty(::cNome),"S/N",::cNome)
		
		aAdd(_cArr, {SC5->C5_VEND1, ::cNome, SC5->C5_NUM, SC5->C5_TIPO, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_CONDPAG, SC5->C5_EMISSAO })
		
		SC5->( DbSkip() )
	EndDo
			
	If(Len(_cArr) <= 0)
		Return(Nil)
	Else
		::aInfo := _cArr
	EndIf
	
Return(Self)