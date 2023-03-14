########### Sophie Leonhardt ############

###################################
##### DO NOT ADD A DATA SECTION ###
###################################

.text
######################################################PART 1: Hash a message
.globl hash
hash:
#preamble
addi $sp, $sp, -8  #allocate space on stack lcm
sw $a0, 0($sp)     #store a0 on stack because of nested function call gcd
sw $ra, 4($sp)     #store on stack space return address
li $v0, 0                                        #make sure v0 is not a garbage value but 0
loop_through_string: 
lb $t0, 0($a0)                                   #load first character into t0
beq $t0, $0, jumpOut                             #if string reached null terminator jump out
add $v0, $v0, $t0                                #add first character to v0
addi $a0, $a0, 1                                 #increment to next character
j loop_through_string
jumpOut:
#postamble
lw $a0, 0($sp)
lw $ra, 4($sp)
addi $sp, $sp, 8 #deacllocate space from stack 

  jr $ra

######################################################PART 2: Detect primes
.globl isPrime
isPrime:
#preamble
addi $sp, $sp, -8  #allocate space on stack lcm
sw $a0, 0($sp)     #store a0 on stack because of nested function call gcd
sw $ra, 4($sp)     #store on stack space return address

#check bases cases n = 0 or n =1
#otherwise set i = 2 (start at 2),  if (n == i) return true if (n%i = 0) return false i++
li $t0, 0  #load 0 for n = 0
li $t1, 1  #load 1 for n = 1
li $t2, 2  #load counter i
beq $a0, $t0, false
beq $a0, $t1, false
primeLoop:                #otherwise passed base cases
beq $a0, $t2, true        #if a0 = i then true
div $a0, $t2              #a0%t2       
mfhi $t4                  #move remainder into t4
beqz $t4, false           #if rem = 0 then false
addi $t2,$t2,1 #increment i 
j primeLoop

false: #set v0 to 1 
li $v0, 0
j donePrime
true:  #set v0 to 0
li $v0, 1
donePrime:

#postamble
lw $a0, 0($sp)
lw $ra, 4($sp)
addi $sp, $sp, 8 #deacllocate space from stack 
  jr $ra


######################################################Part 3: Calculate Least Common Multiple (LCM)
.globl lcm
lcm:
#preamble
addi $sp, $sp, -12  #allocate space on stack lcm
sw $a0, 0($sp)     #store a0 on stack because of nested function call gcd
sw $a1, 4($sp)     #store a1 on stack because of nested function call gcd
sw $ra, 8($sp)     #store on stack space return address

jal gcd          #do function to call on gcd
#do LCM(a,b) = a*b/ gcd(a,b)   
mult $a0, $a1  #numerator
mflo $t4       #load lower 32 bits from product into $t4
div $t4, $v0   #denominator gcd(a,b) is stored in v0
mflo $t4       #move quotient from divsion into T4
li $v0, 0      #make sure vo is 0
move $v0, $t4  #move t4 into v0

#postamble
lw $a0, 0($sp)
lw $a1, 4($sp)
lw $ra, 8($sp)
addi $sp, $sp, 12 #deacllocate space from stack
  jr $ra
  
######################################################Part 4: Calculate Greatest Common Divisor (GCD)
.globl gcd
gcd:
#preamble
addi $sp, $sp, -8  #allocate space on stack lcm
sw $a0, 0($sp)     #store a0 on stack because of nested function call gcd
sw $a1, 4($sp)     #store a1 on stack because of nested function call gcd
sw $ra, 8($sp)     #store on stack space return address

whileLoop:
beq $a0, $a1, exit              #while (a!=b) if a==b then exit
bgt $a0, $a1, then              #if a> b then a = a - b
sub $a1, $a1, $a0               #else b = b-a
j whileLoop                     #after else jump
then:                           #then a = a - b
sub $a0, $a0, $a1               #a = a - b
j whileLoop                     #after then jump
exit:
li $v0, 0
move $v0, $a0  

#postamble
lw $a0, 0($sp)
lw $a1, 4($sp)
lw $ra, 8($sp)
addi $sp, $sp, 8 #deacllocate space from stack 
  jr $ra

######################################################Part 5: Compute Public Key Exponent
#returns a random number r such that 1 < r < z where z is stored in a0
#z and r must be coprime gcd(z,r) = 1
.globl pubkExp
pubkExp:
#preamble
addi $sp, $sp, -12  #allocate space on stack lcm
sw $a0, 0($sp)     #store a0 on stack because of nested function call gcd
sw $s0, 4($sp)
sw $ra, 8($sp)     #store on stack space return address

#generate a random number that is coprime with z
move $t0, $a0      #save a0 for later in t0
move $t9, $a1
move $a1, $a0      #move z into a1 to set as upper bound
not_coprimes:
li $v0, 42
syscall            #now $a0 is random
move $s0, $a0      #move random number into s0
move $a0, $t0      #restore a0
move $a1, $t9      #restore a1
li $t5, 2   
blt $s0, $t5, not_coprimes #check if less than 1 if so try for another random num  

move $a0, $t0      #move original a0 from t0 back to a0
move $a1, $s0      #temporarily move s0 into a1 so gcd can do function call with random r and z
addi $sp, $sp, -4
sw $ra, 0($sp)
jal gcd            #do function call on gcd(z,r) = 1 with values z in a0, r in a1
move $t4, $v0      #move result in t4
lw $ra, 0($sp)
addi $sp, $sp, 4

move $a1, $t9
li $t5, 1
bne $t4, $t5, not_coprimes #check if not coprimes then try for a new random number

#finally load random number into v0
move $v0, $s0

#postamble
lw $a0, 0($sp)
lw $s0, 4($sp)
lw $ra, 8($sp)
addi $sp, $sp, 12 #deacllocate space from stack
  jr $ra


######################################################Part 6: Compute Private Key Exponent
.globl prikExp
#use the Extended Euclidian algorithm 
prikExp:
#preamble
addi $sp, $sp, -24  #allocate space on stack lcm
sw $a0, 0($sp)     #store a0 on stack because of nested function call gcd
sw $a1, 4($sp)     #store a1 on stack because of nested function call gcd
sw $ra, 8($sp)     #store on stack space return address
sw $s0, 12($sp)
sw $s1, 16($sp)
sw $s2, 20($sp)


#first check for coprimes
jal gcd            #do function call on gcd(z,r) = 1 with values z in a0, r in a1
move $t4, $v0      #move result in t4
li $t5, 1          
beq $t4, $t5, coprimes  #if gcd != 1 then not coprimes
li $v0, -1              #if not equal then v0 = -1
j break_2
coprimes:

#Step 0  y = quotient*x + remainder 
div $a1, $a0      #y/x  26/15
mflo $t4          #move quotient = 1 for step 0 into t4  
mfhi $t5          #move remainder = 11 for step 0 into t5 
move $s2, $a1     #save $a1 value
move $a1, $a0     #make new a1 15 for step 1
move $a0, $t5     #make new a0 11 for step 2

beqz $t5, break_  #check if remainder = 0 already

#Step 1
div $a1, $a0      #15/11      
mflo $t8          #quotient = 1   
mfhi $t9          #remainder = 4  
#step 2 onwards currentP = (Pi2 - (Pi1 * Q2) % CONSTANT_Y;    (constant y ) constant y = a0 mod a1
li $t6, 0         #p0 = 0 Pi2
li $t7, 1         #p1 = 1 Pi1
move $a1, $a0
move $a0, $t9     #update arguments
beqz $t9, break_  #check if remainder = 0 already

loop:
div $a1, $a0      
mfhi $t0          #modulo = y % x

mflo $t1          #divided = y / x (remainder)
move $a1, $a0     #y = x
move $a0, $t0     #x = modulo

#currentP = (Pi2 - (Pi1 * Q2) % CONSTANT_Y
mult $t7, $t4  #Pi-1 * Q2
mflo $t2       #stored in t2
sub $s0, $t6, $t2    #Pi-2 - t2

#check if negative s0 if so then make positive add by a1
bgez $s0, not_negative   #if greater than or equal to 0 is not negative
loop_negative:
bgez $s0, out
add $s0, $s0, $s2        #negative so add $a1, $s2 holds original a1 constant y 
j loop_negative
out:
move $s1, $s0
j finish_negative

not_negative:
div $s0, $s2  #(Pi2 - (Pi1 * Q2) % CONSTANT_Y
mfhi $s1      #current p
finish_negative:
move $t6, $t7 #Pi2 = Pi1;
move $t7, $s1 #Pi1 = currentP;
move $t4, $t8 # Q2 = Q1;
move $t8, $t1 #Q1 = divided;

beqz $t0, break_  #if remainder is 0 jump out 
j loop
break_2:
li $s1, -1
j here

break_:
#run loop one last time
div $a1, $a0      
mfhi $t0          #modulo = y % x

mflo $t1          #divided = y / x (remainder)
move $a1, $a0     #y = x
move $a0, $t0     #x = modulo

#currentP = (Pi2 - (Pi1 * Q2) % CONSTANT_Y
mult $t7, $t4  #Pi-1 * Q2
mflo $t2       #stored in t2
sub $s0, $t6, $t2    #Pi-2 - t2

#check if negative s0 if so then make positive add by a1
bgez $s0, not_negative2   #if greater than or equal to 0 is not negative

loop_negatives:
bgez $s0, outs
add $s0, $s0, $s2        #negative so add $a1, $s2 holds original a1 constant y 
j loop_negatives
outs:
move $s1, $s0
j finish_negative2

not_negative2:
div $s0, $s2  #(Pi2 - (Pi1 * Q2) % CONSTANT_Y
mfhi $s1      #current p
finish_negative2:
move $t6, $t7 #Pi2 = Pi1;
move $t7, $s1 #Pi1 = currentP;
j here
here:
move $v0, $s1
#postamble
lw $a0, 0($sp)
lw $a1, 4($sp)
lw $ra, 8($sp)
lw $s0,12($sp)
lw $s1,16($sp)
lw $s2,20($sp)
addi $sp, $sp, 24 #deacllocate space from stack
  jr $ra


######################################################Part 7: Encrypt Message
#n = p * q and n > m
#v0 = m^e (mod n), public key e, lcm(p-1, q-1) = K use K as input for public key, m is just a0 hashed msg
.globl encrypt
encrypt:
#preamble
addi $sp, $sp, -20 #allocate space on stack lcm
sw $a0, 0($sp)     #store a0 on stack because of nested function call gcd
sw $a1, 4($sp)     #store a1 on stack because of nested function call gcd
sw $a2, 8($sp)
sw $s1, 12($sp)
sw $ra, 16($sp)    #store on stack space return address

move $t0, $a0      #save m
move $t1, $a1      #save p
move $t2, $a2      #save q
#get n
mult $a1, $a2      #n = p * q
mflo $t8           #n


#K = lcm(p-1, q-1)
addi $t1, $t1, -1   #subtract -1 from each
addi $t2, $t2, -1

addi $sp, $sp, -12
sw $ra, 0($sp)
sw $a0, 4($sp)
sw $t8, 8($sp)
move $a0, $t1
move $a1, $t2
jal lcm            #do function call on lcm
lw $ra, 0($sp)
lw $a0, 4($sp)
lw $t8, 8($sp)
addi $sp, $sp, 12
move $t4, $v0       #K into t4 to use for pubkExp
#move $a0, $v0      #K into a0 to use for pubkExp

addi $sp, $sp, -12
sw $ra, 0($sp)
sw $a0, 4($sp)
sw $t8, 8($sp)
move $a0, $t4
jal pubkExp     #e stored in v0
lw $ra, 0($sp)
lw $a0, 4($sp)
lw $t8, 8($sp)
addi $sp, $sp, 12

move $t1, $v0   #move e to t1
move $v1, $t1   #move e into v1 to return 


#v0 = m^e (mod n)  -> t9 div t8  take remainder
#Step 1: u' = u mod w, w = n in t8
div $a0, $t8      # u mod w where u = m = a0 and w = n = t8
mfhi $t7          #m % n
#(u'*u) mod w  for v-1 times 
li $s1, 1 
loopPower:
beq $t1, $s1, leave  #break out of loop if e is 1 so $t1 = 1
mult $a0, $t7              #u * u'
mflo $t7                   # u' = u'*u  <- power
div $t7, $t8               #(u'*u) mod w
mfhi $t7                   # u' = (u'*u) mod w
addi $t1, $t1, -1             #decrement e in t1
j loopPower
leave:
move $v0, $t7      #move c into v0 to return

#postamble
lw $a0, 0($sp)
lw $a1, 4($sp)
lw $a2, 8($sp)
lw $s1, 12($sp)
lw $ra, 16($sp)
addi $sp, $sp, 20  #deacllocate space from stack
 jr $ra

######################################################Part 8: Decrypt Message
.globl decrypt
decrypt:

#preamble
addi $sp, $sp, -24 #allocate space on stack lcm
sw $a0, 0($sp)     #store a0 on stack because of nested function call gcd
sw $a1, 4($sp)     #store a1 on stack because of nested function call gcd
sw $a2, 8($sp)
sw $a3, 12($sp)
sw $s1, 16($sp)
sw $ra, 20($sp)    #store on stack space return address

#a0 = c, a1 = public key, p and 1 in a2 and a3
move $t9, $a0
#get n
move $t1, $a2      #save p
move $t2, $a3      #save q
mult $a2, $a3      #n = p * q
mflo $t8           #n


#K = lcm(p-1, q-1)
addi $t1, $t1, -1   #subtract -1 from each
addi $t2, $t2, -1

addi $sp, $sp, -12
sw $ra, 0($sp)
sw $a0, 4($sp)
sw $t8, 8($sp)
move $a0, $t1
move $a1, $t2
jal lcm            #do function call on lcm
lw $ra, 0($sp)
lw $a0, 4($sp)
lw $t8, 8($sp)
addi $sp, $sp, 12


move $t5, $v0      #K into a1 to use for prikExp
#move $t4, $a2      #move e public key into a0 for prikExp
lw $t4, 4($sp)

addi $sp, $sp, -16
sw $ra, 0($sp)
sw $a0, 4($sp)
sw $t8, 8($sp)
sw $t9, 12($sp)
move $a1, $t5      #K into a1 to use for prikExp
move $a0, $t4      #move e public key into a0 for prikExp
jal prikExp        #do function call on lcm
lw $ra, 0($sp)
lw $a0, 4($sp)
lw $t8, 8($sp)
lw $t9, 12($sp)
addi $sp, $sp, 16

move $t2, $v0       #move d into t2      


#Step 1: u' = u mod w, u = c in t9, w = n in t8
div $t9, $t8      #c % n
mfhi $t7          #c'

li $s1, 1 
loopPower_:                #(u'*u) mod w  for v-1 times
beq $t2, $s1, leave_       #break out of loop if d is 1 so $t2 = 1
mult $t9, $t7              #u * u'
mflo $t7                   #u' = u'*u  <- power
div $t7, $t8               #(u'*u) mod w
mfhi $t7                   # u' = (u'*u) mod w
addi $t2, $t2, -1          #decrement d in t2
j loopPower_
leave_:
move $v0, $t7      #move m into v0 to return

#postamble
lw $a0, 0($sp)
lw $a1, 4($sp)
lw $a2, 8($sp)
lw $a3, 12($sp)
lw $s1, 16($sp)
lw $ra, 20($sp)
addi $sp, $sp, 24  #deacllocate space from stack
  jr $ra




