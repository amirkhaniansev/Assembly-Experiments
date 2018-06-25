.386p

;ստեկ սեգմենտ
_stack segment use16 stack 'stack
	db 1024 dup(?)
_stack ends

;տվյալների սեգմենտ
_data segment use16 'data'
	gdtr df ?
_data ends

;կոդ սեգմենտ
_code segment use16 'code'
	assume cs:_code,ds:_data,ss:_stack
		main proc far 
		
			;սկսում ենք ծրագիրը
			push ds
			xor ax,ax
			mov ax,_data
			push ax
			pop ds

			;ստանանք GTD - ի սկզբի հասցեն
			sgdt fword ptr gdtr
			mov eax,dword ptr [gdtr+2]
			
			;ստանանք GDT 5-րդ տողը
			add eax,40
			
			;ստուգենք
			mov bl,byte ptr [eax+5]
			and bl,1fh
			cmp bl,0bh
			jne second_case
			
			mov bl,byte ptr [eax+6]
			and bl,1100000b
			cmp bl,1100000b
			jne second_case
			
			mov bx,word ptr [eax]
			cmp ax,1248h
			jne second_case
			
			;փոփոխենք GDT 7-րդ դեսկրիպտորը
			mov eax,dword ptr [gdtr+2]
			add eax,56
			
			;դարձնենք այն SS descriptor DPL = 2,A = 0,base = 678251h,seg_len = 29725h
			mov byte ptr [eax+5],11010110b
			mov byte ptr [eax+6],11000010b
			mov word ptr [eax],9724h
			mov word ptr [eax+2],8251h
			mov byte ptr [eax+4],67h
			mov byte ptr [eax+7],0
			
			jmp finish
			
	second_case:
			;փոփոխենք GDT 12-երորդ descriptor-ը
			
			mov eax,dword ptr [eax+2]
			add eax,96
			
			;Դարձնենք այն 16bit callgate params = 22 selector = 15 offset = 4892657h
			mov word ptr [eax],2657h
			mov word ptr [eax+2],78h
			mov byte ptr [eax+4],22
			mov byte ptr [eax+5],10000100b
			mov word ptr [eax+6],489h
			
		finish:	ret 
		main endp
	_code ends
end main
