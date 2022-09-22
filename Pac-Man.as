;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR              EQU     0Ah
FIM_TEXTO       EQU     0d
FIM_MAPA        EQU     1d
NCOLUNAS        EQU     26d
RND_MASK        EQU     8016h
LSB_MASK        EQU     0001h

IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh                   ;Ao botar nessa posição na memória imprime na tela na posição configurada do cursos
IO_STATUS       EQU     FFFDh

INITIAL_SP      EQU     FDFFh

CURSOR		    EQU     FFFCh                   ;Configura a posição do cursor na tela
CURSOR_INIT		EQU		FFFFh

ATIVAR_TEMP     EQU     FFF7h
CONF_TEMP       EQU     FFF6h
            
PHANTOM         EQU     '8'
PACMAN          EQU     '@'
ESPACO          EQU     ' '
PAREDE          EQU     '#'
COMIDA          EQU     '.'
CEREJA          EQU     '%'

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

                ORIG    8000h
                        ;0123456789012345678901234      5
life            STR     'Life: <3 <3 <3', FIM_TEXTO
linha0          STR     '#########################', FIM_TEXTO
linha1          STR     '#.......#.......#.......#', FIM_TEXTO
linha2          STR     '#..####.#..###..#.####..#', FIM_TEXTO
linha3          STR     '#.......................#', FIM_TEXTO
linha4          STR     '#..###....##.##....###..#', FIM_TEXTO
linha5          STR     '#....#....#...#....#....#', FIM_TEXTO
linha6          STR     '#..#.#.#.##. .##.#.#.#..#', FIM_TEXTO
linha7          STR     '#..#......#...#......#..#', FIM_TEXTO
linha8          STR     '#..###....##.##....###..#', FIM_TEXTO
linha9          STR     '#.......................#', FIM_TEXTO
linha10         STR     '#..####.#..###..#.####..#', FIM_TEXTO
linha11         STR     '#.......#.......#.......#', FIM_TEXTO
linha12         STR     '#########################', FIM_TEXTO
score           STR     'Score: 0000', FIM_MAPA

;-------------------------------------------------------------------------------
;Configurações do Painel Score
ScoreX          WORD    8d
ScoreY          WORD    15d
Pontuacao       WORD    0d                      ;Pontuação máxima: 1800d(Sem cereja)
PontuacaoN      WORD    1000d
ContComida      WORD    184d                    ;Número total de comida(Diminui quando come ... Se for 0 é vitoria)
;-------------------------------------------------------------------------------
;Configurações da Cereja
CerejaX         WORD    13d
CerejaY         WORD    8d
;-------------------------------------------------------------------------------
;Configurações do Painel Life
LifeX           WORD    14d
LifeY           WORD    1d
;-------------------------------------------------------------------------------
;Configurações do Pac-Man
Direcao         WORD    0d                       ;0 = parado, 1 = esquerda, 2 = direita, 3 = cima, 4 = baixo
Xpac	        WORD	13d                      ;Variável que indica a posição X do PacMan
Ypac	        WORD	8d                       ;Variável que indica a posição Y do PacMan
Packm           WORD    168d                     ;((Ypac - RowIndex - 1)* Ncolunas) + Xpac - ColumnIndex

IniDirecao      WORD    0d                       ;Direção inicial do PacMan
IniXpac         WORD    13d                      ;Posição X inicial do PacMan
IniYpac         WORD    8d                       ;Posição Y inicial do PacMan
IniPackm        WORD    168d                     ;Quantidade inicial de caracteres até o PacMan
;-------------------------------------------------------------------------------
;Configurações dos Fantasmas
FlagPhantom     WORD    0d                      ;Indica qual fantasma está se movimentando

DirecaoPhantom1 WORD    0d
Xphantom1       WORD    13d
Yphantom1       WORD    3d
Phantom1km      WORD    38d

IniDirecaoPhantom1 WORD 0d                      ;Direção inicial do fantasma 1
IniXphantom1    WORD    13d                     ;Coluna inicial do fantasma 1
IniYphantom1    WORD    3d                      ;Linha inicial do fantasma 1
IniPhantom1km   WORD    38d                     ;Quantidade inicial de caracteres até o fantasma 1
Stop1           WORD    1d                      ;Variavel de parada do fantasma 1

DirecaoPhantom2 WORD    1d
Xphantom2       WORD    13d
Yphantom2       WORD    13d
Phantom2km      WORD    298d

IniDirecaoPhantom2 WORD 1d                      ;Direção inicial do fantasma 2
IniXphantom2    WORD    13d                     ;Coluna inicial do fantasma 2
IniYphantom2    WORD    13d                     ;Linha inicial do fantasma 2
IniPhantom2km   WORD    298d                    ;Quantidade inicial de caracteres até o fantasma 2
Stop2           WORD    1d                      ;Variavel de parada do fantasma 2

DirecaoPhantom  WORD    0d
Xphantom        WORD    0d
Yphantom        WORD    0d
Phantomkm       WORD    0d

Stop            WORD    1d                      ;Variavel de parada de algum fantasma

;-------------------------------------------------------------------------------
;Configurações do Mapa
RowIndex		WORD	1d
ColumnIndex		WORD	1d
YFim            WORD    17d
Derrota         STR     '*******Voce perdeu*******', FIM_MAPA
Vitoria         STR     '*******Voce venceu*******', FIM_MAPA
;-------------------------------------------------------------------------------
;Configurações gerais
TextIndex		WORD	0d
Random_var      WORD    A5A5h
FlagVF          WORD    0d                      ;1 = venceu, 2 = perdeu
Vidas           WORD    3d
FlagMorreu      WORD    1d                      ;1 = vivo, 0 = morto
;-------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0            WORD    SetDirLeft
INT1            WORD    SetDirRight
INT2            WORD    SetDirUp
INT3            WORD    SetDirDown

                ORIG    FE0Fh
INT15           WORD    Timer

;------------------------------------------------------------------------------
; ZONA IV: codigo
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;------------------------------------------------------------------------------
;Interrupção Timer
;------------------------------------------------------------------------------
Timer:          PUSH    R1
                PUSH    R2
                
                CALL    Move                    ;Chamada de função para movimentar o Pac-man

                CALL    CheckVictory            ;Chamada de função para checar a quantidade de comidas restantes
                CMP     M[ FlagVF ], R0         ;Caso haja uma vitoria ou uma derrota o jogo é parado
                JMP.NZ  FimTimer

                CALL    CheckLifes              ;Chamada de função para checar o número de vidas
                CMP     M[ FlagVF ], R0         ;Caso haja uma vitoria ou uma derrota o jogo é parado
                JMP.NZ  FimTimer

                MOV     M[ FlagPhantom ], R0
                CALL    Phantom1                ;Chamada de função para definir qual fantasma será movido
                CALL    MovePhantom             ;Chamada de função para movimentar o fantasma
                CALL    RecebePhantom1          ;Chamada de função para atualizar as informações do fantasma que se movimentou
            
                CALL    CheckLifes              ;Chamada de função para checar o número de vidas
                CMP     M[ FlagVF ], R0         ;Caso haja uma vitoria ou uma derrota o jogo é parado
                JMP.NZ  FimTimer

                MOV     R2, 1d 
                MOV     M[ FlagPhantom ], R2
                CALL    Phantom2                ;Chamada de função para definir qual fantasma será movido
                CALL    MovePhantom             ;Chamada de função para movimentar o fantasma
                CALL    RecebePhantom2          ;Chamada de função para atualizar as informações do fantasma que se movimentou
                
                CALL    CheckLifes              ;Chamada de função para checar o número de vidas
                CMP     M[ FlagVF ], R0         ;Caso haja uma vitoria ou uma derrota o jogo é parado
                JMP.NZ  FimTimer

                MOV     R1, 1d
                MOV     M[ FlagMorreu ], R1     ;Reseta a Flag Morreu

                MOV     R1, 4d                  ;Configura o tempo do timer
                MOV     M[ CONF_TEMP ], R1
                MOV     R2, 1d                  ;Ativa o timer
                MOV     M[ ATIVAR_TEMP ], R2

FimTimer:       POP     R2
                POP     R1
                RTI

;------------------------------------------------------------------------------
;Interrupções para definir o movimento
;------------------------------------------------------------------------------
SetDirLeft:     PUSH    R1                      ;Interrupção para definir a direção do PacMan para esquerda
                MOV     R1, 1d
                MOV     M[ Direcao ], R1
                POP     R1
                RTI

SetDirRight:    PUSH    R1                      ;Interrupção para definir a direção do PacManpara direita
                MOV     R1, 2d
                MOV     M[ Direcao ], R1
                POP     R1
                RTI

SetDirUp:       PUSH    R1                      ;Interrupção para definir a direção do PacMan para cima
                MOV     R1, 3d
                MOV     M[ Direcao ], R1
                POP     R1
                RTI

SetDirDown:     PUSH    R1;                     ;Interrupção para definir a direção do PacMan para baixo
                MOV     R1, 4d
                MOV     M[ Direcao ], R1
                POP     R1
                RTI

;------------------------------------------------------------------------------
;Random (Gera número aleatório)
;------------------------------------------------------------------------------
Random:         PUSH    R1
                PUSH    R2
                MOV     R1, LSB_MASK
                AND     R1, M[ Random_var ]
                BR.Z    Rnd_rotate
                MOV     R1, RND_MASK
                XOR     M[ Random_var ], R1

Rnd_rotate:     ROR     M[ Random_var], 1

                MOV     R2, 4d
                MOV     R1, M[ Random_var ]
                DIV     R1, R2                  ;Fazemos uma divisão por 4 pois existem apenas 4 direções
                MOV     M[ DirecaoPhantom ], R2 ;O resto da divisão é um valor entre 0 e 3

                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Checa vitória ou a quantidade de vidas
;------------------------------------------------------------------------------
CheckVictory:   PUSH    R1

                MOV     R1, M[ ContComida ]     ;Comparação para verificar se ainda há comidas no mapa
                CMP     R1, R0
                JMP.NZ  FimCheck                ;Se a quantidade de comidas for diferente de 0 não é impresso nada
                
                MOV     R1, 1d 
                MOV     M[ FlagVF ], R1         ;Configura a Flag VF para indicar se houve ou uma vitoria ou uma derrota
                CALL    PrintVitDer
                JMP     FimCheck

CheckLifes:     PUSH    R1

                MOV     R1, M[ Vidas ]          ;comparação para verificar se ainda há vidas restantes
                CMP     R1, R0
                JMP.NZ   FimCheck               ;Se a quantidade de vidas for diferente de 0 não houve uma derrota
                
                MOV     R1, 2d 
                MOV     M[ FlagVF ], R1         ;Configura a Flag VF para indicar se houve ou uma vitoria ou uma derrota
                CALL    PrintVitDer
                JMP     FimCheck

FimCheck:       POP     R1
                RET

;------------------------------------------------------------------------------
;Funções que armazenam a variavel do fantasma numa variavel geral para que seja
;possível realizar as operações de movimentação e colisão
;------------------------------------------------------------------------------
Phantom1:       PUSH    R1                      ;Phantom1 configura o fantasma 1 para a movimentação
                PUSH    R2
                PUSH    R3
                PUSH    R4

                MOV     R1, M[ DirecaoPhantom1 ]
                MOV     R2, M[ Xphantom1 ]
                MOV     R3, M[ Yphantom1 ]
                MOV     R4, M[ Phantom1km ]

                MOV     M[ DirecaoPhantom ], R1 ;Passa a direção atual do fantasma 1 para a direção de movimentação
                MOV     M[ Xphantom ], R2       ;Passa a posição X atual do fantasma 1 para a posição X de movimentação
                MOV     M[ Yphantom ], R3       ;Passa a posição Y atual do fantasma 1 para a posição Y de movimentação
                MOV     M[ Phantomkm ], R4      ;Passa a quantidade de caracteres até o fantasma 1 para a quantidade de caracteres de movimentação

                MOV     R1, M[ Stop1 ]
                MOV     M[ Stop ], R1           ;Passa a condição do fantasma 1 (Se está parado ou se movimentando)
                 
                POP     R4
                POP     R3
                POP     R2
                POP     R1
                RET

Phantom2:       PUSH    R1                      ;Phantom2 configura o fantasma 2 para a movimentação
                PUSH    R2
                PUSH    R3
                PUSH    R4

                MOV     R1, M[ DirecaoPhantom2 ]
                MOV     R2, M[ Xphantom2 ]
                MOV     R3, M[ Yphantom2 ]
                MOV     R4, M[ Phantom2km ]

                MOV     M[ DirecaoPhantom ], R1 ;Passa a direção atual do fantasma 2 para a direção de movimentaçãoão
                MOV     M[ Xphantom ], R2       ;Passa a posição X atual do fantasma 2 para a posição X de movimentação
                MOV     M[ Yphantom ], R3       ;Passa a posição Y atual do fantasma 2 para a posição Y de movimentação
                MOV     M[ Phantomkm ], R4      ;Passa a quantidade de caracteres até o fantasma 2 para a quantidade de caracteres de movimentação

                MOV     R1, M[ Stop2 ]
                MOV     M[ Stop ], R1           ;Passa a condição do Fantasma 2 (Se está parado ou se movimentando)

                POP     R4
                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Funções que atualizam as informações modificadas pelas funções de movimento
;------------------------------------------------------------------------------
RecebePhantom1: PUSH    R1
                PUSH    R2
                PUSH    R3
                PUSH    R4

                MOV     R1, M[ DirecaoPhantom ]
                MOV     R2, M[ Xphantom ]
                MOV     R3, M[ Yphantom ]
                MOV     R4, M[ Phantomkm ]

                MOV     M[ DirecaoPhantom1 ], R1;Passa a direção modificada pela função de movimento para o fantasma 1
                MOV     M[ Xphantom1 ], R2      ;Passa a posição X modificada pela função de movimento para o fantasma 1
                MOV     M[ Yphantom1 ], R3      ;Passa a posição Y modificada pela função de movimento para o fantasma 1
                MOV     M[ Phantom1km ], R4     ;Passa a quantidade de caracteres modificada pela função de movimento para o fantasma 1

                MOV     R1, 1d
                MOV     M[ Stop1 ], R1          ;Reseta a condição do fantasma (Se está parado ou em movimento)

                POP     R4
                POP     R3
                POP     R2
                POP     R1
                RET

RecebePhantom2: PUSH    R1
                PUSH    R2
                PUSH    R3
                PUSH    R4

                MOV     R1, M[ DirecaoPhantom ]
                MOV     R2, M[ Xphantom ]
                MOV     R3, M[ Yphantom ]
                MOV     R4, M[ Phantomkm ]

                MOV     M[ DirecaoPhantom2 ], R1;Passa a direção modificada pela função de movimento para o fantasma 1
                MOV     M[ Xphantom2 ], R2      ;Passa a posição X modificada pela função de movimento para o fantasma 1
                MOV     M[ Yphantom2 ], R3      ;Passa a posição Y modificada pela função de movimento para o fantasma 1
                MOV     M[ Phantom2km ], R4     ;Passa a quantidade de caracteres modificada pela função de movimento para o fantasma 1

                MOV     R1, 1d
                MOV     M[ Stop2 ], R1          ;Reseta a condição do fantasma (Se está parado ou em movimento)

                POP     R4
                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Função que verifica se houve colisão do fantasma com a parede
;------------------------------------------------------------------------------
ColisaoPhantom: PUSH    R1
                PUSH    R2
                PUSH    R3

                MOV     R1, linha0
                MOV     R2, M[ Phantomkm ]
                MOV     R3, M[ DirecaoPhantom ]

                CMP     R3, 0d
                JMP.Z   ColLeftPhantom
                CMP     R3, 1d 
                JMP.Z   ColRightPhantom
                CMP     R3, 2d 
                JMP.Z   ColUpPhantom
                CMP     R3, 3d
                JMP.Z   ColDownPhantom

                ColLeftPhantom:     DEC     R2
                                    JMP     FimColPhantom
                ColRightPhantom:    INC     R2
                                    JMP     FimColPhantom
                ColUpPhantom:       SUB     R2, NCOLUNAS
                                    JMP     FimColPhantom
                ColDownPhantom:     ADD     R2, NCOLUNAS
                
                FimColPhantom:      ADD     R1, R2
                                    MOV     R3, M[ R1 ]

                                    CMP     R3, PAREDE
                                    JMP.NZ  ColFalsePhantom

                ColTruePhantom:     CALL    Random
                                    MOV     M[ Stop ], R0

                ColFalsePhantom:    POP     R3
                                    POP     R2
                                    POP     R1
                                    RET

;------------------------------------------------------------------------------
;Função que verifica se houve colisão do Pac-man com a parede
;------------------------------------------------------------------------------
Colisao:        PUSH    R1
                PUSH    R2
                PUSH    R3

                MOV     R1, linha0
                MOV     R2, M[ Packm ]
                MOV     R3, M[ Direcao ]

                CMP     R3, 1d
                JMP.Z   ColLeft
                CMP     R3, 2d
                JMP.Z   ColRight
                CMP     R3, 3d
                JMP.Z   ColUp
                CMP     R3, 4d
                JMP.Z   ColDown
                ColLeft:        DEC     R2
                                JMP     FimCol
                ColRight:       INC     R2
                                JMP     FimCol
                ColUp:          SUB     R2, NCOLUNAS
                                JMP     FimCol
                ColDown:        ADD     R2, NCOLUNAS
                                JMP     FimCol

                FimCol:         ADD     R1, R2
                                MOV     R3, M[ R1 ]

                                CMP     R3, COMIDA  ;Comparação para verificar se a próxima posição é uma comida
                                JMP.Z   ComeuHMMM

                                CMP     R3, PAREDE  ;Comparação para verificar se a próxima posição é uma parede
                                JMP.NZ  ColFalse
                                
                ColTrue:        MOV     M[ Direcao ], R0
                                JMP     ColFalse

                ComeuHMMM:      MOV     R2, ESPACO
                                MOV     M[ R1 ] , R2
                                MOV     R1, 10d
                                ADD     M[ Pontuacao ], R1
                                CALL    PrintScore
                                DEC     M[ ContComida ]

ColFalse:       POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Função que verifica se houve colisão com o fantasma e caso sim reseta as posições
;------------------------------------------------------------------------------
ColisaoWPhantom:PUSH    R1
                PUSH    R2
                PUSH    R3
                PUSH    R4

                MOV     R1, M[ Xpac ]
                MOV     R2, M[ Xphantom ]
                CMP     R1, R2                  ;Compara a posição X do fantasma e do PacMan
                JMP.NZ  NaoMorreu
                MOV     R1, M[ Ypac ]
                MOV     R2, M[ Yphantom ]
                CMP     R1, R2                  ;Compara a posição Y do fantasma e do PacMan
                JMP.NZ  NaoMorreu

                ;Caso X e Y sejam iguais as posições dos fantasmas e do PacMan serão resetadas
                CALL    PrintSpace
                DEC     M[ Vidas ]
                MOV     M[ FlagMorreu ], R0
                CALL    DesPrintLIfe

                MOV     M[ Direcao ], R0
                MOV     R1, M[ IniPackm ]
                MOV     M[ Packm ], R1
                MOV     R1, M[ IniXpac ]
                MOV     M[ Xpac ], R1
                MOV     R1, M[ IniYpac ]
                MOV     M[ Ypac ], R1
                MOV     M[ FlagMorreu ], R0
                CALL    PrintMove

                CALL    Phantom1
                CALL    ReprintMapa
                MOV     R1, M[ IniDirecaoPhantom1 ]
                MOV     R2, M[ IniXphantom1 ]
                MOV     R3, M[ IniYphantom1 ]
                MOV     R4, M[ IniPhantom1km ]
                MOV     M[ DirecaoPhantom1 ], R1
                MOV     M[ Xphantom1 ], R2
                MOV     M[ Yphantom1 ], R3
                MOV     M[ Phantom1km ], R4
                CALL    Phantom1
                CALL    PrintPhantom

                CALL    Phantom2
                CALL    ReprintMapa
                MOV     R1, M[ IniDirecaoPhantom2 ]
                MOV     R2, M[ IniXphantom2 ]
                MOV     R3, M[ IniYphantom2 ]
                MOV     R4, M[ IniPhantom2km ]
                MOV     M[ DirecaoPhantom2 ], R1
                MOV     M[ Xphantom2 ], R2
                MOV     M[ Yphantom2 ], R3
                MOV     M[ Phantom2km ], R4
                CALL    Phantom2
                CALL    PrintPhantom

                CMP     M[ FlagPhantom ], R0
                JMP.Z   ConfigPhantom2
                CALL    Phantom2
                JMP     NaoMorreu

                ConfigPhantom2: CALL    Phantom1 

NaoMorreu:      POP     R4
                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Movimentação do fantasma
;------------------------------------------------------------------------------
MoveLeftPhantom:CALL    ReprintMapa             ;Reimprime o mapa na posição antiga do fantasma
                DEC     M[ Xphantom ]           ;Decrementa a variavel para que seja possível imprimir na esquerda
                CALL    PrintPhantom            ;Imprime o fantasma na próxima posição

                DEC     M[ Phantomkm ]          ;Decrementa para indicar que existem menos caracteres até o fantasma

                JMP     FimMovePhantom

MoveRightPhantom:CALL    ReprintMapa            ;Reimprime o mapa na posição antiga do fantasma
                INC     M[ Xphantom ]           ;Increnta a variável para que seja possível imprimir na direita
                CALL    PrintPhantom            ;Imprime o fantasma na próxima posição
                
                INC     M[ Phantomkm ]          ;Incrementa para indicar que existem mais caracteres até o fantasma

                JMP     FimMovePhantom

MoveUpPhantom:  CALL    ReprintMapa             ;Reimprime o mapa na posição antiga do fantasma
                DEC     M[ Yphantom ]           ;Decrementa a variável para que seja possível imprimir em cima
                CALL    PrintPhantom            ;Imprime o fantasma na próxima posição
                
                MOV     R1, M[ Phantomkm ]
                SUB     R1, NCOLUNAS            ;Subtrai o número de colunas para indicar que existem menos caracteres até o fantasma
                MOV     M[ Phantomkm ], R1
                
                JMP     FimMovePhantom

MoveDownPhantom:CALL    ReprintMapa             ;Reimprime o mapa na posição antiga do fantasma
                INC     M[ Yphantom ]           ;Increnta a variável para que seja possível imprimir em baixo
                CALL    PrintPhantom            ;Imprime o fantasma na próxima posição

                MOV     R1, M[ Phantomkm ]
                ADD     R1, NCOLUNAS            ;Soma o número de colunas para indicar que existem mais caracteres até o fantasma
                MOV     M[ Phantomkm ], R1

                JMP     FimMovePhantom

;------------------------------------------------------------------------------
;Funções que realizam o movimento
;------------------------------------------------------------------------------
MoveLeft:       CALL    PrintSpace              ;Imprime um espaço na posição anterior do PacMan
                DEC     M[ Xpac ]               ;Decrementa a variavel para que seja possível imprimir na posição certa
                CALL    PrintMove               ;Imprime o PacMan na proxima posição

                DEC     M[ Packm ]              ;Decrementa para indicar que existem menos caracteres até o PacMan
                
                JMP     FimMove

MoveRight:      CALL    PrintSpace              ;Imprime um espaço na posição anterior do PacMan
                INC     M[ Xpac ]               ;Incrementa a variavel para que seja possível imprimir na posição certa
                CALL    PrintMove               ;Imprime o PacMan na proxima posição
                
                INC     M[ Packm ]              ;Incrementa para indicar que existem mais caracteres até o fantasma
                
                JMP     FimMove

MoveUp:         CALL    PrintSpace              ;Imprime um espaço na posição anterior do PacMan
                DEC     M[ Ypac ]               ;Decrementa a variável para que seja possível imprimir em cima
                CALL    PrintMove               ;Imprime o PacMan na proxima posição
                
                MOV     R1, M[ Packm ]
                SUB     R1, NCOLUNAS            ;Subtrai o número de colunas para indicar que existem menos caracteres até o fantasma
                MOV     M[ Packm ], R1
                
                JMP     FimMove

MoveDown:       CALL    PrintSpace              ;Imprime um espaço na posição anterior do PacMan
                INC     M[ Ypac ]               ;Increnta a variável para que seja possível imprimir em baixo
                CALL    PrintMove               ;Imprime o fantasma na próxima posição

                MOV     R1, M[ Packm ]
                ADD     R1, NCOLUNAS            ;Soma o número de colunas para indicar que existem mais caracteres até o fantasma
                MOV     M[ Packm ], R1

                JMP     FimMove

;------------------------------------------------------------------------------
;Funções que chamam o movimento que será feito
;(Tanto do fantasma quanto do Pac-man)
;------------------------------------------------------------------------------
Move:           PUSH    R1

                CALL    ColisaoWPhantom
                CMP     M[ FlagMorreu ], R0
                JMP.Z   FimMove

                MOV     R1, M [ Direcao ]
                
                CALL    Colisao
                CMP     M[ Direcao ], R0
                JMP.Z   FimMove

                CMP     R1, 1d                   ;Movimenta o PacMan para esquerda
                JMP.Z   MoveLeft

                CMP     R1, 2d                   ;Movimenta o PacMan para direita
                JMP.Z   MoveRight

                CMP     R1, 3d                   ;Movimenta o PacMan para cima
                JMP.Z   MoveUp

                CMP     R1, 4d                   ;Movimenta o PacMan para baixo
                JMP.Z   MoveDown

                CALL    ColisaoWPhantom

FimMove:        POP     R1
                RET

MovePhantom:    PUSH    R1

                CALL    ColisaoWPhantom
                CMP     M[ FlagMorreu ], R0
                JMP.Z   FimMovePhantom

                CALL    ColisaoPhantom
                CMP     M[ Stop ], R0
                JMP.Z   FimMovePhantom

                MOV     R1, M[ DirecaoPhantom ]
                
                CMP     R1, 0d                  ;Movimenta o PacMan para esquerda
                JMP.Z   MoveLeftPhantom

                CMP     R1, 1d                  ;Movimenta o PacMan para direita
                JMP.Z   MoveRightPhantom

                CMP     R1, 2d                  ;Movimenta o PacMan para cima
                JMP.Z   MoveUpPhantom

                CMP     R1, 3d                  ;Movimenta o PacMan para baixo
                JMP.Z   MoveDownPhantom

                CALL    ColisaoWPhantom

FimMovePhantom: POP     R1
                RET

;------------------------------------------------------------------------------
;Função para tirar o coração da barra 'Life'
;------------------------------------------------------------------------------
DesPrintLIfe:   PUSH    R1
                PUSH    R2
                PUSH    R3

                MOV     R1, M[ LifeX ]
                MOV     R2, M[ LifeY ]
                MOV     R3, ESPACO
                
                SHL     R2, 8d
                OR      R2, R1

                MOV     M[ CURSOR ], R2
                MOV     M[ IO_WRITE ], R3

                DEC     M[ LifeX ]
                MOV     R1, M[ LifeX ]
                MOV     R2, M[ LifeY ]
                MOV     R3, ESPACO
                
                SHL     R2, 8d
                OR      R2, R1

                MOV     M[ CURSOR ], R2
                MOV     M[ IO_WRITE ], R3

                MOV     R1, 2d
                MOV     R2, M[ LifeX ]
                SUB     R2, R1
                MOV     M[ LifeX ], R2

                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Função que imprime o caractere que o fantasma passou 
;------------------------------------------------------------------------------
ReprintMapa:    PUSH    R1
                PUSH    R2
                PUSH    R3

                MOV     R1, linha0
                MOV     R2, M[ Phantomkm ]

                ADD     R1, R2
                MOV     R3, M[ R1 ]

                MOV     R2, M[ Xphantom ]
                MOV     R1, M[ Yphantom ]
                SHL     R1, 8d
                OR      R1, R2
                MOV     M[ CURSOR ], R1
                MOV     M[ IO_WRITE ], R3

                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Função que imprime o fantasma
;------------------------------------------------------------------------------
PrintPhantom:   PUSH    R1
                PUSH    R2
                PUSH    R3
                
                MOV     R1, PHANTOM
                MOV     R2, M[ Yphantom ]
                MOV     R3, M[ Xphantom ]
                SHL     R2, 8d
                OR      R2, R3
                MOV     M[ CURSOR ], R2
                MOV     M[ IO_WRITE ], R1

                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Apaga o elemento anterior com o movimento do Pac-man
;------------------------------------------------------------------------------
PrintSpace:     PUSH    R1
                PUSH    R2
                PUSH    R3
                
                MOV     R1, ESPACO
                MOV     R2, M[ Ypac ]
                MOV     R3, M[ Xpac ]
                SHL     R2, 8d
                OR      R2, R3
                MOV     M[ CURSOR ], R2
                MOV     M[ IO_WRITE ], R1

                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Imprime o Pac-man na posição desejada
;------------------------------------------------------------------------------
PrintMove:      PUSH    R1
                PUSH    R2
                PUSH    R3

                MOV     R1, PACMAN
                MOV     R2, M[ Ypac ]
                MOV     R3, M[ Xpac ]
                SHL     R2, 8d
                OR      R2, R3
                MOV     M[ CURSOR ], R2
                MOV     M[ IO_WRITE ], R1
                
                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Imprime pontuação
;------------------------------------------------------------------------------
PrintScore:     PUSH    R1
                PUSH    R2
                PUSH    R3
                PUSH    R4
                PUSH    R5

                MOV     R1, M[ Pontuacao ]
                MOV     R3, M[ PontuacaoN ]
                MOV     R4, M[ ScoreY ]
                MOV     R5, M[ ScoreX ]

                WhileScore:     MOV     R2, R3
                                DIV     R1, R2
                                ADD     R1, 48d
                            
                                SHL     R4, 8d
                                OR      R4, R5

                                MOV     M[ CURSOR ], R4
                                MOV     M[ IO_WRITE ], R1

                                MOV     R1, R2
                                MOV     R2, 10d
                                DIV     R3, R2
                                INC     R5
                                MOV     R4, M[ ScoreY ]
                                MOV     R2, 1d
                                CMP     R3, R2
                                JMP.NZ  WhileScore

                POP     R5
                POP     R4
                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Função para imprimir o mapa
;------------------------------------------------------------------------------
PrintMapa:      PUSH    R1
                PUSH    R2
                PUSH    R3

                MOV     R1, life
				MOV		M[ TextIndex ], R1

                While:          MOV		R1, M[ TextIndex ]

                                MOV     R2, M[ RowIndex ]
                                MOV     R3, M[ ColumnIndex ]
                                SHL     R2, 8d
                                MOV		R1, M[ R1 ]
                                OR      R2, R3
                                MOV     M[ CURSOR ], R2
                                
                                CMP 	R1, FIM_TEXTO
                                JMP.Z	EndWhile
                                CMP     R1, FIM_MAPA
                                JMP.Z   FimPrintMapa
                                MOV     M[ IO_WRITE ], R1 
                                
                                INC		M[ ColumnIndex ]
                                INC		M[ TextIndex ]

                                JMP     While 

                EndWhile:       MOV     R1, 1d
                                INC     M[ RowIndex ]
                                INC     M[ TextIndex ]
                                MOV     M[ ColumnIndex ], R1 ;Zera coluna
                                JMP     While

FimPrintMapa:   MOV     R1, 1d 
                MOV     M[ ColumnIndex ], R1
                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Função para imprimir a vitoria ou a derrota
;------------------------------------------------------------------------------
PrintVitDer:    PUSH    R1
                PUSH    R2
                PUSH    R3

                MOV     R1, M[ FlagVF ]
                CMP     R1, 1d
                JMP.NZ  Over
                MOV     R1, Vitoria
                JMP     Continue

                Over:           MOV     R1, Derrota

                Continue:       MOV     R3, M[ ColumnIndex ]
                                MOV		M[ TextIndex ], R1
                WhileV:         MOV     R2, M[ YFim ]
                                MOV		R1, M[ TextIndex ]
                                SHL     R2, 8d
                                MOV     R1, M[ R1 ]
                                OR      R2, R3
                                MOV     M[ CURSOR ], R2

                                INC     M[ TextIndex ]
                                INC     R3

                                CMP     R1, FIM_MAPA
                                JMP.Z  FimVitoria
                                MOV     M[ IO_WRITE ], R1
                                JMP     WhileV
FimVitoria:     POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
;Main
;------------------------------------------------------------------------------
Main:			ENI
				MOV		R1, INITIAL_SP
				MOV		SP, R1		   ; We need to initialize the stack
				MOV		R2, CURSOR_INIT; We need to initialize the cursor 
				MOV     M[ CURSOR ], R2
				
                CALL    PrintMapa
                CALL    PrintMove
                CALL    Phantom1
                CALL    PrintPhantom
                CALL    Phantom2
                CALL    PrintPhantom
                
                MOV     R1, 1d
                MOV     M[ CONF_TEMP ], R1
                MOV     R2, 1d
                MOV     M[ ATIVAR_TEMP ], R2

Fim:            BR      Fim

;------------------------------------------------------------------------------
;Comentarios gerais
;------------------------------------------------------------------------------
;1- Os fantasmas começam com uma direção inicial para que não ocorra o caso deles
;   começarem batendo na parede e consequentemente perdendo um movimento