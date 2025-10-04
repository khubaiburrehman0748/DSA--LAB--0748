INCLUDE Irvine32.inc
.data

number_of_turns dword 0
rowsize dword 12
col dword 0
row dword 0
temp dword 0
enter_prompt BYTE "Enter your move (0-8): ",0
enter_invalid BYTE "Invalid move cell already taken, try again.",0
enter_computer_win BYTE "Computer Wins ",0
enter_player_win BYTE "Player Wins ",0
enter_draw BYTE "It's a Draw",0
computer_win dword 0
player_win dword 0
computer_played dword 0


grid sdword 9 dup(-1)      

;------------------------------------

dotMsg   BYTE ". ",0       
spaceMsg BYTE " ",0

;------------------------------------


.code
main PROC
    ; initialize random seed (optional)
    call Randomize

    ; zero out counters and flags
    mov number_of_turns, 0
    mov computer_win, 0
    mov player_win, 0
    mov computer_played, 0


    call game
    exit
main ENDP







;---------------- Main Game Loop ----------------

game proc 

mov number_of_turns, 0          ; initialize turn counter

call turn_1                     ; computer makes first random move
call print_grid
inc number_of_turns


main_game_loop:

    ; ----- Human Turn -----
    call human_move
    call print_grid
    call check_player_win
    cmp player_win, 1
    je player_wins_label

    inc number_of_turns
    cmp number_of_turns, 9
    je draw_label                ; if 9 moves, game draw

    ; ----- Computer Turn -----
    mov eax, 0                   ; clear return value
    call computer_win_move       ; if move made, check win
    call check_computer_win
    cmp computer_win, 1
    je computer_wins_label

    ; ----- Block human or calculated move -----
    call block_human_win         ; returns 1 if move placed
    cmp eax, 1
    jne no_block                  ; if no move, go to calculated probability

    jmp after_computer_move       ; already moved

no_block:
    call calculated_probability  ; returns 1 if move placed
    cmp eax, 1
    jne after_computer_move

after_computer_move:
    call check_computer_win
    cmp computer_win, 1
    je computer_wins_label
    mov eax,0
    mov computer_played,eax      ; reset flag
    call print_grid
    inc number_of_turns
    cmp number_of_turns, 9
    je draw_label
    jmp main_game_loop

; ---------- Labels ----------
player_wins_label:
    mov edx, OFFSET enter_player_win
    call WriteString
    jmp end_game

computer_wins_label:
    mov edx, OFFSET enter_computer_win
    call WriteString
    jmp end_game

draw_label:
    mov edx, OFFSET enter_draw
    call WriteString

end_game:
    exit

game endp


;------------generating computer's first move-------------

turn_1 PROC

; generate random col (0–2)
mov eax, 3
call RandomRange
mov col, eax

; generate random row (0–2)
mov eax, 3
call RandomRange
mov row, eax

;----------- compute offset = row*12 + col*4-------------

mov eax, rowsize        ; eax = 12
imul eax, row           ; eax = row*12
mov ebx, col
imul ebx, TYPE grid     ; ebx = col*4
add eax, ebx            ; eax = row*12 + col*4
mov esi, eax            ; esi = byte offset                                    
mov DWORD PTR [grid + esi], 0           ; place 0 in that cell
ret

turn_1 ENDP
;-------------------------------------------------------


;------------ generated ------------------

















; ------------ print grid --------------

print_grid PROC

mov ecx, 9               ; loop 9 cells
mov esi, OFFSET grid

print_loop:
  mov eax, [esi]           ; load cell value
  cmp eax, -1
  jne print_value

                            
   mov edx, OFFSET dotMsg     ; if -1 ? print dot
   call WriteString
    jmp print_next

print_value:
   call WriteDec

print_next:
  mov edx, OFFSET spaceMsg
  call WriteString
  add esi, TYPE grid
 loop print_loop
 ret

print_grid ENDP
;---------------------------------------








;------------ human's turn ------------------

human_move PROC

human_input_loop:
    mov edx, OFFSET enter_prompt
    call WriteString
    call ReadInt          ; input in EAX

    ; map 0..8 -> row,col
    cmp eax, 0
    jl human_move_invalid
    cmp eax, 8
    jg human_move_invalid

    mov ebx, 3
    xor edx, edx
    div ebx               ; quotient in EAX = row, remainder in EDX = col

    mov row, eax
    mov col, edx

    ; compute offset = row*12 + col*4
    mov eax, rowsize      ; 12
    imul eax, row         ; row*12
    mov ebx, col
    imul ebx, TYPE grid   ; col*4
    add eax, ebx
    mov esi, eax

    ; check cell
    mov eax, [grid + esi]
    cmp eax, -1
    jne human_move_invalid  ; occupied -> retry

    mov DWORD PTR [grid + esi], 1   ; place player '1'
    mov edx, OFFSET spaceMsg
    call WriteString
    jmp human_move_done

human_move_invalid:
    mov edx, OFFSET enter_invalid
    call WriteString
    jmp human_input_loop

human_move_done:
    ret
human_move ENDP

;-----------human's turn end------------------



;--------------------check computer win--------------------
check_computer_win PROC
                                                 
mov eax,0
mov computer_win,eax
mov ecx, 0
win_move:
    mov esi, OFFSET grid
    mov ebx, 0
    mov edx,0

check_possibilities_of_1:              ; Row checks
    cmp ecx, 0
    jne skip_row0
    call possibility1
    cmp computer_win,1
    je ccw_done
skip_row0:
    
    cmp ecx, 3
    jne skip_row3
    call possibility1
    cmp computer_win,1
    je ccw_done
skip_row3:

    cmp ecx, 6
    jne skip_row6
    call possibility1
    cmp computer_win,1
    je ccw_done
skip_row6:


check_possibilities_of_2:              ; Column checks
    cmp ecx, 0
    jne skip_col0
    call possibility2
    cmp computer_win,1
    je ccw_done
skip_col0:

    cmp ecx, 1
    jne skip_col1
    call possibility2
    cmp computer_win,1
    je ccw_done
skip_col1:

    cmp ecx, 2
    jne skip_col2
    call possibility2
    cmp computer_win,1
    je ccw_done
skip_col2:


check_possibilities_of_3:              ; Diagonal 1
    cmp ecx, 0
    jne skip_diag1
    call possibility3
    cmp computer_win,1
    je ccw_done
skip_diag1:


check_possibilities_of_4:              ; Diagonal 2
    cmp ecx, 2
    jne skip_diag2
    call possibility4
    cmp computer_win,1
    je ccw_done
skip_diag2:

    jmp end_block


possibility1:                         ; check row (ecx = 0,3,6)
    mov row, ecx
    mov edx, 0                        ; reset sum

    mov ebx, ecx                      ; end index = start index + 3
    add ebx, 3

row_loop:
    mov eax,row          ; load grid[row]
    imul eax, 4
    mov eax, [esi + eax]                   ; if empty, skip adding
    cmp eax,0
    je skip_return_possibility1                               ;
    ret
    skip_return_possibility1:
    inc row
    cmp row, ebx
    jl row_loop                       ; loop until row end index

    mov eax,1
    mov computer_win,eax
    ret

possibility2:                         ; col check (ecx = 0,1,2)
    mov col, ecx
    mov edx, 0

    mov ebx, ecx
    add ebx, 9                        ; col end index (ecx+6 effectively, step 3)

col_loop:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, 0
    je skip_return_possibility2                               ; if sum != 2, return to block 
    ret
    skip_return_possibility2:
    
    add col, 3                        ; move down one row
    cmp col, ebx
    jl col_loop

    mov eax,1
    mov computer_win,eax
    ret

possibility3:
    mov row, 0
    mov edx, 0

diag1_loop:
    mov eax,row
    mov eax, [esi + eax*4]
    cmp eax, 0
    je skip_return_possibility3                               ; if sum != 2, return to block 
    ret
    skip_return_possibility3:
    add row, 4                        ; step through 0,4,8
    cmp row, 12
    jl diag1_loop

    mov eax,1
    mov computer_win,eax
    ret

possibility4:
    mov row, 2
    mov edx, 0

diag2_loop:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, 0
    je skip_return_possibility4                               ; if sum != 2, return to block 
    ret
    skip_return_possibility4:
    add row, 2                        ; step 2 ? goes 2,4,6
    cmp row, 6
    jle diag2_loop                    

    mov eax,1
    mov computer_win,eax
    ret

end_block:
    inc ecx
    cmp ecx, 9
    jl win_move                                                 
    mov eax,0
    mov computer_win,eax

ccw_done:
ret
check_computer_win ENDP

;----------------check computer win end----------------





;--------------------check player win--------------------
check_player_win PROC   

mov eax,0
mov player_win,eax
mov ecx, 0
win_move:
    mov esi, OFFSET grid
    mov ebx, 0
    mov edx,0

check_possibilities_of_1:              ; Row checks
    cmp ecx, 0
    jne skip_row0
    call possibility1
skip_row0:

    cmp ecx, 3
    jne skip_row3
    call possibility1
skip_row3:

    cmp ecx, 6
    jne skip_row6
    call possibility1
skip_row6:


check_possibilities_of_2:              ; Column checks
    cmp ecx, 0
    jne skip_col0
    call possibility2
skip_col0:

    cmp ecx, 1
    jne skip_col1
    call possibility2
skip_col1:

    cmp ecx, 2
    jne skip_col2
    call possibility2
skip_col2:


check_possibilities_of_3:              ; Diagonal 1
    cmp ecx, 0
    jne skip_diag1
    call possibility3
skip_diag1:


check_possibilities_of_4:              ; Diagonal 2
    cmp ecx, 2
    jne skip_diag2
    call possibility4
skip_diag2:

    jmp end_block


possibility1:                         ; check row (ecx = 0,3,6)
    mov row, ecx
    mov edx, 0                        ; reset sum

    mov ebx, ecx                      ; end index = start index + 3
    add ebx, 3

row_loop:
    mov eax,row          ; load grid[row]
    imul eax, 4
    mov eax, [esi + eax]                   ; if empty, skip adding
    cmp eax,1
    je skip_return_possibility1                               ;
    ret
    skip_return_possibility1:
    inc row
    cmp row, ebx
    jl row_loop                       ; loop until row end index

    mov eax,1
    mov player_win,eax
    ret

possibility2:                         ; col check (ecx = 0,1,2)
    mov col, ecx
    mov edx, 0

    mov ebx, ecx
    add ebx, 9                        ; col end index (ecx+6 effectively, step 3)

col_loop:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, 1
    je skip_return_possibility2                               ; if sum != 2, return to block 
    ret
    skip_return_possibility2:
    
    add col, 3                        ; move down one row
    cmp col, ebx
    jl col_loop

    mov eax,1
    mov player_win,eax
    ret

possibility3:
    mov row, 0
    mov edx, 0

diag1_loop:
    mov eax,row
    mov eax, [esi + eax*4]
    cmp eax, 1
    je skip_return_possibility3                               ; if sum != 2, return to block 
    ret
    skip_return_possibility3:
    add row, 4                        ; step through 0,4,8
    cmp row, 12
    jl diag1_loop

    mov eax,1
    mov player_win,eax
    ret

possibility4:
    mov row, 2
    mov edx, 0

diag2_loop:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, 1
    je skip_return_possibility4                               ; if sum != 2, return to block 
    ret
    skip_return_possibility4:
    add row, 2                        ; step 2 ? goes 2,4,6
    cmp row, 6
    jle diag2_loop                    

    mov eax,1
    mov player_win,eax
    ret

end_block:
    inc ecx
    cmp ecx, 9
    jl win_move        

ret
check_player_win ENDP

;----------------check player win end----------------







; ------------possibility --------------


;mov esi, OFFSET grid
;mov ebx, 0
;mov ecx, 9
;possibility_right_next :               ; loop 9 cells
;            mov eax,[esi + ebx]     
;            cmp eax,0               
;            jne end_loop    ; if not 0, skip
;            mov temp,ebx
;            add temp,4
;            mov eax,temp
;            cmp eax,12      ; if eax=12, skip
;            je turn1
;            mov eax, [esi + ebx + 4]
;            cmp eax,-1
;            jne end_loop        ; if not -1, skip
;            mov dword ptr [esi+ebx+4],0     ; place 0 in that cell
;            jmp  print_loop
;            end_loop:
;            add ebx,4
;            loop possibility
;            ret
;;---------------------------------------
        





;-----------------computer calculated move------------------



calculated_probability PROC

    mov ecx,0
    mov esi, OFFSET grid
    
    possibility:
            mov eax,ecx
            imul eax,4
            mov eax,[esi + eax]
            cmp eax,0
            jne next_cell

            mov eax, ecx
            mov ebx, 3
            xor edx, edx
            div ebx       ; eax = row, edx = col
            mov row, eax
            mov col, edx

            cmp col,0
            jne skip_add_to_right
                mov eax, col
                mov temp, eax 
                call add_to_right

            skip_add_to_right:
            cmp col,2
            jne skip_add_to_left
                mov eax, col
                mov temp, eax 
                call add_to_left

            skip_add_to_left:
            cmp row,0
            jne skip_add_to_bottom
                mov eax, row
                mov temp, eax
                call add_to_bottom

            skip_add_to_bottom:
            cmp row,2
            jne skip_add_to_top
                mov eax, row
                mov temp, eax
                call add_to_top

            skip_add_to_top:
            cmp col,0
            jne skip_add_to_diagonal1
            cmp row,0
            jne skip_add_to_diagonal1
                mov eax, row
                mov temp, eax
                call add_to_diagonal1
            
            skip_add_to_diagonal1:
            cmp row,0
            jne next_cell
            cmp col,2
            jne skip_add_to_diagonal2
                mov eax, row
                mov temp,eax 
                call add_to_diagonal2

            skip_add_to_diagonal2:
            jmp next_cell

add_to_right:
        mov eax,temp
   right_loop:
        inc eax
        cmp eax,2
        ja right_done


        mov ebx,row
        imul ebx,3
        add ebx,eax
        imul ebx,4
        mov edx,[esi + ebx]         ; check right neighbor
        cmp edx,-1
        jne right_loop

        mov dword ptr [esi + ebx],0
        mov eax,1
        mov computer_played,eax
        ret

right_done:
        mov eax,0
        ret


add_to_left:
    mov eax, temp
left_loop:
    dec eax
    jl left_done
    
    
    mov ebx, row
    imul ebx, 3
    add ebx, eax
    imul ebx, 4
    mov edx, [esi + ebx]
    cmp edx, -1
    jne left_loop


    mov dword ptr [esi + ebx], 0
    mov eax,1
    mov computer_played,eax
    ret


left_done:
mov eax,0
ret


add_to_bottom:
    mov eax, temp
bottom_loop:
    inc eax
    cmp eax, 2
    ja bottom_done
    
    
    mov ebx, eax
    imul ebx, 3
    add ebx, col
    imul ebx, 4
    mov edx, [esi + ebx]
    cmp edx, -1
    jne bottom_loop
    
    
    mov dword ptr [esi + ebx], 0
    mov eax,1
    mov computer_played,eax
    ret


bottom_done:
mov eax,0
ret

add_to_top:
    mov eax, temp
top_loop:
    dec eax
    jl top_done
            
    
    mov ebx, eax
    imul ebx, 3
    add ebx, col
    imul ebx, 4
    mov edx, [esi + ebx]
    cmp edx, -1
    jne top_loop
    
    
    mov dword ptr [esi + ebx], 0
    mov eax,1
    mov computer_played,eax
    ret


top_done:
    mov eax,0
    ret


add_to_diagonal1:
    mov eax, temp
d1_loop:
    inc eax
    cmp eax, 2
    ja d1_done
    
    
    ; target (eax, eax)
    mov ebx, eax
    imul ebx, 3
    add ebx, eax
    imul ebx, 4
    mov edx, [esi + ebx]
    cmp edx, -1
    jne d1_loop
    
    
    mov dword ptr [esi + ebx], 0
    mov eax,1
    mov computer_played,eax
    ret


d1_done:
    mov eax,0
    ret


add_to_diagonal2:
    mov eax, temp
d2_loop:
    inc eax
    cmp eax, 2
    ja d2_done
    
    
    mov ebx, 2
    sub ebx, eax ; target_col = 2 - eax
    mov edx, eax
    imul edx, 3
    add edx, ebx
    imul edx, 4
    mov ecx, [esi + edx]
    cmp ecx, -1
    jne d2_loop
    
    
    mov dword ptr [esi + edx], 0
    mov eax,1
    mov computer_played,eax
    ret


d2_done:
    mov eax,0
    ret

next_cell:
inc ecx
cmp ecx,9
jl possibility
mov eax,0
mov computer_played,eax
ret


calculated_probability ENDP


;--------------computer's calculated move end------------------






; ------------block human's win--------------

block_human_win PROC

mov ecx, 0
block:
    mov esi, OFFSET grid    
    mov ebx, 0
    mov edx,0

check_possibilities_of_1:              ; Row checks
    cmp ecx, 0
    jne skip_row0
    call possibility1
skip_row0:

    cmp ecx, 3
    jne skip_row3
    call possibility1
skip_row3:

    cmp ecx, 6
    jne skip_row6
    call possibility1
skip_row6:


check_possibilities_of_2:              ; Column checks
    cmp ecx, 0
    jne skip_col0
    call possibility2
skip_col0:

    cmp ecx, 1
    jne skip_col1
    call possibility2
skip_col1:

    cmp ecx, 2
    jne skip_col2
    call possibility2
skip_col2:


check_possibilities_of_3:              ; Diagonal 1
    cmp ecx, 0
    jne skip_diag1
    call possibility3
skip_diag1:


check_possibilities_of_4:              ; Diagonal 2
    cmp ecx, 2
    jne skip_diag2
    call possibility4
skip_diag2:

    jmp end_block


possibility1:                         ; check row (ecx = 0,3,6)
    mov row, ecx
    mov edx, 0                        ; reset sum

    mov ebx, ecx                      ; end index = start index + 3
    add ebx, 3

row_loop:
    mov eax,row          ; load grid[row]
    imul eax, 4
    mov eax, [esi + eax]
    cmp eax, -1
    je skip_add_row                   ; if empty, skip adding
    add edx, eax
skip_add_row:                         ; skip adding if empty
    inc row
    cmp row, ebx
    jl row_loop                       ; loop until row end index

    cmp edx, 2
    je skip_return_possibility                               ; if sum != 2, return to block 
    ret
    skip_return_possibility:

    mov row, ecx                      ; reset row to start index
check_empty_row:
    mov eax, row
    imul eax, 4
    mov eax, [esi + eax]
    cmp eax, -1
    je place_zero_row                 ; found empty
    inc row
    cmp row, ebx
    jl check_empty_row
    jmp end_block

place_zero_row:                       ; found empty cell
    mov eax, row
    imul eax, 4
    mov dword ptr [esi + eax], 0    ; place zero in empty cell
    mov eax,1
    mov computer_played,eax
    ret

possibility2:                         ; col check (ecx = 0,1,2)
    mov col, ecx
    mov edx, 0

    mov ebx, ecx
    add ebx, 9                        ; col end index (ecx+6 effectively, step 3)

col_loop:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, -1
    je skip_add_col
    add edx, eax
skip_add_col:
    add col, 3                        ; move down one row
    cmp col, ebx
    jl col_loop

    cmp edx, 2
    je skip_return_possibility2                               ; if sum != 2, return to block 
    ret
    skip_return_possibility2:

    mov col, ecx
check_empty_col:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_col
    add col, 3
    cmp col, ebx
    jl check_empty_col
    jmp end_block

place_zero_col:
    mov eax, col
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

possibility3:
    mov row, 0
    mov edx, 0

diag1_loop:
    mov eax,row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je skip_add_diag1
    add edx, eax
skip_add_diag1:
    add row, 4                        ; step through 0,4,8
    cmp row, 12
    jl diag1_loop

    cmp edx, 2
    je skip_return_possibility3                               ; if sum != 2, return to block 
    ret
    skip_return_possibility3:

    mov row, 0
check_empty_diag1:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_diag1
    add row, 4
    cmp row, 12
    jl check_empty_diag1
    jmp end_block

place_zero_diag1:
    mov eax, row
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

possibility4:
    mov row, 2
    mov edx, 0

diag2_loop:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je skip_add_diag2
    add edx, eax
skip_add_diag2:
    add row, 2                        ; step 2 ? goes 2,4,6
    cmp row, 6
    jle diag2_loop                    

    cmp edx, 2
    je skip_return_possibility4                               ; if sum != 2, return to block 
    ret
    skip_return_possibility4:

    mov row, 2
check_empty_diag2:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_diag2
    add row, 2
    cmp row, 6
    jle check_empty_diag2
    jmp end_block

place_zero_diag2:
    mov eax, row
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

end_block:
    inc ecx
    cmp ecx, 9
    jl block
    mov eax,0
    mov computer_played,eax
    ret 

block_human_win ENDP


;--------------block human's win end------------------





;-------------computer's win move--------------

computer_win_move PROC

mov ecx, 0
win_move:
    mov esi, OFFSET grid
    mov ebx, 0
    mov edx,0

check_possibilities_of_1:              ; Row checks
    cmp ecx, 0
    jne skip_row0
    call possibility1
skip_row0:

    cmp ecx, 3
    jne skip_row3
    call possibility1
skip_row3:

    cmp ecx, 6
    jne skip_row6
    call possibility1
skip_row6:


check_possibilities_of_2:              ; Column checks
    cmp ecx, 0
    jne skip_col0
    call possibility2
skip_col0:

    cmp ecx, 1
    jne skip_col1
    call possibility2
skip_col1:

    cmp ecx, 2
    jne skip_col2
    call possibility2
skip_col2:


check_possibilities_of_3:              ; Diagonal 1
    cmp ecx, 0
    jne skip_diag1
    call possibility3
skip_diag1:


check_possibilities_of_4:              ; Diagonal 2
    cmp ecx, 2
    jne skip_diag2
    call possibility4
skip_diag2:

    jmp end_block


possibility1:                         ; check row (ecx = 0,3,6)
    mov row, ecx
    mov edx, 0                        ; reset sum

    mov ebx, ecx                      ; end index = start index + 3
    add ebx, 3

row_loop:
    mov eax,row          ; load grid[row]
    imul eax, 4
    mov eax, [esi + eax]                   ; if empty, skip adding
    cmp eax,1
    je rat
    add edx, eax
    inc row
    cmp row, ebx
    jl row_loop                       ; loop until row end index

    cmp edx,-1
    je skip_return_possibility1                               ; if sum != 2, return to block 
    rat:
    ret
    skip_return_possibility1:

    mov row, ecx                      ; reset row to start index
check_empty_row:
    mov eax, row
    imul eax, 4
    mov eax, [esi + eax]
    cmp eax, -1
    je place_zero_row                 ; found empty
    inc row
    cmp row, ebx
    jl check_empty_row
    jmp end_block

place_zero_row:                       ; found empty cell
    mov eax, row
    imul eax, 4
    mov dword ptr [esi + eax], 0    ; place zero in empty cell
    mov eax,1
    mov computer_played,eax
    ret

possibility2:                         ; col check (ecx = 0,1,2)
    mov col, ecx
    mov edx, 0

    mov ebx, ecx
    add ebx, 9                        ; col end index (ecx+6 effectively, step 3)

col_loop:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, 1
    je rat_col
    add edx, eax
    add col, 3                        ; move down one row
    cmp col, ebx
    jl col_loop

    cmp edx, -1
    je skip_return_possibility2                               ; if sum != 2, return to block 
    rat_col:
    ret
    skip_return_possibility2:

    mov col, ecx
check_empty_col:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_col
    add col, 3
    cmp col, ebx
    jl check_empty_col
    jmp end_block

place_zero_col:
    mov eax, col
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

possibility3:
    mov row, 0
    mov edx, 0

diag1_loop:
    mov eax,row
    mov eax, [esi + eax*4]
    cmp eax, 1
    je rat_d1
    add edx, eax
    add row, 4                        ; step through 0,4,8
    cmp row, 12
    jl diag1_loop

    cmp edx, -1
    je skip_return_possibility3                               ; if sum != 2, return to block 
    rat_d1:
    ret
    skip_return_possibility3:

    mov row, 0
check_empty_diag1:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_diag1
    add row, 4
    cmp row, 12
    jl check_empty_diag1
    jmp end_block

place_zero_diag1:
    mov eax, row
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

possibility4:
    mov row, 2
    mov edx, 0

diag2_loop:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, 1
    je rat_d2
    add edx, eax
    add row, 2                        ; step 2 ? goes 2,4,6
    cmp row, 6
    jle diag2_loop                    

    cmp edx, -1
    je skip_return_possibility4                               ; if sum != 2, return to block 
    rat_d2:
    ret
    skip_return_possibility4:

    mov row, 2
check_empty_diag2:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_diag2
    add row, 2
    cmp row, 6
    jle check_empty_diag2
    jmp end_block

place_zero_diag2:
    mov eax, row
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

end_block:
    inc ecx
    cmp ecx, 9
    jl win_move                                                 

ret
computer_win_move ENDP

;---------------computer's win move end------------------







END main



