;4mb 32bit էմուլյատոր

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
			mov eax,cr3
			and eax,0fffff000h
			
			;ստանանք PDE հասցեն
			mov ebx,linear
			shr ebx,22
			shl ebx,2
			add eax,ebx
			
			;ստանանք էջի հասցեն
			mov ecx,dword ptr [eax]
			and ecx,0ffc00000h
			mov eax,linear
			and eax,3fffffh
			add ecx,eax
			
			mov physical,ecx
			
			ret
		main endp
	_code ends
end main