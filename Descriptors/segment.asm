.386p

;տսեկ սեգմենտ
_stack segment use16 stack 'stack'
	db 1024 dup(?)
_stack ends

;տվյալների սեգմենտ
_data segment use16  'data'
	selector dw ?
	offset_p dd ?
	linear dd ?
	gdtr df ?
	sys_message db 'System descriptor$'
	ldt_message db 'Not LDT descriptor$'
_data ends

;code segment
_code segment use16 'code'
	assume ds:_data,cs:_code,ss:_stack
		main proc far
			
			;սկսում ենք ծրագրի աշխատանքը
			push ds
			xor ax,ax
			push ax
			mov ax,_data
			push ax
			pop ds
		
			;ստուգում ենք TI բիթը
			;եթե TI = 1 թռնում ենք LDT 
			xor eax,eax
			mov ax,selector
			test al,04h
			jnz LDT
			
			;ստանում ենք GDT սկզբի հասցեն
			sgdt fword ptr gdtr
			mov ebx,dword ptr [gdtr+2]
			
			;ստանում ենք GDT-ի տողի հասցեն սելեկտորով
			and al,11111000b
			add ebx,eax
			
			;ստուգում ենք արդյոք սիստեմ դեսկրիպտոր ա
			;եթե այո ապա վերջացնում ենք
			mov dl,byte ptr [ebx+5]
			and dl,00010000b
			cmp dl,0
			jne continue
			lea dx,sys_message
			mov ah,9
			int 21h
			jmp finish
			
			;եթե ոչ շարունակում ենք աշխատանքը
   continue:
			;ստանում ենք բազային հասցեն
			mov ch,byte ptr [ebx+7]
			mov cl,byte ptr [ebx+4]
			shl ecx,16
			mov cx,word ptr [ebx+2]
			
			;ստանում ենք վերջնական հասցեն
			add ecx,offset_p
			mov linear,ecx
			jmp finish
	       
		LDT:
			;եթե LDT ա ապա պետք գտնենք GDT-ի սկզբի հասցեն և LDT -ի select1-ը
			sgdt fword ptr gdtr
			mov ebx,dword ptr [gdtr+2]
			xor eax,eax
			
			sldt word ptr ax
			shl eax,3
			add ebx,eax
			
			;ebx ում ստացանք ենթադրյալ LDT -Ի հասցեն այժմ 
			;պետք է ստուգենք այն իրականում LDT ա թե ոչ
			
			mov dl,byte ptr [ebx+5]
			and dl,1fh
			test dl,02h
			je continue_ldt
			lea dx,ldt_message
			mov ah,9
			int 21h
			jmp finish
			
			;եթե LDT ա շարունակում ենք աշխատանքը
continue_ldt:		

			;ստանում ենք LDT-ի հասցեն
			mov ch,byte ptr [ebx+7]
			mov cl,byte ptr [ebx+4]
			shl ecx,16
			mov cx,word ptr [ebx+2]
			
			;ստանում ենք LDT-ի տողի հասցեն
			mov ebx,ecx
			mov ax,selector
			and al,0f8h
			add ebx,eax
			
			;ստանում ենք բազային հասցեն
			mov ch,byte ptr [ebx+7]
			mov cl,byte ptr [ebx+4]
			shl ecx,16
			mov cx,word ptr [ebx+2]
			
			;ստանում ենք վերջնական հասցեն
			add ebx,ecx
			mov linear,ebx
		
	finish:	
			mov eax,linear
			ret
		main endp
	_code ends
end main