; multi-segment executable file template.
 
 
new_line macro
    print 0ah      ;    
    print 0dh      ; Carriage return
endm   
 
print_str macro string 
    push dx
    push ax
    mov dx, offset string
    mov ah, 9
    int 21h 
    pop dx
    pop ax
endm    

data segment
    ; add your data here!   
    START_MSG   db  "START(Y/N):",'$'    
    ERR         db  "ERR",'$'
ends 

print macro char
    push dx 
    push ax
    mov dl, char
    mov ah, 2
    int 21h    
    pop ax     
    pop dx
endm


stack segment   
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here
    print_str START_MSG  
read_init:
    mov ah, 1
    int 21h
    cmp al, 'N'
    je stop   
    cmp al, 'Y'
    jne read_init  
    
    new_line
    ; �������� 3 hex ������, ������� ������� ��� bx
    mov bx, 0000h
    call hex_key     ;�������� 1�� ������� MSB   
    cmp al, 'N'
    je stop
    mov ah, 0
    add bx, ax 
    mov cl, 4       
    shl bx, cl       ; ���������� 
      
    
    call hex_key     ;�������� 2�� ������ MSB   
    mov ah, 0    
    cmp al, 'N'
    je stop
    add bx, ax 
    mov cl, 4       
    shl bx, cl       ; ���������� 
    
    
    call hex_key     ;�������� 3�� ������ MSB 
    mov ah, 0    
    cmp al, 'N'
    je stop  
    mov ah, 0
    add bx, ax 
    
    ; ����������� ����� ��� �� �������
    ; V = 4/4095 * AD  === X.YY => V = 4*1000/4095 * AD = XYYY �� �������� �����
    
    mov ax, bx
    mov cx, 4000
    mul cx          ; ax = ax * 4000
    
    mov cx, 4095
    div cx          ; ������� �� ��� ax = XXXXXY, ������ ��� ���� �� �������� 2 ���������
       
    ; � ������� ������������� ��� ����. ����� � = � * V - 1200, ���� � = 200 ��� V < 2.00 ������ 800
    
    cmp ax, 2000 
    jl case_1
    jmp case_2
    
case_1:
    mov cx, 2   
    mov bx, 0
    jmp compute
case_2:        
    mov cx, 8   
    mov bx, 12000
    
compute:
    mul cx  
    sub ax, bx
    
    cmp ax, 12000 
    jg error
            
     
    ; �������� �������
     
     new_line
     mov cx, 10000    ; ��������� xiliad��
     div cx         ; �������� �� �� 10000    
     mov bx, ax     ; �������� ������
     call print_digit     
     
     mov ax, dx
     mov dx, 0
     mov cx, 1000    ; ��������� �����������
     div cx         ; �������� �� �� 1000    
     mov bx, ax     ; �������� ������
     call print_digit    
    
     mov ax, dx
     mov dx, 0
     mov cx, 100    ; ��������� �������
     div cx         ; �������� �� �� 100    
     mov bx, ax     ; �������� ������
     call print_digit 
     
     mov ax, dx
     mov dx, 0
     mov cx, 10     ; ��������� �������
     div cx         ; �������� �� �� 100    
     mov bx, ax     ; �������� ������
     call print_digit   
     
     print ","
     
     mov bx, dx     ; �������� ������
     call print_digit    
     print " "
     print "o"
     print "C"     
     new_line 
     new_line
  
              
  
    
    jmp start
error:  
    new_line
    print_str ERR
     jmp start
    
    
    
      
  
stop:
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends     

hex_key proc near 
ignore:
    ; Read 
    mov ah, 1
    int 21h
    
    ; Check if exit key pressed
    cmp al, 'N'
    je exit
                       
    cmp al, 30h
    jl ignore
    
    cmp al, 39h
    jg addr_1
    
    ; Extract number
    sub al, 30h
    jmp exit
    
addr_1:
    cmp al, 'A'
    jl ignore
    cmp al, 'F'
    jg ignore
    
    sub al, 37h ; Extract number                          
exit: 
    ret
hex_key endp    


; ������� ���� ����������� dl ��� ���� ��� ������ ��� �� �������           
print_digit proc near
    cmp bl, 9
    jg addr1
    add bl, 30h
    jmp addr2
addr1:
    add bl, 37h
addr2:
    print bl
    ret 
print_digit endp


PRINT_DEC proc near    
     push dx 
     push cx
     push ax 
     

     mov ah, 00h
     mov al, bl
     mov cl, 100    ; ��������� �����������
     div cl         ; �������� �� �� 100
     mov dl, al     ; �������� ������
     call print_digit
     
     mov cl, 10     ; ��������� �������
     mov al, ah     ; ���������� ������� �� ���� �������
     mov ah, 0
     div cl 
     mov dl, al
     call print_digit
     
     mov dl, ah     ; �������� �������
     call print_digit

     pop ax
     pop cx
     pop dx  
     ret    
PRINT_DEC endp 

end start ; set entry point and stop the assembler.
