;===============================================================================
; Mastermind.as
;
; Descricao: Jogo de tabuleiro mastermind
;
; Autor: Guilherme Guerreiro e Hugo Andrade
; Data: 4/05/2017 				Ultima Alteracao:4/05/2017
;===============================================================================

;===============================================================================
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;===============================================================================
; STACK POINTER
SP_INICIAL      EQU     FDFFh

; I/O a partir de FF00H
IO_PRESS		EQU		FFFDh		;Porto que indica sempre que uma tecla é pressionada
IO_CURSOR       EQU     FFFCh		;Porto onde se escreve o endereço do cursor no ecra
IO_WRITE        EQU     FFFEh		;Porto que escreve o valor que contem no ecra
IO_READ			EQU		FFFFh		;Porto que lê o valor ascii da tecla pressionada
DISP7S1			EQU 	FFF0h		;Portos dos displays de 7segmentos
DISP7S2 		EQU 	FFF1h		
DISP7S3 		EQU 	FFF2h
DISP7S4 		EQU 	FFF3h		
TEMP_VALUE		EQU		FFF6h		;Porto onde se escreve o tempo que se pretende contar (x intervalos de 100ms)     
TEMP_ENABLE		EQU		FFF7h		;enable da contagem
INT_MASK		EQU		FFFAh		;Mascara das interrupções

LIMPAR_JANELA   EQU     FFFFh		;Valor  passar ao IO_WRITE para limpar o ecra
XY_INICIAL      EQU     0000h		;Coordenada incial do cursor na janela(canto superior esquerdo)
FIM_TEXTO       EQU     '@'			;Caracter indicador de fim de texto. Usado para marcar o fim de uma string


;Interruptores					;endereços de memoria onde as açoes sobre os interruptores escrevem
GAME_INT0       EQU     FE00h	;Interrupção 0
GAME_INTEMP     EQU     FE0Fh	;interrupções vindas do temporizador (15)

MASK			EQU		5297h	;mascara para calculo do nr aleatorio



;===============================================================================
; ZONA II: Definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres.
;          Cada caracter ocupa 1 palavra
;===============================================================================
				ORIG    8000h
				
StartText1		STR		'*Mecanica do jogo:',FIM_TEXTO                                                                        
StartText2		STR		'-O jogador deve adivinhar uma sequencia de 4 cores gerada pela maquina.',FIM_TEXTO                                                                      
StartText3		STR		'-Tem 10 tentativas para acertar na sequencia, ao fim das quais perde o jogo.',FIM_TEXTO                                                                   
StartText4		STR		'-A maquina avaliara cada jogada com as letras P e B.',FIM_TEXTO                                                                     
StartText5		STR		'-P indica o nr de cores corretas nas posicoes corretas.',FIM_TEXTO                                                               
StartText6		STR		'-B indica o nr de cores corretas nas posicoes erradas.',FIM_TEXTO                 
StartText7		STR		'-O codigo de cores usado pela maquina e o seguinte:',FIM_TEXTO
StartText8		STR		'B-branco, P-preto, E-encarnado, V-verde, Z-azul, A-amarelo',FIM_TEXTO
StartText9		STR		'*Comandos de jogo:',FIM_TEXTO
StartText10		STR		'-Teclas B,P,E,V,Z,A para introduzir cores na jogada.',FIM_TEXTO
StartText11		STR		'-N Para recomecar tudo',FIM_TEXTO
StartText12		STR		'-Apos o fim de cada jogo, pressione qq tecla para passar ao proximo jogador.',FIM_TEXTO	
AvancaText		STR		'***PRESSIONE QUALQUER TECLA PARA AVANCAR***',FIM_TEXTO

WelcomeText1 	STR 	' ___      _       __        ________  ___________  _______   _______   ___      ___   __    _____  ___   ________  ',FIM_TEXTO
WelcomeText2	STR		'|"  \    /"|     /""\      /"       )("     _   ")/"     "| /"      \ |"  \    /"  | |" \  (\"   \|"  \ |"      "\  ',FIM_TEXTO
WelcomeText3	STR		' \   \  // |    /    \    (:   \___/  )__/  \\__/(: ______)|:        | \   \  //   | ||  | |.\\   \    |(.  ___  :)',FIM_TEXTO
WelcomeText4	STR		' /\\  \/.  |   /" /\  \    \___  \       \\_ /    \/    |  |_____/   ) /\\  \/.    | |:  | |: \.   \\  ||: \   ) ||',FIM_TEXTO
WelcomeText5	STR		'|: \.      |  //  __   \    __/  \\      |.  |    // ___)_  //      / |: \.        | |.  | |.  \    \. |(| (___\ || ',FIM_TEXTO
WelcomeText6	STR		'|.  \    /:| /   /  \\  \  /" \   :)     \:  |   (:      "||:  __   \ |.  \    /:  | /\  |\|    \    \ ||:       :) ',FIM_TEXTO
WelcomeText7	STR		'|___|\__/|_|(___/    \___)(_______/       \__|    \_______)|__|  \___)|___|\__/|___|(__\_|_)\___|\____\)(________/  ',FIM_TEXTO

Title       	STR     '***  Mastermind  ***',FIM_TEXTO
Separador       STR		'-------------------', FIM_TEXTO
Tabuleiro       STR     '|  |  |  |  |    |', FIM_TEXTO
Tabuleiro5		STR		'|  |  |  |  |  |     |',FIM_TEXTO
Tabuleiro6		STR		'|  |  |  |  |  |  |      |',FIM_TEXTO
TabSol			STR		'|  |  |  |  |',FIM_TEXTO
TabSol5			STR		'|  |  |  |  |  |',FIM_TEXTO
TabSol6			STR		'|  |  |  |  |  |  |',FIM_TEXTO
Options			STR		'Opcoes de jogo', FIM_TEXTO
Timeop			STR		'Tempo de jogo (1, 2 ou 4):',FIM_TEXTO
Colorop			STR		'Numero de cores (4, 5 ou 6):',FIM_TEXTO 
Jogop			STR		'Numero de jogadores(1 a 5):',FIM_TEXTO
win				STR		'Parabens ACERTOU!!!',FIM_TEXTO
lose			STR		'Perdeu. Tente de novo!',FIM_TEXTO


CodCor			STR		'BPEVZA',FIM_TEXTO	;Todas as cores disponiveis. Esta variável é usada para se selecionar a sequencia
Solucao			STR		0,0,0,0,0,0	;Vetor que guarda a solução(sequencia gerada)
DupSolucao		STR		0,0,0,0,0,0	;Duplicado da Vetor solução(para permitir edições aos elementos durante a avaliação da jogada, sem se perder a solução)
Jogada			STR		0,0,0,0,0,0 ;Vetor que guarda cada sequencia introduzida pelo jogador

;Variaveis 
RAND_NUM		WORD	0	;Variavel para guardar o nr aleatório gerado
SEED			WORD	0	;variavel para guardar a seed aleatória


;Parametros de jogo introduzidos
timeesc			WORD	0	;Tempo de jogo
coresc			WORD	0	;Qtd de cores
jogesc			WORD 	0	;Nr de jogadores

n_p				WORD	0	;Nr de cores no local correto
n_b				WORD	0	;Nr de cores certas

TimeFlag		WORD	0	;Sinaliza que houve interrupção do temporizador
GameEND			WORD	0   ;Variavel de estado(2=GameENDWIN, 1=GameENDLose, 0=GameRunning)
DecMin			WORD	6	;Décima de minuto (valor do segundo display de 7seg)
Time			WORD	0	;Valor atual do tempo (variavel que decrementa a cada segundo)
cursor			WORD	31Ch;Zona do ecrã para escrever o primeiro caracter da jogada
newline			WORD	0	;Nr de caracteres que o jogador tem que escrever antes de ser feita a avaliação e avançar para a proxima linha do tabuleiro
n_jogadas		WORD	10	;Nr de tentativas
posjogada		WORD	0	;Sinaliza em qual elemento do vetor jogada se vai escrever o proximo caracter
CursorAval		WORD	32bh;Zona do ecra onde se escreverá o primeiro caracter da avaliação da jogada

;===============================================================================
; ZONA III: Codigo
;           conjunto de instrucoes Assembly, ordenadas de forma a realizar
;           as funcoes pretendidas
;===============================================================================
                ORIG    0000h
                JMP     inicio

;===============================================================================
; LimpaJanela: Rotina que limpa a janela de texto.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
LimpaJanela:    PUSH 	R2
                MOV     R2, LIMPAR_JANELA
				MOV     M[IO_CURSOR], R2
                POP 	R2
                RET
					
;=============================================================================
;WELCOME:	Rotina que imprime o ecra de boas vindas
;=============================================================================
WELCOME:	PUSH R1
			PUSH R2
			MOV	R2, 45A3h
				
			PUSH Title
			MOV	R1, 001Eh
			PUSH R1
			CALL EscString				
			PUSH WelcomeText1
			MOV	R1, 0200h
			PUSH R1
			CALL EscString
			PUSH WelcomeText2
			ADD	R1, 0100h
			PUSH R1
			CALL EscString
			PUSH WelcomeText3
			ADD	R1, 0100h
			PUSH R1
			CALL EscString
			PUSH WelcomeText4
			ADD R1, 0100h
			PUSH R1
			CALL EscString
			PUSH WelcomeText5
			ADD	R1, 0100h
			PUSH R1
			CALL EscString
			PUSH WelcomeText6
			ADD	R1, 0100h
			PUSH R1
			CALL EscString
			PUSH WelcomeText7
			ADD	R1, 0100h
			PUSH R1
			CALL EscString
			PUSH AvancaText
			ADD	R1, 0212h
			PUSH R1
			CALL EscString
				
nokeypressed:	CMP	M[IO_PRESS], R0	;Verifica se foi premida alguma tecla
				BR.Z nokeypressed
				
proximo:		CMP	M[IO_PRESS], R0	;De forma a evitar que a mesma pressão de tecla avance dois ecrãs de seguida
				BR.Z proximo
				CALL LimpaJanela
				POP	R2
				POP	R1
				RET				
				

;===============================================================================
; STARTSCREEN: Função de escrita do ecra inicial onde inclui as regras do jogo, os
;				comandos do jogo e os modos de jogo. 
;
;Dado não ser possível com as operações suportadas pelo processador alocar memória contínua e inicializa-la com o texto pretendido,
;o bloco de texto tem que ser "impresso" string a string (linha a linha)        
;===============================================================================
STARTSCREEN:	PUSH R1	
				PUSH Title
				MOV R1, 001Eh
				PUSH R1
				CALL EscString			
				PUSH StartText1
				MOV	R1, 0200h
				PUSH R1
				CALL EscString
				PUSH StartText2
				ADD	R1, 0100h
				PUSH R1
				CALL EscString
				PUSH StartText3
				ADD	R1, 0100h
				PUSH R1
				CALL EscString
				PUSH StartText4
				ADD R1, 0100h
				PUSH R1
				CALL EscString
				PUSH StartText5
				ADD	R1, 0100h
				PUSH R1
				CALL EscString
				PUSH StartText6
				ADD	R1, 0100h
				PUSH R1
				CALL EscString
				PUSH StartText7
				ADD	R1, 0100h
				PUSH R1
				CALL EscString
				PUSH StartText8
				ADD	R1, 0100h
				PUSH R1
				CALL EscString
				PUSH StartText9
				ADD	R1, 0200h
				PUSH R1
				CALL EscString
				PUSH StartText10
				ADD	R1, 0100h
				PUSH R1
				CALL EscString
				PUSH StartText11
				ADD	R1, 0100h
				PUSH R1
				CALL EscString
				PUSH StartText12
				ADD	R1, 0100h
				PUSH R1
				CALL EscString
				PUSH AvancaText
				ADD R1, 0212h
				PUSH R1
				CALL EscString
				
				MOV	R1, 45A3h  ;Valor aleatório(ponto de partida para o incremento da seed)
ClearK:			CMP	M[IO_READ], R0
				INC	R1
				BR.NZ ClearK
				
UsrCmd1:		INC	R1						;Espera que o utilizador prima alguma tecla para avançar no ecra de instruções
				MOV	M[SEED], R1				;Equanto executa este loop incrementa o R1 que servirá posteriormente como seed
				CMP	M[IO_READ], R0			;para a sequencia de cores
				BR.Z UsrCmd1
				CALL LimpaJanela
				POP	R1
				RET
				
;===============================================================================
; OPTIONSSCREEN: Função de escrita do ecra onde se escolhem as opções de jogo. 
;      			Cria o ecrã e lê os parametros
;===============================================================================
OPTIONSSCREEN:	PUSH	R1
				PUSH	R2
				PUSH 	R3
				
				MOV R3, R0
				
				PUSH	Options
				MOV		R1, 001Eh
				PUSH	R1
				CALL	EscString
				
				PUSH 	Timeop
				MOV		R1, 0200h
				PUSH	R1
				CALL	EscString
				
				PUSH 	Colorop	
				ADD		R1, 0100h
				PUSH	R1
				CALL	EscString

				PUSH Jogop	
				ADD	R1, 0100h
				PUSH R1
				CALL EscString					
				
timeval:	MOV		R2, M[IO_PRESS]	;Escolha do tempo de jogo
			CMP		R2, R0
			BR.Z	timeval
			MOV		R2, M[IO_READ]		;Verifica se o caracter escrito corresponde a um valor de tempo correto
			CMP		R2, '1'             ;
			BR.Z	printtime           ;
			CMP		R2, '2'             ;
			BR.Z	printtime           ;
			CMP		R2, '4'             ;
			BR.Z	printtime           ;
			BR		timeval

printtime:	MOV	R1, 021bh	;Escreve o valor introduzido para o tempo
			MOV	M[IO_CURSOR], R1
			MOV M[IO_WRITE], R2
			CMP	R2, '2'
			BR.N UmMin	;Comparação para fazer a conversão ASCII para valor de tempo útil
			BR.P QuatMin
			MOV	R1, 120	;2 min
			MOV M[timeesc], R1
			BR cornum
UmMin:		MOV	R1, 60	;1 min
			MOV M[timeesc], R1
			BR cornum
QuatMin:	MOV	R1, 240	;4 min
			MOV M[timeesc], R1		
					
cornum:		MOV		R2, M[IO_PRESS]	;Escolha do nr de cores com que se pretende jogar
			CMP		R2, R0
			BR.Z	cornum
			MOV		R2, M[IO_READ]		;Verifica se o caracter escrito corresponde a um valor de cores correto
			CMP		R2, '4'             ;
			BR.Z	printcor            ;
			CMP		R2, '5'             ;
			BR.Z	printcor            ;
			CMP		R2, '6'             ;
			BR.Z	printcor            ;
			BR	cornum	
		
printcor:	MOV	R1, 031ch	;Escrita do valor no ecra
			MOV	M[IO_CURSOR], R1
			MOV M[IO_WRITE], R2
			CMP R2, '5'		;Comparação para fazer a conversão ASCII para nr de cores efetivo
			BR.N QuatCor
			BR.P SixCor
			MOV	R1, 5
			MOV	M[coresc], R1
			JMP Jog	
QuatCor:	MOV	R1, 4
			MOV M[coresc], R1
			JMP Jog
SixCor:		MOV	R1, 6
			MOV M[coresc], R1
			
Jog:		MOV R1, M[IO_PRESS]	;Escolha do nr de jogadores
			CMP	R1, R0			
			BR.Z Jog
			MOV R2, M[IO_READ]	;Validação da tecla premida
			CMP	R2, '1'             
			BR.Z printjog
			CMP	R2, '2'             
			BR.Z printjog
			CMP	R2, '3'             
			BR.Z printjog			
			CMP	R2, '4'            
			BR.Z printjog            
			CMP	 R2, '5'             
			BR.Z printjog
			BR	Jog
			
printjog:	MOV	R1, 041bh	;Escrita no ecra do nr de jogadores escolhido
			MOV	M[IO_CURSOR], R1
			MOV M[IO_WRITE], R2
			MOV	R1, 48		;Versão mais SOFISTICADA do processo de validação.
search:		INC R1			;Percorre os valores referentes aos nr's na tabela ascii
			INC R3			;Incrementa enquanto não se encontra o nr pretendido
			CMP R1, R2		;Quando for encontrado o valor ascii referente à tecla pressionada
			BR.NZ search
			MOV M[jogesc], R3  ;Guarda o valor "real" do nr, não o valor ascii		
			
			
nxtscreen:	PUSH AvancaText	;"Pressione qq tecla para avançar"
			MOV	R1, 0815h
			PUSH R1
			CALL EscString
				
waitpress:	MOV R1, M[IO_PRESS]
			CMP	R1, R0
			BR.Z waitpress
			
			MOV	R1, M[coresc]	;Guarda em newline o nr de caracteres que têm que ser introduzidos, antes de se processar a avaliação
			MOV M[newline], R1
			
			CALL	LimpaJanela
			POP		R3
			POP		R2
			POP		R1
			RET				
;===============================================================================
; EscCar: Rotina que efectua a escrita de um caracter para o ecran.
;         O caracter pode ser visualizado na janela de texto.
;               Entradas: R1 - Caracter a escrever
;               Saidas: ---
;               Efeitos: alteracao da posicao de memoria M[IO]
;===============================================================================
EscCar:         MOV     M[IO_WRITE], R1
                RET  

;===============================================================================
; EscString: Rotina que efectua a escrita de uma cadeia de caracteres, terminada
;            pelo caracter FIM_TEXTO, na janela de texto numa posicao 
;            especificada. Pode-se definir como terminador qualquer caracter 
;            ASCII. 
;               Entradas: pilha - posicao para escrita do primeiro carater 
;                         pilha - apontador para o inicio da "string"
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
EscString:      PUSH    R1
                PUSH    R2
				PUSH    R3
                MOV     R2, M[SP+6]   ; Apontador para inicio da "string"
                MOV     R3, M[SP+5]   ; Localizacao do primeiro carater
Ciclo:          MOV     M[IO_CURSOR], R3
                MOV     R1, M[R2]
                CMP     R1, FIM_TEXTO
                BR.Z    FimEsc
                CALL    EscCar
                INC     R2
                INC     R3
                BR      Ciclo
FimEsc:         POP     R3
                POP     R2
                POP     R1
                RETN    2                ; Actualiza STACK

;==============================================================================
;TABGEN			TABULEIRO (DESENHA O TABULEIRO DO JOGO)
;==============================================================================

 TABGEN:	PUSH	R1
			PUSH 	R2
			
			PUSH    Title
			MOV		R1, 001Eh
			PUSH	R1
			CALL    EscString
			PUSH    Separador          
			ADD     R1, 0200h	
			PUSH 	R1					
			CALL    EscString
		
			MOV	R2, M[coresc]	;Calcula o nr de linhas a serem desenhadas. Referente ao nr de cores escolhidas
			CMP R2, 5
			BR.Z Ciclotab2
			JMP.P Ciclotab3
					
Ciclotab1:	PUSH Tabuleiro    ;Tabuleiro para jogadas de 4 cores    
			ADD R1, 0100h           
			PUSH R1
			CALL EscString 
			CMP	R1, 0C00h
			BR.N Ciclotab1				
			PUSH Separador         
			ADD R1, 0100h
			PUSH R1 
			CALL EscString
			JMP endboard
			
Ciclotab2:	PUSH Tabuleiro5     ;Tabuleiro para jogadas de 5 cores      
			ADD R1, 0100h              
			PUSH R1
			CALL EscString 
			CMP	R1, 0C00h
			BR.N Ciclotab2				
			PUSH Separador         
			ADD R1, 0100h
			PUSH R1 
			CALL EscString
			BR endboard
			
Ciclotab3:	PUSH Tabuleiro6     ;Tabuleiro para jogadas de 6 cores      
			ADD R1, 0100h             
			PUSH R1
			CALL EscString 
			CMP	R1, 0C00h
			BR.N Ciclotab3				
			PUSH Separador         
			ADD R1, 0100h
			PUSH R1 
			CALL EscString

endboard:	POP R2
			POP	R1
			RET
			
;===============================================================================
;RANDGEN			Random Number Generator
;			gera um nr aleatório com base na seed e na MASK
;===============================================================================

RANDGEN:	PUSH R1
			MOV	R1, M[SEED]		
			ROR	R1, 1			;
			BR.N Negative		;Verificação se o ultimo bit é 1 ou 0
			BR.NN NNegative		;
			
NNegative:	ROR R1, 4		
			BR StoreNum	
							;Conjunto de operações destinado a gerar um nr pseudo aleatório
Negative:	XOR	R1, MASK	;
			ROR	R1, 1		
				
StoreNum:	MOV	M[RAND_NUM], R1
			POP	R1
			RET			
			
;===============================================================================
;CORSEQ						Gera Sequencia de Cores
;===============================================================================

CORSEQ:		PUSH R1
			PUSH R3
			PUSH R4
			PUSH R5
			PUSH R6
			PUSH R7

			MOV	R1, M[coresc]	;Total de cores a incluir na sequencia de cores			
			MOV	R6, Solucao		;Endereço do vetor com a solução
			CALL RANDGEN		;Gera nº aleatório
			MOV	R3, M[RAND_NUM]			;R3 <- nº aleatório	

StoreSeq:	MOV	R4, 6h				;Divisor
			DIV	R3,	R4				;R4 <- Resto
			MOV	R7, M[R4+CodCor]	;R7 <- conteudo do endereço (CodCor + resto)=cor selecionada
			MOV	M[R6], R7			;R6=Solucao, copia cor selecionada para string solucao 
			INC	R6
			DEC R1
			BR.NZ StoreSeq
			POP R7
			POP R6
			POP R5
			POP R4
			POP R3
			POP R1
			RET

;===============================================================================
; STOPI0: 		Interrupcao 0
;               Entradas: 
;               Saidas: 
;               Efeitos: Para o jogo e mostra a solucao
;===============================================================================			
STOPI0:	INC	M[GameEND]
		RTI			
			
;====================================================================================
;WRITESOL				Escreve a solucao no ecra
;====================================================================================
WRITESOL:PUSH R1
		 PUSH R2
		 PUSH R3
		 PUSH R4
		 
		 MOV R2, Solucao
		 MOV R1, 0D1Eh
		 MOV R4, M[coresc]
		 CMP R4, 5	;Calcula qts cores têm a solução e imprime espaço no ecra suficiente para as mostrar todas
		 BR.Z tabsol5
		 BR.P tabsol6
		 
		 PUSH TabSol	;Imprime zona do tabuleiro para mostrar solucao com 4 cores
		 PUSH R1
		 CALL EscString
		 INC R1
		 BR WSol
		 
tabsol5: PUSH TabSol5	;Imprime zona do tabuleiro para mostrar solucao com 5 cores
		 PUSH R1
		 CALL EscString
		 INC R1
		 BR WSol
tabsol6: PUSH TabSol6	;Imprime zona do tabuleiro para mostrar solucao com 6 cores
		 PUSH R1
		 CALL EscString
		 INC R1
		  
WSol:	 MOV	R3, M[R2]			;percorre a string solucao
		 MOV	M[IO_CURSOR], R1	;indica posicao do cursor
		 MOV	M[IO_WRITE], R3		;escreve na zona indicada pelo cursor
		 ADD	R1, 0003h			;anda para a direita no eixo dos x
		 INC	R2
		 DEC	R4
		 BR.NZ	WSol
		 POP R4
		 POP R3
		 POP R2
		 POP R1
		 RET
		
;===============================================================================
;INPUT: 		Imprime as cores escolhidas pelo jogador
;===============================================================================
INPUT:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH	R5
		PUSH	R6
		
		MOV		R2, M[cursor]		;Posição inicial onde se escreve a jogada
		ADD		R2, 0003h
		MOV		R4, M[n_jogadas]
		
gain:	MOV	R5, Jogada
		
corval:	MOV		R1, M[IO_PRESS]
		CMP		R1, R0
		JMP.Z	nokey
		MOV		R1, M[IO_READ]		;Verifica se o caracter escrito corresponde a uma cor
		CMP		R1, 'A'             ;
		BR.Z	print               ;
		CMP		R1, 'B'             ;
		BR.Z	print               ;
		CMP		R1, 'E'             ;
		BR.Z	print               ;
		CMP		R1, 'P'				;Guarda en R1 o valor da tecla premida
		BR.Z	print               ;
		CMP		R1, 'V'             ;
		BR.Z	print               ;
		CMP		R1, 'Z'             ;
		BR.Z	print          		;
		JMP   	nokey               ;
		
print:	MOV		M[IO_CURSOR], R2	;Caso o caracter escrito corresponder a uma cor escreve-o
		MOV		M[cursor], R2
		CALL 	EscCar
		MOV	R6, M[posjogada]	;posjogada contem o valor 1,2,3,4,5 ou 6 referente à posição em que se vai escrever no vetor jogada
		ADD	R5, R6
		MOV	M[R5], R1			;Escreve o caracter no vetor "Jogada"
		INC	M[posjogada]		
		DEC	M[newline]			;qd newline chega a zero(foram introduzidos o nr de caracteres correspondentes ao escolhido) salta para uma nova tentativa
		BR.Z 	nextline
		JMP		corval		
		
nextline:	CALL	AVALIA	;avalia a jogada
			ADD		R2, 0100h		;Quando o jogador acaba a jogada muda de linha
			MOV	R1, M[coresc]
			CMP R1, 5	;Calcula a nova posição do cursor para escrever a proxima jogada
			BR.P sixback
			BR.N fourback
			MOV R1, 15
			BR realign
sixback: 	MOV R1, 18
			BR realign
			
fourback:	MOV	R1,	12
			
realign:	SUB	R2, R1	;Subtrai ao X do cursor o nr de caracteres escritos+toda a formatação da tabela
			MOV	M[cursor], R2
			MOV R3, M[coresc] ;Recinicializa newline
			MOV M[newline], R3
			MOV M[posjogada], R0 ;Reinicializa posjogada
			DEC	M[n_jogadas]	;decrementa o nr total de jogadas
			BR.Z	Sol			;qd chegar a 0 acaba o jogo
			JMP		gain
			
Sol:	CALL	WRITESOL	;Quando acabam as jogadas mostra a solução
		
nokey:	pop		R6
		POP		R5
		POP		R4
		POP		R3
		POP		R2
		POP		R1		
		RET

;===============================================================================
;AVALIA: 		Avalia a jogada
;		Descrição do algoritmo de verificação
;
;Primeiro são avaliadas posições equivalentes nos vetores da jogada e da solução. Sempre qe é encontrada uma correspondecia
;essas entradas são colocadas a 0 e é incrementado M[n_p], variavel que guarda registo de qts P's devem ser escritos
;Apos verificar todas as posições equivalentes são verificadas todas as posições não equivalentes da seguinte forma:
;
;Para uma cor no vetor jogada é percorrido o vetor solução à procura de cores equivalentes. Se a posição atual de jogada for 0 passa para a 
;proxima posição e volta a percorrer a string solução (sempre a partir do inicio).
;Se o valor da posição do vetor solução for 0, passa para a proxima posição enquanto não chegar ao fim desse vetor.
;Qd se chega ao fim do vetor solução avança-se na posição do vetor jogada e "reinicia-se" o registo que percorre a string solução.
;A avaliação acaba quando todas as posições da jogada forem comparadas com todas as posições da solução
;===============================================================================
AVALIA:		PUSH	R1
			PUSH	R2
			PUSH	R3
			PUSH	R4
			PUSH	R5
			PUSH	R6
			PUSH	R7
			
			MOV R4, M[coresc]		
			MOV	R1, DupSolucao	;Endereço da primeira posição do vetor
			MOV	R2, Solucao
dupstring:	MOV	R3, M[R2]		;Duplica a solução para dupsolução. A partir daqui nesta rotina só se trabalhará com o duplicado
			MOV M[R1], R3
			INC	R1
			INC R2
			DEC	R4
			BR.NZ dupstring
			
			MOV		R6, Jogada
			MOV		R5, DupSolucao
			MOV	R4, M[coresc]	;Nr de cores existentes no vetor
			MOV		M[n_p], R0
			MOV		M[n_b], R0

test1:		MOV	R1, M[R6]			;Avalicao de cores corretas em local correto
			MOV	R2, M[R5]			;O algoritmo avalia o "mesmo elemento" dos vetores ao mesmo tempo
			CMP	R1, R2				;Ou seja, compara cores apenas nas mesmas posições dos dois vetores
			BR.NZ skip
			INC	M[n_p]				;Sempre que encontra uma correspondencia, incrementa o nº de P's a escrever
			MOV	M[R5], R0			;Elimina ambas as entradas para não serem avaliadas outra vez posteriormente
			MOV	M[R6], R0			;Pelo teste das cores corretas em posições erradas			
skip:		INC	R5					;Passa para a próxima posição a comparar
			INC	R6
			DEC	R4
			CMP	R4, R0
			BR.NZ test1

			MOV	R4, R0		;Reinicializa registos de controlo 
			MOV	R7, R0		;E endereços dos vetores
			MOV	R5, DupSolucao
			MOV	R6, Jogada
			
test2:		INC	R7
			CMP	M[R6], R0			;Se o valor de r6 for 0 significa que já foi encontrado um match para essa cor
			BR.Z novapos
			CMP	M[R5], R0			;Se o valor de r5 for 0 significa que já foi encontrado um match para essa cor
			BR.Z nocompare2
			MOV	R1, M[R6]			;copia para r1 o valor na posicao atual na string jogada
			MOV	R2, M[R5]			;copia o valor na posicao atual para r1
			CMP	R1, R2				;Compara cores em posicoes diferentes
			BR.Z corcerta			;Em caso de match incrementa o nr de B's a escrever

			CMP	R7, M[coresc]		;Se todas as cores da jogada tiverem sido analisadas
			BR.Z novapos			;Salta para a proxima cor do vetor dupsolução
			INC	R5
			BR	test2
			
nocompare2: INC	R5			;Sub rotina que avança no vetor dupsolução
			CMP	R7, M[coresc]	;Se r7 for igual ao nr de cores escolhidas então todas as posições da solução foram analisadas
			BR.Z novapos
			BR	test2
			

novapos:	MOV	R5, DupSolucao		;Subrotina que avança no vetor jogada. E volta a apontar para o inicio da solução
			MOV	R7, R0				;Reinicializa o controlo de qts posicoes foram comparadas
			INC	R6					;Incrementa posicao na string jogada 
			INC	R4					;Registo de controlo. Qd chega ao valor de coresc significa que todas as posicoes de Jogada foram comparadas
			CMP	R4, M[coresc]
			BR.Z esccplace
			JMP	test2

corcerta:	INC	M[n_b]		;incrementa cada vez que é encontrada uma cor igual em posicoes diferentes nas strings
			MOV M[R5], R0	;
			MOV M[R6], R0	;As cores encontradas são removidas
			BR	novapos
		
esccplace:	MOV	R3, M[n_p]
			MOV	R4, M[n_p]
			CMP	R3, R0
			BR.Z escn_b		;Se 0 então não foram encontradas cores no local correto. Salta para a escrita de B's
			MOV	R1, M[coresc]
			CMP	R4, R1	;Compara o n_p com o nr de cores escolhidas. Se forem iguais então o jogador acertou na sequencia
			BR.NZ escp
			MOV	R5, 0002h
			MOV M[GameEND], R5  ;FLAG de win
			
		
escp:		MOV		R1, 'P'	;Escreve a avaliação da jogada
			MOV		R2, M[CursorAval]	
			SUB		R2, 4
			ADD R2, M[coresc]
			MOV		M[IO_CURSOR], R2
			INC		M[CursorAval]
			CALL	EscCar
			DEC		R3
			BR.NZ	escp

escn_b:		MOV		R3, M[n_b]
			ADD		R4, M[n_b]
			CMP		R3, R0	;Se 0 não foram encontradas cores corretas em locasi errados
			BR.Z	endaval	;sai da avaliação
			
escb:		MOV		R1, 'B' ;Escreve a avaliação da jogada
			MOV		R2, M[CursorAval]
			SUB		R2, 4
			ADD 	R2, M[coresc]
			MOV		M[IO_CURSOR], R2
			INC		M[CursorAval]
			CALL	EscCar
			DEC		R3
			BR.NZ	escb

			
endaval:	MOV		R2, M[CursorAval]
			ADD		R2, 0100h
			SUB		R2, R4
			MOV		M[CursorAval], R2	;Calcula a proxima localização no ecra para o inicio da escrita da avaliação
			MOV 	M[n_b], R0			;De acordo com o nr de caracteres escritos
			MOV		M[n_p], R0
			POP		R7
			POP		R6
			POP		R5
			POP		R4
			POP		R3
			POP		R2
			POP		R1	
			RET

;===============================================================================
;Win: 		Se o jogador vencer imprime uma mensagem de vitória
;===============================================================================
Win:		PUSH	R1
			PUSH    win           ; Passagem de parametros pelo STACK
			MOV		R1, M[IO_CURSOR]
			ADD		R1, 1020h
			PUSH	R1			
			CALL    EscString
			POP 	R1
			RET
;===============================================================================
;Lose: 		Se o jogador perder imprime uma mensagem de derrota
;===============================================================================
Lose:		PUSH	R1
			PUSH    lose           ; Passagem de parametros pelo STACK
			MOV		R1, M[IO_CURSOR]
			ADD		R1, 101eh
			PUSH	R1				
			CALL    EscString
			POP		R1
			RET				
;===============================================================================
;INITALL: 		Inicializa Interrupções, cronometro
;               Entradas: ---
;               Saidas: ---
;               Efeitos: Permite a ocorrencia de interrupções(I0,I1,I2,etc)
;===============================================================================
INITALL:   	PUSH R1
			MOV R1, STOPI0		;Endereço da rotina a ser chamada aquando da interrupção 0
	        MOV M[GAME_INT0], R1		;Interrupcao 0
			MOV	R1, 000Ah
			MOV	M[TEMP_VALUE], R1		;Nr de intervalos de 100ms para o temporizador contar
			MOV R1, 0001h
			MOV	M[TEMP_ENABLE], R1		;Enable do contador
			MOV	R1, 8001h				;Mascara de interrupções. Enable da interrupção 0 e 15
			MOV	M[INT_MASK], R1			
			MOV	R1, DECTIME		;Endereço da rotina a ser chamada aquando da interrupção do temporizador
			MOV	M[GAME_INTEMP], R1
			MOV	M[TimeFlag], R0
			CALL INITTIME
			ENI
			POP	R1
            RET
			
;========================================================================================================
;DECTIME					Reinicia o temporizador
;=========================================================================================================
DECTIME:	PUSH	R1								;Reinicializa o temporizador qd este chega ao fim da contagem
			MOV	R1, 000Ah
			MOV	M[TEMP_VALUE], R1
			MOV R1, 0001h
			MOV	M[TEMP_ENABLE], R1
			INC	M[TimeFlag]						;Flag=1 sp que passa um segundo
			POP	R1
			RTI	
				
;=========================================================================================================
;ACTTIME					Atualiza os displays
;=========================================================================================================						
ACTTIME:	PUSH R1
			PUSH R2
			DEC	M[TimeFlag]					;coloca flag a 0
			DEC M[Time]				    ;decrementa tempo total
				
			MOV R1, 60
			MOV	R2, M[Time]
			DIV	R2, R1
			MOV M[DISP7S3], R2			;MINUTOS
						
				
			MOV	R1, 10
			MOV	R2, M[Time]
			DIV	R2, R1
			MOV M[DISP7S1], R1			;SEGUNDOS
				
				
			CMP R1, 9					;sempre que os segundos chegam a 9
			BR.NZ nocount
			DEC	M[DecMin]				;a décima de minuto decrementa
			MOV R1, M[DecMin]
			MOV	M[DISP7S2], R1
			CMP R1, R0					
			BR.Z fimmin
			BR nocount

fimmin:		MOV	R1, 6					;volta a inicializar a décima de minuto
			MOV	M[DecMin], R1
					
nocount:	POP	R2
			POP	R1
			RET
						
;===============================================================================
;INITTIME:				Coloca o tempo inicial no display
;===============================================================================
INITTIME:	PUSH R1
			
			MOV	R1, M[timeesc]
			MOV M[Time], R1
			MOV	R1, 60
			MOV	R2, M[Time]
			DIV R2, R1
			MOV	M[DISP7S3], R2
			
			POP R1
			RET			

;===============================================================================
;NEWGAME:			REINICIA O JOGO PARA O PROXIMO JOGADOR
;===============================================================================
NEWGAME: 	PUSH R1

			MOV R1, M[jogesc]
			CMP	R1,R0			;se já não houver jogadores para jogar, não faz novo jogo
			JMP.Z noplay
		
remainplay: MOV R1, M[IO_PRESS]	;se ainda houver jogadores
			CMP R1,R0
			BR.Z remainplay		;espera que entre o proximo jogador e carregue numa tecla
			CALL LimpaJanela
			CALL STARTSCREEN	;Chama o ecra das regras
			
			MOV R1, 10
			MOV M[n_jogadas], R1		;Reseta todas as variáveis necessárias para o funcionamento do jogo
										;Todos os valores usados aqui são os mesmos que na declaração das variaveis no inicio do codigo
			MOV M[TimeFlag], R0
			MOV M[GameEND], R0   ;Variavel de estado(2=GameENDWIN, 1=GameENDLose, 0=GameRunning)
			MOV R1, 6
			MOV M[DecMin], R1
			MOV	R1, M[timeesc]
			MOV M[Time], R1
			MOV R1, 031Ch
			MOV M[cursor], R1
			MOV M[newline], R0
			MOV M[posjogada], R0
			MOV R1, 032bh
			MOV M[CursorAval], R1
			MOV	R1, M[coresc]
			MOV M[newline], R1
			CALL INITTIME
			
			MOV R1, M[coresc]
			CMP R1, 5
			BR.N cursoraval4			;Posição de escrita da avaliação
			BR.P cursoraval6
			MOV R1, 032Dh
			MOV M[CursorAval], R1
			BR next
cursoraval4:MOV R1, 032bh
			MOV M[CursorAval], R1
			BR next
			
cursoraval6:MOV R1, 032Fh
			MOV M[CursorAval], R1
			
next:		MOV R1, restart
			PUSH R1				;Quando faz RET retorna para o o endereço da tag restart
			PUSH R1				;Passa o endereço pelo stack  :)
			DEC M[jogesc]
noplay:		POP R1
			RET
			

			
;===============================================================================
;                       Programa prinicipal
;===============================================================================
inicio:  	MOV R1, SP_INICIAL
			MOV SP, R1	
outrojogo:	CALL LimpaJanela	
			MOV	M[DISP7S1], R0
			MOV	M[DISP7S2], R0
			MOV	M[DISP7S3], R0
			MOV	M[DISP7S4], R0	
			MOV R1, 10
			MOV M[n_jogadas], R1
			
        	CALL WELCOME			;Chama o ecra de boas vindas
			CALL OPTIONSSCREEN		;Chama o ecra de opcoes de jogo							
			CALL INITALL				;Inicializa interrupções/interruptores,cronometro(tempo de jogo)
			CALL NEWGAME
restart:	CALL TABGEN				;Gera o tabuleiro de jogo
			CALL CORSEQ				;Gera o sequencia de cores
			
jogogo:		CMP	M[TimeFlag], R0
			CALL.NZ	ACTTIME
			
			CALL	INPUT
			
			CMP	M[Time], R0
			JMP.Z EndgameLose
			
			MOV	R2, 00001h
			MOV	R4, 00002h
			CMP R4, M[GameEND] ;Verifica se há fim de jogo. Se houver, qual o tipo Win ou Lose
			JMP.Z EndgameWin
			CMP M[GameEND], R2 
			JMP.Z EndgameLose
			
			CMP	M[n_jogadas], R0
			JMP.Z EndgameLose
			
			JMP	jogogo
			
EndgameWin:	CALL	Win
			CALL WRITESOL
			CALL NEWGAME
			BR Fim
			
EndgameLose:	CALL	Lose
				CALL 	WRITESOL
				CALL    NEWGAME
				BR Fim
		
Fim:   	MOV R1, M[IO_PRESS]		;Espera comando de novo jogo "N"
		CMP R1,R0
		BR.Z Fim
		MOV R1, M[IO_READ]
		CMP R1, 78
		JMP.Z outrojogo
		BR      Fim
;===============================================================================
