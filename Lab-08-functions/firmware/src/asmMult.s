/*** asmMult.s   ***/
/* SOLUTION; used to test C test harness
 * VB 10/14/2023
 */
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Joshua Lopez"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,a_Sign,b_Sign,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
asmUnpack:   
    
    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/
   
    push {r4-r11, lr}	    /*Save registers and lr*/
    mov r6, 0		    /*Initialize r6 with 0 to keep track of loop iterations*/
    
    loop:
	lsr r4, r0, 31	    /*Isolates the MSB of the 16 bit value in B16-B31*/
	cmp r4, 1	    /*Checks to see if the MSB is 1(negative)*/
	beq negative	    /*If MSB is 1, then it branches to negative*/

	/*If execution is in here, then B16-B31 is a positive value*/
	lsr r4, r0, 16	    /*Shifts the 16 bits we care about (B16-B31) into B0-B15 while also shifting out 
			     *its previous bits, and storing the new value into r4. B16-B31 will have 0 bits.*/
	b assignment_handler /*Once we have our manipulated value, we branch to handle its assignment*/
    negative:
	/*If in here, then B16-B31 in r0 is a negative value*/
	asr r4, r0, 16	    /*In r0, shifts the bits inside B0-B15 out so only the bits in B16-B31 remain in locations B0-B15, 
			    *but it adds 1 to B16-B31 making it a negative value through extended sign and storing it in r4*/
    assignment_handler:
	cmp r6, 0	    /*Checks where we are in the loop, if 0 then we're handling the cand, if 1, then we're handling the plier*/
	streq r4, [r1]	    /*Stores the multiplicand into its memory location. r6 needs to be 0*/
	strne r4, [r2]	    /*Stores the multiplier into its memory location. r6 needs to be 1*/
	cmp r6, 1	    /*Check if r6 has 1, if so, then we went through this loop twice*/
	beq done_asmUnpack  /*If the above cmp is equal, we're done looping*/
	add r6, r6, 1	    /*If here, we're not done, and we add 1 to r6*/
	ror r0, r0, 16	    /*Rotates the packed value to work with the other 16 bits(Rb) as with Ra for the next iteration*/
	b loop		    /*Continue the loop for Rb*/
	
    done_asmUnpack:
	pop {r4-r11, lr}    /* Restore saved registers and lr*/
	bx lr		    /* Return from the function*/
    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit 0 = "+", 1 = "-")
 *    outputs:  r0: Absolute value of r0 input. Same value as stored to location given in r1
 *              memory: store absolute value in location given by r1
 *                      store sign bit in location given by r2
 */    
asmAbs:  

    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/
    push {r4-r11, lr}	/*Save registers and lr*/
    
    cmp r0, 0		/*Checks if the value in r0 is 0*/
    bge positive	/*If the value in r0 >= 0*/
    
    neg r0, r0		/*Takes the 2's complement of the value because the value is negative*/
    mov r4, 1		/*1 is for negative sign. Sets this aside to store in the sign address*/
    b store_handle	/*Branches to handle storing of negative value and sign*/
	
    positive:		/*Branches here if value is positive or 0*/
	mov r4, 0	/*0 is for positive sign. Sets this aside to store in the sign address*/
    
    store_handle:
	str r0, [r1]	/*Takes the absolute value of r0 and stores it in the absolute value address*/
	str r4, [r2]	/*Takes 0 (positive) or 1(negative) and stores it in sign address. */
	
    pop {r4-r11, lr}	/* Restore saved registers and lr */
    bx lr		/* Return from the function */

    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

 
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */ 
asmMult:   

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/

    push {r4-r11, lr}	    /* Save registers and lr */
   
    mov r7, 0		    /*Initializes r7 to 0. Will be used to hold the initial product value.*/
    cmp r0, 0		    /*If the cand is 0, then branch to product since anything multiplied by 0 is 0*/
    beq product		    /*if the cand is 0 then the product is 0 and will branch*/
    
    /*Loop handles the multiplication by shifting*/
    multiply_loop:   
	cmp r1, 0	    /*Checks if the plier is 0. If 0, we're done with multiplying*/
	beq product	    /*If the multiplier is 0, it will branch to product*/
	tst r1, 1	    /*If the LSB is set (1), then Z==0 and it will NOT branch to shift*/
	beq shift	    /*If the LSB is not set (0), then Z==1 and it will branch to shift*/
	add r7, r7, r0	    /*If LSB is 1, then the product and cand are added and stored back to the product*/
	/*Inner Shift Loop*/
	shift:
	    lsl r0, r0, 1   /*shifting the cand left to multiply it by 2*/
	    lsr r1, r1, 1   /*shifting the plier right to divide it by 2. Will eventually reach 0*/
	    b multiply_loop /*branches back to continue multiplication loop*/
	    
    product:
	mov r0, r7	    /*Returns the product to r0*/
	pop {r4-r11, lr}    /*Restore saved registers and lr*/
	bx lr		    /*Return from the function*/

    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/

   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product from previous step: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
    /*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/
    push {r4-r11, lr}	    /*Save registers and lr*/
    eor r4, r1, r2	    /*Takes the signs in r1 and r2, does an xor on it to determine its final sign*/
			    /*0 xor 0 = 0 (positive)*/
			    /*0 xor 1 = 1 (negative)*/
			    /*1 xor 0 = 1 (negative)*/
			    /*1 xor 1 = 0 (positive)*/
    cmp r4, 0		    /*If positive (0), we're done so we branch on the next instruction, else it skips*/
    beq done_signs
    neg r0, r0		    /*Takes the 2s complement on the positive value to get a negative value*/

    done_signs:
    pop {r4-r11, lr}	    /*Restore saved registers and lr*/
    bx lr		    /*Return from the function*/
    
    
    
    
    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */  
asmMain:   
    
    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/
    push {r4-r11, lr}	    /*Save registers and lr*/
    
    /*Loads the below registers to hold the respective memory address locations so we don't need to repeat these instructions*/
    ldr r4, =a_Multiplicand
    ldr r5, =b_Multiplier
    ldr r6, =a_Abs
    ldr r7, =b_Abs
    ldr r8, =a_Sign
    ldr r9, =b_Sign
    ldr r10, =init_Product
    ldr r11, =final_Product
    
    /* Step 1:
     * call asmUnpack. Have it store the output values in a_Multiplicand
     * and b_Multiplier.
     */
    ldr r1, =a_Multiplicand	/*Sets r1 to the a_Multiplicand memory address*/
    ldr r2, =b_Multiplier	/*Sets r2 to the b_Multiplier memory address*/
    bl asmUnpack		/*Call to asmUnpack sublabel*/
    
   


     /* Step 2a:
      * call asmAbs for the multiplicand (a). Have it store the absolute value
      * in a_Abs, and the sign in a_Sign.
      */
     ldr r0, [r4]		/*Sets a_Multiplicand value into r0 input*/
     ldr r1, =a_Abs		/*Sets r1 input to a_Abs memory address location*/
     ldr r2, =a_Sign		/*Sets r2 input to a_Sign memory address location*/
     bl asmAbs			/*Call to asmAbs sublabel*/



     /* Step 2b:
      * call asmAbs for the multiplier (b). Have it store the absolute value
      * in b_Abs, and the sign in b_Sign.
      */
     ldr r0, [r5]		/*Sets r0 input to b_Multiplier value*/
     ldr r1, =b_Abs		/*Sets r1 input to b_Abs memory address location*/
     ldr r2, =b_Sign		/*Sets r2 input to b_Sign memory address location*/
     bl asmAbs			/*Call to asmAbs sublabel*/
     


    /* Step 3:
     * call asmMult. Pass a_Abs as the multiplicand, 
     * and b_Abs as the multiplier.
     * asmMult returns the initial (positive) product in r0.
     * In this function (asmMain), store the output value  
     * returned asmMult in r0 to mem location init_Product.
     */
    ldr r0, [r6]		/*Set r0 input to a_Abs value*/
    ldr r1, [r7]		/*Set r1 input to b_Abs value*/
    bl asmMult			/*Call to asmMult sublabel*/
    str r0, [r10]		/*Sets r0 output to init_Product memory location*/
				/*NOTE: r0 already holds the init_Product input for step 4*/
    

    /* Step 4:
     * call asmFixSign. Pass in the initial product, and the
     * sign bits for the original a and b inputs. 
     * asmFixSign returns the final product with the correct
     * sign. Store the value returned in r0 to mem location 
     * final_Product.
     */
    ldr r1, [r8]		/*Sets r1 input to a_Sign value*/
    ldr r2, [r9]		/*Sets r2 input to b_Sign value*/
    bl asmFixSign		/*Call to asmFixSign sublabel*/
    str r0, [r11]		/*Sets r0 output to final_Product memory location*/
				/*NOTE: r0 already holds the "final answer" for step 5*/


     /* Step 5:
      * END! Return to caller. Make sure of the following:
      * 1) Stack has been correctly managed.
      * 2) the final answer is stored in r0, so that the C call 
      *    can access it.
      */    
     /* restore the caller's registers, as required by the 
      * ARM calling convention 
      */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 
screen_shot:    
    pop {r4-r11,LR}
    mov pc, lr	 /* asmMain return to caller */


    
    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/


    /***************  END ---- asmMain  ************/

 
    
    
.end   /* the assembler will ignore anything after this line. */
