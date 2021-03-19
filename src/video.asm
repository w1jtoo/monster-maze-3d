wait_frame:
    push    dx
    mov     dx, 0x03DA

_wait:
    ;; wait while it renders all the pixels on the screen
    in      al, dx
    test    al, 0x08
    jnz     _wait

_end:
    in      al, dx
    test    al, 0x08
    jz      _end
    pop     dx
    ret

init_video:
    ;; setting VGA 320x200 mode
    mov     ax, 0x13
    int     0x10

    ;; keep pointer to video memory
    mov     ax, 0xA000
    mov     es, ax

    ret

restore_video:
    ;; back to text mode
    ;; TODO: run back to last lunched mode
    mov     ax, 0x03
    int     0x10
    ret

;; update_screen:
    ;; in this game we have field 80 x 50 blocks
    ;;          each block
    ;;              1) 4 x 4 pixels
    ;;              2) has texture from table
    ;; this function should redraw blocks from the list

    ;; test draw of 3 white block
   ;; mov     ax, 0x1
   ;; mov     bx, 0x0
   ;; mov     cx, 0x1
   ;; call    .draw_block

   ;; mov     ax, 0x2
   ;; mov     bx, 0x1
   ;; mov     cx, 0x1
   ;; call    .draw_block

   ;; mov     ax, 0x1
   ;; mov     bx, 0x3
   ;; mov     cx, 0x1
   ;; call    .draw_block

    ;; DRAW_FIRST_LEFT_WHITE_BLOCK

    ;; ret


;; =============================================================================
;; =============================================================================
;;
;;  in the monster maze 3d we could decribe our game's visual part
;;      as three raws: left, middle and right
;;  for each raw is array of 0 or 1 where:
;;          0 is for empty part or passage
;;          1 for filled part   or wall
;;      for left and right raw:
;;          passage means the far wall
;;              its visual part is black rectagle on white square
;;          wall means the near wall
;;              its visual part is black triangle or isoscales trapezoid
;;              on white square
;;      for the middle raw:
;;          passage means nothing
;;              its visual part is pair of symetric white isoscale trapezoid
;;          wall means black rectagle
;;
;;==============================================================================
;;          next macros draws raw parts accounting the dinstance
;;

%define SCREEN_WIDTH    320
%define SCREEN_SIZE     320 * 200
%define SCREEN_HIGHT    200

%define BLACK           0x00
%define DOUBLE_BLACK    0x0000

%define WHITE           0x0f
%define DOUBLE_WHITE    0x0f0f

%define OFFSET(x, y) (4 * x + 4 * SCREEN_WIDTH * y)

%macro FILL_SCREEN_WITH_WHITE 0
    mov     di, 0x0
    mov     ax, DOUBLE_WHITE

%%loop:
    mov     cx, SCREEN_HIGHT / 2
    rep     stosw

    cmp     di, SCREEN_SIZE
    jne     %%loop

%endmacro

%macro DRAW_FIRST_LEFT_WHITE_BLOCK 0
    DRAW_BLACK_BLOCK        0, 49
    DRAW_BLACK_BLOCK_OPT    0, 0        ;; di in good position
                                        ;; ax keep @WHITE
%%first_column_loop:
    mov     cx, 0x4
    rep     stosw
    add     di, (SCREEN_WIDTH - 4 * 2)

    cmp     di, OFFSET(0, 49)
    jne     %%first_column_loop

%endmacro

%macro _DRAW_WHITE_BLOCK 2
    mov     di, OFFSET(%1, %2)

%rep 4
    %ifdef _FIRST
        mov     ax, DOUBLE_WHITE
    %endif
    mov     cx, 0x2
    rep     stosw

    add     di,  (SCREEN_WIDTH - 4)
%endrep
%endmacro

%macro DRAW_WHITE_BLOCK_OPT 2
    _DRAW_WHITE_BLOCK %1, %2
%endmacro

%macro DRAW_WHITE_BLOCK 2
    %define _FIRST
    _DRAW_WHITE_BLOCK %1, %2
    %undef  _FIRST
%endmacro

%macro _DRAW_BLACK_BLOCK 2
    mov     di, OFFSET(%1, %2)

%rep 4
    %ifdef _FIRST
        mov     ax, DOUBLE_BLACK
    %endif
    mov     cx, 0x2
    rep     stosw

    add     di,  (SCREEN_WIDTH - 4)
%endrep
%endmacro

%macro DRAW_BLACK_BLOCK_OPT 2
    _DRAW_BLACK_BLOCK %1, %2
%endmacro

%macro DRAW_BLACK_BLOCK 2
    %define _FIRST
    _DRAW_BLACK_BLOCK %1, %2
    %undef  _FIRST
%endmacro


update_screen:
;;    mov     ax, 0x0
;;    mov     bx, 0x0
;;    mov     cx, 0x1
;;
;;    call .draw_block
    FILL_SCREEN_WITH_WHITE
    DRAW_FIRST_LEFT_WHITE_BLOCK
    ret


;; ax - x
;; bx - y
;; cx - id
.draw_block:
    push    ax
    push    bx
    push    cx

    ;; find pixel number by x
    ;; x_offset = 4 * x
    shl     ax, 2       ;; ax *= 4

    ;; find pixel number by y
    ;; y_offset = 4 * 320 * y
    mov     dx, bx      ;; 
    shl     bx, 10
    shl     dx, 8

    ;; pos = x_offset + y_offset
    add     ax, bx
    add     ax, dx

    mov     di, ax          ;; put offset to block to di
    cmp     cx, 0x0         ;; if id == 0 fast draw black
    je      .draw_black

    cmp     cx, 0x1         ;; if id == 1 fast draw white
    je      .draw_white

    mov     ax, 0x0f0f
    mov     cx, 0x4
    rep     stosw

.ret:
    pop     cx
    pop     bx
    pop     ax
    ret

.draw_black:

%rep 4
    mov     ax, 0x0000
    mov     cx, 0x2
    rep     stosw

    add     di, (0x140 - 4)
%endrep

    jmp     .ret

.draw_white:
%rep 4
    mov     ax, 0x0f0f
    mov     cx, 0x2
    rep     stosw

    add     di, (0x140 - 4)
%endrep

    jmp     .ret

whiteb: db 0x0f dup (64)
