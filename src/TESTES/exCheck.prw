#include "protheus.ch"
#include "rwmake.ch"
/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � CHECBOX    � Autor � Diogo C. Barros     � Data � 11.03.16 ���
���----------+------------------------------------------------------------���
���Descri��o � Exemplo de utiliza��o do elemento checkBox em um getDados. ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function exCheck
                               
	private oDlgTela
	private aHeader := {}  
	private cEstado := space(3)
	private aColsCidades := {}
	private lChkSel    := .F.            
	private lOkSalva   := .F.            
	private lChkFiltro := .F.   
	private oGetDados      
	static oChk, oChkFiltro

	//array de cabe�alho do GetDados
	//Neste caso ser�o 4 colunas incluindo o campo que possui caixa de sele��o ou checkBox
	aadd(aHeader,{''		  ,'CHECKBOL'     ,'@BMP', 2,0,,	             ,"C",     ,"V",,,'seleciona','V','S'})
	aadd(aHeader,{"C�digo"    ,"CC2_CODMUN"   ,"@!"  , 3,0,,"�������������� ","C","CC2","R"})	
	aadd(aHeader,{"Munic�pio" ,"CC2_MUN"      ,"@!"  ,30,0,,"�������������� ","C","CC2","R"})
	aadd(aHeader,{"Estado"    ,"CC2_EST"      ,"@!"  , 4,0,,"�������������� ","C","CC2","R"})	
                                                   
	//Nosso programa ir� listar todos os munic�pios e fazer filtros por Estado
	@003,003 to 530,1150 dialog oDlgTela title "Lista de Munic�pios"

	//Aqui onde o usu�rio informar� o estado que buscar� as cidades pertencentes
	@011,006 say "Estado: " pixel of oDlgTela                                   
	//este elemento get � a caixa de testo que possui a consulta padr�o (op��o F3).
	//esta consulta CC2EST foi configurada no Configurador somente para este uso
	@011,026 get cEstado size 30,11 F3 "CC2EST"
	                                                                            
	//Bot�o pesquisar que, quando acionado, efetua a busca dos munic�pios de acordo com o Estado inserido pelo usu�rio
	//a vari�vel cEstado armazena o conte�do existente no elemento "get" acima
	@012,125 button "&Pesquisar" size 40,11 pixel of oDlgTela action buscaCc2(cEstado)

	//O objeto oGetDados (MsNewGetDados) com os atributos configurados	
	oGetDados := MsNewGetDados():New(025,006,230,570, GD_UPDATE, , , , {'CHECKBOL','CC2_CODMUN','CC2_MUN','CC2_EST'}, 1, 99, , , , oDlgTela, aHeader, aColsCidades,,)
	//quando clicado duas vezes sobre o aCols[oGetDados:nAt,1], ou seja, onde ficar� a coluna com o checkbox, ele ir� alternar de LBOK para LBNO e vice versa
	oGetDados:oBrowse:bLDblClick := {|| oGetDados:EditCell(), oGetDados:aCols[oGetDados:nAt,1] := iif(oGetDados:aCols[oGetDados:nAt,1] == 'LBOK','LBNO','LBOK')}
	
	//objeto oChk de checkbox e vari�vel lChkSel. Quando clicado, executa o m�todo "seleciona" e possibilita 
	//que o usu�rio selecione todas as cidades ao mesmo tempo. Facilita tamb�m no momento da escolha em casos de listas extensas
	@240,006 checkbox oChk var lChkSel PROMPT "Selecionar todos" size 60,07 on CLICK seleciona(lChkSel)

	//botao confirmar comum, ainda daremos utilidade � ele :)	
   	@240,125 button "&Confirmar" size 40,11 pixel of oDlgTela action close(oDlgTela)
   	//bot�o padr�o de Cancelar
    @240,190 button "&Cancelar"  size 40,11 pixel of oDlgTela action close(oDlgTela)	         
	
	//antes de ativar a tela (oDlgTela) e centraliz�-la para o usu�rio, 
	//o m�todo "buscaCc2" pesquisa todas as cidades e estados para pr� carregar o oGetDados
    buscaCc2(cEstado)                                                                                                                     
	 
	//ativa o oDlgTela
    activate dialog oDlgTela center  
    
return                          
/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � BUSCACC2   � Autor � Renan R. Ramos      � Data � 11.03.16 ���
���----------+------------------------------------------------------------���
���Descri��o � Pesquisa as cidades de acordo com o estado escolhido. Caso ���
���          � cEstado esteja vazio, ser�o apresentadas todas as cidades e���
��           � estados presentes na tabela.                               ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function buscaCc2(cEstado)

	private aColsCidades := {}   
	//atualiza/recarrega o oGetDados e o oDlgTela antes de receber novos dados          
	refresh(aColsCidades)
	
	//abre a tabela CC2
	dbSelectArea("CC2")
	//'seta' primeiro �ndice (Filial+Estado+Munic�pio)
	dbSetOrder(1)                                                      
	//posiciona no topo da tabela
	dbGoTop()                      
	//faz a busca pelo �ndice informado utilizando o conte�do da vari�vel cEstado
	dbSeek(xFilial("CC2")+allTrim(cEstado))
	//enquanto n�o � final da tabela
	while CC2->(!eof())             
		//se o conte�do do campo CC2->CC2_EST igual ao conte�do de cEstado                        
		if allTrim(cEstado) = allTrim(CC2->CC2_EST)
			aadd(aColsCidades,{'LBNO', allTrim(CC2->CC2_CODMUN), allTrim(CC2->CC2_MUN), allTrim(CC2->CC2_EST),.F.})
		//se cEstado estiver vazio, adiciona todos 
		elseif empty(allTrim(cEstado))
			aadd(aColsCidades,{'LBNO', allTrim(CC2->CC2_CODMUN), allTrim(CC2->CC2_MUN), allTrim(CC2->CC2_EST),.F.})
		endif                                      
		//avan�a registro
		CC2->(dbSkip())
	endDo
	//atualiza o oGetDados com o novo array
	refresh(aColsCidades)

return
/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � REFRESH  � Autor � Renan Rodrigues Ramos � Data � 13.10.15 ���
���----------+------------------------------------------------------------���
���Descri��o � Realiza limpeza dos dados na MsGetDados e inclui novo array���
���----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function refresh(aDados)

	oGetDados:oBrowse:Refresh()                                                                                                                                    
	oDlgTela:Refresh()
	
	oGetDados := MsNewGetDados():New(025,006,230,570, GD_UPDATE, , , , {'CHECKBOL','CC2_CODMUN','CC2_MUN','CC2_EST'}, 1, 99, , , , oDlgTela, aHeader, aColsCidades,,)
	oGetDados:oBrowse:bLDblClick := {|| oGetDados:EditCell(), oGetDados:aCols[oGetDados:nAt,1] := iif(oGetDados:aCols[oGetDados:nAt,1] == 'LBOK','LBNO','LBOK')}

return
/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � seleciona� Autor � Renan Rodrigues Ramos � Data � 08.10.15 ���
���----------+------------------------------------------------------------���
���Descri��o � Seleciona todas as cidades apresentadas no aCols.          ���
���----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
static function seleciona(lChkSel)

	//percorre todas as linhas do oGetDados
	for i := 1 to len(oGetDados:aCols)
		//verifica o valor da vari�vel lChkSel
		//se verdadeiro, define a primeira coluna do aCols como LBOK ou marcado (checked)
		if lChkSel
			oGetDados:aCOLS[i,1] := 'LBOK'                                               
		//se falso, marca como LBNO ou desmarcado (unchecked)
		else
			oGetDados:aCOLS[i,1] := 'LBNO'
		endif	
	next     
	//executa refresh no getDados e na tela
	//esses m�todos Refresh() s�o pr�prio da classe MsNewGetDados e do dialog
	//totalmente diferentes do m�todo est�tico definido no corpo deste fonte
	oGetDados:oBrowse:Refresh() 
	oDlgTela:Refresh()

return
/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � selFiltro� Autor � Renan Rodrigues Ramos � Data � 03.03.16 ���
���----------+------------------------------------------------------------���
���Descri��o � Executa o filtro de cidades selecionadas.                  ���
���----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
static function selFiltro(lChkFiltro)

	buscaCc2(lChkFiltro)//atualiza o grid de dados
	
	oGetDados:oBrowse:Refresh() 
	oDlgTela:Refresh()

return
/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � VERIFLIN � Autor � Renan Rodrigues Ramos � Data � 09.10.15 ���
���----------+------------------------------------------------------------���
���Descri��o � Verifica se existem cidades selecionadas.                  ���
���----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function verifLin()

	local lRet := .F.
	           
	for i := 1 to len(oGetDados:aCols)
	    if oGetDados:aCols[i,1] == 'LBOK'		
			aadd(aCidades,{oGetDados:aCols[i,2],oGetDados:aCOLS[i,3],oGetDados:aCOLS[i,4]})
			lRet := .T.                  				
		endIf   
	next 
       
return lRet