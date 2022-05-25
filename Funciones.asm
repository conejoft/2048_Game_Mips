	LeeAij:
		move $t5,$a0
		sll $t8,$a1,4 #$t1<--16*$a1
		sll $t9,$a2,2 #$t2<--4*$a2
		add $t5,$t5,$t8 #$a0<--$a0+$t1
		add $t5,$t5,$t9 #$a0<--$a0+$t2
		lw $v0,($t5) #cargamos en $t0 el valor que apunta la direccion de memoria contenida en $a0
		jr $ra
		
	EscAij:
		move $t5,$a0
		sll $t8,$a1,4 #$t1<--16*$a1
		sll $t9,$a2,2 #$t2<--4*$a2
		add $t5,$t5,$t8 #$a0<--$a0+$t1
		add $t5,$t5,$t9 #$a0<--$a0+$t2
		sw $a3,($t5) #guardamos el contenido de $a3 en la posicion apuntada por la direccion de memoria contenida en $a0
		jr $ra
	
	PrintMatrix:		
			move $t6,$a0 #$t7 contiene la dir de la matriz de entrada
			li $t1,0 #indice de la fil
		inicializacion_col:
			li $t0,0 #indice de la col
			li $t2,4 #condicion de salto
		print_fila:
			move $t7,$t6
			bge $t0,$t2,final_fila #si $t0>=$t2(4) salto a la etiqueta
			bge $t1,$t2,fin_matrix #si $t1>=$t2(4) salto a la etiqueta
			sll $t3,$t1,4 #$t3<--16*$t1
			sll $t4,$t0,2 #$t4<--4*$t0
			add $t7,$t7,$t3 #$a0<--$a0+$t3
			add $t7,$t7,$t4 #$a0<--$a0+$t4
			lw $t3($t7) #cargamos en $t3 el valor que apunta la direccion de memoria contenida en $a0
			move $a0,$t3 #movemos contenido de $t3 a $a0
			li $v0,1
			syscall #imprime el int contenido en $a0
			li $a0,9 #cargamos en $a0 el char '\t'
			li $v0,11
			syscall #imprime el char contenido en $a0
			addi $t0,$t0,1 #incrementamos en 1 $t0 cada vuelta del bucle(print_fila)
			j print_fila
		final_fila:
			li $a0,10#cargamos en $a0 el char '\n'
			li $v0,11
			syscall #imprime el char contenido en $a0
			addi $t1,$t1,1 #incrementamos en 1 $t1 cada vez que se imprime una fila completa
			j inicializacion_col
		fin_matrix:
			jr $ra