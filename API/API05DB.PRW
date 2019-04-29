#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL PRODUTOS DESCRIPTION "Retorna os produtos"
	WSMETHOD GET DESCRIPTION "Retorna os produtos" WSSYNTAX "/produtos/"
END WSRESTFUL

WSMETHOD GET WSSERVICE PRODUTOS
	Local nI := 1
	
	dbSelectArea("SB1")
	SB1->(dbGoTop())
	
	::SetResponse('[')
	
	While SB1->(!EOF())
		If nI > 1
			::SetResponse(',')
		Endif
		::SetResponse('{')
		::SetResponse('"Filial":"' + alltrim(SB1->B1_FILIAL)+ '",')
		::SetResponse('"Codigo":"' + alltrim(SB1->B1_COD)+ '",')
		::SetResponse('"Descricao":"' + alltrim(SB1->B1_DESC)+ '"')
		::SetResponse('"Cod.Barra":"' + alltrim(SB1->B1_CODBAR)+ '"')
		::SetResponse('"Unidade Medida":"' + alltrim(SB1->B1_UM)+ '"')
		::SetResponse('"Tipo":"' + alltrim(SB1->B1_TIPO)+ '"')
		::SetResponse('}')
		nI++
		SB1->(dbSkip())
	End While
	
	::SetResponse(']')
Return .T.