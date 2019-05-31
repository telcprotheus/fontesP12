#include "totvs.ch"
#include "fwmvcdef.ch"

user Function TST01MVC()

Local oBrw

//Instaciamento
oBrw := FWMBrowse():New()

//tabela que será utilizada
oBrw:SetAlias( "ZPY" )

//Titulo
oBrw:SetDescription( "Produtos Licitados" )

//ativa
oBrw:Activate()

Return