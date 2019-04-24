#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCOMMAND.CH"
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} FATA01P
//Rotina desenvolvida para realizar o Vínculo do Documento de Saída
//com os seus respectivos Números de Série.
@author FOliveirap
@since 19/09/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/

User Function FATA01P()
Local oBrowse := FWMBrowse():New()

Private aRotina := MenuDef()

oBrowse:SetAlias('SF2')
oBrowse:SetDescription('Documento x Número de Série')

oBrowse:AddLegend("Empty(F2_FIMP)" , "GREEN"	,"Permite o Lançamento do N.S.")
oBrowse:AddLegend("!Empty(F2_FIMP)", "RED"		,"Não Permite o Lançamento do N.S.")

oBrowse:Activate()
Return

Static Function MenuDef()
Local _aRet := {}

ADD OPTION _aRet Title 'Pesquisar'					Action 'PesqBrw'			OPERATION 1 ACCESS 0
ADD OPTION _aRet Title 'Visualizar'					Action 'VIEWDEF.FATA01P'	OPERATION 2 ACCESS 0
ADD OPTION _aRet Title 'Lançar Número de Série'		Action 'VIEWDEF.FATA01P'	OPERATION 4 ACCESS 0
ADD OPTION _aRet Title 'Ordem de Fornecimento'		Action 'U_FATA01PA("002")'	OPERATION 4 ACCESS 0
ADD OPTION _aRet Title 'Excluir Número de Série'	Action 'VIEWDEF.FATA01P'	OPERATION 5 ACCESS 0

Return(_aRet)

Static Function ModelDef()
Local oStSF2Cb := FWFormStruct( 1, 'SF2' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //Cabeçalho de Documento de Saída
Local oStSD2It := FWFormStruct( 1, 'SD2' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //Itens do Documento de Saída
Local oStSZ0It := FWFormStruct( 1, 'SZ0' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //Números de Série dos Itens do Documento.

Local _oModel // Modelo de dados que será construído

//Ajustando a Estrutura
	//CAMPOS OBRIGATÓRIOS:
	oStSF2Cb:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F.)
	oStSD2It:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F.)

//Criando o Objeto MODEL
_oModel := MPFormModel():New( 'FATA01PX', , /*{|_oModel| fVldExMdl(_oModel) } /*Validacao Antes da Gravação*/, /*{|_oModel| fGrvModel(_oModel) } /*Funcao de Gravacao Manual*/ )

_oModel:AddFields( 'SF2MASTER' , /*cOwner*/ , oStSF2Cb )
_oModel:AddGrid(   'SD2_ITENS' , 'SF2MASTER', oStSD2It, /* {|X, Y, Z| fVExclLn(X, Y, Z) } /*bLinePre*/ )
_oModel:AddGrid(   'SZ0_ITENS' , 'SD2_ITENS', oStSZ0It, /* {|X, Y, Z| fVExclLn(X, Y, Z) } /*bLinePre*/ )

//Setando o Relacionamento
_oModel:SetRelation( 'SD2_ITENS' , {{ 'D2_FILIAL'	, 'xFilial( "SD2" )' },;
									{ 'D2_DOC'		, 'F2_DOC' }, { 'D2_SERIE', 'F2_SERIE' }, { 'D2_CLIENTE', 'F2_CLIENTE' },;
									{ 'D2_LOJA'		, 'F2_LOJA' } }, SD2->( IndexKey(01) ) )
									
_oModel:SetRelation( 'SZ0_ITENS' , {{ 'Z0_FILIAL'	, 'xFilial( "SZ0" )' }	, { 'Z0_ENTSAI', '"S"' }, ;
									{ 'Z0_DOC'		, 'D2_DOC' }			, { 'Z0_SERIE', 'D2_SERIE' }, { 'Z0_CLIFOR', 'D2_CLIENTE' },;
									{ 'Z0_LJACF', 'D2_LOJA' }, {'Z0_ITEM', 'D2_ITEM'}, {'Z0_PRODUTO', 'D2_COD'} }, SZ0->( IndexKey(01) ) )
//Setando Chave Primária
_oModel:SetPrimaryKey( { "F2_FILIAL", "F2_DOC", "F2_SERIE", "F2_CLIENTE", "F2_LOJA" } )

_oModel:GetModel( 'SD2_ITENS'  ):SetUniqueLine( { 'D2_DOC', 'D2_SERIE', 'D2_ITEM' } )
_oModel:GetModel( 'SZ0_ITENS'  ):SetUniqueLine( { 'Z0_DOC', 'Z0_SERIE', 'Z0_ITEM', 'Z0_SEQ' } )

//Setando Modelo de Dados Opcional
_oModel:GetModel( 'SZ0_ITENS'  ):SetOptional( .T. )

//Não permita alteração em seus dados, apenas para visualização
_oModel:GetModel( 'SF2MASTER'  ):SetOnlyView ( .T. )
_oModel:GetModel( 'SD2_ITENS'  ):SetOnlyView ( .T. )

_oModel:GetModel( 'SF2MASTER' ):SetOnlyQuery ( .T. )
_oModel:GetModel( 'SD2_ITENS' ):SetOnlyQuery ( .T. )

_oModel:SetDescription( 'Documento x Número de Série' )

_oModel:GetModel( 'SF2MASTER'  ):SetDescription( 'Documento de Saída' )
_oModel:GetModel( 'SD2_ITENS'  ):SetDescription( 'Itens do Documento de Saída' )
_oModel:GetModel( 'SZ0_ITENS'  ):SetDescription( 'Itens do Documento de Saída x Número de Série' )

//Valida se o Modelo pode ser ativado
_oModel:SetVldActivate( {|_oMdl| fVldModel(_oMdl) })

Return(_oModel)

Static Function ViewDef()
Local oModel := FWLoadModel( 'FATA01P' ) //_MVC

// Cria as estruturas a serem usadas na View
Local oStSF2Cb := FWFormStruct( 2, 'SF2' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //Cabeçalho de Documento de Saída
Local oStSD2It := FWFormStruct( 2, 'SD2' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //Itens do Documento de Saída
Local oStSZ0It := FWFormStruct( 2, 'SZ0' /*, {|_cCampo| fCampoSZJ(_cCampo, "CB") }*/ ) //Números de Série dos Itens do Documento.


oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VW_SF2CB', oStSF2Cb, 'SF2MASTER'  )
oView:AddGrid(  'VW_SD2IT', oStSD2It, 'SD2_ITENS'  )
oView:AddGrid(  'VW_SZ0IT', oStSZ0It, 'SZ0_ITENS'  )

//oView:CreateHorizontalBox( 'TELA_FULL'  , 100 )
oView:CreateHorizontalBox( 'TELA_ACIMA' , 30 /*, 'TELA_FULL'*/ )
oView:CreateHorizontalBox( 'TELA_ABAIXO', 70 /*, 'TELA_FULL'*/ )
oView:CreateVerticalBox( 'ABAIXO_DIR', 60, 'TELA_ABAIXO' )
oView:CreateVerticalBox( 'ABAIXO_ESQ', 40, 'TELA_ABAIXO' )

oView:SetOwnerView( 'VW_SF2CB', 'TELA_ACIMA'  )
oView:SetOwnerView( 'VW_SD2IT', 'ABAIXO_DIR'  )
oView:SetOwnerView( 'VW_SZ0IT', 'ABAIXO_ESQ'  )

oView:EnableTitleView('VW_SF2CB','Documento de Saída')
oView:EnableTitleView('VW_SD2IT','Itens do Documento de Saída')
oView:EnableTitleView('VW_SZ0IT','Número de Série')

oView:AddIncrementField( 'VW_SZ0IT', 'Z0_SEQ' )

//Criando Botoes
//oView:AddUserButton("Arquivo DDA"	, "CLIPS", {|oView| fBscArqDDA()		/*Inserção de Blocos na Grid*/				})

//Valida se a Visão pode ser ativada
oView:SetViewCanActivate({|_oVW| fVldView(_oVW) })

Return(oView)

//Função para Validação da Ativação do Modelo
Static Function fVldModel(_oMdl)
Local _aArea		:= GetArea()
Local _lRet			:= .T.
Local _nOper		:= _oMdl:GetOperation()

IF _nOper == 3 //Incluir
	Help( ,, 'FATA01P - fVldModel',, "Não é permitido a Inclusão de Números de Séries.", 1, 0 )
	_lRet := .F.
ElseIf _nOper == 4 //Aletrar
	IF !EMPTY( SF2->F2_FIMP )
		Help( ,, 'FATA01P - fVldModel',, "Não é permitido o Lançamento de Número de Série para Documentos já Transmitidos.", 1, 0 )
		_lRet := .F.
	EndIF
ElseIF _nOper == 5 //Ecluir
	IF !EMPTY( SF2->F2_FIMP )
		Help( ,, 'FATA01P - fVldModel',, "Não é permitido EXCLUIR o Lançamento de Número de Série para Documentos já Transmitidos.", 1, 0 )
		_lRet := .F.
	EndIF
EndIF

Return(_lRet)

//Função para Validação da Ativação da Visão
Static Function fVldView(_oVw)
Local _aArea		:= GetArea()
Local _lRet			:= .T.
Local _nOper		:= _oVw:GetOperation()

IF _nOper == 3 //Incluir
	Help( ,, 'FATA01P - fVldView',, "Não é permitido a Inclusão de Números de Séries.", 1, 0 )
	_lRet := .F.
ElseIf _nOper == 4 //Aletrar
	IF !EMPTY( SF2->F2_FIMP )
		Help( ,, 'FATA01P - fVldView',, "Não é permitido o Lançamento de Número de Série para Documentos já Transmitidos.", 1, 0 )
		_lRet := .F.
	EndIF
ElseIF _nOper == 5 //Ecluir
	IF !EMPTY( SF2->F2_FIMP )
		Help( ,, 'FATA01P - fVldView',, "Não é permitido EXCLUIR o Lançamento de Número de Série para Documentos já Transmitidos.", 1, 0 )
		_lRet := .F.
	EndIF
EndIF

Return(_lRet)