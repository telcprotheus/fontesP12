#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCOMMAND.CH"
#include 'protheus.ch'
#include 'parmtype.ch'

/*/
{Protheus.doc} MATA01D
//Rotina desenvolvida para realizar o V�nculo do Documento de Entrada
//com os seus respectivos N�meros de S�rie.
@author Diogo Barros
@since 25/05/2019
/*/

User Function MATA01D()

	Local oBrowse := FWMBrowse():New()

	Private aRotina := MenuDef()

	oBrowse:SetAlias('SF1')
	oBrowse:SetDescription('Documento x N�mero de S�rie')

	oBrowse:AddLegend("Empty(F1_FIMP)" , "GREEN"	,"Permite o Lan�amento do N.Serie")
	oBrowse:AddLegend("!Empty(F1_FIMP)", "RED"		,"N�o Permite o Lan�amento do N.Serie.")

	oBrowse:Activate()

Return



Static Function MenuDef()

	Local _aRet := {}

	ADD OPTION _aRet Title 'Pesquisar'					Action 'PesqBrw'			OPERATION 1 ACCESS 0
	ADD OPTION _aRet Title 'Visualizar'					Action 'VIEWDEF.MATA01D'	OPERATION 2 ACCESS 0
	ADD OPTION _aRet Title 'Lan�ar N�mero de S�rie'		Action 'VIEWDEF.MATA01D'	OPERATION 4 ACCESS 0
	//ADD OPTION _aRet Title 'Ordem de Fornecimento'		Action 'U_MATA01DA("002")'	OPERATION 4 ACCESS 0
	ADD OPTION _aRet Title 'Excluir N�mero de S�rie'	Action 'VIEWDEF.MATA01D'	OPERATION 5 ACCESS 0

Return(_aRet)



Static Function ModelDef()

	Local oStSF1Cb := FWFormStruct( 1, 'SF1' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //Cabe�alho de Documento de Entrada
	Local oStSD1It := FWFormStruct( 1, 'SD1' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //Itens do Documento de Entrada
	Local oStSZ0It := FWFormStruct( 1, 'SZ0' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //N�meros de S�rie dos Itens do Documento.

	Local _oModel // Modelo de dados que ser� constru�do

	//Ajustando a Estrutura
	//CAMPOS OBRIGAT�RIOS:
	oStSF1Cb:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F.)
	oStSD1It:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F.)

	//Criando o Objeto MODEL
	_oModel := MPFormModel():New( 'MATA01DX', , /*{|_oModel| fVldExMdl(_oModel) } /*Validacao Antes da Grava��o*/, /*{|_oModel| fGrvModel(_oModel) } /*Funcao de Gravacao Manual*/ )

	_oModel:AddFields( 'SF1MASTER' , /*cOwner*/ , oStSF1Cb )
	_oModel:AddGrid(   'SD1_ITENS' , 'SF1MASTER', oStSD1It, /* {|X, Y, Z| fVExclLn(X, Y, Z) } /*bLinePre*/ )
	_oModel:AddGrid(   'SZ0_ITENS' , 'SD1_ITENS', oStSZ0It, /* {|X, Y, Z| fVExclLn(X, Y, Z) } /*bLinePre*/ )

	//Setando o Relacionamento
	_oModel:SetRelation( 'SD1_ITENS' , {{ 'D1_FILIAL'	, 'xFilial( "SD1" )' },;
										{ 'D1_DOC'		, 'F1_DOC' }, { 'D1_SERIE', 'F1_SERIE' }, { 'D1_FORNECE', 'F1_FORNECE' },;
										{ 'D1_LOJA'		, 'F1_LOJA' } }, SD1->( IndexKey(01) ) )
										
	_oModel:SetRelation( 'SZ0_ITENS' , {{ 'Z0_FILIAL'	, 'xFilial( "SZ0" )' }	, { 'Z0_ENTSAI', '"E"' }, ;
										{ 'Z0_DOC'		, 'D1_DOC' }			, { 'Z0_SERIE', 'D1_SERIE' }, { 'Z0_CLIFOR', 'D1_FORNECE' },;
										{ 'Z0_LJACF', 'D1_LOJA' }, {'Z0_ITEM', 'D1_ITEM'}, {'Z0_PRODUTO', 'D1_COD'} }, SZ0->( IndexKey(01) ) )
	//Setando Chave Prim�ria
	_oModel:SetPrimaryKey( { "F1_FILIAL", "F1_DOC", "F1_SERIE", "F1_FORNECE", "F1_LOJA" } )

	_oModel:GetModel( 'SD1_ITENS'  ):SetUniqueLine( { 'D1_DOC', 'D1_SERIE', 'D1_ITEM' } )
	_oModel:GetModel( 'SZ0_ITENS'  ):SetUniqueLine( { 'Z0_DOC', 'Z0_SERIE', 'Z0_ITEM', 'Z0_SEQ' } )

	//Setando Modelo de Dados Opcional
	_oModel:GetModel( 'SZ0_ITENS'  ):SetOptional( .T. )

	//N�o permita altera��o em seus dados, apenas para visualiza��o
	_oModel:GetModel( 'SF1MASTER'  ):SetOnlyView ( .T. )
	_oModel:GetModel( 'SD1_ITENS'  ):SetOnlyView ( .T. )

	_oModel:GetModel( 'SF1MASTER' ):SetOnlyQuery ( .T. )
	_oModel:GetModel( 'SD1_ITENS' ):SetOnlyQuery ( .T. )

	_oModel:SetDescription( 'Documento x N�mero de S�rie' )

	_oModel:GetModel( 'SF1MASTER'  ):SetDescription( 'Documento de Entrada' )
	_oModel:GetModel( 'SD1_ITENS'  ):SetDescription( 'Itens do Documento de Entrada' )
	_oModel:GetModel( 'SZ0_ITENS'  ):SetDescription( 'Itens do Documento de Entrada x N�mero de S�rie' )

	//Valida se o Modelo pode ser ativado
	_oModel:SetVldActivate( {|_oMdl| fVldModel(_oMdl) })

Return(_oModel)



Static Function ViewDef()

	Local oModel := FWLoadModel( 'MATA01D' ) //_MVC

	// Cria as estruturas a serem usadas na View
	Local oStSF1Cb := FWFormStruct( 2, 'SF1' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //Cabe�alho de Documento de Entrada
	Local oStSD1It := FWFormStruct( 2, 'SD1' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //Itens do Documento de Entrada
	Local oStSZ0It := FWFormStruct( 2, 'SZ0' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //N�meros de S�rie dos Itens do Documento.


	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( 'VW_SF1CB', oStSF1Cb, 'SF1MASTER'  )
	oView:AddGrid(  'VW_SD1IT', oStSD1It, 'SD1_ITENS'  )
	oView:AddGrid(  'VW_SZ0IT', oStSZ0It, 'SZ0_ITENS'  )

	//oView:CreateHorizontalBox( 'TELA_FULL'  , 100 )
	oView:CreateHorizontalBox( 'TELA_ACIMA' , 30 /*, 'TELA_FULL'*/ )
	oView:CreateHorizontalBox( 'TELA_ABAIXO', 70 /*, 'TELA_FULL'*/ )
	oView:CreateVerticalBox( 'ABAIXO_DIR', 60, 'TELA_ABAIXO' )
	oView:CreateVerticalBox( 'ABAIXO_ESQ', 40, 'TELA_ABAIXO' )

	oView:SetOwnerView( 'VW_SF1CB', 'TELA_ACIMA'  )
	oView:SetOwnerView( 'VW_SD1IT', 'ABAIXO_DIR'  )
	oView:SetOwnerView( 'VW_SZ0IT', 'ABAIXO_ESQ'  )

	oView:EnableTitleView('VW_SF1CB','Documento de Entrada')
	oView:EnableTitleView('VW_SD1IT','Itens do Documento de Entrada')
	oView:EnableTitleView('VW_SZ0IT','N�mero de S�rie')

	oView:AddIncrementField( 'VW_SZ0IT', 'Z0_SEQ' )

	//Criando Botoes
	//oView:AddUserButton("Arquivo DDA"	, "CLIPS", {|oView| fBscArqDDA()		/*Inser��o de Blocos na Grid*/				})

	//Valida se a Vis�o pode ser ativada
	oView:SetViewCanActivate({|_oVW| fVldView(_oVW) })

Return(oView)



//Fun��o para Valida��o da Ativa��o do Modelo
Static Function fVldModel(_oMdl)

	Local _aArea		:= GetArea()
	Local _lRet			:= .T.
	Local _nOper		:= _oMdl:GetOperation()

	IF _nOper == 3 //Incluir
		Help( ,, 'MATA01D - fVldModel',, "N�o � permitido a Inclus�o de N�meros de S�ries.", 1, 0 )
		_lRet := .F.
	ElseIf _nOper == 4 //Aletrar
		IF !EMPTY( SF1->F1_FIMP )
			Help( ,, 'MATA01D - fVldModel',, "N�o � permitido o Lan�amento de N�mero de S�rie para Documentos j� Transmitidos.", 1, 0 )
			_lRet := .F.
		EndIF
	ElseIF _nOper == 5 //Ecluir
		IF !EMPTY( SF1->F1_FIMP )
			Help( ,, 'MATA01D - fVldModel',, "N�o � permitido EXCLUIR o Lan�amento de N�mero de S�rie para Documentos j� Transmitidos.", 1, 0 )
			_lRet := .F.
		EndIF
	EndIF

Return(_lRet)



//Fun��o para Valida��o da Ativa��o da Vis�o
Static Function fVldView(_oVw)

	Local _aArea		:= GetArea()
	Local _lRet			:= .T.
	Local _nOper		:= _oVw:GetOperation()

	IF _nOper == 3 //Incluir
		Help( ,, 'MATA01D - fVldView',, "N�o � permitido a Inclus�o de N�meros de S�ries.", 1, 0 )
		_lRet := .F.
	ElseIf _nOper == 4 //Aletrar
		IF !EMPTY( SF1->F1_FIMP )
			Help( ,, 'MATA01D - fVldView',, "N�o � permitido o Lan�amento de N�mero de S�rie para Documentos j� Transmitidos.", 1, 0 )
			_lRet := .F.
		EndIF
	ElseIF _nOper == 5 //Ecluir
		IF !EMPTY( SF1->F1_FIMP )
			Help( ,, 'MATA01D - fVldView',, "N�o � permitido EXCLUIR o Lan�amento de N�mero de S�rie para Documentos j� Transmitidos.", 1, 0 )
			_lRet := .F.
		EndIF
	EndIF

Return(_lRet)