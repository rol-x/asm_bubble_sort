DSEG AT 30H						; 80 bytes from 30H to 7FH locations are used for read and write storage; it is called as scratch pad.
ARR: 	DS 7					; Space for array declared here.

CSEG AT 0						; Code segment - program's code memory (read only!).
RESET:
	MOV 	SP, #7FH			; Stack pointer filled with value 7F. 8032/8052 (8051?) architecture assumed.

COPY_ARR:
	MOV 	DPTR, #ARR_DATA		; DPTR points to values in our array in code memory.
	MOV		R0, #ARR			; R0 points to the place reserved for the array in internal memory.
	MOV		R7, #7				; Array size moved to R7 for loop counting purpose.
 
COPY_LP:
	CLR 	A					; Accumulator is cleared.
	MOVC 	A, @A + DPTR		; Consecutive elements from array are stored in accumulator.
	MOV 	@R0, A				; The element is moved from the accumulator to the place reserved for them in data segment.
	INC 	DPTR				; DPTR points to the next element.
	INC 	R0					; R0 points to the next available space.
	DJNZ 	R7, COPY_LP			; The loop is repeated arr.size() times.

	MOV		R6, #7				; Array size stored in R6 (outer loop condition)

SORT:
	MOV		R7, #6				; Pair-selecting counter set to arr.size() - 1 (inner loop condition).
	MOV 	R0, #ARR			; R0 points to arr[i] (loop iterator).
	
COMPARE:
	; Load arr[i] and arr[i+1] to B and A, respectively.
	MOV		A, @R0				; A <- arr[i]
	MOV		B, A				; B <- arr[i]
	
	INC 	R0					; R0 <- *arr[i+1]
	MOV		A, @R0				; A <- arr[i+1]
	DEC		R0					; R0 <- *arr[i]
	
	; Perform a comparison and swap the elements if necessary
	SUBB	A, B				; Carry bit is set if arr[i] > arr[i+1] (for ascending order we need arr[i] to be smaller or equal)
	JNC		CORR				; If the order is correct (arr[i] <= arr[i+1]), skip the swapping and increment R0
	
	; Load arr[i] and arr[i+1] to B and A, respectively.
	MOV		A, @R0				; A <- arr[i]
	MOV		B, A				; B <- arr[i]
	
	INC 	R0					; R0 <- *arr[i+1]
	MOV		A, @R0				; A <- arr[i+1]
	DEC		R0					; R0 <- *arr[i]
	
	; Swap the elements
	MOV		@R0, A				; arr[i] <- arr[i+1] 		(swap part 1)
	MOV		A, B				; A <- arr[i]
	INC		R0					; R0 <- *arr[i+1]
	MOV		@R0, A				; arr[i+1] <- arr[i]		(swap part 2)
	DEC		R0					; R0 <- *arr[i]

CORR:
	INC		R0					; R0 holds the address of the next element.
	DJNZ	R7, COMPARE			; Iterate over the array up to second to last element (we select pairs).
	
	DJNZ	R6, SORT			; Repeat the process arr.size() times.

	MOV		R7, #7				; R7 holds the array size for 'show' loop.
	MOV		R0, #ARR			; R0 is reset to point at the beginning of the array.
	
SHOW:
	MOV		A, @R0				; Load i-th element to A
	MOV		R6, A				; Consecutive array elements shown in R6 for testing
	INC		R0					; Increment the array pointer
	DJNZ	R7, SHOW
	
ARR_DATA:	DB 10, 9, 12, 13, 3, 20, 0

STOP:
	SJMP	STOP
	
END