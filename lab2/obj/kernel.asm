
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 88 af 11 c0       	mov    $0xc011af88,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 04 5e 00 00       	call   c0105e66 <memset>

    cons_init();                // init the console
c0100062:	e8 82 15 00 00       	call   c01015e9 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 00 60 10 c0 	movl   $0xc0106000,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 1c 60 10 c0 	movl   $0xc010601c,(%esp)
c010007c:	e8 c7 02 00 00       	call   c0100348 <cprintf>

    print_kerninfo();
c0100081:	e8 f6 07 00 00       	call   c010087c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 86 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 41 43 00 00       	call   c01043d1 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 bd 16 00 00       	call   c0101752 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 35 18 00 00       	call   c01018cf <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 00 0d 00 00       	call   c0100d9f <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 1c 16 00 00       	call   c01016c0 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 f8 0b 00 00       	call   c0100cc0 <mon_backtrace>
}
c01000c8:	c9                   	leave  
c01000c9:	c3                   	ret    

c01000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ca:	55                   	push   %ebp
c01000cb:	89 e5                	mov    %esp,%ebp
c01000cd:	53                   	push   %ebx
c01000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000d7:	8d 55 08             	lea    0x8(%ebp),%edx
c01000da:	8b 45 08             	mov    0x8(%ebp),%eax
c01000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000e9:	89 04 24             	mov    %eax,(%esp)
c01000ec:	e8 b5 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f1:	83 c4 14             	add    $0x14,%esp
c01000f4:	5b                   	pop    %ebx
c01000f5:	5d                   	pop    %ebp
c01000f6:	c3                   	ret    

c01000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f7:	55                   	push   %ebp
c01000f8:	89 e5                	mov    %esp,%ebp
c01000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0100100:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100104:	8b 45 08             	mov    0x8(%ebp),%eax
c0100107:	89 04 24             	mov    %eax,(%esp)
c010010a:	e8 bb ff ff ff       	call   c01000ca <grade_backtrace1>
}
c010010f:	c9                   	leave  
c0100110:	c3                   	ret    

c0100111 <grade_backtrace>:

void
grade_backtrace(void) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100117:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100123:	ff 
c0100124:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010012f:	e8 c3 ff ff ff       	call   c01000f7 <grade_backtrace0>
}
c0100134:	c9                   	leave  
c0100135:	c3                   	ret    

c0100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100136:	55                   	push   %ebp
c0100137:	89 e5                	mov    %esp,%ebp
c0100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010014c:	0f b7 c0             	movzwl %ax,%eax
c010014f:	83 e0 03             	and    $0x3,%eax
c0100152:	89 c2                	mov    %eax,%edx
c0100154:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100159:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100161:	c7 04 24 21 60 10 c0 	movl   $0xc0106021,(%esp)
c0100168:	e8 db 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	0f b7 d0             	movzwl %ax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 2f 60 10 c0 	movl   $0xc010602f,(%esp)
c0100188:	e8 bb 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	0f b7 d0             	movzwl %ax,%edx
c0100194:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 3d 60 10 c0 	movl   $0xc010603d,(%esp)
c01001a8:	e8 9b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b1:	0f b7 d0             	movzwl %ax,%edx
c01001b4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 4b 60 10 c0 	movl   $0xc010604b,(%esp)
c01001c8:	e8 7b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d1:	0f b7 d0             	movzwl %ax,%edx
c01001d4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e1:	c7 04 24 59 60 10 c0 	movl   $0xc0106059,(%esp)
c01001e8:	e8 5b 01 00 00       	call   c0100348 <cprintf>
    round ++;
c01001ed:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001f2:	83 c0 01             	add    $0x1,%eax
c01001f5:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001fa:	c9                   	leave  
c01001fb:	c3                   	ret    

c01001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fc:	55                   	push   %ebp
c01001fd:	89 e5                	mov    %esp,%ebp

}
c01001ff:	5d                   	pop    %ebp
c0100200:	c3                   	ret    

c0100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100201:	55                   	push   %ebp
c0100202:	89 e5                	mov    %esp,%ebp

}
c0100204:	5d                   	pop    %ebp
c0100205:	c3                   	ret    

c0100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100206:	55                   	push   %ebp
c0100207:	89 e5                	mov    %esp,%ebp
c0100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020c:	e8 25 ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100211:	c7 04 24 68 60 10 c0 	movl   $0xc0106068,(%esp)
c0100218:	e8 2b 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_user();
c010021d:	e8 da ff ff ff       	call   c01001fc <lab1_switch_to_user>
    lab1_print_cur_status();
c0100222:	e8 0f ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100227:	c7 04 24 88 60 10 c0 	movl   $0xc0106088,(%esp)
c010022e:	e8 15 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_kernel();
c0100233:	e8 c9 ff ff ff       	call   c0100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100238:	e8 f9 fe ff ff       	call   c0100136 <lab1_print_cur_status>
}
c010023d:	c9                   	leave  
c010023e:	c3                   	ret    

c010023f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010023f:	55                   	push   %ebp
c0100240:	89 e5                	mov    %esp,%ebp
c0100242:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100245:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100249:	74 13                	je     c010025e <readline+0x1f>
        cprintf("%s", prompt);
c010024b:	8b 45 08             	mov    0x8(%ebp),%eax
c010024e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100252:	c7 04 24 a7 60 10 c0 	movl   $0xc01060a7,(%esp)
c0100259:	e8 ea 00 00 00       	call   c0100348 <cprintf>
    }
    int i = 0, c;
c010025e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100265:	e8 66 01 00 00       	call   c01003d0 <getchar>
c010026a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010026d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100271:	79 07                	jns    c010027a <readline+0x3b>
            return NULL;
c0100273:	b8 00 00 00 00       	mov    $0x0,%eax
c0100278:	eb 79                	jmp    c01002f3 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010027a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010027e:	7e 28                	jle    c01002a8 <readline+0x69>
c0100280:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100287:	7f 1f                	jg     c01002a8 <readline+0x69>
            cputchar(c);
c0100289:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010028c:	89 04 24             	mov    %eax,(%esp)
c010028f:	e8 da 00 00 00       	call   c010036e <cputchar>
            buf[i ++] = c;
c0100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100297:	8d 50 01             	lea    0x1(%eax),%edx
c010029a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010029d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a0:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c01002a6:	eb 46                	jmp    c01002ee <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002ac:	75 17                	jne    c01002c5 <readline+0x86>
c01002ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002b2:	7e 11                	jle    c01002c5 <readline+0x86>
            cputchar(c);
c01002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b7:	89 04 24             	mov    %eax,(%esp)
c01002ba:	e8 af 00 00 00       	call   c010036e <cputchar>
            i --;
c01002bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002c3:	eb 29                	jmp    c01002ee <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002c5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002c9:	74 06                	je     c01002d1 <readline+0x92>
c01002cb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002cf:	75 1d                	jne    c01002ee <readline+0xaf>
            cputchar(c);
c01002d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d4:	89 04 24             	mov    %eax,(%esp)
c01002d7:	e8 92 00 00 00       	call   c010036e <cputchar>
            buf[i] = '\0';
c01002dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002df:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002e7:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01002ec:	eb 05                	jmp    c01002f3 <readline+0xb4>
        }
    }
c01002ee:	e9 72 ff ff ff       	jmp    c0100265 <readline+0x26>
}
c01002f3:	c9                   	leave  
c01002f4:	c3                   	ret    

c01002f5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002f5:	55                   	push   %ebp
c01002f6:	89 e5                	mov    %esp,%ebp
c01002f8:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01002fe:	89 04 24             	mov    %eax,(%esp)
c0100301:	e8 0f 13 00 00       	call   c0101615 <cons_putc>
    (*cnt) ++;
c0100306:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100309:	8b 00                	mov    (%eax),%eax
c010030b:	8d 50 01             	lea    0x1(%eax),%edx
c010030e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100311:	89 10                	mov    %edx,(%eax)
}
c0100313:	c9                   	leave  
c0100314:	c3                   	ret    

c0100315 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100315:	55                   	push   %ebp
c0100316:	89 e5                	mov    %esp,%ebp
c0100318:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010031b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100322:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100325:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100329:	8b 45 08             	mov    0x8(%ebp),%eax
c010032c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100330:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100333:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100337:	c7 04 24 f5 02 10 c0 	movl   $0xc01002f5,(%esp)
c010033e:	e8 3c 53 00 00       	call   c010567f <vprintfmt>
    return cnt;
c0100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100346:	c9                   	leave  
c0100347:	c3                   	ret    

c0100348 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100348:	55                   	push   %ebp
c0100349:	89 e5                	mov    %esp,%ebp
c010034b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010034e:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100354:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100357:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035b:	8b 45 08             	mov    0x8(%ebp),%eax
c010035e:	89 04 24             	mov    %eax,(%esp)
c0100361:	e8 af ff ff ff       	call   c0100315 <vcprintf>
c0100366:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100369:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010036c:	c9                   	leave  
c010036d:	c3                   	ret    

c010036e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010036e:	55                   	push   %ebp
c010036f:	89 e5                	mov    %esp,%ebp
c0100371:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100374:	8b 45 08             	mov    0x8(%ebp),%eax
c0100377:	89 04 24             	mov    %eax,(%esp)
c010037a:	e8 96 12 00 00       	call   c0101615 <cons_putc>
}
c010037f:	c9                   	leave  
c0100380:	c3                   	ret    

c0100381 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100381:	55                   	push   %ebp
c0100382:	89 e5                	mov    %esp,%ebp
c0100384:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010038e:	eb 13                	jmp    c01003a3 <cputs+0x22>
        cputch(c, &cnt);
c0100390:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100394:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100397:	89 54 24 04          	mov    %edx,0x4(%esp)
c010039b:	89 04 24             	mov    %eax,(%esp)
c010039e:	e8 52 ff ff ff       	call   c01002f5 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01003a6:	8d 50 01             	lea    0x1(%eax),%edx
c01003a9:	89 55 08             	mov    %edx,0x8(%ebp)
c01003ac:	0f b6 00             	movzbl (%eax),%eax
c01003af:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003b2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003b6:	75 d8                	jne    c0100390 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003bf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003c6:	e8 2a ff ff ff       	call   c01002f5 <cputch>
    return cnt;
c01003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003ce:	c9                   	leave  
c01003cf:	c3                   	ret    

c01003d0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003d0:	55                   	push   %ebp
c01003d1:	89 e5                	mov    %esp,%ebp
c01003d3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003d6:	e8 76 12 00 00       	call   c0101651 <cons_getc>
c01003db:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003e2:	74 f2                	je     c01003d6 <getchar+0x6>
        /* do nothing */;
    return c;
c01003e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003e7:	c9                   	leave  
c01003e8:	c3                   	ret    

c01003e9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003e9:	55                   	push   %ebp
c01003ea:	89 e5                	mov    %esp,%ebp
c01003ec:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003f2:	8b 00                	mov    (%eax),%eax
c01003f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01003f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01003fa:	8b 00                	mov    (%eax),%eax
c01003fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01003ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100406:	e9 d2 00 00 00       	jmp    c01004dd <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010040b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010040e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100411:	01 d0                	add    %edx,%eax
c0100413:	89 c2                	mov    %eax,%edx
c0100415:	c1 ea 1f             	shr    $0x1f,%edx
c0100418:	01 d0                	add    %edx,%eax
c010041a:	d1 f8                	sar    %eax
c010041c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010041f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100422:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100425:	eb 04                	jmp    c010042b <stab_binsearch+0x42>
            m --;
c0100427:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010042b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010042e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100431:	7c 1f                	jl     c0100452 <stab_binsearch+0x69>
c0100433:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100436:	89 d0                	mov    %edx,%eax
c0100438:	01 c0                	add    %eax,%eax
c010043a:	01 d0                	add    %edx,%eax
c010043c:	c1 e0 02             	shl    $0x2,%eax
c010043f:	89 c2                	mov    %eax,%edx
c0100441:	8b 45 08             	mov    0x8(%ebp),%eax
c0100444:	01 d0                	add    %edx,%eax
c0100446:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010044a:	0f b6 c0             	movzbl %al,%eax
c010044d:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100450:	75 d5                	jne    c0100427 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100452:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100455:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100458:	7d 0b                	jge    c0100465 <stab_binsearch+0x7c>
            l = true_m + 1;
c010045a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010045d:	83 c0 01             	add    $0x1,%eax
c0100460:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100463:	eb 78                	jmp    c01004dd <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100465:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010046c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010046f:	89 d0                	mov    %edx,%eax
c0100471:	01 c0                	add    %eax,%eax
c0100473:	01 d0                	add    %edx,%eax
c0100475:	c1 e0 02             	shl    $0x2,%eax
c0100478:	89 c2                	mov    %eax,%edx
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	01 d0                	add    %edx,%eax
c010047f:	8b 40 08             	mov    0x8(%eax),%eax
c0100482:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100485:	73 13                	jae    c010049a <stab_binsearch+0xb1>
            *region_left = m;
c0100487:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010048d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010048f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100492:	83 c0 01             	add    $0x1,%eax
c0100495:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100498:	eb 43                	jmp    c01004dd <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049d:	89 d0                	mov    %edx,%eax
c010049f:	01 c0                	add    %eax,%eax
c01004a1:	01 d0                	add    %edx,%eax
c01004a3:	c1 e0 02             	shl    $0x2,%eax
c01004a6:	89 c2                	mov    %eax,%edx
c01004a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01004ab:	01 d0                	add    %edx,%eax
c01004ad:	8b 40 08             	mov    0x8(%eax),%eax
c01004b0:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004b3:	76 16                	jbe    c01004cb <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004b8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004be:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c3:	83 e8 01             	sub    $0x1,%eax
c01004c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004c9:	eb 12                	jmp    c01004dd <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004d1:	89 10                	mov    %edx,(%eax)
            l = m;
c01004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004d9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004e3:	0f 8e 22 ff ff ff    	jle    c010040b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004ed:	75 0f                	jne    c01004fe <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f2:	8b 00                	mov    (%eax),%eax
c01004f4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01004fa:	89 10                	mov    %edx,(%eax)
c01004fc:	eb 3f                	jmp    c010053d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01004fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0100501:	8b 00                	mov    (%eax),%eax
c0100503:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100506:	eb 04                	jmp    c010050c <stab_binsearch+0x123>
c0100508:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010050c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010050f:	8b 00                	mov    (%eax),%eax
c0100511:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100514:	7d 1f                	jge    c0100535 <stab_binsearch+0x14c>
c0100516:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100519:	89 d0                	mov    %edx,%eax
c010051b:	01 c0                	add    %eax,%eax
c010051d:	01 d0                	add    %edx,%eax
c010051f:	c1 e0 02             	shl    $0x2,%eax
c0100522:	89 c2                	mov    %eax,%edx
c0100524:	8b 45 08             	mov    0x8(%ebp),%eax
c0100527:	01 d0                	add    %edx,%eax
c0100529:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010052d:	0f b6 c0             	movzbl %al,%eax
c0100530:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100533:	75 d3                	jne    c0100508 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100535:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100538:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010053b:	89 10                	mov    %edx,(%eax)
    }
}
c010053d:	c9                   	leave  
c010053e:	c3                   	ret    

c010053f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010053f:	55                   	push   %ebp
c0100540:	89 e5                	mov    %esp,%ebp
c0100542:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100545:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100548:	c7 00 ac 60 10 c0    	movl   $0xc01060ac,(%eax)
    info->eip_line = 0;
c010054e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055b:	c7 40 08 ac 60 10 c0 	movl   $0xc01060ac,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100562:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100565:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010056c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100572:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100575:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100578:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010057f:	c7 45 f4 40 73 10 c0 	movl   $0xc0107340,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100586:	c7 45 f0 54 1f 11 c0 	movl   $0xc0111f54,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010058d:	c7 45 ec 55 1f 11 c0 	movl   $0xc0111f55,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100594:	c7 45 e8 a0 49 11 c0 	movl   $0xc01149a0,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010059b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010059e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005a1:	76 0d                	jbe    c01005b0 <debuginfo_eip+0x71>
c01005a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005a6:	83 e8 01             	sub    $0x1,%eax
c01005a9:	0f b6 00             	movzbl (%eax),%eax
c01005ac:	84 c0                	test   %al,%al
c01005ae:	74 0a                	je     c01005ba <debuginfo_eip+0x7b>
        return -1;
c01005b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005b5:	e9 c0 02 00 00       	jmp    c010087a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005c7:	29 c2                	sub    %eax,%edx
c01005c9:	89 d0                	mov    %edx,%eax
c01005cb:	c1 f8 02             	sar    $0x2,%eax
c01005ce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005d4:	83 e8 01             	sub    $0x1,%eax
c01005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005da:	8b 45 08             	mov    0x8(%ebp),%eax
c01005dd:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005e1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005e8:	00 
c01005e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005fa:	89 04 24             	mov    %eax,(%esp)
c01005fd:	e8 e7 fd ff ff       	call   c01003e9 <stab_binsearch>
    if (lfile == 0)
c0100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100605:	85 c0                	test   %eax,%eax
c0100607:	75 0a                	jne    c0100613 <debuginfo_eip+0xd4>
        return -1;
c0100609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010060e:	e9 67 02 00 00       	jmp    c010087a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100616:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100619:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010061f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100622:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100626:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010062d:	00 
c010062e:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100631:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100635:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100638:	89 44 24 04          	mov    %eax,0x4(%esp)
c010063c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010063f:	89 04 24             	mov    %eax,(%esp)
c0100642:	e8 a2 fd ff ff       	call   c01003e9 <stab_binsearch>

    if (lfun <= rfun) {
c0100647:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010064a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010064d:	39 c2                	cmp    %eax,%edx
c010064f:	7f 7c                	jg     c01006cd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100651:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100654:	89 c2                	mov    %eax,%edx
c0100656:	89 d0                	mov    %edx,%eax
c0100658:	01 c0                	add    %eax,%eax
c010065a:	01 d0                	add    %edx,%eax
c010065c:	c1 e0 02             	shl    $0x2,%eax
c010065f:	89 c2                	mov    %eax,%edx
c0100661:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100664:	01 d0                	add    %edx,%eax
c0100666:	8b 10                	mov    (%eax),%edx
c0100668:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010066b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010066e:	29 c1                	sub    %eax,%ecx
c0100670:	89 c8                	mov    %ecx,%eax
c0100672:	39 c2                	cmp    %eax,%edx
c0100674:	73 22                	jae    c0100698 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100676:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100679:	89 c2                	mov    %eax,%edx
c010067b:	89 d0                	mov    %edx,%eax
c010067d:	01 c0                	add    %eax,%eax
c010067f:	01 d0                	add    %edx,%eax
c0100681:	c1 e0 02             	shl    $0x2,%eax
c0100684:	89 c2                	mov    %eax,%edx
c0100686:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100689:	01 d0                	add    %edx,%eax
c010068b:	8b 10                	mov    (%eax),%edx
c010068d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100690:	01 c2                	add    %eax,%edx
c0100692:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100695:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100698:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010069b:	89 c2                	mov    %eax,%edx
c010069d:	89 d0                	mov    %edx,%eax
c010069f:	01 c0                	add    %eax,%eax
c01006a1:	01 d0                	add    %edx,%eax
c01006a3:	c1 e0 02             	shl    $0x2,%eax
c01006a6:	89 c2                	mov    %eax,%edx
c01006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ab:	01 d0                	add    %edx,%eax
c01006ad:	8b 50 08             	mov    0x8(%eax),%edx
c01006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b9:	8b 40 10             	mov    0x10(%eax),%eax
c01006bc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006cb:	eb 15                	jmp    c01006e2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e5:	8b 40 08             	mov    0x8(%eax),%eax
c01006e8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006ef:	00 
c01006f0:	89 04 24             	mov    %eax,(%esp)
c01006f3:	e8 e2 55 00 00       	call   c0105cda <strfind>
c01006f8:	89 c2                	mov    %eax,%edx
c01006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006fd:	8b 40 08             	mov    0x8(%eax),%eax
c0100700:	29 c2                	sub    %eax,%edx
c0100702:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100705:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100708:	8b 45 08             	mov    0x8(%ebp),%eax
c010070b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010070f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100716:	00 
c0100717:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010071a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010071e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100721:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100725:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100728:	89 04 24             	mov    %eax,(%esp)
c010072b:	e8 b9 fc ff ff       	call   c01003e9 <stab_binsearch>
    if (lline <= rline) {
c0100730:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100733:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100736:	39 c2                	cmp    %eax,%edx
c0100738:	7f 24                	jg     c010075e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c010073a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073d:	89 c2                	mov    %eax,%edx
c010073f:	89 d0                	mov    %edx,%eax
c0100741:	01 c0                	add    %eax,%eax
c0100743:	01 d0                	add    %edx,%eax
c0100745:	c1 e0 02             	shl    $0x2,%eax
c0100748:	89 c2                	mov    %eax,%edx
c010074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074d:	01 d0                	add    %edx,%eax
c010074f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100753:	0f b7 d0             	movzwl %ax,%edx
c0100756:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100759:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010075c:	eb 13                	jmp    c0100771 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010075e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100763:	e9 12 01 00 00       	jmp    c010087a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010076b:	83 e8 01             	sub    $0x1,%eax
c010076e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100777:	39 c2                	cmp    %eax,%edx
c0100779:	7c 56                	jl     c01007d1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010077b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077e:	89 c2                	mov    %eax,%edx
c0100780:	89 d0                	mov    %edx,%eax
c0100782:	01 c0                	add    %eax,%eax
c0100784:	01 d0                	add    %edx,%eax
c0100786:	c1 e0 02             	shl    $0x2,%eax
c0100789:	89 c2                	mov    %eax,%edx
c010078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078e:	01 d0                	add    %edx,%eax
c0100790:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100794:	3c 84                	cmp    $0x84,%al
c0100796:	74 39                	je     c01007d1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079b:	89 c2                	mov    %eax,%edx
c010079d:	89 d0                	mov    %edx,%eax
c010079f:	01 c0                	add    %eax,%eax
c01007a1:	01 d0                	add    %edx,%eax
c01007a3:	c1 e0 02             	shl    $0x2,%eax
c01007a6:	89 c2                	mov    %eax,%edx
c01007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ab:	01 d0                	add    %edx,%eax
c01007ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b1:	3c 64                	cmp    $0x64,%al
c01007b3:	75 b3                	jne    c0100768 <debuginfo_eip+0x229>
c01007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b8:	89 c2                	mov    %eax,%edx
c01007ba:	89 d0                	mov    %edx,%eax
c01007bc:	01 c0                	add    %eax,%eax
c01007be:	01 d0                	add    %edx,%eax
c01007c0:	c1 e0 02             	shl    $0x2,%eax
c01007c3:	89 c2                	mov    %eax,%edx
c01007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c8:	01 d0                	add    %edx,%eax
c01007ca:	8b 40 08             	mov    0x8(%eax),%eax
c01007cd:	85 c0                	test   %eax,%eax
c01007cf:	74 97                	je     c0100768 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007d7:	39 c2                	cmp    %eax,%edx
c01007d9:	7c 46                	jl     c0100821 <debuginfo_eip+0x2e2>
c01007db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007de:	89 c2                	mov    %eax,%edx
c01007e0:	89 d0                	mov    %edx,%eax
c01007e2:	01 c0                	add    %eax,%eax
c01007e4:	01 d0                	add    %edx,%eax
c01007e6:	c1 e0 02             	shl    $0x2,%eax
c01007e9:	89 c2                	mov    %eax,%edx
c01007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ee:	01 d0                	add    %edx,%eax
c01007f0:	8b 10                	mov    (%eax),%edx
c01007f2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007f8:	29 c1                	sub    %eax,%ecx
c01007fa:	89 c8                	mov    %ecx,%eax
c01007fc:	39 c2                	cmp    %eax,%edx
c01007fe:	73 21                	jae    c0100821 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100800:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100803:	89 c2                	mov    %eax,%edx
c0100805:	89 d0                	mov    %edx,%eax
c0100807:	01 c0                	add    %eax,%eax
c0100809:	01 d0                	add    %edx,%eax
c010080b:	c1 e0 02             	shl    $0x2,%eax
c010080e:	89 c2                	mov    %eax,%edx
c0100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100813:	01 d0                	add    %edx,%eax
c0100815:	8b 10                	mov    (%eax),%edx
c0100817:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010081a:	01 c2                	add    %eax,%edx
c010081c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100821:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100824:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100827:	39 c2                	cmp    %eax,%edx
c0100829:	7d 4a                	jge    c0100875 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010082b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082e:	83 c0 01             	add    $0x1,%eax
c0100831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100834:	eb 18                	jmp    c010084e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100836:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100839:	8b 40 14             	mov    0x14(%eax),%eax
c010083c:	8d 50 01             	lea    0x1(%eax),%edx
c010083f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100842:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100848:	83 c0 01             	add    $0x1,%eax
c010084b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010084e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100851:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100854:	39 c2                	cmp    %eax,%edx
c0100856:	7d 1d                	jge    c0100875 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	89 d0                	mov    %edx,%eax
c010085f:	01 c0                	add    %eax,%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	c1 e0 02             	shl    $0x2,%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100871:	3c a0                	cmp    $0xa0,%al
c0100873:	74 c1                	je     c0100836 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100875:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010087a:	c9                   	leave  
c010087b:	c3                   	ret    

c010087c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010087c:	55                   	push   %ebp
c010087d:	89 e5                	mov    %esp,%ebp
c010087f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100882:	c7 04 24 b6 60 10 c0 	movl   $0xc01060b6,(%esp)
c0100889:	e8 ba fa ff ff       	call   c0100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100895:	c0 
c0100896:	c7 04 24 cf 60 10 c0 	movl   $0xc01060cf,(%esp)
c010089d:	e8 a6 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008a2:	c7 44 24 04 ef 5f 10 	movl   $0xc0105fef,0x4(%esp)
c01008a9:	c0 
c01008aa:	c7 04 24 e7 60 10 c0 	movl   $0xc01060e7,(%esp)
c01008b1:	e8 92 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b6:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c01008bd:	c0 
c01008be:	c7 04 24 ff 60 10 c0 	movl   $0xc01060ff,(%esp)
c01008c5:	e8 7e fa ff ff       	call   c0100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008ca:	c7 44 24 04 88 af 11 	movl   $0xc011af88,0x4(%esp)
c01008d1:	c0 
c01008d2:	c7 04 24 17 61 10 c0 	movl   $0xc0106117,(%esp)
c01008d9:	e8 6a fa ff ff       	call   c0100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008de:	b8 88 af 11 c0       	mov    $0xc011af88,%eax
c01008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008e9:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008ee:	29 c2                	sub    %eax,%edx
c01008f0:	89 d0                	mov    %edx,%eax
c01008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f8:	85 c0                	test   %eax,%eax
c01008fa:	0f 48 c2             	cmovs  %edx,%eax
c01008fd:	c1 f8 0a             	sar    $0xa,%eax
c0100900:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100904:	c7 04 24 30 61 10 c0 	movl   $0xc0106130,(%esp)
c010090b:	e8 38 fa ff ff       	call   c0100348 <cprintf>
}
c0100910:	c9                   	leave  
c0100911:	c3                   	ret    

c0100912 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100912:	55                   	push   %ebp
c0100913:	89 e5                	mov    %esp,%ebp
c0100915:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010091b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010091e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100922:	8b 45 08             	mov    0x8(%ebp),%eax
c0100925:	89 04 24             	mov    %eax,(%esp)
c0100928:	e8 12 fc ff ff       	call   c010053f <debuginfo_eip>
c010092d:	85 c0                	test   %eax,%eax
c010092f:	74 15                	je     c0100946 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100931:	8b 45 08             	mov    0x8(%ebp),%eax
c0100934:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100938:	c7 04 24 5a 61 10 c0 	movl   $0xc010615a,(%esp)
c010093f:	e8 04 fa ff ff       	call   c0100348 <cprintf>
c0100944:	eb 6d                	jmp    c01009b3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010094d:	eb 1c                	jmp    c010096b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010094f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100952:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100955:	01 d0                	add    %edx,%eax
c0100957:	0f b6 00             	movzbl (%eax),%eax
c010095a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100960:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100963:	01 ca                	add    %ecx,%edx
c0100965:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100967:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010096b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010096e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100971:	7f dc                	jg     c010094f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100973:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097c:	01 d0                	add    %edx,%eax
c010097e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100981:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100984:	8b 55 08             	mov    0x8(%ebp),%edx
c0100987:	89 d1                	mov    %edx,%ecx
c0100989:	29 c1                	sub    %eax,%ecx
c010098b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010098e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100991:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100995:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010099b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010099f:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a7:	c7 04 24 76 61 10 c0 	movl   $0xc0106176,(%esp)
c01009ae:	e8 95 f9 ff ff       	call   c0100348 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009b3:	c9                   	leave  
c01009b4:	c3                   	ret    

c01009b5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b5:	55                   	push   %ebp
c01009b6:	89 e5                	mov    %esp,%ebp
c01009b8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009bb:	8b 45 04             	mov    0x4(%ebp),%eax
c01009be:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c4:	c9                   	leave  
c01009c5:	c3                   	ret    

c01009c6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c6:	55                   	push   %ebp
c01009c7:	89 e5                	mov    %esp,%ebp
c01009c9:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009cc:	89 e8                	mov    %ebp,%eax
c01009ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
int i;
int j;
uint32_t ebp=read_ebp();
c01009d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
uint32_t eip=read_eip();
c01009d7:	e8 d9 ff ff ff       	call   c01009b5 <read_eip>
c01009dc:	89 45 e8             	mov    %eax,-0x18(%ebp)

	for (i=0; ebp!=0 && i<STACKFRAME_DEPTH; i++)
c01009df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01009e6:	e9 88 00 00 00       	jmp    c0100a73 <print_stackframe+0xad>
	{
		cprintf("ebp:0x%08x eip:0x%08x ", ebp, eip);
c01009eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01009ee:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f9:	c7 04 24 88 61 10 c0 	movl   $0xc0106188,(%esp)
c0100a00:	e8 43 f9 ff ff       	call   c0100348 <cprintf>
		uint32_t *args=(uint32_t *)ebp+2;
c0100a05:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100a08:	83 c0 08             	add    $0x8,%eax
c0100a0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for( j=0; j<4; j++)
c0100a0e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0100a15:	eb 25                	jmp    c0100a3c <print_stackframe+0x76>
			cprintf("0x%08x ", args[j]);
c0100a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a24:	01 d0                	add    %edx,%eax
c0100a26:	8b 00                	mov    (%eax),%eax
c0100a28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a2c:	c7 04 24 9f 61 10 c0 	movl   $0xc010619f,(%esp)
c0100a33:	e8 10 f9 ff ff       	call   c0100348 <cprintf>

	for (i=0; ebp!=0 && i<STACKFRAME_DEPTH; i++)
	{
		cprintf("ebp:0x%08x eip:0x%08x ", ebp, eip);
		uint32_t *args=(uint32_t *)ebp+2;
		for( j=0; j<4; j++)
c0100a38:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0100a3c:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
c0100a40:	7e d5                	jle    c0100a17 <print_stackframe+0x51>
			cprintf("0x%08x ", args[j]);
		cprintf("\n");
c0100a42:	c7 04 24 a7 61 10 c0 	movl   $0xc01061a7,(%esp)
c0100a49:	e8 fa f8 ff ff       	call   c0100348 <cprintf>
		print_debuginfo(eip-1);
c0100a4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a51:	83 e8 01             	sub    $0x1,%eax
c0100a54:	89 04 24             	mov    %eax,(%esp)
c0100a57:	e8 b6 fe ff ff       	call   c0100912 <print_debuginfo>
		eip=*((uint32_t *)ebp+1);
c0100a5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100a5f:	83 c0 04             	add    $0x4,%eax
c0100a62:	8b 00                	mov    (%eax),%eax
c0100a64:	89 45 e8             	mov    %eax,-0x18(%ebp)
		ebp=*((uint32_t *)ebp);
c0100a67:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100a6a:	8b 00                	mov    (%eax),%eax
c0100a6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
int i;
int j;
uint32_t ebp=read_ebp();
uint32_t eip=read_eip();

	for (i=0; ebp!=0 && i<STACKFRAME_DEPTH; i++)
c0100a6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a73:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0100a77:	74 0a                	je     c0100a83 <print_stackframe+0xbd>
c0100a79:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
c0100a7d:	0f 8e 68 ff ff ff    	jle    c01009eb <print_stackframe+0x25>





}
c0100a83:	c9                   	leave  
c0100a84:	c3                   	ret    

c0100a85 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a85:	55                   	push   %ebp
c0100a86:	89 e5                	mov    %esp,%ebp
c0100a88:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a92:	eb 0c                	jmp    c0100aa0 <parse+0x1b>
            *buf ++ = '\0';
c0100a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a97:	8d 50 01             	lea    0x1(%eax),%edx
c0100a9a:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a9d:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa3:	0f b6 00             	movzbl (%eax),%eax
c0100aa6:	84 c0                	test   %al,%al
c0100aa8:	74 1d                	je     c0100ac7 <parse+0x42>
c0100aaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aad:	0f b6 00             	movzbl (%eax),%eax
c0100ab0:	0f be c0             	movsbl %al,%eax
c0100ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab7:	c7 04 24 2c 62 10 c0 	movl   $0xc010622c,(%esp)
c0100abe:	e8 e4 51 00 00       	call   c0105ca7 <strchr>
c0100ac3:	85 c0                	test   %eax,%eax
c0100ac5:	75 cd                	jne    c0100a94 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aca:	0f b6 00             	movzbl (%eax),%eax
c0100acd:	84 c0                	test   %al,%al
c0100acf:	75 02                	jne    c0100ad3 <parse+0x4e>
            break;
c0100ad1:	eb 67                	jmp    c0100b3a <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ad3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ad7:	75 14                	jne    c0100aed <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ad9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ae0:	00 
c0100ae1:	c7 04 24 31 62 10 c0 	movl   $0xc0106231,(%esp)
c0100ae8:	e8 5b f8 ff ff       	call   c0100348 <cprintf>
        }
        argv[argc ++] = buf;
c0100aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100af0:	8d 50 01             	lea    0x1(%eax),%edx
c0100af3:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100af6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100afd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b00:	01 c2                	add    %eax,%edx
c0100b02:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b05:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b07:	eb 04                	jmp    c0100b0d <parse+0x88>
            buf ++;
c0100b09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b10:	0f b6 00             	movzbl (%eax),%eax
c0100b13:	84 c0                	test   %al,%al
c0100b15:	74 1d                	je     c0100b34 <parse+0xaf>
c0100b17:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b1a:	0f b6 00             	movzbl (%eax),%eax
c0100b1d:	0f be c0             	movsbl %al,%eax
c0100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b24:	c7 04 24 2c 62 10 c0 	movl   $0xc010622c,(%esp)
c0100b2b:	e8 77 51 00 00       	call   c0105ca7 <strchr>
c0100b30:	85 c0                	test   %eax,%eax
c0100b32:	74 d5                	je     c0100b09 <parse+0x84>
            buf ++;
        }
    }
c0100b34:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b35:	e9 66 ff ff ff       	jmp    c0100aa0 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b3d:	c9                   	leave  
c0100b3e:	c3                   	ret    

c0100b3f <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b3f:	55                   	push   %ebp
c0100b40:	89 e5                	mov    %esp,%ebp
c0100b42:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4f:	89 04 24             	mov    %eax,(%esp)
c0100b52:	e8 2e ff ff ff       	call   c0100a85 <parse>
c0100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b5e:	75 0a                	jne    c0100b6a <runcmd+0x2b>
        return 0;
c0100b60:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b65:	e9 85 00 00 00       	jmp    c0100bef <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b71:	eb 5c                	jmp    c0100bcf <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b73:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b76:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b79:	89 d0                	mov    %edx,%eax
c0100b7b:	01 c0                	add    %eax,%eax
c0100b7d:	01 d0                	add    %edx,%eax
c0100b7f:	c1 e0 02             	shl    $0x2,%eax
c0100b82:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100b87:	8b 00                	mov    (%eax),%eax
c0100b89:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100b8d:	89 04 24             	mov    %eax,(%esp)
c0100b90:	e8 73 50 00 00       	call   c0105c08 <strcmp>
c0100b95:	85 c0                	test   %eax,%eax
c0100b97:	75 32                	jne    c0100bcb <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b9c:	89 d0                	mov    %edx,%eax
c0100b9e:	01 c0                	add    %eax,%eax
c0100ba0:	01 d0                	add    %edx,%eax
c0100ba2:	c1 e0 02             	shl    $0x2,%eax
c0100ba5:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100baa:	8b 40 08             	mov    0x8(%eax),%eax
c0100bad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bb0:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bb6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bba:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bbd:	83 c2 04             	add    $0x4,%edx
c0100bc0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bc4:	89 0c 24             	mov    %ecx,(%esp)
c0100bc7:	ff d0                	call   *%eax
c0100bc9:	eb 24                	jmp    c0100bef <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd2:	83 f8 02             	cmp    $0x2,%eax
c0100bd5:	76 9c                	jbe    c0100b73 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bd7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bde:	c7 04 24 4f 62 10 c0 	movl   $0xc010624f,(%esp)
c0100be5:	e8 5e f7 ff ff       	call   c0100348 <cprintf>
    return 0;
c0100bea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bef:	c9                   	leave  
c0100bf0:	c3                   	ret    

c0100bf1 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100bf1:	55                   	push   %ebp
c0100bf2:	89 e5                	mov    %esp,%ebp
c0100bf4:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100bf7:	c7 04 24 68 62 10 c0 	movl   $0xc0106268,(%esp)
c0100bfe:	e8 45 f7 ff ff       	call   c0100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c03:	c7 04 24 90 62 10 c0 	movl   $0xc0106290,(%esp)
c0100c0a:	e8 39 f7 ff ff       	call   c0100348 <cprintf>

    if (tf != NULL) {
c0100c0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c13:	74 0b                	je     c0100c20 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c15:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c18:	89 04 24             	mov    %eax,(%esp)
c0100c1b:	e8 67 0e 00 00       	call   c0101a87 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c20:	c7 04 24 b5 62 10 c0 	movl   $0xc01062b5,(%esp)
c0100c27:	e8 13 f6 ff ff       	call   c010023f <readline>
c0100c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c33:	74 18                	je     c0100c4d <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3f:	89 04 24             	mov    %eax,(%esp)
c0100c42:	e8 f8 fe ff ff       	call   c0100b3f <runcmd>
c0100c47:	85 c0                	test   %eax,%eax
c0100c49:	79 02                	jns    c0100c4d <kmonitor+0x5c>
                break;
c0100c4b:	eb 02                	jmp    c0100c4f <kmonitor+0x5e>
            }
        }
    }
c0100c4d:	eb d1                	jmp    c0100c20 <kmonitor+0x2f>
}
c0100c4f:	c9                   	leave  
c0100c50:	c3                   	ret    

c0100c51 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c51:	55                   	push   %ebp
c0100c52:	89 e5                	mov    %esp,%ebp
c0100c54:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c5e:	eb 3f                	jmp    c0100c9f <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c60:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c63:	89 d0                	mov    %edx,%eax
c0100c65:	01 c0                	add    %eax,%eax
c0100c67:	01 d0                	add    %edx,%eax
c0100c69:	c1 e0 02             	shl    $0x2,%eax
c0100c6c:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c71:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c77:	89 d0                	mov    %edx,%eax
c0100c79:	01 c0                	add    %eax,%eax
c0100c7b:	01 d0                	add    %edx,%eax
c0100c7d:	c1 e0 02             	shl    $0x2,%eax
c0100c80:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c85:	8b 00                	mov    (%eax),%eax
c0100c87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8f:	c7 04 24 b9 62 10 c0 	movl   $0xc01062b9,(%esp)
c0100c96:	e8 ad f6 ff ff       	call   c0100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca2:	83 f8 02             	cmp    $0x2,%eax
c0100ca5:	76 b9                	jbe    c0100c60 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cac:	c9                   	leave  
c0100cad:	c3                   	ret    

c0100cae <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cae:	55                   	push   %ebp
c0100caf:	89 e5                	mov    %esp,%ebp
c0100cb1:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cb4:	e8 c3 fb ff ff       	call   c010087c <print_kerninfo>
    return 0;
c0100cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbe:	c9                   	leave  
c0100cbf:	c3                   	ret    

c0100cc0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cc0:	55                   	push   %ebp
c0100cc1:	89 e5                	mov    %esp,%ebp
c0100cc3:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cc6:	e8 fb fc ff ff       	call   c01009c6 <print_stackframe>
    return 0;
c0100ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd0:	c9                   	leave  
c0100cd1:	c3                   	ret    

c0100cd2 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cd2:	55                   	push   %ebp
c0100cd3:	89 e5                	mov    %esp,%ebp
c0100cd5:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cd8:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c0100cdd:	85 c0                	test   %eax,%eax
c0100cdf:	74 02                	je     c0100ce3 <__panic+0x11>
        goto panic_dead;
c0100ce1:	eb 59                	jmp    c0100d3c <__panic+0x6a>
    }
    is_panic = 1;
c0100ce3:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c0100cea:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100ced:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100cfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d01:	c7 04 24 c2 62 10 c0 	movl   $0xc01062c2,(%esp)
c0100d08:	e8 3b f6 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d14:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d17:	89 04 24             	mov    %eax,(%esp)
c0100d1a:	e8 f6 f5 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100d1f:	c7 04 24 de 62 10 c0 	movl   $0xc01062de,(%esp)
c0100d26:	e8 1d f6 ff ff       	call   c0100348 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d2b:	c7 04 24 e0 62 10 c0 	movl   $0xc01062e0,(%esp)
c0100d32:	e8 11 f6 ff ff       	call   c0100348 <cprintf>
    print_stackframe();
c0100d37:	e8 8a fc ff ff       	call   c01009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d3c:	e8 85 09 00 00       	call   c01016c6 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d48:	e8 a4 fe ff ff       	call   c0100bf1 <kmonitor>
    }
c0100d4d:	eb f2                	jmp    c0100d41 <__panic+0x6f>

c0100d4f <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d4f:	55                   	push   %ebp
c0100d50:	89 e5                	mov    %esp,%ebp
c0100d52:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d55:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d5e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d62:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d69:	c7 04 24 f2 62 10 c0 	movl   $0xc01062f2,(%esp)
c0100d70:	e8 d3 f5 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d7c:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d7f:	89 04 24             	mov    %eax,(%esp)
c0100d82:	e8 8e f5 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100d87:	c7 04 24 de 62 10 c0 	movl   $0xc01062de,(%esp)
c0100d8e:	e8 b5 f5 ff ff       	call   c0100348 <cprintf>
    va_end(ap);
}
c0100d93:	c9                   	leave  
c0100d94:	c3                   	ret    

c0100d95 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100d95:	55                   	push   %ebp
c0100d96:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100d98:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c0100d9d:	5d                   	pop    %ebp
c0100d9e:	c3                   	ret    

c0100d9f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d9f:	55                   	push   %ebp
c0100da0:	89 e5                	mov    %esp,%ebp
c0100da2:	83 ec 28             	sub    $0x28,%esp
c0100da5:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100dab:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100daf:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100db3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100db7:	ee                   	out    %al,(%dx)
c0100db8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dbe:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dc2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dc6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dca:	ee                   	out    %al,(%dx)
c0100dcb:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100dd1:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100dd5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dd9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ddd:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dde:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100de5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100de8:	c7 04 24 10 63 10 c0 	movl   $0xc0106310,(%esp)
c0100def:	e8 54 f5 ff ff       	call   c0100348 <cprintf>
    pic_enable(IRQ_TIMER);
c0100df4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100dfb:	e8 24 09 00 00       	call   c0101724 <pic_enable>
}
c0100e00:	c9                   	leave  
c0100e01:	c3                   	ret    

c0100e02 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e02:	55                   	push   %ebp
c0100e03:	89 e5                	mov    %esp,%ebp
c0100e05:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e08:	9c                   	pushf  
c0100e09:	58                   	pop    %eax
c0100e0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e10:	25 00 02 00 00       	and    $0x200,%eax
c0100e15:	85 c0                	test   %eax,%eax
c0100e17:	74 0c                	je     c0100e25 <__intr_save+0x23>
        intr_disable();
c0100e19:	e8 a8 08 00 00       	call   c01016c6 <intr_disable>
        return 1;
c0100e1e:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e23:	eb 05                	jmp    c0100e2a <__intr_save+0x28>
    }
    return 0;
c0100e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e2a:	c9                   	leave  
c0100e2b:	c3                   	ret    

c0100e2c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e2c:	55                   	push   %ebp
c0100e2d:	89 e5                	mov    %esp,%ebp
c0100e2f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e36:	74 05                	je     c0100e3d <__intr_restore+0x11>
        intr_enable();
c0100e38:	e8 83 08 00 00       	call   c01016c0 <intr_enable>
    }
}
c0100e3d:	c9                   	leave  
c0100e3e:	c3                   	ret    

c0100e3f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e3f:	55                   	push   %ebp
c0100e40:	89 e5                	mov    %esp,%ebp
c0100e42:	83 ec 10             	sub    $0x10,%esp
c0100e45:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e4b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e4f:	89 c2                	mov    %eax,%edx
c0100e51:	ec                   	in     (%dx),%al
c0100e52:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e55:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e5b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e5f:	89 c2                	mov    %eax,%edx
c0100e61:	ec                   	in     (%dx),%al
c0100e62:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e65:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e6f:	89 c2                	mov    %eax,%edx
c0100e71:	ec                   	in     (%dx),%al
c0100e72:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e75:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e7b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e7f:	89 c2                	mov    %eax,%edx
c0100e81:	ec                   	in     (%dx),%al
c0100e82:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e85:	c9                   	leave  
c0100e86:	c3                   	ret    

c0100e87 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e87:	55                   	push   %ebp
c0100e88:	89 e5                	mov    %esp,%ebp
c0100e8a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e8d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e97:	0f b7 00             	movzwl (%eax),%eax
c0100e9a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea1:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea9:	0f b7 00             	movzwl (%eax),%eax
c0100eac:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100eb0:	74 12                	je     c0100ec4 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100eb2:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eb9:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100ec0:	b4 03 
c0100ec2:	eb 13                	jmp    c0100ed7 <cga_init+0x50>
    } else {
        *cp = was;
c0100ec4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ecb:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ece:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100ed5:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ed7:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ede:	0f b7 c0             	movzwl %ax,%eax
c0100ee1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ee5:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ee9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100eed:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ef1:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ef2:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ef9:	83 c0 01             	add    $0x1,%eax
c0100efc:	0f b7 c0             	movzwl %ax,%eax
c0100eff:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f03:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f07:	89 c2                	mov    %eax,%edx
c0100f09:	ec                   	in     (%dx),%al
c0100f0a:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f0d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f11:	0f b6 c0             	movzbl %al,%eax
c0100f14:	c1 e0 08             	shl    $0x8,%eax
c0100f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f1a:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f21:	0f b7 c0             	movzwl %ax,%eax
c0100f24:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f28:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f2c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f30:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f34:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f35:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f3c:	83 c0 01             	add    $0x1,%eax
c0100f3f:	0f b7 c0             	movzwl %ax,%eax
c0100f42:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f46:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f4a:	89 c2                	mov    %eax,%edx
c0100f4c:	ec                   	in     (%dx),%al
c0100f4d:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f50:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f54:	0f b6 c0             	movzbl %al,%eax
c0100f57:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f5d:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f65:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f6b:	c9                   	leave  
c0100f6c:	c3                   	ret    

c0100f6d <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f6d:	55                   	push   %ebp
c0100f6e:	89 e5                	mov    %esp,%ebp
c0100f70:	83 ec 48             	sub    $0x48,%esp
c0100f73:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f79:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f7d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f81:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f85:	ee                   	out    %al,(%dx)
c0100f86:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f8c:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f90:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f94:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f98:	ee                   	out    %al,(%dx)
c0100f99:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100f9f:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fa3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fa7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fab:	ee                   	out    %al,(%dx)
c0100fac:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fb2:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fb6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fbe:	ee                   	out    %al,(%dx)
c0100fbf:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fc5:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fc9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fcd:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fd1:	ee                   	out    %al,(%dx)
c0100fd2:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fd8:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100fdc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fe0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fe4:	ee                   	out    %al,(%dx)
c0100fe5:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100feb:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100fef:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100ff3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100ff7:	ee                   	out    %al,(%dx)
c0100ff8:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ffe:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101002:	89 c2                	mov    %eax,%edx
c0101004:	ec                   	in     (%dx),%al
c0101005:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101008:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010100c:	3c ff                	cmp    $0xff,%al
c010100e:	0f 95 c0             	setne  %al
c0101011:	0f b6 c0             	movzbl %al,%eax
c0101014:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0101019:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010101f:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101023:	89 c2                	mov    %eax,%edx
c0101025:	ec                   	in     (%dx),%al
c0101026:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101029:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c010102f:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101033:	89 c2                	mov    %eax,%edx
c0101035:	ec                   	in     (%dx),%al
c0101036:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101039:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010103e:	85 c0                	test   %eax,%eax
c0101040:	74 0c                	je     c010104e <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101042:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101049:	e8 d6 06 00 00       	call   c0101724 <pic_enable>
    }
}
c010104e:	c9                   	leave  
c010104f:	c3                   	ret    

c0101050 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101050:	55                   	push   %ebp
c0101051:	89 e5                	mov    %esp,%ebp
c0101053:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101056:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010105d:	eb 09                	jmp    c0101068 <lpt_putc_sub+0x18>
        delay();
c010105f:	e8 db fd ff ff       	call   c0100e3f <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101064:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101068:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010106e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101072:	89 c2                	mov    %eax,%edx
c0101074:	ec                   	in     (%dx),%al
c0101075:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101078:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010107c:	84 c0                	test   %al,%al
c010107e:	78 09                	js     c0101089 <lpt_putc_sub+0x39>
c0101080:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101087:	7e d6                	jle    c010105f <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101089:	8b 45 08             	mov    0x8(%ebp),%eax
c010108c:	0f b6 c0             	movzbl %al,%eax
c010108f:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101095:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101098:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010109c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010a0:	ee                   	out    %al,(%dx)
c01010a1:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010a7:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010ab:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010af:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010b3:	ee                   	out    %al,(%dx)
c01010b4:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010ba:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010c6:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010c7:	c9                   	leave  
c01010c8:	c3                   	ret    

c01010c9 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010c9:	55                   	push   %ebp
c01010ca:	89 e5                	mov    %esp,%ebp
c01010cc:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010cf:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010d3:	74 0d                	je     c01010e2 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01010d8:	89 04 24             	mov    %eax,(%esp)
c01010db:	e8 70 ff ff ff       	call   c0101050 <lpt_putc_sub>
c01010e0:	eb 24                	jmp    c0101106 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010e2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010e9:	e8 62 ff ff ff       	call   c0101050 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010f5:	e8 56 ff ff ff       	call   c0101050 <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101101:	e8 4a ff ff ff       	call   c0101050 <lpt_putc_sub>
    }
}
c0101106:	c9                   	leave  
c0101107:	c3                   	ret    

c0101108 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101108:	55                   	push   %ebp
c0101109:	89 e5                	mov    %esp,%ebp
c010110b:	53                   	push   %ebx
c010110c:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010110f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101112:	b0 00                	mov    $0x0,%al
c0101114:	85 c0                	test   %eax,%eax
c0101116:	75 07                	jne    c010111f <cga_putc+0x17>
        c |= 0x0700;
c0101118:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010111f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101122:	0f b6 c0             	movzbl %al,%eax
c0101125:	83 f8 0a             	cmp    $0xa,%eax
c0101128:	74 4c                	je     c0101176 <cga_putc+0x6e>
c010112a:	83 f8 0d             	cmp    $0xd,%eax
c010112d:	74 57                	je     c0101186 <cga_putc+0x7e>
c010112f:	83 f8 08             	cmp    $0x8,%eax
c0101132:	0f 85 88 00 00 00    	jne    c01011c0 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101138:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010113f:	66 85 c0             	test   %ax,%ax
c0101142:	74 30                	je     c0101174 <cga_putc+0x6c>
            crt_pos --;
c0101144:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010114b:	83 e8 01             	sub    $0x1,%eax
c010114e:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101154:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101159:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c0101160:	0f b7 d2             	movzwl %dx,%edx
c0101163:	01 d2                	add    %edx,%edx
c0101165:	01 c2                	add    %eax,%edx
c0101167:	8b 45 08             	mov    0x8(%ebp),%eax
c010116a:	b0 00                	mov    $0x0,%al
c010116c:	83 c8 20             	or     $0x20,%eax
c010116f:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101172:	eb 72                	jmp    c01011e6 <cga_putc+0xde>
c0101174:	eb 70                	jmp    c01011e6 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101176:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010117d:	83 c0 50             	add    $0x50,%eax
c0101180:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101186:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c010118d:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101194:	0f b7 c1             	movzwl %cx,%eax
c0101197:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010119d:	c1 e8 10             	shr    $0x10,%eax
c01011a0:	89 c2                	mov    %eax,%edx
c01011a2:	66 c1 ea 06          	shr    $0x6,%dx
c01011a6:	89 d0                	mov    %edx,%eax
c01011a8:	c1 e0 02             	shl    $0x2,%eax
c01011ab:	01 d0                	add    %edx,%eax
c01011ad:	c1 e0 04             	shl    $0x4,%eax
c01011b0:	29 c1                	sub    %eax,%ecx
c01011b2:	89 ca                	mov    %ecx,%edx
c01011b4:	89 d8                	mov    %ebx,%eax
c01011b6:	29 d0                	sub    %edx,%eax
c01011b8:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011be:	eb 26                	jmp    c01011e6 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011c0:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011c6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011cd:	8d 50 01             	lea    0x1(%eax),%edx
c01011d0:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011d7:	0f b7 c0             	movzwl %ax,%eax
c01011da:	01 c0                	add    %eax,%eax
c01011dc:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011df:	8b 45 08             	mov    0x8(%ebp),%eax
c01011e2:	66 89 02             	mov    %ax,(%edx)
        break;
c01011e5:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011e6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ed:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011f1:	76 5b                	jbe    c010124e <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011f3:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011f8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011fe:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101203:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010120a:	00 
c010120b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010120f:	89 04 24             	mov    %eax,(%esp)
c0101212:	e8 8e 4c 00 00       	call   c0105ea5 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101217:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010121e:	eb 15                	jmp    c0101235 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101220:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101225:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101228:	01 d2                	add    %edx,%edx
c010122a:	01 d0                	add    %edx,%eax
c010122c:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101235:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010123c:	7e e2                	jle    c0101220 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010123e:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101245:	83 e8 50             	sub    $0x50,%eax
c0101248:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010124e:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101255:	0f b7 c0             	movzwl %ax,%eax
c0101258:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010125c:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101260:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101264:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101268:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101269:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101270:	66 c1 e8 08          	shr    $0x8,%ax
c0101274:	0f b6 c0             	movzbl %al,%eax
c0101277:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c010127e:	83 c2 01             	add    $0x1,%edx
c0101281:	0f b7 d2             	movzwl %dx,%edx
c0101284:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101288:	88 45 ed             	mov    %al,-0x13(%ebp)
c010128b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010128f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101293:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101294:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010129b:	0f b7 c0             	movzwl %ax,%eax
c010129e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012a2:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012a6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012aa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012af:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012b6:	0f b6 c0             	movzbl %al,%eax
c01012b9:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012c0:	83 c2 01             	add    $0x1,%edx
c01012c3:	0f b7 d2             	movzwl %dx,%edx
c01012c6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012ca:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012cd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012d1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012d5:	ee                   	out    %al,(%dx)
}
c01012d6:	83 c4 34             	add    $0x34,%esp
c01012d9:	5b                   	pop    %ebx
c01012da:	5d                   	pop    %ebp
c01012db:	c3                   	ret    

c01012dc <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012dc:	55                   	push   %ebp
c01012dd:	89 e5                	mov    %esp,%ebp
c01012df:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012e9:	eb 09                	jmp    c01012f4 <serial_putc_sub+0x18>
        delay();
c01012eb:	e8 4f fb ff ff       	call   c0100e3f <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012f0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012f4:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012fa:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01012fe:	89 c2                	mov    %eax,%edx
c0101300:	ec                   	in     (%dx),%al
c0101301:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101304:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101308:	0f b6 c0             	movzbl %al,%eax
c010130b:	83 e0 20             	and    $0x20,%eax
c010130e:	85 c0                	test   %eax,%eax
c0101310:	75 09                	jne    c010131b <serial_putc_sub+0x3f>
c0101312:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101319:	7e d0                	jle    c01012eb <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010131b:	8b 45 08             	mov    0x8(%ebp),%eax
c010131e:	0f b6 c0             	movzbl %al,%eax
c0101321:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101327:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010132a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010132e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101332:	ee                   	out    %al,(%dx)
}
c0101333:	c9                   	leave  
c0101334:	c3                   	ret    

c0101335 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101335:	55                   	push   %ebp
c0101336:	89 e5                	mov    %esp,%ebp
c0101338:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010133b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010133f:	74 0d                	je     c010134e <serial_putc+0x19>
        serial_putc_sub(c);
c0101341:	8b 45 08             	mov    0x8(%ebp),%eax
c0101344:	89 04 24             	mov    %eax,(%esp)
c0101347:	e8 90 ff ff ff       	call   c01012dc <serial_putc_sub>
c010134c:	eb 24                	jmp    c0101372 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c010134e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101355:	e8 82 ff ff ff       	call   c01012dc <serial_putc_sub>
        serial_putc_sub(' ');
c010135a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101361:	e8 76 ff ff ff       	call   c01012dc <serial_putc_sub>
        serial_putc_sub('\b');
c0101366:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010136d:	e8 6a ff ff ff       	call   c01012dc <serial_putc_sub>
    }
}
c0101372:	c9                   	leave  
c0101373:	c3                   	ret    

c0101374 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101374:	55                   	push   %ebp
c0101375:	89 e5                	mov    %esp,%ebp
c0101377:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010137a:	eb 33                	jmp    c01013af <cons_intr+0x3b>
        if (c != 0) {
c010137c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101380:	74 2d                	je     c01013af <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101382:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101387:	8d 50 01             	lea    0x1(%eax),%edx
c010138a:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c0101390:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101393:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101399:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010139e:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013a3:	75 0a                	jne    c01013af <cons_intr+0x3b>
                cons.wpos = 0;
c01013a5:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c01013ac:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013af:	8b 45 08             	mov    0x8(%ebp),%eax
c01013b2:	ff d0                	call   *%eax
c01013b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013b7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013bb:	75 bf                	jne    c010137c <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013bd:	c9                   	leave  
c01013be:	c3                   	ret    

c01013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013bf:	55                   	push   %ebp
c01013c0:	89 e5                	mov    %esp,%ebp
c01013c2:	83 ec 10             	sub    $0x10,%esp
c01013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013cf:	89 c2                	mov    %eax,%edx
c01013d1:	ec                   	in     (%dx),%al
c01013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013d9:	0f b6 c0             	movzbl %al,%eax
c01013dc:	83 e0 01             	and    $0x1,%eax
c01013df:	85 c0                	test   %eax,%eax
c01013e1:	75 07                	jne    c01013ea <serial_proc_data+0x2b>
        return -1;
c01013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013e8:	eb 2a                	jmp    c0101414 <serial_proc_data+0x55>
c01013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013f4:	89 c2                	mov    %eax,%edx
c01013f6:	ec                   	in     (%dx),%al
c01013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013fe:	0f b6 c0             	movzbl %al,%eax
c0101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101408:	75 07                	jne    c0101411 <serial_proc_data+0x52>
        c = '\b';
c010140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101414:	c9                   	leave  
c0101415:	c3                   	ret    

c0101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101416:	55                   	push   %ebp
c0101417:	89 e5                	mov    %esp,%ebp
c0101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010141c:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101421:	85 c0                	test   %eax,%eax
c0101423:	74 0c                	je     c0101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101425:	c7 04 24 bf 13 10 c0 	movl   $0xc01013bf,(%esp)
c010142c:	e8 43 ff ff ff       	call   c0101374 <cons_intr>
    }
}
c0101431:	c9                   	leave  
c0101432:	c3                   	ret    

c0101433 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101433:	55                   	push   %ebp
c0101434:	89 e5                	mov    %esp,%ebp
c0101436:	83 ec 38             	sub    $0x38,%esp
c0101439:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010143f:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101443:	89 c2                	mov    %eax,%edx
c0101445:	ec                   	in     (%dx),%al
c0101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010144d:	0f b6 c0             	movzbl %al,%eax
c0101450:	83 e0 01             	and    $0x1,%eax
c0101453:	85 c0                	test   %eax,%eax
c0101455:	75 0a                	jne    c0101461 <kbd_proc_data+0x2e>
        return -1;
c0101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010145c:	e9 59 01 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
c0101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101467:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010146b:	89 c2                	mov    %eax,%edx
c010146d:	ec                   	in     (%dx),%al
c010146e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101471:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101475:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101478:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010147c:	75 17                	jne    c0101495 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010147e:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101483:	83 c8 40             	or     $0x40,%eax
c0101486:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c010148b:	b8 00 00 00 00       	mov    $0x0,%eax
c0101490:	e9 25 01 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101495:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101499:	84 c0                	test   %al,%al
c010149b:	79 47                	jns    c01014e4 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010149d:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014a2:	83 e0 40             	and    $0x40,%eax
c01014a5:	85 c0                	test   %eax,%eax
c01014a7:	75 09                	jne    c01014b2 <kbd_proc_data+0x7f>
c01014a9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ad:	83 e0 7f             	and    $0x7f,%eax
c01014b0:	eb 04                	jmp    c01014b6 <kbd_proc_data+0x83>
c01014b2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b6:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014b9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bd:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014c4:	83 c8 40             	or     $0x40,%eax
c01014c7:	0f b6 c0             	movzbl %al,%eax
c01014ca:	f7 d0                	not    %eax
c01014cc:	89 c2                	mov    %eax,%edx
c01014ce:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014d3:	21 d0                	and    %edx,%eax
c01014d5:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014da:	b8 00 00 00 00       	mov    $0x0,%eax
c01014df:	e9 d6 00 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014e4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014e9:	83 e0 40             	and    $0x40,%eax
c01014ec:	85 c0                	test   %eax,%eax
c01014ee:	74 11                	je     c0101501 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014f0:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014f4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f9:	83 e0 bf             	and    $0xffffffbf,%eax
c01014fc:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c0101501:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101505:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c010150c:	0f b6 d0             	movzbl %al,%edx
c010150f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101514:	09 d0                	or     %edx,%eax
c0101516:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c010151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151f:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101526:	0f b6 d0             	movzbl %al,%edx
c0101529:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010152e:	31 d0                	xor    %edx,%eax
c0101530:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101535:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010153a:	83 e0 03             	and    $0x3,%eax
c010153d:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101544:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101548:	01 d0                	add    %edx,%eax
c010154a:	0f b6 00             	movzbl (%eax),%eax
c010154d:	0f b6 c0             	movzbl %al,%eax
c0101550:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101553:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101558:	83 e0 08             	and    $0x8,%eax
c010155b:	85 c0                	test   %eax,%eax
c010155d:	74 22                	je     c0101581 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010155f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101563:	7e 0c                	jle    c0101571 <kbd_proc_data+0x13e>
c0101565:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101569:	7f 06                	jg     c0101571 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010156b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010156f:	eb 10                	jmp    c0101581 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101571:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101575:	7e 0a                	jle    c0101581 <kbd_proc_data+0x14e>
c0101577:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010157b:	7f 04                	jg     c0101581 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010157d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101581:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101586:	f7 d0                	not    %eax
c0101588:	83 e0 06             	and    $0x6,%eax
c010158b:	85 c0                	test   %eax,%eax
c010158d:	75 28                	jne    c01015b7 <kbd_proc_data+0x184>
c010158f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101596:	75 1f                	jne    c01015b7 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101598:	c7 04 24 2b 63 10 c0 	movl   $0xc010632b,(%esp)
c010159f:	e8 a4 ed ff ff       	call   c0100348 <cprintf>
c01015a4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015aa:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ae:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015b2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015b6:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015ba:	c9                   	leave  
c01015bb:	c3                   	ret    

c01015bc <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015bc:	55                   	push   %ebp
c01015bd:	89 e5                	mov    %esp,%ebp
c01015bf:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015c2:	c7 04 24 33 14 10 c0 	movl   $0xc0101433,(%esp)
c01015c9:	e8 a6 fd ff ff       	call   c0101374 <cons_intr>
}
c01015ce:	c9                   	leave  
c01015cf:	c3                   	ret    

c01015d0 <kbd_init>:

static void
kbd_init(void) {
c01015d0:	55                   	push   %ebp
c01015d1:	89 e5                	mov    %esp,%ebp
c01015d3:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015d6:	e8 e1 ff ff ff       	call   c01015bc <kbd_intr>
    pic_enable(IRQ_KBD);
c01015db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015e2:	e8 3d 01 00 00       	call   c0101724 <pic_enable>
}
c01015e7:	c9                   	leave  
c01015e8:	c3                   	ret    

c01015e9 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015e9:	55                   	push   %ebp
c01015ea:	89 e5                	mov    %esp,%ebp
c01015ec:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015ef:	e8 93 f8 ff ff       	call   c0100e87 <cga_init>
    serial_init();
c01015f4:	e8 74 f9 ff ff       	call   c0100f6d <serial_init>
    kbd_init();
c01015f9:	e8 d2 ff ff ff       	call   c01015d0 <kbd_init>
    if (!serial_exists) {
c01015fe:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101603:	85 c0                	test   %eax,%eax
c0101605:	75 0c                	jne    c0101613 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101607:	c7 04 24 37 63 10 c0 	movl   $0xc0106337,(%esp)
c010160e:	e8 35 ed ff ff       	call   c0100348 <cprintf>
    }
}
c0101613:	c9                   	leave  
c0101614:	c3                   	ret    

c0101615 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101615:	55                   	push   %ebp
c0101616:	89 e5                	mov    %esp,%ebp
c0101618:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010161b:	e8 e2 f7 ff ff       	call   c0100e02 <__intr_save>
c0101620:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101623:	8b 45 08             	mov    0x8(%ebp),%eax
c0101626:	89 04 24             	mov    %eax,(%esp)
c0101629:	e8 9b fa ff ff       	call   c01010c9 <lpt_putc>
        cga_putc(c);
c010162e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101631:	89 04 24             	mov    %eax,(%esp)
c0101634:	e8 cf fa ff ff       	call   c0101108 <cga_putc>
        serial_putc(c);
c0101639:	8b 45 08             	mov    0x8(%ebp),%eax
c010163c:	89 04 24             	mov    %eax,(%esp)
c010163f:	e8 f1 fc ff ff       	call   c0101335 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101644:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101647:	89 04 24             	mov    %eax,(%esp)
c010164a:	e8 dd f7 ff ff       	call   c0100e2c <__intr_restore>
}
c010164f:	c9                   	leave  
c0101650:	c3                   	ret    

c0101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101651:	55                   	push   %ebp
c0101652:	89 e5                	mov    %esp,%ebp
c0101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010165e:	e8 9f f7 ff ff       	call   c0100e02 <__intr_save>
c0101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101666:	e8 ab fd ff ff       	call   c0101416 <serial_intr>
        kbd_intr();
c010166b:	e8 4c ff ff ff       	call   c01015bc <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101670:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101676:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010167b:	39 c2                	cmp    %eax,%edx
c010167d:	74 31                	je     c01016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010167f:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c0101684:	8d 50 01             	lea    0x1(%eax),%edx
c0101687:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c010168d:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c0101694:	0f b6 c0             	movzbl %al,%eax
c0101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010169a:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010169f:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016a4:	75 0a                	jne    c01016b0 <cons_getc+0x5f>
                cons.rpos = 0;
c01016a6:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016b3:	89 04 24             	mov    %eax,(%esp)
c01016b6:	e8 71 f7 ff ff       	call   c0100e2c <__intr_restore>
    return c;
c01016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016be:	c9                   	leave  
c01016bf:	c3                   	ret    

c01016c0 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01016c0:	55                   	push   %ebp
c01016c1:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01016c3:	fb                   	sti    
    sti();
}
c01016c4:	5d                   	pop    %ebp
c01016c5:	c3                   	ret    

c01016c6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01016c6:	55                   	push   %ebp
c01016c7:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01016c9:	fa                   	cli    
    cli();
}
c01016ca:	5d                   	pop    %ebp
c01016cb:	c3                   	ret    

c01016cc <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016cc:	55                   	push   %ebp
c01016cd:	89 e5                	mov    %esp,%ebp
c01016cf:	83 ec 14             	sub    $0x14,%esp
c01016d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016d9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016dd:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016e3:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016e8:	85 c0                	test   %eax,%eax
c01016ea:	74 36                	je     c0101722 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016f0:	0f b6 c0             	movzbl %al,%eax
c01016f3:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016f9:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016fc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101700:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101704:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101705:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101709:	66 c1 e8 08          	shr    $0x8,%ax
c010170d:	0f b6 c0             	movzbl %al,%eax
c0101710:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101716:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101719:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010171d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101721:	ee                   	out    %al,(%dx)
    }
}
c0101722:	c9                   	leave  
c0101723:	c3                   	ret    

c0101724 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101724:	55                   	push   %ebp
c0101725:	89 e5                	mov    %esp,%ebp
c0101727:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010172a:	8b 45 08             	mov    0x8(%ebp),%eax
c010172d:	ba 01 00 00 00       	mov    $0x1,%edx
c0101732:	89 c1                	mov    %eax,%ecx
c0101734:	d3 e2                	shl    %cl,%edx
c0101736:	89 d0                	mov    %edx,%eax
c0101738:	f7 d0                	not    %eax
c010173a:	89 c2                	mov    %eax,%edx
c010173c:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101743:	21 d0                	and    %edx,%eax
c0101745:	0f b7 c0             	movzwl %ax,%eax
c0101748:	89 04 24             	mov    %eax,(%esp)
c010174b:	e8 7c ff ff ff       	call   c01016cc <pic_setmask>
}
c0101750:	c9                   	leave  
c0101751:	c3                   	ret    

c0101752 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101752:	55                   	push   %ebp
c0101753:	89 e5                	mov    %esp,%ebp
c0101755:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101758:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c010175f:	00 00 00 
c0101762:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101768:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010176c:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101770:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101774:	ee                   	out    %al,(%dx)
c0101775:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010177b:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010177f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101783:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101787:	ee                   	out    %al,(%dx)
c0101788:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010178e:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0101792:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101796:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010179a:	ee                   	out    %al,(%dx)
c010179b:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c01017a1:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01017a5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01017a9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017ad:	ee                   	out    %al,(%dx)
c01017ae:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01017b4:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01017b8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017bc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017c0:	ee                   	out    %al,(%dx)
c01017c1:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017c7:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017cb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017cf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017d3:	ee                   	out    %al,(%dx)
c01017d4:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017da:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017de:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017e2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017e6:	ee                   	out    %al,(%dx)
c01017e7:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01017ed:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01017f1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017f5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017f9:	ee                   	out    %al,(%dx)
c01017fa:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0101800:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0101804:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101808:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010180c:	ee                   	out    %al,(%dx)
c010180d:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101813:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101817:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010181b:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010181f:	ee                   	out    %al,(%dx)
c0101820:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101826:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c010182a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010182e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101832:	ee                   	out    %al,(%dx)
c0101833:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101839:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c010183d:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101841:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101845:	ee                   	out    %al,(%dx)
c0101846:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010184c:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c0101850:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101854:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101858:	ee                   	out    %al,(%dx)
c0101859:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c010185f:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0101863:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101867:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010186b:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010186c:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101873:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101877:	74 12                	je     c010188b <pic_init+0x139>
        pic_setmask(irq_mask);
c0101879:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101880:	0f b7 c0             	movzwl %ax,%eax
c0101883:	89 04 24             	mov    %eax,(%esp)
c0101886:	e8 41 fe ff ff       	call   c01016cc <pic_setmask>
    }
}
c010188b:	c9                   	leave  
c010188c:	c3                   	ret    

c010188d <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
c010188d:	55                   	push   %ebp
c010188e:	89 e5                	mov    %esp,%ebp
c0101890:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101893:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010189a:	00 
c010189b:	c7 04 24 60 63 10 c0 	movl   $0xc0106360,(%esp)
c01018a2:	e8 a1 ea ff ff       	call   c0100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01018a7:	c7 04 24 6a 63 10 c0 	movl   $0xc010636a,(%esp)
c01018ae:	e8 95 ea ff ff       	call   c0100348 <cprintf>
    panic("EOT: kernel seems ok.");
c01018b3:	c7 44 24 08 78 63 10 	movl   $0xc0106378,0x8(%esp)
c01018ba:	c0 
c01018bb:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c01018c2:	00 
c01018c3:	c7 04 24 8e 63 10 c0 	movl   $0xc010638e,(%esp)
c01018ca:	e8 03 f4 ff ff       	call   c0100cd2 <__panic>

c01018cf <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018cf:	55                   	push   %ebp
c01018d0:	89 e5                	mov    %esp,%ebp
c01018d2:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01018d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018dc:	e9 c3 00 00 00       	jmp    c01019a4 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e4:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018eb:	89 c2                	mov    %eax,%edx
c01018ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f0:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018f7:	c0 
c01018f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018fb:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c0101902:	c0 08 00 
c0101905:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101908:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c010190f:	c0 
c0101910:	83 e2 e0             	and    $0xffffffe0,%edx
c0101913:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c010191a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010191d:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c0101924:	c0 
c0101925:	83 e2 1f             	and    $0x1f,%edx
c0101928:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c010192f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101932:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101939:	c0 
c010193a:	83 e2 f0             	and    $0xfffffff0,%edx
c010193d:	83 ca 0e             	or     $0xe,%edx
c0101940:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101947:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010194a:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101951:	c0 
c0101952:	83 e2 ef             	and    $0xffffffef,%edx
c0101955:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010195c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010195f:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101966:	c0 
c0101967:	83 e2 9f             	and    $0xffffff9f,%edx
c010196a:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101971:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101974:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010197b:	c0 
c010197c:	83 ca 80             	or     $0xffffff80,%edx
c010197f:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101986:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101989:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c0101990:	c1 e8 10             	shr    $0x10,%eax
c0101993:	89 c2                	mov    %eax,%edx
c0101995:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101998:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c010199f:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01019a0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01019a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019a7:	3d ff 00 00 00       	cmp    $0xff,%eax
c01019ac:	0f 86 2f ff ff ff    	jbe    c01018e1 <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c01019b2:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c01019b7:	66 a3 48 aa 11 c0    	mov    %ax,0xc011aa48
c01019bd:	66 c7 05 4a aa 11 c0 	movw   $0x8,0xc011aa4a
c01019c4:	08 00 
c01019c6:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019cd:	83 e0 e0             	and    $0xffffffe0,%eax
c01019d0:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019d5:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019dc:	83 e0 1f             	and    $0x1f,%eax
c01019df:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019e4:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019eb:	83 e0 f0             	and    $0xfffffff0,%eax
c01019ee:	83 c8 0e             	or     $0xe,%eax
c01019f1:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019f6:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019fd:	83 e0 ef             	and    $0xffffffef,%eax
c0101a00:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a05:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a0c:	83 c8 60             	or     $0x60,%eax
c0101a0f:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a14:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a1b:	83 c8 80             	or     $0xffffff80,%eax
c0101a1e:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a23:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c0101a28:	c1 e8 10             	shr    $0x10,%eax
c0101a2b:	66 a3 4e aa 11 c0    	mov    %ax,0xc011aa4e
c0101a31:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a38:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a3b:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idt_pd);
}
c0101a3e:	c9                   	leave  
c0101a3f:	c3                   	ret    

c0101a40 <trapname>:

static const char *
trapname(int trapno) {
c0101a40:	55                   	push   %ebp
c0101a41:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a43:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a46:	83 f8 13             	cmp    $0x13,%eax
c0101a49:	77 0c                	ja     c0101a57 <trapname+0x17>
        return excnames[trapno];
c0101a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4e:	8b 04 85 e0 66 10 c0 	mov    -0x3fef9920(,%eax,4),%eax
c0101a55:	eb 18                	jmp    c0101a6f <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a57:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a5b:	7e 0d                	jle    c0101a6a <trapname+0x2a>
c0101a5d:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a61:	7f 07                	jg     c0101a6a <trapname+0x2a>
        return "Hardware Interrupt";
c0101a63:	b8 9f 63 10 c0       	mov    $0xc010639f,%eax
c0101a68:	eb 05                	jmp    c0101a6f <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a6a:	b8 b2 63 10 c0       	mov    $0xc01063b2,%eax
}
c0101a6f:	5d                   	pop    %ebp
c0101a70:	c3                   	ret    

c0101a71 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a71:	55                   	push   %ebp
c0101a72:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a77:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a7b:	66 83 f8 08          	cmp    $0x8,%ax
c0101a7f:	0f 94 c0             	sete   %al
c0101a82:	0f b6 c0             	movzbl %al,%eax
}
c0101a85:	5d                   	pop    %ebp
c0101a86:	c3                   	ret    

c0101a87 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a87:	55                   	push   %ebp
c0101a88:	89 e5                	mov    %esp,%ebp
c0101a8a:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a94:	c7 04 24 f3 63 10 c0 	movl   $0xc01063f3,(%esp)
c0101a9b:	e8 a8 e8 ff ff       	call   c0100348 <cprintf>
    print_regs(&tf->tf_regs);
c0101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa3:	89 04 24             	mov    %eax,(%esp)
c0101aa6:	e8 a1 01 00 00       	call   c0101c4c <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101aab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aae:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101ab2:	0f b7 c0             	movzwl %ax,%eax
c0101ab5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab9:	c7 04 24 04 64 10 c0 	movl   $0xc0106404,(%esp)
c0101ac0:	e8 83 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac8:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101acc:	0f b7 c0             	movzwl %ax,%eax
c0101acf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ad3:	c7 04 24 17 64 10 c0 	movl   $0xc0106417,(%esp)
c0101ada:	e8 69 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101adf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae2:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101ae6:	0f b7 c0             	movzwl %ax,%eax
c0101ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aed:	c7 04 24 2a 64 10 c0 	movl   $0xc010642a,(%esp)
c0101af4:	e8 4f e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101af9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101afc:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101b00:	0f b7 c0             	movzwl %ax,%eax
c0101b03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b07:	c7 04 24 3d 64 10 c0 	movl   $0xc010643d,(%esp)
c0101b0e:	e8 35 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101b13:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b16:	8b 40 30             	mov    0x30(%eax),%eax
c0101b19:	89 04 24             	mov    %eax,(%esp)
c0101b1c:	e8 1f ff ff ff       	call   c0101a40 <trapname>
c0101b21:	8b 55 08             	mov    0x8(%ebp),%edx
c0101b24:	8b 52 30             	mov    0x30(%edx),%edx
c0101b27:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101b2b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b2f:	c7 04 24 50 64 10 c0 	movl   $0xc0106450,(%esp)
c0101b36:	e8 0d e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b3e:	8b 40 34             	mov    0x34(%eax),%eax
c0101b41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b45:	c7 04 24 62 64 10 c0 	movl   $0xc0106462,(%esp)
c0101b4c:	e8 f7 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b54:	8b 40 38             	mov    0x38(%eax),%eax
c0101b57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b5b:	c7 04 24 71 64 10 c0 	movl   $0xc0106471,(%esp)
c0101b62:	e8 e1 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b67:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b6e:	0f b7 c0             	movzwl %ax,%eax
c0101b71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b75:	c7 04 24 80 64 10 c0 	movl   $0xc0106480,(%esp)
c0101b7c:	e8 c7 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b81:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b84:	8b 40 40             	mov    0x40(%eax),%eax
c0101b87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b8b:	c7 04 24 93 64 10 c0 	movl   $0xc0106493,(%esp)
c0101b92:	e8 b1 e7 ff ff       	call   c0100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b9e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101ba5:	eb 3e                	jmp    c0101be5 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101ba7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101baa:	8b 50 40             	mov    0x40(%eax),%edx
c0101bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101bb0:	21 d0                	and    %edx,%eax
c0101bb2:	85 c0                	test   %eax,%eax
c0101bb4:	74 28                	je     c0101bde <print_trapframe+0x157>
c0101bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bb9:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101bc0:	85 c0                	test   %eax,%eax
c0101bc2:	74 1a                	je     c0101bde <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bc7:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101bce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd2:	c7 04 24 a2 64 10 c0 	movl   $0xc01064a2,(%esp)
c0101bd9:	e8 6a e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bde:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101be2:	d1 65 f0             	shll   -0x10(%ebp)
c0101be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101be8:	83 f8 17             	cmp    $0x17,%eax
c0101beb:	76 ba                	jbe    c0101ba7 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bed:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf0:	8b 40 40             	mov    0x40(%eax),%eax
c0101bf3:	25 00 30 00 00       	and    $0x3000,%eax
c0101bf8:	c1 e8 0c             	shr    $0xc,%eax
c0101bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bff:	c7 04 24 a6 64 10 c0 	movl   $0xc01064a6,(%esp)
c0101c06:	e8 3d e7 ff ff       	call   c0100348 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0e:	89 04 24             	mov    %eax,(%esp)
c0101c11:	e8 5b fe ff ff       	call   c0101a71 <trap_in_kernel>
c0101c16:	85 c0                	test   %eax,%eax
c0101c18:	75 30                	jne    c0101c4a <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c1d:	8b 40 44             	mov    0x44(%eax),%eax
c0101c20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c24:	c7 04 24 af 64 10 c0 	movl   $0xc01064af,(%esp)
c0101c2b:	e8 18 e7 ff ff       	call   c0100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c30:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c33:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c37:	0f b7 c0             	movzwl %ax,%eax
c0101c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c3e:	c7 04 24 be 64 10 c0 	movl   $0xc01064be,(%esp)
c0101c45:	e8 fe e6 ff ff       	call   c0100348 <cprintf>
    }
}
c0101c4a:	c9                   	leave  
c0101c4b:	c3                   	ret    

c0101c4c <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c4c:	55                   	push   %ebp
c0101c4d:	89 e5                	mov    %esp,%ebp
c0101c4f:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c52:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c55:	8b 00                	mov    (%eax),%eax
c0101c57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c5b:	c7 04 24 d1 64 10 c0 	movl   $0xc01064d1,(%esp)
c0101c62:	e8 e1 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c67:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c6a:	8b 40 04             	mov    0x4(%eax),%eax
c0101c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c71:	c7 04 24 e0 64 10 c0 	movl   $0xc01064e0,(%esp)
c0101c78:	e8 cb e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c80:	8b 40 08             	mov    0x8(%eax),%eax
c0101c83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c87:	c7 04 24 ef 64 10 c0 	movl   $0xc01064ef,(%esp)
c0101c8e:	e8 b5 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c93:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c96:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c9d:	c7 04 24 fe 64 10 c0 	movl   $0xc01064fe,(%esp)
c0101ca4:	e8 9f e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cac:	8b 40 10             	mov    0x10(%eax),%eax
c0101caf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb3:	c7 04 24 0d 65 10 c0 	movl   $0xc010650d,(%esp)
c0101cba:	e8 89 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101cbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cc2:	8b 40 14             	mov    0x14(%eax),%eax
c0101cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cc9:	c7 04 24 1c 65 10 c0 	movl   $0xc010651c,(%esp)
c0101cd0:	e8 73 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101cd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd8:	8b 40 18             	mov    0x18(%eax),%eax
c0101cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cdf:	c7 04 24 2b 65 10 c0 	movl   $0xc010652b,(%esp)
c0101ce6:	e8 5d e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cee:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf5:	c7 04 24 3a 65 10 c0 	movl   $0xc010653a,(%esp)
c0101cfc:	e8 47 e6 ff ff       	call   c0100348 <cprintf>
}
c0101d01:	c9                   	leave  
c0101d02:	c3                   	ret    

c0101d03 <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101d03:	55                   	push   %ebp
c0101d04:	89 e5                	mov    %esp,%ebp
c0101d06:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101d09:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d0c:	8b 40 30             	mov    0x30(%eax),%eax
c0101d0f:	83 f8 2f             	cmp    $0x2f,%eax
c0101d12:	77 21                	ja     c0101d35 <trap_dispatch+0x32>
c0101d14:	83 f8 2e             	cmp    $0x2e,%eax
c0101d17:	0f 83 ee 00 00 00    	jae    c0101e0b <trap_dispatch+0x108>
c0101d1d:	83 f8 21             	cmp    $0x21,%eax
c0101d20:	0f 84 87 00 00 00    	je     c0101dad <trap_dispatch+0xaa>
c0101d26:	83 f8 24             	cmp    $0x24,%eax
c0101d29:	74 5c                	je     c0101d87 <trap_dispatch+0x84>
c0101d2b:	83 f8 20             	cmp    $0x20,%eax
c0101d2e:	74 1c                	je     c0101d4c <trap_dispatch+0x49>
c0101d30:	e9 9e 00 00 00       	jmp    c0101dd3 <trap_dispatch+0xd0>
c0101d35:	83 f8 78             	cmp    $0x78,%eax
c0101d38:	0f 84 d0 00 00 00    	je     c0101e0e <trap_dispatch+0x10b>
c0101d3e:	83 f8 79             	cmp    $0x79,%eax
c0101d41:	0f 84 ca 00 00 00    	je     c0101e11 <trap_dispatch+0x10e>
c0101d47:	e9 87 00 00 00       	jmp    c0101dd3 <trap_dispatch+0xd0>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101d4c:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d51:	83 c0 01             	add    $0x1,%eax
c0101d54:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
        if (ticks % TICK_NUM == 0) {
c0101d59:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
c0101d5f:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d64:	89 c8                	mov    %ecx,%eax
c0101d66:	f7 e2                	mul    %edx
c0101d68:	89 d0                	mov    %edx,%eax
c0101d6a:	c1 e8 05             	shr    $0x5,%eax
c0101d6d:	6b c0 64             	imul   $0x64,%eax,%eax
c0101d70:	29 c1                	sub    %eax,%ecx
c0101d72:	89 c8                	mov    %ecx,%eax
c0101d74:	85 c0                	test   %eax,%eax
c0101d76:	75 0a                	jne    c0101d82 <trap_dispatch+0x7f>
            print_ticks();
c0101d78:	e8 10 fb ff ff       	call   c010188d <print_ticks>
        }
        break;
c0101d7d:	e9 90 00 00 00       	jmp    c0101e12 <trap_dispatch+0x10f>
c0101d82:	e9 8b 00 00 00       	jmp    c0101e12 <trap_dispatch+0x10f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d87:	e8 c5 f8 ff ff       	call   c0101651 <cons_getc>
c0101d8c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d8f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d93:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d97:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d9f:	c7 04 24 49 65 10 c0 	movl   $0xc0106549,(%esp)
c0101da6:	e8 9d e5 ff ff       	call   c0100348 <cprintf>
        break;
c0101dab:	eb 65                	jmp    c0101e12 <trap_dispatch+0x10f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101dad:	e8 9f f8 ff ff       	call   c0101651 <cons_getc>
c0101db2:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101db5:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101db9:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101dbd:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dc5:	c7 04 24 5b 65 10 c0 	movl   $0xc010655b,(%esp)
c0101dcc:	e8 77 e5 ff ff       	call   c0100348 <cprintf>
        break;
c0101dd1:	eb 3f                	jmp    c0101e12 <trap_dispatch+0x10f>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dd6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101dda:	0f b7 c0             	movzwl %ax,%eax
c0101ddd:	83 e0 03             	and    $0x3,%eax
c0101de0:	85 c0                	test   %eax,%eax
c0101de2:	75 2e                	jne    c0101e12 <trap_dispatch+0x10f>
            print_trapframe(tf);
c0101de4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101de7:	89 04 24             	mov    %eax,(%esp)
c0101dea:	e8 98 fc ff ff       	call   c0101a87 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101def:	c7 44 24 08 6a 65 10 	movl   $0xc010656a,0x8(%esp)
c0101df6:	c0 
c0101df7:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0101dfe:	00 
c0101dff:	c7 04 24 8e 63 10 c0 	movl   $0xc010638e,(%esp)
c0101e06:	e8 c7 ee ff ff       	call   c0100cd2 <__panic>
        
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101e0b:	90                   	nop
c0101e0c:	eb 04                	jmp    c0101e12 <trap_dispatch+0x10f>
        cprintf("kbd [%03d] %c\n", c, c);
        break;
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        
        break;
c0101e0e:	90                   	nop
c0101e0f:	eb 01                	jmp    c0101e12 <trap_dispatch+0x10f>
    case T_SWITCH_TOK:
        
        break;
c0101e11:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101e12:	c9                   	leave  
c0101e13:	c3                   	ret    

c0101e14 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101e14:	55                   	push   %ebp
c0101e15:	89 e5                	mov    %esp,%ebp
c0101e17:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101e1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e1d:	89 04 24             	mov    %eax,(%esp)
c0101e20:	e8 de fe ff ff       	call   c0101d03 <trap_dispatch>
}
c0101e25:	c9                   	leave  
c0101e26:	c3                   	ret    

c0101e27 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101e27:	1e                   	push   %ds
    pushl %es
c0101e28:	06                   	push   %es
    pushl %fs
c0101e29:	0f a0                	push   %fs
    pushl %gs
c0101e2b:	0f a8                	push   %gs
    pushal
c0101e2d:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101e2e:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101e33:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101e35:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101e37:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101e38:	e8 d7 ff ff ff       	call   c0101e14 <trap>

    # pop the pushed stack pointer
    popl %esp
c0101e3d:	5c                   	pop    %esp

c0101e3e <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101e3e:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101e3f:	0f a9                	pop    %gs
    popl %fs
c0101e41:	0f a1                	pop    %fs
    popl %es
c0101e43:	07                   	pop    %es
    popl %ds
c0101e44:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101e45:	83 c4 08             	add    $0x8,%esp
    iret
c0101e48:	cf                   	iret   

c0101e49 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101e49:	6a 00                	push   $0x0
  pushl $0
c0101e4b:	6a 00                	push   $0x0
  jmp __alltraps
c0101e4d:	e9 d5 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101e52 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101e52:	6a 00                	push   $0x0
  pushl $1
c0101e54:	6a 01                	push   $0x1
  jmp __alltraps
c0101e56:	e9 cc ff ff ff       	jmp    c0101e27 <__alltraps>

c0101e5b <vector2>:
.globl vector2
vector2:
  pushl $0
c0101e5b:	6a 00                	push   $0x0
  pushl $2
c0101e5d:	6a 02                	push   $0x2
  jmp __alltraps
c0101e5f:	e9 c3 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101e64 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101e64:	6a 00                	push   $0x0
  pushl $3
c0101e66:	6a 03                	push   $0x3
  jmp __alltraps
c0101e68:	e9 ba ff ff ff       	jmp    c0101e27 <__alltraps>

c0101e6d <vector4>:
.globl vector4
vector4:
  pushl $0
c0101e6d:	6a 00                	push   $0x0
  pushl $4
c0101e6f:	6a 04                	push   $0x4
  jmp __alltraps
c0101e71:	e9 b1 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101e76 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101e76:	6a 00                	push   $0x0
  pushl $5
c0101e78:	6a 05                	push   $0x5
  jmp __alltraps
c0101e7a:	e9 a8 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101e7f <vector6>:
.globl vector6
vector6:
  pushl $0
c0101e7f:	6a 00                	push   $0x0
  pushl $6
c0101e81:	6a 06                	push   $0x6
  jmp __alltraps
c0101e83:	e9 9f ff ff ff       	jmp    c0101e27 <__alltraps>

c0101e88 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101e88:	6a 00                	push   $0x0
  pushl $7
c0101e8a:	6a 07                	push   $0x7
  jmp __alltraps
c0101e8c:	e9 96 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101e91 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e91:	6a 08                	push   $0x8
  jmp __alltraps
c0101e93:	e9 8f ff ff ff       	jmp    c0101e27 <__alltraps>

c0101e98 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101e98:	6a 00                	push   $0x0
  pushl $9
c0101e9a:	6a 09                	push   $0x9
  jmp __alltraps
c0101e9c:	e9 86 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101ea1 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101ea1:	6a 0a                	push   $0xa
  jmp __alltraps
c0101ea3:	e9 7f ff ff ff       	jmp    c0101e27 <__alltraps>

c0101ea8 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101ea8:	6a 0b                	push   $0xb
  jmp __alltraps
c0101eaa:	e9 78 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101eaf <vector12>:
.globl vector12
vector12:
  pushl $12
c0101eaf:	6a 0c                	push   $0xc
  jmp __alltraps
c0101eb1:	e9 71 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101eb6 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101eb6:	6a 0d                	push   $0xd
  jmp __alltraps
c0101eb8:	e9 6a ff ff ff       	jmp    c0101e27 <__alltraps>

c0101ebd <vector14>:
.globl vector14
vector14:
  pushl $14
c0101ebd:	6a 0e                	push   $0xe
  jmp __alltraps
c0101ebf:	e9 63 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101ec4 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101ec4:	6a 00                	push   $0x0
  pushl $15
c0101ec6:	6a 0f                	push   $0xf
  jmp __alltraps
c0101ec8:	e9 5a ff ff ff       	jmp    c0101e27 <__alltraps>

c0101ecd <vector16>:
.globl vector16
vector16:
  pushl $0
c0101ecd:	6a 00                	push   $0x0
  pushl $16
c0101ecf:	6a 10                	push   $0x10
  jmp __alltraps
c0101ed1:	e9 51 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101ed6 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101ed6:	6a 11                	push   $0x11
  jmp __alltraps
c0101ed8:	e9 4a ff ff ff       	jmp    c0101e27 <__alltraps>

c0101edd <vector18>:
.globl vector18
vector18:
  pushl $0
c0101edd:	6a 00                	push   $0x0
  pushl $18
c0101edf:	6a 12                	push   $0x12
  jmp __alltraps
c0101ee1:	e9 41 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101ee6 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101ee6:	6a 00                	push   $0x0
  pushl $19
c0101ee8:	6a 13                	push   $0x13
  jmp __alltraps
c0101eea:	e9 38 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101eef <vector20>:
.globl vector20
vector20:
  pushl $0
c0101eef:	6a 00                	push   $0x0
  pushl $20
c0101ef1:	6a 14                	push   $0x14
  jmp __alltraps
c0101ef3:	e9 2f ff ff ff       	jmp    c0101e27 <__alltraps>

c0101ef8 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101ef8:	6a 00                	push   $0x0
  pushl $21
c0101efa:	6a 15                	push   $0x15
  jmp __alltraps
c0101efc:	e9 26 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101f01 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101f01:	6a 00                	push   $0x0
  pushl $22
c0101f03:	6a 16                	push   $0x16
  jmp __alltraps
c0101f05:	e9 1d ff ff ff       	jmp    c0101e27 <__alltraps>

c0101f0a <vector23>:
.globl vector23
vector23:
  pushl $0
c0101f0a:	6a 00                	push   $0x0
  pushl $23
c0101f0c:	6a 17                	push   $0x17
  jmp __alltraps
c0101f0e:	e9 14 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101f13 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101f13:	6a 00                	push   $0x0
  pushl $24
c0101f15:	6a 18                	push   $0x18
  jmp __alltraps
c0101f17:	e9 0b ff ff ff       	jmp    c0101e27 <__alltraps>

c0101f1c <vector25>:
.globl vector25
vector25:
  pushl $0
c0101f1c:	6a 00                	push   $0x0
  pushl $25
c0101f1e:	6a 19                	push   $0x19
  jmp __alltraps
c0101f20:	e9 02 ff ff ff       	jmp    c0101e27 <__alltraps>

c0101f25 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101f25:	6a 00                	push   $0x0
  pushl $26
c0101f27:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101f29:	e9 f9 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f2e <vector27>:
.globl vector27
vector27:
  pushl $0
c0101f2e:	6a 00                	push   $0x0
  pushl $27
c0101f30:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101f32:	e9 f0 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f37 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101f37:	6a 00                	push   $0x0
  pushl $28
c0101f39:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101f3b:	e9 e7 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f40 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101f40:	6a 00                	push   $0x0
  pushl $29
c0101f42:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101f44:	e9 de fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f49 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101f49:	6a 00                	push   $0x0
  pushl $30
c0101f4b:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101f4d:	e9 d5 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f52 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101f52:	6a 00                	push   $0x0
  pushl $31
c0101f54:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101f56:	e9 cc fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f5b <vector32>:
.globl vector32
vector32:
  pushl $0
c0101f5b:	6a 00                	push   $0x0
  pushl $32
c0101f5d:	6a 20                	push   $0x20
  jmp __alltraps
c0101f5f:	e9 c3 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f64 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101f64:	6a 00                	push   $0x0
  pushl $33
c0101f66:	6a 21                	push   $0x21
  jmp __alltraps
c0101f68:	e9 ba fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f6d <vector34>:
.globl vector34
vector34:
  pushl $0
c0101f6d:	6a 00                	push   $0x0
  pushl $34
c0101f6f:	6a 22                	push   $0x22
  jmp __alltraps
c0101f71:	e9 b1 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f76 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101f76:	6a 00                	push   $0x0
  pushl $35
c0101f78:	6a 23                	push   $0x23
  jmp __alltraps
c0101f7a:	e9 a8 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f7f <vector36>:
.globl vector36
vector36:
  pushl $0
c0101f7f:	6a 00                	push   $0x0
  pushl $36
c0101f81:	6a 24                	push   $0x24
  jmp __alltraps
c0101f83:	e9 9f fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f88 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101f88:	6a 00                	push   $0x0
  pushl $37
c0101f8a:	6a 25                	push   $0x25
  jmp __alltraps
c0101f8c:	e9 96 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f91 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f91:	6a 00                	push   $0x0
  pushl $38
c0101f93:	6a 26                	push   $0x26
  jmp __alltraps
c0101f95:	e9 8d fe ff ff       	jmp    c0101e27 <__alltraps>

c0101f9a <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f9a:	6a 00                	push   $0x0
  pushl $39
c0101f9c:	6a 27                	push   $0x27
  jmp __alltraps
c0101f9e:	e9 84 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101fa3 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101fa3:	6a 00                	push   $0x0
  pushl $40
c0101fa5:	6a 28                	push   $0x28
  jmp __alltraps
c0101fa7:	e9 7b fe ff ff       	jmp    c0101e27 <__alltraps>

c0101fac <vector41>:
.globl vector41
vector41:
  pushl $0
c0101fac:	6a 00                	push   $0x0
  pushl $41
c0101fae:	6a 29                	push   $0x29
  jmp __alltraps
c0101fb0:	e9 72 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101fb5 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101fb5:	6a 00                	push   $0x0
  pushl $42
c0101fb7:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101fb9:	e9 69 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101fbe <vector43>:
.globl vector43
vector43:
  pushl $0
c0101fbe:	6a 00                	push   $0x0
  pushl $43
c0101fc0:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101fc2:	e9 60 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101fc7 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101fc7:	6a 00                	push   $0x0
  pushl $44
c0101fc9:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101fcb:	e9 57 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101fd0 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101fd0:	6a 00                	push   $0x0
  pushl $45
c0101fd2:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101fd4:	e9 4e fe ff ff       	jmp    c0101e27 <__alltraps>

c0101fd9 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101fd9:	6a 00                	push   $0x0
  pushl $46
c0101fdb:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101fdd:	e9 45 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101fe2 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101fe2:	6a 00                	push   $0x0
  pushl $47
c0101fe4:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101fe6:	e9 3c fe ff ff       	jmp    c0101e27 <__alltraps>

c0101feb <vector48>:
.globl vector48
vector48:
  pushl $0
c0101feb:	6a 00                	push   $0x0
  pushl $48
c0101fed:	6a 30                	push   $0x30
  jmp __alltraps
c0101fef:	e9 33 fe ff ff       	jmp    c0101e27 <__alltraps>

c0101ff4 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101ff4:	6a 00                	push   $0x0
  pushl $49
c0101ff6:	6a 31                	push   $0x31
  jmp __alltraps
c0101ff8:	e9 2a fe ff ff       	jmp    c0101e27 <__alltraps>

c0101ffd <vector50>:
.globl vector50
vector50:
  pushl $0
c0101ffd:	6a 00                	push   $0x0
  pushl $50
c0101fff:	6a 32                	push   $0x32
  jmp __alltraps
c0102001:	e9 21 fe ff ff       	jmp    c0101e27 <__alltraps>

c0102006 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102006:	6a 00                	push   $0x0
  pushl $51
c0102008:	6a 33                	push   $0x33
  jmp __alltraps
c010200a:	e9 18 fe ff ff       	jmp    c0101e27 <__alltraps>

c010200f <vector52>:
.globl vector52
vector52:
  pushl $0
c010200f:	6a 00                	push   $0x0
  pushl $52
c0102011:	6a 34                	push   $0x34
  jmp __alltraps
c0102013:	e9 0f fe ff ff       	jmp    c0101e27 <__alltraps>

c0102018 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102018:	6a 00                	push   $0x0
  pushl $53
c010201a:	6a 35                	push   $0x35
  jmp __alltraps
c010201c:	e9 06 fe ff ff       	jmp    c0101e27 <__alltraps>

c0102021 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102021:	6a 00                	push   $0x0
  pushl $54
c0102023:	6a 36                	push   $0x36
  jmp __alltraps
c0102025:	e9 fd fd ff ff       	jmp    c0101e27 <__alltraps>

c010202a <vector55>:
.globl vector55
vector55:
  pushl $0
c010202a:	6a 00                	push   $0x0
  pushl $55
c010202c:	6a 37                	push   $0x37
  jmp __alltraps
c010202e:	e9 f4 fd ff ff       	jmp    c0101e27 <__alltraps>

c0102033 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102033:	6a 00                	push   $0x0
  pushl $56
c0102035:	6a 38                	push   $0x38
  jmp __alltraps
c0102037:	e9 eb fd ff ff       	jmp    c0101e27 <__alltraps>

c010203c <vector57>:
.globl vector57
vector57:
  pushl $0
c010203c:	6a 00                	push   $0x0
  pushl $57
c010203e:	6a 39                	push   $0x39
  jmp __alltraps
c0102040:	e9 e2 fd ff ff       	jmp    c0101e27 <__alltraps>

c0102045 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102045:	6a 00                	push   $0x0
  pushl $58
c0102047:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102049:	e9 d9 fd ff ff       	jmp    c0101e27 <__alltraps>

c010204e <vector59>:
.globl vector59
vector59:
  pushl $0
c010204e:	6a 00                	push   $0x0
  pushl $59
c0102050:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102052:	e9 d0 fd ff ff       	jmp    c0101e27 <__alltraps>

c0102057 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102057:	6a 00                	push   $0x0
  pushl $60
c0102059:	6a 3c                	push   $0x3c
  jmp __alltraps
c010205b:	e9 c7 fd ff ff       	jmp    c0101e27 <__alltraps>

c0102060 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102060:	6a 00                	push   $0x0
  pushl $61
c0102062:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102064:	e9 be fd ff ff       	jmp    c0101e27 <__alltraps>

c0102069 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102069:	6a 00                	push   $0x0
  pushl $62
c010206b:	6a 3e                	push   $0x3e
  jmp __alltraps
c010206d:	e9 b5 fd ff ff       	jmp    c0101e27 <__alltraps>

c0102072 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102072:	6a 00                	push   $0x0
  pushl $63
c0102074:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102076:	e9 ac fd ff ff       	jmp    c0101e27 <__alltraps>

c010207b <vector64>:
.globl vector64
vector64:
  pushl $0
c010207b:	6a 00                	push   $0x0
  pushl $64
c010207d:	6a 40                	push   $0x40
  jmp __alltraps
c010207f:	e9 a3 fd ff ff       	jmp    c0101e27 <__alltraps>

c0102084 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102084:	6a 00                	push   $0x0
  pushl $65
c0102086:	6a 41                	push   $0x41
  jmp __alltraps
c0102088:	e9 9a fd ff ff       	jmp    c0101e27 <__alltraps>

c010208d <vector66>:
.globl vector66
vector66:
  pushl $0
c010208d:	6a 00                	push   $0x0
  pushl $66
c010208f:	6a 42                	push   $0x42
  jmp __alltraps
c0102091:	e9 91 fd ff ff       	jmp    c0101e27 <__alltraps>

c0102096 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102096:	6a 00                	push   $0x0
  pushl $67
c0102098:	6a 43                	push   $0x43
  jmp __alltraps
c010209a:	e9 88 fd ff ff       	jmp    c0101e27 <__alltraps>

c010209f <vector68>:
.globl vector68
vector68:
  pushl $0
c010209f:	6a 00                	push   $0x0
  pushl $68
c01020a1:	6a 44                	push   $0x44
  jmp __alltraps
c01020a3:	e9 7f fd ff ff       	jmp    c0101e27 <__alltraps>

c01020a8 <vector69>:
.globl vector69
vector69:
  pushl $0
c01020a8:	6a 00                	push   $0x0
  pushl $69
c01020aa:	6a 45                	push   $0x45
  jmp __alltraps
c01020ac:	e9 76 fd ff ff       	jmp    c0101e27 <__alltraps>

c01020b1 <vector70>:
.globl vector70
vector70:
  pushl $0
c01020b1:	6a 00                	push   $0x0
  pushl $70
c01020b3:	6a 46                	push   $0x46
  jmp __alltraps
c01020b5:	e9 6d fd ff ff       	jmp    c0101e27 <__alltraps>

c01020ba <vector71>:
.globl vector71
vector71:
  pushl $0
c01020ba:	6a 00                	push   $0x0
  pushl $71
c01020bc:	6a 47                	push   $0x47
  jmp __alltraps
c01020be:	e9 64 fd ff ff       	jmp    c0101e27 <__alltraps>

c01020c3 <vector72>:
.globl vector72
vector72:
  pushl $0
c01020c3:	6a 00                	push   $0x0
  pushl $72
c01020c5:	6a 48                	push   $0x48
  jmp __alltraps
c01020c7:	e9 5b fd ff ff       	jmp    c0101e27 <__alltraps>

c01020cc <vector73>:
.globl vector73
vector73:
  pushl $0
c01020cc:	6a 00                	push   $0x0
  pushl $73
c01020ce:	6a 49                	push   $0x49
  jmp __alltraps
c01020d0:	e9 52 fd ff ff       	jmp    c0101e27 <__alltraps>

c01020d5 <vector74>:
.globl vector74
vector74:
  pushl $0
c01020d5:	6a 00                	push   $0x0
  pushl $74
c01020d7:	6a 4a                	push   $0x4a
  jmp __alltraps
c01020d9:	e9 49 fd ff ff       	jmp    c0101e27 <__alltraps>

c01020de <vector75>:
.globl vector75
vector75:
  pushl $0
c01020de:	6a 00                	push   $0x0
  pushl $75
c01020e0:	6a 4b                	push   $0x4b
  jmp __alltraps
c01020e2:	e9 40 fd ff ff       	jmp    c0101e27 <__alltraps>

c01020e7 <vector76>:
.globl vector76
vector76:
  pushl $0
c01020e7:	6a 00                	push   $0x0
  pushl $76
c01020e9:	6a 4c                	push   $0x4c
  jmp __alltraps
c01020eb:	e9 37 fd ff ff       	jmp    c0101e27 <__alltraps>

c01020f0 <vector77>:
.globl vector77
vector77:
  pushl $0
c01020f0:	6a 00                	push   $0x0
  pushl $77
c01020f2:	6a 4d                	push   $0x4d
  jmp __alltraps
c01020f4:	e9 2e fd ff ff       	jmp    c0101e27 <__alltraps>

c01020f9 <vector78>:
.globl vector78
vector78:
  pushl $0
c01020f9:	6a 00                	push   $0x0
  pushl $78
c01020fb:	6a 4e                	push   $0x4e
  jmp __alltraps
c01020fd:	e9 25 fd ff ff       	jmp    c0101e27 <__alltraps>

c0102102 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102102:	6a 00                	push   $0x0
  pushl $79
c0102104:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102106:	e9 1c fd ff ff       	jmp    c0101e27 <__alltraps>

c010210b <vector80>:
.globl vector80
vector80:
  pushl $0
c010210b:	6a 00                	push   $0x0
  pushl $80
c010210d:	6a 50                	push   $0x50
  jmp __alltraps
c010210f:	e9 13 fd ff ff       	jmp    c0101e27 <__alltraps>

c0102114 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102114:	6a 00                	push   $0x0
  pushl $81
c0102116:	6a 51                	push   $0x51
  jmp __alltraps
c0102118:	e9 0a fd ff ff       	jmp    c0101e27 <__alltraps>

c010211d <vector82>:
.globl vector82
vector82:
  pushl $0
c010211d:	6a 00                	push   $0x0
  pushl $82
c010211f:	6a 52                	push   $0x52
  jmp __alltraps
c0102121:	e9 01 fd ff ff       	jmp    c0101e27 <__alltraps>

c0102126 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102126:	6a 00                	push   $0x0
  pushl $83
c0102128:	6a 53                	push   $0x53
  jmp __alltraps
c010212a:	e9 f8 fc ff ff       	jmp    c0101e27 <__alltraps>

c010212f <vector84>:
.globl vector84
vector84:
  pushl $0
c010212f:	6a 00                	push   $0x0
  pushl $84
c0102131:	6a 54                	push   $0x54
  jmp __alltraps
c0102133:	e9 ef fc ff ff       	jmp    c0101e27 <__alltraps>

c0102138 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102138:	6a 00                	push   $0x0
  pushl $85
c010213a:	6a 55                	push   $0x55
  jmp __alltraps
c010213c:	e9 e6 fc ff ff       	jmp    c0101e27 <__alltraps>

c0102141 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102141:	6a 00                	push   $0x0
  pushl $86
c0102143:	6a 56                	push   $0x56
  jmp __alltraps
c0102145:	e9 dd fc ff ff       	jmp    c0101e27 <__alltraps>

c010214a <vector87>:
.globl vector87
vector87:
  pushl $0
c010214a:	6a 00                	push   $0x0
  pushl $87
c010214c:	6a 57                	push   $0x57
  jmp __alltraps
c010214e:	e9 d4 fc ff ff       	jmp    c0101e27 <__alltraps>

c0102153 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102153:	6a 00                	push   $0x0
  pushl $88
c0102155:	6a 58                	push   $0x58
  jmp __alltraps
c0102157:	e9 cb fc ff ff       	jmp    c0101e27 <__alltraps>

c010215c <vector89>:
.globl vector89
vector89:
  pushl $0
c010215c:	6a 00                	push   $0x0
  pushl $89
c010215e:	6a 59                	push   $0x59
  jmp __alltraps
c0102160:	e9 c2 fc ff ff       	jmp    c0101e27 <__alltraps>

c0102165 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102165:	6a 00                	push   $0x0
  pushl $90
c0102167:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102169:	e9 b9 fc ff ff       	jmp    c0101e27 <__alltraps>

c010216e <vector91>:
.globl vector91
vector91:
  pushl $0
c010216e:	6a 00                	push   $0x0
  pushl $91
c0102170:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102172:	e9 b0 fc ff ff       	jmp    c0101e27 <__alltraps>

c0102177 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102177:	6a 00                	push   $0x0
  pushl $92
c0102179:	6a 5c                	push   $0x5c
  jmp __alltraps
c010217b:	e9 a7 fc ff ff       	jmp    c0101e27 <__alltraps>

c0102180 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102180:	6a 00                	push   $0x0
  pushl $93
c0102182:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102184:	e9 9e fc ff ff       	jmp    c0101e27 <__alltraps>

c0102189 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102189:	6a 00                	push   $0x0
  pushl $94
c010218b:	6a 5e                	push   $0x5e
  jmp __alltraps
c010218d:	e9 95 fc ff ff       	jmp    c0101e27 <__alltraps>

c0102192 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102192:	6a 00                	push   $0x0
  pushl $95
c0102194:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102196:	e9 8c fc ff ff       	jmp    c0101e27 <__alltraps>

c010219b <vector96>:
.globl vector96
vector96:
  pushl $0
c010219b:	6a 00                	push   $0x0
  pushl $96
c010219d:	6a 60                	push   $0x60
  jmp __alltraps
c010219f:	e9 83 fc ff ff       	jmp    c0101e27 <__alltraps>

c01021a4 <vector97>:
.globl vector97
vector97:
  pushl $0
c01021a4:	6a 00                	push   $0x0
  pushl $97
c01021a6:	6a 61                	push   $0x61
  jmp __alltraps
c01021a8:	e9 7a fc ff ff       	jmp    c0101e27 <__alltraps>

c01021ad <vector98>:
.globl vector98
vector98:
  pushl $0
c01021ad:	6a 00                	push   $0x0
  pushl $98
c01021af:	6a 62                	push   $0x62
  jmp __alltraps
c01021b1:	e9 71 fc ff ff       	jmp    c0101e27 <__alltraps>

c01021b6 <vector99>:
.globl vector99
vector99:
  pushl $0
c01021b6:	6a 00                	push   $0x0
  pushl $99
c01021b8:	6a 63                	push   $0x63
  jmp __alltraps
c01021ba:	e9 68 fc ff ff       	jmp    c0101e27 <__alltraps>

c01021bf <vector100>:
.globl vector100
vector100:
  pushl $0
c01021bf:	6a 00                	push   $0x0
  pushl $100
c01021c1:	6a 64                	push   $0x64
  jmp __alltraps
c01021c3:	e9 5f fc ff ff       	jmp    c0101e27 <__alltraps>

c01021c8 <vector101>:
.globl vector101
vector101:
  pushl $0
c01021c8:	6a 00                	push   $0x0
  pushl $101
c01021ca:	6a 65                	push   $0x65
  jmp __alltraps
c01021cc:	e9 56 fc ff ff       	jmp    c0101e27 <__alltraps>

c01021d1 <vector102>:
.globl vector102
vector102:
  pushl $0
c01021d1:	6a 00                	push   $0x0
  pushl $102
c01021d3:	6a 66                	push   $0x66
  jmp __alltraps
c01021d5:	e9 4d fc ff ff       	jmp    c0101e27 <__alltraps>

c01021da <vector103>:
.globl vector103
vector103:
  pushl $0
c01021da:	6a 00                	push   $0x0
  pushl $103
c01021dc:	6a 67                	push   $0x67
  jmp __alltraps
c01021de:	e9 44 fc ff ff       	jmp    c0101e27 <__alltraps>

c01021e3 <vector104>:
.globl vector104
vector104:
  pushl $0
c01021e3:	6a 00                	push   $0x0
  pushl $104
c01021e5:	6a 68                	push   $0x68
  jmp __alltraps
c01021e7:	e9 3b fc ff ff       	jmp    c0101e27 <__alltraps>

c01021ec <vector105>:
.globl vector105
vector105:
  pushl $0
c01021ec:	6a 00                	push   $0x0
  pushl $105
c01021ee:	6a 69                	push   $0x69
  jmp __alltraps
c01021f0:	e9 32 fc ff ff       	jmp    c0101e27 <__alltraps>

c01021f5 <vector106>:
.globl vector106
vector106:
  pushl $0
c01021f5:	6a 00                	push   $0x0
  pushl $106
c01021f7:	6a 6a                	push   $0x6a
  jmp __alltraps
c01021f9:	e9 29 fc ff ff       	jmp    c0101e27 <__alltraps>

c01021fe <vector107>:
.globl vector107
vector107:
  pushl $0
c01021fe:	6a 00                	push   $0x0
  pushl $107
c0102200:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102202:	e9 20 fc ff ff       	jmp    c0101e27 <__alltraps>

c0102207 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102207:	6a 00                	push   $0x0
  pushl $108
c0102209:	6a 6c                	push   $0x6c
  jmp __alltraps
c010220b:	e9 17 fc ff ff       	jmp    c0101e27 <__alltraps>

c0102210 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102210:	6a 00                	push   $0x0
  pushl $109
c0102212:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102214:	e9 0e fc ff ff       	jmp    c0101e27 <__alltraps>

c0102219 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102219:	6a 00                	push   $0x0
  pushl $110
c010221b:	6a 6e                	push   $0x6e
  jmp __alltraps
c010221d:	e9 05 fc ff ff       	jmp    c0101e27 <__alltraps>

c0102222 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102222:	6a 00                	push   $0x0
  pushl $111
c0102224:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102226:	e9 fc fb ff ff       	jmp    c0101e27 <__alltraps>

c010222b <vector112>:
.globl vector112
vector112:
  pushl $0
c010222b:	6a 00                	push   $0x0
  pushl $112
c010222d:	6a 70                	push   $0x70
  jmp __alltraps
c010222f:	e9 f3 fb ff ff       	jmp    c0101e27 <__alltraps>

c0102234 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102234:	6a 00                	push   $0x0
  pushl $113
c0102236:	6a 71                	push   $0x71
  jmp __alltraps
c0102238:	e9 ea fb ff ff       	jmp    c0101e27 <__alltraps>

c010223d <vector114>:
.globl vector114
vector114:
  pushl $0
c010223d:	6a 00                	push   $0x0
  pushl $114
c010223f:	6a 72                	push   $0x72
  jmp __alltraps
c0102241:	e9 e1 fb ff ff       	jmp    c0101e27 <__alltraps>

c0102246 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102246:	6a 00                	push   $0x0
  pushl $115
c0102248:	6a 73                	push   $0x73
  jmp __alltraps
c010224a:	e9 d8 fb ff ff       	jmp    c0101e27 <__alltraps>

c010224f <vector116>:
.globl vector116
vector116:
  pushl $0
c010224f:	6a 00                	push   $0x0
  pushl $116
c0102251:	6a 74                	push   $0x74
  jmp __alltraps
c0102253:	e9 cf fb ff ff       	jmp    c0101e27 <__alltraps>

c0102258 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102258:	6a 00                	push   $0x0
  pushl $117
c010225a:	6a 75                	push   $0x75
  jmp __alltraps
c010225c:	e9 c6 fb ff ff       	jmp    c0101e27 <__alltraps>

c0102261 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102261:	6a 00                	push   $0x0
  pushl $118
c0102263:	6a 76                	push   $0x76
  jmp __alltraps
c0102265:	e9 bd fb ff ff       	jmp    c0101e27 <__alltraps>

c010226a <vector119>:
.globl vector119
vector119:
  pushl $0
c010226a:	6a 00                	push   $0x0
  pushl $119
c010226c:	6a 77                	push   $0x77
  jmp __alltraps
c010226e:	e9 b4 fb ff ff       	jmp    c0101e27 <__alltraps>

c0102273 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102273:	6a 00                	push   $0x0
  pushl $120
c0102275:	6a 78                	push   $0x78
  jmp __alltraps
c0102277:	e9 ab fb ff ff       	jmp    c0101e27 <__alltraps>

c010227c <vector121>:
.globl vector121
vector121:
  pushl $0
c010227c:	6a 00                	push   $0x0
  pushl $121
c010227e:	6a 79                	push   $0x79
  jmp __alltraps
c0102280:	e9 a2 fb ff ff       	jmp    c0101e27 <__alltraps>

c0102285 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102285:	6a 00                	push   $0x0
  pushl $122
c0102287:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102289:	e9 99 fb ff ff       	jmp    c0101e27 <__alltraps>

c010228e <vector123>:
.globl vector123
vector123:
  pushl $0
c010228e:	6a 00                	push   $0x0
  pushl $123
c0102290:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102292:	e9 90 fb ff ff       	jmp    c0101e27 <__alltraps>

c0102297 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102297:	6a 00                	push   $0x0
  pushl $124
c0102299:	6a 7c                	push   $0x7c
  jmp __alltraps
c010229b:	e9 87 fb ff ff       	jmp    c0101e27 <__alltraps>

c01022a0 <vector125>:
.globl vector125
vector125:
  pushl $0
c01022a0:	6a 00                	push   $0x0
  pushl $125
c01022a2:	6a 7d                	push   $0x7d
  jmp __alltraps
c01022a4:	e9 7e fb ff ff       	jmp    c0101e27 <__alltraps>

c01022a9 <vector126>:
.globl vector126
vector126:
  pushl $0
c01022a9:	6a 00                	push   $0x0
  pushl $126
c01022ab:	6a 7e                	push   $0x7e
  jmp __alltraps
c01022ad:	e9 75 fb ff ff       	jmp    c0101e27 <__alltraps>

c01022b2 <vector127>:
.globl vector127
vector127:
  pushl $0
c01022b2:	6a 00                	push   $0x0
  pushl $127
c01022b4:	6a 7f                	push   $0x7f
  jmp __alltraps
c01022b6:	e9 6c fb ff ff       	jmp    c0101e27 <__alltraps>

c01022bb <vector128>:
.globl vector128
vector128:
  pushl $0
c01022bb:	6a 00                	push   $0x0
  pushl $128
c01022bd:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01022c2:	e9 60 fb ff ff       	jmp    c0101e27 <__alltraps>

c01022c7 <vector129>:
.globl vector129
vector129:
  pushl $0
c01022c7:	6a 00                	push   $0x0
  pushl $129
c01022c9:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01022ce:	e9 54 fb ff ff       	jmp    c0101e27 <__alltraps>

c01022d3 <vector130>:
.globl vector130
vector130:
  pushl $0
c01022d3:	6a 00                	push   $0x0
  pushl $130
c01022d5:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01022da:	e9 48 fb ff ff       	jmp    c0101e27 <__alltraps>

c01022df <vector131>:
.globl vector131
vector131:
  pushl $0
c01022df:	6a 00                	push   $0x0
  pushl $131
c01022e1:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01022e6:	e9 3c fb ff ff       	jmp    c0101e27 <__alltraps>

c01022eb <vector132>:
.globl vector132
vector132:
  pushl $0
c01022eb:	6a 00                	push   $0x0
  pushl $132
c01022ed:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01022f2:	e9 30 fb ff ff       	jmp    c0101e27 <__alltraps>

c01022f7 <vector133>:
.globl vector133
vector133:
  pushl $0
c01022f7:	6a 00                	push   $0x0
  pushl $133
c01022f9:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01022fe:	e9 24 fb ff ff       	jmp    c0101e27 <__alltraps>

c0102303 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102303:	6a 00                	push   $0x0
  pushl $134
c0102305:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010230a:	e9 18 fb ff ff       	jmp    c0101e27 <__alltraps>

c010230f <vector135>:
.globl vector135
vector135:
  pushl $0
c010230f:	6a 00                	push   $0x0
  pushl $135
c0102311:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102316:	e9 0c fb ff ff       	jmp    c0101e27 <__alltraps>

c010231b <vector136>:
.globl vector136
vector136:
  pushl $0
c010231b:	6a 00                	push   $0x0
  pushl $136
c010231d:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102322:	e9 00 fb ff ff       	jmp    c0101e27 <__alltraps>

c0102327 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102327:	6a 00                	push   $0x0
  pushl $137
c0102329:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010232e:	e9 f4 fa ff ff       	jmp    c0101e27 <__alltraps>

c0102333 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102333:	6a 00                	push   $0x0
  pushl $138
c0102335:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010233a:	e9 e8 fa ff ff       	jmp    c0101e27 <__alltraps>

c010233f <vector139>:
.globl vector139
vector139:
  pushl $0
c010233f:	6a 00                	push   $0x0
  pushl $139
c0102341:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102346:	e9 dc fa ff ff       	jmp    c0101e27 <__alltraps>

c010234b <vector140>:
.globl vector140
vector140:
  pushl $0
c010234b:	6a 00                	push   $0x0
  pushl $140
c010234d:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102352:	e9 d0 fa ff ff       	jmp    c0101e27 <__alltraps>

c0102357 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102357:	6a 00                	push   $0x0
  pushl $141
c0102359:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c010235e:	e9 c4 fa ff ff       	jmp    c0101e27 <__alltraps>

c0102363 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102363:	6a 00                	push   $0x0
  pushl $142
c0102365:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010236a:	e9 b8 fa ff ff       	jmp    c0101e27 <__alltraps>

c010236f <vector143>:
.globl vector143
vector143:
  pushl $0
c010236f:	6a 00                	push   $0x0
  pushl $143
c0102371:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102376:	e9 ac fa ff ff       	jmp    c0101e27 <__alltraps>

c010237b <vector144>:
.globl vector144
vector144:
  pushl $0
c010237b:	6a 00                	push   $0x0
  pushl $144
c010237d:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102382:	e9 a0 fa ff ff       	jmp    c0101e27 <__alltraps>

c0102387 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102387:	6a 00                	push   $0x0
  pushl $145
c0102389:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c010238e:	e9 94 fa ff ff       	jmp    c0101e27 <__alltraps>

c0102393 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102393:	6a 00                	push   $0x0
  pushl $146
c0102395:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010239a:	e9 88 fa ff ff       	jmp    c0101e27 <__alltraps>

c010239f <vector147>:
.globl vector147
vector147:
  pushl $0
c010239f:	6a 00                	push   $0x0
  pushl $147
c01023a1:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01023a6:	e9 7c fa ff ff       	jmp    c0101e27 <__alltraps>

c01023ab <vector148>:
.globl vector148
vector148:
  pushl $0
c01023ab:	6a 00                	push   $0x0
  pushl $148
c01023ad:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01023b2:	e9 70 fa ff ff       	jmp    c0101e27 <__alltraps>

c01023b7 <vector149>:
.globl vector149
vector149:
  pushl $0
c01023b7:	6a 00                	push   $0x0
  pushl $149
c01023b9:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01023be:	e9 64 fa ff ff       	jmp    c0101e27 <__alltraps>

c01023c3 <vector150>:
.globl vector150
vector150:
  pushl $0
c01023c3:	6a 00                	push   $0x0
  pushl $150
c01023c5:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01023ca:	e9 58 fa ff ff       	jmp    c0101e27 <__alltraps>

c01023cf <vector151>:
.globl vector151
vector151:
  pushl $0
c01023cf:	6a 00                	push   $0x0
  pushl $151
c01023d1:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01023d6:	e9 4c fa ff ff       	jmp    c0101e27 <__alltraps>

c01023db <vector152>:
.globl vector152
vector152:
  pushl $0
c01023db:	6a 00                	push   $0x0
  pushl $152
c01023dd:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01023e2:	e9 40 fa ff ff       	jmp    c0101e27 <__alltraps>

c01023e7 <vector153>:
.globl vector153
vector153:
  pushl $0
c01023e7:	6a 00                	push   $0x0
  pushl $153
c01023e9:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01023ee:	e9 34 fa ff ff       	jmp    c0101e27 <__alltraps>

c01023f3 <vector154>:
.globl vector154
vector154:
  pushl $0
c01023f3:	6a 00                	push   $0x0
  pushl $154
c01023f5:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01023fa:	e9 28 fa ff ff       	jmp    c0101e27 <__alltraps>

c01023ff <vector155>:
.globl vector155
vector155:
  pushl $0
c01023ff:	6a 00                	push   $0x0
  pushl $155
c0102401:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102406:	e9 1c fa ff ff       	jmp    c0101e27 <__alltraps>

c010240b <vector156>:
.globl vector156
vector156:
  pushl $0
c010240b:	6a 00                	push   $0x0
  pushl $156
c010240d:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102412:	e9 10 fa ff ff       	jmp    c0101e27 <__alltraps>

c0102417 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102417:	6a 00                	push   $0x0
  pushl $157
c0102419:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010241e:	e9 04 fa ff ff       	jmp    c0101e27 <__alltraps>

c0102423 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102423:	6a 00                	push   $0x0
  pushl $158
c0102425:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010242a:	e9 f8 f9 ff ff       	jmp    c0101e27 <__alltraps>

c010242f <vector159>:
.globl vector159
vector159:
  pushl $0
c010242f:	6a 00                	push   $0x0
  pushl $159
c0102431:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102436:	e9 ec f9 ff ff       	jmp    c0101e27 <__alltraps>

c010243b <vector160>:
.globl vector160
vector160:
  pushl $0
c010243b:	6a 00                	push   $0x0
  pushl $160
c010243d:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102442:	e9 e0 f9 ff ff       	jmp    c0101e27 <__alltraps>

c0102447 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102447:	6a 00                	push   $0x0
  pushl $161
c0102449:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010244e:	e9 d4 f9 ff ff       	jmp    c0101e27 <__alltraps>

c0102453 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102453:	6a 00                	push   $0x0
  pushl $162
c0102455:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010245a:	e9 c8 f9 ff ff       	jmp    c0101e27 <__alltraps>

c010245f <vector163>:
.globl vector163
vector163:
  pushl $0
c010245f:	6a 00                	push   $0x0
  pushl $163
c0102461:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102466:	e9 bc f9 ff ff       	jmp    c0101e27 <__alltraps>

c010246b <vector164>:
.globl vector164
vector164:
  pushl $0
c010246b:	6a 00                	push   $0x0
  pushl $164
c010246d:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102472:	e9 b0 f9 ff ff       	jmp    c0101e27 <__alltraps>

c0102477 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102477:	6a 00                	push   $0x0
  pushl $165
c0102479:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c010247e:	e9 a4 f9 ff ff       	jmp    c0101e27 <__alltraps>

c0102483 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102483:	6a 00                	push   $0x0
  pushl $166
c0102485:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010248a:	e9 98 f9 ff ff       	jmp    c0101e27 <__alltraps>

c010248f <vector167>:
.globl vector167
vector167:
  pushl $0
c010248f:	6a 00                	push   $0x0
  pushl $167
c0102491:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102496:	e9 8c f9 ff ff       	jmp    c0101e27 <__alltraps>

c010249b <vector168>:
.globl vector168
vector168:
  pushl $0
c010249b:	6a 00                	push   $0x0
  pushl $168
c010249d:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01024a2:	e9 80 f9 ff ff       	jmp    c0101e27 <__alltraps>

c01024a7 <vector169>:
.globl vector169
vector169:
  pushl $0
c01024a7:	6a 00                	push   $0x0
  pushl $169
c01024a9:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01024ae:	e9 74 f9 ff ff       	jmp    c0101e27 <__alltraps>

c01024b3 <vector170>:
.globl vector170
vector170:
  pushl $0
c01024b3:	6a 00                	push   $0x0
  pushl $170
c01024b5:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01024ba:	e9 68 f9 ff ff       	jmp    c0101e27 <__alltraps>

c01024bf <vector171>:
.globl vector171
vector171:
  pushl $0
c01024bf:	6a 00                	push   $0x0
  pushl $171
c01024c1:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01024c6:	e9 5c f9 ff ff       	jmp    c0101e27 <__alltraps>

c01024cb <vector172>:
.globl vector172
vector172:
  pushl $0
c01024cb:	6a 00                	push   $0x0
  pushl $172
c01024cd:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01024d2:	e9 50 f9 ff ff       	jmp    c0101e27 <__alltraps>

c01024d7 <vector173>:
.globl vector173
vector173:
  pushl $0
c01024d7:	6a 00                	push   $0x0
  pushl $173
c01024d9:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01024de:	e9 44 f9 ff ff       	jmp    c0101e27 <__alltraps>

c01024e3 <vector174>:
.globl vector174
vector174:
  pushl $0
c01024e3:	6a 00                	push   $0x0
  pushl $174
c01024e5:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01024ea:	e9 38 f9 ff ff       	jmp    c0101e27 <__alltraps>

c01024ef <vector175>:
.globl vector175
vector175:
  pushl $0
c01024ef:	6a 00                	push   $0x0
  pushl $175
c01024f1:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01024f6:	e9 2c f9 ff ff       	jmp    c0101e27 <__alltraps>

c01024fb <vector176>:
.globl vector176
vector176:
  pushl $0
c01024fb:	6a 00                	push   $0x0
  pushl $176
c01024fd:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102502:	e9 20 f9 ff ff       	jmp    c0101e27 <__alltraps>

c0102507 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102507:	6a 00                	push   $0x0
  pushl $177
c0102509:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010250e:	e9 14 f9 ff ff       	jmp    c0101e27 <__alltraps>

c0102513 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102513:	6a 00                	push   $0x0
  pushl $178
c0102515:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010251a:	e9 08 f9 ff ff       	jmp    c0101e27 <__alltraps>

c010251f <vector179>:
.globl vector179
vector179:
  pushl $0
c010251f:	6a 00                	push   $0x0
  pushl $179
c0102521:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102526:	e9 fc f8 ff ff       	jmp    c0101e27 <__alltraps>

c010252b <vector180>:
.globl vector180
vector180:
  pushl $0
c010252b:	6a 00                	push   $0x0
  pushl $180
c010252d:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102532:	e9 f0 f8 ff ff       	jmp    c0101e27 <__alltraps>

c0102537 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102537:	6a 00                	push   $0x0
  pushl $181
c0102539:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010253e:	e9 e4 f8 ff ff       	jmp    c0101e27 <__alltraps>

c0102543 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102543:	6a 00                	push   $0x0
  pushl $182
c0102545:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010254a:	e9 d8 f8 ff ff       	jmp    c0101e27 <__alltraps>

c010254f <vector183>:
.globl vector183
vector183:
  pushl $0
c010254f:	6a 00                	push   $0x0
  pushl $183
c0102551:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102556:	e9 cc f8 ff ff       	jmp    c0101e27 <__alltraps>

c010255b <vector184>:
.globl vector184
vector184:
  pushl $0
c010255b:	6a 00                	push   $0x0
  pushl $184
c010255d:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102562:	e9 c0 f8 ff ff       	jmp    c0101e27 <__alltraps>

c0102567 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102567:	6a 00                	push   $0x0
  pushl $185
c0102569:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c010256e:	e9 b4 f8 ff ff       	jmp    c0101e27 <__alltraps>

c0102573 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102573:	6a 00                	push   $0x0
  pushl $186
c0102575:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010257a:	e9 a8 f8 ff ff       	jmp    c0101e27 <__alltraps>

c010257f <vector187>:
.globl vector187
vector187:
  pushl $0
c010257f:	6a 00                	push   $0x0
  pushl $187
c0102581:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102586:	e9 9c f8 ff ff       	jmp    c0101e27 <__alltraps>

c010258b <vector188>:
.globl vector188
vector188:
  pushl $0
c010258b:	6a 00                	push   $0x0
  pushl $188
c010258d:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102592:	e9 90 f8 ff ff       	jmp    c0101e27 <__alltraps>

c0102597 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102597:	6a 00                	push   $0x0
  pushl $189
c0102599:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010259e:	e9 84 f8 ff ff       	jmp    c0101e27 <__alltraps>

c01025a3 <vector190>:
.globl vector190
vector190:
  pushl $0
c01025a3:	6a 00                	push   $0x0
  pushl $190
c01025a5:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01025aa:	e9 78 f8 ff ff       	jmp    c0101e27 <__alltraps>

c01025af <vector191>:
.globl vector191
vector191:
  pushl $0
c01025af:	6a 00                	push   $0x0
  pushl $191
c01025b1:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01025b6:	e9 6c f8 ff ff       	jmp    c0101e27 <__alltraps>

c01025bb <vector192>:
.globl vector192
vector192:
  pushl $0
c01025bb:	6a 00                	push   $0x0
  pushl $192
c01025bd:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01025c2:	e9 60 f8 ff ff       	jmp    c0101e27 <__alltraps>

c01025c7 <vector193>:
.globl vector193
vector193:
  pushl $0
c01025c7:	6a 00                	push   $0x0
  pushl $193
c01025c9:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01025ce:	e9 54 f8 ff ff       	jmp    c0101e27 <__alltraps>

c01025d3 <vector194>:
.globl vector194
vector194:
  pushl $0
c01025d3:	6a 00                	push   $0x0
  pushl $194
c01025d5:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01025da:	e9 48 f8 ff ff       	jmp    c0101e27 <__alltraps>

c01025df <vector195>:
.globl vector195
vector195:
  pushl $0
c01025df:	6a 00                	push   $0x0
  pushl $195
c01025e1:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01025e6:	e9 3c f8 ff ff       	jmp    c0101e27 <__alltraps>

c01025eb <vector196>:
.globl vector196
vector196:
  pushl $0
c01025eb:	6a 00                	push   $0x0
  pushl $196
c01025ed:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01025f2:	e9 30 f8 ff ff       	jmp    c0101e27 <__alltraps>

c01025f7 <vector197>:
.globl vector197
vector197:
  pushl $0
c01025f7:	6a 00                	push   $0x0
  pushl $197
c01025f9:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01025fe:	e9 24 f8 ff ff       	jmp    c0101e27 <__alltraps>

c0102603 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102603:	6a 00                	push   $0x0
  pushl $198
c0102605:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010260a:	e9 18 f8 ff ff       	jmp    c0101e27 <__alltraps>

c010260f <vector199>:
.globl vector199
vector199:
  pushl $0
c010260f:	6a 00                	push   $0x0
  pushl $199
c0102611:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102616:	e9 0c f8 ff ff       	jmp    c0101e27 <__alltraps>

c010261b <vector200>:
.globl vector200
vector200:
  pushl $0
c010261b:	6a 00                	push   $0x0
  pushl $200
c010261d:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102622:	e9 00 f8 ff ff       	jmp    c0101e27 <__alltraps>

c0102627 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102627:	6a 00                	push   $0x0
  pushl $201
c0102629:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010262e:	e9 f4 f7 ff ff       	jmp    c0101e27 <__alltraps>

c0102633 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102633:	6a 00                	push   $0x0
  pushl $202
c0102635:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010263a:	e9 e8 f7 ff ff       	jmp    c0101e27 <__alltraps>

c010263f <vector203>:
.globl vector203
vector203:
  pushl $0
c010263f:	6a 00                	push   $0x0
  pushl $203
c0102641:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102646:	e9 dc f7 ff ff       	jmp    c0101e27 <__alltraps>

c010264b <vector204>:
.globl vector204
vector204:
  pushl $0
c010264b:	6a 00                	push   $0x0
  pushl $204
c010264d:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102652:	e9 d0 f7 ff ff       	jmp    c0101e27 <__alltraps>

c0102657 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102657:	6a 00                	push   $0x0
  pushl $205
c0102659:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010265e:	e9 c4 f7 ff ff       	jmp    c0101e27 <__alltraps>

c0102663 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102663:	6a 00                	push   $0x0
  pushl $206
c0102665:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010266a:	e9 b8 f7 ff ff       	jmp    c0101e27 <__alltraps>

c010266f <vector207>:
.globl vector207
vector207:
  pushl $0
c010266f:	6a 00                	push   $0x0
  pushl $207
c0102671:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102676:	e9 ac f7 ff ff       	jmp    c0101e27 <__alltraps>

c010267b <vector208>:
.globl vector208
vector208:
  pushl $0
c010267b:	6a 00                	push   $0x0
  pushl $208
c010267d:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102682:	e9 a0 f7 ff ff       	jmp    c0101e27 <__alltraps>

c0102687 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102687:	6a 00                	push   $0x0
  pushl $209
c0102689:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010268e:	e9 94 f7 ff ff       	jmp    c0101e27 <__alltraps>

c0102693 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102693:	6a 00                	push   $0x0
  pushl $210
c0102695:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010269a:	e9 88 f7 ff ff       	jmp    c0101e27 <__alltraps>

c010269f <vector211>:
.globl vector211
vector211:
  pushl $0
c010269f:	6a 00                	push   $0x0
  pushl $211
c01026a1:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01026a6:	e9 7c f7 ff ff       	jmp    c0101e27 <__alltraps>

c01026ab <vector212>:
.globl vector212
vector212:
  pushl $0
c01026ab:	6a 00                	push   $0x0
  pushl $212
c01026ad:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01026b2:	e9 70 f7 ff ff       	jmp    c0101e27 <__alltraps>

c01026b7 <vector213>:
.globl vector213
vector213:
  pushl $0
c01026b7:	6a 00                	push   $0x0
  pushl $213
c01026b9:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01026be:	e9 64 f7 ff ff       	jmp    c0101e27 <__alltraps>

c01026c3 <vector214>:
.globl vector214
vector214:
  pushl $0
c01026c3:	6a 00                	push   $0x0
  pushl $214
c01026c5:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01026ca:	e9 58 f7 ff ff       	jmp    c0101e27 <__alltraps>

c01026cf <vector215>:
.globl vector215
vector215:
  pushl $0
c01026cf:	6a 00                	push   $0x0
  pushl $215
c01026d1:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01026d6:	e9 4c f7 ff ff       	jmp    c0101e27 <__alltraps>

c01026db <vector216>:
.globl vector216
vector216:
  pushl $0
c01026db:	6a 00                	push   $0x0
  pushl $216
c01026dd:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01026e2:	e9 40 f7 ff ff       	jmp    c0101e27 <__alltraps>

c01026e7 <vector217>:
.globl vector217
vector217:
  pushl $0
c01026e7:	6a 00                	push   $0x0
  pushl $217
c01026e9:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01026ee:	e9 34 f7 ff ff       	jmp    c0101e27 <__alltraps>

c01026f3 <vector218>:
.globl vector218
vector218:
  pushl $0
c01026f3:	6a 00                	push   $0x0
  pushl $218
c01026f5:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01026fa:	e9 28 f7 ff ff       	jmp    c0101e27 <__alltraps>

c01026ff <vector219>:
.globl vector219
vector219:
  pushl $0
c01026ff:	6a 00                	push   $0x0
  pushl $219
c0102701:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102706:	e9 1c f7 ff ff       	jmp    c0101e27 <__alltraps>

c010270b <vector220>:
.globl vector220
vector220:
  pushl $0
c010270b:	6a 00                	push   $0x0
  pushl $220
c010270d:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102712:	e9 10 f7 ff ff       	jmp    c0101e27 <__alltraps>

c0102717 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102717:	6a 00                	push   $0x0
  pushl $221
c0102719:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010271e:	e9 04 f7 ff ff       	jmp    c0101e27 <__alltraps>

c0102723 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102723:	6a 00                	push   $0x0
  pushl $222
c0102725:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010272a:	e9 f8 f6 ff ff       	jmp    c0101e27 <__alltraps>

c010272f <vector223>:
.globl vector223
vector223:
  pushl $0
c010272f:	6a 00                	push   $0x0
  pushl $223
c0102731:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102736:	e9 ec f6 ff ff       	jmp    c0101e27 <__alltraps>

c010273b <vector224>:
.globl vector224
vector224:
  pushl $0
c010273b:	6a 00                	push   $0x0
  pushl $224
c010273d:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102742:	e9 e0 f6 ff ff       	jmp    c0101e27 <__alltraps>

c0102747 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102747:	6a 00                	push   $0x0
  pushl $225
c0102749:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010274e:	e9 d4 f6 ff ff       	jmp    c0101e27 <__alltraps>

c0102753 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102753:	6a 00                	push   $0x0
  pushl $226
c0102755:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010275a:	e9 c8 f6 ff ff       	jmp    c0101e27 <__alltraps>

c010275f <vector227>:
.globl vector227
vector227:
  pushl $0
c010275f:	6a 00                	push   $0x0
  pushl $227
c0102761:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102766:	e9 bc f6 ff ff       	jmp    c0101e27 <__alltraps>

c010276b <vector228>:
.globl vector228
vector228:
  pushl $0
c010276b:	6a 00                	push   $0x0
  pushl $228
c010276d:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102772:	e9 b0 f6 ff ff       	jmp    c0101e27 <__alltraps>

c0102777 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102777:	6a 00                	push   $0x0
  pushl $229
c0102779:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010277e:	e9 a4 f6 ff ff       	jmp    c0101e27 <__alltraps>

c0102783 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102783:	6a 00                	push   $0x0
  pushl $230
c0102785:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010278a:	e9 98 f6 ff ff       	jmp    c0101e27 <__alltraps>

c010278f <vector231>:
.globl vector231
vector231:
  pushl $0
c010278f:	6a 00                	push   $0x0
  pushl $231
c0102791:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102796:	e9 8c f6 ff ff       	jmp    c0101e27 <__alltraps>

c010279b <vector232>:
.globl vector232
vector232:
  pushl $0
c010279b:	6a 00                	push   $0x0
  pushl $232
c010279d:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01027a2:	e9 80 f6 ff ff       	jmp    c0101e27 <__alltraps>

c01027a7 <vector233>:
.globl vector233
vector233:
  pushl $0
c01027a7:	6a 00                	push   $0x0
  pushl $233
c01027a9:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01027ae:	e9 74 f6 ff ff       	jmp    c0101e27 <__alltraps>

c01027b3 <vector234>:
.globl vector234
vector234:
  pushl $0
c01027b3:	6a 00                	push   $0x0
  pushl $234
c01027b5:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01027ba:	e9 68 f6 ff ff       	jmp    c0101e27 <__alltraps>

c01027bf <vector235>:
.globl vector235
vector235:
  pushl $0
c01027bf:	6a 00                	push   $0x0
  pushl $235
c01027c1:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01027c6:	e9 5c f6 ff ff       	jmp    c0101e27 <__alltraps>

c01027cb <vector236>:
.globl vector236
vector236:
  pushl $0
c01027cb:	6a 00                	push   $0x0
  pushl $236
c01027cd:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01027d2:	e9 50 f6 ff ff       	jmp    c0101e27 <__alltraps>

c01027d7 <vector237>:
.globl vector237
vector237:
  pushl $0
c01027d7:	6a 00                	push   $0x0
  pushl $237
c01027d9:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01027de:	e9 44 f6 ff ff       	jmp    c0101e27 <__alltraps>

c01027e3 <vector238>:
.globl vector238
vector238:
  pushl $0
c01027e3:	6a 00                	push   $0x0
  pushl $238
c01027e5:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01027ea:	e9 38 f6 ff ff       	jmp    c0101e27 <__alltraps>

c01027ef <vector239>:
.globl vector239
vector239:
  pushl $0
c01027ef:	6a 00                	push   $0x0
  pushl $239
c01027f1:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01027f6:	e9 2c f6 ff ff       	jmp    c0101e27 <__alltraps>

c01027fb <vector240>:
.globl vector240
vector240:
  pushl $0
c01027fb:	6a 00                	push   $0x0
  pushl $240
c01027fd:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102802:	e9 20 f6 ff ff       	jmp    c0101e27 <__alltraps>

c0102807 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102807:	6a 00                	push   $0x0
  pushl $241
c0102809:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010280e:	e9 14 f6 ff ff       	jmp    c0101e27 <__alltraps>

c0102813 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102813:	6a 00                	push   $0x0
  pushl $242
c0102815:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010281a:	e9 08 f6 ff ff       	jmp    c0101e27 <__alltraps>

c010281f <vector243>:
.globl vector243
vector243:
  pushl $0
c010281f:	6a 00                	push   $0x0
  pushl $243
c0102821:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102826:	e9 fc f5 ff ff       	jmp    c0101e27 <__alltraps>

c010282b <vector244>:
.globl vector244
vector244:
  pushl $0
c010282b:	6a 00                	push   $0x0
  pushl $244
c010282d:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102832:	e9 f0 f5 ff ff       	jmp    c0101e27 <__alltraps>

c0102837 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102837:	6a 00                	push   $0x0
  pushl $245
c0102839:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010283e:	e9 e4 f5 ff ff       	jmp    c0101e27 <__alltraps>

c0102843 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102843:	6a 00                	push   $0x0
  pushl $246
c0102845:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010284a:	e9 d8 f5 ff ff       	jmp    c0101e27 <__alltraps>

c010284f <vector247>:
.globl vector247
vector247:
  pushl $0
c010284f:	6a 00                	push   $0x0
  pushl $247
c0102851:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102856:	e9 cc f5 ff ff       	jmp    c0101e27 <__alltraps>

c010285b <vector248>:
.globl vector248
vector248:
  pushl $0
c010285b:	6a 00                	push   $0x0
  pushl $248
c010285d:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102862:	e9 c0 f5 ff ff       	jmp    c0101e27 <__alltraps>

c0102867 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102867:	6a 00                	push   $0x0
  pushl $249
c0102869:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010286e:	e9 b4 f5 ff ff       	jmp    c0101e27 <__alltraps>

c0102873 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102873:	6a 00                	push   $0x0
  pushl $250
c0102875:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010287a:	e9 a8 f5 ff ff       	jmp    c0101e27 <__alltraps>

c010287f <vector251>:
.globl vector251
vector251:
  pushl $0
c010287f:	6a 00                	push   $0x0
  pushl $251
c0102881:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102886:	e9 9c f5 ff ff       	jmp    c0101e27 <__alltraps>

c010288b <vector252>:
.globl vector252
vector252:
  pushl $0
c010288b:	6a 00                	push   $0x0
  pushl $252
c010288d:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102892:	e9 90 f5 ff ff       	jmp    c0101e27 <__alltraps>

c0102897 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102897:	6a 00                	push   $0x0
  pushl $253
c0102899:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010289e:	e9 84 f5 ff ff       	jmp    c0101e27 <__alltraps>

c01028a3 <vector254>:
.globl vector254
vector254:
  pushl $0
c01028a3:	6a 00                	push   $0x0
  pushl $254
c01028a5:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01028aa:	e9 78 f5 ff ff       	jmp    c0101e27 <__alltraps>

c01028af <vector255>:
.globl vector255
vector255:
  pushl $0
c01028af:	6a 00                	push   $0x0
  pushl $255
c01028b1:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01028b6:	e9 6c f5 ff ff       	jmp    c0101e27 <__alltraps>

c01028bb <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01028bb:	55                   	push   %ebp
c01028bc:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01028be:	8b 55 08             	mov    0x8(%ebp),%edx
c01028c1:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c01028c6:	29 c2                	sub    %eax,%edx
c01028c8:	89 d0                	mov    %edx,%eax
c01028ca:	c1 f8 02             	sar    $0x2,%eax
c01028cd:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01028d3:	5d                   	pop    %ebp
c01028d4:	c3                   	ret    

c01028d5 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01028d5:	55                   	push   %ebp
c01028d6:	89 e5                	mov    %esp,%ebp
c01028d8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01028db:	8b 45 08             	mov    0x8(%ebp),%eax
c01028de:	89 04 24             	mov    %eax,(%esp)
c01028e1:	e8 d5 ff ff ff       	call   c01028bb <page2ppn>
c01028e6:	c1 e0 0c             	shl    $0xc,%eax
}
c01028e9:	c9                   	leave  
c01028ea:	c3                   	ret    

c01028eb <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01028eb:	55                   	push   %ebp
c01028ec:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01028ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01028f1:	8b 00                	mov    (%eax),%eax
}
c01028f3:	5d                   	pop    %ebp
c01028f4:	c3                   	ret    

c01028f5 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01028f5:	55                   	push   %ebp
c01028f6:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01028f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01028fb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01028fe:	89 10                	mov    %edx,(%eax)
}
c0102900:	5d                   	pop    %ebp
c0102901:	c3                   	ret    

c0102902 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0102902:	55                   	push   %ebp
c0102903:	89 e5                	mov    %esp,%ebp
c0102905:	83 ec 10             	sub    $0x10,%esp
c0102908:	c7 45 fc 70 af 11 c0 	movl   $0xc011af70,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010290f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102912:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102915:	89 50 04             	mov    %edx,0x4(%eax)
c0102918:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010291b:	8b 50 04             	mov    0x4(%eax),%edx
c010291e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102921:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0102923:	c7 05 78 af 11 c0 00 	movl   $0x0,0xc011af78
c010292a:	00 00 00 
}
c010292d:	c9                   	leave  
c010292e:	c3                   	ret    

c010292f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010292f:	55                   	push   %ebp
c0102930:	89 e5                	mov    %esp,%ebp
c0102932:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0102935:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102939:	75 24                	jne    c010295f <default_init_memmap+0x30>
c010293b:	c7 44 24 0c 30 67 10 	movl   $0xc0106730,0xc(%esp)
c0102942:	c0 
c0102943:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010294a:	c0 
c010294b:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0102952:	00 
c0102953:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010295a:	e8 73 e3 ff ff       	call   c0100cd2 <__panic>
    struct Page *p = base;
c010295f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102962:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102965:	eb 7d                	jmp    c01029e4 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0102967:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010296a:	83 c0 04             	add    $0x4,%eax
c010296d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102974:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102977:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010297a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010297d:	0f a3 10             	bt     %edx,(%eax)
c0102980:	19 c0                	sbb    %eax,%eax
c0102982:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102985:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102989:	0f 95 c0             	setne  %al
c010298c:	0f b6 c0             	movzbl %al,%eax
c010298f:	85 c0                	test   %eax,%eax
c0102991:	75 24                	jne    c01029b7 <default_init_memmap+0x88>
c0102993:	c7 44 24 0c 61 67 10 	movl   $0xc0106761,0xc(%esp)
c010299a:	c0 
c010299b:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01029a2:	c0 
c01029a3:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01029aa:	00 
c01029ab:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01029b2:	e8 1b e3 ff ff       	call   c0100cd2 <__panic>
        p->flags = p->property = 0;
c01029b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01029c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029c4:	8b 50 08             	mov    0x8(%eax),%edx
c01029c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029ca:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01029cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01029d4:	00 
c01029d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029d8:	89 04 24             	mov    %eax,(%esp)
c01029db:	e8 15 ff ff ff       	call   c01028f5 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01029e0:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01029e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029e7:	89 d0                	mov    %edx,%eax
c01029e9:	c1 e0 02             	shl    $0x2,%eax
c01029ec:	01 d0                	add    %edx,%eax
c01029ee:	c1 e0 02             	shl    $0x2,%eax
c01029f1:	89 c2                	mov    %eax,%edx
c01029f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f6:	01 d0                	add    %edx,%eax
c01029f8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01029fb:	0f 85 66 ff ff ff    	jne    c0102967 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0102a01:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a04:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102a07:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102a0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a0d:	83 c0 04             	add    $0x4,%eax
c0102a10:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0102a17:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102a1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102a1d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102a20:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0102a23:	8b 15 78 af 11 c0    	mov    0xc011af78,%edx
c0102a29:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102a2c:	01 d0                	add    %edx,%eax
c0102a2e:	a3 78 af 11 c0       	mov    %eax,0xc011af78
    list_add_before(&free_list, &(base->page_link));
c0102a33:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a36:	83 c0 0c             	add    $0xc,%eax
c0102a39:	c7 45 dc 70 af 11 c0 	movl   $0xc011af70,-0x24(%ebp)
c0102a40:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102a43:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102a46:	8b 00                	mov    (%eax),%eax
c0102a48:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102a4b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102a4e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102a51:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102a54:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102a57:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a5a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102a5d:	89 10                	mov    %edx,(%eax)
c0102a5f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a62:	8b 10                	mov    (%eax),%edx
c0102a64:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102a67:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102a6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a6d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102a70:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102a73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a76:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102a79:	89 10                	mov    %edx,(%eax)
}
c0102a7b:	c9                   	leave  
c0102a7c:	c3                   	ret    

c0102a7d <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102a7d:	55                   	push   %ebp
c0102a7e:	89 e5                	mov    %esp,%ebp
c0102a80:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102a83:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a87:	75 24                	jne    c0102aad <default_alloc_pages+0x30>
c0102a89:	c7 44 24 0c 30 67 10 	movl   $0xc0106730,0xc(%esp)
c0102a90:	c0 
c0102a91:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102a98:	c0 
c0102a99:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0102aa0:	00 
c0102aa1:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102aa8:	e8 25 e2 ff ff       	call   c0100cd2 <__panic>
    if (n > nr_free) {
c0102aad:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c0102ab2:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102ab5:	73 0a                	jae    c0102ac1 <default_alloc_pages+0x44>
        return NULL;
c0102ab7:	b8 00 00 00 00       	mov    $0x0,%eax
c0102abc:	e9 3d 01 00 00       	jmp    c0102bfe <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
c0102ac1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0102ac8:	c7 45 f0 70 af 11 c0 	movl   $0xc011af70,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0102acf:	eb 1c                	jmp    c0102aed <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0102ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ad4:	83 e8 0c             	sub    $0xc,%eax
c0102ad7:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0102ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102add:	8b 40 08             	mov    0x8(%eax),%eax
c0102ae0:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102ae3:	72 08                	jb     c0102aed <default_alloc_pages+0x70>
            page = p;
c0102ae5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ae8:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102aeb:	eb 18                	jmp    c0102b05 <default_alloc_pages+0x88>
c0102aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102af0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102af3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102af6:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0102af9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102afc:	81 7d f0 70 af 11 c0 	cmpl   $0xc011af70,-0x10(%ebp)
c0102b03:	75 cc                	jne    c0102ad1 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0102b05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102b09:	0f 84 ec 00 00 00    	je     c0102bfb <default_alloc_pages+0x17e>
        if (page->property > n) {
c0102b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b12:	8b 40 08             	mov    0x8(%eax),%eax
c0102b15:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102b18:	0f 86 8c 00 00 00    	jbe    c0102baa <default_alloc_pages+0x12d>
            struct Page *p = page + n;
c0102b1e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b21:	89 d0                	mov    %edx,%eax
c0102b23:	c1 e0 02             	shl    $0x2,%eax
c0102b26:	01 d0                	add    %edx,%eax
c0102b28:	c1 e0 02             	shl    $0x2,%eax
c0102b2b:	89 c2                	mov    %eax,%edx
c0102b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b30:	01 d0                	add    %edx,%eax
c0102b32:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0102b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b38:	8b 40 08             	mov    0x8(%eax),%eax
c0102b3b:	2b 45 08             	sub    0x8(%ebp),%eax
c0102b3e:	89 c2                	mov    %eax,%edx
c0102b40:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b43:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0102b46:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b49:	83 c0 04             	add    $0x4,%eax
c0102b4c:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102b53:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102b56:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102b59:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102b5c:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0102b5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b62:	83 c0 0c             	add    $0xc,%eax
c0102b65:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102b68:	83 c2 0c             	add    $0xc,%edx
c0102b6b:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0102b6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102b71:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102b74:	8b 40 04             	mov    0x4(%eax),%eax
c0102b77:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102b7a:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0102b7d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102b80:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0102b83:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102b86:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b89:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102b8c:	89 10                	mov    %edx,(%eax)
c0102b8e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b91:	8b 10                	mov    (%eax),%edx
c0102b93:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102b96:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102b99:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b9c:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102b9f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102ba2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102ba5:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102ba8:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c0102baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bad:	83 c0 0c             	add    $0xc,%eax
c0102bb0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102bb3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102bb6:	8b 40 04             	mov    0x4(%eax),%eax
c0102bb9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102bbc:	8b 12                	mov    (%edx),%edx
c0102bbe:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0102bc1:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102bc4:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102bc7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102bca:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102bcd:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102bd0:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102bd3:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0102bd5:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c0102bda:	2b 45 08             	sub    0x8(%ebp),%eax
c0102bdd:	a3 78 af 11 c0       	mov    %eax,0xc011af78
        ClearPageProperty(page);
c0102be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102be5:	83 c0 04             	add    $0x4,%eax
c0102be8:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102bef:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102bf2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102bf5:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102bf8:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0102bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102bfe:	c9                   	leave  
c0102bff:	c3                   	ret    

c0102c00 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102c00:	55                   	push   %ebp
c0102c01:	89 e5                	mov    %esp,%ebp
c0102c03:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0102c09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102c0d:	75 24                	jne    c0102c33 <default_free_pages+0x33>
c0102c0f:	c7 44 24 0c 30 67 10 	movl   $0xc0106730,0xc(%esp)
c0102c16:	c0 
c0102c17:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102c1e:	c0 
c0102c1f:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c0102c26:	00 
c0102c27:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102c2e:	e8 9f e0 ff ff       	call   c0100cd2 <__panic>
    struct Page *p = base;
c0102c33:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102c39:	e9 9d 00 00 00       	jmp    c0102cdb <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0102c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c41:	83 c0 04             	add    $0x4,%eax
c0102c44:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102c4b:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102c4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102c51:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102c54:	0f a3 10             	bt     %edx,(%eax)
c0102c57:	19 c0                	sbb    %eax,%eax
c0102c59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102c5c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102c60:	0f 95 c0             	setne  %al
c0102c63:	0f b6 c0             	movzbl %al,%eax
c0102c66:	85 c0                	test   %eax,%eax
c0102c68:	75 2c                	jne    c0102c96 <default_free_pages+0x96>
c0102c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c6d:	83 c0 04             	add    $0x4,%eax
c0102c70:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102c77:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102c7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102c7d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102c80:	0f a3 10             	bt     %edx,(%eax)
c0102c83:	19 c0                	sbb    %eax,%eax
c0102c85:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102c88:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102c8c:	0f 95 c0             	setne  %al
c0102c8f:	0f b6 c0             	movzbl %al,%eax
c0102c92:	85 c0                	test   %eax,%eax
c0102c94:	74 24                	je     c0102cba <default_free_pages+0xba>
c0102c96:	c7 44 24 0c 74 67 10 	movl   $0xc0106774,0xc(%esp)
c0102c9d:	c0 
c0102c9e:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102ca5:	c0 
c0102ca6:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0102cad:	00 
c0102cae:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102cb5:	e8 18 e0 ff ff       	call   c0100cd2 <__panic>
        p->flags = 0;
c0102cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cbd:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102cc4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102ccb:	00 
c0102ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ccf:	89 04 24             	mov    %eax,(%esp)
c0102cd2:	e8 1e fc ff ff       	call   c01028f5 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102cd7:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102cdb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102cde:	89 d0                	mov    %edx,%eax
c0102ce0:	c1 e0 02             	shl    $0x2,%eax
c0102ce3:	01 d0                	add    %edx,%eax
c0102ce5:	c1 e0 02             	shl    $0x2,%eax
c0102ce8:	89 c2                	mov    %eax,%edx
c0102cea:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ced:	01 d0                	add    %edx,%eax
c0102cef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102cf2:	0f 85 46 ff ff ff    	jne    c0102c3e <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0102cf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cfb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102cfe:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102d01:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d04:	83 c0 04             	add    $0x4,%eax
c0102d07:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102d0e:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d11:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102d14:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102d17:	0f ab 10             	bts    %edx,(%eax)
c0102d1a:	c7 45 cc 70 af 11 c0 	movl   $0xc011af70,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102d21:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102d24:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0102d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102d2a:	e9 08 01 00 00       	jmp    c0102e37 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0102d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d32:	83 e8 0c             	sub    $0xc,%eax
c0102d35:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d3b:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102d3e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102d41:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102d44:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0102d47:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d4a:	8b 50 08             	mov    0x8(%eax),%edx
c0102d4d:	89 d0                	mov    %edx,%eax
c0102d4f:	c1 e0 02             	shl    $0x2,%eax
c0102d52:	01 d0                	add    %edx,%eax
c0102d54:	c1 e0 02             	shl    $0x2,%eax
c0102d57:	89 c2                	mov    %eax,%edx
c0102d59:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d5c:	01 d0                	add    %edx,%eax
c0102d5e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102d61:	75 5a                	jne    c0102dbd <default_free_pages+0x1bd>
            base->property += p->property;
c0102d63:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d66:	8b 50 08             	mov    0x8(%eax),%edx
c0102d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d6c:	8b 40 08             	mov    0x8(%eax),%eax
c0102d6f:	01 c2                	add    %eax,%edx
c0102d71:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d74:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d7a:	83 c0 04             	add    $0x4,%eax
c0102d7d:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0102d84:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d87:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102d8a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102d8d:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0102d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d93:	83 c0 0c             	add    $0xc,%eax
c0102d96:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102d99:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102d9c:	8b 40 04             	mov    0x4(%eax),%eax
c0102d9f:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102da2:	8b 12                	mov    (%edx),%edx
c0102da4:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0102da7:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102daa:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102dad:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102db0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102db3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102db6:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102db9:	89 10                	mov    %edx,(%eax)
c0102dbb:	eb 7a                	jmp    c0102e37 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0102dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dc0:	8b 50 08             	mov    0x8(%eax),%edx
c0102dc3:	89 d0                	mov    %edx,%eax
c0102dc5:	c1 e0 02             	shl    $0x2,%eax
c0102dc8:	01 d0                	add    %edx,%eax
c0102dca:	c1 e0 02             	shl    $0x2,%eax
c0102dcd:	89 c2                	mov    %eax,%edx
c0102dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dd2:	01 d0                	add    %edx,%eax
c0102dd4:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102dd7:	75 5e                	jne    c0102e37 <default_free_pages+0x237>
            p->property += base->property;
c0102dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ddc:	8b 50 08             	mov    0x8(%eax),%edx
c0102ddf:	8b 45 08             	mov    0x8(%ebp),%eax
c0102de2:	8b 40 08             	mov    0x8(%eax),%eax
c0102de5:	01 c2                	add    %eax,%edx
c0102de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dea:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102ded:	8b 45 08             	mov    0x8(%ebp),%eax
c0102df0:	83 c0 04             	add    $0x4,%eax
c0102df3:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0102dfa:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102dfd:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102e00:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102e03:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0102e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e09:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e0f:	83 c0 0c             	add    $0xc,%eax
c0102e12:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102e15:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102e18:	8b 40 04             	mov    0x4(%eax),%eax
c0102e1b:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102e1e:	8b 12                	mov    (%edx),%edx
c0102e20:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102e23:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102e26:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102e29:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0102e2c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102e2f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102e32:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102e35:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0102e37:	81 7d f0 70 af 11 c0 	cmpl   $0xc011af70,-0x10(%ebp)
c0102e3e:	0f 85 eb fe ff ff    	jne    c0102d2f <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0102e44:	8b 15 78 af 11 c0    	mov    0xc011af78,%edx
c0102e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102e4d:	01 d0                	add    %edx,%eax
c0102e4f:	a3 78 af 11 c0       	mov    %eax,0xc011af78
c0102e54:	c7 45 9c 70 af 11 c0 	movl   $0xc011af70,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102e5b:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102e5e:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0102e61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102e64:	eb 76                	jmp    c0102edc <default_free_pages+0x2dc>
        p = le2page(le, page_link);
c0102e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e69:	83 e8 0c             	sub    $0xc,%eax
c0102e6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0102e6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e72:	8b 50 08             	mov    0x8(%eax),%edx
c0102e75:	89 d0                	mov    %edx,%eax
c0102e77:	c1 e0 02             	shl    $0x2,%eax
c0102e7a:	01 d0                	add    %edx,%eax
c0102e7c:	c1 e0 02             	shl    $0x2,%eax
c0102e7f:	89 c2                	mov    %eax,%edx
c0102e81:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e84:	01 d0                	add    %edx,%eax
c0102e86:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e89:	77 42                	ja     c0102ecd <default_free_pages+0x2cd>
            assert(base + base->property != p);
c0102e8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e8e:	8b 50 08             	mov    0x8(%eax),%edx
c0102e91:	89 d0                	mov    %edx,%eax
c0102e93:	c1 e0 02             	shl    $0x2,%eax
c0102e96:	01 d0                	add    %edx,%eax
c0102e98:	c1 e0 02             	shl    $0x2,%eax
c0102e9b:	89 c2                	mov    %eax,%edx
c0102e9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ea0:	01 d0                	add    %edx,%eax
c0102ea2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102ea5:	75 24                	jne    c0102ecb <default_free_pages+0x2cb>
c0102ea7:	c7 44 24 0c 99 67 10 	movl   $0xc0106799,0xc(%esp)
c0102eae:	c0 
c0102eaf:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102eb6:	c0 
c0102eb7:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0102ebe:	00 
c0102ebf:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102ec6:	e8 07 de ff ff       	call   c0100cd2 <__panic>
            break;
c0102ecb:	eb 18                	jmp    c0102ee5 <default_free_pages+0x2e5>
c0102ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ed0:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102ed3:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102ed6:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0102ed9:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0102edc:	81 7d f0 70 af 11 c0 	cmpl   $0xc011af70,-0x10(%ebp)
c0102ee3:	75 81                	jne    c0102e66 <default_free_pages+0x266>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0102ee5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ee8:	8d 50 0c             	lea    0xc(%eax),%edx
c0102eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102eee:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102ef1:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102ef4:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102ef7:	8b 00                	mov    (%eax),%eax
c0102ef9:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102efc:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0102eff:	89 45 88             	mov    %eax,-0x78(%ebp)
c0102f02:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102f05:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102f08:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102f0b:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0102f0e:	89 10                	mov    %edx,(%eax)
c0102f10:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102f13:	8b 10                	mov    (%eax),%edx
c0102f15:	8b 45 88             	mov    -0x78(%ebp),%eax
c0102f18:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102f1b:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102f1e:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102f21:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102f24:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102f27:	8b 55 88             	mov    -0x78(%ebp),%edx
c0102f2a:	89 10                	mov    %edx,(%eax)
}
c0102f2c:	c9                   	leave  
c0102f2d:	c3                   	ret    

c0102f2e <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102f2e:	55                   	push   %ebp
c0102f2f:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102f31:	a1 78 af 11 c0       	mov    0xc011af78,%eax
}
c0102f36:	5d                   	pop    %ebp
c0102f37:	c3                   	ret    

c0102f38 <basic_check>:

static void
basic_check(void) {
c0102f38:	55                   	push   %ebp
c0102f39:	89 e5                	mov    %esp,%ebp
c0102f3b:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102f3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f48:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102f51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f58:	e8 9d 0e 00 00       	call   c0103dfa <alloc_pages>
c0102f5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102f60:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102f64:	75 24                	jne    c0102f8a <basic_check+0x52>
c0102f66:	c7 44 24 0c b4 67 10 	movl   $0xc01067b4,0xc(%esp)
c0102f6d:	c0 
c0102f6e:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102f75:	c0 
c0102f76:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0102f7d:	00 
c0102f7e:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102f85:	e8 48 dd ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102f8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f91:	e8 64 0e 00 00       	call   c0103dfa <alloc_pages>
c0102f96:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102f9d:	75 24                	jne    c0102fc3 <basic_check+0x8b>
c0102f9f:	c7 44 24 0c d0 67 10 	movl   $0xc01067d0,0xc(%esp)
c0102fa6:	c0 
c0102fa7:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102fae:	c0 
c0102faf:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0102fb6:	00 
c0102fb7:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102fbe:	e8 0f dd ff ff       	call   c0100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0102fc3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102fca:	e8 2b 0e 00 00       	call   c0103dfa <alloc_pages>
c0102fcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102fd2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102fd6:	75 24                	jne    c0102ffc <basic_check+0xc4>
c0102fd8:	c7 44 24 0c ec 67 10 	movl   $0xc01067ec,0xc(%esp)
c0102fdf:	c0 
c0102fe0:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102fe7:	c0 
c0102fe8:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0102fef:	00 
c0102ff0:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102ff7:	e8 d6 dc ff ff       	call   c0100cd2 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0102ffc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103002:	74 10                	je     c0103014 <basic_check+0xdc>
c0103004:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103007:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010300a:	74 08                	je     c0103014 <basic_check+0xdc>
c010300c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010300f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103012:	75 24                	jne    c0103038 <basic_check+0x100>
c0103014:	c7 44 24 0c 08 68 10 	movl   $0xc0106808,0xc(%esp)
c010301b:	c0 
c010301c:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103023:	c0 
c0103024:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c010302b:	00 
c010302c:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103033:	e8 9a dc ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103038:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010303b:	89 04 24             	mov    %eax,(%esp)
c010303e:	e8 a8 f8 ff ff       	call   c01028eb <page_ref>
c0103043:	85 c0                	test   %eax,%eax
c0103045:	75 1e                	jne    c0103065 <basic_check+0x12d>
c0103047:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010304a:	89 04 24             	mov    %eax,(%esp)
c010304d:	e8 99 f8 ff ff       	call   c01028eb <page_ref>
c0103052:	85 c0                	test   %eax,%eax
c0103054:	75 0f                	jne    c0103065 <basic_check+0x12d>
c0103056:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103059:	89 04 24             	mov    %eax,(%esp)
c010305c:	e8 8a f8 ff ff       	call   c01028eb <page_ref>
c0103061:	85 c0                	test   %eax,%eax
c0103063:	74 24                	je     c0103089 <basic_check+0x151>
c0103065:	c7 44 24 0c 2c 68 10 	movl   $0xc010682c,0xc(%esp)
c010306c:	c0 
c010306d:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103074:	c0 
c0103075:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c010307c:	00 
c010307d:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103084:	e8 49 dc ff ff       	call   c0100cd2 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103089:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010308c:	89 04 24             	mov    %eax,(%esp)
c010308f:	e8 41 f8 ff ff       	call   c01028d5 <page2pa>
c0103094:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c010309a:	c1 e2 0c             	shl    $0xc,%edx
c010309d:	39 d0                	cmp    %edx,%eax
c010309f:	72 24                	jb     c01030c5 <basic_check+0x18d>
c01030a1:	c7 44 24 0c 68 68 10 	movl   $0xc0106868,0xc(%esp)
c01030a8:	c0 
c01030a9:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01030b0:	c0 
c01030b1:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c01030b8:	00 
c01030b9:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01030c0:	e8 0d dc ff ff       	call   c0100cd2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01030c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030c8:	89 04 24             	mov    %eax,(%esp)
c01030cb:	e8 05 f8 ff ff       	call   c01028d5 <page2pa>
c01030d0:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01030d6:	c1 e2 0c             	shl    $0xc,%edx
c01030d9:	39 d0                	cmp    %edx,%eax
c01030db:	72 24                	jb     c0103101 <basic_check+0x1c9>
c01030dd:	c7 44 24 0c 85 68 10 	movl   $0xc0106885,0xc(%esp)
c01030e4:	c0 
c01030e5:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01030ec:	c0 
c01030ed:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c01030f4:	00 
c01030f5:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01030fc:	e8 d1 db ff ff       	call   c0100cd2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103101:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103104:	89 04 24             	mov    %eax,(%esp)
c0103107:	e8 c9 f7 ff ff       	call   c01028d5 <page2pa>
c010310c:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0103112:	c1 e2 0c             	shl    $0xc,%edx
c0103115:	39 d0                	cmp    %edx,%eax
c0103117:	72 24                	jb     c010313d <basic_check+0x205>
c0103119:	c7 44 24 0c a2 68 10 	movl   $0xc01068a2,0xc(%esp)
c0103120:	c0 
c0103121:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103128:	c0 
c0103129:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103130:	00 
c0103131:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103138:	e8 95 db ff ff       	call   c0100cd2 <__panic>

    list_entry_t free_list_store = free_list;
c010313d:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c0103142:	8b 15 74 af 11 c0    	mov    0xc011af74,%edx
c0103148:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010314b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010314e:	c7 45 e0 70 af 11 c0 	movl   $0xc011af70,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103155:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103158:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010315b:	89 50 04             	mov    %edx,0x4(%eax)
c010315e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103161:	8b 50 04             	mov    0x4(%eax),%edx
c0103164:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103167:	89 10                	mov    %edx,(%eax)
c0103169:	c7 45 dc 70 af 11 c0 	movl   $0xc011af70,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103170:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103173:	8b 40 04             	mov    0x4(%eax),%eax
c0103176:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103179:	0f 94 c0             	sete   %al
c010317c:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010317f:	85 c0                	test   %eax,%eax
c0103181:	75 24                	jne    c01031a7 <basic_check+0x26f>
c0103183:	c7 44 24 0c bf 68 10 	movl   $0xc01068bf,0xc(%esp)
c010318a:	c0 
c010318b:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103192:	c0 
c0103193:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c010319a:	00 
c010319b:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01031a2:	e8 2b db ff ff       	call   c0100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
c01031a7:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c01031ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c01031af:	c7 05 78 af 11 c0 00 	movl   $0x0,0xc011af78
c01031b6:	00 00 00 

    assert(alloc_page() == NULL);
c01031b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031c0:	e8 35 0c 00 00       	call   c0103dfa <alloc_pages>
c01031c5:	85 c0                	test   %eax,%eax
c01031c7:	74 24                	je     c01031ed <basic_check+0x2b5>
c01031c9:	c7 44 24 0c d6 68 10 	movl   $0xc01068d6,0xc(%esp)
c01031d0:	c0 
c01031d1:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01031d8:	c0 
c01031d9:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c01031e0:	00 
c01031e1:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01031e8:	e8 e5 da ff ff       	call   c0100cd2 <__panic>

    free_page(p0);
c01031ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01031f4:	00 
c01031f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031f8:	89 04 24             	mov    %eax,(%esp)
c01031fb:	e8 32 0c 00 00       	call   c0103e32 <free_pages>
    free_page(p1);
c0103200:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103207:	00 
c0103208:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010320b:	89 04 24             	mov    %eax,(%esp)
c010320e:	e8 1f 0c 00 00       	call   c0103e32 <free_pages>
    free_page(p2);
c0103213:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010321a:	00 
c010321b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010321e:	89 04 24             	mov    %eax,(%esp)
c0103221:	e8 0c 0c 00 00       	call   c0103e32 <free_pages>
    assert(nr_free == 3);
c0103226:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c010322b:	83 f8 03             	cmp    $0x3,%eax
c010322e:	74 24                	je     c0103254 <basic_check+0x31c>
c0103230:	c7 44 24 0c eb 68 10 	movl   $0xc01068eb,0xc(%esp)
c0103237:	c0 
c0103238:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010323f:	c0 
c0103240:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0103247:	00 
c0103248:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010324f:	e8 7e da ff ff       	call   c0100cd2 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103254:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010325b:	e8 9a 0b 00 00       	call   c0103dfa <alloc_pages>
c0103260:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103263:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103267:	75 24                	jne    c010328d <basic_check+0x355>
c0103269:	c7 44 24 0c b4 67 10 	movl   $0xc01067b4,0xc(%esp)
c0103270:	c0 
c0103271:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103278:	c0 
c0103279:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0103280:	00 
c0103281:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103288:	e8 45 da ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010328d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103294:	e8 61 0b 00 00       	call   c0103dfa <alloc_pages>
c0103299:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010329c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01032a0:	75 24                	jne    c01032c6 <basic_check+0x38e>
c01032a2:	c7 44 24 0c d0 67 10 	movl   $0xc01067d0,0xc(%esp)
c01032a9:	c0 
c01032aa:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01032b1:	c0 
c01032b2:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c01032b9:	00 
c01032ba:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01032c1:	e8 0c da ff ff       	call   c0100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01032c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032cd:	e8 28 0b 00 00       	call   c0103dfa <alloc_pages>
c01032d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01032d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032d9:	75 24                	jne    c01032ff <basic_check+0x3c7>
c01032db:	c7 44 24 0c ec 67 10 	movl   $0xc01067ec,0xc(%esp)
c01032e2:	c0 
c01032e3:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01032ea:	c0 
c01032eb:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c01032f2:	00 
c01032f3:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01032fa:	e8 d3 d9 ff ff       	call   c0100cd2 <__panic>

    assert(alloc_page() == NULL);
c01032ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103306:	e8 ef 0a 00 00       	call   c0103dfa <alloc_pages>
c010330b:	85 c0                	test   %eax,%eax
c010330d:	74 24                	je     c0103333 <basic_check+0x3fb>
c010330f:	c7 44 24 0c d6 68 10 	movl   $0xc01068d6,0xc(%esp)
c0103316:	c0 
c0103317:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010331e:	c0 
c010331f:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0103326:	00 
c0103327:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010332e:	e8 9f d9 ff ff       	call   c0100cd2 <__panic>

    free_page(p0);
c0103333:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010333a:	00 
c010333b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010333e:	89 04 24             	mov    %eax,(%esp)
c0103341:	e8 ec 0a 00 00       	call   c0103e32 <free_pages>
c0103346:	c7 45 d8 70 af 11 c0 	movl   $0xc011af70,-0x28(%ebp)
c010334d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103350:	8b 40 04             	mov    0x4(%eax),%eax
c0103353:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103356:	0f 94 c0             	sete   %al
c0103359:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c010335c:	85 c0                	test   %eax,%eax
c010335e:	74 24                	je     c0103384 <basic_check+0x44c>
c0103360:	c7 44 24 0c f8 68 10 	movl   $0xc01068f8,0xc(%esp)
c0103367:	c0 
c0103368:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010336f:	c0 
c0103370:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0103377:	00 
c0103378:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010337f:	e8 4e d9 ff ff       	call   c0100cd2 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103384:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010338b:	e8 6a 0a 00 00       	call   c0103dfa <alloc_pages>
c0103390:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103393:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103396:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103399:	74 24                	je     c01033bf <basic_check+0x487>
c010339b:	c7 44 24 0c 10 69 10 	movl   $0xc0106910,0xc(%esp)
c01033a2:	c0 
c01033a3:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01033aa:	c0 
c01033ab:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c01033b2:	00 
c01033b3:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01033ba:	e8 13 d9 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c01033bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01033c6:	e8 2f 0a 00 00       	call   c0103dfa <alloc_pages>
c01033cb:	85 c0                	test   %eax,%eax
c01033cd:	74 24                	je     c01033f3 <basic_check+0x4bb>
c01033cf:	c7 44 24 0c d6 68 10 	movl   $0xc01068d6,0xc(%esp)
c01033d6:	c0 
c01033d7:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01033de:	c0 
c01033df:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c01033e6:	00 
c01033e7:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01033ee:	e8 df d8 ff ff       	call   c0100cd2 <__panic>

    assert(nr_free == 0);
c01033f3:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c01033f8:	85 c0                	test   %eax,%eax
c01033fa:	74 24                	je     c0103420 <basic_check+0x4e8>
c01033fc:	c7 44 24 0c 29 69 10 	movl   $0xc0106929,0xc(%esp)
c0103403:	c0 
c0103404:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010340b:	c0 
c010340c:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0103413:	00 
c0103414:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010341b:	e8 b2 d8 ff ff       	call   c0100cd2 <__panic>
    free_list = free_list_store;
c0103420:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103423:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103426:	a3 70 af 11 c0       	mov    %eax,0xc011af70
c010342b:	89 15 74 af 11 c0    	mov    %edx,0xc011af74
    nr_free = nr_free_store;
c0103431:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103434:	a3 78 af 11 c0       	mov    %eax,0xc011af78

    free_page(p);
c0103439:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103440:	00 
c0103441:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103444:	89 04 24             	mov    %eax,(%esp)
c0103447:	e8 e6 09 00 00       	call   c0103e32 <free_pages>
    free_page(p1);
c010344c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103453:	00 
c0103454:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103457:	89 04 24             	mov    %eax,(%esp)
c010345a:	e8 d3 09 00 00       	call   c0103e32 <free_pages>
    free_page(p2);
c010345f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103466:	00 
c0103467:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010346a:	89 04 24             	mov    %eax,(%esp)
c010346d:	e8 c0 09 00 00       	call   c0103e32 <free_pages>
}
c0103472:	c9                   	leave  
c0103473:	c3                   	ret    

c0103474 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103474:	55                   	push   %ebp
c0103475:	89 e5                	mov    %esp,%ebp
c0103477:	53                   	push   %ebx
c0103478:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c010347e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103485:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c010348c:	c7 45 ec 70 af 11 c0 	movl   $0xc011af70,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103493:	eb 6b                	jmp    c0103500 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0103495:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103498:	83 e8 0c             	sub    $0xc,%eax
c010349b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c010349e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034a1:	83 c0 04             	add    $0x4,%eax
c01034a4:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01034ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01034ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034b1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01034b4:	0f a3 10             	bt     %edx,(%eax)
c01034b7:	19 c0                	sbb    %eax,%eax
c01034b9:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01034bc:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01034c0:	0f 95 c0             	setne  %al
c01034c3:	0f b6 c0             	movzbl %al,%eax
c01034c6:	85 c0                	test   %eax,%eax
c01034c8:	75 24                	jne    c01034ee <default_check+0x7a>
c01034ca:	c7 44 24 0c 36 69 10 	movl   $0xc0106936,0xc(%esp)
c01034d1:	c0 
c01034d2:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01034d9:	c0 
c01034da:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c01034e1:	00 
c01034e2:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01034e9:	e8 e4 d7 ff ff       	call   c0100cd2 <__panic>
        count ++, total += p->property;
c01034ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01034f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034f5:	8b 50 08             	mov    0x8(%eax),%edx
c01034f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034fb:	01 d0                	add    %edx,%eax
c01034fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103500:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103503:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103506:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103509:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010350c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010350f:	81 7d ec 70 af 11 c0 	cmpl   $0xc011af70,-0x14(%ebp)
c0103516:	0f 85 79 ff ff ff    	jne    c0103495 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c010351c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c010351f:	e8 40 09 00 00       	call   c0103e64 <nr_free_pages>
c0103524:	39 c3                	cmp    %eax,%ebx
c0103526:	74 24                	je     c010354c <default_check+0xd8>
c0103528:	c7 44 24 0c 46 69 10 	movl   $0xc0106946,0xc(%esp)
c010352f:	c0 
c0103530:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103537:	c0 
c0103538:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c010353f:	00 
c0103540:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103547:	e8 86 d7 ff ff       	call   c0100cd2 <__panic>

    basic_check();
c010354c:	e8 e7 f9 ff ff       	call   c0102f38 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103551:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103558:	e8 9d 08 00 00       	call   c0103dfa <alloc_pages>
c010355d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0103560:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103564:	75 24                	jne    c010358a <default_check+0x116>
c0103566:	c7 44 24 0c 5f 69 10 	movl   $0xc010695f,0xc(%esp)
c010356d:	c0 
c010356e:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103575:	c0 
c0103576:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c010357d:	00 
c010357e:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103585:	e8 48 d7 ff ff       	call   c0100cd2 <__panic>
    assert(!PageProperty(p0));
c010358a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010358d:	83 c0 04             	add    $0x4,%eax
c0103590:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103597:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010359a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010359d:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01035a0:	0f a3 10             	bt     %edx,(%eax)
c01035a3:	19 c0                	sbb    %eax,%eax
c01035a5:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01035a8:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01035ac:	0f 95 c0             	setne  %al
c01035af:	0f b6 c0             	movzbl %al,%eax
c01035b2:	85 c0                	test   %eax,%eax
c01035b4:	74 24                	je     c01035da <default_check+0x166>
c01035b6:	c7 44 24 0c 6a 69 10 	movl   $0xc010696a,0xc(%esp)
c01035bd:	c0 
c01035be:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01035c5:	c0 
c01035c6:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c01035cd:	00 
c01035ce:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01035d5:	e8 f8 d6 ff ff       	call   c0100cd2 <__panic>

    list_entry_t free_list_store = free_list;
c01035da:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c01035df:	8b 15 74 af 11 c0    	mov    0xc011af74,%edx
c01035e5:	89 45 80             	mov    %eax,-0x80(%ebp)
c01035e8:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01035eb:	c7 45 b4 70 af 11 c0 	movl   $0xc011af70,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01035f2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01035f5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01035f8:	89 50 04             	mov    %edx,0x4(%eax)
c01035fb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01035fe:	8b 50 04             	mov    0x4(%eax),%edx
c0103601:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103604:	89 10                	mov    %edx,(%eax)
c0103606:	c7 45 b0 70 af 11 c0 	movl   $0xc011af70,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010360d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103610:	8b 40 04             	mov    0x4(%eax),%eax
c0103613:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0103616:	0f 94 c0             	sete   %al
c0103619:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010361c:	85 c0                	test   %eax,%eax
c010361e:	75 24                	jne    c0103644 <default_check+0x1d0>
c0103620:	c7 44 24 0c bf 68 10 	movl   $0xc01068bf,0xc(%esp)
c0103627:	c0 
c0103628:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010362f:	c0 
c0103630:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0103637:	00 
c0103638:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010363f:	e8 8e d6 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c0103644:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010364b:	e8 aa 07 00 00       	call   c0103dfa <alloc_pages>
c0103650:	85 c0                	test   %eax,%eax
c0103652:	74 24                	je     c0103678 <default_check+0x204>
c0103654:	c7 44 24 0c d6 68 10 	movl   $0xc01068d6,0xc(%esp)
c010365b:	c0 
c010365c:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103663:	c0 
c0103664:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c010366b:	00 
c010366c:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103673:	e8 5a d6 ff ff       	call   c0100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
c0103678:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c010367d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0103680:	c7 05 78 af 11 c0 00 	movl   $0x0,0xc011af78
c0103687:	00 00 00 

    free_pages(p0 + 2, 3);
c010368a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010368d:	83 c0 28             	add    $0x28,%eax
c0103690:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103697:	00 
c0103698:	89 04 24             	mov    %eax,(%esp)
c010369b:	e8 92 07 00 00       	call   c0103e32 <free_pages>
    assert(alloc_pages(4) == NULL);
c01036a0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01036a7:	e8 4e 07 00 00       	call   c0103dfa <alloc_pages>
c01036ac:	85 c0                	test   %eax,%eax
c01036ae:	74 24                	je     c01036d4 <default_check+0x260>
c01036b0:	c7 44 24 0c 7c 69 10 	movl   $0xc010697c,0xc(%esp)
c01036b7:	c0 
c01036b8:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01036bf:	c0 
c01036c0:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01036c7:	00 
c01036c8:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01036cf:	e8 fe d5 ff ff       	call   c0100cd2 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01036d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036d7:	83 c0 28             	add    $0x28,%eax
c01036da:	83 c0 04             	add    $0x4,%eax
c01036dd:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01036e4:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036e7:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01036ea:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01036ed:	0f a3 10             	bt     %edx,(%eax)
c01036f0:	19 c0                	sbb    %eax,%eax
c01036f2:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01036f5:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01036f9:	0f 95 c0             	setne  %al
c01036fc:	0f b6 c0             	movzbl %al,%eax
c01036ff:	85 c0                	test   %eax,%eax
c0103701:	74 0e                	je     c0103711 <default_check+0x29d>
c0103703:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103706:	83 c0 28             	add    $0x28,%eax
c0103709:	8b 40 08             	mov    0x8(%eax),%eax
c010370c:	83 f8 03             	cmp    $0x3,%eax
c010370f:	74 24                	je     c0103735 <default_check+0x2c1>
c0103711:	c7 44 24 0c 94 69 10 	movl   $0xc0106994,0xc(%esp)
c0103718:	c0 
c0103719:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103720:	c0 
c0103721:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0103728:	00 
c0103729:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103730:	e8 9d d5 ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0103735:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010373c:	e8 b9 06 00 00       	call   c0103dfa <alloc_pages>
c0103741:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103744:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103748:	75 24                	jne    c010376e <default_check+0x2fa>
c010374a:	c7 44 24 0c c0 69 10 	movl   $0xc01069c0,0xc(%esp)
c0103751:	c0 
c0103752:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103759:	c0 
c010375a:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0103761:	00 
c0103762:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103769:	e8 64 d5 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c010376e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103775:	e8 80 06 00 00       	call   c0103dfa <alloc_pages>
c010377a:	85 c0                	test   %eax,%eax
c010377c:	74 24                	je     c01037a2 <default_check+0x32e>
c010377e:	c7 44 24 0c d6 68 10 	movl   $0xc01068d6,0xc(%esp)
c0103785:	c0 
c0103786:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010378d:	c0 
c010378e:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0103795:	00 
c0103796:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010379d:	e8 30 d5 ff ff       	call   c0100cd2 <__panic>
    assert(p0 + 2 == p1);
c01037a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037a5:	83 c0 28             	add    $0x28,%eax
c01037a8:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01037ab:	74 24                	je     c01037d1 <default_check+0x35d>
c01037ad:	c7 44 24 0c de 69 10 	movl   $0xc01069de,0xc(%esp)
c01037b4:	c0 
c01037b5:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01037bc:	c0 
c01037bd:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c01037c4:	00 
c01037c5:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01037cc:	e8 01 d5 ff ff       	call   c0100cd2 <__panic>

    p2 = p0 + 1;
c01037d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037d4:	83 c0 14             	add    $0x14,%eax
c01037d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c01037da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01037e1:	00 
c01037e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037e5:	89 04 24             	mov    %eax,(%esp)
c01037e8:	e8 45 06 00 00       	call   c0103e32 <free_pages>
    free_pages(p1, 3);
c01037ed:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01037f4:	00 
c01037f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037f8:	89 04 24             	mov    %eax,(%esp)
c01037fb:	e8 32 06 00 00       	call   c0103e32 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0103800:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103803:	83 c0 04             	add    $0x4,%eax
c0103806:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010380d:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103810:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103813:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103816:	0f a3 10             	bt     %edx,(%eax)
c0103819:	19 c0                	sbb    %eax,%eax
c010381b:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010381e:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0103822:	0f 95 c0             	setne  %al
c0103825:	0f b6 c0             	movzbl %al,%eax
c0103828:	85 c0                	test   %eax,%eax
c010382a:	74 0b                	je     c0103837 <default_check+0x3c3>
c010382c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010382f:	8b 40 08             	mov    0x8(%eax),%eax
c0103832:	83 f8 01             	cmp    $0x1,%eax
c0103835:	74 24                	je     c010385b <default_check+0x3e7>
c0103837:	c7 44 24 0c ec 69 10 	movl   $0xc01069ec,0xc(%esp)
c010383e:	c0 
c010383f:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103846:	c0 
c0103847:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c010384e:	00 
c010384f:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103856:	e8 77 d4 ff ff       	call   c0100cd2 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010385b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010385e:	83 c0 04             	add    $0x4,%eax
c0103861:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0103868:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010386b:	8b 45 90             	mov    -0x70(%ebp),%eax
c010386e:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103871:	0f a3 10             	bt     %edx,(%eax)
c0103874:	19 c0                	sbb    %eax,%eax
c0103876:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0103879:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010387d:	0f 95 c0             	setne  %al
c0103880:	0f b6 c0             	movzbl %al,%eax
c0103883:	85 c0                	test   %eax,%eax
c0103885:	74 0b                	je     c0103892 <default_check+0x41e>
c0103887:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010388a:	8b 40 08             	mov    0x8(%eax),%eax
c010388d:	83 f8 03             	cmp    $0x3,%eax
c0103890:	74 24                	je     c01038b6 <default_check+0x442>
c0103892:	c7 44 24 0c 14 6a 10 	movl   $0xc0106a14,0xc(%esp)
c0103899:	c0 
c010389a:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01038a1:	c0 
c01038a2:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01038a9:	00 
c01038aa:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01038b1:	e8 1c d4 ff ff       	call   c0100cd2 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01038b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01038bd:	e8 38 05 00 00       	call   c0103dfa <alloc_pages>
c01038c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01038c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038c8:	83 e8 14             	sub    $0x14,%eax
c01038cb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01038ce:	74 24                	je     c01038f4 <default_check+0x480>
c01038d0:	c7 44 24 0c 3a 6a 10 	movl   $0xc0106a3a,0xc(%esp)
c01038d7:	c0 
c01038d8:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01038df:	c0 
c01038e0:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c01038e7:	00 
c01038e8:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01038ef:	e8 de d3 ff ff       	call   c0100cd2 <__panic>
    free_page(p0);
c01038f4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01038fb:	00 
c01038fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038ff:	89 04 24             	mov    %eax,(%esp)
c0103902:	e8 2b 05 00 00       	call   c0103e32 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0103907:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010390e:	e8 e7 04 00 00       	call   c0103dfa <alloc_pages>
c0103913:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103916:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103919:	83 c0 14             	add    $0x14,%eax
c010391c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010391f:	74 24                	je     c0103945 <default_check+0x4d1>
c0103921:	c7 44 24 0c 58 6a 10 	movl   $0xc0106a58,0xc(%esp)
c0103928:	c0 
c0103929:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103930:	c0 
c0103931:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0103938:	00 
c0103939:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103940:	e8 8d d3 ff ff       	call   c0100cd2 <__panic>

    free_pages(p0, 2);
c0103945:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010394c:	00 
c010394d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103950:	89 04 24             	mov    %eax,(%esp)
c0103953:	e8 da 04 00 00       	call   c0103e32 <free_pages>
    free_page(p2);
c0103958:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010395f:	00 
c0103960:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103963:	89 04 24             	mov    %eax,(%esp)
c0103966:	e8 c7 04 00 00       	call   c0103e32 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010396b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103972:	e8 83 04 00 00       	call   c0103dfa <alloc_pages>
c0103977:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010397a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010397e:	75 24                	jne    c01039a4 <default_check+0x530>
c0103980:	c7 44 24 0c 78 6a 10 	movl   $0xc0106a78,0xc(%esp)
c0103987:	c0 
c0103988:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010398f:	c0 
c0103990:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0103997:	00 
c0103998:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010399f:	e8 2e d3 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c01039a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039ab:	e8 4a 04 00 00       	call   c0103dfa <alloc_pages>
c01039b0:	85 c0                	test   %eax,%eax
c01039b2:	74 24                	je     c01039d8 <default_check+0x564>
c01039b4:	c7 44 24 0c d6 68 10 	movl   $0xc01068d6,0xc(%esp)
c01039bb:	c0 
c01039bc:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01039c3:	c0 
c01039c4:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c01039cb:	00 
c01039cc:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01039d3:	e8 fa d2 ff ff       	call   c0100cd2 <__panic>

    assert(nr_free == 0);
c01039d8:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c01039dd:	85 c0                	test   %eax,%eax
c01039df:	74 24                	je     c0103a05 <default_check+0x591>
c01039e1:	c7 44 24 0c 29 69 10 	movl   $0xc0106929,0xc(%esp)
c01039e8:	c0 
c01039e9:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01039f0:	c0 
c01039f1:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c01039f8:	00 
c01039f9:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103a00:	e8 cd d2 ff ff       	call   c0100cd2 <__panic>
    nr_free = nr_free_store;
c0103a05:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a08:	a3 78 af 11 c0       	mov    %eax,0xc011af78

    free_list = free_list_store;
c0103a0d:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103a10:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103a13:	a3 70 af 11 c0       	mov    %eax,0xc011af70
c0103a18:	89 15 74 af 11 c0    	mov    %edx,0xc011af74
    free_pages(p0, 5);
c0103a1e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0103a25:	00 
c0103a26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a29:	89 04 24             	mov    %eax,(%esp)
c0103a2c:	e8 01 04 00 00       	call   c0103e32 <free_pages>

    le = &free_list;
c0103a31:	c7 45 ec 70 af 11 c0 	movl   $0xc011af70,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103a38:	eb 1d                	jmp    c0103a57 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0103a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a3d:	83 e8 0c             	sub    $0xc,%eax
c0103a40:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0103a43:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0103a47:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103a4a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103a4d:	8b 40 08             	mov    0x8(%eax),%eax
c0103a50:	29 c2                	sub    %eax,%edx
c0103a52:	89 d0                	mov    %edx,%eax
c0103a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a57:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a5a:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103a5d:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103a60:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103a63:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a66:	81 7d ec 70 af 11 c0 	cmpl   $0xc011af70,-0x14(%ebp)
c0103a6d:	75 cb                	jne    c0103a3a <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0103a6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a73:	74 24                	je     c0103a99 <default_check+0x625>
c0103a75:	c7 44 24 0c 96 6a 10 	movl   $0xc0106a96,0xc(%esp)
c0103a7c:	c0 
c0103a7d:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103a84:	c0 
c0103a85:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0103a8c:	00 
c0103a8d:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103a94:	e8 39 d2 ff ff       	call   c0100cd2 <__panic>
    assert(total == 0);
c0103a99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a9d:	74 24                	je     c0103ac3 <default_check+0x64f>
c0103a9f:	c7 44 24 0c a1 6a 10 	movl   $0xc0106aa1,0xc(%esp)
c0103aa6:	c0 
c0103aa7:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103aae:	c0 
c0103aaf:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c0103ab6:	00 
c0103ab7:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103abe:	e8 0f d2 ff ff       	call   c0100cd2 <__panic>
}
c0103ac3:	81 c4 94 00 00 00    	add    $0x94,%esp
c0103ac9:	5b                   	pop    %ebx
c0103aca:	5d                   	pop    %ebp
c0103acb:	c3                   	ret    

c0103acc <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103acc:	55                   	push   %ebp
c0103acd:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103acf:	8b 55 08             	mov    0x8(%ebp),%edx
c0103ad2:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c0103ad7:	29 c2                	sub    %eax,%edx
c0103ad9:	89 d0                	mov    %edx,%eax
c0103adb:	c1 f8 02             	sar    $0x2,%eax
c0103ade:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103ae4:	5d                   	pop    %ebp
c0103ae5:	c3                   	ret    

c0103ae6 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103ae6:	55                   	push   %ebp
c0103ae7:	89 e5                	mov    %esp,%ebp
c0103ae9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103aec:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aef:	89 04 24             	mov    %eax,(%esp)
c0103af2:	e8 d5 ff ff ff       	call   c0103acc <page2ppn>
c0103af7:	c1 e0 0c             	shl    $0xc,%eax
}
c0103afa:	c9                   	leave  
c0103afb:	c3                   	ret    

c0103afc <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0103afc:	55                   	push   %ebp
c0103afd:	89 e5                	mov    %esp,%ebp
c0103aff:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103b02:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b05:	c1 e8 0c             	shr    $0xc,%eax
c0103b08:	89 c2                	mov    %eax,%edx
c0103b0a:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103b0f:	39 c2                	cmp    %eax,%edx
c0103b11:	72 1c                	jb     c0103b2f <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103b13:	c7 44 24 08 dc 6a 10 	movl   $0xc0106adc,0x8(%esp)
c0103b1a:	c0 
c0103b1b:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103b22:	00 
c0103b23:	c7 04 24 fb 6a 10 c0 	movl   $0xc0106afb,(%esp)
c0103b2a:	e8 a3 d1 ff ff       	call   c0100cd2 <__panic>
    }
    return &pages[PPN(pa)];
c0103b2f:	8b 0d 84 af 11 c0    	mov    0xc011af84,%ecx
c0103b35:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b38:	c1 e8 0c             	shr    $0xc,%eax
c0103b3b:	89 c2                	mov    %eax,%edx
c0103b3d:	89 d0                	mov    %edx,%eax
c0103b3f:	c1 e0 02             	shl    $0x2,%eax
c0103b42:	01 d0                	add    %edx,%eax
c0103b44:	c1 e0 02             	shl    $0x2,%eax
c0103b47:	01 c8                	add    %ecx,%eax
}
c0103b49:	c9                   	leave  
c0103b4a:	c3                   	ret    

c0103b4b <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0103b4b:	55                   	push   %ebp
c0103b4c:	89 e5                	mov    %esp,%ebp
c0103b4e:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b54:	89 04 24             	mov    %eax,(%esp)
c0103b57:	e8 8a ff ff ff       	call   c0103ae6 <page2pa>
c0103b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b62:	c1 e8 0c             	shr    $0xc,%eax
c0103b65:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b68:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103b6d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103b70:	72 23                	jb     c0103b95 <page2kva+0x4a>
c0103b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b75:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b79:	c7 44 24 08 0c 6b 10 	movl   $0xc0106b0c,0x8(%esp)
c0103b80:	c0 
c0103b81:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103b88:	00 
c0103b89:	c7 04 24 fb 6a 10 c0 	movl   $0xc0106afb,(%esp)
c0103b90:	e8 3d d1 ff ff       	call   c0100cd2 <__panic>
c0103b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b98:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103b9d:	c9                   	leave  
c0103b9e:	c3                   	ret    

c0103b9f <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103b9f:	55                   	push   %ebp
c0103ba0:	89 e5                	mov    %esp,%ebp
c0103ba2:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103ba5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ba8:	83 e0 01             	and    $0x1,%eax
c0103bab:	85 c0                	test   %eax,%eax
c0103bad:	75 1c                	jne    c0103bcb <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103baf:	c7 44 24 08 30 6b 10 	movl   $0xc0106b30,0x8(%esp)
c0103bb6:	c0 
c0103bb7:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103bbe:	00 
c0103bbf:	c7 04 24 fb 6a 10 c0 	movl   $0xc0106afb,(%esp)
c0103bc6:	e8 07 d1 ff ff       	call   c0100cd2 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103bcb:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103bd3:	89 04 24             	mov    %eax,(%esp)
c0103bd6:	e8 21 ff ff ff       	call   c0103afc <pa2page>
}
c0103bdb:	c9                   	leave  
c0103bdc:	c3                   	ret    

c0103bdd <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103bdd:	55                   	push   %ebp
c0103bde:	89 e5                	mov    %esp,%ebp
c0103be0:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103be3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103be6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103beb:	89 04 24             	mov    %eax,(%esp)
c0103bee:	e8 09 ff ff ff       	call   c0103afc <pa2page>
}
c0103bf3:	c9                   	leave  
c0103bf4:	c3                   	ret    

c0103bf5 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0103bf5:	55                   	push   %ebp
c0103bf6:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103bf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bfb:	8b 00                	mov    (%eax),%eax
}
c0103bfd:	5d                   	pop    %ebp
c0103bfe:	c3                   	ret    

c0103bff <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103bff:	55                   	push   %ebp
c0103c00:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103c02:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c05:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103c08:	89 10                	mov    %edx,(%eax)
}
c0103c0a:	5d                   	pop    %ebp
c0103c0b:	c3                   	ret    

c0103c0c <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103c0c:	55                   	push   %ebp
c0103c0d:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103c0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c12:	8b 00                	mov    (%eax),%eax
c0103c14:	8d 50 01             	lea    0x1(%eax),%edx
c0103c17:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c1a:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103c1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c1f:	8b 00                	mov    (%eax),%eax
}
c0103c21:	5d                   	pop    %ebp
c0103c22:	c3                   	ret    

c0103c23 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103c23:	55                   	push   %ebp
c0103c24:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103c26:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c29:	8b 00                	mov    (%eax),%eax
c0103c2b:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103c2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c31:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103c33:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c36:	8b 00                	mov    (%eax),%eax
}
c0103c38:	5d                   	pop    %ebp
c0103c39:	c3                   	ret    

c0103c3a <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103c3a:	55                   	push   %ebp
c0103c3b:	89 e5                	mov    %esp,%ebp
c0103c3d:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103c40:	9c                   	pushf  
c0103c41:	58                   	pop    %eax
c0103c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103c48:	25 00 02 00 00       	and    $0x200,%eax
c0103c4d:	85 c0                	test   %eax,%eax
c0103c4f:	74 0c                	je     c0103c5d <__intr_save+0x23>
        intr_disable();
c0103c51:	e8 70 da ff ff       	call   c01016c6 <intr_disable>
        return 1;
c0103c56:	b8 01 00 00 00       	mov    $0x1,%eax
c0103c5b:	eb 05                	jmp    c0103c62 <__intr_save+0x28>
    }
    return 0;
c0103c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103c62:	c9                   	leave  
c0103c63:	c3                   	ret    

c0103c64 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103c64:	55                   	push   %ebp
c0103c65:	89 e5                	mov    %esp,%ebp
c0103c67:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103c6a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103c6e:	74 05                	je     c0103c75 <__intr_restore+0x11>
        intr_enable();
c0103c70:	e8 4b da ff ff       	call   c01016c0 <intr_enable>
    }
}
c0103c75:	c9                   	leave  
c0103c76:	c3                   	ret    

c0103c77 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103c77:	55                   	push   %ebp
c0103c78:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103c7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c7d:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103c80:	b8 23 00 00 00       	mov    $0x23,%eax
c0103c85:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103c87:	b8 23 00 00 00       	mov    $0x23,%eax
c0103c8c:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103c8e:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c93:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103c95:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c9a:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103c9c:	b8 10 00 00 00       	mov    $0x10,%eax
c0103ca1:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103ca3:	ea aa 3c 10 c0 08 00 	ljmp   $0x8,$0xc0103caa
}
c0103caa:	5d                   	pop    %ebp
c0103cab:	c3                   	ret    

c0103cac <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103cac:	55                   	push   %ebp
c0103cad:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103caf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cb2:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0103cb7:	5d                   	pop    %ebp
c0103cb8:	c3                   	ret    

c0103cb9 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103cb9:	55                   	push   %ebp
c0103cba:	89 e5                	mov    %esp,%ebp
c0103cbc:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103cbf:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0103cc4:	89 04 24             	mov    %eax,(%esp)
c0103cc7:	e8 e0 ff ff ff       	call   c0103cac <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103ccc:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0103cd3:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103cd5:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0103cdc:	68 00 
c0103cde:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103ce3:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0103ce9:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103cee:	c1 e8 10             	shr    $0x10,%eax
c0103cf1:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0103cf6:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103cfd:	83 e0 f0             	and    $0xfffffff0,%eax
c0103d00:	83 c8 09             	or     $0x9,%eax
c0103d03:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103d08:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103d0f:	83 e0 ef             	and    $0xffffffef,%eax
c0103d12:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103d17:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103d1e:	83 e0 9f             	and    $0xffffff9f,%eax
c0103d21:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103d26:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103d2d:	83 c8 80             	or     $0xffffff80,%eax
c0103d30:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103d35:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d3c:	83 e0 f0             	and    $0xfffffff0,%eax
c0103d3f:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d44:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d4b:	83 e0 ef             	and    $0xffffffef,%eax
c0103d4e:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d53:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d5a:	83 e0 df             	and    $0xffffffdf,%eax
c0103d5d:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d62:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d69:	83 c8 40             	or     $0x40,%eax
c0103d6c:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d71:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d78:	83 e0 7f             	and    $0x7f,%eax
c0103d7b:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d80:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103d85:	c1 e8 18             	shr    $0x18,%eax
c0103d88:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103d8d:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0103d94:	e8 de fe ff ff       	call   c0103c77 <lgdt>
c0103d99:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103d9f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103da3:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103da6:	c9                   	leave  
c0103da7:	c3                   	ret    

c0103da8 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103da8:	55                   	push   %ebp
c0103da9:	89 e5                	mov    %esp,%ebp
c0103dab:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103dae:	c7 05 7c af 11 c0 c0 	movl   $0xc0106ac0,0xc011af7c
c0103db5:	6a 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103db8:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103dbd:	8b 00                	mov    (%eax),%eax
c0103dbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103dc3:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0103dca:	e8 79 c5 ff ff       	call   c0100348 <cprintf>
    pmm_manager->init();
c0103dcf:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103dd4:	8b 40 04             	mov    0x4(%eax),%eax
c0103dd7:	ff d0                	call   *%eax
}
c0103dd9:	c9                   	leave  
c0103dda:	c3                   	ret    

c0103ddb <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103ddb:	55                   	push   %ebp
c0103ddc:	89 e5                	mov    %esp,%ebp
c0103dde:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103de1:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103de6:	8b 40 08             	mov    0x8(%eax),%eax
c0103de9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103dec:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103df0:	8b 55 08             	mov    0x8(%ebp),%edx
c0103df3:	89 14 24             	mov    %edx,(%esp)
c0103df6:	ff d0                	call   *%eax
}
c0103df8:	c9                   	leave  
c0103df9:	c3                   	ret    

c0103dfa <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103dfa:	55                   	push   %ebp
c0103dfb:	89 e5                	mov    %esp,%ebp
c0103dfd:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103e00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e07:	e8 2e fe ff ff       	call   c0103c3a <__intr_save>
c0103e0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103e0f:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103e14:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e17:	8b 55 08             	mov    0x8(%ebp),%edx
c0103e1a:	89 14 24             	mov    %edx,(%esp)
c0103e1d:	ff d0                	call   *%eax
c0103e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e25:	89 04 24             	mov    %eax,(%esp)
c0103e28:	e8 37 fe ff ff       	call   c0103c64 <__intr_restore>
    return page;
c0103e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103e30:	c9                   	leave  
c0103e31:	c3                   	ret    

c0103e32 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103e32:	55                   	push   %ebp
c0103e33:	89 e5                	mov    %esp,%ebp
c0103e35:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e38:	e8 fd fd ff ff       	call   c0103c3a <__intr_save>
c0103e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103e40:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103e45:	8b 40 10             	mov    0x10(%eax),%eax
c0103e48:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103e4b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e4f:	8b 55 08             	mov    0x8(%ebp),%edx
c0103e52:	89 14 24             	mov    %edx,(%esp)
c0103e55:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e5a:	89 04 24             	mov    %eax,(%esp)
c0103e5d:	e8 02 fe ff ff       	call   c0103c64 <__intr_restore>
}
c0103e62:	c9                   	leave  
c0103e63:	c3                   	ret    

c0103e64 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103e64:	55                   	push   %ebp
c0103e65:	89 e5                	mov    %esp,%ebp
c0103e67:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e6a:	e8 cb fd ff ff       	call   c0103c3a <__intr_save>
c0103e6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103e72:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103e77:	8b 40 14             	mov    0x14(%eax),%eax
c0103e7a:	ff d0                	call   *%eax
c0103e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e82:	89 04 24             	mov    %eax,(%esp)
c0103e85:	e8 da fd ff ff       	call   c0103c64 <__intr_restore>
    return ret;
c0103e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103e8d:	c9                   	leave  
c0103e8e:	c3                   	ret    

c0103e8f <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103e8f:	55                   	push   %ebp
c0103e90:	89 e5                	mov    %esp,%ebp
c0103e92:	57                   	push   %edi
c0103e93:	56                   	push   %esi
c0103e94:	53                   	push   %ebx
c0103e95:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103e9b:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103ea2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103ea9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103eb0:	c7 04 24 73 6b 10 c0 	movl   $0xc0106b73,(%esp)
c0103eb7:	e8 8c c4 ff ff       	call   c0100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103ebc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103ec3:	e9 15 01 00 00       	jmp    c0103fdd <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103ec8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ecb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ece:	89 d0                	mov    %edx,%eax
c0103ed0:	c1 e0 02             	shl    $0x2,%eax
c0103ed3:	01 d0                	add    %edx,%eax
c0103ed5:	c1 e0 02             	shl    $0x2,%eax
c0103ed8:	01 c8                	add    %ecx,%eax
c0103eda:	8b 50 08             	mov    0x8(%eax),%edx
c0103edd:	8b 40 04             	mov    0x4(%eax),%eax
c0103ee0:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103ee3:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103ee6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ee9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103eec:	89 d0                	mov    %edx,%eax
c0103eee:	c1 e0 02             	shl    $0x2,%eax
c0103ef1:	01 d0                	add    %edx,%eax
c0103ef3:	c1 e0 02             	shl    $0x2,%eax
c0103ef6:	01 c8                	add    %ecx,%eax
c0103ef8:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103efb:	8b 58 10             	mov    0x10(%eax),%ebx
c0103efe:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103f01:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103f04:	01 c8                	add    %ecx,%eax
c0103f06:	11 da                	adc    %ebx,%edx
c0103f08:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0103f0b:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103f0e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f11:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f14:	89 d0                	mov    %edx,%eax
c0103f16:	c1 e0 02             	shl    $0x2,%eax
c0103f19:	01 d0                	add    %edx,%eax
c0103f1b:	c1 e0 02             	shl    $0x2,%eax
c0103f1e:	01 c8                	add    %ecx,%eax
c0103f20:	83 c0 14             	add    $0x14,%eax
c0103f23:	8b 00                	mov    (%eax),%eax
c0103f25:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103f2b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103f2e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103f31:	83 c0 ff             	add    $0xffffffff,%eax
c0103f34:	83 d2 ff             	adc    $0xffffffff,%edx
c0103f37:	89 c6                	mov    %eax,%esi
c0103f39:	89 d7                	mov    %edx,%edi
c0103f3b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f3e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f41:	89 d0                	mov    %edx,%eax
c0103f43:	c1 e0 02             	shl    $0x2,%eax
c0103f46:	01 d0                	add    %edx,%eax
c0103f48:	c1 e0 02             	shl    $0x2,%eax
c0103f4b:	01 c8                	add    %ecx,%eax
c0103f4d:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103f50:	8b 58 10             	mov    0x10(%eax),%ebx
c0103f53:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103f59:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103f5d:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103f61:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103f65:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103f68:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103f6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f6f:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103f73:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103f77:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103f7b:	c7 04 24 80 6b 10 c0 	movl   $0xc0106b80,(%esp)
c0103f82:	e8 c1 c3 ff ff       	call   c0100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103f87:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f8a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f8d:	89 d0                	mov    %edx,%eax
c0103f8f:	c1 e0 02             	shl    $0x2,%eax
c0103f92:	01 d0                	add    %edx,%eax
c0103f94:	c1 e0 02             	shl    $0x2,%eax
c0103f97:	01 c8                	add    %ecx,%eax
c0103f99:	83 c0 14             	add    $0x14,%eax
c0103f9c:	8b 00                	mov    (%eax),%eax
c0103f9e:	83 f8 01             	cmp    $0x1,%eax
c0103fa1:	75 36                	jne    c0103fd9 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0103fa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fa6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103fa9:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103fac:	77 2b                	ja     c0103fd9 <page_init+0x14a>
c0103fae:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103fb1:	72 05                	jb     c0103fb8 <page_init+0x129>
c0103fb3:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0103fb6:	73 21                	jae    c0103fd9 <page_init+0x14a>
c0103fb8:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103fbc:	77 1b                	ja     c0103fd9 <page_init+0x14a>
c0103fbe:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103fc2:	72 09                	jb     c0103fcd <page_init+0x13e>
c0103fc4:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0103fcb:	77 0c                	ja     c0103fd9 <page_init+0x14a>
                maxpa = end;
c0103fcd:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103fd0:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103fd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103fd6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103fd9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103fdd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103fe0:	8b 00                	mov    (%eax),%eax
c0103fe2:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103fe5:	0f 8f dd fe ff ff    	jg     c0103ec8 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103feb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103fef:	72 1d                	jb     c010400e <page_init+0x17f>
c0103ff1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103ff5:	77 09                	ja     c0104000 <page_init+0x171>
c0103ff7:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0103ffe:	76 0e                	jbe    c010400e <page_init+0x17f>
        maxpa = KMEMSIZE;
c0104000:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104007:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c010400e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104011:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104014:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104018:	c1 ea 0c             	shr    $0xc,%edx
c010401b:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0104020:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0104027:	b8 88 af 11 c0       	mov    $0xc011af88,%eax
c010402c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010402f:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104032:	01 d0                	add    %edx,%eax
c0104034:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104037:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010403a:	ba 00 00 00 00       	mov    $0x0,%edx
c010403f:	f7 75 ac             	divl   -0x54(%ebp)
c0104042:	89 d0                	mov    %edx,%eax
c0104044:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104047:	29 c2                	sub    %eax,%edx
c0104049:	89 d0                	mov    %edx,%eax
c010404b:	a3 84 af 11 c0       	mov    %eax,0xc011af84

    for (i = 0; i < npage; i ++) {
c0104050:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104057:	eb 2f                	jmp    c0104088 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0104059:	8b 0d 84 af 11 c0    	mov    0xc011af84,%ecx
c010405f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104062:	89 d0                	mov    %edx,%eax
c0104064:	c1 e0 02             	shl    $0x2,%eax
c0104067:	01 d0                	add    %edx,%eax
c0104069:	c1 e0 02             	shl    $0x2,%eax
c010406c:	01 c8                	add    %ecx,%eax
c010406e:	83 c0 04             	add    $0x4,%eax
c0104071:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0104078:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010407b:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010407e:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104081:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0104084:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104088:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010408b:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104090:	39 c2                	cmp    %eax,%edx
c0104092:	72 c5                	jb     c0104059 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104094:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c010409a:	89 d0                	mov    %edx,%eax
c010409c:	c1 e0 02             	shl    $0x2,%eax
c010409f:	01 d0                	add    %edx,%eax
c01040a1:	c1 e0 02             	shl    $0x2,%eax
c01040a4:	89 c2                	mov    %eax,%edx
c01040a6:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c01040ab:	01 d0                	add    %edx,%eax
c01040ad:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01040b0:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c01040b7:	77 23                	ja     c01040dc <page_init+0x24d>
c01040b9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01040bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01040c0:	c7 44 24 08 b0 6b 10 	movl   $0xc0106bb0,0x8(%esp)
c01040c7:	c0 
c01040c8:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01040cf:	00 
c01040d0:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01040d7:	e8 f6 cb ff ff       	call   c0100cd2 <__panic>
c01040dc:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01040df:	05 00 00 00 40       	add    $0x40000000,%eax
c01040e4:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01040e7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01040ee:	e9 74 01 00 00       	jmp    c0104267 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01040f3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040f9:	89 d0                	mov    %edx,%eax
c01040fb:	c1 e0 02             	shl    $0x2,%eax
c01040fe:	01 d0                	add    %edx,%eax
c0104100:	c1 e0 02             	shl    $0x2,%eax
c0104103:	01 c8                	add    %ecx,%eax
c0104105:	8b 50 08             	mov    0x8(%eax),%edx
c0104108:	8b 40 04             	mov    0x4(%eax),%eax
c010410b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010410e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104111:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104114:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104117:	89 d0                	mov    %edx,%eax
c0104119:	c1 e0 02             	shl    $0x2,%eax
c010411c:	01 d0                	add    %edx,%eax
c010411e:	c1 e0 02             	shl    $0x2,%eax
c0104121:	01 c8                	add    %ecx,%eax
c0104123:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104126:	8b 58 10             	mov    0x10(%eax),%ebx
c0104129:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010412c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010412f:	01 c8                	add    %ecx,%eax
c0104131:	11 da                	adc    %ebx,%edx
c0104133:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104136:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104139:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010413c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010413f:	89 d0                	mov    %edx,%eax
c0104141:	c1 e0 02             	shl    $0x2,%eax
c0104144:	01 d0                	add    %edx,%eax
c0104146:	c1 e0 02             	shl    $0x2,%eax
c0104149:	01 c8                	add    %ecx,%eax
c010414b:	83 c0 14             	add    $0x14,%eax
c010414e:	8b 00                	mov    (%eax),%eax
c0104150:	83 f8 01             	cmp    $0x1,%eax
c0104153:	0f 85 0a 01 00 00    	jne    c0104263 <page_init+0x3d4>
            if (begin < freemem) {
c0104159:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010415c:	ba 00 00 00 00       	mov    $0x0,%edx
c0104161:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104164:	72 17                	jb     c010417d <page_init+0x2ee>
c0104166:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104169:	77 05                	ja     c0104170 <page_init+0x2e1>
c010416b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010416e:	76 0d                	jbe    c010417d <page_init+0x2ee>
                begin = freemem;
c0104170:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104173:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104176:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010417d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104181:	72 1d                	jb     c01041a0 <page_init+0x311>
c0104183:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104187:	77 09                	ja     c0104192 <page_init+0x303>
c0104189:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0104190:	76 0e                	jbe    c01041a0 <page_init+0x311>
                end = KMEMSIZE;
c0104192:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104199:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01041a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01041a6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01041a9:	0f 87 b4 00 00 00    	ja     c0104263 <page_init+0x3d4>
c01041af:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01041b2:	72 09                	jb     c01041bd <page_init+0x32e>
c01041b4:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01041b7:	0f 83 a6 00 00 00    	jae    c0104263 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c01041bd:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c01041c4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01041c7:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01041ca:	01 d0                	add    %edx,%eax
c01041cc:	83 e8 01             	sub    $0x1,%eax
c01041cf:	89 45 98             	mov    %eax,-0x68(%ebp)
c01041d2:	8b 45 98             	mov    -0x68(%ebp),%eax
c01041d5:	ba 00 00 00 00       	mov    $0x0,%edx
c01041da:	f7 75 9c             	divl   -0x64(%ebp)
c01041dd:	89 d0                	mov    %edx,%eax
c01041df:	8b 55 98             	mov    -0x68(%ebp),%edx
c01041e2:	29 c2                	sub    %eax,%edx
c01041e4:	89 d0                	mov    %edx,%eax
c01041e6:	ba 00 00 00 00       	mov    $0x0,%edx
c01041eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01041ee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01041f1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01041f4:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01041f7:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01041fa:	ba 00 00 00 00       	mov    $0x0,%edx
c01041ff:	89 c7                	mov    %eax,%edi
c0104201:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104207:	89 7d 80             	mov    %edi,-0x80(%ebp)
c010420a:	89 d0                	mov    %edx,%eax
c010420c:	83 e0 00             	and    $0x0,%eax
c010420f:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104212:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104215:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104218:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010421b:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c010421e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104221:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104224:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104227:	77 3a                	ja     c0104263 <page_init+0x3d4>
c0104229:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010422c:	72 05                	jb     c0104233 <page_init+0x3a4>
c010422e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104231:	73 30                	jae    c0104263 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104233:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0104236:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0104239:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010423c:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010423f:	29 c8                	sub    %ecx,%eax
c0104241:	19 da                	sbb    %ebx,%edx
c0104243:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104247:	c1 ea 0c             	shr    $0xc,%edx
c010424a:	89 c3                	mov    %eax,%ebx
c010424c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010424f:	89 04 24             	mov    %eax,(%esp)
c0104252:	e8 a5 f8 ff ff       	call   c0103afc <pa2page>
c0104257:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010425b:	89 04 24             	mov    %eax,(%esp)
c010425e:	e8 78 fb ff ff       	call   c0103ddb <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0104263:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104267:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010426a:	8b 00                	mov    (%eax),%eax
c010426c:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010426f:	0f 8f 7e fe ff ff    	jg     c01040f3 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0104275:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010427b:	5b                   	pop    %ebx
c010427c:	5e                   	pop    %esi
c010427d:	5f                   	pop    %edi
c010427e:	5d                   	pop    %ebp
c010427f:	c3                   	ret    

c0104280 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104280:	55                   	push   %ebp
c0104281:	89 e5                	mov    %esp,%ebp
c0104283:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104286:	8b 45 14             	mov    0x14(%ebp),%eax
c0104289:	8b 55 0c             	mov    0xc(%ebp),%edx
c010428c:	31 d0                	xor    %edx,%eax
c010428e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104293:	85 c0                	test   %eax,%eax
c0104295:	74 24                	je     c01042bb <boot_map_segment+0x3b>
c0104297:	c7 44 24 0c e2 6b 10 	movl   $0xc0106be2,0xc(%esp)
c010429e:	c0 
c010429f:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c01042a6:	c0 
c01042a7:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01042ae:	00 
c01042af:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01042b6:	e8 17 ca ff ff       	call   c0100cd2 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01042bb:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01042c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042c5:	25 ff 0f 00 00       	and    $0xfff,%eax
c01042ca:	89 c2                	mov    %eax,%edx
c01042cc:	8b 45 10             	mov    0x10(%ebp),%eax
c01042cf:	01 c2                	add    %eax,%edx
c01042d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01042d4:	01 d0                	add    %edx,%eax
c01042d6:	83 e8 01             	sub    $0x1,%eax
c01042d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01042dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01042df:	ba 00 00 00 00       	mov    $0x0,%edx
c01042e4:	f7 75 f0             	divl   -0x10(%ebp)
c01042e7:	89 d0                	mov    %edx,%eax
c01042e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01042ec:	29 c2                	sub    %eax,%edx
c01042ee:	89 d0                	mov    %edx,%eax
c01042f0:	c1 e8 0c             	shr    $0xc,%eax
c01042f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01042f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01042fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104304:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104307:	8b 45 14             	mov    0x14(%ebp),%eax
c010430a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010430d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104310:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104315:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104318:	eb 6b                	jmp    c0104385 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c010431a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104321:	00 
c0104322:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104325:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104329:	8b 45 08             	mov    0x8(%ebp),%eax
c010432c:	89 04 24             	mov    %eax,(%esp)
c010432f:	e8 82 01 00 00       	call   c01044b6 <get_pte>
c0104334:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104337:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010433b:	75 24                	jne    c0104361 <boot_map_segment+0xe1>
c010433d:	c7 44 24 0c 0e 6c 10 	movl   $0xc0106c0e,0xc(%esp)
c0104344:	c0 
c0104345:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c010434c:	c0 
c010434d:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0104354:	00 
c0104355:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c010435c:	e8 71 c9 ff ff       	call   c0100cd2 <__panic>
        *ptep = pa | PTE_P | perm;
c0104361:	8b 45 18             	mov    0x18(%ebp),%eax
c0104364:	8b 55 14             	mov    0x14(%ebp),%edx
c0104367:	09 d0                	or     %edx,%eax
c0104369:	83 c8 01             	or     $0x1,%eax
c010436c:	89 c2                	mov    %eax,%edx
c010436e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104371:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104373:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104377:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010437e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104385:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104389:	75 8f                	jne    c010431a <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c010438b:	c9                   	leave  
c010438c:	c3                   	ret    

c010438d <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010438d:	55                   	push   %ebp
c010438e:	89 e5                	mov    %esp,%ebp
c0104390:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104393:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010439a:	e8 5b fa ff ff       	call   c0103dfa <alloc_pages>
c010439f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01043a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01043a6:	75 1c                	jne    c01043c4 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01043a8:	c7 44 24 08 1b 6c 10 	movl   $0xc0106c1b,0x8(%esp)
c01043af:	c0 
c01043b0:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01043b7:	00 
c01043b8:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01043bf:	e8 0e c9 ff ff       	call   c0100cd2 <__panic>
    }
    return page2kva(p);
c01043c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043c7:	89 04 24             	mov    %eax,(%esp)
c01043ca:	e8 7c f7 ff ff       	call   c0103b4b <page2kva>
}
c01043cf:	c9                   	leave  
c01043d0:	c3                   	ret    

c01043d1 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01043d1:	55                   	push   %ebp
c01043d2:	89 e5                	mov    %esp,%ebp
c01043d4:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01043d7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01043dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01043df:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01043e6:	77 23                	ja     c010440b <pmm_init+0x3a>
c01043e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01043ef:	c7 44 24 08 b0 6b 10 	movl   $0xc0106bb0,0x8(%esp)
c01043f6:	c0 
c01043f7:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01043fe:	00 
c01043ff:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104406:	e8 c7 c8 ff ff       	call   c0100cd2 <__panic>
c010440b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010440e:	05 00 00 00 40       	add    $0x40000000,%eax
c0104413:	a3 80 af 11 c0       	mov    %eax,0xc011af80
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104418:	e8 8b f9 ff ff       	call   c0103da8 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010441d:	e8 6d fa ff ff       	call   c0103e8f <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104422:	e8 db 03 00 00       	call   c0104802 <check_alloc_page>

    check_pgdir();
c0104427:	e8 f4 03 00 00       	call   c0104820 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010442c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104431:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0104437:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010443c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010443f:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104446:	77 23                	ja     c010446b <pmm_init+0x9a>
c0104448:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010444b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010444f:	c7 44 24 08 b0 6b 10 	movl   $0xc0106bb0,0x8(%esp)
c0104456:	c0 
c0104457:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c010445e:	00 
c010445f:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104466:	e8 67 c8 ff ff       	call   c0100cd2 <__panic>
c010446b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010446e:	05 00 00 00 40       	add    $0x40000000,%eax
c0104473:	83 c8 03             	or     $0x3,%eax
c0104476:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104478:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010447d:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104484:	00 
c0104485:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010448c:	00 
c010448d:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104494:	38 
c0104495:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010449c:	c0 
c010449d:	89 04 24             	mov    %eax,(%esp)
c01044a0:	e8 db fd ff ff       	call   c0104280 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01044a5:	e8 0f f8 ff ff       	call   c0103cb9 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01044aa:	e8 0c 0a 00 00       	call   c0104ebb <check_boot_pgdir>

    print_pgdir();
c01044af:	e8 94 0e 00 00       	call   c0105348 <print_pgdir>

}
c01044b4:	c9                   	leave  
c01044b5:	c3                   	ret    

c01044b6 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01044b6:	55                   	push   %ebp
c01044b7:	89 e5                	mov    %esp,%ebp
c01044b9:	83 ec 38             	sub    $0x38,%esp
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif

 pde_t *pdep = &pgdir[PDX(la)];
c01044bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044bf:	c1 e8 16             	shr    $0x16,%eax
c01044c2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01044c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01044cc:	01 d0                	add    %edx,%eax
c01044ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01044d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044d4:	8b 00                	mov    (%eax),%eax
c01044d6:	83 e0 01             	and    $0x1,%eax
c01044d9:	85 c0                	test   %eax,%eax
c01044db:	0f 85 af 00 00 00    	jne    c0104590 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01044e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01044e5:	74 15                	je     c01044fc <get_pte+0x46>
c01044e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01044ee:	e8 07 f9 ff ff       	call   c0103dfa <alloc_pages>
c01044f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01044f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01044fa:	75 0a                	jne    c0104506 <get_pte+0x50>
            return NULL;
c01044fc:	b8 00 00 00 00       	mov    $0x0,%eax
c0104501:	e9 e6 00 00 00       	jmp    c01045ec <get_pte+0x136>
        }
        set_page_ref(page, 1);
c0104506:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010450d:	00 
c010450e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104511:	89 04 24             	mov    %eax,(%esp)
c0104514:	e8 e6 f6 ff ff       	call   c0103bff <set_page_ref>
        uintptr_t pa = page2pa(page);
c0104519:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010451c:	89 04 24             	mov    %eax,(%esp)
c010451f:	e8 c2 f5 ff ff       	call   c0103ae6 <page2pa>
c0104524:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0104527:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010452a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010452d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104530:	c1 e8 0c             	shr    $0xc,%eax
c0104533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104536:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010453b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010453e:	72 23                	jb     c0104563 <get_pte+0xad>
c0104540:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104543:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104547:	c7 44 24 08 0c 6b 10 	movl   $0xc0106b0c,0x8(%esp)
c010454e:	c0 
c010454f:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
c0104556:	00 
c0104557:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c010455e:	e8 6f c7 ff ff       	call   c0100cd2 <__panic>
c0104563:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104566:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010456b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104572:	00 
c0104573:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010457a:	00 
c010457b:	89 04 24             	mov    %eax,(%esp)
c010457e:	e8 e3 18 00 00       	call   c0105e66 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0104583:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104586:	83 c8 07             	or     $0x7,%eax
c0104589:	89 c2                	mov    %eax,%edx
c010458b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010458e:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0104590:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104593:	8b 00                	mov    (%eax),%eax
c0104595:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010459a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010459d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045a0:	c1 e8 0c             	shr    $0xc,%eax
c01045a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01045a6:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01045ab:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01045ae:	72 23                	jb     c01045d3 <get_pte+0x11d>
c01045b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01045b7:	c7 44 24 08 0c 6b 10 	movl   $0xc0106b0c,0x8(%esp)
c01045be:	c0 
c01045bf:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
c01045c6:	00 
c01045c7:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01045ce:	e8 ff c6 ff ff       	call   c0100cd2 <__panic>
c01045d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045d6:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01045db:	8b 55 0c             	mov    0xc(%ebp),%edx
c01045de:	c1 ea 0c             	shr    $0xc,%edx
c01045e1:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c01045e7:	c1 e2 02             	shl    $0x2,%edx
c01045ea:	01 d0                	add    %edx,%eax
}
c01045ec:	c9                   	leave  
c01045ed:	c3                   	ret    

c01045ee <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01045ee:	55                   	push   %ebp
c01045ef:	89 e5                	mov    %esp,%ebp
c01045f1:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01045f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01045fb:	00 
c01045fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104603:	8b 45 08             	mov    0x8(%ebp),%eax
c0104606:	89 04 24             	mov    %eax,(%esp)
c0104609:	e8 a8 fe ff ff       	call   c01044b6 <get_pte>
c010460e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0104611:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104615:	74 08                	je     c010461f <get_page+0x31>
        *ptep_store = ptep;
c0104617:	8b 45 10             	mov    0x10(%ebp),%eax
c010461a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010461d:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010461f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104623:	74 1b                	je     c0104640 <get_page+0x52>
c0104625:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104628:	8b 00                	mov    (%eax),%eax
c010462a:	83 e0 01             	and    $0x1,%eax
c010462d:	85 c0                	test   %eax,%eax
c010462f:	74 0f                	je     c0104640 <get_page+0x52>
        return pte2page(*ptep);
c0104631:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104634:	8b 00                	mov    (%eax),%eax
c0104636:	89 04 24             	mov    %eax,(%esp)
c0104639:	e8 61 f5 ff ff       	call   c0103b9f <pte2page>
c010463e:	eb 05                	jmp    c0104645 <get_page+0x57>
    }
    return NULL;
c0104640:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104645:	c9                   	leave  
c0104646:	c3                   	ret    

c0104647 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0104647:	55                   	push   %ebp
c0104648:	89 e5                	mov    %esp,%ebp
c010464a:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010464d:	8b 45 10             	mov    0x10(%ebp),%eax
c0104650:	8b 00                	mov    (%eax),%eax
c0104652:	83 e0 01             	and    $0x1,%eax
c0104655:	85 c0                	test   %eax,%eax
c0104657:	74 4d                	je     c01046a6 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0104659:	8b 45 10             	mov    0x10(%ebp),%eax
c010465c:	8b 00                	mov    (%eax),%eax
c010465e:	89 04 24             	mov    %eax,(%esp)
c0104661:	e8 39 f5 ff ff       	call   c0103b9f <pte2page>
c0104666:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0104669:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010466c:	89 04 24             	mov    %eax,(%esp)
c010466f:	e8 af f5 ff ff       	call   c0103c23 <page_ref_dec>
c0104674:	85 c0                	test   %eax,%eax
c0104676:	75 13                	jne    c010468b <page_remove_pte+0x44>
            free_page(page);
c0104678:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010467f:	00 
c0104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104683:	89 04 24             	mov    %eax,(%esp)
c0104686:	e8 a7 f7 ff ff       	call   c0103e32 <free_pages>
        }
        *ptep = 0;
c010468b:	8b 45 10             	mov    0x10(%ebp),%eax
c010468e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0104694:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104697:	89 44 24 04          	mov    %eax,0x4(%esp)
c010469b:	8b 45 08             	mov    0x8(%ebp),%eax
c010469e:	89 04 24             	mov    %eax,(%esp)
c01046a1:	e8 ff 00 00 00       	call   c01047a5 <tlb_invalidate>
    }
}
c01046a6:	c9                   	leave  
c01046a7:	c3                   	ret    

c01046a8 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01046a8:	55                   	push   %ebp
c01046a9:	89 e5                	mov    %esp,%ebp
c01046ab:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01046ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01046b5:	00 
c01046b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01046c0:	89 04 24             	mov    %eax,(%esp)
c01046c3:	e8 ee fd ff ff       	call   c01044b6 <get_pte>
c01046c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01046cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046cf:	74 19                	je     c01046ea <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01046d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046d4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01046d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046df:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e2:	89 04 24             	mov    %eax,(%esp)
c01046e5:	e8 5d ff ff ff       	call   c0104647 <page_remove_pte>
    }
}
c01046ea:	c9                   	leave  
c01046eb:	c3                   	ret    

c01046ec <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01046ec:	55                   	push   %ebp
c01046ed:	89 e5                	mov    %esp,%ebp
c01046ef:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01046f2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01046f9:	00 
c01046fa:	8b 45 10             	mov    0x10(%ebp),%eax
c01046fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104701:	8b 45 08             	mov    0x8(%ebp),%eax
c0104704:	89 04 24             	mov    %eax,(%esp)
c0104707:	e8 aa fd ff ff       	call   c01044b6 <get_pte>
c010470c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c010470f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104713:	75 0a                	jne    c010471f <page_insert+0x33>
        return -E_NO_MEM;
c0104715:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010471a:	e9 84 00 00 00       	jmp    c01047a3 <page_insert+0xb7>
    }
    page_ref_inc(page);
c010471f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104722:	89 04 24             	mov    %eax,(%esp)
c0104725:	e8 e2 f4 ff ff       	call   c0103c0c <page_ref_inc>
    if (*ptep & PTE_P) {
c010472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010472d:	8b 00                	mov    (%eax),%eax
c010472f:	83 e0 01             	and    $0x1,%eax
c0104732:	85 c0                	test   %eax,%eax
c0104734:	74 3e                	je     c0104774 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0104736:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104739:	8b 00                	mov    (%eax),%eax
c010473b:	89 04 24             	mov    %eax,(%esp)
c010473e:	e8 5c f4 ff ff       	call   c0103b9f <pte2page>
c0104743:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0104746:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104749:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010474c:	75 0d                	jne    c010475b <page_insert+0x6f>
            page_ref_dec(page);
c010474e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104751:	89 04 24             	mov    %eax,(%esp)
c0104754:	e8 ca f4 ff ff       	call   c0103c23 <page_ref_dec>
c0104759:	eb 19                	jmp    c0104774 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010475b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010475e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104762:	8b 45 10             	mov    0x10(%ebp),%eax
c0104765:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104769:	8b 45 08             	mov    0x8(%ebp),%eax
c010476c:	89 04 24             	mov    %eax,(%esp)
c010476f:	e8 d3 fe ff ff       	call   c0104647 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104774:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104777:	89 04 24             	mov    %eax,(%esp)
c010477a:	e8 67 f3 ff ff       	call   c0103ae6 <page2pa>
c010477f:	0b 45 14             	or     0x14(%ebp),%eax
c0104782:	83 c8 01             	or     $0x1,%eax
c0104785:	89 c2                	mov    %eax,%edx
c0104787:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010478a:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010478c:	8b 45 10             	mov    0x10(%ebp),%eax
c010478f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104793:	8b 45 08             	mov    0x8(%ebp),%eax
c0104796:	89 04 24             	mov    %eax,(%esp)
c0104799:	e8 07 00 00 00       	call   c01047a5 <tlb_invalidate>
    return 0;
c010479e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01047a3:	c9                   	leave  
c01047a4:	c3                   	ret    

c01047a5 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01047a5:	55                   	push   %ebp
c01047a6:	89 e5                	mov    %esp,%ebp
c01047a8:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01047ab:	0f 20 d8             	mov    %cr3,%eax
c01047ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01047b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c01047b4:	89 c2                	mov    %eax,%edx
c01047b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01047b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01047bc:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01047c3:	77 23                	ja     c01047e8 <tlb_invalidate+0x43>
c01047c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01047cc:	c7 44 24 08 b0 6b 10 	movl   $0xc0106bb0,0x8(%esp)
c01047d3:	c0 
c01047d4:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
c01047db:	00 
c01047dc:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01047e3:	e8 ea c4 ff ff       	call   c0100cd2 <__panic>
c01047e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047eb:	05 00 00 00 40       	add    $0x40000000,%eax
c01047f0:	39 c2                	cmp    %eax,%edx
c01047f2:	75 0c                	jne    c0104800 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01047f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01047fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047fd:	0f 01 38             	invlpg (%eax)
    }
}
c0104800:	c9                   	leave  
c0104801:	c3                   	ret    

c0104802 <check_alloc_page>:

static void
check_alloc_page(void) {
c0104802:	55                   	push   %ebp
c0104803:	89 e5                	mov    %esp,%ebp
c0104805:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0104808:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c010480d:	8b 40 18             	mov    0x18(%eax),%eax
c0104810:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104812:	c7 04 24 34 6c 10 c0 	movl   $0xc0106c34,(%esp)
c0104819:	e8 2a bb ff ff       	call   c0100348 <cprintf>
}
c010481e:	c9                   	leave  
c010481f:	c3                   	ret    

c0104820 <check_pgdir>:

static void
check_pgdir(void) {
c0104820:	55                   	push   %ebp
c0104821:	89 e5                	mov    %esp,%ebp
c0104823:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0104826:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010482b:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0104830:	76 24                	jbe    c0104856 <check_pgdir+0x36>
c0104832:	c7 44 24 0c 53 6c 10 	movl   $0xc0106c53,0xc(%esp)
c0104839:	c0 
c010483a:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104841:	c0 
c0104842:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0104849:	00 
c010484a:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104851:	e8 7c c4 ff ff       	call   c0100cd2 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104856:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010485b:	85 c0                	test   %eax,%eax
c010485d:	74 0e                	je     c010486d <check_pgdir+0x4d>
c010485f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104864:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104869:	85 c0                	test   %eax,%eax
c010486b:	74 24                	je     c0104891 <check_pgdir+0x71>
c010486d:	c7 44 24 0c 70 6c 10 	movl   $0xc0106c70,0xc(%esp)
c0104874:	c0 
c0104875:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c010487c:	c0 
c010487d:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0104884:	00 
c0104885:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c010488c:	e8 41 c4 ff ff       	call   c0100cd2 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104891:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104896:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010489d:	00 
c010489e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01048a5:	00 
c01048a6:	89 04 24             	mov    %eax,(%esp)
c01048a9:	e8 40 fd ff ff       	call   c01045ee <get_page>
c01048ae:	85 c0                	test   %eax,%eax
c01048b0:	74 24                	je     c01048d6 <check_pgdir+0xb6>
c01048b2:	c7 44 24 0c a8 6c 10 	movl   $0xc0106ca8,0xc(%esp)
c01048b9:	c0 
c01048ba:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c01048c1:	c0 
c01048c2:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c01048c9:	00 
c01048ca:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01048d1:	e8 fc c3 ff ff       	call   c0100cd2 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01048d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01048dd:	e8 18 f5 ff ff       	call   c0103dfa <alloc_pages>
c01048e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01048e5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01048ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01048f1:	00 
c01048f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048f9:	00 
c01048fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01048fd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104901:	89 04 24             	mov    %eax,(%esp)
c0104904:	e8 e3 fd ff ff       	call   c01046ec <page_insert>
c0104909:	85 c0                	test   %eax,%eax
c010490b:	74 24                	je     c0104931 <check_pgdir+0x111>
c010490d:	c7 44 24 0c d0 6c 10 	movl   $0xc0106cd0,0xc(%esp)
c0104914:	c0 
c0104915:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c010491c:	c0 
c010491d:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0104924:	00 
c0104925:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c010492c:	e8 a1 c3 ff ff       	call   c0100cd2 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104931:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104936:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010493d:	00 
c010493e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104945:	00 
c0104946:	89 04 24             	mov    %eax,(%esp)
c0104949:	e8 68 fb ff ff       	call   c01044b6 <get_pte>
c010494e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104951:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104955:	75 24                	jne    c010497b <check_pgdir+0x15b>
c0104957:	c7 44 24 0c fc 6c 10 	movl   $0xc0106cfc,0xc(%esp)
c010495e:	c0 
c010495f:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104966:	c0 
c0104967:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c010496e:	00 
c010496f:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104976:	e8 57 c3 ff ff       	call   c0100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
c010497b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010497e:	8b 00                	mov    (%eax),%eax
c0104980:	89 04 24             	mov    %eax,(%esp)
c0104983:	e8 17 f2 ff ff       	call   c0103b9f <pte2page>
c0104988:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010498b:	74 24                	je     c01049b1 <check_pgdir+0x191>
c010498d:	c7 44 24 0c 29 6d 10 	movl   $0xc0106d29,0xc(%esp)
c0104994:	c0 
c0104995:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c010499c:	c0 
c010499d:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c01049a4:	00 
c01049a5:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01049ac:	e8 21 c3 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p1) == 1);
c01049b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049b4:	89 04 24             	mov    %eax,(%esp)
c01049b7:	e8 39 f2 ff ff       	call   c0103bf5 <page_ref>
c01049bc:	83 f8 01             	cmp    $0x1,%eax
c01049bf:	74 24                	je     c01049e5 <check_pgdir+0x1c5>
c01049c1:	c7 44 24 0c 3f 6d 10 	movl   $0xc0106d3f,0xc(%esp)
c01049c8:	c0 
c01049c9:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c01049d0:	c0 
c01049d1:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c01049d8:	00 
c01049d9:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01049e0:	e8 ed c2 ff ff       	call   c0100cd2 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01049e5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01049ea:	8b 00                	mov    (%eax),%eax
c01049ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01049f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01049f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049f7:	c1 e8 0c             	shr    $0xc,%eax
c01049fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01049fd:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104a02:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104a05:	72 23                	jb     c0104a2a <check_pgdir+0x20a>
c0104a07:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104a0e:	c7 44 24 08 0c 6b 10 	movl   $0xc0106b0c,0x8(%esp)
c0104a15:	c0 
c0104a16:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c0104a1d:	00 
c0104a1e:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104a25:	e8 a8 c2 ff ff       	call   c0100cd2 <__panic>
c0104a2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a2d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104a32:	83 c0 04             	add    $0x4,%eax
c0104a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104a38:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a44:	00 
c0104a45:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104a4c:	00 
c0104a4d:	89 04 24             	mov    %eax,(%esp)
c0104a50:	e8 61 fa ff ff       	call   c01044b6 <get_pte>
c0104a55:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104a58:	74 24                	je     c0104a7e <check_pgdir+0x25e>
c0104a5a:	c7 44 24 0c 54 6d 10 	movl   $0xc0106d54,0xc(%esp)
c0104a61:	c0 
c0104a62:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104a69:	c0 
c0104a6a:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c0104a71:	00 
c0104a72:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104a79:	e8 54 c2 ff ff       	call   c0100cd2 <__panic>

    p2 = alloc_page();
c0104a7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a85:	e8 70 f3 ff ff       	call   c0103dfa <alloc_pages>
c0104a8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104a8d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a92:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104a99:	00 
c0104a9a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104aa1:	00 
c0104aa2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104aa5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104aa9:	89 04 24             	mov    %eax,(%esp)
c0104aac:	e8 3b fc ff ff       	call   c01046ec <page_insert>
c0104ab1:	85 c0                	test   %eax,%eax
c0104ab3:	74 24                	je     c0104ad9 <check_pgdir+0x2b9>
c0104ab5:	c7 44 24 0c 7c 6d 10 	movl   $0xc0106d7c,0xc(%esp)
c0104abc:	c0 
c0104abd:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104ac4:	c0 
c0104ac5:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0104acc:	00 
c0104acd:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104ad4:	e8 f9 c1 ff ff       	call   c0100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104ad9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ade:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ae5:	00 
c0104ae6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104aed:	00 
c0104aee:	89 04 24             	mov    %eax,(%esp)
c0104af1:	e8 c0 f9 ff ff       	call   c01044b6 <get_pte>
c0104af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104af9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104afd:	75 24                	jne    c0104b23 <check_pgdir+0x303>
c0104aff:	c7 44 24 0c b4 6d 10 	movl   $0xc0106db4,0xc(%esp)
c0104b06:	c0 
c0104b07:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104b0e:	c0 
c0104b0f:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0104b16:	00 
c0104b17:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104b1e:	e8 af c1 ff ff       	call   c0100cd2 <__panic>
    assert(*ptep & PTE_U);
c0104b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b26:	8b 00                	mov    (%eax),%eax
c0104b28:	83 e0 04             	and    $0x4,%eax
c0104b2b:	85 c0                	test   %eax,%eax
c0104b2d:	75 24                	jne    c0104b53 <check_pgdir+0x333>
c0104b2f:	c7 44 24 0c e4 6d 10 	movl   $0xc0106de4,0xc(%esp)
c0104b36:	c0 
c0104b37:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104b3e:	c0 
c0104b3f:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0104b46:	00 
c0104b47:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104b4e:	e8 7f c1 ff ff       	call   c0100cd2 <__panic>
    assert(*ptep & PTE_W);
c0104b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b56:	8b 00                	mov    (%eax),%eax
c0104b58:	83 e0 02             	and    $0x2,%eax
c0104b5b:	85 c0                	test   %eax,%eax
c0104b5d:	75 24                	jne    c0104b83 <check_pgdir+0x363>
c0104b5f:	c7 44 24 0c f2 6d 10 	movl   $0xc0106df2,0xc(%esp)
c0104b66:	c0 
c0104b67:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104b6e:	c0 
c0104b6f:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0104b76:	00 
c0104b77:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104b7e:	e8 4f c1 ff ff       	call   c0100cd2 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104b83:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104b88:	8b 00                	mov    (%eax),%eax
c0104b8a:	83 e0 04             	and    $0x4,%eax
c0104b8d:	85 c0                	test   %eax,%eax
c0104b8f:	75 24                	jne    c0104bb5 <check_pgdir+0x395>
c0104b91:	c7 44 24 0c 00 6e 10 	movl   $0xc0106e00,0xc(%esp)
c0104b98:	c0 
c0104b99:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104ba0:	c0 
c0104ba1:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0104ba8:	00 
c0104ba9:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104bb0:	e8 1d c1 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 1);
c0104bb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104bb8:	89 04 24             	mov    %eax,(%esp)
c0104bbb:	e8 35 f0 ff ff       	call   c0103bf5 <page_ref>
c0104bc0:	83 f8 01             	cmp    $0x1,%eax
c0104bc3:	74 24                	je     c0104be9 <check_pgdir+0x3c9>
c0104bc5:	c7 44 24 0c 16 6e 10 	movl   $0xc0106e16,0xc(%esp)
c0104bcc:	c0 
c0104bcd:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104bd4:	c0 
c0104bd5:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0104bdc:	00 
c0104bdd:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104be4:	e8 e9 c0 ff ff       	call   c0100cd2 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104be9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104bee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104bf5:	00 
c0104bf6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104bfd:	00 
c0104bfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104c01:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c05:	89 04 24             	mov    %eax,(%esp)
c0104c08:	e8 df fa ff ff       	call   c01046ec <page_insert>
c0104c0d:	85 c0                	test   %eax,%eax
c0104c0f:	74 24                	je     c0104c35 <check_pgdir+0x415>
c0104c11:	c7 44 24 0c 28 6e 10 	movl   $0xc0106e28,0xc(%esp)
c0104c18:	c0 
c0104c19:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104c20:	c0 
c0104c21:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0104c28:	00 
c0104c29:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104c30:	e8 9d c0 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p1) == 2);
c0104c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c38:	89 04 24             	mov    %eax,(%esp)
c0104c3b:	e8 b5 ef ff ff       	call   c0103bf5 <page_ref>
c0104c40:	83 f8 02             	cmp    $0x2,%eax
c0104c43:	74 24                	je     c0104c69 <check_pgdir+0x449>
c0104c45:	c7 44 24 0c 54 6e 10 	movl   $0xc0106e54,0xc(%esp)
c0104c4c:	c0 
c0104c4d:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104c54:	c0 
c0104c55:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0104c5c:	00 
c0104c5d:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104c64:	e8 69 c0 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c6c:	89 04 24             	mov    %eax,(%esp)
c0104c6f:	e8 81 ef ff ff       	call   c0103bf5 <page_ref>
c0104c74:	85 c0                	test   %eax,%eax
c0104c76:	74 24                	je     c0104c9c <check_pgdir+0x47c>
c0104c78:	c7 44 24 0c 66 6e 10 	movl   $0xc0106e66,0xc(%esp)
c0104c7f:	c0 
c0104c80:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104c87:	c0 
c0104c88:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0104c8f:	00 
c0104c90:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104c97:	e8 36 c0 ff ff       	call   c0100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104c9c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ca1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ca8:	00 
c0104ca9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104cb0:	00 
c0104cb1:	89 04 24             	mov    %eax,(%esp)
c0104cb4:	e8 fd f7 ff ff       	call   c01044b6 <get_pte>
c0104cb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104cbc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104cc0:	75 24                	jne    c0104ce6 <check_pgdir+0x4c6>
c0104cc2:	c7 44 24 0c b4 6d 10 	movl   $0xc0106db4,0xc(%esp)
c0104cc9:	c0 
c0104cca:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104cd1:	c0 
c0104cd2:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0104cd9:	00 
c0104cda:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104ce1:	e8 ec bf ff ff       	call   c0100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
c0104ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ce9:	8b 00                	mov    (%eax),%eax
c0104ceb:	89 04 24             	mov    %eax,(%esp)
c0104cee:	e8 ac ee ff ff       	call   c0103b9f <pte2page>
c0104cf3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104cf6:	74 24                	je     c0104d1c <check_pgdir+0x4fc>
c0104cf8:	c7 44 24 0c 29 6d 10 	movl   $0xc0106d29,0xc(%esp)
c0104cff:	c0 
c0104d00:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104d07:	c0 
c0104d08:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0104d0f:	00 
c0104d10:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104d17:	e8 b6 bf ff ff       	call   c0100cd2 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d1f:	8b 00                	mov    (%eax),%eax
c0104d21:	83 e0 04             	and    $0x4,%eax
c0104d24:	85 c0                	test   %eax,%eax
c0104d26:	74 24                	je     c0104d4c <check_pgdir+0x52c>
c0104d28:	c7 44 24 0c 78 6e 10 	movl   $0xc0106e78,0xc(%esp)
c0104d2f:	c0 
c0104d30:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104d37:	c0 
c0104d38:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0104d3f:	00 
c0104d40:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104d47:	e8 86 bf ff ff       	call   c0100cd2 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104d4c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104d58:	00 
c0104d59:	89 04 24             	mov    %eax,(%esp)
c0104d5c:	e8 47 f9 ff ff       	call   c01046a8 <page_remove>
    assert(page_ref(p1) == 1);
c0104d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d64:	89 04 24             	mov    %eax,(%esp)
c0104d67:	e8 89 ee ff ff       	call   c0103bf5 <page_ref>
c0104d6c:	83 f8 01             	cmp    $0x1,%eax
c0104d6f:	74 24                	je     c0104d95 <check_pgdir+0x575>
c0104d71:	c7 44 24 0c 3f 6d 10 	movl   $0xc0106d3f,0xc(%esp)
c0104d78:	c0 
c0104d79:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104d80:	c0 
c0104d81:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0104d88:	00 
c0104d89:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104d90:	e8 3d bf ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104d95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d98:	89 04 24             	mov    %eax,(%esp)
c0104d9b:	e8 55 ee ff ff       	call   c0103bf5 <page_ref>
c0104da0:	85 c0                	test   %eax,%eax
c0104da2:	74 24                	je     c0104dc8 <check_pgdir+0x5a8>
c0104da4:	c7 44 24 0c 66 6e 10 	movl   $0xc0106e66,0xc(%esp)
c0104dab:	c0 
c0104dac:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104db3:	c0 
c0104db4:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0104dbb:	00 
c0104dbc:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104dc3:	e8 0a bf ff ff       	call   c0100cd2 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104dc8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104dcd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104dd4:	00 
c0104dd5:	89 04 24             	mov    %eax,(%esp)
c0104dd8:	e8 cb f8 ff ff       	call   c01046a8 <page_remove>
    assert(page_ref(p1) == 0);
c0104ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104de0:	89 04 24             	mov    %eax,(%esp)
c0104de3:	e8 0d ee ff ff       	call   c0103bf5 <page_ref>
c0104de8:	85 c0                	test   %eax,%eax
c0104dea:	74 24                	je     c0104e10 <check_pgdir+0x5f0>
c0104dec:	c7 44 24 0c 8d 6e 10 	movl   $0xc0106e8d,0xc(%esp)
c0104df3:	c0 
c0104df4:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104dfb:	c0 
c0104dfc:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0104e03:	00 
c0104e04:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104e0b:	e8 c2 be ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e13:	89 04 24             	mov    %eax,(%esp)
c0104e16:	e8 da ed ff ff       	call   c0103bf5 <page_ref>
c0104e1b:	85 c0                	test   %eax,%eax
c0104e1d:	74 24                	je     c0104e43 <check_pgdir+0x623>
c0104e1f:	c7 44 24 0c 66 6e 10 	movl   $0xc0106e66,0xc(%esp)
c0104e26:	c0 
c0104e27:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104e2e:	c0 
c0104e2f:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0104e36:	00 
c0104e37:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104e3e:	e8 8f be ff ff       	call   c0100cd2 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104e43:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e48:	8b 00                	mov    (%eax),%eax
c0104e4a:	89 04 24             	mov    %eax,(%esp)
c0104e4d:	e8 8b ed ff ff       	call   c0103bdd <pde2page>
c0104e52:	89 04 24             	mov    %eax,(%esp)
c0104e55:	e8 9b ed ff ff       	call   c0103bf5 <page_ref>
c0104e5a:	83 f8 01             	cmp    $0x1,%eax
c0104e5d:	74 24                	je     c0104e83 <check_pgdir+0x663>
c0104e5f:	c7 44 24 0c a0 6e 10 	movl   $0xc0106ea0,0xc(%esp)
c0104e66:	c0 
c0104e67:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104e6e:	c0 
c0104e6f:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0104e76:	00 
c0104e77:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104e7e:	e8 4f be ff ff       	call   c0100cd2 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104e83:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e88:	8b 00                	mov    (%eax),%eax
c0104e8a:	89 04 24             	mov    %eax,(%esp)
c0104e8d:	e8 4b ed ff ff       	call   c0103bdd <pde2page>
c0104e92:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e99:	00 
c0104e9a:	89 04 24             	mov    %eax,(%esp)
c0104e9d:	e8 90 ef ff ff       	call   c0103e32 <free_pages>
    boot_pgdir[0] = 0;
c0104ea2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ea7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104ead:	c7 04 24 c7 6e 10 c0 	movl   $0xc0106ec7,(%esp)
c0104eb4:	e8 8f b4 ff ff       	call   c0100348 <cprintf>
}
c0104eb9:	c9                   	leave  
c0104eba:	c3                   	ret    

c0104ebb <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104ebb:	55                   	push   %ebp
c0104ebc:	89 e5                	mov    %esp,%ebp
c0104ebe:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104ec1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104ec8:	e9 ca 00 00 00       	jmp    c0104f97 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ed6:	c1 e8 0c             	shr    $0xc,%eax
c0104ed9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104edc:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104ee1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104ee4:	72 23                	jb     c0104f09 <check_boot_pgdir+0x4e>
c0104ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ee9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104eed:	c7 44 24 08 0c 6b 10 	movl   $0xc0106b0c,0x8(%esp)
c0104ef4:	c0 
c0104ef5:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0104efc:	00 
c0104efd:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104f04:	e8 c9 bd ff ff       	call   c0100cd2 <__panic>
c0104f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f0c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104f11:	89 c2                	mov    %eax,%edx
c0104f13:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f18:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104f1f:	00 
c0104f20:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f24:	89 04 24             	mov    %eax,(%esp)
c0104f27:	e8 8a f5 ff ff       	call   c01044b6 <get_pte>
c0104f2c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104f2f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104f33:	75 24                	jne    c0104f59 <check_boot_pgdir+0x9e>
c0104f35:	c7 44 24 0c e4 6e 10 	movl   $0xc0106ee4,0xc(%esp)
c0104f3c:	c0 
c0104f3d:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104f44:	c0 
c0104f45:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0104f4c:	00 
c0104f4d:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104f54:	e8 79 bd ff ff       	call   c0100cd2 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104f59:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f5c:	8b 00                	mov    (%eax),%eax
c0104f5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f63:	89 c2                	mov    %eax,%edx
c0104f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f68:	39 c2                	cmp    %eax,%edx
c0104f6a:	74 24                	je     c0104f90 <check_boot_pgdir+0xd5>
c0104f6c:	c7 44 24 0c 21 6f 10 	movl   $0xc0106f21,0xc(%esp)
c0104f73:	c0 
c0104f74:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0104f7b:	c0 
c0104f7c:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0104f83:	00 
c0104f84:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104f8b:	e8 42 bd ff ff       	call   c0100cd2 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104f90:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104f97:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104f9a:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104f9f:	39 c2                	cmp    %eax,%edx
c0104fa1:	0f 82 26 ff ff ff    	jb     c0104ecd <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104fa7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104fac:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104fb1:	8b 00                	mov    (%eax),%eax
c0104fb3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104fb8:	89 c2                	mov    %eax,%edx
c0104fba:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104fbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104fc2:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0104fc9:	77 23                	ja     c0104fee <check_boot_pgdir+0x133>
c0104fcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fce:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104fd2:	c7 44 24 08 b0 6b 10 	movl   $0xc0106bb0,0x8(%esp)
c0104fd9:	c0 
c0104fda:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0104fe1:	00 
c0104fe2:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0104fe9:	e8 e4 bc ff ff       	call   c0100cd2 <__panic>
c0104fee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ff1:	05 00 00 00 40       	add    $0x40000000,%eax
c0104ff6:	39 c2                	cmp    %eax,%edx
c0104ff8:	74 24                	je     c010501e <check_boot_pgdir+0x163>
c0104ffa:	c7 44 24 0c 38 6f 10 	movl   $0xc0106f38,0xc(%esp)
c0105001:	c0 
c0105002:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0105009:	c0 
c010500a:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0105011:	00 
c0105012:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0105019:	e8 b4 bc ff ff       	call   c0100cd2 <__panic>

    assert(boot_pgdir[0] == 0);
c010501e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105023:	8b 00                	mov    (%eax),%eax
c0105025:	85 c0                	test   %eax,%eax
c0105027:	74 24                	je     c010504d <check_boot_pgdir+0x192>
c0105029:	c7 44 24 0c 6c 6f 10 	movl   $0xc0106f6c,0xc(%esp)
c0105030:	c0 
c0105031:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0105038:	c0 
c0105039:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0105040:	00 
c0105041:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0105048:	e8 85 bc ff ff       	call   c0100cd2 <__panic>

    struct Page *p;
    p = alloc_page();
c010504d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105054:	e8 a1 ed ff ff       	call   c0103dfa <alloc_pages>
c0105059:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c010505c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105061:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105068:	00 
c0105069:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105070:	00 
c0105071:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105074:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105078:	89 04 24             	mov    %eax,(%esp)
c010507b:	e8 6c f6 ff ff       	call   c01046ec <page_insert>
c0105080:	85 c0                	test   %eax,%eax
c0105082:	74 24                	je     c01050a8 <check_boot_pgdir+0x1ed>
c0105084:	c7 44 24 0c 80 6f 10 	movl   $0xc0106f80,0xc(%esp)
c010508b:	c0 
c010508c:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0105093:	c0 
c0105094:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c010509b:	00 
c010509c:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01050a3:	e8 2a bc ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p) == 1);
c01050a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050ab:	89 04 24             	mov    %eax,(%esp)
c01050ae:	e8 42 eb ff ff       	call   c0103bf5 <page_ref>
c01050b3:	83 f8 01             	cmp    $0x1,%eax
c01050b6:	74 24                	je     c01050dc <check_boot_pgdir+0x221>
c01050b8:	c7 44 24 0c ae 6f 10 	movl   $0xc0106fae,0xc(%esp)
c01050bf:	c0 
c01050c0:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c01050c7:	c0 
c01050c8:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c01050cf:	00 
c01050d0:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01050d7:	e8 f6 bb ff ff       	call   c0100cd2 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01050dc:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01050e1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01050e8:	00 
c01050e9:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c01050f0:	00 
c01050f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01050f4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01050f8:	89 04 24             	mov    %eax,(%esp)
c01050fb:	e8 ec f5 ff ff       	call   c01046ec <page_insert>
c0105100:	85 c0                	test   %eax,%eax
c0105102:	74 24                	je     c0105128 <check_boot_pgdir+0x26d>
c0105104:	c7 44 24 0c c0 6f 10 	movl   $0xc0106fc0,0xc(%esp)
c010510b:	c0 
c010510c:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0105113:	c0 
c0105114:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c010511b:	00 
c010511c:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0105123:	e8 aa bb ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p) == 2);
c0105128:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010512b:	89 04 24             	mov    %eax,(%esp)
c010512e:	e8 c2 ea ff ff       	call   c0103bf5 <page_ref>
c0105133:	83 f8 02             	cmp    $0x2,%eax
c0105136:	74 24                	je     c010515c <check_boot_pgdir+0x2a1>
c0105138:	c7 44 24 0c f7 6f 10 	movl   $0xc0106ff7,0xc(%esp)
c010513f:	c0 
c0105140:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c0105147:	c0 
c0105148:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c010514f:	00 
c0105150:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c0105157:	e8 76 bb ff ff       	call   c0100cd2 <__panic>

    const char *str = "ucore: Hello world!!";
c010515c:	c7 45 dc 08 70 10 c0 	movl   $0xc0107008,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0105163:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105166:	89 44 24 04          	mov    %eax,0x4(%esp)
c010516a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105171:	e8 19 0a 00 00       	call   c0105b8f <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105176:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010517d:	00 
c010517e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105185:	e8 7e 0a 00 00       	call   c0105c08 <strcmp>
c010518a:	85 c0                	test   %eax,%eax
c010518c:	74 24                	je     c01051b2 <check_boot_pgdir+0x2f7>
c010518e:	c7 44 24 0c 20 70 10 	movl   $0xc0107020,0xc(%esp)
c0105195:	c0 
c0105196:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c010519d:	c0 
c010519e:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c01051a5:	00 
c01051a6:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01051ad:	e8 20 bb ff ff       	call   c0100cd2 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01051b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051b5:	89 04 24             	mov    %eax,(%esp)
c01051b8:	e8 8e e9 ff ff       	call   c0103b4b <page2kva>
c01051bd:	05 00 01 00 00       	add    $0x100,%eax
c01051c2:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01051c5:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01051cc:	e8 66 09 00 00       	call   c0105b37 <strlen>
c01051d1:	85 c0                	test   %eax,%eax
c01051d3:	74 24                	je     c01051f9 <check_boot_pgdir+0x33e>
c01051d5:	c7 44 24 0c 58 70 10 	movl   $0xc0107058,0xc(%esp)
c01051dc:	c0 
c01051dd:	c7 44 24 08 f9 6b 10 	movl   $0xc0106bf9,0x8(%esp)
c01051e4:	c0 
c01051e5:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c01051ec:	00 
c01051ed:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01051f4:	e8 d9 ba ff ff       	call   c0100cd2 <__panic>

    free_page(p);
c01051f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105200:	00 
c0105201:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105204:	89 04 24             	mov    %eax,(%esp)
c0105207:	e8 26 ec ff ff       	call   c0103e32 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c010520c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105211:	8b 00                	mov    (%eax),%eax
c0105213:	89 04 24             	mov    %eax,(%esp)
c0105216:	e8 c2 e9 ff ff       	call   c0103bdd <pde2page>
c010521b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105222:	00 
c0105223:	89 04 24             	mov    %eax,(%esp)
c0105226:	e8 07 ec ff ff       	call   c0103e32 <free_pages>
    boot_pgdir[0] = 0;
c010522b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105230:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105236:	c7 04 24 7c 70 10 c0 	movl   $0xc010707c,(%esp)
c010523d:	e8 06 b1 ff ff       	call   c0100348 <cprintf>
}
c0105242:	c9                   	leave  
c0105243:	c3                   	ret    

c0105244 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105244:	55                   	push   %ebp
c0105245:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105247:	8b 45 08             	mov    0x8(%ebp),%eax
c010524a:	83 e0 04             	and    $0x4,%eax
c010524d:	85 c0                	test   %eax,%eax
c010524f:	74 07                	je     c0105258 <perm2str+0x14>
c0105251:	b8 75 00 00 00       	mov    $0x75,%eax
c0105256:	eb 05                	jmp    c010525d <perm2str+0x19>
c0105258:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010525d:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c0105262:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105269:	8b 45 08             	mov    0x8(%ebp),%eax
c010526c:	83 e0 02             	and    $0x2,%eax
c010526f:	85 c0                	test   %eax,%eax
c0105271:	74 07                	je     c010527a <perm2str+0x36>
c0105273:	b8 77 00 00 00       	mov    $0x77,%eax
c0105278:	eb 05                	jmp    c010527f <perm2str+0x3b>
c010527a:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010527f:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c0105284:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c010528b:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c0105290:	5d                   	pop    %ebp
c0105291:	c3                   	ret    

c0105292 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105292:	55                   	push   %ebp
c0105293:	89 e5                	mov    %esp,%ebp
c0105295:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105298:	8b 45 10             	mov    0x10(%ebp),%eax
c010529b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010529e:	72 0a                	jb     c01052aa <get_pgtable_items+0x18>
        return 0;
c01052a0:	b8 00 00 00 00       	mov    $0x0,%eax
c01052a5:	e9 9c 00 00 00       	jmp    c0105346 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c01052aa:	eb 04                	jmp    c01052b0 <get_pgtable_items+0x1e>
        start ++;
c01052ac:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c01052b0:	8b 45 10             	mov    0x10(%ebp),%eax
c01052b3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052b6:	73 18                	jae    c01052d0 <get_pgtable_items+0x3e>
c01052b8:	8b 45 10             	mov    0x10(%ebp),%eax
c01052bb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01052c2:	8b 45 14             	mov    0x14(%ebp),%eax
c01052c5:	01 d0                	add    %edx,%eax
c01052c7:	8b 00                	mov    (%eax),%eax
c01052c9:	83 e0 01             	and    $0x1,%eax
c01052cc:	85 c0                	test   %eax,%eax
c01052ce:	74 dc                	je     c01052ac <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c01052d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01052d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052d6:	73 69                	jae    c0105341 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c01052d8:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01052dc:	74 08                	je     c01052e6 <get_pgtable_items+0x54>
            *left_store = start;
c01052de:	8b 45 18             	mov    0x18(%ebp),%eax
c01052e1:	8b 55 10             	mov    0x10(%ebp),%edx
c01052e4:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01052e6:	8b 45 10             	mov    0x10(%ebp),%eax
c01052e9:	8d 50 01             	lea    0x1(%eax),%edx
c01052ec:	89 55 10             	mov    %edx,0x10(%ebp)
c01052ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01052f6:	8b 45 14             	mov    0x14(%ebp),%eax
c01052f9:	01 d0                	add    %edx,%eax
c01052fb:	8b 00                	mov    (%eax),%eax
c01052fd:	83 e0 07             	and    $0x7,%eax
c0105300:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105303:	eb 04                	jmp    c0105309 <get_pgtable_items+0x77>
            start ++;
c0105305:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105309:	8b 45 10             	mov    0x10(%ebp),%eax
c010530c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010530f:	73 1d                	jae    c010532e <get_pgtable_items+0x9c>
c0105311:	8b 45 10             	mov    0x10(%ebp),%eax
c0105314:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010531b:	8b 45 14             	mov    0x14(%ebp),%eax
c010531e:	01 d0                	add    %edx,%eax
c0105320:	8b 00                	mov    (%eax),%eax
c0105322:	83 e0 07             	and    $0x7,%eax
c0105325:	89 c2                	mov    %eax,%edx
c0105327:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010532a:	39 c2                	cmp    %eax,%edx
c010532c:	74 d7                	je     c0105305 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c010532e:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105332:	74 08                	je     c010533c <get_pgtable_items+0xaa>
            *right_store = start;
c0105334:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105337:	8b 55 10             	mov    0x10(%ebp),%edx
c010533a:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c010533c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010533f:	eb 05                	jmp    c0105346 <get_pgtable_items+0xb4>
    }
    return 0;
c0105341:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105346:	c9                   	leave  
c0105347:	c3                   	ret    

c0105348 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105348:	55                   	push   %ebp
c0105349:	89 e5                	mov    %esp,%ebp
c010534b:	57                   	push   %edi
c010534c:	56                   	push   %esi
c010534d:	53                   	push   %ebx
c010534e:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105351:	c7 04 24 9c 70 10 c0 	movl   $0xc010709c,(%esp)
c0105358:	e8 eb af ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
c010535d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105364:	e9 fa 00 00 00       	jmp    c0105463 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105369:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010536c:	89 04 24             	mov    %eax,(%esp)
c010536f:	e8 d0 fe ff ff       	call   c0105244 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105374:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105377:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010537a:	29 d1                	sub    %edx,%ecx
c010537c:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010537e:	89 d6                	mov    %edx,%esi
c0105380:	c1 e6 16             	shl    $0x16,%esi
c0105383:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105386:	89 d3                	mov    %edx,%ebx
c0105388:	c1 e3 16             	shl    $0x16,%ebx
c010538b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010538e:	89 d1                	mov    %edx,%ecx
c0105390:	c1 e1 16             	shl    $0x16,%ecx
c0105393:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0105396:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105399:	29 d7                	sub    %edx,%edi
c010539b:	89 fa                	mov    %edi,%edx
c010539d:	89 44 24 14          	mov    %eax,0x14(%esp)
c01053a1:	89 74 24 10          	mov    %esi,0x10(%esp)
c01053a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01053a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01053ad:	89 54 24 04          	mov    %edx,0x4(%esp)
c01053b1:	c7 04 24 cd 70 10 c0 	movl   $0xc01070cd,(%esp)
c01053b8:	e8 8b af ff ff       	call   c0100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c01053bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053c0:	c1 e0 0a             	shl    $0xa,%eax
c01053c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01053c6:	eb 54                	jmp    c010541c <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01053c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053cb:	89 04 24             	mov    %eax,(%esp)
c01053ce:	e8 71 fe ff ff       	call   c0105244 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01053d3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01053d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01053d9:	29 d1                	sub    %edx,%ecx
c01053db:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01053dd:	89 d6                	mov    %edx,%esi
c01053df:	c1 e6 0c             	shl    $0xc,%esi
c01053e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053e5:	89 d3                	mov    %edx,%ebx
c01053e7:	c1 e3 0c             	shl    $0xc,%ebx
c01053ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01053ed:	c1 e2 0c             	shl    $0xc,%edx
c01053f0:	89 d1                	mov    %edx,%ecx
c01053f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01053f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01053f8:	29 d7                	sub    %edx,%edi
c01053fa:	89 fa                	mov    %edi,%edx
c01053fc:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105400:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105404:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105408:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010540c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105410:	c7 04 24 ec 70 10 c0 	movl   $0xc01070ec,(%esp)
c0105417:	e8 2c af ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010541c:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0105421:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105424:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105427:	89 ce                	mov    %ecx,%esi
c0105429:	c1 e6 0a             	shl    $0xa,%esi
c010542c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010542f:	89 cb                	mov    %ecx,%ebx
c0105431:	c1 e3 0a             	shl    $0xa,%ebx
c0105434:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0105437:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c010543b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c010543e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105442:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105446:	89 44 24 08          	mov    %eax,0x8(%esp)
c010544a:	89 74 24 04          	mov    %esi,0x4(%esp)
c010544e:	89 1c 24             	mov    %ebx,(%esp)
c0105451:	e8 3c fe ff ff       	call   c0105292 <get_pgtable_items>
c0105456:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105459:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010545d:	0f 85 65 ff ff ff    	jne    c01053c8 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105463:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0105468:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010546b:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c010546e:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105472:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0105475:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105479:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010547d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105481:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0105488:	00 
c0105489:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105490:	e8 fd fd ff ff       	call   c0105292 <get_pgtable_items>
c0105495:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105498:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010549c:	0f 85 c7 fe ff ff    	jne    c0105369 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01054a2:	c7 04 24 10 71 10 c0 	movl   $0xc0107110,(%esp)
c01054a9:	e8 9a ae ff ff       	call   c0100348 <cprintf>
}
c01054ae:	83 c4 4c             	add    $0x4c,%esp
c01054b1:	5b                   	pop    %ebx
c01054b2:	5e                   	pop    %esi
c01054b3:	5f                   	pop    %edi
c01054b4:	5d                   	pop    %ebp
c01054b5:	c3                   	ret    

c01054b6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01054b6:	55                   	push   %ebp
c01054b7:	89 e5                	mov    %esp,%ebp
c01054b9:	83 ec 58             	sub    $0x58,%esp
c01054bc:	8b 45 10             	mov    0x10(%ebp),%eax
c01054bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01054c2:	8b 45 14             	mov    0x14(%ebp),%eax
c01054c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01054c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01054cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01054ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01054d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01054d4:	8b 45 18             	mov    0x18(%ebp),%eax
c01054d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01054da:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01054e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01054e3:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01054e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01054ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01054f0:	74 1c                	je     c010550e <printnum+0x58>
c01054f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054f5:	ba 00 00 00 00       	mov    $0x0,%edx
c01054fa:	f7 75 e4             	divl   -0x1c(%ebp)
c01054fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105500:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105503:	ba 00 00 00 00       	mov    $0x0,%edx
c0105508:	f7 75 e4             	divl   -0x1c(%ebp)
c010550b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010550e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105511:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105514:	f7 75 e4             	divl   -0x1c(%ebp)
c0105517:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010551a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010551d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105520:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105523:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105526:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105529:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010552c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010552f:	8b 45 18             	mov    0x18(%ebp),%eax
c0105532:	ba 00 00 00 00       	mov    $0x0,%edx
c0105537:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010553a:	77 56                	ja     c0105592 <printnum+0xdc>
c010553c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010553f:	72 05                	jb     c0105546 <printnum+0x90>
c0105541:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105544:	77 4c                	ja     c0105592 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105546:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105549:	8d 50 ff             	lea    -0x1(%eax),%edx
c010554c:	8b 45 20             	mov    0x20(%ebp),%eax
c010554f:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105553:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105557:	8b 45 18             	mov    0x18(%ebp),%eax
c010555a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010555e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105561:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105564:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105568:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010556c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010556f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105573:	8b 45 08             	mov    0x8(%ebp),%eax
c0105576:	89 04 24             	mov    %eax,(%esp)
c0105579:	e8 38 ff ff ff       	call   c01054b6 <printnum>
c010557e:	eb 1c                	jmp    c010559c <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105580:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105583:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105587:	8b 45 20             	mov    0x20(%ebp),%eax
c010558a:	89 04 24             	mov    %eax,(%esp)
c010558d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105590:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0105592:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0105596:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010559a:	7f e4                	jg     c0105580 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010559c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010559f:	05 c4 71 10 c0       	add    $0xc01071c4,%eax
c01055a4:	0f b6 00             	movzbl (%eax),%eax
c01055a7:	0f be c0             	movsbl %al,%eax
c01055aa:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055ad:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055b1:	89 04 24             	mov    %eax,(%esp)
c01055b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055b7:	ff d0                	call   *%eax
}
c01055b9:	c9                   	leave  
c01055ba:	c3                   	ret    

c01055bb <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01055bb:	55                   	push   %ebp
c01055bc:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01055be:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01055c2:	7e 14                	jle    c01055d8 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01055c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055c7:	8b 00                	mov    (%eax),%eax
c01055c9:	8d 48 08             	lea    0x8(%eax),%ecx
c01055cc:	8b 55 08             	mov    0x8(%ebp),%edx
c01055cf:	89 0a                	mov    %ecx,(%edx)
c01055d1:	8b 50 04             	mov    0x4(%eax),%edx
c01055d4:	8b 00                	mov    (%eax),%eax
c01055d6:	eb 30                	jmp    c0105608 <getuint+0x4d>
    }
    else if (lflag) {
c01055d8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01055dc:	74 16                	je     c01055f4 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01055de:	8b 45 08             	mov    0x8(%ebp),%eax
c01055e1:	8b 00                	mov    (%eax),%eax
c01055e3:	8d 48 04             	lea    0x4(%eax),%ecx
c01055e6:	8b 55 08             	mov    0x8(%ebp),%edx
c01055e9:	89 0a                	mov    %ecx,(%edx)
c01055eb:	8b 00                	mov    (%eax),%eax
c01055ed:	ba 00 00 00 00       	mov    $0x0,%edx
c01055f2:	eb 14                	jmp    c0105608 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01055f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f7:	8b 00                	mov    (%eax),%eax
c01055f9:	8d 48 04             	lea    0x4(%eax),%ecx
c01055fc:	8b 55 08             	mov    0x8(%ebp),%edx
c01055ff:	89 0a                	mov    %ecx,(%edx)
c0105601:	8b 00                	mov    (%eax),%eax
c0105603:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105608:	5d                   	pop    %ebp
c0105609:	c3                   	ret    

c010560a <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010560a:	55                   	push   %ebp
c010560b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010560d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105611:	7e 14                	jle    c0105627 <getint+0x1d>
        return va_arg(*ap, long long);
c0105613:	8b 45 08             	mov    0x8(%ebp),%eax
c0105616:	8b 00                	mov    (%eax),%eax
c0105618:	8d 48 08             	lea    0x8(%eax),%ecx
c010561b:	8b 55 08             	mov    0x8(%ebp),%edx
c010561e:	89 0a                	mov    %ecx,(%edx)
c0105620:	8b 50 04             	mov    0x4(%eax),%edx
c0105623:	8b 00                	mov    (%eax),%eax
c0105625:	eb 28                	jmp    c010564f <getint+0x45>
    }
    else if (lflag) {
c0105627:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010562b:	74 12                	je     c010563f <getint+0x35>
        return va_arg(*ap, long);
c010562d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105630:	8b 00                	mov    (%eax),%eax
c0105632:	8d 48 04             	lea    0x4(%eax),%ecx
c0105635:	8b 55 08             	mov    0x8(%ebp),%edx
c0105638:	89 0a                	mov    %ecx,(%edx)
c010563a:	8b 00                	mov    (%eax),%eax
c010563c:	99                   	cltd   
c010563d:	eb 10                	jmp    c010564f <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010563f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105642:	8b 00                	mov    (%eax),%eax
c0105644:	8d 48 04             	lea    0x4(%eax),%ecx
c0105647:	8b 55 08             	mov    0x8(%ebp),%edx
c010564a:	89 0a                	mov    %ecx,(%edx)
c010564c:	8b 00                	mov    (%eax),%eax
c010564e:	99                   	cltd   
    }
}
c010564f:	5d                   	pop    %ebp
c0105650:	c3                   	ret    

c0105651 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105651:	55                   	push   %ebp
c0105652:	89 e5                	mov    %esp,%ebp
c0105654:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105657:	8d 45 14             	lea    0x14(%ebp),%eax
c010565a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010565d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105660:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105664:	8b 45 10             	mov    0x10(%ebp),%eax
c0105667:	89 44 24 08          	mov    %eax,0x8(%esp)
c010566b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010566e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105672:	8b 45 08             	mov    0x8(%ebp),%eax
c0105675:	89 04 24             	mov    %eax,(%esp)
c0105678:	e8 02 00 00 00       	call   c010567f <vprintfmt>
    va_end(ap);
}
c010567d:	c9                   	leave  
c010567e:	c3                   	ret    

c010567f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010567f:	55                   	push   %ebp
c0105680:	89 e5                	mov    %esp,%ebp
c0105682:	56                   	push   %esi
c0105683:	53                   	push   %ebx
c0105684:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105687:	eb 18                	jmp    c01056a1 <vprintfmt+0x22>
            if (ch == '\0') {
c0105689:	85 db                	test   %ebx,%ebx
c010568b:	75 05                	jne    c0105692 <vprintfmt+0x13>
                return;
c010568d:	e9 d1 03 00 00       	jmp    c0105a63 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c0105692:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105695:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105699:	89 1c 24             	mov    %ebx,(%esp)
c010569c:	8b 45 08             	mov    0x8(%ebp),%eax
c010569f:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01056a1:	8b 45 10             	mov    0x10(%ebp),%eax
c01056a4:	8d 50 01             	lea    0x1(%eax),%edx
c01056a7:	89 55 10             	mov    %edx,0x10(%ebp)
c01056aa:	0f b6 00             	movzbl (%eax),%eax
c01056ad:	0f b6 d8             	movzbl %al,%ebx
c01056b0:	83 fb 25             	cmp    $0x25,%ebx
c01056b3:	75 d4                	jne    c0105689 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c01056b5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01056b9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01056c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01056c6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01056cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056d0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01056d3:	8b 45 10             	mov    0x10(%ebp),%eax
c01056d6:	8d 50 01             	lea    0x1(%eax),%edx
c01056d9:	89 55 10             	mov    %edx,0x10(%ebp)
c01056dc:	0f b6 00             	movzbl (%eax),%eax
c01056df:	0f b6 d8             	movzbl %al,%ebx
c01056e2:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01056e5:	83 f8 55             	cmp    $0x55,%eax
c01056e8:	0f 87 44 03 00 00    	ja     c0105a32 <vprintfmt+0x3b3>
c01056ee:	8b 04 85 e8 71 10 c0 	mov    -0x3fef8e18(,%eax,4),%eax
c01056f5:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01056f7:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01056fb:	eb d6                	jmp    c01056d3 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01056fd:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105701:	eb d0                	jmp    c01056d3 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105703:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010570a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010570d:	89 d0                	mov    %edx,%eax
c010570f:	c1 e0 02             	shl    $0x2,%eax
c0105712:	01 d0                	add    %edx,%eax
c0105714:	01 c0                	add    %eax,%eax
c0105716:	01 d8                	add    %ebx,%eax
c0105718:	83 e8 30             	sub    $0x30,%eax
c010571b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010571e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105721:	0f b6 00             	movzbl (%eax),%eax
c0105724:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105727:	83 fb 2f             	cmp    $0x2f,%ebx
c010572a:	7e 0b                	jle    c0105737 <vprintfmt+0xb8>
c010572c:	83 fb 39             	cmp    $0x39,%ebx
c010572f:	7f 06                	jg     c0105737 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105731:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0105735:	eb d3                	jmp    c010570a <vprintfmt+0x8b>
            goto process_precision;
c0105737:	eb 33                	jmp    c010576c <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c0105739:	8b 45 14             	mov    0x14(%ebp),%eax
c010573c:	8d 50 04             	lea    0x4(%eax),%edx
c010573f:	89 55 14             	mov    %edx,0x14(%ebp)
c0105742:	8b 00                	mov    (%eax),%eax
c0105744:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105747:	eb 23                	jmp    c010576c <vprintfmt+0xed>

        case '.':
            if (width < 0)
c0105749:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010574d:	79 0c                	jns    c010575b <vprintfmt+0xdc>
                width = 0;
c010574f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105756:	e9 78 ff ff ff       	jmp    c01056d3 <vprintfmt+0x54>
c010575b:	e9 73 ff ff ff       	jmp    c01056d3 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c0105760:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105767:	e9 67 ff ff ff       	jmp    c01056d3 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010576c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105770:	79 12                	jns    c0105784 <vprintfmt+0x105>
                width = precision, precision = -1;
c0105772:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105775:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105778:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010577f:	e9 4f ff ff ff       	jmp    c01056d3 <vprintfmt+0x54>
c0105784:	e9 4a ff ff ff       	jmp    c01056d3 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105789:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010578d:	e9 41 ff ff ff       	jmp    c01056d3 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105792:	8b 45 14             	mov    0x14(%ebp),%eax
c0105795:	8d 50 04             	lea    0x4(%eax),%edx
c0105798:	89 55 14             	mov    %edx,0x14(%ebp)
c010579b:	8b 00                	mov    (%eax),%eax
c010579d:	8b 55 0c             	mov    0xc(%ebp),%edx
c01057a0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057a4:	89 04 24             	mov    %eax,(%esp)
c01057a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01057aa:	ff d0                	call   *%eax
            break;
c01057ac:	e9 ac 02 00 00       	jmp    c0105a5d <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01057b1:	8b 45 14             	mov    0x14(%ebp),%eax
c01057b4:	8d 50 04             	lea    0x4(%eax),%edx
c01057b7:	89 55 14             	mov    %edx,0x14(%ebp)
c01057ba:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01057bc:	85 db                	test   %ebx,%ebx
c01057be:	79 02                	jns    c01057c2 <vprintfmt+0x143>
                err = -err;
c01057c0:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01057c2:	83 fb 06             	cmp    $0x6,%ebx
c01057c5:	7f 0b                	jg     c01057d2 <vprintfmt+0x153>
c01057c7:	8b 34 9d a8 71 10 c0 	mov    -0x3fef8e58(,%ebx,4),%esi
c01057ce:	85 f6                	test   %esi,%esi
c01057d0:	75 23                	jne    c01057f5 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c01057d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01057d6:	c7 44 24 08 d5 71 10 	movl   $0xc01071d5,0x8(%esp)
c01057dd:	c0 
c01057de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057e1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01057e8:	89 04 24             	mov    %eax,(%esp)
c01057eb:	e8 61 fe ff ff       	call   c0105651 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01057f0:	e9 68 02 00 00       	jmp    c0105a5d <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c01057f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01057f9:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105800:	c0 
c0105801:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105804:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105808:	8b 45 08             	mov    0x8(%ebp),%eax
c010580b:	89 04 24             	mov    %eax,(%esp)
c010580e:	e8 3e fe ff ff       	call   c0105651 <printfmt>
            }
            break;
c0105813:	e9 45 02 00 00       	jmp    c0105a5d <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105818:	8b 45 14             	mov    0x14(%ebp),%eax
c010581b:	8d 50 04             	lea    0x4(%eax),%edx
c010581e:	89 55 14             	mov    %edx,0x14(%ebp)
c0105821:	8b 30                	mov    (%eax),%esi
c0105823:	85 f6                	test   %esi,%esi
c0105825:	75 05                	jne    c010582c <vprintfmt+0x1ad>
                p = "(null)";
c0105827:	be e1 71 10 c0       	mov    $0xc01071e1,%esi
            }
            if (width > 0 && padc != '-') {
c010582c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105830:	7e 3e                	jle    c0105870 <vprintfmt+0x1f1>
c0105832:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105836:	74 38                	je     c0105870 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105838:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010583b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010583e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105842:	89 34 24             	mov    %esi,(%esp)
c0105845:	e8 15 03 00 00       	call   c0105b5f <strnlen>
c010584a:	29 c3                	sub    %eax,%ebx
c010584c:	89 d8                	mov    %ebx,%eax
c010584e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105851:	eb 17                	jmp    c010586a <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0105853:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105857:	8b 55 0c             	mov    0xc(%ebp),%edx
c010585a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010585e:	89 04 24             	mov    %eax,(%esp)
c0105861:	8b 45 08             	mov    0x8(%ebp),%eax
c0105864:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105866:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010586a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010586e:	7f e3                	jg     c0105853 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105870:	eb 38                	jmp    c01058aa <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105872:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105876:	74 1f                	je     c0105897 <vprintfmt+0x218>
c0105878:	83 fb 1f             	cmp    $0x1f,%ebx
c010587b:	7e 05                	jle    c0105882 <vprintfmt+0x203>
c010587d:	83 fb 7e             	cmp    $0x7e,%ebx
c0105880:	7e 15                	jle    c0105897 <vprintfmt+0x218>
                    putch('?', putdat);
c0105882:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105885:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105889:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105890:	8b 45 08             	mov    0x8(%ebp),%eax
c0105893:	ff d0                	call   *%eax
c0105895:	eb 0f                	jmp    c01058a6 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0105897:	8b 45 0c             	mov    0xc(%ebp),%eax
c010589a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010589e:	89 1c 24             	mov    %ebx,(%esp)
c01058a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01058a4:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01058a6:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01058aa:	89 f0                	mov    %esi,%eax
c01058ac:	8d 70 01             	lea    0x1(%eax),%esi
c01058af:	0f b6 00             	movzbl (%eax),%eax
c01058b2:	0f be d8             	movsbl %al,%ebx
c01058b5:	85 db                	test   %ebx,%ebx
c01058b7:	74 10                	je     c01058c9 <vprintfmt+0x24a>
c01058b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01058bd:	78 b3                	js     c0105872 <vprintfmt+0x1f3>
c01058bf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c01058c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01058c7:	79 a9                	jns    c0105872 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01058c9:	eb 17                	jmp    c01058e2 <vprintfmt+0x263>
                putch(' ', putdat);
c01058cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01058d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01058dc:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01058de:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01058e2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01058e6:	7f e3                	jg     c01058cb <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c01058e8:	e9 70 01 00 00       	jmp    c0105a5d <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01058ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058f4:	8d 45 14             	lea    0x14(%ebp),%eax
c01058f7:	89 04 24             	mov    %eax,(%esp)
c01058fa:	e8 0b fd ff ff       	call   c010560a <getint>
c01058ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105902:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105905:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105908:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010590b:	85 d2                	test   %edx,%edx
c010590d:	79 26                	jns    c0105935 <vprintfmt+0x2b6>
                putch('-', putdat);
c010590f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105912:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105916:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010591d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105920:	ff d0                	call   *%eax
                num = -(long long)num;
c0105922:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105925:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105928:	f7 d8                	neg    %eax
c010592a:	83 d2 00             	adc    $0x0,%edx
c010592d:	f7 da                	neg    %edx
c010592f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105932:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105935:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010593c:	e9 a8 00 00 00       	jmp    c01059e9 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105941:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105944:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105948:	8d 45 14             	lea    0x14(%ebp),%eax
c010594b:	89 04 24             	mov    %eax,(%esp)
c010594e:	e8 68 fc ff ff       	call   c01055bb <getuint>
c0105953:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105956:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105959:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105960:	e9 84 00 00 00       	jmp    c01059e9 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105965:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105968:	89 44 24 04          	mov    %eax,0x4(%esp)
c010596c:	8d 45 14             	lea    0x14(%ebp),%eax
c010596f:	89 04 24             	mov    %eax,(%esp)
c0105972:	e8 44 fc ff ff       	call   c01055bb <getuint>
c0105977:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010597a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010597d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105984:	eb 63                	jmp    c01059e9 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0105986:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105989:	89 44 24 04          	mov    %eax,0x4(%esp)
c010598d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105994:	8b 45 08             	mov    0x8(%ebp),%eax
c0105997:	ff d0                	call   *%eax
            putch('x', putdat);
c0105999:	8b 45 0c             	mov    0xc(%ebp),%eax
c010599c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059a0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c01059a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01059aa:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c01059ac:	8b 45 14             	mov    0x14(%ebp),%eax
c01059af:	8d 50 04             	lea    0x4(%eax),%edx
c01059b2:	89 55 14             	mov    %edx,0x14(%ebp)
c01059b5:	8b 00                	mov    (%eax),%eax
c01059b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01059c1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01059c8:	eb 1f                	jmp    c01059e9 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01059ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01059cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059d1:	8d 45 14             	lea    0x14(%ebp),%eax
c01059d4:	89 04 24             	mov    %eax,(%esp)
c01059d7:	e8 df fb ff ff       	call   c01055bb <getuint>
c01059dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059df:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01059e2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01059e9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01059ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059f0:	89 54 24 18          	mov    %edx,0x18(%esp)
c01059f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01059f7:	89 54 24 14          	mov    %edx,0x14(%esp)
c01059fb:	89 44 24 10          	mov    %eax,0x10(%esp)
c01059ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a02:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a05:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a09:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a14:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a17:	89 04 24             	mov    %eax,(%esp)
c0105a1a:	e8 97 fa ff ff       	call   c01054b6 <printnum>
            break;
c0105a1f:	eb 3c                	jmp    c0105a5d <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105a21:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a24:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a28:	89 1c 24             	mov    %ebx,(%esp)
c0105a2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a2e:	ff d0                	call   *%eax
            break;
c0105a30:	eb 2b                	jmp    c0105a5d <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105a32:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a39:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105a40:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a43:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105a45:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105a49:	eb 04                	jmp    c0105a4f <vprintfmt+0x3d0>
c0105a4b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105a4f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a52:	83 e8 01             	sub    $0x1,%eax
c0105a55:	0f b6 00             	movzbl (%eax),%eax
c0105a58:	3c 25                	cmp    $0x25,%al
c0105a5a:	75 ef                	jne    c0105a4b <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0105a5c:	90                   	nop
        }
    }
c0105a5d:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105a5e:	e9 3e fc ff ff       	jmp    c01056a1 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0105a63:	83 c4 40             	add    $0x40,%esp
c0105a66:	5b                   	pop    %ebx
c0105a67:	5e                   	pop    %esi
c0105a68:	5d                   	pop    %ebp
c0105a69:	c3                   	ret    

c0105a6a <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105a6a:	55                   	push   %ebp
c0105a6b:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a70:	8b 40 08             	mov    0x8(%eax),%eax
c0105a73:	8d 50 01             	lea    0x1(%eax),%edx
c0105a76:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a79:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a7f:	8b 10                	mov    (%eax),%edx
c0105a81:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a84:	8b 40 04             	mov    0x4(%eax),%eax
c0105a87:	39 c2                	cmp    %eax,%edx
c0105a89:	73 12                	jae    c0105a9d <sprintputch+0x33>
        *b->buf ++ = ch;
c0105a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a8e:	8b 00                	mov    (%eax),%eax
c0105a90:	8d 48 01             	lea    0x1(%eax),%ecx
c0105a93:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a96:	89 0a                	mov    %ecx,(%edx)
c0105a98:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a9b:	88 10                	mov    %dl,(%eax)
    }
}
c0105a9d:	5d                   	pop    %ebp
c0105a9e:	c3                   	ret    

c0105a9f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105a9f:	55                   	push   %ebp
c0105aa0:	89 e5                	mov    %esp,%ebp
c0105aa2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105aa5:	8d 45 14             	lea    0x14(%ebp),%eax
c0105aa8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105aae:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ab2:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105abc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ac0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ac3:	89 04 24             	mov    %eax,(%esp)
c0105ac6:	e8 08 00 00 00       	call   c0105ad3 <vsnprintf>
c0105acb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105ad1:	c9                   	leave  
c0105ad2:	c3                   	ret    

c0105ad3 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105ad3:	55                   	push   %ebp
c0105ad4:	89 e5                	mov    %esp,%ebp
c0105ad6:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105ad9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105adc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105adf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ae2:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105ae5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae8:	01 d0                	add    %edx,%eax
c0105aea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105aed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105af4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105af8:	74 0a                	je     c0105b04 <vsnprintf+0x31>
c0105afa:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b00:	39 c2                	cmp    %eax,%edx
c0105b02:	76 07                	jbe    c0105b0b <vsnprintf+0x38>
        return -E_INVAL;
c0105b04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105b09:	eb 2a                	jmp    c0105b35 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105b0b:	8b 45 14             	mov    0x14(%ebp),%eax
c0105b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105b12:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b15:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b19:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b20:	c7 04 24 6a 5a 10 c0 	movl   $0xc0105a6a,(%esp)
c0105b27:	e8 53 fb ff ff       	call   c010567f <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105b2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b2f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105b35:	c9                   	leave  
c0105b36:	c3                   	ret    

c0105b37 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105b37:	55                   	push   %ebp
c0105b38:	89 e5                	mov    %esp,%ebp
c0105b3a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105b3d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105b44:	eb 04                	jmp    c0105b4a <strlen+0x13>
        cnt ++;
c0105b46:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0105b4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b4d:	8d 50 01             	lea    0x1(%eax),%edx
c0105b50:	89 55 08             	mov    %edx,0x8(%ebp)
c0105b53:	0f b6 00             	movzbl (%eax),%eax
c0105b56:	84 c0                	test   %al,%al
c0105b58:	75 ec                	jne    c0105b46 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0105b5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105b5d:	c9                   	leave  
c0105b5e:	c3                   	ret    

c0105b5f <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105b5f:	55                   	push   %ebp
c0105b60:	89 e5                	mov    %esp,%ebp
c0105b62:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105b65:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105b6c:	eb 04                	jmp    c0105b72 <strnlen+0x13>
        cnt ++;
c0105b6e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0105b72:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b75:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105b78:	73 10                	jae    c0105b8a <strnlen+0x2b>
c0105b7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b7d:	8d 50 01             	lea    0x1(%eax),%edx
c0105b80:	89 55 08             	mov    %edx,0x8(%ebp)
c0105b83:	0f b6 00             	movzbl (%eax),%eax
c0105b86:	84 c0                	test   %al,%al
c0105b88:	75 e4                	jne    c0105b6e <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0105b8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105b8d:	c9                   	leave  
c0105b8e:	c3                   	ret    

c0105b8f <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105b8f:	55                   	push   %ebp
c0105b90:	89 e5                	mov    %esp,%ebp
c0105b92:	57                   	push   %edi
c0105b93:	56                   	push   %esi
c0105b94:	83 ec 20             	sub    $0x20,%esp
c0105b97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ba0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105ba3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ba9:	89 d1                	mov    %edx,%ecx
c0105bab:	89 c2                	mov    %eax,%edx
c0105bad:	89 ce                	mov    %ecx,%esi
c0105baf:	89 d7                	mov    %edx,%edi
c0105bb1:	ac                   	lods   %ds:(%esi),%al
c0105bb2:	aa                   	stos   %al,%es:(%edi)
c0105bb3:	84 c0                	test   %al,%al
c0105bb5:	75 fa                	jne    c0105bb1 <strcpy+0x22>
c0105bb7:	89 fa                	mov    %edi,%edx
c0105bb9:	89 f1                	mov    %esi,%ecx
c0105bbb:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105bbe:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105bc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105bc7:	83 c4 20             	add    $0x20,%esp
c0105bca:	5e                   	pop    %esi
c0105bcb:	5f                   	pop    %edi
c0105bcc:	5d                   	pop    %ebp
c0105bcd:	c3                   	ret    

c0105bce <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105bce:	55                   	push   %ebp
c0105bcf:	89 e5                	mov    %esp,%ebp
c0105bd1:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105bd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bd7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105bda:	eb 21                	jmp    c0105bfd <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bdf:	0f b6 10             	movzbl (%eax),%edx
c0105be2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105be5:	88 10                	mov    %dl,(%eax)
c0105be7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105bea:	0f b6 00             	movzbl (%eax),%eax
c0105bed:	84 c0                	test   %al,%al
c0105bef:	74 04                	je     c0105bf5 <strncpy+0x27>
            src ++;
c0105bf1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105bf5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105bf9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105bfd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c01:	75 d9                	jne    c0105bdc <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105c03:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105c06:	c9                   	leave  
c0105c07:	c3                   	ret    

c0105c08 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105c08:	55                   	push   %ebp
c0105c09:	89 e5                	mov    %esp,%ebp
c0105c0b:	57                   	push   %edi
c0105c0c:	56                   	push   %esi
c0105c0d:	83 ec 20             	sub    $0x20,%esp
c0105c10:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c13:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c19:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105c1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c22:	89 d1                	mov    %edx,%ecx
c0105c24:	89 c2                	mov    %eax,%edx
c0105c26:	89 ce                	mov    %ecx,%esi
c0105c28:	89 d7                	mov    %edx,%edi
c0105c2a:	ac                   	lods   %ds:(%esi),%al
c0105c2b:	ae                   	scas   %es:(%edi),%al
c0105c2c:	75 08                	jne    c0105c36 <strcmp+0x2e>
c0105c2e:	84 c0                	test   %al,%al
c0105c30:	75 f8                	jne    c0105c2a <strcmp+0x22>
c0105c32:	31 c0                	xor    %eax,%eax
c0105c34:	eb 04                	jmp    c0105c3a <strcmp+0x32>
c0105c36:	19 c0                	sbb    %eax,%eax
c0105c38:	0c 01                	or     $0x1,%al
c0105c3a:	89 fa                	mov    %edi,%edx
c0105c3c:	89 f1                	mov    %esi,%ecx
c0105c3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105c41:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105c44:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105c47:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105c4a:	83 c4 20             	add    $0x20,%esp
c0105c4d:	5e                   	pop    %esi
c0105c4e:	5f                   	pop    %edi
c0105c4f:	5d                   	pop    %ebp
c0105c50:	c3                   	ret    

c0105c51 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105c51:	55                   	push   %ebp
c0105c52:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105c54:	eb 0c                	jmp    c0105c62 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105c56:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105c5a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105c5e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105c62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c66:	74 1a                	je     c0105c82 <strncmp+0x31>
c0105c68:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c6b:	0f b6 00             	movzbl (%eax),%eax
c0105c6e:	84 c0                	test   %al,%al
c0105c70:	74 10                	je     c0105c82 <strncmp+0x31>
c0105c72:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c75:	0f b6 10             	movzbl (%eax),%edx
c0105c78:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c7b:	0f b6 00             	movzbl (%eax),%eax
c0105c7e:	38 c2                	cmp    %al,%dl
c0105c80:	74 d4                	je     c0105c56 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105c82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c86:	74 18                	je     c0105ca0 <strncmp+0x4f>
c0105c88:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c8b:	0f b6 00             	movzbl (%eax),%eax
c0105c8e:	0f b6 d0             	movzbl %al,%edx
c0105c91:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c94:	0f b6 00             	movzbl (%eax),%eax
c0105c97:	0f b6 c0             	movzbl %al,%eax
c0105c9a:	29 c2                	sub    %eax,%edx
c0105c9c:	89 d0                	mov    %edx,%eax
c0105c9e:	eb 05                	jmp    c0105ca5 <strncmp+0x54>
c0105ca0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ca5:	5d                   	pop    %ebp
c0105ca6:	c3                   	ret    

c0105ca7 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105ca7:	55                   	push   %ebp
c0105ca8:	89 e5                	mov    %esp,%ebp
c0105caa:	83 ec 04             	sub    $0x4,%esp
c0105cad:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cb0:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105cb3:	eb 14                	jmp    c0105cc9 <strchr+0x22>
        if (*s == c) {
c0105cb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cb8:	0f b6 00             	movzbl (%eax),%eax
c0105cbb:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105cbe:	75 05                	jne    c0105cc5 <strchr+0x1e>
            return (char *)s;
c0105cc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc3:	eb 13                	jmp    c0105cd8 <strchr+0x31>
        }
        s ++;
c0105cc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105cc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ccc:	0f b6 00             	movzbl (%eax),%eax
c0105ccf:	84 c0                	test   %al,%al
c0105cd1:	75 e2                	jne    c0105cb5 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105cd8:	c9                   	leave  
c0105cd9:	c3                   	ret    

c0105cda <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105cda:	55                   	push   %ebp
c0105cdb:	89 e5                	mov    %esp,%ebp
c0105cdd:	83 ec 04             	sub    $0x4,%esp
c0105ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ce3:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105ce6:	eb 11                	jmp    c0105cf9 <strfind+0x1f>
        if (*s == c) {
c0105ce8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ceb:	0f b6 00             	movzbl (%eax),%eax
c0105cee:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105cf1:	75 02                	jne    c0105cf5 <strfind+0x1b>
            break;
c0105cf3:	eb 0e                	jmp    c0105d03 <strfind+0x29>
        }
        s ++;
c0105cf5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105cf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cfc:	0f b6 00             	movzbl (%eax),%eax
c0105cff:	84 c0                	test   %al,%al
c0105d01:	75 e5                	jne    c0105ce8 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0105d03:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105d06:	c9                   	leave  
c0105d07:	c3                   	ret    

c0105d08 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105d08:	55                   	push   %ebp
c0105d09:	89 e5                	mov    %esp,%ebp
c0105d0b:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105d0e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105d15:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105d1c:	eb 04                	jmp    c0105d22 <strtol+0x1a>
        s ++;
c0105d1e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105d22:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d25:	0f b6 00             	movzbl (%eax),%eax
c0105d28:	3c 20                	cmp    $0x20,%al
c0105d2a:	74 f2                	je     c0105d1e <strtol+0x16>
c0105d2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d2f:	0f b6 00             	movzbl (%eax),%eax
c0105d32:	3c 09                	cmp    $0x9,%al
c0105d34:	74 e8                	je     c0105d1e <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105d36:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d39:	0f b6 00             	movzbl (%eax),%eax
c0105d3c:	3c 2b                	cmp    $0x2b,%al
c0105d3e:	75 06                	jne    c0105d46 <strtol+0x3e>
        s ++;
c0105d40:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d44:	eb 15                	jmp    c0105d5b <strtol+0x53>
    }
    else if (*s == '-') {
c0105d46:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d49:	0f b6 00             	movzbl (%eax),%eax
c0105d4c:	3c 2d                	cmp    $0x2d,%al
c0105d4e:	75 0b                	jne    c0105d5b <strtol+0x53>
        s ++, neg = 1;
c0105d50:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d54:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105d5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d5f:	74 06                	je     c0105d67 <strtol+0x5f>
c0105d61:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105d65:	75 24                	jne    c0105d8b <strtol+0x83>
c0105d67:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d6a:	0f b6 00             	movzbl (%eax),%eax
c0105d6d:	3c 30                	cmp    $0x30,%al
c0105d6f:	75 1a                	jne    c0105d8b <strtol+0x83>
c0105d71:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d74:	83 c0 01             	add    $0x1,%eax
c0105d77:	0f b6 00             	movzbl (%eax),%eax
c0105d7a:	3c 78                	cmp    $0x78,%al
c0105d7c:	75 0d                	jne    c0105d8b <strtol+0x83>
        s += 2, base = 16;
c0105d7e:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105d82:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105d89:	eb 2a                	jmp    c0105db5 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105d8b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d8f:	75 17                	jne    c0105da8 <strtol+0xa0>
c0105d91:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d94:	0f b6 00             	movzbl (%eax),%eax
c0105d97:	3c 30                	cmp    $0x30,%al
c0105d99:	75 0d                	jne    c0105da8 <strtol+0xa0>
        s ++, base = 8;
c0105d9b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d9f:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105da6:	eb 0d                	jmp    c0105db5 <strtol+0xad>
    }
    else if (base == 0) {
c0105da8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105dac:	75 07                	jne    c0105db5 <strtol+0xad>
        base = 10;
c0105dae:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105db5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105db8:	0f b6 00             	movzbl (%eax),%eax
c0105dbb:	3c 2f                	cmp    $0x2f,%al
c0105dbd:	7e 1b                	jle    c0105dda <strtol+0xd2>
c0105dbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dc2:	0f b6 00             	movzbl (%eax),%eax
c0105dc5:	3c 39                	cmp    $0x39,%al
c0105dc7:	7f 11                	jg     c0105dda <strtol+0xd2>
            dig = *s - '0';
c0105dc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dcc:	0f b6 00             	movzbl (%eax),%eax
c0105dcf:	0f be c0             	movsbl %al,%eax
c0105dd2:	83 e8 30             	sub    $0x30,%eax
c0105dd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105dd8:	eb 48                	jmp    c0105e22 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105dda:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ddd:	0f b6 00             	movzbl (%eax),%eax
c0105de0:	3c 60                	cmp    $0x60,%al
c0105de2:	7e 1b                	jle    c0105dff <strtol+0xf7>
c0105de4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105de7:	0f b6 00             	movzbl (%eax),%eax
c0105dea:	3c 7a                	cmp    $0x7a,%al
c0105dec:	7f 11                	jg     c0105dff <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105dee:	8b 45 08             	mov    0x8(%ebp),%eax
c0105df1:	0f b6 00             	movzbl (%eax),%eax
c0105df4:	0f be c0             	movsbl %al,%eax
c0105df7:	83 e8 57             	sub    $0x57,%eax
c0105dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105dfd:	eb 23                	jmp    c0105e22 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105dff:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e02:	0f b6 00             	movzbl (%eax),%eax
c0105e05:	3c 40                	cmp    $0x40,%al
c0105e07:	7e 3d                	jle    c0105e46 <strtol+0x13e>
c0105e09:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e0c:	0f b6 00             	movzbl (%eax),%eax
c0105e0f:	3c 5a                	cmp    $0x5a,%al
c0105e11:	7f 33                	jg     c0105e46 <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105e13:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e16:	0f b6 00             	movzbl (%eax),%eax
c0105e19:	0f be c0             	movsbl %al,%eax
c0105e1c:	83 e8 37             	sub    $0x37,%eax
c0105e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e25:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105e28:	7c 02                	jl     c0105e2c <strtol+0x124>
            break;
c0105e2a:	eb 1a                	jmp    c0105e46 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105e2c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105e30:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e33:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105e37:	89 c2                	mov    %eax,%edx
c0105e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e3c:	01 d0                	add    %edx,%eax
c0105e3e:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105e41:	e9 6f ff ff ff       	jmp    c0105db5 <strtol+0xad>

    if (endptr) {
c0105e46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105e4a:	74 08                	je     c0105e54 <strtol+0x14c>
        *endptr = (char *) s;
c0105e4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e4f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e52:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105e54:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105e58:	74 07                	je     c0105e61 <strtol+0x159>
c0105e5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e5d:	f7 d8                	neg    %eax
c0105e5f:	eb 03                	jmp    c0105e64 <strtol+0x15c>
c0105e61:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105e64:	c9                   	leave  
c0105e65:	c3                   	ret    

c0105e66 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105e66:	55                   	push   %ebp
c0105e67:	89 e5                	mov    %esp,%ebp
c0105e69:	57                   	push   %edi
c0105e6a:	83 ec 24             	sub    $0x24,%esp
c0105e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e70:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105e73:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105e77:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e7a:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105e7d:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105e80:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e83:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105e86:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105e89:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105e8d:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105e90:	89 d7                	mov    %edx,%edi
c0105e92:	f3 aa                	rep stos %al,%es:(%edi)
c0105e94:	89 fa                	mov    %edi,%edx
c0105e96:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105e99:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105e9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105e9f:	83 c4 24             	add    $0x24,%esp
c0105ea2:	5f                   	pop    %edi
c0105ea3:	5d                   	pop    %ebp
c0105ea4:	c3                   	ret    

c0105ea5 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105ea5:	55                   	push   %ebp
c0105ea6:	89 e5                	mov    %esp,%ebp
c0105ea8:	57                   	push   %edi
c0105ea9:	56                   	push   %esi
c0105eaa:	53                   	push   %ebx
c0105eab:	83 ec 30             	sub    $0x30,%esp
c0105eae:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105eb7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105eba:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ebd:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ec3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105ec6:	73 42                	jae    c0105f0a <memmove+0x65>
c0105ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ecb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105ece:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ed1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ed7:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105eda:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105edd:	c1 e8 02             	shr    $0x2,%eax
c0105ee0:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105ee2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105ee5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ee8:	89 d7                	mov    %edx,%edi
c0105eea:	89 c6                	mov    %eax,%esi
c0105eec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105eee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105ef1:	83 e1 03             	and    $0x3,%ecx
c0105ef4:	74 02                	je     c0105ef8 <memmove+0x53>
c0105ef6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105ef8:	89 f0                	mov    %esi,%eax
c0105efa:	89 fa                	mov    %edi,%edx
c0105efc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105eff:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105f02:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105f05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f08:	eb 36                	jmp    c0105f40 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105f0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f0d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105f10:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f13:	01 c2                	add    %eax,%edx
c0105f15:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f18:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f1e:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105f21:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f24:	89 c1                	mov    %eax,%ecx
c0105f26:	89 d8                	mov    %ebx,%eax
c0105f28:	89 d6                	mov    %edx,%esi
c0105f2a:	89 c7                	mov    %eax,%edi
c0105f2c:	fd                   	std    
c0105f2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105f2f:	fc                   	cld    
c0105f30:	89 f8                	mov    %edi,%eax
c0105f32:	89 f2                	mov    %esi,%edx
c0105f34:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105f37:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105f3a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105f40:	83 c4 30             	add    $0x30,%esp
c0105f43:	5b                   	pop    %ebx
c0105f44:	5e                   	pop    %esi
c0105f45:	5f                   	pop    %edi
c0105f46:	5d                   	pop    %ebp
c0105f47:	c3                   	ret    

c0105f48 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105f48:	55                   	push   %ebp
c0105f49:	89 e5                	mov    %esp,%ebp
c0105f4b:	57                   	push   %edi
c0105f4c:	56                   	push   %esi
c0105f4d:	83 ec 20             	sub    $0x20,%esp
c0105f50:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f53:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f56:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f59:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f5c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f65:	c1 e8 02             	shr    $0x2,%eax
c0105f68:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105f6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f70:	89 d7                	mov    %edx,%edi
c0105f72:	89 c6                	mov    %eax,%esi
c0105f74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105f76:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105f79:	83 e1 03             	and    $0x3,%ecx
c0105f7c:	74 02                	je     c0105f80 <memcpy+0x38>
c0105f7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105f80:	89 f0                	mov    %esi,%eax
c0105f82:	89 fa                	mov    %edi,%edx
c0105f84:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105f87:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105f8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105f90:	83 c4 20             	add    $0x20,%esp
c0105f93:	5e                   	pop    %esi
c0105f94:	5f                   	pop    %edi
c0105f95:	5d                   	pop    %ebp
c0105f96:	c3                   	ret    

c0105f97 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105f97:	55                   	push   %ebp
c0105f98:	89 e5                	mov    %esp,%ebp
c0105f9a:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105f9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fa0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fa6:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105fa9:	eb 30                	jmp    c0105fdb <memcmp+0x44>
        if (*s1 != *s2) {
c0105fab:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fae:	0f b6 10             	movzbl (%eax),%edx
c0105fb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105fb4:	0f b6 00             	movzbl (%eax),%eax
c0105fb7:	38 c2                	cmp    %al,%dl
c0105fb9:	74 18                	je     c0105fd3 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105fbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fbe:	0f b6 00             	movzbl (%eax),%eax
c0105fc1:	0f b6 d0             	movzbl %al,%edx
c0105fc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105fc7:	0f b6 00             	movzbl (%eax),%eax
c0105fca:	0f b6 c0             	movzbl %al,%eax
c0105fcd:	29 c2                	sub    %eax,%edx
c0105fcf:	89 d0                	mov    %edx,%eax
c0105fd1:	eb 1a                	jmp    c0105fed <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105fd3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105fd7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105fdb:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fde:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105fe1:	89 55 10             	mov    %edx,0x10(%ebp)
c0105fe4:	85 c0                	test   %eax,%eax
c0105fe6:	75 c3                	jne    c0105fab <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105fe8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105fed:	c9                   	leave  
c0105fee:	c3                   	ret    
