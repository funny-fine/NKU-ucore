
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 a0 11 40       	mov    $0x4011a000,%eax
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
  100020:	a3 00 a0 11 00       	mov    %eax,0x11a000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 90 11 00       	mov    $0x119000,%esp
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
  10003c:	ba bc d0 11 00       	mov    $0x11d0bc,%edx
  100041:	b8 36 9a 11 00       	mov    $0x119a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 9a 11 00 	movl   $0x119a36,(%esp)
  10005d:	e8 90 6a 00 00       	call   106af2 <memset>

    cons_init();                // init the console
  100062:	e8 c8 14 00 00       	call   10152f <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 80 6c 10 00 	movl   $0x106c80,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 9c 6c 10 00 	movl   $0x106c9c,(%esp)
  10007c:	e8 c7 02 00 00       	call   100348 <cprintf>

    print_kerninfo();
  100081:	e8 f6 07 00 00       	call   10087c <print_kerninfo>

    grade_backtrace();
  100086:	e8 86 00 00 00       	call   100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 cd 4f 00 00       	call   10505d <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 03 16 00 00       	call   101698 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 55 17 00 00       	call   1017ef <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 46 0c 00 00       	call   100ce5 <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 62 15 00 00       	call   101606 <intr_enable>
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
  1000c3:	e8 3e 0b 00 00       	call   100c06 <mon_backtrace>
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
  100154:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100159:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100161:	c7 04 24 a1 6c 10 00 	movl   $0x106ca1,(%esp)
  100168:	e8 db 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100171:	0f b7 d0             	movzwl %ax,%edx
  100174:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 af 6c 10 00 	movl   $0x106caf,(%esp)
  100188:	e8 bb 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	0f b7 d0             	movzwl %ax,%edx
  100194:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 bd 6c 10 00 	movl   $0x106cbd,(%esp)
  1001a8:	e8 9b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 cb 6c 10 00 	movl   $0x106ccb,(%esp)
  1001c8:	e8 7b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d1:	0f b7 d0             	movzwl %ax,%edx
  1001d4:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e1:	c7 04 24 d9 6c 10 00 	movl   $0x106cd9,(%esp)
  1001e8:	e8 5b 01 00 00       	call   100348 <cprintf>
    round ++;
  1001ed:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001f2:	83 c0 01             	add    $0x1,%eax
  1001f5:	a3 00 c0 11 00       	mov    %eax,0x11c000
}
  1001fa:	c9                   	leave  
  1001fb:	c3                   	ret    

001001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fc:	55                   	push   %ebp
  1001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001ff:	5d                   	pop    %ebp
  100200:	c3                   	ret    

00100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100201:	55                   	push   %ebp
  100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
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
  100211:	c7 04 24 e8 6c 10 00 	movl   $0x106ce8,(%esp)
  100218:	e8 2b 01 00 00       	call   100348 <cprintf>
    lab1_switch_to_user();
  10021d:	e8 da ff ff ff       	call   1001fc <lab1_switch_to_user>
    lab1_print_cur_status();
  100222:	e8 0f ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100227:	c7 04 24 08 6d 10 00 	movl   $0x106d08,(%esp)
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
  100252:	c7 04 24 27 6d 10 00 	movl   $0x106d27,(%esp)
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
  1002a0:	88 90 20 c0 11 00    	mov    %dl,0x11c020(%eax)
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
  1002df:	05 20 c0 11 00       	add    $0x11c020,%eax
  1002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002e7:	b8 20 c0 11 00       	mov    $0x11c020,%eax
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
  100301:	e8 55 12 00 00       	call   10155b <cons_putc>
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
  10033e:	e8 c8 5f 00 00       	call   10630b <vprintfmt>
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
  10037a:	e8 dc 11 00 00       	call   10155b <cons_putc>
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
  1003d6:	e8 bc 11 00 00       	call   101597 <cons_getc>
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
  100548:	c7 00 2c 6d 10 00    	movl   $0x106d2c,(%eax)
    info->eip_line = 0;
  10054e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100558:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055b:	c7 40 08 2c 6d 10 00 	movl   $0x106d2c,0x8(%eax)
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
  10057f:	c7 45 f4 34 81 10 00 	movl   $0x108134,-0xc(%ebp)
    stab_end = __STAB_END__;
  100586:	c7 45 f0 04 3e 11 00 	movl   $0x113e04,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10058d:	c7 45 ec 05 3e 11 00 	movl   $0x113e05,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100594:	c7 45 e8 bb 69 11 00 	movl   $0x1169bb,-0x18(%ebp)

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
  1006f3:	e8 6e 62 00 00       	call   106966 <strfind>
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
  100882:	c7 04 24 36 6d 10 00 	movl   $0x106d36,(%esp)
  100889:	e8 ba fa ff ff       	call   100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088e:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100895:	00 
  100896:	c7 04 24 4f 6d 10 00 	movl   $0x106d4f,(%esp)
  10089d:	e8 a6 fa ff ff       	call   100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008a2:	c7 44 24 04 7b 6c 10 	movl   $0x106c7b,0x4(%esp)
  1008a9:	00 
  1008aa:	c7 04 24 67 6d 10 00 	movl   $0x106d67,(%esp)
  1008b1:	e8 92 fa ff ff       	call   100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b6:	c7 44 24 04 36 9a 11 	movl   $0x119a36,0x4(%esp)
  1008bd:	00 
  1008be:	c7 04 24 7f 6d 10 00 	movl   $0x106d7f,(%esp)
  1008c5:	e8 7e fa ff ff       	call   100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008ca:	c7 44 24 04 bc d0 11 	movl   $0x11d0bc,0x4(%esp)
  1008d1:	00 
  1008d2:	c7 04 24 97 6d 10 00 	movl   $0x106d97,(%esp)
  1008d9:	e8 6a fa ff ff       	call   100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008de:	b8 bc d0 11 00       	mov    $0x11d0bc,%eax
  1008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008e9:	b8 36 00 10 00       	mov    $0x100036,%eax
  1008ee:	29 c2                	sub    %eax,%edx
  1008f0:	89 d0                	mov    %edx,%eax
  1008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f8:	85 c0                	test   %eax,%eax
  1008fa:	0f 48 c2             	cmovs  %edx,%eax
  1008fd:	c1 f8 0a             	sar    $0xa,%eax
  100900:	89 44 24 04          	mov    %eax,0x4(%esp)
  100904:	c7 04 24 b0 6d 10 00 	movl   $0x106db0,(%esp)
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
  100938:	c7 04 24 da 6d 10 00 	movl   $0x106dda,(%esp)
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
  1009a7:	c7 04 24 f6 6d 10 00 	movl   $0x106df6,(%esp)
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
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
}
  1009c9:	5d                   	pop    %ebp
  1009ca:	c3                   	ret    

001009cb <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  1009cb:	55                   	push   %ebp
  1009cc:	89 e5                	mov    %esp,%ebp
  1009ce:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  1009d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  1009d8:	eb 0c                	jmp    1009e6 <parse+0x1b>
            *buf ++ = '\0';
  1009da:	8b 45 08             	mov    0x8(%ebp),%eax
  1009dd:	8d 50 01             	lea    0x1(%eax),%edx
  1009e0:	89 55 08             	mov    %edx,0x8(%ebp)
  1009e3:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  1009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1009e9:	0f b6 00             	movzbl (%eax),%eax
  1009ec:	84 c0                	test   %al,%al
  1009ee:	74 1d                	je     100a0d <parse+0x42>
  1009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1009f3:	0f b6 00             	movzbl (%eax),%eax
  1009f6:	0f be c0             	movsbl %al,%eax
  1009f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009fd:	c7 04 24 88 6e 10 00 	movl   $0x106e88,(%esp)
  100a04:	e8 2a 5f 00 00       	call   106933 <strchr>
  100a09:	85 c0                	test   %eax,%eax
  100a0b:	75 cd                	jne    1009da <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  100a10:	0f b6 00             	movzbl (%eax),%eax
  100a13:	84 c0                	test   %al,%al
  100a15:	75 02                	jne    100a19 <parse+0x4e>
            break;
  100a17:	eb 67                	jmp    100a80 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100a19:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100a1d:	75 14                	jne    100a33 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100a1f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100a26:	00 
  100a27:	c7 04 24 8d 6e 10 00 	movl   $0x106e8d,(%esp)
  100a2e:	e8 15 f9 ff ff       	call   100348 <cprintf>
        }
        argv[argc ++] = buf;
  100a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a36:	8d 50 01             	lea    0x1(%eax),%edx
  100a39:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100a3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  100a46:	01 c2                	add    %eax,%edx
  100a48:	8b 45 08             	mov    0x8(%ebp),%eax
  100a4b:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100a4d:	eb 04                	jmp    100a53 <parse+0x88>
            buf ++;
  100a4f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100a53:	8b 45 08             	mov    0x8(%ebp),%eax
  100a56:	0f b6 00             	movzbl (%eax),%eax
  100a59:	84 c0                	test   %al,%al
  100a5b:	74 1d                	je     100a7a <parse+0xaf>
  100a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  100a60:	0f b6 00             	movzbl (%eax),%eax
  100a63:	0f be c0             	movsbl %al,%eax
  100a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a6a:	c7 04 24 88 6e 10 00 	movl   $0x106e88,(%esp)
  100a71:	e8 bd 5e 00 00       	call   106933 <strchr>
  100a76:	85 c0                	test   %eax,%eax
  100a78:	74 d5                	je     100a4f <parse+0x84>
            buf ++;
        }
    }
  100a7a:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a7b:	e9 66 ff ff ff       	jmp    1009e6 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100a83:	c9                   	leave  
  100a84:	c3                   	ret    

00100a85 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100a85:	55                   	push   %ebp
  100a86:	89 e5                	mov    %esp,%ebp
  100a88:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100a8b:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a92:	8b 45 08             	mov    0x8(%ebp),%eax
  100a95:	89 04 24             	mov    %eax,(%esp)
  100a98:	e8 2e ff ff ff       	call   1009cb <parse>
  100a9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100aa0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100aa4:	75 0a                	jne    100ab0 <runcmd+0x2b>
        return 0;
  100aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  100aab:	e9 85 00 00 00       	jmp    100b35 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100ab0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100ab7:	eb 5c                	jmp    100b15 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100ab9:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100abc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100abf:	89 d0                	mov    %edx,%eax
  100ac1:	01 c0                	add    %eax,%eax
  100ac3:	01 d0                	add    %edx,%eax
  100ac5:	c1 e0 02             	shl    $0x2,%eax
  100ac8:	05 00 90 11 00       	add    $0x119000,%eax
  100acd:	8b 00                	mov    (%eax),%eax
  100acf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100ad3:	89 04 24             	mov    %eax,(%esp)
  100ad6:	e8 b9 5d 00 00       	call   106894 <strcmp>
  100adb:	85 c0                	test   %eax,%eax
  100add:	75 32                	jne    100b11 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100adf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ae2:	89 d0                	mov    %edx,%eax
  100ae4:	01 c0                	add    %eax,%eax
  100ae6:	01 d0                	add    %edx,%eax
  100ae8:	c1 e0 02             	shl    $0x2,%eax
  100aeb:	05 00 90 11 00       	add    $0x119000,%eax
  100af0:	8b 40 08             	mov    0x8(%eax),%eax
  100af3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100af6:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100af9:	8b 55 0c             	mov    0xc(%ebp),%edx
  100afc:	89 54 24 08          	mov    %edx,0x8(%esp)
  100b00:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100b03:	83 c2 04             	add    $0x4,%edx
  100b06:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b0a:	89 0c 24             	mov    %ecx,(%esp)
  100b0d:	ff d0                	call   *%eax
  100b0f:	eb 24                	jmp    100b35 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b11:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b18:	83 f8 02             	cmp    $0x2,%eax
  100b1b:	76 9c                	jbe    100ab9 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100b1d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b24:	c7 04 24 ab 6e 10 00 	movl   $0x106eab,(%esp)
  100b2b:	e8 18 f8 ff ff       	call   100348 <cprintf>
    return 0;
  100b30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100b35:	c9                   	leave  
  100b36:	c3                   	ret    

00100b37 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100b37:	55                   	push   %ebp
  100b38:	89 e5                	mov    %esp,%ebp
  100b3a:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100b3d:	c7 04 24 c4 6e 10 00 	movl   $0x106ec4,(%esp)
  100b44:	e8 ff f7 ff ff       	call   100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100b49:	c7 04 24 ec 6e 10 00 	movl   $0x106eec,(%esp)
  100b50:	e8 f3 f7 ff ff       	call   100348 <cprintf>

    if (tf != NULL) {
  100b55:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100b59:	74 0b                	je     100b66 <kmonitor+0x2f>
        print_trapframe(tf);
  100b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5e:	89 04 24             	mov    %eax,(%esp)
  100b61:	e8 d5 0c 00 00       	call   10183b <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100b66:	c7 04 24 11 6f 10 00 	movl   $0x106f11,(%esp)
  100b6d:	e8 cd f6 ff ff       	call   10023f <readline>
  100b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100b75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b79:	74 18                	je     100b93 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b85:	89 04 24             	mov    %eax,(%esp)
  100b88:	e8 f8 fe ff ff       	call   100a85 <runcmd>
  100b8d:	85 c0                	test   %eax,%eax
  100b8f:	79 02                	jns    100b93 <kmonitor+0x5c>
                break;
  100b91:	eb 02                	jmp    100b95 <kmonitor+0x5e>
            }
        }
    }
  100b93:	eb d1                	jmp    100b66 <kmonitor+0x2f>
}
  100b95:	c9                   	leave  
  100b96:	c3                   	ret    

00100b97 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100b97:	55                   	push   %ebp
  100b98:	89 e5                	mov    %esp,%ebp
  100b9a:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100ba4:	eb 3f                	jmp    100be5 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ba9:	89 d0                	mov    %edx,%eax
  100bab:	01 c0                	add    %eax,%eax
  100bad:	01 d0                	add    %edx,%eax
  100baf:	c1 e0 02             	shl    $0x2,%eax
  100bb2:	05 00 90 11 00       	add    $0x119000,%eax
  100bb7:	8b 48 04             	mov    0x4(%eax),%ecx
  100bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100bbd:	89 d0                	mov    %edx,%eax
  100bbf:	01 c0                	add    %eax,%eax
  100bc1:	01 d0                	add    %edx,%eax
  100bc3:	c1 e0 02             	shl    $0x2,%eax
  100bc6:	05 00 90 11 00       	add    $0x119000,%eax
  100bcb:	8b 00                	mov    (%eax),%eax
  100bcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bd5:	c7 04 24 15 6f 10 00 	movl   $0x106f15,(%esp)
  100bdc:	e8 67 f7 ff ff       	call   100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100be1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100be8:	83 f8 02             	cmp    $0x2,%eax
  100beb:	76 b9                	jbe    100ba6 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bf2:	c9                   	leave  
  100bf3:	c3                   	ret    

00100bf4 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100bf4:	55                   	push   %ebp
  100bf5:	89 e5                	mov    %esp,%ebp
  100bf7:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100bfa:	e8 7d fc ff ff       	call   10087c <print_kerninfo>
    return 0;
  100bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c04:	c9                   	leave  
  100c05:	c3                   	ret    

00100c06 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100c06:	55                   	push   %ebp
  100c07:	89 e5                	mov    %esp,%ebp
  100c09:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100c0c:	e8 b5 fd ff ff       	call   1009c6 <print_stackframe>
    return 0;
  100c11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c16:	c9                   	leave  
  100c17:	c3                   	ret    

00100c18 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100c18:	55                   	push   %ebp
  100c19:	89 e5                	mov    %esp,%ebp
  100c1b:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100c1e:	a1 20 c4 11 00       	mov    0x11c420,%eax
  100c23:	85 c0                	test   %eax,%eax
  100c25:	74 02                	je     100c29 <__panic+0x11>
        goto panic_dead;
  100c27:	eb 59                	jmp    100c82 <__panic+0x6a>
    }
    is_panic = 1;
  100c29:	c7 05 20 c4 11 00 01 	movl   $0x1,0x11c420
  100c30:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100c33:	8d 45 14             	lea    0x14(%ebp),%eax
  100c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100c39:	8b 45 0c             	mov    0xc(%ebp),%eax
  100c3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100c40:	8b 45 08             	mov    0x8(%ebp),%eax
  100c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c47:	c7 04 24 1e 6f 10 00 	movl   $0x106f1e,(%esp)
  100c4e:	e8 f5 f6 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c5a:	8b 45 10             	mov    0x10(%ebp),%eax
  100c5d:	89 04 24             	mov    %eax,(%esp)
  100c60:	e8 b0 f6 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100c65:	c7 04 24 3a 6f 10 00 	movl   $0x106f3a,(%esp)
  100c6c:	e8 d7 f6 ff ff       	call   100348 <cprintf>
    
    cprintf("stack trackback:\n");
  100c71:	c7 04 24 3c 6f 10 00 	movl   $0x106f3c,(%esp)
  100c78:	e8 cb f6 ff ff       	call   100348 <cprintf>
    print_stackframe();
  100c7d:	e8 44 fd ff ff       	call   1009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100c82:	e8 85 09 00 00       	call   10160c <intr_disable>
    while (1) {
        kmonitor(NULL);
  100c87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100c8e:	e8 a4 fe ff ff       	call   100b37 <kmonitor>
    }
  100c93:	eb f2                	jmp    100c87 <__panic+0x6f>

00100c95 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100c95:	55                   	push   %ebp
  100c96:	89 e5                	mov    %esp,%ebp
  100c98:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100c9b:	8d 45 14             	lea    0x14(%ebp),%eax
  100c9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
  100ca4:	89 44 24 08          	mov    %eax,0x8(%esp)
  100ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  100cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  100caf:	c7 04 24 4e 6f 10 00 	movl   $0x106f4e,(%esp)
  100cb6:	e8 8d f6 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  100cc5:	89 04 24             	mov    %eax,(%esp)
  100cc8:	e8 48 f6 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100ccd:	c7 04 24 3a 6f 10 00 	movl   $0x106f3a,(%esp)
  100cd4:	e8 6f f6 ff ff       	call   100348 <cprintf>
    va_end(ap);
}
  100cd9:	c9                   	leave  
  100cda:	c3                   	ret    

00100cdb <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100cdb:	55                   	push   %ebp
  100cdc:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100cde:	a1 20 c4 11 00       	mov    0x11c420,%eax
}
  100ce3:	5d                   	pop    %ebp
  100ce4:	c3                   	ret    

00100ce5 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100ce5:	55                   	push   %ebp
  100ce6:	89 e5                	mov    %esp,%ebp
  100ce8:	83 ec 28             	sub    $0x28,%esp
  100ceb:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100cf1:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100cf5:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100cf9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100cfd:	ee                   	out    %al,(%dx)
  100cfe:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d04:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100d08:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100d0c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100d10:	ee                   	out    %al,(%dx)
  100d11:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100d17:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100d1b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100d1f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100d23:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100d24:	c7 05 ac cf 11 00 00 	movl   $0x0,0x11cfac
  100d2b:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100d2e:	c7 04 24 6c 6f 10 00 	movl   $0x106f6c,(%esp)
  100d35:	e8 0e f6 ff ff       	call   100348 <cprintf>
    pic_enable(IRQ_TIMER);
  100d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d41:	e8 24 09 00 00       	call   10166a <pic_enable>
}
  100d46:	c9                   	leave  
  100d47:	c3                   	ret    

00100d48 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100d48:	55                   	push   %ebp
  100d49:	89 e5                	mov    %esp,%ebp
  100d4b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100d4e:	9c                   	pushf  
  100d4f:	58                   	pop    %eax
  100d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100d56:	25 00 02 00 00       	and    $0x200,%eax
  100d5b:	85 c0                	test   %eax,%eax
  100d5d:	74 0c                	je     100d6b <__intr_save+0x23>
        intr_disable();
  100d5f:	e8 a8 08 00 00       	call   10160c <intr_disable>
        return 1;
  100d64:	b8 01 00 00 00       	mov    $0x1,%eax
  100d69:	eb 05                	jmp    100d70 <__intr_save+0x28>
    }
    return 0;
  100d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d70:	c9                   	leave  
  100d71:	c3                   	ret    

00100d72 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100d72:	55                   	push   %ebp
  100d73:	89 e5                	mov    %esp,%ebp
  100d75:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100d78:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100d7c:	74 05                	je     100d83 <__intr_restore+0x11>
        intr_enable();
  100d7e:	e8 83 08 00 00       	call   101606 <intr_enable>
    }
}
  100d83:	c9                   	leave  
  100d84:	c3                   	ret    

00100d85 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100d85:	55                   	push   %ebp
  100d86:	89 e5                	mov    %esp,%ebp
  100d88:	83 ec 10             	sub    $0x10,%esp
  100d8b:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100d91:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100d95:	89 c2                	mov    %eax,%edx
  100d97:	ec                   	in     (%dx),%al
  100d98:	88 45 fd             	mov    %al,-0x3(%ebp)
  100d9b:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100da1:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100da5:	89 c2                	mov    %eax,%edx
  100da7:	ec                   	in     (%dx),%al
  100da8:	88 45 f9             	mov    %al,-0x7(%ebp)
  100dab:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100db1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100db5:	89 c2                	mov    %eax,%edx
  100db7:	ec                   	in     (%dx),%al
  100db8:	88 45 f5             	mov    %al,-0xb(%ebp)
  100dbb:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100dc1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100dc5:	89 c2                	mov    %eax,%edx
  100dc7:	ec                   	in     (%dx),%al
  100dc8:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100dcb:	c9                   	leave  
  100dcc:	c3                   	ret    

00100dcd <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100dcd:	55                   	push   %ebp
  100dce:	89 e5                	mov    %esp,%ebp
  100dd0:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100dd3:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100dda:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ddd:	0f b7 00             	movzwl (%eax),%eax
  100de0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100de4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100de7:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100def:	0f b7 00             	movzwl (%eax),%eax
  100df2:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100df6:	74 12                	je     100e0a <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100df8:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100dff:	66 c7 05 46 c4 11 00 	movw   $0x3b4,0x11c446
  100e06:	b4 03 
  100e08:	eb 13                	jmp    100e1d <cga_init+0x50>
    } else {
        *cp = was;
  100e0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e0d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e11:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100e14:	66 c7 05 46 c4 11 00 	movw   $0x3d4,0x11c446
  100e1b:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100e1d:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100e24:	0f b7 c0             	movzwl %ax,%eax
  100e27:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100e2b:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e2f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e33:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e37:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100e38:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100e3f:	83 c0 01             	add    $0x1,%eax
  100e42:	0f b7 c0             	movzwl %ax,%eax
  100e45:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e49:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100e4d:	89 c2                	mov    %eax,%edx
  100e4f:	ec                   	in     (%dx),%al
  100e50:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100e53:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100e57:	0f b6 c0             	movzbl %al,%eax
  100e5a:	c1 e0 08             	shl    $0x8,%eax
  100e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100e60:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100e67:	0f b7 c0             	movzwl %ax,%eax
  100e6a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100e6e:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e72:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100e76:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100e7a:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100e7b:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100e82:	83 c0 01             	add    $0x1,%eax
  100e85:	0f b7 c0             	movzwl %ax,%eax
  100e88:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e8c:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100e90:	89 c2                	mov    %eax,%edx
  100e92:	ec                   	in     (%dx),%al
  100e93:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100e96:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100e9a:	0f b6 c0             	movzbl %al,%eax
  100e9d:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100ea0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea3:	a3 40 c4 11 00       	mov    %eax,0x11c440
    crt_pos = pos;
  100ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100eab:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
}
  100eb1:	c9                   	leave  
  100eb2:	c3                   	ret    

00100eb3 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100eb3:	55                   	push   %ebp
  100eb4:	89 e5                	mov    %esp,%ebp
  100eb6:	83 ec 48             	sub    $0x48,%esp
  100eb9:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100ebf:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ec3:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100ec7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100ecb:	ee                   	out    %al,(%dx)
  100ecc:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100ed2:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100ed6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100eda:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100ede:	ee                   	out    %al,(%dx)
  100edf:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100ee5:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100ee9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100eed:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100ef1:	ee                   	out    %al,(%dx)
  100ef2:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100ef8:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100efc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f00:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f04:	ee                   	out    %al,(%dx)
  100f05:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100f0b:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100f0f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f13:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f17:	ee                   	out    %al,(%dx)
  100f18:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100f1e:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100f22:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f26:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f2a:	ee                   	out    %al,(%dx)
  100f2b:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f31:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100f35:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f39:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f3d:	ee                   	out    %al,(%dx)
  100f3e:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f44:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  100f48:	89 c2                	mov    %eax,%edx
  100f4a:	ec                   	in     (%dx),%al
  100f4b:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  100f4e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100f52:	3c ff                	cmp    $0xff,%al
  100f54:	0f 95 c0             	setne  %al
  100f57:	0f b6 c0             	movzbl %al,%eax
  100f5a:	a3 48 c4 11 00       	mov    %eax,0x11c448
  100f5f:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f65:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  100f69:	89 c2                	mov    %eax,%edx
  100f6b:	ec                   	in     (%dx),%al
  100f6c:	88 45 d5             	mov    %al,-0x2b(%ebp)
  100f6f:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  100f75:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  100f79:	89 c2                	mov    %eax,%edx
  100f7b:	ec                   	in     (%dx),%al
  100f7c:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100f7f:	a1 48 c4 11 00       	mov    0x11c448,%eax
  100f84:	85 c0                	test   %eax,%eax
  100f86:	74 0c                	je     100f94 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  100f88:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100f8f:	e8 d6 06 00 00       	call   10166a <pic_enable>
    }
}
  100f94:	c9                   	leave  
  100f95:	c3                   	ret    

00100f96 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100f96:	55                   	push   %ebp
  100f97:	89 e5                	mov    %esp,%ebp
  100f99:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100f9c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100fa3:	eb 09                	jmp    100fae <lpt_putc_sub+0x18>
        delay();
  100fa5:	e8 db fd ff ff       	call   100d85 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100faa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  100fae:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  100fb4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100fb8:	89 c2                	mov    %eax,%edx
  100fba:	ec                   	in     (%dx),%al
  100fbb:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  100fbe:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  100fc2:	84 c0                	test   %al,%al
  100fc4:	78 09                	js     100fcf <lpt_putc_sub+0x39>
  100fc6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  100fcd:	7e d6                	jle    100fa5 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  100fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  100fd2:	0f b6 c0             	movzbl %al,%eax
  100fd5:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  100fdb:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fde:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100fe2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100fe6:	ee                   	out    %al,(%dx)
  100fe7:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  100fed:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  100ff1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100ff5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100ff9:	ee                   	out    %al,(%dx)
  100ffa:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  101000:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  101004:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101008:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10100c:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  10100d:	c9                   	leave  
  10100e:	c3                   	ret    

0010100f <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  10100f:	55                   	push   %ebp
  101010:	89 e5                	mov    %esp,%ebp
  101012:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101015:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101019:	74 0d                	je     101028 <lpt_putc+0x19>
        lpt_putc_sub(c);
  10101b:	8b 45 08             	mov    0x8(%ebp),%eax
  10101e:	89 04 24             	mov    %eax,(%esp)
  101021:	e8 70 ff ff ff       	call   100f96 <lpt_putc_sub>
  101026:	eb 24                	jmp    10104c <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  101028:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10102f:	e8 62 ff ff ff       	call   100f96 <lpt_putc_sub>
        lpt_putc_sub(' ');
  101034:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10103b:	e8 56 ff ff ff       	call   100f96 <lpt_putc_sub>
        lpt_putc_sub('\b');
  101040:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101047:	e8 4a ff ff ff       	call   100f96 <lpt_putc_sub>
    }
}
  10104c:	c9                   	leave  
  10104d:	c3                   	ret    

0010104e <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  10104e:	55                   	push   %ebp
  10104f:	89 e5                	mov    %esp,%ebp
  101051:	53                   	push   %ebx
  101052:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101055:	8b 45 08             	mov    0x8(%ebp),%eax
  101058:	b0 00                	mov    $0x0,%al
  10105a:	85 c0                	test   %eax,%eax
  10105c:	75 07                	jne    101065 <cga_putc+0x17>
        c |= 0x0700;
  10105e:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101065:	8b 45 08             	mov    0x8(%ebp),%eax
  101068:	0f b6 c0             	movzbl %al,%eax
  10106b:	83 f8 0a             	cmp    $0xa,%eax
  10106e:	74 4c                	je     1010bc <cga_putc+0x6e>
  101070:	83 f8 0d             	cmp    $0xd,%eax
  101073:	74 57                	je     1010cc <cga_putc+0x7e>
  101075:	83 f8 08             	cmp    $0x8,%eax
  101078:	0f 85 88 00 00 00    	jne    101106 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  10107e:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101085:	66 85 c0             	test   %ax,%ax
  101088:	74 30                	je     1010ba <cga_putc+0x6c>
            crt_pos --;
  10108a:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101091:	83 e8 01             	sub    $0x1,%eax
  101094:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  10109a:	a1 40 c4 11 00       	mov    0x11c440,%eax
  10109f:	0f b7 15 44 c4 11 00 	movzwl 0x11c444,%edx
  1010a6:	0f b7 d2             	movzwl %dx,%edx
  1010a9:	01 d2                	add    %edx,%edx
  1010ab:	01 c2                	add    %eax,%edx
  1010ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b0:	b0 00                	mov    $0x0,%al
  1010b2:	83 c8 20             	or     $0x20,%eax
  1010b5:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1010b8:	eb 72                	jmp    10112c <cga_putc+0xde>
  1010ba:	eb 70                	jmp    10112c <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  1010bc:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1010c3:	83 c0 50             	add    $0x50,%eax
  1010c6:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1010cc:	0f b7 1d 44 c4 11 00 	movzwl 0x11c444,%ebx
  1010d3:	0f b7 0d 44 c4 11 00 	movzwl 0x11c444,%ecx
  1010da:	0f b7 c1             	movzwl %cx,%eax
  1010dd:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  1010e3:	c1 e8 10             	shr    $0x10,%eax
  1010e6:	89 c2                	mov    %eax,%edx
  1010e8:	66 c1 ea 06          	shr    $0x6,%dx
  1010ec:	89 d0                	mov    %edx,%eax
  1010ee:	c1 e0 02             	shl    $0x2,%eax
  1010f1:	01 d0                	add    %edx,%eax
  1010f3:	c1 e0 04             	shl    $0x4,%eax
  1010f6:	29 c1                	sub    %eax,%ecx
  1010f8:	89 ca                	mov    %ecx,%edx
  1010fa:	89 d8                	mov    %ebx,%eax
  1010fc:	29 d0                	sub    %edx,%eax
  1010fe:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
        break;
  101104:	eb 26                	jmp    10112c <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101106:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  10110c:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101113:	8d 50 01             	lea    0x1(%eax),%edx
  101116:	66 89 15 44 c4 11 00 	mov    %dx,0x11c444
  10111d:	0f b7 c0             	movzwl %ax,%eax
  101120:	01 c0                	add    %eax,%eax
  101122:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101125:	8b 45 08             	mov    0x8(%ebp),%eax
  101128:	66 89 02             	mov    %ax,(%edx)
        break;
  10112b:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  10112c:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101133:	66 3d cf 07          	cmp    $0x7cf,%ax
  101137:	76 5b                	jbe    101194 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101139:	a1 40 c4 11 00       	mov    0x11c440,%eax
  10113e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101144:	a1 40 c4 11 00       	mov    0x11c440,%eax
  101149:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101150:	00 
  101151:	89 54 24 04          	mov    %edx,0x4(%esp)
  101155:	89 04 24             	mov    %eax,(%esp)
  101158:	e8 d4 59 00 00       	call   106b31 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10115d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101164:	eb 15                	jmp    10117b <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  101166:	a1 40 c4 11 00       	mov    0x11c440,%eax
  10116b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10116e:	01 d2                	add    %edx,%edx
  101170:	01 d0                	add    %edx,%eax
  101172:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101177:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10117b:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101182:	7e e2                	jle    101166 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  101184:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10118b:	83 e8 50             	sub    $0x50,%eax
  10118e:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101194:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  10119b:	0f b7 c0             	movzwl %ax,%eax
  10119e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  1011a2:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  1011a6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1011aa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1011ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  1011af:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011b6:	66 c1 e8 08          	shr    $0x8,%ax
  1011ba:	0f b6 c0             	movzbl %al,%eax
  1011bd:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  1011c4:	83 c2 01             	add    $0x1,%edx
  1011c7:	0f b7 d2             	movzwl %dx,%edx
  1011ca:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  1011ce:	88 45 ed             	mov    %al,-0x13(%ebp)
  1011d1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1011d5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1011d9:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  1011da:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  1011e1:	0f b7 c0             	movzwl %ax,%eax
  1011e4:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  1011e8:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  1011ec:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1011f0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1011f4:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1011f5:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011fc:	0f b6 c0             	movzbl %al,%eax
  1011ff:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  101206:	83 c2 01             	add    $0x1,%edx
  101209:	0f b7 d2             	movzwl %dx,%edx
  10120c:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  101210:	88 45 e5             	mov    %al,-0x1b(%ebp)
  101213:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101217:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10121b:	ee                   	out    %al,(%dx)
}
  10121c:	83 c4 34             	add    $0x34,%esp
  10121f:	5b                   	pop    %ebx
  101220:	5d                   	pop    %ebp
  101221:	c3                   	ret    

00101222 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101222:	55                   	push   %ebp
  101223:	89 e5                	mov    %esp,%ebp
  101225:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101228:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10122f:	eb 09                	jmp    10123a <serial_putc_sub+0x18>
        delay();
  101231:	e8 4f fb ff ff       	call   100d85 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101236:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10123a:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101240:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101244:	89 c2                	mov    %eax,%edx
  101246:	ec                   	in     (%dx),%al
  101247:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10124a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10124e:	0f b6 c0             	movzbl %al,%eax
  101251:	83 e0 20             	and    $0x20,%eax
  101254:	85 c0                	test   %eax,%eax
  101256:	75 09                	jne    101261 <serial_putc_sub+0x3f>
  101258:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10125f:	7e d0                	jle    101231 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  101261:	8b 45 08             	mov    0x8(%ebp),%eax
  101264:	0f b6 c0             	movzbl %al,%eax
  101267:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10126d:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101270:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101274:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101278:	ee                   	out    %al,(%dx)
}
  101279:	c9                   	leave  
  10127a:	c3                   	ret    

0010127b <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10127b:	55                   	push   %ebp
  10127c:	89 e5                	mov    %esp,%ebp
  10127e:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101281:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101285:	74 0d                	je     101294 <serial_putc+0x19>
        serial_putc_sub(c);
  101287:	8b 45 08             	mov    0x8(%ebp),%eax
  10128a:	89 04 24             	mov    %eax,(%esp)
  10128d:	e8 90 ff ff ff       	call   101222 <serial_putc_sub>
  101292:	eb 24                	jmp    1012b8 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  101294:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10129b:	e8 82 ff ff ff       	call   101222 <serial_putc_sub>
        serial_putc_sub(' ');
  1012a0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1012a7:	e8 76 ff ff ff       	call   101222 <serial_putc_sub>
        serial_putc_sub('\b');
  1012ac:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012b3:	e8 6a ff ff ff       	call   101222 <serial_putc_sub>
    }
}
  1012b8:	c9                   	leave  
  1012b9:	c3                   	ret    

001012ba <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1012ba:	55                   	push   %ebp
  1012bb:	89 e5                	mov    %esp,%ebp
  1012bd:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1012c0:	eb 33                	jmp    1012f5 <cons_intr+0x3b>
        if (c != 0) {
  1012c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1012c6:	74 2d                	je     1012f5 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1012c8:	a1 64 c6 11 00       	mov    0x11c664,%eax
  1012cd:	8d 50 01             	lea    0x1(%eax),%edx
  1012d0:	89 15 64 c6 11 00    	mov    %edx,0x11c664
  1012d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1012d9:	88 90 60 c4 11 00    	mov    %dl,0x11c460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1012df:	a1 64 c6 11 00       	mov    0x11c664,%eax
  1012e4:	3d 00 02 00 00       	cmp    $0x200,%eax
  1012e9:	75 0a                	jne    1012f5 <cons_intr+0x3b>
                cons.wpos = 0;
  1012eb:	c7 05 64 c6 11 00 00 	movl   $0x0,0x11c664
  1012f2:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1012f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1012f8:	ff d0                	call   *%eax
  1012fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1012fd:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101301:	75 bf                	jne    1012c2 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  101303:	c9                   	leave  
  101304:	c3                   	ret    

00101305 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101305:	55                   	push   %ebp
  101306:	89 e5                	mov    %esp,%ebp
  101308:	83 ec 10             	sub    $0x10,%esp
  10130b:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101311:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101315:	89 c2                	mov    %eax,%edx
  101317:	ec                   	in     (%dx),%al
  101318:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10131b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  10131f:	0f b6 c0             	movzbl %al,%eax
  101322:	83 e0 01             	and    $0x1,%eax
  101325:	85 c0                	test   %eax,%eax
  101327:	75 07                	jne    101330 <serial_proc_data+0x2b>
        return -1;
  101329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10132e:	eb 2a                	jmp    10135a <serial_proc_data+0x55>
  101330:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101336:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10133a:	89 c2                	mov    %eax,%edx
  10133c:	ec                   	in     (%dx),%al
  10133d:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101340:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101344:	0f b6 c0             	movzbl %al,%eax
  101347:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10134a:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10134e:	75 07                	jne    101357 <serial_proc_data+0x52>
        c = '\b';
  101350:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101357:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10135a:	c9                   	leave  
  10135b:	c3                   	ret    

0010135c <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10135c:	55                   	push   %ebp
  10135d:	89 e5                	mov    %esp,%ebp
  10135f:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101362:	a1 48 c4 11 00       	mov    0x11c448,%eax
  101367:	85 c0                	test   %eax,%eax
  101369:	74 0c                	je     101377 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  10136b:	c7 04 24 05 13 10 00 	movl   $0x101305,(%esp)
  101372:	e8 43 ff ff ff       	call   1012ba <cons_intr>
    }
}
  101377:	c9                   	leave  
  101378:	c3                   	ret    

00101379 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101379:	55                   	push   %ebp
  10137a:	89 e5                	mov    %esp,%ebp
  10137c:	83 ec 38             	sub    $0x38,%esp
  10137f:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101385:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101389:	89 c2                	mov    %eax,%edx
  10138b:	ec                   	in     (%dx),%al
  10138c:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  10138f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101393:	0f b6 c0             	movzbl %al,%eax
  101396:	83 e0 01             	and    $0x1,%eax
  101399:	85 c0                	test   %eax,%eax
  10139b:	75 0a                	jne    1013a7 <kbd_proc_data+0x2e>
        return -1;
  10139d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013a2:	e9 59 01 00 00       	jmp    101500 <kbd_proc_data+0x187>
  1013a7:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013ad:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1013b1:	89 c2                	mov    %eax,%edx
  1013b3:	ec                   	in     (%dx),%al
  1013b4:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1013b7:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1013bb:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1013be:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1013c2:	75 17                	jne    1013db <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  1013c4:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1013c9:	83 c8 40             	or     $0x40,%eax
  1013cc:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  1013d1:	b8 00 00 00 00       	mov    $0x0,%eax
  1013d6:	e9 25 01 00 00       	jmp    101500 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  1013db:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1013df:	84 c0                	test   %al,%al
  1013e1:	79 47                	jns    10142a <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1013e3:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1013e8:	83 e0 40             	and    $0x40,%eax
  1013eb:	85 c0                	test   %eax,%eax
  1013ed:	75 09                	jne    1013f8 <kbd_proc_data+0x7f>
  1013ef:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1013f3:	83 e0 7f             	and    $0x7f,%eax
  1013f6:	eb 04                	jmp    1013fc <kbd_proc_data+0x83>
  1013f8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1013fc:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1013ff:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101403:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  10140a:	83 c8 40             	or     $0x40,%eax
  10140d:	0f b6 c0             	movzbl %al,%eax
  101410:	f7 d0                	not    %eax
  101412:	89 c2                	mov    %eax,%edx
  101414:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101419:	21 d0                	and    %edx,%eax
  10141b:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  101420:	b8 00 00 00 00       	mov    $0x0,%eax
  101425:	e9 d6 00 00 00       	jmp    101500 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  10142a:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10142f:	83 e0 40             	and    $0x40,%eax
  101432:	85 c0                	test   %eax,%eax
  101434:	74 11                	je     101447 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101436:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10143a:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10143f:	83 e0 bf             	and    $0xffffffbf,%eax
  101442:	a3 68 c6 11 00       	mov    %eax,0x11c668
    }

    shift |= shiftcode[data];
  101447:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10144b:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  101452:	0f b6 d0             	movzbl %al,%edx
  101455:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10145a:	09 d0                	or     %edx,%eax
  10145c:	a3 68 c6 11 00       	mov    %eax,0x11c668
    shift ^= togglecode[data];
  101461:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101465:	0f b6 80 40 91 11 00 	movzbl 0x119140(%eax),%eax
  10146c:	0f b6 d0             	movzbl %al,%edx
  10146f:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101474:	31 d0                	xor    %edx,%eax
  101476:	a3 68 c6 11 00       	mov    %eax,0x11c668

    c = charcode[shift & (CTL | SHIFT)][data];
  10147b:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101480:	83 e0 03             	and    $0x3,%eax
  101483:	8b 14 85 40 95 11 00 	mov    0x119540(,%eax,4),%edx
  10148a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10148e:	01 d0                	add    %edx,%eax
  101490:	0f b6 00             	movzbl (%eax),%eax
  101493:	0f b6 c0             	movzbl %al,%eax
  101496:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101499:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10149e:	83 e0 08             	and    $0x8,%eax
  1014a1:	85 c0                	test   %eax,%eax
  1014a3:	74 22                	je     1014c7 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  1014a5:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1014a9:	7e 0c                	jle    1014b7 <kbd_proc_data+0x13e>
  1014ab:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1014af:	7f 06                	jg     1014b7 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  1014b1:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1014b5:	eb 10                	jmp    1014c7 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  1014b7:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1014bb:	7e 0a                	jle    1014c7 <kbd_proc_data+0x14e>
  1014bd:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1014c1:	7f 04                	jg     1014c7 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  1014c3:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1014c7:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1014cc:	f7 d0                	not    %eax
  1014ce:	83 e0 06             	and    $0x6,%eax
  1014d1:	85 c0                	test   %eax,%eax
  1014d3:	75 28                	jne    1014fd <kbd_proc_data+0x184>
  1014d5:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1014dc:	75 1f                	jne    1014fd <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  1014de:	c7 04 24 87 6f 10 00 	movl   $0x106f87,(%esp)
  1014e5:	e8 5e ee ff ff       	call   100348 <cprintf>
  1014ea:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1014f0:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1014f4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1014f8:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1014fc:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101500:	c9                   	leave  
  101501:	c3                   	ret    

00101502 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101502:	55                   	push   %ebp
  101503:	89 e5                	mov    %esp,%ebp
  101505:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101508:	c7 04 24 79 13 10 00 	movl   $0x101379,(%esp)
  10150f:	e8 a6 fd ff ff       	call   1012ba <cons_intr>
}
  101514:	c9                   	leave  
  101515:	c3                   	ret    

00101516 <kbd_init>:

static void
kbd_init(void) {
  101516:	55                   	push   %ebp
  101517:	89 e5                	mov    %esp,%ebp
  101519:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  10151c:	e8 e1 ff ff ff       	call   101502 <kbd_intr>
    pic_enable(IRQ_KBD);
  101521:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101528:	e8 3d 01 00 00       	call   10166a <pic_enable>
}
  10152d:	c9                   	leave  
  10152e:	c3                   	ret    

0010152f <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10152f:	55                   	push   %ebp
  101530:	89 e5                	mov    %esp,%ebp
  101532:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101535:	e8 93 f8 ff ff       	call   100dcd <cga_init>
    serial_init();
  10153a:	e8 74 f9 ff ff       	call   100eb3 <serial_init>
    kbd_init();
  10153f:	e8 d2 ff ff ff       	call   101516 <kbd_init>
    if (!serial_exists) {
  101544:	a1 48 c4 11 00       	mov    0x11c448,%eax
  101549:	85 c0                	test   %eax,%eax
  10154b:	75 0c                	jne    101559 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  10154d:	c7 04 24 93 6f 10 00 	movl   $0x106f93,(%esp)
  101554:	e8 ef ed ff ff       	call   100348 <cprintf>
    }
}
  101559:	c9                   	leave  
  10155a:	c3                   	ret    

0010155b <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10155b:	55                   	push   %ebp
  10155c:	89 e5                	mov    %esp,%ebp
  10155e:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101561:	e8 e2 f7 ff ff       	call   100d48 <__intr_save>
  101566:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101569:	8b 45 08             	mov    0x8(%ebp),%eax
  10156c:	89 04 24             	mov    %eax,(%esp)
  10156f:	e8 9b fa ff ff       	call   10100f <lpt_putc>
        cga_putc(c);
  101574:	8b 45 08             	mov    0x8(%ebp),%eax
  101577:	89 04 24             	mov    %eax,(%esp)
  10157a:	e8 cf fa ff ff       	call   10104e <cga_putc>
        serial_putc(c);
  10157f:	8b 45 08             	mov    0x8(%ebp),%eax
  101582:	89 04 24             	mov    %eax,(%esp)
  101585:	e8 f1 fc ff ff       	call   10127b <serial_putc>
    }
    local_intr_restore(intr_flag);
  10158a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10158d:	89 04 24             	mov    %eax,(%esp)
  101590:	e8 dd f7 ff ff       	call   100d72 <__intr_restore>
}
  101595:	c9                   	leave  
  101596:	c3                   	ret    

00101597 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101597:	55                   	push   %ebp
  101598:	89 e5                	mov    %esp,%ebp
  10159a:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  10159d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  1015a4:	e8 9f f7 ff ff       	call   100d48 <__intr_save>
  1015a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  1015ac:	e8 ab fd ff ff       	call   10135c <serial_intr>
        kbd_intr();
  1015b1:	e8 4c ff ff ff       	call   101502 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  1015b6:	8b 15 60 c6 11 00    	mov    0x11c660,%edx
  1015bc:	a1 64 c6 11 00       	mov    0x11c664,%eax
  1015c1:	39 c2                	cmp    %eax,%edx
  1015c3:	74 31                	je     1015f6 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  1015c5:	a1 60 c6 11 00       	mov    0x11c660,%eax
  1015ca:	8d 50 01             	lea    0x1(%eax),%edx
  1015cd:	89 15 60 c6 11 00    	mov    %edx,0x11c660
  1015d3:	0f b6 80 60 c4 11 00 	movzbl 0x11c460(%eax),%eax
  1015da:	0f b6 c0             	movzbl %al,%eax
  1015dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1015e0:	a1 60 c6 11 00       	mov    0x11c660,%eax
  1015e5:	3d 00 02 00 00       	cmp    $0x200,%eax
  1015ea:	75 0a                	jne    1015f6 <cons_getc+0x5f>
                cons.rpos = 0;
  1015ec:	c7 05 60 c6 11 00 00 	movl   $0x0,0x11c660
  1015f3:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1015f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1015f9:	89 04 24             	mov    %eax,(%esp)
  1015fc:	e8 71 f7 ff ff       	call   100d72 <__intr_restore>
    return c;
  101601:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101604:	c9                   	leave  
  101605:	c3                   	ret    

00101606 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101606:	55                   	push   %ebp
  101607:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  101609:	fb                   	sti    
    sti();
}
  10160a:	5d                   	pop    %ebp
  10160b:	c3                   	ret    

0010160c <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10160c:	55                   	push   %ebp
  10160d:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  10160f:	fa                   	cli    
    cli();
}
  101610:	5d                   	pop    %ebp
  101611:	c3                   	ret    

00101612 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101612:	55                   	push   %ebp
  101613:	89 e5                	mov    %esp,%ebp
  101615:	83 ec 14             	sub    $0x14,%esp
  101618:	8b 45 08             	mov    0x8(%ebp),%eax
  10161b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10161f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101623:	66 a3 50 95 11 00    	mov    %ax,0x119550
    if (did_init) {
  101629:	a1 6c c6 11 00       	mov    0x11c66c,%eax
  10162e:	85 c0                	test   %eax,%eax
  101630:	74 36                	je     101668 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101632:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101636:	0f b6 c0             	movzbl %al,%eax
  101639:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10163f:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101642:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101646:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10164a:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10164b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10164f:	66 c1 e8 08          	shr    $0x8,%ax
  101653:	0f b6 c0             	movzbl %al,%eax
  101656:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10165c:	88 45 f9             	mov    %al,-0x7(%ebp)
  10165f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101663:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101667:	ee                   	out    %al,(%dx)
    }
}
  101668:	c9                   	leave  
  101669:	c3                   	ret    

0010166a <pic_enable>:

void
pic_enable(unsigned int irq) {
  10166a:	55                   	push   %ebp
  10166b:	89 e5                	mov    %esp,%ebp
  10166d:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101670:	8b 45 08             	mov    0x8(%ebp),%eax
  101673:	ba 01 00 00 00       	mov    $0x1,%edx
  101678:	89 c1                	mov    %eax,%ecx
  10167a:	d3 e2                	shl    %cl,%edx
  10167c:	89 d0                	mov    %edx,%eax
  10167e:	f7 d0                	not    %eax
  101680:	89 c2                	mov    %eax,%edx
  101682:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  101689:	21 d0                	and    %edx,%eax
  10168b:	0f b7 c0             	movzwl %ax,%eax
  10168e:	89 04 24             	mov    %eax,(%esp)
  101691:	e8 7c ff ff ff       	call   101612 <pic_setmask>
}
  101696:	c9                   	leave  
  101697:	c3                   	ret    

00101698 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101698:	55                   	push   %ebp
  101699:	89 e5                	mov    %esp,%ebp
  10169b:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  10169e:	c7 05 6c c6 11 00 01 	movl   $0x1,0x11c66c
  1016a5:	00 00 00 
  1016a8:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016ae:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  1016b2:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016b6:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016ba:	ee                   	out    %al,(%dx)
  1016bb:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  1016c1:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  1016c5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1016c9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016cd:	ee                   	out    %al,(%dx)
  1016ce:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1016d4:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  1016d8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1016dc:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1016e0:	ee                   	out    %al,(%dx)
  1016e1:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  1016e7:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  1016eb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1016ef:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1016f3:	ee                   	out    %al,(%dx)
  1016f4:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1016fa:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1016fe:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101702:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101706:	ee                   	out    %al,(%dx)
  101707:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  10170d:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  101711:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101715:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101719:	ee                   	out    %al,(%dx)
  10171a:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  101720:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  101724:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101728:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10172c:	ee                   	out    %al,(%dx)
  10172d:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  101733:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  101737:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10173b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10173f:	ee                   	out    %al,(%dx)
  101740:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  101746:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  10174a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10174e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101752:	ee                   	out    %al,(%dx)
  101753:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101759:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  10175d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101761:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101765:	ee                   	out    %al,(%dx)
  101766:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  10176c:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  101770:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101774:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101778:	ee                   	out    %al,(%dx)
  101779:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  10177f:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  101783:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101787:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10178b:	ee                   	out    %al,(%dx)
  10178c:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  101792:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  101796:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  10179a:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  10179e:	ee                   	out    %al,(%dx)
  10179f:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  1017a5:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  1017a9:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017ad:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017b1:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017b2:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  1017b9:	66 83 f8 ff          	cmp    $0xffff,%ax
  1017bd:	74 12                	je     1017d1 <pic_init+0x139>
        pic_setmask(irq_mask);
  1017bf:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  1017c6:	0f b7 c0             	movzwl %ax,%eax
  1017c9:	89 04 24             	mov    %eax,(%esp)
  1017cc:	e8 41 fe ff ff       	call   101612 <pic_setmask>
    }
}
  1017d1:	c9                   	leave  
  1017d2:	c3                   	ret    

001017d3 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1017d3:	55                   	push   %ebp
  1017d4:	89 e5                	mov    %esp,%ebp
  1017d6:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1017d9:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1017e0:	00 
  1017e1:	c7 04 24 c0 6f 10 00 	movl   $0x106fc0,(%esp)
  1017e8:	e8 5b eb ff ff       	call   100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1017ed:	c9                   	leave  
  1017ee:	c3                   	ret    

001017ef <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1017ef:	55                   	push   %ebp
  1017f0:	89 e5                	mov    %esp,%ebp
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
}
  1017f2:	5d                   	pop    %ebp
  1017f3:	c3                   	ret    

001017f4 <trapname>:

static const char *
trapname(int trapno) {
  1017f4:	55                   	push   %ebp
  1017f5:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1017fa:	83 f8 13             	cmp    $0x13,%eax
  1017fd:	77 0c                	ja     10180b <trapname+0x17>
        return excnames[trapno];
  1017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  101802:	8b 04 85 20 73 10 00 	mov    0x107320(,%eax,4),%eax
  101809:	eb 18                	jmp    101823 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  10180b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  10180f:	7e 0d                	jle    10181e <trapname+0x2a>
  101811:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101815:	7f 07                	jg     10181e <trapname+0x2a>
        return "Hardware Interrupt";
  101817:	b8 ca 6f 10 00       	mov    $0x106fca,%eax
  10181c:	eb 05                	jmp    101823 <trapname+0x2f>
    }
    return "(unknown trap)";
  10181e:	b8 dd 6f 10 00       	mov    $0x106fdd,%eax
}
  101823:	5d                   	pop    %ebp
  101824:	c3                   	ret    

00101825 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101825:	55                   	push   %ebp
  101826:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101828:	8b 45 08             	mov    0x8(%ebp),%eax
  10182b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  10182f:	66 83 f8 08          	cmp    $0x8,%ax
  101833:	0f 94 c0             	sete   %al
  101836:	0f b6 c0             	movzbl %al,%eax
}
  101839:	5d                   	pop    %ebp
  10183a:	c3                   	ret    

0010183b <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  10183b:	55                   	push   %ebp
  10183c:	89 e5                	mov    %esp,%ebp
  10183e:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101841:	8b 45 08             	mov    0x8(%ebp),%eax
  101844:	89 44 24 04          	mov    %eax,0x4(%esp)
  101848:	c7 04 24 1e 70 10 00 	movl   $0x10701e,(%esp)
  10184f:	e8 f4 ea ff ff       	call   100348 <cprintf>
    print_regs(&tf->tf_regs);
  101854:	8b 45 08             	mov    0x8(%ebp),%eax
  101857:	89 04 24             	mov    %eax,(%esp)
  10185a:	e8 a1 01 00 00       	call   101a00 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  10185f:	8b 45 08             	mov    0x8(%ebp),%eax
  101862:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101866:	0f b7 c0             	movzwl %ax,%eax
  101869:	89 44 24 04          	mov    %eax,0x4(%esp)
  10186d:	c7 04 24 2f 70 10 00 	movl   $0x10702f,(%esp)
  101874:	e8 cf ea ff ff       	call   100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101879:	8b 45 08             	mov    0x8(%ebp),%eax
  10187c:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101880:	0f b7 c0             	movzwl %ax,%eax
  101883:	89 44 24 04          	mov    %eax,0x4(%esp)
  101887:	c7 04 24 42 70 10 00 	movl   $0x107042,(%esp)
  10188e:	e8 b5 ea ff ff       	call   100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101893:	8b 45 08             	mov    0x8(%ebp),%eax
  101896:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  10189a:	0f b7 c0             	movzwl %ax,%eax
  10189d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1018a1:	c7 04 24 55 70 10 00 	movl   $0x107055,(%esp)
  1018a8:	e8 9b ea ff ff       	call   100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  1018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1018b0:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  1018b4:	0f b7 c0             	movzwl %ax,%eax
  1018b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1018bb:	c7 04 24 68 70 10 00 	movl   $0x107068,(%esp)
  1018c2:	e8 81 ea ff ff       	call   100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  1018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1018ca:	8b 40 30             	mov    0x30(%eax),%eax
  1018cd:	89 04 24             	mov    %eax,(%esp)
  1018d0:	e8 1f ff ff ff       	call   1017f4 <trapname>
  1018d5:	8b 55 08             	mov    0x8(%ebp),%edx
  1018d8:	8b 52 30             	mov    0x30(%edx),%edx
  1018db:	89 44 24 08          	mov    %eax,0x8(%esp)
  1018df:	89 54 24 04          	mov    %edx,0x4(%esp)
  1018e3:	c7 04 24 7b 70 10 00 	movl   $0x10707b,(%esp)
  1018ea:	e8 59 ea ff ff       	call   100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  1018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1018f2:	8b 40 34             	mov    0x34(%eax),%eax
  1018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1018f9:	c7 04 24 8d 70 10 00 	movl   $0x10708d,(%esp)
  101900:	e8 43 ea ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101905:	8b 45 08             	mov    0x8(%ebp),%eax
  101908:	8b 40 38             	mov    0x38(%eax),%eax
  10190b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10190f:	c7 04 24 9c 70 10 00 	movl   $0x10709c,(%esp)
  101916:	e8 2d ea ff ff       	call   100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  10191b:	8b 45 08             	mov    0x8(%ebp),%eax
  10191e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101922:	0f b7 c0             	movzwl %ax,%eax
  101925:	89 44 24 04          	mov    %eax,0x4(%esp)
  101929:	c7 04 24 ab 70 10 00 	movl   $0x1070ab,(%esp)
  101930:	e8 13 ea ff ff       	call   100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101935:	8b 45 08             	mov    0x8(%ebp),%eax
  101938:	8b 40 40             	mov    0x40(%eax),%eax
  10193b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10193f:	c7 04 24 be 70 10 00 	movl   $0x1070be,(%esp)
  101946:	e8 fd e9 ff ff       	call   100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  10194b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101952:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101959:	eb 3e                	jmp    101999 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  10195b:	8b 45 08             	mov    0x8(%ebp),%eax
  10195e:	8b 50 40             	mov    0x40(%eax),%edx
  101961:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101964:	21 d0                	and    %edx,%eax
  101966:	85 c0                	test   %eax,%eax
  101968:	74 28                	je     101992 <print_trapframe+0x157>
  10196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10196d:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101974:	85 c0                	test   %eax,%eax
  101976:	74 1a                	je     101992 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10197b:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101982:	89 44 24 04          	mov    %eax,0x4(%esp)
  101986:	c7 04 24 cd 70 10 00 	movl   $0x1070cd,(%esp)
  10198d:	e8 b6 e9 ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101992:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101996:	d1 65 f0             	shll   -0x10(%ebp)
  101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10199c:	83 f8 17             	cmp    $0x17,%eax
  10199f:	76 ba                	jbe    10195b <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  1019a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1019a4:	8b 40 40             	mov    0x40(%eax),%eax
  1019a7:	25 00 30 00 00       	and    $0x3000,%eax
  1019ac:	c1 e8 0c             	shr    $0xc,%eax
  1019af:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019b3:	c7 04 24 d1 70 10 00 	movl   $0x1070d1,(%esp)
  1019ba:	e8 89 e9 ff ff       	call   100348 <cprintf>

    if (!trap_in_kernel(tf)) {
  1019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c2:	89 04 24             	mov    %eax,(%esp)
  1019c5:	e8 5b fe ff ff       	call   101825 <trap_in_kernel>
  1019ca:	85 c0                	test   %eax,%eax
  1019cc:	75 30                	jne    1019fe <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  1019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1019d1:	8b 40 44             	mov    0x44(%eax),%eax
  1019d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019d8:	c7 04 24 da 70 10 00 	movl   $0x1070da,(%esp)
  1019df:	e8 64 e9 ff ff       	call   100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  1019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1019e7:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  1019eb:	0f b7 c0             	movzwl %ax,%eax
  1019ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019f2:	c7 04 24 e9 70 10 00 	movl   $0x1070e9,(%esp)
  1019f9:	e8 4a e9 ff ff       	call   100348 <cprintf>
    }
}
  1019fe:	c9                   	leave  
  1019ff:	c3                   	ret    

00101a00 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101a00:	55                   	push   %ebp
  101a01:	89 e5                	mov    %esp,%ebp
  101a03:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101a06:	8b 45 08             	mov    0x8(%ebp),%eax
  101a09:	8b 00                	mov    (%eax),%eax
  101a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a0f:	c7 04 24 fc 70 10 00 	movl   $0x1070fc,(%esp)
  101a16:	e8 2d e9 ff ff       	call   100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a1e:	8b 40 04             	mov    0x4(%eax),%eax
  101a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a25:	c7 04 24 0b 71 10 00 	movl   $0x10710b,(%esp)
  101a2c:	e8 17 e9 ff ff       	call   100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101a31:	8b 45 08             	mov    0x8(%ebp),%eax
  101a34:	8b 40 08             	mov    0x8(%eax),%eax
  101a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a3b:	c7 04 24 1a 71 10 00 	movl   $0x10711a,(%esp)
  101a42:	e8 01 e9 ff ff       	call   100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101a47:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4a:	8b 40 0c             	mov    0xc(%eax),%eax
  101a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a51:	c7 04 24 29 71 10 00 	movl   $0x107129,(%esp)
  101a58:	e8 eb e8 ff ff       	call   100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a60:	8b 40 10             	mov    0x10(%eax),%eax
  101a63:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a67:	c7 04 24 38 71 10 00 	movl   $0x107138,(%esp)
  101a6e:	e8 d5 e8 ff ff       	call   100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101a73:	8b 45 08             	mov    0x8(%ebp),%eax
  101a76:	8b 40 14             	mov    0x14(%eax),%eax
  101a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a7d:	c7 04 24 47 71 10 00 	movl   $0x107147,(%esp)
  101a84:	e8 bf e8 ff ff       	call   100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101a89:	8b 45 08             	mov    0x8(%ebp),%eax
  101a8c:	8b 40 18             	mov    0x18(%eax),%eax
  101a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a93:	c7 04 24 56 71 10 00 	movl   $0x107156,(%esp)
  101a9a:	e8 a9 e8 ff ff       	call   100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa2:	8b 40 1c             	mov    0x1c(%eax),%eax
  101aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aa9:	c7 04 24 65 71 10 00 	movl   $0x107165,(%esp)
  101ab0:	e8 93 e8 ff ff       	call   100348 <cprintf>
}
  101ab5:	c9                   	leave  
  101ab6:	c3                   	ret    

00101ab7 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101ab7:	55                   	push   %ebp
  101ab8:	89 e5                	mov    %esp,%ebp
  101aba:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101abd:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac0:	8b 40 30             	mov    0x30(%eax),%eax
  101ac3:	83 f8 2f             	cmp    $0x2f,%eax
  101ac6:	77 1e                	ja     101ae6 <trap_dispatch+0x2f>
  101ac8:	83 f8 2e             	cmp    $0x2e,%eax
  101acb:	0f 83 bf 00 00 00    	jae    101b90 <trap_dispatch+0xd9>
  101ad1:	83 f8 21             	cmp    $0x21,%eax
  101ad4:	74 40                	je     101b16 <trap_dispatch+0x5f>
  101ad6:	83 f8 24             	cmp    $0x24,%eax
  101ad9:	74 15                	je     101af0 <trap_dispatch+0x39>
  101adb:	83 f8 20             	cmp    $0x20,%eax
  101ade:	0f 84 af 00 00 00    	je     101b93 <trap_dispatch+0xdc>
  101ae4:	eb 72                	jmp    101b58 <trap_dispatch+0xa1>
  101ae6:	83 e8 78             	sub    $0x78,%eax
  101ae9:	83 f8 01             	cmp    $0x1,%eax
  101aec:	77 6a                	ja     101b58 <trap_dispatch+0xa1>
  101aee:	eb 4c                	jmp    101b3c <trap_dispatch+0x85>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101af0:	e8 a2 fa ff ff       	call   101597 <cons_getc>
  101af5:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101af8:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101afc:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101b00:	89 54 24 08          	mov    %edx,0x8(%esp)
  101b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b08:	c7 04 24 74 71 10 00 	movl   $0x107174,(%esp)
  101b0f:	e8 34 e8 ff ff       	call   100348 <cprintf>
        break;
  101b14:	eb 7e                	jmp    101b94 <trap_dispatch+0xdd>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101b16:	e8 7c fa ff ff       	call   101597 <cons_getc>
  101b1b:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101b1e:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101b22:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101b26:	89 54 24 08          	mov    %edx,0x8(%esp)
  101b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b2e:	c7 04 24 86 71 10 00 	movl   $0x107186,(%esp)
  101b35:	e8 0e e8 ff ff       	call   100348 <cprintf>
        break;
  101b3a:	eb 58                	jmp    101b94 <trap_dispatch+0xdd>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101b3c:	c7 44 24 08 95 71 10 	movl   $0x107195,0x8(%esp)
  101b43:	00 
  101b44:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  101b4b:	00 
  101b4c:	c7 04 24 a5 71 10 00 	movl   $0x1071a5,(%esp)
  101b53:	e8 c0 f0 ff ff       	call   100c18 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101b58:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b5f:	0f b7 c0             	movzwl %ax,%eax
  101b62:	83 e0 03             	and    $0x3,%eax
  101b65:	85 c0                	test   %eax,%eax
  101b67:	75 2b                	jne    101b94 <trap_dispatch+0xdd>
            print_trapframe(tf);
  101b69:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6c:	89 04 24             	mov    %eax,(%esp)
  101b6f:	e8 c7 fc ff ff       	call   10183b <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101b74:	c7 44 24 08 b6 71 10 	movl   $0x1071b6,0x8(%esp)
  101b7b:	00 
  101b7c:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  101b83:	00 
  101b84:	c7 04 24 a5 71 10 00 	movl   $0x1071a5,(%esp)
  101b8b:	e8 88 f0 ff ff       	call   100c18 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101b90:	90                   	nop
  101b91:	eb 01                	jmp    101b94 <trap_dispatch+0xdd>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
  101b93:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101b94:	c9                   	leave  
  101b95:	c3                   	ret    

00101b96 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101b96:	55                   	push   %ebp
  101b97:	89 e5                	mov    %esp,%ebp
  101b99:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9f:	89 04 24             	mov    %eax,(%esp)
  101ba2:	e8 10 ff ff ff       	call   101ab7 <trap_dispatch>
}
  101ba7:	c9                   	leave  
  101ba8:	c3                   	ret    

00101ba9 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101ba9:	1e                   	push   %ds
    pushl %es
  101baa:	06                   	push   %es
    pushl %fs
  101bab:	0f a0                	push   %fs
    pushl %gs
  101bad:	0f a8                	push   %gs
    pushal
  101baf:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101bb0:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101bb5:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101bb7:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101bb9:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101bba:	e8 d7 ff ff ff       	call   101b96 <trap>

    # pop the pushed stack pointer
    popl %esp
  101bbf:	5c                   	pop    %esp

00101bc0 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101bc0:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101bc1:	0f a9                	pop    %gs
    popl %fs
  101bc3:	0f a1                	pop    %fs
    popl %es
  101bc5:	07                   	pop    %es
    popl %ds
  101bc6:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101bc7:	83 c4 08             	add    $0x8,%esp
    iret
  101bca:	cf                   	iret   

00101bcb <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101bcb:	6a 00                	push   $0x0
  pushl $0
  101bcd:	6a 00                	push   $0x0
  jmp __alltraps
  101bcf:	e9 d5 ff ff ff       	jmp    101ba9 <__alltraps>

00101bd4 <vector1>:
.globl vector1
vector1:
  pushl $0
  101bd4:	6a 00                	push   $0x0
  pushl $1
  101bd6:	6a 01                	push   $0x1
  jmp __alltraps
  101bd8:	e9 cc ff ff ff       	jmp    101ba9 <__alltraps>

00101bdd <vector2>:
.globl vector2
vector2:
  pushl $0
  101bdd:	6a 00                	push   $0x0
  pushl $2
  101bdf:	6a 02                	push   $0x2
  jmp __alltraps
  101be1:	e9 c3 ff ff ff       	jmp    101ba9 <__alltraps>

00101be6 <vector3>:
.globl vector3
vector3:
  pushl $0
  101be6:	6a 00                	push   $0x0
  pushl $3
  101be8:	6a 03                	push   $0x3
  jmp __alltraps
  101bea:	e9 ba ff ff ff       	jmp    101ba9 <__alltraps>

00101bef <vector4>:
.globl vector4
vector4:
  pushl $0
  101bef:	6a 00                	push   $0x0
  pushl $4
  101bf1:	6a 04                	push   $0x4
  jmp __alltraps
  101bf3:	e9 b1 ff ff ff       	jmp    101ba9 <__alltraps>

00101bf8 <vector5>:
.globl vector5
vector5:
  pushl $0
  101bf8:	6a 00                	push   $0x0
  pushl $5
  101bfa:	6a 05                	push   $0x5
  jmp __alltraps
  101bfc:	e9 a8 ff ff ff       	jmp    101ba9 <__alltraps>

00101c01 <vector6>:
.globl vector6
vector6:
  pushl $0
  101c01:	6a 00                	push   $0x0
  pushl $6
  101c03:	6a 06                	push   $0x6
  jmp __alltraps
  101c05:	e9 9f ff ff ff       	jmp    101ba9 <__alltraps>

00101c0a <vector7>:
.globl vector7
vector7:
  pushl $0
  101c0a:	6a 00                	push   $0x0
  pushl $7
  101c0c:	6a 07                	push   $0x7
  jmp __alltraps
  101c0e:	e9 96 ff ff ff       	jmp    101ba9 <__alltraps>

00101c13 <vector8>:
.globl vector8
vector8:
  pushl $8
  101c13:	6a 08                	push   $0x8
  jmp __alltraps
  101c15:	e9 8f ff ff ff       	jmp    101ba9 <__alltraps>

00101c1a <vector9>:
.globl vector9
vector9:
  pushl $0
  101c1a:	6a 00                	push   $0x0
  pushl $9
  101c1c:	6a 09                	push   $0x9
  jmp __alltraps
  101c1e:	e9 86 ff ff ff       	jmp    101ba9 <__alltraps>

00101c23 <vector10>:
.globl vector10
vector10:
  pushl $10
  101c23:	6a 0a                	push   $0xa
  jmp __alltraps
  101c25:	e9 7f ff ff ff       	jmp    101ba9 <__alltraps>

00101c2a <vector11>:
.globl vector11
vector11:
  pushl $11
  101c2a:	6a 0b                	push   $0xb
  jmp __alltraps
  101c2c:	e9 78 ff ff ff       	jmp    101ba9 <__alltraps>

00101c31 <vector12>:
.globl vector12
vector12:
  pushl $12
  101c31:	6a 0c                	push   $0xc
  jmp __alltraps
  101c33:	e9 71 ff ff ff       	jmp    101ba9 <__alltraps>

00101c38 <vector13>:
.globl vector13
vector13:
  pushl $13
  101c38:	6a 0d                	push   $0xd
  jmp __alltraps
  101c3a:	e9 6a ff ff ff       	jmp    101ba9 <__alltraps>

00101c3f <vector14>:
.globl vector14
vector14:
  pushl $14
  101c3f:	6a 0e                	push   $0xe
  jmp __alltraps
  101c41:	e9 63 ff ff ff       	jmp    101ba9 <__alltraps>

00101c46 <vector15>:
.globl vector15
vector15:
  pushl $0
  101c46:	6a 00                	push   $0x0
  pushl $15
  101c48:	6a 0f                	push   $0xf
  jmp __alltraps
  101c4a:	e9 5a ff ff ff       	jmp    101ba9 <__alltraps>

00101c4f <vector16>:
.globl vector16
vector16:
  pushl $0
  101c4f:	6a 00                	push   $0x0
  pushl $16
  101c51:	6a 10                	push   $0x10
  jmp __alltraps
  101c53:	e9 51 ff ff ff       	jmp    101ba9 <__alltraps>

00101c58 <vector17>:
.globl vector17
vector17:
  pushl $17
  101c58:	6a 11                	push   $0x11
  jmp __alltraps
  101c5a:	e9 4a ff ff ff       	jmp    101ba9 <__alltraps>

00101c5f <vector18>:
.globl vector18
vector18:
  pushl $0
  101c5f:	6a 00                	push   $0x0
  pushl $18
  101c61:	6a 12                	push   $0x12
  jmp __alltraps
  101c63:	e9 41 ff ff ff       	jmp    101ba9 <__alltraps>

00101c68 <vector19>:
.globl vector19
vector19:
  pushl $0
  101c68:	6a 00                	push   $0x0
  pushl $19
  101c6a:	6a 13                	push   $0x13
  jmp __alltraps
  101c6c:	e9 38 ff ff ff       	jmp    101ba9 <__alltraps>

00101c71 <vector20>:
.globl vector20
vector20:
  pushl $0
  101c71:	6a 00                	push   $0x0
  pushl $20
  101c73:	6a 14                	push   $0x14
  jmp __alltraps
  101c75:	e9 2f ff ff ff       	jmp    101ba9 <__alltraps>

00101c7a <vector21>:
.globl vector21
vector21:
  pushl $0
  101c7a:	6a 00                	push   $0x0
  pushl $21
  101c7c:	6a 15                	push   $0x15
  jmp __alltraps
  101c7e:	e9 26 ff ff ff       	jmp    101ba9 <__alltraps>

00101c83 <vector22>:
.globl vector22
vector22:
  pushl $0
  101c83:	6a 00                	push   $0x0
  pushl $22
  101c85:	6a 16                	push   $0x16
  jmp __alltraps
  101c87:	e9 1d ff ff ff       	jmp    101ba9 <__alltraps>

00101c8c <vector23>:
.globl vector23
vector23:
  pushl $0
  101c8c:	6a 00                	push   $0x0
  pushl $23
  101c8e:	6a 17                	push   $0x17
  jmp __alltraps
  101c90:	e9 14 ff ff ff       	jmp    101ba9 <__alltraps>

00101c95 <vector24>:
.globl vector24
vector24:
  pushl $0
  101c95:	6a 00                	push   $0x0
  pushl $24
  101c97:	6a 18                	push   $0x18
  jmp __alltraps
  101c99:	e9 0b ff ff ff       	jmp    101ba9 <__alltraps>

00101c9e <vector25>:
.globl vector25
vector25:
  pushl $0
  101c9e:	6a 00                	push   $0x0
  pushl $25
  101ca0:	6a 19                	push   $0x19
  jmp __alltraps
  101ca2:	e9 02 ff ff ff       	jmp    101ba9 <__alltraps>

00101ca7 <vector26>:
.globl vector26
vector26:
  pushl $0
  101ca7:	6a 00                	push   $0x0
  pushl $26
  101ca9:	6a 1a                	push   $0x1a
  jmp __alltraps
  101cab:	e9 f9 fe ff ff       	jmp    101ba9 <__alltraps>

00101cb0 <vector27>:
.globl vector27
vector27:
  pushl $0
  101cb0:	6a 00                	push   $0x0
  pushl $27
  101cb2:	6a 1b                	push   $0x1b
  jmp __alltraps
  101cb4:	e9 f0 fe ff ff       	jmp    101ba9 <__alltraps>

00101cb9 <vector28>:
.globl vector28
vector28:
  pushl $0
  101cb9:	6a 00                	push   $0x0
  pushl $28
  101cbb:	6a 1c                	push   $0x1c
  jmp __alltraps
  101cbd:	e9 e7 fe ff ff       	jmp    101ba9 <__alltraps>

00101cc2 <vector29>:
.globl vector29
vector29:
  pushl $0
  101cc2:	6a 00                	push   $0x0
  pushl $29
  101cc4:	6a 1d                	push   $0x1d
  jmp __alltraps
  101cc6:	e9 de fe ff ff       	jmp    101ba9 <__alltraps>

00101ccb <vector30>:
.globl vector30
vector30:
  pushl $0
  101ccb:	6a 00                	push   $0x0
  pushl $30
  101ccd:	6a 1e                	push   $0x1e
  jmp __alltraps
  101ccf:	e9 d5 fe ff ff       	jmp    101ba9 <__alltraps>

00101cd4 <vector31>:
.globl vector31
vector31:
  pushl $0
  101cd4:	6a 00                	push   $0x0
  pushl $31
  101cd6:	6a 1f                	push   $0x1f
  jmp __alltraps
  101cd8:	e9 cc fe ff ff       	jmp    101ba9 <__alltraps>

00101cdd <vector32>:
.globl vector32
vector32:
  pushl $0
  101cdd:	6a 00                	push   $0x0
  pushl $32
  101cdf:	6a 20                	push   $0x20
  jmp __alltraps
  101ce1:	e9 c3 fe ff ff       	jmp    101ba9 <__alltraps>

00101ce6 <vector33>:
.globl vector33
vector33:
  pushl $0
  101ce6:	6a 00                	push   $0x0
  pushl $33
  101ce8:	6a 21                	push   $0x21
  jmp __alltraps
  101cea:	e9 ba fe ff ff       	jmp    101ba9 <__alltraps>

00101cef <vector34>:
.globl vector34
vector34:
  pushl $0
  101cef:	6a 00                	push   $0x0
  pushl $34
  101cf1:	6a 22                	push   $0x22
  jmp __alltraps
  101cf3:	e9 b1 fe ff ff       	jmp    101ba9 <__alltraps>

00101cf8 <vector35>:
.globl vector35
vector35:
  pushl $0
  101cf8:	6a 00                	push   $0x0
  pushl $35
  101cfa:	6a 23                	push   $0x23
  jmp __alltraps
  101cfc:	e9 a8 fe ff ff       	jmp    101ba9 <__alltraps>

00101d01 <vector36>:
.globl vector36
vector36:
  pushl $0
  101d01:	6a 00                	push   $0x0
  pushl $36
  101d03:	6a 24                	push   $0x24
  jmp __alltraps
  101d05:	e9 9f fe ff ff       	jmp    101ba9 <__alltraps>

00101d0a <vector37>:
.globl vector37
vector37:
  pushl $0
  101d0a:	6a 00                	push   $0x0
  pushl $37
  101d0c:	6a 25                	push   $0x25
  jmp __alltraps
  101d0e:	e9 96 fe ff ff       	jmp    101ba9 <__alltraps>

00101d13 <vector38>:
.globl vector38
vector38:
  pushl $0
  101d13:	6a 00                	push   $0x0
  pushl $38
  101d15:	6a 26                	push   $0x26
  jmp __alltraps
  101d17:	e9 8d fe ff ff       	jmp    101ba9 <__alltraps>

00101d1c <vector39>:
.globl vector39
vector39:
  pushl $0
  101d1c:	6a 00                	push   $0x0
  pushl $39
  101d1e:	6a 27                	push   $0x27
  jmp __alltraps
  101d20:	e9 84 fe ff ff       	jmp    101ba9 <__alltraps>

00101d25 <vector40>:
.globl vector40
vector40:
  pushl $0
  101d25:	6a 00                	push   $0x0
  pushl $40
  101d27:	6a 28                	push   $0x28
  jmp __alltraps
  101d29:	e9 7b fe ff ff       	jmp    101ba9 <__alltraps>

00101d2e <vector41>:
.globl vector41
vector41:
  pushl $0
  101d2e:	6a 00                	push   $0x0
  pushl $41
  101d30:	6a 29                	push   $0x29
  jmp __alltraps
  101d32:	e9 72 fe ff ff       	jmp    101ba9 <__alltraps>

00101d37 <vector42>:
.globl vector42
vector42:
  pushl $0
  101d37:	6a 00                	push   $0x0
  pushl $42
  101d39:	6a 2a                	push   $0x2a
  jmp __alltraps
  101d3b:	e9 69 fe ff ff       	jmp    101ba9 <__alltraps>

00101d40 <vector43>:
.globl vector43
vector43:
  pushl $0
  101d40:	6a 00                	push   $0x0
  pushl $43
  101d42:	6a 2b                	push   $0x2b
  jmp __alltraps
  101d44:	e9 60 fe ff ff       	jmp    101ba9 <__alltraps>

00101d49 <vector44>:
.globl vector44
vector44:
  pushl $0
  101d49:	6a 00                	push   $0x0
  pushl $44
  101d4b:	6a 2c                	push   $0x2c
  jmp __alltraps
  101d4d:	e9 57 fe ff ff       	jmp    101ba9 <__alltraps>

00101d52 <vector45>:
.globl vector45
vector45:
  pushl $0
  101d52:	6a 00                	push   $0x0
  pushl $45
  101d54:	6a 2d                	push   $0x2d
  jmp __alltraps
  101d56:	e9 4e fe ff ff       	jmp    101ba9 <__alltraps>

00101d5b <vector46>:
.globl vector46
vector46:
  pushl $0
  101d5b:	6a 00                	push   $0x0
  pushl $46
  101d5d:	6a 2e                	push   $0x2e
  jmp __alltraps
  101d5f:	e9 45 fe ff ff       	jmp    101ba9 <__alltraps>

00101d64 <vector47>:
.globl vector47
vector47:
  pushl $0
  101d64:	6a 00                	push   $0x0
  pushl $47
  101d66:	6a 2f                	push   $0x2f
  jmp __alltraps
  101d68:	e9 3c fe ff ff       	jmp    101ba9 <__alltraps>

00101d6d <vector48>:
.globl vector48
vector48:
  pushl $0
  101d6d:	6a 00                	push   $0x0
  pushl $48
  101d6f:	6a 30                	push   $0x30
  jmp __alltraps
  101d71:	e9 33 fe ff ff       	jmp    101ba9 <__alltraps>

00101d76 <vector49>:
.globl vector49
vector49:
  pushl $0
  101d76:	6a 00                	push   $0x0
  pushl $49
  101d78:	6a 31                	push   $0x31
  jmp __alltraps
  101d7a:	e9 2a fe ff ff       	jmp    101ba9 <__alltraps>

00101d7f <vector50>:
.globl vector50
vector50:
  pushl $0
  101d7f:	6a 00                	push   $0x0
  pushl $50
  101d81:	6a 32                	push   $0x32
  jmp __alltraps
  101d83:	e9 21 fe ff ff       	jmp    101ba9 <__alltraps>

00101d88 <vector51>:
.globl vector51
vector51:
  pushl $0
  101d88:	6a 00                	push   $0x0
  pushl $51
  101d8a:	6a 33                	push   $0x33
  jmp __alltraps
  101d8c:	e9 18 fe ff ff       	jmp    101ba9 <__alltraps>

00101d91 <vector52>:
.globl vector52
vector52:
  pushl $0
  101d91:	6a 00                	push   $0x0
  pushl $52
  101d93:	6a 34                	push   $0x34
  jmp __alltraps
  101d95:	e9 0f fe ff ff       	jmp    101ba9 <__alltraps>

00101d9a <vector53>:
.globl vector53
vector53:
  pushl $0
  101d9a:	6a 00                	push   $0x0
  pushl $53
  101d9c:	6a 35                	push   $0x35
  jmp __alltraps
  101d9e:	e9 06 fe ff ff       	jmp    101ba9 <__alltraps>

00101da3 <vector54>:
.globl vector54
vector54:
  pushl $0
  101da3:	6a 00                	push   $0x0
  pushl $54
  101da5:	6a 36                	push   $0x36
  jmp __alltraps
  101da7:	e9 fd fd ff ff       	jmp    101ba9 <__alltraps>

00101dac <vector55>:
.globl vector55
vector55:
  pushl $0
  101dac:	6a 00                	push   $0x0
  pushl $55
  101dae:	6a 37                	push   $0x37
  jmp __alltraps
  101db0:	e9 f4 fd ff ff       	jmp    101ba9 <__alltraps>

00101db5 <vector56>:
.globl vector56
vector56:
  pushl $0
  101db5:	6a 00                	push   $0x0
  pushl $56
  101db7:	6a 38                	push   $0x38
  jmp __alltraps
  101db9:	e9 eb fd ff ff       	jmp    101ba9 <__alltraps>

00101dbe <vector57>:
.globl vector57
vector57:
  pushl $0
  101dbe:	6a 00                	push   $0x0
  pushl $57
  101dc0:	6a 39                	push   $0x39
  jmp __alltraps
  101dc2:	e9 e2 fd ff ff       	jmp    101ba9 <__alltraps>

00101dc7 <vector58>:
.globl vector58
vector58:
  pushl $0
  101dc7:	6a 00                	push   $0x0
  pushl $58
  101dc9:	6a 3a                	push   $0x3a
  jmp __alltraps
  101dcb:	e9 d9 fd ff ff       	jmp    101ba9 <__alltraps>

00101dd0 <vector59>:
.globl vector59
vector59:
  pushl $0
  101dd0:	6a 00                	push   $0x0
  pushl $59
  101dd2:	6a 3b                	push   $0x3b
  jmp __alltraps
  101dd4:	e9 d0 fd ff ff       	jmp    101ba9 <__alltraps>

00101dd9 <vector60>:
.globl vector60
vector60:
  pushl $0
  101dd9:	6a 00                	push   $0x0
  pushl $60
  101ddb:	6a 3c                	push   $0x3c
  jmp __alltraps
  101ddd:	e9 c7 fd ff ff       	jmp    101ba9 <__alltraps>

00101de2 <vector61>:
.globl vector61
vector61:
  pushl $0
  101de2:	6a 00                	push   $0x0
  pushl $61
  101de4:	6a 3d                	push   $0x3d
  jmp __alltraps
  101de6:	e9 be fd ff ff       	jmp    101ba9 <__alltraps>

00101deb <vector62>:
.globl vector62
vector62:
  pushl $0
  101deb:	6a 00                	push   $0x0
  pushl $62
  101ded:	6a 3e                	push   $0x3e
  jmp __alltraps
  101def:	e9 b5 fd ff ff       	jmp    101ba9 <__alltraps>

00101df4 <vector63>:
.globl vector63
vector63:
  pushl $0
  101df4:	6a 00                	push   $0x0
  pushl $63
  101df6:	6a 3f                	push   $0x3f
  jmp __alltraps
  101df8:	e9 ac fd ff ff       	jmp    101ba9 <__alltraps>

00101dfd <vector64>:
.globl vector64
vector64:
  pushl $0
  101dfd:	6a 00                	push   $0x0
  pushl $64
  101dff:	6a 40                	push   $0x40
  jmp __alltraps
  101e01:	e9 a3 fd ff ff       	jmp    101ba9 <__alltraps>

00101e06 <vector65>:
.globl vector65
vector65:
  pushl $0
  101e06:	6a 00                	push   $0x0
  pushl $65
  101e08:	6a 41                	push   $0x41
  jmp __alltraps
  101e0a:	e9 9a fd ff ff       	jmp    101ba9 <__alltraps>

00101e0f <vector66>:
.globl vector66
vector66:
  pushl $0
  101e0f:	6a 00                	push   $0x0
  pushl $66
  101e11:	6a 42                	push   $0x42
  jmp __alltraps
  101e13:	e9 91 fd ff ff       	jmp    101ba9 <__alltraps>

00101e18 <vector67>:
.globl vector67
vector67:
  pushl $0
  101e18:	6a 00                	push   $0x0
  pushl $67
  101e1a:	6a 43                	push   $0x43
  jmp __alltraps
  101e1c:	e9 88 fd ff ff       	jmp    101ba9 <__alltraps>

00101e21 <vector68>:
.globl vector68
vector68:
  pushl $0
  101e21:	6a 00                	push   $0x0
  pushl $68
  101e23:	6a 44                	push   $0x44
  jmp __alltraps
  101e25:	e9 7f fd ff ff       	jmp    101ba9 <__alltraps>

00101e2a <vector69>:
.globl vector69
vector69:
  pushl $0
  101e2a:	6a 00                	push   $0x0
  pushl $69
  101e2c:	6a 45                	push   $0x45
  jmp __alltraps
  101e2e:	e9 76 fd ff ff       	jmp    101ba9 <__alltraps>

00101e33 <vector70>:
.globl vector70
vector70:
  pushl $0
  101e33:	6a 00                	push   $0x0
  pushl $70
  101e35:	6a 46                	push   $0x46
  jmp __alltraps
  101e37:	e9 6d fd ff ff       	jmp    101ba9 <__alltraps>

00101e3c <vector71>:
.globl vector71
vector71:
  pushl $0
  101e3c:	6a 00                	push   $0x0
  pushl $71
  101e3e:	6a 47                	push   $0x47
  jmp __alltraps
  101e40:	e9 64 fd ff ff       	jmp    101ba9 <__alltraps>

00101e45 <vector72>:
.globl vector72
vector72:
  pushl $0
  101e45:	6a 00                	push   $0x0
  pushl $72
  101e47:	6a 48                	push   $0x48
  jmp __alltraps
  101e49:	e9 5b fd ff ff       	jmp    101ba9 <__alltraps>

00101e4e <vector73>:
.globl vector73
vector73:
  pushl $0
  101e4e:	6a 00                	push   $0x0
  pushl $73
  101e50:	6a 49                	push   $0x49
  jmp __alltraps
  101e52:	e9 52 fd ff ff       	jmp    101ba9 <__alltraps>

00101e57 <vector74>:
.globl vector74
vector74:
  pushl $0
  101e57:	6a 00                	push   $0x0
  pushl $74
  101e59:	6a 4a                	push   $0x4a
  jmp __alltraps
  101e5b:	e9 49 fd ff ff       	jmp    101ba9 <__alltraps>

00101e60 <vector75>:
.globl vector75
vector75:
  pushl $0
  101e60:	6a 00                	push   $0x0
  pushl $75
  101e62:	6a 4b                	push   $0x4b
  jmp __alltraps
  101e64:	e9 40 fd ff ff       	jmp    101ba9 <__alltraps>

00101e69 <vector76>:
.globl vector76
vector76:
  pushl $0
  101e69:	6a 00                	push   $0x0
  pushl $76
  101e6b:	6a 4c                	push   $0x4c
  jmp __alltraps
  101e6d:	e9 37 fd ff ff       	jmp    101ba9 <__alltraps>

00101e72 <vector77>:
.globl vector77
vector77:
  pushl $0
  101e72:	6a 00                	push   $0x0
  pushl $77
  101e74:	6a 4d                	push   $0x4d
  jmp __alltraps
  101e76:	e9 2e fd ff ff       	jmp    101ba9 <__alltraps>

00101e7b <vector78>:
.globl vector78
vector78:
  pushl $0
  101e7b:	6a 00                	push   $0x0
  pushl $78
  101e7d:	6a 4e                	push   $0x4e
  jmp __alltraps
  101e7f:	e9 25 fd ff ff       	jmp    101ba9 <__alltraps>

00101e84 <vector79>:
.globl vector79
vector79:
  pushl $0
  101e84:	6a 00                	push   $0x0
  pushl $79
  101e86:	6a 4f                	push   $0x4f
  jmp __alltraps
  101e88:	e9 1c fd ff ff       	jmp    101ba9 <__alltraps>

00101e8d <vector80>:
.globl vector80
vector80:
  pushl $0
  101e8d:	6a 00                	push   $0x0
  pushl $80
  101e8f:	6a 50                	push   $0x50
  jmp __alltraps
  101e91:	e9 13 fd ff ff       	jmp    101ba9 <__alltraps>

00101e96 <vector81>:
.globl vector81
vector81:
  pushl $0
  101e96:	6a 00                	push   $0x0
  pushl $81
  101e98:	6a 51                	push   $0x51
  jmp __alltraps
  101e9a:	e9 0a fd ff ff       	jmp    101ba9 <__alltraps>

00101e9f <vector82>:
.globl vector82
vector82:
  pushl $0
  101e9f:	6a 00                	push   $0x0
  pushl $82
  101ea1:	6a 52                	push   $0x52
  jmp __alltraps
  101ea3:	e9 01 fd ff ff       	jmp    101ba9 <__alltraps>

00101ea8 <vector83>:
.globl vector83
vector83:
  pushl $0
  101ea8:	6a 00                	push   $0x0
  pushl $83
  101eaa:	6a 53                	push   $0x53
  jmp __alltraps
  101eac:	e9 f8 fc ff ff       	jmp    101ba9 <__alltraps>

00101eb1 <vector84>:
.globl vector84
vector84:
  pushl $0
  101eb1:	6a 00                	push   $0x0
  pushl $84
  101eb3:	6a 54                	push   $0x54
  jmp __alltraps
  101eb5:	e9 ef fc ff ff       	jmp    101ba9 <__alltraps>

00101eba <vector85>:
.globl vector85
vector85:
  pushl $0
  101eba:	6a 00                	push   $0x0
  pushl $85
  101ebc:	6a 55                	push   $0x55
  jmp __alltraps
  101ebe:	e9 e6 fc ff ff       	jmp    101ba9 <__alltraps>

00101ec3 <vector86>:
.globl vector86
vector86:
  pushl $0
  101ec3:	6a 00                	push   $0x0
  pushl $86
  101ec5:	6a 56                	push   $0x56
  jmp __alltraps
  101ec7:	e9 dd fc ff ff       	jmp    101ba9 <__alltraps>

00101ecc <vector87>:
.globl vector87
vector87:
  pushl $0
  101ecc:	6a 00                	push   $0x0
  pushl $87
  101ece:	6a 57                	push   $0x57
  jmp __alltraps
  101ed0:	e9 d4 fc ff ff       	jmp    101ba9 <__alltraps>

00101ed5 <vector88>:
.globl vector88
vector88:
  pushl $0
  101ed5:	6a 00                	push   $0x0
  pushl $88
  101ed7:	6a 58                	push   $0x58
  jmp __alltraps
  101ed9:	e9 cb fc ff ff       	jmp    101ba9 <__alltraps>

00101ede <vector89>:
.globl vector89
vector89:
  pushl $0
  101ede:	6a 00                	push   $0x0
  pushl $89
  101ee0:	6a 59                	push   $0x59
  jmp __alltraps
  101ee2:	e9 c2 fc ff ff       	jmp    101ba9 <__alltraps>

00101ee7 <vector90>:
.globl vector90
vector90:
  pushl $0
  101ee7:	6a 00                	push   $0x0
  pushl $90
  101ee9:	6a 5a                	push   $0x5a
  jmp __alltraps
  101eeb:	e9 b9 fc ff ff       	jmp    101ba9 <__alltraps>

00101ef0 <vector91>:
.globl vector91
vector91:
  pushl $0
  101ef0:	6a 00                	push   $0x0
  pushl $91
  101ef2:	6a 5b                	push   $0x5b
  jmp __alltraps
  101ef4:	e9 b0 fc ff ff       	jmp    101ba9 <__alltraps>

00101ef9 <vector92>:
.globl vector92
vector92:
  pushl $0
  101ef9:	6a 00                	push   $0x0
  pushl $92
  101efb:	6a 5c                	push   $0x5c
  jmp __alltraps
  101efd:	e9 a7 fc ff ff       	jmp    101ba9 <__alltraps>

00101f02 <vector93>:
.globl vector93
vector93:
  pushl $0
  101f02:	6a 00                	push   $0x0
  pushl $93
  101f04:	6a 5d                	push   $0x5d
  jmp __alltraps
  101f06:	e9 9e fc ff ff       	jmp    101ba9 <__alltraps>

00101f0b <vector94>:
.globl vector94
vector94:
  pushl $0
  101f0b:	6a 00                	push   $0x0
  pushl $94
  101f0d:	6a 5e                	push   $0x5e
  jmp __alltraps
  101f0f:	e9 95 fc ff ff       	jmp    101ba9 <__alltraps>

00101f14 <vector95>:
.globl vector95
vector95:
  pushl $0
  101f14:	6a 00                	push   $0x0
  pushl $95
  101f16:	6a 5f                	push   $0x5f
  jmp __alltraps
  101f18:	e9 8c fc ff ff       	jmp    101ba9 <__alltraps>

00101f1d <vector96>:
.globl vector96
vector96:
  pushl $0
  101f1d:	6a 00                	push   $0x0
  pushl $96
  101f1f:	6a 60                	push   $0x60
  jmp __alltraps
  101f21:	e9 83 fc ff ff       	jmp    101ba9 <__alltraps>

00101f26 <vector97>:
.globl vector97
vector97:
  pushl $0
  101f26:	6a 00                	push   $0x0
  pushl $97
  101f28:	6a 61                	push   $0x61
  jmp __alltraps
  101f2a:	e9 7a fc ff ff       	jmp    101ba9 <__alltraps>

00101f2f <vector98>:
.globl vector98
vector98:
  pushl $0
  101f2f:	6a 00                	push   $0x0
  pushl $98
  101f31:	6a 62                	push   $0x62
  jmp __alltraps
  101f33:	e9 71 fc ff ff       	jmp    101ba9 <__alltraps>

00101f38 <vector99>:
.globl vector99
vector99:
  pushl $0
  101f38:	6a 00                	push   $0x0
  pushl $99
  101f3a:	6a 63                	push   $0x63
  jmp __alltraps
  101f3c:	e9 68 fc ff ff       	jmp    101ba9 <__alltraps>

00101f41 <vector100>:
.globl vector100
vector100:
  pushl $0
  101f41:	6a 00                	push   $0x0
  pushl $100
  101f43:	6a 64                	push   $0x64
  jmp __alltraps
  101f45:	e9 5f fc ff ff       	jmp    101ba9 <__alltraps>

00101f4a <vector101>:
.globl vector101
vector101:
  pushl $0
  101f4a:	6a 00                	push   $0x0
  pushl $101
  101f4c:	6a 65                	push   $0x65
  jmp __alltraps
  101f4e:	e9 56 fc ff ff       	jmp    101ba9 <__alltraps>

00101f53 <vector102>:
.globl vector102
vector102:
  pushl $0
  101f53:	6a 00                	push   $0x0
  pushl $102
  101f55:	6a 66                	push   $0x66
  jmp __alltraps
  101f57:	e9 4d fc ff ff       	jmp    101ba9 <__alltraps>

00101f5c <vector103>:
.globl vector103
vector103:
  pushl $0
  101f5c:	6a 00                	push   $0x0
  pushl $103
  101f5e:	6a 67                	push   $0x67
  jmp __alltraps
  101f60:	e9 44 fc ff ff       	jmp    101ba9 <__alltraps>

00101f65 <vector104>:
.globl vector104
vector104:
  pushl $0
  101f65:	6a 00                	push   $0x0
  pushl $104
  101f67:	6a 68                	push   $0x68
  jmp __alltraps
  101f69:	e9 3b fc ff ff       	jmp    101ba9 <__alltraps>

00101f6e <vector105>:
.globl vector105
vector105:
  pushl $0
  101f6e:	6a 00                	push   $0x0
  pushl $105
  101f70:	6a 69                	push   $0x69
  jmp __alltraps
  101f72:	e9 32 fc ff ff       	jmp    101ba9 <__alltraps>

00101f77 <vector106>:
.globl vector106
vector106:
  pushl $0
  101f77:	6a 00                	push   $0x0
  pushl $106
  101f79:	6a 6a                	push   $0x6a
  jmp __alltraps
  101f7b:	e9 29 fc ff ff       	jmp    101ba9 <__alltraps>

00101f80 <vector107>:
.globl vector107
vector107:
  pushl $0
  101f80:	6a 00                	push   $0x0
  pushl $107
  101f82:	6a 6b                	push   $0x6b
  jmp __alltraps
  101f84:	e9 20 fc ff ff       	jmp    101ba9 <__alltraps>

00101f89 <vector108>:
.globl vector108
vector108:
  pushl $0
  101f89:	6a 00                	push   $0x0
  pushl $108
  101f8b:	6a 6c                	push   $0x6c
  jmp __alltraps
  101f8d:	e9 17 fc ff ff       	jmp    101ba9 <__alltraps>

00101f92 <vector109>:
.globl vector109
vector109:
  pushl $0
  101f92:	6a 00                	push   $0x0
  pushl $109
  101f94:	6a 6d                	push   $0x6d
  jmp __alltraps
  101f96:	e9 0e fc ff ff       	jmp    101ba9 <__alltraps>

00101f9b <vector110>:
.globl vector110
vector110:
  pushl $0
  101f9b:	6a 00                	push   $0x0
  pushl $110
  101f9d:	6a 6e                	push   $0x6e
  jmp __alltraps
  101f9f:	e9 05 fc ff ff       	jmp    101ba9 <__alltraps>

00101fa4 <vector111>:
.globl vector111
vector111:
  pushl $0
  101fa4:	6a 00                	push   $0x0
  pushl $111
  101fa6:	6a 6f                	push   $0x6f
  jmp __alltraps
  101fa8:	e9 fc fb ff ff       	jmp    101ba9 <__alltraps>

00101fad <vector112>:
.globl vector112
vector112:
  pushl $0
  101fad:	6a 00                	push   $0x0
  pushl $112
  101faf:	6a 70                	push   $0x70
  jmp __alltraps
  101fb1:	e9 f3 fb ff ff       	jmp    101ba9 <__alltraps>

00101fb6 <vector113>:
.globl vector113
vector113:
  pushl $0
  101fb6:	6a 00                	push   $0x0
  pushl $113
  101fb8:	6a 71                	push   $0x71
  jmp __alltraps
  101fba:	e9 ea fb ff ff       	jmp    101ba9 <__alltraps>

00101fbf <vector114>:
.globl vector114
vector114:
  pushl $0
  101fbf:	6a 00                	push   $0x0
  pushl $114
  101fc1:	6a 72                	push   $0x72
  jmp __alltraps
  101fc3:	e9 e1 fb ff ff       	jmp    101ba9 <__alltraps>

00101fc8 <vector115>:
.globl vector115
vector115:
  pushl $0
  101fc8:	6a 00                	push   $0x0
  pushl $115
  101fca:	6a 73                	push   $0x73
  jmp __alltraps
  101fcc:	e9 d8 fb ff ff       	jmp    101ba9 <__alltraps>

00101fd1 <vector116>:
.globl vector116
vector116:
  pushl $0
  101fd1:	6a 00                	push   $0x0
  pushl $116
  101fd3:	6a 74                	push   $0x74
  jmp __alltraps
  101fd5:	e9 cf fb ff ff       	jmp    101ba9 <__alltraps>

00101fda <vector117>:
.globl vector117
vector117:
  pushl $0
  101fda:	6a 00                	push   $0x0
  pushl $117
  101fdc:	6a 75                	push   $0x75
  jmp __alltraps
  101fde:	e9 c6 fb ff ff       	jmp    101ba9 <__alltraps>

00101fe3 <vector118>:
.globl vector118
vector118:
  pushl $0
  101fe3:	6a 00                	push   $0x0
  pushl $118
  101fe5:	6a 76                	push   $0x76
  jmp __alltraps
  101fe7:	e9 bd fb ff ff       	jmp    101ba9 <__alltraps>

00101fec <vector119>:
.globl vector119
vector119:
  pushl $0
  101fec:	6a 00                	push   $0x0
  pushl $119
  101fee:	6a 77                	push   $0x77
  jmp __alltraps
  101ff0:	e9 b4 fb ff ff       	jmp    101ba9 <__alltraps>

00101ff5 <vector120>:
.globl vector120
vector120:
  pushl $0
  101ff5:	6a 00                	push   $0x0
  pushl $120
  101ff7:	6a 78                	push   $0x78
  jmp __alltraps
  101ff9:	e9 ab fb ff ff       	jmp    101ba9 <__alltraps>

00101ffe <vector121>:
.globl vector121
vector121:
  pushl $0
  101ffe:	6a 00                	push   $0x0
  pushl $121
  102000:	6a 79                	push   $0x79
  jmp __alltraps
  102002:	e9 a2 fb ff ff       	jmp    101ba9 <__alltraps>

00102007 <vector122>:
.globl vector122
vector122:
  pushl $0
  102007:	6a 00                	push   $0x0
  pushl $122
  102009:	6a 7a                	push   $0x7a
  jmp __alltraps
  10200b:	e9 99 fb ff ff       	jmp    101ba9 <__alltraps>

00102010 <vector123>:
.globl vector123
vector123:
  pushl $0
  102010:	6a 00                	push   $0x0
  pushl $123
  102012:	6a 7b                	push   $0x7b
  jmp __alltraps
  102014:	e9 90 fb ff ff       	jmp    101ba9 <__alltraps>

00102019 <vector124>:
.globl vector124
vector124:
  pushl $0
  102019:	6a 00                	push   $0x0
  pushl $124
  10201b:	6a 7c                	push   $0x7c
  jmp __alltraps
  10201d:	e9 87 fb ff ff       	jmp    101ba9 <__alltraps>

00102022 <vector125>:
.globl vector125
vector125:
  pushl $0
  102022:	6a 00                	push   $0x0
  pushl $125
  102024:	6a 7d                	push   $0x7d
  jmp __alltraps
  102026:	e9 7e fb ff ff       	jmp    101ba9 <__alltraps>

0010202b <vector126>:
.globl vector126
vector126:
  pushl $0
  10202b:	6a 00                	push   $0x0
  pushl $126
  10202d:	6a 7e                	push   $0x7e
  jmp __alltraps
  10202f:	e9 75 fb ff ff       	jmp    101ba9 <__alltraps>

00102034 <vector127>:
.globl vector127
vector127:
  pushl $0
  102034:	6a 00                	push   $0x0
  pushl $127
  102036:	6a 7f                	push   $0x7f
  jmp __alltraps
  102038:	e9 6c fb ff ff       	jmp    101ba9 <__alltraps>

0010203d <vector128>:
.globl vector128
vector128:
  pushl $0
  10203d:	6a 00                	push   $0x0
  pushl $128
  10203f:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102044:	e9 60 fb ff ff       	jmp    101ba9 <__alltraps>

00102049 <vector129>:
.globl vector129
vector129:
  pushl $0
  102049:	6a 00                	push   $0x0
  pushl $129
  10204b:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102050:	e9 54 fb ff ff       	jmp    101ba9 <__alltraps>

00102055 <vector130>:
.globl vector130
vector130:
  pushl $0
  102055:	6a 00                	push   $0x0
  pushl $130
  102057:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10205c:	e9 48 fb ff ff       	jmp    101ba9 <__alltraps>

00102061 <vector131>:
.globl vector131
vector131:
  pushl $0
  102061:	6a 00                	push   $0x0
  pushl $131
  102063:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102068:	e9 3c fb ff ff       	jmp    101ba9 <__alltraps>

0010206d <vector132>:
.globl vector132
vector132:
  pushl $0
  10206d:	6a 00                	push   $0x0
  pushl $132
  10206f:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102074:	e9 30 fb ff ff       	jmp    101ba9 <__alltraps>

00102079 <vector133>:
.globl vector133
vector133:
  pushl $0
  102079:	6a 00                	push   $0x0
  pushl $133
  10207b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102080:	e9 24 fb ff ff       	jmp    101ba9 <__alltraps>

00102085 <vector134>:
.globl vector134
vector134:
  pushl $0
  102085:	6a 00                	push   $0x0
  pushl $134
  102087:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10208c:	e9 18 fb ff ff       	jmp    101ba9 <__alltraps>

00102091 <vector135>:
.globl vector135
vector135:
  pushl $0
  102091:	6a 00                	push   $0x0
  pushl $135
  102093:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102098:	e9 0c fb ff ff       	jmp    101ba9 <__alltraps>

0010209d <vector136>:
.globl vector136
vector136:
  pushl $0
  10209d:	6a 00                	push   $0x0
  pushl $136
  10209f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1020a4:	e9 00 fb ff ff       	jmp    101ba9 <__alltraps>

001020a9 <vector137>:
.globl vector137
vector137:
  pushl $0
  1020a9:	6a 00                	push   $0x0
  pushl $137
  1020ab:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1020b0:	e9 f4 fa ff ff       	jmp    101ba9 <__alltraps>

001020b5 <vector138>:
.globl vector138
vector138:
  pushl $0
  1020b5:	6a 00                	push   $0x0
  pushl $138
  1020b7:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1020bc:	e9 e8 fa ff ff       	jmp    101ba9 <__alltraps>

001020c1 <vector139>:
.globl vector139
vector139:
  pushl $0
  1020c1:	6a 00                	push   $0x0
  pushl $139
  1020c3:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1020c8:	e9 dc fa ff ff       	jmp    101ba9 <__alltraps>

001020cd <vector140>:
.globl vector140
vector140:
  pushl $0
  1020cd:	6a 00                	push   $0x0
  pushl $140
  1020cf:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1020d4:	e9 d0 fa ff ff       	jmp    101ba9 <__alltraps>

001020d9 <vector141>:
.globl vector141
vector141:
  pushl $0
  1020d9:	6a 00                	push   $0x0
  pushl $141
  1020db:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1020e0:	e9 c4 fa ff ff       	jmp    101ba9 <__alltraps>

001020e5 <vector142>:
.globl vector142
vector142:
  pushl $0
  1020e5:	6a 00                	push   $0x0
  pushl $142
  1020e7:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1020ec:	e9 b8 fa ff ff       	jmp    101ba9 <__alltraps>

001020f1 <vector143>:
.globl vector143
vector143:
  pushl $0
  1020f1:	6a 00                	push   $0x0
  pushl $143
  1020f3:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1020f8:	e9 ac fa ff ff       	jmp    101ba9 <__alltraps>

001020fd <vector144>:
.globl vector144
vector144:
  pushl $0
  1020fd:	6a 00                	push   $0x0
  pushl $144
  1020ff:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102104:	e9 a0 fa ff ff       	jmp    101ba9 <__alltraps>

00102109 <vector145>:
.globl vector145
vector145:
  pushl $0
  102109:	6a 00                	push   $0x0
  pushl $145
  10210b:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102110:	e9 94 fa ff ff       	jmp    101ba9 <__alltraps>

00102115 <vector146>:
.globl vector146
vector146:
  pushl $0
  102115:	6a 00                	push   $0x0
  pushl $146
  102117:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10211c:	e9 88 fa ff ff       	jmp    101ba9 <__alltraps>

00102121 <vector147>:
.globl vector147
vector147:
  pushl $0
  102121:	6a 00                	push   $0x0
  pushl $147
  102123:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102128:	e9 7c fa ff ff       	jmp    101ba9 <__alltraps>

0010212d <vector148>:
.globl vector148
vector148:
  pushl $0
  10212d:	6a 00                	push   $0x0
  pushl $148
  10212f:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102134:	e9 70 fa ff ff       	jmp    101ba9 <__alltraps>

00102139 <vector149>:
.globl vector149
vector149:
  pushl $0
  102139:	6a 00                	push   $0x0
  pushl $149
  10213b:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102140:	e9 64 fa ff ff       	jmp    101ba9 <__alltraps>

00102145 <vector150>:
.globl vector150
vector150:
  pushl $0
  102145:	6a 00                	push   $0x0
  pushl $150
  102147:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10214c:	e9 58 fa ff ff       	jmp    101ba9 <__alltraps>

00102151 <vector151>:
.globl vector151
vector151:
  pushl $0
  102151:	6a 00                	push   $0x0
  pushl $151
  102153:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102158:	e9 4c fa ff ff       	jmp    101ba9 <__alltraps>

0010215d <vector152>:
.globl vector152
vector152:
  pushl $0
  10215d:	6a 00                	push   $0x0
  pushl $152
  10215f:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102164:	e9 40 fa ff ff       	jmp    101ba9 <__alltraps>

00102169 <vector153>:
.globl vector153
vector153:
  pushl $0
  102169:	6a 00                	push   $0x0
  pushl $153
  10216b:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102170:	e9 34 fa ff ff       	jmp    101ba9 <__alltraps>

00102175 <vector154>:
.globl vector154
vector154:
  pushl $0
  102175:	6a 00                	push   $0x0
  pushl $154
  102177:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10217c:	e9 28 fa ff ff       	jmp    101ba9 <__alltraps>

00102181 <vector155>:
.globl vector155
vector155:
  pushl $0
  102181:	6a 00                	push   $0x0
  pushl $155
  102183:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102188:	e9 1c fa ff ff       	jmp    101ba9 <__alltraps>

0010218d <vector156>:
.globl vector156
vector156:
  pushl $0
  10218d:	6a 00                	push   $0x0
  pushl $156
  10218f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102194:	e9 10 fa ff ff       	jmp    101ba9 <__alltraps>

00102199 <vector157>:
.globl vector157
vector157:
  pushl $0
  102199:	6a 00                	push   $0x0
  pushl $157
  10219b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1021a0:	e9 04 fa ff ff       	jmp    101ba9 <__alltraps>

001021a5 <vector158>:
.globl vector158
vector158:
  pushl $0
  1021a5:	6a 00                	push   $0x0
  pushl $158
  1021a7:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1021ac:	e9 f8 f9 ff ff       	jmp    101ba9 <__alltraps>

001021b1 <vector159>:
.globl vector159
vector159:
  pushl $0
  1021b1:	6a 00                	push   $0x0
  pushl $159
  1021b3:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1021b8:	e9 ec f9 ff ff       	jmp    101ba9 <__alltraps>

001021bd <vector160>:
.globl vector160
vector160:
  pushl $0
  1021bd:	6a 00                	push   $0x0
  pushl $160
  1021bf:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1021c4:	e9 e0 f9 ff ff       	jmp    101ba9 <__alltraps>

001021c9 <vector161>:
.globl vector161
vector161:
  pushl $0
  1021c9:	6a 00                	push   $0x0
  pushl $161
  1021cb:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1021d0:	e9 d4 f9 ff ff       	jmp    101ba9 <__alltraps>

001021d5 <vector162>:
.globl vector162
vector162:
  pushl $0
  1021d5:	6a 00                	push   $0x0
  pushl $162
  1021d7:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1021dc:	e9 c8 f9 ff ff       	jmp    101ba9 <__alltraps>

001021e1 <vector163>:
.globl vector163
vector163:
  pushl $0
  1021e1:	6a 00                	push   $0x0
  pushl $163
  1021e3:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1021e8:	e9 bc f9 ff ff       	jmp    101ba9 <__alltraps>

001021ed <vector164>:
.globl vector164
vector164:
  pushl $0
  1021ed:	6a 00                	push   $0x0
  pushl $164
  1021ef:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1021f4:	e9 b0 f9 ff ff       	jmp    101ba9 <__alltraps>

001021f9 <vector165>:
.globl vector165
vector165:
  pushl $0
  1021f9:	6a 00                	push   $0x0
  pushl $165
  1021fb:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102200:	e9 a4 f9 ff ff       	jmp    101ba9 <__alltraps>

00102205 <vector166>:
.globl vector166
vector166:
  pushl $0
  102205:	6a 00                	push   $0x0
  pushl $166
  102207:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10220c:	e9 98 f9 ff ff       	jmp    101ba9 <__alltraps>

00102211 <vector167>:
.globl vector167
vector167:
  pushl $0
  102211:	6a 00                	push   $0x0
  pushl $167
  102213:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102218:	e9 8c f9 ff ff       	jmp    101ba9 <__alltraps>

0010221d <vector168>:
.globl vector168
vector168:
  pushl $0
  10221d:	6a 00                	push   $0x0
  pushl $168
  10221f:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102224:	e9 80 f9 ff ff       	jmp    101ba9 <__alltraps>

00102229 <vector169>:
.globl vector169
vector169:
  pushl $0
  102229:	6a 00                	push   $0x0
  pushl $169
  10222b:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102230:	e9 74 f9 ff ff       	jmp    101ba9 <__alltraps>

00102235 <vector170>:
.globl vector170
vector170:
  pushl $0
  102235:	6a 00                	push   $0x0
  pushl $170
  102237:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10223c:	e9 68 f9 ff ff       	jmp    101ba9 <__alltraps>

00102241 <vector171>:
.globl vector171
vector171:
  pushl $0
  102241:	6a 00                	push   $0x0
  pushl $171
  102243:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102248:	e9 5c f9 ff ff       	jmp    101ba9 <__alltraps>

0010224d <vector172>:
.globl vector172
vector172:
  pushl $0
  10224d:	6a 00                	push   $0x0
  pushl $172
  10224f:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102254:	e9 50 f9 ff ff       	jmp    101ba9 <__alltraps>

00102259 <vector173>:
.globl vector173
vector173:
  pushl $0
  102259:	6a 00                	push   $0x0
  pushl $173
  10225b:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102260:	e9 44 f9 ff ff       	jmp    101ba9 <__alltraps>

00102265 <vector174>:
.globl vector174
vector174:
  pushl $0
  102265:	6a 00                	push   $0x0
  pushl $174
  102267:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10226c:	e9 38 f9 ff ff       	jmp    101ba9 <__alltraps>

00102271 <vector175>:
.globl vector175
vector175:
  pushl $0
  102271:	6a 00                	push   $0x0
  pushl $175
  102273:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102278:	e9 2c f9 ff ff       	jmp    101ba9 <__alltraps>

0010227d <vector176>:
.globl vector176
vector176:
  pushl $0
  10227d:	6a 00                	push   $0x0
  pushl $176
  10227f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102284:	e9 20 f9 ff ff       	jmp    101ba9 <__alltraps>

00102289 <vector177>:
.globl vector177
vector177:
  pushl $0
  102289:	6a 00                	push   $0x0
  pushl $177
  10228b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102290:	e9 14 f9 ff ff       	jmp    101ba9 <__alltraps>

00102295 <vector178>:
.globl vector178
vector178:
  pushl $0
  102295:	6a 00                	push   $0x0
  pushl $178
  102297:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  10229c:	e9 08 f9 ff ff       	jmp    101ba9 <__alltraps>

001022a1 <vector179>:
.globl vector179
vector179:
  pushl $0
  1022a1:	6a 00                	push   $0x0
  pushl $179
  1022a3:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1022a8:	e9 fc f8 ff ff       	jmp    101ba9 <__alltraps>

001022ad <vector180>:
.globl vector180
vector180:
  pushl $0
  1022ad:	6a 00                	push   $0x0
  pushl $180
  1022af:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1022b4:	e9 f0 f8 ff ff       	jmp    101ba9 <__alltraps>

001022b9 <vector181>:
.globl vector181
vector181:
  pushl $0
  1022b9:	6a 00                	push   $0x0
  pushl $181
  1022bb:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1022c0:	e9 e4 f8 ff ff       	jmp    101ba9 <__alltraps>

001022c5 <vector182>:
.globl vector182
vector182:
  pushl $0
  1022c5:	6a 00                	push   $0x0
  pushl $182
  1022c7:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1022cc:	e9 d8 f8 ff ff       	jmp    101ba9 <__alltraps>

001022d1 <vector183>:
.globl vector183
vector183:
  pushl $0
  1022d1:	6a 00                	push   $0x0
  pushl $183
  1022d3:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1022d8:	e9 cc f8 ff ff       	jmp    101ba9 <__alltraps>

001022dd <vector184>:
.globl vector184
vector184:
  pushl $0
  1022dd:	6a 00                	push   $0x0
  pushl $184
  1022df:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1022e4:	e9 c0 f8 ff ff       	jmp    101ba9 <__alltraps>

001022e9 <vector185>:
.globl vector185
vector185:
  pushl $0
  1022e9:	6a 00                	push   $0x0
  pushl $185
  1022eb:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1022f0:	e9 b4 f8 ff ff       	jmp    101ba9 <__alltraps>

001022f5 <vector186>:
.globl vector186
vector186:
  pushl $0
  1022f5:	6a 00                	push   $0x0
  pushl $186
  1022f7:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1022fc:	e9 a8 f8 ff ff       	jmp    101ba9 <__alltraps>

00102301 <vector187>:
.globl vector187
vector187:
  pushl $0
  102301:	6a 00                	push   $0x0
  pushl $187
  102303:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102308:	e9 9c f8 ff ff       	jmp    101ba9 <__alltraps>

0010230d <vector188>:
.globl vector188
vector188:
  pushl $0
  10230d:	6a 00                	push   $0x0
  pushl $188
  10230f:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102314:	e9 90 f8 ff ff       	jmp    101ba9 <__alltraps>

00102319 <vector189>:
.globl vector189
vector189:
  pushl $0
  102319:	6a 00                	push   $0x0
  pushl $189
  10231b:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102320:	e9 84 f8 ff ff       	jmp    101ba9 <__alltraps>

00102325 <vector190>:
.globl vector190
vector190:
  pushl $0
  102325:	6a 00                	push   $0x0
  pushl $190
  102327:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10232c:	e9 78 f8 ff ff       	jmp    101ba9 <__alltraps>

00102331 <vector191>:
.globl vector191
vector191:
  pushl $0
  102331:	6a 00                	push   $0x0
  pushl $191
  102333:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102338:	e9 6c f8 ff ff       	jmp    101ba9 <__alltraps>

0010233d <vector192>:
.globl vector192
vector192:
  pushl $0
  10233d:	6a 00                	push   $0x0
  pushl $192
  10233f:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102344:	e9 60 f8 ff ff       	jmp    101ba9 <__alltraps>

00102349 <vector193>:
.globl vector193
vector193:
  pushl $0
  102349:	6a 00                	push   $0x0
  pushl $193
  10234b:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102350:	e9 54 f8 ff ff       	jmp    101ba9 <__alltraps>

00102355 <vector194>:
.globl vector194
vector194:
  pushl $0
  102355:	6a 00                	push   $0x0
  pushl $194
  102357:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10235c:	e9 48 f8 ff ff       	jmp    101ba9 <__alltraps>

00102361 <vector195>:
.globl vector195
vector195:
  pushl $0
  102361:	6a 00                	push   $0x0
  pushl $195
  102363:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102368:	e9 3c f8 ff ff       	jmp    101ba9 <__alltraps>

0010236d <vector196>:
.globl vector196
vector196:
  pushl $0
  10236d:	6a 00                	push   $0x0
  pushl $196
  10236f:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102374:	e9 30 f8 ff ff       	jmp    101ba9 <__alltraps>

00102379 <vector197>:
.globl vector197
vector197:
  pushl $0
  102379:	6a 00                	push   $0x0
  pushl $197
  10237b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102380:	e9 24 f8 ff ff       	jmp    101ba9 <__alltraps>

00102385 <vector198>:
.globl vector198
vector198:
  pushl $0
  102385:	6a 00                	push   $0x0
  pushl $198
  102387:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10238c:	e9 18 f8 ff ff       	jmp    101ba9 <__alltraps>

00102391 <vector199>:
.globl vector199
vector199:
  pushl $0
  102391:	6a 00                	push   $0x0
  pushl $199
  102393:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102398:	e9 0c f8 ff ff       	jmp    101ba9 <__alltraps>

0010239d <vector200>:
.globl vector200
vector200:
  pushl $0
  10239d:	6a 00                	push   $0x0
  pushl $200
  10239f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1023a4:	e9 00 f8 ff ff       	jmp    101ba9 <__alltraps>

001023a9 <vector201>:
.globl vector201
vector201:
  pushl $0
  1023a9:	6a 00                	push   $0x0
  pushl $201
  1023ab:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1023b0:	e9 f4 f7 ff ff       	jmp    101ba9 <__alltraps>

001023b5 <vector202>:
.globl vector202
vector202:
  pushl $0
  1023b5:	6a 00                	push   $0x0
  pushl $202
  1023b7:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1023bc:	e9 e8 f7 ff ff       	jmp    101ba9 <__alltraps>

001023c1 <vector203>:
.globl vector203
vector203:
  pushl $0
  1023c1:	6a 00                	push   $0x0
  pushl $203
  1023c3:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1023c8:	e9 dc f7 ff ff       	jmp    101ba9 <__alltraps>

001023cd <vector204>:
.globl vector204
vector204:
  pushl $0
  1023cd:	6a 00                	push   $0x0
  pushl $204
  1023cf:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1023d4:	e9 d0 f7 ff ff       	jmp    101ba9 <__alltraps>

001023d9 <vector205>:
.globl vector205
vector205:
  pushl $0
  1023d9:	6a 00                	push   $0x0
  pushl $205
  1023db:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1023e0:	e9 c4 f7 ff ff       	jmp    101ba9 <__alltraps>

001023e5 <vector206>:
.globl vector206
vector206:
  pushl $0
  1023e5:	6a 00                	push   $0x0
  pushl $206
  1023e7:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1023ec:	e9 b8 f7 ff ff       	jmp    101ba9 <__alltraps>

001023f1 <vector207>:
.globl vector207
vector207:
  pushl $0
  1023f1:	6a 00                	push   $0x0
  pushl $207
  1023f3:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1023f8:	e9 ac f7 ff ff       	jmp    101ba9 <__alltraps>

001023fd <vector208>:
.globl vector208
vector208:
  pushl $0
  1023fd:	6a 00                	push   $0x0
  pushl $208
  1023ff:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102404:	e9 a0 f7 ff ff       	jmp    101ba9 <__alltraps>

00102409 <vector209>:
.globl vector209
vector209:
  pushl $0
  102409:	6a 00                	push   $0x0
  pushl $209
  10240b:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102410:	e9 94 f7 ff ff       	jmp    101ba9 <__alltraps>

00102415 <vector210>:
.globl vector210
vector210:
  pushl $0
  102415:	6a 00                	push   $0x0
  pushl $210
  102417:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10241c:	e9 88 f7 ff ff       	jmp    101ba9 <__alltraps>

00102421 <vector211>:
.globl vector211
vector211:
  pushl $0
  102421:	6a 00                	push   $0x0
  pushl $211
  102423:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102428:	e9 7c f7 ff ff       	jmp    101ba9 <__alltraps>

0010242d <vector212>:
.globl vector212
vector212:
  pushl $0
  10242d:	6a 00                	push   $0x0
  pushl $212
  10242f:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102434:	e9 70 f7 ff ff       	jmp    101ba9 <__alltraps>

00102439 <vector213>:
.globl vector213
vector213:
  pushl $0
  102439:	6a 00                	push   $0x0
  pushl $213
  10243b:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102440:	e9 64 f7 ff ff       	jmp    101ba9 <__alltraps>

00102445 <vector214>:
.globl vector214
vector214:
  pushl $0
  102445:	6a 00                	push   $0x0
  pushl $214
  102447:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10244c:	e9 58 f7 ff ff       	jmp    101ba9 <__alltraps>

00102451 <vector215>:
.globl vector215
vector215:
  pushl $0
  102451:	6a 00                	push   $0x0
  pushl $215
  102453:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102458:	e9 4c f7 ff ff       	jmp    101ba9 <__alltraps>

0010245d <vector216>:
.globl vector216
vector216:
  pushl $0
  10245d:	6a 00                	push   $0x0
  pushl $216
  10245f:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102464:	e9 40 f7 ff ff       	jmp    101ba9 <__alltraps>

00102469 <vector217>:
.globl vector217
vector217:
  pushl $0
  102469:	6a 00                	push   $0x0
  pushl $217
  10246b:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102470:	e9 34 f7 ff ff       	jmp    101ba9 <__alltraps>

00102475 <vector218>:
.globl vector218
vector218:
  pushl $0
  102475:	6a 00                	push   $0x0
  pushl $218
  102477:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  10247c:	e9 28 f7 ff ff       	jmp    101ba9 <__alltraps>

00102481 <vector219>:
.globl vector219
vector219:
  pushl $0
  102481:	6a 00                	push   $0x0
  pushl $219
  102483:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102488:	e9 1c f7 ff ff       	jmp    101ba9 <__alltraps>

0010248d <vector220>:
.globl vector220
vector220:
  pushl $0
  10248d:	6a 00                	push   $0x0
  pushl $220
  10248f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102494:	e9 10 f7 ff ff       	jmp    101ba9 <__alltraps>

00102499 <vector221>:
.globl vector221
vector221:
  pushl $0
  102499:	6a 00                	push   $0x0
  pushl $221
  10249b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1024a0:	e9 04 f7 ff ff       	jmp    101ba9 <__alltraps>

001024a5 <vector222>:
.globl vector222
vector222:
  pushl $0
  1024a5:	6a 00                	push   $0x0
  pushl $222
  1024a7:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1024ac:	e9 f8 f6 ff ff       	jmp    101ba9 <__alltraps>

001024b1 <vector223>:
.globl vector223
vector223:
  pushl $0
  1024b1:	6a 00                	push   $0x0
  pushl $223
  1024b3:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1024b8:	e9 ec f6 ff ff       	jmp    101ba9 <__alltraps>

001024bd <vector224>:
.globl vector224
vector224:
  pushl $0
  1024bd:	6a 00                	push   $0x0
  pushl $224
  1024bf:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1024c4:	e9 e0 f6 ff ff       	jmp    101ba9 <__alltraps>

001024c9 <vector225>:
.globl vector225
vector225:
  pushl $0
  1024c9:	6a 00                	push   $0x0
  pushl $225
  1024cb:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1024d0:	e9 d4 f6 ff ff       	jmp    101ba9 <__alltraps>

001024d5 <vector226>:
.globl vector226
vector226:
  pushl $0
  1024d5:	6a 00                	push   $0x0
  pushl $226
  1024d7:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1024dc:	e9 c8 f6 ff ff       	jmp    101ba9 <__alltraps>

001024e1 <vector227>:
.globl vector227
vector227:
  pushl $0
  1024e1:	6a 00                	push   $0x0
  pushl $227
  1024e3:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1024e8:	e9 bc f6 ff ff       	jmp    101ba9 <__alltraps>

001024ed <vector228>:
.globl vector228
vector228:
  pushl $0
  1024ed:	6a 00                	push   $0x0
  pushl $228
  1024ef:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1024f4:	e9 b0 f6 ff ff       	jmp    101ba9 <__alltraps>

001024f9 <vector229>:
.globl vector229
vector229:
  pushl $0
  1024f9:	6a 00                	push   $0x0
  pushl $229
  1024fb:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102500:	e9 a4 f6 ff ff       	jmp    101ba9 <__alltraps>

00102505 <vector230>:
.globl vector230
vector230:
  pushl $0
  102505:	6a 00                	push   $0x0
  pushl $230
  102507:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  10250c:	e9 98 f6 ff ff       	jmp    101ba9 <__alltraps>

00102511 <vector231>:
.globl vector231
vector231:
  pushl $0
  102511:	6a 00                	push   $0x0
  pushl $231
  102513:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102518:	e9 8c f6 ff ff       	jmp    101ba9 <__alltraps>

0010251d <vector232>:
.globl vector232
vector232:
  pushl $0
  10251d:	6a 00                	push   $0x0
  pushl $232
  10251f:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102524:	e9 80 f6 ff ff       	jmp    101ba9 <__alltraps>

00102529 <vector233>:
.globl vector233
vector233:
  pushl $0
  102529:	6a 00                	push   $0x0
  pushl $233
  10252b:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102530:	e9 74 f6 ff ff       	jmp    101ba9 <__alltraps>

00102535 <vector234>:
.globl vector234
vector234:
  pushl $0
  102535:	6a 00                	push   $0x0
  pushl $234
  102537:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  10253c:	e9 68 f6 ff ff       	jmp    101ba9 <__alltraps>

00102541 <vector235>:
.globl vector235
vector235:
  pushl $0
  102541:	6a 00                	push   $0x0
  pushl $235
  102543:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102548:	e9 5c f6 ff ff       	jmp    101ba9 <__alltraps>

0010254d <vector236>:
.globl vector236
vector236:
  pushl $0
  10254d:	6a 00                	push   $0x0
  pushl $236
  10254f:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102554:	e9 50 f6 ff ff       	jmp    101ba9 <__alltraps>

00102559 <vector237>:
.globl vector237
vector237:
  pushl $0
  102559:	6a 00                	push   $0x0
  pushl $237
  10255b:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102560:	e9 44 f6 ff ff       	jmp    101ba9 <__alltraps>

00102565 <vector238>:
.globl vector238
vector238:
  pushl $0
  102565:	6a 00                	push   $0x0
  pushl $238
  102567:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  10256c:	e9 38 f6 ff ff       	jmp    101ba9 <__alltraps>

00102571 <vector239>:
.globl vector239
vector239:
  pushl $0
  102571:	6a 00                	push   $0x0
  pushl $239
  102573:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102578:	e9 2c f6 ff ff       	jmp    101ba9 <__alltraps>

0010257d <vector240>:
.globl vector240
vector240:
  pushl $0
  10257d:	6a 00                	push   $0x0
  pushl $240
  10257f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102584:	e9 20 f6 ff ff       	jmp    101ba9 <__alltraps>

00102589 <vector241>:
.globl vector241
vector241:
  pushl $0
  102589:	6a 00                	push   $0x0
  pushl $241
  10258b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102590:	e9 14 f6 ff ff       	jmp    101ba9 <__alltraps>

00102595 <vector242>:
.globl vector242
vector242:
  pushl $0
  102595:	6a 00                	push   $0x0
  pushl $242
  102597:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  10259c:	e9 08 f6 ff ff       	jmp    101ba9 <__alltraps>

001025a1 <vector243>:
.globl vector243
vector243:
  pushl $0
  1025a1:	6a 00                	push   $0x0
  pushl $243
  1025a3:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1025a8:	e9 fc f5 ff ff       	jmp    101ba9 <__alltraps>

001025ad <vector244>:
.globl vector244
vector244:
  pushl $0
  1025ad:	6a 00                	push   $0x0
  pushl $244
  1025af:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1025b4:	e9 f0 f5 ff ff       	jmp    101ba9 <__alltraps>

001025b9 <vector245>:
.globl vector245
vector245:
  pushl $0
  1025b9:	6a 00                	push   $0x0
  pushl $245
  1025bb:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1025c0:	e9 e4 f5 ff ff       	jmp    101ba9 <__alltraps>

001025c5 <vector246>:
.globl vector246
vector246:
  pushl $0
  1025c5:	6a 00                	push   $0x0
  pushl $246
  1025c7:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1025cc:	e9 d8 f5 ff ff       	jmp    101ba9 <__alltraps>

001025d1 <vector247>:
.globl vector247
vector247:
  pushl $0
  1025d1:	6a 00                	push   $0x0
  pushl $247
  1025d3:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1025d8:	e9 cc f5 ff ff       	jmp    101ba9 <__alltraps>

001025dd <vector248>:
.globl vector248
vector248:
  pushl $0
  1025dd:	6a 00                	push   $0x0
  pushl $248
  1025df:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1025e4:	e9 c0 f5 ff ff       	jmp    101ba9 <__alltraps>

001025e9 <vector249>:
.globl vector249
vector249:
  pushl $0
  1025e9:	6a 00                	push   $0x0
  pushl $249
  1025eb:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1025f0:	e9 b4 f5 ff ff       	jmp    101ba9 <__alltraps>

001025f5 <vector250>:
.globl vector250
vector250:
  pushl $0
  1025f5:	6a 00                	push   $0x0
  pushl $250
  1025f7:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1025fc:	e9 a8 f5 ff ff       	jmp    101ba9 <__alltraps>

00102601 <vector251>:
.globl vector251
vector251:
  pushl $0
  102601:	6a 00                	push   $0x0
  pushl $251
  102603:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102608:	e9 9c f5 ff ff       	jmp    101ba9 <__alltraps>

0010260d <vector252>:
.globl vector252
vector252:
  pushl $0
  10260d:	6a 00                	push   $0x0
  pushl $252
  10260f:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102614:	e9 90 f5 ff ff       	jmp    101ba9 <__alltraps>

00102619 <vector253>:
.globl vector253
vector253:
  pushl $0
  102619:	6a 00                	push   $0x0
  pushl $253
  10261b:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102620:	e9 84 f5 ff ff       	jmp    101ba9 <__alltraps>

00102625 <vector254>:
.globl vector254
vector254:
  pushl $0
  102625:	6a 00                	push   $0x0
  pushl $254
  102627:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  10262c:	e9 78 f5 ff ff       	jmp    101ba9 <__alltraps>

00102631 <vector255>:
.globl vector255
vector255:
  pushl $0
  102631:	6a 00                	push   $0x0
  pushl $255
  102633:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102638:	e9 6c f5 ff ff       	jmp    101ba9 <__alltraps>

0010263d <set_page_ref>:
page_ref(struct Page *page) {
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
  10263d:	55                   	push   %ebp
  10263e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102640:	8b 45 08             	mov    0x8(%ebp),%eax
  102643:	8b 55 0c             	mov    0xc(%ebp),%edx
  102646:	89 10                	mov    %edx,(%eax)
}
  102648:	5d                   	pop    %ebp
  102649:	c3                   	ret    

0010264a <buddy_init>:
static unsigned long long buddy_type[buddy_type_size];
#define free_list(n) (free_area_list[n].free_list)
#define nr_free(n) (free_area_list[n].nr_free)

static void
buddy_init(void) {
  10264a:	55                   	push   %ebp
  10264b:	89 e5                	mov    %esp,%ebp
  10264d:	83 ec 28             	sub    $0x28,%esp
    cprintf("buddy_init\n");
  102650:	c7 04 24 70 73 10 00 	movl   $0x107370,(%esp)
  102657:	e8 ec dc ff ff       	call   100348 <cprintf>
    unsigned i=0;
  10265c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    buddy_type[0]=1;
  102663:	c7 05 80 ce 11 00 01 	movl   $0x1,0x11ce80
  10266a:	00 00 00 
  10266d:	c7 05 84 ce 11 00 00 	movl   $0x0,0x11ce84
  102674:	00 00 00 
    for(;i<buddy_type_size;i++){
  102677:	eb 75                	jmp    1026ee <buddy_init+0xa4>
        list_init(&(free_list(i)));  
  102679:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10267c:	89 d0                	mov    %edx,%eax
  10267e:	01 c0                	add    %eax,%eax
  102680:	01 d0                	add    %edx,%eax
  102682:	c1 e0 02             	shl    $0x2,%eax
  102685:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  10268a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10268d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102690:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102693:	89 50 04             	mov    %edx,0x4(%eax)
  102696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102699:	8b 50 04             	mov    0x4(%eax),%edx
  10269c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10269f:	89 10                	mov    %edx,(%eax)
        nr_free(i) = 0;
  1026a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1026a4:	89 d0                	mov    %edx,%eax
  1026a6:	01 c0                	add    %eax,%eax
  1026a8:	01 d0                	add    %edx,%eax
  1026aa:	c1 e0 02             	shl    $0x2,%eax
  1026ad:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  1026b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        if(i!=0){
  1026b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1026bd:	74 2b                	je     1026ea <buddy_init+0xa0>
            buddy_type[i]=buddy_type[i-1]<<1; 
  1026bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1026c2:	83 e8 01             	sub    $0x1,%eax
  1026c5:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  1026cc:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  1026d3:	0f a4 c2 01          	shld   $0x1,%eax,%edx
  1026d7:	01 c0                	add    %eax,%eax
  1026d9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  1026dc:	89 04 cd 80 ce 11 00 	mov    %eax,0x11ce80(,%ecx,8)
  1026e3:	89 14 cd 84 ce 11 00 	mov    %edx,0x11ce84(,%ecx,8)
static void
buddy_init(void) {
    cprintf("buddy_init\n");
    unsigned i=0;
    buddy_type[0]=1;
    for(;i<buddy_type_size;i++){
  1026ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1026ee:	83 7d f4 12          	cmpl   $0x12,-0xc(%ebp)
  1026f2:	76 85                	jbe    102679 <buddy_init+0x2f>
        nr_free(i) = 0;
        if(i!=0){
            buddy_type[i]=buddy_type[i-1]<<1; 
        }
    }
}
  1026f4:	c9                   	leave  
  1026f5:	c3                   	ret    

001026f6 <find_list>:
static size_t find_list(size_t n){
  1026f6:	55                   	push   %ebp
  1026f7:	89 e5                	mov    %esp,%ebp
  1026f9:	53                   	push   %ebx
  1026fa:	83 ec 14             	sub    $0x14,%esp
    size_t i=0;
  1026fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for(;i<buddy_type_size;i++){
  102704:	eb 2e                	jmp    102734 <find_list+0x3e>
        if(buddy_type[i]>=n)
  102706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102709:	8b 0c c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%ecx
  102710:	8b 1c c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%ebx
  102717:	8b 45 08             	mov    0x8(%ebp),%eax
  10271a:	ba 00 00 00 00       	mov    $0x0,%edx
  10271f:	39 d3                	cmp    %edx,%ebx
  102721:	72 0d                	jb     102730 <find_list+0x3a>
  102723:	39 d3                	cmp    %edx,%ebx
  102725:	77 04                	ja     10272b <find_list+0x35>
  102727:	39 c1                	cmp    %eax,%ecx
  102729:	72 05                	jb     102730 <find_list+0x3a>
        return i;
  10272b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10272e:	eb 0f                	jmp    10273f <find_list+0x49>
        }
    }
}
static size_t find_list(size_t n){
    size_t i=0;
    for(;i<buddy_type_size;i++){
  102730:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  102734:	83 7d f4 12          	cmpl   $0x12,-0xc(%ebp)
  102738:	76 cc                	jbe    102706 <find_list+0x10>
        if(buddy_type[i]>=n)
        return i;
    }
    return -1;
  10273a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10273f:	83 c4 14             	add    $0x14,%esp
  102742:	5b                   	pop    %ebx
  102743:	5d                   	pop    %ebp
  102744:	c3                   	ret    

00102745 <buddy_get_page_init>:
static int buddy_get_page_init(size_t n){ 
  102745:	55                   	push   %ebp
  102746:	89 e5                	mov    %esp,%ebp
  102748:	56                   	push   %esi
  102749:	53                   	push   %ebx
  10274a:	83 ec 10             	sub    $0x10,%esp
    if(n==0)
  10274d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102751:	75 07                	jne    10275a <buddy_get_page_init+0x15>
        return -2;
  102753:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  102758:	eb 6f                	jmp    1027c9 <buddy_get_page_init+0x84>
    int i;
    for(i=0;i<buddy_type_size;i++){
  10275a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102761:	eb 5b                	jmp    1027be <buddy_get_page_init+0x79>
        if(buddy_type[i]==n){
  102763:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102766:	8b 0c c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%ecx
  10276d:	8b 1c c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%ebx
  102774:	8b 45 08             	mov    0x8(%ebp),%eax
  102777:	ba 00 00 00 00       	mov    $0x0,%edx
  10277c:	89 de                	mov    %ebx,%esi
  10277e:	31 d6                	xor    %edx,%esi
  102780:	31 c8                	xor    %ecx,%eax
  102782:	09 f0                	or     %esi,%eax
  102784:	85 c0                	test   %eax,%eax
  102786:	75 05                	jne    10278d <buddy_get_page_init+0x48>
            return i;
  102788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10278b:	eb 3c                	jmp    1027c9 <buddy_get_page_init+0x84>
        }else if(buddy_type[i]>n){
  10278d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102790:	8b 0c c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%ecx
  102797:	8b 1c c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%ebx
  10279e:	8b 45 08             	mov    0x8(%ebp),%eax
  1027a1:	ba 00 00 00 00       	mov    $0x0,%edx
  1027a6:	39 d3                	cmp    %edx,%ebx
  1027a8:	72 10                	jb     1027ba <buddy_get_page_init+0x75>
  1027aa:	39 d3                	cmp    %edx,%ebx
  1027ac:	77 04                	ja     1027b2 <buddy_get_page_init+0x6d>
  1027ae:	39 c1                	cmp    %eax,%ecx
  1027b0:	76 08                	jbe    1027ba <buddy_get_page_init+0x75>
            return i-1;
  1027b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1027b5:	83 e8 01             	sub    $0x1,%eax
  1027b8:	eb 0f                	jmp    1027c9 <buddy_get_page_init+0x84>
}
static int buddy_get_page_init(size_t n){ 
    if(n==0)
        return -2;
    int i;
    for(i=0;i<buddy_type_size;i++){
  1027ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1027be:	83 7d f4 12          	cmpl   $0x12,-0xc(%ebp)
  1027c2:	7e 9f                	jle    102763 <buddy_get_page_init+0x1e>
            return i;
        }else if(buddy_type[i]>n){
            return i-1;
        }
    }
    return -1;
  1027c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1027c9:	83 c4 10             	add    $0x10,%esp
  1027cc:	5b                   	pop    %ebx
  1027cd:	5e                   	pop    %esi
  1027ce:	5d                   	pop    %ebp
  1027cf:	c3                   	ret    

001027d0 <buddy_init_memmap>:
static void
buddy_init_memmap(struct Page *base,size_t n) {
  1027d0:	55                   	push   %ebp
  1027d1:	89 e5                	mov    %esp,%ebp
  1027d3:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  1027d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1027da:	75 24                	jne    102800 <buddy_init_memmap+0x30>
  1027dc:	c7 44 24 0c 7c 73 10 	movl   $0x10737c,0xc(%esp)
  1027e3:	00 
  1027e4:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  1027eb:	00 
  1027ec:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  1027f3:	00 
  1027f4:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  1027fb:	e8 18 e4 ff ff       	call   100c18 <__panic>
    struct Page *p = base;
  102800:	8b 45 08             	mov    0x8(%ebp),%eax
  102803:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++){
  102806:	eb 7d                	jmp    102885 <buddy_init_memmap+0xb5>
        assert(PageReserved(p));
  102808:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10280b:	83 c0 04             	add    $0x4,%eax
  10280e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102815:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102818:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10281b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10281e:	0f a3 10             	bt     %edx,(%eax)
  102821:	19 c0                	sbb    %eax,%eax
  102823:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102826:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10282a:	0f 95 c0             	setne  %al
  10282d:	0f b6 c0             	movzbl %al,%eax
  102830:	85 c0                	test   %eax,%eax
  102832:	75 24                	jne    102858 <buddy_init_memmap+0x88>
  102834:	c7 44 24 0c ab 73 10 	movl   $0x1073ab,0xc(%esp)
  10283b:	00 
  10283c:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  102843:	00 
  102844:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  10284b:	00 
  10284c:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  102853:	e8 c0 e3 ff ff       	call   100c18 <__panic>
        p->flags = p->property = 0;
  102858:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10285b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  102862:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102865:	8b 50 08             	mov    0x8(%eax),%edx
  102868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10286b:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0); 
  10286e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102875:	00 
  102876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102879:	89 04 24             	mov    %eax,(%esp)
  10287c:	e8 bc fd ff ff       	call   10263d <set_page_ref>
}
static void
buddy_init_memmap(struct Page *base,size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++){
  102881:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102885:	8b 55 0c             	mov    0xc(%ebp),%edx
  102888:	89 d0                	mov    %edx,%eax
  10288a:	c1 e0 02             	shl    $0x2,%eax
  10288d:	01 d0                	add    %edx,%eax
  10288f:	c1 e0 02             	shl    $0x2,%eax
  102892:	89 c2                	mov    %eax,%edx
  102894:	8b 45 08             	mov    0x8(%ebp),%eax
  102897:	01 d0                	add    %edx,%eax
  102899:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10289c:	0f 85 66 ff ff ff    	jne    102808 <buddy_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0); 
    }
    int index_type;
    SetPageProperty(base);
  1028a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1028a5:	83 c0 04             	add    $0x4,%eax
  1028a8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  1028af:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1028b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1028b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1028b8:	0f ab 10             	bts    %edx,(%eax)
    while( (index_type=buddy_get_page_init(n)) >= 0 ){
  1028bb:	e9 e6 00 00 00       	jmp    1029a6 <buddy_init_memmap+0x1d6>
        nr_free(index_type)= 1; 
  1028c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1028c3:	89 d0                	mov    %edx,%eax
  1028c5:	01 c0                	add    %eax,%eax
  1028c7:	01 d0                	add    %edx,%eax
  1028c9:	c1 e0 02             	shl    $0x2,%eax
  1028cc:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  1028d1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	//cprintf("%d\n",index_type);
        list_add_before(&(free_list(index_type)),&(base->page_link));
  1028d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1028db:	8d 48 0c             	lea    0xc(%eax),%ecx
  1028de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1028e1:	89 d0                	mov    %edx,%eax
  1028e3:	01 c0                	add    %eax,%eax
  1028e5:	01 d0                	add    %edx,%eax
  1028e7:	c1 e0 02             	shl    $0x2,%eax
  1028ea:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  1028ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1028f2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1028f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1028f8:	8b 00                	mov    (%eax),%eax
  1028fa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1028fd:	89 55 d0             	mov    %edx,-0x30(%ebp)
  102900:	89 45 cc             	mov    %eax,-0x34(%ebp)
  102903:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102906:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102909:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10290c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10290f:	89 10                	mov    %edx,(%eax)
  102911:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102914:	8b 10                	mov    (%eax),%edx
  102916:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102919:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10291c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10291f:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102922:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102925:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102928:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10292b:	89 10                	mov    %edx,(%eax)
        base->property = buddy_type[index_type];
  10292d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102930:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  102937:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  10293e:	89 c2                	mov    %eax,%edx
  102940:	8b 45 08             	mov    0x8(%ebp),%eax
  102943:	89 50 08             	mov    %edx,0x8(%eax)
        base=base+buddy_type[index_type];
  102946:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102949:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  102950:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  102957:	89 c2                	mov    %eax,%edx
  102959:	89 d0                	mov    %edx,%eax
  10295b:	c1 e0 02             	shl    $0x2,%eax
  10295e:	01 d0                	add    %edx,%eax
  102960:	c1 e0 02             	shl    $0x2,%eax
  102963:	01 45 08             	add    %eax,0x8(%ebp)
	cprintf("%d %d\n",n,buddy_type[index_type]);
  102966:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102969:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  102970:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  102977:	89 44 24 08          	mov    %eax,0x8(%esp)
  10297b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10297f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102982:	89 44 24 04          	mov    %eax,0x4(%esp)
  102986:	c7 04 24 bb 73 10 00 	movl   $0x1073bb,(%esp)
  10298d:	e8 b6 d9 ff ff       	call   100348 <cprintf>
        n -= buddy_type[index_type]; 
  102992:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102995:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  10299c:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  1029a3:	29 45 0c             	sub    %eax,0xc(%ebp)
        p->flags = p->property = 0;
        set_page_ref(p, 0); 
    }
    int index_type;
    SetPageProperty(base);
    while( (index_type=buddy_get_page_init(n)) >= 0 ){
  1029a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1029a9:	89 04 24             	mov    %eax,(%esp)
  1029ac:	e8 94 fd ff ff       	call   102745 <buddy_get_page_init>
  1029b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1029b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1029b8:	0f 89 02 ff ff ff    	jns    1028c0 <buddy_init_memmap+0xf0>
        base->property = buddy_type[index_type];
        base=base+buddy_type[index_type];
	cprintf("%d %d\n",n,buddy_type[index_type]);
        n -= buddy_type[index_type]; 
    }
}
  1029be:	c9                   	leave  
  1029bf:	c3                   	ret    

001029c0 <buddy_alloc_pages>:
static struct Page *
buddy_alloc_pages(size_t n) {
  1029c0:	55                   	push   %ebp
  1029c1:	89 e5                	mov    %esp,%ebp
  1029c3:	53                   	push   %ebx
  1029c4:	83 ec 74             	sub    $0x74,%esp
    assert(n > 0);
  1029c7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1029cb:	75 24                	jne    1029f1 <buddy_alloc_pages+0x31>
  1029cd:	c7 44 24 0c 7c 73 10 	movl   $0x10737c,0xc(%esp)
  1029d4:	00 
  1029d5:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  1029dc:	00 
  1029dd:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  1029e4:	00 
  1029e5:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  1029ec:	e8 27 e2 ff ff       	call   100c18 <__panic>
    if(n>buddy_type[buddy_type_size-1]){
  1029f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1029f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  1029f9:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  1029fe:	8b 15 14 cf 11 00    	mov    0x11cf14,%edx
  102a04:	39 d3                	cmp    %edx,%ebx
  102a06:	72 12                	jb     102a1a <buddy_alloc_pages+0x5a>
  102a08:	39 d3                	cmp    %edx,%ebx
  102a0a:	77 04                	ja     102a10 <buddy_alloc_pages+0x50>
  102a0c:	39 c1                	cmp    %eax,%ecx
  102a0e:	76 0a                	jbe    102a1a <buddy_alloc_pages+0x5a>
        return NULL;
  102a10:	b8 00 00 00 00       	mov    $0x0,%eax
  102a15:	e9 22 03 00 00       	jmp    102d3c <buddy_alloc_pages+0x37c>
    }
    struct Page *page = NULL;
  102a1a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    size_t index=find_list(n);
  102a21:	8b 45 08             	mov    0x8(%ebp),%eax
  102a24:	89 04 24             	mov    %eax,(%esp)
  102a27:	e8 ca fc ff ff       	call   1026f6 <find_list>
  102a2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    list_entry_t *le = &free_list(index);
  102a2f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102a32:	89 d0                	mov    %edx,%eax
  102a34:	01 c0                	add    %eax,%eax
  102a36:	01 d0                	add    %edx,%eax
  102a38:	c1 e0 02             	shl    $0x2,%eax
  102a3b:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t i=index;
  102a43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102a46:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(le==NULL){
  102a49:	eb 18                	jmp    102a63 <buddy_alloc_pages+0xa3>
        le=&free_list(++i);
  102a4b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  102a4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102a52:	89 d0                	mov    %edx,%eax
  102a54:	01 c0                	add    %eax,%eax
  102a56:	01 d0                	add    %edx,%eax
  102a58:	c1 e0 02             	shl    $0x2,%eax
  102a5b:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    struct Page *page = NULL;
    size_t index=find_list(n);
    list_entry_t *le = &free_list(index);
    size_t i=index;
    while(le==NULL){
  102a63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102a67:	74 e2                	je     102a4b <buddy_alloc_pages+0x8b>
        le=&free_list(++i);
    } 
    page = le2page(le, page_link);
  102a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a6c:	83 e8 0c             	sub    $0xc,%eax
  102a6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(page!=NULL){
  102a72:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102a76:	0f 84 bd 02 00 00    	je     102d39 <buddy_alloc_pages+0x379>
        if (n<buddy_type[index]&&n>buddy_type[index]/2) { 
  102a7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  102a7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  102a84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102a87:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  102a8e:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  102a95:	39 d3                	cmp    %edx,%ebx
  102a97:	0f 87 92 00 00 00    	ja     102b2f <buddy_alloc_pages+0x16f>
  102a9d:	39 d3                	cmp    %edx,%ebx
  102a9f:	72 08                	jb     102aa9 <buddy_alloc_pages+0xe9>
  102aa1:	39 c1                	cmp    %eax,%ecx
  102aa3:	0f 83 86 00 00 00    	jae    102b2f <buddy_alloc_pages+0x16f>
  102aa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  102aac:	bb 00 00 00 00       	mov    $0x0,%ebx
  102ab1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102ab4:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  102abb:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  102ac2:	0f ac d0 01          	shrd   $0x1,%edx,%eax
  102ac6:	d1 ea                	shr    %edx
  102ac8:	39 d3                	cmp    %edx,%ebx
  102aca:	72 63                	jb     102b2f <buddy_alloc_pages+0x16f>
  102acc:	39 d3                	cmp    %edx,%ebx
  102ace:	77 04                	ja     102ad4 <buddy_alloc_pages+0x114>
  102ad0:	39 c1                	cmp    %eax,%ecx
  102ad2:	76 5b                	jbe    102b2f <buddy_alloc_pages+0x16f>
            list_del(&(page->page_link));
  102ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ad7:	83 c0 0c             	add    $0xc,%eax
  102ada:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102add:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102ae0:	8b 40 04             	mov    0x4(%eax),%eax
  102ae3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ae6:	8b 12                	mov    (%edx),%edx
  102ae8:	89 55 d8             	mov    %edx,-0x28(%ebp)
  102aeb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102aee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102af1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102af4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102af7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102afa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102afd:	89 10                	mov    %edx,(%eax)
            nr_free(index) -=1;
  102aff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102b02:	89 d0                	mov    %edx,%eax
  102b04:	01 c0                	add    %eax,%eax
  102b06:	01 d0                	add    %edx,%eax
  102b08:	c1 e0 02             	shl    $0x2,%eax
  102b0b:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102b10:	8b 40 08             	mov    0x8(%eax),%eax
  102b13:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102b16:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102b19:	89 d0                	mov    %edx,%eax
  102b1b:	01 c0                	add    %eax,%eax
  102b1d:	01 d0                	add    %edx,%eax
  102b1f:	c1 e0 02             	shl    $0x2,%eax
  102b22:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102b27:	89 48 08             	mov    %ecx,0x8(%eax)
  102b2a:	e9 f1 01 00 00       	jmp    102d20 <buddy_alloc_pages+0x360>
        }
        else {
            size_t i=index;
  102b2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102b32:	89 45 ec             	mov    %eax,-0x14(%ebp)
            while(n<buddy_type[i]/2){
  102b35:	e9 5d 01 00 00       	jmp    102c97 <buddy_alloc_pages+0x2d7>
                struct  Page *p=page+buddy_type[i]/2;
  102b3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102b3d:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  102b44:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  102b4b:	0f ac d0 01          	shrd   $0x1,%edx,%eax
  102b4f:	d1 ea                	shr    %edx
  102b51:	89 c2                	mov    %eax,%edx
  102b53:	89 d0                	mov    %edx,%eax
  102b55:	c1 e0 02             	shl    $0x2,%eax
  102b58:	01 d0                	add    %edx,%eax
  102b5a:	c1 e0 02             	shl    $0x2,%eax
  102b5d:	89 c2                	mov    %eax,%edx
  102b5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b62:	01 d0                	add    %edx,%eax
  102b64:	89 45 e0             	mov    %eax,-0x20(%ebp)
                p->property = page->property/2;
  102b67:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b6a:	8b 40 08             	mov    0x8(%eax),%eax
  102b6d:	d1 e8                	shr    %eax
  102b6f:	89 c2                	mov    %eax,%edx
  102b71:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102b74:	89 50 08             	mov    %edx,0x8(%eax)
                page->property=page->property/2;
  102b77:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b7a:	8b 40 08             	mov    0x8(%eax),%eax
  102b7d:	d1 e8                	shr    %eax
  102b7f:	89 c2                	mov    %eax,%edx
  102b81:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b84:	89 50 08             	mov    %edx,0x8(%eax)
                nr_free(i)-=1;
  102b87:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102b8a:	89 d0                	mov    %edx,%eax
  102b8c:	01 c0                	add    %eax,%eax
  102b8e:	01 d0                	add    %edx,%eax
  102b90:	c1 e0 02             	shl    $0x2,%eax
  102b93:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102b98:	8b 40 08             	mov    0x8(%eax),%eax
  102b9b:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102b9e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102ba1:	89 d0                	mov    %edx,%eax
  102ba3:	01 c0                	add    %eax,%eax
  102ba5:	01 d0                	add    %edx,%eax
  102ba7:	c1 e0 02             	shl    $0x2,%eax
  102baa:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102baf:	89 48 08             	mov    %ecx,0x8(%eax)
                list_add_before(&free_list(i-1),&(p->page_link));
  102bb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102bb5:	8d 48 0c             	lea    0xc(%eax),%ecx
  102bb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102bbb:	8d 50 ff             	lea    -0x1(%eax),%edx
  102bbe:	89 d0                	mov    %edx,%eax
  102bc0:	01 c0                	add    %eax,%eax
  102bc2:	01 d0                	add    %edx,%eax
  102bc4:	c1 e0 02             	shl    $0x2,%eax
  102bc7:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102bcc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102bcf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102bd2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102bd5:	8b 00                	mov    (%eax),%eax
  102bd7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102bda:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102bdd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  102be0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102be3:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102be6:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102be9:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102bec:	89 10                	mov    %edx,(%eax)
  102bee:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102bf1:	8b 10                	mov    (%eax),%edx
  102bf3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102bf6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102bf9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102bfc:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102bff:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102c02:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102c05:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102c08:	89 10                	mov    %edx,(%eax)
                list_add_before(&free_list(i-1),&(page->page_link));
  102c0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c0d:	8d 48 0c             	lea    0xc(%eax),%ecx
  102c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102c13:	8d 50 ff             	lea    -0x1(%eax),%edx
  102c16:	89 d0                	mov    %edx,%eax
  102c18:	01 c0                	add    %eax,%eax
  102c1a:	01 d0                	add    %edx,%eax
  102c1c:	c1 e0 02             	shl    $0x2,%eax
  102c1f:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102c24:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102c27:	89 4d b8             	mov    %ecx,-0x48(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102c2a:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102c2d:	8b 00                	mov    (%eax),%eax
  102c2f:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102c32:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  102c35:	89 45 b0             	mov    %eax,-0x50(%ebp)
  102c38:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102c3b:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102c3e:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102c41:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102c44:	89 10                	mov    %edx,(%eax)
  102c46:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102c49:	8b 10                	mov    (%eax),%edx
  102c4b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102c4e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102c51:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102c54:	8b 55 ac             	mov    -0x54(%ebp),%edx
  102c57:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102c5a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102c5d:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102c60:	89 10                	mov    %edx,(%eax)
                nr_free(i-1)+=2;
  102c62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102c65:	8d 50 ff             	lea    -0x1(%eax),%edx
  102c68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102c6b:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102c6e:	89 c8                	mov    %ecx,%eax
  102c70:	01 c0                	add    %eax,%eax
  102c72:	01 c8                	add    %ecx,%eax
  102c74:	c1 e0 02             	shl    $0x2,%eax
  102c77:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102c7c:	8b 40 08             	mov    0x8(%eax),%eax
  102c7f:	8d 48 02             	lea    0x2(%eax),%ecx
  102c82:	89 d0                	mov    %edx,%eax
  102c84:	01 c0                	add    %eax,%eax
  102c86:	01 d0                	add    %edx,%eax
  102c88:	c1 e0 02             	shl    $0x2,%eax
  102c8b:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102c90:	89 48 08             	mov    %ecx,0x8(%eax)
                i--;   
  102c93:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
            list_del(&(page->page_link));
            nr_free(index) -=1;
        }
        else {
            size_t i=index;
            while(n<buddy_type[i]/2){
  102c97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  102c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  102c9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ca2:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  102ca9:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  102cb0:	0f ac d0 01          	shrd   $0x1,%edx,%eax
  102cb4:	d1 ea                	shr    %edx
  102cb6:	39 d3                	cmp    %edx,%ebx
  102cb8:	0f 82 7c fe ff ff    	jb     102b3a <buddy_alloc_pages+0x17a>
  102cbe:	39 d3                	cmp    %edx,%ebx
  102cc0:	77 08                	ja     102cca <buddy_alloc_pages+0x30a>
  102cc2:	39 c1                	cmp    %eax,%ecx
  102cc4:	0f 82 70 fe ff ff    	jb     102b3a <buddy_alloc_pages+0x17a>
                list_add_before(&free_list(i-1),&(p->page_link));
                list_add_before(&free_list(i-1),&(page->page_link));
                nr_free(i-1)+=2;
                i--;   
            }
            list_del(&(page->page_link));
  102cca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ccd:	83 c0 0c             	add    $0xc,%eax
  102cd0:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102cd3:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102cd6:	8b 40 04             	mov    0x4(%eax),%eax
  102cd9:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102cdc:	8b 12                	mov    (%edx),%edx
  102cde:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102ce1:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102ce4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102ce7:	8b 55 a0             	mov    -0x60(%ebp),%edx
  102cea:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102ced:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102cf0:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102cf3:	89 10                	mov    %edx,(%eax)
            nr_free(i) -=1;
  102cf5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102cf8:	89 d0                	mov    %edx,%eax
  102cfa:	01 c0                	add    %eax,%eax
  102cfc:	01 d0                	add    %edx,%eax
  102cfe:	c1 e0 02             	shl    $0x2,%eax
  102d01:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102d06:	8b 40 08             	mov    0x8(%eax),%eax
  102d09:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102d0c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102d0f:	89 d0                	mov    %edx,%eax
  102d11:	01 c0                	add    %eax,%eax
  102d13:	01 d0                	add    %edx,%eax
  102d15:	c1 e0 02             	shl    $0x2,%eax
  102d18:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102d1d:	89 48 08             	mov    %ecx,0x8(%eax)
        } 
    ClearPageProperty(page);
  102d20:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d23:	83 c0 04             	add    $0x4,%eax
  102d26:	c7 45 9c 01 00 00 00 	movl   $0x1,-0x64(%ebp)
  102d2d:	89 45 98             	mov    %eax,-0x68(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d30:	8b 45 98             	mov    -0x68(%ebp),%eax
  102d33:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102d36:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  102d39:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
  102d3c:	83 c4 74             	add    $0x74,%esp
  102d3f:	5b                   	pop    %ebx
  102d40:	5d                   	pop    %ebp
  102d41:	c3                   	ret    

00102d42 <buddy_free_pages>:
static void
buddy_free_pages(struct Page *base, size_t n) {
  102d42:	55                   	push   %ebp
  102d43:	89 e5                	mov    %esp,%ebp
  102d45:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102d4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102d4f:	75 24                	jne    102d75 <buddy_free_pages+0x33>
  102d51:	c7 44 24 0c 7c 73 10 	movl   $0x10737c,0xc(%esp)
  102d58:	00 
  102d59:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  102d60:	00 
  102d61:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  102d68:	00 
  102d69:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  102d70:	e8 a3 de ff ff       	call   100c18 <__panic>
    struct Page *p = base;
  102d75:	8b 45 08             	mov    0x8(%ebp),%eax
  102d78:	89 45 f4             	mov    %eax,-0xc(%ebp)
    unsigned index=find_list(n);
  102d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d7e:	89 04 24             	mov    %eax,(%esp)
  102d81:	e8 70 f9 ff ff       	call   1026f6 <find_list>
  102d86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    n=buddy_type[index];
  102d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102d8c:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  102d93:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  102d9a:	89 45 0c             	mov    %eax,0xc(%ebp)
    base->property = n;
  102d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  102da0:	8b 55 0c             	mov    0xc(%ebp),%edx
  102da3:	89 50 08             	mov    %edx,0x8(%eax)
    for (; p != base + n; p ++){ 
  102da6:	e9 9d 00 00 00       	jmp    102e48 <buddy_free_pages+0x106>
        assert(!PageReserved(p) && !PageProperty(p));
  102dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dae:	83 c0 04             	add    $0x4,%eax
  102db1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102db8:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102dbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102dbe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102dc1:	0f a3 10             	bt     %edx,(%eax)
  102dc4:	19 c0                	sbb    %eax,%eax
  102dc6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102dc9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102dcd:	0f 95 c0             	setne  %al
  102dd0:	0f b6 c0             	movzbl %al,%eax
  102dd3:	85 c0                	test   %eax,%eax
  102dd5:	75 2c                	jne    102e03 <buddy_free_pages+0xc1>
  102dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dda:	83 c0 04             	add    $0x4,%eax
  102ddd:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102de4:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102de7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102dea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102ded:	0f a3 10             	bt     %edx,(%eax)
  102df0:	19 c0                	sbb    %eax,%eax
  102df2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    return oldbit != 0;
  102df5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102df9:	0f 95 c0             	setne  %al
  102dfc:	0f b6 c0             	movzbl %al,%eax
  102dff:	85 c0                	test   %eax,%eax
  102e01:	74 24                	je     102e27 <buddy_free_pages+0xe5>
  102e03:	c7 44 24 0c c4 73 10 	movl   $0x1073c4,0xc(%esp)
  102e0a:	00 
  102e0b:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  102e12:	00 
  102e13:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  102e1a:	00 
  102e1b:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  102e22:	e8 f1 dd ff ff       	call   100c18 <__panic>
        p->flags = 0;
  102e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e2a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102e31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102e38:	00 
  102e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e3c:	89 04 24             	mov    %eax,(%esp)
  102e3f:	e8 f9 f7 ff ff       	call   10263d <set_page_ref>
    assert(n > 0);
    struct Page *p = base;
    unsigned index=find_list(n);
    n=buddy_type[index];
    base->property = n;
    for (; p != base + n; p ++){ 
  102e44:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102e48:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e4b:	89 d0                	mov    %edx,%eax
  102e4d:	c1 e0 02             	shl    $0x2,%eax
  102e50:	01 d0                	add    %edx,%eax
  102e52:	c1 e0 02             	shl    $0x2,%eax
  102e55:	89 c2                	mov    %eax,%edx
  102e57:	8b 45 08             	mov    0x8(%ebp),%eax
  102e5a:	01 d0                	add    %edx,%eax
  102e5c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102e5f:	0f 85 46 ff ff ff    	jne    102dab <buddy_free_pages+0x69>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    SetPageProperty(base);
  102e65:	8b 45 08             	mov    0x8(%ebp),%eax
  102e68:	83 c0 04             	add    $0x4,%eax
  102e6b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  102e72:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e75:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102e78:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102e7b:	0f ab 10             	bts    %edx,(%eax)
    list_entry_t *le = list_next(&free_list(index));
  102e7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102e81:	89 d0                	mov    %edx,%eax
  102e83:	01 c0                	add    %eax,%eax
  102e85:	01 d0                	add    %edx,%eax
  102e87:	c1 e0 02             	shl    $0x2,%eax
  102e8a:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102e8f:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102e92:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102e95:	8b 40 04             	mov    0x4(%eax),%eax
  102e98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned i=index;
  102e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102e9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    bool b=0;
  102ea1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    for(;i<buddy_type_size;i++){
  102ea8:	e9 33 02 00 00       	jmp    1030e0 <buddy_free_pages+0x39e>
        while (le != &free_list(i)) {
  102ead:	e9 10 02 00 00       	jmp    1030c2 <buddy_free_pages+0x380>
            p = le2page(le, page_link);
  102eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102eb5:	83 e8 0c             	sub    $0xc,%eax
  102eb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ebe:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102ec1:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102ec4:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
  102ec7:	89 45 f0             	mov    %eax,-0x10(%ebp)
            if (base + base->property == p) {
  102eca:	8b 45 08             	mov    0x8(%ebp),%eax
  102ecd:	8b 50 08             	mov    0x8(%eax),%edx
  102ed0:	89 d0                	mov    %edx,%eax
  102ed2:	c1 e0 02             	shl    $0x2,%eax
  102ed5:	01 d0                	add    %edx,%eax
  102ed7:	c1 e0 02             	shl    $0x2,%eax
  102eda:	89 c2                	mov    %eax,%edx
  102edc:	8b 45 08             	mov    0x8(%ebp),%eax
  102edf:	01 d0                	add    %edx,%eax
  102ee1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102ee4:	0f 85 8f 00 00 00    	jne    102f79 <buddy_free_pages+0x237>
                base->property += p->property;
  102eea:	8b 45 08             	mov    0x8(%ebp),%eax
  102eed:	8b 50 08             	mov    0x8(%eax),%edx
  102ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ef3:	8b 40 08             	mov    0x8(%eax),%eax
  102ef6:	01 c2                	add    %eax,%edx
  102ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  102efb:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(p);
  102efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f01:	83 c0 04             	add    $0x4,%eax
  102f04:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102f0b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102f0e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102f11:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102f14:	0f b3 10             	btr    %edx,(%eax)
                nr_free(i)-=1;
  102f17:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102f1a:	89 d0                	mov    %edx,%eax
  102f1c:	01 c0                	add    %eax,%eax
  102f1e:	01 d0                	add    %edx,%eax
  102f20:	c1 e0 02             	shl    $0x2,%eax
  102f23:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102f28:	8b 40 08             	mov    0x8(%eax),%eax
  102f2b:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102f2e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102f31:	89 d0                	mov    %edx,%eax
  102f33:	01 c0                	add    %eax,%eax
  102f35:	01 d0                	add    %edx,%eax
  102f37:	c1 e0 02             	shl    $0x2,%eax
  102f3a:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102f3f:	89 48 08             	mov    %ecx,0x8(%eax)
                list_del(&(p->page_link));
  102f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f45:	83 c0 0c             	add    $0xc,%eax
  102f48:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102f4b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102f4e:	8b 40 04             	mov    0x4(%eax),%eax
  102f51:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102f54:	8b 12                	mov    (%edx),%edx
  102f56:	89 55 ac             	mov    %edx,-0x54(%ebp)
  102f59:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102f5c:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102f5f:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102f62:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102f65:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102f68:	8b 55 ac             	mov    -0x54(%ebp),%edx
  102f6b:	89 10                	mov    %edx,(%eax)
                b=1;
  102f6d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
                break;
  102f74:	e9 63 01 00 00       	jmp    1030dc <buddy_free_pages+0x39a>
            }
            else if (p + p->property == base) {
  102f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f7c:	8b 50 08             	mov    0x8(%eax),%edx
  102f7f:	89 d0                	mov    %edx,%eax
  102f81:	c1 e0 02             	shl    $0x2,%eax
  102f84:	01 d0                	add    %edx,%eax
  102f86:	c1 e0 02             	shl    $0x2,%eax
  102f89:	89 c2                	mov    %eax,%edx
  102f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f8e:	01 d0                	add    %edx,%eax
  102f90:	3b 45 08             	cmp    0x8(%ebp),%eax
  102f93:	0f 85 95 00 00 00    	jne    10302e <buddy_free_pages+0x2ec>
                p->property += base->property;
  102f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f9c:	8b 50 08             	mov    0x8(%eax),%edx
  102f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  102fa2:	8b 40 08             	mov    0x8(%eax),%eax
  102fa5:	01 c2                	add    %eax,%edx
  102fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102faa:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(base);
  102fad:	8b 45 08             	mov    0x8(%ebp),%eax
  102fb0:	83 c0 04             	add    $0x4,%eax
  102fb3:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  102fba:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102fbd:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102fc0:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102fc3:	0f b3 10             	btr    %edx,(%eax)
                base = p;
  102fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fc9:	89 45 08             	mov    %eax,0x8(%ebp)
                nr_free(i)-=1;
  102fcc:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102fcf:	89 d0                	mov    %edx,%eax
  102fd1:	01 c0                	add    %eax,%eax
  102fd3:	01 d0                	add    %edx,%eax
  102fd5:	c1 e0 02             	shl    $0x2,%eax
  102fd8:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102fdd:	8b 40 08             	mov    0x8(%eax),%eax
  102fe0:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102fe3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102fe6:	89 d0                	mov    %edx,%eax
  102fe8:	01 c0                	add    %eax,%eax
  102fea:	01 d0                	add    %edx,%eax
  102fec:	c1 e0 02             	shl    $0x2,%eax
  102fef:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  102ff4:	89 48 08             	mov    %ecx,0x8(%eax)
                list_del(&(p->page_link));
  102ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ffa:	83 c0 0c             	add    $0xc,%eax
  102ffd:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  103000:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103003:	8b 40 04             	mov    0x4(%eax),%eax
  103006:	8b 55 9c             	mov    -0x64(%ebp),%edx
  103009:	8b 12                	mov    (%edx),%edx
  10300b:	89 55 98             	mov    %edx,-0x68(%ebp)
  10300e:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  103011:	8b 45 98             	mov    -0x68(%ebp),%eax
  103014:	8b 55 94             	mov    -0x6c(%ebp),%edx
  103017:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  10301a:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10301d:	8b 55 98             	mov    -0x68(%ebp),%edx
  103020:	89 10                	mov    %edx,(%eax)
                b=1;
  103022:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
                break;
  103029:	e9 ae 00 00 00       	jmp    1030dc <buddy_free_pages+0x39a>
            }
            if(b){
  10302e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103032:	0f 84 88 00 00 00    	je     1030c0 <buddy_free_pages+0x37e>
                nr_free(i+1) += 1;
  103038:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10303b:	8d 50 01             	lea    0x1(%eax),%edx
  10303e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103041:	8d 48 01             	lea    0x1(%eax),%ecx
  103044:	89 c8                	mov    %ecx,%eax
  103046:	01 c0                	add    %eax,%eax
  103048:	01 c8                	add    %ecx,%eax
  10304a:	c1 e0 02             	shl    $0x2,%eax
  10304d:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  103052:	8b 40 08             	mov    0x8(%eax),%eax
  103055:	8d 48 01             	lea    0x1(%eax),%ecx
  103058:	89 d0                	mov    %edx,%eax
  10305a:	01 c0                	add    %eax,%eax
  10305c:	01 d0                	add    %edx,%eax
  10305e:	c1 e0 02             	shl    $0x2,%eax
  103061:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  103066:	89 48 08             	mov    %ecx,0x8(%eax)
                list_add_before(&free_list(index), &(base->page_link));
  103069:	8b 45 08             	mov    0x8(%ebp),%eax
  10306c:	8d 48 0c             	lea    0xc(%eax),%ecx
  10306f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103072:	89 d0                	mov    %edx,%eax
  103074:	01 c0                	add    %eax,%eax
  103076:	01 d0                	add    %edx,%eax
  103078:	c1 e0 02             	shl    $0x2,%eax
  10307b:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  103080:	89 45 90             	mov    %eax,-0x70(%ebp)
  103083:	89 4d 8c             	mov    %ecx,-0x74(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  103086:	8b 45 90             	mov    -0x70(%ebp),%eax
  103089:	8b 00                	mov    (%eax),%eax
  10308b:	8b 55 8c             	mov    -0x74(%ebp),%edx
  10308e:	89 55 88             	mov    %edx,-0x78(%ebp)
  103091:	89 45 84             	mov    %eax,-0x7c(%ebp)
  103094:	8b 45 90             	mov    -0x70(%ebp),%eax
  103097:	89 45 80             	mov    %eax,-0x80(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  10309a:	8b 45 80             	mov    -0x80(%ebp),%eax
  10309d:	8b 55 88             	mov    -0x78(%ebp),%edx
  1030a0:	89 10                	mov    %edx,(%eax)
  1030a2:	8b 45 80             	mov    -0x80(%ebp),%eax
  1030a5:	8b 10                	mov    (%eax),%edx
  1030a7:	8b 45 84             	mov    -0x7c(%ebp),%eax
  1030aa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1030ad:	8b 45 88             	mov    -0x78(%ebp),%eax
  1030b0:	8b 55 80             	mov    -0x80(%ebp),%edx
  1030b3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1030b6:	8b 45 88             	mov    -0x78(%ebp),%eax
  1030b9:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1030bc:	89 10                	mov    %edx,(%eax)
  1030be:	eb 02                	jmp    1030c2 <buddy_free_pages+0x380>
            }
            else
                break;
  1030c0:	eb 1a                	jmp    1030dc <buddy_free_pages+0x39a>
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list(index));
    unsigned i=index;
    bool b=0;
    for(;i<buddy_type_size;i++){
        while (le != &free_list(i)) {
  1030c2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1030c5:	89 d0                	mov    %edx,%eax
  1030c7:	01 c0                	add    %eax,%eax
  1030c9:	01 d0                	add    %edx,%eax
  1030cb:	c1 e0 02             	shl    $0x2,%eax
  1030ce:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  1030d3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1030d6:	0f 85 d6 fd ff ff    	jne    102eb2 <buddy_free_pages+0x170>
    }
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list(index));
    unsigned i=index;
    bool b=0;
    for(;i<buddy_type_size;i++){
  1030dc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  1030e0:	83 7d ec 12          	cmpl   $0x12,-0x14(%ebp)
  1030e4:	0f 86 c3 fd ff ff    	jbe    102ead <buddy_free_pages+0x16b>
            }
            else
                break;
        }
    }
}
  1030ea:	c9                   	leave  
  1030eb:	c3                   	ret    

001030ec <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void) {
  1030ec:	55                   	push   %ebp
  1030ed:	89 e5                	mov    %esp,%ebp
  1030ef:	83 ec 10             	sub    $0x10,%esp
     size_t count=0;
  1030f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    unsigned i=0;
  1030f9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
    size_t temp;
    for(;i<buddy_type_size;i++){
  103100:	eb 2f                	jmp    103131 <buddy_nr_free_pages+0x45>
        count+= ( nr_free(i) * buddy_type[i] );
  103102:	8b 55 f8             	mov    -0x8(%ebp),%edx
  103105:	89 d0                	mov    %edx,%eax
  103107:	01 c0                	add    %eax,%eax
  103109:	01 d0                	add    %edx,%eax
  10310b:	c1 e0 02             	shl    $0x2,%eax
  10310e:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  103113:	8b 48 08             	mov    0x8(%eax),%ecx
  103116:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103119:	8b 14 c5 84 ce 11 00 	mov    0x11ce84(,%eax,8),%edx
  103120:	8b 04 c5 80 ce 11 00 	mov    0x11ce80(,%eax,8),%eax
  103127:	0f af c1             	imul   %ecx,%eax
  10312a:	01 45 fc             	add    %eax,-0x4(%ebp)
static size_t
buddy_nr_free_pages(void) {
     size_t count=0;
    unsigned i=0;
    size_t temp;
    for(;i<buddy_type_size;i++){
  10312d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  103131:	83 7d f8 12          	cmpl   $0x12,-0x8(%ebp)
  103135:	76 cb                	jbe    103102 <buddy_nr_free_pages+0x16>
        count+= ( nr_free(i) * buddy_type[i] );
    }
    return count;
  103137:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10313a:	c9                   	leave  
  10313b:	c3                   	ret    

0010313c <buddy_check>:
// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, buddy_check functions!
static void
buddy_check(void) {
  10313c:	55                   	push   %ebp
  10313d:	89 e5                	mov    %esp,%ebp
  10313f:	81 ec 88 00 00 00    	sub    $0x88,%esp
    cprintf("buddy checking\n");
  103145:	c7 04 24 e9 73 10 00 	movl   $0x1073e9,(%esp)
  10314c:	e8 f7 d1 ff ff       	call   100348 <cprintf>
    unsigned count = 0, total = 0;
  103151:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103158:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    unsigned i=0;
  10315f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    for(;i<buddy_type_size;i++){
  103166:	e9 a9 00 00 00       	jmp    103214 <buddy_check+0xd8>
        list_entry_t *le = &free_list(i);
  10316b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10316e:	89 d0                	mov    %edx,%eax
  103170:	01 c0                	add    %eax,%eax
  103172:	01 d0                	add    %edx,%eax
  103174:	c1 e0 02             	shl    $0x2,%eax
  103177:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  10317c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        while ((le = list_next(le)) != &free_list(i)) {
  10317f:	eb 66                	jmp    1031e7 <buddy_check+0xab>
            struct Page *p = le2page(le, page_link);
  103181:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103184:	83 e8 0c             	sub    $0xc,%eax
  103187:	89 45 e0             	mov    %eax,-0x20(%ebp)
            assert(PageProperty(p));
  10318a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10318d:	83 c0 04             	add    $0x4,%eax
  103190:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  103197:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10319a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10319d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1031a0:	0f a3 10             	bt     %edx,(%eax)
  1031a3:	19 c0                	sbb    %eax,%eax
  1031a5:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  1031a8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  1031ac:	0f 95 c0             	setne  %al
  1031af:	0f b6 c0             	movzbl %al,%eax
  1031b2:	85 c0                	test   %eax,%eax
  1031b4:	75 24                	jne    1031da <buddy_check+0x9e>
  1031b6:	c7 44 24 0c f9 73 10 	movl   $0x1073f9,0xc(%esp)
  1031bd:	00 
  1031be:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  1031c5:	00 
  1031c6:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  1031cd:	00 
  1031ce:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  1031d5:	e8 3e da ff ff       	call   100c18 <__panic>
            count ++, total += p->property;
  1031da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1031de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1031e1:	8b 40 08             	mov    0x8(%eax),%eax
  1031e4:	01 45 f0             	add    %eax,-0x10(%ebp)
  1031e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1031ea:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1031ed:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1031f0:	8b 40 04             	mov    0x4(%eax),%eax
    cprintf("buddy checking\n");
    unsigned count = 0, total = 0;
    unsigned i=0;
    for(;i<buddy_type_size;i++){
        list_entry_t *le = &free_list(i);
        while ((le = list_next(le)) != &free_list(i)) {
  1031f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1031f6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1031f9:	89 d0                	mov    %edx,%eax
  1031fb:	01 c0                	add    %eax,%eax
  1031fd:	01 d0                	add    %edx,%eax
  1031ff:	c1 e0 02             	shl    $0x2,%eax
  103202:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  103207:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10320a:	0f 85 71 ff ff ff    	jne    103181 <buddy_check+0x45>
static void
buddy_check(void) {
    cprintf("buddy checking\n");
    unsigned count = 0, total = 0;
    unsigned i=0;
    for(;i<buddy_type_size;i++){
  103210:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  103214:	83 7d ec 12          	cmpl   $0x12,-0x14(%ebp)
  103218:	0f 86 4d ff ff ff    	jbe    10316b <buddy_check+0x2f>
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
            count ++, total += p->property;
        }
    }
    assert(total == nr_free_pages());
  10321e:	e8 cd 18 00 00       	call   104af0 <nr_free_pages>
  103223:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103226:	74 24                	je     10324c <buddy_check+0x110>
  103228:	c7 44 24 0c 09 74 10 	movl   $0x107409,0xc(%esp)
  10322f:	00 
  103230:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  103237:	00 
  103238:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  10323f:	00 
  103240:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  103247:	e8 cc d9 ff ff       	call   100c18 <__panic>
    struct Page *p0 = alloc_pages(8), *p1, *p2;
  10324c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  103253:	e8 2e 18 00 00       	call   104a86 <alloc_pages>
  103258:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
  10325b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10325f:	75 24                	jne    103285 <buddy_check+0x149>
  103261:	c7 44 24 0c 22 74 10 	movl   $0x107422,0xc(%esp)
  103268:	00 
  103269:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  103270:	00 
  103271:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  103278:	00 
  103279:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  103280:	e8 93 d9 ff ff       	call   100c18 <__panic>
    assert(!PageProperty(p0));
  103285:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103288:	83 c0 04             	add    $0x4,%eax
  10328b:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  103292:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103295:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103298:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10329b:	0f a3 10             	bt     %edx,(%eax)
  10329e:	19 c0                	sbb    %eax,%eax
  1032a0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1032a3:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1032a7:	0f 95 c0             	setne  %al
  1032aa:	0f b6 c0             	movzbl %al,%eax
  1032ad:	85 c0                	test   %eax,%eax
  1032af:	74 24                	je     1032d5 <buddy_check+0x199>
  1032b1:	c7 44 24 0c 2d 74 10 	movl   $0x10742d,0xc(%esp)
  1032b8:	00 
  1032b9:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  1032c0:	00 
  1032c1:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  1032c8:	00 
  1032c9:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  1032d0:	e8 43 d9 ff ff       	call   100c18 <__panic>
    list_entry_t free_list_store = free_list(3);
  1032d5:	a1 e4 cf 11 00       	mov    0x11cfe4,%eax
  1032da:	8b 15 e8 cf 11 00    	mov    0x11cfe8,%edx
  1032e0:	89 45 90             	mov    %eax,-0x70(%ebp)
  1032e3:	89 55 94             	mov    %edx,-0x6c(%ebp)
  1032e6:	c7 45 b4 e4 cf 11 00 	movl   $0x11cfe4,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1032ed:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1032f0:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1032f3:	89 50 04             	mov    %edx,0x4(%eax)
  1032f6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1032f9:	8b 50 04             	mov    0x4(%eax),%edx
  1032fc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1032ff:	89 10                	mov    %edx,(%eax)
  103301:	c7 45 b0 e4 cf 11 00 	movl   $0x11cfe4,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103308:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10330b:	8b 40 04             	mov    0x4(%eax),%eax
  10330e:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  103311:	0f 94 c0             	sete   %al
  103314:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list(3));
    assert(list_empty(&free_list(3)));
  103317:	85 c0                	test   %eax,%eax
  103319:	75 24                	jne    10333f <buddy_check+0x203>
  10331b:	c7 44 24 0c 3f 74 10 	movl   $0x10743f,0xc(%esp)
  103322:	00 
  103323:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  10332a:	00 
  10332b:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  103332:	00 
  103333:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  10333a:	e8 d9 d8 ff ff       	call   100c18 <__panic>
    struct Page *p01 = alloc_pages(8);
  10333f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  103346:	e8 3b 17 00 00       	call   104a86 <alloc_pages>
  10334b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    assert(p01 != NULL);
  10334e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  103352:	75 24                	jne    103378 <buddy_check+0x23c>
  103354:	c7 44 24 0c 59 74 10 	movl   $0x107459,0xc(%esp)
  10335b:	00 
  10335c:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  103363:	00 
  103364:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  10336b:	00 
  10336c:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  103373:	e8 a0 d8 ff ff       	call   100c18 <__panic>
    assert(!PageProperty(p01));
  103378:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10337b:	83 c0 04             	add    $0x4,%eax
  10337e:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  103385:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103388:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10338b:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10338e:	0f a3 10             	bt     %edx,(%eax)
  103391:	19 c0                	sbb    %eax,%eax
  103393:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  103396:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  10339a:	0f 95 c0             	setne  %al
  10339d:	0f b6 c0             	movzbl %al,%eax
  1033a0:	85 c0                	test   %eax,%eax
  1033a2:	74 24                	je     1033c8 <buddy_check+0x28c>
  1033a4:	c7 44 24 0c 65 74 10 	movl   $0x107465,0xc(%esp)
  1033ab:	00 
  1033ac:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  1033b3:	00 
  1033b4:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1033bb:	00 
  1033bc:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  1033c3:	e8 50 d8 ff ff       	call   100c18 <__panic>
    free_list_store = free_list(3);
  1033c8:	a1 e4 cf 11 00       	mov    0x11cfe4,%eax
  1033cd:	8b 15 e8 cf 11 00    	mov    0x11cfe8,%edx
  1033d3:	89 45 90             	mov    %eax,-0x70(%ebp)
  1033d6:	89 55 94             	mov    %edx,-0x6c(%ebp)
  1033d9:	c7 45 a0 e4 cf 11 00 	movl   $0x11cfe4,-0x60(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1033e0:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1033e3:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1033e6:	89 50 04             	mov    %edx,0x4(%eax)
  1033e9:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1033ec:	8b 50 04             	mov    0x4(%eax),%edx
  1033ef:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1033f2:	89 10                	mov    %edx,(%eax)
  1033f4:	c7 45 9c e4 cf 11 00 	movl   $0x11cfe4,-0x64(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  1033fb:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1033fe:	8b 40 04             	mov    0x4(%eax),%eax
  103401:	39 45 9c             	cmp    %eax,-0x64(%ebp)
  103404:	0f 94 c0             	sete   %al
  103407:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list(3));
    assert(list_empty(&free_list(3)));
  10340a:	85 c0                	test   %eax,%eax
  10340c:	75 24                	jne    103432 <buddy_check+0x2f6>
  10340e:	c7 44 24 0c 3f 74 10 	movl   $0x10743f,0xc(%esp)
  103415:	00 
  103416:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  10341d:	00 
  10341e:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  103425:	00 
  103426:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  10342d:	e8 e6 d7 ff ff       	call   100c18 <__panic>
    cprintf("%d\n",nr_free(3));
  103432:	a1 ec cf 11 00       	mov    0x11cfec,%eax
  103437:	89 44 24 04          	mov    %eax,0x4(%esp)
  10343b:	c7 04 24 78 74 10 00 	movl   $0x107478,(%esp)
  103442:	e8 01 cf ff ff       	call   100348 <cprintf>
    free_pages(p01,8);
  103447:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
  10344e:	00 
  10344f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103452:	89 04 24             	mov    %eax,(%esp)
  103455:	e8 64 16 00 00       	call   104abe <free_pages>
    cprintf("%d\n",nr_free(3));
  10345a:	a1 ec cf 11 00       	mov    0x11cfec,%eax
  10345f:	89 44 24 04          	mov    %eax,0x4(%esp)
  103463:	c7 04 24 78 74 10 00 	movl   $0x107478,(%esp)
  10346a:	e8 d9 ce ff ff       	call   100348 <cprintf>
    free_pages(p0, 8);
  10346f:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
  103476:	00 
  103477:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10347a:	89 04 24             	mov    %eax,(%esp)
  10347d:	e8 3c 16 00 00       	call   104abe <free_pages>
    cprintf("xxxxxxxxxxxxxx\n");
  103482:	c7 04 24 7c 74 10 00 	movl   $0x10747c,(%esp)
  103489:	e8 ba ce ff ff       	call   100348 <cprintf>
     for(;i<buddy_type_size;i++){
  10348e:	e9 93 00 00 00       	jmp    103526 <buddy_check+0x3ea>
        list_entry_t *le = &free_list(i);
  103493:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103496:	89 d0                	mov    %edx,%eax
  103498:	01 c0                	add    %eax,%eax
  10349a:	01 d0                	add    %edx,%eax
  10349c:	c1 e0 02             	shl    $0x2,%eax
  10349f:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  1034a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        while ((le = list_next(le)) != &free_list(i)) {
  1034a7:	eb 54                	jmp    1034fd <buddy_check+0x3c1>
            assert(le->next->prev == le && le->prev->next == le);
  1034a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034ac:	8b 40 04             	mov    0x4(%eax),%eax
  1034af:	8b 00                	mov    (%eax),%eax
  1034b1:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  1034b4:	75 0d                	jne    1034c3 <buddy_check+0x387>
  1034b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034b9:	8b 00                	mov    (%eax),%eax
  1034bb:	8b 40 04             	mov    0x4(%eax),%eax
  1034be:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  1034c1:	74 24                	je     1034e7 <buddy_check+0x3ab>
  1034c3:	c7 44 24 0c 8c 74 10 	movl   $0x10748c,0xc(%esp)
  1034ca:	00 
  1034cb:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  1034d2:	00 
  1034d3:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
  1034da:	00 
  1034db:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  1034e2:	e8 31 d7 ff ff       	call   100c18 <__panic>
        struct Page *p = le2page(le, page_link);
  1034e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034ea:	83 e8 0c             	sub    $0xc,%eax
  1034ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  1034f0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1034f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1034f7:	8b 40 08             	mov    0x8(%eax),%eax
  1034fa:	29 45 f0             	sub    %eax,-0x10(%ebp)
  1034fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103500:	89 45 98             	mov    %eax,-0x68(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  103503:	8b 45 98             	mov    -0x68(%ebp),%eax
  103506:	8b 40 04             	mov    0x4(%eax),%eax
    cprintf("%d\n",nr_free(3));
    free_pages(p0, 8);
    cprintf("xxxxxxxxxxxxxx\n");
     for(;i<buddy_type_size;i++){
        list_entry_t *le = &free_list(i);
        while ((le = list_next(le)) != &free_list(i)) {
  103509:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10350c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10350f:	89 d0                	mov    %edx,%eax
  103511:	01 c0                	add    %eax,%eax
  103513:	01 d0                	add    %edx,%eax
  103515:	c1 e0 02             	shl    $0x2,%eax
  103518:	05 c0 cf 11 00       	add    $0x11cfc0,%eax
  10351d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103520:	75 87                	jne    1034a9 <buddy_check+0x36d>
    cprintf("%d\n",nr_free(3));
    free_pages(p01,8);
    cprintf("%d\n",nr_free(3));
    free_pages(p0, 8);
    cprintf("xxxxxxxxxxxxxx\n");
     for(;i<buddy_type_size;i++){
  103522:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  103526:	83 7d ec 12          	cmpl   $0x12,-0x14(%ebp)
  10352a:	0f 86 63 ff ff ff    	jbe    103493 <buddy_check+0x357>
            assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
        }
    }
    assert(count == 0);
  103530:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103534:	74 24                	je     10355a <buddy_check+0x41e>
  103536:	c7 44 24 0c b9 74 10 	movl   $0x1074b9,0xc(%esp)
  10353d:	00 
  10353e:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  103545:	00 
  103546:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  10354d:	00 
  10354e:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  103555:	e8 be d6 ff ff       	call   100c18 <__panic>
    assert(total == 0);
  10355a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10355e:	74 24                	je     103584 <buddy_check+0x448>
  103560:	c7 44 24 0c c4 74 10 	movl   $0x1074c4,0xc(%esp)
  103567:	00 
  103568:	c7 44 24 08 82 73 10 	movl   $0x107382,0x8(%esp)
  10356f:	00 
  103570:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  103577:	00 
  103578:	c7 04 24 97 73 10 00 	movl   $0x107397,(%esp)
  10357f:	e8 94 d6 ff ff       	call   100c18 <__panic>
    cprintf("pppppppppppp\n");
  103584:	c7 04 24 cf 74 10 00 	movl   $0x1074cf,(%esp)
  10358b:	e8 b8 cd ff ff       	call   100348 <cprintf>
}
  103590:	c9                   	leave  
  103591:	c3                   	ret    

00103592 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  103592:	55                   	push   %ebp
  103593:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103595:	8b 55 08             	mov    0x8(%ebp),%edx
  103598:	a1 b8 d0 11 00       	mov    0x11d0b8,%eax
  10359d:	29 c2                	sub    %eax,%edx
  10359f:	89 d0                	mov    %edx,%eax
  1035a1:	c1 f8 02             	sar    $0x2,%eax
  1035a4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1035aa:	5d                   	pop    %ebp
  1035ab:	c3                   	ret    

001035ac <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1035ac:	55                   	push   %ebp
  1035ad:	89 e5                	mov    %esp,%ebp
  1035af:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1035b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1035b5:	89 04 24             	mov    %eax,(%esp)
  1035b8:	e8 d5 ff ff ff       	call   103592 <page2ppn>
  1035bd:	c1 e0 0c             	shl    $0xc,%eax
}
  1035c0:	c9                   	leave  
  1035c1:	c3                   	ret    

001035c2 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  1035c2:	55                   	push   %ebp
  1035c3:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1035c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1035c8:	8b 00                	mov    (%eax),%eax
}
  1035ca:	5d                   	pop    %ebp
  1035cb:	c3                   	ret    

001035cc <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1035cc:	55                   	push   %ebp
  1035cd:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1035cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1035d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1035d5:	89 10                	mov    %edx,(%eax)
}
  1035d7:	5d                   	pop    %ebp
  1035d8:	c3                   	ret    

001035d9 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1035d9:	55                   	push   %ebp
  1035da:	89 e5                	mov    %esp,%ebp
  1035dc:	83 ec 10             	sub    $0x10,%esp
  1035df:	c7 45 fc a4 d0 11 00 	movl   $0x11d0a4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1035e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1035e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1035ec:	89 50 04             	mov    %edx,0x4(%eax)
  1035ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1035f2:	8b 50 04             	mov    0x4(%eax),%edx
  1035f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1035f8:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1035fa:	c7 05 ac d0 11 00 00 	movl   $0x0,0x11d0ac
  103601:	00 00 00 
}
  103604:	c9                   	leave  
  103605:	c3                   	ret    

00103606 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  103606:	55                   	push   %ebp
  103607:	89 e5                	mov    %esp,%ebp
  103609:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  10360c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103610:	75 24                	jne    103636 <default_init_memmap+0x30>
  103612:	c7 44 24 0c 0c 75 10 	movl   $0x10750c,0xc(%esp)
  103619:	00 
  10361a:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103621:	00 
  103622:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  103629:	00 
  10362a:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103631:	e8 e2 d5 ff ff       	call   100c18 <__panic>
    struct Page *p = base;
  103636:	8b 45 08             	mov    0x8(%ebp),%eax
  103639:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  10363c:	eb 7d                	jmp    1036bb <default_init_memmap+0xb5>
        assert(PageReserved(p));
  10363e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103641:	83 c0 04             	add    $0x4,%eax
  103644:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  10364b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10364e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103651:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103654:	0f a3 10             	bt     %edx,(%eax)
  103657:	19 c0                	sbb    %eax,%eax
  103659:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  10365c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103660:	0f 95 c0             	setne  %al
  103663:	0f b6 c0             	movzbl %al,%eax
  103666:	85 c0                	test   %eax,%eax
  103668:	75 24                	jne    10368e <default_init_memmap+0x88>
  10366a:	c7 44 24 0c 3d 75 10 	movl   $0x10753d,0xc(%esp)
  103671:	00 
  103672:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103679:	00 
  10367a:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  103681:	00 
  103682:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103689:	e8 8a d5 ff ff       	call   100c18 <__panic>
        p->flags = p->property = 0;
  10368e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103691:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  103698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10369b:	8b 50 08             	mov    0x8(%eax),%edx
  10369e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036a1:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  1036a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1036ab:	00 
  1036ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036af:	89 04 24             	mov    %eax,(%esp)
  1036b2:	e8 15 ff ff ff       	call   1035cc <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  1036b7:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1036bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  1036be:	89 d0                	mov    %edx,%eax
  1036c0:	c1 e0 02             	shl    $0x2,%eax
  1036c3:	01 d0                	add    %edx,%eax
  1036c5:	c1 e0 02             	shl    $0x2,%eax
  1036c8:	89 c2                	mov    %eax,%edx
  1036ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1036cd:	01 d0                	add    %edx,%eax
  1036cf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1036d2:	0f 85 66 ff ff ff    	jne    10363e <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  1036d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1036db:	8b 55 0c             	mov    0xc(%ebp),%edx
  1036de:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1036e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1036e4:	83 c0 04             	add    $0x4,%eax
  1036e7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  1036ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1036f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1036f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1036f7:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  1036fa:	8b 15 ac d0 11 00    	mov    0x11d0ac,%edx
  103700:	8b 45 0c             	mov    0xc(%ebp),%eax
  103703:	01 d0                	add    %edx,%eax
  103705:	a3 ac d0 11 00       	mov    %eax,0x11d0ac
    list_add(&free_list, &(base->page_link));
  10370a:	8b 45 08             	mov    0x8(%ebp),%eax
  10370d:	83 c0 0c             	add    $0xc,%eax
  103710:	c7 45 dc a4 d0 11 00 	movl   $0x11d0a4,-0x24(%ebp)
  103717:	89 45 d8             	mov    %eax,-0x28(%ebp)
  10371a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10371d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  103720:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103723:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  103726:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103729:	8b 40 04             	mov    0x4(%eax),%eax
  10372c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10372f:	89 55 cc             	mov    %edx,-0x34(%ebp)
  103732:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103735:	89 55 c8             	mov    %edx,-0x38(%ebp)
  103738:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  10373b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10373e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103741:	89 10                	mov    %edx,(%eax)
  103743:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103746:	8b 10                	mov    (%eax),%edx
  103748:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10374b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10374e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103751:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  103754:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103757:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10375a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10375d:	89 10                	mov    %edx,(%eax)
}
  10375f:	c9                   	leave  
  103760:	c3                   	ret    

00103761 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  103761:	55                   	push   %ebp
  103762:	89 e5                	mov    %esp,%ebp
  103764:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  103767:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10376b:	75 24                	jne    103791 <default_alloc_pages+0x30>
  10376d:	c7 44 24 0c 0c 75 10 	movl   $0x10750c,0xc(%esp)
  103774:	00 
  103775:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  10377c:	00 
  10377d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  103784:	00 
  103785:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  10378c:	e8 87 d4 ff ff       	call   100c18 <__panic>
    if (n > nr_free) {
  103791:	a1 ac d0 11 00       	mov    0x11d0ac,%eax
  103796:	3b 45 08             	cmp    0x8(%ebp),%eax
  103799:	73 0a                	jae    1037a5 <default_alloc_pages+0x44>
        return NULL;
  10379b:	b8 00 00 00 00       	mov    $0x0,%eax
  1037a0:	e9 2a 01 00 00       	jmp    1038cf <default_alloc_pages+0x16e>
    }
    struct Page *page = NULL;
  1037a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  1037ac:	c7 45 f0 a4 d0 11 00 	movl   $0x11d0a4,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1037b3:	eb 1c                	jmp    1037d1 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  1037b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1037b8:	83 e8 0c             	sub    $0xc,%eax
  1037bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  1037be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037c1:	8b 40 08             	mov    0x8(%eax),%eax
  1037c4:	3b 45 08             	cmp    0x8(%ebp),%eax
  1037c7:	72 08                	jb     1037d1 <default_alloc_pages+0x70>
            page = p;
  1037c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  1037cf:	eb 18                	jmp    1037e9 <default_alloc_pages+0x88>
  1037d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1037d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1037d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037da:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1037dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1037e0:	81 7d f0 a4 d0 11 00 	cmpl   $0x11d0a4,-0x10(%ebp)
  1037e7:	75 cc                	jne    1037b5 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
  1037e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1037ed:	0f 84 d9 00 00 00    	je     1038cc <default_alloc_pages+0x16b>
        list_del(&(page->page_link));
  1037f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1037f6:	83 c0 0c             	add    $0xc,%eax
  1037f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  1037fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1037ff:	8b 40 04             	mov    0x4(%eax),%eax
  103802:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103805:	8b 12                	mov    (%edx),%edx
  103807:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10380a:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  10380d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103810:	8b 55 d8             	mov    -0x28(%ebp),%edx
  103813:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  103816:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103819:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10381c:	89 10                	mov    %edx,(%eax)
        if (page->property > n) {
  10381e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103821:	8b 40 08             	mov    0x8(%eax),%eax
  103824:	3b 45 08             	cmp    0x8(%ebp),%eax
  103827:	76 7d                	jbe    1038a6 <default_alloc_pages+0x145>
            struct Page *p = page + n;
  103829:	8b 55 08             	mov    0x8(%ebp),%edx
  10382c:	89 d0                	mov    %edx,%eax
  10382e:	c1 e0 02             	shl    $0x2,%eax
  103831:	01 d0                	add    %edx,%eax
  103833:	c1 e0 02             	shl    $0x2,%eax
  103836:	89 c2                	mov    %eax,%edx
  103838:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10383b:	01 d0                	add    %edx,%eax
  10383d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  103840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103843:	8b 40 08             	mov    0x8(%eax),%eax
  103846:	2b 45 08             	sub    0x8(%ebp),%eax
  103849:	89 c2                	mov    %eax,%edx
  10384b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10384e:	89 50 08             	mov    %edx,0x8(%eax)
            list_add(&free_list, &(p->page_link));
  103851:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103854:	83 c0 0c             	add    $0xc,%eax
  103857:	c7 45 d4 a4 d0 11 00 	movl   $0x11d0a4,-0x2c(%ebp)
  10385e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103861:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103864:	89 45 cc             	mov    %eax,-0x34(%ebp)
  103867:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10386a:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  10386d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103870:	8b 40 04             	mov    0x4(%eax),%eax
  103873:	8b 55 c8             	mov    -0x38(%ebp),%edx
  103876:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  103879:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10387c:	89 55 c0             	mov    %edx,-0x40(%ebp)
  10387f:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  103882:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103885:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  103888:	89 10                	mov    %edx,(%eax)
  10388a:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10388d:	8b 10                	mov    (%eax),%edx
  10388f:	8b 45 c0             	mov    -0x40(%ebp),%eax
  103892:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103895:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103898:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10389b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10389e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1038a1:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1038a4:	89 10                	mov    %edx,(%eax)
    }
        nr_free -= n;
  1038a6:	a1 ac d0 11 00       	mov    0x11d0ac,%eax
  1038ab:	2b 45 08             	sub    0x8(%ebp),%eax
  1038ae:	a3 ac d0 11 00       	mov    %eax,0x11d0ac
        ClearPageProperty(page);
  1038b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038b6:	83 c0 04             	add    $0x4,%eax
  1038b9:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  1038c0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1038c3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1038c6:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1038c9:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  1038cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1038cf:	c9                   	leave  
  1038d0:	c3                   	ret    

001038d1 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  1038d1:	55                   	push   %ebp
  1038d2:	89 e5                	mov    %esp,%ebp
  1038d4:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  1038da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1038de:	75 24                	jne    103904 <default_free_pages+0x33>
  1038e0:	c7 44 24 0c 0c 75 10 	movl   $0x10750c,0xc(%esp)
  1038e7:	00 
  1038e8:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  1038ef:	00 
  1038f0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  1038f7:	00 
  1038f8:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  1038ff:	e8 14 d3 ff ff       	call   100c18 <__panic>
    struct Page *p = base;
  103904:	8b 45 08             	mov    0x8(%ebp),%eax
  103907:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  10390a:	e9 9d 00 00 00       	jmp    1039ac <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  10390f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103912:	83 c0 04             	add    $0x4,%eax
  103915:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  10391c:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10391f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103922:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103925:	0f a3 10             	bt     %edx,(%eax)
  103928:	19 c0                	sbb    %eax,%eax
  10392a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  10392d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103931:	0f 95 c0             	setne  %al
  103934:	0f b6 c0             	movzbl %al,%eax
  103937:	85 c0                	test   %eax,%eax
  103939:	75 2c                	jne    103967 <default_free_pages+0x96>
  10393b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10393e:	83 c0 04             	add    $0x4,%eax
  103941:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  103948:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10394b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10394e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103951:	0f a3 10             	bt     %edx,(%eax)
  103954:	19 c0                	sbb    %eax,%eax
  103956:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  103959:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  10395d:	0f 95 c0             	setne  %al
  103960:	0f b6 c0             	movzbl %al,%eax
  103963:	85 c0                	test   %eax,%eax
  103965:	74 24                	je     10398b <default_free_pages+0xba>
  103967:	c7 44 24 0c 50 75 10 	movl   $0x107550,0xc(%esp)
  10396e:	00 
  10396f:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103976:	00 
  103977:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  10397e:	00 
  10397f:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103986:	e8 8d d2 ff ff       	call   100c18 <__panic>
        p->flags = 0;
  10398b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10398e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  103995:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10399c:	00 
  10399d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1039a0:	89 04 24             	mov    %eax,(%esp)
  1039a3:	e8 24 fc ff ff       	call   1035cc <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  1039a8:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1039ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  1039af:	89 d0                	mov    %edx,%eax
  1039b1:	c1 e0 02             	shl    $0x2,%eax
  1039b4:	01 d0                	add    %edx,%eax
  1039b6:	c1 e0 02             	shl    $0x2,%eax
  1039b9:	89 c2                	mov    %eax,%edx
  1039bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1039be:	01 d0                	add    %edx,%eax
  1039c0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1039c3:	0f 85 46 ff ff ff    	jne    10390f <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  1039c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1039cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1039cf:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1039d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1039d5:	83 c0 04             	add    $0x4,%eax
  1039d8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  1039df:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1039e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1039e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1039e8:	0f ab 10             	bts    %edx,(%eax)
  1039eb:	c7 45 cc a4 d0 11 00 	movl   $0x11d0a4,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1039f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1039f5:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  1039f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  1039fb:	e9 08 01 00 00       	jmp    103b08 <default_free_pages+0x237>
        p = le2page(le, page_link);
  103a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a03:	83 e8 0c             	sub    $0xc,%eax
  103a06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a0c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  103a0f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103a12:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  103a15:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  103a18:	8b 45 08             	mov    0x8(%ebp),%eax
  103a1b:	8b 50 08             	mov    0x8(%eax),%edx
  103a1e:	89 d0                	mov    %edx,%eax
  103a20:	c1 e0 02             	shl    $0x2,%eax
  103a23:	01 d0                	add    %edx,%eax
  103a25:	c1 e0 02             	shl    $0x2,%eax
  103a28:	89 c2                	mov    %eax,%edx
  103a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  103a2d:	01 d0                	add    %edx,%eax
  103a2f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103a32:	75 5a                	jne    103a8e <default_free_pages+0x1bd>
            base->property += p->property;
  103a34:	8b 45 08             	mov    0x8(%ebp),%eax
  103a37:	8b 50 08             	mov    0x8(%eax),%edx
  103a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a3d:	8b 40 08             	mov    0x8(%eax),%eax
  103a40:	01 c2                	add    %eax,%edx
  103a42:	8b 45 08             	mov    0x8(%ebp),%eax
  103a45:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  103a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a4b:	83 c0 04             	add    $0x4,%eax
  103a4e:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  103a55:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103a58:	8b 45 c0             	mov    -0x40(%ebp),%eax
  103a5b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  103a5e:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  103a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a64:	83 c0 0c             	add    $0xc,%eax
  103a67:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  103a6a:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103a6d:	8b 40 04             	mov    0x4(%eax),%eax
  103a70:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103a73:	8b 12                	mov    (%edx),%edx
  103a75:	89 55 b8             	mov    %edx,-0x48(%ebp)
  103a78:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  103a7b:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103a7e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103a81:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  103a84:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103a87:	8b 55 b8             	mov    -0x48(%ebp),%edx
  103a8a:	89 10                	mov    %edx,(%eax)
  103a8c:	eb 7a                	jmp    103b08 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  103a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a91:	8b 50 08             	mov    0x8(%eax),%edx
  103a94:	89 d0                	mov    %edx,%eax
  103a96:	c1 e0 02             	shl    $0x2,%eax
  103a99:	01 d0                	add    %edx,%eax
  103a9b:	c1 e0 02             	shl    $0x2,%eax
  103a9e:	89 c2                	mov    %eax,%edx
  103aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103aa3:	01 d0                	add    %edx,%eax
  103aa5:	3b 45 08             	cmp    0x8(%ebp),%eax
  103aa8:	75 5e                	jne    103b08 <default_free_pages+0x237>
            p->property += base->property;
  103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103aad:	8b 50 08             	mov    0x8(%eax),%edx
  103ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  103ab3:	8b 40 08             	mov    0x8(%eax),%eax
  103ab6:	01 c2                	add    %eax,%edx
  103ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103abb:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  103abe:	8b 45 08             	mov    0x8(%ebp),%eax
  103ac1:	83 c0 04             	add    $0x4,%eax
  103ac4:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  103acb:	89 45 ac             	mov    %eax,-0x54(%ebp)
  103ace:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103ad1:	8b 55 b0             	mov    -0x50(%ebp),%edx
  103ad4:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  103ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ada:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  103add:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ae0:	83 c0 0c             	add    $0xc,%eax
  103ae3:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  103ae6:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103ae9:	8b 40 04             	mov    0x4(%eax),%eax
  103aec:	8b 55 a8             	mov    -0x58(%ebp),%edx
  103aef:	8b 12                	mov    (%edx),%edx
  103af1:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  103af4:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  103af7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  103afa:	8b 55 a0             	mov    -0x60(%ebp),%edx
  103afd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  103b00:	8b 45 a0             	mov    -0x60(%ebp),%eax
  103b03:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  103b06:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  103b08:	81 7d f0 a4 d0 11 00 	cmpl   $0x11d0a4,-0x10(%ebp)
  103b0f:	0f 85 eb fe ff ff    	jne    103a00 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  103b15:	8b 15 ac d0 11 00    	mov    0x11d0ac,%edx
  103b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  103b1e:	01 d0                	add    %edx,%eax
  103b20:	a3 ac d0 11 00       	mov    %eax,0x11d0ac
    list_add(&free_list, &(base->page_link));
  103b25:	8b 45 08             	mov    0x8(%ebp),%eax
  103b28:	83 c0 0c             	add    $0xc,%eax
  103b2b:	c7 45 9c a4 d0 11 00 	movl   $0x11d0a4,-0x64(%ebp)
  103b32:	89 45 98             	mov    %eax,-0x68(%ebp)
  103b35:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103b38:	89 45 94             	mov    %eax,-0x6c(%ebp)
  103b3b:	8b 45 98             	mov    -0x68(%ebp),%eax
  103b3e:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  103b41:	8b 45 94             	mov    -0x6c(%ebp),%eax
  103b44:	8b 40 04             	mov    0x4(%eax),%eax
  103b47:	8b 55 90             	mov    -0x70(%ebp),%edx
  103b4a:	89 55 8c             	mov    %edx,-0x74(%ebp)
  103b4d:	8b 55 94             	mov    -0x6c(%ebp),%edx
  103b50:	89 55 88             	mov    %edx,-0x78(%ebp)
  103b53:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  103b56:	8b 45 84             	mov    -0x7c(%ebp),%eax
  103b59:	8b 55 8c             	mov    -0x74(%ebp),%edx
  103b5c:	89 10                	mov    %edx,(%eax)
  103b5e:	8b 45 84             	mov    -0x7c(%ebp),%eax
  103b61:	8b 10                	mov    (%eax),%edx
  103b63:	8b 45 88             	mov    -0x78(%ebp),%eax
  103b66:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103b69:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103b6c:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103b6f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103b72:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103b75:	8b 55 88             	mov    -0x78(%ebp),%edx
  103b78:	89 10                	mov    %edx,(%eax)
}
  103b7a:	c9                   	leave  
  103b7b:	c3                   	ret    

00103b7c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  103b7c:	55                   	push   %ebp
  103b7d:	89 e5                	mov    %esp,%ebp
    return nr_free;
  103b7f:	a1 ac d0 11 00       	mov    0x11d0ac,%eax
}
  103b84:	5d                   	pop    %ebp
  103b85:	c3                   	ret    

00103b86 <basic_check>:

static void
basic_check(void) {
  103b86:	55                   	push   %ebp
  103b87:	89 e5                	mov    %esp,%ebp
  103b89:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  103b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b96:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  103b9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103ba6:	e8 db 0e 00 00       	call   104a86 <alloc_pages>
  103bab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103bae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103bb2:	75 24                	jne    103bd8 <basic_check+0x52>
  103bb4:	c7 44 24 0c 75 75 10 	movl   $0x107575,0xc(%esp)
  103bbb:	00 
  103bbc:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103bc3:	00 
  103bc4:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
  103bcb:	00 
  103bcc:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103bd3:	e8 40 d0 ff ff       	call   100c18 <__panic>
    assert((p1 = alloc_page()) != NULL);
  103bd8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103bdf:	e8 a2 0e 00 00       	call   104a86 <alloc_pages>
  103be4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103be7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103beb:	75 24                	jne    103c11 <basic_check+0x8b>
  103bed:	c7 44 24 0c 91 75 10 	movl   $0x107591,0xc(%esp)
  103bf4:	00 
  103bf5:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103bfc:	00 
  103bfd:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  103c04:	00 
  103c05:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103c0c:	e8 07 d0 ff ff       	call   100c18 <__panic>
    assert((p2 = alloc_page()) != NULL);
  103c11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103c18:	e8 69 0e 00 00       	call   104a86 <alloc_pages>
  103c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103c20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103c24:	75 24                	jne    103c4a <basic_check+0xc4>
  103c26:	c7 44 24 0c ad 75 10 	movl   $0x1075ad,0xc(%esp)
  103c2d:	00 
  103c2e:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103c35:	00 
  103c36:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  103c3d:	00 
  103c3e:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103c45:	e8 ce cf ff ff       	call   100c18 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  103c4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c4d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103c50:	74 10                	je     103c62 <basic_check+0xdc>
  103c52:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c55:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103c58:	74 08                	je     103c62 <basic_check+0xdc>
  103c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c5d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103c60:	75 24                	jne    103c86 <basic_check+0x100>
  103c62:	c7 44 24 0c cc 75 10 	movl   $0x1075cc,0xc(%esp)
  103c69:	00 
  103c6a:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103c71:	00 
  103c72:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
  103c79:	00 
  103c7a:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103c81:	e8 92 cf ff ff       	call   100c18 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  103c86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c89:	89 04 24             	mov    %eax,(%esp)
  103c8c:	e8 31 f9 ff ff       	call   1035c2 <page_ref>
  103c91:	85 c0                	test   %eax,%eax
  103c93:	75 1e                	jne    103cb3 <basic_check+0x12d>
  103c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c98:	89 04 24             	mov    %eax,(%esp)
  103c9b:	e8 22 f9 ff ff       	call   1035c2 <page_ref>
  103ca0:	85 c0                	test   %eax,%eax
  103ca2:	75 0f                	jne    103cb3 <basic_check+0x12d>
  103ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ca7:	89 04 24             	mov    %eax,(%esp)
  103caa:	e8 13 f9 ff ff       	call   1035c2 <page_ref>
  103caf:	85 c0                	test   %eax,%eax
  103cb1:	74 24                	je     103cd7 <basic_check+0x151>
  103cb3:	c7 44 24 0c f0 75 10 	movl   $0x1075f0,0xc(%esp)
  103cba:	00 
  103cbb:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103cc2:	00 
  103cc3:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
  103cca:	00 
  103ccb:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103cd2:	e8 41 cf ff ff       	call   100c18 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  103cd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103cda:	89 04 24             	mov    %eax,(%esp)
  103cdd:	e8 ca f8 ff ff       	call   1035ac <page2pa>
  103ce2:	8b 15 20 cf 11 00    	mov    0x11cf20,%edx
  103ce8:	c1 e2 0c             	shl    $0xc,%edx
  103ceb:	39 d0                	cmp    %edx,%eax
  103ced:	72 24                	jb     103d13 <basic_check+0x18d>
  103cef:	c7 44 24 0c 2c 76 10 	movl   $0x10762c,0xc(%esp)
  103cf6:	00 
  103cf7:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103cfe:	00 
  103cff:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  103d06:	00 
  103d07:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103d0e:	e8 05 cf ff ff       	call   100c18 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  103d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d16:	89 04 24             	mov    %eax,(%esp)
  103d19:	e8 8e f8 ff ff       	call   1035ac <page2pa>
  103d1e:	8b 15 20 cf 11 00    	mov    0x11cf20,%edx
  103d24:	c1 e2 0c             	shl    $0xc,%edx
  103d27:	39 d0                	cmp    %edx,%eax
  103d29:	72 24                	jb     103d4f <basic_check+0x1c9>
  103d2b:	c7 44 24 0c 49 76 10 	movl   $0x107649,0xc(%esp)
  103d32:	00 
  103d33:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103d3a:	00 
  103d3b:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  103d42:	00 
  103d43:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103d4a:	e8 c9 ce ff ff       	call   100c18 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  103d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d52:	89 04 24             	mov    %eax,(%esp)
  103d55:	e8 52 f8 ff ff       	call   1035ac <page2pa>
  103d5a:	8b 15 20 cf 11 00    	mov    0x11cf20,%edx
  103d60:	c1 e2 0c             	shl    $0xc,%edx
  103d63:	39 d0                	cmp    %edx,%eax
  103d65:	72 24                	jb     103d8b <basic_check+0x205>
  103d67:	c7 44 24 0c 66 76 10 	movl   $0x107666,0xc(%esp)
  103d6e:	00 
  103d6f:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103d76:	00 
  103d77:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  103d7e:	00 
  103d7f:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103d86:	e8 8d ce ff ff       	call   100c18 <__panic>

    list_entry_t free_list_store = free_list;
  103d8b:	a1 a4 d0 11 00       	mov    0x11d0a4,%eax
  103d90:	8b 15 a8 d0 11 00    	mov    0x11d0a8,%edx
  103d96:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103d99:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103d9c:	c7 45 e0 a4 d0 11 00 	movl   $0x11d0a4,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  103da3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103da6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103da9:	89 50 04             	mov    %edx,0x4(%eax)
  103dac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103daf:	8b 50 04             	mov    0x4(%eax),%edx
  103db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103db5:	89 10                	mov    %edx,(%eax)
  103db7:	c7 45 dc a4 d0 11 00 	movl   $0x11d0a4,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103dbe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103dc1:	8b 40 04             	mov    0x4(%eax),%eax
  103dc4:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103dc7:	0f 94 c0             	sete   %al
  103dca:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103dcd:	85 c0                	test   %eax,%eax
  103dcf:	75 24                	jne    103df5 <basic_check+0x26f>
  103dd1:	c7 44 24 0c 83 76 10 	movl   $0x107683,0xc(%esp)
  103dd8:	00 
  103dd9:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103de0:	00 
  103de1:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  103de8:	00 
  103de9:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103df0:	e8 23 ce ff ff       	call   100c18 <__panic>

    unsigned int nr_free_store = nr_free;
  103df5:	a1 ac d0 11 00       	mov    0x11d0ac,%eax
  103dfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  103dfd:	c7 05 ac d0 11 00 00 	movl   $0x0,0x11d0ac
  103e04:	00 00 00 

    assert(alloc_page() == NULL);
  103e07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103e0e:	e8 73 0c 00 00       	call   104a86 <alloc_pages>
  103e13:	85 c0                	test   %eax,%eax
  103e15:	74 24                	je     103e3b <basic_check+0x2b5>
  103e17:	c7 44 24 0c 9a 76 10 	movl   $0x10769a,0xc(%esp)
  103e1e:	00 
  103e1f:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103e26:	00 
  103e27:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  103e2e:	00 
  103e2f:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103e36:	e8 dd cd ff ff       	call   100c18 <__panic>

    free_page(p0);
  103e3b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103e42:	00 
  103e43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e46:	89 04 24             	mov    %eax,(%esp)
  103e49:	e8 70 0c 00 00       	call   104abe <free_pages>
    free_page(p1);
  103e4e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103e55:	00 
  103e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e59:	89 04 24             	mov    %eax,(%esp)
  103e5c:	e8 5d 0c 00 00       	call   104abe <free_pages>
    free_page(p2);
  103e61:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103e68:	00 
  103e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e6c:	89 04 24             	mov    %eax,(%esp)
  103e6f:	e8 4a 0c 00 00       	call   104abe <free_pages>
    assert(nr_free == 3);
  103e74:	a1 ac d0 11 00       	mov    0x11d0ac,%eax
  103e79:	83 f8 03             	cmp    $0x3,%eax
  103e7c:	74 24                	je     103ea2 <basic_check+0x31c>
  103e7e:	c7 44 24 0c af 76 10 	movl   $0x1076af,0xc(%esp)
  103e85:	00 
  103e86:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103e8d:	00 
  103e8e:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  103e95:	00 
  103e96:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103e9d:	e8 76 cd ff ff       	call   100c18 <__panic>

    assert((p0 = alloc_page()) != NULL);
  103ea2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103ea9:	e8 d8 0b 00 00       	call   104a86 <alloc_pages>
  103eae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103eb1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103eb5:	75 24                	jne    103edb <basic_check+0x355>
  103eb7:	c7 44 24 0c 75 75 10 	movl   $0x107575,0xc(%esp)
  103ebe:	00 
  103ebf:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103ec6:	00 
  103ec7:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  103ece:	00 
  103ecf:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103ed6:	e8 3d cd ff ff       	call   100c18 <__panic>
    assert((p1 = alloc_page()) != NULL);
  103edb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103ee2:	e8 9f 0b 00 00       	call   104a86 <alloc_pages>
  103ee7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103eea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103eee:	75 24                	jne    103f14 <basic_check+0x38e>
  103ef0:	c7 44 24 0c 91 75 10 	movl   $0x107591,0xc(%esp)
  103ef7:	00 
  103ef8:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103eff:	00 
  103f00:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  103f07:	00 
  103f08:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103f0f:	e8 04 cd ff ff       	call   100c18 <__panic>
    assert((p2 = alloc_page()) != NULL);
  103f14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103f1b:	e8 66 0b 00 00       	call   104a86 <alloc_pages>
  103f20:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103f23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103f27:	75 24                	jne    103f4d <basic_check+0x3c7>
  103f29:	c7 44 24 0c ad 75 10 	movl   $0x1075ad,0xc(%esp)
  103f30:	00 
  103f31:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103f38:	00 
  103f39:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
  103f40:	00 
  103f41:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103f48:	e8 cb cc ff ff       	call   100c18 <__panic>

    assert(alloc_page() == NULL);
  103f4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103f54:	e8 2d 0b 00 00       	call   104a86 <alloc_pages>
  103f59:	85 c0                	test   %eax,%eax
  103f5b:	74 24                	je     103f81 <basic_check+0x3fb>
  103f5d:	c7 44 24 0c 9a 76 10 	movl   $0x10769a,0xc(%esp)
  103f64:	00 
  103f65:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103f6c:	00 
  103f6d:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  103f74:	00 
  103f75:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103f7c:	e8 97 cc ff ff       	call   100c18 <__panic>

    free_page(p0);
  103f81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103f88:	00 
  103f89:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103f8c:	89 04 24             	mov    %eax,(%esp)
  103f8f:	e8 2a 0b 00 00       	call   104abe <free_pages>
  103f94:	c7 45 d8 a4 d0 11 00 	movl   $0x11d0a4,-0x28(%ebp)
  103f9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103f9e:	8b 40 04             	mov    0x4(%eax),%eax
  103fa1:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  103fa4:	0f 94 c0             	sete   %al
  103fa7:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  103faa:	85 c0                	test   %eax,%eax
  103fac:	74 24                	je     103fd2 <basic_check+0x44c>
  103fae:	c7 44 24 0c bc 76 10 	movl   $0x1076bc,0xc(%esp)
  103fb5:	00 
  103fb6:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103fbd:	00 
  103fbe:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  103fc5:	00 
  103fc6:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  103fcd:	e8 46 cc ff ff       	call   100c18 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  103fd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103fd9:	e8 a8 0a 00 00       	call   104a86 <alloc_pages>
  103fde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103fe1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103fe4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103fe7:	74 24                	je     10400d <basic_check+0x487>
  103fe9:	c7 44 24 0c d4 76 10 	movl   $0x1076d4,0xc(%esp)
  103ff0:	00 
  103ff1:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  103ff8:	00 
  103ff9:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  104000:	00 
  104001:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  104008:	e8 0b cc ff ff       	call   100c18 <__panic>
    assert(alloc_page() == NULL);
  10400d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104014:	e8 6d 0a 00 00       	call   104a86 <alloc_pages>
  104019:	85 c0                	test   %eax,%eax
  10401b:	74 24                	je     104041 <basic_check+0x4bb>
  10401d:	c7 44 24 0c 9a 76 10 	movl   $0x10769a,0xc(%esp)
  104024:	00 
  104025:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  10402c:	00 
  10402d:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  104034:	00 
  104035:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  10403c:	e8 d7 cb ff ff       	call   100c18 <__panic>

    assert(nr_free == 0);
  104041:	a1 ac d0 11 00       	mov    0x11d0ac,%eax
  104046:	85 c0                	test   %eax,%eax
  104048:	74 24                	je     10406e <basic_check+0x4e8>
  10404a:	c7 44 24 0c ed 76 10 	movl   $0x1076ed,0xc(%esp)
  104051:	00 
  104052:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  104059:	00 
  10405a:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  104061:	00 
  104062:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  104069:	e8 aa cb ff ff       	call   100c18 <__panic>
    free_list = free_list_store;
  10406e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104071:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104074:	a3 a4 d0 11 00       	mov    %eax,0x11d0a4
  104079:	89 15 a8 d0 11 00    	mov    %edx,0x11d0a8
    nr_free = nr_free_store;
  10407f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104082:	a3 ac d0 11 00       	mov    %eax,0x11d0ac

    free_page(p);
  104087:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10408e:	00 
  10408f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104092:	89 04 24             	mov    %eax,(%esp)
  104095:	e8 24 0a 00 00       	call   104abe <free_pages>
    free_page(p1);
  10409a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1040a1:	00 
  1040a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1040a5:	89 04 24             	mov    %eax,(%esp)
  1040a8:	e8 11 0a 00 00       	call   104abe <free_pages>
    free_page(p2);
  1040ad:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1040b4:	00 
  1040b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1040b8:	89 04 24             	mov    %eax,(%esp)
  1040bb:	e8 fe 09 00 00       	call   104abe <free_pages>
}
  1040c0:	c9                   	leave  
  1040c1:	c3                   	ret    

001040c2 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  1040c2:	55                   	push   %ebp
  1040c3:	89 e5                	mov    %esp,%ebp
  1040c5:	53                   	push   %ebx
  1040c6:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  1040cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1040d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  1040da:	c7 45 ec a4 d0 11 00 	movl   $0x11d0a4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1040e1:	eb 6b                	jmp    10414e <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  1040e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1040e6:	83 e8 0c             	sub    $0xc,%eax
  1040e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  1040ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1040ef:	83 c0 04             	add    $0x4,%eax
  1040f2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1040f9:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1040fc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1040ff:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104102:	0f a3 10             	bt     %edx,(%eax)
  104105:	19 c0                	sbb    %eax,%eax
  104107:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  10410a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  10410e:	0f 95 c0             	setne  %al
  104111:	0f b6 c0             	movzbl %al,%eax
  104114:	85 c0                	test   %eax,%eax
  104116:	75 24                	jne    10413c <default_check+0x7a>
  104118:	c7 44 24 0c fa 76 10 	movl   $0x1076fa,0xc(%esp)
  10411f:	00 
  104120:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  104127:	00 
  104128:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
  10412f:	00 
  104130:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  104137:	e8 dc ca ff ff       	call   100c18 <__panic>
        count ++, total += p->property;
  10413c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  104140:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104143:	8b 50 08             	mov    0x8(%eax),%edx
  104146:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104149:	01 d0                	add    %edx,%eax
  10414b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10414e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104151:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  104154:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104157:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  10415a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10415d:	81 7d ec a4 d0 11 00 	cmpl   $0x11d0a4,-0x14(%ebp)
  104164:	0f 85 79 ff ff ff    	jne    1040e3 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  10416a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  10416d:	e8 7e 09 00 00       	call   104af0 <nr_free_pages>
  104172:	39 c3                	cmp    %eax,%ebx
  104174:	74 24                	je     10419a <default_check+0xd8>
  104176:	c7 44 24 0c 0a 77 10 	movl   $0x10770a,0xc(%esp)
  10417d:	00 
  10417e:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  104185:	00 
  104186:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  10418d:	00 
  10418e:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  104195:	e8 7e ca ff ff       	call   100c18 <__panic>

    basic_check();
  10419a:	e8 e7 f9 ff ff       	call   103b86 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  10419f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1041a6:	e8 db 08 00 00       	call   104a86 <alloc_pages>
  1041ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  1041ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1041b2:	75 24                	jne    1041d8 <default_check+0x116>
  1041b4:	c7 44 24 0c 23 77 10 	movl   $0x107723,0xc(%esp)
  1041bb:	00 
  1041bc:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  1041c3:	00 
  1041c4:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
  1041cb:	00 
  1041cc:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  1041d3:	e8 40 ca ff ff       	call   100c18 <__panic>
    assert(!PageProperty(p0));
  1041d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1041db:	83 c0 04             	add    $0x4,%eax
  1041de:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1041e5:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1041e8:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1041eb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1041ee:	0f a3 10             	bt     %edx,(%eax)
  1041f1:	19 c0                	sbb    %eax,%eax
  1041f3:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1041f6:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1041fa:	0f 95 c0             	setne  %al
  1041fd:	0f b6 c0             	movzbl %al,%eax
  104200:	85 c0                	test   %eax,%eax
  104202:	74 24                	je     104228 <default_check+0x166>
  104204:	c7 44 24 0c 2e 77 10 	movl   $0x10772e,0xc(%esp)
  10420b:	00 
  10420c:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  104213:	00 
  104214:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  10421b:	00 
  10421c:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  104223:	e8 f0 c9 ff ff       	call   100c18 <__panic>

    list_entry_t free_list_store = free_list;
  104228:	a1 a4 d0 11 00       	mov    0x11d0a4,%eax
  10422d:	8b 15 a8 d0 11 00    	mov    0x11d0a8,%edx
  104233:	89 45 80             	mov    %eax,-0x80(%ebp)
  104236:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104239:	c7 45 b4 a4 d0 11 00 	movl   $0x11d0a4,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104240:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104243:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104246:	89 50 04             	mov    %edx,0x4(%eax)
  104249:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10424c:	8b 50 04             	mov    0x4(%eax),%edx
  10424f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104252:	89 10                	mov    %edx,(%eax)
  104254:	c7 45 b0 a4 d0 11 00 	movl   $0x11d0a4,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  10425b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10425e:	8b 40 04             	mov    0x4(%eax),%eax
  104261:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  104264:	0f 94 c0             	sete   %al
  104267:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  10426a:	85 c0                	test   %eax,%eax
  10426c:	75 24                	jne    104292 <default_check+0x1d0>
  10426e:	c7 44 24 0c 83 76 10 	movl   $0x107683,0xc(%esp)
  104275:	00 
  104276:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  10427d:	00 
  10427e:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  104285:	00 
  104286:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  10428d:	e8 86 c9 ff ff       	call   100c18 <__panic>
    assert(alloc_page() == NULL);
  104292:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104299:	e8 e8 07 00 00       	call   104a86 <alloc_pages>
  10429e:	85 c0                	test   %eax,%eax
  1042a0:	74 24                	je     1042c6 <default_check+0x204>
  1042a2:	c7 44 24 0c 9a 76 10 	movl   $0x10769a,0xc(%esp)
  1042a9:	00 
  1042aa:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  1042b1:	00 
  1042b2:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
  1042b9:	00 
  1042ba:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  1042c1:	e8 52 c9 ff ff       	call   100c18 <__panic>

    unsigned int nr_free_store = nr_free;
  1042c6:	a1 ac d0 11 00       	mov    0x11d0ac,%eax
  1042cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  1042ce:	c7 05 ac d0 11 00 00 	movl   $0x0,0x11d0ac
  1042d5:	00 00 00 

    free_pages(p0 + 2, 3);
  1042d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1042db:	83 c0 28             	add    $0x28,%eax
  1042de:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1042e5:	00 
  1042e6:	89 04 24             	mov    %eax,(%esp)
  1042e9:	e8 d0 07 00 00       	call   104abe <free_pages>
    assert(alloc_pages(4) == NULL);
  1042ee:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1042f5:	e8 8c 07 00 00       	call   104a86 <alloc_pages>
  1042fa:	85 c0                	test   %eax,%eax
  1042fc:	74 24                	je     104322 <default_check+0x260>
  1042fe:	c7 44 24 0c 40 77 10 	movl   $0x107740,0xc(%esp)
  104305:	00 
  104306:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  10430d:	00 
  10430e:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  104315:	00 
  104316:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  10431d:	e8 f6 c8 ff ff       	call   100c18 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104322:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104325:	83 c0 28             	add    $0x28,%eax
  104328:	83 c0 04             	add    $0x4,%eax
  10432b:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  104332:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104335:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104338:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10433b:	0f a3 10             	bt     %edx,(%eax)
  10433e:	19 c0                	sbb    %eax,%eax
  104340:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  104343:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  104347:	0f 95 c0             	setne  %al
  10434a:	0f b6 c0             	movzbl %al,%eax
  10434d:	85 c0                	test   %eax,%eax
  10434f:	74 0e                	je     10435f <default_check+0x29d>
  104351:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104354:	83 c0 28             	add    $0x28,%eax
  104357:	8b 40 08             	mov    0x8(%eax),%eax
  10435a:	83 f8 03             	cmp    $0x3,%eax
  10435d:	74 24                	je     104383 <default_check+0x2c1>
  10435f:	c7 44 24 0c 58 77 10 	movl   $0x107758,0xc(%esp)
  104366:	00 
  104367:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  10436e:	00 
  10436f:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  104376:	00 
  104377:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  10437e:	e8 95 c8 ff ff       	call   100c18 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  104383:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  10438a:	e8 f7 06 00 00       	call   104a86 <alloc_pages>
  10438f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104392:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104396:	75 24                	jne    1043bc <default_check+0x2fa>
  104398:	c7 44 24 0c 84 77 10 	movl   $0x107784,0xc(%esp)
  10439f:	00 
  1043a0:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  1043a7:	00 
  1043a8:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  1043af:	00 
  1043b0:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  1043b7:	e8 5c c8 ff ff       	call   100c18 <__panic>
    assert(alloc_page() == NULL);
  1043bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1043c3:	e8 be 06 00 00       	call   104a86 <alloc_pages>
  1043c8:	85 c0                	test   %eax,%eax
  1043ca:	74 24                	je     1043f0 <default_check+0x32e>
  1043cc:	c7 44 24 0c 9a 76 10 	movl   $0x10769a,0xc(%esp)
  1043d3:	00 
  1043d4:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  1043db:	00 
  1043dc:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  1043e3:	00 
  1043e4:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  1043eb:	e8 28 c8 ff ff       	call   100c18 <__panic>
    assert(p0 + 2 == p1);
  1043f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043f3:	83 c0 28             	add    $0x28,%eax
  1043f6:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1043f9:	74 24                	je     10441f <default_check+0x35d>
  1043fb:	c7 44 24 0c a2 77 10 	movl   $0x1077a2,0xc(%esp)
  104402:	00 
  104403:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  10440a:	00 
  10440b:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  104412:	00 
  104413:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  10441a:	e8 f9 c7 ff ff       	call   100c18 <__panic>

    p2 = p0 + 1;
  10441f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104422:	83 c0 14             	add    $0x14,%eax
  104425:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  104428:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10442f:	00 
  104430:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104433:	89 04 24             	mov    %eax,(%esp)
  104436:	e8 83 06 00 00       	call   104abe <free_pages>
    free_pages(p1, 3);
  10443b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104442:	00 
  104443:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104446:	89 04 24             	mov    %eax,(%esp)
  104449:	e8 70 06 00 00       	call   104abe <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  10444e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104451:	83 c0 04             	add    $0x4,%eax
  104454:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  10445b:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10445e:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104461:	8b 55 a0             	mov    -0x60(%ebp),%edx
  104464:	0f a3 10             	bt     %edx,(%eax)
  104467:	19 c0                	sbb    %eax,%eax
  104469:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  10446c:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  104470:	0f 95 c0             	setne  %al
  104473:	0f b6 c0             	movzbl %al,%eax
  104476:	85 c0                	test   %eax,%eax
  104478:	74 0b                	je     104485 <default_check+0x3c3>
  10447a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10447d:	8b 40 08             	mov    0x8(%eax),%eax
  104480:	83 f8 01             	cmp    $0x1,%eax
  104483:	74 24                	je     1044a9 <default_check+0x3e7>
  104485:	c7 44 24 0c b0 77 10 	movl   $0x1077b0,0xc(%esp)
  10448c:	00 
  10448d:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  104494:	00 
  104495:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  10449c:	00 
  10449d:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  1044a4:	e8 6f c7 ff ff       	call   100c18 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1044a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1044ac:	83 c0 04             	add    $0x4,%eax
  1044af:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  1044b6:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1044b9:	8b 45 90             	mov    -0x70(%ebp),%eax
  1044bc:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1044bf:	0f a3 10             	bt     %edx,(%eax)
  1044c2:	19 c0                	sbb    %eax,%eax
  1044c4:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  1044c7:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  1044cb:	0f 95 c0             	setne  %al
  1044ce:	0f b6 c0             	movzbl %al,%eax
  1044d1:	85 c0                	test   %eax,%eax
  1044d3:	74 0b                	je     1044e0 <default_check+0x41e>
  1044d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1044d8:	8b 40 08             	mov    0x8(%eax),%eax
  1044db:	83 f8 03             	cmp    $0x3,%eax
  1044de:	74 24                	je     104504 <default_check+0x442>
  1044e0:	c7 44 24 0c d8 77 10 	movl   $0x1077d8,0xc(%esp)
  1044e7:	00 
  1044e8:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  1044ef:	00 
  1044f0:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  1044f7:	00 
  1044f8:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  1044ff:	e8 14 c7 ff ff       	call   100c18 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  104504:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10450b:	e8 76 05 00 00       	call   104a86 <alloc_pages>
  104510:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104513:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104516:	83 e8 14             	sub    $0x14,%eax
  104519:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10451c:	74 24                	je     104542 <default_check+0x480>
  10451e:	c7 44 24 0c fe 77 10 	movl   $0x1077fe,0xc(%esp)
  104525:	00 
  104526:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  10452d:	00 
  10452e:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  104535:	00 
  104536:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  10453d:	e8 d6 c6 ff ff       	call   100c18 <__panic>
    free_page(p0);
  104542:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104549:	00 
  10454a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10454d:	89 04 24             	mov    %eax,(%esp)
  104550:	e8 69 05 00 00       	call   104abe <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  104555:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10455c:	e8 25 05 00 00       	call   104a86 <alloc_pages>
  104561:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104564:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104567:	83 c0 14             	add    $0x14,%eax
  10456a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10456d:	74 24                	je     104593 <default_check+0x4d1>
  10456f:	c7 44 24 0c 1c 78 10 	movl   $0x10781c,0xc(%esp)
  104576:	00 
  104577:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  10457e:	00 
  10457f:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  104586:	00 
  104587:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  10458e:	e8 85 c6 ff ff       	call   100c18 <__panic>

    free_pages(p0, 2);
  104593:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10459a:	00 
  10459b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10459e:	89 04 24             	mov    %eax,(%esp)
  1045a1:	e8 18 05 00 00       	call   104abe <free_pages>
    free_page(p2);
  1045a6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1045ad:	00 
  1045ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1045b1:	89 04 24             	mov    %eax,(%esp)
  1045b4:	e8 05 05 00 00       	call   104abe <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1045b9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1045c0:	e8 c1 04 00 00       	call   104a86 <alloc_pages>
  1045c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1045c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1045cc:	75 24                	jne    1045f2 <default_check+0x530>
  1045ce:	c7 44 24 0c 3c 78 10 	movl   $0x10783c,0xc(%esp)
  1045d5:	00 
  1045d6:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  1045dd:	00 
  1045de:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  1045e5:	00 
  1045e6:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  1045ed:	e8 26 c6 ff ff       	call   100c18 <__panic>
    assert(alloc_page() == NULL);
  1045f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1045f9:	e8 88 04 00 00       	call   104a86 <alloc_pages>
  1045fe:	85 c0                	test   %eax,%eax
  104600:	74 24                	je     104626 <default_check+0x564>
  104602:	c7 44 24 0c 9a 76 10 	movl   $0x10769a,0xc(%esp)
  104609:	00 
  10460a:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  104611:	00 
  104612:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  104619:	00 
  10461a:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  104621:	e8 f2 c5 ff ff       	call   100c18 <__panic>

    assert(nr_free == 0);
  104626:	a1 ac d0 11 00       	mov    0x11d0ac,%eax
  10462b:	85 c0                	test   %eax,%eax
  10462d:	74 24                	je     104653 <default_check+0x591>
  10462f:	c7 44 24 0c ed 76 10 	movl   $0x1076ed,0xc(%esp)
  104636:	00 
  104637:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  10463e:	00 
  10463f:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  104646:	00 
  104647:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  10464e:	e8 c5 c5 ff ff       	call   100c18 <__panic>
    nr_free = nr_free_store;
  104653:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104656:	a3 ac d0 11 00       	mov    %eax,0x11d0ac

    free_list = free_list_store;
  10465b:	8b 45 80             	mov    -0x80(%ebp),%eax
  10465e:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104661:	a3 a4 d0 11 00       	mov    %eax,0x11d0a4
  104666:	89 15 a8 d0 11 00    	mov    %edx,0x11d0a8
    free_pages(p0, 5);
  10466c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  104673:	00 
  104674:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104677:	89 04 24             	mov    %eax,(%esp)
  10467a:	e8 3f 04 00 00       	call   104abe <free_pages>

    le = &free_list;
  10467f:	c7 45 ec a4 d0 11 00 	movl   $0x11d0a4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104686:	eb 5b                	jmp    1046e3 <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
  104688:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10468b:	8b 40 04             	mov    0x4(%eax),%eax
  10468e:	8b 00                	mov    (%eax),%eax
  104690:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104693:	75 0d                	jne    1046a2 <default_check+0x5e0>
  104695:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104698:	8b 00                	mov    (%eax),%eax
  10469a:	8b 40 04             	mov    0x4(%eax),%eax
  10469d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1046a0:	74 24                	je     1046c6 <default_check+0x604>
  1046a2:	c7 44 24 0c 5c 78 10 	movl   $0x10785c,0xc(%esp)
  1046a9:	00 
  1046aa:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  1046b1:	00 
  1046b2:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  1046b9:	00 
  1046ba:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  1046c1:	e8 52 c5 ff ff       	call   100c18 <__panic>
        struct Page *p = le2page(le, page_link);
  1046c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1046c9:	83 e8 0c             	sub    $0xc,%eax
  1046cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  1046cf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1046d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1046d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1046d9:	8b 40 08             	mov    0x8(%eax),%eax
  1046dc:	29 c2                	sub    %eax,%edx
  1046de:	89 d0                	mov    %edx,%eax
  1046e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1046e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1046e6:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1046e9:	8b 45 88             	mov    -0x78(%ebp),%eax
  1046ec:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1046ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1046f2:	81 7d ec a4 d0 11 00 	cmpl   $0x11d0a4,-0x14(%ebp)
  1046f9:	75 8d                	jne    104688 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  1046fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1046ff:	74 24                	je     104725 <default_check+0x663>
  104701:	c7 44 24 0c 89 78 10 	movl   $0x107889,0xc(%esp)
  104708:	00 
  104709:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  104710:	00 
  104711:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
  104718:	00 
  104719:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  104720:	e8 f3 c4 ff ff       	call   100c18 <__panic>
    assert(total == 0);
  104725:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104729:	74 24                	je     10474f <default_check+0x68d>
  10472b:	c7 44 24 0c 94 78 10 	movl   $0x107894,0xc(%esp)
  104732:	00 
  104733:	c7 44 24 08 12 75 10 	movl   $0x107512,0x8(%esp)
  10473a:	00 
  10473b:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  104742:	00 
  104743:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  10474a:	e8 c9 c4 ff ff       	call   100c18 <__panic>
}
  10474f:	81 c4 94 00 00 00    	add    $0x94,%esp
  104755:	5b                   	pop    %ebx
  104756:	5d                   	pop    %ebp
  104757:	c3                   	ret    

00104758 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  104758:	55                   	push   %ebp
  104759:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10475b:	8b 55 08             	mov    0x8(%ebp),%edx
  10475e:	a1 b8 d0 11 00       	mov    0x11d0b8,%eax
  104763:	29 c2                	sub    %eax,%edx
  104765:	89 d0                	mov    %edx,%eax
  104767:	c1 f8 02             	sar    $0x2,%eax
  10476a:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  104770:	5d                   	pop    %ebp
  104771:	c3                   	ret    

00104772 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  104772:	55                   	push   %ebp
  104773:	89 e5                	mov    %esp,%ebp
  104775:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104778:	8b 45 08             	mov    0x8(%ebp),%eax
  10477b:	89 04 24             	mov    %eax,(%esp)
  10477e:	e8 d5 ff ff ff       	call   104758 <page2ppn>
  104783:	c1 e0 0c             	shl    $0xc,%eax
}
  104786:	c9                   	leave  
  104787:	c3                   	ret    

00104788 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  104788:	55                   	push   %ebp
  104789:	89 e5                	mov    %esp,%ebp
  10478b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  10478e:	8b 45 08             	mov    0x8(%ebp),%eax
  104791:	c1 e8 0c             	shr    $0xc,%eax
  104794:	89 c2                	mov    %eax,%edx
  104796:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  10479b:	39 c2                	cmp    %eax,%edx
  10479d:	72 1c                	jb     1047bb <pa2page+0x33>
        panic("pa2page called with invalid pa");
  10479f:	c7 44 24 08 d0 78 10 	movl   $0x1078d0,0x8(%esp)
  1047a6:	00 
  1047a7:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  1047ae:	00 
  1047af:	c7 04 24 ef 78 10 00 	movl   $0x1078ef,(%esp)
  1047b6:	e8 5d c4 ff ff       	call   100c18 <__panic>
    }
    return &pages[PPN(pa)];
  1047bb:	8b 0d b8 d0 11 00    	mov    0x11d0b8,%ecx
  1047c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1047c4:	c1 e8 0c             	shr    $0xc,%eax
  1047c7:	89 c2                	mov    %eax,%edx
  1047c9:	89 d0                	mov    %edx,%eax
  1047cb:	c1 e0 02             	shl    $0x2,%eax
  1047ce:	01 d0                	add    %edx,%eax
  1047d0:	c1 e0 02             	shl    $0x2,%eax
  1047d3:	01 c8                	add    %ecx,%eax
}
  1047d5:	c9                   	leave  
  1047d6:	c3                   	ret    

001047d7 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  1047d7:	55                   	push   %ebp
  1047d8:	89 e5                	mov    %esp,%ebp
  1047da:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  1047dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1047e0:	89 04 24             	mov    %eax,(%esp)
  1047e3:	e8 8a ff ff ff       	call   104772 <page2pa>
  1047e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1047eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047ee:	c1 e8 0c             	shr    $0xc,%eax
  1047f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1047f4:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  1047f9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1047fc:	72 23                	jb     104821 <page2kva+0x4a>
  1047fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104801:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104805:	c7 44 24 08 00 79 10 	movl   $0x107900,0x8(%esp)
  10480c:	00 
  10480d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  104814:	00 
  104815:	c7 04 24 ef 78 10 00 	movl   $0x1078ef,(%esp)
  10481c:	e8 f7 c3 ff ff       	call   100c18 <__panic>
  104821:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104824:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  104829:	c9                   	leave  
  10482a:	c3                   	ret    

0010482b <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  10482b:	55                   	push   %ebp
  10482c:	89 e5                	mov    %esp,%ebp
  10482e:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  104831:	8b 45 08             	mov    0x8(%ebp),%eax
  104834:	83 e0 01             	and    $0x1,%eax
  104837:	85 c0                	test   %eax,%eax
  104839:	75 1c                	jne    104857 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  10483b:	c7 44 24 08 24 79 10 	movl   $0x107924,0x8(%esp)
  104842:	00 
  104843:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  10484a:	00 
  10484b:	c7 04 24 ef 78 10 00 	movl   $0x1078ef,(%esp)
  104852:	e8 c1 c3 ff ff       	call   100c18 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  104857:	8b 45 08             	mov    0x8(%ebp),%eax
  10485a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10485f:	89 04 24             	mov    %eax,(%esp)
  104862:	e8 21 ff ff ff       	call   104788 <pa2page>
}
  104867:	c9                   	leave  
  104868:	c3                   	ret    

00104869 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  104869:	55                   	push   %ebp
  10486a:	89 e5                	mov    %esp,%ebp
  10486c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  10486f:	8b 45 08             	mov    0x8(%ebp),%eax
  104872:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104877:	89 04 24             	mov    %eax,(%esp)
  10487a:	e8 09 ff ff ff       	call   104788 <pa2page>
}
  10487f:	c9                   	leave  
  104880:	c3                   	ret    

00104881 <page_ref>:

static inline int
page_ref(struct Page *page) {
  104881:	55                   	push   %ebp
  104882:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104884:	8b 45 08             	mov    0x8(%ebp),%eax
  104887:	8b 00                	mov    (%eax),%eax
}
  104889:	5d                   	pop    %ebp
  10488a:	c3                   	ret    

0010488b <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  10488b:	55                   	push   %ebp
  10488c:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  10488e:	8b 45 08             	mov    0x8(%ebp),%eax
  104891:	8b 55 0c             	mov    0xc(%ebp),%edx
  104894:	89 10                	mov    %edx,(%eax)
}
  104896:	5d                   	pop    %ebp
  104897:	c3                   	ret    

00104898 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  104898:	55                   	push   %ebp
  104899:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  10489b:	8b 45 08             	mov    0x8(%ebp),%eax
  10489e:	8b 00                	mov    (%eax),%eax
  1048a0:	8d 50 01             	lea    0x1(%eax),%edx
  1048a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1048a6:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1048a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1048ab:	8b 00                	mov    (%eax),%eax
}
  1048ad:	5d                   	pop    %ebp
  1048ae:	c3                   	ret    

001048af <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  1048af:	55                   	push   %ebp
  1048b0:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  1048b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1048b5:	8b 00                	mov    (%eax),%eax
  1048b7:	8d 50 ff             	lea    -0x1(%eax),%edx
  1048ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1048bd:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1048bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1048c2:	8b 00                	mov    (%eax),%eax
}
  1048c4:	5d                   	pop    %ebp
  1048c5:	c3                   	ret    

001048c6 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  1048c6:	55                   	push   %ebp
  1048c7:	89 e5                	mov    %esp,%ebp
  1048c9:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  1048cc:	9c                   	pushf  
  1048cd:	58                   	pop    %eax
  1048ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  1048d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  1048d4:	25 00 02 00 00       	and    $0x200,%eax
  1048d9:	85 c0                	test   %eax,%eax
  1048db:	74 0c                	je     1048e9 <__intr_save+0x23>
        intr_disable();
  1048dd:	e8 2a cd ff ff       	call   10160c <intr_disable>
        return 1;
  1048e2:	b8 01 00 00 00       	mov    $0x1,%eax
  1048e7:	eb 05                	jmp    1048ee <__intr_save+0x28>
    }
    return 0;
  1048e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1048ee:	c9                   	leave  
  1048ef:	c3                   	ret    

001048f0 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  1048f0:	55                   	push   %ebp
  1048f1:	89 e5                	mov    %esp,%ebp
  1048f3:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  1048f6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1048fa:	74 05                	je     104901 <__intr_restore+0x11>
        intr_enable();
  1048fc:	e8 05 cd ff ff       	call   101606 <intr_enable>
    }
}
  104901:	c9                   	leave  
  104902:	c3                   	ret    

00104903 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  104903:	55                   	push   %ebp
  104904:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  104906:	8b 45 08             	mov    0x8(%ebp),%eax
  104909:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  10490c:	b8 23 00 00 00       	mov    $0x23,%eax
  104911:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  104913:	b8 23 00 00 00       	mov    $0x23,%eax
  104918:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  10491a:	b8 10 00 00 00       	mov    $0x10,%eax
  10491f:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  104921:	b8 10 00 00 00       	mov    $0x10,%eax
  104926:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  104928:	b8 10 00 00 00       	mov    $0x10,%eax
  10492d:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  10492f:	ea 36 49 10 00 08 00 	ljmp   $0x8,$0x104936
}
  104936:	5d                   	pop    %ebp
  104937:	c3                   	ret    

00104938 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  104938:	55                   	push   %ebp
  104939:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  10493b:	8b 45 08             	mov    0x8(%ebp),%eax
  10493e:	a3 44 cf 11 00       	mov    %eax,0x11cf44
}
  104943:	5d                   	pop    %ebp
  104944:	c3                   	ret    

00104945 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  104945:	55                   	push   %ebp
  104946:	89 e5                	mov    %esp,%ebp
  104948:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  10494b:	b8 00 90 11 00       	mov    $0x119000,%eax
  104950:	89 04 24             	mov    %eax,(%esp)
  104953:	e8 e0 ff ff ff       	call   104938 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  104958:	66 c7 05 48 cf 11 00 	movw   $0x10,0x11cf48
  10495f:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  104961:	66 c7 05 28 9a 11 00 	movw   $0x68,0x119a28
  104968:	68 00 
  10496a:	b8 40 cf 11 00       	mov    $0x11cf40,%eax
  10496f:	66 a3 2a 9a 11 00    	mov    %ax,0x119a2a
  104975:	b8 40 cf 11 00       	mov    $0x11cf40,%eax
  10497a:	c1 e8 10             	shr    $0x10,%eax
  10497d:	a2 2c 9a 11 00       	mov    %al,0x119a2c
  104982:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  104989:	83 e0 f0             	and    $0xfffffff0,%eax
  10498c:	83 c8 09             	or     $0x9,%eax
  10498f:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  104994:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  10499b:	83 e0 ef             	and    $0xffffffef,%eax
  10499e:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  1049a3:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  1049aa:	83 e0 9f             	and    $0xffffff9f,%eax
  1049ad:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  1049b2:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  1049b9:	83 c8 80             	or     $0xffffff80,%eax
  1049bc:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  1049c1:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  1049c8:	83 e0 f0             	and    $0xfffffff0,%eax
  1049cb:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  1049d0:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  1049d7:	83 e0 ef             	and    $0xffffffef,%eax
  1049da:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  1049df:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  1049e6:	83 e0 df             	and    $0xffffffdf,%eax
  1049e9:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  1049ee:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  1049f5:	83 c8 40             	or     $0x40,%eax
  1049f8:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  1049fd:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  104a04:	83 e0 7f             	and    $0x7f,%eax
  104a07:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  104a0c:	b8 40 cf 11 00       	mov    $0x11cf40,%eax
  104a11:	c1 e8 18             	shr    $0x18,%eax
  104a14:	a2 2f 9a 11 00       	mov    %al,0x119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  104a19:	c7 04 24 30 9a 11 00 	movl   $0x119a30,(%esp)
  104a20:	e8 de fe ff ff       	call   104903 <lgdt>
  104a25:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  104a2b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  104a2f:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  104a32:	c9                   	leave  
  104a33:	c3                   	ret    

00104a34 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  104a34:	55                   	push   %ebp
  104a35:	89 e5                	mov    %esp,%ebp
  104a37:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &buddy_pmm_manager;
  104a3a:	c7 05 b0 d0 11 00 f0 	movl   $0x1074f0,0x11d0b0
  104a41:	74 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  104a44:	a1 b0 d0 11 00       	mov    0x11d0b0,%eax
  104a49:	8b 00                	mov    (%eax),%eax
  104a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a4f:	c7 04 24 50 79 10 00 	movl   $0x107950,(%esp)
  104a56:	e8 ed b8 ff ff       	call   100348 <cprintf>
    pmm_manager->init();
  104a5b:	a1 b0 d0 11 00       	mov    0x11d0b0,%eax
  104a60:	8b 40 04             	mov    0x4(%eax),%eax
  104a63:	ff d0                	call   *%eax
}
  104a65:	c9                   	leave  
  104a66:	c3                   	ret    

00104a67 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  104a67:	55                   	push   %ebp
  104a68:	89 e5                	mov    %esp,%ebp
  104a6a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  104a6d:	a1 b0 d0 11 00       	mov    0x11d0b0,%eax
  104a72:	8b 40 08             	mov    0x8(%eax),%eax
  104a75:	8b 55 0c             	mov    0xc(%ebp),%edx
  104a78:	89 54 24 04          	mov    %edx,0x4(%esp)
  104a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  104a7f:	89 14 24             	mov    %edx,(%esp)
  104a82:	ff d0                	call   *%eax
}
  104a84:	c9                   	leave  
  104a85:	c3                   	ret    

00104a86 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  104a86:	55                   	push   %ebp
  104a87:	89 e5                	mov    %esp,%ebp
  104a89:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  104a8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  104a93:	e8 2e fe ff ff       	call   1048c6 <__intr_save>
  104a98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  104a9b:	a1 b0 d0 11 00       	mov    0x11d0b0,%eax
  104aa0:	8b 40 0c             	mov    0xc(%eax),%eax
  104aa3:	8b 55 08             	mov    0x8(%ebp),%edx
  104aa6:	89 14 24             	mov    %edx,(%esp)
  104aa9:	ff d0                	call   *%eax
  104aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  104aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ab1:	89 04 24             	mov    %eax,(%esp)
  104ab4:	e8 37 fe ff ff       	call   1048f0 <__intr_restore>
    return page;
  104ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104abc:	c9                   	leave  
  104abd:	c3                   	ret    

00104abe <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  104abe:	55                   	push   %ebp
  104abf:	89 e5                	mov    %esp,%ebp
  104ac1:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  104ac4:	e8 fd fd ff ff       	call   1048c6 <__intr_save>
  104ac9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  104acc:	a1 b0 d0 11 00       	mov    0x11d0b0,%eax
  104ad1:	8b 40 10             	mov    0x10(%eax),%eax
  104ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
  104ad7:	89 54 24 04          	mov    %edx,0x4(%esp)
  104adb:	8b 55 08             	mov    0x8(%ebp),%edx
  104ade:	89 14 24             	mov    %edx,(%esp)
  104ae1:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  104ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ae6:	89 04 24             	mov    %eax,(%esp)
  104ae9:	e8 02 fe ff ff       	call   1048f0 <__intr_restore>
}
  104aee:	c9                   	leave  
  104aef:	c3                   	ret    

00104af0 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  104af0:	55                   	push   %ebp
  104af1:	89 e5                	mov    %esp,%ebp
  104af3:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  104af6:	e8 cb fd ff ff       	call   1048c6 <__intr_save>
  104afb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  104afe:	a1 b0 d0 11 00       	mov    0x11d0b0,%eax
  104b03:	8b 40 14             	mov    0x14(%eax),%eax
  104b06:	ff d0                	call   *%eax
  104b08:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  104b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b0e:	89 04 24             	mov    %eax,(%esp)
  104b11:	e8 da fd ff ff       	call   1048f0 <__intr_restore>
    return ret;
  104b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  104b19:	c9                   	leave  
  104b1a:	c3                   	ret    

00104b1b <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  104b1b:	55                   	push   %ebp
  104b1c:	89 e5                	mov    %esp,%ebp
  104b1e:	57                   	push   %edi
  104b1f:	56                   	push   %esi
  104b20:	53                   	push   %ebx
  104b21:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  104b27:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  104b2e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  104b35:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  104b3c:	c7 04 24 67 79 10 00 	movl   $0x107967,(%esp)
  104b43:	e8 00 b8 ff ff       	call   100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  104b48:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104b4f:	e9 15 01 00 00       	jmp    104c69 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104b54:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104b57:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104b5a:	89 d0                	mov    %edx,%eax
  104b5c:	c1 e0 02             	shl    $0x2,%eax
  104b5f:	01 d0                	add    %edx,%eax
  104b61:	c1 e0 02             	shl    $0x2,%eax
  104b64:	01 c8                	add    %ecx,%eax
  104b66:	8b 50 08             	mov    0x8(%eax),%edx
  104b69:	8b 40 04             	mov    0x4(%eax),%eax
  104b6c:	89 45 b8             	mov    %eax,-0x48(%ebp)
  104b6f:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104b72:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104b75:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104b78:	89 d0                	mov    %edx,%eax
  104b7a:	c1 e0 02             	shl    $0x2,%eax
  104b7d:	01 d0                	add    %edx,%eax
  104b7f:	c1 e0 02             	shl    $0x2,%eax
  104b82:	01 c8                	add    %ecx,%eax
  104b84:	8b 48 0c             	mov    0xc(%eax),%ecx
  104b87:	8b 58 10             	mov    0x10(%eax),%ebx
  104b8a:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104b8d:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104b90:	01 c8                	add    %ecx,%eax
  104b92:	11 da                	adc    %ebx,%edx
  104b94:	89 45 b0             	mov    %eax,-0x50(%ebp)
  104b97:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  104b9a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104b9d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104ba0:	89 d0                	mov    %edx,%eax
  104ba2:	c1 e0 02             	shl    $0x2,%eax
  104ba5:	01 d0                	add    %edx,%eax
  104ba7:	c1 e0 02             	shl    $0x2,%eax
  104baa:	01 c8                	add    %ecx,%eax
  104bac:	83 c0 14             	add    $0x14,%eax
  104baf:	8b 00                	mov    (%eax),%eax
  104bb1:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  104bb7:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104bba:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104bbd:	83 c0 ff             	add    $0xffffffff,%eax
  104bc0:	83 d2 ff             	adc    $0xffffffff,%edx
  104bc3:	89 c6                	mov    %eax,%esi
  104bc5:	89 d7                	mov    %edx,%edi
  104bc7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104bca:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104bcd:	89 d0                	mov    %edx,%eax
  104bcf:	c1 e0 02             	shl    $0x2,%eax
  104bd2:	01 d0                	add    %edx,%eax
  104bd4:	c1 e0 02             	shl    $0x2,%eax
  104bd7:	01 c8                	add    %ecx,%eax
  104bd9:	8b 48 0c             	mov    0xc(%eax),%ecx
  104bdc:	8b 58 10             	mov    0x10(%eax),%ebx
  104bdf:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  104be5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  104be9:	89 74 24 14          	mov    %esi,0x14(%esp)
  104bed:	89 7c 24 18          	mov    %edi,0x18(%esp)
  104bf1:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104bf4:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104bf7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104bfb:	89 54 24 10          	mov    %edx,0x10(%esp)
  104bff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104c03:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  104c07:	c7 04 24 74 79 10 00 	movl   $0x107974,(%esp)
  104c0e:	e8 35 b7 ff ff       	call   100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  104c13:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104c16:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104c19:	89 d0                	mov    %edx,%eax
  104c1b:	c1 e0 02             	shl    $0x2,%eax
  104c1e:	01 d0                	add    %edx,%eax
  104c20:	c1 e0 02             	shl    $0x2,%eax
  104c23:	01 c8                	add    %ecx,%eax
  104c25:	83 c0 14             	add    $0x14,%eax
  104c28:	8b 00                	mov    (%eax),%eax
  104c2a:	83 f8 01             	cmp    $0x1,%eax
  104c2d:	75 36                	jne    104c65 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  104c2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104c32:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104c35:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  104c38:	77 2b                	ja     104c65 <page_init+0x14a>
  104c3a:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  104c3d:	72 05                	jb     104c44 <page_init+0x129>
  104c3f:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  104c42:	73 21                	jae    104c65 <page_init+0x14a>
  104c44:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  104c48:	77 1b                	ja     104c65 <page_init+0x14a>
  104c4a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  104c4e:	72 09                	jb     104c59 <page_init+0x13e>
  104c50:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  104c57:	77 0c                	ja     104c65 <page_init+0x14a>
                maxpa = end;
  104c59:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104c5c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104c5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104c62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  104c65:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104c69:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104c6c:	8b 00                	mov    (%eax),%eax
  104c6e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  104c71:	0f 8f dd fe ff ff    	jg     104b54 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  104c77:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104c7b:	72 1d                	jb     104c9a <page_init+0x17f>
  104c7d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104c81:	77 09                	ja     104c8c <page_init+0x171>
  104c83:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  104c8a:	76 0e                	jbe    104c9a <page_init+0x17f>
        maxpa = KMEMSIZE;
  104c8c:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  104c93:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }
    extern char end[];

    npage = maxpa / PGSIZE;
  104c9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104c9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104ca0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104ca4:	c1 ea 0c             	shr    $0xc,%edx
  104ca7:	a3 20 cf 11 00       	mov    %eax,0x11cf20
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  104cac:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  104cb3:	b8 bc d0 11 00       	mov    $0x11d0bc,%eax
  104cb8:	8d 50 ff             	lea    -0x1(%eax),%edx
  104cbb:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104cbe:	01 d0                	add    %edx,%eax
  104cc0:	89 45 a8             	mov    %eax,-0x58(%ebp)
  104cc3:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104cc6:	ba 00 00 00 00       	mov    $0x0,%edx
  104ccb:	f7 75 ac             	divl   -0x54(%ebp)
  104cce:	89 d0                	mov    %edx,%eax
  104cd0:	8b 55 a8             	mov    -0x58(%ebp),%edx
  104cd3:	29 c2                	sub    %eax,%edx
  104cd5:	89 d0                	mov    %edx,%eax
  104cd7:	a3 b8 d0 11 00       	mov    %eax,0x11d0b8
    for (i = 0; i < npage; i ++) {
  104cdc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104ce3:	eb 2f                	jmp    104d14 <page_init+0x1f9>
        SetPageReserved(pages + i);
  104ce5:	8b 0d b8 d0 11 00    	mov    0x11d0b8,%ecx
  104ceb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104cee:	89 d0                	mov    %edx,%eax
  104cf0:	c1 e0 02             	shl    $0x2,%eax
  104cf3:	01 d0                	add    %edx,%eax
  104cf5:	c1 e0 02             	shl    $0x2,%eax
  104cf8:	01 c8                	add    %ecx,%eax
  104cfa:	83 c0 04             	add    $0x4,%eax
  104cfd:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  104d04:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104d07:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104d0a:	8b 55 90             	mov    -0x70(%ebp),%edx
  104d0d:	0f ab 10             	bts    %edx,(%eax)
    }
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
    for (i = 0; i < npage; i ++) {
  104d10:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104d14:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104d17:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  104d1c:	39 c2                	cmp    %eax,%edx
  104d1e:	72 c5                	jb     104ce5 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  104d20:	8b 15 20 cf 11 00    	mov    0x11cf20,%edx
  104d26:	89 d0                	mov    %edx,%eax
  104d28:	c1 e0 02             	shl    $0x2,%eax
  104d2b:	01 d0                	add    %edx,%eax
  104d2d:	c1 e0 02             	shl    $0x2,%eax
  104d30:	89 c2                	mov    %eax,%edx
  104d32:	a1 b8 d0 11 00       	mov    0x11d0b8,%eax
  104d37:	01 d0                	add    %edx,%eax
  104d39:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  104d3c:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  104d43:	77 23                	ja     104d68 <page_init+0x24d>
  104d45:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104d48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104d4c:	c7 44 24 08 a4 79 10 	movl   $0x1079a4,0x8(%esp)
  104d53:	00 
  104d54:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  104d5b:	00 
  104d5c:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  104d63:	e8 b0 be ff ff       	call   100c18 <__panic>
  104d68:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104d6b:	05 00 00 00 40       	add    $0x40000000,%eax
  104d70:	89 45 a0             	mov    %eax,-0x60(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  104d73:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104d7a:	e9 74 01 00 00       	jmp    104ef3 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104d7f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104d82:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104d85:	89 d0                	mov    %edx,%eax
  104d87:	c1 e0 02             	shl    $0x2,%eax
  104d8a:	01 d0                	add    %edx,%eax
  104d8c:	c1 e0 02             	shl    $0x2,%eax
  104d8f:	01 c8                	add    %ecx,%eax
  104d91:	8b 50 08             	mov    0x8(%eax),%edx
  104d94:	8b 40 04             	mov    0x4(%eax),%eax
  104d97:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104d9a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104d9d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104da0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104da3:	89 d0                	mov    %edx,%eax
  104da5:	c1 e0 02             	shl    $0x2,%eax
  104da8:	01 d0                	add    %edx,%eax
  104daa:	c1 e0 02             	shl    $0x2,%eax
  104dad:	01 c8                	add    %ecx,%eax
  104daf:	8b 48 0c             	mov    0xc(%eax),%ecx
  104db2:	8b 58 10             	mov    0x10(%eax),%ebx
  104db5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104db8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104dbb:	01 c8                	add    %ecx,%eax
  104dbd:	11 da                	adc    %ebx,%edx
  104dbf:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104dc2:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  104dc5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104dc8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104dcb:	89 d0                	mov    %edx,%eax
  104dcd:	c1 e0 02             	shl    $0x2,%eax
  104dd0:	01 d0                	add    %edx,%eax
  104dd2:	c1 e0 02             	shl    $0x2,%eax
  104dd5:	01 c8                	add    %ecx,%eax
  104dd7:	83 c0 14             	add    $0x14,%eax
  104dda:	8b 00                	mov    (%eax),%eax
  104ddc:	83 f8 01             	cmp    $0x1,%eax
  104ddf:	0f 85 0a 01 00 00    	jne    104eef <page_init+0x3d4>
            if (begin < freemem) {
  104de5:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104de8:	ba 00 00 00 00       	mov    $0x0,%edx
  104ded:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104df0:	72 17                	jb     104e09 <page_init+0x2ee>
  104df2:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104df5:	77 05                	ja     104dfc <page_init+0x2e1>
  104df7:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  104dfa:	76 0d                	jbe    104e09 <page_init+0x2ee>
                begin = freemem;
  104dfc:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104dff:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104e02:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  104e09:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  104e0d:	72 1d                	jb     104e2c <page_init+0x311>
  104e0f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  104e13:	77 09                	ja     104e1e <page_init+0x303>
  104e15:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  104e1c:	76 0e                	jbe    104e2c <page_init+0x311>
                end = KMEMSIZE;
  104e1e:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  104e25:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  104e2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104e2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104e32:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104e35:	0f 87 b4 00 00 00    	ja     104eef <page_init+0x3d4>
  104e3b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104e3e:	72 09                	jb     104e49 <page_init+0x32e>
  104e40:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104e43:	0f 83 a6 00 00 00    	jae    104eef <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  104e49:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  104e50:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104e53:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104e56:	01 d0                	add    %edx,%eax
  104e58:	83 e8 01             	sub    $0x1,%eax
  104e5b:	89 45 98             	mov    %eax,-0x68(%ebp)
  104e5e:	8b 45 98             	mov    -0x68(%ebp),%eax
  104e61:	ba 00 00 00 00       	mov    $0x0,%edx
  104e66:	f7 75 9c             	divl   -0x64(%ebp)
  104e69:	89 d0                	mov    %edx,%eax
  104e6b:	8b 55 98             	mov    -0x68(%ebp),%edx
  104e6e:	29 c2                	sub    %eax,%edx
  104e70:	89 d0                	mov    %edx,%eax
  104e72:	ba 00 00 00 00       	mov    $0x0,%edx
  104e77:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104e7a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  104e7d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104e80:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104e83:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104e86:	ba 00 00 00 00       	mov    $0x0,%edx
  104e8b:	89 c7                	mov    %eax,%edi
  104e8d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  104e93:	89 7d 80             	mov    %edi,-0x80(%ebp)
  104e96:	89 d0                	mov    %edx,%eax
  104e98:	83 e0 00             	and    $0x0,%eax
  104e9b:	89 45 84             	mov    %eax,-0x7c(%ebp)
  104e9e:	8b 45 80             	mov    -0x80(%ebp),%eax
  104ea1:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104ea4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104ea7:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  104eaa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104ead:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104eb0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104eb3:	77 3a                	ja     104eef <page_init+0x3d4>
  104eb5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104eb8:	72 05                	jb     104ebf <page_init+0x3a4>
  104eba:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104ebd:	73 30                	jae    104eef <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  104ebf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  104ec2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  104ec5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104ec8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104ecb:	29 c8                	sub    %ecx,%eax
  104ecd:	19 da                	sbb    %ebx,%edx
  104ecf:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104ed3:	c1 ea 0c             	shr    $0xc,%edx
  104ed6:	89 c3                	mov    %eax,%ebx
  104ed8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104edb:	89 04 24             	mov    %eax,(%esp)
  104ede:	e8 a5 f8 ff ff       	call   104788 <pa2page>
  104ee3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104ee7:	89 04 24             	mov    %eax,(%esp)
  104eea:	e8 78 fb ff ff       	call   104a67 <init_memmap>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
    for (i = 0; i < npage; i ++) {
        SetPageReserved(pages + i);
    }
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
    for (i = 0; i < memmap->nr_map; i ++) {
  104eef:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104ef3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104ef6:	8b 00                	mov    (%eax),%eax
  104ef8:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  104efb:	0f 8f 7e fe ff ff    	jg     104d7f <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  104f01:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  104f07:	5b                   	pop    %ebx
  104f08:	5e                   	pop    %esi
  104f09:	5f                   	pop    %edi
  104f0a:	5d                   	pop    %ebp
  104f0b:	c3                   	ret    

00104f0c <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  104f0c:	55                   	push   %ebp
  104f0d:	89 e5                	mov    %esp,%ebp
  104f0f:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  104f12:	8b 45 14             	mov    0x14(%ebp),%eax
  104f15:	8b 55 0c             	mov    0xc(%ebp),%edx
  104f18:	31 d0                	xor    %edx,%eax
  104f1a:	25 ff 0f 00 00       	and    $0xfff,%eax
  104f1f:	85 c0                	test   %eax,%eax
  104f21:	74 24                	je     104f47 <boot_map_segment+0x3b>
  104f23:	c7 44 24 0c d6 79 10 	movl   $0x1079d6,0xc(%esp)
  104f2a:	00 
  104f2b:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  104f32:	00 
  104f33:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
  104f3a:	00 
  104f3b:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  104f42:	e8 d1 bc ff ff       	call   100c18 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  104f47:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  104f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  104f51:	25 ff 0f 00 00       	and    $0xfff,%eax
  104f56:	89 c2                	mov    %eax,%edx
  104f58:	8b 45 10             	mov    0x10(%ebp),%eax
  104f5b:	01 c2                	add    %eax,%edx
  104f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f60:	01 d0                	add    %edx,%eax
  104f62:	83 e8 01             	sub    $0x1,%eax
  104f65:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104f68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104f6b:	ba 00 00 00 00       	mov    $0x0,%edx
  104f70:	f7 75 f0             	divl   -0x10(%ebp)
  104f73:	89 d0                	mov    %edx,%eax
  104f75:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104f78:	29 c2                	sub    %eax,%edx
  104f7a:	89 d0                	mov    %edx,%eax
  104f7c:	c1 e8 0c             	shr    $0xc,%eax
  104f7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  104f82:	8b 45 0c             	mov    0xc(%ebp),%eax
  104f85:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104f88:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f90:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  104f93:	8b 45 14             	mov    0x14(%ebp),%eax
  104f96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104f99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f9c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104fa1:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104fa4:	eb 6b                	jmp    105011 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  104fa6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104fad:	00 
  104fae:	8b 45 0c             	mov    0xc(%ebp),%eax
  104fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  104fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  104fb8:	89 04 24             	mov    %eax,(%esp)
  104fbb:	e8 82 01 00 00       	call   105142 <get_pte>
  104fc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  104fc3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104fc7:	75 24                	jne    104fed <boot_map_segment+0xe1>
  104fc9:	c7 44 24 0c 02 7a 10 	movl   $0x107a02,0xc(%esp)
  104fd0:	00 
  104fd1:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  104fd8:	00 
  104fd9:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
  104fe0:	00 
  104fe1:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  104fe8:	e8 2b bc ff ff       	call   100c18 <__panic>
        *ptep = pa | PTE_P | perm;
  104fed:	8b 45 18             	mov    0x18(%ebp),%eax
  104ff0:	8b 55 14             	mov    0x14(%ebp),%edx
  104ff3:	09 d0                	or     %edx,%eax
  104ff5:	83 c8 01             	or     $0x1,%eax
  104ff8:	89 c2                	mov    %eax,%edx
  104ffa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104ffd:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104fff:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  105003:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10500a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  105011:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105015:	75 8f                	jne    104fa6 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  105017:	c9                   	leave  
  105018:	c3                   	ret    

00105019 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  105019:	55                   	push   %ebp
  10501a:	89 e5                	mov    %esp,%ebp
  10501c:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  10501f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105026:	e8 5b fa ff ff       	call   104a86 <alloc_pages>
  10502b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  10502e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105032:	75 1c                	jne    105050 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  105034:	c7 44 24 08 0f 7a 10 	movl   $0x107a0f,0x8(%esp)
  10503b:	00 
  10503c:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  105043:	00 
  105044:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  10504b:	e8 c8 bb ff ff       	call   100c18 <__panic>
    }
    return page2kva(p);
  105050:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105053:	89 04 24             	mov    %eax,(%esp)
  105056:	e8 7c f7 ff ff       	call   1047d7 <page2kva>
}
  10505b:	c9                   	leave  
  10505c:	c3                   	ret    

0010505d <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10505d:	55                   	push   %ebp
  10505e:	89 e5                	mov    %esp,%ebp
  105060:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  105063:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105068:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10506b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  105072:	77 23                	ja     105097 <pmm_init+0x3a>
  105074:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105077:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10507b:	c7 44 24 08 a4 79 10 	movl   $0x1079a4,0x8(%esp)
  105082:	00 
  105083:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  10508a:	00 
  10508b:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105092:	e8 81 bb ff ff       	call   100c18 <__panic>
  105097:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10509a:	05 00 00 00 40       	add    $0x40000000,%eax
  10509f:	a3 b4 d0 11 00       	mov    %eax,0x11d0b4
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1050a4:	e8 8b f9 ff ff       	call   104a34 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1050a9:	e8 6d fa ff ff       	call   104b1b <page_init>
    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1050ae:	e8 db 03 00 00       	call   10548e <check_alloc_page>

    check_pgdir();
  1050b3:	e8 f4 03 00 00       	call   1054ac <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1050b8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1050bd:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  1050c3:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1050c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1050cb:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1050d2:	77 23                	ja     1050f7 <pmm_init+0x9a>
  1050d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1050d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1050db:	c7 44 24 08 a4 79 10 	movl   $0x1079a4,0x8(%esp)
  1050e2:	00 
  1050e3:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  1050ea:	00 
  1050eb:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1050f2:	e8 21 bb ff ff       	call   100c18 <__panic>
  1050f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1050fa:	05 00 00 00 40       	add    $0x40000000,%eax
  1050ff:	83 c8 03             	or     $0x3,%eax
  105102:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  105104:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105109:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  105110:	00 
  105111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  105118:	00 
  105119:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  105120:	38 
  105121:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  105128:	c0 
  105129:	89 04 24             	mov    %eax,(%esp)
  10512c:	e8 db fd ff ff       	call   104f0c <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  105131:	e8 0f f8 ff ff       	call   104945 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  105136:	e8 0c 0a 00 00       	call   105b47 <check_boot_pgdir>

    print_pgdir();
  10513b:	e8 94 0e 00 00       	call   105fd4 <print_pgdir>

}
  105140:	c9                   	leave  
  105141:	c3                   	ret    

00105142 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  105142:	55                   	push   %ebp
  105143:	89 e5                	mov    %esp,%ebp
  105145:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
  105148:	8b 45 0c             	mov    0xc(%ebp),%eax
  10514b:	c1 e8 16             	shr    $0x16,%eax
  10514e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105155:	8b 45 08             	mov    0x8(%ebp),%eax
  105158:	01 d0                	add    %edx,%eax
  10515a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
  10515d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105160:	8b 00                	mov    (%eax),%eax
  105162:	83 e0 01             	and    $0x1,%eax
  105165:	85 c0                	test   %eax,%eax
  105167:	0f 85 af 00 00 00    	jne    10521c <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  10516d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105171:	74 15                	je     105188 <get_pte+0x46>
  105173:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10517a:	e8 07 f9 ff ff       	call   104a86 <alloc_pages>
  10517f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105182:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105186:	75 0a                	jne    105192 <get_pte+0x50>
            return NULL;
  105188:	b8 00 00 00 00       	mov    $0x0,%eax
  10518d:	e9 e6 00 00 00       	jmp    105278 <get_pte+0x136>
        }
        set_page_ref(page, 1);
  105192:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105199:	00 
  10519a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10519d:	89 04 24             	mov    %eax,(%esp)
  1051a0:	e8 e6 f6 ff ff       	call   10488b <set_page_ref>
        uintptr_t pa = page2pa(page);
  1051a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1051a8:	89 04 24             	mov    %eax,(%esp)
  1051ab:	e8 c2 f5 ff ff       	call   104772 <page2pa>
  1051b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
  1051b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1051b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1051b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051bc:	c1 e8 0c             	shr    $0xc,%eax
  1051bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1051c2:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  1051c7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1051ca:	72 23                	jb     1051ef <get_pte+0xad>
  1051cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1051d3:	c7 44 24 08 00 79 10 	movl   $0x107900,0x8(%esp)
  1051da:	00 
  1051db:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
  1051e2:	00 
  1051e3:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1051ea:	e8 29 ba ff ff       	call   100c18 <__panic>
  1051ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051f2:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1051f7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1051fe:	00 
  1051ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105206:	00 
  105207:	89 04 24             	mov    %eax,(%esp)
  10520a:	e8 e3 18 00 00       	call   106af2 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  10520f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105212:	83 c8 07             	or     $0x7,%eax
  105215:	89 c2                	mov    %eax,%edx
  105217:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10521a:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  10521c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10521f:	8b 00                	mov    (%eax),%eax
  105221:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105226:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105229:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10522c:	c1 e8 0c             	shr    $0xc,%eax
  10522f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105232:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  105237:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10523a:	72 23                	jb     10525f <get_pte+0x11d>
  10523c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10523f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105243:	c7 44 24 08 00 79 10 	movl   $0x107900,0x8(%esp)
  10524a:	00 
  10524b:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
  105252:	00 
  105253:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  10525a:	e8 b9 b9 ff ff       	call   100c18 <__panic>
  10525f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105262:	2d 00 00 00 40       	sub    $0x40000000,%eax
  105267:	8b 55 0c             	mov    0xc(%ebp),%edx
  10526a:	c1 ea 0c             	shr    $0xc,%edx
  10526d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  105273:	c1 e2 02             	shl    $0x2,%edx
  105276:	01 d0                	add    %edx,%eax
}
  105278:	c9                   	leave  
  105279:	c3                   	ret    

0010527a <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  10527a:	55                   	push   %ebp
  10527b:	89 e5                	mov    %esp,%ebp
  10527d:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  105280:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105287:	00 
  105288:	8b 45 0c             	mov    0xc(%ebp),%eax
  10528b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10528f:	8b 45 08             	mov    0x8(%ebp),%eax
  105292:	89 04 24             	mov    %eax,(%esp)
  105295:	e8 a8 fe ff ff       	call   105142 <get_pte>
  10529a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  10529d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1052a1:	74 08                	je     1052ab <get_page+0x31>
        *ptep_store = ptep;
  1052a3:	8b 45 10             	mov    0x10(%ebp),%eax
  1052a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1052a9:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  1052ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1052af:	74 1b                	je     1052cc <get_page+0x52>
  1052b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1052b4:	8b 00                	mov    (%eax),%eax
  1052b6:	83 e0 01             	and    $0x1,%eax
  1052b9:	85 c0                	test   %eax,%eax
  1052bb:	74 0f                	je     1052cc <get_page+0x52>
        return pte2page(*ptep);
  1052bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1052c0:	8b 00                	mov    (%eax),%eax
  1052c2:	89 04 24             	mov    %eax,(%esp)
  1052c5:	e8 61 f5 ff ff       	call   10482b <pte2page>
  1052ca:	eb 05                	jmp    1052d1 <get_page+0x57>
    }
    return NULL;
  1052cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1052d1:	c9                   	leave  
  1052d2:	c3                   	ret    

001052d3 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  1052d3:	55                   	push   %ebp
  1052d4:	89 e5                	mov    %esp,%ebp
  1052d6:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
  1052d9:	8b 45 10             	mov    0x10(%ebp),%eax
  1052dc:	8b 00                	mov    (%eax),%eax
  1052de:	83 e0 01             	and    $0x1,%eax
  1052e1:	85 c0                	test   %eax,%eax
  1052e3:	74 4d                	je     105332 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  1052e5:	8b 45 10             	mov    0x10(%ebp),%eax
  1052e8:	8b 00                	mov    (%eax),%eax
  1052ea:	89 04 24             	mov    %eax,(%esp)
  1052ed:	e8 39 f5 ff ff       	call   10482b <pte2page>
  1052f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  1052f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1052f8:	89 04 24             	mov    %eax,(%esp)
  1052fb:	e8 af f5 ff ff       	call   1048af <page_ref_dec>
  105300:	85 c0                	test   %eax,%eax
  105302:	75 13                	jne    105317 <page_remove_pte+0x44>
            free_page(page);
  105304:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10530b:	00 
  10530c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10530f:	89 04 24             	mov    %eax,(%esp)
  105312:	e8 a7 f7 ff ff       	call   104abe <free_pages>
        }
        *ptep = 0;
  105317:	8b 45 10             	mov    0x10(%ebp),%eax
  10531a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  105320:	8b 45 0c             	mov    0xc(%ebp),%eax
  105323:	89 44 24 04          	mov    %eax,0x4(%esp)
  105327:	8b 45 08             	mov    0x8(%ebp),%eax
  10532a:	89 04 24             	mov    %eax,(%esp)
  10532d:	e8 ff 00 00 00       	call   105431 <tlb_invalidate>
    }
}
  105332:	c9                   	leave  
  105333:	c3                   	ret    

00105334 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  105334:	55                   	push   %ebp
  105335:	89 e5                	mov    %esp,%ebp
  105337:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10533a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105341:	00 
  105342:	8b 45 0c             	mov    0xc(%ebp),%eax
  105345:	89 44 24 04          	mov    %eax,0x4(%esp)
  105349:	8b 45 08             	mov    0x8(%ebp),%eax
  10534c:	89 04 24             	mov    %eax,(%esp)
  10534f:	e8 ee fd ff ff       	call   105142 <get_pte>
  105354:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  105357:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10535b:	74 19                	je     105376 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10535d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105360:	89 44 24 08          	mov    %eax,0x8(%esp)
  105364:	8b 45 0c             	mov    0xc(%ebp),%eax
  105367:	89 44 24 04          	mov    %eax,0x4(%esp)
  10536b:	8b 45 08             	mov    0x8(%ebp),%eax
  10536e:	89 04 24             	mov    %eax,(%esp)
  105371:	e8 5d ff ff ff       	call   1052d3 <page_remove_pte>
    }
}
  105376:	c9                   	leave  
  105377:	c3                   	ret    

00105378 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  105378:	55                   	push   %ebp
  105379:	89 e5                	mov    %esp,%ebp
  10537b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10537e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  105385:	00 
  105386:	8b 45 10             	mov    0x10(%ebp),%eax
  105389:	89 44 24 04          	mov    %eax,0x4(%esp)
  10538d:	8b 45 08             	mov    0x8(%ebp),%eax
  105390:	89 04 24             	mov    %eax,(%esp)
  105393:	e8 aa fd ff ff       	call   105142 <get_pte>
  105398:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  10539b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10539f:	75 0a                	jne    1053ab <page_insert+0x33>
        return -E_NO_MEM;
  1053a1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1053a6:	e9 84 00 00 00       	jmp    10542f <page_insert+0xb7>
    }
    page_ref_inc(page);
  1053ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053ae:	89 04 24             	mov    %eax,(%esp)
  1053b1:	e8 e2 f4 ff ff       	call   104898 <page_ref_inc>
    if (*ptep & PTE_P) {
  1053b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053b9:	8b 00                	mov    (%eax),%eax
  1053bb:	83 e0 01             	and    $0x1,%eax
  1053be:	85 c0                	test   %eax,%eax
  1053c0:	74 3e                	je     105400 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1053c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053c5:	8b 00                	mov    (%eax),%eax
  1053c7:	89 04 24             	mov    %eax,(%esp)
  1053ca:	e8 5c f4 ff ff       	call   10482b <pte2page>
  1053cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1053d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1053d5:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1053d8:	75 0d                	jne    1053e7 <page_insert+0x6f>
            page_ref_dec(page);
  1053da:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053dd:	89 04 24             	mov    %eax,(%esp)
  1053e0:	e8 ca f4 ff ff       	call   1048af <page_ref_dec>
  1053e5:	eb 19                	jmp    105400 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1053e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  1053ee:	8b 45 10             	mov    0x10(%ebp),%eax
  1053f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1053f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1053f8:	89 04 24             	mov    %eax,(%esp)
  1053fb:	e8 d3 fe ff ff       	call   1052d3 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  105400:	8b 45 0c             	mov    0xc(%ebp),%eax
  105403:	89 04 24             	mov    %eax,(%esp)
  105406:	e8 67 f3 ff ff       	call   104772 <page2pa>
  10540b:	0b 45 14             	or     0x14(%ebp),%eax
  10540e:	83 c8 01             	or     $0x1,%eax
  105411:	89 c2                	mov    %eax,%edx
  105413:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105416:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  105418:	8b 45 10             	mov    0x10(%ebp),%eax
  10541b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10541f:	8b 45 08             	mov    0x8(%ebp),%eax
  105422:	89 04 24             	mov    %eax,(%esp)
  105425:	e8 07 00 00 00       	call   105431 <tlb_invalidate>
    return 0;
  10542a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10542f:	c9                   	leave  
  105430:	c3                   	ret    

00105431 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  105431:	55                   	push   %ebp
  105432:	89 e5                	mov    %esp,%ebp
  105434:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  105437:	0f 20 d8             	mov    %cr3,%eax
  10543a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10543d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  105440:	89 c2                	mov    %eax,%edx
  105442:	8b 45 08             	mov    0x8(%ebp),%eax
  105445:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105448:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10544f:	77 23                	ja     105474 <tlb_invalidate+0x43>
  105451:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105454:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105458:	c7 44 24 08 a4 79 10 	movl   $0x1079a4,0x8(%esp)
  10545f:	00 
  105460:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
  105467:	00 
  105468:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  10546f:	e8 a4 b7 ff ff       	call   100c18 <__panic>
  105474:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105477:	05 00 00 00 40       	add    $0x40000000,%eax
  10547c:	39 c2                	cmp    %eax,%edx
  10547e:	75 0c                	jne    10548c <tlb_invalidate+0x5b>
        invlpg((void *)la);
  105480:	8b 45 0c             	mov    0xc(%ebp),%eax
  105483:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  105486:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105489:	0f 01 38             	invlpg (%eax)
    }
}
  10548c:	c9                   	leave  
  10548d:	c3                   	ret    

0010548e <check_alloc_page>:

static void
check_alloc_page(void) {
  10548e:	55                   	push   %ebp
  10548f:	89 e5                	mov    %esp,%ebp
  105491:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  105494:	a1 b0 d0 11 00       	mov    0x11d0b0,%eax
  105499:	8b 40 18             	mov    0x18(%eax),%eax
  10549c:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  10549e:	c7 04 24 28 7a 10 00 	movl   $0x107a28,(%esp)
  1054a5:	e8 9e ae ff ff       	call   100348 <cprintf>
}
  1054aa:	c9                   	leave  
  1054ab:	c3                   	ret    

001054ac <check_pgdir>:

static void
check_pgdir(void) {
  1054ac:	55                   	push   %ebp
  1054ad:	89 e5                	mov    %esp,%ebp
  1054af:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1054b2:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  1054b7:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1054bc:	76 24                	jbe    1054e2 <check_pgdir+0x36>
  1054be:	c7 44 24 0c 47 7a 10 	movl   $0x107a47,0xc(%esp)
  1054c5:	00 
  1054c6:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  1054cd:	00 
  1054ce:	c7 44 24 04 e0 01 00 	movl   $0x1e0,0x4(%esp)
  1054d5:	00 
  1054d6:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1054dd:	e8 36 b7 ff ff       	call   100c18 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1054e2:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1054e7:	85 c0                	test   %eax,%eax
  1054e9:	74 0e                	je     1054f9 <check_pgdir+0x4d>
  1054eb:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1054f0:	25 ff 0f 00 00       	and    $0xfff,%eax
  1054f5:	85 c0                	test   %eax,%eax
  1054f7:	74 24                	je     10551d <check_pgdir+0x71>
  1054f9:	c7 44 24 0c 64 7a 10 	movl   $0x107a64,0xc(%esp)
  105500:	00 
  105501:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105508:	00 
  105509:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  105510:	00 
  105511:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105518:	e8 fb b6 ff ff       	call   100c18 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  10551d:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105522:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105529:	00 
  10552a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105531:	00 
  105532:	89 04 24             	mov    %eax,(%esp)
  105535:	e8 40 fd ff ff       	call   10527a <get_page>
  10553a:	85 c0                	test   %eax,%eax
  10553c:	74 24                	je     105562 <check_pgdir+0xb6>
  10553e:	c7 44 24 0c 9c 7a 10 	movl   $0x107a9c,0xc(%esp)
  105545:	00 
  105546:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  10554d:	00 
  10554e:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  105555:	00 
  105556:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  10555d:	e8 b6 b6 ff ff       	call   100c18 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  105562:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105569:	e8 18 f5 ff ff       	call   104a86 <alloc_pages>
  10556e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  105571:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105576:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10557d:	00 
  10557e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105585:	00 
  105586:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105589:	89 54 24 04          	mov    %edx,0x4(%esp)
  10558d:	89 04 24             	mov    %eax,(%esp)
  105590:	e8 e3 fd ff ff       	call   105378 <page_insert>
  105595:	85 c0                	test   %eax,%eax
  105597:	74 24                	je     1055bd <check_pgdir+0x111>
  105599:	c7 44 24 0c c4 7a 10 	movl   $0x107ac4,0xc(%esp)
  1055a0:	00 
  1055a1:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  1055a8:	00 
  1055a9:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  1055b0:	00 
  1055b1:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1055b8:	e8 5b b6 ff ff       	call   100c18 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1055bd:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1055c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1055c9:	00 
  1055ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1055d1:	00 
  1055d2:	89 04 24             	mov    %eax,(%esp)
  1055d5:	e8 68 fb ff ff       	call   105142 <get_pte>
  1055da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1055dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1055e1:	75 24                	jne    105607 <check_pgdir+0x15b>
  1055e3:	c7 44 24 0c f0 7a 10 	movl   $0x107af0,0xc(%esp)
  1055ea:	00 
  1055eb:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  1055f2:	00 
  1055f3:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  1055fa:	00 
  1055fb:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105602:	e8 11 b6 ff ff       	call   100c18 <__panic>
    assert(pte2page(*ptep) == p1);
  105607:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10560a:	8b 00                	mov    (%eax),%eax
  10560c:	89 04 24             	mov    %eax,(%esp)
  10560f:	e8 17 f2 ff ff       	call   10482b <pte2page>
  105614:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  105617:	74 24                	je     10563d <check_pgdir+0x191>
  105619:	c7 44 24 0c 1d 7b 10 	movl   $0x107b1d,0xc(%esp)
  105620:	00 
  105621:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105628:	00 
  105629:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  105630:	00 
  105631:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105638:	e8 db b5 ff ff       	call   100c18 <__panic>
    assert(page_ref(p1) == 1);
  10563d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105640:	89 04 24             	mov    %eax,(%esp)
  105643:	e8 39 f2 ff ff       	call   104881 <page_ref>
  105648:	83 f8 01             	cmp    $0x1,%eax
  10564b:	74 24                	je     105671 <check_pgdir+0x1c5>
  10564d:	c7 44 24 0c 33 7b 10 	movl   $0x107b33,0xc(%esp)
  105654:	00 
  105655:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  10565c:	00 
  10565d:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  105664:	00 
  105665:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  10566c:	e8 a7 b5 ff ff       	call   100c18 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  105671:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105676:	8b 00                	mov    (%eax),%eax
  105678:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10567d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105680:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105683:	c1 e8 0c             	shr    $0xc,%eax
  105686:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105689:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  10568e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105691:	72 23                	jb     1056b6 <check_pgdir+0x20a>
  105693:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105696:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10569a:	c7 44 24 08 00 79 10 	movl   $0x107900,0x8(%esp)
  1056a1:	00 
  1056a2:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  1056a9:	00 
  1056aa:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1056b1:	e8 62 b5 ff ff       	call   100c18 <__panic>
  1056b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1056b9:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1056be:	83 c0 04             	add    $0x4,%eax
  1056c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1056c4:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1056c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1056d0:	00 
  1056d1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1056d8:	00 
  1056d9:	89 04 24             	mov    %eax,(%esp)
  1056dc:	e8 61 fa ff ff       	call   105142 <get_pte>
  1056e1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1056e4:	74 24                	je     10570a <check_pgdir+0x25e>
  1056e6:	c7 44 24 0c 48 7b 10 	movl   $0x107b48,0xc(%esp)
  1056ed:	00 
  1056ee:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  1056f5:	00 
  1056f6:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  1056fd:	00 
  1056fe:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105705:	e8 0e b5 ff ff       	call   100c18 <__panic>

    p2 = alloc_page();
  10570a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105711:	e8 70 f3 ff ff       	call   104a86 <alloc_pages>
  105716:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  105719:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10571e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  105725:	00 
  105726:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10572d:	00 
  10572e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105731:	89 54 24 04          	mov    %edx,0x4(%esp)
  105735:	89 04 24             	mov    %eax,(%esp)
  105738:	e8 3b fc ff ff       	call   105378 <page_insert>
  10573d:	85 c0                	test   %eax,%eax
  10573f:	74 24                	je     105765 <check_pgdir+0x2b9>
  105741:	c7 44 24 0c 70 7b 10 	movl   $0x107b70,0xc(%esp)
  105748:	00 
  105749:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105750:	00 
  105751:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  105758:	00 
  105759:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105760:	e8 b3 b4 ff ff       	call   100c18 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  105765:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10576a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105771:	00 
  105772:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  105779:	00 
  10577a:	89 04 24             	mov    %eax,(%esp)
  10577d:	e8 c0 f9 ff ff       	call   105142 <get_pte>
  105782:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105785:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105789:	75 24                	jne    1057af <check_pgdir+0x303>
  10578b:	c7 44 24 0c a8 7b 10 	movl   $0x107ba8,0xc(%esp)
  105792:	00 
  105793:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  10579a:	00 
  10579b:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  1057a2:	00 
  1057a3:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1057aa:	e8 69 b4 ff ff       	call   100c18 <__panic>
    assert(*ptep & PTE_U);
  1057af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057b2:	8b 00                	mov    (%eax),%eax
  1057b4:	83 e0 04             	and    $0x4,%eax
  1057b7:	85 c0                	test   %eax,%eax
  1057b9:	75 24                	jne    1057df <check_pgdir+0x333>
  1057bb:	c7 44 24 0c d8 7b 10 	movl   $0x107bd8,0xc(%esp)
  1057c2:	00 
  1057c3:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  1057ca:	00 
  1057cb:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  1057d2:	00 
  1057d3:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1057da:	e8 39 b4 ff ff       	call   100c18 <__panic>
    assert(*ptep & PTE_W);
  1057df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057e2:	8b 00                	mov    (%eax),%eax
  1057e4:	83 e0 02             	and    $0x2,%eax
  1057e7:	85 c0                	test   %eax,%eax
  1057e9:	75 24                	jne    10580f <check_pgdir+0x363>
  1057eb:	c7 44 24 0c e6 7b 10 	movl   $0x107be6,0xc(%esp)
  1057f2:	00 
  1057f3:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  1057fa:	00 
  1057fb:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  105802:	00 
  105803:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  10580a:	e8 09 b4 ff ff       	call   100c18 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  10580f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105814:	8b 00                	mov    (%eax),%eax
  105816:	83 e0 04             	and    $0x4,%eax
  105819:	85 c0                	test   %eax,%eax
  10581b:	75 24                	jne    105841 <check_pgdir+0x395>
  10581d:	c7 44 24 0c f4 7b 10 	movl   $0x107bf4,0xc(%esp)
  105824:	00 
  105825:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  10582c:	00 
  10582d:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  105834:	00 
  105835:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  10583c:	e8 d7 b3 ff ff       	call   100c18 <__panic>
    assert(page_ref(p2) == 1);
  105841:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105844:	89 04 24             	mov    %eax,(%esp)
  105847:	e8 35 f0 ff ff       	call   104881 <page_ref>
  10584c:	83 f8 01             	cmp    $0x1,%eax
  10584f:	74 24                	je     105875 <check_pgdir+0x3c9>
  105851:	c7 44 24 0c 0a 7c 10 	movl   $0x107c0a,0xc(%esp)
  105858:	00 
  105859:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105860:	00 
  105861:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  105868:	00 
  105869:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105870:	e8 a3 b3 ff ff       	call   100c18 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  105875:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10587a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  105881:	00 
  105882:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105889:	00 
  10588a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10588d:	89 54 24 04          	mov    %edx,0x4(%esp)
  105891:	89 04 24             	mov    %eax,(%esp)
  105894:	e8 df fa ff ff       	call   105378 <page_insert>
  105899:	85 c0                	test   %eax,%eax
  10589b:	74 24                	je     1058c1 <check_pgdir+0x415>
  10589d:	c7 44 24 0c 1c 7c 10 	movl   $0x107c1c,0xc(%esp)
  1058a4:	00 
  1058a5:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  1058ac:	00 
  1058ad:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  1058b4:	00 
  1058b5:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1058bc:	e8 57 b3 ff ff       	call   100c18 <__panic>
    assert(page_ref(p1) == 2);
  1058c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1058c4:	89 04 24             	mov    %eax,(%esp)
  1058c7:	e8 b5 ef ff ff       	call   104881 <page_ref>
  1058cc:	83 f8 02             	cmp    $0x2,%eax
  1058cf:	74 24                	je     1058f5 <check_pgdir+0x449>
  1058d1:	c7 44 24 0c 48 7c 10 	movl   $0x107c48,0xc(%esp)
  1058d8:	00 
  1058d9:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  1058e0:	00 
  1058e1:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  1058e8:	00 
  1058e9:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1058f0:	e8 23 b3 ff ff       	call   100c18 <__panic>
    assert(page_ref(p2) == 0);
  1058f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1058f8:	89 04 24             	mov    %eax,(%esp)
  1058fb:	e8 81 ef ff ff       	call   104881 <page_ref>
  105900:	85 c0                	test   %eax,%eax
  105902:	74 24                	je     105928 <check_pgdir+0x47c>
  105904:	c7 44 24 0c 5a 7c 10 	movl   $0x107c5a,0xc(%esp)
  10590b:	00 
  10590c:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105913:	00 
  105914:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  10591b:	00 
  10591c:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105923:	e8 f0 b2 ff ff       	call   100c18 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  105928:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10592d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105934:	00 
  105935:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10593c:	00 
  10593d:	89 04 24             	mov    %eax,(%esp)
  105940:	e8 fd f7 ff ff       	call   105142 <get_pte>
  105945:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105948:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10594c:	75 24                	jne    105972 <check_pgdir+0x4c6>
  10594e:	c7 44 24 0c a8 7b 10 	movl   $0x107ba8,0xc(%esp)
  105955:	00 
  105956:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  10595d:	00 
  10595e:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  105965:	00 
  105966:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  10596d:	e8 a6 b2 ff ff       	call   100c18 <__panic>
    assert(pte2page(*ptep) == p1);
  105972:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105975:	8b 00                	mov    (%eax),%eax
  105977:	89 04 24             	mov    %eax,(%esp)
  10597a:	e8 ac ee ff ff       	call   10482b <pte2page>
  10597f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  105982:	74 24                	je     1059a8 <check_pgdir+0x4fc>
  105984:	c7 44 24 0c 1d 7b 10 	movl   $0x107b1d,0xc(%esp)
  10598b:	00 
  10598c:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105993:	00 
  105994:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  10599b:	00 
  10599c:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1059a3:	e8 70 b2 ff ff       	call   100c18 <__panic>
    assert((*ptep & PTE_U) == 0);
  1059a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059ab:	8b 00                	mov    (%eax),%eax
  1059ad:	83 e0 04             	and    $0x4,%eax
  1059b0:	85 c0                	test   %eax,%eax
  1059b2:	74 24                	je     1059d8 <check_pgdir+0x52c>
  1059b4:	c7 44 24 0c 6c 7c 10 	movl   $0x107c6c,0xc(%esp)
  1059bb:	00 
  1059bc:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  1059c3:	00 
  1059c4:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  1059cb:	00 
  1059cc:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  1059d3:	e8 40 b2 ff ff       	call   100c18 <__panic>

    page_remove(boot_pgdir, 0x0);
  1059d8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1059dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1059e4:	00 
  1059e5:	89 04 24             	mov    %eax,(%esp)
  1059e8:	e8 47 f9 ff ff       	call   105334 <page_remove>
    assert(page_ref(p1) == 1);
  1059ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059f0:	89 04 24             	mov    %eax,(%esp)
  1059f3:	e8 89 ee ff ff       	call   104881 <page_ref>
  1059f8:	83 f8 01             	cmp    $0x1,%eax
  1059fb:	74 24                	je     105a21 <check_pgdir+0x575>
  1059fd:	c7 44 24 0c 33 7b 10 	movl   $0x107b33,0xc(%esp)
  105a04:	00 
  105a05:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105a0c:	00 
  105a0d:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  105a14:	00 
  105a15:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105a1c:	e8 f7 b1 ff ff       	call   100c18 <__panic>
    assert(page_ref(p2) == 0);
  105a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105a24:	89 04 24             	mov    %eax,(%esp)
  105a27:	e8 55 ee ff ff       	call   104881 <page_ref>
  105a2c:	85 c0                	test   %eax,%eax
  105a2e:	74 24                	je     105a54 <check_pgdir+0x5a8>
  105a30:	c7 44 24 0c 5a 7c 10 	movl   $0x107c5a,0xc(%esp)
  105a37:	00 
  105a38:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105a3f:	00 
  105a40:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  105a47:	00 
  105a48:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105a4f:	e8 c4 b1 ff ff       	call   100c18 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  105a54:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105a59:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  105a60:	00 
  105a61:	89 04 24             	mov    %eax,(%esp)
  105a64:	e8 cb f8 ff ff       	call   105334 <page_remove>
    assert(page_ref(p1) == 0);
  105a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a6c:	89 04 24             	mov    %eax,(%esp)
  105a6f:	e8 0d ee ff ff       	call   104881 <page_ref>
  105a74:	85 c0                	test   %eax,%eax
  105a76:	74 24                	je     105a9c <check_pgdir+0x5f0>
  105a78:	c7 44 24 0c 81 7c 10 	movl   $0x107c81,0xc(%esp)
  105a7f:	00 
  105a80:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105a87:	00 
  105a88:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  105a8f:	00 
  105a90:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105a97:	e8 7c b1 ff ff       	call   100c18 <__panic>
    assert(page_ref(p2) == 0);
  105a9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105a9f:	89 04 24             	mov    %eax,(%esp)
  105aa2:	e8 da ed ff ff       	call   104881 <page_ref>
  105aa7:	85 c0                	test   %eax,%eax
  105aa9:	74 24                	je     105acf <check_pgdir+0x623>
  105aab:	c7 44 24 0c 5a 7c 10 	movl   $0x107c5a,0xc(%esp)
  105ab2:	00 
  105ab3:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105aba:	00 
  105abb:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  105ac2:	00 
  105ac3:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105aca:	e8 49 b1 ff ff       	call   100c18 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  105acf:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105ad4:	8b 00                	mov    (%eax),%eax
  105ad6:	89 04 24             	mov    %eax,(%esp)
  105ad9:	e8 8b ed ff ff       	call   104869 <pde2page>
  105ade:	89 04 24             	mov    %eax,(%esp)
  105ae1:	e8 9b ed ff ff       	call   104881 <page_ref>
  105ae6:	83 f8 01             	cmp    $0x1,%eax
  105ae9:	74 24                	je     105b0f <check_pgdir+0x663>
  105aeb:	c7 44 24 0c 94 7c 10 	movl   $0x107c94,0xc(%esp)
  105af2:	00 
  105af3:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105afa:	00 
  105afb:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  105b02:	00 
  105b03:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105b0a:	e8 09 b1 ff ff       	call   100c18 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  105b0f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105b14:	8b 00                	mov    (%eax),%eax
  105b16:	89 04 24             	mov    %eax,(%esp)
  105b19:	e8 4b ed ff ff       	call   104869 <pde2page>
  105b1e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105b25:	00 
  105b26:	89 04 24             	mov    %eax,(%esp)
  105b29:	e8 90 ef ff ff       	call   104abe <free_pages>
    boot_pgdir[0] = 0;
  105b2e:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105b33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  105b39:	c7 04 24 bb 7c 10 00 	movl   $0x107cbb,(%esp)
  105b40:	e8 03 a8 ff ff       	call   100348 <cprintf>
}
  105b45:	c9                   	leave  
  105b46:	c3                   	ret    

00105b47 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  105b47:	55                   	push   %ebp
  105b48:	89 e5                	mov    %esp,%ebp
  105b4a:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  105b4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105b54:	e9 ca 00 00 00       	jmp    105c23 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  105b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b62:	c1 e8 0c             	shr    $0xc,%eax
  105b65:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105b68:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  105b6d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105b70:	72 23                	jb     105b95 <check_boot_pgdir+0x4e>
  105b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105b79:	c7 44 24 08 00 79 10 	movl   $0x107900,0x8(%esp)
  105b80:	00 
  105b81:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  105b88:	00 
  105b89:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105b90:	e8 83 b0 ff ff       	call   100c18 <__panic>
  105b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b98:	2d 00 00 00 40       	sub    $0x40000000,%eax
  105b9d:	89 c2                	mov    %eax,%edx
  105b9f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105ba4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105bab:	00 
  105bac:	89 54 24 04          	mov    %edx,0x4(%esp)
  105bb0:	89 04 24             	mov    %eax,(%esp)
  105bb3:	e8 8a f5 ff ff       	call   105142 <get_pte>
  105bb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105bbb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105bbf:	75 24                	jne    105be5 <check_boot_pgdir+0x9e>
  105bc1:	c7 44 24 0c d8 7c 10 	movl   $0x107cd8,0xc(%esp)
  105bc8:	00 
  105bc9:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105bd0:	00 
  105bd1:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  105bd8:	00 
  105bd9:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105be0:	e8 33 b0 ff ff       	call   100c18 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  105be5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105be8:	8b 00                	mov    (%eax),%eax
  105bea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105bef:	89 c2                	mov    %eax,%edx
  105bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105bf4:	39 c2                	cmp    %eax,%edx
  105bf6:	74 24                	je     105c1c <check_boot_pgdir+0xd5>
  105bf8:	c7 44 24 0c 15 7d 10 	movl   $0x107d15,0xc(%esp)
  105bff:	00 
  105c00:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105c07:	00 
  105c08:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  105c0f:	00 
  105c10:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105c17:	e8 fc af ff ff       	call   100c18 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  105c1c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  105c23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c26:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  105c2b:	39 c2                	cmp    %eax,%edx
  105c2d:	0f 82 26 ff ff ff    	jb     105b59 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  105c33:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105c38:	05 ac 0f 00 00       	add    $0xfac,%eax
  105c3d:	8b 00                	mov    (%eax),%eax
  105c3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105c44:	89 c2                	mov    %eax,%edx
  105c46:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105c4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105c4e:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  105c55:	77 23                	ja     105c7a <check_boot_pgdir+0x133>
  105c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105c5e:	c7 44 24 08 a4 79 10 	movl   $0x1079a4,0x8(%esp)
  105c65:	00 
  105c66:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  105c6d:	00 
  105c6e:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105c75:	e8 9e af ff ff       	call   100c18 <__panic>
  105c7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c7d:	05 00 00 00 40       	add    $0x40000000,%eax
  105c82:	39 c2                	cmp    %eax,%edx
  105c84:	74 24                	je     105caa <check_boot_pgdir+0x163>
  105c86:	c7 44 24 0c 2c 7d 10 	movl   $0x107d2c,0xc(%esp)
  105c8d:	00 
  105c8e:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105c95:	00 
  105c96:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  105c9d:	00 
  105c9e:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105ca5:	e8 6e af ff ff       	call   100c18 <__panic>

    assert(boot_pgdir[0] == 0);
  105caa:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105caf:	8b 00                	mov    (%eax),%eax
  105cb1:	85 c0                	test   %eax,%eax
  105cb3:	74 24                	je     105cd9 <check_boot_pgdir+0x192>
  105cb5:	c7 44 24 0c 60 7d 10 	movl   $0x107d60,0xc(%esp)
  105cbc:	00 
  105cbd:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105cc4:	00 
  105cc5:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  105ccc:	00 
  105ccd:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105cd4:	e8 3f af ff ff       	call   100c18 <__panic>

    struct Page *p;
    p = alloc_page();
  105cd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105ce0:	e8 a1 ed ff ff       	call   104a86 <alloc_pages>
  105ce5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  105ce8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105ced:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105cf4:	00 
  105cf5:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  105cfc:	00 
  105cfd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105d00:	89 54 24 04          	mov    %edx,0x4(%esp)
  105d04:	89 04 24             	mov    %eax,(%esp)
  105d07:	e8 6c f6 ff ff       	call   105378 <page_insert>
  105d0c:	85 c0                	test   %eax,%eax
  105d0e:	74 24                	je     105d34 <check_boot_pgdir+0x1ed>
  105d10:	c7 44 24 0c 74 7d 10 	movl   $0x107d74,0xc(%esp)
  105d17:	00 
  105d18:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105d1f:	00 
  105d20:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  105d27:	00 
  105d28:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105d2f:	e8 e4 ae ff ff       	call   100c18 <__panic>
    assert(page_ref(p) == 1);
  105d34:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d37:	89 04 24             	mov    %eax,(%esp)
  105d3a:	e8 42 eb ff ff       	call   104881 <page_ref>
  105d3f:	83 f8 01             	cmp    $0x1,%eax
  105d42:	74 24                	je     105d68 <check_boot_pgdir+0x221>
  105d44:	c7 44 24 0c a2 7d 10 	movl   $0x107da2,0xc(%esp)
  105d4b:	00 
  105d4c:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105d53:	00 
  105d54:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  105d5b:	00 
  105d5c:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105d63:	e8 b0 ae ff ff       	call   100c18 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  105d68:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105d6d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105d74:	00 
  105d75:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  105d7c:	00 
  105d7d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105d80:	89 54 24 04          	mov    %edx,0x4(%esp)
  105d84:	89 04 24             	mov    %eax,(%esp)
  105d87:	e8 ec f5 ff ff       	call   105378 <page_insert>
  105d8c:	85 c0                	test   %eax,%eax
  105d8e:	74 24                	je     105db4 <check_boot_pgdir+0x26d>
  105d90:	c7 44 24 0c b4 7d 10 	movl   $0x107db4,0xc(%esp)
  105d97:	00 
  105d98:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105d9f:	00 
  105da0:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  105da7:	00 
  105da8:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105daf:	e8 64 ae ff ff       	call   100c18 <__panic>
    assert(page_ref(p) == 2);
  105db4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105db7:	89 04 24             	mov    %eax,(%esp)
  105dba:	e8 c2 ea ff ff       	call   104881 <page_ref>
  105dbf:	83 f8 02             	cmp    $0x2,%eax
  105dc2:	74 24                	je     105de8 <check_boot_pgdir+0x2a1>
  105dc4:	c7 44 24 0c eb 7d 10 	movl   $0x107deb,0xc(%esp)
  105dcb:	00 
  105dcc:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105dd3:	00 
  105dd4:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  105ddb:	00 
  105ddc:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105de3:	e8 30 ae ff ff       	call   100c18 <__panic>

    const char *str = "ucore: Hello world!!";
  105de8:	c7 45 dc fc 7d 10 00 	movl   $0x107dfc,-0x24(%ebp)
    strcpy((void *)0x100, str);
  105def:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  105df6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105dfd:	e8 19 0a 00 00       	call   10681b <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  105e02:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  105e09:	00 
  105e0a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105e11:	e8 7e 0a 00 00       	call   106894 <strcmp>
  105e16:	85 c0                	test   %eax,%eax
  105e18:	74 24                	je     105e3e <check_boot_pgdir+0x2f7>
  105e1a:	c7 44 24 0c 14 7e 10 	movl   $0x107e14,0xc(%esp)
  105e21:	00 
  105e22:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105e29:	00 
  105e2a:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  105e31:	00 
  105e32:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105e39:	e8 da ad ff ff       	call   100c18 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  105e3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e41:	89 04 24             	mov    %eax,(%esp)
  105e44:	e8 8e e9 ff ff       	call   1047d7 <page2kva>
  105e49:	05 00 01 00 00       	add    $0x100,%eax
  105e4e:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  105e51:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105e58:	e8 66 09 00 00       	call   1067c3 <strlen>
  105e5d:	85 c0                	test   %eax,%eax
  105e5f:	74 24                	je     105e85 <check_boot_pgdir+0x33e>
  105e61:	c7 44 24 0c 4c 7e 10 	movl   $0x107e4c,0xc(%esp)
  105e68:	00 
  105e69:	c7 44 24 08 ed 79 10 	movl   $0x1079ed,0x8(%esp)
  105e70:	00 
  105e71:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
  105e78:	00 
  105e79:	c7 04 24 c8 79 10 00 	movl   $0x1079c8,(%esp)
  105e80:	e8 93 ad ff ff       	call   100c18 <__panic>

    free_page(p);
  105e85:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105e8c:	00 
  105e8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e90:	89 04 24             	mov    %eax,(%esp)
  105e93:	e8 26 ec ff ff       	call   104abe <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  105e98:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105e9d:	8b 00                	mov    (%eax),%eax
  105e9f:	89 04 24             	mov    %eax,(%esp)
  105ea2:	e8 c2 e9 ff ff       	call   104869 <pde2page>
  105ea7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105eae:	00 
  105eaf:	89 04 24             	mov    %eax,(%esp)
  105eb2:	e8 07 ec ff ff       	call   104abe <free_pages>
    boot_pgdir[0] = 0;
  105eb7:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105ebc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  105ec2:	c7 04 24 70 7e 10 00 	movl   $0x107e70,(%esp)
  105ec9:	e8 7a a4 ff ff       	call   100348 <cprintf>
}
  105ece:	c9                   	leave  
  105ecf:	c3                   	ret    

00105ed0 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105ed0:	55                   	push   %ebp
  105ed1:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  105ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ed6:	83 e0 04             	and    $0x4,%eax
  105ed9:	85 c0                	test   %eax,%eax
  105edb:	74 07                	je     105ee4 <perm2str+0x14>
  105edd:	b8 75 00 00 00       	mov    $0x75,%eax
  105ee2:	eb 05                	jmp    105ee9 <perm2str+0x19>
  105ee4:	b8 2d 00 00 00       	mov    $0x2d,%eax
  105ee9:	a2 a8 cf 11 00       	mov    %al,0x11cfa8
    str[1] = 'r';
  105eee:	c6 05 a9 cf 11 00 72 	movb   $0x72,0x11cfa9
    str[2] = (perm & PTE_W) ? 'w' : '-';
  105ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  105ef8:	83 e0 02             	and    $0x2,%eax
  105efb:	85 c0                	test   %eax,%eax
  105efd:	74 07                	je     105f06 <perm2str+0x36>
  105eff:	b8 77 00 00 00       	mov    $0x77,%eax
  105f04:	eb 05                	jmp    105f0b <perm2str+0x3b>
  105f06:	b8 2d 00 00 00       	mov    $0x2d,%eax
  105f0b:	a2 aa cf 11 00       	mov    %al,0x11cfaa
    str[3] = '\0';
  105f10:	c6 05 ab cf 11 00 00 	movb   $0x0,0x11cfab
    return str;
  105f17:	b8 a8 cf 11 00       	mov    $0x11cfa8,%eax
}
  105f1c:	5d                   	pop    %ebp
  105f1d:	c3                   	ret    

00105f1e <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  105f1e:	55                   	push   %ebp
  105f1f:	89 e5                	mov    %esp,%ebp
  105f21:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  105f24:	8b 45 10             	mov    0x10(%ebp),%eax
  105f27:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105f2a:	72 0a                	jb     105f36 <get_pgtable_items+0x18>
        return 0;
  105f2c:	b8 00 00 00 00       	mov    $0x0,%eax
  105f31:	e9 9c 00 00 00       	jmp    105fd2 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  105f36:	eb 04                	jmp    105f3c <get_pgtable_items+0x1e>
        start ++;
  105f38:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  105f3c:	8b 45 10             	mov    0x10(%ebp),%eax
  105f3f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105f42:	73 18                	jae    105f5c <get_pgtable_items+0x3e>
  105f44:	8b 45 10             	mov    0x10(%ebp),%eax
  105f47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105f4e:	8b 45 14             	mov    0x14(%ebp),%eax
  105f51:	01 d0                	add    %edx,%eax
  105f53:	8b 00                	mov    (%eax),%eax
  105f55:	83 e0 01             	and    $0x1,%eax
  105f58:	85 c0                	test   %eax,%eax
  105f5a:	74 dc                	je     105f38 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  105f5c:	8b 45 10             	mov    0x10(%ebp),%eax
  105f5f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105f62:	73 69                	jae    105fcd <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  105f64:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  105f68:	74 08                	je     105f72 <get_pgtable_items+0x54>
            *left_store = start;
  105f6a:	8b 45 18             	mov    0x18(%ebp),%eax
  105f6d:	8b 55 10             	mov    0x10(%ebp),%edx
  105f70:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  105f72:	8b 45 10             	mov    0x10(%ebp),%eax
  105f75:	8d 50 01             	lea    0x1(%eax),%edx
  105f78:	89 55 10             	mov    %edx,0x10(%ebp)
  105f7b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105f82:	8b 45 14             	mov    0x14(%ebp),%eax
  105f85:	01 d0                	add    %edx,%eax
  105f87:	8b 00                	mov    (%eax),%eax
  105f89:	83 e0 07             	and    $0x7,%eax
  105f8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105f8f:	eb 04                	jmp    105f95 <get_pgtable_items+0x77>
            start ++;
  105f91:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  105f95:	8b 45 10             	mov    0x10(%ebp),%eax
  105f98:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105f9b:	73 1d                	jae    105fba <get_pgtable_items+0x9c>
  105f9d:	8b 45 10             	mov    0x10(%ebp),%eax
  105fa0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105fa7:	8b 45 14             	mov    0x14(%ebp),%eax
  105faa:	01 d0                	add    %edx,%eax
  105fac:	8b 00                	mov    (%eax),%eax
  105fae:	83 e0 07             	and    $0x7,%eax
  105fb1:	89 c2                	mov    %eax,%edx
  105fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105fb6:	39 c2                	cmp    %eax,%edx
  105fb8:	74 d7                	je     105f91 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  105fba:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105fbe:	74 08                	je     105fc8 <get_pgtable_items+0xaa>
            *right_store = start;
  105fc0:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105fc3:	8b 55 10             	mov    0x10(%ebp),%edx
  105fc6:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  105fc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105fcb:	eb 05                	jmp    105fd2 <get_pgtable_items+0xb4>
    }
    return 0;
  105fcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105fd2:	c9                   	leave  
  105fd3:	c3                   	ret    

00105fd4 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  105fd4:	55                   	push   %ebp
  105fd5:	89 e5                	mov    %esp,%ebp
  105fd7:	57                   	push   %edi
  105fd8:	56                   	push   %esi
  105fd9:	53                   	push   %ebx
  105fda:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  105fdd:	c7 04 24 90 7e 10 00 	movl   $0x107e90,(%esp)
  105fe4:	e8 5f a3 ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
  105fe9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105ff0:	e9 fa 00 00 00       	jmp    1060ef <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105ff5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105ff8:	89 04 24             	mov    %eax,(%esp)
  105ffb:	e8 d0 fe ff ff       	call   105ed0 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  106000:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  106003:	8b 55 e0             	mov    -0x20(%ebp),%edx
  106006:	29 d1                	sub    %edx,%ecx
  106008:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10600a:	89 d6                	mov    %edx,%esi
  10600c:	c1 e6 16             	shl    $0x16,%esi
  10600f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  106012:	89 d3                	mov    %edx,%ebx
  106014:	c1 e3 16             	shl    $0x16,%ebx
  106017:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10601a:	89 d1                	mov    %edx,%ecx
  10601c:	c1 e1 16             	shl    $0x16,%ecx
  10601f:	8b 7d dc             	mov    -0x24(%ebp),%edi
  106022:	8b 55 e0             	mov    -0x20(%ebp),%edx
  106025:	29 d7                	sub    %edx,%edi
  106027:	89 fa                	mov    %edi,%edx
  106029:	89 44 24 14          	mov    %eax,0x14(%esp)
  10602d:	89 74 24 10          	mov    %esi,0x10(%esp)
  106031:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  106035:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  106039:	89 54 24 04          	mov    %edx,0x4(%esp)
  10603d:	c7 04 24 c1 7e 10 00 	movl   $0x107ec1,(%esp)
  106044:	e8 ff a2 ff ff       	call   100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  106049:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10604c:	c1 e0 0a             	shl    $0xa,%eax
  10604f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  106052:	eb 54                	jmp    1060a8 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  106054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106057:	89 04 24             	mov    %eax,(%esp)
  10605a:	e8 71 fe ff ff       	call   105ed0 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  10605f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  106062:	8b 55 d8             	mov    -0x28(%ebp),%edx
  106065:	29 d1                	sub    %edx,%ecx
  106067:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  106069:	89 d6                	mov    %edx,%esi
  10606b:	c1 e6 0c             	shl    $0xc,%esi
  10606e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  106071:	89 d3                	mov    %edx,%ebx
  106073:	c1 e3 0c             	shl    $0xc,%ebx
  106076:	8b 55 d8             	mov    -0x28(%ebp),%edx
  106079:	c1 e2 0c             	shl    $0xc,%edx
  10607c:	89 d1                	mov    %edx,%ecx
  10607e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  106081:	8b 55 d8             	mov    -0x28(%ebp),%edx
  106084:	29 d7                	sub    %edx,%edi
  106086:	89 fa                	mov    %edi,%edx
  106088:	89 44 24 14          	mov    %eax,0x14(%esp)
  10608c:	89 74 24 10          	mov    %esi,0x10(%esp)
  106090:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  106094:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  106098:	89 54 24 04          	mov    %edx,0x4(%esp)
  10609c:	c7 04 24 e0 7e 10 00 	movl   $0x107ee0,(%esp)
  1060a3:	e8 a0 a2 ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1060a8:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  1060ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1060b0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1060b3:	89 ce                	mov    %ecx,%esi
  1060b5:	c1 e6 0a             	shl    $0xa,%esi
  1060b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1060bb:	89 cb                	mov    %ecx,%ebx
  1060bd:	c1 e3 0a             	shl    $0xa,%ebx
  1060c0:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  1060c3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1060c7:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  1060ca:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1060ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1060d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1060d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  1060da:	89 1c 24             	mov    %ebx,(%esp)
  1060dd:	e8 3c fe ff ff       	call   105f1e <get_pgtable_items>
  1060e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1060e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1060e9:	0f 85 65 ff ff ff    	jne    106054 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1060ef:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  1060f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1060f7:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  1060fa:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1060fe:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  106101:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  106105:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106109:	89 44 24 08          	mov    %eax,0x8(%esp)
  10610d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  106114:	00 
  106115:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10611c:	e8 fd fd ff ff       	call   105f1e <get_pgtable_items>
  106121:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106124:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106128:	0f 85 c7 fe ff ff    	jne    105ff5 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  10612e:	c7 04 24 04 7f 10 00 	movl   $0x107f04,(%esp)
  106135:	e8 0e a2 ff ff       	call   100348 <cprintf>
}
  10613a:	83 c4 4c             	add    $0x4c,%esp
  10613d:	5b                   	pop    %ebx
  10613e:	5e                   	pop    %esi
  10613f:	5f                   	pop    %edi
  106140:	5d                   	pop    %ebp
  106141:	c3                   	ret    

00106142 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  106142:	55                   	push   %ebp
  106143:	89 e5                	mov    %esp,%ebp
  106145:	83 ec 58             	sub    $0x58,%esp
  106148:	8b 45 10             	mov    0x10(%ebp),%eax
  10614b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10614e:	8b 45 14             	mov    0x14(%ebp),%eax
  106151:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  106154:	8b 45 d0             	mov    -0x30(%ebp),%eax
  106157:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10615a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10615d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  106160:	8b 45 18             	mov    0x18(%ebp),%eax
  106163:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106166:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106169:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10616c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10616f:	89 55 f0             	mov    %edx,-0x10(%ebp)
  106172:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106175:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106178:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10617c:	74 1c                	je     10619a <printnum+0x58>
  10617e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106181:	ba 00 00 00 00       	mov    $0x0,%edx
  106186:	f7 75 e4             	divl   -0x1c(%ebp)
  106189:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10618c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10618f:	ba 00 00 00 00       	mov    $0x0,%edx
  106194:	f7 75 e4             	divl   -0x1c(%ebp)
  106197:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10619a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10619d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1061a0:	f7 75 e4             	divl   -0x1c(%ebp)
  1061a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1061a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1061a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1061ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1061af:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1061b2:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1061b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1061b8:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1061bb:	8b 45 18             	mov    0x18(%ebp),%eax
  1061be:	ba 00 00 00 00       	mov    $0x0,%edx
  1061c3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1061c6:	77 56                	ja     10621e <printnum+0xdc>
  1061c8:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1061cb:	72 05                	jb     1061d2 <printnum+0x90>
  1061cd:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1061d0:	77 4c                	ja     10621e <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  1061d2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1061d5:	8d 50 ff             	lea    -0x1(%eax),%edx
  1061d8:	8b 45 20             	mov    0x20(%ebp),%eax
  1061db:	89 44 24 18          	mov    %eax,0x18(%esp)
  1061df:	89 54 24 14          	mov    %edx,0x14(%esp)
  1061e3:	8b 45 18             	mov    0x18(%ebp),%eax
  1061e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  1061ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1061ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1061f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1061f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1061f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1061fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1061ff:	8b 45 08             	mov    0x8(%ebp),%eax
  106202:	89 04 24             	mov    %eax,(%esp)
  106205:	e8 38 ff ff ff       	call   106142 <printnum>
  10620a:	eb 1c                	jmp    106228 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10620c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10620f:	89 44 24 04          	mov    %eax,0x4(%esp)
  106213:	8b 45 20             	mov    0x20(%ebp),%eax
  106216:	89 04 24             	mov    %eax,(%esp)
  106219:	8b 45 08             	mov    0x8(%ebp),%eax
  10621c:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  10621e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  106222:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  106226:	7f e4                	jg     10620c <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  106228:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10622b:	05 b8 7f 10 00       	add    $0x107fb8,%eax
  106230:	0f b6 00             	movzbl (%eax),%eax
  106233:	0f be c0             	movsbl %al,%eax
  106236:	8b 55 0c             	mov    0xc(%ebp),%edx
  106239:	89 54 24 04          	mov    %edx,0x4(%esp)
  10623d:	89 04 24             	mov    %eax,(%esp)
  106240:	8b 45 08             	mov    0x8(%ebp),%eax
  106243:	ff d0                	call   *%eax
}
  106245:	c9                   	leave  
  106246:	c3                   	ret    

00106247 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  106247:	55                   	push   %ebp
  106248:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10624a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10624e:	7e 14                	jle    106264 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  106250:	8b 45 08             	mov    0x8(%ebp),%eax
  106253:	8b 00                	mov    (%eax),%eax
  106255:	8d 48 08             	lea    0x8(%eax),%ecx
  106258:	8b 55 08             	mov    0x8(%ebp),%edx
  10625b:	89 0a                	mov    %ecx,(%edx)
  10625d:	8b 50 04             	mov    0x4(%eax),%edx
  106260:	8b 00                	mov    (%eax),%eax
  106262:	eb 30                	jmp    106294 <getuint+0x4d>
    }
    else if (lflag) {
  106264:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106268:	74 16                	je     106280 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10626a:	8b 45 08             	mov    0x8(%ebp),%eax
  10626d:	8b 00                	mov    (%eax),%eax
  10626f:	8d 48 04             	lea    0x4(%eax),%ecx
  106272:	8b 55 08             	mov    0x8(%ebp),%edx
  106275:	89 0a                	mov    %ecx,(%edx)
  106277:	8b 00                	mov    (%eax),%eax
  106279:	ba 00 00 00 00       	mov    $0x0,%edx
  10627e:	eb 14                	jmp    106294 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  106280:	8b 45 08             	mov    0x8(%ebp),%eax
  106283:	8b 00                	mov    (%eax),%eax
  106285:	8d 48 04             	lea    0x4(%eax),%ecx
  106288:	8b 55 08             	mov    0x8(%ebp),%edx
  10628b:	89 0a                	mov    %ecx,(%edx)
  10628d:	8b 00                	mov    (%eax),%eax
  10628f:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  106294:	5d                   	pop    %ebp
  106295:	c3                   	ret    

00106296 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  106296:	55                   	push   %ebp
  106297:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  106299:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10629d:	7e 14                	jle    1062b3 <getint+0x1d>
        return va_arg(*ap, long long);
  10629f:	8b 45 08             	mov    0x8(%ebp),%eax
  1062a2:	8b 00                	mov    (%eax),%eax
  1062a4:	8d 48 08             	lea    0x8(%eax),%ecx
  1062a7:	8b 55 08             	mov    0x8(%ebp),%edx
  1062aa:	89 0a                	mov    %ecx,(%edx)
  1062ac:	8b 50 04             	mov    0x4(%eax),%edx
  1062af:	8b 00                	mov    (%eax),%eax
  1062b1:	eb 28                	jmp    1062db <getint+0x45>
    }
    else if (lflag) {
  1062b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1062b7:	74 12                	je     1062cb <getint+0x35>
        return va_arg(*ap, long);
  1062b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1062bc:	8b 00                	mov    (%eax),%eax
  1062be:	8d 48 04             	lea    0x4(%eax),%ecx
  1062c1:	8b 55 08             	mov    0x8(%ebp),%edx
  1062c4:	89 0a                	mov    %ecx,(%edx)
  1062c6:	8b 00                	mov    (%eax),%eax
  1062c8:	99                   	cltd   
  1062c9:	eb 10                	jmp    1062db <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1062cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1062ce:	8b 00                	mov    (%eax),%eax
  1062d0:	8d 48 04             	lea    0x4(%eax),%ecx
  1062d3:	8b 55 08             	mov    0x8(%ebp),%edx
  1062d6:	89 0a                	mov    %ecx,(%edx)
  1062d8:	8b 00                	mov    (%eax),%eax
  1062da:	99                   	cltd   
    }
}
  1062db:	5d                   	pop    %ebp
  1062dc:	c3                   	ret    

001062dd <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1062dd:	55                   	push   %ebp
  1062de:	89 e5                	mov    %esp,%ebp
  1062e0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1062e3:	8d 45 14             	lea    0x14(%ebp),%eax
  1062e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1062e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1062ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1062f0:	8b 45 10             	mov    0x10(%ebp),%eax
  1062f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  1062f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1062fe:	8b 45 08             	mov    0x8(%ebp),%eax
  106301:	89 04 24             	mov    %eax,(%esp)
  106304:	e8 02 00 00 00       	call   10630b <vprintfmt>
    va_end(ap);
}
  106309:	c9                   	leave  
  10630a:	c3                   	ret    

0010630b <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10630b:	55                   	push   %ebp
  10630c:	89 e5                	mov    %esp,%ebp
  10630e:	56                   	push   %esi
  10630f:	53                   	push   %ebx
  106310:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  106313:	eb 18                	jmp    10632d <vprintfmt+0x22>
            if (ch == '\0') {
  106315:	85 db                	test   %ebx,%ebx
  106317:	75 05                	jne    10631e <vprintfmt+0x13>
                return;
  106319:	e9 d1 03 00 00       	jmp    1066ef <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  10631e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106321:	89 44 24 04          	mov    %eax,0x4(%esp)
  106325:	89 1c 24             	mov    %ebx,(%esp)
  106328:	8b 45 08             	mov    0x8(%ebp),%eax
  10632b:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10632d:	8b 45 10             	mov    0x10(%ebp),%eax
  106330:	8d 50 01             	lea    0x1(%eax),%edx
  106333:	89 55 10             	mov    %edx,0x10(%ebp)
  106336:	0f b6 00             	movzbl (%eax),%eax
  106339:	0f b6 d8             	movzbl %al,%ebx
  10633c:	83 fb 25             	cmp    $0x25,%ebx
  10633f:	75 d4                	jne    106315 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  106341:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  106345:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10634c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10634f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  106352:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  106359:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10635c:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  10635f:	8b 45 10             	mov    0x10(%ebp),%eax
  106362:	8d 50 01             	lea    0x1(%eax),%edx
  106365:	89 55 10             	mov    %edx,0x10(%ebp)
  106368:	0f b6 00             	movzbl (%eax),%eax
  10636b:	0f b6 d8             	movzbl %al,%ebx
  10636e:	8d 43 dd             	lea    -0x23(%ebx),%eax
  106371:	83 f8 55             	cmp    $0x55,%eax
  106374:	0f 87 44 03 00 00    	ja     1066be <vprintfmt+0x3b3>
  10637a:	8b 04 85 dc 7f 10 00 	mov    0x107fdc(,%eax,4),%eax
  106381:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  106383:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  106387:	eb d6                	jmp    10635f <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  106389:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10638d:	eb d0                	jmp    10635f <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10638f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  106396:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106399:	89 d0                	mov    %edx,%eax
  10639b:	c1 e0 02             	shl    $0x2,%eax
  10639e:	01 d0                	add    %edx,%eax
  1063a0:	01 c0                	add    %eax,%eax
  1063a2:	01 d8                	add    %ebx,%eax
  1063a4:	83 e8 30             	sub    $0x30,%eax
  1063a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1063aa:	8b 45 10             	mov    0x10(%ebp),%eax
  1063ad:	0f b6 00             	movzbl (%eax),%eax
  1063b0:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1063b3:	83 fb 2f             	cmp    $0x2f,%ebx
  1063b6:	7e 0b                	jle    1063c3 <vprintfmt+0xb8>
  1063b8:	83 fb 39             	cmp    $0x39,%ebx
  1063bb:	7f 06                	jg     1063c3 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1063bd:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  1063c1:	eb d3                	jmp    106396 <vprintfmt+0x8b>
            goto process_precision;
  1063c3:	eb 33                	jmp    1063f8 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  1063c5:	8b 45 14             	mov    0x14(%ebp),%eax
  1063c8:	8d 50 04             	lea    0x4(%eax),%edx
  1063cb:	89 55 14             	mov    %edx,0x14(%ebp)
  1063ce:	8b 00                	mov    (%eax),%eax
  1063d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1063d3:	eb 23                	jmp    1063f8 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  1063d5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1063d9:	79 0c                	jns    1063e7 <vprintfmt+0xdc>
                width = 0;
  1063db:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1063e2:	e9 78 ff ff ff       	jmp    10635f <vprintfmt+0x54>
  1063e7:	e9 73 ff ff ff       	jmp    10635f <vprintfmt+0x54>

        case '#':
            altflag = 1;
  1063ec:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1063f3:	e9 67 ff ff ff       	jmp    10635f <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  1063f8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1063fc:	79 12                	jns    106410 <vprintfmt+0x105>
                width = precision, precision = -1;
  1063fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106401:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106404:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  10640b:	e9 4f ff ff ff       	jmp    10635f <vprintfmt+0x54>
  106410:	e9 4a ff ff ff       	jmp    10635f <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  106415:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  106419:	e9 41 ff ff ff       	jmp    10635f <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  10641e:	8b 45 14             	mov    0x14(%ebp),%eax
  106421:	8d 50 04             	lea    0x4(%eax),%edx
  106424:	89 55 14             	mov    %edx,0x14(%ebp)
  106427:	8b 00                	mov    (%eax),%eax
  106429:	8b 55 0c             	mov    0xc(%ebp),%edx
  10642c:	89 54 24 04          	mov    %edx,0x4(%esp)
  106430:	89 04 24             	mov    %eax,(%esp)
  106433:	8b 45 08             	mov    0x8(%ebp),%eax
  106436:	ff d0                	call   *%eax
            break;
  106438:	e9 ac 02 00 00       	jmp    1066e9 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  10643d:	8b 45 14             	mov    0x14(%ebp),%eax
  106440:	8d 50 04             	lea    0x4(%eax),%edx
  106443:	89 55 14             	mov    %edx,0x14(%ebp)
  106446:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  106448:	85 db                	test   %ebx,%ebx
  10644a:	79 02                	jns    10644e <vprintfmt+0x143>
                err = -err;
  10644c:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  10644e:	83 fb 06             	cmp    $0x6,%ebx
  106451:	7f 0b                	jg     10645e <vprintfmt+0x153>
  106453:	8b 34 9d 9c 7f 10 00 	mov    0x107f9c(,%ebx,4),%esi
  10645a:	85 f6                	test   %esi,%esi
  10645c:	75 23                	jne    106481 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  10645e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  106462:	c7 44 24 08 c9 7f 10 	movl   $0x107fc9,0x8(%esp)
  106469:	00 
  10646a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10646d:	89 44 24 04          	mov    %eax,0x4(%esp)
  106471:	8b 45 08             	mov    0x8(%ebp),%eax
  106474:	89 04 24             	mov    %eax,(%esp)
  106477:	e8 61 fe ff ff       	call   1062dd <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10647c:	e9 68 02 00 00       	jmp    1066e9 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  106481:	89 74 24 0c          	mov    %esi,0xc(%esp)
  106485:	c7 44 24 08 d2 7f 10 	movl   $0x107fd2,0x8(%esp)
  10648c:	00 
  10648d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106490:	89 44 24 04          	mov    %eax,0x4(%esp)
  106494:	8b 45 08             	mov    0x8(%ebp),%eax
  106497:	89 04 24             	mov    %eax,(%esp)
  10649a:	e8 3e fe ff ff       	call   1062dd <printfmt>
            }
            break;
  10649f:	e9 45 02 00 00       	jmp    1066e9 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  1064a4:	8b 45 14             	mov    0x14(%ebp),%eax
  1064a7:	8d 50 04             	lea    0x4(%eax),%edx
  1064aa:	89 55 14             	mov    %edx,0x14(%ebp)
  1064ad:	8b 30                	mov    (%eax),%esi
  1064af:	85 f6                	test   %esi,%esi
  1064b1:	75 05                	jne    1064b8 <vprintfmt+0x1ad>
                p = "(null)";
  1064b3:	be d5 7f 10 00       	mov    $0x107fd5,%esi
            }
            if (width > 0 && padc != '-') {
  1064b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1064bc:	7e 3e                	jle    1064fc <vprintfmt+0x1f1>
  1064be:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1064c2:	74 38                	je     1064fc <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1064c4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  1064c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1064ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  1064ce:	89 34 24             	mov    %esi,(%esp)
  1064d1:	e8 15 03 00 00       	call   1067eb <strnlen>
  1064d6:	29 c3                	sub    %eax,%ebx
  1064d8:	89 d8                	mov    %ebx,%eax
  1064da:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1064dd:	eb 17                	jmp    1064f6 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  1064df:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1064e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  1064e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1064ea:	89 04 24             	mov    %eax,(%esp)
  1064ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1064f0:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  1064f2:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1064f6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1064fa:	7f e3                	jg     1064df <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1064fc:	eb 38                	jmp    106536 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  1064fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  106502:	74 1f                	je     106523 <vprintfmt+0x218>
  106504:	83 fb 1f             	cmp    $0x1f,%ebx
  106507:	7e 05                	jle    10650e <vprintfmt+0x203>
  106509:	83 fb 7e             	cmp    $0x7e,%ebx
  10650c:	7e 15                	jle    106523 <vprintfmt+0x218>
                    putch('?', putdat);
  10650e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106511:	89 44 24 04          	mov    %eax,0x4(%esp)
  106515:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  10651c:	8b 45 08             	mov    0x8(%ebp),%eax
  10651f:	ff d0                	call   *%eax
  106521:	eb 0f                	jmp    106532 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  106523:	8b 45 0c             	mov    0xc(%ebp),%eax
  106526:	89 44 24 04          	mov    %eax,0x4(%esp)
  10652a:	89 1c 24             	mov    %ebx,(%esp)
  10652d:	8b 45 08             	mov    0x8(%ebp),%eax
  106530:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106532:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  106536:	89 f0                	mov    %esi,%eax
  106538:	8d 70 01             	lea    0x1(%eax),%esi
  10653b:	0f b6 00             	movzbl (%eax),%eax
  10653e:	0f be d8             	movsbl %al,%ebx
  106541:	85 db                	test   %ebx,%ebx
  106543:	74 10                	je     106555 <vprintfmt+0x24a>
  106545:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106549:	78 b3                	js     1064fe <vprintfmt+0x1f3>
  10654b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  10654f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106553:	79 a9                	jns    1064fe <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  106555:	eb 17                	jmp    10656e <vprintfmt+0x263>
                putch(' ', putdat);
  106557:	8b 45 0c             	mov    0xc(%ebp),%eax
  10655a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10655e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  106565:	8b 45 08             	mov    0x8(%ebp),%eax
  106568:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10656a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  10656e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106572:	7f e3                	jg     106557 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  106574:	e9 70 01 00 00       	jmp    1066e9 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  106579:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10657c:	89 44 24 04          	mov    %eax,0x4(%esp)
  106580:	8d 45 14             	lea    0x14(%ebp),%eax
  106583:	89 04 24             	mov    %eax,(%esp)
  106586:	e8 0b fd ff ff       	call   106296 <getint>
  10658b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10658e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  106591:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106594:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106597:	85 d2                	test   %edx,%edx
  106599:	79 26                	jns    1065c1 <vprintfmt+0x2b6>
                putch('-', putdat);
  10659b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10659e:	89 44 24 04          	mov    %eax,0x4(%esp)
  1065a2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  1065a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1065ac:	ff d0                	call   *%eax
                num = -(long long)num;
  1065ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1065b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1065b4:	f7 d8                	neg    %eax
  1065b6:	83 d2 00             	adc    $0x0,%edx
  1065b9:	f7 da                	neg    %edx
  1065bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1065be:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1065c1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1065c8:	e9 a8 00 00 00       	jmp    106675 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1065cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1065d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1065d4:	8d 45 14             	lea    0x14(%ebp),%eax
  1065d7:	89 04 24             	mov    %eax,(%esp)
  1065da:	e8 68 fc ff ff       	call   106247 <getuint>
  1065df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1065e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1065e5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1065ec:	e9 84 00 00 00       	jmp    106675 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1065f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1065f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1065f8:	8d 45 14             	lea    0x14(%ebp),%eax
  1065fb:	89 04 24             	mov    %eax,(%esp)
  1065fe:	e8 44 fc ff ff       	call   106247 <getuint>
  106603:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106606:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  106609:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  106610:	eb 63                	jmp    106675 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  106612:	8b 45 0c             	mov    0xc(%ebp),%eax
  106615:	89 44 24 04          	mov    %eax,0x4(%esp)
  106619:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  106620:	8b 45 08             	mov    0x8(%ebp),%eax
  106623:	ff d0                	call   *%eax
            putch('x', putdat);
  106625:	8b 45 0c             	mov    0xc(%ebp),%eax
  106628:	89 44 24 04          	mov    %eax,0x4(%esp)
  10662c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  106633:	8b 45 08             	mov    0x8(%ebp),%eax
  106636:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  106638:	8b 45 14             	mov    0x14(%ebp),%eax
  10663b:	8d 50 04             	lea    0x4(%eax),%edx
  10663e:	89 55 14             	mov    %edx,0x14(%ebp)
  106641:	8b 00                	mov    (%eax),%eax
  106643:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106646:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  10664d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  106654:	eb 1f                	jmp    106675 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  106656:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106659:	89 44 24 04          	mov    %eax,0x4(%esp)
  10665d:	8d 45 14             	lea    0x14(%ebp),%eax
  106660:	89 04 24             	mov    %eax,(%esp)
  106663:	e8 df fb ff ff       	call   106247 <getuint>
  106668:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10666b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  10666e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  106675:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  106679:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10667c:	89 54 24 18          	mov    %edx,0x18(%esp)
  106680:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106683:	89 54 24 14          	mov    %edx,0x14(%esp)
  106687:	89 44 24 10          	mov    %eax,0x10(%esp)
  10668b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10668e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106691:	89 44 24 08          	mov    %eax,0x8(%esp)
  106695:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106699:	8b 45 0c             	mov    0xc(%ebp),%eax
  10669c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1066a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1066a3:	89 04 24             	mov    %eax,(%esp)
  1066a6:	e8 97 fa ff ff       	call   106142 <printnum>
            break;
  1066ab:	eb 3c                	jmp    1066e9 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  1066ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  1066b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1066b4:	89 1c 24             	mov    %ebx,(%esp)
  1066b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1066ba:	ff d0                	call   *%eax
            break;
  1066bc:	eb 2b                	jmp    1066e9 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  1066be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1066c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1066c5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1066cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1066cf:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1066d1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1066d5:	eb 04                	jmp    1066db <vprintfmt+0x3d0>
  1066d7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1066db:	8b 45 10             	mov    0x10(%ebp),%eax
  1066de:	83 e8 01             	sub    $0x1,%eax
  1066e1:	0f b6 00             	movzbl (%eax),%eax
  1066e4:	3c 25                	cmp    $0x25,%al
  1066e6:	75 ef                	jne    1066d7 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  1066e8:	90                   	nop
        }
    }
  1066e9:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1066ea:	e9 3e fc ff ff       	jmp    10632d <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  1066ef:	83 c4 40             	add    $0x40,%esp
  1066f2:	5b                   	pop    %ebx
  1066f3:	5e                   	pop    %esi
  1066f4:	5d                   	pop    %ebp
  1066f5:	c3                   	ret    

001066f6 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1066f6:	55                   	push   %ebp
  1066f7:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1066f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1066fc:	8b 40 08             	mov    0x8(%eax),%eax
  1066ff:	8d 50 01             	lea    0x1(%eax),%edx
  106702:	8b 45 0c             	mov    0xc(%ebp),%eax
  106705:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106708:	8b 45 0c             	mov    0xc(%ebp),%eax
  10670b:	8b 10                	mov    (%eax),%edx
  10670d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106710:	8b 40 04             	mov    0x4(%eax),%eax
  106713:	39 c2                	cmp    %eax,%edx
  106715:	73 12                	jae    106729 <sprintputch+0x33>
        *b->buf ++ = ch;
  106717:	8b 45 0c             	mov    0xc(%ebp),%eax
  10671a:	8b 00                	mov    (%eax),%eax
  10671c:	8d 48 01             	lea    0x1(%eax),%ecx
  10671f:	8b 55 0c             	mov    0xc(%ebp),%edx
  106722:	89 0a                	mov    %ecx,(%edx)
  106724:	8b 55 08             	mov    0x8(%ebp),%edx
  106727:	88 10                	mov    %dl,(%eax)
    }
}
  106729:	5d                   	pop    %ebp
  10672a:	c3                   	ret    

0010672b <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  10672b:	55                   	push   %ebp
  10672c:	89 e5                	mov    %esp,%ebp
  10672e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  106731:	8d 45 14             	lea    0x14(%ebp),%eax
  106734:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10673a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10673e:	8b 45 10             	mov    0x10(%ebp),%eax
  106741:	89 44 24 08          	mov    %eax,0x8(%esp)
  106745:	8b 45 0c             	mov    0xc(%ebp),%eax
  106748:	89 44 24 04          	mov    %eax,0x4(%esp)
  10674c:	8b 45 08             	mov    0x8(%ebp),%eax
  10674f:	89 04 24             	mov    %eax,(%esp)
  106752:	e8 08 00 00 00       	call   10675f <vsnprintf>
  106757:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10675a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10675d:	c9                   	leave  
  10675e:	c3                   	ret    

0010675f <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  10675f:	55                   	push   %ebp
  106760:	89 e5                	mov    %esp,%ebp
  106762:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  106765:	8b 45 08             	mov    0x8(%ebp),%eax
  106768:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10676b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10676e:	8d 50 ff             	lea    -0x1(%eax),%edx
  106771:	8b 45 08             	mov    0x8(%ebp),%eax
  106774:	01 d0                	add    %edx,%eax
  106776:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106779:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  106780:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  106784:	74 0a                	je     106790 <vsnprintf+0x31>
  106786:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106789:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10678c:	39 c2                	cmp    %eax,%edx
  10678e:	76 07                	jbe    106797 <vsnprintf+0x38>
        return -E_INVAL;
  106790:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  106795:	eb 2a                	jmp    1067c1 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  106797:	8b 45 14             	mov    0x14(%ebp),%eax
  10679a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10679e:	8b 45 10             	mov    0x10(%ebp),%eax
  1067a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  1067a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1067a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1067ac:	c7 04 24 f6 66 10 00 	movl   $0x1066f6,(%esp)
  1067b3:	e8 53 fb ff ff       	call   10630b <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1067b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1067bb:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1067be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1067c1:	c9                   	leave  
  1067c2:	c3                   	ret    

001067c3 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1067c3:	55                   	push   %ebp
  1067c4:	89 e5                	mov    %esp,%ebp
  1067c6:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1067c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1067d0:	eb 04                	jmp    1067d6 <strlen+0x13>
        cnt ++;
  1067d2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  1067d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1067d9:	8d 50 01             	lea    0x1(%eax),%edx
  1067dc:	89 55 08             	mov    %edx,0x8(%ebp)
  1067df:	0f b6 00             	movzbl (%eax),%eax
  1067e2:	84 c0                	test   %al,%al
  1067e4:	75 ec                	jne    1067d2 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  1067e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1067e9:	c9                   	leave  
  1067ea:	c3                   	ret    

001067eb <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1067eb:	55                   	push   %ebp
  1067ec:	89 e5                	mov    %esp,%ebp
  1067ee:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1067f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1067f8:	eb 04                	jmp    1067fe <strnlen+0x13>
        cnt ++;
  1067fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  1067fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106801:	3b 45 0c             	cmp    0xc(%ebp),%eax
  106804:	73 10                	jae    106816 <strnlen+0x2b>
  106806:	8b 45 08             	mov    0x8(%ebp),%eax
  106809:	8d 50 01             	lea    0x1(%eax),%edx
  10680c:	89 55 08             	mov    %edx,0x8(%ebp)
  10680f:	0f b6 00             	movzbl (%eax),%eax
  106812:	84 c0                	test   %al,%al
  106814:	75 e4                	jne    1067fa <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  106816:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  106819:	c9                   	leave  
  10681a:	c3                   	ret    

0010681b <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  10681b:	55                   	push   %ebp
  10681c:	89 e5                	mov    %esp,%ebp
  10681e:	57                   	push   %edi
  10681f:	56                   	push   %esi
  106820:	83 ec 20             	sub    $0x20,%esp
  106823:	8b 45 08             	mov    0x8(%ebp),%eax
  106826:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106829:	8b 45 0c             	mov    0xc(%ebp),%eax
  10682c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  10682f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  106832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106835:	89 d1                	mov    %edx,%ecx
  106837:	89 c2                	mov    %eax,%edx
  106839:	89 ce                	mov    %ecx,%esi
  10683b:	89 d7                	mov    %edx,%edi
  10683d:	ac                   	lods   %ds:(%esi),%al
  10683e:	aa                   	stos   %al,%es:(%edi)
  10683f:	84 c0                	test   %al,%al
  106841:	75 fa                	jne    10683d <strcpy+0x22>
  106843:	89 fa                	mov    %edi,%edx
  106845:	89 f1                	mov    %esi,%ecx
  106847:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10684a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  10684d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  106850:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  106853:	83 c4 20             	add    $0x20,%esp
  106856:	5e                   	pop    %esi
  106857:	5f                   	pop    %edi
  106858:	5d                   	pop    %ebp
  106859:	c3                   	ret    

0010685a <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  10685a:	55                   	push   %ebp
  10685b:	89 e5                	mov    %esp,%ebp
  10685d:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  106860:	8b 45 08             	mov    0x8(%ebp),%eax
  106863:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  106866:	eb 21                	jmp    106889 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  106868:	8b 45 0c             	mov    0xc(%ebp),%eax
  10686b:	0f b6 10             	movzbl (%eax),%edx
  10686e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106871:	88 10                	mov    %dl,(%eax)
  106873:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106876:	0f b6 00             	movzbl (%eax),%eax
  106879:	84 c0                	test   %al,%al
  10687b:	74 04                	je     106881 <strncpy+0x27>
            src ++;
  10687d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  106881:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  106885:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  106889:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10688d:	75 d9                	jne    106868 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  10688f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106892:	c9                   	leave  
  106893:	c3                   	ret    

00106894 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  106894:	55                   	push   %ebp
  106895:	89 e5                	mov    %esp,%ebp
  106897:	57                   	push   %edi
  106898:	56                   	push   %esi
  106899:	83 ec 20             	sub    $0x20,%esp
  10689c:	8b 45 08             	mov    0x8(%ebp),%eax
  10689f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1068a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  1068a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1068ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1068ae:	89 d1                	mov    %edx,%ecx
  1068b0:	89 c2                	mov    %eax,%edx
  1068b2:	89 ce                	mov    %ecx,%esi
  1068b4:	89 d7                	mov    %edx,%edi
  1068b6:	ac                   	lods   %ds:(%esi),%al
  1068b7:	ae                   	scas   %es:(%edi),%al
  1068b8:	75 08                	jne    1068c2 <strcmp+0x2e>
  1068ba:	84 c0                	test   %al,%al
  1068bc:	75 f8                	jne    1068b6 <strcmp+0x22>
  1068be:	31 c0                	xor    %eax,%eax
  1068c0:	eb 04                	jmp    1068c6 <strcmp+0x32>
  1068c2:	19 c0                	sbb    %eax,%eax
  1068c4:	0c 01                	or     $0x1,%al
  1068c6:	89 fa                	mov    %edi,%edx
  1068c8:	89 f1                	mov    %esi,%ecx
  1068ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1068cd:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1068d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  1068d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1068d6:	83 c4 20             	add    $0x20,%esp
  1068d9:	5e                   	pop    %esi
  1068da:	5f                   	pop    %edi
  1068db:	5d                   	pop    %ebp
  1068dc:	c3                   	ret    

001068dd <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1068dd:	55                   	push   %ebp
  1068de:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1068e0:	eb 0c                	jmp    1068ee <strncmp+0x11>
        n --, s1 ++, s2 ++;
  1068e2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1068e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1068ea:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1068ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1068f2:	74 1a                	je     10690e <strncmp+0x31>
  1068f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1068f7:	0f b6 00             	movzbl (%eax),%eax
  1068fa:	84 c0                	test   %al,%al
  1068fc:	74 10                	je     10690e <strncmp+0x31>
  1068fe:	8b 45 08             	mov    0x8(%ebp),%eax
  106901:	0f b6 10             	movzbl (%eax),%edx
  106904:	8b 45 0c             	mov    0xc(%ebp),%eax
  106907:	0f b6 00             	movzbl (%eax),%eax
  10690a:	38 c2                	cmp    %al,%dl
  10690c:	74 d4                	je     1068e2 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  10690e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106912:	74 18                	je     10692c <strncmp+0x4f>
  106914:	8b 45 08             	mov    0x8(%ebp),%eax
  106917:	0f b6 00             	movzbl (%eax),%eax
  10691a:	0f b6 d0             	movzbl %al,%edx
  10691d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106920:	0f b6 00             	movzbl (%eax),%eax
  106923:	0f b6 c0             	movzbl %al,%eax
  106926:	29 c2                	sub    %eax,%edx
  106928:	89 d0                	mov    %edx,%eax
  10692a:	eb 05                	jmp    106931 <strncmp+0x54>
  10692c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106931:	5d                   	pop    %ebp
  106932:	c3                   	ret    

00106933 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  106933:	55                   	push   %ebp
  106934:	89 e5                	mov    %esp,%ebp
  106936:	83 ec 04             	sub    $0x4,%esp
  106939:	8b 45 0c             	mov    0xc(%ebp),%eax
  10693c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10693f:	eb 14                	jmp    106955 <strchr+0x22>
        if (*s == c) {
  106941:	8b 45 08             	mov    0x8(%ebp),%eax
  106944:	0f b6 00             	movzbl (%eax),%eax
  106947:	3a 45 fc             	cmp    -0x4(%ebp),%al
  10694a:	75 05                	jne    106951 <strchr+0x1e>
            return (char *)s;
  10694c:	8b 45 08             	mov    0x8(%ebp),%eax
  10694f:	eb 13                	jmp    106964 <strchr+0x31>
        }
        s ++;
  106951:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  106955:	8b 45 08             	mov    0x8(%ebp),%eax
  106958:	0f b6 00             	movzbl (%eax),%eax
  10695b:	84 c0                	test   %al,%al
  10695d:	75 e2                	jne    106941 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  10695f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106964:	c9                   	leave  
  106965:	c3                   	ret    

00106966 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  106966:	55                   	push   %ebp
  106967:	89 e5                	mov    %esp,%ebp
  106969:	83 ec 04             	sub    $0x4,%esp
  10696c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10696f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  106972:	eb 11                	jmp    106985 <strfind+0x1f>
        if (*s == c) {
  106974:	8b 45 08             	mov    0x8(%ebp),%eax
  106977:	0f b6 00             	movzbl (%eax),%eax
  10697a:	3a 45 fc             	cmp    -0x4(%ebp),%al
  10697d:	75 02                	jne    106981 <strfind+0x1b>
            break;
  10697f:	eb 0e                	jmp    10698f <strfind+0x29>
        }
        s ++;
  106981:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  106985:	8b 45 08             	mov    0x8(%ebp),%eax
  106988:	0f b6 00             	movzbl (%eax),%eax
  10698b:	84 c0                	test   %al,%al
  10698d:	75 e5                	jne    106974 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  10698f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106992:	c9                   	leave  
  106993:	c3                   	ret    

00106994 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  106994:	55                   	push   %ebp
  106995:	89 e5                	mov    %esp,%ebp
  106997:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10699a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1069a1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1069a8:	eb 04                	jmp    1069ae <strtol+0x1a>
        s ++;
  1069aa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1069ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1069b1:	0f b6 00             	movzbl (%eax),%eax
  1069b4:	3c 20                	cmp    $0x20,%al
  1069b6:	74 f2                	je     1069aa <strtol+0x16>
  1069b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1069bb:	0f b6 00             	movzbl (%eax),%eax
  1069be:	3c 09                	cmp    $0x9,%al
  1069c0:	74 e8                	je     1069aa <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  1069c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1069c5:	0f b6 00             	movzbl (%eax),%eax
  1069c8:	3c 2b                	cmp    $0x2b,%al
  1069ca:	75 06                	jne    1069d2 <strtol+0x3e>
        s ++;
  1069cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1069d0:	eb 15                	jmp    1069e7 <strtol+0x53>
    }
    else if (*s == '-') {
  1069d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1069d5:	0f b6 00             	movzbl (%eax),%eax
  1069d8:	3c 2d                	cmp    $0x2d,%al
  1069da:	75 0b                	jne    1069e7 <strtol+0x53>
        s ++, neg = 1;
  1069dc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1069e0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1069e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1069eb:	74 06                	je     1069f3 <strtol+0x5f>
  1069ed:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1069f1:	75 24                	jne    106a17 <strtol+0x83>
  1069f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1069f6:	0f b6 00             	movzbl (%eax),%eax
  1069f9:	3c 30                	cmp    $0x30,%al
  1069fb:	75 1a                	jne    106a17 <strtol+0x83>
  1069fd:	8b 45 08             	mov    0x8(%ebp),%eax
  106a00:	83 c0 01             	add    $0x1,%eax
  106a03:	0f b6 00             	movzbl (%eax),%eax
  106a06:	3c 78                	cmp    $0x78,%al
  106a08:	75 0d                	jne    106a17 <strtol+0x83>
        s += 2, base = 16;
  106a0a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  106a0e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  106a15:	eb 2a                	jmp    106a41 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  106a17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106a1b:	75 17                	jne    106a34 <strtol+0xa0>
  106a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  106a20:	0f b6 00             	movzbl (%eax),%eax
  106a23:	3c 30                	cmp    $0x30,%al
  106a25:	75 0d                	jne    106a34 <strtol+0xa0>
        s ++, base = 8;
  106a27:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  106a2b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  106a32:	eb 0d                	jmp    106a41 <strtol+0xad>
    }
    else if (base == 0) {
  106a34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106a38:	75 07                	jne    106a41 <strtol+0xad>
        base = 10;
  106a3a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  106a41:	8b 45 08             	mov    0x8(%ebp),%eax
  106a44:	0f b6 00             	movzbl (%eax),%eax
  106a47:	3c 2f                	cmp    $0x2f,%al
  106a49:	7e 1b                	jle    106a66 <strtol+0xd2>
  106a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  106a4e:	0f b6 00             	movzbl (%eax),%eax
  106a51:	3c 39                	cmp    $0x39,%al
  106a53:	7f 11                	jg     106a66 <strtol+0xd2>
            dig = *s - '0';
  106a55:	8b 45 08             	mov    0x8(%ebp),%eax
  106a58:	0f b6 00             	movzbl (%eax),%eax
  106a5b:	0f be c0             	movsbl %al,%eax
  106a5e:	83 e8 30             	sub    $0x30,%eax
  106a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106a64:	eb 48                	jmp    106aae <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  106a66:	8b 45 08             	mov    0x8(%ebp),%eax
  106a69:	0f b6 00             	movzbl (%eax),%eax
  106a6c:	3c 60                	cmp    $0x60,%al
  106a6e:	7e 1b                	jle    106a8b <strtol+0xf7>
  106a70:	8b 45 08             	mov    0x8(%ebp),%eax
  106a73:	0f b6 00             	movzbl (%eax),%eax
  106a76:	3c 7a                	cmp    $0x7a,%al
  106a78:	7f 11                	jg     106a8b <strtol+0xf7>
            dig = *s - 'a' + 10;
  106a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  106a7d:	0f b6 00             	movzbl (%eax),%eax
  106a80:	0f be c0             	movsbl %al,%eax
  106a83:	83 e8 57             	sub    $0x57,%eax
  106a86:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106a89:	eb 23                	jmp    106aae <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  106a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  106a8e:	0f b6 00             	movzbl (%eax),%eax
  106a91:	3c 40                	cmp    $0x40,%al
  106a93:	7e 3d                	jle    106ad2 <strtol+0x13e>
  106a95:	8b 45 08             	mov    0x8(%ebp),%eax
  106a98:	0f b6 00             	movzbl (%eax),%eax
  106a9b:	3c 5a                	cmp    $0x5a,%al
  106a9d:	7f 33                	jg     106ad2 <strtol+0x13e>
            dig = *s - 'A' + 10;
  106a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  106aa2:	0f b6 00             	movzbl (%eax),%eax
  106aa5:	0f be c0             	movsbl %al,%eax
  106aa8:	83 e8 37             	sub    $0x37,%eax
  106aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  106aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106ab1:	3b 45 10             	cmp    0x10(%ebp),%eax
  106ab4:	7c 02                	jl     106ab8 <strtol+0x124>
            break;
  106ab6:	eb 1a                	jmp    106ad2 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  106ab8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  106abc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106abf:	0f af 45 10          	imul   0x10(%ebp),%eax
  106ac3:	89 c2                	mov    %eax,%edx
  106ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106ac8:	01 d0                	add    %edx,%eax
  106aca:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  106acd:	e9 6f ff ff ff       	jmp    106a41 <strtol+0xad>

    if (endptr) {
  106ad2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106ad6:	74 08                	je     106ae0 <strtol+0x14c>
        *endptr = (char *) s;
  106ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  106adb:	8b 55 08             	mov    0x8(%ebp),%edx
  106ade:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  106ae0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  106ae4:	74 07                	je     106aed <strtol+0x159>
  106ae6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106ae9:	f7 d8                	neg    %eax
  106aeb:	eb 03                	jmp    106af0 <strtol+0x15c>
  106aed:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  106af0:	c9                   	leave  
  106af1:	c3                   	ret    

00106af2 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  106af2:	55                   	push   %ebp
  106af3:	89 e5                	mov    %esp,%ebp
  106af5:	57                   	push   %edi
  106af6:	83 ec 24             	sub    $0x24,%esp
  106af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  106afc:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  106aff:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  106b03:	8b 55 08             	mov    0x8(%ebp),%edx
  106b06:	89 55 f8             	mov    %edx,-0x8(%ebp)
  106b09:	88 45 f7             	mov    %al,-0x9(%ebp)
  106b0c:	8b 45 10             	mov    0x10(%ebp),%eax
  106b0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  106b12:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  106b15:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  106b19:	8b 55 f8             	mov    -0x8(%ebp),%edx
  106b1c:	89 d7                	mov    %edx,%edi
  106b1e:	f3 aa                	rep stos %al,%es:(%edi)
  106b20:	89 fa                	mov    %edi,%edx
  106b22:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  106b25:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  106b28:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  106b2b:	83 c4 24             	add    $0x24,%esp
  106b2e:	5f                   	pop    %edi
  106b2f:	5d                   	pop    %ebp
  106b30:	c3                   	ret    

00106b31 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  106b31:	55                   	push   %ebp
  106b32:	89 e5                	mov    %esp,%ebp
  106b34:	57                   	push   %edi
  106b35:	56                   	push   %esi
  106b36:	53                   	push   %ebx
  106b37:	83 ec 30             	sub    $0x30,%esp
  106b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  106b3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106b46:	8b 45 10             	mov    0x10(%ebp),%eax
  106b49:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  106b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106b4f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  106b52:	73 42                	jae    106b96 <memmove+0x65>
  106b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106b57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106b5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106b5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106b60:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106b63:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106b66:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106b69:	c1 e8 02             	shr    $0x2,%eax
  106b6c:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  106b6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106b71:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106b74:	89 d7                	mov    %edx,%edi
  106b76:	89 c6                	mov    %eax,%esi
  106b78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106b7a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  106b7d:	83 e1 03             	and    $0x3,%ecx
  106b80:	74 02                	je     106b84 <memmove+0x53>
  106b82:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106b84:	89 f0                	mov    %esi,%eax
  106b86:	89 fa                	mov    %edi,%edx
  106b88:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  106b8b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  106b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  106b91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106b94:	eb 36                	jmp    106bcc <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  106b96:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106b99:	8d 50 ff             	lea    -0x1(%eax),%edx
  106b9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106b9f:	01 c2                	add    %eax,%edx
  106ba1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106ba4:	8d 48 ff             	lea    -0x1(%eax),%ecx
  106ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106baa:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  106bad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106bb0:	89 c1                	mov    %eax,%ecx
  106bb2:	89 d8                	mov    %ebx,%eax
  106bb4:	89 d6                	mov    %edx,%esi
  106bb6:	89 c7                	mov    %eax,%edi
  106bb8:	fd                   	std    
  106bb9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106bbb:	fc                   	cld    
  106bbc:	89 f8                	mov    %edi,%eax
  106bbe:	89 f2                	mov    %esi,%edx
  106bc0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  106bc3:	89 55 c8             	mov    %edx,-0x38(%ebp)
  106bc6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  106bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  106bcc:	83 c4 30             	add    $0x30,%esp
  106bcf:	5b                   	pop    %ebx
  106bd0:	5e                   	pop    %esi
  106bd1:	5f                   	pop    %edi
  106bd2:	5d                   	pop    %ebp
  106bd3:	c3                   	ret    

00106bd4 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  106bd4:	55                   	push   %ebp
  106bd5:	89 e5                	mov    %esp,%ebp
  106bd7:	57                   	push   %edi
  106bd8:	56                   	push   %esi
  106bd9:	83 ec 20             	sub    $0x20,%esp
  106bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  106bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  106be5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106be8:	8b 45 10             	mov    0x10(%ebp),%eax
  106beb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106bee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106bf1:	c1 e8 02             	shr    $0x2,%eax
  106bf4:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  106bf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106bfc:	89 d7                	mov    %edx,%edi
  106bfe:	89 c6                	mov    %eax,%esi
  106c00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106c02:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  106c05:	83 e1 03             	and    $0x3,%ecx
  106c08:	74 02                	je     106c0c <memcpy+0x38>
  106c0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106c0c:	89 f0                	mov    %esi,%eax
  106c0e:	89 fa                	mov    %edi,%edx
  106c10:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106c13:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  106c16:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  106c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  106c1c:	83 c4 20             	add    $0x20,%esp
  106c1f:	5e                   	pop    %esi
  106c20:	5f                   	pop    %edi
  106c21:	5d                   	pop    %ebp
  106c22:	c3                   	ret    

00106c23 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  106c23:	55                   	push   %ebp
  106c24:	89 e5                	mov    %esp,%ebp
  106c26:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  106c29:	8b 45 08             	mov    0x8(%ebp),%eax
  106c2c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  106c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c32:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  106c35:	eb 30                	jmp    106c67 <memcmp+0x44>
        if (*s1 != *s2) {
  106c37:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106c3a:	0f b6 10             	movzbl (%eax),%edx
  106c3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106c40:	0f b6 00             	movzbl (%eax),%eax
  106c43:	38 c2                	cmp    %al,%dl
  106c45:	74 18                	je     106c5f <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  106c47:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106c4a:	0f b6 00             	movzbl (%eax),%eax
  106c4d:	0f b6 d0             	movzbl %al,%edx
  106c50:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106c53:	0f b6 00             	movzbl (%eax),%eax
  106c56:	0f b6 c0             	movzbl %al,%eax
  106c59:	29 c2                	sub    %eax,%edx
  106c5b:	89 d0                	mov    %edx,%eax
  106c5d:	eb 1a                	jmp    106c79 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  106c5f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  106c63:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  106c67:	8b 45 10             	mov    0x10(%ebp),%eax
  106c6a:	8d 50 ff             	lea    -0x1(%eax),%edx
  106c6d:	89 55 10             	mov    %edx,0x10(%ebp)
  106c70:	85 c0                	test   %eax,%eax
  106c72:	75 c3                	jne    106c37 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  106c74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106c79:	c9                   	leave  
  106c7a:	c3                   	ret    
