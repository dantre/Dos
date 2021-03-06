;===============================================================
Can_Make_Move proc
	push cx dx

	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne fail_make_move
	
	mov ax, cx	
	call Get_Board_Value_By_AX_to_AL
	cmp al, 1
	je Is_pawn_move_check
	cmp al, 3
	je Is_king_move_check
	jmp fail_make_move	
	
	Is_king_move_check:
		call Can_King_Move_like_This_Cx_Dx
		cmp ax, 0
		je fail_make_move
		jmp success_make_move
	
	Is_pawn_move_check:
		call Can_Pawn_Move_like_This_Cx_Dx
		cmp ax, 0
		je fail_make_move		
	
	success_make_move:
		mov ax, 1
		pop dx cx
		ret
		
	fail_make_move:
		mov ax, 0
		pop dx cx
		ret
Can_Make_Move endp
;===============================================================
; from cx
Remove_Pawn_From_Board proc
	push bx cx dx
	mov ax, cx
	mov dl, 0
	call Set_Board_Value_To_AX_From_DL
	pop dx cx bx
	ret
Remove_Pawn_From_Board endp
;===============================================================
Remove_Pawned_Pawn_From_Board proc
	push cx dx
	call Find_Middle_Cell	
	mov dl, 0
	call Set_Board_Value_To_AX_From_DL
	pop dx cx
	ret
Remove_Pawned_Pawn_From_Board endp
;===============================================================
;set BOARD[ah*8+al]
Set_Board_Value_To_AX_From_DL proc
	dec ah
	dec al
	mov bx, ax
	mov ax, 7
	sub al, bl
	shl ax, 3
	mov bl, 0
	xchg bl, bh	
	add ax, bx
	mov bp, ax
	mov byte ptr BOARD[bp], dl	
	ret	
Set_Board_Value_To_AX_From_DL endp
;===============================================================
;bl-VALUE
Set_New_Pawn_On_Board proc
	push cx dx
	mov ax, dx
	mov dl, bl
	call Set_Board_Value_To_AX_From_DL
	pop dx cx
	ret
Set_New_Pawn_On_Board endp
;===============================================================
;bl-colour
Draw_New_Pawn_On_Screen proc
	push cx dx
	push bx
	mov cx, dx
	dec ch 
	dec cl
	xchg cl, ch
	mov bl, 48
	xor dx, dx
	mov dl, ch
	mov ch, 0
	mov ax, cx
	mul bl
	mov cx, ax
	mov ax, 7
	sub ax, dx
	mul bl
	mov dx, ax
	
	mov ax, 2
	int 33h
	pop bx
	mov al, bl
	call Change_Colour
	cmp Last_Was_King, 1
	je draw_king_mm
		call Draw_Pawn
		jmp draw_king_fin
	draw_king_mm:
		call Draw_King
	draw_king_fin:	
 	mov ax, 1 
 	int 33h

	pop dx cx
	ret
Draw_New_Pawn_On_Screen endp
;===============================================================
;bl-colour
Draw_New_King_On_Screen proc
	push cx dx
	push bx
	mov cx, dx
	dec ch 
	dec cl
	xchg cl, ch
	mov bl, 48
	xor dx, dx
	mov dl, ch
	mov ch, 0
	mov ax, cx
	mul bl
	mov cx, ax
	mov ax, 7
	sub ax, dx
	mul bl
	mov dx, ax
	
	mov ax, 2
	int 33h
	pop bx
	mov al, bl
	call Change_Colour
	call Draw_King	
 	mov ax, 1 
 	int 33h

	pop dx cx
	ret
Draw_New_King_On_Screen endp
;===============================================================
Try_Make_Move proc
	push cx dx
	call Repaint_Cell	
	call Remove_Pawn_From_Board	
	
	cmp dl, 8
	je King_Moves
	cmp Last_Was_King, 1
	je King_Moves
	
	mov bl, 1
	call Set_New_Pawn_On_Board
	mov bl, PAWN_WHITE
	call Draw_New_Pawn_On_Screen
	
	King_Moves_Back:
	pop dx cx
	SEND_COMMAND:
		call Reverse_Cx_Dx
		mov al, 'S'
		call Serial_AL_To_Buf
		mov al, ch
		add al, '0'
		call Serial_AL_To_Buf
		mov al, cl
		add al, '0'
		call Serial_AL_To_Buf
		mov al, dh
		add al, '0'
		call Serial_AL_To_Buf
		mov al, dl
		add al, '0'
		call Serial_AL_To_Buf
		mov al, 'E'
		call Serial_AL_To_Buf				
		call Serial_Send_All	
	
	ret
	
	King_Moves:
		mov Last_Was_King, 1
		mov bl, 3
		call Set_New_Pawn_On_Board
		mov bl, PAWN_WHITE
		call Draw_New_Pawn_On_Screen
		jmp King_Moves_Back
		
Try_Make_Move endp	
;===============================================================
Can_Pawn_Move_like_This_Cx_Dx proc
	push cx dx
	add dx, 3030h	
	sub dh, ch
	sub dl, cl
	cmp dl, 30h
	jl pawn_cant
	cmp dl, 31h
	jg pawn_cant
	cmp dh, 2fh
	jl pawn_cant
	cmp dh, 31h
	jg pawn_cant

	pawn_can:
		mov ax, 1
		pop dx cx
		ret
	pawn_cant:
		mov ax,0
		pop dx cx
		ret	
Can_Pawn_Move_like_This_Cx_Dx endp
;===============================================================
Can_King_Move_like_This_Cx_Dx proc
	push cx dx	
	cmp cx, dx
	je king_cant		
	call King_Find_Move_Offset_TO_BX	
	
	king_check_all_directions_loop:
		add ch, bh
		add cl, bl
		mov ax, cx		
		call Get_Board_Value_By_AX_to_AL		
		cmp al, 0
		jne king_cant
		cmp cx, dx
		jne king_check_all_directions_loop
	jmp king_can			

	king_can:
		mov ax, 1
		pop dx cx
		ret
	king_cant:
		mov ax,0
		pop dx cx
		ret			
	
Can_King_Move_like_This_Cx_Dx endp
;===============================================================
King_Find_Move_Offset_TO_BX proc
	push cx dx
	cmp ch, dh
	je bh_0
	jl bh_plus_1
	jg bh_min_1	
	bh_back:
	
	cmp cl, dl
	je bl_0
	jl bl_plus_1
	jg bl_min_1	
	bl_back:	
	
	pop dx cx
	ret
	
	bh_0:
		mov bh, 0
		jmp bh_back
	bh_plus_1:
		mov bh, 1
		jmp bh_back
	bh_min_1:
		mov bh, -1
		jmp bh_back
		
	bl_0:
		mov bl, 0
		jmp bl_back
	bl_plus_1:
		mov bl, 1
		jmp bl_back
	bl_min_1:
		mov bl, -1
		jmp bl_back
King_Find_Move_Offset_TO_BX endp
;===============================================================
Can_Pawn_Cut_like_This_Cx_Dx proc
	push cx dx
	add dx, 3030h
	sub dx, cx
	mov ax, dx
	mov bx, cx
	cmp ax, 3032h
	je _good_cut_1
	cmp ax, 2e30h
	je _good_cut_2
	cmp ax, 3230h
	je _good_cut_3

	
	bad_cut:
		mov ax, 0
		pop dx cx
		ret
	_good_cut_1:
		mov ax, 1
		add bl, 01h
		pop dx cx	
		ret
	_good_cut_2:
		mov ax, 1
		sub bh, 01
		pop dx cx	
		ret
	_good_cut_3:
		mov ax, 1
		add bh, 01
		pop dx cx	
		ret
Can_Pawn_Cut_like_This_Cx_Dx endp
;===============================================================
Can_Cut_Pawn proc
	push cx dx

	mov ax, cx
	;your color
	call Get_Board_Value_By_AX_to_AL
	cmp al, 1
	jne fail_cut
	
	; enemy pawn
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne fail_cut

	call Can_Pawn_Cut_like_This_Cx_Dx
	cmp ax, 1
	jne fail_cut

	mov ax, bx
	mov Last_Pawned_Cell, bx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 2
	je good_cut

	cmp al, 4
	je good_cut
	
	jmp fail_cut
	good_cut:		
		mov ax, 1
		pop dx cx
		ret
	fail_cut:		
		mov ax, 0
		pop dx cx
		ret	
Can_Cut_Pawn endp
;===============================================================
Can_Cut_King_Position_To_Bx proc
	push cx dx
	
	mov ax, cx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 3
	jne king_cant_cut
	
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne king_cant_cut
	
	mov was_enemy_on_way, 0
	mov enemy_position, 0
	
	cmp cx, dx
	je king_cant_cut	
	call King_Find_Move_Offset_TO_BX	
	
	king_check_all_directions_loop_1:
		add ch, bh
		add cl, bl
		mov ax, cx		
		call Get_Board_Value_By_AX_to_AL		
		cmp al, 0
		je continue_checking
		cmp al, 2
		je incing_way
		cmp al, 4
		je incing_way
		jmp king_cant_cut
		continue_checking:
		cmp cx, dx
		jne king_check_all_directions_loop_1
	
	cmp was_enemy_on_way, 1
	jne king_cant_cut

	king_can_cut:
		mov ax, 1
		mov bx, enemy_position
		pop dx cx
		ret
		
	king_cant_cut:
		mov ax,0
		pop dx cx
		ret			
		
	incing_way:
		inc was_enemy_on_way
		mov enemy_position, cx
		jmp continue_checking
		
		
	was_enemy_on_way db 0
	enemy_position dw 0
Can_Cut_King_Position_To_Bx endp
;===============================================================
Enemy_Can_Cut_King_Position_To_Bx proc	
	push cx dx	
	
	mov was_enemy_on_way_2, 0
	mov enemy_position_2, 0
	
	cmp cx, dx
	je king_cant_cut_2		
	call King_Find_Move_Offset_TO_BX	
	
	king_check_all_directions_loop_2:
		add ch, bh
		add cl, bl
		mov ax, cx		
		call Get_Board_Value_By_AX_to_AL		
		cmp al, 0
		je continue_checking_2
		cmp al, 1
		je incing_way_2
		cmp al, 3
		je incing_way_2
		jmp king_cant_cut_2
		continue_checking_2:
		cmp cx, dx
		jne king_check_all_directions_loop_2
	
	cmp was_enemy_on_way_2, 1
	jne king_cant_cut_2

	king_can_cut_2:
		mov ax, 1
		mov bx, enemy_position_2
		pop dx cx
		ret
		
	king_cant_cut_2:
		mov ax,0
		pop dx cx
		ret			
		
	incing_way_2:
		inc was_enemy_on_way_2
		mov enemy_position_2, cx
		jmp continue_checking_2
		
		
	was_enemy_on_way_2 db 0
	enemy_position_2 dw 0
Enemy_Can_Cut_King_Position_To_Bx endp
;===============================================================
Try_Cut_Pawn proc
	push dx
	call Repaint_Cell	
	call Repaint_Pawned_Cell
	call Remove_Pawn_From_Board
	call Remove_Pawned_Pawn_From_Board
	
	mov bl, 1
	call Set_New_Pawn_On_Board
	mov bl, PAWN_WHITE
	call Draw_New_Pawn_On_Screen
	pop dx
	ret
Try_Cut_Pawn endp
;===============================================================
Try_Cut_Pawn_Became_King proc
	push dx
	call Repaint_Cell	
	call Repaint_Pawned_Cell
	call Remove_Pawn_From_Board
	call Remove_Pawned_Pawn_From_Board
	
	mov bl, 3
	call Set_New_Pawn_On_Board
	mov bl, PAWN_WHITE
	call Draw_New_King_On_Screen
	pop dx
	ret
Try_Cut_Pawn_Became_King endp
;===============================================================

Try_Cut_King proc
	push cx dx
		call Repaint_Cell	
		call Remove_Pawn_From_Board
		push cx
		mov cx, bx
		call Repaint_Cell
		call Remove_Pawn_From_Board
		pop cx
		
		mov bl, 3
		call Set_New_Pawn_On_Board
		mov bl, PAWN_WHITE
		call Draw_New_King_On_Screen
		
	pop dx cx
	ret
Try_Cut_King endp
;===============================================================
Last_Pawned_Cell dw 0
;===============================================================
; cx, dx
; return ax
Find_Middle_Cell proc
	push cx dx
	add dx, 3030h
	sub dx, cx
	mov ax, cx

	cmp dx, 3032h
	je find_1
	cmp dx, 2e30h
	je find_2
	cmp dx, 3230h
	je find_3
	cmp dx, 302eh
	je find_4
	mov ax, 0ffffh
	pop dx cx
	ret


	find_1:
		inc al
		jmp find_mid_cell_ret
	find_4:
		dec al
		jmp find_mid_cell_ret
	find_2:
		dec ah
		jmp find_mid_cell_ret
	find_3:
		inc ah
		jmp find_mid_cell_ret

	find_mid_cell_ret:
	pop dx cx
	ret
Find_Middle_Cell endp
;===============================================================	
Check_Another_Possible_Cut proc
	push cx dx

	mov cx, dx
	add dl, 2
	call Check_For_Cut
	cmp ax, 1
	je possible_cut
	sub dl, 2

	add dh, 2
	call Check_For_Cut
	cmp ax, 1
	je possible_cut

	sub dh, 4
	call Check_For_Cut
	cmp ax, 1
	je possible_cut

	not_possible_cut:
		mov ax, 0
		pop dx cx
		ret
		
	possible_cut:
		mov ax, 1
		pop dx cx
		ret
Check_Another_Possible_Cut endp
;===============================================================
Check_Another_Possible_Cut_King proc
	push cx dx
	mov cx, dx
	mov fucking_index, 0
	fucking_index_loop:
		mov ax, fucking_index
		mov bl, 8
		div bl
		inc ah
		inc al
		mov dx, ax		
		call Can_Cut_King_Position_To_Bx
		cmp ax, 1
		je find_another_king_cut		
		inc fucking_index
		cmp fucking_index, 64
		jne fucking_index_loop
	
	cant_find_king_cut:
		mov ax, 0	
		pop dx cx
		ret
	find_another_king_cut:
		mov ax, 1
		pop dx cx
		ret
	fucking_index dw 0
Check_Another_Possible_Cut_King endp
;===============================================================
Check_For_Cut proc
	push cx dx
	
	call Find_Middle_Cell
	call Get_Board_Value_By_AX_to_AL
	cmp al, 2
	jne cant_cut

	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne cant_cut	

	can_cut:
		mov ax, 1
		pop dx cx
		ret
	cant_cut:
		mov ax, 0
		pop dx cx
		ret
Check_For_Cut endp
;===============================================================
AddMessage_Equal proc
	mov di, offset BufferString
	mov si, offset choose_msg2
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History
	call AddMessage_Input_Paper_Rock_Scissors


	ret	 	
	choose_msg2	   db '�������� ᮢ����.        '
	
AddMessage_Equal endp
;===============================================================
Check_Opponent_Choise  proc	
	cmp MY_CHOISE, 0ffh
	je not_input_choise

	cmp Opponent_Choise, 0ffh
	je not_input_choise_2

	mov bl, Opponent_Choise
	cmp bl, MY_CHOISE
	je _equal


		cmp MY_CHOISE, '1'
		jne check_2_3
		cmp Opponent_Choise, '2'
		je you_win
		jmp you_lose

	check_2_3:

		cmp MY_CHOISE, '2'
		jne check_3
		cmp Opponent_Choise, '3'
		je you_win
		jmp you_lose


	check_3:
		cmp MY_CHOISE, '3'
		jne some_error
		cmp Opponent_Choise, '1'
		je you_win
		jmp you_lose

	some_error:
		ret
		_equal:
			mov State, 1
			mov MY_CHOISE, 0ffh
			mov Opponent_Choise, 0ffh
			call AddMessage_Equal
			mov al, 'B'
			call Serial_AL_To_Buf	
			call Serial_Send_All
			ret

		you_win:
			mov MY_CHOISE, 0ffh
			mov Opponent_Choise, 0ffh
			call Win_Rock
			ret

		you_lose:	
			mov MY_CHOISE, 0ffh
			mov Opponent_Choise, 0ffh
			call Lose_Rock
			ret

		not_input_choise:
			call AddMessage_Input_Paper_Rock_Scissors
		not_input_choise_2:
			ret
Check_Opponent_Choise endp
;===============================================================
Win_Rock proc
	mov di, offset BufferString
	mov si, offset win_rock_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History


	mov di, offset BufferString
	mov si, offset win_rock_msg2
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	mov al, 'D'
	call Serial_AL_To_Buf
	call Serial_Send_All
	
	mov YOUR_COLOR, 1
	mov PAWN_BLACK, 0
	mov PAWN_WHITE, 7
	mov TURN, 1	
	mov ax, 2
	int 33h
	call Draw_Chessboard
	call Send_Sync_Impulse 
	call Draw_Pawns
	mov ax, 1
	int 33h
	call AddMessage_Your_Turn
	
	ret

	win_rock_msg db '������� 室� �먣࠭.     '
	win_rock_msg2 db '�� ��ࠥ� ���묨          '
Win_Rock endp
;===============================================================
Lose_Rock proc
	mov di, offset BufferString
	mov si, offset lost_rock_msg 
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	mov di, offset BufferString
	mov si, offset lost_rock_msg2
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	mov al, 'D'
	call Serial_AL_To_Buf
	call Serial_Send_All

	mov YOUR_COLOR, 2	
	mov PAWN_BLACK, 7
	mov PAWN_WHITE, 0

	mov ax, 2
	int 33h
	call Draw_Chessboard
	call Send_Sync_Impulse 
	call Draw_Pawns
	mov ax, 1
	int 33h
	;mov TURN, 2
	call AddMessage_Enemy_Turn
	
	ret
	lost_rock_msg db '������� 室� �ந�࠭.    '
	lost_rock_msg2 db '�� ��ࠥ� ��묨         '
Lose_Rock endp
;===============================================================
Get_Enemy_Colour proc
	cmp YOUR_COLOR, 1
	je mov_white
		mov bl, PAWN_WHITE
		ret
	mov_white:
		mov bl, PAWN_BLACK
	ret
Get_Enemy_Colour endp
;===============================================================
Make_Step_Cx_Dx proc
	
	push cx dx
	call Repaint_Cell	
	call Remove_Pawn_From_Board	
	cmp dl, 1
	je became_king_com
	mov bl, 2
	call Set_New_Pawn_On_Board
	mov bl, PAWN_BLACK
	call Draw_New_Pawn_On_Screen
	pop dx cx	
	ret
	
	became_king_com:
		mov bl, 4
		call Set_New_Pawn_On_Board
		mov bl, PAWN_BLACK
		call Draw_New_King_On_Screen
		pop dx cx	
		ret
Make_Step_Cx_Dx endp
;===============================================================
Reverse_Cx_Dx proc
	cmp YOUR_COLOR, 1
	jne $+1
	ret
	mov bx, 0909h
	sub bh, ch
	sub bl, cl
	mov cx, bx
	mov bx, 0909h
	sub bh, dh
	sub bl, dl
	mov dx, bx
	ret
Reverse_Cx_Dx endp
;===============================================================
Reverse_DX proc
	cmp YOUR_COLOR, 1
	jne $+1
	ret
	mov bx, 0909h
	sub bh, dh
	sub bl, dl
	mov dx, bx
	ret
Reverse_DX endp
;===============================================================
Check_Possible_King_Cut_CX proc
	push cx dx
	mov fucking_index_5, 0
	fucking_index_loop_5:
		mov ax, fucking_index_5
		mov bl, 8
		div bl
		inc ah
		inc al
		mov dx, ax		
		call Can_Cut_King_Position_To_Bx
		cmp ax, 1
		je find_another_king_cut_5		
		inc fucking_index_5
		cmp fucking_index_5, 64
		jne fucking_index_loop_5
	
	cant_find_king_cut_5:
		mov ax, 0	
		pop dx cx
		ret
	find_another_king_cut_5:
		mov ax, 1
		pop dx cx
		ret
	fucking_index_5 dw 0
Check_Possible_King_Cut_CX endp
;===============================================================
Check_Possible_Cut_CX proc
	push cx dx

	mov dx, cx
	add dl, 2
	call Check_For_Cut
	cmp ax, 1
	je possible_cut_1
	sub dl, 2

	add dh, 2
	call Check_For_Cut
	cmp ax, 1
	je possible_cut_1

	sub dh, 4
	call Check_For_Cut
	cmp ax, 1
	je possible_cut_1

	not_possible_cut_1:
		mov ax, 0
		pop dx cx
		ret
		
	possible_cut_1:
		mov ax, 1
		pop dx cx
		ret

Check_Possible_Cut_CX	endp
;===============================================================
RESET_BOARD proc
	mov si, offset INITIALIZE_BOARD
	mov di, offset BOARD
	mov cx, 64
	rep movsb	
	ret
RESET_BOARD endp
;===============================================================
CHANGE_PAWNS_COLOUR proc
	push bx
		mov bh, PAWN_BLACK
		mov bl, PAWN_WHITE
		mov PAWN_BLACK, bl
		mov PAWN_WHITE, bh
	pop bx
	ret
CHANGE_PAWNS_COLOUR endp
;===============================================================
Check_Agree_For_New proc
	cmp Enemy_agree_new, 1
	jne agree_exit
	cmp you_agree_new, 1
	jne agree_exit
	
		call RESET_BOARD
		call CHANGE_PAWNS_COLOUR
		cmp YOUR_COLOR, 1
		je white_was
		not_white_was:
			mov YOUR_COLOR, 1
			mov TURN, 1
			jmp here
		white_was:
			mov YOUR_COLOR, 2
			;mov TURN, 2
		here:
			mov sync_exit, 0
			call Draw_Chessboard
			mov sync_exit, 0
			call Draw_Pawns			
			mov STATE, 4		
			mov Enemy_agree_new, 0	
			mov you_agree_new, 0
		
	agree_exit:
		ret
Check_Agree_For_New endp
;===============================================================
EXECUTE_DRAWN_AGREE proc
	cmp STATE, 4
	je $+3
	ret
	mov STATE, 6
	mov di, offset BufferString
	mov si, offset drawn_agree_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	
	mov di, offset BufferString
	mov si, offset again_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	
	ret	
 	drawn_agree_msg db '�����!                     '
	ret
EXECUTE_DRAWN_AGREE endp
;===============================================================
ExecuteCommand_In_Di_Size_CX proc
	mov cmd_size, cx
	mov Enemy_Was_King, 0
	mov Last_Was_King, 0
	push di
	sub30_loop:
		mov bl, [di]
		sub bl, 30h
		mov [di], bl
		inc di
		loop sub30_loop
	pop di
	
	mov ch, [di]
	mov cl, [di+1]
	mov dh, [di+2]
	mov dl, [di+3]
	call Reverse_Cx_Dx
	
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne not_can_command
	
	mov ax, cx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 2
	je enemy_moves_pawn
	
	cmp al, 4 
	je enemy_moves_pawn	
		
	not_can_command:
		; Send Serial can not _ do command
		mov TURN, 2
		call Copy_BOARD_TO_TEMP
		mov ax, 2
		int 33h
		call Draw_Chessboard
		call Draw_Pawns	
		mov ax, 1
		int 33h
		call Send_Wrong_Move
		call AddMessage_Enemy_Gives_wrong_move
		ret
		
			
	enemy_moves_pawn:
		call Can_Enemy_Do_Move_Command_Cx_Dx
		cmp ax, 1
		je can_move_command	
		
		call Can_King_Move_like_This_Cx_Dx
		cmp ax, 1
		je can_king_move_command		

		can_pawn_command:
			mov si, di
			add si, cmd_size	
			add di, 2
			mov dx, cx
			all_cuts_loop:					
				mov cx, dx
				mov dh, byte ptr[di]
				mov dl, byte ptr[di+1]
				call Reverse_DX
				push si di						
				
				call Can_Enemy_Do_Pawn_Command_Cx_dx
				cmp al, 1
				je Do_pawn_command				
				
				call Can_Enemy_Do_Pawn_Command_Cx_dx_With_King
				cmp al, 1
				je Do_pawn_command_With_King
				jmp not_can_command
				
				commands_execute_back:
				
				pop di si
				add di, 2
				cmp di, si
				jne all_cuts_loop
				
			can_pawn_finish:				
				mov TURN, 1
				call Send_Move_Accept
				call AddMessage_Your_Turn
				call Check_Enemy_Has_Moves
				cmp al, 1
				jne enemy_hasnot_moves
				
				call Check_You_Have_Moves
				cmp al, 1
				jne you_havenot_moves
				ret
				
		can_move_command:
			call Make_Step_Cx_Dx
			
			mov TURN, 1
			call Send_Move_Accept			
			call AddMessage_Your_Turn	
			
			call Check_Enemy_Has_Moves
			cmp al, 1
			jne enemy_hasnot_moves
				
			call Check_You_Have_Moves			
			cmp al, 1
			jne you_havenot_moves
			ret		
		
	can_king_move_command:
		call Repaint_Cell	
		call Remove_Pawn_From_Board			
		mov ax, cx
		mov bl, 4
		call Set_New_Pawn_On_Board
		mov bl, PAWN_BLACK
		call Draw_New_King_On_Screen		
	
		mov TURN, 1
		call Send_Move_Accept
		call AddMessage_Your_Turn
		
		call Check_Enemy_Has_Moves
		cmp al, 1
		jne enemy_hasnot_moves
				
		call Check_You_Have_Moves
		cmp al, 1
		jne you_havenot_moves
		ret
		
		Do_pawn_command:
			call Execute_Enemy_Pawn_Command
			jmp commands_execute_back
		
		Do_pawn_command_With_King:
			call Execute_Enemy_Pawn_Command_With_King
			jmp commands_execute_back
		
		
		you_havenot_moves:	
			call AddMessage_YOU_LOSE
			ret		
			
		enemy_hasnot_moves:
			call AddMessage_YOU_WIN
			ret
			
			
	cmd_size dw 0
	Enemy_Was_King db 0
ExecuteCommand_In_Di_Size_CX endp	
;===============================================================
;===============================================================
AddMessage_Input_Paper_Rock_Scissors proc
	mov di, offset BufferString
	mov si, offset choose_msg1
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	ret	 	
	choose_msg1	   db '������, �������, �㬠��?   '	
AddMessage_Input_Paper_Rock_Scissors endp


