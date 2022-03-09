#SingleInstance, Force
FileEncoding, UTF-8 ; pra funcionar o emoji tem que salvar o arquivo como UTF-8-BOM
SetBatchLines, -1

; variaveis globais
dirAtual := ""

; GUI extensao do arquivo
Gui, Add, Text, x22 y59 w170 h20, Arquivo.extensao (* = tudo)
Gui, Add, Edit, x22 y79 w180 h20 vNomeExt, nome*.ext

; GUI pasta para procurar ele
Gui, Add, Text, x22 y9 w100 h20, Pasta para procurar
Gui, Add, Edit, x22 y29 w400 h20 vPastaProcurar, % A_ScriptDir
Gui, Add, Button, x425 y27 w33 h26 gSelecionarPasta, 📂

; GUI botao procurar
Gui, Add, Button, x182 y109 w100 h30 gProcurarArquivos, Procurar

; GUI exibir arquivos encontrados
Gui, Add, ListView, AltSubmit r20 x22 y169 w430 h180 gAbrirPastaArquivo, Arquivos Encontrados
Gui, Font, s11
Gui, Add, Text, x160 y149 w190 h20 vMsgEncontrados,
;Gui, Add, Button, x22 y349 w40 h30 , <
;Gui, Add, Button, x412 y349 w40 h30 , >

Gui, Show, w468 h358, FileFinder
return

; Labels:
GuiDropFiles: ; arrastou algo pra dentro
	if InStr( FileExist(A_GuiEvent),"D" ) ; apenas se for uma pasta
	{
		GuiControl,, pastaProcurar, % A_GuiEvent
		pastaProcurar := % A_GuiEvent
	} Else { ; se nao for uma pasta
		MsgBox, 16, Selection Error, Pasta Inválida
	}
	
	Return
SelecionarPasta:
	Gui, Submit, NoHide
	FileSelectFolder, pastaSelecionada, %dirAtual%, 0, Selecione uma pasta para procurar
	If(ErrorLevel=1) ; apertou cancelar
		Return
	
	GuiControl,, pastaProcurar, % pastaSelecionada
	pastaProcurar := % pastaSelecionada
	Return
ProcurarArquivos:
	Gui, Submit, NoHide
	LV_Delete() ; limpa a lista de encontrados

	If(SubStr(pastaProcurar,0,1) != "\"){ ; adiciona no final da pasta eh o \
		pastaProcurar .= "\"
	}

	contFiles := 0
	Loop, Files, %pastaProcurar%%nomeExt%, R ; cada linha de arquivo encontrado vai pra variavel %A_LoopFileFullPath%
	{
		LV_Add("",A_LoopFileFullPath)
		contFiles++
	}

	GuiControl,, msgEncontrados, Encontrado %contFiles% Arquivo(s)
	Return
AbrirPastaArquivo:
	Gui, Submit, NoHide
	LV_GetText(arquivo, A_EventInfo)
		
	if A_GuiEvent = Normal
	{
		ToolTip, % arquivo
		setTimer, LimparTT, -3000
	}
	Else If A_GuiEvent = RightClick
	{
		Clipboard := % arquivo
		ToolTip, Caminho Copiado!
		setTimer, LimparTT, -3000
	}
	Else If A_GuiEvent = DoubleClick
	{
		; seleciona apenas a pasta
		arquivoPath := StrSplit(arquivo,"\")
		arquivoPath.Pop()
		pastaPath := arrToStr(arquivoPath)
		; abrir pasta do arquivo
		Run, %pastaPath%
	}
	Return

LimparTT: ; limpa o tooltip
	ToolTip
	Return
GuiClose: ; fecha o app
	ExitApp

; Funcões:
arrToStr(arquivoPath){ ; converter um array para uma string
	pastaPath := ""
	For index, elem In arquivoPath
		pastaPath .= elem . "\"
	
	pastaPath := RTrim(pastaPath,"\")
	return %pastaPath%
}