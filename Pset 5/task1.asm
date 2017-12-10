; multi-segment executable file template.

print macro char
    mov dl, char
    mov ah, 2
    int 21h
endm

; ������ ������� ��� �����             
N EQU 10
            
data segment
    ; add your data here!
    ADDRN dw N dup(?)
ends

stack segment
ends
                             
code segment 
    
  
          
    
    
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here
    
    ; ������� ������ �� ������������� ��������
    mov cl, N
    cld                     ; df = 0
    mov di, OFFSET ADDRN       
    mov ax, 4
write_again:   
    stosw     
    inc ax                  ; ������� �������� ���������
    loop write_again   
    
    
    ; �������� ������� �� �����-32 bit ����������
    ; =>>>> 32 bit: dX:bX 
    
    
    mov cl, N
    cld                     ; df = 0
    mov di, OFFSET ADDRN   
    mov dx, 0               ; ������������ ���������� ����������� 
    mov bx, 0
load_again:   
    lodsw                   ; ������� ���� ����������  
    add bx, ax
    jnc no_overflow         ; �� ��� ������ �����������  
    inc dx                  ; dx <- dx + 1    
no_overflow:    
    loop load_again         
        
    ; �������� dl:dh:ah:al/�������� = ������ ���� dh:dl
    
    mov ax, bx              ; ���������� ���������
    mov bx, N               ; ���������
    div bx                  ; �������� ���������        
 
    mov dl, ah
    call print_hex_full
    mov dl, al
    call print_hex_full      
    
    
    mov cl, N
    cld                     ; df = 0
    mov di, OFFSET ADDRN   
    mov dx, 0FFFFh           ; dx = local min 
    mov bx, 0000H           ; bx = local max
load_again_2:   
    lodsw                   ; ������� ���� ����������   
local_min_calc:
    cmp ax, dx              ; current < local min ? 
    ja local_max_calc       ; local min <-- current
    mov dx, ax
local_max_calc:
    cmp ax, bx              ; current > local max ? 
    jb next
    mov bx, ax      
next:    
    loop load_again_2  
    
     ; ������� �� ������� ����� ��� ����� ��� ��������� �� ����������� ��� �����        

    print " "
    print "m"
    print ":" 
    push dx
    mov dl, dh
    call print_hex_full 
    pop dx 
    call print_hex_full
    
    print " "
    print "M"
    print ":"
    mov dl, bh               ; �������� 8MSB
    call print_hex_full         
    mov dl, bl               ; �������� 8LSB
    call print_hex_full     
    
    
    mov ax, 4c00h ; exit to operating system.
    int 21h

     
ends    

  print_hex proc near
    cmp dl, 9
    jg addr1
    add dl, 30h
    jmp addr2
addr1:
    add dl, 37h
addr2:
    print dl
    ret 
print_hex endp




print_hex_full  proc near
     push dx
     push ax
     push bx 
     push dx        ; ������ ��� ������������� 
      
     sar dx, 1
     sar dx, 1
     sar dx, 1
     sar dx, 1    
     and dl, 0fh 
     call print_hex   
     
     pop dx
     and dl, 0fh    ; ����� dl   
     call print_hex   
     pop bx
     pop ax
     pop dx
     ret  
print_hex_full    endp  

end start ; set entry point and stop the assembler.
              
