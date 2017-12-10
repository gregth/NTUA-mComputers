; multi-segment executable file template.
   

new_line macro
    print 0ah      ; Νέα γραμμή    
    print 0dh      ; Carriage return
endm   

print_str macro string 
    mov dx, offset string
    mov ah, 9
    int 21h
endm       

print macro char
    mov dl, char
    mov ah, 2
    int 21h
endm
   
   
data segment
    ; add your data here! 
    Z_MSG   db  "Z=",'$'    
    W_MSG   db  "W=",'$'
    ADD_MSG   db  "Z+W=",'$'
    SUB_MSG   db  "Z-W=",'$'   
    ERR       db "WRONG INPUT! TRY AGAIN!",'$'
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here 
    
    
main proc far    
     
    mov cl, 00h; 
loop: 
    call read_num  
    cmp al, 0dh     ; Check if enter was hit   
    je validation   
    mov ah, 00h
    push ax 
    inc cl          ; cl++  
    jmp loop
    
    
 
validation:         ; Checks if 4 valid numbers were enetered previously
    new_line
    cmp cl, 04h
    jz  print_results
           
           
print_error:
    new_line
    print_str ERR
    new_line
    jmp start

print_results:   
     print_str W_MSG
     pop bx         ;2ο ψηφίο του W 
     pop cx         ;1o ψηφίο του w
     mov dl, cl     
     call print_bin
     mov dl, bl
     call print_bin
     print " "    
     mov ch, 0ah    ; Πολλαπλασιασμός για δεκάδες  
     mov al, cl       
  
     mul ch         ; al = 10 * 1o ψηφίο του w
     add al, bl     ; al = αξία του w σε δυαδική μορφή
     
    
     
     pop bx         ; Ανάκτηση 2ου ψηφίου z
     pop cx         ; ’νάκτηση 1ου ψηφίου z
     push ax         ; Σώσιμο του w
     
     
     print_str Z_MSG
     mov dl, cl     
     call print_bin
     mov dl, bl
     call print_bin    
     mov ch, 0ah    ; Πολλαπλασιασμός για δεκάδες  
     mov al, cl
     mul ch         ; al = 10 * 1o ψηφίο του z
     add al, bl     ; al = z
     
    
   
     push ax
     new_line
     print_str ADD_MSG   
     ;O z βρίσκεται στο al ενώ ο w στον bl  
     pop ax
     pop bx
    
    
     mov dl, al
     add dl, bl     ; dl = al + bl    
     
     push ax
     push bx
     call print_hex_full
     print " "
     print_str SUB_MSG     
     
     pop bx
     pop ax
     
     mov dl, al
     sub dl, bl    ; dl = al - bl
     jns print_abs ; Εκτύπωση θετικής διαφοράς
     neg dl
     push dx
     print "-"  
     pop dx
print_abs:
     call print_hex_full
     new_line
    
    
    
     
     
     
     


jmp start

main endp     




; Reads a valid number character and stores its value in register AL
; On enter hit returns it's ASCI value 0dh
read_num proc near
   
    ; Reads key asci code in al
    mov ah, 01h
    int 21h            
    
    cmp al, 0dh     ; Check if enter key
    jne check_num
    ret 
    
check_num:          ; Check if number character was entered (30h ~ 39h)
    cmp al, 30h
    jl read_num
    
    cmp al, 39h
    jg read_num        
    
    ; Extract its decimal value
    sub al, 30h
    
    ret
read_num endp    
    

; Prints the ascii character
print_asci proc near
    
     

    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends  

; Παίρνει σε δυαδική μορφή ένα ψηφίο και εκτυπώνει τη δεκαεξαδική του μορφή        
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

print_bin proc near
    cmp dl, 9
    jg b_addr1
    add dl, 30h
    jmp b_addr2
b_addr1:
    add dl, 37h
b_addr2:
    print dl
    ret 
print_bin endp
  

print_dec proc near
    add dl, 30h
    print dl
print_dec endp    


print_hex_full  proc near
     push ax
     push bx
     
     push dx        ; Σώσιμο του αποτελέσματος 
      
     sar dx, 1
     sar dx, 1
     sar dx, 1
     sar dx, 1    
     and dl, 0fh 
     call print_hex   
     
     pop dx
     and dl, 0fh    ; Μάσκα dl   
     call print_hex   
     pop bx
     pop ax
     ret
     
print_hex_full    endp

end start ; set entry point and stop the assembler.
 
