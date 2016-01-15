*--------------------------------------------------------------------
* Title      : Combined Test Program for 68k Disassembler
* Written by : Arthur Bulan, Phat Tran, & Felicia Passovoy
* Date       : Nov/Dec 2015
* Description: Tests all required opcodes using various registers
*--------------------------------------------------------------------    
      
**********************************************************************
addr1     EQU     $4000        

addr2     EQU     $4001 

data1	  EQU	  $C0

data2     EQU     $A7FF 

data3     EQU     $5555

data4     EQU     $0000 

data5     EQU     4678 

data6     EQU     %01001111 

data7     EQU     %00010111 




**************************************************************************

*

* Beginning of code segment. This is the actual assembly lang instructions

*

**************************************************************************
 

	ORG	$7000          * This pseudo op code tells the assembler  here                                                                                                                         
START
                                           * the program will run in memory

        MOVE.B  D6,D4
        MOVEA.W D6,A4
        MOVEM.L a0-a4/a6/d0-d3/d5/d7,-(A3)
        MULS.W  D6,D7
        DIVS.W  D3,D2
        NEG.W   D3
        LSL     D3,D2 
        LSR     D3,D2 
        BTST    D3,D2 
        BRA     START 
        RTS
         
        
        MOVE.W  A4,D5
        MOVEA.W A4,A5
       
       
       
        MOVE.B  (A3),D6
        MOVEA.W (A3),A6
        DIVS.W  (A3),D6   
        NEG.W   (A3)
        LSL     (A3)
        LSR     (A3)
        BTST    D3,(A3)
        JSR     (A3)
 
        MOVE.B  #16,D3  
        MOVEA.W #16,A3  
        MULS.W  #1245,D5 
        DIVS.W  #2635, D4 
        
         
        MOVE.B  (A4)+,D2
        MULS.W  (A4)+,D2
        DIVS.W  (A3)+,D2 
        NEG.W   (A3)+
        LSL     (A3)+
        LSR     (A3)+
        BTST    D2,(A3)+
        
        MOVE.B  -(A2),D1
        MULS.W  -(A2),D1
        DIVS.W  -(A2),D1
        NEG.W   -(A2)
        LSL     -(A2)
        LSR     -(A2)
        BTST    D1, -(A2)
        
        MOVE.B  $4501.L,D2
        MULS.W  $1245.L,D5
        DIVS.W  $1233.L,D5
        NEG.W   $5641.L
        LSL     $5641.L
        LSR     $5641.L
        BTST    D5, $5454.L 
        JSR     $5454.L 
        
        MOVE.B  $4501.W,D2
        MULS.W  $1245.W,D5
        DIVS.W  $7545.W,D5
        NEG.W   $5641.W   
        LSL     $5641.W
        LSR     $5641.W
        BTST    D5, $5454.W 
        JSR     $5454.W 


************************************************************************
************************************************************************

     	MOVE.W	#data2,D0     * Load D0 

    	MOVE.B	#data6,D1     * Load D1 

    	MOVE.B	#data7,D2     * load D2 

	    MOVE.W	#data3,D3     * load D3 

	    MOVEA.W	#addr1,A0     * load address register 

	    MOVEA.W	#addr1,A1	* not sure what this is



********************************** SUB *********************************
* sub byte



	    SUB.B	#data1,D0	* immediate data to D0 byye

	    SUB.B	D1,(A0)+	* sub post-increment to D1

	    SUB.B	D1,-(A1)	* sub pre-increment to D1

	    SUB.B	D1,$4000	* not sure what this does

	    SUB.B	D1,$40010000	* not sure what this does



	    SUB.B	D1, D0		* sub D1 to D0


	    SUB.B	(A0),D0		* sub D0 to A0 indirect

	    SUB.B	(A0)+,D0	* sub post-increment

	    SUB.B	-(A1),D0	* sub pre-increment


	    SUB.B	data2,D0	* i think this passes? word

	    SUB.B	data3,D0	* longword?

* sub word

	    SUB.W	#data1,D0	* immediate data to D0 byte

	    SUB.W	#$1021,D0	* immediate data to D0 word

	    SUB.W	D1,A0		* sub A0 to D1

	    SUB.W	D1,(A0)+	* sub post-increment to D1

	    SUB.W	D1,-(A1)	* sub pre-increment to D1

	    SUB.W	D1,$4000	* not sure what this does

	    SUB.W	D1,$40010000	* not sure what this does



	    SUB.W	D1, D0		* sub D1 to D0

	    SUB.W	A0,D0		* sub D0 to A0 direct

	    SUB.W	(A0),D0		* sub D0 to A0 indirect

	    SUB.W	(A0)+,D0	* sub post-increment

	    SUB.W	-(A1),D0	* sub pre-increment


	    SUB.W	data2,D0	* i think this passes? word

	    SUB.W	data3,D0	* longword?


* sub longword


	    SUB.L	#data1,D0	* immediate data to D0 byte

	    SUB.L	#$1021,D0	* immediate data to D0 word

	    SUB.L	#$AAAA5555,D0	* immediate data to D0 longword

	    SUB.L	D1,A0		* sub A0 to D1

	    SUB.L	D1,(A0)+	* sub post-increment to D1

	    SUB.L	D1,-(A1)	* sub pre-increment to D1

	    SUB.L	D1,$4000	* not sure what this does

	    SUB.L	D1,$40010000	* not sure what this does



	    SUB.L	D1, D0		* sub D1 to D0

	    SUB.L	A0,D0		* sub D0 to A0 direct

	    SUB.L	(A0),D0		* sub D0 to A0 indirect

	    SUB.L	(A0)+,D0	* sub post-increment

	    SUB.L	-(A1),D0	* sub pre-increment


	    SUB.L	data2,D0	* i think this passes? word

    	SUB.L	data3,D0	* longword?


******************************* SUBA **************************************
* SUBA WORD

	    SUBA.W D1,A0		* Data register to address register

	    SUBA.W A0,A0		* address register to data register direct

	    SUBA.W (A0),A0		* address register to data register indirect

	    SUBA.W (A0)+,A0		* post-increment

	    SUBA.W -(A1),A0		* pre-increment

	    SUBA.W addr1,A0		* word address?

	    SUBA.W #addr1,A0	* immediate address?

	    SUBA.W $4000,A0		* random address

	    SUBA.W data2,A0		* random data word

	    SUBA.W #data2,A0	* immediate data word

	    SUBA.W #$AAAA,A0	* immediate data word



* SUBA LONGWORD

	    SUBA.L D1,A0		* Data register to data register

	    SUBA.L A0,A0		* address register to data register direct

	    SUBA.L (A0),A0		* address register to data register indirect

	    SUBA.L (A0)+,A0		* post-increment

	    SUBA.L -(A1),A0		* pre-increment

	    SUBA.L addr1,A0		* word address?

	    SUBA.L #addr1,A0	* immediate address?

	    SUBA.L $4000,A0		* random address

    	SUBA.L data2,A0		* random data word

    	SUBA.L data3,A0		* random data longword

    	SUBA.L #data2,A0	* immediate data word

	    SUBA.L #data3,A0	* immediate data longword

	    SUBA.L #$AAAA,A0	* immediate data word

	    SUBA.L #$AAAA5555,A0	* immediate data longword


******************************* SUBI **************************************
*SUBI byte

    	SUBI.B #$AA,D0		* immediate data to D0

	    SUBI.B #$AA,(A0)	* address register indirect

	    SUBI.B #$AA,(A0)+	* address register post-increment

	    SUBI.B #$AA,-(A1)	* address register pre-increment

	    SUBI.B #$AA,$4000	* destination word address

	    SUBI.B #$AA,$00004000	* destination longword address


*SUBI word

	    SUBI.W #$AA55,D0	* data register

	    SUBI.W #$AA55,(A0)	* address register indirect

	    SUBI.W #$AA55,(A0)+	* address register post-increment

	    SUBI.W #$AA55,-(A1)	* address register pre-increment

	    SUBI.W #$AA55,$4000	* destination word 

	    SUBI.W #$AA55,$00004000	* destination longword


*SUBI longword

	    SUBI.L #$AA55FF,D0	* data register

	    SUBI.L #$AA55FF,(A0)	* address register indirect

	    SUBI.L #$AA55FF,(A0)+	* address register post-increment

	    SUBI.L #$AA55FF,-(A1)	* address register pre-increment

	    SUBI.L #$AA55FF,$4000	* destination word

	    SUBI.L #$AA55FF,$00004000   * destination longword


******************************* AND **************************************
*AND byte

	    AND.B D1,D0		* data register for source and destination

	    AND.B (A0),D0		* souce address register indirect

	    AND.B (A0)+,D0		* source address register post-increment

	    AND.B -(A1),D0		* source address register pre-decrement

	    AND.B $4000,D0		* source word address

	    AND.B $00004000,D0	* source longword address

	    AND.B #$AE,D0		* immediate data


	    AND.B D1,(A0)		* dest address register indirect

	    AND.B D1,(A0)+		* dest address register post-increment

	    AND.B D1,-(A1)		* dest address register pre-decrement

	    AND.B D1,$4000		* dest word address

	    AND.B D1,$00004000	* dest longword address


*AND word

	    AND.W D1,D0		* data register for source and destination

	    AND.W (A0),D0		* souce address register indirect

	    AND.W (A0)+,D0		* source address register post-increment

	    AND.W -(A1),D0		* source address register pre-decrement

	    AND.W $4000,D0		* source word address

	    AND.W $00004000,D0	* source longword address

	    AND.W #$AE,D0		* immediate data byte

	    AND.W #$AAAA,D0		* immediate data word


	    AND.W D1,(A0)		* dest address register indirect

	    AND.W D1,(A0)+		* dest address register post-increment

	    AND.W D1,-(A1)		* dest address register pre-decrement

	    AND.W D1,$4000		* dest word address

	    AND.W D1,$00004000	* dest longword address


*AND longword

    	AND.L D1,D0		* data register for source and destination

	    AND.L (A0),D0		* souce address register indirect

	    AND.L (A0)+,D0		* source address register post-increment

	    AND.L -(A1),D0		* source address register pre-decrement

	    AND.L $4000,D0		* source word address

	    AND.L $00004000,D0	* source longword address

	    AND.L #$AE,D0		* immediate data byte

	    AND.L #$AAAA,D0		* immediate data word

	    AND.L #$AAAAEEEE,D0	* immediate data longword


	    AND.L D1,(A0)		* dest address register indirect

	    AND.L D1,(A0)+		* dest address register post-increment

	    AND.L D1,-(A1)		* dest address register pre-decrement

	    AND.L D1,$4000		* dest word address

	    AND.L D1,$00004000	* dest longword address


******************************* ORI ***************************************
*ORI byte

	    ORI.B #$EA,D0		* data register

	    ORI.B #$EA,(A1)		* address register indirect

	    ORI.B #$EA,(A0)+	* post-increment

	    ORI.B #$EA,-(A1)	* pre-decrement

	    ORI.B #$EA,$4000	* address word

	    ORI.B #$EA,$00004000	* address longword

*ORI word

	    ORI.W #$EAEA,D0		* data register

	    ORI.W #$EAEA,(A1)	* address register indirect

	    ORI.W #$EAEA,(A0)+	* post-increment

	    ORI.W #$EAEA,-(A1)	* pre-decrement

	    ORI.W #$EAEA,$4000	* address word

	    ORI.W #$EAEA,$00004000	* address longword

*ORI longword

	    ORI.L #$EAEACCCC,D0		* data register

	    ORI.L #$EAEACCCC,(A1)		* address register indirect

	    ORI.L #$EAEACCCC,(A0)+		* post-increment

	    ORI.L #$EAEACCCC,-(A1)		* pre-decrement

	    ORI.L #$EAEACCCC,$4000		* address word

	    ORI.L #$EAEACCCC,$00004000	* address longword


******************************* NOT ***************************************
* NOT byte

	    NOT.B D0	* data register

	    NOT.B (A0)	* address register indirect

	    NOT.B (A0)+	* address register post-increment

	    NOT.B -(A1)	* address register pre-increment

	    NOT.B $4000	* address word

	    NOT.B $00004000	*address longword


* NOT word

	    NOT.W D0	* data register

	    NOT.W (A0)	* address register indirect

	    NOT.W (A0)+	* address register post-increment

	    NOT.W -(A1)	* address register pre-increment

	    NOT.W $4000	* address word

	    NOT.W $00004000	*address longword


* NOT longword

	    NOT.L D0	* data register

	    NOT.L (A0)	* address register indirect

	    NOT.L (A0)+	* address register post-increment

	    NOT.L -(A1)	* address register pre-increment

	    NOT.L $4000	* address word

	    NOT.L $00004000	*address longword

******************************* ROL ***************************************
*ROL byte

    	ROL.B D0,D1
	
	    ROL.B #1,D0
	
*ROL word
        ROL.W D0,D1
    
        ROL.W #1,D0

*ROL longword
        ROL.L D0,D1
    
        ROL.L #1,D0
    

*ROR byte
        ROR.B D0,D1
	
	    ROR.B #1,D0
	
*ROR word
        ROR.W D0,D1
    
        ROR.W #1,D0

*ROR longword
        ROR.L D0,D1
    
        ROR.L #1,D0

 ****************************** Bcc ***************************************
 
LOOP    
        BEQ   LOOP
        BNE   LOOP
        BLT   LOOP
        BHI   LOOP
        

***************************************************************************

*   MOVE.W  #$B6EE,D0
    MOVE.B  #$F2,D1
    MOVE.B  #%01011000,D2
*   MOVE.W  #$4545,D2
*   MOVEA.W #$4000,A0
        
        
********** A D D *************** A D D *************** A D D **************

***************************************************************************
*ADD - byte size
    
        ADD.B   D0,D1
        ADD.B   (A0),D2
        ADD.B   (A1)+,D3
        ADD.B   -(A2),D4
        ADD.B   $AA12,D2
        ADD.B   $EF110033,D3        
        ADD.B   D2,D5
        ADD.B   D1,(A1)
        ADD.B   D1,(A2)+
        ADD.B   D1,-(A3)
        ADD.B   D2,$80AA
        ADD.B   D0,$53642353

***************************************************************************
*ADD - word size

        ADD.W   D2,D3
        ADD.W   D1,A0
        ADD.W   D3,(A1)
        ADD.W   D2,(A2)+
        ADD.W   D5,-(A3)
        ADD.W   D0,D2
        ADD.W   (A1),D1
        ADD.W   (A0)+,D1
        ADD.W   -(A0),D1
        ADD.W   $AA10,D2
        ADD.W   $EF234033,D3
        
***************************************************************************
*ADD - long size         
        
        ADD.L   D2,D3
        ADD.L   D1,A0
        ADD.L   D1,(A1)
        ADD.L   D1,(A2)+
        ADD.L   D1,-(A3)
        ADD.L   D0,D2
        ADD.L   (A1),D1
        ADD.L   (A0)+,D1
        ADD.L   -(A0),D1
        ADD.L   $A0,D0
        ADD.L   $AA10,D2
        ADD.L   $22334455,D3


********** A D D A ************* A D D A ************** A D D A ***********

*****************************
*ADDA - word size 

        ADDA.W   A0,A1
        ADDA.W   D1,A0
        ADDA.W   (A1),A2
        ADDA.W   (A2)+,A2
        ADDA.W   -(A3),A2
        ADDA.W   $AA10,A2
        ADDA.W   $AABB1033,A0
        ADDA.W   #50,A3
        ADDA.W   #$A1,A4
        ADDA.W   #$A010,A4
        
*****************************
*ADDA - long size 
        
        ADDA.L   A0,A1
        ADDA.L   D1,A0
        ADDA.L   (A1),A2
        ADDA.L   (A2)+,A2
        ADDA.L   -(A3),A2
        ADDA.L   $AA10,A2
        ADDA.L   $AABB1033,A0
        ADDA.L   #50,A3
        ADDA.L   #$A1,A4
        ADDA.L   #$A010,A4
        ADDA.L   #$A0104500,A4    
        
        
********** A D D Q ************* A D D Q ************* A D D Q ************

*****************************
*ADDQ - byte size

        ADDQ.B  #1,D0
        ADDQ.B  #1,D1
        ADDQ.B  #1,D0
        ADDQ.B  #2,D1
        ADDQ.B  #$1,D0
        ADDQ.B  #$7,D1
        ADDQ.B  #3,(A1)
        ADDQ.B  #5,(A2)+
        ADDQ.B  #%101,-(A2)
        ADDQ.B  #3,$1234
        ADDQ.B  #7,$ABCD1534
     
*****************************
*ADDQ - word size

        ADDQ.W  #5,D0
        ADDQ.W  #$1,D1
        ADDQ.W  #$8,D0
        ADDQ.W  #$1,A1
        ADDQ.W  #%0110,(A1)
        ADDQ.W  #5,(A2)+
        ADDQ.W  #%101,-(A2)
        ADDQ.W  #3,$1234
        ADDQ.W  #7,$ABCD1534


*****************************
*ADDQ - long size

        ADDQ.L  #5,D0
        ADDQ.L  #$1,D1
        ADDQ.L  #$8,D0
        ADDQ.L  #$1,A1
        ADDQ.L  #%0110,(A1)
        ADDQ.L  #5,(A2)+
        ADDQ.L  #%101,-(A2)
        ADDQ.L  #3,$1234
        ADDQ.L  #7,$ABCD1534
        

********** A S L *************** A S L *************** A S L **************

*****************************
*ASL

        ASL     D3,D5
        ASL     #5,D0
        ASL     #6,D1
        ASL     #%101,D1
        ASL     (A0)
        ASL     (A1)+
        ASL     -(A1)
        ASL     $1000
        ASL     $AABBCCDD

*****************************
*ASL - word size

        ASL.W   D0,D1
        ASL.W   #3,D0
        ASL.W   #7,D1
        ASL.W   #%101,D1
        ASL.W   (A0)
        ASL.W   (A3)+
        ASL.W   -(A5)
        ASL.W   $A432
        ASL.W   $12345678

*****************************
*ASL - long size
        
        ASL.L   D1,D2
        ASL.L   #3,D0
        ASL.L   #$1,D0
        ASL.L   #%101,D2
        
        
********** A S R *************** A S R *************** A S R **************

*****************************
*ASR

        ASR     D0,D1
        ASR     #5,D1
        ASR     #$5,D1
        ASR     #%101,D1
        ASR     (A0)
        ASR     (A0)+
        ASR     -(A0)
        ASR     $A000
        ASR     $1234FEDC
        
*****************************
*ASR - byte size

        ASR.B   D0,D2
        ASR.B   #5,D1
        ASR.B   #%1,D3
        ASR.B   #%101,D1

*****************************
*ASR - word size
        
        ASR.W   D0,D1
        ASR.W   #3,D0
        ASR.W   #$5,D1
        ASR.W   #%101,D1
        ASR.W   (A0)
        ASR.W   (A0)+
        ASR.W   -(A0)
        ASR.W   $AEFE
        ASR.W   $32243223
        
*****************************
*ASR - long size

        ASR.L   D0,D1
        ASR.L   #1,D0
        ASR.L   #$2,D1
        ASR.L   #3,D2
        
        
********** C M P *************** C M P *************** C M P **************

*****************************
*CMP 

 CMP     D0,D1
        CMP     A0,D3
        CMP     (A1),D4
        CMP     (A2)+,D2
        CMP     -(A3),D1
        CMP     $4251,D0
        CMP     $AABBCCDD,D1
        CMP     #5,D2
        CMP     #$5,D1
        CMP     #%101,D1

*****************************
*CMP - byte size
        
        CMP.B   D0,D2
        CMP.B   (A0),D1
        CMP.B   (A1)+,D2
        CMP.B   -(A4),D5
        CMP.B   $4321,D1
        CMP.B   $ACBDFE12,D1
        CMP.B   #5,D1
        CMP.B   #$5,D1
        CMP.B   #%101,D1
        
*****************************
*CMP - word size        
        
        CMP.W   D0,D1
        CMP.W   A0,D1
        CMP.W   (A0),D1
        CMP.W   (A1)+,D1
        CMP.W   -(A2),D1
        CMP.W   $423A,D1
        CMP.W   $AABBCCDD,D1
        CMP.W   #3342,D1
        CMP.W   #$2342,D1
        CMP.W   #$A,D1
        
*****************************
*CMP - long size        

        CMP.L   D0,D1
        CMP.L   A0,D2
        CMP.L   (A1),D3
        CMP.L   (A2)+,D4
        CMP.L   -(A0),D1
        CMP.L   $007A,D2
        CMP.L   $CCDD3647,D3
        CMP.L   #5,D4
        CMP.L   #$5,D5
        CMP.L   #%101,D1
        

********* C M P I ************* C M P I ************* C M P I *************

*****************************
*CMPI

        CMPI    #$E,D1
        CMPI    #$D,(A0)
        CMPI    #$F,(A0)+
        CMPI    #23,-(A0)
        CMPI    #1,$A000
        CMPI    #32,$AC34AE2D
        
*****************************
*CMPI - byte size

        CMPI.B  #$46,D0
        CMPI.B  #$2,(A0)
        CMPI.B  #22,(A0)+
        CMPI.B  #14,-(A0)
        CMPI.B  #3,$A000
        CMPI.B  #6,$11223344
        
*****************************
*CMPI - word size 
       
        CMPI.W  #1,D0
        CMPI.W  #34,(A0)
        CMPI.W  #$1A,(A0)+
        CMPI.W  #$BD,-(A0)
        CMPI.W  #$12,$A000
        CMPI.W  #1234,$AABBCCDD
        
*****************************
*CMPI - long size        
        
        CMPI.L  #5,D0
        CMPI.L  #3343,(A0)
        CMPI.L  #$AF33DE,(A0)+
        CMPI.L  #$15,-(A0)
        CMPI.L  #%101,$2345DEEF
        CMPI.L  #34,$AABBCCDD


********** E O R *************** E O R *************** E O R **************

*****************************
*EOR - byte size

        EOR.B    D1,D0
        EOR.B    D6,(A0)
        EOR.B    D1,(A1)+
        EOR.B    D4,-(A1)
        EOR.B    D1,$A
        EOR.B    D6,$CB
        EOR.B    D1,$1181
        EOR.B    D4,$AFE51433

*****************************
*EOR - word size

        EOR.W    D1,D0
        EOR.W    D0,(A0)
        EOR.W    D1,(A1)+
        EOR.W    D0,-(A1)
        EOR.W    D1,$0987
        EOR.W    D0,$FE
        EOR.W    D1,$BE35
        EOR.W    D0,$ABCD1234

*****************************
*EOR - long size

        EOR.L    D1,D0
        EOR.L    D5,(A1)
        EOR.L    D2,(A3)+
        EOR.L    D3,-(A5)
        EOR.L    D1,$1324
        EOR.L    D1,$DF78
        EOR.L    D2,$73411234
        EOR.L    D1,$ACDC5636
   

********** L E A *************** L E A *************** L E A **************

*****************************
*LEA

    LEA     $33,A3
    LEA     $C2D3,A4
    LEA     $A2,A2
    LEA     (A0),A3
    LEA     (A2),A3
    LEA     $2,A1
    LEA     $AA12,A1
    LEA     $14,A2
    LEA     $ACBD12,A0
    LEA     $ABC1,A3
    LEA     $EF, A0

******************************** MOVEM *************************************

        MOVEM.L D0-D4,-(A1)
        MOVEM.W D0-D4,$4000
        MOVEM.L A0-A5,$4000
        MOVEM.L A4/D5,(A2)
        MOVEM.L (A6),D1-D6/A0-A4
        MOVEM.W $4001,A0/A3/A6/D1/D2
        MOVEM.L (A4)+,D0/D3/D7/A1/A5/A7

 ****************************** END ***************************************

*Stop here. The next instruction shows how a label is used


        END   START           
        
* End of the program


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
