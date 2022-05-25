.text
f2048:
	move $t0,$a0
	li $t1,0
	j comprobar_Isvacia #comprobamos si la matriz de entrada esta vacía

matriz_correcta1:	
	move $t0,$a0
	li $t1,1 #mascara
	li $t5,0
	j comprobar_Isvalida #comprobamos si la matriz de entrada contiene valores correctos (0 o 2^i, siendo i de 1-10)
	
	
matriz_correcta2:
	addi $sp,$sp,-28
	sw $ra,0($sp) #guardas $ra de f2048
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $s2,12($sp)
	sw $s3,16($sp)
	sw $s4,20($sp)
	sw $s5,24($sp)
	add $s5,$zero,$zero
	
	beq $a1,'D',movimiento_derecha #salto si tecleamos "D"
	beq $a1,'d',movimiento_derecha #salto si tecleamos d"
	
	beq $a1,'S',movimiento_abajo #salto si tecleamos "S"
	beq $a1,'s',movimiento_abajo #salto si tecleamos "s"
	
	beq $a1,'A',movimiento_izquierda #salto si tecleamos "A"
	beq $a1,'a',movimiento_izquierda #salto si tecleamos "a"
	
	beq $a1,'W',movimiento_arriba #salto si tecleamos "W"
	beq $a1,'w',movimiento_arriba #salto si tecleamos "w"
	
	j fin_exception1 #salto si $a1 contiene un movimiento fuera de los permitidos

###################################################################################

comprobar_Isvacia:
	bgt $t1,15,fin_excepcion3 #si recorremos toda la matriz quiere decir que esta vacia
	lw $t2,($t0)
	bne $t2,$zero,matriz_correcta1
	addi $t0,$t0,4 #siguiente posicion
	addi $t1,$t1,1
	j comprobar_Isvacia

###################################################################################

comprobar_Isvalida: #contamos el numero de 1's de cada valor de la matriz, ya que las potencias de 2 solo tienen un 1 (binario)
	li $t4,0
	bgt $t5,15,matriz_correcta2 #si recorremos todas las posiciones sin fallo significa que contiene valores correctos
	lw $t2,($t0)
	bgt $t2,1024,fin_excepcion2
	beq $t2,1,fin_excepcion2
	beq $t2,$zero,siguiente_num #si leemos un cero pasamos a la siguiente posicion directamente
num_valido:
	and $t3,$t1,$t2
	bne $t3,$zero,find_1
	beq $t2,0,siguiente_num
seguir_buscando:
	srl $t2,$t2,1
	j num_valido
find_1:
	addi $t4,$t4,1 #contador de 1's
	bgt $t4,1,fin_excepcion2
	j seguir_buscando
siguiente_num:
	addi $t0,$t0,4
	addi $t5,$t5,1
	j comprobar_Isvalida
	
###################################################################################
movimiento_derecha:
	
	jal mov_drcha
	jal suma_drcha
	jal mov_drcha
	
	j final

movimiento_izquierda:
	
	jal mov_izquierda
	jal suma_izquierda
	jal mov_izquierda
	
	j final

movimiento_arriba:
	
	jal mov_arriba
	jal suma_arriba
	jal mov_arriba
	
	j final

movimiento_abajo:
	
	jal mov_abajo
	jal suma_abajo
	jal mov_abajo
	
final: #final de la funcion	 
	beq $s5,$zero,fin_exception4 #salto si no se producen cambios en la matriz
	li $v0,0 #todo es correcto
	j carga_pila
fin_exception1:	
	li $v0,1
	j carga_pila
fin_exception4:	
	li $v0,4
carga_pila:
	lw $ra,0($sp) #guardas $ra de f2048
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $s2,12($sp)
	lw $s3,16($sp)
	lw $s4,20($sp)
	lw $s5,24($sp)
	addi $sp,$sp,28
	jr $ra #volvemos a la instruccion siguiente de jal f2048

fin_excepcion2: #final de la funcion con el error valores no validos
	li $v0,2
	jr $ra
		
fin_excepcion3: #final de la funcion con el error matriz vacia
	li $v0,3
	jr $ra

###################################################################################
	
mov_drcha: #inicialización de los bucles i,j
	addi $sp,$sp,-4
	sw $ra, 0($sp)	
	li $s0,0 #bucle i
	li $s1,3 #bucle j
	move $s3,$a0
	
bucleJ_derecha:
	blt $s1,0,bucleI_derecha #salto cuando se termina de recorrer toda la fila
	move $a0,$s3
	move $a1,$s0
	move $a2,$s1
	jal LeeAij #leemos el valor A[i][j]
	addi $s2,$s1,-1 #bucle k
	bne $v0,$zero,bucleJ2_derecha #si no se cumple la condicion para entrar al bucle K salto a bucleJ2_derecha
	
bucleK_derecha:
	blt $s2,$zero,bucleI_derecha
	move $a0,$s3
	move $a1,$s0
	move $a2,$s2
	jal LeeAij #leemos el valor A[i][k], y lo almacenamos en $v0
	blt $s2,$zero,bucleI_derecha #si recorremos con el bucle k toda la fila salto a bucleI_derecha para pasar a la fila siguiente
	beq $v0,$zero,bucleK2_derecha #si no se cumple la condicion para seguir en el bucle salto a bucleK2_derecha
	move $a0,$s3
	move $a1,$s0
	move $a2,$s1
	move $a3,$v0
	addi $s5,$s5,1
	jal EscAij #escribimos en A[i][j] el valor de A[i][k]
	move $a0,$s3
	move $a1,$s0
	move $a2,$s2
	move $a3,$zero
	jal EscAij #escribimos en A[i][k] un 0
	addi $s2,$s2,-1 #bucle k
	addi $s1,$s1,-1 #bucle j
	j bucleJ_derecha
	
bucleI_derecha: #al cambiar de fila reestablecemos el valor de la j e incrementamos i, si i>3 (j) significa final del movimiento y pasamos a la suma
	addi $s0,$s0,1
	li $s1,3
	bgt $s0,$s1,fin_mov_drcha
	j bucleJ_derecha
	
bucleJ2_derecha:
	addi $s1,$s1,-1
	j bucleJ_derecha
	
bucleK2_derecha:
	addi $s2,$s2,-1
	j bucleK_derecha
	
fin_mov_drcha:
	move $a0,$s3
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra

###################################################################################
	
suma_drcha:
	addi $sp,$sp,-4
	sw $ra,0($sp)

	move $s3,$a0
	li $s0,0 #bucle i
	li $s1,3 #bucle j
bucleJ_sumaderecha:
	beq $s1,0,bucleI_sumaderecha #salto cuando se termina de recorrer toda la fila
	move $a0,$s3
	move $a1,$s0
	move $a2,$s1
	jal LeeAij
	move $s2,$v0 #obtenemos el valor de A[i][j]
	addi $s4,$s1,-1
	move $a0,$s3
	move $a1,$s0
	move $a2,$s4
	jal LeeAij #leemos el valor de A[i][j-1]
	bne $s2,$v0,bucleJ_sumaderecha2 #si $s2 y $v0 son distintos salto para decrementar j y seguir en el bucleJ_sumaderecha2
	beq $v0,$zero,bucleJ_sumaderecha2
	move $a0,$s3	
	move $a1,$s0
	move $a2,$s4
	move $a3,$zero
	addi $s5,$s5,1
	jal EscAij #escribimos un 0 en la posicion A[i][j-1]
	move $a0,$s3
	move $a1,$s0
	move $a2,$s1
	add $a3,$s2,$s2
	jal EscAij #escribimos el valor de $s2*2 en A[i][j]
	addi $s1,$s1,-1
	j bucleJ_sumaderecha
	
bucleI_sumaderecha: #al cambiar de fila reestablecemos el valor de la j e incrementamos i, si i>3 (j) significa final de la suma y pasamos a mover de nuevo a la derecha
	addi $s0,$s0,1
	li $s1,3
	bgt $s0,$s1,fin_sum_drcha
	j bucleJ_sumaderecha
		
bucleJ_sumaderecha2:
	addi $s1,$s1,-1
	j bucleJ_sumaderecha
	
fin_sum_drcha:
	move $a0,$s3
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
###################################################################################

#el movimiento abajo se obtiene realizando las misma instrucciones que en el mov derecha
#sobre la matriz A traspuesta, luego lo único distinto es el intercambio entre los valores de i y j

mov_abajo: 
	addi $sp,$sp,-4
	sw $ra, 0($sp)	
	li $s0,0 
	li $s1,3 
	move $s3,$a0
	
bucleJ_abajo:
	blt $s1,0,bucleI_abajo
	move $a0,$s3
	move $a1,$s1
	move $a2,$s0
	jal LeeAij
	addi $s2,$s1,-1 
	bne $v0,$zero,bucleJ2_abajo 
	
bucleK_abajo:
	blt $s2,$zero,bucleI_abajo
	move $a0,$s3
	move $a1,$s2
	move $a2,$s0
	jal LeeAij 
	blt $s2,$zero,bucleI_abajo
	beq $v0,$zero,bucleK2_abajo
	move $a0,$s3
	move $a1,$s1
	move $a2,$s0
	move $a3,$v0
	addi $s5,$s5,1
	jal EscAij
	move $a0,$s3
	move $a1,$s2
	move $a2,$s0
	move $a3,$zero
	jal EscAij
	addi $s2,$s2,-1 
	addi $s1,$s1,-1
	j bucleJ_abajo
	
bucleI_abajo:
	addi $s0,$s0,1
	li $s1,3
	bgt $s0,$s1,fin_mov_abajo
	j bucleJ_abajo
	
bucleJ2_abajo:
	addi $s1,$s1,-1
	j bucleJ_abajo
	
bucleK2_abajo:
	addi $s2,$s2,-1
	j bucleK_abajo
	
fin_mov_abajo:
	move $a0,$s3
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra

###################################################################################
	
suma_abajo:
	addi $sp,$sp,-4
	sw $ra,0($sp)

	move $s3,$a0
	li $s0,0 
	li $s1,3
bucleJ_sumaabajo:
	beq $s1,0,bucleI_sumaabajo
	move $a0,$s3
	move $a1,$s1
	move $a2,$s0
	jal LeeAij
	move $s2,$v0
	addi $s4,$s1,-1
	move $a0,$s3
	move $a1,$s4
	move $a2,$s0
	jal LeeAij
	bne $s2,$v0,bucleJ_sumaabajo2 
	beq $v0,$zero,bucleJ_sumaabajo2 
	move $a0,$s3	
	move $a1,$s4
	move $a2,$s0
	move $a3,$zero
	addi $s5,$s5,1
	jal EscAij
	move $a0,$s3
	move $a1,$s1
	move $a2,$s0
	add $a3,$s2,$s2
	jal EscAij 
	addi $s1,$s1,-1
	j bucleJ_sumaabajo
	
bucleI_sumaabajo:
	addi $s0,$s0,1
	li $s1,3
	bgt $s0,$s1,fin_sum_abajo
	j bucleJ_sumaabajo
		
bucleJ_sumaabajo2:
	addi $s1,$s1,-1
	j bucleJ_sumaabajo
	
fin_sum_abajo:
	move $a0,$s3
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra

###################################################################################

mov_izquierda: #inicialización de los bucles i,j
	addi $sp,$sp,-4
	sw $ra, 0($sp)	
	li $s0,0 #bucle i
	li $s1,0 #bucle j
	move $s3,$a0
	
bucleJ_izquierda:
	bgt $s1,3,bucleI_izquierda #salto cuando se termina de recorrer toda la fila
	move $a0,$s3
	move $a1,$s0
	move $a2,$s1
	jal LeeAij
	addi $s2,$s1,1 #bucle k
	bne $v0,$zero,bucleJ2_izquierda #si no se cumple la condicion para entrar al bucle K salto a bucleJ2_izquierda
	
bucleK_izquierda:
	bgt $s2,3,bucleI_izquierda
	move $a0,$s3
	move $a1,$s0
	move $a2,$s2
	jal LeeAij #leemos el valor A[i][k], y lo almacenamos en $v0
	bgt $s2,3,bucleI_izquierda #si recorremos con el bucle k toda la fila salto a bucleI_izquierda para pasar a la fila siguiente
	beq $v0,$zero,bucleK2_izquierda #si no se cumple la condicion para seguir en el bucle salto a bucleK2_izquierda
	move $a0,$s3
	move $a1,$s0
	move $a2,$s1
	move $a3,$v0
	addi $s5,$s5,1
	jal EscAij #escribimos en A[i][j] el valor de A[i][k]
	move $a0,$s3
	move $a1,$s0
	move $a2,$s2
	move $a3,$zero
	jal EscAij #escribimos en A[i][k] un 0
	addi $s2,$s2,1 #bucle k
	addi $s1,$s1,1 #bucle j
	j bucleJ_izquierda
	
bucleI_izquierda: #al cambiar de fila reestablecemos el valor de la j e incrementamos i, si i>3 (j) significa final del movimiento y pasamos a la suma
	addi $s0,$s0,1
	li $s1,0
	bgt $s0,3,fin_mov_izquierda
	j bucleJ_izquierda
	
bucleJ2_izquierda:
	addi $s1,$s1,1
	j bucleJ_izquierda
	
bucleK2_izquierda:
	addi $s2,$s2,1
	j bucleK_izquierda
	
fin_mov_izquierda:
	move $a0,$s3
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra

###################################################################################
	
suma_izquierda:
	addi $sp,$sp,-4
	sw $ra,0($sp)

	move $s3,$a0
	li $s0,0 #bucle i
	li $s1,0 #bucle j
bucleJ_sumaizquierda:
	bgt $s1,3,bucleI_sumaizquierda #salto cuando se termina de recorrer toda la fila
	move $a0,$s3
	move $a1,$s0
	move $a2,$s1
	jal LeeAij
	move $s2,$v0 #obtenemos el valor de A[i][j]
	addi $s4,$s1,1
	move $a0,$s3
	move $a1,$s0
	move $a2,$s4
	jal LeeAij #leemos el valor de A[i][j+1]
	bne $s2,$v0,bucleJ_sumaizquierda2 #si $s2 y $v0 son distintos salto para incrementar j, no hacemos suma
	beq $v0,$zero,bucleJ_sumaizquierda2
	move $a0,$s3	
	move $a1,$s0
	move $a2,$s4
	move $a3,$zero
	addi $s5,$s5,1
	jal EscAij #escribimos un 0 en la posicion A[i][j+1]
	move $a0,$s3
	move $a1,$s0
	move $a2,$s1
	add $a3,$s2,$s2
	jal EscAij #escribimos el valor de $s2*2 en A[i][j]
	addi $s1,$s1,1
	j bucleJ_sumaizquierda
	
bucleI_sumaizquierda: #al cambiar de fila reestablecemos el valor de la j e incrementamos i, si i>3 (j) significa final de la suma y pasamos a mover de nuevo a la derecha
	addi $s0,$s0,1
	li $s1,0
	bgt $s0,3,fin_sum_izquierda
	j bucleJ_sumaizquierda
		
bucleJ_sumaizquierda2:
	addi $s1,$s1,1
	j bucleJ_sumaizquierda
	
fin_sum_izquierda:
	move $a0,$s3
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	
###################################################################################

#el movimiento arriba se obtiene realizando las misma instrucciones que en el mov izquierda
#sobre la matriz A traspuesta, luego lo único distinto es el intercambio entre los valores de i y j

mov_arriba:
	addi $sp,$sp,-4
	sw $ra, 0($sp)	
	li $s0,0
	li $s1,0
	move $s3,$a0
	
bucleJ_arriba:
	bgt $s1,3,bucleI_arriba
	move $a0,$s3
	move $a1,$s1
	move $a2,$s0
	jal LeeAij
	addi $s2,$s1,1 
	bne $v0,$zero,bucleJ2_arriba 
	
bucleK_arriba:
	bgt $s2,3,bucleI_arriba
	move $a0,$s3
	move $a1,$s2
	move $a2,$s0
	jal LeeAij 
	bgt $s2,3,bucleI_arriba 
	beq $v0,$zero,bucleK2_arriba 
	move $a0,$s3
	move $a1,$s1
	move $a2,$s0
	move $a3,$v0
	addi $s5,$s5,1
	jal EscAij
	move $a0,$s3
	move $a1,$s2
	move $a2,$s0
	move $a3,$zero
	jal EscAij
	addi $s2,$s2,1 
	addi $s1,$s1,1 
	j bucleJ_arriba
	
bucleI_arriba: 
	addi $s0,$s0,1
	li $s1,0
	bgt $s0,3,fin_mov_arriba
	j bucleJ_arriba
	
bucleJ2_arriba:
	addi $s1,$s1,1
	j bucleJ_arriba
	
bucleK2_arriba:
	addi $s2,$s2,1
	j bucleK_arriba
	
fin_mov_arriba:
	move $a0,$s3
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra

###################################################################################
	
suma_arriba:
	addi $sp,$sp,-4
	sw $ra,0($sp)

	move $s3,$a0
	li $s0,0 
	li $s1,0
bucleJ_sumaarriba:
	bgt $s1,3,bucleI_sumaarriba 
	move $a0,$s3
	move $a1,$s1
	move $a2,$s0
	jal LeeAij
	move $s2,$v0 
	addi $s4,$s1,1
	move $a0,$s3
	move $a1,$s4
	move $a2,$s0
	jal LeeAij
	bne $s2,$v0,bucleJ_sumaarriba2 
	beq $v0,$zero,bucleJ_sumaarriba2
	move $a0,$s3	
	move $a1,$s4
	move $a2,$s0
	move $a3,$zero
	addi $s5,$s5,1
	jal EscAij 
	move $a0,$s3
	move $a1,$s1
	move $a2,$s0
	add $a3,$s2,$s2
	jal EscAij 
	addi $s1,$s1,1
	j bucleJ_sumaarriba
	
bucleI_sumaarriba: 
	addi $s0,$s0,1
	li $s1,0
	bgt $s0,3,fin_sum_arriba
	j bucleJ_sumaarriba
		
bucleJ_sumaarriba2:
	addi $s1,$s1,1
	j bucleJ_sumaarriba
	
fin_sum_arriba:
	move $a0,$s3
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra