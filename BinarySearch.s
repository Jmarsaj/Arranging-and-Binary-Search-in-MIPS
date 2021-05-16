.data 

original_list: .space 100 
sorted_list: .space 100

str0: .asciiz "Enter size of list (between 1 and 25): "
str1: .asciiz "Enter one list element: "
str2: .asciiz "Content of original list: "
str3: .asciiz "Enter a key to search for: "
str4: .asciiz "Content of sorted list: "
strYes: .asciiz "Key found!"
strNo: .asciiz "Key not found!"
newLine: .asciiz "\n"



.text 

#This is the main program.
#It first asks user to enter the size of a list.
#It then asks user to input the elements of the list, one at a time.
#It then calls printList to print out content of the list.
#It then calls inSort to perform insertion sort
#It then asks user to enter a search key and calls bSearch on the sorted list.
#It then prints out search result based on return value of bSearch
main: 
	addi $sp, $sp -8
	sw $ra, 0($sp)
	li $v0, 4 
	la $a0, str0 
	syscall 
	li $v0, 5	#read size of list from user
	syscall
	move $s0, $v0
	move $t0, $0
	la $s1, original_list
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	#read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	move $a0, $s1
	move $a1, $s0
	
	jal inSort	#Call inSort to perform insertion sort in original list
	
	sw $v0, 4($sp)
	li $v0, 4 
	la $a0, str2 
	syscall 
	la $a0, original_list
	move $a1, $s0	
	jal printList	#Print original list
	li $v0, 4 
	la $a0, str4 
	syscall 
	lw $a0, 4($sp)
	jal printList	#Print sorted list
	
	li $v0, 4 
	la $a0, str3 
	syscall 
	li $v0, 5	#read search key from user
	syscall
	move $a3, $v0
	lw $a0, 4($sp)
	jal bSearch	#call bSearch to perform binary search
	
	beq $v0, $0, notFound
	li $v0, 4 
	la $a0, strYes 
	syscall 
	j end
	
notFound:
	li $v0, 4 
	la $a0, strNo 
	syscall 
end:
	lw $ra, 0($sp)
	addi $sp, $sp 8
	li $v0, 10 
	syscall
	
	
#printList takes in a list and its size as arguments. 
#It prints all the elements in one line.
printList:
	#Your implementation of printList here	
	move $t1, $a0			# array
	move $t0, $zero
printloop:	
	lw $t2, 0($t1)
	addi $t1, $t1, 4
	
	li $v0, 1
	move $a0, $t2
	syscall
	
	li $a0, 32			# for space between numbers
	li $v0, 11
	syscall
	
	addi $t0, $t0, 1
	blt $t0, $a1, printloop
			
	li $v0, 4
	la $a0, newLine
	syscall
	jr $ra
	
	
#inSort takes in a list and it size as arguments. 
#It performs INSERTION sort in ascending order and returns a new sorted list
#You may use the pre-defined sorted_list to store the result
inSort:
	#Your implementation of inSort here
	la $t2, sorted_list
	move $t0, $a0			# list
	move $t1, $a1			# size of list
	move $t4, $zero
	
listCopy:
	lw $t3, 0($t0)
	sw $t3, 0($t2)
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	addi $t4, $t4, 1
	blt $t4, $t1, listCopy		
											
	li $t0, 1			# setting $t0 = i as 1
	la $s2, sorted_list		# might have to change $s2 to $t2
	
loopStart:
	bge $t0, $a1, loopFail1		# i < n
	mul $t7, $t0, 4
	add $t7, $t7, $s2
	lw $t6, 0($t7)			# $t6 = key = arr[i]
	addi $t1, $t0, -1		# j = i - 1

whileLoop:	
	blt $t1, $zero, loopFail2	# j >= 0
	mul $t7, $t1, 4
	add $t7, $t7, $s2
	lw $t5, 0($t7)			# arr[j]
	ble $t5, $t6, loopFail2		# arr[j] > key
	
	addi $t4, $t1, 1			# j + 1
	mul $t4, $t4, 4
	add $t4, $t4, $s2
	sw, $t5, 0($t4)			# storing arr[j] in arr[j+1]
	addi $t1, $t1, -1		# j = j - 1
	j whileLoop
	
loopFail2:
	addi $t4, $t1, 1
	mul $t4, $t4, 4
	add $t4, $t4, $s2
	sw $t6, 0($t4)			# storing key in arr[j+1]
	addi $t0, $t0, 1			# i++
	j loopStart
	
loopFail1:
	la $v0, sorted_list
	jr $ra
	
	
#bSearch takes in a list, its size, and a search key as arguments.
#It performs binary search RECURSIVELY to look for the search key.
#It will return a 1 if the key is found, or a 0 otherwise.
#Note: you MUST NOT use iterative approach in this function.
bSearch:
	#Your implementation of bSearch here
	# $a0 = sorted list
	# $a1 = size of list
	# $a2 = 
	# $a3 = search key
	move $t1, $zero			# $t1 = l = 0 assigned when calling the function
	addi $t0, $a1, -1		# $t0 = r = size - 1
bSearchStart:
	blt $t0, $t1, loopFail3		# r >= l
	sub $t2, $t0, $t1		# r - l
	div $t2, $t2, 2			# (r-l)/2
	add $t2, $t2, $t1		# mid = l + ((r-l)/2)
	mul $t3, $t2, 4			
	add $t3, $t3, $a0
	lw $t4, 0($t3)			# arr[mid]
	
	bne $t4, $a3, loopFail4		# arr[mid] == search key
	addi $v0, $zero, 1
	jr $ra
	
loopFail4:
	ble $t4, $a3, loopFail5		# arr[mid] > search key
	addi $t2, $t2, -1		# mid - 1
	move $t0, $t2			# updates r as mid - 1
	j bSearchStart
	
loopFail5:
	addi $t2, $t2, 1			# mid + 1
	move $t1, $t2			# updates l as mid + 1
	j bSearchStart
	
loopFail3:
	move $v0, $zero
	jr $ra
	
