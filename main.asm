TITLE MASM Template						(main.asm)

; Description:
; 
; Revision date:

INCLUDE Irvine32.inc
.data
NumOfTypes = 6											;1:fire; 2:water; 3:grass; 4:health; 5:light; 6:dark
DataRowSize = 5											;row size of board data
DataColSize = 6											;column size of board data
BlankByte = 0											;a byte represent blank
LengthToScore = 3										;3 gems to score a combo
BoardData BYTE DataRowSize*DataColSize dup(0)			;stores the board data
EliminateData BYTE DataRowSize*DataColSize dup(0FFh)	;stores the board data to eliminate
SelX BYTE 0												;select coord x
SelY BYTE 0												;select coord y
state BYTE 1											;selector state 0:hide, 1:focus, 2:locked
ExceptionTitle BYTE "EXCEPTION!", 0						;ExceptionTitle
ExceptionMsg BYTE "there is an exception", 0			;ExceptionMessage
WelcomeTitle BYTE "P&D Coach", 0						;WelcomeTitle
WelcomeMsg BYTE "Use arrow keys to move", 0dh, 0ah,		;WelcomeMessage
				"Use spacebar to lock/release", 0
ComboMSG BYTE "Combo!", 0

.code

PrintCell PROTO index:DWORD, CellType:BYTE
Swap PROTO direction:BYTE

main PROC
mov ebx, OFFSET WelcomeTitle
mov edx, OFFSET WelcomeMsg
call MsgBox
call Game
exit
main ENDP

ClearBoardData PROC					;clears BoardData to 0
mov ecx, DataRowSize*DataColSize	;size of board data
mov al, BlankByte					;input BlankByte
mov edi, OFFSET BoardData			;target BoardData
cld									;clear flag
rep stosb							;store string byte
ret									;return
ClearBoardData ENDP

ClearEliminateData PROC				;clears EliminateData to FF
mov ecx, DataRowSize*DataColSize	;size of board data
mov al, 0FFh						;input 0FFh
mov edi, OFFSET EliminateData		;target BoardData
cld									;clear flag
rep stosb							;store string byte
ret									;return
ClearEliminateData ENDP

PrintBoardData PROC					;prints BoardData
LOCAL temp:DWORD, index:DWORD
pushad
mov index, 0						;index = 0
mov ecx, DataRowSize				;ecx = DataRowSize
L2:
mov temp, ecx						;temp = ecx
mov ecx, DataColSize				;ecx = DataColSize
L1:
mov esi, OFFSET BoardData			;target BoardData
add esi, index						;target BoardData+index
lodsb								;load string byte to al
and eax, 000000FFh					;mask
call WriteDec						;write data
inc index							;index++
loop L1								;inner loop L1: loops DataColSize time
call Crlf							;crlf
mov ecx, temp						;ecx = temp(that is, DataRowSize)
loop L2								;outer loop L2: loops DataRowSize time
popad
ret									;return
PrintBoardData ENDP

PrintEliminateData PROC				;prints EliminateData
LOCAL temp:DWORD, index:DWORD
mov index, 0						;index = 0
mov ecx, DataRowSize				;ecx = DataRowSize
L2:
mov temp, ecx						;temp = ecx
mov ecx, DataColSize				;ecx = DataColSize
L1:
mov esi, OFFSET EliminateData		;target EliminateData
add esi, index						;target EliminateData+index
lodsb								;load string byte to al
and eax, 000000FFh					;mask
mov ebx, TYPE BYTE					;set type byte
call WriteHexB						;write data
inc index							;index++
loop L1								;inner loop L1: loops DataColSize time
call Crlf							;crlf
mov ecx, temp						;ecx = temp(that is, DataRowSize)
loop L2								;outer loop L2: loops DataRowSize time
ret									;return
PrintEliminateData ENDP

RandBoardData PROC					;changes BoardData's 0 to randomized 1-6
LOCAL temp:DWORD, index:DWORD, tempdata:DWORD
mov index, 0						;index = 0
mov ecx, DataRowSize				;ecx = DataRowSize
L2:
mov temp, ecx						;temp = ecx
mov ecx, DataColSize				;ecx = DataColSize
L1:
mov esi, OFFSET BoardData			;target BoardData
add esi, index						;target BoardData+index
lodsb								;load string byte to al
and eax, 000000FFh					;mask
cmp al, BlankByte					;is the character = BlankByte?
jne Pass							;no:continue
mov tempdata, eax					;store character
mov eax, NumOfTypes					;eax = NumOfTypes
call RandomRange					;rand(0~NumOfTypes-1)
inc eax								;rand(1~NumOfTypes)
add eax, tempdata					;eax = rand(1~NumOfTypes)+tempdata
mov edi, OFFSET BoardData			;target BoardData
add edi, index						;target BoardData+index
stosb								;store back
Pass:
inc index							;index++
loop L1								;inner loop L1: loops DataColSize time
mov ecx, temp						;ecx = temp(that is, DataRowSize)
loop L2								;outer loop L2: loops DataRowSize time
ret									;return
RandBoardData ENDP

FindElimination PROC				;find elements to eliminate, store answer into EliminateData
call HorizontalFind					;find horizontally
call VerticalFind					;find vertically
ret									;return
FindElimination ENDP

HorizontalFind PROC					;find elements to eliminate horizontally, store answer into EliminateData
LOCAL temp:DWORD, index:DWORD, before:BYTE
mov index, 0						;index = 0
mov ecx, DataRowSize				;ecx = DataRowSize
L2:
mov temp, ecx						;temp = ecx
mov ecx, DataColSize				;ecx = DataColSize
L1:
mov edx, 0							;edx = 0
mov eax, index						;eax = index
mov ebx, DataColSize				;ebx = DataColSize
div ebx								;div:eax, mod:edx
and edx, 000000FFh					;mask
cmp dl, 0							;if dl == 0
je skip								;pass
cmp dl, DataColSize-1				;if dl == DataColSize-1	
je skip								;pass
cld									;clear flag
mov esi, OFFSET BoardData			;target BoardData
add esi, index						;target BoardData+index
dec esi								;esi--
lodsb								;load string byte to al
mov before, al						;before = al
lodsb								;load string byte to al
cmp al, before						;if al != before
jne skip							;pass
lodsb								;load string byte to al
cmp al, before						;if al != before
jne skip							;pass
nop									;before == now == after arrives here
mov edi, OFFSET EliminateData		;target EliminateData
add edi, index						;target EliminateData+index
mov al, 0							;input 0
dec edi								;edi--
stosb
stosb
stosb
skip:
inc index							;index++
loop L1								;inner loop L1: loops DataColSize time
mov ecx, temp						;ecx = temp(that is, DataRowSize)
loop L2								;outer loop L2: loops DataRowSize time
ret									;return
HorizontalFind ENDP

VerticalFind PROC					;find elements to eliminate vertically, store answer into EliminateData
LOCAL temp:DWORD, index:DWORD, before:BYTE
mov index, 0						;index = 0
mov ecx, DataRowSize				;ecx = DataRowSize
L2:
mov temp, ecx						;temp = ecx
mov ecx, DataColSize				;ecx = DataColSize
L1:
mov eax, index						;eax = index
cmp al, DataColSize					;if al < DataColSize
jb skip								;pass
cmp al, DataColSize*(DataRowSize-1)	;if al >= DataColSize*(DataRowSize-1)
jae skip							;pass
cld									;clear flag
mov esi, OFFSET BoardData			;target BoardData
add esi, index						;target BoardData+index
sub esi, DataColSize				;esi -= DataColSize
lodsb								;load string byte to al
mov before, al						;before = al
add esi, DataColSize				;esi += DataColSize
dec esi								;esi--
lodsb								;load string byte to al
cmp al, before						;if al != before
jne skip							;pass
add esi, DataColSize				;esi += DataColSize
dec esi								;esi--
lodsb								;load string byte to al
cmp al, before						;if al != before
jne skip							;pass
nop									;before == now == after arrives here
mov edi, OFFSET EliminateData		;target EliminateData
add edi, index						;target EliminateData+index
mov al, 0							;input 0
sub edi, DataColSize				;edi-=DataColSize
stosb
add edi, DataColSize				;edi += DataColSize
dec edi								;edi--
stosb
add edi, DataColSize				;edi += DataColSize
dec edi								;edi--
stosb
skip:
inc index							;index++
loop L1								;inner loop L1: loops DataColSize time
mov ecx, temp						;ecx = temp(that is, DataRowSize)
loop L2								;outer loop L2: loops DataRowSize time
ret									;return
VerticalFind ENDP

Eliminate PROC						;clears BoardData where EliminateData == 0
LOCAL index:DWORD
mov ecx, DataRowSize*DataColSize	;size of board data
mov index, 0						;index = 0
cld									;clear flag
L1:
mov esi, OFFSET EliminateData		;target BoardData
add esi, index						;target BoardData+index
lodsb								;loads to al
cmp al, 0							;if al = 0
jne pass
mov al, 0							;input 0
mov edi, OFFSET BoardData			;target BoardData
add edi, index						;target BoardData+index
stosb								;store data
pass:
inc index							;index++
loop L1								;loops for DataRowSize*DataColSize times
call ClearEliminateData				;clear EliminateData
ret
Eliminate ENDP

Initialize PROC						;initializes gameboard and print
call Randomize
call ClearBoardData
call ClearEliminateData
call RandBoardData
call FindElimination
ReInitialize:
call Eliminate
call RandBoardData
call FindElimination
call CheckStable
cmp eax, 0							;is stable?
jne ReInitialize					;ReInitialize if not
call PrintLocation					;Prints player Location
ret
Initialize ENDP

CheckStable PROC					;return 0 if stable, 1 if otherwise
mov ecx, DataRowSize*DataColSize	;size of board data
mov al,0							;search for 0
mov edi, OFFSET EliminateData		;search EliminateData
repne scasb
jnz Scan_Done						;stable
mov eax, 1
ret
Scan_Done:
mov eax, 0
ret
CheckStable ENDP

PrintGamePad PROC					;prints BoardData in form of ascii art
LOCAL temp:DWORD, index:DWORD
mov index, 0						;index = 0
mov ecx, DataRowSize				;ecx = DataRowSize
L2:
mov temp, ecx						;temp = ecx
mov ecx, DataColSize				;ecx = DataColSize
L1:
mov esi, OFFSET BoardData			;target BoardData
add esi, index						;target BoardData+index
lodsb								;load string byte to al
and eax, 000000FFh					;mask
INVOKE PrintCell, index, al			;PrintCell(index, al)
inc index							;index++
loop L1								;inner loop L1: loops DataColSize time
mov ecx, temp						;ecx = temp(that is, DataRowSize)
loop L2								;outer loop L2: loops DataRowSize time
ret									;return
PrintGamePad ENDP

PrintCell PROC index:DWORD, CellType:BYTE
LOCAL X:BYTE, Y:BYTE
mov eax, index						;eax = index
and eax, 000000FFh					;mask, al = index
mov dx, 0							;dx = 0
mov bx, DataColSize					;bx = DataColSize
div bx								;division
mov X, dl							;X = index%DataColSize
mov Y, al							;Y = index/DataColSize
mov dl, X							;dh = 2*(4*X+1)
shl dl, 2
inc dl
shl dl, 1
mov dh, Y							;dl = 4*Y+1
shl dh, 2
inc dh
call Gotoxy							;goto(2*(4*X+1), 4*Y+1)
mov al, CellType					;load cell type
cmp al, 0							;unknown
je unknown
cmp al, 1							;fire
je fire
cmp al, 2							;water
je water
cmp al, 3							;grass
je grass
cmp al, 4							;health
je health
cmp al, 5							;light
je light
cmp al, 6							;dark
je dark
mov ebx, OFFSET ExceptionTitle		;exception
mov edx, OFFSET ExceptionMsg		;exception
call MsgBox
jmp done
unknown:
mov eax, black*16					;default
call SetTextColor
jmp done
fire:
mov eax, lightRed*16				;lightRed
call SetTextColor
jmp done
water:
mov eax, lightBlue*16				;blue
call SetTextColor
jmp done
grass:
mov eax, lightGreen*16				;lightGreen
call SetTextColor
jmp done
health:
mov eax, lightMagenta*16			;lightMagenta
call SetTextColor
jmp done
light:
mov eax, yellow*16					;yellow
call SetTextColor
jmp done
dark:
mov eax, magenta*16					;magenta
call SetTextColor
jmp done
done:
mov al, ' '
call WriteChar
call WriteChar
call WriteChar
call WriteChar
inc dh
call Gotoxy
call WriteChar
call WriteChar
call WriteChar
call WriteChar
mov eax, white+black*16				;default
call SetTextColor
mov dl,0
mov dh,20
call Gotoxy							;goto(0,20)
ret
PrintCell ENDP

PrintLocation PROC
mov dl,SelX							;X
shl dl, 3							;dl=X*8
mov dh,SelY							;Y
shl dh, 2							;dh=Y*4
call Gotoxy
mov al, state						;al = state
cmp al, 0							;hide
je hide
cmp al, 1							;focus
je focus
cmp al, 2							;locked
je locked
jmp done							;exception
hide:
mov eax, black*16					;black
call SetTextColor
jmp done
focus:
mov eax, cyan*16					;cyan
call SetTextColor
jmp done
locked:
mov eax, lightCyan*16				;lightCyan
call SetTextColor
jmp done
done:
mov al, ' '
call WriteChar						;top piece
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
inc dh
call Gotoxy
call WriteChar						;left top
call WriteChar
inc dh
call Gotoxy
call WriteChar						;left bottom
call WriteChar
inc dl
inc dl
inc dl
inc dl
inc dl
inc dl
dec dh
call Gotoxy
call WriteChar						;right top
call WriteChar						;right bottom
inc dh
call Gotoxy
call WriteChar
call WriteChar
dec dl
dec dl
dec dl
dec dl
dec dl
dec dl
inc dh
call Gotoxy
call WriteChar						;bottom
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
mov eax, white+black*16				;default
call SetTextColor
mov dl,0
mov dh,20
call Gotoxy							;goto(0,20)
ret
PrintLocation ENDP

Game PROC
call Initialize
GameLoop:
call PrintGamePad
call KBProccess
;mov eax, 100
jmp GameLoop
ret
Game ENDP

KBProccess PROC
call ReadChar
cmp al, ' '							;if space is pressed
je space
cmp al, 0							;if special key
je special
jmp done
space:
cmp state, 0							;hide
je state0
cmp state, 1							;focus
je state1
cmp state, 2							;locked
je state2
state0:
jmp done
state1:
mov state, 2						;change to locked
call PrintLocation					;Prints player Location
jmp done
state2:
call Score							;do the scoring
jmp done
special:
cmp ah, 72							;up
je up
cmp ah, 80							;down
je down
cmp ah, 75							;left
je left
cmp ah, 77							;right
je right
up:
cmp SelY, 0
je done
cmp state, 2						;is locked?
jne noswapU
INVOKE Swap, 0						;swap(up)
noswapU:
call EraseLocation					;Earases player Location
dec	SelY							;SelY--
call PrintLocation					;Prints player Location
jmp done
down:
cmp SelY, DataRowSize-1
je done
cmp state, 2						;is locked?
jne noswapD
INVOKE Swap, 1						;swap(down)
noswapD:
call EraseLocation					;Earases player Location
inc	SelY							;SelY++
call PrintLocation					;Prints player Location
jmp done
left:
cmp SelX, 0
je done
cmp state, 2						;is locked?
jne noswapL
INVOKE Swap, 2						;swap(left)
noswapL:
call EraseLocation					;Earases player Location
dec	SelX							;SelX--
call PrintLocation					;Prints player Location
jmp done
right:
cmp SelX, DataColSize-1
je done
cmp state, 2						;is locked?
jne noswapR
INVOKE Swap, 3						;swap(right)
noswapR:
call EraseLocation					;Earases player Location
inc	SelX							;SelX++
call PrintLocation					;Prints player Location
jmp done
done:
ret
KBProccess ENDP

EraseLocation PROC
mov dl,SelX							;X
shl dl, 3							;dl=X*8
mov dh,SelY							;Y
shl dh, 2							;dh=Y*4
call Gotoxy
mov eax, black*16					;black
call SetTextColor
mov al, ' '
call WriteChar						;top piece
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
inc dh
call Gotoxy
call WriteChar						;left top
call WriteChar
inc dh
call Gotoxy
call WriteChar						;left bottom
call WriteChar
inc dl
inc dl
inc dl
inc dl
inc dl
inc dl
dec dh
call Gotoxy
call WriteChar						;right top
call WriteChar						;right bottom
inc dh
call Gotoxy
call WriteChar
call WriteChar
dec dl
dec dl
dec dl
dec dl
dec dl
dec dl
inc dh
call Gotoxy
call WriteChar						;bottom
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
call WriteChar
mov eax, white+black*16				;default
call SetTextColor
mov dl,0
mov dh,20
call Gotoxy							;goto(0,20)
ret
EraseLocation ENDP

Swap PROC direction:BYTE			;swaps BoardData(SelX,SelY) with the dir neighbor
LOCAL temp:BYTE, temp2:BYTE			;up0, down1, left2, right3
cld									;clear flag
mov eax,0
mov al, SelY						;eax = SelY
mov ebx, DataColSize				;ebx = DataColSize
mul ebx								;eax = SelY*DataColSize
add al,SelX							;eax = SelX*DataColSize+SelY, should be < 30
mov esi, OFFSET BoardData
add esi, eax						;esi = BoardData(SelX,SelY)
mov eax, 0
lodsb								;al = BoardData(SelX,SelY)
mov temp, al
cmp direction, 0
je up
cmp direction, 1
je down
cmp direction, 2
je left
cmp direction, 3
je right
jmp done							;exception
;------here we get the direction neighbor value, stores in temp2. then overwrite there with temp
up:									;up
mov eax,0
mov al, SelY						;eax = SelY
dec al								;eax--
mov ebx, DataColSize				;ebx = DataColSize
mul ebx								;eax = (SelY-1)*DataColSize
add al,SelX							;eax = (SelY-1)*DataColSize+SelX, should be < 30
mov esi, OFFSET BoardData
add esi, eax						;esi = BoardData(SelX,SelY-1)
mov eax, 0
lodsb								;al = BoardData(SelX,SelY-1)
mov temp2, al						;temp2 = BoardData(SelX,SelY-1)
dec esi								;esi--
mov edi, esi						;copy address to edi
mov eax, 0
mov al, temp						;al = temp
stosb								;store to that address
jmp done
down:								;down
mov eax,0
mov al, SelY						;eax = SelY
inc al								;eax++
mov ebx, DataColSize				;ebx = DataColSize
mul ebx								;eax = (SelY+1)*DataColSize
add al,SelX							;eax = (SelY+1)*DataColSize+SelX, should be < 30
mov esi, OFFSET BoardData
add esi, eax						;esi = BoardData(SelX,SelY+1)
mov eax, 0
lodsb								;al = BoardData(SelX,SelY+1)
mov temp2, al						;temp2 = BoardData(SelX,SelY+1)
dec esi								;esi--
mov edi, esi						;copy address to edi
mov eax, 0
mov al, temp						;al = temp
stosb								;store to that address
jmp done
left:								;left
mov eax,0
mov al, SelY						;eax = SelY
mov ebx, DataColSize				;ebx = DataColSize
mul ebx								;eax = SelY*DataColSize
add al,SelX							;eax = SelY*DataColSize+SelX, should be < 30
dec al								;eax = SelY*DataColSize+SelX-1
mov esi, OFFSET BoardData
add esi, eax						;esi = BoardData(SelX-1,SelY)
mov eax, 0
lodsb								;al = BoardData(SelX-1,SelY)
mov temp2, al						;temp2 = BoardData(SelX-1,SelY)
dec esi								;esi--
mov edi, esi						;copy address to edi
mov eax, 0
mov al, temp						;al = temp
stosb								;store to that address
jmp done
right:								;right
mov eax,0
mov al, SelY						;eax = SelY
mov ebx, DataColSize				;ebx = DataColSize
mul ebx								;eax = SelY*DataColSize
add al,SelX							;eax = SelY*DataColSize+SelX, should be < 30
inc al								;eax = SelY*DataColSize+SelX+1
mov esi, OFFSET BoardData
add esi, eax						;esi = BoardData(SelX+1,SelY)
mov eax, 0
lodsb								;al = BoardData(SelX+1,SelY)
mov temp2, al						;temp2 = BoardData(SelX+1,SelY)
dec esi								;esi--
mov edi, esi						;copy address to edi
mov eax, 0
mov al, temp						;al = temp
stosb								;store to that address
jmp done
done:
;------here we store temp2 into SelX,SelY and ENDP
mov eax,0
mov al, SelY						;eax = SelY
mov ebx, DataColSize				;ebx = DataColSize
mul ebx								;eax = SelY*DataColSize
add al,SelX							;eax = SelX*DataColSize+SelY, should be < 30
mov edi, OFFSET BoardData
add edi, eax						;edi = BoardData(SelX,SelY)
mov eax, 0
mov al, temp2
stosb								;stores temp2
ret
Swap ENDP

Score PROC
LOCAL combo:BYTE, cols:BYTE
;----------------------------
;change state to 0 first
;find and detonate score blocks, between each detonate delays 500ms, print combos after every detonation at (0,20)
;after final detonation, call StackBoardData and RandBoardData and repeat, do this until CheckStable returns 0
;before return, change state to 1
;----------------------------
mov state, 0						;state = 0
mov combo, 1						;combo = 1
call PrintLocation
call FindScoreCells					;find combo
WomboCombo:
call Eliminate
call PrintGamePad
mov eax, 500						;delay 500 ms
call delay
call FindScoreCells					;find again
call CheckStable
cmp eax, 0							;if stable
je break
inc combo							;combo++
mov dl,0
mov dh,20
call Gotoxy							;goto(0,20)
call GetMaxXY
mov cols, dl
mov ecx, 0
mov cl, cols
loopOfSpace:
mov al, ' '
call WriteChar
loop loopOfSpace					;cols times
mov dl,0
mov dh,20
call Gotoxy							;goto(0,20)
mov eax, 0
mov al, combo
call WriteDec
mov edx, OFFSET ComboMSG
call WriteString
jmp WomboCombo
break:
call CheckUnknown					;finds unknown cell, 1:have 0, 0:no 0
cmp eax, 0							;if no 0
je comboDone						;done
call StackBoardData					;else StackBoardData()
call RandBoardData					;and RandBoardData()
jmp WomboCombo						;moar wombocombo!!
comboDone:
mov dl,0
mov dh,20
call Gotoxy							;goto(0,20)
call GetMaxXY
mov cols, dl
mov ecx, 0
mov cl, cols
loopOfSpace2:
mov al, ' '
call WriteChar
loop loopOfSpace2					;cols times
mov SelX, 0							;(0,0)
mov SelY, 0
mov state, 1						;state = 1
call PrintLocation
ret
Score ENDP

FindScoreCells PROC					;finds first bunch of score cells
LOCAL temp:DWORD, index:DWORD
mov SelX, 0							;(0,0)
mov SelY, 0
mov index, 0						;index = 0
mov ecx, DataRowSize				;ecx = DataRowSize
L2:
mov temp, ecx						;temp = ecx
mov ecx, DataColSize				;ecx = DataColSize
mov SelX, 0							;SelX = 0
L1:
call HorSearch
cmp eax, 1							;found hor
je found
call VerSearch
cmp eax, 1							;found ver
je found
jmp notfound
found:								;found then mark at EliminateData
call MarkDetonate
ret									;then return
notfound:							;not found: continue
inc SelX							;SelX++
loop L1								;inner loop L1: loops DataColSize time
inc SelY							;SelY++
mov ecx, temp						;ecx = temp(that is, DataRowSize)
loop L2								;outer loop L2: loops DataRowSize time
ret									;return
FindScoreCells ENDP

HorSearch PROC						;searches horizontally around (SelX, SelY), return eax = 0 if not found, otherwise eax = 1
LOCAL thiscolor:BYTE, horcount:BYTE, tempX:BYTE, tempY:BYTE
mov eax, 0							;save(SelX, SelY)
mov al, SelX						;al = SelX
mov tempX, al						;tempX=SelX
mov al, SelY						;al = SelY
mov tempY, al						;tempX=SelY
mov horcount, 1						;horizontal count = 1(itself)
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb
mov thiscolor, al					;thiscolor = BoardData(SelX,SelY)
;------testzone
;call writeDec						;for testing
;mov al, ','							;for testing
;call writeChar						;for testing
;mov al, '('							;for testing
;call writeChar						;for testing
;mov al, SelX						;for testing
;call writeDec						;for testing
;mov al, ','							;for testing
;call writeChar						;for testing
;mov al, SelY						;for testing
;call writeDec						;for testing
;mov al, ')'							;for testing
;call writeChar						;for testing
;call crlf							;for testing
;------testzone
cmp thiscolor, 0					;if thiscolor = unknown
je notfound							;notfound
CheckLoopLeft:						;left check
cmp SelX, 0							;if SelX == 0
je breakL							;break
dec SelX							;SelX--
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb
cmp thiscolor, al					;check leftcolor
jne breakL							;break if not same
inc	horcount						;horcount++
jmp CheckLoopLeft
breakL:
mov al, tempX						;restore SelX
mov SelX, al
CheckLoopRight:						;check right
cmp SelX, DataColSize-1				;if SelX == DataColSize-1
je breakR							;break
inc SelX							;SelX++
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb
cmp thiscolor, al					;check rightcolor
jne breakR							;break if not same
inc	horcount						;horcount++
jmp CheckLoopRight
breakR:
cmp horcount, LengthToScore			;if horcount >= LengthToScore
jae found
jmp notfound
found:
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
mov eax, 1							;found
ret
notfound:
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
mov eax, 0							;notfound
ret
HorSearch ENDP

VerSearch PROC						;searches Vertically around (SelX, SelY), return eax = 0 if not found, otherwise eax = 1
LOCAL thiscolor:BYTE, vercount:BYTE, tempX:BYTE, tempY:BYTE
mov eax, 0							;save(SelX, SelY)
mov al, SelX						;al = SelX
mov tempX, al						;tempX=SelX
mov al, SelY						;al = SelY
mov tempY, al						;tempX=SelY
mov vercount, 1						;vertical count = 1(itself)
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb
mov thiscolor, al					;thiscolor = BoardData(SelX,SelY)
;------testzone
;call writeDec						;for testing
;mov al, ','							;for testing
;call writeChar						;for testing
;mov al, '('							;for testing
;call writeChar						;for testing
;mov al, SelX						;for testing
;call writeDec						;for testing
;mov al, ','							;for testing
;call writeChar						;for testing
;mov al, SelY						;for testing
;call writeDec						;for testing
;mov al, ')'							;for testing
;call writeChar						;for testing
;call crlf							;for testing
;------testzone
cmp thiscolor, 0					;if thiscolor = unknown
je notfound							;notfound
CheckLoopUp:						;up check
cmp SelY, 0							;if SelY == 0
je breakU							;break
dec SelY							;SelY--
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb
cmp thiscolor, al					;check upcolor
jne breakU							;break if not same
inc	vercount						;vercount++
jmp CheckLoopUp
breakU:
mov al, tempY						;restore SelY
mov SelY, al
CheckLoopDown:						;check down
cmp SelY, DataRowSize-1				;if SelY == DataRowSize-1
je breakD							;break
inc SelY							;SelY--
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb
cmp thiscolor, al					;check downcolor
jne breakD							;break if not same
inc	vercount						;vercount++
jmp CheckLoopDown
breakD:
cmp vercount, LengthToScore			;if horcount >= LengthToScore
jae found
jmp notfound
found:
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
mov eax, 1							;found
ret
notfound:
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
mov eax, 0							;notfound
ret
VerSearch ENDP

MarkDetonate PROC					;changes EliminateData at (SelX,SelY) to 0 and all counterparts
LOCAL tempX:BYTE, tempY:BYTE, thiscolor:BYTE
mov al, SelX						;save coordinate
mov tempX, al
mov al, SelY
mov tempY, al
;------get this cell color
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
mov thiscolor, al					;save color
;------testzone
;mov al, selx						;for testing
;call writeDec						;for testing
;mov al, ','							;for testing
;call writechar						;for testing
;mov al, sely						;for testing
;call writeDec						;for testing
;call crlf							;for testing
;------testzone
;------ret if already marked
mov esi, OFFSET EliminateData		;target EliminateData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
cmp al,0							;if marked
jne moveon
ret									;ret
moveon:
call HorSearch						;Horizontal search
cmp eax, 0							;is not Horizontal
je notHorizontal
;------Horizontal
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
call MarkThisCell					;mark this cell
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
cmp SelX, 0							;if SelX = 0
je skipRecur1H
dec SelX							;SelX--
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
cmp al, thiscolor					;skip recursive if not right color
jne skipRecur1H
call MarkDetonate					;recursive
skipRecur1H:
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
cmp SelX, DataColSize-1				;if SelX = DataColSize-1
je skipRecur2H
inc SelX							;SelX++
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
cmp al, thiscolor					;skip recursive if not right color
jne skipRecur2H
call MarkDetonate					;recursive
skipRecur2H:
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
cmp SelY, 0							;if SelY = 0
je skipRecur3H
dec SelY							;SelY--
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
cmp al, thiscolor					;skip recursive if not right color
jne skipRecur3H
call MarkDetonate					;recursive
skipRecur3H:
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
cmp SelY, DataRowSize-1				;if SelY = DataColSize-1
je skipRecur4H
inc SelY							;SelY++
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
cmp al, thiscolor					;skip recursive if not right color
jne skipRecur4H
call MarkDetonate					;recursive
skipRecur4H:
notHorizontal:
call VerSearch						;Vertical search
cmp eax, 0							;is not Vertical
je notVertical
;------Vertical
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
call MarkThisCell					;mark this cell
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
cmp SelX, 0							;if SelX = 0
je skipRecur1V
dec SelX							;SelX++
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
cmp al, thiscolor					;skip recursive if not right color
jne skipRecur1V
call MarkDetonate					;recursive
skipRecur1V:
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
cmp SelX, DataColSize-1				;if SelX = DataColSize-1
je skipRecur2V
inc SelX							;SelX++
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
cmp al, thiscolor					;skip recursive if not right color
jne skipRecur2V
call MarkDetonate					;recursive
skipRecur2V:
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
cmp SelY, 0							;if SelY = 0
je skipRecur3V
dec SelY							;SelY--
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
cmp al, thiscolor					;skip recursive if not right color
jne skipRecur3V
call MarkDetonate					;recursive
skipRecur3V:
mov eax, 0							;restore(SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX=tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY=tempY
cmp SelY, DataRowSize-1				;if SelY = DataColSize-1
je skipRecur4V
inc SelY							;SelY++
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
cmp al, thiscolor					;skip recursive if not right color
jne skipRecur4V
call MarkDetonate					;recursive
skipRecur4V:
notVertical:
mov eax, 0							;restore (SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX = tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY = tempY
ret
MarkDetonate ENDP

MarkThisCell PROC					;changes EliminateData at (SelX,SelY) to 0
;------testzone
;mov al, '!'						;for testing
;call writechar						;for testing
;mov al, selx						;for testing
;call writeDec						;for testing
;mov al, ','						;for testing
;call writechar						;for testing
;mov al, sely						;for testing
;call writeDec						;for testing
;call crlf							;for testing
;------testzone
mov edi, OFFSET EliminateData		;target EliminateData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add edi, eax						;edi = BoardData+SelY*DataColSize+SelX
mov eax, 0							;eax = 0
stosb
;------testzone
;call PrintEliminateData				;for testing
;call crlf							;for testing
;------testzone
ret
MarkThisCell ENDP

CheckUnknown PROC					;checks BoardData contains 0 or not,1:have 0, 0,notfound
mov ecx, DataRowSize*DataColSize	;size of board data
mov al,0							;search for 0
mov edi, OFFSET BoardData			;search BoardData
repne scasb
jnz Scan_Done						;no zero
mov eax, 1
ret
Scan_Done:
mov eax, 0
ret
CheckUnknown ENDP

StackBoardData PROC					;modify BoardData that contains 0 to be in stacked state
LOCAL tempX:BYTE, tempY:BYTE, temp:DWORD
mov eax, 0							;store (SelX, SelY)
mov al, SelX						;al = SelX
mov tempX, al						;tempX = SelX
mov al, SelY						;al = SelY
mov tempY, al						;tempY = SelY
;------perform stack here
StackingBegin:
mov SelX, 0							;(0,0)
mov SelY, 0
mov ecx, DataRowSize				;ecx = DataRowSize
L2:
mov temp, ecx						;temp = ecx
mov ecx, DataColSize				;ecx = DataColSize
L1:
mov esi, OFFSET BoardData			;target BoardData
mov eax, 0
mov al, SelY						;eax = SelY
mov ebx, 0
mov bl, DataColSize					;ebx = DataColSize
mul bl								;eax = SelY*DataColSize
add al, SelX						;eax = SelY*DataColSize+SelX
add esi, eax						;esi = BoardData+SelY*DataColSize+SelX
lodsb								;load string byte to al
;------swap(up)if al = 0, but skip if this cell is at top
cmp al, 0							;if this cell is not unknown
jne skipSwap						;skipSwap
cmp SelY, 0							;if top cell
je skipSwap							;skipSwap
INVOKE Swap, 0						;else Swap(up)
skipSwap:
inc SelX							;SelX++
loop L1								;inner loop L1: loops DataColSize time
mov SelX, 0							;SelX = 0
inc SelY							;SelY++
mov ecx, temp						;ecx = temp(that is, DataRowSize)
loop L2								;outer loop L2: loops DataRowSize time
;------all cell swapped
call CheckStack
cmp eax, 0							;if not stack
je StackingBegin					;stack again
;------testzone
;call WriteDec						;for testing
;------testzone
;------perform stack end
mov eax, 0							;restore (SelX, SelY)
mov al, tempX						;al = tempX
mov SelX, al						;SelX = tempX
mov al, tempY						;al = tempY
mov SelY, al						;SelY = tempY
ret
StackBoardData ENDP

CheckStack PROC						;checks BoardData if it stacks, return 0 if not stack, 1 if stack
LOCAL index:DWORD
cld
mov eax, 0
mov index, 0
mov ecx, DataColSize*DataRowSize	;ecx = DataColSize*DataRowSize
ColLoop:
cmp index, DataColSize				;if index<DataColSize
jb continue							;continue
mov esi, OFFSET	BoardData			;target BoardData
add esi, index						;target BoardData+index
lodsb
dec esi
cmp al, 0							;if not 0
jne continue						;continue
sub esi, DataColSize				;target BoardData+index-DataColSize
lodsb
dec esi
cmp al, 0							;if not 0
jne foundBad						;not stack
continue:
inc index							;index++
loop ColLoop						;loops DataColSize*DataRowSize times
mov eax, 1							;return 1
;------testzone
;call PrintBoardData					;for testing
;call writeDec						;for testing
;call crlf							;for testing
;------testzone
ret
foundBad:
;------testzone
;call writeDec						;for testing
;call crlf							;for testing
;------testzone
mov eax, 0							;return 0
;------testzone
;call PrintBoardData					;for testing
;call writeDec						;for testing
;call crlf							;for testing
;------testzone
ret
CheckStack ENDP

END main

;board data:stores the game playing data
;0:unknown
;1:fire
;2:water
;3:grass
;4:health
;5:light
;6:dark