; multi-segment executable file template.

print macro char
    mov dl, char
    mov ah, 2
    int 21h
endm

; Πλήθος αριθμών στη μνήμη             
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
    
    ; Φόρτωση μνήμης με σσυνεχόμενους αριθμούς
    mov cl, N
    cld                     ; df = 0
    mov di, OFFSET ADDRN       
    mov ax, 4
write_again:   
    stosw     
    inc ax                  ; Φόρτωση επόμενου δεδομένου
    loop write_again   
    
    
    ; ’θροισμα αριθμών σε ψευδο-32 bit καταχωρητή
    ; =>>>> 32 bit: dX:bX 
    
    
    mov cl, N
    cld                     ; df = 0
    mov di, OFFSET ADDRN   
    mov dx, 0               ; Αρχικοποίηση καταχωητών αθροίσματος 
    mov bx, 0
load_again:   
    lodsw                   ; Φόρτωση στον καταχωρητή  
    add bx, ax
    jnc no_overflow         ; Αν δεν έχουμε υπερχείληση  
    inc dx                  ; dx <- dx + 1    
no_overflow:    
    loop load_again         
        
    ; Διαίρεση dl:dh:ah:al/Διαρέτης = Πηλίκο στον dh:dl
    
    mov ax, bx              ; Μετακίνηση διαρέτέου
    mov bx, N               ; Διαιρέτης
    div bx                  ; Εκτέλεση διαίρεσης        
 
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
    lodsw                   ; Φόρτωση στον καταχωρητή   
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
    
     ; Παίρνει σε δυαδική μορφή ένα ψηφίο και εκτυπώνει τη δεκαεξαδική του μορφή        

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
    mov dl, bh               ; Εκτύπωση 8MSB
    call print_hex_full         
    mov dl, bl               ; Εκτύπωση 8LSB
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
     pop dx
     ret  
print_hex_full    endp  

end start ; set entry point and stop the assembler.
              
