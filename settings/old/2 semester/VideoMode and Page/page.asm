.model tiny
.386
.code
org 100h
start:			
	mov ax, 3
	int 10h	
	
	mov si, 080h
	lodsb
	mov cx, ax
	jcxz no_params			
	
	lodsb
	lodsb
	sub al, '0'
	mov y, al	
	lodsb 
	lodsb
	sub al, '0'
	mov z, al

	cmp y, 0
	je _0
	cmp y, 1
	je _0
	cmp y, 2
	je _2
	cmp y, 3
	je _2
	cmp y, 7
	je _7
	
	jmp _error
	ret
	
no_params:
	mov ah, 09h
	mov dx, offset no_msg
	int 21h
	ret	
;==============================================================	
_0:
	cmp z, 0
	jl _error
	cmp z, 7
	jg _error	
		
	mov ah, 0
	mov al, y
	int 10h	
	
	mov ah, 05h
	mov al, z
	int 10h
		
	mov ax, 0b800h
	mov es, ax
			
	xor ax, ax
	mov al, z
	mov dx, 0800h
	mul dx	
	add ax, 07cah
	mov di, ax
	
	mov dh, 14
	mov dl, y
	add dl, '0'
	mov es:[di], dx
	mov dl, z
	add dl, '0'
	mov es:[di+4], dx	
	ret	
;==============================================================	
_2:
	cmp z, 0
	jl _error
	cmp z, 3
	jg _error		
		
	mov ah, 0
	mov al, y
	int 10h	
	
	mov ah, 05h
	mov al, z
	int 10h
		
	mov ax, 0b800h
	mov es, ax
			
	xor ax, ax
	mov al, z
	mov dx, 01000h
	mul dx	
	add ax, 0F9Ah
	mov di, ax
	
	mov dh, 14
	mov dl, y
	add dl, '0'
	mov es:[di], dx
	mov dl, z
	add dl, '0'
	mov es:[di+4], dx	
	ret		
	
;==============================================================		
_7:
	cmp z, 0
	jl _error
	cmp z, 7
	jg _error	
	
	mov ah, 0
	mov al, y
	int 10h	
	
	mov ah, 05h
	mov al, z
	int 10h
		
	mov ax, 0b000h
	mov es, ax
			
	xor ax, ax
	mov al, z
	mov dx, 01000h
	mul dx	
	add ax, 0F9Ah
	mov di, ax
	
	mov dh, 14
	mov dl, y
	add dl, '0'
	mov es:[di], dx
	mov dl, z
	add dl, '0'
	mov es:[di+4], dx	
	ret		
;==============================================================	
_error:
	mov ah, 09h
	mov dx, offset error_msg
	int 21h
	ret
;==============================================================	
	
;==============================================================

error_msg db 'Error', 0Dh, 0Ah, 024h
no_msg db 'No params ', 0Dh, 0Ah, 024h

y db 0
z db 0

end start