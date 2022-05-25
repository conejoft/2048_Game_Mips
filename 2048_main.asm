
.data
_Comienzo:	.asciiz "-- Estado inicial --\n"
_PideMatriz: 	.asciiz "\n Dame el estado inicial (16 n�meros): "
_PideJugada:	.asciiz "\nMovimiento: "
_Mensaje_error1:.asciiz "\nERROR 1 - MOVIMIENTO NO PERMITIDO"
_Mensaje_error2:.asciiz "\nERROR 2 - MATRIZ CON VALORES NO VALIDOS"
_Mensaje_error3:.asciiz "\nERROR 3 - MATRIZ VACIA"
_Mensaje_error4:.asciiz "\nERROR 4 - MOVIMIENTO SIN CAMBIOS"
_MensajeOtro: 	.asciiz "\nERROR: CODIGO DE ERROR DESCONOCIDO"
_Mensaje_Ctxt:	.ascii "\nERROR DE CONTEXTO. REGISTRO $s"
_NRegS:		.byte 0
		.asciiz " MODIFICADO"
		.align 2
_Matriz: 	.word   0 2 4 8 0 32 128 4 0 2 4 8 0 2 2 2  # <-------- Poner aqu� el estado inicial de prueba .space 64
_Buffer: 	.space 4
.text
main:
# 	PIDE LA MATRIZ
#	la $a0, _PideMatriz
#	li $v0, 4
#	syscall
#	la $s0, _Matriz
#	li $t0, 16
#_BuclePedir:
#	li $v0, 5
#	syscall
#	sw $v0, ($s0)
#	addi $t0, $t0, -1
#	addi $s0, $s0, 4
#	bne $t0, $zero, _BuclePedir
	la $a0, _Comienzo
	li $v0, 4
	syscall
	la $a0, _Matriz
	jal PrintMatrix
	li $v0, 4
	la $a0, _PideJugada
	syscall
	li $v0, 8
	la $a0, _Buffer
	li $a1, 2
	syscall
	li $s0, 1048
	li $s1, 1049
	li $s2, 1050
	li $s3, 1051
	li $s4, 1052
	li $s5, 1053
	li $s6, 1054
	li $s7, 1055	
	lw   $a1, ($a0)
	la $a0, _Matriz
	jal f2048
	li $t0, 48
	addi $s0, $s0, -1000
	addi $s1, $s1, -1000
	addi $s2, $s2, -1000
	addi $s3, $s3, -1000
	addi $s4, $s4, -1000
	addi $s5, $s5, -1000
	addi $s6, $s6, -1000
	addi $s7, $s7, -1000
	bne  $s0, $t0, _ErrorCtxt
	addi $t0, $t0, 1
	bne  $s1, $t0, _ErrorCtxt
	addi $t0, $t0, 1
	bne  $s2, $t0, _ErrorCtxt
	addi $t0, $t0, 1
	bne  $s3, $t0, _ErrorCtxt
	addi $t0, $t0, 1
	bne  $s4, $t0, _ErrorCtxt
	addi $t0, $t0, 1
	bne  $s5, $t0, _ErrorCtxt
	addi $t0, $t0, 1
	bne  $s6, $t0, _ErrorCtxt
	addi $t0, $t0, 1
	bne  $s7, $t0, _ErrorCtxt			
	bne $v0, $zero, _ImprimirError
	li $a0, '\n'
	li $v0, 11
	syscall
	la $a0, _Matriz	
	jal PrintMatrix
_FinMain:	       
	li $v0,10
	syscall
	
_ImprimirError:	
	beq $v0, 1, _Error1
	beq $v0, 2, _Error2
	beq $v0, 3, _Error3	
	beq $v0, 4, _Error4
	la  $a0, _MensajeOtro
	b _ImprimeError
_Error1:la  $a0, _Mensaje_error1
	b _ImprimeError
_Error2:la  $a0, _Mensaje_error2
	b _ImprimeError
_Error3:la  $a0, _Mensaje_error3
	b _ImprimeError
_Error4:la  $a0, _Mensaje_error4
_ImprimeError:
	li $v0,4
	syscall	
	li $v0,10
	syscall	
_ErrorCtxt:
	sb $t0, _NRegS
	la $a0, _Mensaje_Ctxt
	li $v0,4
	syscall	
	li $v0,10
	syscall	
	
		
.include "Funciones.asm"  	# Aqu� van las funciones LeeAij, EscAij y PrintMatrix
.include "Funcion2048.asm"	# Aqu� va la funci�n f2048 y las dem�s funciones necesarias.