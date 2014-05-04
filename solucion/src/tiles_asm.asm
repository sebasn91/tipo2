;MACROS
;%include "macros.txt"

global tiles_asm

%define modulo(x,y) mod x,y

%macro mod 2
	mov rax, %1
	mov rbx, %2
	xor rdx, rdx
	div rbx
	; rdx = %1 mod %2
%endmacro 

section .data

section .text

global _start

tiles_asm:
;void tiles_c    (
;	unsigned char *src,		RDI
;	unsigned char *dst,		RSI
;	int cols,				RDX
;	int filas,				RCX
;	int src_row_size,		R8
;	int dst_row_size,		R9
;	int tamx,				[RBP + 16]
;	int tamy,				[RBP + 24]
;	int offsetx,			[RBP + 32]
;	int offsety){			[RBP + 40]

;	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
;	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
;
;	for (int i = 0; i < filas; i++) {
;		for (int j = 0; j < cols; j++) {
;			rgb_t *p_d = (rgb_t*)&dst_matrix[i][j*3];
;			rgb_t *p_s = (rgb_t*)&src_matrix[(i % tamy) + offsety][((j*3) % (tamx*3)) + (offsetx*3)];
;			*p_d = *p_s;}}}
 
	
	PUSH RBP					
	MOV RBP, RSP
	
	
	XOR R10, R10
	MOV R10D, [RBP+32] ; coloco offsetX
	XOR R11, R11
	.muevoX:
	CMP R11, R10
	JE .bajoY
	LEA RDI, [RDI+3] ;muevo 3 bytes el puntero de la matriz src
	INC R11
	JMP .muevoX
	
	.bajoY:
	XOR R10, R10
	MOV R10D, [RBP+40] ;coloco offsetY
	XOR R11, R11
	.bajoY2:
	CMP R11, R10
	JE .inicio
	lEA RDI, [RDI+R8] ;aumento en row size bytes el puntero ( bajo una fila)
	INC R11
	JMP .bajoY2
	;unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	
	;unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
    
    ;for (int i = 0; i < filas; i++) {
	.inicio:
	MOV R13, RDI
	XOR R10, R10
	XOR R11, R11
	XOR R12, R12
	XOR R14, R14
	XOR R15, R15
	LEA R13, [RDI]
	LEA R12, [RDI]
	MOV R14, 0	; R14: i
	.for1:
		;CONDICION
		CMP R14, RCX
		;CMP R14, RCX
		JGE .endfor1
		;CODIGO
		;for (int j = 0; j < cols; j++) {
			MOV R10, 0
			MOV R15, 0	;R15: j
			MOV RAX, RDI
			.for2:
				;CONDICION
				CMP R15, RDX
				JGE .endfor2
				 
				;CODIGO
				;rgb_t *p_d = (rgb_t*)&dst_matrix[i][j*3];
				;rgb_t *p_s = (rgb_t*)&src_matrix[(i % tamy) + offsety][((j*3) % (tamx*3)) + (offsetx*3)];
				;*p_d = *p_s;}}}
				
				MOVDQU XMM0, [RDI]
				MOVDQU [RSI], XMM0
				
				CMP R10D, [RBP+16]
				JB .mePaseTile
				MOV R10, 0
				LEA RDI, [R13]
				
	
				
				;R10 CUENTA EL PIXEL DEL RECUADRO
				.mePaseTile:
				MOV R11, R10
				ADD R11, 4
				CMP R11, [RBP+16]
				JBE .sigo
				INC R10
				INC R15
				LEA RDI, [RDI + 3]
				LEA RSI, [RSI + 3]
				JMP .for2
				
				.sigo:
				MOV R11, R15
				ADD R11, 4
				CMP R11, RDX
				JBE .sigo2
				ADD R10, 1
				ADD R15, 1
				LEA RDI, [RDI + 3]
				LEA RSI, [RSI + 3]
				JMP .for2
				
				.sigo2:
				ADD R10, 4
				ADD R15, 4
				LEA RDI, [RDI + 12]
				LEA RSI, [RSI + 12]
				JMP .for2
				
				.endfor2:
				
				XOR RAX, RAX
				XOR R15, R15
				MOV EAX, [RBP + 24] ;TAM Y
				MOV R15, R14 ; FILAS QUE RECORRI
				
				.cicloDiv:
				CMP R15, RAX
				JB .muevoRecuadro
				JE .inicioTiles
				SUB R15, RAX
				CMP R15, RAX
				JG .cicloDiv
				JB .muevoRecuadro
				.inicioTiles:
				LEA RDI, [R12]
				LEA R13, [RDI]
				JMP .muevoDST
				
				.muevoRecuadro:
				LEA RDI, [R13 + R8]
				LEA R13, [RDI]
				
				.muevoDST:
				MOV R15, RDX
				MOV RAX, RDX
				ADD RAX, RAX
				ADD R15, RAX
				SUB R15, R9
				LEA RSI, [RSI + R15]
				
				INC R14
				
				JMP .for1
		
		.endfor1:
    
    
	POP RBP
	RET