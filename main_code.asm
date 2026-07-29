# Dana Hafetha 1211234 sec 1
# Leen Daraghmeh 1210904 sec3

.data 

# Print the welcome message and ask for the file name 
welcome_message:	.asciiz "------------- Welcome to the Program -------------\n\n"
outfile_best: .asciiz "Output_bestfit.txt"

# ASK for input file name to read
ask_file:		.asciiz "Please Enter the file name (using the full path) or Q/q to exit: " 

#Defining the string to save the file name
file:		.space 100
outfile:	.asciiz "Output.txt"
fileWords:	.space 1024	#a buffer to read file elements
.align 2
numbers:	.space 80	#save all the numbers in the file. 4bytes for an integer up to 200 
newline:	.asciiz "\n"

.align 2
dollars_str:  .space 16   # Stores dollar part
cents_buf:    .space 3    # Stores cents (2 digits)
float_result: .space 16   # Final formatted string
floatbest_result: .space 16   # Final formatted string
comma_space:  .asciiz ", "
int_str: 	.space 6
bin_num_str: .space 4

# Defining the error Messages for the Program.
error_open:	.asciiz "Invalid file path please re-check\n"
error_close:	.asciiz	"Error in closing the file\n"
error_read:	.asciiz "Error in reading file contents\n"
error_print:	.asciiz "Error in printing file contents\n"
valid:		.asciiz "Valid file content\n"
invalid:	.asciiz "Invalid file content please insert another file name or fix the content\n"

## for the first fit algorithim
.align 2
bin_remaining: .space 400
.align 2
assigned_bins: .space 400

##for the best fit
.align 2
bin_remaining_best: .space 400
.align 2
assigned_bins_best: .space 400

debug_loop:    .asciiz "\n[DEBUG] Entered item loop...\n"
debug_item:    .asciiz "[DEBUG] Item value: "
debug_newbin:  .asciiz "[DEBUG] Opened a new bin\n"
debug_place:   .asciiz "[DEBUG] Placed in existing bin\n"
debug_placed:  .asciiz "[DEBUG] Item placed in bin: "
debug_reached: .asciiz "\n[DEBUG] Reached DONE section\n"
output_msg:    .asciiz "Total bins used: "
bin_label:     .asciiz "\nBin "
colon_space:   .asciiz ": "

firstfit_msg: 	.asciiz "First Fit Algorithm:\r\n"
bestfit_msg: 	.asciiz "Best Fit Algorithm:\r\n"

ask_algo:      .asciiz "\nChoose algorithm \nFirst Fit (FF) \nBest Fit (BF) \n(m/M)to choose another file \nQ/q to exit: "
algo_input:    .space 4       # space for 2 letters + newline + null
invalid_algo:  .asciiz "Invalid choice. Please choose between FF and BF or Q/q to exit\n"



#Defining the Menu for the Program 

################################### Code Segment ##################################
.text 
.globl main 
main:   #main Program 
	#Printing the Welcome Message
	li $v0, 4
	la $a0, welcome_message
	syscall
	
menu: 	
	#Asking for the file path
	li $v0, 4
	la $a0, ask_file
	syscall
	
	#Read the file path 
	li $v0, 8
	la $a0, file
	li $a1, 100
	syscall
	
	#seeing if the user inserted q or Q to exit
	la $t0, file		# reading what is inside the file
	lb $t1, 0($t0)       	# Load first char
	li $t2, 'Q'		#see if the character is Q
	li $t3, 'q'		#see if the character is q
	beq $t1, $t2, exit	#if any of those exit the program
	beq $t1, $t3, exit

	#else we trim the input file path
	j trim
		
	#prased numbers counter
	li $s1, 0		
	
########################### trimming the \n from the file name ############################
trim:
	lb $t1, 0($t0)			#load the saved file name
	beq $t1, 0, openfile		#if we reach the end of the path 
	beq $t1, 10, replace		#replace \n with \0
	addi $t0, $t0, 1		#go to the next character
	j trim				#re loop
	
replace:
	sb $zero, 0($t0)		#replace \n with 0 that is saved in $zero
	j openfile			#then go to open the file
	
############################ Opening read file ######################################
	
openfile:
	#opening file using syscall 13
	li $v0, 13
	la $a0, file
	li $a1, 0		#open file in read mode
	li $a2, 0		# to insure just read the file that has been already created
	syscall
	
	#check for errors in opening file
	blt $v0, 0, openerror
	move $s0, $v0		#save the file descriptor
	
############################ Reading file contents ######################################
	
fileread:			#as a loop 
	#reading the file contents
	li $v0, 14
	move $a0, $s0
	la $a1, fileWords
	la $a2, 1024		#loading the size that will be read (fileWords size)
	syscall
	
	#check if the reding is alright
	blt $v0, 0, readerror
	beqz $v0, closefile	#if nothing n the file close the file
	
	move $t0, $v0		#bytes read 
	la $t8, fileWords	#pointer to the start of the words buffer
	la $t9, numbers		#pointer to the address of the numbers array
	
	#define the validation flag
	li $s7, 1		# s7 = 1 => valid , s7 = 0 => invalid

############################ traverse file content line by line and print ######################################
	
loop_fileWords:	
	lb $t1,0($t8)		#load current character on t1
	beq $t1, $zero, closefile	#done with printing the buffer line by line
	
	move $t2, $t8		#mark the start of that string
	
findnewline:	#search for \n in the buffer to indicate that the string is finished
	lb $t1, 0($t8)				#t1 the first character of the string
	beq $t1, '\n', printstring		# when the \n is reached it indicates that the line is done
	beq $t1, $zero, printlast		#when done with the last index
	
	addi $t8, $t8, 1			#go to the next character
	j findnewline
	
printstring:
	sb $zero, 0($t8)			#change the \n with \0
	
	#printing the number
	move $a0, $t2
	li $v0, 4
	syscall
	
	# validate the string if it is a float or not
	jal validate
	beqz $v0, notvalid
	
	li $v0, 11
	li, $a0, '\t'
	syscall
	
	#reput the new line again instead of the \0
	li $t1, '\n'
	sb $t1, 0($t8)
	
	addi $t8, $t8, 1	#move to the next character
	j loop_fileWords
	
printlast:
	move $a0,$t2
	li $v0, 4
	syscall
	
	jal validate
	beqz $v0, notvalid
	
	j closefile
	
############################ Validate file contents ######################################
	
validate:
	#check the first character to be zero
	lb $t0, 0($a0)
	li $t1,'0'
	bne $t0, $t1, fail
	
	lb $t0, 1($a0)
	li $t1, '.'
	bne $t0, $t1, fail
	
	#check for the first digit to be an integer
	lb $t2, 2($a0)
	li $t3, '0'
	li $t4, '9'
	blt $t2, $t3, fail	#digit less than 0 -> fail
	bgt $t2, $t4, fail	#digit greater than 9 -> fail
	
	li $t7, 1		#digit count => up to 2 only
	
	#check for the second digit
	lb $t5, 3($a0)
	beqz $t5, checkzero
	beq $t5, '\r', checkzero
	li $t3, '0'
	li $t4, '9'
	blt $t5, $t3, fail	#digit less than 0 -> fail
	bgt $t5, $t4, fail	#digit greater than 9 -> fail
	
	addiu $t7, $t7, 1
	
	#third digit: invalid
	lb $t6, 4($a0)
	beqz $t6, checkzero
	beq $t6, '\r', checkzero
	j fail
	
checkzero:
	#here reject 0.00 and 1.00
	lb $t2, 2($a0)
	li $t3, '0'
	bne $t2, $t3, succeed	# not 0.0
	lb $t4, 3($a0)
	beqz $t4, fail		#0.00
	bne $t4, $t3, succeed	#not 0.00
	j fail
	
succeed:
	li $v0, 1
	jr $ra

fail:	
	li $v0, 0
	jr $ra	
	
notvalid:
	#print a message for invalid and close the file
	li $v0, 11
	li, $a0, '\n'
	syscall
	
	li $v0, 4
	la $a0, invalid
	syscall
	
	li $s7, 0			#make the flag invalid s7 = 0
	j closefile

################################ Closing the file ######################################			
closefile:
	li $v0, 16
	move $a0, $s0
	syscall
	
	#checking if the file is truely closed
	blt $v0, 0, closeerror
	
	#check the flag
	beqz $s7, menu			#if the flag is invlaid return to read the file
	j startparse
	
################ in here we traverse the strings array to convert to the string into integer ##############
startparse:
	#in here redefine the pointers
	la $t8, fileWords	#pointer to the start of the words buffer
	la $t9, numbers		#pointer to the address of the numbers array
	
	#define array index
	li $s1, 0 		#define the conter for the array elements again 
				# in order to not change between the loop turns
		
parseline:	
	lb $t1, 0($t8)
	beqz $t1, exit
	beq $t1, 13, skip	#skip \r\n
	beq $t1, 10, skip	
	
	##start parsing before dot
	sub $t1, $t1, 48	#turn to int
	mul $t2, $t1, 100	#t2 = t1*100
	
	addi $t8, $t8, 2	# skip the dot 
	
	#first digit
	lb $t3, 0($t8)
	sub $t3, $t3, 48
	mul $t3, $t3, 10
	addi $t8, $t8, 1
	
	#before parsing the next digit make sure there is a second digit
	lb $t4, 0($t8)
	li $t6, '0'
	li $t7, '9'
	blt $t4, $t6, onedigit
	bgt $t4, $t7, onedigit
	
	#this is the second digit
	sub $t4, $t4, 48
	j continue

onedigit:
	li $t4, 0

continue:
	#add the numbers togother
	add $t3, $t3, $t4
	add $t2, $t2, $t3
	
	sw $t2, 0($t9)
	addi $t9, $t9, 4	#add the index
	addi $s1, $s1, 1	#increment counter
	
	#print the parsed value
	li $v0, 11
	li $a0,'\n'
	syscall
	
	#print the integer
	move $a0, $t2
	li $v0, 1
	syscall	
	
	j skip
	
skip:
	lb $t5, 0($t8)
	beqz $t5, printnums		#reached the end of the file string
	addi $t8, $t8, 1
	
	beq $t5, 13, skip
	bne $t5 , 10, skip
	
	j parseline
	
	
#################################################################################################	
printnums:
	la $t9, numbers
	#create a counter
	li $t1, 0
	
printloop:
	beq $t1, $s1, askforAlgo	#done with the printing #nned to be change when done with the menu
	
	# load and print the integer
	lw $a0, 0($t9)
	li $v0, 1
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall

	addi $t9, $t9, 4
	addi $t1, $t1, 1
	j printloop
	
########################### Asking on which algorithim to use ###########################
askforAlgo:
	#Asking the user to insert which to use
	li $v0, 4
	la $a0, ask_algo
	syscall
	
	# Read user input (max 3 chars: 2 letters + newline)
	li $v0, 8
	la $a0, algo_input
	li $a1, 4
	syscall
	
	#check if it is m, M to re choose another file
	la $t0, algo_input	
	lb $t1, 0($t0)       	# Load first char
	li $t2, 'M'		#see if the character is M
	li $t3, 'm'		#see if the character is m
	beq $t1, $t2, menu	#if any of those re-ask for input file 
	beq $t1, $t3, menu
	
	#check if it is q or Q to exit
	la $t0, algo_input	
	lb $t1, 0($t0)       	# Load first char
	li $t2, 'Q'		#see if the character is Q
	li $t3, 'q'		#see if the character is q
	beq $t1, $t2, exit	#if any of those exit the program
	beq $t1, $t3, exit

	# Check the two characters in algo_input
	la $t0, algo_input
	lb $t1, 0($t0)       # first char
	lb $t2, 1($t0)       # second char

	# Check for 'f' or 'F' in first char
	li $t3, 'f'
	li $t4, 'F'
	beq $t1, $t3, checkSecondForF
	beq $t1, $t4, checkSecondForF
	
	# Check for 'b' or 'B' in first char
	li $t3, 'b'
	li $t4, 'B'
	beq $t1, $t3, checkSecondForB	
	beq $t1, $t4, checkSecondForB	

checkSecondForF:
	li $t5, 'f'
	li $t6, 'F'
	beq $t2, $t5, firstfit		#go to first fit if any of the cases is entered by user:
	beq $t2, $t6, firstfit		#FF, ff, Ff, fF


checkSecondForB:
	li $t5, 'f'
	li $t6, 'F'
	beq $t2, $t5, bestfit		#go to best fit if any of the cases is entered by user:
	beq $t2, $t6, bestfit		#BF, bf, bF, Bf

invalidAlgo:
	# Print invalid message
	li $v0, 4
	la $a0, invalid_algo
	syscall
	j askforAlgo			#and reask for which algorithim to use
	

##################################### Helping functions ##############################################
# Function to convert integer to string
# Input: $a0 = integer, output in int_str
# Returns length in $v0
int_to_string:
    la $t0, int_str
    li $t1, 0        # length counter
    li $t3, 10       # divisor
    
    # Handle zero case
    beqz $a0, zero_case
    
convert_loop:
    beqz $a0, end_convert
    divu $a0, $t3
    mflo $a0         # quotient
    mfhi $t2         # remainder
    addi $t2, $t2, 48 # convert to ASCII
    sb $t2, 0($t0)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j convert_loop
    
zero_case:
    li $t2, 48
    sb $t2, 0($t0)
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    
end_convert:
    sb $zero, 0($t0) # null terminator
    move $v0, $t1
    jr $ra

# Function to get string length
# Input: $a0 = string address
# Output: $v0 = length
strlen:
    li $v0, 0
strlen_loop:
    lb $t0, 0($a0)
    beqz $t0, strlen_end
    addi $v0, $v0, 1
    addi $a0, $a0, 1
    j strlen_loop
strlen_end:
    jr $ra
    
convert_cents_to_string:
    # Input: $a0 = integer (e.g., 23 for 0.23)
    # Output: string in float_result (e.g., "0.23")

    li $t1, 100
    div $a0, $t1
    mflo $t2           # Dollars (always 0 in this problem)
    mfhi $t3           # Cents (0-99)

    la $t0, float_result

    # Store '0'
    li $t4, 48
    sb $t4, 0($t0)

    # Store '.'
    li $t4, 46
    sb $t4, 1($t0)

    # Convert tens digit of cents
    li $t5, 10
    div $t3, $t5
    mflo $t6
    mfhi $t7

    addi $t6, $t6, 48  # ASCII
    sb $t6, 2($t0)

    addi $t7, $t7, 48  # ASCII
    sb $t7, 3($t0)

    sb $zero, 4($t0)   # Null terminator

    jr $ra

##################################### First Fit Code ####################################################
  
firstfit:

#open write file
openwritefile:
	# Open file for writing and just for the first fit
	li $v0, 13           	# syscall for open file
	la $a0, outfile 	# filename 
	li $a1, 1    
	li $a2, 0    
	syscall
	
	move $s4, $v0          # save file descriptor in $s4
	
continue_firstfit:
	
	la $s0, numbers
	la $s2, bin_remaining
    	la $s3, assigned_bins
	#define the index items
	li $t2, 0 	# counter for the numbers
	li $t5, 0	# bins count
	
	# $s1 saving the number of sizes before
	
	li $v0, 15
	move $a0, $s4
	la $a1, firstfit_msg
	li $a2, 22
	syscall
	
	#print the new line
	li $v0, 15
	move $a0, $s4
	la $a1, newline
	li $a2, 1
	syscall
	
itemloop:
	#in this part we loop the items and get them uploaded to $s6 => the size that will be placed in a pin
	beq $t2, $s1, algofinish	#go to the finish part after the loop is done
	
	#enter the item loop 
	li $v0, 4
	la $a0, debug_loop
	syscall

	#load the sizes
	mul $t6, $t2, 4
	add $t7, $s0, $t6
	lw $s6, 0($t7)
	
	#print the integer 
	li $v0, 4
	la $a0, debug_item 
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $t3, 0	#number of bin
		
checkbins:
#in this part we check which bin to put $s6 in if it is full we open a new bin
	beq $t3, $t5, newbin
	
	mul $t8, $t3, 4		#calculates the byte offset of bin remaining
	add $t9, $s2, $t8	#Calculates the memory address of the current bin’s remaining space
	lw  $s7, 0($t9)		#Loads the remaining space in the current bin into $s7
				#$s7 hold the remaining space in the bin
	
	sub $t4, $s7, $s6	#$t4 = remaining_space - item_size
	bgez $t4, placeitem	#Branch to placeitem: if result is ≥ 0, the item fits in the bin
	
	addiu $t3, $t3, 1	#go to the next bin
	j checkbins
	
placeitem:
	sw $t4, 0($t9)		#stores the new remaining space in the bin 
				# $t4 = bin’s remaining space after placing the item
				# $t9 = address of the bin’s remaining space
	
	# assign the bin 
	mul $t9, $t2, 4		# Records which bin the current item was placed into
	add $t9, $s3, $t9	# Item $t2 was placed in bin $t3
	sw $t3, 0($t9)
	
	li $v0, 4
	la $a0, debug_place
	syscall
	
	li $v0, 4
	la $a0, debug_placed
	syscall
	
	li $v0, 1
	move $a0, $t3
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	addiu $t2, $t2, 1 	#item index ($t2) to move to the next item
	j itemloop
	
newbin:
	#opens a new bin whe there is no enogh space in any of the created pins
	li $t4, 100		#the capcity of the bin 100 means 1.0
	sub $t4, $t4, $s6	# subtract item size ($s6)
	
	mul $t8, $t5, 4		#Stores the remaining space into bin_remaining[$t5] and saved in $t8
	add $t9, $s2, $t8	# $s2 the base address of the bin_remaining
	sw $t4, 0($t9)		# upload the remining space to $t4
	
	
	# assign to the new bin
	# item ($t2) to the newly created bin ($t5)
	mul $t9, $t2, 4		
	add $t9, $s3, $t9
	sw $t5, 0($t9)
	
	li $v0, 4
	la $a0, debug_newbin
	syscall
	
	li $v0, 4
	la $a0, debug_placed
	syscall
	
	li $v0, 1
	move $a0, $t5
	syscall
	
	li $v0, 4
	la $a0, newline 
	syscall
	
	addiu $t5, $t5, 1	# increment number of bins
	addiu $t2, $t2, 1	# increment item index
	li $t0, 0
	j itemloop

algofinish:
	li $v0, 4
	la $a0, debug_reached
	syscall
	
	li $v0, 4
	la $a0, output_msg
	syscall
	
	li $v0, 1
	move $a0, $t5
	syscall
	
	#in here i print the total number of bins used to the file
	la $a0, output_msg
	jal strlen
	move $a2, $v0
	li $v0, 15
	move $a0, $s4
	la $a1, output_msg
	syscall
	
	# Convert and write bin count
	move $a0, $t5
	jal int_to_string
	move $a2, $v0
	li $v0, 15
	move $a0, $s4
	la $a1, int_str
	syscall
    
        # Write newline to file
	li $v0, 15
	move $a0, $s4
	la $a1, newline
	li $a2, 1
	syscall
	
	#print the bin content 
	li $t6, 0
	
printbinloop:
	bge $t6, $t5, closewritefile 	#$t6 is the bin index
	
	li $t7, 0	
		
	li $v0, 4
	la $a0, bin_label
	syscall
	
	li $v0, 1
	move $a0, $t6
	syscall
	
	li $v0, 4
	la $a0, colon_space
	syscall
	
	# Write "Bin X: " to file
	la $a0, bin_label
	jal strlen
	move $a2, $v0
	li $v0, 15
	move $a0, $s4
	la $a1, bin_label
	syscall
    
    	# Write bin number
	move $a0, $t6
	jal int_to_string
	move $a2, $v0
	li $v0, 15
	move $a0, $s4
	la $a1, int_str
	syscall
    
    	# Write ": " to file
	la $a0, colon_space
	jal strlen
	move $a2, $v0
	li $v0, 15
	move $a0, $s4
	la $a1, colon_space
	syscall
	
	
innerloop:
	bge $t7, $s1, endline		# the items in the pin are all printed
	
	mul $t8, $t7, 4			#assigned_bins[item] == current_bin
	add $t9, $s3, $t8		# in order to know in which bin the item is saved in  
	lw $t0, 0($t9)			# if it is not in the current pin skip this item
	bne $t0, $t6, skipline
	
	mul $t8, $t7, 4			#loads the item value
	add $t9, $s0, $t8
	lw $t0, 0($t9)
	
	mtc1 $t0, $f12			#convert the item to float in order to print it as 0.XX
	li $t2, 100
	mtc1 $t2, $f14
	cvt.s.w $f12, $f12
	cvt.s.w $f14, $f14
	div.s $f12, $f12, $f14
	
	li $v0, 2			#prints the float value
	syscall
	
	li $v0, 4
	la $a0, colon_space
	syscall
	
	# Allocate stack space
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)


	# Function call
	move $a0, $t0
	jal convert_cents_to_string

	# Restore values
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	addi $sp, $sp, 28
	
    	# Write to file
    	la $a0, float_result
    	jal strlen
    	move $a2, $v0
    	li $v0, 15
    	move $a0, $s4
    	la $a1, float_result
    	syscall
    	
    	la $a0, colon_space
	jal strlen
	move $a2, $v0
	li $v0, 15
	move $a0, $s4
	la $a1, colon_space
	syscall
	
skipline:
	addiu $t7, $t7, 1
	j innerloop

endline:			# in here we end the printing process by printing a new line 
	li $v0, 4		# and going to the next bin
	la $a0, newline
	syscall
	
	# Write newline to file
	li $v0, 15
	move $a0, $s4
	la $a1, newline
	li $a2, 1
	syscall
	
	addiu $t6, $t6, 1
	j printbinloop
#################################### Closing the write file ###############################################	
closewritefile:

	li $v0, 16
	move $a0, $s4
	syscall
	 
	j askforAlgo
	
##################################### Best Fit Algorithem ###############################################
bestfit:

#open write file
openbestwritefile:
	# Open file for writing and just for the first fit
	li $v0, 13           	# syscall for open file
	la $a0, outfile_best 	# filename 
	li $a1, 1    
	li $a2, 0    
	syscall
	
	move $s7, $v0          # save file descriptor in $s7
	
bestfit_cont:
	la $s0, numbers
	la $s2, bin_remaining_best
    	la $s3, assigned_bins_best
	#define the index items
	li $t2, 0 	# counter for the numbers
	li $t5, 0	# bins count
	
	# $s1 saving the number of sizes before
	
	li $v0, 15
	move $a0, $s7
	la $a1, bestfit_msg
	li $a2, 22
	syscall
	
	#print the new line
	li $v0, 15
	move $a0, $s7
	la $a1, newline
	li $a2, 1
	syscall

bestitemloop:
	beq $t2, $s1, bestfinish
	
	#enter the item loop 
	li $v0, 4
	la $a0, debug_loop
	syscall

	#load the sizes
	mul $t6, $t2, 4
	add $t7, $s0, $t6
	lw $s6, 0($t7)
	
	#print the integer 
	li $v0, 4
	la $a0, debug_item 
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $t3, 0
	li $s4, -1	#best_bin_index
	li $s5, 101	#best remaining
	
bestfitloop:	#s1 instead of t1
	beq $t3, $t5, bestcheckbins
	
	mul $t8, $t3, 4
	add $t9, $s2, $t8
	lw $t0, 0($t9)
	
	sub $t7, $t0, $s6
	bltz $t7, skipbin
	
	bge $t0, $s5, skipbin
	move $s4, $t3
	move $s5, $t0
	
skipbin:
	addiu $t3, $t3, 1
	j bestfitloop
	
bestcheckbins:
	bltz $s4, opennewbin
	
	#update remaining bin
	mul $t8, $s4, 4
	add $t9, $s2, $t8
	lw  $t0, 0($t9)
	sub $t0, $t0, $s6
	sw $t0, 0($t9)
	
	##assign the bin
	mul $t8, $t2, 4
	add $t9, $s3, $t8
	sw $s4, 0($t9)
	
	li $v0, 4
	la $a0, debug_place
	syscall
	
	li $v0, 4
	la $a0, debug_placed
	syscall
	
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	addiu $t2, $t2, 1
	j bestitemloop
	
opennewbin:
	li $t0, 100
	sub $t0, $t0, $s6
	mul $t8, $t5, 4
	add $t9, $s2, $t8
	sw $t0, 0($t9)

	# FIXED: assign bin index to the correct item index!
	mul $t8, $t2, 4
	add $t9, $s3, $t8
	sw $t5, 0($t9)

	li $v0, 4
	la $a0, debug_newbin
	syscall
	
	li $v0, 4
	la $a0, debug_place
	syscall
	
	li $v0, 4
	la $a0, debug_placed
	syscall
	
	li $v0, 1
	move $a0, $t5
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	addiu $t2, $t2, 1
	addiu $t5, $t5, 1
	j bestitemloop
	
bestfinish:
	li $v0, 4
	la $a0, debug_reached
	syscall
	
	li $v0, 4
	la $a0, output_msg
	syscall
	
	li $v0, 1
	move $a0, $t5
	syscall
	
	#in here i print the total number of bins used to the file
	la $a0, output_msg
	jal strlen
	move $a2, $v0
	li $v0, 15
	move $a0, $s7
	la $a1, output_msg
	syscall
	
	# Convert and write bin count
	move $a0, $t5
	jal int_to_string
	move $a2, $v0
	li $v0, 15
	move $a0, $s7
	la $a1, int_str
	syscall
    
        # Write newline to file
	li $v0, 15
	move $a0, $s7
	la $a1, newline
	li $a2, 1
	syscall
	
	#print the bin content 
	li $t6, 0
	
bestprintbinloop:
	bge $t6, $t5, closebestwritefile		#for now it was exit before
	
	li $v0, 4
	la $a0, bin_label
	syscall
	
	li $v0, 1
	move $a0, $t6
	syscall
	
	li $v0, 4
	la $a0, colon_space
	syscall
	
	# Write "Bin X: " to file
	la $a0, bin_label
	jal strlen
	move $a2, $v0
	li $v0, 15
	move $a0, $s7
	la $a1, bin_label
	syscall
    
    	# Write bin number
	move $a0, $t6
	jal int_to_string
	move $a2, $v0
	li $v0, 15
	move $a0, $s7
	la $a1, int_str
	syscall
    
    	# Write ": " to file
	la $a0, colon_space
	jal strlen
	move $a2, $v0
	li $v0, 15
	move $a0, $s7
	la $a1, colon_space
	syscall
	
	li $t7, 0
	
bestinnerloop:
	bge $t7, $s1, bestendline
	
	mul $t8, $t7, 4
	add $t9, $s3, $t8
	lw $t0, 0($t9)
	bne $t0, $t6, bestskipline
	
	mul $t8, $t7, 4
	add $t9, $s0, $t8
	lw $t1, 0($t9)
	
	#convert to float before print
	mtc1 $t1, $f12
	li $t2, 100
	mtc1 $t2, $f14
	cvt.s.w $f12, $f12
	cvt.s.w $f14, $f14
	div.s $f12, $f12, $f14
	
	#print the float number
	li $v0, 2
	syscall
	
	li $v0, 4
	la $a0, colon_space
	syscall
	
	# Allocate stack space
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)


	# Function call
	move $a0, $t1
	jal convert_cents_to_string

	# Restore values
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	addi $sp, $sp, 28
	
    	# Write to file
    	la $a0, float_result
    	jal strlen
    	move $a2, $v0
    	li $v0, 15
    	move $a0, $s7
    	la $a1,	float_result
    	syscall
    	
    	la $a0, colon_space
	jal strlen
	move $a2, $v0
	li $v0, 15
	move $a0, $s7
	la $a1, colon_space
	syscall
	
bestskipline:
	addiu $t7, $t7, 1
	j bestinnerloop

bestendline:
	li $v0, 4
	la $a0, newline
	syscall
	
	# Write newline to file
	li $v0, 15
	move $a0, $s7
	la $a1, newline
	li $a2, 1
	syscall
	
	addiu $t6, $t6, 1
	j bestprintbinloop
	
#################################### Closing the write file ###############################################	
closebestwritefile:

	li $v0, 16
	move $a0, $s7
	syscall
	 
	j askforAlgo

##################################### Error Messages ####################################################
	
openerror:
	li $v0, 4
	la $a0, error_open
	syscall
	
	# and return to reask for the file name
	j menu
	
closeerror:
	li $v0, 4
	la $a0, error_close
	syscall
	
readerror:
	li $v0, 4
	la $a0, error_read
	syscall
	
printerror:
	li $v0, 4
	la $a0, error_print
	syscall
	
################################## Exiting the Program ###############################################	
exit:
	li $v0, 10
	syscall
