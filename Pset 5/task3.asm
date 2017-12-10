; multi-segment executable file template.

print macro char
    push dx
    push ax
    
    mov dl, char
    mov ah, 2
    int 21h 
    
    pop ax
    pop dx
endm

new_line macro
    print 0ah      ;    
    print 0dh      ; Carriage return
endm   

data segment
    ; add your data here! 
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
    
    ; Διάβασμα πρώτου ψηφίου
    call hex_key
    ; Έλεγχος για τερματισμός προγράμματος
    ;mov al, 0fh;
    cmp al, 'T'
    je stop  
    mov cl, 4
    mov bl, al
    shl bl, cl  ; Μετακίνηση 4 θέσεις δεξιά
    
    
    
    ; Δίάβασμα 2ου ψηφίου
    call hex_key  
    cmp al, 'T'
    je stop
    add bl, al  ; Προσθήκη 4 τελευταίων ψηφίων
    
    print "H"
    print "="
    call print_dec
    print "D"
    print "="
    call print_oct
    print "o"
    print "="
    call print_bin
    print "b"
    new_line  
    
    jmp start 

; Δέχεται στον καταχωρρητή dl την αξία του ψηφίου που θα τυπωθεί           
print_digit proc near
    cmp dl, 9
    jg addr1
    add dl, 30h
    jmp addr2
addr1:
    add dl, 37h
addr2:
    print dl
    ret 
print_digit endp


PRINT_DEC proc near    
     push dx 
     push cx
     push ax 
     

     mov ah, 00h
     mov al, bl
     mov cl, 100    ; Απομόνωση εκατοντάδων
     div cl         ; Διαίρεση με το 100
     mov dl, al     ; Εκτύπωση πηλίκο
     call print_digit
     
     mov cl, 10     ; Απομόνωση δεκάδων
     mov al, ah     ; Μετακίνηση πηλίκου ως νέου αριθμού
     mov ah, 0
     div cl 
     mov dl, al
     call print_digit
     
     mov dl, ah     ; Εκτύπωση μονάδων
     call print_digit

     pop ax
     pop cx
     pop dx  
     ret
    
PRINT_DEC endp 
 
PRINT_OCT proc near   
     push dx 
     push cx 
     
     mov cl, 6
     mov dl, bl     ; Eκτύπωση 1ου ψηφίου
     sar dl, cl  
     and dl, 03h 
     call print_digit   
     
     
     mov cl, 3
     mov dl, bl     ; Eκτύπωση 2oυ ψηφίου
     sar dl, cl  
     and dl, 07h 
     call print_digit   
     
     mov dl, bl     ; Eκτύπωση 3ου ψηφίου  
     and dl, 07h 
     call print_digit

     pop cx
     pop dx
     ret
PRINT_OCT endp 

PRINT_BIN proc near
    push bx
    push cx
    
    mov cx, 8      ; Loop 8 φορές
again:
    rol bl, 1
    jc print1
    mov dl, 00h    ; Εκτύπωση 0 
    call print_digit
    LOOP again
    pop cx
    pop bx
    ret
print1:
    mov dl, 01h     ; Εκτύπωση 1
    call print_digit
    LOOP again  
    pop cx
    pop bx
    ret   
PRINT_BIN endp 
 
hex_key proc near 
ignore:
    ; Read 
    mov ah, 1
    int 21h
    
    ; Check if exit key pressed
    cmp al, 'T'
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

    
stop:
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends
end start ; set entry point and stop the assembler.
