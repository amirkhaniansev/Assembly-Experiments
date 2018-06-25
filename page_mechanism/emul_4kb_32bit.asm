;4 kb 32-bit մեխանիզմի էմուլյատոր

.386p

;ստեկ սեգմենտ
_stack segment use16 stack 'stack'
	db 1024 dup(?)
_stack ends

;տվյալների սեգմենտ
_data segment use16 'data'
	linear dd ?
	physical dd ?
_data ends

;կոդ սեգմենտ
_code segment use16 'code'
	assume cs:_code,ds:_data,ss:_stack	
		main proc far
			
			;սկսում ենք ծրագիրը
			push ds
			xor ax,ax
			push ax
			mov ax,_data
			push ax
			pop ds
				
			;ստանանք PD հասցեն
			mov ebx,cr3
			and ebx,0fffff000h
			
			;ստանանք PDE հասցեն
			mov eax,linear
			shr eax,22
			shl eax,2
			add ebx,eax
			
			;ստանանք PT հասցեն
			mov ecx,dword ptr [ebx]
			and ecx,0fffff000h
			
			;ստանանք PTE հասցեն
			mov eax,linear
			shl eax,10
			shr eax,22
			shl eax,2
			add ecx,eax
			
			;ստանանք էջի հասցեն
			mov ebx,dword ptr [ecx]
			and ebx,0fffff000h
			
			;ստանանք ֆիզիկական հասցեն
			mov eax,linear
			and eax,0fffh
			add ebx,eax
			
			mov physical,ebx
			
			ret
		main endp
	_code ends
end main