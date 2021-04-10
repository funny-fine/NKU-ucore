
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 88 af 11 00       	mov    $0x11af88,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 04 5e 00 00       	call   105e66 <memset>

    cons_init();                // init the console
  100062:	e8 82 15 00 00       	call   1015e9 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 00 60 10 00 	movl   $0x106000,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 1c 60 10 00 	movl   $0x10601c,(%esp)
  10007c:	e8 c7 02 00 00       	call   100348 <cprintf>

    print_kerninfo();
  100081:	e8 f6 07 00 00       	call   10087c <print_kerninfo>

    grade_backtrace();
  100086:	e8 86 00 00 00       	call   100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 41 43 00 00       	call   1043d1 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 bd 16 00 00       	call   101752 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 35 18 00 00       	call   1018cf <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 00 0d 00 00       	call   100d9f <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 1c 16 00 00       	call   1016c0 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 f8 0b 00 00       	call   100cc0 <mon_backtrace>
}
  1000c8:	c9                   	leave  
  1000c9:	c3                   	ret    

001000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000ca:	55                   	push   %ebp
  1000cb:	89 e5                	mov    %esp,%ebp
  1000cd:	53                   	push   %ebx
  1000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000d7:	8d 55 08             	lea    0x8(%ebp),%edx
  1000da:	8b 45 08             	mov    0x8(%ebp),%eax
  1000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000e9:	89 04 24             	mov    %eax,(%esp)
  1000ec:	e8 b5 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f1:	83 c4 14             	add    $0x14,%esp
  1000f4:	5b                   	pop    %ebx
  1000f5:	5d                   	pop    %ebp
  1000f6:	c3                   	ret    

001000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f7:	55                   	push   %ebp
  1000f8:	89 e5                	mov    %esp,%ebp
  1000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000fd:	8b 45 10             	mov    0x10(%ebp),%eax
  100100:	89 44 24 04          	mov    %eax,0x4(%esp)
  100104:	8b 45 08             	mov    0x8(%ebp),%eax
  100107:	89 04 24             	mov    %eax,(%esp)
  10010a:	e8 bb ff ff ff       	call   1000ca <grade_backtrace1>
}
  10010f:	c9                   	leave  
  100110:	c3                   	ret    

00100111 <grade_backtrace>:

void
grade_backtrace(void) {
  100111:	55                   	push   %ebp
  100112:	89 e5                	mov    %esp,%ebp
  100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  100117:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100123:	ff 
  100124:	89 44 24 04          	mov    %eax,0x4(%esp)
  100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10012f:	e8 c3 ff ff ff       	call   1000f7 <grade_backtrace0>
}
  100134:	c9                   	leave  
  100135:	c3                   	ret    

00100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100136:	55                   	push   %ebp
  100137:	89 e5                	mov    %esp,%ebp
  100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10014c:	0f b7 c0             	movzwl %ax,%eax
  10014f:	83 e0 03             	and    $0x3,%eax
  100152:	89 c2                	mov    %eax,%edx
  100154:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100159:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100161:	c7 04 24 21 60 10 00 	movl   $0x106021,(%esp)
  100168:	e8 db 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100171:	0f b7 d0             	movzwl %ax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 2f 60 10 00 	movl   $0x10602f,(%esp)
  100188:	e8 bb 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	0f b7 d0             	movzwl %ax,%edx
  100194:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 3d 60 10 00 	movl   $0x10603d,(%esp)
  1001a8:	e8 9b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 4b 60 10 00 	movl   $0x10604b,(%esp)
  1001c8:	e8 7b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d1:	0f b7 d0             	movzwl %ax,%edx
  1001d4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e1:	c7 04 24 59 60 10 00 	movl   $0x106059,(%esp)
  1001e8:	e8 5b 01 00 00       	call   100348 <cprintf>
    round ++;
  1001ed:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001f2:	83 c0 01             	add    $0x1,%eax
  1001f5:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001fa:	c9                   	leave  
  1001fb:	c3                   	ret    

001001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fc:	55                   	push   %ebp
  1001fd:	89 e5                	mov    %esp,%ebp

}
  1001ff:	5d                   	pop    %ebp
  100200:	c3                   	ret    

00100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100201:	55                   	push   %ebp
  100202:	89 e5                	mov    %esp,%ebp

}
  100204:	5d                   	pop    %ebp
  100205:	c3                   	ret    

00100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100206:	55                   	push   %ebp
  100207:	89 e5                	mov    %esp,%ebp
  100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020c:	e8 25 ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100211:	c7 04 24 68 60 10 00 	movl   $0x106068,(%esp)
  100218:	e8 2b 01 00 00       	call   100348 <cprintf>
    lab1_switch_to_user();
  10021d:	e8 da ff ff ff       	call   1001fc <lab1_switch_to_user>
    lab1_print_cur_status();
  100222:	e8 0f ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100227:	c7 04 24 88 60 10 00 	movl   $0x106088,(%esp)
  10022e:	e8 15 01 00 00       	call   100348 <cprintf>
    lab1_switch_to_kernel();
  100233:	e8 c9 ff ff ff       	call   100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100238:	e8 f9 fe ff ff       	call   100136 <lab1_print_cur_status>
}
  10023d:	c9                   	leave  
  10023e:	c3                   	ret    

0010023f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10023f:	55                   	push   %ebp
  100240:	89 e5                	mov    %esp,%ebp
  100242:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100245:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100249:	74 13                	je     10025e <readline+0x1f>
        cprintf("%s", prompt);
  10024b:	8b 45 08             	mov    0x8(%ebp),%eax
  10024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100252:	c7 04 24 a7 60 10 00 	movl   $0x1060a7,(%esp)
  100259:	e8 ea 00 00 00       	call   100348 <cprintf>
    }
    int i = 0, c;
  10025e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100265:	e8 66 01 00 00       	call   1003d0 <getchar>
  10026a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10026d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100271:	79 07                	jns    10027a <readline+0x3b>
            return NULL;
  100273:	b8 00 00 00 00       	mov    $0x0,%eax
  100278:	eb 79                	jmp    1002f3 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10027a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10027e:	7e 28                	jle    1002a8 <readline+0x69>
  100280:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100287:	7f 1f                	jg     1002a8 <readline+0x69>
            cputchar(c);
  100289:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10028c:	89 04 24             	mov    %eax,(%esp)
  10028f:	e8 da 00 00 00       	call   10036e <cputchar>
            buf[i ++] = c;
  100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100297:	8d 50 01             	lea    0x1(%eax),%edx
  10029a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10029d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002a0:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  1002a6:	eb 46                	jmp    1002ee <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  1002a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002ac:	75 17                	jne    1002c5 <readline+0x86>
  1002ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002b2:	7e 11                	jle    1002c5 <readline+0x86>
            cputchar(c);
  1002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002b7:	89 04 24             	mov    %eax,(%esp)
  1002ba:	e8 af 00 00 00       	call   10036e <cputchar>
            i --;
  1002bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1002c3:	eb 29                	jmp    1002ee <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  1002c5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002c9:	74 06                	je     1002d1 <readline+0x92>
  1002cb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002cf:	75 1d                	jne    1002ee <readline+0xaf>
            cputchar(c);
  1002d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002d4:	89 04 24             	mov    %eax,(%esp)
  1002d7:	e8 92 00 00 00       	call   10036e <cputchar>
            buf[i] = '\0';
  1002dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002df:	05 20 a0 11 00       	add    $0x11a020,%eax
  1002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002e7:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1002ec:	eb 05                	jmp    1002f3 <readline+0xb4>
        }
    }
  1002ee:	e9 72 ff ff ff       	jmp    100265 <readline+0x26>
}
  1002f3:	c9                   	leave  
  1002f4:	c3                   	ret    

001002f5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002f5:	55                   	push   %ebp
  1002f6:	89 e5                	mov    %esp,%ebp
  1002f8:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1002fe:	89 04 24             	mov    %eax,(%esp)
  100301:	e8 0f 13 00 00       	call   101615 <cons_putc>
    (*cnt) ++;
  100306:	8b 45 0c             	mov    0xc(%ebp),%eax
  100309:	8b 00                	mov    (%eax),%eax
  10030b:	8d 50 01             	lea    0x1(%eax),%edx
  10030e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100311:	89 10                	mov    %edx,(%eax)
}
  100313:	c9                   	leave  
  100314:	c3                   	ret    

00100315 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100315:	55                   	push   %ebp
  100316:	89 e5                	mov    %esp,%ebp
  100318:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10031b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100322:	8b 45 0c             	mov    0xc(%ebp),%eax
  100325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100329:	8b 45 08             	mov    0x8(%ebp),%eax
  10032c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100330:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100333:	89 44 24 04          	mov    %eax,0x4(%esp)
  100337:	c7 04 24 f5 02 10 00 	movl   $0x1002f5,(%esp)
  10033e:	e8 3c 53 00 00       	call   10567f <vprintfmt>
    return cnt;
  100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100346:	c9                   	leave  
  100347:	c3                   	ret    

00100348 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100348:	55                   	push   %ebp
  100349:	89 e5                	mov    %esp,%ebp
  10034b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10034e:	8d 45 0c             	lea    0xc(%ebp),%eax
  100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100357:	89 44 24 04          	mov    %eax,0x4(%esp)
  10035b:	8b 45 08             	mov    0x8(%ebp),%eax
  10035e:	89 04 24             	mov    %eax,(%esp)
  100361:	e8 af ff ff ff       	call   100315 <vcprintf>
  100366:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100369:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10036c:	c9                   	leave  
  10036d:	c3                   	ret    

0010036e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10036e:	55                   	push   %ebp
  10036f:	89 e5                	mov    %esp,%ebp
  100371:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100374:	8b 45 08             	mov    0x8(%ebp),%eax
  100377:	89 04 24             	mov    %eax,(%esp)
  10037a:	e8 96 12 00 00       	call   101615 <cons_putc>
}
  10037f:	c9                   	leave  
  100380:	c3                   	ret    

00100381 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100381:	55                   	push   %ebp
  100382:	89 e5                	mov    %esp,%ebp
  100384:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  10038e:	eb 13                	jmp    1003a3 <cputs+0x22>
        cputch(c, &cnt);
  100390:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  100394:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100397:	89 54 24 04          	mov    %edx,0x4(%esp)
  10039b:	89 04 24             	mov    %eax,(%esp)
  10039e:	e8 52 ff ff ff       	call   1002f5 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1003a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1003a6:	8d 50 01             	lea    0x1(%eax),%edx
  1003a9:	89 55 08             	mov    %edx,0x8(%ebp)
  1003ac:	0f b6 00             	movzbl (%eax),%eax
  1003af:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003b2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003b6:	75 d8                	jne    100390 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1003b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003bf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003c6:	e8 2a ff ff ff       	call   1002f5 <cputch>
    return cnt;
  1003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003ce:	c9                   	leave  
  1003cf:	c3                   	ret    

001003d0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003d0:	55                   	push   %ebp
  1003d1:	89 e5                	mov    %esp,%ebp
  1003d3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003d6:	e8 76 12 00 00       	call   101651 <cons_getc>
  1003db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003e2:	74 f2                	je     1003d6 <getchar+0x6>
        /* do nothing */;
    return c;
  1003e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003e7:	c9                   	leave  
  1003e8:	c3                   	ret    

001003e9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003e9:	55                   	push   %ebp
  1003ea:	89 e5                	mov    %esp,%ebp
  1003ec:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003f2:	8b 00                	mov    (%eax),%eax
  1003f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1003f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1003fa:	8b 00                	mov    (%eax),%eax
  1003fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1003ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100406:	e9 d2 00 00 00       	jmp    1004dd <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  10040b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10040e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100411:	01 d0                	add    %edx,%eax
  100413:	89 c2                	mov    %eax,%edx
  100415:	c1 ea 1f             	shr    $0x1f,%edx
  100418:	01 d0                	add    %edx,%eax
  10041a:	d1 f8                	sar    %eax
  10041c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10041f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100422:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100425:	eb 04                	jmp    10042b <stab_binsearch+0x42>
            m --;
  100427:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10042b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10042e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100431:	7c 1f                	jl     100452 <stab_binsearch+0x69>
  100433:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100436:	89 d0                	mov    %edx,%eax
  100438:	01 c0                	add    %eax,%eax
  10043a:	01 d0                	add    %edx,%eax
  10043c:	c1 e0 02             	shl    $0x2,%eax
  10043f:	89 c2                	mov    %eax,%edx
  100441:	8b 45 08             	mov    0x8(%ebp),%eax
  100444:	01 d0                	add    %edx,%eax
  100446:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10044a:	0f b6 c0             	movzbl %al,%eax
  10044d:	3b 45 14             	cmp    0x14(%ebp),%eax
  100450:	75 d5                	jne    100427 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  100452:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100455:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100458:	7d 0b                	jge    100465 <stab_binsearch+0x7c>
            l = true_m + 1;
  10045a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10045d:	83 c0 01             	add    $0x1,%eax
  100460:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100463:	eb 78                	jmp    1004dd <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100465:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10046c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10046f:	89 d0                	mov    %edx,%eax
  100471:	01 c0                	add    %eax,%eax
  100473:	01 d0                	add    %edx,%eax
  100475:	c1 e0 02             	shl    $0x2,%eax
  100478:	89 c2                	mov    %eax,%edx
  10047a:	8b 45 08             	mov    0x8(%ebp),%eax
  10047d:	01 d0                	add    %edx,%eax
  10047f:	8b 40 08             	mov    0x8(%eax),%eax
  100482:	3b 45 18             	cmp    0x18(%ebp),%eax
  100485:	73 13                	jae    10049a <stab_binsearch+0xb1>
            *region_left = m;
  100487:	8b 45 0c             	mov    0xc(%ebp),%eax
  10048a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10048d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10048f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100492:	83 c0 01             	add    $0x1,%eax
  100495:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100498:	eb 43                	jmp    1004dd <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  10049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10049d:	89 d0                	mov    %edx,%eax
  10049f:	01 c0                	add    %eax,%eax
  1004a1:	01 d0                	add    %edx,%eax
  1004a3:	c1 e0 02             	shl    $0x2,%eax
  1004a6:	89 c2                	mov    %eax,%edx
  1004a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1004ab:	01 d0                	add    %edx,%eax
  1004ad:	8b 40 08             	mov    0x8(%eax),%eax
  1004b0:	3b 45 18             	cmp    0x18(%ebp),%eax
  1004b3:	76 16                	jbe    1004cb <stab_binsearch+0xe2>
            *region_right = m - 1;
  1004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004b8:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004bb:	8b 45 10             	mov    0x10(%ebp),%eax
  1004be:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004c3:	83 e8 01             	sub    $0x1,%eax
  1004c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004c9:	eb 12                	jmp    1004dd <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004d1:	89 10                	mov    %edx,(%eax)
            l = m;
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004d9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004e3:	0f 8e 22 ff ff ff    	jle    10040b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004ed:	75 0f                	jne    1004fe <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004f2:	8b 00                	mov    (%eax),%eax
  1004f4:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1004fa:	89 10                	mov    %edx,(%eax)
  1004fc:	eb 3f                	jmp    10053d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1004fe:	8b 45 10             	mov    0x10(%ebp),%eax
  100501:	8b 00                	mov    (%eax),%eax
  100503:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100506:	eb 04                	jmp    10050c <stab_binsearch+0x123>
  100508:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  10050c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10050f:	8b 00                	mov    (%eax),%eax
  100511:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100514:	7d 1f                	jge    100535 <stab_binsearch+0x14c>
  100516:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100519:	89 d0                	mov    %edx,%eax
  10051b:	01 c0                	add    %eax,%eax
  10051d:	01 d0                	add    %edx,%eax
  10051f:	c1 e0 02             	shl    $0x2,%eax
  100522:	89 c2                	mov    %eax,%edx
  100524:	8b 45 08             	mov    0x8(%ebp),%eax
  100527:	01 d0                	add    %edx,%eax
  100529:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10052d:	0f b6 c0             	movzbl %al,%eax
  100530:	3b 45 14             	cmp    0x14(%ebp),%eax
  100533:	75 d3                	jne    100508 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  100535:	8b 45 0c             	mov    0xc(%ebp),%eax
  100538:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10053b:	89 10                	mov    %edx,(%eax)
    }
}
  10053d:	c9                   	leave  
  10053e:	c3                   	ret    

0010053f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10053f:	55                   	push   %ebp
  100540:	89 e5                	mov    %esp,%ebp
  100542:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100545:	8b 45 0c             	mov    0xc(%ebp),%eax
  100548:	c7 00 ac 60 10 00    	movl   $0x1060ac,(%eax)
    info->eip_line = 0;
  10054e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100558:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055b:	c7 40 08 ac 60 10 00 	movl   $0x1060ac,0x8(%eax)
    info->eip_fn_namelen = 9;
  100562:	8b 45 0c             	mov    0xc(%ebp),%eax
  100565:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10056c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056f:	8b 55 08             	mov    0x8(%ebp),%edx
  100572:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100575:	8b 45 0c             	mov    0xc(%ebp),%eax
  100578:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10057f:	c7 45 f4 40 73 10 00 	movl   $0x107340,-0xc(%ebp)
    stab_end = __STAB_END__;
  100586:	c7 45 f0 54 1f 11 00 	movl   $0x111f54,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10058d:	c7 45 ec 55 1f 11 00 	movl   $0x111f55,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100594:	c7 45 e8 a0 49 11 00 	movl   $0x1149a0,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10059b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10059e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005a1:	76 0d                	jbe    1005b0 <debuginfo_eip+0x71>
  1005a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005a6:	83 e8 01             	sub    $0x1,%eax
  1005a9:	0f b6 00             	movzbl (%eax),%eax
  1005ac:	84 c0                	test   %al,%al
  1005ae:	74 0a                	je     1005ba <debuginfo_eip+0x7b>
        return -1;
  1005b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005b5:	e9 c0 02 00 00       	jmp    10087a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005c7:	29 c2                	sub    %eax,%edx
  1005c9:	89 d0                	mov    %edx,%eax
  1005cb:	c1 f8 02             	sar    $0x2,%eax
  1005ce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005d4:	83 e8 01             	sub    $0x1,%eax
  1005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005da:	8b 45 08             	mov    0x8(%ebp),%eax
  1005dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005e1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005e8:	00 
  1005e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005fa:	89 04 24             	mov    %eax,(%esp)
  1005fd:	e8 e7 fd ff ff       	call   1003e9 <stab_binsearch>
    if (lfile == 0)
  100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100605:	85 c0                	test   %eax,%eax
  100607:	75 0a                	jne    100613 <debuginfo_eip+0xd4>
        return -1;
  100609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10060e:	e9 67 02 00 00       	jmp    10087a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100616:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100619:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10061f:	8b 45 08             	mov    0x8(%ebp),%eax
  100622:	89 44 24 10          	mov    %eax,0x10(%esp)
  100626:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  10062d:	00 
  10062e:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100631:	89 44 24 08          	mov    %eax,0x8(%esp)
  100635:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100638:	89 44 24 04          	mov    %eax,0x4(%esp)
  10063c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10063f:	89 04 24             	mov    %eax,(%esp)
  100642:	e8 a2 fd ff ff       	call   1003e9 <stab_binsearch>

    if (lfun <= rfun) {
  100647:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10064a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10064d:	39 c2                	cmp    %eax,%edx
  10064f:	7f 7c                	jg     1006cd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100651:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100654:	89 c2                	mov    %eax,%edx
  100656:	89 d0                	mov    %edx,%eax
  100658:	01 c0                	add    %eax,%eax
  10065a:	01 d0                	add    %edx,%eax
  10065c:	c1 e0 02             	shl    $0x2,%eax
  10065f:	89 c2                	mov    %eax,%edx
  100661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100664:	01 d0                	add    %edx,%eax
  100666:	8b 10                	mov    (%eax),%edx
  100668:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10066b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10066e:	29 c1                	sub    %eax,%ecx
  100670:	89 c8                	mov    %ecx,%eax
  100672:	39 c2                	cmp    %eax,%edx
  100674:	73 22                	jae    100698 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100676:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100679:	89 c2                	mov    %eax,%edx
  10067b:	89 d0                	mov    %edx,%eax
  10067d:	01 c0                	add    %eax,%eax
  10067f:	01 d0                	add    %edx,%eax
  100681:	c1 e0 02             	shl    $0x2,%eax
  100684:	89 c2                	mov    %eax,%edx
  100686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100689:	01 d0                	add    %edx,%eax
  10068b:	8b 10                	mov    (%eax),%edx
  10068d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100690:	01 c2                	add    %eax,%edx
  100692:	8b 45 0c             	mov    0xc(%ebp),%eax
  100695:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100698:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10069b:	89 c2                	mov    %eax,%edx
  10069d:	89 d0                	mov    %edx,%eax
  10069f:	01 c0                	add    %eax,%eax
  1006a1:	01 d0                	add    %edx,%eax
  1006a3:	c1 e0 02             	shl    $0x2,%eax
  1006a6:	89 c2                	mov    %eax,%edx
  1006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006ab:	01 d0                	add    %edx,%eax
  1006ad:	8b 50 08             	mov    0x8(%eax),%edx
  1006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b9:	8b 40 10             	mov    0x10(%eax),%eax
  1006bc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006cb:	eb 15                	jmp    1006e2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d0:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006e5:	8b 40 08             	mov    0x8(%eax),%eax
  1006e8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006ef:	00 
  1006f0:	89 04 24             	mov    %eax,(%esp)
  1006f3:	e8 e2 55 00 00       	call   105cda <strfind>
  1006f8:	89 c2                	mov    %eax,%edx
  1006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006fd:	8b 40 08             	mov    0x8(%eax),%eax
  100700:	29 c2                	sub    %eax,%edx
  100702:	8b 45 0c             	mov    0xc(%ebp),%eax
  100705:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100708:	8b 45 08             	mov    0x8(%ebp),%eax
  10070b:	89 44 24 10          	mov    %eax,0x10(%esp)
  10070f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100716:	00 
  100717:	8d 45 d0             	lea    -0x30(%ebp),%eax
  10071a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10071e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100721:	89 44 24 04          	mov    %eax,0x4(%esp)
  100725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100728:	89 04 24             	mov    %eax,(%esp)
  10072b:	e8 b9 fc ff ff       	call   1003e9 <stab_binsearch>
    if (lline <= rline) {
  100730:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100733:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100736:	39 c2                	cmp    %eax,%edx
  100738:	7f 24                	jg     10075e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  10073a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073d:	89 c2                	mov    %eax,%edx
  10073f:	89 d0                	mov    %edx,%eax
  100741:	01 c0                	add    %eax,%eax
  100743:	01 d0                	add    %edx,%eax
  100745:	c1 e0 02             	shl    $0x2,%eax
  100748:	89 c2                	mov    %eax,%edx
  10074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074d:	01 d0                	add    %edx,%eax
  10074f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100753:	0f b7 d0             	movzwl %ax,%edx
  100756:	8b 45 0c             	mov    0xc(%ebp),%eax
  100759:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10075c:	eb 13                	jmp    100771 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  10075e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100763:	e9 12 01 00 00       	jmp    10087a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10076b:	83 e8 01             	sub    $0x1,%eax
  10076e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100777:	39 c2                	cmp    %eax,%edx
  100779:	7c 56                	jl     1007d1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  10077b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10077e:	89 c2                	mov    %eax,%edx
  100780:	89 d0                	mov    %edx,%eax
  100782:	01 c0                	add    %eax,%eax
  100784:	01 d0                	add    %edx,%eax
  100786:	c1 e0 02             	shl    $0x2,%eax
  100789:	89 c2                	mov    %eax,%edx
  10078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10078e:	01 d0                	add    %edx,%eax
  100790:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100794:	3c 84                	cmp    $0x84,%al
  100796:	74 39                	je     1007d1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079b:	89 c2                	mov    %eax,%edx
  10079d:	89 d0                	mov    %edx,%eax
  10079f:	01 c0                	add    %eax,%eax
  1007a1:	01 d0                	add    %edx,%eax
  1007a3:	c1 e0 02             	shl    $0x2,%eax
  1007a6:	89 c2                	mov    %eax,%edx
  1007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ab:	01 d0                	add    %edx,%eax
  1007ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b1:	3c 64                	cmp    $0x64,%al
  1007b3:	75 b3                	jne    100768 <debuginfo_eip+0x229>
  1007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007b8:	89 c2                	mov    %eax,%edx
  1007ba:	89 d0                	mov    %edx,%eax
  1007bc:	01 c0                	add    %eax,%eax
  1007be:	01 d0                	add    %edx,%eax
  1007c0:	c1 e0 02             	shl    $0x2,%eax
  1007c3:	89 c2                	mov    %eax,%edx
  1007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c8:	01 d0                	add    %edx,%eax
  1007ca:	8b 40 08             	mov    0x8(%eax),%eax
  1007cd:	85 c0                	test   %eax,%eax
  1007cf:	74 97                	je     100768 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007d7:	39 c2                	cmp    %eax,%edx
  1007d9:	7c 46                	jl     100821 <debuginfo_eip+0x2e2>
  1007db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007de:	89 c2                	mov    %eax,%edx
  1007e0:	89 d0                	mov    %edx,%eax
  1007e2:	01 c0                	add    %eax,%eax
  1007e4:	01 d0                	add    %edx,%eax
  1007e6:	c1 e0 02             	shl    $0x2,%eax
  1007e9:	89 c2                	mov    %eax,%edx
  1007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ee:	01 d0                	add    %edx,%eax
  1007f0:	8b 10                	mov    (%eax),%edx
  1007f2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007f8:	29 c1                	sub    %eax,%ecx
  1007fa:	89 c8                	mov    %ecx,%eax
  1007fc:	39 c2                	cmp    %eax,%edx
  1007fe:	73 21                	jae    100821 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100800:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100803:	89 c2                	mov    %eax,%edx
  100805:	89 d0                	mov    %edx,%eax
  100807:	01 c0                	add    %eax,%eax
  100809:	01 d0                	add    %edx,%eax
  10080b:	c1 e0 02             	shl    $0x2,%eax
  10080e:	89 c2                	mov    %eax,%edx
  100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100813:	01 d0                	add    %edx,%eax
  100815:	8b 10                	mov    (%eax),%edx
  100817:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10081a:	01 c2                	add    %eax,%edx
  10081c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100821:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100824:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100827:	39 c2                	cmp    %eax,%edx
  100829:	7d 4a                	jge    100875 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  10082b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10082e:	83 c0 01             	add    $0x1,%eax
  100831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100834:	eb 18                	jmp    10084e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100836:	8b 45 0c             	mov    0xc(%ebp),%eax
  100839:	8b 40 14             	mov    0x14(%eax),%eax
  10083c:	8d 50 01             	lea    0x1(%eax),%edx
  10083f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100842:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100848:	83 c0 01             	add    $0x1,%eax
  10084b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10084e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100851:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  100854:	39 c2                	cmp    %eax,%edx
  100856:	7d 1d                	jge    100875 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10085b:	89 c2                	mov    %eax,%edx
  10085d:	89 d0                	mov    %edx,%eax
  10085f:	01 c0                	add    %eax,%eax
  100861:	01 d0                	add    %edx,%eax
  100863:	c1 e0 02             	shl    $0x2,%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10086b:	01 d0                	add    %edx,%eax
  10086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100871:	3c a0                	cmp    $0xa0,%al
  100873:	74 c1                	je     100836 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100875:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10087a:	c9                   	leave  
  10087b:	c3                   	ret    

0010087c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10087c:	55                   	push   %ebp
  10087d:	89 e5                	mov    %esp,%ebp
  10087f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100882:	c7 04 24 b6 60 10 00 	movl   $0x1060b6,(%esp)
  100889:	e8 ba fa ff ff       	call   100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088e:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100895:	00 
  100896:	c7 04 24 cf 60 10 00 	movl   $0x1060cf,(%esp)
  10089d:	e8 a6 fa ff ff       	call   100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008a2:	c7 44 24 04 ef 5f 10 	movl   $0x105fef,0x4(%esp)
  1008a9:	00 
  1008aa:	c7 04 24 e7 60 10 00 	movl   $0x1060e7,(%esp)
  1008b1:	e8 92 fa ff ff       	call   100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b6:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  1008bd:	00 
  1008be:	c7 04 24 ff 60 10 00 	movl   $0x1060ff,(%esp)
  1008c5:	e8 7e fa ff ff       	call   100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008ca:	c7 44 24 04 88 af 11 	movl   $0x11af88,0x4(%esp)
  1008d1:	00 
  1008d2:	c7 04 24 17 61 10 00 	movl   $0x106117,(%esp)
  1008d9:	e8 6a fa ff ff       	call   100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008de:	b8 88 af 11 00       	mov    $0x11af88,%eax
  1008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008e9:	b8 36 00 10 00       	mov    $0x100036,%eax
  1008ee:	29 c2                	sub    %eax,%edx
  1008f0:	89 d0                	mov    %edx,%eax
  1008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f8:	85 c0                	test   %eax,%eax
  1008fa:	0f 48 c2             	cmovs  %edx,%eax
  1008fd:	c1 f8 0a             	sar    $0xa,%eax
  100900:	89 44 24 04          	mov    %eax,0x4(%esp)
  100904:	c7 04 24 30 61 10 00 	movl   $0x106130,(%esp)
  10090b:	e8 38 fa ff ff       	call   100348 <cprintf>
}
  100910:	c9                   	leave  
  100911:	c3                   	ret    

00100912 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100912:	55                   	push   %ebp
  100913:	89 e5                	mov    %esp,%ebp
  100915:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  10091b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100922:	8b 45 08             	mov    0x8(%ebp),%eax
  100925:	89 04 24             	mov    %eax,(%esp)
  100928:	e8 12 fc ff ff       	call   10053f <debuginfo_eip>
  10092d:	85 c0                	test   %eax,%eax
  10092f:	74 15                	je     100946 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100931:	8b 45 08             	mov    0x8(%ebp),%eax
  100934:	89 44 24 04          	mov    %eax,0x4(%esp)
  100938:	c7 04 24 5a 61 10 00 	movl   $0x10615a,(%esp)
  10093f:	e8 04 fa ff ff       	call   100348 <cprintf>
  100944:	eb 6d                	jmp    1009b3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10094d:	eb 1c                	jmp    10096b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  10094f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100955:	01 d0                	add    %edx,%eax
  100957:	0f b6 00             	movzbl (%eax),%eax
  10095a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100960:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100963:	01 ca                	add    %ecx,%edx
  100965:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100967:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10096b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10096e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100971:	7f dc                	jg     10094f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100973:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10097c:	01 d0                	add    %edx,%eax
  10097e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100981:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100984:	8b 55 08             	mov    0x8(%ebp),%edx
  100987:	89 d1                	mov    %edx,%ecx
  100989:	29 c1                	sub    %eax,%ecx
  10098b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10098e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100991:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100995:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10099b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10099f:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009a7:	c7 04 24 76 61 10 00 	movl   $0x106176,(%esp)
  1009ae:	e8 95 f9 ff ff       	call   100348 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  1009b3:	c9                   	leave  
  1009b4:	c3                   	ret    

001009b5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009b5:	55                   	push   %ebp
  1009b6:	89 e5                	mov    %esp,%ebp
  1009b8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009bb:	8b 45 04             	mov    0x4(%ebp),%eax
  1009be:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009c4:	c9                   	leave  
  1009c5:	c3                   	ret    

001009c6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009c6:	55                   	push   %ebp
  1009c7:	89 e5                	mov    %esp,%ebp
  1009c9:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009cc:	89 e8                	mov    %ebp,%eax
  1009ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  1009d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
int i;
int j;
uint32_t ebp=read_ebp();
  1009d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
uint32_t eip=read_eip();
  1009d7:	e8 d9 ff ff ff       	call   1009b5 <read_eip>
  1009dc:	89 45 e8             	mov    %eax,-0x18(%ebp)

	for (i=0; ebp!=0 && i<STACKFRAME_DEPTH; i++)
  1009df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009e6:	e9 88 00 00 00       	jmp    100a73 <print_stackframe+0xad>
	{
		cprintf("ebp:0x%08x eip:0x%08x ", ebp, eip);
  1009eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f9:	c7 04 24 88 61 10 00 	movl   $0x106188,(%esp)
  100a00:	e8 43 f9 ff ff       	call   100348 <cprintf>
		uint32_t *args=(uint32_t *)ebp+2;
  100a05:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100a08:	83 c0 08             	add    $0x8,%eax
  100a0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for( j=0; j<4; j++)
  100a0e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  100a15:	eb 25                	jmp    100a3c <print_stackframe+0x76>
			cprintf("0x%08x ", args[j]);
  100a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a24:	01 d0                	add    %edx,%eax
  100a26:	8b 00                	mov    (%eax),%eax
  100a28:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a2c:	c7 04 24 9f 61 10 00 	movl   $0x10619f,(%esp)
  100a33:	e8 10 f9 ff ff       	call   100348 <cprintf>

	for (i=0; ebp!=0 && i<STACKFRAME_DEPTH; i++)
	{
		cprintf("ebp:0x%08x eip:0x%08x ", ebp, eip);
		uint32_t *args=(uint32_t *)ebp+2;
		for( j=0; j<4; j++)
  100a38:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  100a3c:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
  100a40:	7e d5                	jle    100a17 <print_stackframe+0x51>
			cprintf("0x%08x ", args[j]);
		cprintf("\n");
  100a42:	c7 04 24 a7 61 10 00 	movl   $0x1061a7,(%esp)
  100a49:	e8 fa f8 ff ff       	call   100348 <cprintf>
		print_debuginfo(eip-1);
  100a4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a51:	83 e8 01             	sub    $0x1,%eax
  100a54:	89 04 24             	mov    %eax,(%esp)
  100a57:	e8 b6 fe ff ff       	call   100912 <print_debuginfo>
		eip=*((uint32_t *)ebp+1);
  100a5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100a5f:	83 c0 04             	add    $0x4,%eax
  100a62:	8b 00                	mov    (%eax),%eax
  100a64:	89 45 e8             	mov    %eax,-0x18(%ebp)
		ebp=*((uint32_t *)ebp);
  100a67:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100a6a:	8b 00                	mov    (%eax),%eax
  100a6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
int i;
int j;
uint32_t ebp=read_ebp();
uint32_t eip=read_eip();

	for (i=0; ebp!=0 && i<STACKFRAME_DEPTH; i++)
  100a6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100a73:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  100a77:	74 0a                	je     100a83 <print_stackframe+0xbd>
  100a79:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
  100a7d:	0f 8e 68 ff ff ff    	jle    1009eb <print_stackframe+0x25>





}
  100a83:	c9                   	leave  
  100a84:	c3                   	ret    

00100a85 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a85:	55                   	push   %ebp
  100a86:	89 e5                	mov    %esp,%ebp
  100a88:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a92:	eb 0c                	jmp    100aa0 <parse+0x1b>
            *buf ++ = '\0';
  100a94:	8b 45 08             	mov    0x8(%ebp),%eax
  100a97:	8d 50 01             	lea    0x1(%eax),%edx
  100a9a:	89 55 08             	mov    %edx,0x8(%ebp)
  100a9d:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa3:	0f b6 00             	movzbl (%eax),%eax
  100aa6:	84 c0                	test   %al,%al
  100aa8:	74 1d                	je     100ac7 <parse+0x42>
  100aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  100aad:	0f b6 00             	movzbl (%eax),%eax
  100ab0:	0f be c0             	movsbl %al,%eax
  100ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab7:	c7 04 24 2c 62 10 00 	movl   $0x10622c,(%esp)
  100abe:	e8 e4 51 00 00       	call   105ca7 <strchr>
  100ac3:	85 c0                	test   %eax,%eax
  100ac5:	75 cd                	jne    100a94 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  100aca:	0f b6 00             	movzbl (%eax),%eax
  100acd:	84 c0                	test   %al,%al
  100acf:	75 02                	jne    100ad3 <parse+0x4e>
            break;
  100ad1:	eb 67                	jmp    100b3a <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ad3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ad7:	75 14                	jne    100aed <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ad9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100ae0:	00 
  100ae1:	c7 04 24 31 62 10 00 	movl   $0x106231,(%esp)
  100ae8:	e8 5b f8 ff ff       	call   100348 <cprintf>
        }
        argv[argc ++] = buf;
  100aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100af0:	8d 50 01             	lea    0x1(%eax),%edx
  100af3:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100af6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b00:	01 c2                	add    %eax,%edx
  100b02:	8b 45 08             	mov    0x8(%ebp),%eax
  100b05:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b07:	eb 04                	jmp    100b0d <parse+0x88>
            buf ++;
  100b09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  100b10:	0f b6 00             	movzbl (%eax),%eax
  100b13:	84 c0                	test   %al,%al
  100b15:	74 1d                	je     100b34 <parse+0xaf>
  100b17:	8b 45 08             	mov    0x8(%ebp),%eax
  100b1a:	0f b6 00             	movzbl (%eax),%eax
  100b1d:	0f be c0             	movsbl %al,%eax
  100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b24:	c7 04 24 2c 62 10 00 	movl   $0x10622c,(%esp)
  100b2b:	e8 77 51 00 00       	call   105ca7 <strchr>
  100b30:	85 c0                	test   %eax,%eax
  100b32:	74 d5                	je     100b09 <parse+0x84>
            buf ++;
        }
    }
  100b34:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b35:	e9 66 ff ff ff       	jmp    100aa0 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b3d:	c9                   	leave  
  100b3e:	c3                   	ret    

00100b3f <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b3f:	55                   	push   %ebp
  100b40:	89 e5                	mov    %esp,%ebp
  100b42:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4f:	89 04 24             	mov    %eax,(%esp)
  100b52:	e8 2e ff ff ff       	call   100a85 <parse>
  100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b5e:	75 0a                	jne    100b6a <runcmd+0x2b>
        return 0;
  100b60:	b8 00 00 00 00       	mov    $0x0,%eax
  100b65:	e9 85 00 00 00       	jmp    100bef <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b71:	eb 5c                	jmp    100bcf <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b73:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b79:	89 d0                	mov    %edx,%eax
  100b7b:	01 c0                	add    %eax,%eax
  100b7d:	01 d0                	add    %edx,%eax
  100b7f:	c1 e0 02             	shl    $0x2,%eax
  100b82:	05 00 70 11 00       	add    $0x117000,%eax
  100b87:	8b 00                	mov    (%eax),%eax
  100b89:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b8d:	89 04 24             	mov    %eax,(%esp)
  100b90:	e8 73 50 00 00       	call   105c08 <strcmp>
  100b95:	85 c0                	test   %eax,%eax
  100b97:	75 32                	jne    100bcb <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b9c:	89 d0                	mov    %edx,%eax
  100b9e:	01 c0                	add    %eax,%eax
  100ba0:	01 d0                	add    %edx,%eax
  100ba2:	c1 e0 02             	shl    $0x2,%eax
  100ba5:	05 00 70 11 00       	add    $0x117000,%eax
  100baa:	8b 40 08             	mov    0x8(%eax),%eax
  100bad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100bb0:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  100bb6:	89 54 24 08          	mov    %edx,0x8(%esp)
  100bba:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100bbd:	83 c2 04             	add    $0x4,%edx
  100bc0:	89 54 24 04          	mov    %edx,0x4(%esp)
  100bc4:	89 0c 24             	mov    %ecx,(%esp)
  100bc7:	ff d0                	call   *%eax
  100bc9:	eb 24                	jmp    100bef <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bd2:	83 f8 02             	cmp    $0x2,%eax
  100bd5:	76 9c                	jbe    100b73 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bd7:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bda:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bde:	c7 04 24 4f 62 10 00 	movl   $0x10624f,(%esp)
  100be5:	e8 5e f7 ff ff       	call   100348 <cprintf>
    return 0;
  100bea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bef:	c9                   	leave  
  100bf0:	c3                   	ret    

00100bf1 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bf1:	55                   	push   %ebp
  100bf2:	89 e5                	mov    %esp,%ebp
  100bf4:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bf7:	c7 04 24 68 62 10 00 	movl   $0x106268,(%esp)
  100bfe:	e8 45 f7 ff ff       	call   100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c03:	c7 04 24 90 62 10 00 	movl   $0x106290,(%esp)
  100c0a:	e8 39 f7 ff ff       	call   100348 <cprintf>

    if (tf != NULL) {
  100c0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c13:	74 0b                	je     100c20 <kmonitor+0x2f>
        print_trapframe(tf);
  100c15:	8b 45 08             	mov    0x8(%ebp),%eax
  100c18:	89 04 24             	mov    %eax,(%esp)
  100c1b:	e8 67 0e 00 00       	call   101a87 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c20:	c7 04 24 b5 62 10 00 	movl   $0x1062b5,(%esp)
  100c27:	e8 13 f6 ff ff       	call   10023f <readline>
  100c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c33:	74 18                	je     100c4d <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c35:	8b 45 08             	mov    0x8(%ebp),%eax
  100c38:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c3f:	89 04 24             	mov    %eax,(%esp)
  100c42:	e8 f8 fe ff ff       	call   100b3f <runcmd>
  100c47:	85 c0                	test   %eax,%eax
  100c49:	79 02                	jns    100c4d <kmonitor+0x5c>
                break;
  100c4b:	eb 02                	jmp    100c4f <kmonitor+0x5e>
            }
        }
    }
  100c4d:	eb d1                	jmp    100c20 <kmonitor+0x2f>
}
  100c4f:	c9                   	leave  
  100c50:	c3                   	ret    

00100c51 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c51:	55                   	push   %ebp
  100c52:	89 e5                	mov    %esp,%ebp
  100c54:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c5e:	eb 3f                	jmp    100c9f <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c60:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c63:	89 d0                	mov    %edx,%eax
  100c65:	01 c0                	add    %eax,%eax
  100c67:	01 d0                	add    %edx,%eax
  100c69:	c1 e0 02             	shl    $0x2,%eax
  100c6c:	05 00 70 11 00       	add    $0x117000,%eax
  100c71:	8b 48 04             	mov    0x4(%eax),%ecx
  100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c77:	89 d0                	mov    %edx,%eax
  100c79:	01 c0                	add    %eax,%eax
  100c7b:	01 d0                	add    %edx,%eax
  100c7d:	c1 e0 02             	shl    $0x2,%eax
  100c80:	05 00 70 11 00       	add    $0x117000,%eax
  100c85:	8b 00                	mov    (%eax),%eax
  100c87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c8f:	c7 04 24 b9 62 10 00 	movl   $0x1062b9,(%esp)
  100c96:	e8 ad f6 ff ff       	call   100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ca2:	83 f8 02             	cmp    $0x2,%eax
  100ca5:	76 b9                	jbe    100c60 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cac:	c9                   	leave  
  100cad:	c3                   	ret    

00100cae <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cae:	55                   	push   %ebp
  100caf:	89 e5                	mov    %esp,%ebp
  100cb1:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cb4:	e8 c3 fb ff ff       	call   10087c <print_kerninfo>
    return 0;
  100cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cbe:	c9                   	leave  
  100cbf:	c3                   	ret    

00100cc0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cc0:	55                   	push   %ebp
  100cc1:	89 e5                	mov    %esp,%ebp
  100cc3:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cc6:	e8 fb fc ff ff       	call   1009c6 <print_stackframe>
    return 0;
  100ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cd0:	c9                   	leave  
  100cd1:	c3                   	ret    

00100cd2 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cd2:	55                   	push   %ebp
  100cd3:	89 e5                	mov    %esp,%ebp
  100cd5:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cd8:	a1 20 a4 11 00       	mov    0x11a420,%eax
  100cdd:	85 c0                	test   %eax,%eax
  100cdf:	74 02                	je     100ce3 <__panic+0x11>
        goto panic_dead;
  100ce1:	eb 59                	jmp    100d3c <__panic+0x6a>
    }
    is_panic = 1;
  100ce3:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  100cea:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100ced:	8d 45 14             	lea    0x14(%ebp),%eax
  100cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d01:	c7 04 24 c2 62 10 00 	movl   $0x1062c2,(%esp)
  100d08:	e8 3b f6 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d10:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d14:	8b 45 10             	mov    0x10(%ebp),%eax
  100d17:	89 04 24             	mov    %eax,(%esp)
  100d1a:	e8 f6 f5 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100d1f:	c7 04 24 de 62 10 00 	movl   $0x1062de,(%esp)
  100d26:	e8 1d f6 ff ff       	call   100348 <cprintf>
    
    cprintf("stack trackback:\n");
  100d2b:	c7 04 24 e0 62 10 00 	movl   $0x1062e0,(%esp)
  100d32:	e8 11 f6 ff ff       	call   100348 <cprintf>
    print_stackframe();
  100d37:	e8 8a fc ff ff       	call   1009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d3c:	e8 85 09 00 00       	call   1016c6 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d48:	e8 a4 fe ff ff       	call   100bf1 <kmonitor>
    }
  100d4d:	eb f2                	jmp    100d41 <__panic+0x6f>

00100d4f <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d4f:	55                   	push   %ebp
  100d50:	89 e5                	mov    %esp,%ebp
  100d52:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d55:	8d 45 14             	lea    0x14(%ebp),%eax
  100d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d62:	8b 45 08             	mov    0x8(%ebp),%eax
  100d65:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d69:	c7 04 24 f2 62 10 00 	movl   $0x1062f2,(%esp)
  100d70:	e8 d3 f5 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d7c:	8b 45 10             	mov    0x10(%ebp),%eax
  100d7f:	89 04 24             	mov    %eax,(%esp)
  100d82:	e8 8e f5 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100d87:	c7 04 24 de 62 10 00 	movl   $0x1062de,(%esp)
  100d8e:	e8 b5 f5 ff ff       	call   100348 <cprintf>
    va_end(ap);
}
  100d93:	c9                   	leave  
  100d94:	c3                   	ret    

00100d95 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d95:	55                   	push   %ebp
  100d96:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d98:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  100d9d:	5d                   	pop    %ebp
  100d9e:	c3                   	ret    

00100d9f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d9f:	55                   	push   %ebp
  100da0:	89 e5                	mov    %esp,%ebp
  100da2:	83 ec 28             	sub    $0x28,%esp
  100da5:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100dab:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100daf:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100db3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100db7:	ee                   	out    %al,(%dx)
  100db8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dbe:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dc2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dca:	ee                   	out    %al,(%dx)
  100dcb:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100dd1:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100dd5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dd9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100ddd:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dde:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100de5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100de8:	c7 04 24 10 63 10 00 	movl   $0x106310,(%esp)
  100def:	e8 54 f5 ff ff       	call   100348 <cprintf>
    pic_enable(IRQ_TIMER);
  100df4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dfb:	e8 24 09 00 00       	call   101724 <pic_enable>
}
  100e00:	c9                   	leave  
  100e01:	c3                   	ret    

00100e02 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e02:	55                   	push   %ebp
  100e03:	89 e5                	mov    %esp,%ebp
  100e05:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e08:	9c                   	pushf  
  100e09:	58                   	pop    %eax
  100e0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e10:	25 00 02 00 00       	and    $0x200,%eax
  100e15:	85 c0                	test   %eax,%eax
  100e17:	74 0c                	je     100e25 <__intr_save+0x23>
        intr_disable();
  100e19:	e8 a8 08 00 00       	call   1016c6 <intr_disable>
        return 1;
  100e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  100e23:	eb 05                	jmp    100e2a <__intr_save+0x28>
    }
    return 0;
  100e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e2a:	c9                   	leave  
  100e2b:	c3                   	ret    

00100e2c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e2c:	55                   	push   %ebp
  100e2d:	89 e5                	mov    %esp,%ebp
  100e2f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e36:	74 05                	je     100e3d <__intr_restore+0x11>
        intr_enable();
  100e38:	e8 83 08 00 00       	call   1016c0 <intr_enable>
    }
}
  100e3d:	c9                   	leave  
  100e3e:	c3                   	ret    

00100e3f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e3f:	55                   	push   %ebp
  100e40:	89 e5                	mov    %esp,%ebp
  100e42:	83 ec 10             	sub    $0x10,%esp
  100e45:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e4b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e4f:	89 c2                	mov    %eax,%edx
  100e51:	ec                   	in     (%dx),%al
  100e52:	88 45 fd             	mov    %al,-0x3(%ebp)
  100e55:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e5b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e5f:	89 c2                	mov    %eax,%edx
  100e61:	ec                   	in     (%dx),%al
  100e62:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e65:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e6f:	89 c2                	mov    %eax,%edx
  100e71:	ec                   	in     (%dx),%al
  100e72:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e75:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e7b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e7f:	89 c2                	mov    %eax,%edx
  100e81:	ec                   	in     (%dx),%al
  100e82:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e85:	c9                   	leave  
  100e86:	c3                   	ret    

00100e87 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e87:	55                   	push   %ebp
  100e88:	89 e5                	mov    %esp,%ebp
  100e8a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e8d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e97:	0f b7 00             	movzwl (%eax),%eax
  100e9a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea1:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea9:	0f b7 00             	movzwl (%eax),%eax
  100eac:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100eb0:	74 12                	je     100ec4 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100eb2:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100eb9:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100ec0:	b4 03 
  100ec2:	eb 13                	jmp    100ed7 <cga_init+0x50>
    } else {
        *cp = was;
  100ec4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ec7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ecb:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ece:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100ed5:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ed7:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ede:	0f b7 c0             	movzwl %ax,%eax
  100ee1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100ee5:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ee9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100eed:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100ef1:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ef2:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ef9:	83 c0 01             	add    $0x1,%eax
  100efc:	0f b7 c0             	movzwl %ax,%eax
  100eff:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f03:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f07:	89 c2                	mov    %eax,%edx
  100f09:	ec                   	in     (%dx),%al
  100f0a:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f0d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f11:	0f b6 c0             	movzbl %al,%eax
  100f14:	c1 e0 08             	shl    $0x8,%eax
  100f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f1a:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f21:	0f b7 c0             	movzwl %ax,%eax
  100f24:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100f28:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f2c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f30:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f34:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f35:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f3c:	83 c0 01             	add    $0x1,%eax
  100f3f:	0f b7 c0             	movzwl %ax,%eax
  100f42:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f46:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f4a:	89 c2                	mov    %eax,%edx
  100f4c:	ec                   	in     (%dx),%al
  100f4d:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100f50:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f54:	0f b6 c0             	movzbl %al,%eax
  100f57:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f5d:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f65:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f6b:	c9                   	leave  
  100f6c:	c3                   	ret    

00100f6d <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f6d:	55                   	push   %ebp
  100f6e:	89 e5                	mov    %esp,%ebp
  100f70:	83 ec 48             	sub    $0x48,%esp
  100f73:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f79:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f7d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f81:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f85:	ee                   	out    %al,(%dx)
  100f86:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f8c:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f90:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f94:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f98:	ee                   	out    %al,(%dx)
  100f99:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f9f:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100fa3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100fa7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fab:	ee                   	out    %al,(%dx)
  100fac:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fb2:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100fb6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fbe:	ee                   	out    %al,(%dx)
  100fbf:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100fc5:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100fc9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fcd:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fd1:	ee                   	out    %al,(%dx)
  100fd2:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100fd8:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100fdc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fe0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fe4:	ee                   	out    %al,(%dx)
  100fe5:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100feb:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100fef:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100ff3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100ff7:	ee                   	out    %al,(%dx)
  100ff8:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ffe:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  101002:	89 c2                	mov    %eax,%edx
  101004:	ec                   	in     (%dx),%al
  101005:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  101008:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  10100c:	3c ff                	cmp    $0xff,%al
  10100e:	0f 95 c0             	setne  %al
  101011:	0f b6 c0             	movzbl %al,%eax
  101014:	a3 48 a4 11 00       	mov    %eax,0x11a448
  101019:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10101f:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101023:	89 c2                	mov    %eax,%edx
  101025:	ec                   	in     (%dx),%al
  101026:	88 45 d5             	mov    %al,-0x2b(%ebp)
  101029:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  10102f:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  101033:	89 c2                	mov    %eax,%edx
  101035:	ec                   	in     (%dx),%al
  101036:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101039:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10103e:	85 c0                	test   %eax,%eax
  101040:	74 0c                	je     10104e <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  101042:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101049:	e8 d6 06 00 00       	call   101724 <pic_enable>
    }
}
  10104e:	c9                   	leave  
  10104f:	c3                   	ret    

00101050 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101050:	55                   	push   %ebp
  101051:	89 e5                	mov    %esp,%ebp
  101053:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101056:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10105d:	eb 09                	jmp    101068 <lpt_putc_sub+0x18>
        delay();
  10105f:	e8 db fd ff ff       	call   100e3f <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101064:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101068:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10106e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101072:	89 c2                	mov    %eax,%edx
  101074:	ec                   	in     (%dx),%al
  101075:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101078:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10107c:	84 c0                	test   %al,%al
  10107e:	78 09                	js     101089 <lpt_putc_sub+0x39>
  101080:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101087:	7e d6                	jle    10105f <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101089:	8b 45 08             	mov    0x8(%ebp),%eax
  10108c:	0f b6 c0             	movzbl %al,%eax
  10108f:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  101095:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101098:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10109c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010a0:	ee                   	out    %al,(%dx)
  1010a1:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010a7:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010ab:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010af:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010b3:	ee                   	out    %al,(%dx)
  1010b4:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  1010ba:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  1010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010c6:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010c7:	c9                   	leave  
  1010c8:	c3                   	ret    

001010c9 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010c9:	55                   	push   %ebp
  1010ca:	89 e5                	mov    %esp,%ebp
  1010cc:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010cf:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010d3:	74 0d                	je     1010e2 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1010d8:	89 04 24             	mov    %eax,(%esp)
  1010db:	e8 70 ff ff ff       	call   101050 <lpt_putc_sub>
  1010e0:	eb 24                	jmp    101106 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  1010e2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010e9:	e8 62 ff ff ff       	call   101050 <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010f5:	e8 56 ff ff ff       	call   101050 <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101101:	e8 4a ff ff ff       	call   101050 <lpt_putc_sub>
    }
}
  101106:	c9                   	leave  
  101107:	c3                   	ret    

00101108 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101108:	55                   	push   %ebp
  101109:	89 e5                	mov    %esp,%ebp
  10110b:	53                   	push   %ebx
  10110c:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  10110f:	8b 45 08             	mov    0x8(%ebp),%eax
  101112:	b0 00                	mov    $0x0,%al
  101114:	85 c0                	test   %eax,%eax
  101116:	75 07                	jne    10111f <cga_putc+0x17>
        c |= 0x0700;
  101118:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10111f:	8b 45 08             	mov    0x8(%ebp),%eax
  101122:	0f b6 c0             	movzbl %al,%eax
  101125:	83 f8 0a             	cmp    $0xa,%eax
  101128:	74 4c                	je     101176 <cga_putc+0x6e>
  10112a:	83 f8 0d             	cmp    $0xd,%eax
  10112d:	74 57                	je     101186 <cga_putc+0x7e>
  10112f:	83 f8 08             	cmp    $0x8,%eax
  101132:	0f 85 88 00 00 00    	jne    1011c0 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  101138:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10113f:	66 85 c0             	test   %ax,%ax
  101142:	74 30                	je     101174 <cga_putc+0x6c>
            crt_pos --;
  101144:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10114b:	83 e8 01             	sub    $0x1,%eax
  10114e:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101154:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101159:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  101160:	0f b7 d2             	movzwl %dx,%edx
  101163:	01 d2                	add    %edx,%edx
  101165:	01 c2                	add    %eax,%edx
  101167:	8b 45 08             	mov    0x8(%ebp),%eax
  10116a:	b0 00                	mov    $0x0,%al
  10116c:	83 c8 20             	or     $0x20,%eax
  10116f:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101172:	eb 72                	jmp    1011e6 <cga_putc+0xde>
  101174:	eb 70                	jmp    1011e6 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101176:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10117d:	83 c0 50             	add    $0x50,%eax
  101180:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101186:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  10118d:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  101194:	0f b7 c1             	movzwl %cx,%eax
  101197:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  10119d:	c1 e8 10             	shr    $0x10,%eax
  1011a0:	89 c2                	mov    %eax,%edx
  1011a2:	66 c1 ea 06          	shr    $0x6,%dx
  1011a6:	89 d0                	mov    %edx,%eax
  1011a8:	c1 e0 02             	shl    $0x2,%eax
  1011ab:	01 d0                	add    %edx,%eax
  1011ad:	c1 e0 04             	shl    $0x4,%eax
  1011b0:	29 c1                	sub    %eax,%ecx
  1011b2:	89 ca                	mov    %ecx,%edx
  1011b4:	89 d8                	mov    %ebx,%eax
  1011b6:	29 d0                	sub    %edx,%eax
  1011b8:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011be:	eb 26                	jmp    1011e6 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011c0:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011c6:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011cd:	8d 50 01             	lea    0x1(%eax),%edx
  1011d0:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011d7:	0f b7 c0             	movzwl %ax,%eax
  1011da:	01 c0                	add    %eax,%eax
  1011dc:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011df:	8b 45 08             	mov    0x8(%ebp),%eax
  1011e2:	66 89 02             	mov    %ax,(%edx)
        break;
  1011e5:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011e6:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011ed:	66 3d cf 07          	cmp    $0x7cf,%ax
  1011f1:	76 5b                	jbe    10124e <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011f3:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011f8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011fe:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101203:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10120a:	00 
  10120b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10120f:	89 04 24             	mov    %eax,(%esp)
  101212:	e8 8e 4c 00 00       	call   105ea5 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101217:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10121e:	eb 15                	jmp    101235 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  101220:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101225:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101228:	01 d2                	add    %edx,%edx
  10122a:	01 d0                	add    %edx,%eax
  10122c:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101235:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10123c:	7e e2                	jle    101220 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  10123e:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101245:	83 e8 50             	sub    $0x50,%eax
  101248:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10124e:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101255:	0f b7 c0             	movzwl %ax,%eax
  101258:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  10125c:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  101260:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101264:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101268:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101269:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101270:	66 c1 e8 08          	shr    $0x8,%ax
  101274:	0f b6 c0             	movzbl %al,%eax
  101277:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  10127e:	83 c2 01             	add    $0x1,%edx
  101281:	0f b7 d2             	movzwl %dx,%edx
  101284:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  101288:	88 45 ed             	mov    %al,-0x13(%ebp)
  10128b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10128f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101293:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101294:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  10129b:	0f b7 c0             	movzwl %ax,%eax
  10129e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  1012a2:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  1012a6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012aa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012af:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012b6:	0f b6 c0             	movzbl %al,%eax
  1012b9:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012c0:	83 c2 01             	add    $0x1,%edx
  1012c3:	0f b7 d2             	movzwl %dx,%edx
  1012c6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  1012ca:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1012cd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012d1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012d5:	ee                   	out    %al,(%dx)
}
  1012d6:	83 c4 34             	add    $0x34,%esp
  1012d9:	5b                   	pop    %ebx
  1012da:	5d                   	pop    %ebp
  1012db:	c3                   	ret    

001012dc <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012dc:	55                   	push   %ebp
  1012dd:	89 e5                	mov    %esp,%ebp
  1012df:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012e9:	eb 09                	jmp    1012f4 <serial_putc_sub+0x18>
        delay();
  1012eb:	e8 4f fb ff ff       	call   100e3f <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012f0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1012f4:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012fa:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012fe:	89 c2                	mov    %eax,%edx
  101300:	ec                   	in     (%dx),%al
  101301:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101304:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101308:	0f b6 c0             	movzbl %al,%eax
  10130b:	83 e0 20             	and    $0x20,%eax
  10130e:	85 c0                	test   %eax,%eax
  101310:	75 09                	jne    10131b <serial_putc_sub+0x3f>
  101312:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101319:	7e d0                	jle    1012eb <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  10131b:	8b 45 08             	mov    0x8(%ebp),%eax
  10131e:	0f b6 c0             	movzbl %al,%eax
  101321:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101327:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10132a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10132e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101332:	ee                   	out    %al,(%dx)
}
  101333:	c9                   	leave  
  101334:	c3                   	ret    

00101335 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101335:	55                   	push   %ebp
  101336:	89 e5                	mov    %esp,%ebp
  101338:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10133b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10133f:	74 0d                	je     10134e <serial_putc+0x19>
        serial_putc_sub(c);
  101341:	8b 45 08             	mov    0x8(%ebp),%eax
  101344:	89 04 24             	mov    %eax,(%esp)
  101347:	e8 90 ff ff ff       	call   1012dc <serial_putc_sub>
  10134c:	eb 24                	jmp    101372 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  10134e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101355:	e8 82 ff ff ff       	call   1012dc <serial_putc_sub>
        serial_putc_sub(' ');
  10135a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101361:	e8 76 ff ff ff       	call   1012dc <serial_putc_sub>
        serial_putc_sub('\b');
  101366:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10136d:	e8 6a ff ff ff       	call   1012dc <serial_putc_sub>
    }
}
  101372:	c9                   	leave  
  101373:	c3                   	ret    

00101374 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101374:	55                   	push   %ebp
  101375:	89 e5                	mov    %esp,%ebp
  101377:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10137a:	eb 33                	jmp    1013af <cons_intr+0x3b>
        if (c != 0) {
  10137c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101380:	74 2d                	je     1013af <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101382:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101387:	8d 50 01             	lea    0x1(%eax),%edx
  10138a:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  101390:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101393:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101399:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10139e:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013a3:	75 0a                	jne    1013af <cons_intr+0x3b>
                cons.wpos = 0;
  1013a5:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  1013ac:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013af:	8b 45 08             	mov    0x8(%ebp),%eax
  1013b2:	ff d0                	call   *%eax
  1013b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013b7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013bb:	75 bf                	jne    10137c <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013bd:	c9                   	leave  
  1013be:	c3                   	ret    

001013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013bf:	55                   	push   %ebp
  1013c0:	89 e5                	mov    %esp,%ebp
  1013c2:	83 ec 10             	sub    $0x10,%esp
  1013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013cf:	89 c2                	mov    %eax,%edx
  1013d1:	ec                   	in     (%dx),%al
  1013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013d9:	0f b6 c0             	movzbl %al,%eax
  1013dc:	83 e0 01             	and    $0x1,%eax
  1013df:	85 c0                	test   %eax,%eax
  1013e1:	75 07                	jne    1013ea <serial_proc_data+0x2b>
        return -1;
  1013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013e8:	eb 2a                	jmp    101414 <serial_proc_data+0x55>
  1013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013f4:	89 c2                	mov    %eax,%edx
  1013f6:	ec                   	in     (%dx),%al
  1013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013fe:	0f b6 c0             	movzbl %al,%eax
  101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101408:	75 07                	jne    101411 <serial_proc_data+0x52>
        c = '\b';
  10140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101414:	c9                   	leave  
  101415:	c3                   	ret    

00101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101416:	55                   	push   %ebp
  101417:	89 e5                	mov    %esp,%ebp
  101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10141c:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101421:	85 c0                	test   %eax,%eax
  101423:	74 0c                	je     101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101425:	c7 04 24 bf 13 10 00 	movl   $0x1013bf,(%esp)
  10142c:	e8 43 ff ff ff       	call   101374 <cons_intr>
    }
}
  101431:	c9                   	leave  
  101432:	c3                   	ret    

00101433 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101433:	55                   	push   %ebp
  101434:	89 e5                	mov    %esp,%ebp
  101436:	83 ec 38             	sub    $0x38,%esp
  101439:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10143f:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101443:	89 c2                	mov    %eax,%edx
  101445:	ec                   	in     (%dx),%al
  101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10144d:	0f b6 c0             	movzbl %al,%eax
  101450:	83 e0 01             	and    $0x1,%eax
  101453:	85 c0                	test   %eax,%eax
  101455:	75 0a                	jne    101461 <kbd_proc_data+0x2e>
        return -1;
  101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10145c:	e9 59 01 00 00       	jmp    1015ba <kbd_proc_data+0x187>
  101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101467:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10146b:	89 c2                	mov    %eax,%edx
  10146d:	ec                   	in     (%dx),%al
  10146e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101471:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101475:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101478:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10147c:	75 17                	jne    101495 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  10147e:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101483:	83 c8 40             	or     $0x40,%eax
  101486:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  10148b:	b8 00 00 00 00       	mov    $0x0,%eax
  101490:	e9 25 01 00 00       	jmp    1015ba <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101495:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101499:	84 c0                	test   %al,%al
  10149b:	79 47                	jns    1014e4 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10149d:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014a2:	83 e0 40             	and    $0x40,%eax
  1014a5:	85 c0                	test   %eax,%eax
  1014a7:	75 09                	jne    1014b2 <kbd_proc_data+0x7f>
  1014a9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ad:	83 e0 7f             	and    $0x7f,%eax
  1014b0:	eb 04                	jmp    1014b6 <kbd_proc_data+0x83>
  1014b2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b6:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014b9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bd:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014c4:	83 c8 40             	or     $0x40,%eax
  1014c7:	0f b6 c0             	movzbl %al,%eax
  1014ca:	f7 d0                	not    %eax
  1014cc:	89 c2                	mov    %eax,%edx
  1014ce:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014d3:	21 d0                	and    %edx,%eax
  1014d5:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014da:	b8 00 00 00 00       	mov    $0x0,%eax
  1014df:	e9 d6 00 00 00       	jmp    1015ba <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1014e4:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014e9:	83 e0 40             	and    $0x40,%eax
  1014ec:	85 c0                	test   %eax,%eax
  1014ee:	74 11                	je     101501 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014f0:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014f4:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014f9:	83 e0 bf             	and    $0xffffffbf,%eax
  1014fc:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  101501:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101505:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  10150c:	0f b6 d0             	movzbl %al,%edx
  10150f:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101514:	09 d0                	or     %edx,%eax
  101516:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  10151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151f:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101526:	0f b6 d0             	movzbl %al,%edx
  101529:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10152e:	31 d0                	xor    %edx,%eax
  101530:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  101535:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10153a:	83 e0 03             	and    $0x3,%eax
  10153d:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  101544:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101548:	01 d0                	add    %edx,%eax
  10154a:	0f b6 00             	movzbl (%eax),%eax
  10154d:	0f b6 c0             	movzbl %al,%eax
  101550:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101553:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101558:	83 e0 08             	and    $0x8,%eax
  10155b:	85 c0                	test   %eax,%eax
  10155d:	74 22                	je     101581 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  10155f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101563:	7e 0c                	jle    101571 <kbd_proc_data+0x13e>
  101565:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101569:	7f 06                	jg     101571 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  10156b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10156f:	eb 10                	jmp    101581 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101571:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101575:	7e 0a                	jle    101581 <kbd_proc_data+0x14e>
  101577:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10157b:	7f 04                	jg     101581 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  10157d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101581:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101586:	f7 d0                	not    %eax
  101588:	83 e0 06             	and    $0x6,%eax
  10158b:	85 c0                	test   %eax,%eax
  10158d:	75 28                	jne    1015b7 <kbd_proc_data+0x184>
  10158f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101596:	75 1f                	jne    1015b7 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  101598:	c7 04 24 2b 63 10 00 	movl   $0x10632b,(%esp)
  10159f:	e8 a4 ed ff ff       	call   100348 <cprintf>
  1015a4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015aa:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015ae:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015b2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1015b6:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015ba:	c9                   	leave  
  1015bb:	c3                   	ret    

001015bc <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015bc:	55                   	push   %ebp
  1015bd:	89 e5                	mov    %esp,%ebp
  1015bf:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015c2:	c7 04 24 33 14 10 00 	movl   $0x101433,(%esp)
  1015c9:	e8 a6 fd ff ff       	call   101374 <cons_intr>
}
  1015ce:	c9                   	leave  
  1015cf:	c3                   	ret    

001015d0 <kbd_init>:

static void
kbd_init(void) {
  1015d0:	55                   	push   %ebp
  1015d1:	89 e5                	mov    %esp,%ebp
  1015d3:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015d6:	e8 e1 ff ff ff       	call   1015bc <kbd_intr>
    pic_enable(IRQ_KBD);
  1015db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015e2:	e8 3d 01 00 00       	call   101724 <pic_enable>
}
  1015e7:	c9                   	leave  
  1015e8:	c3                   	ret    

001015e9 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015e9:	55                   	push   %ebp
  1015ea:	89 e5                	mov    %esp,%ebp
  1015ec:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015ef:	e8 93 f8 ff ff       	call   100e87 <cga_init>
    serial_init();
  1015f4:	e8 74 f9 ff ff       	call   100f6d <serial_init>
    kbd_init();
  1015f9:	e8 d2 ff ff ff       	call   1015d0 <kbd_init>
    if (!serial_exists) {
  1015fe:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101603:	85 c0                	test   %eax,%eax
  101605:	75 0c                	jne    101613 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101607:	c7 04 24 37 63 10 00 	movl   $0x106337,(%esp)
  10160e:	e8 35 ed ff ff       	call   100348 <cprintf>
    }
}
  101613:	c9                   	leave  
  101614:	c3                   	ret    

00101615 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101615:	55                   	push   %ebp
  101616:	89 e5                	mov    %esp,%ebp
  101618:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10161b:	e8 e2 f7 ff ff       	call   100e02 <__intr_save>
  101620:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101623:	8b 45 08             	mov    0x8(%ebp),%eax
  101626:	89 04 24             	mov    %eax,(%esp)
  101629:	e8 9b fa ff ff       	call   1010c9 <lpt_putc>
        cga_putc(c);
  10162e:	8b 45 08             	mov    0x8(%ebp),%eax
  101631:	89 04 24             	mov    %eax,(%esp)
  101634:	e8 cf fa ff ff       	call   101108 <cga_putc>
        serial_putc(c);
  101639:	8b 45 08             	mov    0x8(%ebp),%eax
  10163c:	89 04 24             	mov    %eax,(%esp)
  10163f:	e8 f1 fc ff ff       	call   101335 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101644:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101647:	89 04 24             	mov    %eax,(%esp)
  10164a:	e8 dd f7 ff ff       	call   100e2c <__intr_restore>
}
  10164f:	c9                   	leave  
  101650:	c3                   	ret    

00101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101651:	55                   	push   %ebp
  101652:	89 e5                	mov    %esp,%ebp
  101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10165e:	e8 9f f7 ff ff       	call   100e02 <__intr_save>
  101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101666:	e8 ab fd ff ff       	call   101416 <serial_intr>
        kbd_intr();
  10166b:	e8 4c ff ff ff       	call   1015bc <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101670:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  101676:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10167b:	39 c2                	cmp    %eax,%edx
  10167d:	74 31                	je     1016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10167f:	a1 60 a6 11 00       	mov    0x11a660,%eax
  101684:	8d 50 01             	lea    0x1(%eax),%edx
  101687:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  10168d:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  101694:	0f b6 c0             	movzbl %al,%eax
  101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  10169a:	a1 60 a6 11 00       	mov    0x11a660,%eax
  10169f:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016a4:	75 0a                	jne    1016b0 <cons_getc+0x5f>
                cons.rpos = 0;
  1016a6:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016b3:	89 04 24             	mov    %eax,(%esp)
  1016b6:	e8 71 f7 ff ff       	call   100e2c <__intr_restore>
    return c;
  1016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016be:	c9                   	leave  
  1016bf:	c3                   	ret    

001016c0 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016c0:	55                   	push   %ebp
  1016c1:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016c3:	fb                   	sti    
    sti();
}
  1016c4:	5d                   	pop    %ebp
  1016c5:	c3                   	ret    

001016c6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016c6:	55                   	push   %ebp
  1016c7:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  1016c9:	fa                   	cli    
    cli();
}
  1016ca:	5d                   	pop    %ebp
  1016cb:	c3                   	ret    

001016cc <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016cc:	55                   	push   %ebp
  1016cd:	89 e5                	mov    %esp,%ebp
  1016cf:	83 ec 14             	sub    $0x14,%esp
  1016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1016d5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016d9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016dd:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016e3:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  1016e8:	85 c0                	test   %eax,%eax
  1016ea:	74 36                	je     101722 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016f0:	0f b6 c0             	movzbl %al,%eax
  1016f3:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016f9:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1016fc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101700:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101704:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101705:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101709:	66 c1 e8 08          	shr    $0x8,%ax
  10170d:	0f b6 c0             	movzbl %al,%eax
  101710:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101716:	88 45 f9             	mov    %al,-0x7(%ebp)
  101719:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10171d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101721:	ee                   	out    %al,(%dx)
    }
}
  101722:	c9                   	leave  
  101723:	c3                   	ret    

00101724 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101724:	55                   	push   %ebp
  101725:	89 e5                	mov    %esp,%ebp
  101727:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10172a:	8b 45 08             	mov    0x8(%ebp),%eax
  10172d:	ba 01 00 00 00       	mov    $0x1,%edx
  101732:	89 c1                	mov    %eax,%ecx
  101734:	d3 e2                	shl    %cl,%edx
  101736:	89 d0                	mov    %edx,%eax
  101738:	f7 d0                	not    %eax
  10173a:	89 c2                	mov    %eax,%edx
  10173c:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101743:	21 d0                	and    %edx,%eax
  101745:	0f b7 c0             	movzwl %ax,%eax
  101748:	89 04 24             	mov    %eax,(%esp)
  10174b:	e8 7c ff ff ff       	call   1016cc <pic_setmask>
}
  101750:	c9                   	leave  
  101751:	c3                   	ret    

00101752 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101752:	55                   	push   %ebp
  101753:	89 e5                	mov    %esp,%ebp
  101755:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101758:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  10175f:	00 00 00 
  101762:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101768:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  10176c:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101770:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101774:	ee                   	out    %al,(%dx)
  101775:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10177b:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  10177f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101783:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101787:	ee                   	out    %al,(%dx)
  101788:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10178e:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  101792:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101796:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10179a:	ee                   	out    %al,(%dx)
  10179b:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  1017a1:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  1017a5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1017a9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017ad:	ee                   	out    %al,(%dx)
  1017ae:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1017b4:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1017b8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1017bc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017c0:	ee                   	out    %al,(%dx)
  1017c1:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  1017c7:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  1017cb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1017cf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017d3:	ee                   	out    %al,(%dx)
  1017d4:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017da:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  1017de:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017e2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017e6:	ee                   	out    %al,(%dx)
  1017e7:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  1017ed:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  1017f1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017f5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017f9:	ee                   	out    %al,(%dx)
  1017fa:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  101800:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  101804:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101808:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  10180c:	ee                   	out    %al,(%dx)
  10180d:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101813:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  101817:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10181b:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10181f:	ee                   	out    %al,(%dx)
  101820:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  101826:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  10182a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10182e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101832:	ee                   	out    %al,(%dx)
  101833:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101839:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  10183d:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101841:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101845:	ee                   	out    %al,(%dx)
  101846:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  10184c:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  101850:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101854:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101858:	ee                   	out    %al,(%dx)
  101859:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  10185f:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  101863:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101867:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  10186b:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10186c:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101873:	66 83 f8 ff          	cmp    $0xffff,%ax
  101877:	74 12                	je     10188b <pic_init+0x139>
        pic_setmask(irq_mask);
  101879:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101880:	0f b7 c0             	movzwl %ax,%eax
  101883:	89 04 24             	mov    %eax,(%esp)
  101886:	e8 41 fe ff ff       	call   1016cc <pic_setmask>
    }
}
  10188b:	c9                   	leave  
  10188c:	c3                   	ret    

0010188d <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
  10188d:	55                   	push   %ebp
  10188e:	89 e5                	mov    %esp,%ebp
  101890:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101893:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10189a:	00 
  10189b:	c7 04 24 60 63 10 00 	movl   $0x106360,(%esp)
  1018a2:	e8 a1 ea ff ff       	call   100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  1018a7:	c7 04 24 6a 63 10 00 	movl   $0x10636a,(%esp)
  1018ae:	e8 95 ea ff ff       	call   100348 <cprintf>
    panic("EOT: kernel seems ok.");
  1018b3:	c7 44 24 08 78 63 10 	movl   $0x106378,0x8(%esp)
  1018ba:	00 
  1018bb:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  1018c2:	00 
  1018c3:	c7 04 24 8e 63 10 00 	movl   $0x10638e,(%esp)
  1018ca:	e8 03 f4 ff ff       	call   100cd2 <__panic>

001018cf <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018cf:	55                   	push   %ebp
  1018d0:	89 e5                	mov    %esp,%ebp
  1018d2:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1018d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018dc:	e9 c3 00 00 00       	jmp    1019a4 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e4:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018eb:	89 c2                	mov    %eax,%edx
  1018ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f0:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  1018f7:	00 
  1018f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018fb:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  101902:	00 08 00 
  101905:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101908:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  10190f:	00 
  101910:	83 e2 e0             	and    $0xffffffe0,%edx
  101913:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  10191a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10191d:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  101924:	00 
  101925:	83 e2 1f             	and    $0x1f,%edx
  101928:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  10192f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101932:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101939:	00 
  10193a:	83 e2 f0             	and    $0xfffffff0,%edx
  10193d:	83 ca 0e             	or     $0xe,%edx
  101940:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101947:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10194a:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101951:	00 
  101952:	83 e2 ef             	and    $0xffffffef,%edx
  101955:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10195c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10195f:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101966:	00 
  101967:	83 e2 9f             	and    $0xffffff9f,%edx
  10196a:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101971:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101974:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10197b:	00 
  10197c:	83 ca 80             	or     $0xffffff80,%edx
  10197f:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101986:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101989:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  101990:	c1 e8 10             	shr    $0x10,%eax
  101993:	89 c2                	mov    %eax,%edx
  101995:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101998:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  10199f:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1019a0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1019a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a7:	3d ff 00 00 00       	cmp    $0xff,%eax
  1019ac:	0f 86 2f ff ff ff    	jbe    1018e1 <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  1019b2:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  1019b7:	66 a3 48 aa 11 00    	mov    %ax,0x11aa48
  1019bd:	66 c7 05 4a aa 11 00 	movw   $0x8,0x11aa4a
  1019c4:	08 00 
  1019c6:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019cd:	83 e0 e0             	and    $0xffffffe0,%eax
  1019d0:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019d5:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019dc:	83 e0 1f             	and    $0x1f,%eax
  1019df:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019e4:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019eb:	83 e0 f0             	and    $0xfffffff0,%eax
  1019ee:	83 c8 0e             	or     $0xe,%eax
  1019f1:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019f6:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019fd:	83 e0 ef             	and    $0xffffffef,%eax
  101a00:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a05:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a0c:	83 c8 60             	or     $0x60,%eax
  101a0f:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a14:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a1b:	83 c8 80             	or     $0xffffff80,%eax
  101a1e:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a23:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  101a28:	c1 e8 10             	shr    $0x10,%eax
  101a2b:	66 a3 4e aa 11 00    	mov    %ax,0x11aa4e
  101a31:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a38:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a3b:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idt_pd);
}
  101a3e:	c9                   	leave  
  101a3f:	c3                   	ret    

00101a40 <trapname>:

static const char *
trapname(int trapno) {
  101a40:	55                   	push   %ebp
  101a41:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a43:	8b 45 08             	mov    0x8(%ebp),%eax
  101a46:	83 f8 13             	cmp    $0x13,%eax
  101a49:	77 0c                	ja     101a57 <trapname+0x17>
        return excnames[trapno];
  101a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4e:	8b 04 85 e0 66 10 00 	mov    0x1066e0(,%eax,4),%eax
  101a55:	eb 18                	jmp    101a6f <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a57:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a5b:	7e 0d                	jle    101a6a <trapname+0x2a>
  101a5d:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a61:	7f 07                	jg     101a6a <trapname+0x2a>
        return "Hardware Interrupt";
  101a63:	b8 9f 63 10 00       	mov    $0x10639f,%eax
  101a68:	eb 05                	jmp    101a6f <trapname+0x2f>
    }
    return "(unknown trap)";
  101a6a:	b8 b2 63 10 00       	mov    $0x1063b2,%eax
}
  101a6f:	5d                   	pop    %ebp
  101a70:	c3                   	ret    

00101a71 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a71:	55                   	push   %ebp
  101a72:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a74:	8b 45 08             	mov    0x8(%ebp),%eax
  101a77:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a7b:	66 83 f8 08          	cmp    $0x8,%ax
  101a7f:	0f 94 c0             	sete   %al
  101a82:	0f b6 c0             	movzbl %al,%eax
}
  101a85:	5d                   	pop    %ebp
  101a86:	c3                   	ret    

00101a87 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a87:	55                   	push   %ebp
  101a88:	89 e5                	mov    %esp,%ebp
  101a8a:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a90:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a94:	c7 04 24 f3 63 10 00 	movl   $0x1063f3,(%esp)
  101a9b:	e8 a8 e8 ff ff       	call   100348 <cprintf>
    print_regs(&tf->tf_regs);
  101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa3:	89 04 24             	mov    %eax,(%esp)
  101aa6:	e8 a1 01 00 00       	call   101c4c <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101aab:	8b 45 08             	mov    0x8(%ebp),%eax
  101aae:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101ab2:	0f b7 c0             	movzwl %ax,%eax
  101ab5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab9:	c7 04 24 04 64 10 00 	movl   $0x106404,(%esp)
  101ac0:	e8 83 e8 ff ff       	call   100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac8:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101acc:	0f b7 c0             	movzwl %ax,%eax
  101acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad3:	c7 04 24 17 64 10 00 	movl   $0x106417,(%esp)
  101ada:	e8 69 e8 ff ff       	call   100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101adf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae2:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ae6:	0f b7 c0             	movzwl %ax,%eax
  101ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aed:	c7 04 24 2a 64 10 00 	movl   $0x10642a,(%esp)
  101af4:	e8 4f e8 ff ff       	call   100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101af9:	8b 45 08             	mov    0x8(%ebp),%eax
  101afc:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b00:	0f b7 c0             	movzwl %ax,%eax
  101b03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b07:	c7 04 24 3d 64 10 00 	movl   $0x10643d,(%esp)
  101b0e:	e8 35 e8 ff ff       	call   100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b13:	8b 45 08             	mov    0x8(%ebp),%eax
  101b16:	8b 40 30             	mov    0x30(%eax),%eax
  101b19:	89 04 24             	mov    %eax,(%esp)
  101b1c:	e8 1f ff ff ff       	call   101a40 <trapname>
  101b21:	8b 55 08             	mov    0x8(%ebp),%edx
  101b24:	8b 52 30             	mov    0x30(%edx),%edx
  101b27:	89 44 24 08          	mov    %eax,0x8(%esp)
  101b2b:	89 54 24 04          	mov    %edx,0x4(%esp)
  101b2f:	c7 04 24 50 64 10 00 	movl   $0x106450,(%esp)
  101b36:	e8 0d e8 ff ff       	call   100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b3e:	8b 40 34             	mov    0x34(%eax),%eax
  101b41:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b45:	c7 04 24 62 64 10 00 	movl   $0x106462,(%esp)
  101b4c:	e8 f7 e7 ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b51:	8b 45 08             	mov    0x8(%ebp),%eax
  101b54:	8b 40 38             	mov    0x38(%eax),%eax
  101b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b5b:	c7 04 24 71 64 10 00 	movl   $0x106471,(%esp)
  101b62:	e8 e1 e7 ff ff       	call   100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b67:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b6e:	0f b7 c0             	movzwl %ax,%eax
  101b71:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b75:	c7 04 24 80 64 10 00 	movl   $0x106480,(%esp)
  101b7c:	e8 c7 e7 ff ff       	call   100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b81:	8b 45 08             	mov    0x8(%ebp),%eax
  101b84:	8b 40 40             	mov    0x40(%eax),%eax
  101b87:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b8b:	c7 04 24 93 64 10 00 	movl   $0x106493,(%esp)
  101b92:	e8 b1 e7 ff ff       	call   100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b9e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101ba5:	eb 3e                	jmp    101be5 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  101baa:	8b 50 40             	mov    0x40(%eax),%edx
  101bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101bb0:	21 d0                	and    %edx,%eax
  101bb2:	85 c0                	test   %eax,%eax
  101bb4:	74 28                	je     101bde <print_trapframe+0x157>
  101bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bb9:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101bc0:	85 c0                	test   %eax,%eax
  101bc2:	74 1a                	je     101bde <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bc7:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd2:	c7 04 24 a2 64 10 00 	movl   $0x1064a2,(%esp)
  101bd9:	e8 6a e7 ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bde:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101be2:	d1 65 f0             	shll   -0x10(%ebp)
  101be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101be8:	83 f8 17             	cmp    $0x17,%eax
  101beb:	76 ba                	jbe    101ba7 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bed:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf0:	8b 40 40             	mov    0x40(%eax),%eax
  101bf3:	25 00 30 00 00       	and    $0x3000,%eax
  101bf8:	c1 e8 0c             	shr    $0xc,%eax
  101bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bff:	c7 04 24 a6 64 10 00 	movl   $0x1064a6,(%esp)
  101c06:	e8 3d e7 ff ff       	call   100348 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0e:	89 04 24             	mov    %eax,(%esp)
  101c11:	e8 5b fe ff ff       	call   101a71 <trap_in_kernel>
  101c16:	85 c0                	test   %eax,%eax
  101c18:	75 30                	jne    101c4a <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1d:	8b 40 44             	mov    0x44(%eax),%eax
  101c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c24:	c7 04 24 af 64 10 00 	movl   $0x1064af,(%esp)
  101c2b:	e8 18 e7 ff ff       	call   100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c30:	8b 45 08             	mov    0x8(%ebp),%eax
  101c33:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c37:	0f b7 c0             	movzwl %ax,%eax
  101c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3e:	c7 04 24 be 64 10 00 	movl   $0x1064be,(%esp)
  101c45:	e8 fe e6 ff ff       	call   100348 <cprintf>
    }
}
  101c4a:	c9                   	leave  
  101c4b:	c3                   	ret    

00101c4c <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c4c:	55                   	push   %ebp
  101c4d:	89 e5                	mov    %esp,%ebp
  101c4f:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c52:	8b 45 08             	mov    0x8(%ebp),%eax
  101c55:	8b 00                	mov    (%eax),%eax
  101c57:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5b:	c7 04 24 d1 64 10 00 	movl   $0x1064d1,(%esp)
  101c62:	e8 e1 e6 ff ff       	call   100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c67:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6a:	8b 40 04             	mov    0x4(%eax),%eax
  101c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c71:	c7 04 24 e0 64 10 00 	movl   $0x1064e0,(%esp)
  101c78:	e8 cb e6 ff ff       	call   100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  101c80:	8b 40 08             	mov    0x8(%eax),%eax
  101c83:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c87:	c7 04 24 ef 64 10 00 	movl   $0x1064ef,(%esp)
  101c8e:	e8 b5 e6 ff ff       	call   100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c93:	8b 45 08             	mov    0x8(%ebp),%eax
  101c96:	8b 40 0c             	mov    0xc(%eax),%eax
  101c99:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c9d:	c7 04 24 fe 64 10 00 	movl   $0x1064fe,(%esp)
  101ca4:	e8 9f e6 ff ff       	call   100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  101cac:	8b 40 10             	mov    0x10(%eax),%eax
  101caf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb3:	c7 04 24 0d 65 10 00 	movl   $0x10650d,(%esp)
  101cba:	e8 89 e6 ff ff       	call   100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc2:	8b 40 14             	mov    0x14(%eax),%eax
  101cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc9:	c7 04 24 1c 65 10 00 	movl   $0x10651c,(%esp)
  101cd0:	e8 73 e6 ff ff       	call   100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd8:	8b 40 18             	mov    0x18(%eax),%eax
  101cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cdf:	c7 04 24 2b 65 10 00 	movl   $0x10652b,(%esp)
  101ce6:	e8 5d e6 ff ff       	call   100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  101cee:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf5:	c7 04 24 3a 65 10 00 	movl   $0x10653a,(%esp)
  101cfc:	e8 47 e6 ff ff       	call   100348 <cprintf>
}
  101d01:	c9                   	leave  
  101d02:	c3                   	ret    

00101d03 <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d03:	55                   	push   %ebp
  101d04:	89 e5                	mov    %esp,%ebp
  101d06:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101d09:	8b 45 08             	mov    0x8(%ebp),%eax
  101d0c:	8b 40 30             	mov    0x30(%eax),%eax
  101d0f:	83 f8 2f             	cmp    $0x2f,%eax
  101d12:	77 21                	ja     101d35 <trap_dispatch+0x32>
  101d14:	83 f8 2e             	cmp    $0x2e,%eax
  101d17:	0f 83 ee 00 00 00    	jae    101e0b <trap_dispatch+0x108>
  101d1d:	83 f8 21             	cmp    $0x21,%eax
  101d20:	0f 84 87 00 00 00    	je     101dad <trap_dispatch+0xaa>
  101d26:	83 f8 24             	cmp    $0x24,%eax
  101d29:	74 5c                	je     101d87 <trap_dispatch+0x84>
  101d2b:	83 f8 20             	cmp    $0x20,%eax
  101d2e:	74 1c                	je     101d4c <trap_dispatch+0x49>
  101d30:	e9 9e 00 00 00       	jmp    101dd3 <trap_dispatch+0xd0>
  101d35:	83 f8 78             	cmp    $0x78,%eax
  101d38:	0f 84 d0 00 00 00    	je     101e0e <trap_dispatch+0x10b>
  101d3e:	83 f8 79             	cmp    $0x79,%eax
  101d41:	0f 84 ca 00 00 00    	je     101e11 <trap_dispatch+0x10e>
  101d47:	e9 87 00 00 00       	jmp    101dd3 <trap_dispatch+0xd0>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101d4c:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d51:	83 c0 01             	add    $0x1,%eax
  101d54:	a3 0c af 11 00       	mov    %eax,0x11af0c
        if (ticks % TICK_NUM == 0) {
  101d59:	8b 0d 0c af 11 00    	mov    0x11af0c,%ecx
  101d5f:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d64:	89 c8                	mov    %ecx,%eax
  101d66:	f7 e2                	mul    %edx
  101d68:	89 d0                	mov    %edx,%eax
  101d6a:	c1 e8 05             	shr    $0x5,%eax
  101d6d:	6b c0 64             	imul   $0x64,%eax,%eax
  101d70:	29 c1                	sub    %eax,%ecx
  101d72:	89 c8                	mov    %ecx,%eax
  101d74:	85 c0                	test   %eax,%eax
  101d76:	75 0a                	jne    101d82 <trap_dispatch+0x7f>
            print_ticks();
  101d78:	e8 10 fb ff ff       	call   10188d <print_ticks>
        }
        break;
  101d7d:	e9 90 00 00 00       	jmp    101e12 <trap_dispatch+0x10f>
  101d82:	e9 8b 00 00 00       	jmp    101e12 <trap_dispatch+0x10f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d87:	e8 c5 f8 ff ff       	call   101651 <cons_getc>
  101d8c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d8f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d93:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d97:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d9f:	c7 04 24 49 65 10 00 	movl   $0x106549,(%esp)
  101da6:	e8 9d e5 ff ff       	call   100348 <cprintf>
        break;
  101dab:	eb 65                	jmp    101e12 <trap_dispatch+0x10f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101dad:	e8 9f f8 ff ff       	call   101651 <cons_getc>
  101db2:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101db5:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101db9:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101dbd:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dc5:	c7 04 24 5b 65 10 00 	movl   $0x10655b,(%esp)
  101dcc:	e8 77 e5 ff ff       	call   100348 <cprintf>
        break;
  101dd1:	eb 3f                	jmp    101e12 <trap_dispatch+0x10f>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101dda:	0f b7 c0             	movzwl %ax,%eax
  101ddd:	83 e0 03             	and    $0x3,%eax
  101de0:	85 c0                	test   %eax,%eax
  101de2:	75 2e                	jne    101e12 <trap_dispatch+0x10f>
            print_trapframe(tf);
  101de4:	8b 45 08             	mov    0x8(%ebp),%eax
  101de7:	89 04 24             	mov    %eax,(%esp)
  101dea:	e8 98 fc ff ff       	call   101a87 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101def:	c7 44 24 08 6a 65 10 	movl   $0x10656a,0x8(%esp)
  101df6:	00 
  101df7:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
  101dfe:	00 
  101dff:	c7 04 24 8e 63 10 00 	movl   $0x10638e,(%esp)
  101e06:	e8 c7 ee ff ff       	call   100cd2 <__panic>
        
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101e0b:	90                   	nop
  101e0c:	eb 04                	jmp    101e12 <trap_dispatch+0x10f>
        cprintf("kbd [%03d] %c\n", c, c);
        break;
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        
        break;
  101e0e:	90                   	nop
  101e0f:	eb 01                	jmp    101e12 <trap_dispatch+0x10f>
    case T_SWITCH_TOK:
        
        break;
  101e11:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101e12:	c9                   	leave  
  101e13:	c3                   	ret    

00101e14 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e14:	55                   	push   %ebp
  101e15:	89 e5                	mov    %esp,%ebp
  101e17:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e1d:	89 04 24             	mov    %eax,(%esp)
  101e20:	e8 de fe ff ff       	call   101d03 <trap_dispatch>
}
  101e25:	c9                   	leave  
  101e26:	c3                   	ret    

00101e27 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101e27:	1e                   	push   %ds
    pushl %es
  101e28:	06                   	push   %es
    pushl %fs
  101e29:	0f a0                	push   %fs
    pushl %gs
  101e2b:	0f a8                	push   %gs
    pushal
  101e2d:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101e2e:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101e33:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101e35:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101e37:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101e38:	e8 d7 ff ff ff       	call   101e14 <trap>

    # pop the pushed stack pointer
    popl %esp
  101e3d:	5c                   	pop    %esp

00101e3e <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101e3e:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101e3f:	0f a9                	pop    %gs
    popl %fs
  101e41:	0f a1                	pop    %fs
    popl %es
  101e43:	07                   	pop    %es
    popl %ds
  101e44:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101e45:	83 c4 08             	add    $0x8,%esp
    iret
  101e48:	cf                   	iret   

00101e49 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e49:	6a 00                	push   $0x0
  pushl $0
  101e4b:	6a 00                	push   $0x0
  jmp __alltraps
  101e4d:	e9 d5 ff ff ff       	jmp    101e27 <__alltraps>

00101e52 <vector1>:
.globl vector1
vector1:
  pushl $0
  101e52:	6a 00                	push   $0x0
  pushl $1
  101e54:	6a 01                	push   $0x1
  jmp __alltraps
  101e56:	e9 cc ff ff ff       	jmp    101e27 <__alltraps>

00101e5b <vector2>:
.globl vector2
vector2:
  pushl $0
  101e5b:	6a 00                	push   $0x0
  pushl $2
  101e5d:	6a 02                	push   $0x2
  jmp __alltraps
  101e5f:	e9 c3 ff ff ff       	jmp    101e27 <__alltraps>

00101e64 <vector3>:
.globl vector3
vector3:
  pushl $0
  101e64:	6a 00                	push   $0x0
  pushl $3
  101e66:	6a 03                	push   $0x3
  jmp __alltraps
  101e68:	e9 ba ff ff ff       	jmp    101e27 <__alltraps>

00101e6d <vector4>:
.globl vector4
vector4:
  pushl $0
  101e6d:	6a 00                	push   $0x0
  pushl $4
  101e6f:	6a 04                	push   $0x4
  jmp __alltraps
  101e71:	e9 b1 ff ff ff       	jmp    101e27 <__alltraps>

00101e76 <vector5>:
.globl vector5
vector5:
  pushl $0
  101e76:	6a 00                	push   $0x0
  pushl $5
  101e78:	6a 05                	push   $0x5
  jmp __alltraps
  101e7a:	e9 a8 ff ff ff       	jmp    101e27 <__alltraps>

00101e7f <vector6>:
.globl vector6
vector6:
  pushl $0
  101e7f:	6a 00                	push   $0x0
  pushl $6
  101e81:	6a 06                	push   $0x6
  jmp __alltraps
  101e83:	e9 9f ff ff ff       	jmp    101e27 <__alltraps>

00101e88 <vector7>:
.globl vector7
vector7:
  pushl $0
  101e88:	6a 00                	push   $0x0
  pushl $7
  101e8a:	6a 07                	push   $0x7
  jmp __alltraps
  101e8c:	e9 96 ff ff ff       	jmp    101e27 <__alltraps>

00101e91 <vector8>:
.globl vector8
vector8:
  pushl $8
  101e91:	6a 08                	push   $0x8
  jmp __alltraps
  101e93:	e9 8f ff ff ff       	jmp    101e27 <__alltraps>

00101e98 <vector9>:
.globl vector9
vector9:
  pushl $0
  101e98:	6a 00                	push   $0x0
  pushl $9
  101e9a:	6a 09                	push   $0x9
  jmp __alltraps
  101e9c:	e9 86 ff ff ff       	jmp    101e27 <__alltraps>

00101ea1 <vector10>:
.globl vector10
vector10:
  pushl $10
  101ea1:	6a 0a                	push   $0xa
  jmp __alltraps
  101ea3:	e9 7f ff ff ff       	jmp    101e27 <__alltraps>

00101ea8 <vector11>:
.globl vector11
vector11:
  pushl $11
  101ea8:	6a 0b                	push   $0xb
  jmp __alltraps
  101eaa:	e9 78 ff ff ff       	jmp    101e27 <__alltraps>

00101eaf <vector12>:
.globl vector12
vector12:
  pushl $12
  101eaf:	6a 0c                	push   $0xc
  jmp __alltraps
  101eb1:	e9 71 ff ff ff       	jmp    101e27 <__alltraps>

00101eb6 <vector13>:
.globl vector13
vector13:
  pushl $13
  101eb6:	6a 0d                	push   $0xd
  jmp __alltraps
  101eb8:	e9 6a ff ff ff       	jmp    101e27 <__alltraps>

00101ebd <vector14>:
.globl vector14
vector14:
  pushl $14
  101ebd:	6a 0e                	push   $0xe
  jmp __alltraps
  101ebf:	e9 63 ff ff ff       	jmp    101e27 <__alltraps>

00101ec4 <vector15>:
.globl vector15
vector15:
  pushl $0
  101ec4:	6a 00                	push   $0x0
  pushl $15
  101ec6:	6a 0f                	push   $0xf
  jmp __alltraps
  101ec8:	e9 5a ff ff ff       	jmp    101e27 <__alltraps>

00101ecd <vector16>:
.globl vector16
vector16:
  pushl $0
  101ecd:	6a 00                	push   $0x0
  pushl $16
  101ecf:	6a 10                	push   $0x10
  jmp __alltraps
  101ed1:	e9 51 ff ff ff       	jmp    101e27 <__alltraps>

00101ed6 <vector17>:
.globl vector17
vector17:
  pushl $17
  101ed6:	6a 11                	push   $0x11
  jmp __alltraps
  101ed8:	e9 4a ff ff ff       	jmp    101e27 <__alltraps>

00101edd <vector18>:
.globl vector18
vector18:
  pushl $0
  101edd:	6a 00                	push   $0x0
  pushl $18
  101edf:	6a 12                	push   $0x12
  jmp __alltraps
  101ee1:	e9 41 ff ff ff       	jmp    101e27 <__alltraps>

00101ee6 <vector19>:
.globl vector19
vector19:
  pushl $0
  101ee6:	6a 00                	push   $0x0
  pushl $19
  101ee8:	6a 13                	push   $0x13
  jmp __alltraps
  101eea:	e9 38 ff ff ff       	jmp    101e27 <__alltraps>

00101eef <vector20>:
.globl vector20
vector20:
  pushl $0
  101eef:	6a 00                	push   $0x0
  pushl $20
  101ef1:	6a 14                	push   $0x14
  jmp __alltraps
  101ef3:	e9 2f ff ff ff       	jmp    101e27 <__alltraps>

00101ef8 <vector21>:
.globl vector21
vector21:
  pushl $0
  101ef8:	6a 00                	push   $0x0
  pushl $21
  101efa:	6a 15                	push   $0x15
  jmp __alltraps
  101efc:	e9 26 ff ff ff       	jmp    101e27 <__alltraps>

00101f01 <vector22>:
.globl vector22
vector22:
  pushl $0
  101f01:	6a 00                	push   $0x0
  pushl $22
  101f03:	6a 16                	push   $0x16
  jmp __alltraps
  101f05:	e9 1d ff ff ff       	jmp    101e27 <__alltraps>

00101f0a <vector23>:
.globl vector23
vector23:
  pushl $0
  101f0a:	6a 00                	push   $0x0
  pushl $23
  101f0c:	6a 17                	push   $0x17
  jmp __alltraps
  101f0e:	e9 14 ff ff ff       	jmp    101e27 <__alltraps>

00101f13 <vector24>:
.globl vector24
vector24:
  pushl $0
  101f13:	6a 00                	push   $0x0
  pushl $24
  101f15:	6a 18                	push   $0x18
  jmp __alltraps
  101f17:	e9 0b ff ff ff       	jmp    101e27 <__alltraps>

00101f1c <vector25>:
.globl vector25
vector25:
  pushl $0
  101f1c:	6a 00                	push   $0x0
  pushl $25
  101f1e:	6a 19                	push   $0x19
  jmp __alltraps
  101f20:	e9 02 ff ff ff       	jmp    101e27 <__alltraps>

00101f25 <vector26>:
.globl vector26
vector26:
  pushl $0
  101f25:	6a 00                	push   $0x0
  pushl $26
  101f27:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f29:	e9 f9 fe ff ff       	jmp    101e27 <__alltraps>

00101f2e <vector27>:
.globl vector27
vector27:
  pushl $0
  101f2e:	6a 00                	push   $0x0
  pushl $27
  101f30:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f32:	e9 f0 fe ff ff       	jmp    101e27 <__alltraps>

00101f37 <vector28>:
.globl vector28
vector28:
  pushl $0
  101f37:	6a 00                	push   $0x0
  pushl $28
  101f39:	6a 1c                	push   $0x1c
  jmp __alltraps
  101f3b:	e9 e7 fe ff ff       	jmp    101e27 <__alltraps>

00101f40 <vector29>:
.globl vector29
vector29:
  pushl $0
  101f40:	6a 00                	push   $0x0
  pushl $29
  101f42:	6a 1d                	push   $0x1d
  jmp __alltraps
  101f44:	e9 de fe ff ff       	jmp    101e27 <__alltraps>

00101f49 <vector30>:
.globl vector30
vector30:
  pushl $0
  101f49:	6a 00                	push   $0x0
  pushl $30
  101f4b:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f4d:	e9 d5 fe ff ff       	jmp    101e27 <__alltraps>

00101f52 <vector31>:
.globl vector31
vector31:
  pushl $0
  101f52:	6a 00                	push   $0x0
  pushl $31
  101f54:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f56:	e9 cc fe ff ff       	jmp    101e27 <__alltraps>

00101f5b <vector32>:
.globl vector32
vector32:
  pushl $0
  101f5b:	6a 00                	push   $0x0
  pushl $32
  101f5d:	6a 20                	push   $0x20
  jmp __alltraps
  101f5f:	e9 c3 fe ff ff       	jmp    101e27 <__alltraps>

00101f64 <vector33>:
.globl vector33
vector33:
  pushl $0
  101f64:	6a 00                	push   $0x0
  pushl $33
  101f66:	6a 21                	push   $0x21
  jmp __alltraps
  101f68:	e9 ba fe ff ff       	jmp    101e27 <__alltraps>

00101f6d <vector34>:
.globl vector34
vector34:
  pushl $0
  101f6d:	6a 00                	push   $0x0
  pushl $34
  101f6f:	6a 22                	push   $0x22
  jmp __alltraps
  101f71:	e9 b1 fe ff ff       	jmp    101e27 <__alltraps>

00101f76 <vector35>:
.globl vector35
vector35:
  pushl $0
  101f76:	6a 00                	push   $0x0
  pushl $35
  101f78:	6a 23                	push   $0x23
  jmp __alltraps
  101f7a:	e9 a8 fe ff ff       	jmp    101e27 <__alltraps>

00101f7f <vector36>:
.globl vector36
vector36:
  pushl $0
  101f7f:	6a 00                	push   $0x0
  pushl $36
  101f81:	6a 24                	push   $0x24
  jmp __alltraps
  101f83:	e9 9f fe ff ff       	jmp    101e27 <__alltraps>

00101f88 <vector37>:
.globl vector37
vector37:
  pushl $0
  101f88:	6a 00                	push   $0x0
  pushl $37
  101f8a:	6a 25                	push   $0x25
  jmp __alltraps
  101f8c:	e9 96 fe ff ff       	jmp    101e27 <__alltraps>

00101f91 <vector38>:
.globl vector38
vector38:
  pushl $0
  101f91:	6a 00                	push   $0x0
  pushl $38
  101f93:	6a 26                	push   $0x26
  jmp __alltraps
  101f95:	e9 8d fe ff ff       	jmp    101e27 <__alltraps>

00101f9a <vector39>:
.globl vector39
vector39:
  pushl $0
  101f9a:	6a 00                	push   $0x0
  pushl $39
  101f9c:	6a 27                	push   $0x27
  jmp __alltraps
  101f9e:	e9 84 fe ff ff       	jmp    101e27 <__alltraps>

00101fa3 <vector40>:
.globl vector40
vector40:
  pushl $0
  101fa3:	6a 00                	push   $0x0
  pushl $40
  101fa5:	6a 28                	push   $0x28
  jmp __alltraps
  101fa7:	e9 7b fe ff ff       	jmp    101e27 <__alltraps>

00101fac <vector41>:
.globl vector41
vector41:
  pushl $0
  101fac:	6a 00                	push   $0x0
  pushl $41
  101fae:	6a 29                	push   $0x29
  jmp __alltraps
  101fb0:	e9 72 fe ff ff       	jmp    101e27 <__alltraps>

00101fb5 <vector42>:
.globl vector42
vector42:
  pushl $0
  101fb5:	6a 00                	push   $0x0
  pushl $42
  101fb7:	6a 2a                	push   $0x2a
  jmp __alltraps
  101fb9:	e9 69 fe ff ff       	jmp    101e27 <__alltraps>

00101fbe <vector43>:
.globl vector43
vector43:
  pushl $0
  101fbe:	6a 00                	push   $0x0
  pushl $43
  101fc0:	6a 2b                	push   $0x2b
  jmp __alltraps
  101fc2:	e9 60 fe ff ff       	jmp    101e27 <__alltraps>

00101fc7 <vector44>:
.globl vector44
vector44:
  pushl $0
  101fc7:	6a 00                	push   $0x0
  pushl $44
  101fc9:	6a 2c                	push   $0x2c
  jmp __alltraps
  101fcb:	e9 57 fe ff ff       	jmp    101e27 <__alltraps>

00101fd0 <vector45>:
.globl vector45
vector45:
  pushl $0
  101fd0:	6a 00                	push   $0x0
  pushl $45
  101fd2:	6a 2d                	push   $0x2d
  jmp __alltraps
  101fd4:	e9 4e fe ff ff       	jmp    101e27 <__alltraps>

00101fd9 <vector46>:
.globl vector46
vector46:
  pushl $0
  101fd9:	6a 00                	push   $0x0
  pushl $46
  101fdb:	6a 2e                	push   $0x2e
  jmp __alltraps
  101fdd:	e9 45 fe ff ff       	jmp    101e27 <__alltraps>

00101fe2 <vector47>:
.globl vector47
vector47:
  pushl $0
  101fe2:	6a 00                	push   $0x0
  pushl $47
  101fe4:	6a 2f                	push   $0x2f
  jmp __alltraps
  101fe6:	e9 3c fe ff ff       	jmp    101e27 <__alltraps>

00101feb <vector48>:
.globl vector48
vector48:
  pushl $0
  101feb:	6a 00                	push   $0x0
  pushl $48
  101fed:	6a 30                	push   $0x30
  jmp __alltraps
  101fef:	e9 33 fe ff ff       	jmp    101e27 <__alltraps>

00101ff4 <vector49>:
.globl vector49
vector49:
  pushl $0
  101ff4:	6a 00                	push   $0x0
  pushl $49
  101ff6:	6a 31                	push   $0x31
  jmp __alltraps
  101ff8:	e9 2a fe ff ff       	jmp    101e27 <__alltraps>

00101ffd <vector50>:
.globl vector50
vector50:
  pushl $0
  101ffd:	6a 00                	push   $0x0
  pushl $50
  101fff:	6a 32                	push   $0x32
  jmp __alltraps
  102001:	e9 21 fe ff ff       	jmp    101e27 <__alltraps>

00102006 <vector51>:
.globl vector51
vector51:
  pushl $0
  102006:	6a 00                	push   $0x0
  pushl $51
  102008:	6a 33                	push   $0x33
  jmp __alltraps
  10200a:	e9 18 fe ff ff       	jmp    101e27 <__alltraps>

0010200f <vector52>:
.globl vector52
vector52:
  pushl $0
  10200f:	6a 00                	push   $0x0
  pushl $52
  102011:	6a 34                	push   $0x34
  jmp __alltraps
  102013:	e9 0f fe ff ff       	jmp    101e27 <__alltraps>

00102018 <vector53>:
.globl vector53
vector53:
  pushl $0
  102018:	6a 00                	push   $0x0
  pushl $53
  10201a:	6a 35                	push   $0x35
  jmp __alltraps
  10201c:	e9 06 fe ff ff       	jmp    101e27 <__alltraps>

00102021 <vector54>:
.globl vector54
vector54:
  pushl $0
  102021:	6a 00                	push   $0x0
  pushl $54
  102023:	6a 36                	push   $0x36
  jmp __alltraps
  102025:	e9 fd fd ff ff       	jmp    101e27 <__alltraps>

0010202a <vector55>:
.globl vector55
vector55:
  pushl $0
  10202a:	6a 00                	push   $0x0
  pushl $55
  10202c:	6a 37                	push   $0x37
  jmp __alltraps
  10202e:	e9 f4 fd ff ff       	jmp    101e27 <__alltraps>

00102033 <vector56>:
.globl vector56
vector56:
  pushl $0
  102033:	6a 00                	push   $0x0
  pushl $56
  102035:	6a 38                	push   $0x38
  jmp __alltraps
  102037:	e9 eb fd ff ff       	jmp    101e27 <__alltraps>

0010203c <vector57>:
.globl vector57
vector57:
  pushl $0
  10203c:	6a 00                	push   $0x0
  pushl $57
  10203e:	6a 39                	push   $0x39
  jmp __alltraps
  102040:	e9 e2 fd ff ff       	jmp    101e27 <__alltraps>

00102045 <vector58>:
.globl vector58
vector58:
  pushl $0
  102045:	6a 00                	push   $0x0
  pushl $58
  102047:	6a 3a                	push   $0x3a
  jmp __alltraps
  102049:	e9 d9 fd ff ff       	jmp    101e27 <__alltraps>

0010204e <vector59>:
.globl vector59
vector59:
  pushl $0
  10204e:	6a 00                	push   $0x0
  pushl $59
  102050:	6a 3b                	push   $0x3b
  jmp __alltraps
  102052:	e9 d0 fd ff ff       	jmp    101e27 <__alltraps>

00102057 <vector60>:
.globl vector60
vector60:
  pushl $0
  102057:	6a 00                	push   $0x0
  pushl $60
  102059:	6a 3c                	push   $0x3c
  jmp __alltraps
  10205b:	e9 c7 fd ff ff       	jmp    101e27 <__alltraps>

00102060 <vector61>:
.globl vector61
vector61:
  pushl $0
  102060:	6a 00                	push   $0x0
  pushl $61
  102062:	6a 3d                	push   $0x3d
  jmp __alltraps
  102064:	e9 be fd ff ff       	jmp    101e27 <__alltraps>

00102069 <vector62>:
.globl vector62
vector62:
  pushl $0
  102069:	6a 00                	push   $0x0
  pushl $62
  10206b:	6a 3e                	push   $0x3e
  jmp __alltraps
  10206d:	e9 b5 fd ff ff       	jmp    101e27 <__alltraps>

00102072 <vector63>:
.globl vector63
vector63:
  pushl $0
  102072:	6a 00                	push   $0x0
  pushl $63
  102074:	6a 3f                	push   $0x3f
  jmp __alltraps
  102076:	e9 ac fd ff ff       	jmp    101e27 <__alltraps>

0010207b <vector64>:
.globl vector64
vector64:
  pushl $0
  10207b:	6a 00                	push   $0x0
  pushl $64
  10207d:	6a 40                	push   $0x40
  jmp __alltraps
  10207f:	e9 a3 fd ff ff       	jmp    101e27 <__alltraps>

00102084 <vector65>:
.globl vector65
vector65:
  pushl $0
  102084:	6a 00                	push   $0x0
  pushl $65
  102086:	6a 41                	push   $0x41
  jmp __alltraps
  102088:	e9 9a fd ff ff       	jmp    101e27 <__alltraps>

0010208d <vector66>:
.globl vector66
vector66:
  pushl $0
  10208d:	6a 00                	push   $0x0
  pushl $66
  10208f:	6a 42                	push   $0x42
  jmp __alltraps
  102091:	e9 91 fd ff ff       	jmp    101e27 <__alltraps>

00102096 <vector67>:
.globl vector67
vector67:
  pushl $0
  102096:	6a 00                	push   $0x0
  pushl $67
  102098:	6a 43                	push   $0x43
  jmp __alltraps
  10209a:	e9 88 fd ff ff       	jmp    101e27 <__alltraps>

0010209f <vector68>:
.globl vector68
vector68:
  pushl $0
  10209f:	6a 00                	push   $0x0
  pushl $68
  1020a1:	6a 44                	push   $0x44
  jmp __alltraps
  1020a3:	e9 7f fd ff ff       	jmp    101e27 <__alltraps>

001020a8 <vector69>:
.globl vector69
vector69:
  pushl $0
  1020a8:	6a 00                	push   $0x0
  pushl $69
  1020aa:	6a 45                	push   $0x45
  jmp __alltraps
  1020ac:	e9 76 fd ff ff       	jmp    101e27 <__alltraps>

001020b1 <vector70>:
.globl vector70
vector70:
  pushl $0
  1020b1:	6a 00                	push   $0x0
  pushl $70
  1020b3:	6a 46                	push   $0x46
  jmp __alltraps
  1020b5:	e9 6d fd ff ff       	jmp    101e27 <__alltraps>

001020ba <vector71>:
.globl vector71
vector71:
  pushl $0
  1020ba:	6a 00                	push   $0x0
  pushl $71
  1020bc:	6a 47                	push   $0x47
  jmp __alltraps
  1020be:	e9 64 fd ff ff       	jmp    101e27 <__alltraps>

001020c3 <vector72>:
.globl vector72
vector72:
  pushl $0
  1020c3:	6a 00                	push   $0x0
  pushl $72
  1020c5:	6a 48                	push   $0x48
  jmp __alltraps
  1020c7:	e9 5b fd ff ff       	jmp    101e27 <__alltraps>

001020cc <vector73>:
.globl vector73
vector73:
  pushl $0
  1020cc:	6a 00                	push   $0x0
  pushl $73
  1020ce:	6a 49                	push   $0x49
  jmp __alltraps
  1020d0:	e9 52 fd ff ff       	jmp    101e27 <__alltraps>

001020d5 <vector74>:
.globl vector74
vector74:
  pushl $0
  1020d5:	6a 00                	push   $0x0
  pushl $74
  1020d7:	6a 4a                	push   $0x4a
  jmp __alltraps
  1020d9:	e9 49 fd ff ff       	jmp    101e27 <__alltraps>

001020de <vector75>:
.globl vector75
vector75:
  pushl $0
  1020de:	6a 00                	push   $0x0
  pushl $75
  1020e0:	6a 4b                	push   $0x4b
  jmp __alltraps
  1020e2:	e9 40 fd ff ff       	jmp    101e27 <__alltraps>

001020e7 <vector76>:
.globl vector76
vector76:
  pushl $0
  1020e7:	6a 00                	push   $0x0
  pushl $76
  1020e9:	6a 4c                	push   $0x4c
  jmp __alltraps
  1020eb:	e9 37 fd ff ff       	jmp    101e27 <__alltraps>

001020f0 <vector77>:
.globl vector77
vector77:
  pushl $0
  1020f0:	6a 00                	push   $0x0
  pushl $77
  1020f2:	6a 4d                	push   $0x4d
  jmp __alltraps
  1020f4:	e9 2e fd ff ff       	jmp    101e27 <__alltraps>

001020f9 <vector78>:
.globl vector78
vector78:
  pushl $0
  1020f9:	6a 00                	push   $0x0
  pushl $78
  1020fb:	6a 4e                	push   $0x4e
  jmp __alltraps
  1020fd:	e9 25 fd ff ff       	jmp    101e27 <__alltraps>

00102102 <vector79>:
.globl vector79
vector79:
  pushl $0
  102102:	6a 00                	push   $0x0
  pushl $79
  102104:	6a 4f                	push   $0x4f
  jmp __alltraps
  102106:	e9 1c fd ff ff       	jmp    101e27 <__alltraps>

0010210b <vector80>:
.globl vector80
vector80:
  pushl $0
  10210b:	6a 00                	push   $0x0
  pushl $80
  10210d:	6a 50                	push   $0x50
  jmp __alltraps
  10210f:	e9 13 fd ff ff       	jmp    101e27 <__alltraps>

00102114 <vector81>:
.globl vector81
vector81:
  pushl $0
  102114:	6a 00                	push   $0x0
  pushl $81
  102116:	6a 51                	push   $0x51
  jmp __alltraps
  102118:	e9 0a fd ff ff       	jmp    101e27 <__alltraps>

0010211d <vector82>:
.globl vector82
vector82:
  pushl $0
  10211d:	6a 00                	push   $0x0
  pushl $82
  10211f:	6a 52                	push   $0x52
  jmp __alltraps
  102121:	e9 01 fd ff ff       	jmp    101e27 <__alltraps>

00102126 <vector83>:
.globl vector83
vector83:
  pushl $0
  102126:	6a 00                	push   $0x0
  pushl $83
  102128:	6a 53                	push   $0x53
  jmp __alltraps
  10212a:	e9 f8 fc ff ff       	jmp    101e27 <__alltraps>

0010212f <vector84>:
.globl vector84
vector84:
  pushl $0
  10212f:	6a 00                	push   $0x0
  pushl $84
  102131:	6a 54                	push   $0x54
  jmp __alltraps
  102133:	e9 ef fc ff ff       	jmp    101e27 <__alltraps>

00102138 <vector85>:
.globl vector85
vector85:
  pushl $0
  102138:	6a 00                	push   $0x0
  pushl $85
  10213a:	6a 55                	push   $0x55
  jmp __alltraps
  10213c:	e9 e6 fc ff ff       	jmp    101e27 <__alltraps>

00102141 <vector86>:
.globl vector86
vector86:
  pushl $0
  102141:	6a 00                	push   $0x0
  pushl $86
  102143:	6a 56                	push   $0x56
  jmp __alltraps
  102145:	e9 dd fc ff ff       	jmp    101e27 <__alltraps>

0010214a <vector87>:
.globl vector87
vector87:
  pushl $0
  10214a:	6a 00                	push   $0x0
  pushl $87
  10214c:	6a 57                	push   $0x57
  jmp __alltraps
  10214e:	e9 d4 fc ff ff       	jmp    101e27 <__alltraps>

00102153 <vector88>:
.globl vector88
vector88:
  pushl $0
  102153:	6a 00                	push   $0x0
  pushl $88
  102155:	6a 58                	push   $0x58
  jmp __alltraps
  102157:	e9 cb fc ff ff       	jmp    101e27 <__alltraps>

0010215c <vector89>:
.globl vector89
vector89:
  pushl $0
  10215c:	6a 00                	push   $0x0
  pushl $89
  10215e:	6a 59                	push   $0x59
  jmp __alltraps
  102160:	e9 c2 fc ff ff       	jmp    101e27 <__alltraps>

00102165 <vector90>:
.globl vector90
vector90:
  pushl $0
  102165:	6a 00                	push   $0x0
  pushl $90
  102167:	6a 5a                	push   $0x5a
  jmp __alltraps
  102169:	e9 b9 fc ff ff       	jmp    101e27 <__alltraps>

0010216e <vector91>:
.globl vector91
vector91:
  pushl $0
  10216e:	6a 00                	push   $0x0
  pushl $91
  102170:	6a 5b                	push   $0x5b
  jmp __alltraps
  102172:	e9 b0 fc ff ff       	jmp    101e27 <__alltraps>

00102177 <vector92>:
.globl vector92
vector92:
  pushl $0
  102177:	6a 00                	push   $0x0
  pushl $92
  102179:	6a 5c                	push   $0x5c
  jmp __alltraps
  10217b:	e9 a7 fc ff ff       	jmp    101e27 <__alltraps>

00102180 <vector93>:
.globl vector93
vector93:
  pushl $0
  102180:	6a 00                	push   $0x0
  pushl $93
  102182:	6a 5d                	push   $0x5d
  jmp __alltraps
  102184:	e9 9e fc ff ff       	jmp    101e27 <__alltraps>

00102189 <vector94>:
.globl vector94
vector94:
  pushl $0
  102189:	6a 00                	push   $0x0
  pushl $94
  10218b:	6a 5e                	push   $0x5e
  jmp __alltraps
  10218d:	e9 95 fc ff ff       	jmp    101e27 <__alltraps>

00102192 <vector95>:
.globl vector95
vector95:
  pushl $0
  102192:	6a 00                	push   $0x0
  pushl $95
  102194:	6a 5f                	push   $0x5f
  jmp __alltraps
  102196:	e9 8c fc ff ff       	jmp    101e27 <__alltraps>

0010219b <vector96>:
.globl vector96
vector96:
  pushl $0
  10219b:	6a 00                	push   $0x0
  pushl $96
  10219d:	6a 60                	push   $0x60
  jmp __alltraps
  10219f:	e9 83 fc ff ff       	jmp    101e27 <__alltraps>

001021a4 <vector97>:
.globl vector97
vector97:
  pushl $0
  1021a4:	6a 00                	push   $0x0
  pushl $97
  1021a6:	6a 61                	push   $0x61
  jmp __alltraps
  1021a8:	e9 7a fc ff ff       	jmp    101e27 <__alltraps>

001021ad <vector98>:
.globl vector98
vector98:
  pushl $0
  1021ad:	6a 00                	push   $0x0
  pushl $98
  1021af:	6a 62                	push   $0x62
  jmp __alltraps
  1021b1:	e9 71 fc ff ff       	jmp    101e27 <__alltraps>

001021b6 <vector99>:
.globl vector99
vector99:
  pushl $0
  1021b6:	6a 00                	push   $0x0
  pushl $99
  1021b8:	6a 63                	push   $0x63
  jmp __alltraps
  1021ba:	e9 68 fc ff ff       	jmp    101e27 <__alltraps>

001021bf <vector100>:
.globl vector100
vector100:
  pushl $0
  1021bf:	6a 00                	push   $0x0
  pushl $100
  1021c1:	6a 64                	push   $0x64
  jmp __alltraps
  1021c3:	e9 5f fc ff ff       	jmp    101e27 <__alltraps>

001021c8 <vector101>:
.globl vector101
vector101:
  pushl $0
  1021c8:	6a 00                	push   $0x0
  pushl $101
  1021ca:	6a 65                	push   $0x65
  jmp __alltraps
  1021cc:	e9 56 fc ff ff       	jmp    101e27 <__alltraps>

001021d1 <vector102>:
.globl vector102
vector102:
  pushl $0
  1021d1:	6a 00                	push   $0x0
  pushl $102
  1021d3:	6a 66                	push   $0x66
  jmp __alltraps
  1021d5:	e9 4d fc ff ff       	jmp    101e27 <__alltraps>

001021da <vector103>:
.globl vector103
vector103:
  pushl $0
  1021da:	6a 00                	push   $0x0
  pushl $103
  1021dc:	6a 67                	push   $0x67
  jmp __alltraps
  1021de:	e9 44 fc ff ff       	jmp    101e27 <__alltraps>

001021e3 <vector104>:
.globl vector104
vector104:
  pushl $0
  1021e3:	6a 00                	push   $0x0
  pushl $104
  1021e5:	6a 68                	push   $0x68
  jmp __alltraps
  1021e7:	e9 3b fc ff ff       	jmp    101e27 <__alltraps>

001021ec <vector105>:
.globl vector105
vector105:
  pushl $0
  1021ec:	6a 00                	push   $0x0
  pushl $105
  1021ee:	6a 69                	push   $0x69
  jmp __alltraps
  1021f0:	e9 32 fc ff ff       	jmp    101e27 <__alltraps>

001021f5 <vector106>:
.globl vector106
vector106:
  pushl $0
  1021f5:	6a 00                	push   $0x0
  pushl $106
  1021f7:	6a 6a                	push   $0x6a
  jmp __alltraps
  1021f9:	e9 29 fc ff ff       	jmp    101e27 <__alltraps>

001021fe <vector107>:
.globl vector107
vector107:
  pushl $0
  1021fe:	6a 00                	push   $0x0
  pushl $107
  102200:	6a 6b                	push   $0x6b
  jmp __alltraps
  102202:	e9 20 fc ff ff       	jmp    101e27 <__alltraps>

00102207 <vector108>:
.globl vector108
vector108:
  pushl $0
  102207:	6a 00                	push   $0x0
  pushl $108
  102209:	6a 6c                	push   $0x6c
  jmp __alltraps
  10220b:	e9 17 fc ff ff       	jmp    101e27 <__alltraps>

00102210 <vector109>:
.globl vector109
vector109:
  pushl $0
  102210:	6a 00                	push   $0x0
  pushl $109
  102212:	6a 6d                	push   $0x6d
  jmp __alltraps
  102214:	e9 0e fc ff ff       	jmp    101e27 <__alltraps>

00102219 <vector110>:
.globl vector110
vector110:
  pushl $0
  102219:	6a 00                	push   $0x0
  pushl $110
  10221b:	6a 6e                	push   $0x6e
  jmp __alltraps
  10221d:	e9 05 fc ff ff       	jmp    101e27 <__alltraps>

00102222 <vector111>:
.globl vector111
vector111:
  pushl $0
  102222:	6a 00                	push   $0x0
  pushl $111
  102224:	6a 6f                	push   $0x6f
  jmp __alltraps
  102226:	e9 fc fb ff ff       	jmp    101e27 <__alltraps>

0010222b <vector112>:
.globl vector112
vector112:
  pushl $0
  10222b:	6a 00                	push   $0x0
  pushl $112
  10222d:	6a 70                	push   $0x70
  jmp __alltraps
  10222f:	e9 f3 fb ff ff       	jmp    101e27 <__alltraps>

00102234 <vector113>:
.globl vector113
vector113:
  pushl $0
  102234:	6a 00                	push   $0x0
  pushl $113
  102236:	6a 71                	push   $0x71
  jmp __alltraps
  102238:	e9 ea fb ff ff       	jmp    101e27 <__alltraps>

0010223d <vector114>:
.globl vector114
vector114:
  pushl $0
  10223d:	6a 00                	push   $0x0
  pushl $114
  10223f:	6a 72                	push   $0x72
  jmp __alltraps
  102241:	e9 e1 fb ff ff       	jmp    101e27 <__alltraps>

00102246 <vector115>:
.globl vector115
vector115:
  pushl $0
  102246:	6a 00                	push   $0x0
  pushl $115
  102248:	6a 73                	push   $0x73
  jmp __alltraps
  10224a:	e9 d8 fb ff ff       	jmp    101e27 <__alltraps>

0010224f <vector116>:
.globl vector116
vector116:
  pushl $0
  10224f:	6a 00                	push   $0x0
  pushl $116
  102251:	6a 74                	push   $0x74
  jmp __alltraps
  102253:	e9 cf fb ff ff       	jmp    101e27 <__alltraps>

00102258 <vector117>:
.globl vector117
vector117:
  pushl $0
  102258:	6a 00                	push   $0x0
  pushl $117
  10225a:	6a 75                	push   $0x75
  jmp __alltraps
  10225c:	e9 c6 fb ff ff       	jmp    101e27 <__alltraps>

00102261 <vector118>:
.globl vector118
vector118:
  pushl $0
  102261:	6a 00                	push   $0x0
  pushl $118
  102263:	6a 76                	push   $0x76
  jmp __alltraps
  102265:	e9 bd fb ff ff       	jmp    101e27 <__alltraps>

0010226a <vector119>:
.globl vector119
vector119:
  pushl $0
  10226a:	6a 00                	push   $0x0
  pushl $119
  10226c:	6a 77                	push   $0x77
  jmp __alltraps
  10226e:	e9 b4 fb ff ff       	jmp    101e27 <__alltraps>

00102273 <vector120>:
.globl vector120
vector120:
  pushl $0
  102273:	6a 00                	push   $0x0
  pushl $120
  102275:	6a 78                	push   $0x78
  jmp __alltraps
  102277:	e9 ab fb ff ff       	jmp    101e27 <__alltraps>

0010227c <vector121>:
.globl vector121
vector121:
  pushl $0
  10227c:	6a 00                	push   $0x0
  pushl $121
  10227e:	6a 79                	push   $0x79
  jmp __alltraps
  102280:	e9 a2 fb ff ff       	jmp    101e27 <__alltraps>

00102285 <vector122>:
.globl vector122
vector122:
  pushl $0
  102285:	6a 00                	push   $0x0
  pushl $122
  102287:	6a 7a                	push   $0x7a
  jmp __alltraps
  102289:	e9 99 fb ff ff       	jmp    101e27 <__alltraps>

0010228e <vector123>:
.globl vector123
vector123:
  pushl $0
  10228e:	6a 00                	push   $0x0
  pushl $123
  102290:	6a 7b                	push   $0x7b
  jmp __alltraps
  102292:	e9 90 fb ff ff       	jmp    101e27 <__alltraps>

00102297 <vector124>:
.globl vector124
vector124:
  pushl $0
  102297:	6a 00                	push   $0x0
  pushl $124
  102299:	6a 7c                	push   $0x7c
  jmp __alltraps
  10229b:	e9 87 fb ff ff       	jmp    101e27 <__alltraps>

001022a0 <vector125>:
.globl vector125
vector125:
  pushl $0
  1022a0:	6a 00                	push   $0x0
  pushl $125
  1022a2:	6a 7d                	push   $0x7d
  jmp __alltraps
  1022a4:	e9 7e fb ff ff       	jmp    101e27 <__alltraps>

001022a9 <vector126>:
.globl vector126
vector126:
  pushl $0
  1022a9:	6a 00                	push   $0x0
  pushl $126
  1022ab:	6a 7e                	push   $0x7e
  jmp __alltraps
  1022ad:	e9 75 fb ff ff       	jmp    101e27 <__alltraps>

001022b2 <vector127>:
.globl vector127
vector127:
  pushl $0
  1022b2:	6a 00                	push   $0x0
  pushl $127
  1022b4:	6a 7f                	push   $0x7f
  jmp __alltraps
  1022b6:	e9 6c fb ff ff       	jmp    101e27 <__alltraps>

001022bb <vector128>:
.globl vector128
vector128:
  pushl $0
  1022bb:	6a 00                	push   $0x0
  pushl $128
  1022bd:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1022c2:	e9 60 fb ff ff       	jmp    101e27 <__alltraps>

001022c7 <vector129>:
.globl vector129
vector129:
  pushl $0
  1022c7:	6a 00                	push   $0x0
  pushl $129
  1022c9:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1022ce:	e9 54 fb ff ff       	jmp    101e27 <__alltraps>

001022d3 <vector130>:
.globl vector130
vector130:
  pushl $0
  1022d3:	6a 00                	push   $0x0
  pushl $130
  1022d5:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1022da:	e9 48 fb ff ff       	jmp    101e27 <__alltraps>

001022df <vector131>:
.globl vector131
vector131:
  pushl $0
  1022df:	6a 00                	push   $0x0
  pushl $131
  1022e1:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1022e6:	e9 3c fb ff ff       	jmp    101e27 <__alltraps>

001022eb <vector132>:
.globl vector132
vector132:
  pushl $0
  1022eb:	6a 00                	push   $0x0
  pushl $132
  1022ed:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1022f2:	e9 30 fb ff ff       	jmp    101e27 <__alltraps>

001022f7 <vector133>:
.globl vector133
vector133:
  pushl $0
  1022f7:	6a 00                	push   $0x0
  pushl $133
  1022f9:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1022fe:	e9 24 fb ff ff       	jmp    101e27 <__alltraps>

00102303 <vector134>:
.globl vector134
vector134:
  pushl $0
  102303:	6a 00                	push   $0x0
  pushl $134
  102305:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10230a:	e9 18 fb ff ff       	jmp    101e27 <__alltraps>

0010230f <vector135>:
.globl vector135
vector135:
  pushl $0
  10230f:	6a 00                	push   $0x0
  pushl $135
  102311:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102316:	e9 0c fb ff ff       	jmp    101e27 <__alltraps>

0010231b <vector136>:
.globl vector136
vector136:
  pushl $0
  10231b:	6a 00                	push   $0x0
  pushl $136
  10231d:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102322:	e9 00 fb ff ff       	jmp    101e27 <__alltraps>

00102327 <vector137>:
.globl vector137
vector137:
  pushl $0
  102327:	6a 00                	push   $0x0
  pushl $137
  102329:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10232e:	e9 f4 fa ff ff       	jmp    101e27 <__alltraps>

00102333 <vector138>:
.globl vector138
vector138:
  pushl $0
  102333:	6a 00                	push   $0x0
  pushl $138
  102335:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  10233a:	e9 e8 fa ff ff       	jmp    101e27 <__alltraps>

0010233f <vector139>:
.globl vector139
vector139:
  pushl $0
  10233f:	6a 00                	push   $0x0
  pushl $139
  102341:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102346:	e9 dc fa ff ff       	jmp    101e27 <__alltraps>

0010234b <vector140>:
.globl vector140
vector140:
  pushl $0
  10234b:	6a 00                	push   $0x0
  pushl $140
  10234d:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102352:	e9 d0 fa ff ff       	jmp    101e27 <__alltraps>

00102357 <vector141>:
.globl vector141
vector141:
  pushl $0
  102357:	6a 00                	push   $0x0
  pushl $141
  102359:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10235e:	e9 c4 fa ff ff       	jmp    101e27 <__alltraps>

00102363 <vector142>:
.globl vector142
vector142:
  pushl $0
  102363:	6a 00                	push   $0x0
  pushl $142
  102365:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  10236a:	e9 b8 fa ff ff       	jmp    101e27 <__alltraps>

0010236f <vector143>:
.globl vector143
vector143:
  pushl $0
  10236f:	6a 00                	push   $0x0
  pushl $143
  102371:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102376:	e9 ac fa ff ff       	jmp    101e27 <__alltraps>

0010237b <vector144>:
.globl vector144
vector144:
  pushl $0
  10237b:	6a 00                	push   $0x0
  pushl $144
  10237d:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102382:	e9 a0 fa ff ff       	jmp    101e27 <__alltraps>

00102387 <vector145>:
.globl vector145
vector145:
  pushl $0
  102387:	6a 00                	push   $0x0
  pushl $145
  102389:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  10238e:	e9 94 fa ff ff       	jmp    101e27 <__alltraps>

00102393 <vector146>:
.globl vector146
vector146:
  pushl $0
  102393:	6a 00                	push   $0x0
  pushl $146
  102395:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10239a:	e9 88 fa ff ff       	jmp    101e27 <__alltraps>

0010239f <vector147>:
.globl vector147
vector147:
  pushl $0
  10239f:	6a 00                	push   $0x0
  pushl $147
  1023a1:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1023a6:	e9 7c fa ff ff       	jmp    101e27 <__alltraps>

001023ab <vector148>:
.globl vector148
vector148:
  pushl $0
  1023ab:	6a 00                	push   $0x0
  pushl $148
  1023ad:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1023b2:	e9 70 fa ff ff       	jmp    101e27 <__alltraps>

001023b7 <vector149>:
.globl vector149
vector149:
  pushl $0
  1023b7:	6a 00                	push   $0x0
  pushl $149
  1023b9:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1023be:	e9 64 fa ff ff       	jmp    101e27 <__alltraps>

001023c3 <vector150>:
.globl vector150
vector150:
  pushl $0
  1023c3:	6a 00                	push   $0x0
  pushl $150
  1023c5:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1023ca:	e9 58 fa ff ff       	jmp    101e27 <__alltraps>

001023cf <vector151>:
.globl vector151
vector151:
  pushl $0
  1023cf:	6a 00                	push   $0x0
  pushl $151
  1023d1:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1023d6:	e9 4c fa ff ff       	jmp    101e27 <__alltraps>

001023db <vector152>:
.globl vector152
vector152:
  pushl $0
  1023db:	6a 00                	push   $0x0
  pushl $152
  1023dd:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1023e2:	e9 40 fa ff ff       	jmp    101e27 <__alltraps>

001023e7 <vector153>:
.globl vector153
vector153:
  pushl $0
  1023e7:	6a 00                	push   $0x0
  pushl $153
  1023e9:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1023ee:	e9 34 fa ff ff       	jmp    101e27 <__alltraps>

001023f3 <vector154>:
.globl vector154
vector154:
  pushl $0
  1023f3:	6a 00                	push   $0x0
  pushl $154
  1023f5:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1023fa:	e9 28 fa ff ff       	jmp    101e27 <__alltraps>

001023ff <vector155>:
.globl vector155
vector155:
  pushl $0
  1023ff:	6a 00                	push   $0x0
  pushl $155
  102401:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102406:	e9 1c fa ff ff       	jmp    101e27 <__alltraps>

0010240b <vector156>:
.globl vector156
vector156:
  pushl $0
  10240b:	6a 00                	push   $0x0
  pushl $156
  10240d:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102412:	e9 10 fa ff ff       	jmp    101e27 <__alltraps>

00102417 <vector157>:
.globl vector157
vector157:
  pushl $0
  102417:	6a 00                	push   $0x0
  pushl $157
  102419:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10241e:	e9 04 fa ff ff       	jmp    101e27 <__alltraps>

00102423 <vector158>:
.globl vector158
vector158:
  pushl $0
  102423:	6a 00                	push   $0x0
  pushl $158
  102425:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  10242a:	e9 f8 f9 ff ff       	jmp    101e27 <__alltraps>

0010242f <vector159>:
.globl vector159
vector159:
  pushl $0
  10242f:	6a 00                	push   $0x0
  pushl $159
  102431:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102436:	e9 ec f9 ff ff       	jmp    101e27 <__alltraps>

0010243b <vector160>:
.globl vector160
vector160:
  pushl $0
  10243b:	6a 00                	push   $0x0
  pushl $160
  10243d:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102442:	e9 e0 f9 ff ff       	jmp    101e27 <__alltraps>

00102447 <vector161>:
.globl vector161
vector161:
  pushl $0
  102447:	6a 00                	push   $0x0
  pushl $161
  102449:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10244e:	e9 d4 f9 ff ff       	jmp    101e27 <__alltraps>

00102453 <vector162>:
.globl vector162
vector162:
  pushl $0
  102453:	6a 00                	push   $0x0
  pushl $162
  102455:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  10245a:	e9 c8 f9 ff ff       	jmp    101e27 <__alltraps>

0010245f <vector163>:
.globl vector163
vector163:
  pushl $0
  10245f:	6a 00                	push   $0x0
  pushl $163
  102461:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102466:	e9 bc f9 ff ff       	jmp    101e27 <__alltraps>

0010246b <vector164>:
.globl vector164
vector164:
  pushl $0
  10246b:	6a 00                	push   $0x0
  pushl $164
  10246d:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102472:	e9 b0 f9 ff ff       	jmp    101e27 <__alltraps>

00102477 <vector165>:
.globl vector165
vector165:
  pushl $0
  102477:	6a 00                	push   $0x0
  pushl $165
  102479:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  10247e:	e9 a4 f9 ff ff       	jmp    101e27 <__alltraps>

00102483 <vector166>:
.globl vector166
vector166:
  pushl $0
  102483:	6a 00                	push   $0x0
  pushl $166
  102485:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10248a:	e9 98 f9 ff ff       	jmp    101e27 <__alltraps>

0010248f <vector167>:
.globl vector167
vector167:
  pushl $0
  10248f:	6a 00                	push   $0x0
  pushl $167
  102491:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102496:	e9 8c f9 ff ff       	jmp    101e27 <__alltraps>

0010249b <vector168>:
.globl vector168
vector168:
  pushl $0
  10249b:	6a 00                	push   $0x0
  pushl $168
  10249d:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1024a2:	e9 80 f9 ff ff       	jmp    101e27 <__alltraps>

001024a7 <vector169>:
.globl vector169
vector169:
  pushl $0
  1024a7:	6a 00                	push   $0x0
  pushl $169
  1024a9:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1024ae:	e9 74 f9 ff ff       	jmp    101e27 <__alltraps>

001024b3 <vector170>:
.globl vector170
vector170:
  pushl $0
  1024b3:	6a 00                	push   $0x0
  pushl $170
  1024b5:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1024ba:	e9 68 f9 ff ff       	jmp    101e27 <__alltraps>

001024bf <vector171>:
.globl vector171
vector171:
  pushl $0
  1024bf:	6a 00                	push   $0x0
  pushl $171
  1024c1:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1024c6:	e9 5c f9 ff ff       	jmp    101e27 <__alltraps>

001024cb <vector172>:
.globl vector172
vector172:
  pushl $0
  1024cb:	6a 00                	push   $0x0
  pushl $172
  1024cd:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1024d2:	e9 50 f9 ff ff       	jmp    101e27 <__alltraps>

001024d7 <vector173>:
.globl vector173
vector173:
  pushl $0
  1024d7:	6a 00                	push   $0x0
  pushl $173
  1024d9:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1024de:	e9 44 f9 ff ff       	jmp    101e27 <__alltraps>

001024e3 <vector174>:
.globl vector174
vector174:
  pushl $0
  1024e3:	6a 00                	push   $0x0
  pushl $174
  1024e5:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1024ea:	e9 38 f9 ff ff       	jmp    101e27 <__alltraps>

001024ef <vector175>:
.globl vector175
vector175:
  pushl $0
  1024ef:	6a 00                	push   $0x0
  pushl $175
  1024f1:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1024f6:	e9 2c f9 ff ff       	jmp    101e27 <__alltraps>

001024fb <vector176>:
.globl vector176
vector176:
  pushl $0
  1024fb:	6a 00                	push   $0x0
  pushl $176
  1024fd:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102502:	e9 20 f9 ff ff       	jmp    101e27 <__alltraps>

00102507 <vector177>:
.globl vector177
vector177:
  pushl $0
  102507:	6a 00                	push   $0x0
  pushl $177
  102509:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10250e:	e9 14 f9 ff ff       	jmp    101e27 <__alltraps>

00102513 <vector178>:
.globl vector178
vector178:
  pushl $0
  102513:	6a 00                	push   $0x0
  pushl $178
  102515:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  10251a:	e9 08 f9 ff ff       	jmp    101e27 <__alltraps>

0010251f <vector179>:
.globl vector179
vector179:
  pushl $0
  10251f:	6a 00                	push   $0x0
  pushl $179
  102521:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102526:	e9 fc f8 ff ff       	jmp    101e27 <__alltraps>

0010252b <vector180>:
.globl vector180
vector180:
  pushl $0
  10252b:	6a 00                	push   $0x0
  pushl $180
  10252d:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102532:	e9 f0 f8 ff ff       	jmp    101e27 <__alltraps>

00102537 <vector181>:
.globl vector181
vector181:
  pushl $0
  102537:	6a 00                	push   $0x0
  pushl $181
  102539:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10253e:	e9 e4 f8 ff ff       	jmp    101e27 <__alltraps>

00102543 <vector182>:
.globl vector182
vector182:
  pushl $0
  102543:	6a 00                	push   $0x0
  pushl $182
  102545:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  10254a:	e9 d8 f8 ff ff       	jmp    101e27 <__alltraps>

0010254f <vector183>:
.globl vector183
vector183:
  pushl $0
  10254f:	6a 00                	push   $0x0
  pushl $183
  102551:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102556:	e9 cc f8 ff ff       	jmp    101e27 <__alltraps>

0010255b <vector184>:
.globl vector184
vector184:
  pushl $0
  10255b:	6a 00                	push   $0x0
  pushl $184
  10255d:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102562:	e9 c0 f8 ff ff       	jmp    101e27 <__alltraps>

00102567 <vector185>:
.globl vector185
vector185:
  pushl $0
  102567:	6a 00                	push   $0x0
  pushl $185
  102569:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  10256e:	e9 b4 f8 ff ff       	jmp    101e27 <__alltraps>

00102573 <vector186>:
.globl vector186
vector186:
  pushl $0
  102573:	6a 00                	push   $0x0
  pushl $186
  102575:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  10257a:	e9 a8 f8 ff ff       	jmp    101e27 <__alltraps>

0010257f <vector187>:
.globl vector187
vector187:
  pushl $0
  10257f:	6a 00                	push   $0x0
  pushl $187
  102581:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102586:	e9 9c f8 ff ff       	jmp    101e27 <__alltraps>

0010258b <vector188>:
.globl vector188
vector188:
  pushl $0
  10258b:	6a 00                	push   $0x0
  pushl $188
  10258d:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102592:	e9 90 f8 ff ff       	jmp    101e27 <__alltraps>

00102597 <vector189>:
.globl vector189
vector189:
  pushl $0
  102597:	6a 00                	push   $0x0
  pushl $189
  102599:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  10259e:	e9 84 f8 ff ff       	jmp    101e27 <__alltraps>

001025a3 <vector190>:
.globl vector190
vector190:
  pushl $0
  1025a3:	6a 00                	push   $0x0
  pushl $190
  1025a5:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1025aa:	e9 78 f8 ff ff       	jmp    101e27 <__alltraps>

001025af <vector191>:
.globl vector191
vector191:
  pushl $0
  1025af:	6a 00                	push   $0x0
  pushl $191
  1025b1:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1025b6:	e9 6c f8 ff ff       	jmp    101e27 <__alltraps>

001025bb <vector192>:
.globl vector192
vector192:
  pushl $0
  1025bb:	6a 00                	push   $0x0
  pushl $192
  1025bd:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1025c2:	e9 60 f8 ff ff       	jmp    101e27 <__alltraps>

001025c7 <vector193>:
.globl vector193
vector193:
  pushl $0
  1025c7:	6a 00                	push   $0x0
  pushl $193
  1025c9:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1025ce:	e9 54 f8 ff ff       	jmp    101e27 <__alltraps>

001025d3 <vector194>:
.globl vector194
vector194:
  pushl $0
  1025d3:	6a 00                	push   $0x0
  pushl $194
  1025d5:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1025da:	e9 48 f8 ff ff       	jmp    101e27 <__alltraps>

001025df <vector195>:
.globl vector195
vector195:
  pushl $0
  1025df:	6a 00                	push   $0x0
  pushl $195
  1025e1:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1025e6:	e9 3c f8 ff ff       	jmp    101e27 <__alltraps>

001025eb <vector196>:
.globl vector196
vector196:
  pushl $0
  1025eb:	6a 00                	push   $0x0
  pushl $196
  1025ed:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1025f2:	e9 30 f8 ff ff       	jmp    101e27 <__alltraps>

001025f7 <vector197>:
.globl vector197
vector197:
  pushl $0
  1025f7:	6a 00                	push   $0x0
  pushl $197
  1025f9:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1025fe:	e9 24 f8 ff ff       	jmp    101e27 <__alltraps>

00102603 <vector198>:
.globl vector198
vector198:
  pushl $0
  102603:	6a 00                	push   $0x0
  pushl $198
  102605:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10260a:	e9 18 f8 ff ff       	jmp    101e27 <__alltraps>

0010260f <vector199>:
.globl vector199
vector199:
  pushl $0
  10260f:	6a 00                	push   $0x0
  pushl $199
  102611:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102616:	e9 0c f8 ff ff       	jmp    101e27 <__alltraps>

0010261b <vector200>:
.globl vector200
vector200:
  pushl $0
  10261b:	6a 00                	push   $0x0
  pushl $200
  10261d:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102622:	e9 00 f8 ff ff       	jmp    101e27 <__alltraps>

00102627 <vector201>:
.globl vector201
vector201:
  pushl $0
  102627:	6a 00                	push   $0x0
  pushl $201
  102629:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10262e:	e9 f4 f7 ff ff       	jmp    101e27 <__alltraps>

00102633 <vector202>:
.globl vector202
vector202:
  pushl $0
  102633:	6a 00                	push   $0x0
  pushl $202
  102635:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  10263a:	e9 e8 f7 ff ff       	jmp    101e27 <__alltraps>

0010263f <vector203>:
.globl vector203
vector203:
  pushl $0
  10263f:	6a 00                	push   $0x0
  pushl $203
  102641:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102646:	e9 dc f7 ff ff       	jmp    101e27 <__alltraps>

0010264b <vector204>:
.globl vector204
vector204:
  pushl $0
  10264b:	6a 00                	push   $0x0
  pushl $204
  10264d:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102652:	e9 d0 f7 ff ff       	jmp    101e27 <__alltraps>

00102657 <vector205>:
.globl vector205
vector205:
  pushl $0
  102657:	6a 00                	push   $0x0
  pushl $205
  102659:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10265e:	e9 c4 f7 ff ff       	jmp    101e27 <__alltraps>

00102663 <vector206>:
.globl vector206
vector206:
  pushl $0
  102663:	6a 00                	push   $0x0
  pushl $206
  102665:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  10266a:	e9 b8 f7 ff ff       	jmp    101e27 <__alltraps>

0010266f <vector207>:
.globl vector207
vector207:
  pushl $0
  10266f:	6a 00                	push   $0x0
  pushl $207
  102671:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102676:	e9 ac f7 ff ff       	jmp    101e27 <__alltraps>

0010267b <vector208>:
.globl vector208
vector208:
  pushl $0
  10267b:	6a 00                	push   $0x0
  pushl $208
  10267d:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102682:	e9 a0 f7 ff ff       	jmp    101e27 <__alltraps>

00102687 <vector209>:
.globl vector209
vector209:
  pushl $0
  102687:	6a 00                	push   $0x0
  pushl $209
  102689:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  10268e:	e9 94 f7 ff ff       	jmp    101e27 <__alltraps>

00102693 <vector210>:
.globl vector210
vector210:
  pushl $0
  102693:	6a 00                	push   $0x0
  pushl $210
  102695:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10269a:	e9 88 f7 ff ff       	jmp    101e27 <__alltraps>

0010269f <vector211>:
.globl vector211
vector211:
  pushl $0
  10269f:	6a 00                	push   $0x0
  pushl $211
  1026a1:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1026a6:	e9 7c f7 ff ff       	jmp    101e27 <__alltraps>

001026ab <vector212>:
.globl vector212
vector212:
  pushl $0
  1026ab:	6a 00                	push   $0x0
  pushl $212
  1026ad:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1026b2:	e9 70 f7 ff ff       	jmp    101e27 <__alltraps>

001026b7 <vector213>:
.globl vector213
vector213:
  pushl $0
  1026b7:	6a 00                	push   $0x0
  pushl $213
  1026b9:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1026be:	e9 64 f7 ff ff       	jmp    101e27 <__alltraps>

001026c3 <vector214>:
.globl vector214
vector214:
  pushl $0
  1026c3:	6a 00                	push   $0x0
  pushl $214
  1026c5:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1026ca:	e9 58 f7 ff ff       	jmp    101e27 <__alltraps>

001026cf <vector215>:
.globl vector215
vector215:
  pushl $0
  1026cf:	6a 00                	push   $0x0
  pushl $215
  1026d1:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1026d6:	e9 4c f7 ff ff       	jmp    101e27 <__alltraps>

001026db <vector216>:
.globl vector216
vector216:
  pushl $0
  1026db:	6a 00                	push   $0x0
  pushl $216
  1026dd:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1026e2:	e9 40 f7 ff ff       	jmp    101e27 <__alltraps>

001026e7 <vector217>:
.globl vector217
vector217:
  pushl $0
  1026e7:	6a 00                	push   $0x0
  pushl $217
  1026e9:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1026ee:	e9 34 f7 ff ff       	jmp    101e27 <__alltraps>

001026f3 <vector218>:
.globl vector218
vector218:
  pushl $0
  1026f3:	6a 00                	push   $0x0
  pushl $218
  1026f5:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1026fa:	e9 28 f7 ff ff       	jmp    101e27 <__alltraps>

001026ff <vector219>:
.globl vector219
vector219:
  pushl $0
  1026ff:	6a 00                	push   $0x0
  pushl $219
  102701:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102706:	e9 1c f7 ff ff       	jmp    101e27 <__alltraps>

0010270b <vector220>:
.globl vector220
vector220:
  pushl $0
  10270b:	6a 00                	push   $0x0
  pushl $220
  10270d:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102712:	e9 10 f7 ff ff       	jmp    101e27 <__alltraps>

00102717 <vector221>:
.globl vector221
vector221:
  pushl $0
  102717:	6a 00                	push   $0x0
  pushl $221
  102719:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10271e:	e9 04 f7 ff ff       	jmp    101e27 <__alltraps>

00102723 <vector222>:
.globl vector222
vector222:
  pushl $0
  102723:	6a 00                	push   $0x0
  pushl $222
  102725:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  10272a:	e9 f8 f6 ff ff       	jmp    101e27 <__alltraps>

0010272f <vector223>:
.globl vector223
vector223:
  pushl $0
  10272f:	6a 00                	push   $0x0
  pushl $223
  102731:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102736:	e9 ec f6 ff ff       	jmp    101e27 <__alltraps>

0010273b <vector224>:
.globl vector224
vector224:
  pushl $0
  10273b:	6a 00                	push   $0x0
  pushl $224
  10273d:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102742:	e9 e0 f6 ff ff       	jmp    101e27 <__alltraps>

00102747 <vector225>:
.globl vector225
vector225:
  pushl $0
  102747:	6a 00                	push   $0x0
  pushl $225
  102749:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10274e:	e9 d4 f6 ff ff       	jmp    101e27 <__alltraps>

00102753 <vector226>:
.globl vector226
vector226:
  pushl $0
  102753:	6a 00                	push   $0x0
  pushl $226
  102755:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  10275a:	e9 c8 f6 ff ff       	jmp    101e27 <__alltraps>

0010275f <vector227>:
.globl vector227
vector227:
  pushl $0
  10275f:	6a 00                	push   $0x0
  pushl $227
  102761:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102766:	e9 bc f6 ff ff       	jmp    101e27 <__alltraps>

0010276b <vector228>:
.globl vector228
vector228:
  pushl $0
  10276b:	6a 00                	push   $0x0
  pushl $228
  10276d:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102772:	e9 b0 f6 ff ff       	jmp    101e27 <__alltraps>

00102777 <vector229>:
.globl vector229
vector229:
  pushl $0
  102777:	6a 00                	push   $0x0
  pushl $229
  102779:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  10277e:	e9 a4 f6 ff ff       	jmp    101e27 <__alltraps>

00102783 <vector230>:
.globl vector230
vector230:
  pushl $0
  102783:	6a 00                	push   $0x0
  pushl $230
  102785:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  10278a:	e9 98 f6 ff ff       	jmp    101e27 <__alltraps>

0010278f <vector231>:
.globl vector231
vector231:
  pushl $0
  10278f:	6a 00                	push   $0x0
  pushl $231
  102791:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102796:	e9 8c f6 ff ff       	jmp    101e27 <__alltraps>

0010279b <vector232>:
.globl vector232
vector232:
  pushl $0
  10279b:	6a 00                	push   $0x0
  pushl $232
  10279d:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1027a2:	e9 80 f6 ff ff       	jmp    101e27 <__alltraps>

001027a7 <vector233>:
.globl vector233
vector233:
  pushl $0
  1027a7:	6a 00                	push   $0x0
  pushl $233
  1027a9:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1027ae:	e9 74 f6 ff ff       	jmp    101e27 <__alltraps>

001027b3 <vector234>:
.globl vector234
vector234:
  pushl $0
  1027b3:	6a 00                	push   $0x0
  pushl $234
  1027b5:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1027ba:	e9 68 f6 ff ff       	jmp    101e27 <__alltraps>

001027bf <vector235>:
.globl vector235
vector235:
  pushl $0
  1027bf:	6a 00                	push   $0x0
  pushl $235
  1027c1:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1027c6:	e9 5c f6 ff ff       	jmp    101e27 <__alltraps>

001027cb <vector236>:
.globl vector236
vector236:
  pushl $0
  1027cb:	6a 00                	push   $0x0
  pushl $236
  1027cd:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1027d2:	e9 50 f6 ff ff       	jmp    101e27 <__alltraps>

001027d7 <vector237>:
.globl vector237
vector237:
  pushl $0
  1027d7:	6a 00                	push   $0x0
  pushl $237
  1027d9:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1027de:	e9 44 f6 ff ff       	jmp    101e27 <__alltraps>

001027e3 <vector238>:
.globl vector238
vector238:
  pushl $0
  1027e3:	6a 00                	push   $0x0
  pushl $238
  1027e5:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1027ea:	e9 38 f6 ff ff       	jmp    101e27 <__alltraps>

001027ef <vector239>:
.globl vector239
vector239:
  pushl $0
  1027ef:	6a 00                	push   $0x0
  pushl $239
  1027f1:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1027f6:	e9 2c f6 ff ff       	jmp    101e27 <__alltraps>

001027fb <vector240>:
.globl vector240
vector240:
  pushl $0
  1027fb:	6a 00                	push   $0x0
  pushl $240
  1027fd:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102802:	e9 20 f6 ff ff       	jmp    101e27 <__alltraps>

00102807 <vector241>:
.globl vector241
vector241:
  pushl $0
  102807:	6a 00                	push   $0x0
  pushl $241
  102809:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10280e:	e9 14 f6 ff ff       	jmp    101e27 <__alltraps>

00102813 <vector242>:
.globl vector242
vector242:
  pushl $0
  102813:	6a 00                	push   $0x0
  pushl $242
  102815:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  10281a:	e9 08 f6 ff ff       	jmp    101e27 <__alltraps>

0010281f <vector243>:
.globl vector243
vector243:
  pushl $0
  10281f:	6a 00                	push   $0x0
  pushl $243
  102821:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102826:	e9 fc f5 ff ff       	jmp    101e27 <__alltraps>

0010282b <vector244>:
.globl vector244
vector244:
  pushl $0
  10282b:	6a 00                	push   $0x0
  pushl $244
  10282d:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102832:	e9 f0 f5 ff ff       	jmp    101e27 <__alltraps>

00102837 <vector245>:
.globl vector245
vector245:
  pushl $0
  102837:	6a 00                	push   $0x0
  pushl $245
  102839:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10283e:	e9 e4 f5 ff ff       	jmp    101e27 <__alltraps>

00102843 <vector246>:
.globl vector246
vector246:
  pushl $0
  102843:	6a 00                	push   $0x0
  pushl $246
  102845:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  10284a:	e9 d8 f5 ff ff       	jmp    101e27 <__alltraps>

0010284f <vector247>:
.globl vector247
vector247:
  pushl $0
  10284f:	6a 00                	push   $0x0
  pushl $247
  102851:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102856:	e9 cc f5 ff ff       	jmp    101e27 <__alltraps>

0010285b <vector248>:
.globl vector248
vector248:
  pushl $0
  10285b:	6a 00                	push   $0x0
  pushl $248
  10285d:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102862:	e9 c0 f5 ff ff       	jmp    101e27 <__alltraps>

00102867 <vector249>:
.globl vector249
vector249:
  pushl $0
  102867:	6a 00                	push   $0x0
  pushl $249
  102869:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  10286e:	e9 b4 f5 ff ff       	jmp    101e27 <__alltraps>

00102873 <vector250>:
.globl vector250
vector250:
  pushl $0
  102873:	6a 00                	push   $0x0
  pushl $250
  102875:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  10287a:	e9 a8 f5 ff ff       	jmp    101e27 <__alltraps>

0010287f <vector251>:
.globl vector251
vector251:
  pushl $0
  10287f:	6a 00                	push   $0x0
  pushl $251
  102881:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102886:	e9 9c f5 ff ff       	jmp    101e27 <__alltraps>

0010288b <vector252>:
.globl vector252
vector252:
  pushl $0
  10288b:	6a 00                	push   $0x0
  pushl $252
  10288d:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102892:	e9 90 f5 ff ff       	jmp    101e27 <__alltraps>

00102897 <vector253>:
.globl vector253
vector253:
  pushl $0
  102897:	6a 00                	push   $0x0
  pushl $253
  102899:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  10289e:	e9 84 f5 ff ff       	jmp    101e27 <__alltraps>

001028a3 <vector254>:
.globl vector254
vector254:
  pushl $0
  1028a3:	6a 00                	push   $0x0
  pushl $254
  1028a5:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1028aa:	e9 78 f5 ff ff       	jmp    101e27 <__alltraps>

001028af <vector255>:
.globl vector255
vector255:
  pushl $0
  1028af:	6a 00                	push   $0x0
  pushl $255
  1028b1:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1028b6:	e9 6c f5 ff ff       	jmp    101e27 <__alltraps>

001028bb <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1028bb:	55                   	push   %ebp
  1028bc:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1028be:	8b 55 08             	mov    0x8(%ebp),%edx
  1028c1:	a1 84 af 11 00       	mov    0x11af84,%eax
  1028c6:	29 c2                	sub    %eax,%edx
  1028c8:	89 d0                	mov    %edx,%eax
  1028ca:	c1 f8 02             	sar    $0x2,%eax
  1028cd:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1028d3:	5d                   	pop    %ebp
  1028d4:	c3                   	ret    

001028d5 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1028d5:	55                   	push   %ebp
  1028d6:	89 e5                	mov    %esp,%ebp
  1028d8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1028db:	8b 45 08             	mov    0x8(%ebp),%eax
  1028de:	89 04 24             	mov    %eax,(%esp)
  1028e1:	e8 d5 ff ff ff       	call   1028bb <page2ppn>
  1028e6:	c1 e0 0c             	shl    $0xc,%eax
}
  1028e9:	c9                   	leave  
  1028ea:	c3                   	ret    

001028eb <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  1028eb:	55                   	push   %ebp
  1028ec:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1028ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1028f1:	8b 00                	mov    (%eax),%eax
}
  1028f3:	5d                   	pop    %ebp
  1028f4:	c3                   	ret    

001028f5 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1028f5:	55                   	push   %ebp
  1028f6:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1028f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1028fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  1028fe:	89 10                	mov    %edx,(%eax)
}
  102900:	5d                   	pop    %ebp
  102901:	c3                   	ret    

00102902 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  102902:	55                   	push   %ebp
  102903:	89 e5                	mov    %esp,%ebp
  102905:	83 ec 10             	sub    $0x10,%esp
  102908:	c7 45 fc 70 af 11 00 	movl   $0x11af70,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10290f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102912:	8b 55 fc             	mov    -0x4(%ebp),%edx
  102915:	89 50 04             	mov    %edx,0x4(%eax)
  102918:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10291b:	8b 50 04             	mov    0x4(%eax),%edx
  10291e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102921:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  102923:	c7 05 78 af 11 00 00 	movl   $0x0,0x11af78
  10292a:	00 00 00 
}
  10292d:	c9                   	leave  
  10292e:	c3                   	ret    

0010292f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  10292f:	55                   	push   %ebp
  102930:	89 e5                	mov    %esp,%ebp
  102932:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  102935:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102939:	75 24                	jne    10295f <default_init_memmap+0x30>
  10293b:	c7 44 24 0c 30 67 10 	movl   $0x106730,0xc(%esp)
  102942:	00 
  102943:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10294a:	00 
  10294b:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  102952:	00 
  102953:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10295a:	e8 73 e3 ff ff       	call   100cd2 <__panic>
    struct Page *p = base;
  10295f:	8b 45 08             	mov    0x8(%ebp),%eax
  102962:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102965:	eb 7d                	jmp    1029e4 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  102967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10296a:	83 c0 04             	add    $0x4,%eax
  10296d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  102974:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102977:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10297a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10297d:	0f a3 10             	bt     %edx,(%eax)
  102980:	19 c0                	sbb    %eax,%eax
  102982:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  102985:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102989:	0f 95 c0             	setne  %al
  10298c:	0f b6 c0             	movzbl %al,%eax
  10298f:	85 c0                	test   %eax,%eax
  102991:	75 24                	jne    1029b7 <default_init_memmap+0x88>
  102993:	c7 44 24 0c 61 67 10 	movl   $0x106761,0xc(%esp)
  10299a:	00 
  10299b:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1029a2:	00 
  1029a3:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  1029aa:	00 
  1029ab:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1029b2:	e8 1b e3 ff ff       	call   100cd2 <__panic>
        p->flags = p->property = 0;
  1029b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1029c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029c4:	8b 50 08             	mov    0x8(%eax),%edx
  1029c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029ca:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  1029cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1029d4:	00 
  1029d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029d8:	89 04 24             	mov    %eax,(%esp)
  1029db:	e8 15 ff ff ff       	call   1028f5 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  1029e0:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1029e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029e7:	89 d0                	mov    %edx,%eax
  1029e9:	c1 e0 02             	shl    $0x2,%eax
  1029ec:	01 d0                	add    %edx,%eax
  1029ee:	c1 e0 02             	shl    $0x2,%eax
  1029f1:	89 c2                	mov    %eax,%edx
  1029f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f6:	01 d0                	add    %edx,%eax
  1029f8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1029fb:	0f 85 66 ff ff ff    	jne    102967 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  102a01:	8b 45 08             	mov    0x8(%ebp),%eax
  102a04:	8b 55 0c             	mov    0xc(%ebp),%edx
  102a07:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  102a0d:	83 c0 04             	add    $0x4,%eax
  102a10:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  102a17:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102a1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102a1d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102a20:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  102a23:	8b 15 78 af 11 00    	mov    0x11af78,%edx
  102a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a2c:	01 d0                	add    %edx,%eax
  102a2e:	a3 78 af 11 00       	mov    %eax,0x11af78
    list_add_before(&free_list, &(base->page_link));
  102a33:	8b 45 08             	mov    0x8(%ebp),%eax
  102a36:	83 c0 0c             	add    $0xc,%eax
  102a39:	c7 45 dc 70 af 11 00 	movl   $0x11af70,-0x24(%ebp)
  102a40:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102a43:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a46:	8b 00                	mov    (%eax),%eax
  102a48:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102a4b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102a4e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102a51:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a54:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102a57:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a5a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102a5d:	89 10                	mov    %edx,(%eax)
  102a5f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a62:	8b 10                	mov    (%eax),%edx
  102a64:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102a67:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102a6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a6d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102a70:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102a73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a76:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102a79:	89 10                	mov    %edx,(%eax)
}
  102a7b:	c9                   	leave  
  102a7c:	c3                   	ret    

00102a7d <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  102a7d:	55                   	push   %ebp
  102a7e:	89 e5                	mov    %esp,%ebp
  102a80:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102a83:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a87:	75 24                	jne    102aad <default_alloc_pages+0x30>
  102a89:	c7 44 24 0c 30 67 10 	movl   $0x106730,0xc(%esp)
  102a90:	00 
  102a91:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102a98:	00 
  102a99:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  102aa0:	00 
  102aa1:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102aa8:	e8 25 e2 ff ff       	call   100cd2 <__panic>
    if (n > nr_free) {
  102aad:	a1 78 af 11 00       	mov    0x11af78,%eax
  102ab2:	3b 45 08             	cmp    0x8(%ebp),%eax
  102ab5:	73 0a                	jae    102ac1 <default_alloc_pages+0x44>
        return NULL;
  102ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  102abc:	e9 3d 01 00 00       	jmp    102bfe <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
  102ac1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  102ac8:	c7 45 f0 70 af 11 00 	movl   $0x11af70,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  102acf:	eb 1c                	jmp    102aed <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  102ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ad4:	83 e8 0c             	sub    $0xc,%eax
  102ad7:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  102ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102add:	8b 40 08             	mov    0x8(%eax),%eax
  102ae0:	3b 45 08             	cmp    0x8(%ebp),%eax
  102ae3:	72 08                	jb     102aed <default_alloc_pages+0x70>
            page = p;
  102ae5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ae8:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102aeb:	eb 18                	jmp    102b05 <default_alloc_pages+0x88>
  102aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102af0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102af3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102af6:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  102af9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102afc:	81 7d f0 70 af 11 00 	cmpl   $0x11af70,-0x10(%ebp)
  102b03:	75 cc                	jne    102ad1 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
  102b05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102b09:	0f 84 ec 00 00 00    	je     102bfb <default_alloc_pages+0x17e>
        if (page->property > n) {
  102b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b12:	8b 40 08             	mov    0x8(%eax),%eax
  102b15:	3b 45 08             	cmp    0x8(%ebp),%eax
  102b18:	0f 86 8c 00 00 00    	jbe    102baa <default_alloc_pages+0x12d>
            struct Page *p = page + n;
  102b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  102b21:	89 d0                	mov    %edx,%eax
  102b23:	c1 e0 02             	shl    $0x2,%eax
  102b26:	01 d0                	add    %edx,%eax
  102b28:	c1 e0 02             	shl    $0x2,%eax
  102b2b:	89 c2                	mov    %eax,%edx
  102b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b30:	01 d0                	add    %edx,%eax
  102b32:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  102b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b38:	8b 40 08             	mov    0x8(%eax),%eax
  102b3b:	2b 45 08             	sub    0x8(%ebp),%eax
  102b3e:	89 c2                	mov    %eax,%edx
  102b40:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b43:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  102b46:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b49:	83 c0 04             	add    $0x4,%eax
  102b4c:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102b53:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102b56:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102b59:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102b5c:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
  102b5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b62:	83 c0 0c             	add    $0xc,%eax
  102b65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b68:	83 c2 0c             	add    $0xc,%edx
  102b6b:	89 55 d8             	mov    %edx,-0x28(%ebp)
  102b6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102b71:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102b74:	8b 40 04             	mov    0x4(%eax),%eax
  102b77:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102b7a:	89 55 d0             	mov    %edx,-0x30(%ebp)
  102b7d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102b80:	89 55 cc             	mov    %edx,-0x34(%ebp)
  102b83:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102b86:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b89:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102b8c:	89 10                	mov    %edx,(%eax)
  102b8e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b91:	8b 10                	mov    (%eax),%edx
  102b93:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b96:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102b99:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102b9c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102b9f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102ba2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102ba5:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102ba8:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
  102baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bad:	83 c0 0c             	add    $0xc,%eax
  102bb0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102bb3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102bb6:	8b 40 04             	mov    0x4(%eax),%eax
  102bb9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102bbc:	8b 12                	mov    (%edx),%edx
  102bbe:	89 55 c0             	mov    %edx,-0x40(%ebp)
  102bc1:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102bc4:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102bc7:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102bca:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102bcd:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102bd0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102bd3:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
  102bd5:	a1 78 af 11 00       	mov    0x11af78,%eax
  102bda:	2b 45 08             	sub    0x8(%ebp),%eax
  102bdd:	a3 78 af 11 00       	mov    %eax,0x11af78
        ClearPageProperty(page);
  102be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102be5:	83 c0 04             	add    $0x4,%eax
  102be8:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102bef:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102bf2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102bf5:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102bf8:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  102bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102bfe:	c9                   	leave  
  102bff:	c3                   	ret    

00102c00 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102c00:	55                   	push   %ebp
  102c01:	89 e5                	mov    %esp,%ebp
  102c03:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102c09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102c0d:	75 24                	jne    102c33 <default_free_pages+0x33>
  102c0f:	c7 44 24 0c 30 67 10 	movl   $0x106730,0xc(%esp)
  102c16:	00 
  102c17:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102c1e:	00 
  102c1f:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  102c26:	00 
  102c27:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102c2e:	e8 9f e0 ff ff       	call   100cd2 <__panic>
    struct Page *p = base;
  102c33:	8b 45 08             	mov    0x8(%ebp),%eax
  102c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102c39:	e9 9d 00 00 00       	jmp    102cdb <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c41:	83 c0 04             	add    $0x4,%eax
  102c44:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102c4b:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102c4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c51:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102c54:	0f a3 10             	bt     %edx,(%eax)
  102c57:	19 c0                	sbb    %eax,%eax
  102c59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102c5c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102c60:	0f 95 c0             	setne  %al
  102c63:	0f b6 c0             	movzbl %al,%eax
  102c66:	85 c0                	test   %eax,%eax
  102c68:	75 2c                	jne    102c96 <default_free_pages+0x96>
  102c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c6d:	83 c0 04             	add    $0x4,%eax
  102c70:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102c77:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102c7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c7d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102c80:	0f a3 10             	bt     %edx,(%eax)
  102c83:	19 c0                	sbb    %eax,%eax
  102c85:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102c88:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102c8c:	0f 95 c0             	setne  %al
  102c8f:	0f b6 c0             	movzbl %al,%eax
  102c92:	85 c0                	test   %eax,%eax
  102c94:	74 24                	je     102cba <default_free_pages+0xba>
  102c96:	c7 44 24 0c 74 67 10 	movl   $0x106774,0xc(%esp)
  102c9d:	00 
  102c9e:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102ca5:	00 
  102ca6:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  102cad:	00 
  102cae:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102cb5:	e8 18 e0 ff ff       	call   100cd2 <__panic>
        p->flags = 0;
  102cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cbd:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102cc4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102ccb:	00 
  102ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ccf:	89 04 24             	mov    %eax,(%esp)
  102cd2:	e8 1e fc ff ff       	call   1028f5 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102cd7:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102cdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  102cde:	89 d0                	mov    %edx,%eax
  102ce0:	c1 e0 02             	shl    $0x2,%eax
  102ce3:	01 d0                	add    %edx,%eax
  102ce5:	c1 e0 02             	shl    $0x2,%eax
  102ce8:	89 c2                	mov    %eax,%edx
  102cea:	8b 45 08             	mov    0x8(%ebp),%eax
  102ced:	01 d0                	add    %edx,%eax
  102cef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102cf2:	0f 85 46 ff ff ff    	jne    102c3e <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  102cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  102cfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  102cfe:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102d01:	8b 45 08             	mov    0x8(%ebp),%eax
  102d04:	83 c0 04             	add    $0x4,%eax
  102d07:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102d0e:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d11:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102d14:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102d17:	0f ab 10             	bts    %edx,(%eax)
  102d1a:	c7 45 cc 70 af 11 00 	movl   $0x11af70,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102d21:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102d24:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  102d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102d2a:	e9 08 01 00 00       	jmp    102e37 <default_free_pages+0x237>
        p = le2page(le, page_link);
  102d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d32:	83 e8 0c             	sub    $0xc,%eax
  102d35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d3b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102d3e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102d41:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102d44:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  102d47:	8b 45 08             	mov    0x8(%ebp),%eax
  102d4a:	8b 50 08             	mov    0x8(%eax),%edx
  102d4d:	89 d0                	mov    %edx,%eax
  102d4f:	c1 e0 02             	shl    $0x2,%eax
  102d52:	01 d0                	add    %edx,%eax
  102d54:	c1 e0 02             	shl    $0x2,%eax
  102d57:	89 c2                	mov    %eax,%edx
  102d59:	8b 45 08             	mov    0x8(%ebp),%eax
  102d5c:	01 d0                	add    %edx,%eax
  102d5e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102d61:	75 5a                	jne    102dbd <default_free_pages+0x1bd>
            base->property += p->property;
  102d63:	8b 45 08             	mov    0x8(%ebp),%eax
  102d66:	8b 50 08             	mov    0x8(%eax),%edx
  102d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d6c:	8b 40 08             	mov    0x8(%eax),%eax
  102d6f:	01 c2                	add    %eax,%edx
  102d71:	8b 45 08             	mov    0x8(%ebp),%eax
  102d74:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d7a:	83 c0 04             	add    $0x4,%eax
  102d7d:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102d84:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d87:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102d8a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102d8d:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  102d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d93:	83 c0 0c             	add    $0xc,%eax
  102d96:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102d99:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102d9c:	8b 40 04             	mov    0x4(%eax),%eax
  102d9f:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102da2:	8b 12                	mov    (%edx),%edx
  102da4:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102da7:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102daa:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102dad:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102db0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102db3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102db6:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102db9:	89 10                	mov    %edx,(%eax)
  102dbb:	eb 7a                	jmp    102e37 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  102dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dc0:	8b 50 08             	mov    0x8(%eax),%edx
  102dc3:	89 d0                	mov    %edx,%eax
  102dc5:	c1 e0 02             	shl    $0x2,%eax
  102dc8:	01 d0                	add    %edx,%eax
  102dca:	c1 e0 02             	shl    $0x2,%eax
  102dcd:	89 c2                	mov    %eax,%edx
  102dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dd2:	01 d0                	add    %edx,%eax
  102dd4:	3b 45 08             	cmp    0x8(%ebp),%eax
  102dd7:	75 5e                	jne    102e37 <default_free_pages+0x237>
            p->property += base->property;
  102dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ddc:	8b 50 08             	mov    0x8(%eax),%edx
  102ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  102de2:	8b 40 08             	mov    0x8(%eax),%eax
  102de5:	01 c2                	add    %eax,%edx
  102de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dea:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102ded:	8b 45 08             	mov    0x8(%ebp),%eax
  102df0:	83 c0 04             	add    $0x4,%eax
  102df3:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  102dfa:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102dfd:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102e00:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102e03:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  102e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e09:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e0f:	83 c0 0c             	add    $0xc,%eax
  102e12:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102e15:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102e18:	8b 40 04             	mov    0x4(%eax),%eax
  102e1b:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102e1e:	8b 12                	mov    (%edx),%edx
  102e20:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102e23:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102e26:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102e29:	8b 55 a0             	mov    -0x60(%ebp),%edx
  102e2c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102e2f:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102e32:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102e35:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  102e37:	81 7d f0 70 af 11 00 	cmpl   $0x11af70,-0x10(%ebp)
  102e3e:	0f 85 eb fe ff ff    	jne    102d2f <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  102e44:	8b 15 78 af 11 00    	mov    0x11af78,%edx
  102e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e4d:	01 d0                	add    %edx,%eax
  102e4f:	a3 78 af 11 00       	mov    %eax,0x11af78
  102e54:	c7 45 9c 70 af 11 00 	movl   $0x11af70,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102e5b:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102e5e:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
  102e61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102e64:	eb 76                	jmp    102edc <default_free_pages+0x2dc>
        p = le2page(le, page_link);
  102e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e69:	83 e8 0c             	sub    $0xc,%eax
  102e6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  102e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  102e72:	8b 50 08             	mov    0x8(%eax),%edx
  102e75:	89 d0                	mov    %edx,%eax
  102e77:	c1 e0 02             	shl    $0x2,%eax
  102e7a:	01 d0                	add    %edx,%eax
  102e7c:	c1 e0 02             	shl    $0x2,%eax
  102e7f:	89 c2                	mov    %eax,%edx
  102e81:	8b 45 08             	mov    0x8(%ebp),%eax
  102e84:	01 d0                	add    %edx,%eax
  102e86:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102e89:	77 42                	ja     102ecd <default_free_pages+0x2cd>
            assert(base + base->property != p);
  102e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  102e8e:	8b 50 08             	mov    0x8(%eax),%edx
  102e91:	89 d0                	mov    %edx,%eax
  102e93:	c1 e0 02             	shl    $0x2,%eax
  102e96:	01 d0                	add    %edx,%eax
  102e98:	c1 e0 02             	shl    $0x2,%eax
  102e9b:	89 c2                	mov    %eax,%edx
  102e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea0:	01 d0                	add    %edx,%eax
  102ea2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102ea5:	75 24                	jne    102ecb <default_free_pages+0x2cb>
  102ea7:	c7 44 24 0c 99 67 10 	movl   $0x106799,0xc(%esp)
  102eae:	00 
  102eaf:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102eb6:	00 
  102eb7:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  102ebe:	00 
  102ebf:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102ec6:	e8 07 de ff ff       	call   100cd2 <__panic>
            break;
  102ecb:	eb 18                	jmp    102ee5 <default_free_pages+0x2e5>
  102ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ed0:	89 45 98             	mov    %eax,-0x68(%ebp)
  102ed3:	8b 45 98             	mov    -0x68(%ebp),%eax
  102ed6:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
  102ed9:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
  102edc:	81 7d f0 70 af 11 00 	cmpl   $0x11af70,-0x10(%ebp)
  102ee3:	75 81                	jne    102e66 <default_free_pages+0x266>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
  102ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  102ee8:	8d 50 0c             	lea    0xc(%eax),%edx
  102eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102eee:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102ef1:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102ef4:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102ef7:	8b 00                	mov    (%eax),%eax
  102ef9:	8b 55 90             	mov    -0x70(%ebp),%edx
  102efc:	89 55 8c             	mov    %edx,-0x74(%ebp)
  102eff:	89 45 88             	mov    %eax,-0x78(%ebp)
  102f02:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102f05:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102f08:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102f0b:	8b 55 8c             	mov    -0x74(%ebp),%edx
  102f0e:	89 10                	mov    %edx,(%eax)
  102f10:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102f13:	8b 10                	mov    (%eax),%edx
  102f15:	8b 45 88             	mov    -0x78(%ebp),%eax
  102f18:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102f1b:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102f1e:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102f21:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102f24:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102f27:	8b 55 88             	mov    -0x78(%ebp),%edx
  102f2a:	89 10                	mov    %edx,(%eax)
}
  102f2c:	c9                   	leave  
  102f2d:	c3                   	ret    

00102f2e <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  102f2e:	55                   	push   %ebp
  102f2f:	89 e5                	mov    %esp,%ebp
    return nr_free;
  102f31:	a1 78 af 11 00       	mov    0x11af78,%eax
}
  102f36:	5d                   	pop    %ebp
  102f37:	c3                   	ret    

00102f38 <basic_check>:

static void
basic_check(void) {
  102f38:	55                   	push   %ebp
  102f39:	89 e5                	mov    %esp,%ebp
  102f3b:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  102f3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f48:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  102f51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f58:	e8 9d 0e 00 00       	call   103dfa <alloc_pages>
  102f5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102f60:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  102f64:	75 24                	jne    102f8a <basic_check+0x52>
  102f66:	c7 44 24 0c b4 67 10 	movl   $0x1067b4,0xc(%esp)
  102f6d:	00 
  102f6e:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102f75:	00 
  102f76:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  102f7d:	00 
  102f7e:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102f85:	e8 48 dd ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
  102f8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f91:	e8 64 0e 00 00       	call   103dfa <alloc_pages>
  102f96:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102f9d:	75 24                	jne    102fc3 <basic_check+0x8b>
  102f9f:	c7 44 24 0c d0 67 10 	movl   $0x1067d0,0xc(%esp)
  102fa6:	00 
  102fa7:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102fae:	00 
  102faf:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
  102fb6:	00 
  102fb7:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102fbe:	e8 0f dd ff ff       	call   100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
  102fc3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102fca:	e8 2b 0e 00 00       	call   103dfa <alloc_pages>
  102fcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102fd2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102fd6:	75 24                	jne    102ffc <basic_check+0xc4>
  102fd8:	c7 44 24 0c ec 67 10 	movl   $0x1067ec,0xc(%esp)
  102fdf:	00 
  102fe0:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102fe7:	00 
  102fe8:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  102fef:	00 
  102ff0:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102ff7:	e8 d6 dc ff ff       	call   100cd2 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  102ffc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103002:	74 10                	je     103014 <basic_check+0xdc>
  103004:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103007:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10300a:	74 08                	je     103014 <basic_check+0xdc>
  10300c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10300f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103012:	75 24                	jne    103038 <basic_check+0x100>
  103014:	c7 44 24 0c 08 68 10 	movl   $0x106808,0xc(%esp)
  10301b:	00 
  10301c:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103023:	00 
  103024:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  10302b:	00 
  10302c:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103033:	e8 9a dc ff ff       	call   100cd2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  103038:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10303b:	89 04 24             	mov    %eax,(%esp)
  10303e:	e8 a8 f8 ff ff       	call   1028eb <page_ref>
  103043:	85 c0                	test   %eax,%eax
  103045:	75 1e                	jne    103065 <basic_check+0x12d>
  103047:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10304a:	89 04 24             	mov    %eax,(%esp)
  10304d:	e8 99 f8 ff ff       	call   1028eb <page_ref>
  103052:	85 c0                	test   %eax,%eax
  103054:	75 0f                	jne    103065 <basic_check+0x12d>
  103056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103059:	89 04 24             	mov    %eax,(%esp)
  10305c:	e8 8a f8 ff ff       	call   1028eb <page_ref>
  103061:	85 c0                	test   %eax,%eax
  103063:	74 24                	je     103089 <basic_check+0x151>
  103065:	c7 44 24 0c 2c 68 10 	movl   $0x10682c,0xc(%esp)
  10306c:	00 
  10306d:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103074:	00 
  103075:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  10307c:	00 
  10307d:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103084:	e8 49 dc ff ff       	call   100cd2 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  103089:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10308c:	89 04 24             	mov    %eax,(%esp)
  10308f:	e8 41 f8 ff ff       	call   1028d5 <page2pa>
  103094:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  10309a:	c1 e2 0c             	shl    $0xc,%edx
  10309d:	39 d0                	cmp    %edx,%eax
  10309f:	72 24                	jb     1030c5 <basic_check+0x18d>
  1030a1:	c7 44 24 0c 68 68 10 	movl   $0x106868,0xc(%esp)
  1030a8:	00 
  1030a9:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1030b0:	00 
  1030b1:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  1030b8:	00 
  1030b9:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1030c0:	e8 0d dc ff ff       	call   100cd2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1030c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030c8:	89 04 24             	mov    %eax,(%esp)
  1030cb:	e8 05 f8 ff ff       	call   1028d5 <page2pa>
  1030d0:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1030d6:	c1 e2 0c             	shl    $0xc,%edx
  1030d9:	39 d0                	cmp    %edx,%eax
  1030db:	72 24                	jb     103101 <basic_check+0x1c9>
  1030dd:	c7 44 24 0c 85 68 10 	movl   $0x106885,0xc(%esp)
  1030e4:	00 
  1030e5:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1030ec:	00 
  1030ed:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  1030f4:	00 
  1030f5:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1030fc:	e8 d1 db ff ff       	call   100cd2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  103101:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103104:	89 04 24             	mov    %eax,(%esp)
  103107:	e8 c9 f7 ff ff       	call   1028d5 <page2pa>
  10310c:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  103112:	c1 e2 0c             	shl    $0xc,%edx
  103115:	39 d0                	cmp    %edx,%eax
  103117:	72 24                	jb     10313d <basic_check+0x205>
  103119:	c7 44 24 0c a2 68 10 	movl   $0x1068a2,0xc(%esp)
  103120:	00 
  103121:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103128:	00 
  103129:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  103130:	00 
  103131:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103138:	e8 95 db ff ff       	call   100cd2 <__panic>

    list_entry_t free_list_store = free_list;
  10313d:	a1 70 af 11 00       	mov    0x11af70,%eax
  103142:	8b 15 74 af 11 00    	mov    0x11af74,%edx
  103148:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10314b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10314e:	c7 45 e0 70 af 11 00 	movl   $0x11af70,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  103155:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103158:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10315b:	89 50 04             	mov    %edx,0x4(%eax)
  10315e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103161:	8b 50 04             	mov    0x4(%eax),%edx
  103164:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103167:	89 10                	mov    %edx,(%eax)
  103169:	c7 45 dc 70 af 11 00 	movl   $0x11af70,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103170:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103173:	8b 40 04             	mov    0x4(%eax),%eax
  103176:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103179:	0f 94 c0             	sete   %al
  10317c:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  10317f:	85 c0                	test   %eax,%eax
  103181:	75 24                	jne    1031a7 <basic_check+0x26f>
  103183:	c7 44 24 0c bf 68 10 	movl   $0x1068bf,0xc(%esp)
  10318a:	00 
  10318b:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103192:	00 
  103193:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  10319a:	00 
  10319b:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1031a2:	e8 2b db ff ff       	call   100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
  1031a7:	a1 78 af 11 00       	mov    0x11af78,%eax
  1031ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  1031af:	c7 05 78 af 11 00 00 	movl   $0x0,0x11af78
  1031b6:	00 00 00 

    assert(alloc_page() == NULL);
  1031b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031c0:	e8 35 0c 00 00       	call   103dfa <alloc_pages>
  1031c5:	85 c0                	test   %eax,%eax
  1031c7:	74 24                	je     1031ed <basic_check+0x2b5>
  1031c9:	c7 44 24 0c d6 68 10 	movl   $0x1068d6,0xc(%esp)
  1031d0:	00 
  1031d1:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1031d8:	00 
  1031d9:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  1031e0:	00 
  1031e1:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1031e8:	e8 e5 da ff ff       	call   100cd2 <__panic>

    free_page(p0);
  1031ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1031f4:	00 
  1031f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031f8:	89 04 24             	mov    %eax,(%esp)
  1031fb:	e8 32 0c 00 00       	call   103e32 <free_pages>
    free_page(p1);
  103200:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103207:	00 
  103208:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10320b:	89 04 24             	mov    %eax,(%esp)
  10320e:	e8 1f 0c 00 00       	call   103e32 <free_pages>
    free_page(p2);
  103213:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10321a:	00 
  10321b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10321e:	89 04 24             	mov    %eax,(%esp)
  103221:	e8 0c 0c 00 00       	call   103e32 <free_pages>
    assert(nr_free == 3);
  103226:	a1 78 af 11 00       	mov    0x11af78,%eax
  10322b:	83 f8 03             	cmp    $0x3,%eax
  10322e:	74 24                	je     103254 <basic_check+0x31c>
  103230:	c7 44 24 0c eb 68 10 	movl   $0x1068eb,0xc(%esp)
  103237:	00 
  103238:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10323f:	00 
  103240:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  103247:	00 
  103248:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10324f:	e8 7e da ff ff       	call   100cd2 <__panic>

    assert((p0 = alloc_page()) != NULL);
  103254:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10325b:	e8 9a 0b 00 00       	call   103dfa <alloc_pages>
  103260:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103263:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103267:	75 24                	jne    10328d <basic_check+0x355>
  103269:	c7 44 24 0c b4 67 10 	movl   $0x1067b4,0xc(%esp)
  103270:	00 
  103271:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103278:	00 
  103279:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  103280:	00 
  103281:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103288:	e8 45 da ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
  10328d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103294:	e8 61 0b 00 00       	call   103dfa <alloc_pages>
  103299:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10329c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1032a0:	75 24                	jne    1032c6 <basic_check+0x38e>
  1032a2:	c7 44 24 0c d0 67 10 	movl   $0x1067d0,0xc(%esp)
  1032a9:	00 
  1032aa:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1032b1:	00 
  1032b2:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  1032b9:	00 
  1032ba:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1032c1:	e8 0c da ff ff       	call   100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1032c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032cd:	e8 28 0b 00 00       	call   103dfa <alloc_pages>
  1032d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1032d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1032d9:	75 24                	jne    1032ff <basic_check+0x3c7>
  1032db:	c7 44 24 0c ec 67 10 	movl   $0x1067ec,0xc(%esp)
  1032e2:	00 
  1032e3:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1032ea:	00 
  1032eb:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  1032f2:	00 
  1032f3:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1032fa:	e8 d3 d9 ff ff       	call   100cd2 <__panic>

    assert(alloc_page() == NULL);
  1032ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103306:	e8 ef 0a 00 00       	call   103dfa <alloc_pages>
  10330b:	85 c0                	test   %eax,%eax
  10330d:	74 24                	je     103333 <basic_check+0x3fb>
  10330f:	c7 44 24 0c d6 68 10 	movl   $0x1068d6,0xc(%esp)
  103316:	00 
  103317:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10331e:	00 
  10331f:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  103326:	00 
  103327:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10332e:	e8 9f d9 ff ff       	call   100cd2 <__panic>

    free_page(p0);
  103333:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10333a:	00 
  10333b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10333e:	89 04 24             	mov    %eax,(%esp)
  103341:	e8 ec 0a 00 00       	call   103e32 <free_pages>
  103346:	c7 45 d8 70 af 11 00 	movl   $0x11af70,-0x28(%ebp)
  10334d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103350:	8b 40 04             	mov    0x4(%eax),%eax
  103353:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  103356:	0f 94 c0             	sete   %al
  103359:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  10335c:	85 c0                	test   %eax,%eax
  10335e:	74 24                	je     103384 <basic_check+0x44c>
  103360:	c7 44 24 0c f8 68 10 	movl   $0x1068f8,0xc(%esp)
  103367:	00 
  103368:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10336f:	00 
  103370:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  103377:	00 
  103378:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10337f:	e8 4e d9 ff ff       	call   100cd2 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  103384:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10338b:	e8 6a 0a 00 00       	call   103dfa <alloc_pages>
  103390:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103393:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103396:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103399:	74 24                	je     1033bf <basic_check+0x487>
  10339b:	c7 44 24 0c 10 69 10 	movl   $0x106910,0xc(%esp)
  1033a2:	00 
  1033a3:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1033aa:	00 
  1033ab:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
  1033b2:	00 
  1033b3:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1033ba:	e8 13 d9 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  1033bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033c6:	e8 2f 0a 00 00       	call   103dfa <alloc_pages>
  1033cb:	85 c0                	test   %eax,%eax
  1033cd:	74 24                	je     1033f3 <basic_check+0x4bb>
  1033cf:	c7 44 24 0c d6 68 10 	movl   $0x1068d6,0xc(%esp)
  1033d6:	00 
  1033d7:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1033de:	00 
  1033df:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  1033e6:	00 
  1033e7:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1033ee:	e8 df d8 ff ff       	call   100cd2 <__panic>

    assert(nr_free == 0);
  1033f3:	a1 78 af 11 00       	mov    0x11af78,%eax
  1033f8:	85 c0                	test   %eax,%eax
  1033fa:	74 24                	je     103420 <basic_check+0x4e8>
  1033fc:	c7 44 24 0c 29 69 10 	movl   $0x106929,0xc(%esp)
  103403:	00 
  103404:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10340b:	00 
  10340c:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  103413:	00 
  103414:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10341b:	e8 b2 d8 ff ff       	call   100cd2 <__panic>
    free_list = free_list_store;
  103420:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103423:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103426:	a3 70 af 11 00       	mov    %eax,0x11af70
  10342b:	89 15 74 af 11 00    	mov    %edx,0x11af74
    nr_free = nr_free_store;
  103431:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103434:	a3 78 af 11 00       	mov    %eax,0x11af78

    free_page(p);
  103439:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103440:	00 
  103441:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103444:	89 04 24             	mov    %eax,(%esp)
  103447:	e8 e6 09 00 00       	call   103e32 <free_pages>
    free_page(p1);
  10344c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103453:	00 
  103454:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103457:	89 04 24             	mov    %eax,(%esp)
  10345a:	e8 d3 09 00 00       	call   103e32 <free_pages>
    free_page(p2);
  10345f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103466:	00 
  103467:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10346a:	89 04 24             	mov    %eax,(%esp)
  10346d:	e8 c0 09 00 00       	call   103e32 <free_pages>
}
  103472:	c9                   	leave  
  103473:	c3                   	ret    

00103474 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  103474:	55                   	push   %ebp
  103475:	89 e5                	mov    %esp,%ebp
  103477:	53                   	push   %ebx
  103478:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  10347e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103485:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  10348c:	c7 45 ec 70 af 11 00 	movl   $0x11af70,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103493:	eb 6b                	jmp    103500 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  103495:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103498:	83 e8 0c             	sub    $0xc,%eax
  10349b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  10349e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034a1:	83 c0 04             	add    $0x4,%eax
  1034a4:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1034ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1034ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1034b1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1034b4:	0f a3 10             	bt     %edx,(%eax)
  1034b7:	19 c0                	sbb    %eax,%eax
  1034b9:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  1034bc:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  1034c0:	0f 95 c0             	setne  %al
  1034c3:	0f b6 c0             	movzbl %al,%eax
  1034c6:	85 c0                	test   %eax,%eax
  1034c8:	75 24                	jne    1034ee <default_check+0x7a>
  1034ca:	c7 44 24 0c 36 69 10 	movl   $0x106936,0xc(%esp)
  1034d1:	00 
  1034d2:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1034d9:	00 
  1034da:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  1034e1:	00 
  1034e2:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1034e9:	e8 e4 d7 ff ff       	call   100cd2 <__panic>
        count ++, total += p->property;
  1034ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1034f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034f5:	8b 50 08             	mov    0x8(%eax),%edx
  1034f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034fb:	01 d0                	add    %edx,%eax
  1034fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103500:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103503:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  103506:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103509:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  10350c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10350f:	81 7d ec 70 af 11 00 	cmpl   $0x11af70,-0x14(%ebp)
  103516:	0f 85 79 ff ff ff    	jne    103495 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  10351c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  10351f:	e8 40 09 00 00       	call   103e64 <nr_free_pages>
  103524:	39 c3                	cmp    %eax,%ebx
  103526:	74 24                	je     10354c <default_check+0xd8>
  103528:	c7 44 24 0c 46 69 10 	movl   $0x106946,0xc(%esp)
  10352f:	00 
  103530:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103537:	00 
  103538:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  10353f:	00 
  103540:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103547:	e8 86 d7 ff ff       	call   100cd2 <__panic>

    basic_check();
  10354c:	e8 e7 f9 ff ff       	call   102f38 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  103551:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103558:	e8 9d 08 00 00       	call   103dfa <alloc_pages>
  10355d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  103560:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103564:	75 24                	jne    10358a <default_check+0x116>
  103566:	c7 44 24 0c 5f 69 10 	movl   $0x10695f,0xc(%esp)
  10356d:	00 
  10356e:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103575:	00 
  103576:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  10357d:	00 
  10357e:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103585:	e8 48 d7 ff ff       	call   100cd2 <__panic>
    assert(!PageProperty(p0));
  10358a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10358d:	83 c0 04             	add    $0x4,%eax
  103590:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  103597:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10359a:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10359d:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1035a0:	0f a3 10             	bt     %edx,(%eax)
  1035a3:	19 c0                	sbb    %eax,%eax
  1035a5:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1035a8:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1035ac:	0f 95 c0             	setne  %al
  1035af:	0f b6 c0             	movzbl %al,%eax
  1035b2:	85 c0                	test   %eax,%eax
  1035b4:	74 24                	je     1035da <default_check+0x166>
  1035b6:	c7 44 24 0c 6a 69 10 	movl   $0x10696a,0xc(%esp)
  1035bd:	00 
  1035be:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1035c5:	00 
  1035c6:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  1035cd:	00 
  1035ce:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1035d5:	e8 f8 d6 ff ff       	call   100cd2 <__panic>

    list_entry_t free_list_store = free_list;
  1035da:	a1 70 af 11 00       	mov    0x11af70,%eax
  1035df:	8b 15 74 af 11 00    	mov    0x11af74,%edx
  1035e5:	89 45 80             	mov    %eax,-0x80(%ebp)
  1035e8:	89 55 84             	mov    %edx,-0x7c(%ebp)
  1035eb:	c7 45 b4 70 af 11 00 	movl   $0x11af70,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1035f2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1035f5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1035f8:	89 50 04             	mov    %edx,0x4(%eax)
  1035fb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1035fe:	8b 50 04             	mov    0x4(%eax),%edx
  103601:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103604:	89 10                	mov    %edx,(%eax)
  103606:	c7 45 b0 70 af 11 00 	movl   $0x11af70,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  10360d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103610:	8b 40 04             	mov    0x4(%eax),%eax
  103613:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  103616:	0f 94 c0             	sete   %al
  103619:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  10361c:	85 c0                	test   %eax,%eax
  10361e:	75 24                	jne    103644 <default_check+0x1d0>
  103620:	c7 44 24 0c bf 68 10 	movl   $0x1068bf,0xc(%esp)
  103627:	00 
  103628:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10362f:	00 
  103630:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  103637:	00 
  103638:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10363f:	e8 8e d6 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  103644:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10364b:	e8 aa 07 00 00       	call   103dfa <alloc_pages>
  103650:	85 c0                	test   %eax,%eax
  103652:	74 24                	je     103678 <default_check+0x204>
  103654:	c7 44 24 0c d6 68 10 	movl   $0x1068d6,0xc(%esp)
  10365b:	00 
  10365c:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103663:	00 
  103664:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  10366b:	00 
  10366c:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103673:	e8 5a d6 ff ff       	call   100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
  103678:	a1 78 af 11 00       	mov    0x11af78,%eax
  10367d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  103680:	c7 05 78 af 11 00 00 	movl   $0x0,0x11af78
  103687:	00 00 00 

    free_pages(p0 + 2, 3);
  10368a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10368d:	83 c0 28             	add    $0x28,%eax
  103690:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  103697:	00 
  103698:	89 04 24             	mov    %eax,(%esp)
  10369b:	e8 92 07 00 00       	call   103e32 <free_pages>
    assert(alloc_pages(4) == NULL);
  1036a0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1036a7:	e8 4e 07 00 00       	call   103dfa <alloc_pages>
  1036ac:	85 c0                	test   %eax,%eax
  1036ae:	74 24                	je     1036d4 <default_check+0x260>
  1036b0:	c7 44 24 0c 7c 69 10 	movl   $0x10697c,0xc(%esp)
  1036b7:	00 
  1036b8:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1036bf:	00 
  1036c0:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  1036c7:	00 
  1036c8:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1036cf:	e8 fe d5 ff ff       	call   100cd2 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1036d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036d7:	83 c0 28             	add    $0x28,%eax
  1036da:	83 c0 04             	add    $0x4,%eax
  1036dd:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1036e4:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1036e7:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1036ea:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1036ed:	0f a3 10             	bt     %edx,(%eax)
  1036f0:	19 c0                	sbb    %eax,%eax
  1036f2:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1036f5:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1036f9:	0f 95 c0             	setne  %al
  1036fc:	0f b6 c0             	movzbl %al,%eax
  1036ff:	85 c0                	test   %eax,%eax
  103701:	74 0e                	je     103711 <default_check+0x29d>
  103703:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103706:	83 c0 28             	add    $0x28,%eax
  103709:	8b 40 08             	mov    0x8(%eax),%eax
  10370c:	83 f8 03             	cmp    $0x3,%eax
  10370f:	74 24                	je     103735 <default_check+0x2c1>
  103711:	c7 44 24 0c 94 69 10 	movl   $0x106994,0xc(%esp)
  103718:	00 
  103719:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103720:	00 
  103721:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
  103728:	00 
  103729:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103730:	e8 9d d5 ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  103735:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  10373c:	e8 b9 06 00 00       	call   103dfa <alloc_pages>
  103741:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103744:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103748:	75 24                	jne    10376e <default_check+0x2fa>
  10374a:	c7 44 24 0c c0 69 10 	movl   $0x1069c0,0xc(%esp)
  103751:	00 
  103752:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103759:	00 
  10375a:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  103761:	00 
  103762:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103769:	e8 64 d5 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  10376e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103775:	e8 80 06 00 00       	call   103dfa <alloc_pages>
  10377a:	85 c0                	test   %eax,%eax
  10377c:	74 24                	je     1037a2 <default_check+0x32e>
  10377e:	c7 44 24 0c d6 68 10 	movl   $0x1068d6,0xc(%esp)
  103785:	00 
  103786:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10378d:	00 
  10378e:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  103795:	00 
  103796:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10379d:	e8 30 d5 ff ff       	call   100cd2 <__panic>
    assert(p0 + 2 == p1);
  1037a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037a5:	83 c0 28             	add    $0x28,%eax
  1037a8:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1037ab:	74 24                	je     1037d1 <default_check+0x35d>
  1037ad:	c7 44 24 0c de 69 10 	movl   $0x1069de,0xc(%esp)
  1037b4:	00 
  1037b5:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1037bc:	00 
  1037bd:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  1037c4:	00 
  1037c5:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1037cc:	e8 01 d5 ff ff       	call   100cd2 <__panic>

    p2 = p0 + 1;
  1037d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037d4:	83 c0 14             	add    $0x14,%eax
  1037d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  1037da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1037e1:	00 
  1037e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037e5:	89 04 24             	mov    %eax,(%esp)
  1037e8:	e8 45 06 00 00       	call   103e32 <free_pages>
    free_pages(p1, 3);
  1037ed:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1037f4:	00 
  1037f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1037f8:	89 04 24             	mov    %eax,(%esp)
  1037fb:	e8 32 06 00 00       	call   103e32 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  103800:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103803:	83 c0 04             	add    $0x4,%eax
  103806:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  10380d:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103810:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103813:	8b 55 a0             	mov    -0x60(%ebp),%edx
  103816:	0f a3 10             	bt     %edx,(%eax)
  103819:	19 c0                	sbb    %eax,%eax
  10381b:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  10381e:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  103822:	0f 95 c0             	setne  %al
  103825:	0f b6 c0             	movzbl %al,%eax
  103828:	85 c0                	test   %eax,%eax
  10382a:	74 0b                	je     103837 <default_check+0x3c3>
  10382c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10382f:	8b 40 08             	mov    0x8(%eax),%eax
  103832:	83 f8 01             	cmp    $0x1,%eax
  103835:	74 24                	je     10385b <default_check+0x3e7>
  103837:	c7 44 24 0c ec 69 10 	movl   $0x1069ec,0xc(%esp)
  10383e:	00 
  10383f:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103846:	00 
  103847:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  10384e:	00 
  10384f:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103856:	e8 77 d4 ff ff       	call   100cd2 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  10385b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10385e:	83 c0 04             	add    $0x4,%eax
  103861:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  103868:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10386b:	8b 45 90             	mov    -0x70(%ebp),%eax
  10386e:	8b 55 94             	mov    -0x6c(%ebp),%edx
  103871:	0f a3 10             	bt     %edx,(%eax)
  103874:	19 c0                	sbb    %eax,%eax
  103876:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  103879:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  10387d:	0f 95 c0             	setne  %al
  103880:	0f b6 c0             	movzbl %al,%eax
  103883:	85 c0                	test   %eax,%eax
  103885:	74 0b                	je     103892 <default_check+0x41e>
  103887:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10388a:	8b 40 08             	mov    0x8(%eax),%eax
  10388d:	83 f8 03             	cmp    $0x3,%eax
  103890:	74 24                	je     1038b6 <default_check+0x442>
  103892:	c7 44 24 0c 14 6a 10 	movl   $0x106a14,0xc(%esp)
  103899:	00 
  10389a:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1038a1:	00 
  1038a2:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  1038a9:	00 
  1038aa:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1038b1:	e8 1c d4 ff ff       	call   100cd2 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1038b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1038bd:	e8 38 05 00 00       	call   103dfa <alloc_pages>
  1038c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1038c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1038c8:	83 e8 14             	sub    $0x14,%eax
  1038cb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1038ce:	74 24                	je     1038f4 <default_check+0x480>
  1038d0:	c7 44 24 0c 3a 6a 10 	movl   $0x106a3a,0xc(%esp)
  1038d7:	00 
  1038d8:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1038df:	00 
  1038e0:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  1038e7:	00 
  1038e8:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1038ef:	e8 de d3 ff ff       	call   100cd2 <__panic>
    free_page(p0);
  1038f4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1038fb:	00 
  1038fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1038ff:	89 04 24             	mov    %eax,(%esp)
  103902:	e8 2b 05 00 00       	call   103e32 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  103907:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10390e:	e8 e7 04 00 00       	call   103dfa <alloc_pages>
  103913:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103916:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103919:	83 c0 14             	add    $0x14,%eax
  10391c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10391f:	74 24                	je     103945 <default_check+0x4d1>
  103921:	c7 44 24 0c 58 6a 10 	movl   $0x106a58,0xc(%esp)
  103928:	00 
  103929:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103930:	00 
  103931:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  103938:	00 
  103939:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103940:	e8 8d d3 ff ff       	call   100cd2 <__panic>

    free_pages(p0, 2);
  103945:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10394c:	00 
  10394d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103950:	89 04 24             	mov    %eax,(%esp)
  103953:	e8 da 04 00 00       	call   103e32 <free_pages>
    free_page(p2);
  103958:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10395f:	00 
  103960:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103963:	89 04 24             	mov    %eax,(%esp)
  103966:	e8 c7 04 00 00       	call   103e32 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  10396b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103972:	e8 83 04 00 00       	call   103dfa <alloc_pages>
  103977:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10397a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10397e:	75 24                	jne    1039a4 <default_check+0x530>
  103980:	c7 44 24 0c 78 6a 10 	movl   $0x106a78,0xc(%esp)
  103987:	00 
  103988:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10398f:	00 
  103990:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  103997:	00 
  103998:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10399f:	e8 2e d3 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  1039a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1039ab:	e8 4a 04 00 00       	call   103dfa <alloc_pages>
  1039b0:	85 c0                	test   %eax,%eax
  1039b2:	74 24                	je     1039d8 <default_check+0x564>
  1039b4:	c7 44 24 0c d6 68 10 	movl   $0x1068d6,0xc(%esp)
  1039bb:	00 
  1039bc:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1039c3:	00 
  1039c4:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  1039cb:	00 
  1039cc:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1039d3:	e8 fa d2 ff ff       	call   100cd2 <__panic>

    assert(nr_free == 0);
  1039d8:	a1 78 af 11 00       	mov    0x11af78,%eax
  1039dd:	85 c0                	test   %eax,%eax
  1039df:	74 24                	je     103a05 <default_check+0x591>
  1039e1:	c7 44 24 0c 29 69 10 	movl   $0x106929,0xc(%esp)
  1039e8:	00 
  1039e9:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1039f0:	00 
  1039f1:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  1039f8:	00 
  1039f9:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103a00:	e8 cd d2 ff ff       	call   100cd2 <__panic>
    nr_free = nr_free_store;
  103a05:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103a08:	a3 78 af 11 00       	mov    %eax,0x11af78

    free_list = free_list_store;
  103a0d:	8b 45 80             	mov    -0x80(%ebp),%eax
  103a10:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103a13:	a3 70 af 11 00       	mov    %eax,0x11af70
  103a18:	89 15 74 af 11 00    	mov    %edx,0x11af74
    free_pages(p0, 5);
  103a1e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  103a25:	00 
  103a26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a29:	89 04 24             	mov    %eax,(%esp)
  103a2c:	e8 01 04 00 00       	call   103e32 <free_pages>

    le = &free_list;
  103a31:	c7 45 ec 70 af 11 00 	movl   $0x11af70,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103a38:	eb 1d                	jmp    103a57 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
  103a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a3d:	83 e8 0c             	sub    $0xc,%eax
  103a40:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  103a43:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  103a47:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103a4a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103a4d:	8b 40 08             	mov    0x8(%eax),%eax
  103a50:	29 c2                	sub    %eax,%edx
  103a52:	89 d0                	mov    %edx,%eax
  103a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a57:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a5a:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  103a5d:	8b 45 88             	mov    -0x78(%ebp),%eax
  103a60:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  103a63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103a66:	81 7d ec 70 af 11 00 	cmpl   $0x11af70,-0x14(%ebp)
  103a6d:	75 cb                	jne    103a3a <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  103a6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103a73:	74 24                	je     103a99 <default_check+0x625>
  103a75:	c7 44 24 0c 96 6a 10 	movl   $0x106a96,0xc(%esp)
  103a7c:	00 
  103a7d:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103a84:	00 
  103a85:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
  103a8c:	00 
  103a8d:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103a94:	e8 39 d2 ff ff       	call   100cd2 <__panic>
    assert(total == 0);
  103a99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a9d:	74 24                	je     103ac3 <default_check+0x64f>
  103a9f:	c7 44 24 0c a1 6a 10 	movl   $0x106aa1,0xc(%esp)
  103aa6:	00 
  103aa7:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103aae:	00 
  103aaf:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
  103ab6:	00 
  103ab7:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103abe:	e8 0f d2 ff ff       	call   100cd2 <__panic>
}
  103ac3:	81 c4 94 00 00 00    	add    $0x94,%esp
  103ac9:	5b                   	pop    %ebx
  103aca:	5d                   	pop    %ebp
  103acb:	c3                   	ret    

00103acc <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  103acc:	55                   	push   %ebp
  103acd:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103acf:	8b 55 08             	mov    0x8(%ebp),%edx
  103ad2:	a1 84 af 11 00       	mov    0x11af84,%eax
  103ad7:	29 c2                	sub    %eax,%edx
  103ad9:	89 d0                	mov    %edx,%eax
  103adb:	c1 f8 02             	sar    $0x2,%eax
  103ade:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103ae4:	5d                   	pop    %ebp
  103ae5:	c3                   	ret    

00103ae6 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  103ae6:	55                   	push   %ebp
  103ae7:	89 e5                	mov    %esp,%ebp
  103ae9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103aec:	8b 45 08             	mov    0x8(%ebp),%eax
  103aef:	89 04 24             	mov    %eax,(%esp)
  103af2:	e8 d5 ff ff ff       	call   103acc <page2ppn>
  103af7:	c1 e0 0c             	shl    $0xc,%eax
}
  103afa:	c9                   	leave  
  103afb:	c3                   	ret    

00103afc <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  103afc:	55                   	push   %ebp
  103afd:	89 e5                	mov    %esp,%ebp
  103aff:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103b02:	8b 45 08             	mov    0x8(%ebp),%eax
  103b05:	c1 e8 0c             	shr    $0xc,%eax
  103b08:	89 c2                	mov    %eax,%edx
  103b0a:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103b0f:	39 c2                	cmp    %eax,%edx
  103b11:	72 1c                	jb     103b2f <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103b13:	c7 44 24 08 dc 6a 10 	movl   $0x106adc,0x8(%esp)
  103b1a:	00 
  103b1b:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103b22:	00 
  103b23:	c7 04 24 fb 6a 10 00 	movl   $0x106afb,(%esp)
  103b2a:	e8 a3 d1 ff ff       	call   100cd2 <__panic>
    }
    return &pages[PPN(pa)];
  103b2f:	8b 0d 84 af 11 00    	mov    0x11af84,%ecx
  103b35:	8b 45 08             	mov    0x8(%ebp),%eax
  103b38:	c1 e8 0c             	shr    $0xc,%eax
  103b3b:	89 c2                	mov    %eax,%edx
  103b3d:	89 d0                	mov    %edx,%eax
  103b3f:	c1 e0 02             	shl    $0x2,%eax
  103b42:	01 d0                	add    %edx,%eax
  103b44:	c1 e0 02             	shl    $0x2,%eax
  103b47:	01 c8                	add    %ecx,%eax
}
  103b49:	c9                   	leave  
  103b4a:	c3                   	ret    

00103b4b <page2kva>:

static inline void *
page2kva(struct Page *page) {
  103b4b:	55                   	push   %ebp
  103b4c:	89 e5                	mov    %esp,%ebp
  103b4e:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103b51:	8b 45 08             	mov    0x8(%ebp),%eax
  103b54:	89 04 24             	mov    %eax,(%esp)
  103b57:	e8 8a ff ff ff       	call   103ae6 <page2pa>
  103b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b62:	c1 e8 0c             	shr    $0xc,%eax
  103b65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b68:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103b6d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103b70:	72 23                	jb     103b95 <page2kva+0x4a>
  103b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103b79:	c7 44 24 08 0c 6b 10 	movl   $0x106b0c,0x8(%esp)
  103b80:	00 
  103b81:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103b88:	00 
  103b89:	c7 04 24 fb 6a 10 00 	movl   $0x106afb,(%esp)
  103b90:	e8 3d d1 ff ff       	call   100cd2 <__panic>
  103b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b98:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103b9d:	c9                   	leave  
  103b9e:	c3                   	ret    

00103b9f <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  103b9f:	55                   	push   %ebp
  103ba0:	89 e5                	mov    %esp,%ebp
  103ba2:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  103ba8:	83 e0 01             	and    $0x1,%eax
  103bab:	85 c0                	test   %eax,%eax
  103bad:	75 1c                	jne    103bcb <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103baf:	c7 44 24 08 30 6b 10 	movl   $0x106b30,0x8(%esp)
  103bb6:	00 
  103bb7:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103bbe:	00 
  103bbf:	c7 04 24 fb 6a 10 00 	movl   $0x106afb,(%esp)
  103bc6:	e8 07 d1 ff ff       	call   100cd2 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  103bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  103bce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103bd3:	89 04 24             	mov    %eax,(%esp)
  103bd6:	e8 21 ff ff ff       	call   103afc <pa2page>
}
  103bdb:	c9                   	leave  
  103bdc:	c3                   	ret    

00103bdd <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  103bdd:	55                   	push   %ebp
  103bde:	89 e5                	mov    %esp,%ebp
  103be0:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103be3:	8b 45 08             	mov    0x8(%ebp),%eax
  103be6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103beb:	89 04 24             	mov    %eax,(%esp)
  103bee:	e8 09 ff ff ff       	call   103afc <pa2page>
}
  103bf3:	c9                   	leave  
  103bf4:	c3                   	ret    

00103bf5 <page_ref>:

static inline int
page_ref(struct Page *page) {
  103bf5:	55                   	push   %ebp
  103bf6:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  103bfb:	8b 00                	mov    (%eax),%eax
}
  103bfd:	5d                   	pop    %ebp
  103bfe:	c3                   	ret    

00103bff <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  103bff:	55                   	push   %ebp
  103c00:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103c02:	8b 45 08             	mov    0x8(%ebp),%eax
  103c05:	8b 55 0c             	mov    0xc(%ebp),%edx
  103c08:	89 10                	mov    %edx,(%eax)
}
  103c0a:	5d                   	pop    %ebp
  103c0b:	c3                   	ret    

00103c0c <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103c0c:	55                   	push   %ebp
  103c0d:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  103c12:	8b 00                	mov    (%eax),%eax
  103c14:	8d 50 01             	lea    0x1(%eax),%edx
  103c17:	8b 45 08             	mov    0x8(%ebp),%eax
  103c1a:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  103c1f:	8b 00                	mov    (%eax),%eax
}
  103c21:	5d                   	pop    %ebp
  103c22:	c3                   	ret    

00103c23 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103c23:	55                   	push   %ebp
  103c24:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103c26:	8b 45 08             	mov    0x8(%ebp),%eax
  103c29:	8b 00                	mov    (%eax),%eax
  103c2b:	8d 50 ff             	lea    -0x1(%eax),%edx
  103c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  103c31:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103c33:	8b 45 08             	mov    0x8(%ebp),%eax
  103c36:	8b 00                	mov    (%eax),%eax
}
  103c38:	5d                   	pop    %ebp
  103c39:	c3                   	ret    

00103c3a <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  103c3a:	55                   	push   %ebp
  103c3b:	89 e5                	mov    %esp,%ebp
  103c3d:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103c40:	9c                   	pushf  
  103c41:	58                   	pop    %eax
  103c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103c48:	25 00 02 00 00       	and    $0x200,%eax
  103c4d:	85 c0                	test   %eax,%eax
  103c4f:	74 0c                	je     103c5d <__intr_save+0x23>
        intr_disable();
  103c51:	e8 70 da ff ff       	call   1016c6 <intr_disable>
        return 1;
  103c56:	b8 01 00 00 00       	mov    $0x1,%eax
  103c5b:	eb 05                	jmp    103c62 <__intr_save+0x28>
    }
    return 0;
  103c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103c62:	c9                   	leave  
  103c63:	c3                   	ret    

00103c64 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  103c64:	55                   	push   %ebp
  103c65:	89 e5                	mov    %esp,%ebp
  103c67:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103c6a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103c6e:	74 05                	je     103c75 <__intr_restore+0x11>
        intr_enable();
  103c70:	e8 4b da ff ff       	call   1016c0 <intr_enable>
    }
}
  103c75:	c9                   	leave  
  103c76:	c3                   	ret    

00103c77 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103c77:	55                   	push   %ebp
  103c78:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  103c7d:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103c80:	b8 23 00 00 00       	mov    $0x23,%eax
  103c85:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103c87:	b8 23 00 00 00       	mov    $0x23,%eax
  103c8c:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103c8e:	b8 10 00 00 00       	mov    $0x10,%eax
  103c93:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103c95:	b8 10 00 00 00       	mov    $0x10,%eax
  103c9a:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103c9c:	b8 10 00 00 00       	mov    $0x10,%eax
  103ca1:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103ca3:	ea aa 3c 10 00 08 00 	ljmp   $0x8,$0x103caa
}
  103caa:	5d                   	pop    %ebp
  103cab:	c3                   	ret    

00103cac <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103cac:	55                   	push   %ebp
  103cad:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103caf:	8b 45 08             	mov    0x8(%ebp),%eax
  103cb2:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  103cb7:	5d                   	pop    %ebp
  103cb8:	c3                   	ret    

00103cb9 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103cb9:	55                   	push   %ebp
  103cba:	89 e5                	mov    %esp,%ebp
  103cbc:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103cbf:	b8 00 70 11 00       	mov    $0x117000,%eax
  103cc4:	89 04 24             	mov    %eax,(%esp)
  103cc7:	e8 e0 ff ff ff       	call   103cac <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103ccc:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  103cd3:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103cd5:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  103cdc:	68 00 
  103cde:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103ce3:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  103ce9:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103cee:	c1 e8 10             	shr    $0x10,%eax
  103cf1:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  103cf6:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103cfd:	83 e0 f0             	and    $0xfffffff0,%eax
  103d00:	83 c8 09             	or     $0x9,%eax
  103d03:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103d08:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103d0f:	83 e0 ef             	and    $0xffffffef,%eax
  103d12:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103d17:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103d1e:	83 e0 9f             	and    $0xffffff9f,%eax
  103d21:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103d26:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103d2d:	83 c8 80             	or     $0xffffff80,%eax
  103d30:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103d35:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d3c:	83 e0 f0             	and    $0xfffffff0,%eax
  103d3f:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d44:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d4b:	83 e0 ef             	and    $0xffffffef,%eax
  103d4e:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d53:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d5a:	83 e0 df             	and    $0xffffffdf,%eax
  103d5d:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d62:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d69:	83 c8 40             	or     $0x40,%eax
  103d6c:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d71:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d78:	83 e0 7f             	and    $0x7f,%eax
  103d7b:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d80:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103d85:	c1 e8 18             	shr    $0x18,%eax
  103d88:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103d8d:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  103d94:	e8 de fe ff ff       	call   103c77 <lgdt>
  103d99:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103d9f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103da3:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  103da6:	c9                   	leave  
  103da7:	c3                   	ret    

00103da8 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103da8:	55                   	push   %ebp
  103da9:	89 e5                	mov    %esp,%ebp
  103dab:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103dae:	c7 05 7c af 11 00 c0 	movl   $0x106ac0,0x11af7c
  103db5:	6a 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103db8:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103dbd:	8b 00                	mov    (%eax),%eax
  103dbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  103dc3:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  103dca:	e8 79 c5 ff ff       	call   100348 <cprintf>
    pmm_manager->init();
  103dcf:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103dd4:	8b 40 04             	mov    0x4(%eax),%eax
  103dd7:	ff d0                	call   *%eax
}
  103dd9:	c9                   	leave  
  103dda:	c3                   	ret    

00103ddb <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103ddb:	55                   	push   %ebp
  103ddc:	89 e5                	mov    %esp,%ebp
  103dde:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103de1:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103de6:	8b 40 08             	mov    0x8(%eax),%eax
  103de9:	8b 55 0c             	mov    0xc(%ebp),%edx
  103dec:	89 54 24 04          	mov    %edx,0x4(%esp)
  103df0:	8b 55 08             	mov    0x8(%ebp),%edx
  103df3:	89 14 24             	mov    %edx,(%esp)
  103df6:	ff d0                	call   *%eax
}
  103df8:	c9                   	leave  
  103df9:	c3                   	ret    

00103dfa <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103dfa:	55                   	push   %ebp
  103dfb:	89 e5                	mov    %esp,%ebp
  103dfd:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103e00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103e07:	e8 2e fe ff ff       	call   103c3a <__intr_save>
  103e0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103e0f:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103e14:	8b 40 0c             	mov    0xc(%eax),%eax
  103e17:	8b 55 08             	mov    0x8(%ebp),%edx
  103e1a:	89 14 24             	mov    %edx,(%esp)
  103e1d:	ff d0                	call   *%eax
  103e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e25:	89 04 24             	mov    %eax,(%esp)
  103e28:	e8 37 fe ff ff       	call   103c64 <__intr_restore>
    return page;
  103e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103e30:	c9                   	leave  
  103e31:	c3                   	ret    

00103e32 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103e32:	55                   	push   %ebp
  103e33:	89 e5                	mov    %esp,%ebp
  103e35:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103e38:	e8 fd fd ff ff       	call   103c3a <__intr_save>
  103e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103e40:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103e45:	8b 40 10             	mov    0x10(%eax),%eax
  103e48:	8b 55 0c             	mov    0xc(%ebp),%edx
  103e4b:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  103e52:	89 14 24             	mov    %edx,(%esp)
  103e55:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e5a:	89 04 24             	mov    %eax,(%esp)
  103e5d:	e8 02 fe ff ff       	call   103c64 <__intr_restore>
}
  103e62:	c9                   	leave  
  103e63:	c3                   	ret    

00103e64 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103e64:	55                   	push   %ebp
  103e65:	89 e5                	mov    %esp,%ebp
  103e67:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103e6a:	e8 cb fd ff ff       	call   103c3a <__intr_save>
  103e6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103e72:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103e77:	8b 40 14             	mov    0x14(%eax),%eax
  103e7a:	ff d0                	call   *%eax
  103e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e82:	89 04 24             	mov    %eax,(%esp)
  103e85:	e8 da fd ff ff       	call   103c64 <__intr_restore>
    return ret;
  103e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103e8d:	c9                   	leave  
  103e8e:	c3                   	ret    

00103e8f <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103e8f:	55                   	push   %ebp
  103e90:	89 e5                	mov    %esp,%ebp
  103e92:	57                   	push   %edi
  103e93:	56                   	push   %esi
  103e94:	53                   	push   %ebx
  103e95:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103e9b:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103ea2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103ea9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103eb0:	c7 04 24 73 6b 10 00 	movl   $0x106b73,(%esp)
  103eb7:	e8 8c c4 ff ff       	call   100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103ebc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103ec3:	e9 15 01 00 00       	jmp    103fdd <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103ec8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ecb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103ece:	89 d0                	mov    %edx,%eax
  103ed0:	c1 e0 02             	shl    $0x2,%eax
  103ed3:	01 d0                	add    %edx,%eax
  103ed5:	c1 e0 02             	shl    $0x2,%eax
  103ed8:	01 c8                	add    %ecx,%eax
  103eda:	8b 50 08             	mov    0x8(%eax),%edx
  103edd:	8b 40 04             	mov    0x4(%eax),%eax
  103ee0:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103ee3:	89 55 bc             	mov    %edx,-0x44(%ebp)
  103ee6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ee9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103eec:	89 d0                	mov    %edx,%eax
  103eee:	c1 e0 02             	shl    $0x2,%eax
  103ef1:	01 d0                	add    %edx,%eax
  103ef3:	c1 e0 02             	shl    $0x2,%eax
  103ef6:	01 c8                	add    %ecx,%eax
  103ef8:	8b 48 0c             	mov    0xc(%eax),%ecx
  103efb:	8b 58 10             	mov    0x10(%eax),%ebx
  103efe:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103f01:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103f04:	01 c8                	add    %ecx,%eax
  103f06:	11 da                	adc    %ebx,%edx
  103f08:	89 45 b0             	mov    %eax,-0x50(%ebp)
  103f0b:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  103f0e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f11:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f14:	89 d0                	mov    %edx,%eax
  103f16:	c1 e0 02             	shl    $0x2,%eax
  103f19:	01 d0                	add    %edx,%eax
  103f1b:	c1 e0 02             	shl    $0x2,%eax
  103f1e:	01 c8                	add    %ecx,%eax
  103f20:	83 c0 14             	add    $0x14,%eax
  103f23:	8b 00                	mov    (%eax),%eax
  103f25:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  103f2b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103f2e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103f31:	83 c0 ff             	add    $0xffffffff,%eax
  103f34:	83 d2 ff             	adc    $0xffffffff,%edx
  103f37:	89 c6                	mov    %eax,%esi
  103f39:	89 d7                	mov    %edx,%edi
  103f3b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f3e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f41:	89 d0                	mov    %edx,%eax
  103f43:	c1 e0 02             	shl    $0x2,%eax
  103f46:	01 d0                	add    %edx,%eax
  103f48:	c1 e0 02             	shl    $0x2,%eax
  103f4b:	01 c8                	add    %ecx,%eax
  103f4d:	8b 48 0c             	mov    0xc(%eax),%ecx
  103f50:	8b 58 10             	mov    0x10(%eax),%ebx
  103f53:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  103f59:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  103f5d:	89 74 24 14          	mov    %esi,0x14(%esp)
  103f61:	89 7c 24 18          	mov    %edi,0x18(%esp)
  103f65:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103f68:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103f6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103f6f:	89 54 24 10          	mov    %edx,0x10(%esp)
  103f73:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103f77:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  103f7b:	c7 04 24 80 6b 10 00 	movl   $0x106b80,(%esp)
  103f82:	e8 c1 c3 ff ff       	call   100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  103f87:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f8a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f8d:	89 d0                	mov    %edx,%eax
  103f8f:	c1 e0 02             	shl    $0x2,%eax
  103f92:	01 d0                	add    %edx,%eax
  103f94:	c1 e0 02             	shl    $0x2,%eax
  103f97:	01 c8                	add    %ecx,%eax
  103f99:	83 c0 14             	add    $0x14,%eax
  103f9c:	8b 00                	mov    (%eax),%eax
  103f9e:	83 f8 01             	cmp    $0x1,%eax
  103fa1:	75 36                	jne    103fd9 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  103fa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103fa6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103fa9:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103fac:	77 2b                	ja     103fd9 <page_init+0x14a>
  103fae:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103fb1:	72 05                	jb     103fb8 <page_init+0x129>
  103fb3:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  103fb6:	73 21                	jae    103fd9 <page_init+0x14a>
  103fb8:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103fbc:	77 1b                	ja     103fd9 <page_init+0x14a>
  103fbe:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103fc2:	72 09                	jb     103fcd <page_init+0x13e>
  103fc4:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  103fcb:	77 0c                	ja     103fd9 <page_init+0x14a>
                maxpa = end;
  103fcd:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103fd0:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103fd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103fd6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103fd9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103fdd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103fe0:	8b 00                	mov    (%eax),%eax
  103fe2:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103fe5:	0f 8f dd fe ff ff    	jg     103ec8 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  103feb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103fef:	72 1d                	jb     10400e <page_init+0x17f>
  103ff1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103ff5:	77 09                	ja     104000 <page_init+0x171>
  103ff7:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  103ffe:	76 0e                	jbe    10400e <page_init+0x17f>
        maxpa = KMEMSIZE;
  104000:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  104007:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  10400e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104011:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104014:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104018:	c1 ea 0c             	shr    $0xc,%edx
  10401b:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  104020:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  104027:	b8 88 af 11 00       	mov    $0x11af88,%eax
  10402c:	8d 50 ff             	lea    -0x1(%eax),%edx
  10402f:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104032:	01 d0                	add    %edx,%eax
  104034:	89 45 a8             	mov    %eax,-0x58(%ebp)
  104037:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10403a:	ba 00 00 00 00       	mov    $0x0,%edx
  10403f:	f7 75 ac             	divl   -0x54(%ebp)
  104042:	89 d0                	mov    %edx,%eax
  104044:	8b 55 a8             	mov    -0x58(%ebp),%edx
  104047:	29 c2                	sub    %eax,%edx
  104049:	89 d0                	mov    %edx,%eax
  10404b:	a3 84 af 11 00       	mov    %eax,0x11af84

    for (i = 0; i < npage; i ++) {
  104050:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104057:	eb 2f                	jmp    104088 <page_init+0x1f9>
        SetPageReserved(pages + i);
  104059:	8b 0d 84 af 11 00    	mov    0x11af84,%ecx
  10405f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104062:	89 d0                	mov    %edx,%eax
  104064:	c1 e0 02             	shl    $0x2,%eax
  104067:	01 d0                	add    %edx,%eax
  104069:	c1 e0 02             	shl    $0x2,%eax
  10406c:	01 c8                	add    %ecx,%eax
  10406e:	83 c0 04             	add    $0x4,%eax
  104071:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  104078:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10407b:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10407e:	8b 55 90             	mov    -0x70(%ebp),%edx
  104081:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  104084:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104088:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10408b:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104090:	39 c2                	cmp    %eax,%edx
  104092:	72 c5                	jb     104059 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  104094:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  10409a:	89 d0                	mov    %edx,%eax
  10409c:	c1 e0 02             	shl    $0x2,%eax
  10409f:	01 d0                	add    %edx,%eax
  1040a1:	c1 e0 02             	shl    $0x2,%eax
  1040a4:	89 c2                	mov    %eax,%edx
  1040a6:	a1 84 af 11 00       	mov    0x11af84,%eax
  1040ab:	01 d0                	add    %edx,%eax
  1040ad:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  1040b0:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  1040b7:	77 23                	ja     1040dc <page_init+0x24d>
  1040b9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1040bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1040c0:	c7 44 24 08 b0 6b 10 	movl   $0x106bb0,0x8(%esp)
  1040c7:	00 
  1040c8:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  1040cf:	00 
  1040d0:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1040d7:	e8 f6 cb ff ff       	call   100cd2 <__panic>
  1040dc:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1040df:	05 00 00 00 40       	add    $0x40000000,%eax
  1040e4:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  1040e7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1040ee:	e9 74 01 00 00       	jmp    104267 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  1040f3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040f9:	89 d0                	mov    %edx,%eax
  1040fb:	c1 e0 02             	shl    $0x2,%eax
  1040fe:	01 d0                	add    %edx,%eax
  104100:	c1 e0 02             	shl    $0x2,%eax
  104103:	01 c8                	add    %ecx,%eax
  104105:	8b 50 08             	mov    0x8(%eax),%edx
  104108:	8b 40 04             	mov    0x4(%eax),%eax
  10410b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10410e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104111:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104114:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104117:	89 d0                	mov    %edx,%eax
  104119:	c1 e0 02             	shl    $0x2,%eax
  10411c:	01 d0                	add    %edx,%eax
  10411e:	c1 e0 02             	shl    $0x2,%eax
  104121:	01 c8                	add    %ecx,%eax
  104123:	8b 48 0c             	mov    0xc(%eax),%ecx
  104126:	8b 58 10             	mov    0x10(%eax),%ebx
  104129:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10412c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10412f:	01 c8                	add    %ecx,%eax
  104131:	11 da                	adc    %ebx,%edx
  104133:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104136:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  104139:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10413c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10413f:	89 d0                	mov    %edx,%eax
  104141:	c1 e0 02             	shl    $0x2,%eax
  104144:	01 d0                	add    %edx,%eax
  104146:	c1 e0 02             	shl    $0x2,%eax
  104149:	01 c8                	add    %ecx,%eax
  10414b:	83 c0 14             	add    $0x14,%eax
  10414e:	8b 00                	mov    (%eax),%eax
  104150:	83 f8 01             	cmp    $0x1,%eax
  104153:	0f 85 0a 01 00 00    	jne    104263 <page_init+0x3d4>
            if (begin < freemem) {
  104159:	8b 45 a0             	mov    -0x60(%ebp),%eax
  10415c:	ba 00 00 00 00       	mov    $0x0,%edx
  104161:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104164:	72 17                	jb     10417d <page_init+0x2ee>
  104166:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104169:	77 05                	ja     104170 <page_init+0x2e1>
  10416b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  10416e:	76 0d                	jbe    10417d <page_init+0x2ee>
                begin = freemem;
  104170:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104173:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104176:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  10417d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  104181:	72 1d                	jb     1041a0 <page_init+0x311>
  104183:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  104187:	77 09                	ja     104192 <page_init+0x303>
  104189:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  104190:	76 0e                	jbe    1041a0 <page_init+0x311>
                end = KMEMSIZE;
  104192:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  104199:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  1041a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1041a6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1041a9:	0f 87 b4 00 00 00    	ja     104263 <page_init+0x3d4>
  1041af:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1041b2:	72 09                	jb     1041bd <page_init+0x32e>
  1041b4:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1041b7:	0f 83 a6 00 00 00    	jae    104263 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  1041bd:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  1041c4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1041c7:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1041ca:	01 d0                	add    %edx,%eax
  1041cc:	83 e8 01             	sub    $0x1,%eax
  1041cf:	89 45 98             	mov    %eax,-0x68(%ebp)
  1041d2:	8b 45 98             	mov    -0x68(%ebp),%eax
  1041d5:	ba 00 00 00 00       	mov    $0x0,%edx
  1041da:	f7 75 9c             	divl   -0x64(%ebp)
  1041dd:	89 d0                	mov    %edx,%eax
  1041df:	8b 55 98             	mov    -0x68(%ebp),%edx
  1041e2:	29 c2                	sub    %eax,%edx
  1041e4:	89 d0                	mov    %edx,%eax
  1041e6:	ba 00 00 00 00       	mov    $0x0,%edx
  1041eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1041ee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  1041f1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1041f4:	89 45 94             	mov    %eax,-0x6c(%ebp)
  1041f7:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1041fa:	ba 00 00 00 00       	mov    $0x0,%edx
  1041ff:	89 c7                	mov    %eax,%edi
  104201:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  104207:	89 7d 80             	mov    %edi,-0x80(%ebp)
  10420a:	89 d0                	mov    %edx,%eax
  10420c:	83 e0 00             	and    $0x0,%eax
  10420f:	89 45 84             	mov    %eax,-0x7c(%ebp)
  104212:	8b 45 80             	mov    -0x80(%ebp),%eax
  104215:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104218:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10421b:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  10421e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104221:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104224:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104227:	77 3a                	ja     104263 <page_init+0x3d4>
  104229:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10422c:	72 05                	jb     104233 <page_init+0x3a4>
  10422e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104231:	73 30                	jae    104263 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  104233:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  104236:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  104239:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10423c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10423f:	29 c8                	sub    %ecx,%eax
  104241:	19 da                	sbb    %ebx,%edx
  104243:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104247:	c1 ea 0c             	shr    $0xc,%edx
  10424a:	89 c3                	mov    %eax,%ebx
  10424c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10424f:	89 04 24             	mov    %eax,(%esp)
  104252:	e8 a5 f8 ff ff       	call   103afc <pa2page>
  104257:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10425b:	89 04 24             	mov    %eax,(%esp)
  10425e:	e8 78 fb ff ff       	call   103ddb <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  104263:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104267:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10426a:	8b 00                	mov    (%eax),%eax
  10426c:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  10426f:	0f 8f 7e fe ff ff    	jg     1040f3 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  104275:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  10427b:	5b                   	pop    %ebx
  10427c:	5e                   	pop    %esi
  10427d:	5f                   	pop    %edi
  10427e:	5d                   	pop    %ebp
  10427f:	c3                   	ret    

00104280 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  104280:	55                   	push   %ebp
  104281:	89 e5                	mov    %esp,%ebp
  104283:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  104286:	8b 45 14             	mov    0x14(%ebp),%eax
  104289:	8b 55 0c             	mov    0xc(%ebp),%edx
  10428c:	31 d0                	xor    %edx,%eax
  10428e:	25 ff 0f 00 00       	and    $0xfff,%eax
  104293:	85 c0                	test   %eax,%eax
  104295:	74 24                	je     1042bb <boot_map_segment+0x3b>
  104297:	c7 44 24 0c e2 6b 10 	movl   $0x106be2,0xc(%esp)
  10429e:	00 
  10429f:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  1042a6:	00 
  1042a7:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  1042ae:	00 
  1042af:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1042b6:	e8 17 ca ff ff       	call   100cd2 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1042bb:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1042c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1042c5:	25 ff 0f 00 00       	and    $0xfff,%eax
  1042ca:	89 c2                	mov    %eax,%edx
  1042cc:	8b 45 10             	mov    0x10(%ebp),%eax
  1042cf:	01 c2                	add    %eax,%edx
  1042d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1042d4:	01 d0                	add    %edx,%eax
  1042d6:	83 e8 01             	sub    $0x1,%eax
  1042d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1042dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1042df:	ba 00 00 00 00       	mov    $0x0,%edx
  1042e4:	f7 75 f0             	divl   -0x10(%ebp)
  1042e7:	89 d0                	mov    %edx,%eax
  1042e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1042ec:	29 c2                	sub    %eax,%edx
  1042ee:	89 d0                	mov    %edx,%eax
  1042f0:	c1 e8 0c             	shr    $0xc,%eax
  1042f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1042f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1042f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1042fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1042ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104304:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  104307:	8b 45 14             	mov    0x14(%ebp),%eax
  10430a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10430d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104310:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104315:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104318:	eb 6b                	jmp    104385 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  10431a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104321:	00 
  104322:	8b 45 0c             	mov    0xc(%ebp),%eax
  104325:	89 44 24 04          	mov    %eax,0x4(%esp)
  104329:	8b 45 08             	mov    0x8(%ebp),%eax
  10432c:	89 04 24             	mov    %eax,(%esp)
  10432f:	e8 82 01 00 00       	call   1044b6 <get_pte>
  104334:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  104337:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10433b:	75 24                	jne    104361 <boot_map_segment+0xe1>
  10433d:	c7 44 24 0c 0e 6c 10 	movl   $0x106c0e,0xc(%esp)
  104344:	00 
  104345:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  10434c:	00 
  10434d:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  104354:	00 
  104355:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  10435c:	e8 71 c9 ff ff       	call   100cd2 <__panic>
        *ptep = pa | PTE_P | perm;
  104361:	8b 45 18             	mov    0x18(%ebp),%eax
  104364:	8b 55 14             	mov    0x14(%ebp),%edx
  104367:	09 d0                	or     %edx,%eax
  104369:	83 c8 01             	or     $0x1,%eax
  10436c:	89 c2                	mov    %eax,%edx
  10436e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104371:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104373:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  104377:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10437e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  104385:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104389:	75 8f                	jne    10431a <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  10438b:	c9                   	leave  
  10438c:	c3                   	ret    

0010438d <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10438d:	55                   	push   %ebp
  10438e:	89 e5                	mov    %esp,%ebp
  104390:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  104393:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10439a:	e8 5b fa ff ff       	call   103dfa <alloc_pages>
  10439f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1043a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1043a6:	75 1c                	jne    1043c4 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1043a8:	c7 44 24 08 1b 6c 10 	movl   $0x106c1b,0x8(%esp)
  1043af:	00 
  1043b0:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  1043b7:	00 
  1043b8:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1043bf:	e8 0e c9 ff ff       	call   100cd2 <__panic>
    }
    return page2kva(p);
  1043c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043c7:	89 04 24             	mov    %eax,(%esp)
  1043ca:	e8 7c f7 ff ff       	call   103b4b <page2kva>
}
  1043cf:	c9                   	leave  
  1043d0:	c3                   	ret    

001043d1 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1043d1:	55                   	push   %ebp
  1043d2:	89 e5                	mov    %esp,%ebp
  1043d4:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1043d7:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1043dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1043df:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1043e6:	77 23                	ja     10440b <pmm_init+0x3a>
  1043e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1043ef:	c7 44 24 08 b0 6b 10 	movl   $0x106bb0,0x8(%esp)
  1043f6:	00 
  1043f7:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1043fe:	00 
  1043ff:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104406:	e8 c7 c8 ff ff       	call   100cd2 <__panic>
  10440b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10440e:	05 00 00 00 40       	add    $0x40000000,%eax
  104413:	a3 80 af 11 00       	mov    %eax,0x11af80
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  104418:	e8 8b f9 ff ff       	call   103da8 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  10441d:	e8 6d fa ff ff       	call   103e8f <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  104422:	e8 db 03 00 00       	call   104802 <check_alloc_page>

    check_pgdir();
  104427:	e8 f4 03 00 00       	call   104820 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  10442c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104431:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  104437:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10443c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10443f:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  104446:	77 23                	ja     10446b <pmm_init+0x9a>
  104448:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10444b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10444f:	c7 44 24 08 b0 6b 10 	movl   $0x106bb0,0x8(%esp)
  104456:	00 
  104457:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  10445e:	00 
  10445f:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104466:	e8 67 c8 ff ff       	call   100cd2 <__panic>
  10446b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10446e:	05 00 00 00 40       	add    $0x40000000,%eax
  104473:	83 c8 03             	or     $0x3,%eax
  104476:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  104478:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10447d:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  104484:	00 
  104485:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10448c:	00 
  10448d:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  104494:	38 
  104495:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  10449c:	c0 
  10449d:	89 04 24             	mov    %eax,(%esp)
  1044a0:	e8 db fd ff ff       	call   104280 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1044a5:	e8 0f f8 ff ff       	call   103cb9 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1044aa:	e8 0c 0a 00 00       	call   104ebb <check_boot_pgdir>

    print_pgdir();
  1044af:	e8 94 0e 00 00       	call   105348 <print_pgdir>

}
  1044b4:	c9                   	leave  
  1044b5:	c3                   	ret    

001044b6 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1044b6:	55                   	push   %ebp
  1044b7:	89 e5                	mov    %esp,%ebp
  1044b9:	83 ec 38             	sub    $0x38,%esp
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif

 pde_t *pdep = &pgdir[PDX(la)];
  1044bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044bf:	c1 e8 16             	shr    $0x16,%eax
  1044c2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1044c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1044cc:	01 d0                	add    %edx,%eax
  1044ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
  1044d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044d4:	8b 00                	mov    (%eax),%eax
  1044d6:	83 e0 01             	and    $0x1,%eax
  1044d9:	85 c0                	test   %eax,%eax
  1044db:	0f 85 af 00 00 00    	jne    104590 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  1044e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1044e5:	74 15                	je     1044fc <get_pte+0x46>
  1044e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1044ee:	e8 07 f9 ff ff       	call   103dfa <alloc_pages>
  1044f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1044f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1044fa:	75 0a                	jne    104506 <get_pte+0x50>
            return NULL;
  1044fc:	b8 00 00 00 00       	mov    $0x0,%eax
  104501:	e9 e6 00 00 00       	jmp    1045ec <get_pte+0x136>
        }
        set_page_ref(page, 1);
  104506:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10450d:	00 
  10450e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104511:	89 04 24             	mov    %eax,(%esp)
  104514:	e8 e6 f6 ff ff       	call   103bff <set_page_ref>
        uintptr_t pa = page2pa(page);
  104519:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10451c:	89 04 24             	mov    %eax,(%esp)
  10451f:	e8 c2 f5 ff ff       	call   103ae6 <page2pa>
  104524:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
  104527:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10452a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10452d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104530:	c1 e8 0c             	shr    $0xc,%eax
  104533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104536:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10453b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10453e:	72 23                	jb     104563 <get_pte+0xad>
  104540:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104543:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104547:	c7 44 24 08 0c 6b 10 	movl   $0x106b0c,0x8(%esp)
  10454e:	00 
  10454f:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
  104556:	00 
  104557:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  10455e:	e8 6f c7 ff ff       	call   100cd2 <__panic>
  104563:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104566:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10456b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104572:	00 
  104573:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10457a:	00 
  10457b:	89 04 24             	mov    %eax,(%esp)
  10457e:	e8 e3 18 00 00       	call   105e66 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  104583:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104586:	83 c8 07             	or     $0x7,%eax
  104589:	89 c2                	mov    %eax,%edx
  10458b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10458e:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  104590:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104593:	8b 00                	mov    (%eax),%eax
  104595:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10459a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10459d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1045a0:	c1 e8 0c             	shr    $0xc,%eax
  1045a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1045a6:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1045ab:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1045ae:	72 23                	jb     1045d3 <get_pte+0x11d>
  1045b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1045b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1045b7:	c7 44 24 08 0c 6b 10 	movl   $0x106b0c,0x8(%esp)
  1045be:	00 
  1045bf:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
  1045c6:	00 
  1045c7:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1045ce:	e8 ff c6 ff ff       	call   100cd2 <__panic>
  1045d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1045d6:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1045db:	8b 55 0c             	mov    0xc(%ebp),%edx
  1045de:	c1 ea 0c             	shr    $0xc,%edx
  1045e1:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  1045e7:	c1 e2 02             	shl    $0x2,%edx
  1045ea:	01 d0                	add    %edx,%eax
}
  1045ec:	c9                   	leave  
  1045ed:	c3                   	ret    

001045ee <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1045ee:	55                   	push   %ebp
  1045ef:	89 e5                	mov    %esp,%ebp
  1045f1:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1045f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1045fb:	00 
  1045fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  104603:	8b 45 08             	mov    0x8(%ebp),%eax
  104606:	89 04 24             	mov    %eax,(%esp)
  104609:	e8 a8 fe ff ff       	call   1044b6 <get_pte>
  10460e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  104611:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  104615:	74 08                	je     10461f <get_page+0x31>
        *ptep_store = ptep;
  104617:	8b 45 10             	mov    0x10(%ebp),%eax
  10461a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10461d:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  10461f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104623:	74 1b                	je     104640 <get_page+0x52>
  104625:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104628:	8b 00                	mov    (%eax),%eax
  10462a:	83 e0 01             	and    $0x1,%eax
  10462d:	85 c0                	test   %eax,%eax
  10462f:	74 0f                	je     104640 <get_page+0x52>
        return pte2page(*ptep);
  104631:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104634:	8b 00                	mov    (%eax),%eax
  104636:	89 04 24             	mov    %eax,(%esp)
  104639:	e8 61 f5 ff ff       	call   103b9f <pte2page>
  10463e:	eb 05                	jmp    104645 <get_page+0x57>
    }
    return NULL;
  104640:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104645:	c9                   	leave  
  104646:	c3                   	ret    

00104647 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  104647:	55                   	push   %ebp
  104648:	89 e5                	mov    %esp,%ebp
  10464a:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
  10464d:	8b 45 10             	mov    0x10(%ebp),%eax
  104650:	8b 00                	mov    (%eax),%eax
  104652:	83 e0 01             	and    $0x1,%eax
  104655:	85 c0                	test   %eax,%eax
  104657:	74 4d                	je     1046a6 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  104659:	8b 45 10             	mov    0x10(%ebp),%eax
  10465c:	8b 00                	mov    (%eax),%eax
  10465e:	89 04 24             	mov    %eax,(%esp)
  104661:	e8 39 f5 ff ff       	call   103b9f <pte2page>
  104666:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  104669:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10466c:	89 04 24             	mov    %eax,(%esp)
  10466f:	e8 af f5 ff ff       	call   103c23 <page_ref_dec>
  104674:	85 c0                	test   %eax,%eax
  104676:	75 13                	jne    10468b <page_remove_pte+0x44>
            free_page(page);
  104678:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10467f:	00 
  104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104683:	89 04 24             	mov    %eax,(%esp)
  104686:	e8 a7 f7 ff ff       	call   103e32 <free_pages>
        }
        *ptep = 0;
  10468b:	8b 45 10             	mov    0x10(%ebp),%eax
  10468e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  104694:	8b 45 0c             	mov    0xc(%ebp),%eax
  104697:	89 44 24 04          	mov    %eax,0x4(%esp)
  10469b:	8b 45 08             	mov    0x8(%ebp),%eax
  10469e:	89 04 24             	mov    %eax,(%esp)
  1046a1:	e8 ff 00 00 00       	call   1047a5 <tlb_invalidate>
    }
}
  1046a6:	c9                   	leave  
  1046a7:	c3                   	ret    

001046a8 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1046a8:	55                   	push   %ebp
  1046a9:	89 e5                	mov    %esp,%ebp
  1046ab:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1046ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1046b5:	00 
  1046b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1046c0:	89 04 24             	mov    %eax,(%esp)
  1046c3:	e8 ee fd ff ff       	call   1044b6 <get_pte>
  1046c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  1046cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1046cf:	74 19                	je     1046ea <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1046d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1046d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046db:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046df:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e2:	89 04 24             	mov    %eax,(%esp)
  1046e5:	e8 5d ff ff ff       	call   104647 <page_remove_pte>
    }
}
  1046ea:	c9                   	leave  
  1046eb:	c3                   	ret    

001046ec <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1046ec:	55                   	push   %ebp
  1046ed:	89 e5                	mov    %esp,%ebp
  1046ef:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1046f2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1046f9:	00 
  1046fa:	8b 45 10             	mov    0x10(%ebp),%eax
  1046fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  104701:	8b 45 08             	mov    0x8(%ebp),%eax
  104704:	89 04 24             	mov    %eax,(%esp)
  104707:	e8 aa fd ff ff       	call   1044b6 <get_pte>
  10470c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  10470f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104713:	75 0a                	jne    10471f <page_insert+0x33>
        return -E_NO_MEM;
  104715:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  10471a:	e9 84 00 00 00       	jmp    1047a3 <page_insert+0xb7>
    }
    page_ref_inc(page);
  10471f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104722:	89 04 24             	mov    %eax,(%esp)
  104725:	e8 e2 f4 ff ff       	call   103c0c <page_ref_inc>
    if (*ptep & PTE_P) {
  10472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10472d:	8b 00                	mov    (%eax),%eax
  10472f:	83 e0 01             	and    $0x1,%eax
  104732:	85 c0                	test   %eax,%eax
  104734:	74 3e                	je     104774 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  104736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104739:	8b 00                	mov    (%eax),%eax
  10473b:	89 04 24             	mov    %eax,(%esp)
  10473e:	e8 5c f4 ff ff       	call   103b9f <pte2page>
  104743:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  104746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104749:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10474c:	75 0d                	jne    10475b <page_insert+0x6f>
            page_ref_dec(page);
  10474e:	8b 45 0c             	mov    0xc(%ebp),%eax
  104751:	89 04 24             	mov    %eax,(%esp)
  104754:	e8 ca f4 ff ff       	call   103c23 <page_ref_dec>
  104759:	eb 19                	jmp    104774 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  10475b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10475e:	89 44 24 08          	mov    %eax,0x8(%esp)
  104762:	8b 45 10             	mov    0x10(%ebp),%eax
  104765:	89 44 24 04          	mov    %eax,0x4(%esp)
  104769:	8b 45 08             	mov    0x8(%ebp),%eax
  10476c:	89 04 24             	mov    %eax,(%esp)
  10476f:	e8 d3 fe ff ff       	call   104647 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  104774:	8b 45 0c             	mov    0xc(%ebp),%eax
  104777:	89 04 24             	mov    %eax,(%esp)
  10477a:	e8 67 f3 ff ff       	call   103ae6 <page2pa>
  10477f:	0b 45 14             	or     0x14(%ebp),%eax
  104782:	83 c8 01             	or     $0x1,%eax
  104785:	89 c2                	mov    %eax,%edx
  104787:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10478a:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  10478c:	8b 45 10             	mov    0x10(%ebp),%eax
  10478f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104793:	8b 45 08             	mov    0x8(%ebp),%eax
  104796:	89 04 24             	mov    %eax,(%esp)
  104799:	e8 07 00 00 00       	call   1047a5 <tlb_invalidate>
    return 0;
  10479e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1047a3:	c9                   	leave  
  1047a4:	c3                   	ret    

001047a5 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1047a5:	55                   	push   %ebp
  1047a6:	89 e5                	mov    %esp,%ebp
  1047a8:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1047ab:	0f 20 d8             	mov    %cr3,%eax
  1047ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  1047b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  1047b4:	89 c2                	mov    %eax,%edx
  1047b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1047b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1047bc:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1047c3:	77 23                	ja     1047e8 <tlb_invalidate+0x43>
  1047c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1047cc:	c7 44 24 08 b0 6b 10 	movl   $0x106bb0,0x8(%esp)
  1047d3:	00 
  1047d4:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
  1047db:	00 
  1047dc:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1047e3:	e8 ea c4 ff ff       	call   100cd2 <__panic>
  1047e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047eb:	05 00 00 00 40       	add    $0x40000000,%eax
  1047f0:	39 c2                	cmp    %eax,%edx
  1047f2:	75 0c                	jne    104800 <tlb_invalidate+0x5b>
        invlpg((void *)la);
  1047f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1047fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047fd:	0f 01 38             	invlpg (%eax)
    }
}
  104800:	c9                   	leave  
  104801:	c3                   	ret    

00104802 <check_alloc_page>:

static void
check_alloc_page(void) {
  104802:	55                   	push   %ebp
  104803:	89 e5                	mov    %esp,%ebp
  104805:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  104808:	a1 7c af 11 00       	mov    0x11af7c,%eax
  10480d:	8b 40 18             	mov    0x18(%eax),%eax
  104810:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  104812:	c7 04 24 34 6c 10 00 	movl   $0x106c34,(%esp)
  104819:	e8 2a bb ff ff       	call   100348 <cprintf>
}
  10481e:	c9                   	leave  
  10481f:	c3                   	ret    

00104820 <check_pgdir>:

static void
check_pgdir(void) {
  104820:	55                   	push   %ebp
  104821:	89 e5                	mov    %esp,%ebp
  104823:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  104826:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10482b:	3d 00 80 03 00       	cmp    $0x38000,%eax
  104830:	76 24                	jbe    104856 <check_pgdir+0x36>
  104832:	c7 44 24 0c 53 6c 10 	movl   $0x106c53,0xc(%esp)
  104839:	00 
  10483a:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104841:	00 
  104842:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  104849:	00 
  10484a:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104851:	e8 7c c4 ff ff       	call   100cd2 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  104856:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10485b:	85 c0                	test   %eax,%eax
  10485d:	74 0e                	je     10486d <check_pgdir+0x4d>
  10485f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104864:	25 ff 0f 00 00       	and    $0xfff,%eax
  104869:	85 c0                	test   %eax,%eax
  10486b:	74 24                	je     104891 <check_pgdir+0x71>
  10486d:	c7 44 24 0c 70 6c 10 	movl   $0x106c70,0xc(%esp)
  104874:	00 
  104875:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  10487c:	00 
  10487d:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  104884:	00 
  104885:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  10488c:	e8 41 c4 ff ff       	call   100cd2 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  104891:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104896:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10489d:	00 
  10489e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1048a5:	00 
  1048a6:	89 04 24             	mov    %eax,(%esp)
  1048a9:	e8 40 fd ff ff       	call   1045ee <get_page>
  1048ae:	85 c0                	test   %eax,%eax
  1048b0:	74 24                	je     1048d6 <check_pgdir+0xb6>
  1048b2:	c7 44 24 0c a8 6c 10 	movl   $0x106ca8,0xc(%esp)
  1048b9:	00 
  1048ba:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  1048c1:	00 
  1048c2:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
  1048c9:	00 
  1048ca:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1048d1:	e8 fc c3 ff ff       	call   100cd2 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1048d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048dd:	e8 18 f5 ff ff       	call   103dfa <alloc_pages>
  1048e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1048e5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1048ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1048f1:	00 
  1048f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048f9:	00 
  1048fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1048fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  104901:	89 04 24             	mov    %eax,(%esp)
  104904:	e8 e3 fd ff ff       	call   1046ec <page_insert>
  104909:	85 c0                	test   %eax,%eax
  10490b:	74 24                	je     104931 <check_pgdir+0x111>
  10490d:	c7 44 24 0c d0 6c 10 	movl   $0x106cd0,0xc(%esp)
  104914:	00 
  104915:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  10491c:	00 
  10491d:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  104924:	00 
  104925:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  10492c:	e8 a1 c3 ff ff       	call   100cd2 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  104931:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104936:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10493d:	00 
  10493e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104945:	00 
  104946:	89 04 24             	mov    %eax,(%esp)
  104949:	e8 68 fb ff ff       	call   1044b6 <get_pte>
  10494e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104951:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104955:	75 24                	jne    10497b <check_pgdir+0x15b>
  104957:	c7 44 24 0c fc 6c 10 	movl   $0x106cfc,0xc(%esp)
  10495e:	00 
  10495f:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104966:	00 
  104967:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  10496e:	00 
  10496f:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104976:	e8 57 c3 ff ff       	call   100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
  10497b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10497e:	8b 00                	mov    (%eax),%eax
  104980:	89 04 24             	mov    %eax,(%esp)
  104983:	e8 17 f2 ff ff       	call   103b9f <pte2page>
  104988:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10498b:	74 24                	je     1049b1 <check_pgdir+0x191>
  10498d:	c7 44 24 0c 29 6d 10 	movl   $0x106d29,0xc(%esp)
  104994:	00 
  104995:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  10499c:	00 
  10499d:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  1049a4:	00 
  1049a5:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1049ac:	e8 21 c3 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p1) == 1);
  1049b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049b4:	89 04 24             	mov    %eax,(%esp)
  1049b7:	e8 39 f2 ff ff       	call   103bf5 <page_ref>
  1049bc:	83 f8 01             	cmp    $0x1,%eax
  1049bf:	74 24                	je     1049e5 <check_pgdir+0x1c5>
  1049c1:	c7 44 24 0c 3f 6d 10 	movl   $0x106d3f,0xc(%esp)
  1049c8:	00 
  1049c9:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  1049d0:	00 
  1049d1:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  1049d8:	00 
  1049d9:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1049e0:	e8 ed c2 ff ff       	call   100cd2 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1049e5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1049ea:	8b 00                	mov    (%eax),%eax
  1049ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1049f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1049f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049f7:	c1 e8 0c             	shr    $0xc,%eax
  1049fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1049fd:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104a02:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104a05:	72 23                	jb     104a2a <check_pgdir+0x20a>
  104a07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104a0e:	c7 44 24 08 0c 6b 10 	movl   $0x106b0c,0x8(%esp)
  104a15:	00 
  104a16:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  104a1d:	00 
  104a1e:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104a25:	e8 a8 c2 ff ff       	call   100cd2 <__panic>
  104a2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a2d:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104a32:	83 c0 04             	add    $0x4,%eax
  104a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  104a38:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a44:	00 
  104a45:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104a4c:	00 
  104a4d:	89 04 24             	mov    %eax,(%esp)
  104a50:	e8 61 fa ff ff       	call   1044b6 <get_pte>
  104a55:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104a58:	74 24                	je     104a7e <check_pgdir+0x25e>
  104a5a:	c7 44 24 0c 54 6d 10 	movl   $0x106d54,0xc(%esp)
  104a61:	00 
  104a62:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104a69:	00 
  104a6a:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  104a71:	00 
  104a72:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104a79:	e8 54 c2 ff ff       	call   100cd2 <__panic>

    p2 = alloc_page();
  104a7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a85:	e8 70 f3 ff ff       	call   103dfa <alloc_pages>
  104a8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104a8d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a92:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104a99:	00 
  104a9a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104aa1:	00 
  104aa2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104aa5:	89 54 24 04          	mov    %edx,0x4(%esp)
  104aa9:	89 04 24             	mov    %eax,(%esp)
  104aac:	e8 3b fc ff ff       	call   1046ec <page_insert>
  104ab1:	85 c0                	test   %eax,%eax
  104ab3:	74 24                	je     104ad9 <check_pgdir+0x2b9>
  104ab5:	c7 44 24 0c 7c 6d 10 	movl   $0x106d7c,0xc(%esp)
  104abc:	00 
  104abd:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104ac4:	00 
  104ac5:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  104acc:	00 
  104acd:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104ad4:	e8 f9 c1 ff ff       	call   100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104ad9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104ade:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ae5:	00 
  104ae6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104aed:	00 
  104aee:	89 04 24             	mov    %eax,(%esp)
  104af1:	e8 c0 f9 ff ff       	call   1044b6 <get_pte>
  104af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104af9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104afd:	75 24                	jne    104b23 <check_pgdir+0x303>
  104aff:	c7 44 24 0c b4 6d 10 	movl   $0x106db4,0xc(%esp)
  104b06:	00 
  104b07:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104b0e:	00 
  104b0f:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  104b16:	00 
  104b17:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104b1e:	e8 af c1 ff ff       	call   100cd2 <__panic>
    assert(*ptep & PTE_U);
  104b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b26:	8b 00                	mov    (%eax),%eax
  104b28:	83 e0 04             	and    $0x4,%eax
  104b2b:	85 c0                	test   %eax,%eax
  104b2d:	75 24                	jne    104b53 <check_pgdir+0x333>
  104b2f:	c7 44 24 0c e4 6d 10 	movl   $0x106de4,0xc(%esp)
  104b36:	00 
  104b37:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104b3e:	00 
  104b3f:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  104b46:	00 
  104b47:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104b4e:	e8 7f c1 ff ff       	call   100cd2 <__panic>
    assert(*ptep & PTE_W);
  104b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b56:	8b 00                	mov    (%eax),%eax
  104b58:	83 e0 02             	and    $0x2,%eax
  104b5b:	85 c0                	test   %eax,%eax
  104b5d:	75 24                	jne    104b83 <check_pgdir+0x363>
  104b5f:	c7 44 24 0c f2 6d 10 	movl   $0x106df2,0xc(%esp)
  104b66:	00 
  104b67:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104b6e:	00 
  104b6f:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  104b76:	00 
  104b77:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104b7e:	e8 4f c1 ff ff       	call   100cd2 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104b83:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b88:	8b 00                	mov    (%eax),%eax
  104b8a:	83 e0 04             	and    $0x4,%eax
  104b8d:	85 c0                	test   %eax,%eax
  104b8f:	75 24                	jne    104bb5 <check_pgdir+0x395>
  104b91:	c7 44 24 0c 00 6e 10 	movl   $0x106e00,0xc(%esp)
  104b98:	00 
  104b99:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104ba0:	00 
  104ba1:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  104ba8:	00 
  104ba9:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104bb0:	e8 1d c1 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 1);
  104bb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104bb8:	89 04 24             	mov    %eax,(%esp)
  104bbb:	e8 35 f0 ff ff       	call   103bf5 <page_ref>
  104bc0:	83 f8 01             	cmp    $0x1,%eax
  104bc3:	74 24                	je     104be9 <check_pgdir+0x3c9>
  104bc5:	c7 44 24 0c 16 6e 10 	movl   $0x106e16,0xc(%esp)
  104bcc:	00 
  104bcd:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104bd4:	00 
  104bd5:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  104bdc:	00 
  104bdd:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104be4:	e8 e9 c0 ff ff       	call   100cd2 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104be9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104bee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104bf5:	00 
  104bf6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104bfd:	00 
  104bfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104c01:	89 54 24 04          	mov    %edx,0x4(%esp)
  104c05:	89 04 24             	mov    %eax,(%esp)
  104c08:	e8 df fa ff ff       	call   1046ec <page_insert>
  104c0d:	85 c0                	test   %eax,%eax
  104c0f:	74 24                	je     104c35 <check_pgdir+0x415>
  104c11:	c7 44 24 0c 28 6e 10 	movl   $0x106e28,0xc(%esp)
  104c18:	00 
  104c19:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104c20:	00 
  104c21:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  104c28:	00 
  104c29:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104c30:	e8 9d c0 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p1) == 2);
  104c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c38:	89 04 24             	mov    %eax,(%esp)
  104c3b:	e8 b5 ef ff ff       	call   103bf5 <page_ref>
  104c40:	83 f8 02             	cmp    $0x2,%eax
  104c43:	74 24                	je     104c69 <check_pgdir+0x449>
  104c45:	c7 44 24 0c 54 6e 10 	movl   $0x106e54,0xc(%esp)
  104c4c:	00 
  104c4d:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104c54:	00 
  104c55:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  104c5c:	00 
  104c5d:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104c64:	e8 69 c0 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c6c:	89 04 24             	mov    %eax,(%esp)
  104c6f:	e8 81 ef ff ff       	call   103bf5 <page_ref>
  104c74:	85 c0                	test   %eax,%eax
  104c76:	74 24                	je     104c9c <check_pgdir+0x47c>
  104c78:	c7 44 24 0c 66 6e 10 	movl   $0x106e66,0xc(%esp)
  104c7f:	00 
  104c80:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104c87:	00 
  104c88:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  104c8f:	00 
  104c90:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104c97:	e8 36 c0 ff ff       	call   100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104c9c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104ca1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ca8:	00 
  104ca9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104cb0:	00 
  104cb1:	89 04 24             	mov    %eax,(%esp)
  104cb4:	e8 fd f7 ff ff       	call   1044b6 <get_pte>
  104cb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104cbc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104cc0:	75 24                	jne    104ce6 <check_pgdir+0x4c6>
  104cc2:	c7 44 24 0c b4 6d 10 	movl   $0x106db4,0xc(%esp)
  104cc9:	00 
  104cca:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104cd1:	00 
  104cd2:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  104cd9:	00 
  104cda:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104ce1:	e8 ec bf ff ff       	call   100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
  104ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ce9:	8b 00                	mov    (%eax),%eax
  104ceb:	89 04 24             	mov    %eax,(%esp)
  104cee:	e8 ac ee ff ff       	call   103b9f <pte2page>
  104cf3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104cf6:	74 24                	je     104d1c <check_pgdir+0x4fc>
  104cf8:	c7 44 24 0c 29 6d 10 	movl   $0x106d29,0xc(%esp)
  104cff:	00 
  104d00:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104d07:	00 
  104d08:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  104d0f:	00 
  104d10:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104d17:	e8 b6 bf ff ff       	call   100cd2 <__panic>
    assert((*ptep & PTE_U) == 0);
  104d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d1f:	8b 00                	mov    (%eax),%eax
  104d21:	83 e0 04             	and    $0x4,%eax
  104d24:	85 c0                	test   %eax,%eax
  104d26:	74 24                	je     104d4c <check_pgdir+0x52c>
  104d28:	c7 44 24 0c 78 6e 10 	movl   $0x106e78,0xc(%esp)
  104d2f:	00 
  104d30:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104d37:	00 
  104d38:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  104d3f:	00 
  104d40:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104d47:	e8 86 bf ff ff       	call   100cd2 <__panic>

    page_remove(boot_pgdir, 0x0);
  104d4c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104d58:	00 
  104d59:	89 04 24             	mov    %eax,(%esp)
  104d5c:	e8 47 f9 ff ff       	call   1046a8 <page_remove>
    assert(page_ref(p1) == 1);
  104d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d64:	89 04 24             	mov    %eax,(%esp)
  104d67:	e8 89 ee ff ff       	call   103bf5 <page_ref>
  104d6c:	83 f8 01             	cmp    $0x1,%eax
  104d6f:	74 24                	je     104d95 <check_pgdir+0x575>
  104d71:	c7 44 24 0c 3f 6d 10 	movl   $0x106d3f,0xc(%esp)
  104d78:	00 
  104d79:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104d80:	00 
  104d81:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  104d88:	00 
  104d89:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104d90:	e8 3d bf ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104d95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d98:	89 04 24             	mov    %eax,(%esp)
  104d9b:	e8 55 ee ff ff       	call   103bf5 <page_ref>
  104da0:	85 c0                	test   %eax,%eax
  104da2:	74 24                	je     104dc8 <check_pgdir+0x5a8>
  104da4:	c7 44 24 0c 66 6e 10 	movl   $0x106e66,0xc(%esp)
  104dab:	00 
  104dac:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104db3:	00 
  104db4:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  104dbb:	00 
  104dbc:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104dc3:	e8 0a bf ff ff       	call   100cd2 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104dc8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104dcd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104dd4:	00 
  104dd5:	89 04 24             	mov    %eax,(%esp)
  104dd8:	e8 cb f8 ff ff       	call   1046a8 <page_remove>
    assert(page_ref(p1) == 0);
  104ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104de0:	89 04 24             	mov    %eax,(%esp)
  104de3:	e8 0d ee ff ff       	call   103bf5 <page_ref>
  104de8:	85 c0                	test   %eax,%eax
  104dea:	74 24                	je     104e10 <check_pgdir+0x5f0>
  104dec:	c7 44 24 0c 8d 6e 10 	movl   $0x106e8d,0xc(%esp)
  104df3:	00 
  104df4:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104dfb:	00 
  104dfc:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  104e03:	00 
  104e04:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104e0b:	e8 c2 be ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e13:	89 04 24             	mov    %eax,(%esp)
  104e16:	e8 da ed ff ff       	call   103bf5 <page_ref>
  104e1b:	85 c0                	test   %eax,%eax
  104e1d:	74 24                	je     104e43 <check_pgdir+0x623>
  104e1f:	c7 44 24 0c 66 6e 10 	movl   $0x106e66,0xc(%esp)
  104e26:	00 
  104e27:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104e2e:	00 
  104e2f:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  104e36:	00 
  104e37:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104e3e:	e8 8f be ff ff       	call   100cd2 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104e43:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e48:	8b 00                	mov    (%eax),%eax
  104e4a:	89 04 24             	mov    %eax,(%esp)
  104e4d:	e8 8b ed ff ff       	call   103bdd <pde2page>
  104e52:	89 04 24             	mov    %eax,(%esp)
  104e55:	e8 9b ed ff ff       	call   103bf5 <page_ref>
  104e5a:	83 f8 01             	cmp    $0x1,%eax
  104e5d:	74 24                	je     104e83 <check_pgdir+0x663>
  104e5f:	c7 44 24 0c a0 6e 10 	movl   $0x106ea0,0xc(%esp)
  104e66:	00 
  104e67:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104e6e:	00 
  104e6f:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  104e76:	00 
  104e77:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104e7e:	e8 4f be ff ff       	call   100cd2 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104e83:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e88:	8b 00                	mov    (%eax),%eax
  104e8a:	89 04 24             	mov    %eax,(%esp)
  104e8d:	e8 4b ed ff ff       	call   103bdd <pde2page>
  104e92:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e99:	00 
  104e9a:	89 04 24             	mov    %eax,(%esp)
  104e9d:	e8 90 ef ff ff       	call   103e32 <free_pages>
    boot_pgdir[0] = 0;
  104ea2:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104ea7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104ead:	c7 04 24 c7 6e 10 00 	movl   $0x106ec7,(%esp)
  104eb4:	e8 8f b4 ff ff       	call   100348 <cprintf>
}
  104eb9:	c9                   	leave  
  104eba:	c3                   	ret    

00104ebb <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104ebb:	55                   	push   %ebp
  104ebc:	89 e5                	mov    %esp,%ebp
  104ebe:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104ec1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104ec8:	e9 ca 00 00 00       	jmp    104f97 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ed6:	c1 e8 0c             	shr    $0xc,%eax
  104ed9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104edc:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104ee1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104ee4:	72 23                	jb     104f09 <check_boot_pgdir+0x4e>
  104ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ee9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104eed:	c7 44 24 08 0c 6b 10 	movl   $0x106b0c,0x8(%esp)
  104ef4:	00 
  104ef5:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  104efc:	00 
  104efd:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104f04:	e8 c9 bd ff ff       	call   100cd2 <__panic>
  104f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f0c:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104f11:	89 c2                	mov    %eax,%edx
  104f13:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f18:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104f1f:	00 
  104f20:	89 54 24 04          	mov    %edx,0x4(%esp)
  104f24:	89 04 24             	mov    %eax,(%esp)
  104f27:	e8 8a f5 ff ff       	call   1044b6 <get_pte>
  104f2c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104f2f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104f33:	75 24                	jne    104f59 <check_boot_pgdir+0x9e>
  104f35:	c7 44 24 0c e4 6e 10 	movl   $0x106ee4,0xc(%esp)
  104f3c:	00 
  104f3d:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104f44:	00 
  104f45:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  104f4c:	00 
  104f4d:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104f54:	e8 79 bd ff ff       	call   100cd2 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104f59:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f5c:	8b 00                	mov    (%eax),%eax
  104f5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f63:	89 c2                	mov    %eax,%edx
  104f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f68:	39 c2                	cmp    %eax,%edx
  104f6a:	74 24                	je     104f90 <check_boot_pgdir+0xd5>
  104f6c:	c7 44 24 0c 21 6f 10 	movl   $0x106f21,0xc(%esp)
  104f73:	00 
  104f74:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  104f7b:	00 
  104f7c:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  104f83:	00 
  104f84:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104f8b:	e8 42 bd ff ff       	call   100cd2 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104f90:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  104f97:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104f9a:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104f9f:	39 c2                	cmp    %eax,%edx
  104fa1:	0f 82 26 ff ff ff    	jb     104ecd <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104fa7:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fac:	05 ac 0f 00 00       	add    $0xfac,%eax
  104fb1:	8b 00                	mov    (%eax),%eax
  104fb3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104fb8:	89 c2                	mov    %eax,%edx
  104fba:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104fc2:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  104fc9:	77 23                	ja     104fee <check_boot_pgdir+0x133>
  104fcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104fd2:	c7 44 24 08 b0 6b 10 	movl   $0x106bb0,0x8(%esp)
  104fd9:	00 
  104fda:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  104fe1:	00 
  104fe2:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  104fe9:	e8 e4 bc ff ff       	call   100cd2 <__panic>
  104fee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ff1:	05 00 00 00 40       	add    $0x40000000,%eax
  104ff6:	39 c2                	cmp    %eax,%edx
  104ff8:	74 24                	je     10501e <check_boot_pgdir+0x163>
  104ffa:	c7 44 24 0c 38 6f 10 	movl   $0x106f38,0xc(%esp)
  105001:	00 
  105002:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  105009:	00 
  10500a:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  105011:	00 
  105012:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  105019:	e8 b4 bc ff ff       	call   100cd2 <__panic>

    assert(boot_pgdir[0] == 0);
  10501e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105023:	8b 00                	mov    (%eax),%eax
  105025:	85 c0                	test   %eax,%eax
  105027:	74 24                	je     10504d <check_boot_pgdir+0x192>
  105029:	c7 44 24 0c 6c 6f 10 	movl   $0x106f6c,0xc(%esp)
  105030:	00 
  105031:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  105038:	00 
  105039:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  105040:	00 
  105041:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  105048:	e8 85 bc ff ff       	call   100cd2 <__panic>

    struct Page *p;
    p = alloc_page();
  10504d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105054:	e8 a1 ed ff ff       	call   103dfa <alloc_pages>
  105059:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  10505c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105061:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105068:	00 
  105069:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  105070:	00 
  105071:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105074:	89 54 24 04          	mov    %edx,0x4(%esp)
  105078:	89 04 24             	mov    %eax,(%esp)
  10507b:	e8 6c f6 ff ff       	call   1046ec <page_insert>
  105080:	85 c0                	test   %eax,%eax
  105082:	74 24                	je     1050a8 <check_boot_pgdir+0x1ed>
  105084:	c7 44 24 0c 80 6f 10 	movl   $0x106f80,0xc(%esp)
  10508b:	00 
  10508c:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  105093:	00 
  105094:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  10509b:	00 
  10509c:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1050a3:	e8 2a bc ff ff       	call   100cd2 <__panic>
    assert(page_ref(p) == 1);
  1050a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1050ab:	89 04 24             	mov    %eax,(%esp)
  1050ae:	e8 42 eb ff ff       	call   103bf5 <page_ref>
  1050b3:	83 f8 01             	cmp    $0x1,%eax
  1050b6:	74 24                	je     1050dc <check_boot_pgdir+0x221>
  1050b8:	c7 44 24 0c ae 6f 10 	movl   $0x106fae,0xc(%esp)
  1050bf:	00 
  1050c0:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  1050c7:	00 
  1050c8:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  1050cf:	00 
  1050d0:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1050d7:	e8 f6 bb ff ff       	call   100cd2 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  1050dc:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1050e1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  1050e8:	00 
  1050e9:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  1050f0:	00 
  1050f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1050f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  1050f8:	89 04 24             	mov    %eax,(%esp)
  1050fb:	e8 ec f5 ff ff       	call   1046ec <page_insert>
  105100:	85 c0                	test   %eax,%eax
  105102:	74 24                	je     105128 <check_boot_pgdir+0x26d>
  105104:	c7 44 24 0c c0 6f 10 	movl   $0x106fc0,0xc(%esp)
  10510b:	00 
  10510c:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  105113:	00 
  105114:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  10511b:	00 
  10511c:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  105123:	e8 aa bb ff ff       	call   100cd2 <__panic>
    assert(page_ref(p) == 2);
  105128:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10512b:	89 04 24             	mov    %eax,(%esp)
  10512e:	e8 c2 ea ff ff       	call   103bf5 <page_ref>
  105133:	83 f8 02             	cmp    $0x2,%eax
  105136:	74 24                	je     10515c <check_boot_pgdir+0x2a1>
  105138:	c7 44 24 0c f7 6f 10 	movl   $0x106ff7,0xc(%esp)
  10513f:	00 
  105140:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  105147:	00 
  105148:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  10514f:	00 
  105150:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  105157:	e8 76 bb ff ff       	call   100cd2 <__panic>

    const char *str = "ucore: Hello world!!";
  10515c:	c7 45 dc 08 70 10 00 	movl   $0x107008,-0x24(%ebp)
    strcpy((void *)0x100, str);
  105163:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105166:	89 44 24 04          	mov    %eax,0x4(%esp)
  10516a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105171:	e8 19 0a 00 00       	call   105b8f <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  105176:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  10517d:	00 
  10517e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105185:	e8 7e 0a 00 00       	call   105c08 <strcmp>
  10518a:	85 c0                	test   %eax,%eax
  10518c:	74 24                	je     1051b2 <check_boot_pgdir+0x2f7>
  10518e:	c7 44 24 0c 20 70 10 	movl   $0x107020,0xc(%esp)
  105195:	00 
  105196:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  10519d:	00 
  10519e:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  1051a5:	00 
  1051a6:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1051ad:	e8 20 bb ff ff       	call   100cd2 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  1051b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051b5:	89 04 24             	mov    %eax,(%esp)
  1051b8:	e8 8e e9 ff ff       	call   103b4b <page2kva>
  1051bd:	05 00 01 00 00       	add    $0x100,%eax
  1051c2:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  1051c5:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1051cc:	e8 66 09 00 00       	call   105b37 <strlen>
  1051d1:	85 c0                	test   %eax,%eax
  1051d3:	74 24                	je     1051f9 <check_boot_pgdir+0x33e>
  1051d5:	c7 44 24 0c 58 70 10 	movl   $0x107058,0xc(%esp)
  1051dc:	00 
  1051dd:	c7 44 24 08 f9 6b 10 	movl   $0x106bf9,0x8(%esp)
  1051e4:	00 
  1051e5:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  1051ec:	00 
  1051ed:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1051f4:	e8 d9 ba ff ff       	call   100cd2 <__panic>

    free_page(p);
  1051f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105200:	00 
  105201:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105204:	89 04 24             	mov    %eax,(%esp)
  105207:	e8 26 ec ff ff       	call   103e32 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  10520c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105211:	8b 00                	mov    (%eax),%eax
  105213:	89 04 24             	mov    %eax,(%esp)
  105216:	e8 c2 e9 ff ff       	call   103bdd <pde2page>
  10521b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105222:	00 
  105223:	89 04 24             	mov    %eax,(%esp)
  105226:	e8 07 ec ff ff       	call   103e32 <free_pages>
    boot_pgdir[0] = 0;
  10522b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105230:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  105236:	c7 04 24 7c 70 10 00 	movl   $0x10707c,(%esp)
  10523d:	e8 06 b1 ff ff       	call   100348 <cprintf>
}
  105242:	c9                   	leave  
  105243:	c3                   	ret    

00105244 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105244:	55                   	push   %ebp
  105245:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  105247:	8b 45 08             	mov    0x8(%ebp),%eax
  10524a:	83 e0 04             	and    $0x4,%eax
  10524d:	85 c0                	test   %eax,%eax
  10524f:	74 07                	je     105258 <perm2str+0x14>
  105251:	b8 75 00 00 00       	mov    $0x75,%eax
  105256:	eb 05                	jmp    10525d <perm2str+0x19>
  105258:	b8 2d 00 00 00       	mov    $0x2d,%eax
  10525d:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  105262:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  105269:	8b 45 08             	mov    0x8(%ebp),%eax
  10526c:	83 e0 02             	and    $0x2,%eax
  10526f:	85 c0                	test   %eax,%eax
  105271:	74 07                	je     10527a <perm2str+0x36>
  105273:	b8 77 00 00 00       	mov    $0x77,%eax
  105278:	eb 05                	jmp    10527f <perm2str+0x3b>
  10527a:	b8 2d 00 00 00       	mov    $0x2d,%eax
  10527f:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  105284:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  10528b:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  105290:	5d                   	pop    %ebp
  105291:	c3                   	ret    

00105292 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  105292:	55                   	push   %ebp
  105293:	89 e5                	mov    %esp,%ebp
  105295:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  105298:	8b 45 10             	mov    0x10(%ebp),%eax
  10529b:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10529e:	72 0a                	jb     1052aa <get_pgtable_items+0x18>
        return 0;
  1052a0:	b8 00 00 00 00       	mov    $0x0,%eax
  1052a5:	e9 9c 00 00 00       	jmp    105346 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  1052aa:	eb 04                	jmp    1052b0 <get_pgtable_items+0x1e>
        start ++;
  1052ac:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  1052b0:	8b 45 10             	mov    0x10(%ebp),%eax
  1052b3:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052b6:	73 18                	jae    1052d0 <get_pgtable_items+0x3e>
  1052b8:	8b 45 10             	mov    0x10(%ebp),%eax
  1052bb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1052c2:	8b 45 14             	mov    0x14(%ebp),%eax
  1052c5:	01 d0                	add    %edx,%eax
  1052c7:	8b 00                	mov    (%eax),%eax
  1052c9:	83 e0 01             	and    $0x1,%eax
  1052cc:	85 c0                	test   %eax,%eax
  1052ce:	74 dc                	je     1052ac <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  1052d0:	8b 45 10             	mov    0x10(%ebp),%eax
  1052d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052d6:	73 69                	jae    105341 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  1052d8:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1052dc:	74 08                	je     1052e6 <get_pgtable_items+0x54>
            *left_store = start;
  1052de:	8b 45 18             	mov    0x18(%ebp),%eax
  1052e1:	8b 55 10             	mov    0x10(%ebp),%edx
  1052e4:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1052e6:	8b 45 10             	mov    0x10(%ebp),%eax
  1052e9:	8d 50 01             	lea    0x1(%eax),%edx
  1052ec:	89 55 10             	mov    %edx,0x10(%ebp)
  1052ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1052f6:	8b 45 14             	mov    0x14(%ebp),%eax
  1052f9:	01 d0                	add    %edx,%eax
  1052fb:	8b 00                	mov    (%eax),%eax
  1052fd:	83 e0 07             	and    $0x7,%eax
  105300:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105303:	eb 04                	jmp    105309 <get_pgtable_items+0x77>
            start ++;
  105305:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  105309:	8b 45 10             	mov    0x10(%ebp),%eax
  10530c:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10530f:	73 1d                	jae    10532e <get_pgtable_items+0x9c>
  105311:	8b 45 10             	mov    0x10(%ebp),%eax
  105314:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10531b:	8b 45 14             	mov    0x14(%ebp),%eax
  10531e:	01 d0                	add    %edx,%eax
  105320:	8b 00                	mov    (%eax),%eax
  105322:	83 e0 07             	and    $0x7,%eax
  105325:	89 c2                	mov    %eax,%edx
  105327:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10532a:	39 c2                	cmp    %eax,%edx
  10532c:	74 d7                	je     105305 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  10532e:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105332:	74 08                	je     10533c <get_pgtable_items+0xaa>
            *right_store = start;
  105334:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105337:	8b 55 10             	mov    0x10(%ebp),%edx
  10533a:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  10533c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10533f:	eb 05                	jmp    105346 <get_pgtable_items+0xb4>
    }
    return 0;
  105341:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105346:	c9                   	leave  
  105347:	c3                   	ret    

00105348 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  105348:	55                   	push   %ebp
  105349:	89 e5                	mov    %esp,%ebp
  10534b:	57                   	push   %edi
  10534c:	56                   	push   %esi
  10534d:	53                   	push   %ebx
  10534e:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  105351:	c7 04 24 9c 70 10 00 	movl   $0x10709c,(%esp)
  105358:	e8 eb af ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
  10535d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105364:	e9 fa 00 00 00       	jmp    105463 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105369:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10536c:	89 04 24             	mov    %eax,(%esp)
  10536f:	e8 d0 fe ff ff       	call   105244 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  105374:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105377:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10537a:	29 d1                	sub    %edx,%ecx
  10537c:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10537e:	89 d6                	mov    %edx,%esi
  105380:	c1 e6 16             	shl    $0x16,%esi
  105383:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105386:	89 d3                	mov    %edx,%ebx
  105388:	c1 e3 16             	shl    $0x16,%ebx
  10538b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10538e:	89 d1                	mov    %edx,%ecx
  105390:	c1 e1 16             	shl    $0x16,%ecx
  105393:	8b 7d dc             	mov    -0x24(%ebp),%edi
  105396:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105399:	29 d7                	sub    %edx,%edi
  10539b:	89 fa                	mov    %edi,%edx
  10539d:	89 44 24 14          	mov    %eax,0x14(%esp)
  1053a1:	89 74 24 10          	mov    %esi,0x10(%esp)
  1053a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1053a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1053ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  1053b1:	c7 04 24 cd 70 10 00 	movl   $0x1070cd,(%esp)
  1053b8:	e8 8b af ff ff       	call   100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  1053bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1053c0:	c1 e0 0a             	shl    $0xa,%eax
  1053c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1053c6:	eb 54                	jmp    10541c <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1053c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1053cb:	89 04 24             	mov    %eax,(%esp)
  1053ce:	e8 71 fe ff ff       	call   105244 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1053d3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1053d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1053d9:	29 d1                	sub    %edx,%ecx
  1053db:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1053dd:	89 d6                	mov    %edx,%esi
  1053df:	c1 e6 0c             	shl    $0xc,%esi
  1053e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1053e5:	89 d3                	mov    %edx,%ebx
  1053e7:	c1 e3 0c             	shl    $0xc,%ebx
  1053ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1053ed:	c1 e2 0c             	shl    $0xc,%edx
  1053f0:	89 d1                	mov    %edx,%ecx
  1053f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  1053f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1053f8:	29 d7                	sub    %edx,%edi
  1053fa:	89 fa                	mov    %edi,%edx
  1053fc:	89 44 24 14          	mov    %eax,0x14(%esp)
  105400:	89 74 24 10          	mov    %esi,0x10(%esp)
  105404:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105408:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10540c:	89 54 24 04          	mov    %edx,0x4(%esp)
  105410:	c7 04 24 ec 70 10 00 	movl   $0x1070ec,(%esp)
  105417:	e8 2c af ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10541c:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  105421:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105424:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105427:	89 ce                	mov    %ecx,%esi
  105429:	c1 e6 0a             	shl    $0xa,%esi
  10542c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  10542f:	89 cb                	mov    %ecx,%ebx
  105431:	c1 e3 0a             	shl    $0xa,%ebx
  105434:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  105437:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  10543b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  10543e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  105442:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105446:	89 44 24 08          	mov    %eax,0x8(%esp)
  10544a:	89 74 24 04          	mov    %esi,0x4(%esp)
  10544e:	89 1c 24             	mov    %ebx,(%esp)
  105451:	e8 3c fe ff ff       	call   105292 <get_pgtable_items>
  105456:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105459:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10545d:	0f 85 65 ff ff ff    	jne    1053c8 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105463:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  105468:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10546b:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  10546e:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  105472:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  105475:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  105479:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10547d:	89 44 24 08          	mov    %eax,0x8(%esp)
  105481:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  105488:	00 
  105489:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  105490:	e8 fd fd ff ff       	call   105292 <get_pgtable_items>
  105495:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105498:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10549c:	0f 85 c7 fe ff ff    	jne    105369 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1054a2:	c7 04 24 10 71 10 00 	movl   $0x107110,(%esp)
  1054a9:	e8 9a ae ff ff       	call   100348 <cprintf>
}
  1054ae:	83 c4 4c             	add    $0x4c,%esp
  1054b1:	5b                   	pop    %ebx
  1054b2:	5e                   	pop    %esi
  1054b3:	5f                   	pop    %edi
  1054b4:	5d                   	pop    %ebp
  1054b5:	c3                   	ret    

001054b6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1054b6:	55                   	push   %ebp
  1054b7:	89 e5                	mov    %esp,%ebp
  1054b9:	83 ec 58             	sub    $0x58,%esp
  1054bc:	8b 45 10             	mov    0x10(%ebp),%eax
  1054bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1054c2:	8b 45 14             	mov    0x14(%ebp),%eax
  1054c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1054c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1054cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1054ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1054d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1054d4:	8b 45 18             	mov    0x18(%ebp),%eax
  1054d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1054da:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1054dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1054e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1054e3:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1054e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1054ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1054f0:	74 1c                	je     10550e <printnum+0x58>
  1054f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054f5:	ba 00 00 00 00       	mov    $0x0,%edx
  1054fa:	f7 75 e4             	divl   -0x1c(%ebp)
  1054fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105500:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105503:	ba 00 00 00 00       	mov    $0x0,%edx
  105508:	f7 75 e4             	divl   -0x1c(%ebp)
  10550b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10550e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105511:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105514:	f7 75 e4             	divl   -0x1c(%ebp)
  105517:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10551a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10551d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105520:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105523:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105526:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105529:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10552c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10552f:	8b 45 18             	mov    0x18(%ebp),%eax
  105532:	ba 00 00 00 00       	mov    $0x0,%edx
  105537:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10553a:	77 56                	ja     105592 <printnum+0xdc>
  10553c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10553f:	72 05                	jb     105546 <printnum+0x90>
  105541:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105544:	77 4c                	ja     105592 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105546:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105549:	8d 50 ff             	lea    -0x1(%eax),%edx
  10554c:	8b 45 20             	mov    0x20(%ebp),%eax
  10554f:	89 44 24 18          	mov    %eax,0x18(%esp)
  105553:	89 54 24 14          	mov    %edx,0x14(%esp)
  105557:	8b 45 18             	mov    0x18(%ebp),%eax
  10555a:	89 44 24 10          	mov    %eax,0x10(%esp)
  10555e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105561:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105564:	89 44 24 08          	mov    %eax,0x8(%esp)
  105568:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10556c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10556f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105573:	8b 45 08             	mov    0x8(%ebp),%eax
  105576:	89 04 24             	mov    %eax,(%esp)
  105579:	e8 38 ff ff ff       	call   1054b6 <printnum>
  10557e:	eb 1c                	jmp    10559c <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105580:	8b 45 0c             	mov    0xc(%ebp),%eax
  105583:	89 44 24 04          	mov    %eax,0x4(%esp)
  105587:	8b 45 20             	mov    0x20(%ebp),%eax
  10558a:	89 04 24             	mov    %eax,(%esp)
  10558d:	8b 45 08             	mov    0x8(%ebp),%eax
  105590:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  105592:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  105596:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10559a:	7f e4                	jg     105580 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  10559c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10559f:	05 c4 71 10 00       	add    $0x1071c4,%eax
  1055a4:	0f b6 00             	movzbl (%eax),%eax
  1055a7:	0f be c0             	movsbl %al,%eax
  1055aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  1055ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  1055b1:	89 04 24             	mov    %eax,(%esp)
  1055b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1055b7:	ff d0                	call   *%eax
}
  1055b9:	c9                   	leave  
  1055ba:	c3                   	ret    

001055bb <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1055bb:	55                   	push   %ebp
  1055bc:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1055be:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1055c2:	7e 14                	jle    1055d8 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1055c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1055c7:	8b 00                	mov    (%eax),%eax
  1055c9:	8d 48 08             	lea    0x8(%eax),%ecx
  1055cc:	8b 55 08             	mov    0x8(%ebp),%edx
  1055cf:	89 0a                	mov    %ecx,(%edx)
  1055d1:	8b 50 04             	mov    0x4(%eax),%edx
  1055d4:	8b 00                	mov    (%eax),%eax
  1055d6:	eb 30                	jmp    105608 <getuint+0x4d>
    }
    else if (lflag) {
  1055d8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1055dc:	74 16                	je     1055f4 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  1055de:	8b 45 08             	mov    0x8(%ebp),%eax
  1055e1:	8b 00                	mov    (%eax),%eax
  1055e3:	8d 48 04             	lea    0x4(%eax),%ecx
  1055e6:	8b 55 08             	mov    0x8(%ebp),%edx
  1055e9:	89 0a                	mov    %ecx,(%edx)
  1055eb:	8b 00                	mov    (%eax),%eax
  1055ed:	ba 00 00 00 00       	mov    $0x0,%edx
  1055f2:	eb 14                	jmp    105608 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  1055f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1055f7:	8b 00                	mov    (%eax),%eax
  1055f9:	8d 48 04             	lea    0x4(%eax),%ecx
  1055fc:	8b 55 08             	mov    0x8(%ebp),%edx
  1055ff:	89 0a                	mov    %ecx,(%edx)
  105601:	8b 00                	mov    (%eax),%eax
  105603:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105608:	5d                   	pop    %ebp
  105609:	c3                   	ret    

0010560a <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  10560a:	55                   	push   %ebp
  10560b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10560d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105611:	7e 14                	jle    105627 <getint+0x1d>
        return va_arg(*ap, long long);
  105613:	8b 45 08             	mov    0x8(%ebp),%eax
  105616:	8b 00                	mov    (%eax),%eax
  105618:	8d 48 08             	lea    0x8(%eax),%ecx
  10561b:	8b 55 08             	mov    0x8(%ebp),%edx
  10561e:	89 0a                	mov    %ecx,(%edx)
  105620:	8b 50 04             	mov    0x4(%eax),%edx
  105623:	8b 00                	mov    (%eax),%eax
  105625:	eb 28                	jmp    10564f <getint+0x45>
    }
    else if (lflag) {
  105627:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10562b:	74 12                	je     10563f <getint+0x35>
        return va_arg(*ap, long);
  10562d:	8b 45 08             	mov    0x8(%ebp),%eax
  105630:	8b 00                	mov    (%eax),%eax
  105632:	8d 48 04             	lea    0x4(%eax),%ecx
  105635:	8b 55 08             	mov    0x8(%ebp),%edx
  105638:	89 0a                	mov    %ecx,(%edx)
  10563a:	8b 00                	mov    (%eax),%eax
  10563c:	99                   	cltd   
  10563d:	eb 10                	jmp    10564f <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  10563f:	8b 45 08             	mov    0x8(%ebp),%eax
  105642:	8b 00                	mov    (%eax),%eax
  105644:	8d 48 04             	lea    0x4(%eax),%ecx
  105647:	8b 55 08             	mov    0x8(%ebp),%edx
  10564a:	89 0a                	mov    %ecx,(%edx)
  10564c:	8b 00                	mov    (%eax),%eax
  10564e:	99                   	cltd   
    }
}
  10564f:	5d                   	pop    %ebp
  105650:	c3                   	ret    

00105651 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105651:	55                   	push   %ebp
  105652:	89 e5                	mov    %esp,%ebp
  105654:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105657:	8d 45 14             	lea    0x14(%ebp),%eax
  10565a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  10565d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105660:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105664:	8b 45 10             	mov    0x10(%ebp),%eax
  105667:	89 44 24 08          	mov    %eax,0x8(%esp)
  10566b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10566e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105672:	8b 45 08             	mov    0x8(%ebp),%eax
  105675:	89 04 24             	mov    %eax,(%esp)
  105678:	e8 02 00 00 00       	call   10567f <vprintfmt>
    va_end(ap);
}
  10567d:	c9                   	leave  
  10567e:	c3                   	ret    

0010567f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10567f:	55                   	push   %ebp
  105680:	89 e5                	mov    %esp,%ebp
  105682:	56                   	push   %esi
  105683:	53                   	push   %ebx
  105684:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105687:	eb 18                	jmp    1056a1 <vprintfmt+0x22>
            if (ch == '\0') {
  105689:	85 db                	test   %ebx,%ebx
  10568b:	75 05                	jne    105692 <vprintfmt+0x13>
                return;
  10568d:	e9 d1 03 00 00       	jmp    105a63 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  105692:	8b 45 0c             	mov    0xc(%ebp),%eax
  105695:	89 44 24 04          	mov    %eax,0x4(%esp)
  105699:	89 1c 24             	mov    %ebx,(%esp)
  10569c:	8b 45 08             	mov    0x8(%ebp),%eax
  10569f:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1056a1:	8b 45 10             	mov    0x10(%ebp),%eax
  1056a4:	8d 50 01             	lea    0x1(%eax),%edx
  1056a7:	89 55 10             	mov    %edx,0x10(%ebp)
  1056aa:	0f b6 00             	movzbl (%eax),%eax
  1056ad:	0f b6 d8             	movzbl %al,%ebx
  1056b0:	83 fb 25             	cmp    $0x25,%ebx
  1056b3:	75 d4                	jne    105689 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  1056b5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1056b9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1056c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1056c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1056c6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1056cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1056d0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  1056d3:	8b 45 10             	mov    0x10(%ebp),%eax
  1056d6:	8d 50 01             	lea    0x1(%eax),%edx
  1056d9:	89 55 10             	mov    %edx,0x10(%ebp)
  1056dc:	0f b6 00             	movzbl (%eax),%eax
  1056df:	0f b6 d8             	movzbl %al,%ebx
  1056e2:	8d 43 dd             	lea    -0x23(%ebx),%eax
  1056e5:	83 f8 55             	cmp    $0x55,%eax
  1056e8:	0f 87 44 03 00 00    	ja     105a32 <vprintfmt+0x3b3>
  1056ee:	8b 04 85 e8 71 10 00 	mov    0x1071e8(,%eax,4),%eax
  1056f5:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  1056f7:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  1056fb:	eb d6                	jmp    1056d3 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  1056fd:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105701:	eb d0                	jmp    1056d3 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105703:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  10570a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10570d:	89 d0                	mov    %edx,%eax
  10570f:	c1 e0 02             	shl    $0x2,%eax
  105712:	01 d0                	add    %edx,%eax
  105714:	01 c0                	add    %eax,%eax
  105716:	01 d8                	add    %ebx,%eax
  105718:	83 e8 30             	sub    $0x30,%eax
  10571b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10571e:	8b 45 10             	mov    0x10(%ebp),%eax
  105721:	0f b6 00             	movzbl (%eax),%eax
  105724:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105727:	83 fb 2f             	cmp    $0x2f,%ebx
  10572a:	7e 0b                	jle    105737 <vprintfmt+0xb8>
  10572c:	83 fb 39             	cmp    $0x39,%ebx
  10572f:	7f 06                	jg     105737 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105731:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  105735:	eb d3                	jmp    10570a <vprintfmt+0x8b>
            goto process_precision;
  105737:	eb 33                	jmp    10576c <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  105739:	8b 45 14             	mov    0x14(%ebp),%eax
  10573c:	8d 50 04             	lea    0x4(%eax),%edx
  10573f:	89 55 14             	mov    %edx,0x14(%ebp)
  105742:	8b 00                	mov    (%eax),%eax
  105744:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105747:	eb 23                	jmp    10576c <vprintfmt+0xed>

        case '.':
            if (width < 0)
  105749:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10574d:	79 0c                	jns    10575b <vprintfmt+0xdc>
                width = 0;
  10574f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105756:	e9 78 ff ff ff       	jmp    1056d3 <vprintfmt+0x54>
  10575b:	e9 73 ff ff ff       	jmp    1056d3 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  105760:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105767:	e9 67 ff ff ff       	jmp    1056d3 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  10576c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105770:	79 12                	jns    105784 <vprintfmt+0x105>
                width = precision, precision = -1;
  105772:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105775:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105778:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  10577f:	e9 4f ff ff ff       	jmp    1056d3 <vprintfmt+0x54>
  105784:	e9 4a ff ff ff       	jmp    1056d3 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105789:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  10578d:	e9 41 ff ff ff       	jmp    1056d3 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105792:	8b 45 14             	mov    0x14(%ebp),%eax
  105795:	8d 50 04             	lea    0x4(%eax),%edx
  105798:	89 55 14             	mov    %edx,0x14(%ebp)
  10579b:	8b 00                	mov    (%eax),%eax
  10579d:	8b 55 0c             	mov    0xc(%ebp),%edx
  1057a0:	89 54 24 04          	mov    %edx,0x4(%esp)
  1057a4:	89 04 24             	mov    %eax,(%esp)
  1057a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1057aa:	ff d0                	call   *%eax
            break;
  1057ac:	e9 ac 02 00 00       	jmp    105a5d <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1057b1:	8b 45 14             	mov    0x14(%ebp),%eax
  1057b4:	8d 50 04             	lea    0x4(%eax),%edx
  1057b7:	89 55 14             	mov    %edx,0x14(%ebp)
  1057ba:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1057bc:	85 db                	test   %ebx,%ebx
  1057be:	79 02                	jns    1057c2 <vprintfmt+0x143>
                err = -err;
  1057c0:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1057c2:	83 fb 06             	cmp    $0x6,%ebx
  1057c5:	7f 0b                	jg     1057d2 <vprintfmt+0x153>
  1057c7:	8b 34 9d a8 71 10 00 	mov    0x1071a8(,%ebx,4),%esi
  1057ce:	85 f6                	test   %esi,%esi
  1057d0:	75 23                	jne    1057f5 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  1057d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1057d6:	c7 44 24 08 d5 71 10 	movl   $0x1071d5,0x8(%esp)
  1057dd:	00 
  1057de:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1057e8:	89 04 24             	mov    %eax,(%esp)
  1057eb:	e8 61 fe ff ff       	call   105651 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  1057f0:	e9 68 02 00 00       	jmp    105a5d <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  1057f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1057f9:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105800:	00 
  105801:	8b 45 0c             	mov    0xc(%ebp),%eax
  105804:	89 44 24 04          	mov    %eax,0x4(%esp)
  105808:	8b 45 08             	mov    0x8(%ebp),%eax
  10580b:	89 04 24             	mov    %eax,(%esp)
  10580e:	e8 3e fe ff ff       	call   105651 <printfmt>
            }
            break;
  105813:	e9 45 02 00 00       	jmp    105a5d <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105818:	8b 45 14             	mov    0x14(%ebp),%eax
  10581b:	8d 50 04             	lea    0x4(%eax),%edx
  10581e:	89 55 14             	mov    %edx,0x14(%ebp)
  105821:	8b 30                	mov    (%eax),%esi
  105823:	85 f6                	test   %esi,%esi
  105825:	75 05                	jne    10582c <vprintfmt+0x1ad>
                p = "(null)";
  105827:	be e1 71 10 00       	mov    $0x1071e1,%esi
            }
            if (width > 0 && padc != '-') {
  10582c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105830:	7e 3e                	jle    105870 <vprintfmt+0x1f1>
  105832:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105836:	74 38                	je     105870 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105838:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  10583b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10583e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105842:	89 34 24             	mov    %esi,(%esp)
  105845:	e8 15 03 00 00       	call   105b5f <strnlen>
  10584a:	29 c3                	sub    %eax,%ebx
  10584c:	89 d8                	mov    %ebx,%eax
  10584e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105851:	eb 17                	jmp    10586a <vprintfmt+0x1eb>
                    putch(padc, putdat);
  105853:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105857:	8b 55 0c             	mov    0xc(%ebp),%edx
  10585a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10585e:	89 04 24             	mov    %eax,(%esp)
  105861:	8b 45 08             	mov    0x8(%ebp),%eax
  105864:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  105866:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  10586a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10586e:	7f e3                	jg     105853 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105870:	eb 38                	jmp    1058aa <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  105872:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105876:	74 1f                	je     105897 <vprintfmt+0x218>
  105878:	83 fb 1f             	cmp    $0x1f,%ebx
  10587b:	7e 05                	jle    105882 <vprintfmt+0x203>
  10587d:	83 fb 7e             	cmp    $0x7e,%ebx
  105880:	7e 15                	jle    105897 <vprintfmt+0x218>
                    putch('?', putdat);
  105882:	8b 45 0c             	mov    0xc(%ebp),%eax
  105885:	89 44 24 04          	mov    %eax,0x4(%esp)
  105889:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105890:	8b 45 08             	mov    0x8(%ebp),%eax
  105893:	ff d0                	call   *%eax
  105895:	eb 0f                	jmp    1058a6 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  105897:	8b 45 0c             	mov    0xc(%ebp),%eax
  10589a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10589e:	89 1c 24             	mov    %ebx,(%esp)
  1058a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1058a4:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1058a6:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1058aa:	89 f0                	mov    %esi,%eax
  1058ac:	8d 70 01             	lea    0x1(%eax),%esi
  1058af:	0f b6 00             	movzbl (%eax),%eax
  1058b2:	0f be d8             	movsbl %al,%ebx
  1058b5:	85 db                	test   %ebx,%ebx
  1058b7:	74 10                	je     1058c9 <vprintfmt+0x24a>
  1058b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1058bd:	78 b3                	js     105872 <vprintfmt+0x1f3>
  1058bf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  1058c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1058c7:	79 a9                	jns    105872 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  1058c9:	eb 17                	jmp    1058e2 <vprintfmt+0x263>
                putch(' ', putdat);
  1058cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1058d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1058dc:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  1058de:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1058e2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1058e6:	7f e3                	jg     1058cb <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  1058e8:	e9 70 01 00 00       	jmp    105a5d <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  1058ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058f4:	8d 45 14             	lea    0x14(%ebp),%eax
  1058f7:	89 04 24             	mov    %eax,(%esp)
  1058fa:	e8 0b fd ff ff       	call   10560a <getint>
  1058ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105902:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105905:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105908:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10590b:	85 d2                	test   %edx,%edx
  10590d:	79 26                	jns    105935 <vprintfmt+0x2b6>
                putch('-', putdat);
  10590f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105912:	89 44 24 04          	mov    %eax,0x4(%esp)
  105916:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  10591d:	8b 45 08             	mov    0x8(%ebp),%eax
  105920:	ff d0                	call   *%eax
                num = -(long long)num;
  105922:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105925:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105928:	f7 d8                	neg    %eax
  10592a:	83 d2 00             	adc    $0x0,%edx
  10592d:	f7 da                	neg    %edx
  10592f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105932:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105935:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  10593c:	e9 a8 00 00 00       	jmp    1059e9 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105941:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105944:	89 44 24 04          	mov    %eax,0x4(%esp)
  105948:	8d 45 14             	lea    0x14(%ebp),%eax
  10594b:	89 04 24             	mov    %eax,(%esp)
  10594e:	e8 68 fc ff ff       	call   1055bb <getuint>
  105953:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105956:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105959:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105960:	e9 84 00 00 00       	jmp    1059e9 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105965:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105968:	89 44 24 04          	mov    %eax,0x4(%esp)
  10596c:	8d 45 14             	lea    0x14(%ebp),%eax
  10596f:	89 04 24             	mov    %eax,(%esp)
  105972:	e8 44 fc ff ff       	call   1055bb <getuint>
  105977:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10597a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  10597d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105984:	eb 63                	jmp    1059e9 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  105986:	8b 45 0c             	mov    0xc(%ebp),%eax
  105989:	89 44 24 04          	mov    %eax,0x4(%esp)
  10598d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105994:	8b 45 08             	mov    0x8(%ebp),%eax
  105997:	ff d0                	call   *%eax
            putch('x', putdat);
  105999:	8b 45 0c             	mov    0xc(%ebp),%eax
  10599c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059a0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  1059a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1059aa:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  1059ac:	8b 45 14             	mov    0x14(%ebp),%eax
  1059af:	8d 50 04             	lea    0x4(%eax),%edx
  1059b2:	89 55 14             	mov    %edx,0x14(%ebp)
  1059b5:	8b 00                	mov    (%eax),%eax
  1059b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1059c1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1059c8:	eb 1f                	jmp    1059e9 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1059ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1059cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059d1:	8d 45 14             	lea    0x14(%ebp),%eax
  1059d4:	89 04 24             	mov    %eax,(%esp)
  1059d7:	e8 df fb ff ff       	call   1055bb <getuint>
  1059dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059df:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  1059e2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  1059e9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  1059ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1059f0:	89 54 24 18          	mov    %edx,0x18(%esp)
  1059f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1059f7:	89 54 24 14          	mov    %edx,0x14(%esp)
  1059fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  1059ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105a05:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a09:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a14:	8b 45 08             	mov    0x8(%ebp),%eax
  105a17:	89 04 24             	mov    %eax,(%esp)
  105a1a:	e8 97 fa ff ff       	call   1054b6 <printnum>
            break;
  105a1f:	eb 3c                	jmp    105a5d <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105a21:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a24:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a28:	89 1c 24             	mov    %ebx,(%esp)
  105a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  105a2e:	ff d0                	call   *%eax
            break;
  105a30:	eb 2b                	jmp    105a5d <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a35:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a39:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105a40:	8b 45 08             	mov    0x8(%ebp),%eax
  105a43:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105a45:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105a49:	eb 04                	jmp    105a4f <vprintfmt+0x3d0>
  105a4b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105a4f:	8b 45 10             	mov    0x10(%ebp),%eax
  105a52:	83 e8 01             	sub    $0x1,%eax
  105a55:	0f b6 00             	movzbl (%eax),%eax
  105a58:	3c 25                	cmp    $0x25,%al
  105a5a:	75 ef                	jne    105a4b <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  105a5c:	90                   	nop
        }
    }
  105a5d:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105a5e:	e9 3e fc ff ff       	jmp    1056a1 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  105a63:	83 c4 40             	add    $0x40,%esp
  105a66:	5b                   	pop    %ebx
  105a67:	5e                   	pop    %esi
  105a68:	5d                   	pop    %ebp
  105a69:	c3                   	ret    

00105a6a <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105a6a:	55                   	push   %ebp
  105a6b:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a70:	8b 40 08             	mov    0x8(%eax),%eax
  105a73:	8d 50 01             	lea    0x1(%eax),%edx
  105a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a79:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a7f:	8b 10                	mov    (%eax),%edx
  105a81:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a84:	8b 40 04             	mov    0x4(%eax),%eax
  105a87:	39 c2                	cmp    %eax,%edx
  105a89:	73 12                	jae    105a9d <sprintputch+0x33>
        *b->buf ++ = ch;
  105a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a8e:	8b 00                	mov    (%eax),%eax
  105a90:	8d 48 01             	lea    0x1(%eax),%ecx
  105a93:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a96:	89 0a                	mov    %ecx,(%edx)
  105a98:	8b 55 08             	mov    0x8(%ebp),%edx
  105a9b:	88 10                	mov    %dl,(%eax)
    }
}
  105a9d:	5d                   	pop    %ebp
  105a9e:	c3                   	ret    

00105a9f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105a9f:	55                   	push   %ebp
  105aa0:	89 e5                	mov    %esp,%ebp
  105aa2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105aa5:	8d 45 14             	lea    0x14(%ebp),%eax
  105aa8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105aae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  105ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  105ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  105ac3:	89 04 24             	mov    %eax,(%esp)
  105ac6:	e8 08 00 00 00       	call   105ad3 <vsnprintf>
  105acb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105ad1:	c9                   	leave  
  105ad2:	c3                   	ret    

00105ad3 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105ad3:	55                   	push   %ebp
  105ad4:	89 e5                	mov    %esp,%ebp
  105ad6:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  105adc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105adf:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ae2:	8d 50 ff             	lea    -0x1(%eax),%edx
  105ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  105ae8:	01 d0                	add    %edx,%eax
  105aea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105aed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105af4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105af8:	74 0a                	je     105b04 <vsnprintf+0x31>
  105afa:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b00:	39 c2                	cmp    %eax,%edx
  105b02:	76 07                	jbe    105b0b <vsnprintf+0x38>
        return -E_INVAL;
  105b04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105b09:	eb 2a                	jmp    105b35 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105b0b:	8b 45 14             	mov    0x14(%ebp),%eax
  105b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105b12:	8b 45 10             	mov    0x10(%ebp),%eax
  105b15:	89 44 24 08          	mov    %eax,0x8(%esp)
  105b19:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b20:	c7 04 24 6a 5a 10 00 	movl   $0x105a6a,(%esp)
  105b27:	e8 53 fb ff ff       	call   10567f <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105b2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105b2f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105b35:	c9                   	leave  
  105b36:	c3                   	ret    

00105b37 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105b37:	55                   	push   %ebp
  105b38:	89 e5                	mov    %esp,%ebp
  105b3a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105b3d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105b44:	eb 04                	jmp    105b4a <strlen+0x13>
        cnt ++;
  105b46:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  105b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  105b4d:	8d 50 01             	lea    0x1(%eax),%edx
  105b50:	89 55 08             	mov    %edx,0x8(%ebp)
  105b53:	0f b6 00             	movzbl (%eax),%eax
  105b56:	84 c0                	test   %al,%al
  105b58:	75 ec                	jne    105b46 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  105b5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105b5d:	c9                   	leave  
  105b5e:	c3                   	ret    

00105b5f <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105b5f:	55                   	push   %ebp
  105b60:	89 e5                	mov    %esp,%ebp
  105b62:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105b65:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105b6c:	eb 04                	jmp    105b72 <strnlen+0x13>
        cnt ++;
  105b6e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  105b72:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b75:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105b78:	73 10                	jae    105b8a <strnlen+0x2b>
  105b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  105b7d:	8d 50 01             	lea    0x1(%eax),%edx
  105b80:	89 55 08             	mov    %edx,0x8(%ebp)
  105b83:	0f b6 00             	movzbl (%eax),%eax
  105b86:	84 c0                	test   %al,%al
  105b88:	75 e4                	jne    105b6e <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  105b8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105b8d:	c9                   	leave  
  105b8e:	c3                   	ret    

00105b8f <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105b8f:	55                   	push   %ebp
  105b90:	89 e5                	mov    %esp,%ebp
  105b92:	57                   	push   %edi
  105b93:	56                   	push   %esi
  105b94:	83 ec 20             	sub    $0x20,%esp
  105b97:	8b 45 08             	mov    0x8(%ebp),%eax
  105b9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ba0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105ba3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105ba9:	89 d1                	mov    %edx,%ecx
  105bab:	89 c2                	mov    %eax,%edx
  105bad:	89 ce                	mov    %ecx,%esi
  105baf:	89 d7                	mov    %edx,%edi
  105bb1:	ac                   	lods   %ds:(%esi),%al
  105bb2:	aa                   	stos   %al,%es:(%edi)
  105bb3:	84 c0                	test   %al,%al
  105bb5:	75 fa                	jne    105bb1 <strcpy+0x22>
  105bb7:	89 fa                	mov    %edi,%edx
  105bb9:	89 f1                	mov    %esi,%ecx
  105bbb:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105bbe:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105bc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105bc7:	83 c4 20             	add    $0x20,%esp
  105bca:	5e                   	pop    %esi
  105bcb:	5f                   	pop    %edi
  105bcc:	5d                   	pop    %ebp
  105bcd:	c3                   	ret    

00105bce <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105bce:	55                   	push   %ebp
  105bcf:	89 e5                	mov    %esp,%ebp
  105bd1:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  105bd7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105bda:	eb 21                	jmp    105bfd <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  105bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bdf:	0f b6 10             	movzbl (%eax),%edx
  105be2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105be5:	88 10                	mov    %dl,(%eax)
  105be7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105bea:	0f b6 00             	movzbl (%eax),%eax
  105bed:	84 c0                	test   %al,%al
  105bef:	74 04                	je     105bf5 <strncpy+0x27>
            src ++;
  105bf1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105bf5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105bf9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105bfd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c01:	75 d9                	jne    105bdc <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105c03:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105c06:	c9                   	leave  
  105c07:	c3                   	ret    

00105c08 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105c08:	55                   	push   %ebp
  105c09:	89 e5                	mov    %esp,%ebp
  105c0b:	57                   	push   %edi
  105c0c:	56                   	push   %esi
  105c0d:	83 ec 20             	sub    $0x20,%esp
  105c10:	8b 45 08             	mov    0x8(%ebp),%eax
  105c13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105c16:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c19:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  105c1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c22:	89 d1                	mov    %edx,%ecx
  105c24:	89 c2                	mov    %eax,%edx
  105c26:	89 ce                	mov    %ecx,%esi
  105c28:	89 d7                	mov    %edx,%edi
  105c2a:	ac                   	lods   %ds:(%esi),%al
  105c2b:	ae                   	scas   %es:(%edi),%al
  105c2c:	75 08                	jne    105c36 <strcmp+0x2e>
  105c2e:	84 c0                	test   %al,%al
  105c30:	75 f8                	jne    105c2a <strcmp+0x22>
  105c32:	31 c0                	xor    %eax,%eax
  105c34:	eb 04                	jmp    105c3a <strcmp+0x32>
  105c36:	19 c0                	sbb    %eax,%eax
  105c38:	0c 01                	or     $0x1,%al
  105c3a:	89 fa                	mov    %edi,%edx
  105c3c:	89 f1                	mov    %esi,%ecx
  105c3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105c41:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105c44:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  105c47:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105c4a:	83 c4 20             	add    $0x20,%esp
  105c4d:	5e                   	pop    %esi
  105c4e:	5f                   	pop    %edi
  105c4f:	5d                   	pop    %ebp
  105c50:	c3                   	ret    

00105c51 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105c51:	55                   	push   %ebp
  105c52:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105c54:	eb 0c                	jmp    105c62 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105c56:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105c5a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105c5e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105c62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c66:	74 1a                	je     105c82 <strncmp+0x31>
  105c68:	8b 45 08             	mov    0x8(%ebp),%eax
  105c6b:	0f b6 00             	movzbl (%eax),%eax
  105c6e:	84 c0                	test   %al,%al
  105c70:	74 10                	je     105c82 <strncmp+0x31>
  105c72:	8b 45 08             	mov    0x8(%ebp),%eax
  105c75:	0f b6 10             	movzbl (%eax),%edx
  105c78:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c7b:	0f b6 00             	movzbl (%eax),%eax
  105c7e:	38 c2                	cmp    %al,%dl
  105c80:	74 d4                	je     105c56 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105c82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c86:	74 18                	je     105ca0 <strncmp+0x4f>
  105c88:	8b 45 08             	mov    0x8(%ebp),%eax
  105c8b:	0f b6 00             	movzbl (%eax),%eax
  105c8e:	0f b6 d0             	movzbl %al,%edx
  105c91:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c94:	0f b6 00             	movzbl (%eax),%eax
  105c97:	0f b6 c0             	movzbl %al,%eax
  105c9a:	29 c2                	sub    %eax,%edx
  105c9c:	89 d0                	mov    %edx,%eax
  105c9e:	eb 05                	jmp    105ca5 <strncmp+0x54>
  105ca0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105ca5:	5d                   	pop    %ebp
  105ca6:	c3                   	ret    

00105ca7 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105ca7:	55                   	push   %ebp
  105ca8:	89 e5                	mov    %esp,%ebp
  105caa:	83 ec 04             	sub    $0x4,%esp
  105cad:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cb0:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105cb3:	eb 14                	jmp    105cc9 <strchr+0x22>
        if (*s == c) {
  105cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  105cb8:	0f b6 00             	movzbl (%eax),%eax
  105cbb:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105cbe:	75 05                	jne    105cc5 <strchr+0x1e>
            return (char *)s;
  105cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  105cc3:	eb 13                	jmp    105cd8 <strchr+0x31>
        }
        s ++;
  105cc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  105cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  105ccc:	0f b6 00             	movzbl (%eax),%eax
  105ccf:	84 c0                	test   %al,%al
  105cd1:	75 e2                	jne    105cb5 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105cd8:	c9                   	leave  
  105cd9:	c3                   	ret    

00105cda <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105cda:	55                   	push   %ebp
  105cdb:	89 e5                	mov    %esp,%ebp
  105cdd:	83 ec 04             	sub    $0x4,%esp
  105ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ce3:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105ce6:	eb 11                	jmp    105cf9 <strfind+0x1f>
        if (*s == c) {
  105ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  105ceb:	0f b6 00             	movzbl (%eax),%eax
  105cee:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105cf1:	75 02                	jne    105cf5 <strfind+0x1b>
            break;
  105cf3:	eb 0e                	jmp    105d03 <strfind+0x29>
        }
        s ++;
  105cf5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  105cfc:	0f b6 00             	movzbl (%eax),%eax
  105cff:	84 c0                	test   %al,%al
  105d01:	75 e5                	jne    105ce8 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  105d03:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105d06:	c9                   	leave  
  105d07:	c3                   	ret    

00105d08 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105d08:	55                   	push   %ebp
  105d09:	89 e5                	mov    %esp,%ebp
  105d0b:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105d0e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105d15:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105d1c:	eb 04                	jmp    105d22 <strtol+0x1a>
        s ++;
  105d1e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105d22:	8b 45 08             	mov    0x8(%ebp),%eax
  105d25:	0f b6 00             	movzbl (%eax),%eax
  105d28:	3c 20                	cmp    $0x20,%al
  105d2a:	74 f2                	je     105d1e <strtol+0x16>
  105d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d2f:	0f b6 00             	movzbl (%eax),%eax
  105d32:	3c 09                	cmp    $0x9,%al
  105d34:	74 e8                	je     105d1e <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105d36:	8b 45 08             	mov    0x8(%ebp),%eax
  105d39:	0f b6 00             	movzbl (%eax),%eax
  105d3c:	3c 2b                	cmp    $0x2b,%al
  105d3e:	75 06                	jne    105d46 <strtol+0x3e>
        s ++;
  105d40:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d44:	eb 15                	jmp    105d5b <strtol+0x53>
    }
    else if (*s == '-') {
  105d46:	8b 45 08             	mov    0x8(%ebp),%eax
  105d49:	0f b6 00             	movzbl (%eax),%eax
  105d4c:	3c 2d                	cmp    $0x2d,%al
  105d4e:	75 0b                	jne    105d5b <strtol+0x53>
        s ++, neg = 1;
  105d50:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d54:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105d5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d5f:	74 06                	je     105d67 <strtol+0x5f>
  105d61:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105d65:	75 24                	jne    105d8b <strtol+0x83>
  105d67:	8b 45 08             	mov    0x8(%ebp),%eax
  105d6a:	0f b6 00             	movzbl (%eax),%eax
  105d6d:	3c 30                	cmp    $0x30,%al
  105d6f:	75 1a                	jne    105d8b <strtol+0x83>
  105d71:	8b 45 08             	mov    0x8(%ebp),%eax
  105d74:	83 c0 01             	add    $0x1,%eax
  105d77:	0f b6 00             	movzbl (%eax),%eax
  105d7a:	3c 78                	cmp    $0x78,%al
  105d7c:	75 0d                	jne    105d8b <strtol+0x83>
        s += 2, base = 16;
  105d7e:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105d82:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105d89:	eb 2a                	jmp    105db5 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105d8b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d8f:	75 17                	jne    105da8 <strtol+0xa0>
  105d91:	8b 45 08             	mov    0x8(%ebp),%eax
  105d94:	0f b6 00             	movzbl (%eax),%eax
  105d97:	3c 30                	cmp    $0x30,%al
  105d99:	75 0d                	jne    105da8 <strtol+0xa0>
        s ++, base = 8;
  105d9b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d9f:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105da6:	eb 0d                	jmp    105db5 <strtol+0xad>
    }
    else if (base == 0) {
  105da8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105dac:	75 07                	jne    105db5 <strtol+0xad>
        base = 10;
  105dae:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105db5:	8b 45 08             	mov    0x8(%ebp),%eax
  105db8:	0f b6 00             	movzbl (%eax),%eax
  105dbb:	3c 2f                	cmp    $0x2f,%al
  105dbd:	7e 1b                	jle    105dda <strtol+0xd2>
  105dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  105dc2:	0f b6 00             	movzbl (%eax),%eax
  105dc5:	3c 39                	cmp    $0x39,%al
  105dc7:	7f 11                	jg     105dda <strtol+0xd2>
            dig = *s - '0';
  105dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  105dcc:	0f b6 00             	movzbl (%eax),%eax
  105dcf:	0f be c0             	movsbl %al,%eax
  105dd2:	83 e8 30             	sub    $0x30,%eax
  105dd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105dd8:	eb 48                	jmp    105e22 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105dda:	8b 45 08             	mov    0x8(%ebp),%eax
  105ddd:	0f b6 00             	movzbl (%eax),%eax
  105de0:	3c 60                	cmp    $0x60,%al
  105de2:	7e 1b                	jle    105dff <strtol+0xf7>
  105de4:	8b 45 08             	mov    0x8(%ebp),%eax
  105de7:	0f b6 00             	movzbl (%eax),%eax
  105dea:	3c 7a                	cmp    $0x7a,%al
  105dec:	7f 11                	jg     105dff <strtol+0xf7>
            dig = *s - 'a' + 10;
  105dee:	8b 45 08             	mov    0x8(%ebp),%eax
  105df1:	0f b6 00             	movzbl (%eax),%eax
  105df4:	0f be c0             	movsbl %al,%eax
  105df7:	83 e8 57             	sub    $0x57,%eax
  105dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105dfd:	eb 23                	jmp    105e22 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105dff:	8b 45 08             	mov    0x8(%ebp),%eax
  105e02:	0f b6 00             	movzbl (%eax),%eax
  105e05:	3c 40                	cmp    $0x40,%al
  105e07:	7e 3d                	jle    105e46 <strtol+0x13e>
  105e09:	8b 45 08             	mov    0x8(%ebp),%eax
  105e0c:	0f b6 00             	movzbl (%eax),%eax
  105e0f:	3c 5a                	cmp    $0x5a,%al
  105e11:	7f 33                	jg     105e46 <strtol+0x13e>
            dig = *s - 'A' + 10;
  105e13:	8b 45 08             	mov    0x8(%ebp),%eax
  105e16:	0f b6 00             	movzbl (%eax),%eax
  105e19:	0f be c0             	movsbl %al,%eax
  105e1c:	83 e8 37             	sub    $0x37,%eax
  105e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105e25:	3b 45 10             	cmp    0x10(%ebp),%eax
  105e28:	7c 02                	jl     105e2c <strtol+0x124>
            break;
  105e2a:	eb 1a                	jmp    105e46 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  105e2c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105e30:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105e33:	0f af 45 10          	imul   0x10(%ebp),%eax
  105e37:	89 c2                	mov    %eax,%edx
  105e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105e3c:	01 d0                	add    %edx,%eax
  105e3e:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  105e41:	e9 6f ff ff ff       	jmp    105db5 <strtol+0xad>

    if (endptr) {
  105e46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105e4a:	74 08                	je     105e54 <strtol+0x14c>
        *endptr = (char *) s;
  105e4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  105e52:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105e54:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105e58:	74 07                	je     105e61 <strtol+0x159>
  105e5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105e5d:	f7 d8                	neg    %eax
  105e5f:	eb 03                	jmp    105e64 <strtol+0x15c>
  105e61:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105e64:	c9                   	leave  
  105e65:	c3                   	ret    

00105e66 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105e66:	55                   	push   %ebp
  105e67:	89 e5                	mov    %esp,%ebp
  105e69:	57                   	push   %edi
  105e6a:	83 ec 24             	sub    $0x24,%esp
  105e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e70:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105e73:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105e77:	8b 55 08             	mov    0x8(%ebp),%edx
  105e7a:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105e7d:	88 45 f7             	mov    %al,-0x9(%ebp)
  105e80:	8b 45 10             	mov    0x10(%ebp),%eax
  105e83:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105e86:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105e89:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105e8d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105e90:	89 d7                	mov    %edx,%edi
  105e92:	f3 aa                	rep stos %al,%es:(%edi)
  105e94:	89 fa                	mov    %edi,%edx
  105e96:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105e99:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105e9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105e9f:	83 c4 24             	add    $0x24,%esp
  105ea2:	5f                   	pop    %edi
  105ea3:	5d                   	pop    %ebp
  105ea4:	c3                   	ret    

00105ea5 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105ea5:	55                   	push   %ebp
  105ea6:	89 e5                	mov    %esp,%ebp
  105ea8:	57                   	push   %edi
  105ea9:	56                   	push   %esi
  105eaa:	53                   	push   %ebx
  105eab:	83 ec 30             	sub    $0x30,%esp
  105eae:	8b 45 08             	mov    0x8(%ebp),%eax
  105eb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  105eb7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105eba:	8b 45 10             	mov    0x10(%ebp),%eax
  105ebd:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ec3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105ec6:	73 42                	jae    105f0a <memmove+0x65>
  105ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ecb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105ece:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ed1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ed7:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105eda:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105edd:	c1 e8 02             	shr    $0x2,%eax
  105ee0:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105ee2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105ee5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ee8:	89 d7                	mov    %edx,%edi
  105eea:	89 c6                	mov    %eax,%esi
  105eec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105eee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105ef1:	83 e1 03             	and    $0x3,%ecx
  105ef4:	74 02                	je     105ef8 <memmove+0x53>
  105ef6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105ef8:	89 f0                	mov    %esi,%eax
  105efa:	89 fa                	mov    %edi,%edx
  105efc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105eff:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105f02:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105f05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105f08:	eb 36                	jmp    105f40 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105f0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f0d:	8d 50 ff             	lea    -0x1(%eax),%edx
  105f10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f13:	01 c2                	add    %eax,%edx
  105f15:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f18:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f1e:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  105f21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f24:	89 c1                	mov    %eax,%ecx
  105f26:	89 d8                	mov    %ebx,%eax
  105f28:	89 d6                	mov    %edx,%esi
  105f2a:	89 c7                	mov    %eax,%edi
  105f2c:	fd                   	std    
  105f2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105f2f:	fc                   	cld    
  105f30:	89 f8                	mov    %edi,%eax
  105f32:	89 f2                	mov    %esi,%edx
  105f34:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105f37:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105f3a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  105f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105f40:	83 c4 30             	add    $0x30,%esp
  105f43:	5b                   	pop    %ebx
  105f44:	5e                   	pop    %esi
  105f45:	5f                   	pop    %edi
  105f46:	5d                   	pop    %ebp
  105f47:	c3                   	ret    

00105f48 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105f48:	55                   	push   %ebp
  105f49:	89 e5                	mov    %esp,%ebp
  105f4b:	57                   	push   %edi
  105f4c:	56                   	push   %esi
  105f4d:	83 ec 20             	sub    $0x20,%esp
  105f50:	8b 45 08             	mov    0x8(%ebp),%eax
  105f53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f5c:	8b 45 10             	mov    0x10(%ebp),%eax
  105f5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f65:	c1 e8 02             	shr    $0x2,%eax
  105f68:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105f6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f70:	89 d7                	mov    %edx,%edi
  105f72:	89 c6                	mov    %eax,%esi
  105f74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105f76:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105f79:	83 e1 03             	and    $0x3,%ecx
  105f7c:	74 02                	je     105f80 <memcpy+0x38>
  105f7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105f80:	89 f0                	mov    %esi,%eax
  105f82:	89 fa                	mov    %edi,%edx
  105f84:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105f87:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105f8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105f90:	83 c4 20             	add    $0x20,%esp
  105f93:	5e                   	pop    %esi
  105f94:	5f                   	pop    %edi
  105f95:	5d                   	pop    %ebp
  105f96:	c3                   	ret    

00105f97 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105f97:	55                   	push   %ebp
  105f98:	89 e5                	mov    %esp,%ebp
  105f9a:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  105fa0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fa6:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105fa9:	eb 30                	jmp    105fdb <memcmp+0x44>
        if (*s1 != *s2) {
  105fab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105fae:	0f b6 10             	movzbl (%eax),%edx
  105fb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105fb4:	0f b6 00             	movzbl (%eax),%eax
  105fb7:	38 c2                	cmp    %al,%dl
  105fb9:	74 18                	je     105fd3 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105fbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105fbe:	0f b6 00             	movzbl (%eax),%eax
  105fc1:	0f b6 d0             	movzbl %al,%edx
  105fc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105fc7:	0f b6 00             	movzbl (%eax),%eax
  105fca:	0f b6 c0             	movzbl %al,%eax
  105fcd:	29 c2                	sub    %eax,%edx
  105fcf:	89 d0                	mov    %edx,%eax
  105fd1:	eb 1a                	jmp    105fed <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105fd3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105fd7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  105fdb:	8b 45 10             	mov    0x10(%ebp),%eax
  105fde:	8d 50 ff             	lea    -0x1(%eax),%edx
  105fe1:	89 55 10             	mov    %edx,0x10(%ebp)
  105fe4:	85 c0                	test   %eax,%eax
  105fe6:	75 c3                	jne    105fab <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  105fe8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105fed:	c9                   	leave  
  105fee:	c3                   	ret    
