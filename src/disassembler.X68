*-----------------------------------------------------------
* Title      : A Disassembler for the Motorola MC68000 Microprocessor
* Written by : Team A (Phat, Felicia, Arthur)
* Date       : Thanksgiving 2015 (We started earlier but I happen to be filling this in today)
* Description: Converts assembly language written in hex to readable human code (CSS422 Project)
*-----------------------------------------------------------


********************************
* INFO:
* bit0-4 are used to store information about binary op-code split into it's split-up stage
* They are stored at the end of the code. (You can find code for storage at the end, after all the messages.)
*   bit0 - Store first hex of op code
*   bit1 - Store first 'bit' of a split op code
*   bit2 - Store second 'bit' of a split op code
*   bit3 - Store third 'bit' of a split op code
*   bit4 - Store fourth 'bit' of a split op code
* 
* 
* 
* COMPLETED WORK:
* SUB
* SUBA
* SUBA      
* AND
* ADD 
* SUBI
* ORI   - EORI and CMPI uses the same logic as these two
* NOT
* Bcc
* BRA
* CMP
* CMPI
* CMPA
* EOR
* EORI
* ADDA
* RTS
* MOVEM
* 
* Display buffer thingy
* IO for user input
* IO for continue/exit
* 
* MOVE                  1806
* MOVEA                 3846
* MULS                  CFC6
* DIVS                  85C3
* NEG                   4443
* LSL                   E76A
* LSR                   E66A
* ROL                   
* ROR                   
* BTST                  0702
* JSR
* ASL 
* ASR
****************************************************************************

dispnum     EQU     30          Number of lines output will display before asking to continue


    ORG    $1000
START:                  ; first instruction of program

*********************************************************************************************************************
* Displays a fancy ascii art

DISPASCII
        LEA     ASCII11,A1
        MOVE    #13,D0
        TRAP    #15
        LEA     ASCII12,A1
        TRAP    #15
        LEA     ASCII13,A1
        TRAP    #15
        LEA     ASCII14,A1
        TRAP    #15
        LEA     ASCII15,A1
        TRAP    #15
        LEA     ASCII16,A1
        TRAP    #15
        LEA     ASCII17,A1
        TRAP    #15
        LEA     ASCII18,A1
        TRAP    #15
        LEA     ASCII19,A1
        TRAP    #15
        LEA     ASCII1A,A1
        TRAP    #15
        LEA     ASCII1B,A1
        TRAP    #15
        LEA     ASCII1C,A1
        TRAP    #15
        LEA     ASCII1D,A1
        TRAP    #15
        LEA     ASCII1E,A1
        TRAP    #15
        LEA     ASCII1F,A1
        TRAP    #15
        LEA     NEWLINE,A1          Creates a new line in output window
        MOVE.B  #14,D0
        TRAP    #15

*********************************************************************************************************************
* Takes in user start and end address

IOSTART
*   Displays message asking for address
        LEA     MADDR1,A1           Loads message to retrieve first number
        BSR     IOGETADDR

        BTST    #0,D4               Checks of the starting address is an odd number
        BNE     IOERROR4            Throws an error if it is because it will crash

        MOVE.L  D4,D7               Moves starting address to D7 for now
        LEA     MADDR2,A1           Then grabs the ending address
        BSR     IOGETADDR
        CMP.L   D7,D4               Compares the start address to end address
        BGT     DISPADDR            Continues if start < end
        BRA     IOERROR1            Error if not

IOGETADDR
        MOVEA.L A1,A3               Saves the message incase of an error
        MOVE.B  #14,D0              Prepares to display message
        TRAP    #15                 Displays message

        CLR     D4                  Clears D4 register to prevent errors

        LEA     startaddr,A1        Uses this memory location to store the data
        MOVE.B  #2,D0               Trap task 4 reads number from keyboard into D1.L
        TRAP    #15

        CMP.B   #8,D1               Throws an error if the input is longer than a longword
        BGT     IOERROR2
        MOVE.B  D1,D5               Moves the length of the input to D5

IOSTARTLOOP
        LEA     startaddr,A2        Moves starting address to A2, which will be current addr

IOLOOP
        MOVE.B  (A2)+,D2            Moves data from current addr to D2
        SUB.B   #1,D5               Subtract 1 from counter
        BSR     DEC2HEX             Converts decimal to hex number
        CMP.B   #$F,D1
        BEQ     IOERROR3

        MOVE.B  D5,D6               Moves counter to D6 to be manipulated
        MULS    #4,D6               Multiply by 4 to find number of shifts left
        
        LSL.L   D6,D3               Shifts hex left
        ADD.L   D3,D4               Adds number to new total
        
        MOVE.L  #0,D3               Clears D3 to prevent errors
        
        CMP.B   #0,D5               Compares counter to 0    
        BNE     IOLOOP              Otherwise will loop
        RTS

* Error message for start address greater than end address
IOERROR1
        LEA     MIOERR1,A1
        MOVE.B  #13,D0
        TRAP    #15
        BRA     IOSTART

* Error message if user input address is longer than longword
IOERROR2
        LEA     MIOERR2,A1
        MOVE.B  #13,D0
        TRAP    #15
        MOVEA.L A3,A1
        BRA     IOGETADDR

* Error message if user enters non-valid hex numbers
IOERROR3
        LEA     MIOERR3,A1
        MOVE.B  #13,D0
        TRAP    #15
        MOVEA.L A3,A1
        BRA     IOGETADDR

* Error message for odd numbered addresses
IOERROR4
        LEA     MIOERR4,A1
        MOVE.B  #13,D0
        TRAP    #15
        BRA     IOSTART

******************************************** displays address location***********************************************
* This displays the address location of the op-code being worked on
* A6 is used as current address
DISPADDR
        MOVE.L  D7,startaddr
        MOVE.L  D4,endaddr
        BSR     CLRDN
        MOVEA.L startaddr,A6        Moves starting addr into A6 register
        MOVE.B  #dispnum,dispcount  Sets display line counter

        LEA     NEWLINE,A1          Creates a new line in output window
        MOVE.B  #14,D0
        TRAP    #15

NEWADDR
        MOVE.L  A6,D7               Loads the current address into D7
        CMP.L   endaddr,D7          Compares current address to end address
        BGT     ASK4REPEAT          Branches to done if current address > end address
        LEA     DISPADDREND,A2

************************************************
* Displays address as HEX
* INPUT: address stored into D7
* OUTPUT: prints hex address to output window
DISPADDRSTART
        MOVE.B  #2,D6               D6 is a counter, used for looping
        MOVE.L  D7,D2               Copies opcode saved in D7 to D2 to be manipulated
        SWAP    D2                  Swaps the location to be displayed (Display first word of a long word)
        BRA     DISPADDR2           Skips the second part to do later

DISPADDR1
        MOVE.W  D7,D2
DISPADDR2
        MOVE.W  D2,D1               D1 will be the first byte of the word
        MOVE.W  D2,D3               D3 will be the second byte of the word
        MOVE.W  D2,D4               D4 will be the third byte of the word
        MOVE.W  D2,D5               D5 will be the fourth byte of the word

        LSR.W   #8,D1               Shifts D1 right 12 times to move the first byte of the word to the last byte
        LSR.W   #4,D1
        LSL.W   #4,D3               Shifts D3 left 4 times to get rid of the first byte
        LSR.W   #8,D3                 Then shifts D3 right 12 times to move it to the last byte
        LSR.W   #4,D3
        LSL.W   #8,D4               Shifts D4 to the left 8 times to get rid of first 2 bytes
        LSR.W   #8,D4                 Then shifts it right 12 times to move it to the last byte
        LSR.W   #4,D4
        LSL.W   #8,D5               Shifts D5 to the left 12 times to get rid of the first 3 bytes
        LSL.W   #4,D5                 Then shifts it back to the left 12 times to move it to the last byte position
        LSR.W   #8,D5
        LSR.W   #4,D5
        
        
        LEA     DISPADDR3,A3        Place address of TENS into A3 to continue from there after conversion
        CMP.B   #9,D1               Compares digit to 9
        BGT     CONV                Print out letter representation if greater than 9

        MOVE.B  #3,D0               Displays digit if it is less than A
        TRAP    #15
        
DISPADDR3   
        MOVE.B  D3,D1               Displays digit in 1's place second

        *   converts digits 10+ into letters
        LEA     DISPADDR4,A3           Places address of NEXT into A3 to continue from there after conversion
        CMP.B   #9,D1               Compares digit to 9
        BGT     CONV                Print out letter representation if greater than 9
        
        MOVE.B  #3,D0               Displays digit if it is less than A
        TRAP    #15

DISPADDR4
        MOVE.B  D4,D1               Displays digit in 1's place second

        *   converts digits 10+ into letters
        LEA     DISPADDR5,A3           Places address of NEXT into A3 to continue from there after conversion
        CMP.B   #9,D1               Compares digit to 9
        BGT     CONV                Print out letter representation if greater than 9
        
        MOVE.B  #3,D0               Displays digit if it is less than A
        TRAP    #15

DISPADDR5
        MOVE.B  D5,D1               Displays digit in 1's place second

        *   converts digits 10+ into letters
        LEA     DISPADDR6,A3           Places address of NEXT into A3 to continue from there after conversion
        CMP.B   #9,D1               Compares digit to 9
        BGT     CONV                Print out letter representation if greater than 9
        
        MOVE.B  #3,D0               Displays digit if it is less than A
        TRAP    #15
        
DISPADDR6
* Display counter -- creates new line every 8 bytes
        * D6 is used as counter
        
        SUB.B   #1,D6
        CMP.B   #0,D6
        BNE     DISPADDR1

        JMP     (A2)                Jumps to address stored in A2 when complete

DISPADDREND
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15
        
*********************************************************************************************************************
* Splits the first byte of the op code into nibbles
* then sends it to the branch-table to jump to the appropiate section to be decoded

        CLR.L   D1                  Clears the data registers
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        MOVE.W  (A6),D6
        MOVE.B  (A6)+,D2            Moves data at current address to D1, then increments
  
        MOVE.B  D2,D7
        LSL.W   #8,D7
        
        MOVE.B  D2,D3               Copies data at D2 to D3
        *   this gets digit in 10's place
        LSR.B   #4,D3               Shifts right to get rid of 1's place
        *   this gets digit in 1's place
        LSL.B   #4,D2               Shifts left to get rid of 10's place
        LSR.B   #4,D2               Shifts back right into 1's place
        
        *   D3 holds digit in 10's place
        *   D2 holds digit in 1's place

        *   Moves second nibble to D5 to be used later
        MOVE.B  D2,D5
        MOVE.B  D3,bit0
        *   Goes to a branch-table to figure out which op code it is
        BRA     CODE

******************************************************************************************************
*   This is where the table goes to detirmine which op-code to use
CODE    
        CMP.B   #$0,D3              Goes to immediate operation section
        BEQ     IMD
        CMP.B   #$4,D3              Goes to miscellaneous section
        BEQ     MISC
        CMP.B   #$5,D3
        BEQ     ADDQ                Goes to addq section
        CMP.B   #$6,D3
        BEQ     BCC
        CMP.B   #$9,D3              Goes to sub section
        BEQ     SUB
        CMP.B   #$C,D3              Goes to sub but displays as AND
        BEQ     SUB
        CMP.B   #$D,D3              Goes to sub but displays as ADD
        BEQ     SUB
        CMP.B   #$B,D3              Goes to sub but displays as CMP or EOR
        BEQ     SUB
        CMP.B   #$1,D3
        BEQ     MOVB                Goes to movb
        CMP.B   #$3,D3
        BEQ     MOVW                Goes to movb
        CMP.B   #$2,D3
        BEQ     MOVL                Goes to movb
        CMP.B   #$8,D3
        BEQ     DIVSW               Goes to divsw
        CMP.B   #$E,D3
        BEQ     LSLR                Goes to divsw

        BRA     INVOPCODE

******************************************************************************************************
* 
JSR
        LEA MJSR,A1
        MOVE.B  #14,D0
        TRAP    #15 
        
        MOVE.B  D6,D2
        LSL.B   #5,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit4
        
        MOVE.B  D6,D2
        LSL.B   #2,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit3

        MOVE.B  #$3,D4

        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        
        LEA     TAB,A1
        MOVE    #3,D1
        TRAP    #15
        
        CMP.B   #$7,bit3
        BEQ     ADDIMDDES
        
BTST 
        LEA MBTST,A1
        MOVE.B  #14,D0
        TRAP    #15 
        
        MOVE.B  D6,D2
        LSL.B   #5,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit1
        
        MOVE.B  D6,D2
        LSL.B   #2,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit2
        
        MOVE.W  D6,D2
        LSL.W   #4,D2
        LSR.W   #8,D2
        LSR.W   #5,D2
        MOVE.B  D2,bit3
        
        MOVE.W  D6,D2
        LSL.W   #7,D2
        LSR.W   #8,D2
        LSR.W   #7,D2
        MOVE.B  D2,bit0
        
        CMP.B   #0,bit0
        BEQ     BTSTMEM
        
        LEA TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA DISPD,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        MOVE.B   #$4,D5
        
        MOVE.B  bit3,D1
        MOVE.B  #3,D0
        TRAP    #15
        
        BRA HANDLEDES
        
BTSTMEM
        LEA TAB,A1
        MOVE.B  #3,D1
        TRAP    #15
        
        MOVE.B  #$1,D4
        LEA     HANDLEDES,A2
        BRA     DISPEA
        
MOVW
        LSR.B   #1,D2
        MOVE.B  D2,bit1
        
        MOVE.B  (A6),D2
        LSL.B   #5,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit4
        
        MOVE.B  (A6)+,D2
        LSL.B   #2,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit3
        
        LSL.W   #7,D6
        LSR.W   #8,D6 
        LSR.W   #5,D6 
        MOVE.B  D6,bit2

        CMP.B   #$1,bit2
        BEQ     MOVEAW

        LEA MMOVEW,A1
        MOVE.B  #14,D0
        TRAP    #15 

        CMP.B   #$0,bit3           
        BEQ     MOVBDN1
        CMP.B   #$1,bit3
        BEQ     MOVEAN1
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        CMP.B   #$7,bit3
        BEQ     ADDIMD

MOVEAW
        LEA MMOVEAW,A1
        MOVE.B  #14,D0
        TRAP    #15 
        
        CMP.B   #$0,bit3           
        BEQ     MOVBDN1
        CMP.B   #$1,bit3
        BEQ     MOVEAN1
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        CMP.B   #$7,bit3
        BEQ     ADDIMD

MOVL
        LSR.B   #1,D2
        MOVE.B  D2,bit1
        
        MOVE.B  (A6),D2
        LSL.B   #5,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit4
        
        MOVE.B  (A6)+,D2
        LSL.B   #2,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit3
        
        LSL.W   #7,D6
        LSR.W   #8,D6 
        LSR.W   #5,D6 
        MOVE.B  D6,bit2
        
        CMP.B   #$1,bit2
        BEQ     MOVEAL

        LEA MMOVEL,A1
        MOVE.B  #14,D0
        TRAP    #15 
        
        CMP.B   #$0,bit3           
        BEQ     MOVBDN1
        CMP.B   #$1,bit3
        BEQ     MOVEAN1
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        CMP.B   #$7,bit3
        BEQ     ADDIMD

MOVEAL
        LEA MMOVEAL,A1
        MOVE.B  #14,D0
        TRAP    #15 
        
        CMP.B   #$0,bit3           
        BEQ     MOVBDN1
        CMP.B   #$1,bit3
        BEQ     MOVEAN1
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        CMP.B   #$7,bit3
        BEQ     ADDIMD        

MOVB
        LEA MMOVEB,A1
        MOVE.B  #14,D0
        TRAP    #15 
        
        LSR.B   #1,D2
        MOVE.B  D2,bit1
        
        MOVE.B  (A6),D2
        LSL.B   #5,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit4
        
        MOVE.B  (A6)+,D2
        LSL.B   #2,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit3
        
        LSL.W   #7,D6
        LSR.W   #8,D6 
        LSR.W   #5,D6 
        MOVE.B  D6,bit2
        
    
        CLR.L   D5
        
        CMP.B   #$0,bit3           
        BEQ     MOVBDN1
        CMP.B   #$1,bit3
        BEQ     MOVEAN1
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        CMP.B   #$7,bit3
        BEQ     ADDIMD
        
        BRA     INVOP

ADDIMD
    LEA     TAB,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    CMP.B   #$0,bit4
    BEQ     ADDIMD0
    CMP.B   #$1,bit4
    BEQ     ADDIMD1
    CMP.B   #$4,bit4
    BEQ     ADDIMD4

ADDIMD0
    MOVE.B  #$1,D4
    LEA     HANDLEDES,A2
    BRA     DISPEA
ADDIMD1 
    MOVE.B  #$2,D4
    LEA     HANDLEDES,A2
    BRA     DISPEA
ADDIMD4
    LEA     HASH,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     HANDLEDES,A2
    BRA     DISPEA 
    
HANDLEDES
    LEA     COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    CMP.B   #$0,bit2
    BEQ     MOVBDN2
    CMP.B   #$1,bit2
    BEQ     MOVEAN2
    CMP.B   #$2,bit2 
    BEQ     MOVIAN2
    CMP.B   #$3,bit2 
    BEQ     MOVIANI2
    CMP.B   #$4,bit2 
    BEQ     MOVIAND2
    CMP.B   #$5,D5
    BEQ     MOVBDN2
    CMP.B   #$7,D5
    BEQ     ADDIMDDES

ADDIMDDES
    CMP.B   #$0,bit4
    BEQ     ADDIMDDES0
    CMP.B   #$1,bit4
    BEQ     ADDIMDDES1
    CMP.B   #$4,bit4
    BEQ     ADDIMDDES4
    
ADDIMDDES0
    MOVE.B  #$1,D4
    LEA     ENDNEWLINE,A2
    BRA     DISPEA
    
ADDIMDDES1
    MOVE.B  #$2,D4
    LEA     ENDNEWLINE,A2
    BRA     DISPEA
    
ADDIMDDES4    
    LEA     HASH,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     ENDNEWLINE,A2
    BRA     DISPEA 
        
MOVEAN1
    LEA TAB,A1
    MOVE.B  #14,D0
    TRAP    #15

    LEA DISPA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  bit4,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    LEA COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    CMP.B   #$0,bit2
    BEQ     MOVBDN2
    CMP.B   #$1,bit2
    BEQ     MOVEAN2
    CMP.B   #$2,bit2 
    BEQ     MOVIAN2
    CMP.B   #$3,bit2 
    BEQ     MOVIANI2
    CMP.B   #$4,bit2 
    BEQ     MOVIAND2
    CMP.B   #$5,D5
    BEQ     MOVBDN2
    
MOVEIAN1
    LEA TAB,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA OPENBRA,A1
    MOVE.B  #14,D0
    TRAP    #15

    LEA DISPA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  bit4,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    LEA CLOSEBRA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    CMP.B   #$3,D4
    BEQ     ENDNEWLINE
    
    LEA COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    CMP.B   #$0,bit2
    BEQ     MOVBDN2
    CMP.B   #$1,bit2
    BEQ     MOVEAN2
    CMP.B   #$2,bit2 
    BEQ     MOVIAN2
    CMP.B   #$3,bit2 
    BEQ     MOVIANI2
    CMP.B   #$4,bit2 
    BEQ     MOVIAND2
    CMP.B   #$5,D5
    BEQ     MOVBDN2

MOVEIANI1
    LEA TAB,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA OPENBRA,A1
    MOVE.B  #14,D0
    TRAP    #15

    LEA DISPA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  bit4,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    LEA CLOSEBRA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA POS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    CMP.B   #$3,D5
    BEQ     ENDNEWLINE
           
    CMP.B   #$4,D5
    BEQ     ENDNEWLINE
        
        
    LEA COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    CMP.B   #$0,bit2
    BEQ     MOVBDN2
    CMP.B   #$1,bit2
    BEQ     MOVEAN2
    CMP.B   #$2,bit2 
    BEQ     MOVIAN2
    CMP.B   #$3,bit2 
    BEQ     MOVIANI2
    CMP.B   #$4,bit2 
    BEQ     MOVIAND2
    CMP.B   #$5,D5
    BEQ     MOVBDN2

MOVEIAND1
    LEA TAB,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA NEG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA OPENBRA,A1
    MOVE.B  #14,D0
    TRAP    #15

    LEA DISPA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  bit4,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    LEA CLOSEBRA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    CMP.B   #$4,D5
    BEQ     ENDNEWLINE
    
    LEA COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    CMP.B   #$0,bit2
    BEQ     MOVBDN2
    CMP.B   #$1,bit2
    BEQ     MOVEAN2
    CMP.B   #$2,bit2 
    BEQ     MOVIAN2
    CMP.B   #$3,bit2 
    BEQ     MOVIANI2
    CMP.B   #$4,bit2 
    BEQ     MOVIAND2
    CMP.B   #$5,D5
    BEQ     MOVBDN2

MOVBDN1
    LEA TAB,A1
    MOVE.B  #14,D0
    TRAP    #15

    CMP.B   #$6,D5             * Data Reg for LSLR
    BEQ     LSLRSRCD

    LEA DISPD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  bit4,D1
    MOVE.B  #3,D0
    TRAP    #15

    CMP.B   #$4,D5
    BEQ     ENDNLINC

    LEA COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15

    CMP.B   #$6,D5             * Data Reg for LSLR
    BEQ     LSLRDESD
    CMP.B   #$0,bit2
    BEQ     MOVBDN2
    CMP.B   #$1,bit2
    BEQ     MOVEAN2
    CMP.B   #$2,bit2 
    BEQ     MOVIAN2
    CMP.B   #$3,bit2 
    BEQ     MOVIANI2
    CMP.B   #$4,bit2 
    BEQ     MOVIAND2
    CMP.B   #$5,D5
    BEQ     MOVBDN2
    
LSLRSRCD
    LEA DISPD,A1
    MOVE.B  #14,D0
    TRAP    #15
        
    MOVE.B  bit0,D1
    MOVE.B  #3,D0
    TRAP    #15    

    LEA COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     LSLRDESD
    
LSLRDESD
    LEA DISPD,A1
    MOVE.B  #14,D0
    TRAP    #15
        
    MOVE.B  bit4,D1
    MOVE.B  #3,D0
    TRAP    #15      
    
    *MOVE.B  (A6)+,$7500            * Kind of sketch but makes it work 
    BRA     ENDNEWLINE       

MOVEAN2
    LEA DISPA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  bit1,D1
    MOVE.B  #3,D0
    TRAP    #15

    *MOVE.B  (A6)+,$7500            * Kind of sketch but makes it work 
    BRA     ENDNEWLINE    

MOVIAN2
    LEA OPENBRA,A1
    MOVE.B  #14,D0
    TRAP    #15

    LEA DISPA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  bit1,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    LEA CLOSEBRA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    *MOVE.B  (A6)+,$7500            * Kind of sketch but makes it work 
    BRA     ENDNEWLINE

MOVIANI2
    LEA OPENBRA,A1
    MOVE.B  #14,D0
    TRAP    #15

    LEA DISPA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  bit1,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    LEA CLOSEBRA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA POS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    *MOVE.B  (A6)+,$7500            * Kind of sketch but makes it work 
    BRA     ENDNEWLINE

MOVIAND2
    LEA NEG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA OPENBRA,A1
    MOVE.B  #14,D0
    TRAP    #15

    LEA DISPA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  bit1,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    LEA CLOSEBRA,A1
    MOVE.B  #14,D0
    TRAP    #15

    *MOVE.B  (A6)+,$7500            * Kind of sketch but makes it work 
    BRA     ENDNEWLINE

MOVBDN2
    LEA DISPD,A1
    MOVE.B  #14,D0
    TRAP    #15
        
    MOVE.B  bit1,D1
    MOVE.B  #3,D0
    TRAP    #15   
    
    CMP.B   #$0,D4                 * MULS meaning that A6 has already been incremented 
    BEQ     ENDNEWLINE
    
    *MOVE.B  (A6)+,$7500            * Kind of sketch but makes it work 
    BRA     ENDNEWLINE
    
    
ENDNLINC
    *MOVE.B  (A6)+,$7500            * Kind of sketch but makes it work 
    BRA     ENDNEWLINE    
    
MULSW
        MOVE.B  D7,D2
        LSL.B   #5,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit4
        
        MOVE.B  D7,D2
        LSL.B   #2,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit3
        
        MOVE.W  D7,D6
        LSL.W   #7,D6
        LSR.W   #8,D6 
        LSR.W   #5,D6 
        MOVE.B  D6,bit2
        
        LSL.W   #4,D7
        LSR.W   #8,D7 
        LSR.W   #5,D7 
        MOVE.B  D7,bit1
        
        LEA MMULSW,A1
        MOVE    #14,D1
        TRAP    #15
        
        MOVE.B  #$5,D5 
        
        CMP.B   #$0,bit3           
        BEQ     MOVBDN1
        CMP.B   #$1,bit3
        BEQ     MOVEAN1
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        CMP.B   #$7,bit3
        BEQ     ADDIMD

         
DIVSW               
        *MOVE.B  D6,D2
        MOVE.B  (A6)+,D2
        LSL.B   #5,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit4
        
        MOVE.B  D6,D2
        LSL.B   #2,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit3
        
        MOVE.W  D6,D7
        LSL.W   #7,D7
        LSR.W   #8,D7 
        LSR.W   #5,D7 
        MOVE.B  D7,bit2
        
        LSL.W   #4,D6
        LSR.W   #8,D6 
        LSR.W   #5,D6 
        MOVE.B  D6,bit1
        
        LEA MMDIVSW,A1
        MOVE    #14,D1
        TRAP    #15
        
        MOVE.B  #$5,D5 
        MOVE.B  #$4,D4
        
        CMP.B   #$0,bit3           
        BEQ     MOVBDN1
        CMP.B   #$1,bit3
        BEQ     MOVEAN1
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        CMP.B   #$7,bit3
        BEQ     ADDIMD

NEGW
        MOVE.B  D6,D2
        LSL.B   #5,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit4
        
        MOVE.B  D6,D2
        LSL.B   #2,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit3
        
        MOVE.W  D6,D7
        LSL.W   #8,D7
        LSR.W   #8,D7 
        LSR.W   #6,D7 
        MOVE.B  D7,bit2
        
        LEA MMNEGW,A1
        MOVE    #14,D1
        TRAP    #15
        
        MOVE.B  #$3,D4
        
        CMP.B   #$0,bit2
        BEQ     PRINTBYTE
        CMP.B   #$1,bit2
        BEQ     PRINTWORD
        CMP.B   #$2,bit2
        BEQ     PRINTLONG
        
PRINTBYTE
    LEA MBYTE,A1
    MOVE    #14,D1
    TRAP    #15

    CMP.B   #$0,bit3           
        BEQ     MOVBDN1
        CMP.B   #$1,bit3
        BEQ     MOVEAN1
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        CMP.B   #$7,bit3
        BEQ     ADDIMDDES
    
PRINTWORD
    LEA MWORD,A1
    MOVE    #14,D1
    TRAP    #15

    CMP.B   #$0,bit3           
        BEQ     MOVBDN1
        CMP.B   #$1,bit3
        BEQ     MOVEAN1
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        CMP.B   #$7,bit3
        BEQ     ADDIMDDES
    
PRINTLONG
    LEA MLONG,A1
    MOVE    #14,D1
    TRAP    #15
 
    CMP.B   #$0,bit3           
        BEQ     MOVBDN1
        CMP.B   #$1,bit3
        BEQ     MOVEAN1
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        CMP.B   #$7,bit3
        BEQ     ADDIMDDES
        
LSLR
        *MOVE.B  D6,D2
        MOVE.B  (A6)+,D2
        LSL.B   #5,D2
        LSR.B   #5,D2
        MOVE.B  D2,bit4
        
        MOVE.B  D6,D2
        LSL.B   #2,D2
        LSR.B   #7,D2
        MOVE.B  D2,bit3
        
        MOVE.W  D6,D7
        LSL.W   #8,D7
        LSR.W   #8,D7 
        LSR.W   #6,D7 
        MOVE.B  D7,bit2
        
        MOVE.W  D6,D7
        LSL.W   #7,D7
        LSR.W   #8,D7 
        LSR.W   #7,D7
        MOVE.B  D7,bit1   
    
        MOVE.B  D6,D4
        
        MOVE.W  D6,D7
        LSL.W   #4,D7
        LSR.W   #8,D7 
        LSR.W   #5,D7
        MOVE.B  D7,bit0 
        
        MOVE.B  D6,D7
        LSL.B   #4,D7
        LSR.B   #7,D7
        
        CMP.B   #3,bit2
        BEQ     LSLRMEMH
        
        CMP.B   #0,D7
        BEQ     ASLRMEMH
        
        MOVE.B  D6,D3
        LSL.B   #3,D3
        LSR.B   #6,D3
        CMP.B   #3,D3
        BEQ     RORL
        
        CMP.B   #$1,bit1
        BEQ     PRINTLSL
        CMP.B   #$0,bit1
        BEQ     PRINTLSR
        
ASLRMEMH
        MOVE.B  #4,D5
        CMP.B   #$1,bit1
        BEQ     PRINTASL
        CMP.B   #$0,bit1
        BEQ     PRINTASR
        
PRINTASL
        LEA MASL,A1
        MOVE    #14,D0
        TRAP    #15
        
        CMP.B   #$0,bit2
        BEQ     PRINTB
        CMP.B   #$1,bit2
        BEQ     PRINTW
        CMP.B   #$2,bit2
        BEQ     PRINTL
        BRA     LSLRMEM
        
PRINTASR        
        LEA MASR,A1
        MOVE    #14,D0
        TRAP    #15
        
        CMP.B   #$0,bit2
        BEQ     PRINTB
        CMP.B   #$1,bit2
        BEQ     PRINTW
        CMP.B   #$2,bit2
        BEQ     PRINTL
        BRA     LSLRMEM
        
LSLRMEMH
        MOVE.W  D6,D7
        LSL.W   #6,D7
        LSR.W   #8,D7
        LSR.W   #7,D7
        CMP.B   #0,D7
        BEQ     ASLRMEMH
        
        MOVE.B  #4,D5
        CMP.B   #$1,bit1
        BEQ     PRINTLSL
        CMP.B   #$0,bit1
        BEQ     PRINTLSR
RORL
        CMP.B   #$1,bit1
        BEQ     PRINTROL
        CMP.B   #$0,bit1
        BEQ     PRINTROR
PRINTROL
        LEA MROL,A1
        MOVE    #14,D0
        TRAP    #15
        
        CMP.B   #$0,bit2
        BEQ     PRINTB
        CMP.B   #$1,bit2
        BEQ     PRINTW
        CMP.B   #$2,bit2
        BEQ     PRINTL
        BRA     LSLRMEM
PRINTROR
        LEA MROR,A1
        MOVE    #14,D1
        TRAP    #15
        
        CMP.B   #$0,bit2
        BEQ     PRINTB
        CMP.B   #$1,bit2
        BEQ     PRINTW
        CMP.B   #$2,bit2
        BEQ     PRINTL
        BRA     LSLRMEM
PRINTLSL
        LEA MLSL,A1
        MOVE    #14,D0
        TRAP    #15
        
        CMP.B   #$0,bit2
        BEQ     PRINTB
        CMP.B   #$1,bit2
        BEQ     PRINTW
        CMP.B   #$2,bit2
        BEQ     PRINTL
        BRA     LSLRMEM
        
LSLRMEM
        
        LSL.B   #2,D4
        LSR.B   #5,D4
        MOVE.B  D4,bit3
        
        MOVE.B  #$3,D4
        
        CMP.B   #$2,bit3
        BEQ     MOVEIAN1
        CMP.B   #$3,bit3
        BEQ     MOVEIANI1
        CMP.B   #$4,bit3
        BEQ     MOVEIAND1
        
        LEA TAB,A1
        MOVE.B  #3,D1
        TRAP    #15 
        
        CMP.B   #$7,bit3
        BEQ     ADDIMDDES
PRINTB
        LEA MDOT,A1
        MOVE    #14,D0
        TRAP    #15

        LEA MBYTE,A1
        MOVE    #14,D0
        TRAP    #15
        
        MOVE #$6,D5
        
        CMP.B   #0,bit3
        BEQ     PRINTLSLRCOUNT
        CMP.B   #1,bit3
        BEQ     MOVBDN1

PRINTW 
        LEA MDOT,A1
        MOVE    #14,D0
        TRAP    #15

        LEA MWORD,A1
        MOVE    #14,D0
        TRAP    #15
        
        MOVE #$6,D5
        
        CMP.B   #0,bit3
        BEQ     PRINTLSLRCOUNT
        CMP.B   #1,bit3
        BEQ     MOVBDN1

PRINTL
        LEA MDOT,A1
        MOVE    #14,D0
        TRAP    #15

        LEA MLONG,A1
        MOVE    #14,D0
        TRAP    #15

        MOVE #$6,D5
        
        CMP.B   #0,bit3
        BEQ     PRINTLSLRCOUNT
        CMP.B   #1,bit3
        BEQ     MOVBDN1    

PRINTLSLRCOUNT
        LEA TAB,A1
        MOVE    #14,D0
        TRAP    #15
        
        LEA HASH,A1
        MOVE    #14,D0
        TRAP    #15
        
        MOVE.B  bit0,D1
        MOVE    #3,D0
        TRAP    #15
        
        LEA COMMA,A1
        MOVE    #14,D0
        TRAP    #15
        
        BRA LSLRDESD
  
PRINTLSR
        LEA MLSR,A1
        MOVE    #14,D1
        TRAP    #15
        
        CMP.B   #$0,bit2
        BEQ     PRINTB
        CMP.B   #$1,bit2
        BEQ     PRINTW
        CMP.B   #$2,bit2
        BEQ     PRINTL
        BRA     LSLRMEM

******************************************************************************************************
*   Branch, branch to subroutine, and branch conditionally
*   BRA, BSR, Bcc

BCC
        MOVE.B  D5,bit1             Moves condition code to bit1
        MOVE.B  (A6)+,D5            Moves the 8-bit displacement to D5
        MOVE.B  D5,bit2             Moves the 8-bit displacement to bit2
        MOVE.L  A6,D4               Moves current address to D4 register

        CMP.B   #$0,D5              If bit1 is 0, displacement is word size
        BEQ     BCCWORD
        CMP.B   #$FF,D5             If bit1 is FF, displacement is longword size
        BEQ     BCCLONG             Else, displacement is 8-bits

        * Calculates 8-bit displacement
        * 8-bit displacement is already in D5
        * Adds displacement to current address
        ADD.B   D5,D4               Adds the displacement to current address
        BRA     BCCNEXT

* Calculates 16-bit displacement
BCCWORD
        MOVE.W  (A6)+,D5            Moves the the 16-bit displacement to D5
        ADD.W   D5,D4               Adds the displacement to current address
        BRA     BCCNEXT

* Calculates 32-bit displacement
BCCLONG
        MOVE.L  (A6)+,D5            Moves the 32-bit displacement to D5
        ADD.L   D5,D4               Adds the displacement to current address
        BRA     BCCNEXT

* Does the actual calculation
* Adds the displacement to the current address
BCCNEXT
        BSR     BCCDISP             Displays branch op-code
        LEA     ENDNEWLINE,A2
        MOVE.L  D4,D7
        BRA     DISPADDRSTART

BCCDISP * Figures out which conditional code it is
        CMP.B   #$0,D2
        BEQ     BCCBRA
        CMP.B   #$7,D2
        BEQ     BCCBEQ
        CMP.B   #$6,D2
        BEQ     BCCBNE
        CMP.B   #$D,D2
        BEQ     BCCBLT
        CMP.B   #$2,D2
        BEQ     BCCBHI

        BRA     INVOP

* Prints out the appropiate code
BCCBRA
        LEA     MBRA,A1
        BRA     BCCPRINT
BCCBEQ
        LEA     MBEQ,A1
        BRA     BCCPRINT
BCCBNE
        LEA     MBNE,A1
        BRA     BCCPRINT
BCCBLT
        LEA     MBLT,A1
        BRA     BCCPRINT
BCCBHI
        LEA     MBHI,A1
        BRA     BCCPRINT
BCCPRINT
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        TRAP    #15
        RTS

******************************************************************************************************
*   Immediate data arithmetic operations
*   SUBI

IMD     MOVE.B  D5,bit1
        MOVE.B  D2,D1
        MOVE.B  (A6)+,D2
        
        MOVE    D5,D4
        AND.B   #$0001,D4
        CMP.B   #$1,D4
        BEQ     BTST
        CMP.B   #8,D1
        BEQ     BTST

        ADD.B   D2,D7

        MOVE.B  D2,D3               Copies data at D2 to D3
        *   this gets digit in 10's place
        LSR.B   #4,D3               Shifts right to get rid of 1's place
        *   this gets digit in 1's place
        LSL.B   #4,D2               Shifts left to get rid of 10's place
        LSR.B   #4,D2               Shifts back right into 1's place

        *   D3 holds digit in 10's place
        *   D2 holds digit in 1's place

        LSR.B   #1,D3
        BCC     IMD2
        ADD.B   #$2,D4
IMD2    LSR.B   #1,D3
        BCC     IMD3
        ADD.B   #$4,D4
IMD3    CMP.B   #$7,D2
        BLT     IMD4
        ADD.B   #$1,D4
        SUB.B   #$8,D2

        *   Stores them into addr
IMD4    MOVE.B  D3,bit2
        MOVE.B  D4,bit3
        MOVE.B  D2,bit4

**************************
* This finds the size of the operation

        CMP.B   #$0,bit2
        BEQ     IMDBYTE
        CMP.B   #$1,bit2
        BEQ     IMDWORD
        CMP.B   #$2,bit2
        BEQ     IMDLONG
        BRA     INVOP

*************************************************************
* Display IMD op-code
IMDPRINT
        CMP.B   #$0,bit1
        BEQ     IMDPRINTORI
        CMP.B   #$4,bit1
        BEQ     IMDPRINTSUBI
        CMP.B   #$A,bit1
        BEQ     IMDPRINTEORI
        CMP.B   #$C,bit1
        BEQ     IMDPRINTCMPI

IMDPRINTORI
        LEA     MORI,A1
        BRA     IMDPRINTEND

IMDPRINTSUBI
        LEA     MSUBI,A1
        BRA     IMDPRINTEND

IMDPRINTEORI
        LEA     MEORI,A1
        BRA     IMDPRINTEND

IMDPRINTCMPI
        LEA     MCMPI,A1
        BRA     IMDPRINTEND

IMDPRINTEND
        MOVE.B  #14,D0
        TRAP    #15
        RTS

*************************************************************
* Immediate data operation size BYTE
IMDBYTE
        BSR     IMDPRINT
        LEA     MBYTE,A1

        * Moves size to D4, needed to use DISPEA
        MOVE.B  #$1,D4
        BRA     IMDEA

*************************************************************
* Immediate data operation size WORD
IMDWORD
        BSR     IMDPRINT
        LEA     MWORD,A1

        MOVE.B  D3,D4
        BRA     IMDEA


*************************************************************
* Immediate data operation size LONG
IMDLONG
        BSR     IMDPRINT
        LEA     MLONG,A1
        

        * Moves size to D4, needed to use DISPEA
        MOVE.B  D3,D4

IMDEA
        * This prints out the size and creates tab
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     HASH,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Loads return address into A2
        LEA     IMDEA2,A2
        BRA     DISPEA
IMDEA2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     IMDEA3,A2
        BRA     SUBEA
IMDEA3
        BRA     ENDNEWLINE

******************************************************************************************************
* Miscellaneous section
*   Not goes here

MISC
        MOVE.B  D5,bit1
        MOVE.B  (A6)+,D2

        ADD.B   D2,D7

        MOVE.B  D2,D3               Copies data at D2 to D3
        *   this gets digit in 10's place
        LSR.B   #4,D3               Shifts right to get rid of 1's place
        *   this gets digit in 1's place
        LSL.B   #4,D2               Shifts left to get rid of 10's place
        LSR.B   #4,D2               Shifts back right into 1's place


        MOVE.W  D6,D4
        LSL.W   #$4,D4
        LSR.W   #$8,D4
        LSR.W   #$2,D4
        MOVE.B  D4,bit2
        CMP.B   #$3A,bit2
        BEQ     JSR

    ***
        *BTST.B  #$04,bit0
        *BEQ     MISCLEA
        *   D5 is bit1
        *   D3 is bit2
        *   D2 is bit3

**************************
* This finds the size of the operation
        * D5 is bit1
        CMP.B   #$4,D5
        BEQ     NEGW                We can branch to MISCNOT now because they use similar format <<********************************************************************************************
        CMP.B   #$6,D5              Branches to NOT section
        BEQ     MISCNOT
        CMP.B   #$E,D5              Goes to section to check for NOP or JSR
        BEQ     MISCBIT2
        BRA     MISCCHKLEA          Check bits to see if LEA, else branch to MoveM

MISCBIT2
        * D3 is bit2
        CMP.B   #$7,D3              Branches to NOP
        BEQ     MISCBIT3
        BRA     INVOP

MISCBIT3
        * D2 is bit3
        CMP.B   #$1,D2              Branches to NOP
        BEQ     MISCNOP
        CMP.B   #$5,D2              Branches to NOP
        BEQ     MISCRTS
        BRA     INVOP

* Checks if the opcode is LEA
MISCCHKLEA
        MOVE.B  D5,D4
        AND.B   #$1,D4
        CMP.B   #$1,D4
        BNE     MISCCHECKM
        MOVE.B  D3,D4
        AND.B   #$C,D4
        CMP.B   #$C,D4
        BNE     MISCCHECKM
        BRA     MISCLEA

* Checks if the opcode is MOVEM
MISCCHECKM
        MOVE.B  D5,D4
        AND.B   #$8,D4
        CMP.B   #$8,D4
        BNE     INVOP
        MOVE.B  D3,D4
        AND.B   #$8,D4
        CMP.B   #$8,D4
        BNE     INVOP
        BRA     MISCMOVEM

******************************************************
* NOP
* No operation
MISCNOP
        LEA     MNOP,A1
        MOVE.B  #14,D0
        TRAP    #15

        BRA     ENDNEWLINE          Goes to next opcode

******************************************************
MISCLEA
    
        LEA     MLEA,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15        
        
        LSR.B   #1,D5   *isolate addr register
        MOVE.W  D2,D6   *copy over bit3 for potential manip of ea reg

        LSL.B   #1,D3               Shifts the byte to the left
        AND.B   #$07,D3             Clears everything except the last 3 bits because those 3 are the mode bits

        BCLR    #3,D2               Clears the first bit of the byte because it isn't part of the reg
        BEQ     MISCLEA2             If it was already zero, then it will skip this next step
        ADD.B   #$1,D3              It it was one, then it will add one to the mode

MISCLEA2
        MOVE.B  D3,bit3     *MODE?
        MOVE.B  D2,bit4     *REG?

        ***
*        AND.L   D2,D7
*        CMP.L   #$0,D7
*        BEQ     LEAMODE0
*        CMP.L   #$1,D7 
*        BEQ     LEAMODE1
*        
*        CMP.B   #1,D7
*        BEQ     LEAMODE1
*        CMP.B   #0,D7
*        BEQ     LEAMODE0
*        
*        ***
        
LEAMODE1
        *ea mode should be set to 111
        CMP.B   #7,D3   *error check
        BEQ     LEA_ABS_EA 
        
LEAMODE0
        *ea mode should be set to 010
        CMP.B   #2,D3   *error check
        BEQ     LEA_INDIR_AN
        BNE     INVOP

LEA_ABS_EA
        *MOVE RET LOC INTO A2
        CMP.B   #$0,bit4
        BEQ     LEAIMD0
        CMP.B   #$1,bit4
        BEQ     LEAIMD1

LEAIMD0
        MOVE.B  #$1,D4
        LEA     CONTPRINTLEA,A2
        BRA     DISPEA
LEAIMD1 
        MOVE.B  #$2,D4
        LEA     CONTPRINTLEA,A2
        BRA     DISPEA  
        
CONTPRINTLEA
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     DISPA,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  D5,D1
        MOVE.B  #3,D0
        TRAP    #15
        BRA     ENDNEWLINE
        
LEA_INDIR_AN

        LEA     OPENBRA,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        LEA     DISPA,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        MOVE.B  D2,D1
        MOVE.B  #3,D0
        TRAP    #15
        
        LEA     CLOSEBRA,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        LEA     DISPA,A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.B  D5,D1
        MOVE.B  #3,D0
        TRAP    #15

        BRA     ENDNEWLINE

******************************************************
* RTS
* Return to sub routine
MISCRTS
        LEA     MRTS,A1
        MOVE.B  #14,D0
        TRAP    #15

        BRA     ENDNEWLINE          Goes to next opcode

******************************************************
* NOT
* Reuses some of IMD section to display because they have similar format
*  (I was kinda lazy too)
MISCNOT
        CLR     D4
        LSR.B   #1,D3
        BCC     MISCNOT2
        ADD.B   #$2,D4
MISCNOT2   
        LSR.B   #1,D3
        BCC     MISCNOT3
        ADD.B   #$4,D4
MISCNOT3   
        CMP.B   #$7,D2
        BLT     MISCNOT4
        ADD.B   #$1,D4
        SUB.B   #$8,D2

        *   Stores them into addr
MISCNOT4
        MOVE.B  D3,bit2
        MOVE.B  D4,bit3
        MOVE.B  D2,bit4

        CMP.B   #$0,D3
        BEQ     MISCBYTE
        CMP.B   #$1,D3
        BEQ     MISCWORD
        CMP.B   #$2,D3
        BEQ     MISCLONG
        BRA     INVOP
*************************************************************
* Immediate data operation size BYTE
MISCBYTE
        BSR     MISCPRINT
        LEA     MBYTE,A1

        * Moves size to D4, needed to use DISPEA
        MOVE.B  #$1,D4
        BRA     MISCEA

*************************************************************
* Immediate data operation size WORD
MISCWORD
        BSR     MISCPRINT
        LEA     MWORD,A1

        MOVE.B  D3,D4
        BRA     MISCEA


*************************************************************
* Immediate data operation size LONG
MISCLONG
        BSR     MISCPRINT
        LEA     MLONG,A1

        * Moves size to D4, needed to use DISPEA
        MOVE.B  D3,D4

MISCEA
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     MISCEA2,A2
        BRA     SUBEA
MISCEA2
        BRA     ENDNEWLINE

*************************************************************
* Display IMD op-code
MISCPRINT
        CMP.B   #$4,bit1
        BEQ     MISCPRINTNEG
        CMP.B   #$6,bit1
        BEQ     MISCPRINTNOT

MISCPRINTNOT
        LEA     MNOT,A1
        BRA     MISCPRINTEND

MISCPRINTNEG
        LEA     MNEG,A1
        BRA     MISCPRINTEND

MISCPRINTEND
        MOVE.B  #14,D0
        TRAP    #15
        RTS

*******************************************************************************
* ADDQ section 

ADDQ    
*       BRA     IMD
        
        MOVE.B  D5,bit1
        MOVE.B  (A6)+,D2

        ADD.B   D2,D7

        MOVE.B  D2,D3               *copy data at D2 to D3
                                    *get digit in 10's place
        LSR.B   #4,D3               Shifts right to get rid of 1's place
                                    *get digit in 1's place
        LSL.B   #4,D2               Shift left to get rid of 10's place
        LSR.B   #4,D2               Shift back right into 1's place

        * gets size
        MOVE.W  D3,D4
        LSR.W   #$2,D4
        MOVE.B  D4,bit2
    

*        BRA     IMD
        LEA     MADDQ,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        *determine size
        CMP.B   #$0,D4
        BEQ     ADDQB
        CMP.W   #$1,D4
        BEQ     ADDQW
        CMP.L   #$2,D4
        BEQ     ADDQL
        BRA     INVOP

ADDQB
        LEA     MBYTE,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     ADDQCONT
        
ADDQW
        LEA     MWORD,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     ADDQCONT
        
ADDQL        
        LEA     MLONG,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     ADDQCONT
        
ADDQCONT        
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     HASH,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        LSR.B   #1,D5               Shifts the byte over to get the value of the immediate data
        CMP.B   #$0,D5              Checks if the value is 0
        BNE     ADDQCONT2           If it isn't then skips this next part
        MOVE.B  #8,D5               If it is, then replaces the 0 with 8

ADDQCONT2
        MOVE.B  D5,D1
        MOVE.B  #3,D0
        TRAP    #15
        
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        BRA     ADDQEA
        
ADDQEA
        LSL.B   #1,D3               Shifts the byte to the left
        AND.B   #$07,D3             Clears everything except the last 3 bits because those 3 are the mode bits

        BCLR    #3,D2               Clears the first bit of the byte because it isn't part of the reg
        BEQ     ADDQEA2             If it was already zero, then it will skip this next step
        ADD.B   #$1,D3              It it was one, then it will add one to the mode

ADDQEA2
        MOVE.B  D2,bit4     *REG?
        MOVE.B  D3,bit3     *MODE?
        MOVE.B  D4,bit2     *SIZE?
        LEA     ENDNEWLINE,A2
        BRA     SUBEA
        ***
        
        
        CMP.B   #$0,D3
        BEQ     DN_EAM
        CMP.B   #$1,D3
        BEQ     AN_EAM
        CMP.B   #$2,D3
        BEQ     INAN_EAM
        CMP.B   #$3,D3
        BEQ     INC_EAM
        CMP.B   #$4,D3
        BEQ     DEC_EAM
        CMP.B   #$7,D3
        BEQ     ABS_EA
        
DN_EAM
        LEA     DISPD,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  D2,D1
        MOVE.B  #3,D0
        TRAP    #15
        BRA     ENDNEWLINE
        
AN_EAM
        LEA     DISPA,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  D2,D1
        MOVE.B  #3,D0
        TRAP    #15
        BRA     ENDNEWLINE
        
INAN_EAM
        LEA     OPENBRA,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     DISPA,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  D2,D1
        MOVE.B  #3,D0
        TRAP    #15
        LEA     CLOSEBRA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     ENDNEWLINE
        
INC_EAM                             *Consider combining inc and dec with in and removing dup com
        LEA     OPENBRA,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     DISPA,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        MOVE.W  D2,D1
        MOVE.B  #3,D0
        TRAP    #15
        
        LEA     CLOSEBRA,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     POS,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     ENDNEWLINE
        
DEC_EAM
        LEA     NEG,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     OPENBRA,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     DISPA,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  D2,D1
        MOVE.B  #3,D0
        TRAP    #15
        LEA     CLOSEBRA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     ENDNEWLINE
        
ABS_EA  
        *USE D5 TO SET SIZE APPROPRIATELY AND TO FULFILL REQ TO USE DISPEA SR
        LEA     ABS_EA2,A2
        BRA     DISPEA
        
ABS_EA2
        BRA     ENDNEWLINE

*************************************************************************
* MOVEM stuff
        *   D5 is bit1
        *   D3 is bit2
        *   D2 is bit3
MISCMOVEM
        MOVE.B  D5,D4               Gets the dr field and stores it into D5
        CLR     D5                  Moves 0 to D5
        BTST    #2,D4               Checks the bit at spot 2
        BEQ     MISCMOVEM2          Moves 1 to D5 if it is 1
        MOVE.B  #1,D5               Else, it will skip it

MISCMOVEM2
        CLR     D6                  Clears D6, setting it to 0
        MOVE.B  D3,D4               Gets the size field and stores it into D6
        BTST    #2,D4               Checks the bit at spot 2
        BEQ     MISCMOVEM3          Moves 1 to D5 if it is 1,
        MOVE.B  #1,D6               Else, it will skip it. 

MISCMOVEM3
        AND.B   #$3,D3              Gets ride of the first 2 bits
        LSL.B   #1,D3               Shifts it over 1 to make room for last bit
        BCLR    #3,D2               Checks furthest left bit and set it to 0
        BEQ     MISCMOVEM4
        BSET    #0,D3               If bit was 1, adds 1 to mode

    * bit1 is in D5 dr field
    * bit2 is in D6 size
    * bit3 is in D3 mode
    * bit4 is in D2 reg
MISCMOVEM4
        MOVE.B  D5,bit1
        MOVE.B  D6,bit2
        MOVE.B  D3,bit3
        MOVE.B  D2,bit4

    * Prints out MOVEM and size + tab
        LEA     MMOVEM,A1
        MOVE.B  #14,D0
        TRAP    #15

* Finds the appropiate size and prints it out
        CMP.B   #1,D6
        BEQ     MISCMMSIZEL
        LEA     MWORD,A1
        BRA     MISCMMPRINTSIZE

MISCMMSIZEL
        LEA     MLONG,A1

MISCMMPRINTSIZE
        TRAP    #15
        LEA     TAB,A1
        TRAP    #15

* Figures out if it is REG-to-MEM or MEM-to-REG
        MOVE.W  (A6)+,D6
        CMP.B   #0,D5
        BEQ     MISCMMPREDECCHECK
        BRA     MISCMMPOSTINC

MISCMMPREDECCHECK
        CMP.B   #$4,D3
        BEQ     MISCMMPREDEC
        BRA     MISCMMREGMEM

******************************************************************
* MOVEM Post-decrement
* Prints out registers from post-decrement
* D6 holds the reg list
MISCMMPREDEC
        MOVE.B  D6,D4
        MOVE.W  #8,D7               Counter
        MOVE.B  #$F,D1

        LEA     DISPA,A4
        BSR     MISCMMPREDECPRINT

        MOVE.W  D6,D4
        LSR.W   #8,D4
        MOVE.W  #8,D7               Counter
        LEA     DISPD,A4
        BSR     MISCMMPREDECPRINT
        BRA     MISCMMPREDEC2

MISCMMPREDEC2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     MISCMMPREDEC3,A2
        BRA     SUBEA

MISCMMPREDEC3
        BRA     ENDNEWLINE

* Prints out reg list
MISCMMPREDECPRINT
        LSL.B   #1,D4
        BCC     MISCMMPREDECPRINT3

        CMP.B   #$F,D1
        BEQ     MISCMMPREDECPRINT2
        JSR     MISCMMSLASH

MISCMMPREDECPRINT2
        MOVEA.L A4,A1
        MOVE.B  #14,D0
        TRAP    #15
        BSR     MISCMMPRINTNUM

MISCMMPREDECPRINT3
        SUB.B   #1,D7
        CMP.B   #0,D7
        BNE     MISCMMPREDECPRINT
        RTS

******************************************************************
* MOVEM Post-increment
* Prints out registers from post-increment
* D6 holds the reg list
MISCMMPOSTINC
        LEA     MISCMMPOSTINC2,A2
        BRA     SUBEA

MISCMMPOSTINC2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.W  D6,D4
        LSR.W   #8,D4
        MOVE.W  #8,D7               Counter
        MOVE.B  #$F,D1

        LEA     DISPA,A4
        BSR     MISCMMPOSTINCPRINT

        MOVE.B  D6,D4
        MOVE.W  #8,D7               Counter
        LEA     DISPD,A4
        BSR     MISCMMPOSTINCPRINT
        BRA     MISCMMPOSTINC3

MISCMMPOSTINC3
        BRA     ENDNEWLINE

* Prints out reg list
MISCMMPOSTINCPRINT
        LSR.B   #1,D4
        BCC     MISCMMPOSTINCPRINT3

        CMP.B   #$F,D1
        BEQ     MISCMMPOSTINCPRINT2
        JSR     MISCMMSLASH

MISCMMPOSTINCPRINT2
        MOVEA.L A4,A1
        MOVE.B  #14,D0
        TRAP    #15
        BSR     MISCMMPRINTNUM

MISCMMPOSTINCPRINT3
        SUB.B   #1,D7
        CMP.B   #0,D7
        BNE     MISCMMPOSTINCPRINT
        RTS

******************************************************************
* MOVEM REG-to-MEM non-predecrement
* Prints out a register to memory when it is NOT in predecrement
* D6 holds the reg list
MISCMMREGMEM
        MOVE.B  D6,D4
        MOVE.W  #8,D7               Counter
        MOVE.B  #$F,D1

        LEA     DISPD,A4
        BSR     MISCMMPOSTINCPRINT

        MOVE.W  D6,D4
        LSR.W   #8,D4
        MOVE.W  #8,D7               Counter
        LEA     DISPA,A4
        BSR     MISCMMPOSTINCPRINT
        BRA     MISCMMREGMEM2

MISCMMREGMEM2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     MISCMMREGMEM3,A2
        BRA     SUBEA

MISCMMREGMEM3
        BRA     ENDNEWLINE

* Prints out reg list
MISCMMREGMEMPRINT
        LSR.B   #1,D4
        BCC     MISCMMPOSTINCPRINT3

        CMP.B   #$F,D1
        BEQ     MISCMMPOSTINCPRINT2
        JSR     MISCMMSLASH

MISCMMREGMEMPRINT2
        MOVEA.L A4,A1
        MOVE.B  #14,D0
        TRAP    #15
        BSR     MISCMMPRINTNUM

MISCMMREGMEMPRINT3
        SUB.B   #1,D7
        CMP.B   #0,D7
        BNE     MISCMMPOSTINCPRINT
        RTS



***********************************************
* Stuff for printing reg list
MISCMMPRINTNUM
        MOVE.B  #8,D1
        SUB.B   D7,D1
        MOVE.B  #3,D0
        TRAP    #15
        RTS

MISCMMSLASH
        LEA     SLASH,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS

******************************************************************************************************
* SUB section

        *   Grabs next two nibbles
SUB     MOVE.B  (A6)+,D2

        ADD.B   D2,D7

        MOVE.B  D2,D3               Copies data at D2 to D3
        *   this gets digit in 10's place
        LSR.B   #4,D3               Shifts right to get rid of 1's place
        *   this gets digit in 1's place
        LSL.B   #4,D2               Shifts left to get rid of 10's place
        LSR.B   #4,D2               Shifts back right into 1's place

        *   D3 holds digit in 10's place
        *   D2 holds digit in 1's place

        
        *   Converts nibble into 3-bit parts
        LSR.B   #1,D3
        BCC     SUB2
        ADD.B   #$2,D4
        
SUB2    LSR.B   #1,D3
        BCC     SUB3
        ADD.B   #$4,D4
        
SUB3    MOVE.B  D5,D1
        LSR.B   #1,D1
        BCC     SUB4
        ADD.B   #$4,D3

SUB4    CMP.B   #$7,D2
        BLT     SUB1
        ADD.B   #$1,D4
        SUB.B   #$8,D2

        *   Stores them into addr
SUB1    MOVE.B  D1,bit1
        MOVE.B  D3,bit2
        MOVE.B  D4,bit3
        MOVE.B  D2,bit4

        * do this later
        CLR     D1
        MOVE.L  #0,D2
        MOVE.L  #0,D3
        MOVE.L  #0,D4
        MOVE.L  #0,D5
        MOVE.L  #0,D6

        
******************************************************************************************************
* After spliting the op-code into SUB's defined groupings
*   This figures out which operation it is and goes to that sub-routine

        * This checks if bit0 is C which is either AND or MULS
        CMP.B   #$C,bit0
        BNE     SUBACHECK
        CMP.B   #$7,bit2                    If bit0 is C and bit2 is 7, then it will branch to MULS instead
        BEQ     MULSW                       AND will use SUB's routine

SUBACHECK
        * This will display SUBA instead  -- check this later
        CMP.B   #$3,bit2
        BEQ     SUBA
        CMP.B   #$7,bit2
        BEQ     SUBA

        * This will find the size and stuff
        CMP.B   #$0,bit2
        BEQ     SUBSIZE1
        CMP.B   #$1,bit2
        BEQ     SUBSIZE2
        CMP.B   #$2,bit2
        BEQ     SUBSIZE3
        CMP.B   #$4,bit2
        BEQ     SUBSIZE4
        CMP.B   #$5,bit2
        BEQ     SUBSIZE5
        CMP.B   #$6,bit2
        BEQ     SUBSIZE6
   
******************************************************************************************************
*   Displays size, then does operation order

*   000 byte    EA,DN
SUBSIZE1
        BSR     SUBPRINT
        LEA     MBYTE,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     SUBSIZE11,A2
        BRA     SUBEA
SUBSIZE11
        LEA     SUBSIZE12,A2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBDN
SUBSIZE12
        BRA     ENDNEWLINE

*************************************************
*   001 word    EA,DN
SUBSIZE2
        BSR     SUBPRINT
        LEA     MWORD,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     SUBSIZE21,A2
        BRA     SUBEA
SUBSIZE21
        LEA     SUBSIZE22,A2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBDN
SUBSIZE22
        BRA     ENDNEWLINE

*************************************************
*   010 long    EA,DN
SUBSIZE3
        BSR     SUBPRINT
        LEA     MLONG,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     SUBSIZE31,A2
        BRA     SUBEA
SUBSIZE31
        LEA     SUBSIZE32,A2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBDN
SUBSIZE32
        BRA     ENDNEWLINE

*************************************************
*   100 byte    DN,EA
SUBSIZE4
        BSR     SUBPRINT
        LEA     MBYTE,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        *BSR     SUBERRORTEST1

        LEA     SUBSIZE41,A2
        BRA     SUBDN
SUBSIZE41
        LEA     SUBSIZE42,A2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBEA
SUBSIZE42
        BRA     ENDNEWLINE

*************************************************
*   101 word    DN,EA
SUBSIZE5
        *BSR     SUBERRORTEST1               * This does error testing
        BSR     SUBPRINT                    * Prints out 'SUB.'
        LEA     MWORD,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     SUBSIZE51,A2
        BRA     SUBDN
SUBSIZE51
        LEA     SUBSIZE52,A2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBEA
SUBSIZE52
        BRA     ENDNEWLINE

*************************************************
*   110 long    DN,EA
SUBSIZE6
        *BSR     SUBERRORTEST1               * This does error testing
        BSR     SUBPRINT                    * Prints out 'SUB.'
        LEA     MLONG,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        *BSR     SUBERRORTEST1

        LEA     SUBSIZE61,A2
        BRA     SUBDN
SUBSIZE61
        LEA     SUBSIZE62,A2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBEA
SUBSIZE62
        BRA     ENDNEWLINE

****************************************************************************
*   This section is for SUBA
*   Displays 'SUBA.' then decodes the op-code as SUBA
SUBA
        CMP.B   #$9,bit0
        BEQ     SUBPRINTSUBA
        CMP.B   #$B,bit0
        BEQ     SUBPRINTCMPA
        CMP.B   #$D,bit0
        BEQ     SUBPRINTADDA


SUBPRINTSUBA
        LEA     MSUBA,A1                    Displays 'SUBA.'
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBACONT

SUBPRINTCMPA
        LEA     MCMPA,A1                    Displays 'SUBA.'
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBACONT

SUBPRINTADDA
        LEA     MADDA,A1                    Displays 'SUBA.'
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBACONT

SUBACONT
        * Does the rest of SUBA
        CMP.B   #$3,bit2
        BEQ     SUBSIZE7
        CMP.B   #$7,bit2
        BEQ     SUBSIZE8

*************************************************
*   SUBA Word   ea,An
SUBSIZE7
        LEA     MWORD,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     SUBSIZE71,A2
        BRA     SUBEA
SUBSIZE71
        LEA     SUBSIZE72,A2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBAN2
SUBSIZE72
        BRA     ENDNEWLINE

*************************************************
*   SUBA longword   ea,An
SUBSIZE8
        LEA     MLONG,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     SUBSIZE71,A2
        BRA     SUBEA
SUBSIZE81
        LEA     SUBSIZE72,A2
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBAN2
SUBSIZE82
        BRA     ENDNEWLINE

*************************************************
* Jumps to memory location at A2
SUBJMPA2
        JMP     (A2)

*************************************************
* Prints out opcode name
SUBPRINT
        CMP.B   #$9,bit0                Prints SUB
        BEQ     SUBPRINTSUB
        CMP.B   #$B,bit0                Prints CMP or EOR
        BEQ     SUBPRINTB
        CMP.B   #$C,bit0                Prints AND
        BEQ     SUBPRINTAND
        CMP.B   #$D,bit0                Prints ADD
        BEQ     SUBPRINTADD

SUBPRINTSUB   * Displays 'SUB.' 
        LEA     MSUB,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBPRINTEND

SUBPRINTAND   * Displays 'AND.' 
        LEA     MAND,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBPRINTEND

SUBPRINTADD   * Displays 'ADD.' 
        LEA     MADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBPRINTEND

SUBPRINTB
        CMP.B   #$4,bit2
        BLT     SUBPRINTCMP

SUBPRINTEOR   * Displays 'EOR.' 
        LEA     MEOR,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBPRINTEND

SUBPRINTCMP   * Displays 'CMP.' 
        LEA     MCMP,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBPRINTEND

SUBPRINTEND
        RTS


*******************************************************************
* Error testing for DN->EA operations
*  Data register, address register, and immediate data cannot be destinations
SUBERRORTEST1
        * test for DN or AN register, branches to invalid op code if true
        CMP.B   #0,bit3
        BEQ     INVOP
        CMP.B   #1,bit3
        BEQ     INVOP
        
        * check if destination is immediate data
        CMP.B   #7,bit3
        BNE     SUBERRORTEST11
        CMP.B   #0,bit4
        BEQ     SUBERRORTEST11
        CMP.B   #1,bit4
        BEQ     SUBERRORTEST11
        BRA     INVOP
        
SUBERRORTEST11
        RTS


******************************************************************************************************
*   Displays data register
SUBDN
        LEA     MDN,A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.B  bit1,D1
        MOVE.B  #3,D0
        TRAP    #15
        
        BRA     SUBJMPA2

*   Displays data register
*   This is for Dn -> Dn cases. Source Dn uses bit4 as register instead of bit1
SUBDN2
        LEA     MDN,A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.B  bit4,D1
        MOVE.B  #3,D0
        TRAP    #15
        
        BRA     SUBJMPA2

*   Displays address register
SUBAN
        LEA     MAN,A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.B  bit4,D1
        MOVE.B  #3,D0
        TRAP    #15
        
        BRA     SUBJMPA2

*   Displays address register
*   This is for SUBA, SUBA puts An into bit1
SUBAN2
        LEA     MAN,A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.B  bit1,D1
        MOVE.B  #3,D0
        TRAP    #15
        
        BRA     SUBJMPA2


*   Displays indirect address register
SUBANID
        LEA     OPENBRA,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     MAN,A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.B  bit4,D1
        MOVE.B  #3,D0
        TRAP    #15

        LEA     CLOSEBRA,A1
        MOVE.B  #14,D0
        TRAP    #15

        BRA     SUBJMPA2

*   Displays indirect address register with post increment
SUBANIDPOS
        LEA     OPENBRA,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     MAN,A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.B  bit4,D1
        MOVE.B  #3,D0
        TRAP    #15

        LEA     CLOSEBRA,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     POS,A1
        MOVE.B  #14,D0
        TRAP    #15

        BRA     SUBJMPA2

*   Displays indirect address register with pre decrement
SUBANIDNEG
        LEA     NEG,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     OPENBRA,A1
        MOVE.B  #14,D0
        TRAP    #15

        LEA     MAN,A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.B  bit4,D1
        MOVE.B  #3,D0
        TRAP    #15

        LEA     CLOSEBRA,A1
        MOVE.B  #14,D0
        TRAP    #15

        BRA     SUBJMPA2




******************************************************************************************************
* Displays the EA as hex numbers
* 
SUBEA
        *   This finds which mode to use
        CMP.B   #$0,bit3
        BEQ     SUBDN2
        CMP.B   #$1,bit3                BYTE SIZED OPERATIONS ARE NOT ALLOWED FOR An
        BEQ     SUBAN
        CMP.B   #$2,bit3
        BEQ     SUBANID
        CMP.B   #$3,bit3
        BEQ     SUBANIDPOS
        CMP.B   #$4,bit3
        BEQ     SUBANIDNEG
        CMP.B   #$5,bit3
        BEQ     ERROR
        CMP.B   #$6,bit3
        BEQ     ERROR
        CMP.B   #$7,bit3
        BEQ     SUBEAHEX

SUBEAHEX
        CMP.B   #$4,bit4            Branches to immediate data section of bit4 is 4
        BEQ     SUBEAID
SUBEAID2
        *   Else it will assume it is absolute addressing mode
        LEA     MHEX,A1
        MOVE.B  #14,D0
        TRAP    #15

        CMP.B   #$0,bit4
        BEQ     SUBEAHEX1
        CMP.B   #$1,bit4
        BEQ     SUBEAHEX2

        CMP.B   #$0,bit2            * SUB byte displays as word
        BEQ     SUBEAHEX1
        CMP.B   #$4,bit2            * SUB byte displays as word
        BEQ     SUBEAHEX1
        CMP.B   #$1,bit2            * SUB word
        BEQ     SUBEAHEX1
        CMP.B   #$5,bit2            * SUB word
        BEQ     SUBEAHEX1
        CMP.B   #$3,bit2            * SUBA word
        BEQ     SUBEAHEX1
        CMP.B   #$2,bit2            * SUB longword
        BEQ     SUBEAHEX2
        CMP.B   #$6,bit2            * SUB longword
        BEQ     SUBEAHEX2
        CMP.B   #$7,bit2            * SUBA longword
        BEQ     SUBEAHEX2

SUBEAID
        LEA     HASH,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SUBEAID2

SUBEAHEX1  
        *absolute address word
        MOVE.B  #2,D7
        BRA     SUBEAHEX3

SUBEAHEX2  *absolute address long
        MOVE.B  #4,D7
        BRA     SUBEAHEX3

SUBEAHEX3
        CMP.B   #0,D7               Compares current addr to ending addr
        BEQ     SUBJMPA2            Branches to done if they are equal

    
        MOVE.B  (A6)+,D2            Moves data at current address to D1, then increments
        
        MOVE.B  D2,D3               Copies data at D2 to D3
        *   this gets digit in 10's place
        LSR.B   #4,D3               Shifts right to get rid of 1's place
        *   this gets digit in 1's place
        LSL.B   #4,D2               Shifts left to get rid of 10's place
        LSR.B   #4,D2               Shifts back right into 1's place

        
        *   D3 holds digit in 10's place
        *   D2 holds digit in 1's place
        
        MOVE.B  D3,D1               Displays digit in 10's place first

        *   converts digits 10+ into letters

        LEA     SUBEAHEX4,A3        Place address of TENS into A3 to continue from there after conversion
        CMP.B   #9,D1               Compares digit to 9
        BGT     CONV                Print out letter representation if greater than 9

        MOVE.B  #3,D0               Displays digit if it is less than A
        TRAP    #15
        
SUBEAHEX4    
        MOVE.B  D2,D1               Displays digit in 1's place second

        *   converts digits 10+ into letters
        LEA     SUBEAHEX5,A3           Places address of NEXT into A3 to continue from there after conversion
        CMP.B   #9,D1               Compares digit to 9
        BGT     CONV                Print out letter representation if greater than 9
        
        MOVE.B  #3,D0               Displays digit if it is less than A
        TRAP    #15
        
SUBEAHEX5         
* Display counter -- creates new line every 8 bytes
        * D7 is used as counter
        
        SUB.B   #1,D7                       
        BRA     SUBEAHEX3              Loops back to display next address

***   display EA ends here

******************************************************************************************************
* Displays the EA as hex numbers
* INPUT: Size of EA in D4; 1 = word, 2 = longword
* OUTPUT: Displays size of EA reading from A6
* Jumps to location stored in A2 when finished
DISPEA
        LEA     MHEX,A1
        MOVE.B  #14,D0
        TRAP    #15

        CMP.B   #$2,D4              Branches to longword display if size is 2
        BEQ     DISPEALONG          Else it will assume word length

DISPEAWORD
        *absolute address word
        MOVE.B  #2,D7
        BRA     DISPEA3
 
DISPEALONG
        *absolute address long
        MOVE.B  #4,D7
        BRA     DISPEA3

DISPEA3
        CMP.B   #0,D7               Compares current addr to ending addr
        BEQ     SUBJMPA2            Branches to done if they are equal

    
        MOVE.B  (A6)+,D2            Moves data at current address to D1, then increments
        
        MOVE.B  D2,D3               Copies data at D2 to D3
        *   this gets digit in 10's place
        LSR.B   #4,D3               Shifts right to get rid of 1's place
        *   this gets digit in 1's place
        LSL.B   #4,D2               Shifts left to get rid of 10's place
        LSR.B   #4,D2               Shifts back right into 1's place

        
        *   D3 holds digit in 10's place
        *   D2 holds digit in 1's place
        
        MOVE.B  D3,D1               Displays digit in 10's place first

        *   converts digits 10+ into letters

        LEA     DISPEA4,A3        Place address of TENS into A3 to continue from there after conversion
        CMP.B   #9,D1               Compares digit to 9
        BGT     CONV                Print out letter representation if greater than 9

        MOVE.B  #3,D0               Displays digit if it is less than A
        TRAP    #15
  
DISPEA4
        MOVE.B  D2,D1               Displays digit in 1's place second

        *   converts digits 10+ into letters
        LEA     DISPEA5,A3           Places address of NEXT into A3 to continue from there after conversion
        CMP.B   #9,D1               Compares digit to 9
        BGT     CONV                Print out letter representation if greater than 9
        
        MOVE.B  #3,D0               Displays digit if it is less than A
        TRAP    #15
      
DISPEA5
* Display counter -- creates new line every 8 bytes
        * D7 is used as counter
        
        SUB.B   #1,D7                       
        BRA     DISPEA3              Loops back to display next address

***   display EA ends here

*******************************************************************
* Clears all of the data registers
CLRDN
        CLR.L   D0
        CLR.L   D1
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        CLR.L   D7
        RTS

********************************************************************
* Invalid op-code handling
* Displays DATA YYYY
*  YYYY represents the op-code that failed
INVOPCODE
        ADD.B   (A6)+,D7

INVOP
        LEA     MDATA,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     TAB,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     MHEX,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        MOVE.B  #2,D6               D6 is a counter, used to know loop back once
        
        MOVE.W  D7,D2               Copies opcode saved in D2 to D7
        LSR.W   #8,D2               Shifts D2 right 8 spaces to get the first byte of the word
        BRA     INVOP2              Skips the second part to do later

INVOP1
        MOVE.B  D7,D2
INVOP2
        MOVE.B  D2,D3               Copies data at D2 to D3
        *   this gets digit in 10's place
        LSR.B   #4,D3               Shifts right to get rid of 1's place
        *   this gets digit in 1's place
        LSL.B   #4,D2               Shifts left to get rid of 10's place
        LSR.B   #4,D2               Shifts back right into 1's place

        
        *   D3 holds digit in 10's place
        *   D2 holds digit in 1's place
        
        MOVE.B  D3,D1               Displays digit in 10's place first

        *   converts digits 10+ into letters

        LEA     INVOP3,A3        Place address of TENS into A3 to continue from there after conversion
        CMP.B   #9,D1               Compares digit to 9
        BGT     CONV                Print out letter representation if greater than 9

        MOVE.B  #3,D0               Displays digit if it is less than A
        TRAP    #15
        
INVOP3   
        MOVE.B  D2,D1               Displays digit in 1's place second

        *   converts digits 10+ into letters
        LEA     INVOP4,A3           Places address of NEXT into A3 to continue from there after conversion
        CMP.B   #9,D1               Compares digit to 9
        BGT     CONV                Print out letter representation if greater than 9
        
        MOVE.B  #3,D0               Displays digit if it is less than A
        TRAP    #15
        
INVOP4
* Display counter -- creates new line every 8 bytes
        * D6 is used as counter
        
        SUB.B   #1,D6
        CMP.B   #0,D6
        BEQ     ENDNEWLINE
        BRA     INVOP1              Loops back to display next address


******************************************************************************************************
* Creates a new line after an op-code is displayed, loops back to start to display next code
ENDNEWLINE
        LEA     NEWLINE,A1          Creates a new line in output window
        MOVE.B  #14,D0
        TRAP    #15

        SUB.B   #1,dispcount
        CMP.B   #0,dispcount               Checks if display counter is zero
        BNE     NEWADDR

* Asks user to press enter to continue
* Resets counter
        LEA     NEWLINE,A1          Creates a new line in output window
        MOVE.B  #14,D0
        TRAP    #15
        
        LEA     MCONT,A1            Asks user to press enter to continue
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.B  #4,D0               Takes in user input
        TRAP    #15
        CLR.L   D1                  Clears D1 incase user decides to input something

        LEA     NEWLINE,A1          Creates a new line in output window
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.B  #dispnum,dispcount  Resets display counter
        BRA     NEWADDR             Loops back to beginning


******************************************************************************************************
* Converts decimal number into hex and displays it
*   converts number 10-15 to A-F
*   INPUT: decimal number in D1
*   OUTPUT: HEX number to output
CONV    CMP.B   #10,D1              Displays 10 as A
        BEQ     HEXA
        CMP.B   #11,D1              Displays 11 as B
        BEQ     HEXB
        CMP.B   #12,D1              Displays 12 as C
        BEQ     HEXC
        CMP.B   #13,D1              Displays 13 as D
        BEQ     HEXD
        CMP.B   #14,D1              Displays 14 as E
        BEQ     HEXE
        CMP.B   #15,D1              Displays 15 as F
        BEQ     HEXF

HEXA    LEA     DISPA,A1            Loads A character
        BRA     PRINT
  
HEXB    LEA     DISPB,A1            Loads B character
        BRA     PRINT

HEXC    LEA     DISPC,A1            Loads C character
        BRA     PRINT

HEXD    LEA     DISPD,A1            Loads D character
        BRA     PRINT

HEXE    LEA     DISPE,A1            Loads E character
        BRA     PRINT

HEXF    LEA     DISPF,A1            Loads F character
        BRA     PRINT

PRINT   MOVE.B  #14,D0              Sets trap task to #14
        TRAP    #15                 Prints out message in A1
        JMP     (A3)

******************************************************************************
* Converts decimal input to hex
* INPUT: Decimal inside D2
* OUTPUT: HEX into D3
*   Converts number in decimal to hex        
DEC2HEX
        CMP.B   #$30,D2             0
        BEQ     D2HZERO
        CMP.B   #$31,D2             1
        BEQ     D2HONE
        CMP.B   #$32,D2             2
        BEQ     D2HTWO
        CMP.B   #$33,D2             3
        BEQ     D2HTHREE
        CMP.B   #$34,D2             4
        BEQ     D2HFOUR
        CMP.B   #$35,D2             5
        BEQ     D2HFIVE
        CMP.B   #$36,D2             6
        BEQ     D2HSIX
        CMP.B   #$37,D2             7
        BEQ     D2HSEVEN
        CMP.B   #$38,D2             8
        BEQ     D2HEIGHT
        CMP.B   #$39,D2             9
        BEQ     D2HNINE
        CMP.B   #$41,D2             A
        BEQ     D2HHEXA
        CMP.B   #$42,D2             B
        BEQ     D2HHEXB
        CMP.B   #$43,D2             C
        BEQ     D2HHEXC
        CMP.B   #$44,D2             D
        BEQ     D2HHEXD
        CMP.B   #$45,D2             E
        BEQ     D2HHEXE
        CMP.B   #$46,D2             F
        BEQ     D2HHEXF
        CMP.B   #$61,D2             A
        BEQ     D2HHEXA
        CMP.B   #$62,D2             B
        BEQ     D2HHEXB
        CMP.B   #$63,D2             C
        BEQ     D2HHEXC
        CMP.B   #$64,D2             D
        BEQ     D2HHEXD
        CMP.B   #$65,D2             E
        BEQ     D2HHEXE
        CMP.B   #$66,D2             F
        BEQ     D2HHEXF

        * User entered a non-hex character
        * Moves F to D1 to indicate error before returning
        MOVE.B  #$F,D1
        RTS

*   Moves the appropiate hex number to D3
D2HZERO MOVE.B  #$0,D3
        RTS

D2HONE
        MOVE.B  #$1,D3
        RTS

D2HTWO
        MOVE.B  #$2,D3
        RTS

D2HTHREE
        MOVE.B  #$3,D3
        RTS

D2HFOUR
        MOVE.B  #$4,D3
        RTS

D2HFIVE
        MOVE.B  #$5,D3
        RTS

D2HSIX
        MOVE.B  #$6,D3
        RTS

D2HSEVEN
        MOVE.B  #$7,D3
        RTS

D2HEIGHT
        MOVE.B  #$8,D3
        RTS

D2HNINE
        MOVE.B  #$9,D3
        RTS

D2HHEXA
        MOVE.B  #$A,D3
        RTS

D2HHEXB
        MOVE.B  #$B,D3
        RTS

D2HHEXC
        MOVE.B  #$C,D3
        RTS

D2HHEXD
        MOVE.B  #$D,D3
        RTS

D2HHEXE
        MOVE.B  #$E,D3
        RTS

D2HHEXF
        MOVE.B  #$F,D3
        RTS

*************************************************************************************************
ASK4REPEAT
        LEA     NEWLINE,A1          Creates a new line in output window
        MOVE.B  #14,D0
        TRAP    #15
ASK4REPEAT2
        LEA     MREPEAT,A1          Asks user if they want to start over or exit
        MOVE.B  #14,D0
        TRAP    #15

        LEA     bit4,A1             User has to enter Y to start over
        MOVE.B  #2,D0               N to exit
        TRAP    #15

        MOVE.B  bit4,D1             User input was stored in bit4
        CMP.B   #$59,D1             Char Y
        BEQ     DISPASCII
        CMP.B   #$79,D1             Char y
        BEQ     DISPASCII
        CMP.B   #$4E,D1             Char N
        BEQ     DONE
        CMP.B   #$6E,D1             Char n
        BEQ     DONE
        BRA     ASK4REPEAT2          Asks again if user enters invalid character

**************************************************************************************************
ERROR   LEA     MERROR,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     EXIT

DONE    LEA     MDONE,A1
        MOVE.B  #14,D0
        TRAP    #15

EXIT    MOVE.B  #9,D0
        TRAP    #15

************************************ Output stuff **************************************
* Stuff for output

CR      EQU     $0D
LF      EQU     $0A

SPACE       DC.B    ' ',0
NEWLINE     DC.B    '',CR,LF,0
TAB         DC.B    '   ',0
COMMA       DC.B    ',',0
OPENBRA     DC.B    '(',0
CLOSEBRA    DC.B    ')',0
POS         DC.B    '+',0
NEG         DC.B    '-',0
HASH        DC.B    '#',0
SLASH       DC.B    '/',0


DISPA       DC.B    'A',0
DISPB       DC.B    'B',0
DISPC       DC.B    'C',0
DISPD       DC.B    'D',0
DISPE       DC.B    'E',0
DISPF       DC.B    'F',0

MDOT        DC.B    '.',0
MHEX        DC.B    '$',0
MBYTE       DC.B    'B ',0
MWORD       DC.B    'W ',0
MLONG       DC.B    'L ',0
MDN         DC.B    'D',0
MAN         DC.B    'A',0

MJSR        DC.B    'JSR',0
MBTST       DC.B    'BTST',0
MROL        DC.B    'ROL',0
MROR        DC.B    'ROR',0
MLSL        DC.B    'LSL',0
MLSR        DC.B    'LSR',0
MMNEGW      DC.B    'NEG.',0
MMDIVSW     DC.B    'DIVS.W',0
MMULSW      DC.B    'MULS.W',0
MMOVEB      DC.B    'MOVE.B',0
MMOVEW      DC.B    'MOVE.W',0
MMOVEL      DC.B    'MOVE.L',0
MMOVEAW     DC.B    'MOVEA.W',0
MMOVEAL     DC.B    'MOVEA.L',0
MMOVEM      DC.B    'MOVEM.',0

MASL        DC.B    'ASL',0
MASR        DC.B    'ASR',0
MDATA       DC.B    'DATA',0
MSUB        DC.B    'SUB.',0
MSUBA       DC.B    'SUBA.',0
MAND        DC.B    'AND.',0
MADD        DC.B    'ADD.',0
MSUBI       DC.B    'SUBI.',0
MORI        DC.B    'ORI.',0
MNOT        DC.B    'NOT.',0
MMUL        DC.B    'MULS.',0
MNEG        DC.B    'NEG',0
MCMP        DC.B    'CMP.',0
MCMPI       DC.B    'CMPI.',0
MCMPA       DC.B    'CMPA.',0
MEOR        DC.B    'EOR.',0
MEORI       DC.B    'EORI.',0
MADDA       DC.B    'ADDA.',0
MADDQ       DC.B    'ADDQ.',0

MBEQ        DC.B    'BEQ',0
MBNE        DC.B    'BNE',0
MBLT        DC.B    'BLT',0
MBHI        DC.B    'BHI',0
MBRA        DC.B    'BRA',0
MNOP        DC.B    'NOP',0
MRTS        DC.B    'RTS',0
MLEA        DC.B    'LEA',0

MADDR1      DC.B    'Lemme get dat start address, fam: ',0
MADDR2      DC.B    'Gimme that end address too homie: ',0
MREPEAT     DC.B    'Tryna go again or what? (Y/N): ',0
MIOERR1     DC.B    'End address must be after the start address, try again.',0
MIOERR2     DC.B    'Address cannot be longer than longword, try again.',0
MIOERR3     DC.B    'Re-enter valid hex numbers.',0
MIOERR4     DC.B    'Address must be an even number.',0
MERROR      DC.B    'ERROR: Something broke',0
MDONE       DC.B    'COMPLETE: IT DID NOT CRASH',0
MCONT       DC.B    '**PRESS ENTER TO CONTINUE**',0

ASCII1      DC.B    ' ________  ________  ___  __       ',0
ASCII2      DC.B    '|\   ____\|\   __  \|\  \|\  \     ',0
ASCII3      DC.B    '\ \  \___|\ \  \|\  \ \  \/  /|_   ',0
ASCII4      DC.B    ' \ \  \____\ \   __  \ \   ___  \  ',0
ASCII5      DC.B    '  \ \  ___  \ \  \|\  \ \  \\ \  \ ',0
ASCII6      DC.B    '   \ \_______\ \_______\ \__\\ \__\',0
ASCII7      DC.B    '    \|_______|\|_______|\|__| \|__|',0

ASCII11     DC.B    '%%#% %% %% #%**      .%%%%%%%%%.',0
ASCII12     DC.B    ' %#  %%#%% #%..      *%%%%%%%%%%              %/%%%/% #%%%%%    /%%    %%#  %%#',0
ASCII13     DC.B    ' %#  %% %% #%,,       %%%%%%%%%%.     ###       %%%   /%%,,,   /%%%    % %, %%#',0
ASCII14     DC.B    '                    # /%%%%%%%%%#               %%%   /%%***  /% %%%   %  %/ %#',0
ASCII15     DC.B    '                   (%  %%%%%%%%%%               %%%   /%%%%% /%  (%%   %  %  %#',0
ASCII16     DC.B    '                   %%, (%%%%%%%%%#',0
ASCII17     DC.B    '                  #%%   %%%%%%%%%%',0
ASCII18     DC.B    '                  %%.   #%%%%%%%%%#',0
ASCII19     DC.B    '                 #%#     %%%%%%%%%%           ________  ________  ___  __',0
ASCII1A     DC.B    '                .%%      #%%%%%%%%%(        |\   ____\|\   __  \|\  \|\  \',0
ASCII1B     DC.B    '                %%( (%%%%%%%%%%%%%%%        \ \  \___|\ \  \|\  \ \  \/  /|_',0
ASCII1C     DC.B    '               ,%%  //////%%%%%%%%%%(        \ \  \____\ \   __  \ \   ___  \',0
ASCII1D     DC.B    '               %%/        *%%%%%%%%%%         \ \  ___  \ \  \|\  \ \  \\ \  \',0
ASCII1E     DC.B    '              %%%,         %%%%%%%%%%/         \ \_______\ \_______\ \__\\ \__\',0
ASCII1F     DC.B    '           (%%%%%%%(     *%%%%%%%%%%%%%,        \|_______|\|_______|\|__| \|__|',0

********************************** MEMORY STORAGE **********************************************
* Stores memory locations at the end of the program
* How DS works: Give it a variable name.
*   DS means Define Storage. Give it a size of how big you want the storage to be (Byte, Word, Longword)
*   Last is the number of storage you want. 
*   Example: DS.W   1   This creates a 1 longword location to be used. Memory would look like: FF FF
*            DS.B   3   This creates three byte-sized locations to be used. Memory would look like: FF FF FF
*            

dispcount   DS.B    1           Used to count display lines

startaddr   DS.L    1
endaddr     DS.L    1

bit0        DS.B    1           SEE NOTE UP TOP
bit1        DS.B    1           SEE NOTE UP TOP
bit2        DS.B    1           SEE NOTE UP TOP
bit3        DS.B    1           SEE NOTE UP TOP
bit4        DS.B    1           SEE NOTE UP TOP


    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
