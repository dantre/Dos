.model tiny
.386
.code
org 100h
;==============================================================
Start:	
	mov ax, 10h
	int 10h	
	call Read_Paramets
	call Open_File	
	call Check_File			
	call Repair_Width_Height	
	call Read_Buffer_And_Paint
	call Exit_Proc
;==============================================================
Read_Paramets proc near
	mov si, 80h	
	mov di, offset Filename
	lodsb	
	cmp al, 0
	je _Input_Error
	dec al	
	xor cx, cx
	mov cl, al
	lodsb
_read_param_byte:
	lodsb
	stosb	
	loop _read_param_byte
	ret
_Input_Error:
	mov ah, 09h
	mov dx, offset InputError_str
	int 21h
	call Exit_Proc
Read_Paramets endp
;==============================================================	
Open_File proc near
	mov ax, 3d00h		
	mov dx, offset Filename
	int 21h	
	jc File_Error	
	mov File_Handle, ax
	ret	
File_Error:	
	mov ah, 09h
	mov dx, offset Error_str
	int 21h
	call Exit_Proc
Open_File endp
;==============================================================	
Check_File proc near		
	mov ax, 4200h
	mov bx, File_Handle
	xor cx, cx
	mov dx, 0Ah
	int 21h	

	mov ah, 3fh
	mov cx, 4
	mov dx, offset Starting_Address
	int 21h
	
	mov ax, 4200h	
	xor cx, cx
	mov dx, 12h
	int 21h

	mov ah, 3fh
	mov cx, 4
	mov dx, offset _Width
	int 21h	
	mov ah, 3fh		
	mov dx, offset _Height
	int 21h

	mov ah, 3fh
	mov cx, 2
	mov dx, offset Color_Number
	int 21h
	mov ah, 3fh
	mov dx, offset Color_Number
	int 21h

	mov dx, word ptr Color_Number
	cmp dx, 4
	jne _Wrong_Bytes_Per_Pixel	

	ret
_Wrong_Bytes_Per_Pixel:
	mov ah, 9
	mov dx, offset WrongPixels_Str
	int 21h
	call Exit_Proc
	ret
Check_File endp
;==============================================================	
Repair_Width_Height proc near
	mov ah, byte ptr _Width
	mov al, byte ptr [_Width+1]
	xchg ah, al	
	mov _Width, ax
	mov _X, ax

	mov ah, byte ptr _Height
	mov al, byte ptr [_Height+1]
	xchg ah, al
	mov _Height, ax
	mov _Y, ax	
	ret
Repair_Width_Height endp
;==============================================================
Read_Buffer_And_Paint proc near
	mov ax, 4200h
	mov bx, File_Handle
	xor cx, cx
	mov dx, word ptr Starting_Address
	int 21h	

_File_Read_Loop:
	mov ah, 3Fh
	mov bx, File_Handle
	mov cx, _Width
	mov dx, offset Buffer
	int 21h
	push ax
	call Paint_From_Buffer
	dec _Y 
	mov ax, _Width
	mov _X, ax

	pop ax
	cmp ax, _Width
	je _File_Read_Loop

	ret		
Read_Buffer_And_Paint endp
;==============================================================	
Paint_From_Buffer proc near
	mov si, offset Buffer
	mov cx, _X
	mov dx, _Y

	mov ax, 0CFFh
	mov bh, 0
_Paint_Loop:
	lodsb
	mov temp, al
	and al, 00001111b
	int 10h	
	dec cx
	mov al, temp
	shr al, 4
	int 10h
	loop _Paint_Loop

	ret
Paint_From_Buffer  endp
;==============================================================	
Exit_Proc proc near
	mov ax, 4c00h
	int 21h	
	ret
Exit_Proc endp
;==============================================================	
	_X dw 0		
	_Y dw 0
	temp db 0
	Error_str db 'File Error', 0dh, 0ah, 024h
	InputError_str db 'No params', 0dh, 0ah, 024h
	WrongPixels_Str db 'Wrong Bytes Per Pixels', 0dh, 0ah, 024h
	Param_Len db 0
	File_Handle dw 0
	_Width dw 0
	dw 0
	_Double_Width dw 0
	_Height dw 0
	dw 0
	Color_Number dw 0
	Starting_Address db 4 dup (0)
	Filename db 20h dup(0)
	Buffer db 300h dup(0)
	Buffer_End db 0
;==============================================================
end start