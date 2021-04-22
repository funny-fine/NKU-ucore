
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 a0 11 00       	mov    $0x11a000,%eax
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
c0100020:	a3 00 a0 11 c0       	mov    %eax,0xc011a000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 90 11 c0       	mov    $0xc0119000,%esp
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
c010003c:	ba bc d0 11 c0       	mov    $0xc011d0bc,%edx
c0100041:	b8 00 c0 11 c0       	mov    $0xc011c000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 c0 11 c0 	movl   $0xc011c000,(%esp)
c010005d:	e8 90 6a 00 00       	call   c0106af2 <memset>

    cons_init();                // init the console
c0100062:	e8 c8 14 00 00       	call   c010152f <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 80 6c 10 c0 	movl   $0xc0106c80,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 9c 6c 10 c0 	movl   $0xc0106c9c,(%esp)
c010007c:	e8 c7 02 00 00       	call   c0100348 <cprintf>

    print_kerninfo();
c0100081:	e8 f6 07 00 00       	call   c010087c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 86 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 cd 4f 00 00       	call   c010505d <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 03 16 00 00       	call   c0101698 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 55 17 00 00       	call   c01017ef <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 46 0c 00 00       	call   c0100ce5 <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 62 15 00 00       	call   c0101606 <intr_enable>
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
c01000c3:	e8 3e 0b 00 00       	call   c0100c06 <mon_backtrace>
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
c0100154:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100159:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100161:	c7 04 24 a1 6c 10 c0 	movl   $0xc0106ca1,(%esp)
c0100168:	e8 db 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	0f b7 d0             	movzwl %ax,%edx
c0100174:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 af 6c 10 c0 	movl   $0xc0106caf,(%esp)
c0100188:	e8 bb 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	0f b7 d0             	movzwl %ax,%edx
c0100194:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 bd 6c 10 c0 	movl   $0xc0106cbd,(%esp)
c01001a8:	e8 9b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b1:	0f b7 d0             	movzwl %ax,%edx
c01001b4:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 cb 6c 10 c0 	movl   $0xc0106ccb,(%esp)
c01001c8:	e8 7b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d1:	0f b7 d0             	movzwl %ax,%edx
c01001d4:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e1:	c7 04 24 d9 6c 10 c0 	movl   $0xc0106cd9,(%esp)
c01001e8:	e8 5b 01 00 00       	call   c0100348 <cprintf>
    round ++;
c01001ed:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001f2:	83 c0 01             	add    $0x1,%eax
c01001f5:	a3 00 c0 11 c0       	mov    %eax,0xc011c000
}
c01001fa:	c9                   	leave  
c01001fb:	c3                   	ret    

c01001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fc:	55                   	push   %ebp
c01001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001ff:	5d                   	pop    %ebp
c0100200:	c3                   	ret    

c0100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100201:	55                   	push   %ebp
c0100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
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
c0100211:	c7 04 24 e8 6c 10 c0 	movl   $0xc0106ce8,(%esp)
c0100218:	e8 2b 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_user();
c010021d:	e8 da ff ff ff       	call   c01001fc <lab1_switch_to_user>
    lab1_print_cur_status();
c0100222:	e8 0f ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100227:	c7 04 24 08 6d 10 c0 	movl   $0xc0106d08,(%esp)
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
c0100252:	c7 04 24 27 6d 10 c0 	movl   $0xc0106d27,(%esp)
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
c01002a0:	88 90 20 c0 11 c0    	mov    %dl,-0x3fee3fe0(%eax)
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
c01002df:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c01002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002e7:	b8 20 c0 11 c0       	mov    $0xc011c020,%eax
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
c0100301:	e8 55 12 00 00       	call   c010155b <cons_putc>
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
c010033e:	e8 c8 5f 00 00       	call   c010630b <vprintfmt>
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
c010037a:	e8 dc 11 00 00       	call   c010155b <cons_putc>
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
c01003d6:	e8 bc 11 00 00       	call   c0101597 <cons_getc>
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
c0100548:	c7 00 2c 6d 10 c0    	movl   $0xc0106d2c,(%eax)
    info->eip_line = 0;
c010054e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055b:	c7 40 08 2c 6d 10 c0 	movl   $0xc0106d2c,0x8(%eax)
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
c010057f:	c7 45 f4 34 81 10 c0 	movl   $0xc0108134,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100586:	c7 45 f0 04 3e 11 c0 	movl   $0xc0113e04,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010058d:	c7 45 ec 05 3e 11 c0 	movl   $0xc0113e05,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100594:	c7 45 e8 bb 69 11 c0 	movl   $0xc01169bb,-0x18(%ebp)

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
c01006f3:	e8 6e 62 00 00       	call   c0106966 <strfind>
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
c0100882:	c7 04 24 36 6d 10 c0 	movl   $0xc0106d36,(%esp)
c0100889:	e8 ba fa ff ff       	call   c0100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100895:	c0 
c0100896:	c7 04 24 4f 6d 10 c0 	movl   $0xc0106d4f,(%esp)
c010089d:	e8 a6 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008a2:	c7 44 24 04 7b 6c 10 	movl   $0xc0106c7b,0x4(%esp)
c01008a9:	c0 
c01008aa:	c7 04 24 67 6d 10 c0 	movl   $0xc0106d67,(%esp)
c01008b1:	e8 92 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b6:	c7 44 24 04 00 c0 11 	movl   $0xc011c000,0x4(%esp)
c01008bd:	c0 
c01008be:	c7 04 24 7f 6d 10 c0 	movl   $0xc0106d7f,(%esp)
c01008c5:	e8 7e fa ff ff       	call   c0100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008ca:	c7 44 24 04 bc d0 11 	movl   $0xc011d0bc,0x4(%esp)
c01008d1:	c0 
c01008d2:	c7 04 24 97 6d 10 c0 	movl   $0xc0106d97,(%esp)
c01008d9:	e8 6a fa ff ff       	call   c0100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008de:	b8 bc d0 11 c0       	mov    $0xc011d0bc,%eax
c01008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008e9:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008ee:	29 c2                	sub    %eax,%edx
c01008f0:	89 d0                	mov    %edx,%eax
c01008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f8:	85 c0                	test   %eax,%eax
c01008fa:	0f 48 c2             	cmovs  %edx,%eax
c01008fd:	c1 f8 0a             	sar    $0xa,%eax
c0100900:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100904:	c7 04 24 b0 6d 10 c0 	movl   $0xc0106db0,(%esp)
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
c0100938:	c7 04 24 da 6d 10 c0 	movl   $0xc0106dda,(%esp)
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
c01009a7:	c7 04 24 f6 6d 10 c0 	movl   $0xc0106df6,(%esp)
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
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
}
c01009c9:	5d                   	pop    %ebp
c01009ca:	c3                   	ret    

c01009cb <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c01009cb:	55                   	push   %ebp
c01009cc:	89 e5                	mov    %esp,%ebp
c01009ce:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c01009d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c01009d8:	eb 0c                	jmp    c01009e6 <parse+0x1b>
            *buf ++ = '\0';
c01009da:	8b 45 08             	mov    0x8(%ebp),%eax
c01009dd:	8d 50 01             	lea    0x1(%eax),%edx
c01009e0:	89 55 08             	mov    %edx,0x8(%ebp)
c01009e3:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c01009e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01009e9:	0f b6 00             	movzbl (%eax),%eax
c01009ec:	84 c0                	test   %al,%al
c01009ee:	74 1d                	je     c0100a0d <parse+0x42>
c01009f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f3:	0f b6 00             	movzbl (%eax),%eax
c01009f6:	0f be c0             	movsbl %al,%eax
c01009f9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009fd:	c7 04 24 88 6e 10 c0 	movl   $0xc0106e88,(%esp)
c0100a04:	e8 2a 5f 00 00       	call   c0106933 <strchr>
c0100a09:	85 c0                	test   %eax,%eax
c0100a0b:	75 cd                	jne    c01009da <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a10:	0f b6 00             	movzbl (%eax),%eax
c0100a13:	84 c0                	test   %al,%al
c0100a15:	75 02                	jne    c0100a19 <parse+0x4e>
            break;
c0100a17:	eb 67                	jmp    c0100a80 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100a19:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100a1d:	75 14                	jne    c0100a33 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100a1f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100a26:	00 
c0100a27:	c7 04 24 8d 6e 10 c0 	movl   $0xc0106e8d,(%esp)
c0100a2e:	e8 15 f9 ff ff       	call   c0100348 <cprintf>
        }
        argv[argc ++] = buf;
c0100a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a36:	8d 50 01             	lea    0x1(%eax),%edx
c0100a39:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100a3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a46:	01 c2                	add    %eax,%edx
c0100a48:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a4b:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100a4d:	eb 04                	jmp    c0100a53 <parse+0x88>
            buf ++;
c0100a4f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100a53:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a56:	0f b6 00             	movzbl (%eax),%eax
c0100a59:	84 c0                	test   %al,%al
c0100a5b:	74 1d                	je     c0100a7a <parse+0xaf>
c0100a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a60:	0f b6 00             	movzbl (%eax),%eax
c0100a63:	0f be c0             	movsbl %al,%eax
c0100a66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a6a:	c7 04 24 88 6e 10 c0 	movl   $0xc0106e88,(%esp)
c0100a71:	e8 bd 5e 00 00       	call   c0106933 <strchr>
c0100a76:	85 c0                	test   %eax,%eax
c0100a78:	74 d5                	je     c0100a4f <parse+0x84>
            buf ++;
        }
    }
c0100a7a:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a7b:	e9 66 ff ff ff       	jmp    c01009e6 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100a83:	c9                   	leave  
c0100a84:	c3                   	ret    

c0100a85 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100a85:	55                   	push   %ebp
c0100a86:	89 e5                	mov    %esp,%ebp
c0100a88:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100a8b:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a92:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a95:	89 04 24             	mov    %eax,(%esp)
c0100a98:	e8 2e ff ff ff       	call   c01009cb <parse>
c0100a9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100aa0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100aa4:	75 0a                	jne    c0100ab0 <runcmd+0x2b>
        return 0;
c0100aa6:	b8 00 00 00 00       	mov    $0x0,%eax
c0100aab:	e9 85 00 00 00       	jmp    c0100b35 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ab0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100ab7:	eb 5c                	jmp    c0100b15 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100ab9:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100abc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100abf:	89 d0                	mov    %edx,%eax
c0100ac1:	01 c0                	add    %eax,%eax
c0100ac3:	01 d0                	add    %edx,%eax
c0100ac5:	c1 e0 02             	shl    $0x2,%eax
c0100ac8:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100acd:	8b 00                	mov    (%eax),%eax
c0100acf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100ad3:	89 04 24             	mov    %eax,(%esp)
c0100ad6:	e8 b9 5d 00 00       	call   c0106894 <strcmp>
c0100adb:	85 c0                	test   %eax,%eax
c0100add:	75 32                	jne    c0100b11 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100adf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ae2:	89 d0                	mov    %edx,%eax
c0100ae4:	01 c0                	add    %eax,%eax
c0100ae6:	01 d0                	add    %edx,%eax
c0100ae8:	c1 e0 02             	shl    $0x2,%eax
c0100aeb:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100af0:	8b 40 08             	mov    0x8(%eax),%eax
c0100af3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100af6:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100af9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100afc:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b00:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100b03:	83 c2 04             	add    $0x4,%edx
c0100b06:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100b0a:	89 0c 24             	mov    %ecx,(%esp)
c0100b0d:	ff d0                	call   *%eax
c0100b0f:	eb 24                	jmp    c0100b35 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b11:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b18:	83 f8 02             	cmp    $0x2,%eax
c0100b1b:	76 9c                	jbe    c0100ab9 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100b1d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b24:	c7 04 24 ab 6e 10 c0 	movl   $0xc0106eab,(%esp)
c0100b2b:	e8 18 f8 ff ff       	call   c0100348 <cprintf>
    return 0;
c0100b30:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100b35:	c9                   	leave  
c0100b36:	c3                   	ret    

c0100b37 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100b37:	55                   	push   %ebp
c0100b38:	89 e5                	mov    %esp,%ebp
c0100b3a:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100b3d:	c7 04 24 c4 6e 10 c0 	movl   $0xc0106ec4,(%esp)
c0100b44:	e8 ff f7 ff ff       	call   c0100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100b49:	c7 04 24 ec 6e 10 c0 	movl   $0xc0106eec,(%esp)
c0100b50:	e8 f3 f7 ff ff       	call   c0100348 <cprintf>

    if (tf != NULL) {
c0100b55:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100b59:	74 0b                	je     c0100b66 <kmonitor+0x2f>
        print_trapframe(tf);
c0100b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5e:	89 04 24             	mov    %eax,(%esp)
c0100b61:	e8 d5 0c 00 00       	call   c010183b <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100b66:	c7 04 24 11 6f 10 c0 	movl   $0xc0106f11,(%esp)
c0100b6d:	e8 cd f6 ff ff       	call   c010023f <readline>
c0100b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100b75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b79:	74 18                	je     c0100b93 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100b7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b85:	89 04 24             	mov    %eax,(%esp)
c0100b88:	e8 f8 fe ff ff       	call   c0100a85 <runcmd>
c0100b8d:	85 c0                	test   %eax,%eax
c0100b8f:	79 02                	jns    c0100b93 <kmonitor+0x5c>
                break;
c0100b91:	eb 02                	jmp    c0100b95 <kmonitor+0x5e>
            }
        }
    }
c0100b93:	eb d1                	jmp    c0100b66 <kmonitor+0x2f>
}
c0100b95:	c9                   	leave  
c0100b96:	c3                   	ret    

c0100b97 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100b97:	55                   	push   %ebp
c0100b98:	89 e5                	mov    %esp,%ebp
c0100b9a:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100ba4:	eb 3f                	jmp    c0100be5 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ba9:	89 d0                	mov    %edx,%eax
c0100bab:	01 c0                	add    %eax,%eax
c0100bad:	01 d0                	add    %edx,%eax
c0100baf:	c1 e0 02             	shl    $0x2,%eax
c0100bb2:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100bb7:	8b 48 04             	mov    0x4(%eax),%ecx
c0100bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bbd:	89 d0                	mov    %edx,%eax
c0100bbf:	01 c0                	add    %eax,%eax
c0100bc1:	01 d0                	add    %edx,%eax
c0100bc3:	c1 e0 02             	shl    $0x2,%eax
c0100bc6:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100bcb:	8b 00                	mov    (%eax),%eax
c0100bcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bd5:	c7 04 24 15 6f 10 c0 	movl   $0xc0106f15,(%esp)
c0100bdc:	e8 67 f7 ff ff       	call   c0100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100be1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100be8:	83 f8 02             	cmp    $0x2,%eax
c0100beb:	76 b9                	jbe    c0100ba6 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bf2:	c9                   	leave  
c0100bf3:	c3                   	ret    

c0100bf4 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100bf4:	55                   	push   %ebp
c0100bf5:	89 e5                	mov    %esp,%ebp
c0100bf7:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100bfa:	e8 7d fc ff ff       	call   c010087c <print_kerninfo>
    return 0;
c0100bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c04:	c9                   	leave  
c0100c05:	c3                   	ret    

c0100c06 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100c06:	55                   	push   %ebp
c0100c07:	89 e5                	mov    %esp,%ebp
c0100c09:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100c0c:	e8 b5 fd ff ff       	call   c01009c6 <print_stackframe>
    return 0;
c0100c11:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c16:	c9                   	leave  
c0100c17:	c3                   	ret    

c0100c18 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100c18:	55                   	push   %ebp
c0100c19:	89 e5                	mov    %esp,%ebp
c0100c1b:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100c1e:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
c0100c23:	85 c0                	test   %eax,%eax
c0100c25:	74 02                	je     c0100c29 <__panic+0x11>
        goto panic_dead;
c0100c27:	eb 59                	jmp    c0100c82 <__panic+0x6a>
    }
    is_panic = 1;
c0100c29:	c7 05 20 c4 11 c0 01 	movl   $0x1,0xc011c420
c0100c30:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100c33:	8d 45 14             	lea    0x14(%ebp),%eax
c0100c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100c39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c3c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100c40:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c47:	c7 04 24 1e 6f 10 c0 	movl   $0xc0106f1e,(%esp)
c0100c4e:	e8 f5 f6 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c5a:	8b 45 10             	mov    0x10(%ebp),%eax
c0100c5d:	89 04 24             	mov    %eax,(%esp)
c0100c60:	e8 b0 f6 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100c65:	c7 04 24 3a 6f 10 c0 	movl   $0xc0106f3a,(%esp)
c0100c6c:	e8 d7 f6 ff ff       	call   c0100348 <cprintf>
    
    cprintf("stack trackback:\n");
c0100c71:	c7 04 24 3c 6f 10 c0 	movl   $0xc0106f3c,(%esp)
c0100c78:	e8 cb f6 ff ff       	call   c0100348 <cprintf>
    print_stackframe();
c0100c7d:	e8 44 fd ff ff       	call   c01009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100c82:	e8 85 09 00 00       	call   c010160c <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100c87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100c8e:	e8 a4 fe ff ff       	call   c0100b37 <kmonitor>
    }
c0100c93:	eb f2                	jmp    c0100c87 <__panic+0x6f>

c0100c95 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100c95:	55                   	push   %ebp
c0100c96:	89 e5                	mov    %esp,%ebp
c0100c98:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100c9b:	8d 45 14             	lea    0x14(%ebp),%eax
c0100c9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ca4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100ca8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100caf:	c7 04 24 4e 6f 10 c0 	movl   $0xc0106f4e,(%esp)
c0100cb6:	e8 8d f6 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cc2:	8b 45 10             	mov    0x10(%ebp),%eax
c0100cc5:	89 04 24             	mov    %eax,(%esp)
c0100cc8:	e8 48 f6 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100ccd:	c7 04 24 3a 6f 10 c0 	movl   $0xc0106f3a,(%esp)
c0100cd4:	e8 6f f6 ff ff       	call   c0100348 <cprintf>
    va_end(ap);
}
c0100cd9:	c9                   	leave  
c0100cda:	c3                   	ret    

c0100cdb <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100cdb:	55                   	push   %ebp
c0100cdc:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100cde:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
}
c0100ce3:	5d                   	pop    %ebp
c0100ce4:	c3                   	ret    

c0100ce5 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100ce5:	55                   	push   %ebp
c0100ce6:	89 e5                	mov    %esp,%ebp
c0100ce8:	83 ec 28             	sub    $0x28,%esp
c0100ceb:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100cf1:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100cf5:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100cf9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100cfd:	ee                   	out    %al,(%dx)
c0100cfe:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100d04:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100d08:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100d0c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100d10:	ee                   	out    %al,(%dx)
c0100d11:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100d17:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100d1b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100d1f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100d23:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100d24:	c7 05 ac cf 11 c0 00 	movl   $0x0,0xc011cfac
c0100d2b:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100d2e:	c7 04 24 6c 6f 10 c0 	movl   $0xc0106f6c,(%esp)
c0100d35:	e8 0e f6 ff ff       	call   c0100348 <cprintf>
    pic_enable(IRQ_TIMER);
c0100d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d41:	e8 24 09 00 00       	call   c010166a <pic_enable>
}
c0100d46:	c9                   	leave  
c0100d47:	c3                   	ret    

c0100d48 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100d48:	55                   	push   %ebp
c0100d49:	89 e5                	mov    %esp,%ebp
c0100d4b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100d4e:	9c                   	pushf  
c0100d4f:	58                   	pop    %eax
c0100d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100d56:	25 00 02 00 00       	and    $0x200,%eax
c0100d5b:	85 c0                	test   %eax,%eax
c0100d5d:	74 0c                	je     c0100d6b <__intr_save+0x23>
        intr_disable();
c0100d5f:	e8 a8 08 00 00       	call   c010160c <intr_disable>
        return 1;
c0100d64:	b8 01 00 00 00       	mov    $0x1,%eax
c0100d69:	eb 05                	jmp    c0100d70 <__intr_save+0x28>
    }
    return 0;
c0100d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d70:	c9                   	leave  
c0100d71:	c3                   	ret    

c0100d72 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100d72:	55                   	push   %ebp
c0100d73:	89 e5                	mov    %esp,%ebp
c0100d75:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100d78:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d7c:	74 05                	je     c0100d83 <__intr_restore+0x11>
        intr_enable();
c0100d7e:	e8 83 08 00 00       	call   c0101606 <intr_enable>
    }
}
c0100d83:	c9                   	leave  
c0100d84:	c3                   	ret    

c0100d85 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100d85:	55                   	push   %ebp
c0100d86:	89 e5                	mov    %esp,%ebp
c0100d88:	83 ec 10             	sub    $0x10,%esp
c0100d8b:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100d91:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100d95:	89 c2                	mov    %eax,%edx
c0100d97:	ec                   	in     (%dx),%al
c0100d98:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100d9b:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100da1:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100da5:	89 c2                	mov    %eax,%edx
c0100da7:	ec                   	in     (%dx),%al
c0100da8:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100dab:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100db1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100db5:	89 c2                	mov    %eax,%edx
c0100db7:	ec                   	in     (%dx),%al
c0100db8:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100dbb:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100dc1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100dc5:	89 c2                	mov    %eax,%edx
c0100dc7:	ec                   	in     (%dx),%al
c0100dc8:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100dcb:	c9                   	leave  
c0100dcc:	c3                   	ret    

c0100dcd <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100dcd:	55                   	push   %ebp
c0100dce:	89 e5                	mov    %esp,%ebp
c0100dd0:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100dd3:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100dda:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ddd:	0f b7 00             	movzwl (%eax),%eax
c0100de0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100de4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100de7:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100def:	0f b7 00             	movzwl (%eax),%eax
c0100df2:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100df6:	74 12                	je     c0100e0a <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100df8:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100dff:	66 c7 05 46 c4 11 c0 	movw   $0x3b4,0xc011c446
c0100e06:	b4 03 
c0100e08:	eb 13                	jmp    c0100e1d <cga_init+0x50>
    } else {
        *cp = was;
c0100e0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e0d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100e11:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100e14:	66 c7 05 46 c4 11 c0 	movw   $0x3d4,0xc011c446
c0100e1b:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100e1d:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100e24:	0f b7 c0             	movzwl %ax,%eax
c0100e27:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100e2b:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e2f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e33:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e37:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100e38:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100e3f:	83 c0 01             	add    $0x1,%eax
c0100e42:	0f b7 c0             	movzwl %ax,%eax
c0100e45:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e49:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100e4d:	89 c2                	mov    %eax,%edx
c0100e4f:	ec                   	in     (%dx),%al
c0100e50:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100e53:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e57:	0f b6 c0             	movzbl %al,%eax
c0100e5a:	c1 e0 08             	shl    $0x8,%eax
c0100e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100e60:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100e67:	0f b7 c0             	movzwl %ax,%eax
c0100e6a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100e6e:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e72:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100e76:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e7a:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100e7b:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100e82:	83 c0 01             	add    $0x1,%eax
c0100e85:	0f b7 c0             	movzwl %ax,%eax
c0100e88:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e8c:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100e90:	89 c2                	mov    %eax,%edx
c0100e92:	ec                   	in     (%dx),%al
c0100e93:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100e96:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100e9a:	0f b6 c0             	movzbl %al,%eax
c0100e9d:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100ea0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea3:	a3 40 c4 11 c0       	mov    %eax,0xc011c440
    crt_pos = pos;
c0100ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100eab:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
}
c0100eb1:	c9                   	leave  
c0100eb2:	c3                   	ret    

c0100eb3 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100eb3:	55                   	push   %ebp
c0100eb4:	89 e5                	mov    %esp,%ebp
c0100eb6:	83 ec 48             	sub    $0x48,%esp
c0100eb9:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100ebf:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ec3:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100ec7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100ecb:	ee                   	out    %al,(%dx)
c0100ecc:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100ed2:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100ed6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100eda:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ede:	ee                   	out    %al,(%dx)
c0100edf:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100ee5:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100ee9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100eed:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ef1:	ee                   	out    %al,(%dx)
c0100ef2:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100ef8:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100efc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f00:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f04:	ee                   	out    %al,(%dx)
c0100f05:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100f0b:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100f0f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f13:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f17:	ee                   	out    %al,(%dx)
c0100f18:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100f1e:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100f22:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100f26:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100f2a:	ee                   	out    %al,(%dx)
c0100f2b:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100f31:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100f35:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100f39:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100f3d:	ee                   	out    %al,(%dx)
c0100f3e:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f44:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0100f48:	89 c2                	mov    %eax,%edx
c0100f4a:	ec                   	in     (%dx),%al
c0100f4b:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0100f4e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100f52:	3c ff                	cmp    $0xff,%al
c0100f54:	0f 95 c0             	setne  %al
c0100f57:	0f b6 c0             	movzbl %al,%eax
c0100f5a:	a3 48 c4 11 c0       	mov    %eax,0xc011c448
c0100f5f:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f65:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0100f69:	89 c2                	mov    %eax,%edx
c0100f6b:	ec                   	in     (%dx),%al
c0100f6c:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0100f6f:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0100f75:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0100f79:	89 c2                	mov    %eax,%edx
c0100f7b:	ec                   	in     (%dx),%al
c0100f7c:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0100f7f:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c0100f84:	85 c0                	test   %eax,%eax
c0100f86:	74 0c                	je     c0100f94 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0100f88:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0100f8f:	e8 d6 06 00 00       	call   c010166a <pic_enable>
    }
}
c0100f94:	c9                   	leave  
c0100f95:	c3                   	ret    

c0100f96 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0100f96:	55                   	push   %ebp
c0100f97:	89 e5                	mov    %esp,%ebp
c0100f99:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0100f9c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0100fa3:	eb 09                	jmp    c0100fae <lpt_putc_sub+0x18>
        delay();
c0100fa5:	e8 db fd ff ff       	call   c0100d85 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0100faa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0100fae:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0100fb4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100fb8:	89 c2                	mov    %eax,%edx
c0100fba:	ec                   	in     (%dx),%al
c0100fbb:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100fbe:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100fc2:	84 c0                	test   %al,%al
c0100fc4:	78 09                	js     c0100fcf <lpt_putc_sub+0x39>
c0100fc6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0100fcd:	7e d6                	jle    c0100fa5 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0100fcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fd2:	0f b6 c0             	movzbl %al,%eax
c0100fd5:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0100fdb:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fde:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100fe2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100fe6:	ee                   	out    %al,(%dx)
c0100fe7:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0100fed:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0100ff1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ff5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ff9:	ee                   	out    %al,(%dx)
c0100ffa:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c0101000:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c0101004:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101008:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010100c:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010100d:	c9                   	leave  
c010100e:	c3                   	ret    

c010100f <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c010100f:	55                   	push   %ebp
c0101010:	89 e5                	mov    %esp,%ebp
c0101012:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101015:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101019:	74 0d                	je     c0101028 <lpt_putc+0x19>
        lpt_putc_sub(c);
c010101b:	8b 45 08             	mov    0x8(%ebp),%eax
c010101e:	89 04 24             	mov    %eax,(%esp)
c0101021:	e8 70 ff ff ff       	call   c0100f96 <lpt_putc_sub>
c0101026:	eb 24                	jmp    c010104c <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0101028:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010102f:	e8 62 ff ff ff       	call   c0100f96 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101034:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010103b:	e8 56 ff ff ff       	call   c0100f96 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101040:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101047:	e8 4a ff ff ff       	call   c0100f96 <lpt_putc_sub>
    }
}
c010104c:	c9                   	leave  
c010104d:	c3                   	ret    

c010104e <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010104e:	55                   	push   %ebp
c010104f:	89 e5                	mov    %esp,%ebp
c0101051:	53                   	push   %ebx
c0101052:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101055:	8b 45 08             	mov    0x8(%ebp),%eax
c0101058:	b0 00                	mov    $0x0,%al
c010105a:	85 c0                	test   %eax,%eax
c010105c:	75 07                	jne    c0101065 <cga_putc+0x17>
        c |= 0x0700;
c010105e:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101065:	8b 45 08             	mov    0x8(%ebp),%eax
c0101068:	0f b6 c0             	movzbl %al,%eax
c010106b:	83 f8 0a             	cmp    $0xa,%eax
c010106e:	74 4c                	je     c01010bc <cga_putc+0x6e>
c0101070:	83 f8 0d             	cmp    $0xd,%eax
c0101073:	74 57                	je     c01010cc <cga_putc+0x7e>
c0101075:	83 f8 08             	cmp    $0x8,%eax
c0101078:	0f 85 88 00 00 00    	jne    c0101106 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c010107e:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101085:	66 85 c0             	test   %ax,%ax
c0101088:	74 30                	je     c01010ba <cga_putc+0x6c>
            crt_pos --;
c010108a:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101091:	83 e8 01             	sub    $0x1,%eax
c0101094:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010109a:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c010109f:	0f b7 15 44 c4 11 c0 	movzwl 0xc011c444,%edx
c01010a6:	0f b7 d2             	movzwl %dx,%edx
c01010a9:	01 d2                	add    %edx,%edx
c01010ab:	01 c2                	add    %eax,%edx
c01010ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01010b0:	b0 00                	mov    $0x0,%al
c01010b2:	83 c8 20             	or     $0x20,%eax
c01010b5:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01010b8:	eb 72                	jmp    c010112c <cga_putc+0xde>
c01010ba:	eb 70                	jmp    c010112c <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c01010bc:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01010c3:	83 c0 50             	add    $0x50,%eax
c01010c6:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01010cc:	0f b7 1d 44 c4 11 c0 	movzwl 0xc011c444,%ebx
c01010d3:	0f b7 0d 44 c4 11 c0 	movzwl 0xc011c444,%ecx
c01010da:	0f b7 c1             	movzwl %cx,%eax
c01010dd:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01010e3:	c1 e8 10             	shr    $0x10,%eax
c01010e6:	89 c2                	mov    %eax,%edx
c01010e8:	66 c1 ea 06          	shr    $0x6,%dx
c01010ec:	89 d0                	mov    %edx,%eax
c01010ee:	c1 e0 02             	shl    $0x2,%eax
c01010f1:	01 d0                	add    %edx,%eax
c01010f3:	c1 e0 04             	shl    $0x4,%eax
c01010f6:	29 c1                	sub    %eax,%ecx
c01010f8:	89 ca                	mov    %ecx,%edx
c01010fa:	89 d8                	mov    %ebx,%eax
c01010fc:	29 d0                	sub    %edx,%eax
c01010fe:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
        break;
c0101104:	eb 26                	jmp    c010112c <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101106:	8b 0d 40 c4 11 c0    	mov    0xc011c440,%ecx
c010110c:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101113:	8d 50 01             	lea    0x1(%eax),%edx
c0101116:	66 89 15 44 c4 11 c0 	mov    %dx,0xc011c444
c010111d:	0f b7 c0             	movzwl %ax,%eax
c0101120:	01 c0                	add    %eax,%eax
c0101122:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101125:	8b 45 08             	mov    0x8(%ebp),%eax
c0101128:	66 89 02             	mov    %ax,(%edx)
        break;
c010112b:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c010112c:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101133:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101137:	76 5b                	jbe    c0101194 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101139:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c010113e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101144:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c0101149:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101150:	00 
c0101151:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101155:	89 04 24             	mov    %eax,(%esp)
c0101158:	e8 d4 59 00 00       	call   c0106b31 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010115d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101164:	eb 15                	jmp    c010117b <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101166:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c010116b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010116e:	01 d2                	add    %edx,%edx
c0101170:	01 d0                	add    %edx,%eax
c0101172:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101177:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010117b:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101182:	7e e2                	jle    c0101166 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101184:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010118b:	83 e8 50             	sub    $0x50,%eax
c010118e:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101194:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c010119b:	0f b7 c0             	movzwl %ax,%eax
c010119e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01011a2:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c01011a6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01011aa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c01011af:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011b6:	66 c1 e8 08          	shr    $0x8,%ax
c01011ba:	0f b6 c0             	movzbl %al,%eax
c01011bd:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c01011c4:	83 c2 01             	add    $0x1,%edx
c01011c7:	0f b7 d2             	movzwl %dx,%edx
c01011ca:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c01011ce:	88 45 ed             	mov    %al,-0x13(%ebp)
c01011d1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01011d5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01011d9:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01011da:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c01011e1:	0f b7 c0             	movzwl %ax,%eax
c01011e4:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01011e8:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01011ec:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01011f0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01011f4:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01011f5:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011fc:	0f b6 c0             	movzbl %al,%eax
c01011ff:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c0101206:	83 c2 01             	add    $0x1,%edx
c0101209:	0f b7 d2             	movzwl %dx,%edx
c010120c:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101210:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101213:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101217:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010121b:	ee                   	out    %al,(%dx)
}
c010121c:	83 c4 34             	add    $0x34,%esp
c010121f:	5b                   	pop    %ebx
c0101220:	5d                   	pop    %ebp
c0101221:	c3                   	ret    

c0101222 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101222:	55                   	push   %ebp
c0101223:	89 e5                	mov    %esp,%ebp
c0101225:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101228:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010122f:	eb 09                	jmp    c010123a <serial_putc_sub+0x18>
        delay();
c0101231:	e8 4f fb ff ff       	call   c0100d85 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101236:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010123a:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101240:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101244:	89 c2                	mov    %eax,%edx
c0101246:	ec                   	in     (%dx),%al
c0101247:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010124a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010124e:	0f b6 c0             	movzbl %al,%eax
c0101251:	83 e0 20             	and    $0x20,%eax
c0101254:	85 c0                	test   %eax,%eax
c0101256:	75 09                	jne    c0101261 <serial_putc_sub+0x3f>
c0101258:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010125f:	7e d0                	jle    c0101231 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101261:	8b 45 08             	mov    0x8(%ebp),%eax
c0101264:	0f b6 c0             	movzbl %al,%eax
c0101267:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010126d:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101270:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101274:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101278:	ee                   	out    %al,(%dx)
}
c0101279:	c9                   	leave  
c010127a:	c3                   	ret    

c010127b <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010127b:	55                   	push   %ebp
c010127c:	89 e5                	mov    %esp,%ebp
c010127e:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101281:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101285:	74 0d                	je     c0101294 <serial_putc+0x19>
        serial_putc_sub(c);
c0101287:	8b 45 08             	mov    0x8(%ebp),%eax
c010128a:	89 04 24             	mov    %eax,(%esp)
c010128d:	e8 90 ff ff ff       	call   c0101222 <serial_putc_sub>
c0101292:	eb 24                	jmp    c01012b8 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101294:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010129b:	e8 82 ff ff ff       	call   c0101222 <serial_putc_sub>
        serial_putc_sub(' ');
c01012a0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01012a7:	e8 76 ff ff ff       	call   c0101222 <serial_putc_sub>
        serial_putc_sub('\b');
c01012ac:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01012b3:	e8 6a ff ff ff       	call   c0101222 <serial_putc_sub>
    }
}
c01012b8:	c9                   	leave  
c01012b9:	c3                   	ret    

c01012ba <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01012ba:	55                   	push   %ebp
c01012bb:	89 e5                	mov    %esp,%ebp
c01012bd:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01012c0:	eb 33                	jmp    c01012f5 <cons_intr+0x3b>
        if (c != 0) {
c01012c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01012c6:	74 2d                	je     c01012f5 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01012c8:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c01012cd:	8d 50 01             	lea    0x1(%eax),%edx
c01012d0:	89 15 64 c6 11 c0    	mov    %edx,0xc011c664
c01012d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01012d9:	88 90 60 c4 11 c0    	mov    %dl,-0x3fee3ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01012df:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c01012e4:	3d 00 02 00 00       	cmp    $0x200,%eax
c01012e9:	75 0a                	jne    c01012f5 <cons_intr+0x3b>
                cons.wpos = 0;
c01012eb:	c7 05 64 c6 11 c0 00 	movl   $0x0,0xc011c664
c01012f2:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01012f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01012f8:	ff d0                	call   *%eax
c01012fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01012fd:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101301:	75 bf                	jne    c01012c2 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101303:	c9                   	leave  
c0101304:	c3                   	ret    

c0101305 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101305:	55                   	push   %ebp
c0101306:	89 e5                	mov    %esp,%ebp
c0101308:	83 ec 10             	sub    $0x10,%esp
c010130b:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101311:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101315:	89 c2                	mov    %eax,%edx
c0101317:	ec                   	in     (%dx),%al
c0101318:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010131b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c010131f:	0f b6 c0             	movzbl %al,%eax
c0101322:	83 e0 01             	and    $0x1,%eax
c0101325:	85 c0                	test   %eax,%eax
c0101327:	75 07                	jne    c0101330 <serial_proc_data+0x2b>
        return -1;
c0101329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010132e:	eb 2a                	jmp    c010135a <serial_proc_data+0x55>
c0101330:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101336:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010133a:	89 c2                	mov    %eax,%edx
c010133c:	ec                   	in     (%dx),%al
c010133d:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101340:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101344:	0f b6 c0             	movzbl %al,%eax
c0101347:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010134a:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c010134e:	75 07                	jne    c0101357 <serial_proc_data+0x52>
        c = '\b';
c0101350:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101357:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010135a:	c9                   	leave  
c010135b:	c3                   	ret    

c010135c <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010135c:	55                   	push   %ebp
c010135d:	89 e5                	mov    %esp,%ebp
c010135f:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101362:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c0101367:	85 c0                	test   %eax,%eax
c0101369:	74 0c                	je     c0101377 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010136b:	c7 04 24 05 13 10 c0 	movl   $0xc0101305,(%esp)
c0101372:	e8 43 ff ff ff       	call   c01012ba <cons_intr>
    }
}
c0101377:	c9                   	leave  
c0101378:	c3                   	ret    

c0101379 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101379:	55                   	push   %ebp
c010137a:	89 e5                	mov    %esp,%ebp
c010137c:	83 ec 38             	sub    $0x38,%esp
c010137f:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101385:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101389:	89 c2                	mov    %eax,%edx
c010138b:	ec                   	in     (%dx),%al
c010138c:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010138f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101393:	0f b6 c0             	movzbl %al,%eax
c0101396:	83 e0 01             	and    $0x1,%eax
c0101399:	85 c0                	test   %eax,%eax
c010139b:	75 0a                	jne    c01013a7 <kbd_proc_data+0x2e>
        return -1;
c010139d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013a2:	e9 59 01 00 00       	jmp    c0101500 <kbd_proc_data+0x187>
c01013a7:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013ad:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01013b1:	89 c2                	mov    %eax,%edx
c01013b3:	ec                   	in     (%dx),%al
c01013b4:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01013b7:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01013bb:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01013be:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01013c2:	75 17                	jne    c01013db <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c01013c4:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01013c9:	83 c8 40             	or     $0x40,%eax
c01013cc:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c01013d1:	b8 00 00 00 00       	mov    $0x0,%eax
c01013d6:	e9 25 01 00 00       	jmp    c0101500 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01013db:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01013df:	84 c0                	test   %al,%al
c01013e1:	79 47                	jns    c010142a <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01013e3:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01013e8:	83 e0 40             	and    $0x40,%eax
c01013eb:	85 c0                	test   %eax,%eax
c01013ed:	75 09                	jne    c01013f8 <kbd_proc_data+0x7f>
c01013ef:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01013f3:	83 e0 7f             	and    $0x7f,%eax
c01013f6:	eb 04                	jmp    c01013fc <kbd_proc_data+0x83>
c01013f8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01013fc:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01013ff:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101403:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c010140a:	83 c8 40             	or     $0x40,%eax
c010140d:	0f b6 c0             	movzbl %al,%eax
c0101410:	f7 d0                	not    %eax
c0101412:	89 c2                	mov    %eax,%edx
c0101414:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101419:	21 d0                	and    %edx,%eax
c010141b:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c0101420:	b8 00 00 00 00       	mov    $0x0,%eax
c0101425:	e9 d6 00 00 00       	jmp    c0101500 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c010142a:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010142f:	83 e0 40             	and    $0x40,%eax
c0101432:	85 c0                	test   %eax,%eax
c0101434:	74 11                	je     c0101447 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101436:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010143a:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010143f:	83 e0 bf             	and    $0xffffffbf,%eax
c0101442:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    }

    shift |= shiftcode[data];
c0101447:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010144b:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c0101452:	0f b6 d0             	movzbl %al,%edx
c0101455:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010145a:	09 d0                	or     %edx,%eax
c010145c:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    shift ^= togglecode[data];
c0101461:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101465:	0f b6 80 40 91 11 c0 	movzbl -0x3fee6ec0(%eax),%eax
c010146c:	0f b6 d0             	movzbl %al,%edx
c010146f:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101474:	31 d0                	xor    %edx,%eax
c0101476:	a3 68 c6 11 c0       	mov    %eax,0xc011c668

    c = charcode[shift & (CTL | SHIFT)][data];
c010147b:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101480:	83 e0 03             	and    $0x3,%eax
c0101483:	8b 14 85 40 95 11 c0 	mov    -0x3fee6ac0(,%eax,4),%edx
c010148a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010148e:	01 d0                	add    %edx,%eax
c0101490:	0f b6 00             	movzbl (%eax),%eax
c0101493:	0f b6 c0             	movzbl %al,%eax
c0101496:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101499:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010149e:	83 e0 08             	and    $0x8,%eax
c01014a1:	85 c0                	test   %eax,%eax
c01014a3:	74 22                	je     c01014c7 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c01014a5:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01014a9:	7e 0c                	jle    c01014b7 <kbd_proc_data+0x13e>
c01014ab:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01014af:	7f 06                	jg     c01014b7 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c01014b1:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01014b5:	eb 10                	jmp    c01014c7 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c01014b7:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01014bb:	7e 0a                	jle    c01014c7 <kbd_proc_data+0x14e>
c01014bd:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01014c1:	7f 04                	jg     c01014c7 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c01014c3:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01014c7:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01014cc:	f7 d0                	not    %eax
c01014ce:	83 e0 06             	and    $0x6,%eax
c01014d1:	85 c0                	test   %eax,%eax
c01014d3:	75 28                	jne    c01014fd <kbd_proc_data+0x184>
c01014d5:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01014dc:	75 1f                	jne    c01014fd <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01014de:	c7 04 24 87 6f 10 c0 	movl   $0xc0106f87,(%esp)
c01014e5:	e8 5e ee ff ff       	call   c0100348 <cprintf>
c01014ea:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01014f0:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014f4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01014f8:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01014fc:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101500:	c9                   	leave  
c0101501:	c3                   	ret    

c0101502 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101502:	55                   	push   %ebp
c0101503:	89 e5                	mov    %esp,%ebp
c0101505:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101508:	c7 04 24 79 13 10 c0 	movl   $0xc0101379,(%esp)
c010150f:	e8 a6 fd ff ff       	call   c01012ba <cons_intr>
}
c0101514:	c9                   	leave  
c0101515:	c3                   	ret    

c0101516 <kbd_init>:

static void
kbd_init(void) {
c0101516:	55                   	push   %ebp
c0101517:	89 e5                	mov    %esp,%ebp
c0101519:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c010151c:	e8 e1 ff ff ff       	call   c0101502 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101521:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101528:	e8 3d 01 00 00       	call   c010166a <pic_enable>
}
c010152d:	c9                   	leave  
c010152e:	c3                   	ret    

c010152f <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010152f:	55                   	push   %ebp
c0101530:	89 e5                	mov    %esp,%ebp
c0101532:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101535:	e8 93 f8 ff ff       	call   c0100dcd <cga_init>
    serial_init();
c010153a:	e8 74 f9 ff ff       	call   c0100eb3 <serial_init>
    kbd_init();
c010153f:	e8 d2 ff ff ff       	call   c0101516 <kbd_init>
    if (!serial_exists) {
c0101544:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c0101549:	85 c0                	test   %eax,%eax
c010154b:	75 0c                	jne    c0101559 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010154d:	c7 04 24 93 6f 10 c0 	movl   $0xc0106f93,(%esp)
c0101554:	e8 ef ed ff ff       	call   c0100348 <cprintf>
    }
}
c0101559:	c9                   	leave  
c010155a:	c3                   	ret    

c010155b <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010155b:	55                   	push   %ebp
c010155c:	89 e5                	mov    %esp,%ebp
c010155e:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101561:	e8 e2 f7 ff ff       	call   c0100d48 <__intr_save>
c0101566:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101569:	8b 45 08             	mov    0x8(%ebp),%eax
c010156c:	89 04 24             	mov    %eax,(%esp)
c010156f:	e8 9b fa ff ff       	call   c010100f <lpt_putc>
        cga_putc(c);
c0101574:	8b 45 08             	mov    0x8(%ebp),%eax
c0101577:	89 04 24             	mov    %eax,(%esp)
c010157a:	e8 cf fa ff ff       	call   c010104e <cga_putc>
        serial_putc(c);
c010157f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101582:	89 04 24             	mov    %eax,(%esp)
c0101585:	e8 f1 fc ff ff       	call   c010127b <serial_putc>
    }
    local_intr_restore(intr_flag);
c010158a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010158d:	89 04 24             	mov    %eax,(%esp)
c0101590:	e8 dd f7 ff ff       	call   c0100d72 <__intr_restore>
}
c0101595:	c9                   	leave  
c0101596:	c3                   	ret    

c0101597 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101597:	55                   	push   %ebp
c0101598:	89 e5                	mov    %esp,%ebp
c010159a:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010159d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01015a4:	e8 9f f7 ff ff       	call   c0100d48 <__intr_save>
c01015a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01015ac:	e8 ab fd ff ff       	call   c010135c <serial_intr>
        kbd_intr();
c01015b1:	e8 4c ff ff ff       	call   c0101502 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01015b6:	8b 15 60 c6 11 c0    	mov    0xc011c660,%edx
c01015bc:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c01015c1:	39 c2                	cmp    %eax,%edx
c01015c3:	74 31                	je     c01015f6 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01015c5:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c01015ca:	8d 50 01             	lea    0x1(%eax),%edx
c01015cd:	89 15 60 c6 11 c0    	mov    %edx,0xc011c660
c01015d3:	0f b6 80 60 c4 11 c0 	movzbl -0x3fee3ba0(%eax),%eax
c01015da:	0f b6 c0             	movzbl %al,%eax
c01015dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01015e0:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c01015e5:	3d 00 02 00 00       	cmp    $0x200,%eax
c01015ea:	75 0a                	jne    c01015f6 <cons_getc+0x5f>
                cons.rpos = 0;
c01015ec:	c7 05 60 c6 11 c0 00 	movl   $0x0,0xc011c660
c01015f3:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01015f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01015f9:	89 04 24             	mov    %eax,(%esp)
c01015fc:	e8 71 f7 ff ff       	call   c0100d72 <__intr_restore>
    return c;
c0101601:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101604:	c9                   	leave  
c0101605:	c3                   	ret    

c0101606 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101606:	55                   	push   %ebp
c0101607:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101609:	fb                   	sti    
    sti();
}
c010160a:	5d                   	pop    %ebp
c010160b:	c3                   	ret    

c010160c <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010160c:	55                   	push   %ebp
c010160d:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c010160f:	fa                   	cli    
    cli();
}
c0101610:	5d                   	pop    %ebp
c0101611:	c3                   	ret    

c0101612 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101612:	55                   	push   %ebp
c0101613:	89 e5                	mov    %esp,%ebp
c0101615:	83 ec 14             	sub    $0x14,%esp
c0101618:	8b 45 08             	mov    0x8(%ebp),%eax
c010161b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010161f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101623:	66 a3 50 95 11 c0    	mov    %ax,0xc0119550
    if (did_init) {
c0101629:	a1 6c c6 11 c0       	mov    0xc011c66c,%eax
c010162e:	85 c0                	test   %eax,%eax
c0101630:	74 36                	je     c0101668 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101632:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101636:	0f b6 c0             	movzbl %al,%eax
c0101639:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010163f:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101642:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101646:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010164a:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c010164b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010164f:	66 c1 e8 08          	shr    $0x8,%ax
c0101653:	0f b6 c0             	movzbl %al,%eax
c0101656:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010165c:	88 45 f9             	mov    %al,-0x7(%ebp)
c010165f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101663:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101667:	ee                   	out    %al,(%dx)
    }
}
c0101668:	c9                   	leave  
c0101669:	c3                   	ret    

c010166a <pic_enable>:

void
pic_enable(unsigned int irq) {
c010166a:	55                   	push   %ebp
c010166b:	89 e5                	mov    %esp,%ebp
c010166d:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101670:	8b 45 08             	mov    0x8(%ebp),%eax
c0101673:	ba 01 00 00 00       	mov    $0x1,%edx
c0101678:	89 c1                	mov    %eax,%ecx
c010167a:	d3 e2                	shl    %cl,%edx
c010167c:	89 d0                	mov    %edx,%eax
c010167e:	f7 d0                	not    %eax
c0101680:	89 c2                	mov    %eax,%edx
c0101682:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c0101689:	21 d0                	and    %edx,%eax
c010168b:	0f b7 c0             	movzwl %ax,%eax
c010168e:	89 04 24             	mov    %eax,(%esp)
c0101691:	e8 7c ff ff ff       	call   c0101612 <pic_setmask>
}
c0101696:	c9                   	leave  
c0101697:	c3                   	ret    

c0101698 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101698:	55                   	push   %ebp
c0101699:	89 e5                	mov    %esp,%ebp
c010169b:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c010169e:	c7 05 6c c6 11 c0 01 	movl   $0x1,0xc011c66c
c01016a5:	00 00 00 
c01016a8:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016ae:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c01016b2:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01016b6:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01016ba:	ee                   	out    %al,(%dx)
c01016bb:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01016c1:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c01016c5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01016c9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01016cd:	ee                   	out    %al,(%dx)
c01016ce:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01016d4:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c01016d8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01016dc:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01016e0:	ee                   	out    %al,(%dx)
c01016e1:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c01016e7:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01016eb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01016ef:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01016f3:	ee                   	out    %al,(%dx)
c01016f4:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01016fa:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01016fe:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101702:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101706:	ee                   	out    %al,(%dx)
c0101707:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c010170d:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0101711:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101715:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101719:	ee                   	out    %al,(%dx)
c010171a:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0101720:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0101724:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101728:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010172c:	ee                   	out    %al,(%dx)
c010172d:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0101733:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0101737:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010173b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010173f:	ee                   	out    %al,(%dx)
c0101740:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0101746:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c010174a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010174e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101752:	ee                   	out    %al,(%dx)
c0101753:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101759:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c010175d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101761:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101765:	ee                   	out    %al,(%dx)
c0101766:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c010176c:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0101770:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101774:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101778:	ee                   	out    %al,(%dx)
c0101779:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010177f:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c0101783:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101787:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010178b:	ee                   	out    %al,(%dx)
c010178c:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c0101792:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c0101796:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010179a:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010179e:	ee                   	out    %al,(%dx)
c010179f:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01017a5:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01017a9:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01017ad:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01017b1:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01017b2:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c01017b9:	66 83 f8 ff          	cmp    $0xffff,%ax
c01017bd:	74 12                	je     c01017d1 <pic_init+0x139>
        pic_setmask(irq_mask);
c01017bf:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c01017c6:	0f b7 c0             	movzwl %ax,%eax
c01017c9:	89 04 24             	mov    %eax,(%esp)
c01017cc:	e8 41 fe ff ff       	call   c0101612 <pic_setmask>
    }
}
c01017d1:	c9                   	leave  
c01017d2:	c3                   	ret    

c01017d3 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01017d3:	55                   	push   %ebp
c01017d4:	89 e5                	mov    %esp,%ebp
c01017d6:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01017d9:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01017e0:	00 
c01017e1:	c7 04 24 c0 6f 10 c0 	movl   $0xc0106fc0,(%esp)
c01017e8:	e8 5b eb ff ff       	call   c0100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01017ed:	c9                   	leave  
c01017ee:	c3                   	ret    

c01017ef <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01017ef:	55                   	push   %ebp
c01017f0:	89 e5                	mov    %esp,%ebp
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
}
c01017f2:	5d                   	pop    %ebp
c01017f3:	c3                   	ret    

c01017f4 <trapname>:

static const char *
trapname(int trapno) {
c01017f4:	55                   	push   %ebp
c01017f5:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01017f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01017fa:	83 f8 13             	cmp    $0x13,%eax
c01017fd:	77 0c                	ja     c010180b <trapname+0x17>
        return excnames[trapno];
c01017ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0101802:	8b 04 85 20 73 10 c0 	mov    -0x3fef8ce0(,%eax,4),%eax
c0101809:	eb 18                	jmp    c0101823 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010180b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c010180f:	7e 0d                	jle    c010181e <trapname+0x2a>
c0101811:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101815:	7f 07                	jg     c010181e <trapname+0x2a>
        return "Hardware Interrupt";
c0101817:	b8 ca 6f 10 c0       	mov    $0xc0106fca,%eax
c010181c:	eb 05                	jmp    c0101823 <trapname+0x2f>
    }
    return "(unknown trap)";
c010181e:	b8 dd 6f 10 c0       	mov    $0xc0106fdd,%eax
}
c0101823:	5d                   	pop    %ebp
c0101824:	c3                   	ret    

c0101825 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101825:	55                   	push   %ebp
c0101826:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101828:	8b 45 08             	mov    0x8(%ebp),%eax
c010182b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010182f:	66 83 f8 08          	cmp    $0x8,%ax
c0101833:	0f 94 c0             	sete   %al
c0101836:	0f b6 c0             	movzbl %al,%eax
}
c0101839:	5d                   	pop    %ebp
c010183a:	c3                   	ret    

c010183b <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c010183b:	55                   	push   %ebp
c010183c:	89 e5                	mov    %esp,%ebp
c010183e:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101841:	8b 45 08             	mov    0x8(%ebp),%eax
c0101844:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101848:	c7 04 24 1e 70 10 c0 	movl   $0xc010701e,(%esp)
c010184f:	e8 f4 ea ff ff       	call   c0100348 <cprintf>
    print_regs(&tf->tf_regs);
c0101854:	8b 45 08             	mov    0x8(%ebp),%eax
c0101857:	89 04 24             	mov    %eax,(%esp)
c010185a:	e8 a1 01 00 00       	call   c0101a00 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c010185f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101862:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101866:	0f b7 c0             	movzwl %ax,%eax
c0101869:	89 44 24 04          	mov    %eax,0x4(%esp)
c010186d:	c7 04 24 2f 70 10 c0 	movl   $0xc010702f,(%esp)
c0101874:	e8 cf ea ff ff       	call   c0100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101879:	8b 45 08             	mov    0x8(%ebp),%eax
c010187c:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101880:	0f b7 c0             	movzwl %ax,%eax
c0101883:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101887:	c7 04 24 42 70 10 c0 	movl   $0xc0107042,(%esp)
c010188e:	e8 b5 ea ff ff       	call   c0100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101893:	8b 45 08             	mov    0x8(%ebp),%eax
c0101896:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010189a:	0f b7 c0             	movzwl %ax,%eax
c010189d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01018a1:	c7 04 24 55 70 10 c0 	movl   $0xc0107055,(%esp)
c01018a8:	e8 9b ea ff ff       	call   c0100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c01018ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01018b0:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c01018b4:	0f b7 c0             	movzwl %ax,%eax
c01018b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01018bb:	c7 04 24 68 70 10 c0 	movl   $0xc0107068,(%esp)
c01018c2:	e8 81 ea ff ff       	call   c0100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01018c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01018ca:	8b 40 30             	mov    0x30(%eax),%eax
c01018cd:	89 04 24             	mov    %eax,(%esp)
c01018d0:	e8 1f ff ff ff       	call   c01017f4 <trapname>
c01018d5:	8b 55 08             	mov    0x8(%ebp),%edx
c01018d8:	8b 52 30             	mov    0x30(%edx),%edx
c01018db:	89 44 24 08          	mov    %eax,0x8(%esp)
c01018df:	89 54 24 04          	mov    %edx,0x4(%esp)
c01018e3:	c7 04 24 7b 70 10 c0 	movl   $0xc010707b,(%esp)
c01018ea:	e8 59 ea ff ff       	call   c0100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01018ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01018f2:	8b 40 34             	mov    0x34(%eax),%eax
c01018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01018f9:	c7 04 24 8d 70 10 c0 	movl   $0xc010708d,(%esp)
c0101900:	e8 43 ea ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101905:	8b 45 08             	mov    0x8(%ebp),%eax
c0101908:	8b 40 38             	mov    0x38(%eax),%eax
c010190b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010190f:	c7 04 24 9c 70 10 c0 	movl   $0xc010709c,(%esp)
c0101916:	e8 2d ea ff ff       	call   c0100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c010191b:	8b 45 08             	mov    0x8(%ebp),%eax
c010191e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101922:	0f b7 c0             	movzwl %ax,%eax
c0101925:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101929:	c7 04 24 ab 70 10 c0 	movl   $0xc01070ab,(%esp)
c0101930:	e8 13 ea ff ff       	call   c0100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101935:	8b 45 08             	mov    0x8(%ebp),%eax
c0101938:	8b 40 40             	mov    0x40(%eax),%eax
c010193b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010193f:	c7 04 24 be 70 10 c0 	movl   $0xc01070be,(%esp)
c0101946:	e8 fd e9 ff ff       	call   c0100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010194b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101952:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101959:	eb 3e                	jmp    c0101999 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c010195b:	8b 45 08             	mov    0x8(%ebp),%eax
c010195e:	8b 50 40             	mov    0x40(%eax),%edx
c0101961:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101964:	21 d0                	and    %edx,%eax
c0101966:	85 c0                	test   %eax,%eax
c0101968:	74 28                	je     c0101992 <print_trapframe+0x157>
c010196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010196d:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101974:	85 c0                	test   %eax,%eax
c0101976:	74 1a                	je     c0101992 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010197b:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101982:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101986:	c7 04 24 cd 70 10 c0 	movl   $0xc01070cd,(%esp)
c010198d:	e8 b6 e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101992:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101996:	d1 65 f0             	shll   -0x10(%ebp)
c0101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010199c:	83 f8 17             	cmp    $0x17,%eax
c010199f:	76 ba                	jbe    c010195b <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c01019a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01019a4:	8b 40 40             	mov    0x40(%eax),%eax
c01019a7:	25 00 30 00 00       	and    $0x3000,%eax
c01019ac:	c1 e8 0c             	shr    $0xc,%eax
c01019af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019b3:	c7 04 24 d1 70 10 c0 	movl   $0xc01070d1,(%esp)
c01019ba:	e8 89 e9 ff ff       	call   c0100348 <cprintf>

    if (!trap_in_kernel(tf)) {
c01019bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01019c2:	89 04 24             	mov    %eax,(%esp)
c01019c5:	e8 5b fe ff ff       	call   c0101825 <trap_in_kernel>
c01019ca:	85 c0                	test   %eax,%eax
c01019cc:	75 30                	jne    c01019fe <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01019ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01019d1:	8b 40 44             	mov    0x44(%eax),%eax
c01019d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019d8:	c7 04 24 da 70 10 c0 	movl   $0xc01070da,(%esp)
c01019df:	e8 64 e9 ff ff       	call   c0100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01019e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01019e7:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01019eb:	0f b7 c0             	movzwl %ax,%eax
c01019ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019f2:	c7 04 24 e9 70 10 c0 	movl   $0xc01070e9,(%esp)
c01019f9:	e8 4a e9 ff ff       	call   c0100348 <cprintf>
    }
}
c01019fe:	c9                   	leave  
c01019ff:	c3                   	ret    

c0101a00 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101a00:	55                   	push   %ebp
c0101a01:	89 e5                	mov    %esp,%ebp
c0101a03:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101a06:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a09:	8b 00                	mov    (%eax),%eax
c0101a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a0f:	c7 04 24 fc 70 10 c0 	movl   $0xc01070fc,(%esp)
c0101a16:	e8 2d e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a1e:	8b 40 04             	mov    0x4(%eax),%eax
c0101a21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a25:	c7 04 24 0b 71 10 c0 	movl   $0xc010710b,(%esp)
c0101a2c:	e8 17 e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101a31:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a34:	8b 40 08             	mov    0x8(%eax),%eax
c0101a37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a3b:	c7 04 24 1a 71 10 c0 	movl   $0xc010711a,(%esp)
c0101a42:	e8 01 e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101a47:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4a:	8b 40 0c             	mov    0xc(%eax),%eax
c0101a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a51:	c7 04 24 29 71 10 c0 	movl   $0xc0107129,(%esp)
c0101a58:	e8 eb e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a60:	8b 40 10             	mov    0x10(%eax),%eax
c0101a63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a67:	c7 04 24 38 71 10 c0 	movl   $0xc0107138,(%esp)
c0101a6e:	e8 d5 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101a73:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a76:	8b 40 14             	mov    0x14(%eax),%eax
c0101a79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a7d:	c7 04 24 47 71 10 c0 	movl   $0xc0107147,(%esp)
c0101a84:	e8 bf e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101a89:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a8c:	8b 40 18             	mov    0x18(%eax),%eax
c0101a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a93:	c7 04 24 56 71 10 c0 	movl   $0xc0107156,(%esp)
c0101a9a:	e8 a9 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa2:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aa9:	c7 04 24 65 71 10 c0 	movl   $0xc0107165,(%esp)
c0101ab0:	e8 93 e8 ff ff       	call   c0100348 <cprintf>
}
c0101ab5:	c9                   	leave  
c0101ab6:	c3                   	ret    

c0101ab7 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101ab7:	55                   	push   %ebp
c0101ab8:	89 e5                	mov    %esp,%ebp
c0101aba:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101abd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac0:	8b 40 30             	mov    0x30(%eax),%eax
c0101ac3:	83 f8 2f             	cmp    $0x2f,%eax
c0101ac6:	77 1e                	ja     c0101ae6 <trap_dispatch+0x2f>
c0101ac8:	83 f8 2e             	cmp    $0x2e,%eax
c0101acb:	0f 83 bf 00 00 00    	jae    c0101b90 <trap_dispatch+0xd9>
c0101ad1:	83 f8 21             	cmp    $0x21,%eax
c0101ad4:	74 40                	je     c0101b16 <trap_dispatch+0x5f>
c0101ad6:	83 f8 24             	cmp    $0x24,%eax
c0101ad9:	74 15                	je     c0101af0 <trap_dispatch+0x39>
c0101adb:	83 f8 20             	cmp    $0x20,%eax
c0101ade:	0f 84 af 00 00 00    	je     c0101b93 <trap_dispatch+0xdc>
c0101ae4:	eb 72                	jmp    c0101b58 <trap_dispatch+0xa1>
c0101ae6:	83 e8 78             	sub    $0x78,%eax
c0101ae9:	83 f8 01             	cmp    $0x1,%eax
c0101aec:	77 6a                	ja     c0101b58 <trap_dispatch+0xa1>
c0101aee:	eb 4c                	jmp    c0101b3c <trap_dispatch+0x85>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101af0:	e8 a2 fa ff ff       	call   c0101597 <cons_getc>
c0101af5:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101af8:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101afc:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101b00:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b08:	c7 04 24 74 71 10 c0 	movl   $0xc0107174,(%esp)
c0101b0f:	e8 34 e8 ff ff       	call   c0100348 <cprintf>
        break;
c0101b14:	eb 7e                	jmp    c0101b94 <trap_dispatch+0xdd>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101b16:	e8 7c fa ff ff       	call   c0101597 <cons_getc>
c0101b1b:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101b1e:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101b22:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101b26:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b2e:	c7 04 24 86 71 10 c0 	movl   $0xc0107186,(%esp)
c0101b35:	e8 0e e8 ff ff       	call   c0100348 <cprintf>
        break;
c0101b3a:	eb 58                	jmp    c0101b94 <trap_dispatch+0xdd>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101b3c:	c7 44 24 08 95 71 10 	movl   $0xc0107195,0x8(%esp)
c0101b43:	c0 
c0101b44:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
c0101b4b:	00 
c0101b4c:	c7 04 24 a5 71 10 c0 	movl   $0xc01071a5,(%esp)
c0101b53:	e8 c0 f0 ff ff       	call   c0100c18 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101b58:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b5f:	0f b7 c0             	movzwl %ax,%eax
c0101b62:	83 e0 03             	and    $0x3,%eax
c0101b65:	85 c0                	test   %eax,%eax
c0101b67:	75 2b                	jne    c0101b94 <trap_dispatch+0xdd>
            print_trapframe(tf);
c0101b69:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6c:	89 04 24             	mov    %eax,(%esp)
c0101b6f:	e8 c7 fc ff ff       	call   c010183b <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101b74:	c7 44 24 08 b6 71 10 	movl   $0xc01071b6,0x8(%esp)
c0101b7b:	c0 
c0101b7c:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c0101b83:	00 
c0101b84:	c7 04 24 a5 71 10 c0 	movl   $0xc01071a5,(%esp)
c0101b8b:	e8 88 f0 ff ff       	call   c0100c18 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101b90:	90                   	nop
c0101b91:	eb 01                	jmp    c0101b94 <trap_dispatch+0xdd>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
c0101b93:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101b94:	c9                   	leave  
c0101b95:	c3                   	ret    

c0101b96 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101b96:	55                   	push   %ebp
c0101b97:	89 e5                	mov    %esp,%ebp
c0101b99:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9f:	89 04 24             	mov    %eax,(%esp)
c0101ba2:	e8 10 ff ff ff       	call   c0101ab7 <trap_dispatch>
}
c0101ba7:	c9                   	leave  
c0101ba8:	c3                   	ret    

c0101ba9 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101ba9:	1e                   	push   %ds
    pushl %es
c0101baa:	06                   	push   %es
    pushl %fs
c0101bab:	0f a0                	push   %fs
    pushl %gs
c0101bad:	0f a8                	push   %gs
    pushal
c0101baf:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101bb0:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101bb5:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101bb7:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101bb9:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101bba:	e8 d7 ff ff ff       	call   c0101b96 <trap>

    # pop the pushed stack pointer
    popl %esp
c0101bbf:	5c                   	pop    %esp

c0101bc0 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101bc0:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101bc1:	0f a9                	pop    %gs
    popl %fs
c0101bc3:	0f a1                	pop    %fs
    popl %es
c0101bc5:	07                   	pop    %es
    popl %ds
c0101bc6:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101bc7:	83 c4 08             	add    $0x8,%esp
    iret
c0101bca:	cf                   	iret   

c0101bcb <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101bcb:	6a 00                	push   $0x0
  pushl $0
c0101bcd:	6a 00                	push   $0x0
  jmp __alltraps
c0101bcf:	e9 d5 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101bd4 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101bd4:	6a 00                	push   $0x0
  pushl $1
c0101bd6:	6a 01                	push   $0x1
  jmp __alltraps
c0101bd8:	e9 cc ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101bdd <vector2>:
.globl vector2
vector2:
  pushl $0
c0101bdd:	6a 00                	push   $0x0
  pushl $2
c0101bdf:	6a 02                	push   $0x2
  jmp __alltraps
c0101be1:	e9 c3 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101be6 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101be6:	6a 00                	push   $0x0
  pushl $3
c0101be8:	6a 03                	push   $0x3
  jmp __alltraps
c0101bea:	e9 ba ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101bef <vector4>:
.globl vector4
vector4:
  pushl $0
c0101bef:	6a 00                	push   $0x0
  pushl $4
c0101bf1:	6a 04                	push   $0x4
  jmp __alltraps
c0101bf3:	e9 b1 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101bf8 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101bf8:	6a 00                	push   $0x0
  pushl $5
c0101bfa:	6a 05                	push   $0x5
  jmp __alltraps
c0101bfc:	e9 a8 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c01 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101c01:	6a 00                	push   $0x0
  pushl $6
c0101c03:	6a 06                	push   $0x6
  jmp __alltraps
c0101c05:	e9 9f ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c0a <vector7>:
.globl vector7
vector7:
  pushl $0
c0101c0a:	6a 00                	push   $0x0
  pushl $7
c0101c0c:	6a 07                	push   $0x7
  jmp __alltraps
c0101c0e:	e9 96 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c13 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101c13:	6a 08                	push   $0x8
  jmp __alltraps
c0101c15:	e9 8f ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c1a <vector9>:
.globl vector9
vector9:
  pushl $0
c0101c1a:	6a 00                	push   $0x0
  pushl $9
c0101c1c:	6a 09                	push   $0x9
  jmp __alltraps
c0101c1e:	e9 86 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c23 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101c23:	6a 0a                	push   $0xa
  jmp __alltraps
c0101c25:	e9 7f ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c2a <vector11>:
.globl vector11
vector11:
  pushl $11
c0101c2a:	6a 0b                	push   $0xb
  jmp __alltraps
c0101c2c:	e9 78 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c31 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101c31:	6a 0c                	push   $0xc
  jmp __alltraps
c0101c33:	e9 71 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c38 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101c38:	6a 0d                	push   $0xd
  jmp __alltraps
c0101c3a:	e9 6a ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c3f <vector14>:
.globl vector14
vector14:
  pushl $14
c0101c3f:	6a 0e                	push   $0xe
  jmp __alltraps
c0101c41:	e9 63 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c46 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101c46:	6a 00                	push   $0x0
  pushl $15
c0101c48:	6a 0f                	push   $0xf
  jmp __alltraps
c0101c4a:	e9 5a ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c4f <vector16>:
.globl vector16
vector16:
  pushl $0
c0101c4f:	6a 00                	push   $0x0
  pushl $16
c0101c51:	6a 10                	push   $0x10
  jmp __alltraps
c0101c53:	e9 51 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c58 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101c58:	6a 11                	push   $0x11
  jmp __alltraps
c0101c5a:	e9 4a ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c5f <vector18>:
.globl vector18
vector18:
  pushl $0
c0101c5f:	6a 00                	push   $0x0
  pushl $18
c0101c61:	6a 12                	push   $0x12
  jmp __alltraps
c0101c63:	e9 41 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c68 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101c68:	6a 00                	push   $0x0
  pushl $19
c0101c6a:	6a 13                	push   $0x13
  jmp __alltraps
c0101c6c:	e9 38 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c71 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101c71:	6a 00                	push   $0x0
  pushl $20
c0101c73:	6a 14                	push   $0x14
  jmp __alltraps
c0101c75:	e9 2f ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c7a <vector21>:
.globl vector21
vector21:
  pushl $0
c0101c7a:	6a 00                	push   $0x0
  pushl $21
c0101c7c:	6a 15                	push   $0x15
  jmp __alltraps
c0101c7e:	e9 26 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c83 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101c83:	6a 00                	push   $0x0
  pushl $22
c0101c85:	6a 16                	push   $0x16
  jmp __alltraps
c0101c87:	e9 1d ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c8c <vector23>:
.globl vector23
vector23:
  pushl $0
c0101c8c:	6a 00                	push   $0x0
  pushl $23
c0101c8e:	6a 17                	push   $0x17
  jmp __alltraps
c0101c90:	e9 14 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c95 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101c95:	6a 00                	push   $0x0
  pushl $24
c0101c97:	6a 18                	push   $0x18
  jmp __alltraps
c0101c99:	e9 0b ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c9e <vector25>:
.globl vector25
vector25:
  pushl $0
c0101c9e:	6a 00                	push   $0x0
  pushl $25
c0101ca0:	6a 19                	push   $0x19
  jmp __alltraps
c0101ca2:	e9 02 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101ca7 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101ca7:	6a 00                	push   $0x0
  pushl $26
c0101ca9:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101cab:	e9 f9 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cb0 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101cb0:	6a 00                	push   $0x0
  pushl $27
c0101cb2:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101cb4:	e9 f0 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cb9 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101cb9:	6a 00                	push   $0x0
  pushl $28
c0101cbb:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101cbd:	e9 e7 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cc2 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101cc2:	6a 00                	push   $0x0
  pushl $29
c0101cc4:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101cc6:	e9 de fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101ccb <vector30>:
.globl vector30
vector30:
  pushl $0
c0101ccb:	6a 00                	push   $0x0
  pushl $30
c0101ccd:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101ccf:	e9 d5 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cd4 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101cd4:	6a 00                	push   $0x0
  pushl $31
c0101cd6:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101cd8:	e9 cc fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cdd <vector32>:
.globl vector32
vector32:
  pushl $0
c0101cdd:	6a 00                	push   $0x0
  pushl $32
c0101cdf:	6a 20                	push   $0x20
  jmp __alltraps
c0101ce1:	e9 c3 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101ce6 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101ce6:	6a 00                	push   $0x0
  pushl $33
c0101ce8:	6a 21                	push   $0x21
  jmp __alltraps
c0101cea:	e9 ba fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cef <vector34>:
.globl vector34
vector34:
  pushl $0
c0101cef:	6a 00                	push   $0x0
  pushl $34
c0101cf1:	6a 22                	push   $0x22
  jmp __alltraps
c0101cf3:	e9 b1 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cf8 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101cf8:	6a 00                	push   $0x0
  pushl $35
c0101cfa:	6a 23                	push   $0x23
  jmp __alltraps
c0101cfc:	e9 a8 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d01 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101d01:	6a 00                	push   $0x0
  pushl $36
c0101d03:	6a 24                	push   $0x24
  jmp __alltraps
c0101d05:	e9 9f fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d0a <vector37>:
.globl vector37
vector37:
  pushl $0
c0101d0a:	6a 00                	push   $0x0
  pushl $37
c0101d0c:	6a 25                	push   $0x25
  jmp __alltraps
c0101d0e:	e9 96 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d13 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101d13:	6a 00                	push   $0x0
  pushl $38
c0101d15:	6a 26                	push   $0x26
  jmp __alltraps
c0101d17:	e9 8d fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d1c <vector39>:
.globl vector39
vector39:
  pushl $0
c0101d1c:	6a 00                	push   $0x0
  pushl $39
c0101d1e:	6a 27                	push   $0x27
  jmp __alltraps
c0101d20:	e9 84 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d25 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101d25:	6a 00                	push   $0x0
  pushl $40
c0101d27:	6a 28                	push   $0x28
  jmp __alltraps
c0101d29:	e9 7b fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d2e <vector41>:
.globl vector41
vector41:
  pushl $0
c0101d2e:	6a 00                	push   $0x0
  pushl $41
c0101d30:	6a 29                	push   $0x29
  jmp __alltraps
c0101d32:	e9 72 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d37 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101d37:	6a 00                	push   $0x0
  pushl $42
c0101d39:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101d3b:	e9 69 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d40 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101d40:	6a 00                	push   $0x0
  pushl $43
c0101d42:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101d44:	e9 60 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d49 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101d49:	6a 00                	push   $0x0
  pushl $44
c0101d4b:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101d4d:	e9 57 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d52 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101d52:	6a 00                	push   $0x0
  pushl $45
c0101d54:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101d56:	e9 4e fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d5b <vector46>:
.globl vector46
vector46:
  pushl $0
c0101d5b:	6a 00                	push   $0x0
  pushl $46
c0101d5d:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101d5f:	e9 45 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d64 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101d64:	6a 00                	push   $0x0
  pushl $47
c0101d66:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101d68:	e9 3c fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d6d <vector48>:
.globl vector48
vector48:
  pushl $0
c0101d6d:	6a 00                	push   $0x0
  pushl $48
c0101d6f:	6a 30                	push   $0x30
  jmp __alltraps
c0101d71:	e9 33 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d76 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101d76:	6a 00                	push   $0x0
  pushl $49
c0101d78:	6a 31                	push   $0x31
  jmp __alltraps
c0101d7a:	e9 2a fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d7f <vector50>:
.globl vector50
vector50:
  pushl $0
c0101d7f:	6a 00                	push   $0x0
  pushl $50
c0101d81:	6a 32                	push   $0x32
  jmp __alltraps
c0101d83:	e9 21 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d88 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101d88:	6a 00                	push   $0x0
  pushl $51
c0101d8a:	6a 33                	push   $0x33
  jmp __alltraps
c0101d8c:	e9 18 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d91 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101d91:	6a 00                	push   $0x0
  pushl $52
c0101d93:	6a 34                	push   $0x34
  jmp __alltraps
c0101d95:	e9 0f fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d9a <vector53>:
.globl vector53
vector53:
  pushl $0
c0101d9a:	6a 00                	push   $0x0
  pushl $53
c0101d9c:	6a 35                	push   $0x35
  jmp __alltraps
c0101d9e:	e9 06 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101da3 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101da3:	6a 00                	push   $0x0
  pushl $54
c0101da5:	6a 36                	push   $0x36
  jmp __alltraps
c0101da7:	e9 fd fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dac <vector55>:
.globl vector55
vector55:
  pushl $0
c0101dac:	6a 00                	push   $0x0
  pushl $55
c0101dae:	6a 37                	push   $0x37
  jmp __alltraps
c0101db0:	e9 f4 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101db5 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101db5:	6a 00                	push   $0x0
  pushl $56
c0101db7:	6a 38                	push   $0x38
  jmp __alltraps
c0101db9:	e9 eb fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dbe <vector57>:
.globl vector57
vector57:
  pushl $0
c0101dbe:	6a 00                	push   $0x0
  pushl $57
c0101dc0:	6a 39                	push   $0x39
  jmp __alltraps
c0101dc2:	e9 e2 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dc7 <vector58>:
.globl vector58
vector58:
  pushl $0
c0101dc7:	6a 00                	push   $0x0
  pushl $58
c0101dc9:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101dcb:	e9 d9 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dd0 <vector59>:
.globl vector59
vector59:
  pushl $0
c0101dd0:	6a 00                	push   $0x0
  pushl $59
c0101dd2:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101dd4:	e9 d0 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dd9 <vector60>:
.globl vector60
vector60:
  pushl $0
c0101dd9:	6a 00                	push   $0x0
  pushl $60
c0101ddb:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101ddd:	e9 c7 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101de2 <vector61>:
.globl vector61
vector61:
  pushl $0
c0101de2:	6a 00                	push   $0x0
  pushl $61
c0101de4:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101de6:	e9 be fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101deb <vector62>:
.globl vector62
vector62:
  pushl $0
c0101deb:	6a 00                	push   $0x0
  pushl $62
c0101ded:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101def:	e9 b5 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101df4 <vector63>:
.globl vector63
vector63:
  pushl $0
c0101df4:	6a 00                	push   $0x0
  pushl $63
c0101df6:	6a 3f                	push   $0x3f
  jmp __alltraps
c0101df8:	e9 ac fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dfd <vector64>:
.globl vector64
vector64:
  pushl $0
c0101dfd:	6a 00                	push   $0x0
  pushl $64
c0101dff:	6a 40                	push   $0x40
  jmp __alltraps
c0101e01:	e9 a3 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e06 <vector65>:
.globl vector65
vector65:
  pushl $0
c0101e06:	6a 00                	push   $0x0
  pushl $65
c0101e08:	6a 41                	push   $0x41
  jmp __alltraps
c0101e0a:	e9 9a fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e0f <vector66>:
.globl vector66
vector66:
  pushl $0
c0101e0f:	6a 00                	push   $0x0
  pushl $66
c0101e11:	6a 42                	push   $0x42
  jmp __alltraps
c0101e13:	e9 91 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e18 <vector67>:
.globl vector67
vector67:
  pushl $0
c0101e18:	6a 00                	push   $0x0
  pushl $67
c0101e1a:	6a 43                	push   $0x43
  jmp __alltraps
c0101e1c:	e9 88 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e21 <vector68>:
.globl vector68
vector68:
  pushl $0
c0101e21:	6a 00                	push   $0x0
  pushl $68
c0101e23:	6a 44                	push   $0x44
  jmp __alltraps
c0101e25:	e9 7f fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e2a <vector69>:
.globl vector69
vector69:
  pushl $0
c0101e2a:	6a 00                	push   $0x0
  pushl $69
c0101e2c:	6a 45                	push   $0x45
  jmp __alltraps
c0101e2e:	e9 76 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e33 <vector70>:
.globl vector70
vector70:
  pushl $0
c0101e33:	6a 00                	push   $0x0
  pushl $70
c0101e35:	6a 46                	push   $0x46
  jmp __alltraps
c0101e37:	e9 6d fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e3c <vector71>:
.globl vector71
vector71:
  pushl $0
c0101e3c:	6a 00                	push   $0x0
  pushl $71
c0101e3e:	6a 47                	push   $0x47
  jmp __alltraps
c0101e40:	e9 64 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e45 <vector72>:
.globl vector72
vector72:
  pushl $0
c0101e45:	6a 00                	push   $0x0
  pushl $72
c0101e47:	6a 48                	push   $0x48
  jmp __alltraps
c0101e49:	e9 5b fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e4e <vector73>:
.globl vector73
vector73:
  pushl $0
c0101e4e:	6a 00                	push   $0x0
  pushl $73
c0101e50:	6a 49                	push   $0x49
  jmp __alltraps
c0101e52:	e9 52 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e57 <vector74>:
.globl vector74
vector74:
  pushl $0
c0101e57:	6a 00                	push   $0x0
  pushl $74
c0101e59:	6a 4a                	push   $0x4a
  jmp __alltraps
c0101e5b:	e9 49 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e60 <vector75>:
.globl vector75
vector75:
  pushl $0
c0101e60:	6a 00                	push   $0x0
  pushl $75
c0101e62:	6a 4b                	push   $0x4b
  jmp __alltraps
c0101e64:	e9 40 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e69 <vector76>:
.globl vector76
vector76:
  pushl $0
c0101e69:	6a 00                	push   $0x0
  pushl $76
c0101e6b:	6a 4c                	push   $0x4c
  jmp __alltraps
c0101e6d:	e9 37 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e72 <vector77>:
.globl vector77
vector77:
  pushl $0
c0101e72:	6a 00                	push   $0x0
  pushl $77
c0101e74:	6a 4d                	push   $0x4d
  jmp __alltraps
c0101e76:	e9 2e fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e7b <vector78>:
.globl vector78
vector78:
  pushl $0
c0101e7b:	6a 00                	push   $0x0
  pushl $78
c0101e7d:	6a 4e                	push   $0x4e
  jmp __alltraps
c0101e7f:	e9 25 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e84 <vector79>:
.globl vector79
vector79:
  pushl $0
c0101e84:	6a 00                	push   $0x0
  pushl $79
c0101e86:	6a 4f                	push   $0x4f
  jmp __alltraps
c0101e88:	e9 1c fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e8d <vector80>:
.globl vector80
vector80:
  pushl $0
c0101e8d:	6a 00                	push   $0x0
  pushl $80
c0101e8f:	6a 50                	push   $0x50
  jmp __alltraps
c0101e91:	e9 13 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e96 <vector81>:
.globl vector81
vector81:
  pushl $0
c0101e96:	6a 00                	push   $0x0
  pushl $81
c0101e98:	6a 51                	push   $0x51
  jmp __alltraps
c0101e9a:	e9 0a fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e9f <vector82>:
.globl vector82
vector82:
  pushl $0
c0101e9f:	6a 00                	push   $0x0
  pushl $82
c0101ea1:	6a 52                	push   $0x52
  jmp __alltraps
c0101ea3:	e9 01 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101ea8 <vector83>:
.globl vector83
vector83:
  pushl $0
c0101ea8:	6a 00                	push   $0x0
  pushl $83
c0101eaa:	6a 53                	push   $0x53
  jmp __alltraps
c0101eac:	e9 f8 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101eb1 <vector84>:
.globl vector84
vector84:
  pushl $0
c0101eb1:	6a 00                	push   $0x0
  pushl $84
c0101eb3:	6a 54                	push   $0x54
  jmp __alltraps
c0101eb5:	e9 ef fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101eba <vector85>:
.globl vector85
vector85:
  pushl $0
c0101eba:	6a 00                	push   $0x0
  pushl $85
c0101ebc:	6a 55                	push   $0x55
  jmp __alltraps
c0101ebe:	e9 e6 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ec3 <vector86>:
.globl vector86
vector86:
  pushl $0
c0101ec3:	6a 00                	push   $0x0
  pushl $86
c0101ec5:	6a 56                	push   $0x56
  jmp __alltraps
c0101ec7:	e9 dd fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ecc <vector87>:
.globl vector87
vector87:
  pushl $0
c0101ecc:	6a 00                	push   $0x0
  pushl $87
c0101ece:	6a 57                	push   $0x57
  jmp __alltraps
c0101ed0:	e9 d4 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ed5 <vector88>:
.globl vector88
vector88:
  pushl $0
c0101ed5:	6a 00                	push   $0x0
  pushl $88
c0101ed7:	6a 58                	push   $0x58
  jmp __alltraps
c0101ed9:	e9 cb fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ede <vector89>:
.globl vector89
vector89:
  pushl $0
c0101ede:	6a 00                	push   $0x0
  pushl $89
c0101ee0:	6a 59                	push   $0x59
  jmp __alltraps
c0101ee2:	e9 c2 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ee7 <vector90>:
.globl vector90
vector90:
  pushl $0
c0101ee7:	6a 00                	push   $0x0
  pushl $90
c0101ee9:	6a 5a                	push   $0x5a
  jmp __alltraps
c0101eeb:	e9 b9 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ef0 <vector91>:
.globl vector91
vector91:
  pushl $0
c0101ef0:	6a 00                	push   $0x0
  pushl $91
c0101ef2:	6a 5b                	push   $0x5b
  jmp __alltraps
c0101ef4:	e9 b0 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ef9 <vector92>:
.globl vector92
vector92:
  pushl $0
c0101ef9:	6a 00                	push   $0x0
  pushl $92
c0101efb:	6a 5c                	push   $0x5c
  jmp __alltraps
c0101efd:	e9 a7 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f02 <vector93>:
.globl vector93
vector93:
  pushl $0
c0101f02:	6a 00                	push   $0x0
  pushl $93
c0101f04:	6a 5d                	push   $0x5d
  jmp __alltraps
c0101f06:	e9 9e fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f0b <vector94>:
.globl vector94
vector94:
  pushl $0
c0101f0b:	6a 00                	push   $0x0
  pushl $94
c0101f0d:	6a 5e                	push   $0x5e
  jmp __alltraps
c0101f0f:	e9 95 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f14 <vector95>:
.globl vector95
vector95:
  pushl $0
c0101f14:	6a 00                	push   $0x0
  pushl $95
c0101f16:	6a 5f                	push   $0x5f
  jmp __alltraps
c0101f18:	e9 8c fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f1d <vector96>:
.globl vector96
vector96:
  pushl $0
c0101f1d:	6a 00                	push   $0x0
  pushl $96
c0101f1f:	6a 60                	push   $0x60
  jmp __alltraps
c0101f21:	e9 83 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f26 <vector97>:
.globl vector97
vector97:
  pushl $0
c0101f26:	6a 00                	push   $0x0
  pushl $97
c0101f28:	6a 61                	push   $0x61
  jmp __alltraps
c0101f2a:	e9 7a fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f2f <vector98>:
.globl vector98
vector98:
  pushl $0
c0101f2f:	6a 00                	push   $0x0
  pushl $98
c0101f31:	6a 62                	push   $0x62
  jmp __alltraps
c0101f33:	e9 71 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f38 <vector99>:
.globl vector99
vector99:
  pushl $0
c0101f38:	6a 00                	push   $0x0
  pushl $99
c0101f3a:	6a 63                	push   $0x63
  jmp __alltraps
c0101f3c:	e9 68 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f41 <vector100>:
.globl vector100
vector100:
  pushl $0
c0101f41:	6a 00                	push   $0x0
  pushl $100
c0101f43:	6a 64                	push   $0x64
  jmp __alltraps
c0101f45:	e9 5f fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f4a <vector101>:
.globl vector101
vector101:
  pushl $0
c0101f4a:	6a 00                	push   $0x0
  pushl $101
c0101f4c:	6a 65                	push   $0x65
  jmp __alltraps
c0101f4e:	e9 56 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f53 <vector102>:
.globl vector102
vector102:
  pushl $0
c0101f53:	6a 00                	push   $0x0
  pushl $102
c0101f55:	6a 66                	push   $0x66
  jmp __alltraps
c0101f57:	e9 4d fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f5c <vector103>:
.globl vector103
vector103:
  pushl $0
c0101f5c:	6a 00                	push   $0x0
  pushl $103
c0101f5e:	6a 67                	push   $0x67
  jmp __alltraps
c0101f60:	e9 44 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f65 <vector104>:
.globl vector104
vector104:
  pushl $0
c0101f65:	6a 00                	push   $0x0
  pushl $104
c0101f67:	6a 68                	push   $0x68
  jmp __alltraps
c0101f69:	e9 3b fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f6e <vector105>:
.globl vector105
vector105:
  pushl $0
c0101f6e:	6a 00                	push   $0x0
  pushl $105
c0101f70:	6a 69                	push   $0x69
  jmp __alltraps
c0101f72:	e9 32 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f77 <vector106>:
.globl vector106
vector106:
  pushl $0
c0101f77:	6a 00                	push   $0x0
  pushl $106
c0101f79:	6a 6a                	push   $0x6a
  jmp __alltraps
c0101f7b:	e9 29 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f80 <vector107>:
.globl vector107
vector107:
  pushl $0
c0101f80:	6a 00                	push   $0x0
  pushl $107
c0101f82:	6a 6b                	push   $0x6b
  jmp __alltraps
c0101f84:	e9 20 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f89 <vector108>:
.globl vector108
vector108:
  pushl $0
c0101f89:	6a 00                	push   $0x0
  pushl $108
c0101f8b:	6a 6c                	push   $0x6c
  jmp __alltraps
c0101f8d:	e9 17 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f92 <vector109>:
.globl vector109
vector109:
  pushl $0
c0101f92:	6a 00                	push   $0x0
  pushl $109
c0101f94:	6a 6d                	push   $0x6d
  jmp __alltraps
c0101f96:	e9 0e fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f9b <vector110>:
.globl vector110
vector110:
  pushl $0
c0101f9b:	6a 00                	push   $0x0
  pushl $110
c0101f9d:	6a 6e                	push   $0x6e
  jmp __alltraps
c0101f9f:	e9 05 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101fa4 <vector111>:
.globl vector111
vector111:
  pushl $0
c0101fa4:	6a 00                	push   $0x0
  pushl $111
c0101fa6:	6a 6f                	push   $0x6f
  jmp __alltraps
c0101fa8:	e9 fc fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fad <vector112>:
.globl vector112
vector112:
  pushl $0
c0101fad:	6a 00                	push   $0x0
  pushl $112
c0101faf:	6a 70                	push   $0x70
  jmp __alltraps
c0101fb1:	e9 f3 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fb6 <vector113>:
.globl vector113
vector113:
  pushl $0
c0101fb6:	6a 00                	push   $0x0
  pushl $113
c0101fb8:	6a 71                	push   $0x71
  jmp __alltraps
c0101fba:	e9 ea fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fbf <vector114>:
.globl vector114
vector114:
  pushl $0
c0101fbf:	6a 00                	push   $0x0
  pushl $114
c0101fc1:	6a 72                	push   $0x72
  jmp __alltraps
c0101fc3:	e9 e1 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fc8 <vector115>:
.globl vector115
vector115:
  pushl $0
c0101fc8:	6a 00                	push   $0x0
  pushl $115
c0101fca:	6a 73                	push   $0x73
  jmp __alltraps
c0101fcc:	e9 d8 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fd1 <vector116>:
.globl vector116
vector116:
  pushl $0
c0101fd1:	6a 00                	push   $0x0
  pushl $116
c0101fd3:	6a 74                	push   $0x74
  jmp __alltraps
c0101fd5:	e9 cf fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fda <vector117>:
.globl vector117
vector117:
  pushl $0
c0101fda:	6a 00                	push   $0x0
  pushl $117
c0101fdc:	6a 75                	push   $0x75
  jmp __alltraps
c0101fde:	e9 c6 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fe3 <vector118>:
.globl vector118
vector118:
  pushl $0
c0101fe3:	6a 00                	push   $0x0
  pushl $118
c0101fe5:	6a 76                	push   $0x76
  jmp __alltraps
c0101fe7:	e9 bd fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fec <vector119>:
.globl vector119
vector119:
  pushl $0
c0101fec:	6a 00                	push   $0x0
  pushl $119
c0101fee:	6a 77                	push   $0x77
  jmp __alltraps
c0101ff0:	e9 b4 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101ff5 <vector120>:
.globl vector120
vector120:
  pushl $0
c0101ff5:	6a 00                	push   $0x0
  pushl $120
c0101ff7:	6a 78                	push   $0x78
  jmp __alltraps
c0101ff9:	e9 ab fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101ffe <vector121>:
.globl vector121
vector121:
  pushl $0
c0101ffe:	6a 00                	push   $0x0
  pushl $121
c0102000:	6a 79                	push   $0x79
  jmp __alltraps
c0102002:	e9 a2 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102007 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102007:	6a 00                	push   $0x0
  pushl $122
c0102009:	6a 7a                	push   $0x7a
  jmp __alltraps
c010200b:	e9 99 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102010 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102010:	6a 00                	push   $0x0
  pushl $123
c0102012:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102014:	e9 90 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102019 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102019:	6a 00                	push   $0x0
  pushl $124
c010201b:	6a 7c                	push   $0x7c
  jmp __alltraps
c010201d:	e9 87 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102022 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102022:	6a 00                	push   $0x0
  pushl $125
c0102024:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102026:	e9 7e fb ff ff       	jmp    c0101ba9 <__alltraps>

c010202b <vector126>:
.globl vector126
vector126:
  pushl $0
c010202b:	6a 00                	push   $0x0
  pushl $126
c010202d:	6a 7e                	push   $0x7e
  jmp __alltraps
c010202f:	e9 75 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102034 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102034:	6a 00                	push   $0x0
  pushl $127
c0102036:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102038:	e9 6c fb ff ff       	jmp    c0101ba9 <__alltraps>

c010203d <vector128>:
.globl vector128
vector128:
  pushl $0
c010203d:	6a 00                	push   $0x0
  pushl $128
c010203f:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102044:	e9 60 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102049 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102049:	6a 00                	push   $0x0
  pushl $129
c010204b:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102050:	e9 54 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102055 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102055:	6a 00                	push   $0x0
  pushl $130
c0102057:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010205c:	e9 48 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102061 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102061:	6a 00                	push   $0x0
  pushl $131
c0102063:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102068:	e9 3c fb ff ff       	jmp    c0101ba9 <__alltraps>

c010206d <vector132>:
.globl vector132
vector132:
  pushl $0
c010206d:	6a 00                	push   $0x0
  pushl $132
c010206f:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102074:	e9 30 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102079 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102079:	6a 00                	push   $0x0
  pushl $133
c010207b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102080:	e9 24 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102085 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102085:	6a 00                	push   $0x0
  pushl $134
c0102087:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010208c:	e9 18 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102091 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102091:	6a 00                	push   $0x0
  pushl $135
c0102093:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102098:	e9 0c fb ff ff       	jmp    c0101ba9 <__alltraps>

c010209d <vector136>:
.globl vector136
vector136:
  pushl $0
c010209d:	6a 00                	push   $0x0
  pushl $136
c010209f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01020a4:	e9 00 fb ff ff       	jmp    c0101ba9 <__alltraps>

c01020a9 <vector137>:
.globl vector137
vector137:
  pushl $0
c01020a9:	6a 00                	push   $0x0
  pushl $137
c01020ab:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01020b0:	e9 f4 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020b5 <vector138>:
.globl vector138
vector138:
  pushl $0
c01020b5:	6a 00                	push   $0x0
  pushl $138
c01020b7:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01020bc:	e9 e8 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020c1 <vector139>:
.globl vector139
vector139:
  pushl $0
c01020c1:	6a 00                	push   $0x0
  pushl $139
c01020c3:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01020c8:	e9 dc fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020cd <vector140>:
.globl vector140
vector140:
  pushl $0
c01020cd:	6a 00                	push   $0x0
  pushl $140
c01020cf:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01020d4:	e9 d0 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020d9 <vector141>:
.globl vector141
vector141:
  pushl $0
c01020d9:	6a 00                	push   $0x0
  pushl $141
c01020db:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01020e0:	e9 c4 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020e5 <vector142>:
.globl vector142
vector142:
  pushl $0
c01020e5:	6a 00                	push   $0x0
  pushl $142
c01020e7:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01020ec:	e9 b8 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020f1 <vector143>:
.globl vector143
vector143:
  pushl $0
c01020f1:	6a 00                	push   $0x0
  pushl $143
c01020f3:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01020f8:	e9 ac fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020fd <vector144>:
.globl vector144
vector144:
  pushl $0
c01020fd:	6a 00                	push   $0x0
  pushl $144
c01020ff:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102104:	e9 a0 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102109 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102109:	6a 00                	push   $0x0
  pushl $145
c010210b:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102110:	e9 94 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102115 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102115:	6a 00                	push   $0x0
  pushl $146
c0102117:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010211c:	e9 88 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102121 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102121:	6a 00                	push   $0x0
  pushl $147
c0102123:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102128:	e9 7c fa ff ff       	jmp    c0101ba9 <__alltraps>

c010212d <vector148>:
.globl vector148
vector148:
  pushl $0
c010212d:	6a 00                	push   $0x0
  pushl $148
c010212f:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102134:	e9 70 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102139 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102139:	6a 00                	push   $0x0
  pushl $149
c010213b:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102140:	e9 64 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102145 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102145:	6a 00                	push   $0x0
  pushl $150
c0102147:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010214c:	e9 58 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102151 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102151:	6a 00                	push   $0x0
  pushl $151
c0102153:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102158:	e9 4c fa ff ff       	jmp    c0101ba9 <__alltraps>

c010215d <vector152>:
.globl vector152
vector152:
  pushl $0
c010215d:	6a 00                	push   $0x0
  pushl $152
c010215f:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102164:	e9 40 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102169 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102169:	6a 00                	push   $0x0
  pushl $153
c010216b:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102170:	e9 34 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102175 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102175:	6a 00                	push   $0x0
  pushl $154
c0102177:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010217c:	e9 28 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102181 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102181:	6a 00                	push   $0x0
  pushl $155
c0102183:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102188:	e9 1c fa ff ff       	jmp    c0101ba9 <__alltraps>

c010218d <vector156>:
.globl vector156
vector156:
  pushl $0
c010218d:	6a 00                	push   $0x0
  pushl $156
c010218f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102194:	e9 10 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102199 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102199:	6a 00                	push   $0x0
  pushl $157
c010219b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01021a0:	e9 04 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01021a5 <vector158>:
.globl vector158
vector158:
  pushl $0
c01021a5:	6a 00                	push   $0x0
  pushl $158
c01021a7:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01021ac:	e9 f8 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021b1 <vector159>:
.globl vector159
vector159:
  pushl $0
c01021b1:	6a 00                	push   $0x0
  pushl $159
c01021b3:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01021b8:	e9 ec f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021bd <vector160>:
.globl vector160
vector160:
  pushl $0
c01021bd:	6a 00                	push   $0x0
  pushl $160
c01021bf:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01021c4:	e9 e0 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021c9 <vector161>:
.globl vector161
vector161:
  pushl $0
c01021c9:	6a 00                	push   $0x0
  pushl $161
c01021cb:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01021d0:	e9 d4 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021d5 <vector162>:
.globl vector162
vector162:
  pushl $0
c01021d5:	6a 00                	push   $0x0
  pushl $162
c01021d7:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01021dc:	e9 c8 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021e1 <vector163>:
.globl vector163
vector163:
  pushl $0
c01021e1:	6a 00                	push   $0x0
  pushl $163
c01021e3:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01021e8:	e9 bc f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021ed <vector164>:
.globl vector164
vector164:
  pushl $0
c01021ed:	6a 00                	push   $0x0
  pushl $164
c01021ef:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01021f4:	e9 b0 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021f9 <vector165>:
.globl vector165
vector165:
  pushl $0
c01021f9:	6a 00                	push   $0x0
  pushl $165
c01021fb:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102200:	e9 a4 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102205 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102205:	6a 00                	push   $0x0
  pushl $166
c0102207:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010220c:	e9 98 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102211 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102211:	6a 00                	push   $0x0
  pushl $167
c0102213:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102218:	e9 8c f9 ff ff       	jmp    c0101ba9 <__alltraps>

c010221d <vector168>:
.globl vector168
vector168:
  pushl $0
c010221d:	6a 00                	push   $0x0
  pushl $168
c010221f:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102224:	e9 80 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102229 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102229:	6a 00                	push   $0x0
  pushl $169
c010222b:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102230:	e9 74 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102235 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102235:	6a 00                	push   $0x0
  pushl $170
c0102237:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010223c:	e9 68 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102241 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102241:	6a 00                	push   $0x0
  pushl $171
c0102243:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102248:	e9 5c f9 ff ff       	jmp    c0101ba9 <__alltraps>

c010224d <vector172>:
.globl vector172
vector172:
  pushl $0
c010224d:	6a 00                	push   $0x0
  pushl $172
c010224f:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102254:	e9 50 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102259 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102259:	6a 00                	push   $0x0
  pushl $173
c010225b:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102260:	e9 44 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102265 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102265:	6a 00                	push   $0x0
  pushl $174
c0102267:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010226c:	e9 38 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102271 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102271:	6a 00                	push   $0x0
  pushl $175
c0102273:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102278:	e9 2c f9 ff ff       	jmp    c0101ba9 <__alltraps>

c010227d <vector176>:
.globl vector176
vector176:
  pushl $0
c010227d:	6a 00                	push   $0x0
  pushl $176
c010227f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102284:	e9 20 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102289 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102289:	6a 00                	push   $0x0
  pushl $177
c010228b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102290:	e9 14 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102295 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102295:	6a 00                	push   $0x0
  pushl $178
c0102297:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010229c:	e9 08 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01022a1 <vector179>:
.globl vector179
vector179:
  pushl $0
c01022a1:	6a 00                	push   $0x0
  pushl $179
c01022a3:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01022a8:	e9 fc f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022ad <vector180>:
.globl vector180
vector180:
  pushl $0
c01022ad:	6a 00                	push   $0x0
  pushl $180
c01022af:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01022b4:	e9 f0 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022b9 <vector181>:
.globl vector181
vector181:
  pushl $0
c01022b9:	6a 00                	push   $0x0
  pushl $181
c01022bb:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01022c0:	e9 e4 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022c5 <vector182>:
.globl vector182
vector182:
  pushl $0
c01022c5:	6a 00                	push   $0x0
  pushl $182
c01022c7:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01022cc:	e9 d8 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022d1 <vector183>:
.globl vector183
vector183:
  pushl $0
c01022d1:	6a 00                	push   $0x0
  pushl $183
c01022d3:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01022d8:	e9 cc f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022dd <vector184>:
.globl vector184
vector184:
  pushl $0
c01022dd:	6a 00                	push   $0x0
  pushl $184
c01022df:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01022e4:	e9 c0 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022e9 <vector185>:
.globl vector185
vector185:
  pushl $0
c01022e9:	6a 00                	push   $0x0
  pushl $185
c01022eb:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01022f0:	e9 b4 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022f5 <vector186>:
.globl vector186
vector186:
  pushl $0
c01022f5:	6a 00                	push   $0x0
  pushl $186
c01022f7:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01022fc:	e9 a8 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102301 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102301:	6a 00                	push   $0x0
  pushl $187
c0102303:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102308:	e9 9c f8 ff ff       	jmp    c0101ba9 <__alltraps>

c010230d <vector188>:
.globl vector188
vector188:
  pushl $0
c010230d:	6a 00                	push   $0x0
  pushl $188
c010230f:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102314:	e9 90 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102319 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102319:	6a 00                	push   $0x0
  pushl $189
c010231b:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102320:	e9 84 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102325 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102325:	6a 00                	push   $0x0
  pushl $190
c0102327:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010232c:	e9 78 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102331 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102331:	6a 00                	push   $0x0
  pushl $191
c0102333:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102338:	e9 6c f8 ff ff       	jmp    c0101ba9 <__alltraps>

c010233d <vector192>:
.globl vector192
vector192:
  pushl $0
c010233d:	6a 00                	push   $0x0
  pushl $192
c010233f:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102344:	e9 60 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102349 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102349:	6a 00                	push   $0x0
  pushl $193
c010234b:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102350:	e9 54 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102355 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102355:	6a 00                	push   $0x0
  pushl $194
c0102357:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010235c:	e9 48 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102361 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102361:	6a 00                	push   $0x0
  pushl $195
c0102363:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102368:	e9 3c f8 ff ff       	jmp    c0101ba9 <__alltraps>

c010236d <vector196>:
.globl vector196
vector196:
  pushl $0
c010236d:	6a 00                	push   $0x0
  pushl $196
c010236f:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102374:	e9 30 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102379 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102379:	6a 00                	push   $0x0
  pushl $197
c010237b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102380:	e9 24 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102385 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102385:	6a 00                	push   $0x0
  pushl $198
c0102387:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010238c:	e9 18 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102391 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102391:	6a 00                	push   $0x0
  pushl $199
c0102393:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102398:	e9 0c f8 ff ff       	jmp    c0101ba9 <__alltraps>

c010239d <vector200>:
.globl vector200
vector200:
  pushl $0
c010239d:	6a 00                	push   $0x0
  pushl $200
c010239f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01023a4:	e9 00 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01023a9 <vector201>:
.globl vector201
vector201:
  pushl $0
c01023a9:	6a 00                	push   $0x0
  pushl $201
c01023ab:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01023b0:	e9 f4 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023b5 <vector202>:
.globl vector202
vector202:
  pushl $0
c01023b5:	6a 00                	push   $0x0
  pushl $202
c01023b7:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01023bc:	e9 e8 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023c1 <vector203>:
.globl vector203
vector203:
  pushl $0
c01023c1:	6a 00                	push   $0x0
  pushl $203
c01023c3:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01023c8:	e9 dc f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023cd <vector204>:
.globl vector204
vector204:
  pushl $0
c01023cd:	6a 00                	push   $0x0
  pushl $204
c01023cf:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01023d4:	e9 d0 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023d9 <vector205>:
.globl vector205
vector205:
  pushl $0
c01023d9:	6a 00                	push   $0x0
  pushl $205
c01023db:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01023e0:	e9 c4 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023e5 <vector206>:
.globl vector206
vector206:
  pushl $0
c01023e5:	6a 00                	push   $0x0
  pushl $206
c01023e7:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01023ec:	e9 b8 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023f1 <vector207>:
.globl vector207
vector207:
  pushl $0
c01023f1:	6a 00                	push   $0x0
  pushl $207
c01023f3:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01023f8:	e9 ac f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023fd <vector208>:
.globl vector208
vector208:
  pushl $0
c01023fd:	6a 00                	push   $0x0
  pushl $208
c01023ff:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102404:	e9 a0 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102409 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102409:	6a 00                	push   $0x0
  pushl $209
c010240b:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102410:	e9 94 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102415 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102415:	6a 00                	push   $0x0
  pushl $210
c0102417:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010241c:	e9 88 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102421 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102421:	6a 00                	push   $0x0
  pushl $211
c0102423:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102428:	e9 7c f7 ff ff       	jmp    c0101ba9 <__alltraps>

c010242d <vector212>:
.globl vector212
vector212:
  pushl $0
c010242d:	6a 00                	push   $0x0
  pushl $212
c010242f:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102434:	e9 70 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102439 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102439:	6a 00                	push   $0x0
  pushl $213
c010243b:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102440:	e9 64 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102445 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102445:	6a 00                	push   $0x0
  pushl $214
c0102447:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010244c:	e9 58 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102451 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102451:	6a 00                	push   $0x0
  pushl $215
c0102453:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102458:	e9 4c f7 ff ff       	jmp    c0101ba9 <__alltraps>

c010245d <vector216>:
.globl vector216
vector216:
  pushl $0
c010245d:	6a 00                	push   $0x0
  pushl $216
c010245f:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102464:	e9 40 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102469 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102469:	6a 00                	push   $0x0
  pushl $217
c010246b:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102470:	e9 34 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102475 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102475:	6a 00                	push   $0x0
  pushl $218
c0102477:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010247c:	e9 28 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102481 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102481:	6a 00                	push   $0x0
  pushl $219
c0102483:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102488:	e9 1c f7 ff ff       	jmp    c0101ba9 <__alltraps>

c010248d <vector220>:
.globl vector220
vector220:
  pushl $0
c010248d:	6a 00                	push   $0x0
  pushl $220
c010248f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102494:	e9 10 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102499 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102499:	6a 00                	push   $0x0
  pushl $221
c010249b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01024a0:	e9 04 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01024a5 <vector222>:
.globl vector222
vector222:
  pushl $0
c01024a5:	6a 00                	push   $0x0
  pushl $222
c01024a7:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01024ac:	e9 f8 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024b1 <vector223>:
.globl vector223
vector223:
  pushl $0
c01024b1:	6a 00                	push   $0x0
  pushl $223
c01024b3:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01024b8:	e9 ec f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024bd <vector224>:
.globl vector224
vector224:
  pushl $0
c01024bd:	6a 00                	push   $0x0
  pushl $224
c01024bf:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01024c4:	e9 e0 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024c9 <vector225>:
.globl vector225
vector225:
  pushl $0
c01024c9:	6a 00                	push   $0x0
  pushl $225
c01024cb:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01024d0:	e9 d4 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024d5 <vector226>:
.globl vector226
vector226:
  pushl $0
c01024d5:	6a 00                	push   $0x0
  pushl $226
c01024d7:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01024dc:	e9 c8 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024e1 <vector227>:
.globl vector227
vector227:
  pushl $0
c01024e1:	6a 00                	push   $0x0
  pushl $227
c01024e3:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01024e8:	e9 bc f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024ed <vector228>:
.globl vector228
vector228:
  pushl $0
c01024ed:	6a 00                	push   $0x0
  pushl $228
c01024ef:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01024f4:	e9 b0 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024f9 <vector229>:
.globl vector229
vector229:
  pushl $0
c01024f9:	6a 00                	push   $0x0
  pushl $229
c01024fb:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102500:	e9 a4 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102505 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102505:	6a 00                	push   $0x0
  pushl $230
c0102507:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010250c:	e9 98 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102511 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102511:	6a 00                	push   $0x0
  pushl $231
c0102513:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102518:	e9 8c f6 ff ff       	jmp    c0101ba9 <__alltraps>

c010251d <vector232>:
.globl vector232
vector232:
  pushl $0
c010251d:	6a 00                	push   $0x0
  pushl $232
c010251f:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102524:	e9 80 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102529 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102529:	6a 00                	push   $0x0
  pushl $233
c010252b:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102530:	e9 74 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102535 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102535:	6a 00                	push   $0x0
  pushl $234
c0102537:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010253c:	e9 68 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102541 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102541:	6a 00                	push   $0x0
  pushl $235
c0102543:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102548:	e9 5c f6 ff ff       	jmp    c0101ba9 <__alltraps>

c010254d <vector236>:
.globl vector236
vector236:
  pushl $0
c010254d:	6a 00                	push   $0x0
  pushl $236
c010254f:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102554:	e9 50 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102559 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102559:	6a 00                	push   $0x0
  pushl $237
c010255b:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102560:	e9 44 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102565 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102565:	6a 00                	push   $0x0
  pushl $238
c0102567:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010256c:	e9 38 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102571 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102571:	6a 00                	push   $0x0
  pushl $239
c0102573:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102578:	e9 2c f6 ff ff       	jmp    c0101ba9 <__alltraps>

c010257d <vector240>:
.globl vector240
vector240:
  pushl $0
c010257d:	6a 00                	push   $0x0
  pushl $240
c010257f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102584:	e9 20 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102589 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102589:	6a 00                	push   $0x0
  pushl $241
c010258b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102590:	e9 14 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102595 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102595:	6a 00                	push   $0x0
  pushl $242
c0102597:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010259c:	e9 08 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01025a1 <vector243>:
.globl vector243
vector243:
  pushl $0
c01025a1:	6a 00                	push   $0x0
  pushl $243
c01025a3:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01025a8:	e9 fc f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025ad <vector244>:
.globl vector244
vector244:
  pushl $0
c01025ad:	6a 00                	push   $0x0
  pushl $244
c01025af:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01025b4:	e9 f0 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025b9 <vector245>:
.globl vector245
vector245:
  pushl $0
c01025b9:	6a 00                	push   $0x0
  pushl $245
c01025bb:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01025c0:	e9 e4 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025c5 <vector246>:
.globl vector246
vector246:
  pushl $0
c01025c5:	6a 00                	push   $0x0
  pushl $246
c01025c7:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01025cc:	e9 d8 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025d1 <vector247>:
.globl vector247
vector247:
  pushl $0
c01025d1:	6a 00                	push   $0x0
  pushl $247
c01025d3:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01025d8:	e9 cc f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025dd <vector248>:
.globl vector248
vector248:
  pushl $0
c01025dd:	6a 00                	push   $0x0
  pushl $248
c01025df:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01025e4:	e9 c0 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025e9 <vector249>:
.globl vector249
vector249:
  pushl $0
c01025e9:	6a 00                	push   $0x0
  pushl $249
c01025eb:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01025f0:	e9 b4 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025f5 <vector250>:
.globl vector250
vector250:
  pushl $0
c01025f5:	6a 00                	push   $0x0
  pushl $250
c01025f7:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01025fc:	e9 a8 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c0102601 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102601:	6a 00                	push   $0x0
  pushl $251
c0102603:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102608:	e9 9c f5 ff ff       	jmp    c0101ba9 <__alltraps>

c010260d <vector252>:
.globl vector252
vector252:
  pushl $0
c010260d:	6a 00                	push   $0x0
  pushl $252
c010260f:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102614:	e9 90 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c0102619 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102619:	6a 00                	push   $0x0
  pushl $253
c010261b:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102620:	e9 84 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c0102625 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102625:	6a 00                	push   $0x0
  pushl $254
c0102627:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010262c:	e9 78 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c0102631 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102631:	6a 00                	push   $0x0
  pushl $255
c0102633:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102638:	e9 6c f5 ff ff       	jmp    c0101ba9 <__alltraps>

c010263d <set_page_ref>:
page_ref(struct Page *page) {
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
c010263d:	55                   	push   %ebp
c010263e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102640:	8b 45 08             	mov    0x8(%ebp),%eax
c0102643:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102646:	89 10                	mov    %edx,(%eax)
}
c0102648:	5d                   	pop    %ebp
c0102649:	c3                   	ret    

c010264a <buddy_init>:
static unsigned long long buddy_type[buddy_type_size];
#define free_list(n) (free_area_list[n].free_list)
#define nr_free(n) (free_area_list[n].nr_free)

static void
buddy_init(void) {
c010264a:	55                   	push   %ebp
c010264b:	89 e5                	mov    %esp,%ebp
c010264d:	83 ec 28             	sub    $0x28,%esp
    cprintf("buddy_init\n");
c0102650:	c7 04 24 70 73 10 c0 	movl   $0xc0107370,(%esp)
c0102657:	e8 ec dc ff ff       	call   c0100348 <cprintf>
    unsigned i=0;
c010265c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    buddy_type[0]=1;
c0102663:	c7 05 80 ce 11 c0 01 	movl   $0x1,0xc011ce80
c010266a:	00 00 00 
c010266d:	c7 05 84 ce 11 c0 00 	movl   $0x0,0xc011ce84
c0102674:	00 00 00 
    for(;i<buddy_type_size;i++){
c0102677:	eb 75                	jmp    c01026ee <buddy_init+0xa4>
        list_init(&(free_list(i)));  
c0102679:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010267c:	89 d0                	mov    %edx,%eax
c010267e:	01 c0                	add    %eax,%eax
c0102680:	01 d0                	add    %edx,%eax
c0102682:	c1 e0 02             	shl    $0x2,%eax
c0102685:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c010268a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010268d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102690:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102693:	89 50 04             	mov    %edx,0x4(%eax)
c0102696:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102699:	8b 50 04             	mov    0x4(%eax),%edx
c010269c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010269f:	89 10                	mov    %edx,(%eax)
        nr_free(i) = 0;
c01026a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01026a4:	89 d0                	mov    %edx,%eax
c01026a6:	01 c0                	add    %eax,%eax
c01026a8:	01 d0                	add    %edx,%eax
c01026aa:	c1 e0 02             	shl    $0x2,%eax
c01026ad:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c01026b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        if(i!=0){
c01026b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01026bd:	74 2b                	je     c01026ea <buddy_init+0xa0>
            buddy_type[i]=buddy_type[i-1]<<1; 
c01026bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01026c2:	83 e8 01             	sub    $0x1,%eax
c01026c5:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c01026cc:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c01026d3:	0f a4 c2 01          	shld   $0x1,%eax,%edx
c01026d7:	01 c0                	add    %eax,%eax
c01026d9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c01026dc:	89 04 cd 80 ce 11 c0 	mov    %eax,-0x3fee3180(,%ecx,8)
c01026e3:	89 14 cd 84 ce 11 c0 	mov    %edx,-0x3fee317c(,%ecx,8)
static void
buddy_init(void) {
    cprintf("buddy_init\n");
    unsigned i=0;
    buddy_type[0]=1;
    for(;i<buddy_type_size;i++){
c01026ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01026ee:	83 7d f4 12          	cmpl   $0x12,-0xc(%ebp)
c01026f2:	76 85                	jbe    c0102679 <buddy_init+0x2f>
        nr_free(i) = 0;
        if(i!=0){
            buddy_type[i]=buddy_type[i-1]<<1; 
        }
    }
}
c01026f4:	c9                   	leave  
c01026f5:	c3                   	ret    

c01026f6 <find_list>:
static size_t find_list(size_t n){
c01026f6:	55                   	push   %ebp
c01026f7:	89 e5                	mov    %esp,%ebp
c01026f9:	53                   	push   %ebx
c01026fa:	83 ec 14             	sub    $0x14,%esp
    size_t i=0;
c01026fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for(;i<buddy_type_size;i++){
c0102704:	eb 2e                	jmp    c0102734 <find_list+0x3e>
        if(buddy_type[i]>=n)
c0102706:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102709:	8b 0c c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%ecx
c0102710:	8b 1c c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%ebx
c0102717:	8b 45 08             	mov    0x8(%ebp),%eax
c010271a:	ba 00 00 00 00       	mov    $0x0,%edx
c010271f:	39 d3                	cmp    %edx,%ebx
c0102721:	72 0d                	jb     c0102730 <find_list+0x3a>
c0102723:	39 d3                	cmp    %edx,%ebx
c0102725:	77 04                	ja     c010272b <find_list+0x35>
c0102727:	39 c1                	cmp    %eax,%ecx
c0102729:	72 05                	jb     c0102730 <find_list+0x3a>
        return i;
c010272b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010272e:	eb 0f                	jmp    c010273f <find_list+0x49>
        }
    }
}
static size_t find_list(size_t n){
    size_t i=0;
    for(;i<buddy_type_size;i++){
c0102730:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102734:	83 7d f4 12          	cmpl   $0x12,-0xc(%ebp)
c0102738:	76 cc                	jbe    c0102706 <find_list+0x10>
        if(buddy_type[i]>=n)
        return i;
    }
    return -1;
c010273a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
c010273f:	83 c4 14             	add    $0x14,%esp
c0102742:	5b                   	pop    %ebx
c0102743:	5d                   	pop    %ebp
c0102744:	c3                   	ret    

c0102745 <buddy_get_page_init>:
static int buddy_get_page_init(size_t n){ 
c0102745:	55                   	push   %ebp
c0102746:	89 e5                	mov    %esp,%ebp
c0102748:	56                   	push   %esi
c0102749:	53                   	push   %ebx
c010274a:	83 ec 10             	sub    $0x10,%esp
    if(n==0)
c010274d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102751:	75 07                	jne    c010275a <buddy_get_page_init+0x15>
        return -2;
c0102753:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c0102758:	eb 6f                	jmp    c01027c9 <buddy_get_page_init+0x84>
    int i;
    for(i=0;i<buddy_type_size;i++){
c010275a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102761:	eb 5b                	jmp    c01027be <buddy_get_page_init+0x79>
        if(buddy_type[i]==n){
c0102763:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102766:	8b 0c c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%ecx
c010276d:	8b 1c c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%ebx
c0102774:	8b 45 08             	mov    0x8(%ebp),%eax
c0102777:	ba 00 00 00 00       	mov    $0x0,%edx
c010277c:	89 de                	mov    %ebx,%esi
c010277e:	31 d6                	xor    %edx,%esi
c0102780:	31 c8                	xor    %ecx,%eax
c0102782:	09 f0                	or     %esi,%eax
c0102784:	85 c0                	test   %eax,%eax
c0102786:	75 05                	jne    c010278d <buddy_get_page_init+0x48>
            return i;
c0102788:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010278b:	eb 3c                	jmp    c01027c9 <buddy_get_page_init+0x84>
        }else if(buddy_type[i]>n){
c010278d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102790:	8b 0c c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%ecx
c0102797:	8b 1c c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%ebx
c010279e:	8b 45 08             	mov    0x8(%ebp),%eax
c01027a1:	ba 00 00 00 00       	mov    $0x0,%edx
c01027a6:	39 d3                	cmp    %edx,%ebx
c01027a8:	72 10                	jb     c01027ba <buddy_get_page_init+0x75>
c01027aa:	39 d3                	cmp    %edx,%ebx
c01027ac:	77 04                	ja     c01027b2 <buddy_get_page_init+0x6d>
c01027ae:	39 c1                	cmp    %eax,%ecx
c01027b0:	76 08                	jbe    c01027ba <buddy_get_page_init+0x75>
            return i-1;
c01027b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027b5:	83 e8 01             	sub    $0x1,%eax
c01027b8:	eb 0f                	jmp    c01027c9 <buddy_get_page_init+0x84>
}
static int buddy_get_page_init(size_t n){ 
    if(n==0)
        return -2;
    int i;
    for(i=0;i<buddy_type_size;i++){
c01027ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01027be:	83 7d f4 12          	cmpl   $0x12,-0xc(%ebp)
c01027c2:	7e 9f                	jle    c0102763 <buddy_get_page_init+0x1e>
            return i;
        }else if(buddy_type[i]>n){
            return i-1;
        }
    }
    return -1;
c01027c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
c01027c9:	83 c4 10             	add    $0x10,%esp
c01027cc:	5b                   	pop    %ebx
c01027cd:	5e                   	pop    %esi
c01027ce:	5d                   	pop    %ebp
c01027cf:	c3                   	ret    

c01027d0 <buddy_init_memmap>:
static void
buddy_init_memmap(struct Page *base,size_t n) {
c01027d0:	55                   	push   %ebp
c01027d1:	89 e5                	mov    %esp,%ebp
c01027d3:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01027d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01027da:	75 24                	jne    c0102800 <buddy_init_memmap+0x30>
c01027dc:	c7 44 24 0c 7c 73 10 	movl   $0xc010737c,0xc(%esp)
c01027e3:	c0 
c01027e4:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c01027eb:	c0 
c01027ec:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
c01027f3:	00 
c01027f4:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c01027fb:	e8 18 e4 ff ff       	call   c0100c18 <__panic>
    struct Page *p = base;
c0102800:	8b 45 08             	mov    0x8(%ebp),%eax
c0102803:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++){
c0102806:	eb 7d                	jmp    c0102885 <buddy_init_memmap+0xb5>
        assert(PageReserved(p));
c0102808:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010280b:	83 c0 04             	add    $0x4,%eax
c010280e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102815:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102818:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010281b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010281e:	0f a3 10             	bt     %edx,(%eax)
c0102821:	19 c0                	sbb    %eax,%eax
c0102823:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102826:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010282a:	0f 95 c0             	setne  %al
c010282d:	0f b6 c0             	movzbl %al,%eax
c0102830:	85 c0                	test   %eax,%eax
c0102832:	75 24                	jne    c0102858 <buddy_init_memmap+0x88>
c0102834:	c7 44 24 0c ab 73 10 	movl   $0xc01073ab,0xc(%esp)
c010283b:	c0 
c010283c:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c0102843:	c0 
c0102844:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
c010284b:	00 
c010284c:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c0102853:	e8 c0 e3 ff ff       	call   c0100c18 <__panic>
        p->flags = p->property = 0;
c0102858:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010285b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0102862:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102865:	8b 50 08             	mov    0x8(%eax),%edx
c0102868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010286b:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0); 
c010286e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102875:	00 
c0102876:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102879:	89 04 24             	mov    %eax,(%esp)
c010287c:	e8 bc fd ff ff       	call   c010263d <set_page_ref>
}
static void
buddy_init_memmap(struct Page *base,size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++){
c0102881:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102885:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102888:	89 d0                	mov    %edx,%eax
c010288a:	c1 e0 02             	shl    $0x2,%eax
c010288d:	01 d0                	add    %edx,%eax
c010288f:	c1 e0 02             	shl    $0x2,%eax
c0102892:	89 c2                	mov    %eax,%edx
c0102894:	8b 45 08             	mov    0x8(%ebp),%eax
c0102897:	01 d0                	add    %edx,%eax
c0102899:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010289c:	0f 85 66 ff ff ff    	jne    c0102808 <buddy_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0); 
    }
    int index_type;
    SetPageProperty(base);
c01028a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01028a5:	83 c0 04             	add    $0x4,%eax
c01028a8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01028af:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01028b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01028b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01028b8:	0f ab 10             	bts    %edx,(%eax)
    while( (index_type=buddy_get_page_init(n)) >= 0 ){
c01028bb:	e9 e6 00 00 00       	jmp    c01029a6 <buddy_init_memmap+0x1d6>
        nr_free(index_type)= 1; 
c01028c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01028c3:	89 d0                	mov    %edx,%eax
c01028c5:	01 c0                	add    %eax,%eax
c01028c7:	01 d0                	add    %edx,%eax
c01028c9:	c1 e0 02             	shl    $0x2,%eax
c01028cc:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c01028d1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	//cprintf("%d\n",index_type);
        list_add_before(&(free_list(index_type)),&(base->page_link));
c01028d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01028db:	8d 48 0c             	lea    0xc(%eax),%ecx
c01028de:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01028e1:	89 d0                	mov    %edx,%eax
c01028e3:	01 c0                	add    %eax,%eax
c01028e5:	01 d0                	add    %edx,%eax
c01028e7:	c1 e0 02             	shl    $0x2,%eax
c01028ea:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c01028ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01028f2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01028f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01028f8:	8b 00                	mov    (%eax),%eax
c01028fa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01028fd:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0102900:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102903:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102906:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102909:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010290c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010290f:	89 10                	mov    %edx,(%eax)
c0102911:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102914:	8b 10                	mov    (%eax),%edx
c0102916:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102919:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010291c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010291f:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102922:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102925:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102928:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010292b:	89 10                	mov    %edx,(%eax)
        base->property = buddy_type[index_type];
c010292d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102930:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c0102937:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c010293e:	89 c2                	mov    %eax,%edx
c0102940:	8b 45 08             	mov    0x8(%ebp),%eax
c0102943:	89 50 08             	mov    %edx,0x8(%eax)
        base=base+buddy_type[index_type];
c0102946:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102949:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c0102950:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c0102957:	89 c2                	mov    %eax,%edx
c0102959:	89 d0                	mov    %edx,%eax
c010295b:	c1 e0 02             	shl    $0x2,%eax
c010295e:	01 d0                	add    %edx,%eax
c0102960:	c1 e0 02             	shl    $0x2,%eax
c0102963:	01 45 08             	add    %eax,0x8(%ebp)
	cprintf("%d %d\n",n,buddy_type[index_type]);
c0102966:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102969:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c0102970:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c0102977:	89 44 24 08          	mov    %eax,0x8(%esp)
c010297b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010297f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102982:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102986:	c7 04 24 bb 73 10 c0 	movl   $0xc01073bb,(%esp)
c010298d:	e8 b6 d9 ff ff       	call   c0100348 <cprintf>
        n -= buddy_type[index_type]; 
c0102992:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102995:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c010299c:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c01029a3:	29 45 0c             	sub    %eax,0xc(%ebp)
        p->flags = p->property = 0;
        set_page_ref(p, 0); 
    }
    int index_type;
    SetPageProperty(base);
    while( (index_type=buddy_get_page_init(n)) >= 0 ){
c01029a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01029a9:	89 04 24             	mov    %eax,(%esp)
c01029ac:	e8 94 fd ff ff       	call   c0102745 <buddy_get_page_init>
c01029b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01029b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01029b8:	0f 89 02 ff ff ff    	jns    c01028c0 <buddy_init_memmap+0xf0>
        base->property = buddy_type[index_type];
        base=base+buddy_type[index_type];
	cprintf("%d %d\n",n,buddy_type[index_type]);
        n -= buddy_type[index_type]; 
    }
}
c01029be:	c9                   	leave  
c01029bf:	c3                   	ret    

c01029c0 <buddy_alloc_pages>:
static struct Page *
buddy_alloc_pages(size_t n) {
c01029c0:	55                   	push   %ebp
c01029c1:	89 e5                	mov    %esp,%ebp
c01029c3:	53                   	push   %ebx
c01029c4:	83 ec 74             	sub    $0x74,%esp
    assert(n > 0);
c01029c7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01029cb:	75 24                	jne    c01029f1 <buddy_alloc_pages+0x31>
c01029cd:	c7 44 24 0c 7c 73 10 	movl   $0xc010737c,0xc(%esp)
c01029d4:	c0 
c01029d5:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c01029dc:	c0 
c01029dd:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
c01029e4:	00 
c01029e5:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c01029ec:	e8 27 e2 ff ff       	call   c0100c18 <__panic>
    if(n>buddy_type[buddy_type_size-1]){
c01029f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
c01029f4:	bb 00 00 00 00       	mov    $0x0,%ebx
c01029f9:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c01029fe:	8b 15 14 cf 11 c0    	mov    0xc011cf14,%edx
c0102a04:	39 d3                	cmp    %edx,%ebx
c0102a06:	72 12                	jb     c0102a1a <buddy_alloc_pages+0x5a>
c0102a08:	39 d3                	cmp    %edx,%ebx
c0102a0a:	77 04                	ja     c0102a10 <buddy_alloc_pages+0x50>
c0102a0c:	39 c1                	cmp    %eax,%ecx
c0102a0e:	76 0a                	jbe    c0102a1a <buddy_alloc_pages+0x5a>
        return NULL;
c0102a10:	b8 00 00 00 00       	mov    $0x0,%eax
c0102a15:	e9 22 03 00 00       	jmp    c0102d3c <buddy_alloc_pages+0x37c>
    }
    struct Page *page = NULL;
c0102a1a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    size_t index=find_list(n);
c0102a21:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a24:	89 04 24             	mov    %eax,(%esp)
c0102a27:	e8 ca fc ff ff       	call   c01026f6 <find_list>
c0102a2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    list_entry_t *le = &free_list(index);
c0102a2f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102a32:	89 d0                	mov    %edx,%eax
c0102a34:	01 c0                	add    %eax,%eax
c0102a36:	01 d0                	add    %edx,%eax
c0102a38:	c1 e0 02             	shl    $0x2,%eax
c0102a3b:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t i=index;
c0102a43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102a46:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(le==NULL){
c0102a49:	eb 18                	jmp    c0102a63 <buddy_alloc_pages+0xa3>
        le=&free_list(++i);
c0102a4b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0102a4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102a52:	89 d0                	mov    %edx,%eax
c0102a54:	01 c0                	add    %eax,%eax
c0102a56:	01 d0                	add    %edx,%eax
c0102a58:	c1 e0 02             	shl    $0x2,%eax
c0102a5b:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    struct Page *page = NULL;
    size_t index=find_list(n);
    list_entry_t *le = &free_list(index);
    size_t i=index;
    while(le==NULL){
c0102a63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102a67:	74 e2                	je     c0102a4b <buddy_alloc_pages+0x8b>
        le=&free_list(++i);
    } 
    page = le2page(le, page_link);
c0102a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a6c:	83 e8 0c             	sub    $0xc,%eax
c0102a6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(page!=NULL){
c0102a72:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102a76:	0f 84 bd 02 00 00    	je     c0102d39 <buddy_alloc_pages+0x379>
        if (n<buddy_type[index]&&n>buddy_type[index]/2) { 
c0102a7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102a7f:	bb 00 00 00 00       	mov    $0x0,%ebx
c0102a84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102a87:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c0102a8e:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c0102a95:	39 d3                	cmp    %edx,%ebx
c0102a97:	0f 87 92 00 00 00    	ja     c0102b2f <buddy_alloc_pages+0x16f>
c0102a9d:	39 d3                	cmp    %edx,%ebx
c0102a9f:	72 08                	jb     c0102aa9 <buddy_alloc_pages+0xe9>
c0102aa1:	39 c1                	cmp    %eax,%ecx
c0102aa3:	0f 83 86 00 00 00    	jae    c0102b2f <buddy_alloc_pages+0x16f>
c0102aa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102aac:	bb 00 00 00 00       	mov    $0x0,%ebx
c0102ab1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102ab4:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c0102abb:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c0102ac2:	0f ac d0 01          	shrd   $0x1,%edx,%eax
c0102ac6:	d1 ea                	shr    %edx
c0102ac8:	39 d3                	cmp    %edx,%ebx
c0102aca:	72 63                	jb     c0102b2f <buddy_alloc_pages+0x16f>
c0102acc:	39 d3                	cmp    %edx,%ebx
c0102ace:	77 04                	ja     c0102ad4 <buddy_alloc_pages+0x114>
c0102ad0:	39 c1                	cmp    %eax,%ecx
c0102ad2:	76 5b                	jbe    c0102b2f <buddy_alloc_pages+0x16f>
            list_del(&(page->page_link));
c0102ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102ad7:	83 c0 0c             	add    $0xc,%eax
c0102ada:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102add:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102ae0:	8b 40 04             	mov    0x4(%eax),%eax
c0102ae3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ae6:	8b 12                	mov    (%edx),%edx
c0102ae8:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0102aeb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102aee:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102af1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102af4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102af7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102afa:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102afd:	89 10                	mov    %edx,(%eax)
            nr_free(index) -=1;
c0102aff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102b02:	89 d0                	mov    %edx,%eax
c0102b04:	01 c0                	add    %eax,%eax
c0102b06:	01 d0                	add    %edx,%eax
c0102b08:	c1 e0 02             	shl    $0x2,%eax
c0102b0b:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102b10:	8b 40 08             	mov    0x8(%eax),%eax
c0102b13:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0102b16:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102b19:	89 d0                	mov    %edx,%eax
c0102b1b:	01 c0                	add    %eax,%eax
c0102b1d:	01 d0                	add    %edx,%eax
c0102b1f:	c1 e0 02             	shl    $0x2,%eax
c0102b22:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102b27:	89 48 08             	mov    %ecx,0x8(%eax)
c0102b2a:	e9 f1 01 00 00       	jmp    c0102d20 <buddy_alloc_pages+0x360>
        }
        else {
            size_t i=index;
c0102b2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102b32:	89 45 ec             	mov    %eax,-0x14(%ebp)
            while(n<buddy_type[i]/2){
c0102b35:	e9 5d 01 00 00       	jmp    c0102c97 <buddy_alloc_pages+0x2d7>
                struct  Page *p=page+buddy_type[i]/2;
c0102b3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102b3d:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c0102b44:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c0102b4b:	0f ac d0 01          	shrd   $0x1,%edx,%eax
c0102b4f:	d1 ea                	shr    %edx
c0102b51:	89 c2                	mov    %eax,%edx
c0102b53:	89 d0                	mov    %edx,%eax
c0102b55:	c1 e0 02             	shl    $0x2,%eax
c0102b58:	01 d0                	add    %edx,%eax
c0102b5a:	c1 e0 02             	shl    $0x2,%eax
c0102b5d:	89 c2                	mov    %eax,%edx
c0102b5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b62:	01 d0                	add    %edx,%eax
c0102b64:	89 45 e0             	mov    %eax,-0x20(%ebp)
                p->property = page->property/2;
c0102b67:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b6a:	8b 40 08             	mov    0x8(%eax),%eax
c0102b6d:	d1 e8                	shr    %eax
c0102b6f:	89 c2                	mov    %eax,%edx
c0102b71:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102b74:	89 50 08             	mov    %edx,0x8(%eax)
                page->property=page->property/2;
c0102b77:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b7a:	8b 40 08             	mov    0x8(%eax),%eax
c0102b7d:	d1 e8                	shr    %eax
c0102b7f:	89 c2                	mov    %eax,%edx
c0102b81:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b84:	89 50 08             	mov    %edx,0x8(%eax)
                nr_free(i)-=1;
c0102b87:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102b8a:	89 d0                	mov    %edx,%eax
c0102b8c:	01 c0                	add    %eax,%eax
c0102b8e:	01 d0                	add    %edx,%eax
c0102b90:	c1 e0 02             	shl    $0x2,%eax
c0102b93:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102b98:	8b 40 08             	mov    0x8(%eax),%eax
c0102b9b:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0102b9e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102ba1:	89 d0                	mov    %edx,%eax
c0102ba3:	01 c0                	add    %eax,%eax
c0102ba5:	01 d0                	add    %edx,%eax
c0102ba7:	c1 e0 02             	shl    $0x2,%eax
c0102baa:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102baf:	89 48 08             	mov    %ecx,0x8(%eax)
                list_add_before(&free_list(i-1),&(p->page_link));
c0102bb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102bb5:	8d 48 0c             	lea    0xc(%eax),%ecx
c0102bb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102bbb:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102bbe:	89 d0                	mov    %edx,%eax
c0102bc0:	01 c0                	add    %eax,%eax
c0102bc2:	01 d0                	add    %edx,%eax
c0102bc4:	c1 e0 02             	shl    $0x2,%eax
c0102bc7:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102bcc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102bcf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102bd2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102bd5:	8b 00                	mov    (%eax),%eax
c0102bd7:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102bda:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0102bdd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0102be0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102be3:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102be6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102be9:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102bec:	89 10                	mov    %edx,(%eax)
c0102bee:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102bf1:	8b 10                	mov    (%eax),%edx
c0102bf3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102bf6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102bf9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102bfc:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102bff:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102c02:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102c05:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102c08:	89 10                	mov    %edx,(%eax)
                list_add_before(&free_list(i-1),&(page->page_link));
c0102c0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102c0d:	8d 48 0c             	lea    0xc(%eax),%ecx
c0102c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102c13:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102c16:	89 d0                	mov    %edx,%eax
c0102c18:	01 c0                	add    %eax,%eax
c0102c1a:	01 d0                	add    %edx,%eax
c0102c1c:	c1 e0 02             	shl    $0x2,%eax
c0102c1f:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102c24:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102c27:	89 4d b8             	mov    %ecx,-0x48(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102c2a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102c2d:	8b 00                	mov    (%eax),%eax
c0102c2f:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102c32:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c0102c35:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0102c38:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102c3b:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102c3e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102c41:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102c44:	89 10                	mov    %edx,(%eax)
c0102c46:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102c49:	8b 10                	mov    (%eax),%edx
c0102c4b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102c4e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102c51:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102c54:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0102c57:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102c5a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102c5d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102c60:	89 10                	mov    %edx,(%eax)
                nr_free(i-1)+=2;
c0102c62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102c65:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102c68:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102c6b:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0102c6e:	89 c8                	mov    %ecx,%eax
c0102c70:	01 c0                	add    %eax,%eax
c0102c72:	01 c8                	add    %ecx,%eax
c0102c74:	c1 e0 02             	shl    $0x2,%eax
c0102c77:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102c7c:	8b 40 08             	mov    0x8(%eax),%eax
c0102c7f:	8d 48 02             	lea    0x2(%eax),%ecx
c0102c82:	89 d0                	mov    %edx,%eax
c0102c84:	01 c0                	add    %eax,%eax
c0102c86:	01 d0                	add    %edx,%eax
c0102c88:	c1 e0 02             	shl    $0x2,%eax
c0102c8b:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102c90:	89 48 08             	mov    %ecx,0x8(%eax)
                i--;   
c0102c93:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
            list_del(&(page->page_link));
            nr_free(index) -=1;
        }
        else {
            size_t i=index;
            while(n<buddy_type[i]/2){
c0102c97:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
c0102c9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ca2:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c0102ca9:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c0102cb0:	0f ac d0 01          	shrd   $0x1,%edx,%eax
c0102cb4:	d1 ea                	shr    %edx
c0102cb6:	39 d3                	cmp    %edx,%ebx
c0102cb8:	0f 82 7c fe ff ff    	jb     c0102b3a <buddy_alloc_pages+0x17a>
c0102cbe:	39 d3                	cmp    %edx,%ebx
c0102cc0:	77 08                	ja     c0102cca <buddy_alloc_pages+0x30a>
c0102cc2:	39 c1                	cmp    %eax,%ecx
c0102cc4:	0f 82 70 fe ff ff    	jb     c0102b3a <buddy_alloc_pages+0x17a>
                list_add_before(&free_list(i-1),&(p->page_link));
                list_add_before(&free_list(i-1),&(page->page_link));
                nr_free(i-1)+=2;
                i--;   
            }
            list_del(&(page->page_link));
c0102cca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102ccd:	83 c0 0c             	add    $0xc,%eax
c0102cd0:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102cd3:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102cd6:	8b 40 04             	mov    0x4(%eax),%eax
c0102cd9:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102cdc:	8b 12                	mov    (%edx),%edx
c0102cde:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102ce1:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102ce4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102ce7:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0102cea:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102ced:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102cf0:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102cf3:	89 10                	mov    %edx,(%eax)
            nr_free(i) -=1;
c0102cf5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102cf8:	89 d0                	mov    %edx,%eax
c0102cfa:	01 c0                	add    %eax,%eax
c0102cfc:	01 d0                	add    %edx,%eax
c0102cfe:	c1 e0 02             	shl    $0x2,%eax
c0102d01:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102d06:	8b 40 08             	mov    0x8(%eax),%eax
c0102d09:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0102d0c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102d0f:	89 d0                	mov    %edx,%eax
c0102d11:	01 c0                	add    %eax,%eax
c0102d13:	01 d0                	add    %edx,%eax
c0102d15:	c1 e0 02             	shl    $0x2,%eax
c0102d18:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102d1d:	89 48 08             	mov    %ecx,0x8(%eax)
        } 
    ClearPageProperty(page);
c0102d20:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d23:	83 c0 04             	add    $0x4,%eax
c0102d26:	c7 45 9c 01 00 00 00 	movl   $0x1,-0x64(%ebp)
c0102d2d:	89 45 98             	mov    %eax,-0x68(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d30:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102d33:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102d36:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0102d39:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
c0102d3c:	83 c4 74             	add    $0x74,%esp
c0102d3f:	5b                   	pop    %ebx
c0102d40:	5d                   	pop    %ebp
c0102d41:	c3                   	ret    

c0102d42 <buddy_free_pages>:
static void
buddy_free_pages(struct Page *base, size_t n) {
c0102d42:	55                   	push   %ebp
c0102d43:	89 e5                	mov    %esp,%ebp
c0102d45:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0102d4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102d4f:	75 24                	jne    c0102d75 <buddy_free_pages+0x33>
c0102d51:	c7 44 24 0c 7c 73 10 	movl   $0xc010737c,0xc(%esp)
c0102d58:	c0 
c0102d59:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c0102d60:	c0 
c0102d61:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0102d68:	00 
c0102d69:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c0102d70:	e8 a3 de ff ff       	call   c0100c18 <__panic>
    struct Page *p = base;
c0102d75:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d78:	89 45 f4             	mov    %eax,-0xc(%ebp)
    unsigned index=find_list(n);
c0102d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d7e:	89 04 24             	mov    %eax,(%esp)
c0102d81:	e8 70 f9 ff ff       	call   c01026f6 <find_list>
c0102d86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    n=buddy_type[index];
c0102d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102d8c:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c0102d93:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c0102d9a:	89 45 0c             	mov    %eax,0xc(%ebp)
    base->property = n;
c0102d9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102da0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102da3:	89 50 08             	mov    %edx,0x8(%eax)
    for (; p != base + n; p ++){ 
c0102da6:	e9 9d 00 00 00       	jmp    c0102e48 <buddy_free_pages+0x106>
        assert(!PageReserved(p) && !PageProperty(p));
c0102dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dae:	83 c0 04             	add    $0x4,%eax
c0102db1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102db8:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102dbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102dbe:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102dc1:	0f a3 10             	bt     %edx,(%eax)
c0102dc4:	19 c0                	sbb    %eax,%eax
c0102dc6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102dc9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102dcd:	0f 95 c0             	setne  %al
c0102dd0:	0f b6 c0             	movzbl %al,%eax
c0102dd3:	85 c0                	test   %eax,%eax
c0102dd5:	75 2c                	jne    c0102e03 <buddy_free_pages+0xc1>
c0102dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dda:	83 c0 04             	add    $0x4,%eax
c0102ddd:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102de4:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102de7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102dea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102ded:	0f a3 10             	bt     %edx,(%eax)
c0102df0:	19 c0                	sbb    %eax,%eax
c0102df2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    return oldbit != 0;
c0102df5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102df9:	0f 95 c0             	setne  %al
c0102dfc:	0f b6 c0             	movzbl %al,%eax
c0102dff:	85 c0                	test   %eax,%eax
c0102e01:	74 24                	je     c0102e27 <buddy_free_pages+0xe5>
c0102e03:	c7 44 24 0c c4 73 10 	movl   $0xc01073c4,0xc(%esp)
c0102e0a:	c0 
c0102e0b:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c0102e12:	c0 
c0102e13:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0102e1a:	00 
c0102e1b:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c0102e22:	e8 f1 dd ff ff       	call   c0100c18 <__panic>
        p->flags = 0;
c0102e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e2a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102e31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102e38:	00 
c0102e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e3c:	89 04 24             	mov    %eax,(%esp)
c0102e3f:	e8 f9 f7 ff ff       	call   c010263d <set_page_ref>
    assert(n > 0);
    struct Page *p = base;
    unsigned index=find_list(n);
    n=buddy_type[index];
    base->property = n;
    for (; p != base + n; p ++){ 
c0102e44:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102e48:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102e4b:	89 d0                	mov    %edx,%eax
c0102e4d:	c1 e0 02             	shl    $0x2,%eax
c0102e50:	01 d0                	add    %edx,%eax
c0102e52:	c1 e0 02             	shl    $0x2,%eax
c0102e55:	89 c2                	mov    %eax,%edx
c0102e57:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e5a:	01 d0                	add    %edx,%eax
c0102e5c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e5f:	0f 85 46 ff ff ff    	jne    c0102dab <buddy_free_pages+0x69>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    SetPageProperty(base);
c0102e65:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e68:	83 c0 04             	add    $0x4,%eax
c0102e6b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0102e72:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e75:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102e78:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102e7b:	0f ab 10             	bts    %edx,(%eax)
    list_entry_t *le = list_next(&free_list(index));
c0102e7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102e81:	89 d0                	mov    %edx,%eax
c0102e83:	01 c0                	add    %eax,%eax
c0102e85:	01 d0                	add    %edx,%eax
c0102e87:	c1 e0 02             	shl    $0x2,%eax
c0102e8a:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102e8f:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102e92:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102e95:	8b 40 04             	mov    0x4(%eax),%eax
c0102e98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned i=index;
c0102e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102e9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    bool b=0;
c0102ea1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    for(;i<buddy_type_size;i++){
c0102ea8:	e9 33 02 00 00       	jmp    c01030e0 <buddy_free_pages+0x39e>
        while (le != &free_list(i)) {
c0102ead:	e9 10 02 00 00       	jmp    c01030c2 <buddy_free_pages+0x380>
            p = le2page(le, page_link);
c0102eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102eb5:	83 e8 0c             	sub    $0xc,%eax
c0102eb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ebe:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102ec1:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102ec4:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
c0102ec7:	89 45 f0             	mov    %eax,-0x10(%ebp)
            if (base + base->property == p) {
c0102eca:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ecd:	8b 50 08             	mov    0x8(%eax),%edx
c0102ed0:	89 d0                	mov    %edx,%eax
c0102ed2:	c1 e0 02             	shl    $0x2,%eax
c0102ed5:	01 d0                	add    %edx,%eax
c0102ed7:	c1 e0 02             	shl    $0x2,%eax
c0102eda:	89 c2                	mov    %eax,%edx
c0102edc:	8b 45 08             	mov    0x8(%ebp),%eax
c0102edf:	01 d0                	add    %edx,%eax
c0102ee1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102ee4:	0f 85 8f 00 00 00    	jne    c0102f79 <buddy_free_pages+0x237>
                base->property += p->property;
c0102eea:	8b 45 08             	mov    0x8(%ebp),%eax
c0102eed:	8b 50 08             	mov    0x8(%eax),%edx
c0102ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ef3:	8b 40 08             	mov    0x8(%eax),%eax
c0102ef6:	01 c2                	add    %eax,%edx
c0102ef8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102efb:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(p);
c0102efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f01:	83 c0 04             	add    $0x4,%eax
c0102f04:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102f0b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102f0e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102f11:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102f14:	0f b3 10             	btr    %edx,(%eax)
                nr_free(i)-=1;
c0102f17:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102f1a:	89 d0                	mov    %edx,%eax
c0102f1c:	01 c0                	add    %eax,%eax
c0102f1e:	01 d0                	add    %edx,%eax
c0102f20:	c1 e0 02             	shl    $0x2,%eax
c0102f23:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102f28:	8b 40 08             	mov    0x8(%eax),%eax
c0102f2b:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0102f2e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102f31:	89 d0                	mov    %edx,%eax
c0102f33:	01 c0                	add    %eax,%eax
c0102f35:	01 d0                	add    %edx,%eax
c0102f37:	c1 e0 02             	shl    $0x2,%eax
c0102f3a:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102f3f:	89 48 08             	mov    %ecx,0x8(%eax)
                list_del(&(p->page_link));
c0102f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f45:	83 c0 0c             	add    $0xc,%eax
c0102f48:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102f4b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102f4e:	8b 40 04             	mov    0x4(%eax),%eax
c0102f51:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102f54:	8b 12                	mov    (%edx),%edx
c0102f56:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0102f59:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102f5c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102f5f:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102f62:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102f65:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102f68:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0102f6b:	89 10                	mov    %edx,(%eax)
                b=1;
c0102f6d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
                break;
c0102f74:	e9 63 01 00 00       	jmp    c01030dc <buddy_free_pages+0x39a>
            }
            else if (p + p->property == base) {
c0102f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f7c:	8b 50 08             	mov    0x8(%eax),%edx
c0102f7f:	89 d0                	mov    %edx,%eax
c0102f81:	c1 e0 02             	shl    $0x2,%eax
c0102f84:	01 d0                	add    %edx,%eax
c0102f86:	c1 e0 02             	shl    $0x2,%eax
c0102f89:	89 c2                	mov    %eax,%edx
c0102f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f8e:	01 d0                	add    %edx,%eax
c0102f90:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102f93:	0f 85 95 00 00 00    	jne    c010302e <buddy_free_pages+0x2ec>
                p->property += base->property;
c0102f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f9c:	8b 50 08             	mov    0x8(%eax),%edx
c0102f9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102fa2:	8b 40 08             	mov    0x8(%eax),%eax
c0102fa5:	01 c2                	add    %eax,%edx
c0102fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102faa:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(base);
c0102fad:	8b 45 08             	mov    0x8(%ebp),%eax
c0102fb0:	83 c0 04             	add    $0x4,%eax
c0102fb3:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0102fba:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102fbd:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102fc0:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102fc3:	0f b3 10             	btr    %edx,(%eax)
                base = p;
c0102fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fc9:	89 45 08             	mov    %eax,0x8(%ebp)
                nr_free(i)-=1;
c0102fcc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102fcf:	89 d0                	mov    %edx,%eax
c0102fd1:	01 c0                	add    %eax,%eax
c0102fd3:	01 d0                	add    %edx,%eax
c0102fd5:	c1 e0 02             	shl    $0x2,%eax
c0102fd8:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102fdd:	8b 40 08             	mov    0x8(%eax),%eax
c0102fe0:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0102fe3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102fe6:	89 d0                	mov    %edx,%eax
c0102fe8:	01 c0                	add    %eax,%eax
c0102fea:	01 d0                	add    %edx,%eax
c0102fec:	c1 e0 02             	shl    $0x2,%eax
c0102fef:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0102ff4:	89 48 08             	mov    %ecx,0x8(%eax)
                list_del(&(p->page_link));
c0102ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ffa:	83 c0 0c             	add    $0xc,%eax
c0102ffd:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103000:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103003:	8b 40 04             	mov    0x4(%eax),%eax
c0103006:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103009:	8b 12                	mov    (%edx),%edx
c010300b:	89 55 98             	mov    %edx,-0x68(%ebp)
c010300e:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103011:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103014:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103017:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010301a:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010301d:	8b 55 98             	mov    -0x68(%ebp),%edx
c0103020:	89 10                	mov    %edx,(%eax)
                b=1;
c0103022:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
                break;
c0103029:	e9 ae 00 00 00       	jmp    c01030dc <buddy_free_pages+0x39a>
            }
            if(b){
c010302e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103032:	0f 84 88 00 00 00    	je     c01030c0 <buddy_free_pages+0x37e>
                nr_free(i+1) += 1;
c0103038:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010303b:	8d 50 01             	lea    0x1(%eax),%edx
c010303e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103041:	8d 48 01             	lea    0x1(%eax),%ecx
c0103044:	89 c8                	mov    %ecx,%eax
c0103046:	01 c0                	add    %eax,%eax
c0103048:	01 c8                	add    %ecx,%eax
c010304a:	c1 e0 02             	shl    $0x2,%eax
c010304d:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0103052:	8b 40 08             	mov    0x8(%eax),%eax
c0103055:	8d 48 01             	lea    0x1(%eax),%ecx
c0103058:	89 d0                	mov    %edx,%eax
c010305a:	01 c0                	add    %eax,%eax
c010305c:	01 d0                	add    %edx,%eax
c010305e:	c1 e0 02             	shl    $0x2,%eax
c0103061:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0103066:	89 48 08             	mov    %ecx,0x8(%eax)
                list_add_before(&free_list(index), &(base->page_link));
c0103069:	8b 45 08             	mov    0x8(%ebp),%eax
c010306c:	8d 48 0c             	lea    0xc(%eax),%ecx
c010306f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103072:	89 d0                	mov    %edx,%eax
c0103074:	01 c0                	add    %eax,%eax
c0103076:	01 d0                	add    %edx,%eax
c0103078:	c1 e0 02             	shl    $0x2,%eax
c010307b:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0103080:	89 45 90             	mov    %eax,-0x70(%ebp)
c0103083:	89 4d 8c             	mov    %ecx,-0x74(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103086:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103089:	8b 00                	mov    (%eax),%eax
c010308b:	8b 55 8c             	mov    -0x74(%ebp),%edx
c010308e:	89 55 88             	mov    %edx,-0x78(%ebp)
c0103091:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0103094:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103097:	89 45 80             	mov    %eax,-0x80(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010309a:	8b 45 80             	mov    -0x80(%ebp),%eax
c010309d:	8b 55 88             	mov    -0x78(%ebp),%edx
c01030a0:	89 10                	mov    %edx,(%eax)
c01030a2:	8b 45 80             	mov    -0x80(%ebp),%eax
c01030a5:	8b 10                	mov    (%eax),%edx
c01030a7:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01030aa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01030ad:	8b 45 88             	mov    -0x78(%ebp),%eax
c01030b0:	8b 55 80             	mov    -0x80(%ebp),%edx
c01030b3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01030b6:	8b 45 88             	mov    -0x78(%ebp),%eax
c01030b9:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01030bc:	89 10                	mov    %edx,(%eax)
c01030be:	eb 02                	jmp    c01030c2 <buddy_free_pages+0x380>
            }
            else
                break;
c01030c0:	eb 1a                	jmp    c01030dc <buddy_free_pages+0x39a>
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list(index));
    unsigned i=index;
    bool b=0;
    for(;i<buddy_type_size;i++){
        while (le != &free_list(i)) {
c01030c2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01030c5:	89 d0                	mov    %edx,%eax
c01030c7:	01 c0                	add    %eax,%eax
c01030c9:	01 d0                	add    %edx,%eax
c01030cb:	c1 e0 02             	shl    $0x2,%eax
c01030ce:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c01030d3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01030d6:	0f 85 d6 fd ff ff    	jne    c0102eb2 <buddy_free_pages+0x170>
    }
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list(index));
    unsigned i=index;
    bool b=0;
    for(;i<buddy_type_size;i++){
c01030dc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01030e0:	83 7d ec 12          	cmpl   $0x12,-0x14(%ebp)
c01030e4:	0f 86 c3 fd ff ff    	jbe    c0102ead <buddy_free_pages+0x16b>
            }
            else
                break;
        }
    }
}
c01030ea:	c9                   	leave  
c01030eb:	c3                   	ret    

c01030ec <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void) {
c01030ec:	55                   	push   %ebp
c01030ed:	89 e5                	mov    %esp,%ebp
c01030ef:	83 ec 10             	sub    $0x10,%esp
     size_t count=0;
c01030f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    unsigned i=0;
c01030f9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
    size_t temp;
    for(;i<buddy_type_size;i++){
c0103100:	eb 2f                	jmp    c0103131 <buddy_nr_free_pages+0x45>
        count+= ( nr_free(i) * buddy_type[i] );
c0103102:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0103105:	89 d0                	mov    %edx,%eax
c0103107:	01 c0                	add    %eax,%eax
c0103109:	01 d0                	add    %edx,%eax
c010310b:	c1 e0 02             	shl    $0x2,%eax
c010310e:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0103113:	8b 48 08             	mov    0x8(%eax),%ecx
c0103116:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103119:	8b 14 c5 84 ce 11 c0 	mov    -0x3fee317c(,%eax,8),%edx
c0103120:	8b 04 c5 80 ce 11 c0 	mov    -0x3fee3180(,%eax,8),%eax
c0103127:	0f af c1             	imul   %ecx,%eax
c010312a:	01 45 fc             	add    %eax,-0x4(%ebp)
static size_t
buddy_nr_free_pages(void) {
     size_t count=0;
    unsigned i=0;
    size_t temp;
    for(;i<buddy_type_size;i++){
c010312d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
c0103131:	83 7d f8 12          	cmpl   $0x12,-0x8(%ebp)
c0103135:	76 cb                	jbe    c0103102 <buddy_nr_free_pages+0x16>
        count+= ( nr_free(i) * buddy_type[i] );
    }
    return count;
c0103137:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010313a:	c9                   	leave  
c010313b:	c3                   	ret    

c010313c <buddy_check>:
// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, buddy_check functions!
static void
buddy_check(void) {
c010313c:	55                   	push   %ebp
c010313d:	89 e5                	mov    %esp,%ebp
c010313f:	81 ec 88 00 00 00    	sub    $0x88,%esp
    cprintf("buddy checking\n");
c0103145:	c7 04 24 e9 73 10 c0 	movl   $0xc01073e9,(%esp)
c010314c:	e8 f7 d1 ff ff       	call   c0100348 <cprintf>
    unsigned count = 0, total = 0;
c0103151:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103158:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    unsigned i=0;
c010315f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    for(;i<buddy_type_size;i++){
c0103166:	e9 a9 00 00 00       	jmp    c0103214 <buddy_check+0xd8>
        list_entry_t *le = &free_list(i);
c010316b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010316e:	89 d0                	mov    %edx,%eax
c0103170:	01 c0                	add    %eax,%eax
c0103172:	01 d0                	add    %edx,%eax
c0103174:	c1 e0 02             	shl    $0x2,%eax
c0103177:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c010317c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        while ((le = list_next(le)) != &free_list(i)) {
c010317f:	eb 66                	jmp    c01031e7 <buddy_check+0xab>
            struct Page *p = le2page(le, page_link);
c0103181:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103184:	83 e8 0c             	sub    $0xc,%eax
c0103187:	89 45 e0             	mov    %eax,-0x20(%ebp)
            assert(PageProperty(p));
c010318a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010318d:	83 c0 04             	add    $0x4,%eax
c0103190:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103197:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010319a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010319d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01031a0:	0f a3 10             	bt     %edx,(%eax)
c01031a3:	19 c0                	sbb    %eax,%eax
c01031a5:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01031a8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01031ac:	0f 95 c0             	setne  %al
c01031af:	0f b6 c0             	movzbl %al,%eax
c01031b2:	85 c0                	test   %eax,%eax
c01031b4:	75 24                	jne    c01031da <buddy_check+0x9e>
c01031b6:	c7 44 24 0c f9 73 10 	movl   $0xc01073f9,0xc(%esp)
c01031bd:	c0 
c01031be:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c01031c5:	c0 
c01031c6:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c01031cd:	00 
c01031ce:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c01031d5:	e8 3e da ff ff       	call   c0100c18 <__panic>
            count ++, total += p->property;
c01031da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01031de:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01031e1:	8b 40 08             	mov    0x8(%eax),%eax
c01031e4:	01 45 f0             	add    %eax,-0x10(%ebp)
c01031e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01031ea:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01031ed:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01031f0:	8b 40 04             	mov    0x4(%eax),%eax
    cprintf("buddy checking\n");
    unsigned count = 0, total = 0;
    unsigned i=0;
    for(;i<buddy_type_size;i++){
        list_entry_t *le = &free_list(i);
        while ((le = list_next(le)) != &free_list(i)) {
c01031f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01031f6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01031f9:	89 d0                	mov    %edx,%eax
c01031fb:	01 c0                	add    %eax,%eax
c01031fd:	01 d0                	add    %edx,%eax
c01031ff:	c1 e0 02             	shl    $0x2,%eax
c0103202:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c0103207:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010320a:	0f 85 71 ff ff ff    	jne    c0103181 <buddy_check+0x45>
static void
buddy_check(void) {
    cprintf("buddy checking\n");
    unsigned count = 0, total = 0;
    unsigned i=0;
    for(;i<buddy_type_size;i++){
c0103210:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0103214:	83 7d ec 12          	cmpl   $0x12,-0x14(%ebp)
c0103218:	0f 86 4d ff ff ff    	jbe    c010316b <buddy_check+0x2f>
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
            count ++, total += p->property;
        }
    }
    assert(total == nr_free_pages());
c010321e:	e8 cd 18 00 00       	call   c0104af0 <nr_free_pages>
c0103223:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103226:	74 24                	je     c010324c <buddy_check+0x110>
c0103228:	c7 44 24 0c 09 74 10 	movl   $0xc0107409,0xc(%esp)
c010322f:	c0 
c0103230:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c0103237:	c0 
c0103238:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c010323f:	00 
c0103240:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c0103247:	e8 cc d9 ff ff       	call   c0100c18 <__panic>
    struct Page *p0 = alloc_pages(8), *p1, *p2;
c010324c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0103253:	e8 2e 18 00 00       	call   c0104a86 <alloc_pages>
c0103258:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c010325b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010325f:	75 24                	jne    c0103285 <buddy_check+0x149>
c0103261:	c7 44 24 0c 22 74 10 	movl   $0xc0107422,0xc(%esp)
c0103268:	c0 
c0103269:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c0103270:	c0 
c0103271:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0103278:	00 
c0103279:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c0103280:	e8 93 d9 ff ff       	call   c0100c18 <__panic>
    assert(!PageProperty(p0));
c0103285:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103288:	83 c0 04             	add    $0x4,%eax
c010328b:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103292:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103295:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103298:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010329b:	0f a3 10             	bt     %edx,(%eax)
c010329e:	19 c0                	sbb    %eax,%eax
c01032a0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01032a3:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01032a7:	0f 95 c0             	setne  %al
c01032aa:	0f b6 c0             	movzbl %al,%eax
c01032ad:	85 c0                	test   %eax,%eax
c01032af:	74 24                	je     c01032d5 <buddy_check+0x199>
c01032b1:	c7 44 24 0c 2d 74 10 	movl   $0xc010742d,0xc(%esp)
c01032b8:	c0 
c01032b9:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c01032c0:	c0 
c01032c1:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c01032c8:	00 
c01032c9:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c01032d0:	e8 43 d9 ff ff       	call   c0100c18 <__panic>
    list_entry_t free_list_store = free_list(3);
c01032d5:	a1 e4 cf 11 c0       	mov    0xc011cfe4,%eax
c01032da:	8b 15 e8 cf 11 c0    	mov    0xc011cfe8,%edx
c01032e0:	89 45 90             	mov    %eax,-0x70(%ebp)
c01032e3:	89 55 94             	mov    %edx,-0x6c(%ebp)
c01032e6:	c7 45 b4 e4 cf 11 c0 	movl   $0xc011cfe4,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01032ed:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01032f0:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01032f3:	89 50 04             	mov    %edx,0x4(%eax)
c01032f6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01032f9:	8b 50 04             	mov    0x4(%eax),%edx
c01032fc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01032ff:	89 10                	mov    %edx,(%eax)
c0103301:	c7 45 b0 e4 cf 11 c0 	movl   $0xc011cfe4,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103308:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010330b:	8b 40 04             	mov    0x4(%eax),%eax
c010330e:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0103311:	0f 94 c0             	sete   %al
c0103314:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list(3));
    assert(list_empty(&free_list(3)));
c0103317:	85 c0                	test   %eax,%eax
c0103319:	75 24                	jne    c010333f <buddy_check+0x203>
c010331b:	c7 44 24 0c 3f 74 10 	movl   $0xc010743f,0xc(%esp)
c0103322:	c0 
c0103323:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c010332a:	c0 
c010332b:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0103332:	00 
c0103333:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c010333a:	e8 d9 d8 ff ff       	call   c0100c18 <__panic>
    struct Page *p01 = alloc_pages(8);
c010333f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0103346:	e8 3b 17 00 00       	call   c0104a86 <alloc_pages>
c010334b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    assert(p01 != NULL);
c010334e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103352:	75 24                	jne    c0103378 <buddy_check+0x23c>
c0103354:	c7 44 24 0c 59 74 10 	movl   $0xc0107459,0xc(%esp)
c010335b:	c0 
c010335c:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c0103363:	c0 
c0103364:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c010336b:	00 
c010336c:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c0103373:	e8 a0 d8 ff ff       	call   c0100c18 <__panic>
    assert(!PageProperty(p01));
c0103378:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010337b:	83 c0 04             	add    $0x4,%eax
c010337e:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0103385:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103388:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010338b:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010338e:	0f a3 10             	bt     %edx,(%eax)
c0103391:	19 c0                	sbb    %eax,%eax
c0103393:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0103396:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c010339a:	0f 95 c0             	setne  %al
c010339d:	0f b6 c0             	movzbl %al,%eax
c01033a0:	85 c0                	test   %eax,%eax
c01033a2:	74 24                	je     c01033c8 <buddy_check+0x28c>
c01033a4:	c7 44 24 0c 65 74 10 	movl   $0xc0107465,0xc(%esp)
c01033ab:	c0 
c01033ac:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c01033b3:	c0 
c01033b4:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01033bb:	00 
c01033bc:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c01033c3:	e8 50 d8 ff ff       	call   c0100c18 <__panic>
    free_list_store = free_list(3);
c01033c8:	a1 e4 cf 11 c0       	mov    0xc011cfe4,%eax
c01033cd:	8b 15 e8 cf 11 c0    	mov    0xc011cfe8,%edx
c01033d3:	89 45 90             	mov    %eax,-0x70(%ebp)
c01033d6:	89 55 94             	mov    %edx,-0x6c(%ebp)
c01033d9:	c7 45 a0 e4 cf 11 c0 	movl   $0xc011cfe4,-0x60(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01033e0:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01033e3:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01033e6:	89 50 04             	mov    %edx,0x4(%eax)
c01033e9:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01033ec:	8b 50 04             	mov    0x4(%eax),%edx
c01033ef:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01033f2:	89 10                	mov    %edx,(%eax)
c01033f4:	c7 45 9c e4 cf 11 c0 	movl   $0xc011cfe4,-0x64(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01033fb:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01033fe:	8b 40 04             	mov    0x4(%eax),%eax
c0103401:	39 45 9c             	cmp    %eax,-0x64(%ebp)
c0103404:	0f 94 c0             	sete   %al
c0103407:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list(3));
    assert(list_empty(&free_list(3)));
c010340a:	85 c0                	test   %eax,%eax
c010340c:	75 24                	jne    c0103432 <buddy_check+0x2f6>
c010340e:	c7 44 24 0c 3f 74 10 	movl   $0xc010743f,0xc(%esp)
c0103415:	c0 
c0103416:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c010341d:	c0 
c010341e:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0103425:	00 
c0103426:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c010342d:	e8 e6 d7 ff ff       	call   c0100c18 <__panic>
    cprintf("%d\n",nr_free(3));
c0103432:	a1 ec cf 11 c0       	mov    0xc011cfec,%eax
c0103437:	89 44 24 04          	mov    %eax,0x4(%esp)
c010343b:	c7 04 24 78 74 10 c0 	movl   $0xc0107478,(%esp)
c0103442:	e8 01 cf ff ff       	call   c0100348 <cprintf>
    free_pages(p01,8);
c0103447:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
c010344e:	00 
c010344f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103452:	89 04 24             	mov    %eax,(%esp)
c0103455:	e8 64 16 00 00       	call   c0104abe <free_pages>
    cprintf("%d\n",nr_free(3));
c010345a:	a1 ec cf 11 c0       	mov    0xc011cfec,%eax
c010345f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103463:	c7 04 24 78 74 10 c0 	movl   $0xc0107478,(%esp)
c010346a:	e8 d9 ce ff ff       	call   c0100348 <cprintf>
    free_pages(p0, 8);
c010346f:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
c0103476:	00 
c0103477:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010347a:	89 04 24             	mov    %eax,(%esp)
c010347d:	e8 3c 16 00 00       	call   c0104abe <free_pages>
    cprintf("xxxxxxxxxxxxxx\n");
c0103482:	c7 04 24 7c 74 10 c0 	movl   $0xc010747c,(%esp)
c0103489:	e8 ba ce ff ff       	call   c0100348 <cprintf>
     for(;i<buddy_type_size;i++){
c010348e:	e9 93 00 00 00       	jmp    c0103526 <buddy_check+0x3ea>
        list_entry_t *le = &free_list(i);
c0103493:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103496:	89 d0                	mov    %edx,%eax
c0103498:	01 c0                	add    %eax,%eax
c010349a:	01 d0                	add    %edx,%eax
c010349c:	c1 e0 02             	shl    $0x2,%eax
c010349f:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c01034a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        while ((le = list_next(le)) != &free_list(i)) {
c01034a7:	eb 54                	jmp    c01034fd <buddy_check+0x3c1>
            assert(le->next->prev == le && le->prev->next == le);
c01034a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034ac:	8b 40 04             	mov    0x4(%eax),%eax
c01034af:	8b 00                	mov    (%eax),%eax
c01034b1:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c01034b4:	75 0d                	jne    c01034c3 <buddy_check+0x387>
c01034b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034b9:	8b 00                	mov    (%eax),%eax
c01034bb:	8b 40 04             	mov    0x4(%eax),%eax
c01034be:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c01034c1:	74 24                	je     c01034e7 <buddy_check+0x3ab>
c01034c3:	c7 44 24 0c 8c 74 10 	movl   $0xc010748c,0xc(%esp)
c01034ca:	c0 
c01034cb:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c01034d2:	c0 
c01034d3:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c01034da:	00 
c01034db:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c01034e2:	e8 31 d7 ff ff       	call   c0100c18 <__panic>
        struct Page *p = le2page(le, page_link);
c01034e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034ea:	83 e8 0c             	sub    $0xc,%eax
c01034ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01034f0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01034f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01034f7:	8b 40 08             	mov    0x8(%eax),%eax
c01034fa:	29 45 f0             	sub    %eax,-0x10(%ebp)
c01034fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103500:	89 45 98             	mov    %eax,-0x68(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103503:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103506:	8b 40 04             	mov    0x4(%eax),%eax
    cprintf("%d\n",nr_free(3));
    free_pages(p0, 8);
    cprintf("xxxxxxxxxxxxxx\n");
     for(;i<buddy_type_size;i++){
        list_entry_t *le = &free_list(i);
        while ((le = list_next(le)) != &free_list(i)) {
c0103509:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010350c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010350f:	89 d0                	mov    %edx,%eax
c0103511:	01 c0                	add    %eax,%eax
c0103513:	01 d0                	add    %edx,%eax
c0103515:	c1 e0 02             	shl    $0x2,%eax
c0103518:	05 c0 cf 11 c0       	add    $0xc011cfc0,%eax
c010351d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103520:	75 87                	jne    c01034a9 <buddy_check+0x36d>
    cprintf("%d\n",nr_free(3));
    free_pages(p01,8);
    cprintf("%d\n",nr_free(3));
    free_pages(p0, 8);
    cprintf("xxxxxxxxxxxxxx\n");
     for(;i<buddy_type_size;i++){
c0103522:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0103526:	83 7d ec 12          	cmpl   $0x12,-0x14(%ebp)
c010352a:	0f 86 63 ff ff ff    	jbe    c0103493 <buddy_check+0x357>
            assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
        }
    }
    assert(count == 0);
c0103530:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103534:	74 24                	je     c010355a <buddy_check+0x41e>
c0103536:	c7 44 24 0c b9 74 10 	movl   $0xc01074b9,0xc(%esp)
c010353d:	c0 
c010353e:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c0103545:	c0 
c0103546:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c010354d:	00 
c010354e:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c0103555:	e8 be d6 ff ff       	call   c0100c18 <__panic>
    assert(total == 0);
c010355a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010355e:	74 24                	je     c0103584 <buddy_check+0x448>
c0103560:	c7 44 24 0c c4 74 10 	movl   $0xc01074c4,0xc(%esp)
c0103567:	c0 
c0103568:	c7 44 24 08 82 73 10 	movl   $0xc0107382,0x8(%esp)
c010356f:	c0 
c0103570:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0103577:	00 
c0103578:	c7 04 24 97 73 10 c0 	movl   $0xc0107397,(%esp)
c010357f:	e8 94 d6 ff ff       	call   c0100c18 <__panic>
    cprintf("pppppppppppp\n");
c0103584:	c7 04 24 cf 74 10 c0 	movl   $0xc01074cf,(%esp)
c010358b:	e8 b8 cd ff ff       	call   c0100348 <cprintf>
}
c0103590:	c9                   	leave  
c0103591:	c3                   	ret    

c0103592 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103592:	55                   	push   %ebp
c0103593:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103595:	8b 55 08             	mov    0x8(%ebp),%edx
c0103598:	a1 b8 d0 11 c0       	mov    0xc011d0b8,%eax
c010359d:	29 c2                	sub    %eax,%edx
c010359f:	89 d0                	mov    %edx,%eax
c01035a1:	c1 f8 02             	sar    $0x2,%eax
c01035a4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01035aa:	5d                   	pop    %ebp
c01035ab:	c3                   	ret    

c01035ac <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01035ac:	55                   	push   %ebp
c01035ad:	89 e5                	mov    %esp,%ebp
c01035af:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01035b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01035b5:	89 04 24             	mov    %eax,(%esp)
c01035b8:	e8 d5 ff ff ff       	call   c0103592 <page2ppn>
c01035bd:	c1 e0 0c             	shl    $0xc,%eax
}
c01035c0:	c9                   	leave  
c01035c1:	c3                   	ret    

c01035c2 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01035c2:	55                   	push   %ebp
c01035c3:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01035c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01035c8:	8b 00                	mov    (%eax),%eax
}
c01035ca:	5d                   	pop    %ebp
c01035cb:	c3                   	ret    

c01035cc <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01035cc:	55                   	push   %ebp
c01035cd:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01035cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01035d2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01035d5:	89 10                	mov    %edx,(%eax)
}
c01035d7:	5d                   	pop    %ebp
c01035d8:	c3                   	ret    

c01035d9 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01035d9:	55                   	push   %ebp
c01035da:	89 e5                	mov    %esp,%ebp
c01035dc:	83 ec 10             	sub    $0x10,%esp
c01035df:	c7 45 fc a4 d0 11 c0 	movl   $0xc011d0a4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01035e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01035ec:	89 50 04             	mov    %edx,0x4(%eax)
c01035ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035f2:	8b 50 04             	mov    0x4(%eax),%edx
c01035f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035f8:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01035fa:	c7 05 ac d0 11 c0 00 	movl   $0x0,0xc011d0ac
c0103601:	00 00 00 
}
c0103604:	c9                   	leave  
c0103605:	c3                   	ret    

c0103606 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0103606:	55                   	push   %ebp
c0103607:	89 e5                	mov    %esp,%ebp
c0103609:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c010360c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103610:	75 24                	jne    c0103636 <default_init_memmap+0x30>
c0103612:	c7 44 24 0c 0c 75 10 	movl   $0xc010750c,0xc(%esp)
c0103619:	c0 
c010361a:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103621:	c0 
c0103622:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103629:	00 
c010362a:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103631:	e8 e2 d5 ff ff       	call   c0100c18 <__panic>
    struct Page *p = base;
c0103636:	8b 45 08             	mov    0x8(%ebp),%eax
c0103639:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010363c:	eb 7d                	jmp    c01036bb <default_init_memmap+0xb5>
        assert(PageReserved(p));
c010363e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103641:	83 c0 04             	add    $0x4,%eax
c0103644:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010364b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010364e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103651:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103654:	0f a3 10             	bt     %edx,(%eax)
c0103657:	19 c0                	sbb    %eax,%eax
c0103659:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c010365c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103660:	0f 95 c0             	setne  %al
c0103663:	0f b6 c0             	movzbl %al,%eax
c0103666:	85 c0                	test   %eax,%eax
c0103668:	75 24                	jne    c010368e <default_init_memmap+0x88>
c010366a:	c7 44 24 0c 3d 75 10 	movl   $0xc010753d,0xc(%esp)
c0103671:	c0 
c0103672:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103679:	c0 
c010367a:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0103681:	00 
c0103682:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103689:	e8 8a d5 ff ff       	call   c0100c18 <__panic>
        p->flags = p->property = 0;
c010368e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103691:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0103698:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010369b:	8b 50 08             	mov    0x8(%eax),%edx
c010369e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036a1:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01036a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01036ab:	00 
c01036ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036af:	89 04 24             	mov    %eax,(%esp)
c01036b2:	e8 15 ff ff ff       	call   c01035cc <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01036b7:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01036bb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01036be:	89 d0                	mov    %edx,%eax
c01036c0:	c1 e0 02             	shl    $0x2,%eax
c01036c3:	01 d0                	add    %edx,%eax
c01036c5:	c1 e0 02             	shl    $0x2,%eax
c01036c8:	89 c2                	mov    %eax,%edx
c01036ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01036cd:	01 d0                	add    %edx,%eax
c01036cf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01036d2:	0f 85 66 ff ff ff    	jne    c010363e <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01036d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01036db:	8b 55 0c             	mov    0xc(%ebp),%edx
c01036de:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01036e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01036e4:	83 c0 04             	add    $0x4,%eax
c01036e7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01036ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01036f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01036f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01036f7:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01036fa:	8b 15 ac d0 11 c0    	mov    0xc011d0ac,%edx
c0103700:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103703:	01 d0                	add    %edx,%eax
c0103705:	a3 ac d0 11 c0       	mov    %eax,0xc011d0ac
    list_add(&free_list, &(base->page_link));
c010370a:	8b 45 08             	mov    0x8(%ebp),%eax
c010370d:	83 c0 0c             	add    $0xc,%eax
c0103710:	c7 45 dc a4 d0 11 c0 	movl   $0xc011d0a4,-0x24(%ebp)
c0103717:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010371a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010371d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0103720:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103723:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103726:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103729:	8b 40 04             	mov    0x4(%eax),%eax
c010372c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010372f:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103732:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103735:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0103738:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010373b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010373e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103741:	89 10                	mov    %edx,(%eax)
c0103743:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103746:	8b 10                	mov    (%eax),%edx
c0103748:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010374b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010374e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103751:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103754:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103757:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010375a:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010375d:	89 10                	mov    %edx,(%eax)
}
c010375f:	c9                   	leave  
c0103760:	c3                   	ret    

c0103761 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0103761:	55                   	push   %ebp
c0103762:	89 e5                	mov    %esp,%ebp
c0103764:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0103767:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010376b:	75 24                	jne    c0103791 <default_alloc_pages+0x30>
c010376d:	c7 44 24 0c 0c 75 10 	movl   $0xc010750c,0xc(%esp)
c0103774:	c0 
c0103775:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c010377c:	c0 
c010377d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0103784:	00 
c0103785:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c010378c:	e8 87 d4 ff ff       	call   c0100c18 <__panic>
    if (n > nr_free) {
c0103791:	a1 ac d0 11 c0       	mov    0xc011d0ac,%eax
c0103796:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103799:	73 0a                	jae    c01037a5 <default_alloc_pages+0x44>
        return NULL;
c010379b:	b8 00 00 00 00       	mov    $0x0,%eax
c01037a0:	e9 2a 01 00 00       	jmp    c01038cf <default_alloc_pages+0x16e>
    }
    struct Page *page = NULL;
c01037a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01037ac:	c7 45 f0 a4 d0 11 c0 	movl   $0xc011d0a4,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01037b3:	eb 1c                	jmp    c01037d1 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c01037b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037b8:	83 e8 0c             	sub    $0xc,%eax
c01037bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c01037be:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037c1:	8b 40 08             	mov    0x8(%eax),%eax
c01037c4:	3b 45 08             	cmp    0x8(%ebp),%eax
c01037c7:	72 08                	jb     c01037d1 <default_alloc_pages+0x70>
            page = p;
c01037c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01037cf:	eb 18                	jmp    c01037e9 <default_alloc_pages+0x88>
c01037d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01037d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037da:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01037dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01037e0:	81 7d f0 a4 d0 11 c0 	cmpl   $0xc011d0a4,-0x10(%ebp)
c01037e7:	75 cc                	jne    c01037b5 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c01037e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01037ed:	0f 84 d9 00 00 00    	je     c01038cc <default_alloc_pages+0x16b>
        list_del(&(page->page_link));
c01037f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037f6:	83 c0 0c             	add    $0xc,%eax
c01037f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01037fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01037ff:	8b 40 04             	mov    0x4(%eax),%eax
c0103802:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103805:	8b 12                	mov    (%edx),%edx
c0103807:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010380a:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010380d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103810:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103813:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103816:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103819:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010381c:	89 10                	mov    %edx,(%eax)
        if (page->property > n) {
c010381e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103821:	8b 40 08             	mov    0x8(%eax),%eax
c0103824:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103827:	76 7d                	jbe    c01038a6 <default_alloc_pages+0x145>
            struct Page *p = page + n;
c0103829:	8b 55 08             	mov    0x8(%ebp),%edx
c010382c:	89 d0                	mov    %edx,%eax
c010382e:	c1 e0 02             	shl    $0x2,%eax
c0103831:	01 d0                	add    %edx,%eax
c0103833:	c1 e0 02             	shl    $0x2,%eax
c0103836:	89 c2                	mov    %eax,%edx
c0103838:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010383b:	01 d0                	add    %edx,%eax
c010383d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0103840:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103843:	8b 40 08             	mov    0x8(%eax),%eax
c0103846:	2b 45 08             	sub    0x8(%ebp),%eax
c0103849:	89 c2                	mov    %eax,%edx
c010384b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010384e:	89 50 08             	mov    %edx,0x8(%eax)
            list_add(&free_list, &(p->page_link));
c0103851:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103854:	83 c0 0c             	add    $0xc,%eax
c0103857:	c7 45 d4 a4 d0 11 c0 	movl   $0xc011d0a4,-0x2c(%ebp)
c010385e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103861:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103864:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0103867:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010386a:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010386d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103870:	8b 40 04             	mov    0x4(%eax),%eax
c0103873:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103876:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0103879:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010387c:	89 55 c0             	mov    %edx,-0x40(%ebp)
c010387f:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103882:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103885:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103888:	89 10                	mov    %edx,(%eax)
c010388a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010388d:	8b 10                	mov    (%eax),%edx
c010388f:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103892:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103895:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103898:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010389b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010389e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01038a1:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01038a4:	89 10                	mov    %edx,(%eax)
    }
        nr_free -= n;
c01038a6:	a1 ac d0 11 c0       	mov    0xc011d0ac,%eax
c01038ab:	2b 45 08             	sub    0x8(%ebp),%eax
c01038ae:	a3 ac d0 11 c0       	mov    %eax,0xc011d0ac
        ClearPageProperty(page);
c01038b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038b6:	83 c0 04             	add    $0x4,%eax
c01038b9:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c01038c0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01038c3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01038c6:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01038c9:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c01038cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01038cf:	c9                   	leave  
c01038d0:	c3                   	ret    

c01038d1 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01038d1:	55                   	push   %ebp
c01038d2:	89 e5                	mov    %esp,%ebp
c01038d4:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c01038da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01038de:	75 24                	jne    c0103904 <default_free_pages+0x33>
c01038e0:	c7 44 24 0c 0c 75 10 	movl   $0xc010750c,0xc(%esp)
c01038e7:	c0 
c01038e8:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c01038ef:	c0 
c01038f0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c01038f7:	00 
c01038f8:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c01038ff:	e8 14 d3 ff ff       	call   c0100c18 <__panic>
    struct Page *p = base;
c0103904:	8b 45 08             	mov    0x8(%ebp),%eax
c0103907:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010390a:	e9 9d 00 00 00       	jmp    c01039ac <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c010390f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103912:	83 c0 04             	add    $0x4,%eax
c0103915:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010391c:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010391f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103922:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103925:	0f a3 10             	bt     %edx,(%eax)
c0103928:	19 c0                	sbb    %eax,%eax
c010392a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c010392d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103931:	0f 95 c0             	setne  %al
c0103934:	0f b6 c0             	movzbl %al,%eax
c0103937:	85 c0                	test   %eax,%eax
c0103939:	75 2c                	jne    c0103967 <default_free_pages+0x96>
c010393b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010393e:	83 c0 04             	add    $0x4,%eax
c0103941:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0103948:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010394b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010394e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103951:	0f a3 10             	bt     %edx,(%eax)
c0103954:	19 c0                	sbb    %eax,%eax
c0103956:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0103959:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010395d:	0f 95 c0             	setne  %al
c0103960:	0f b6 c0             	movzbl %al,%eax
c0103963:	85 c0                	test   %eax,%eax
c0103965:	74 24                	je     c010398b <default_free_pages+0xba>
c0103967:	c7 44 24 0c 50 75 10 	movl   $0xc0107550,0xc(%esp)
c010396e:	c0 
c010396f:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103976:	c0 
c0103977:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
c010397e:	00 
c010397f:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103986:	e8 8d d2 ff ff       	call   c0100c18 <__panic>
        p->flags = 0;
c010398b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010398e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103995:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010399c:	00 
c010399d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039a0:	89 04 24             	mov    %eax,(%esp)
c01039a3:	e8 24 fc ff ff       	call   c01035cc <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01039a8:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01039ac:	8b 55 0c             	mov    0xc(%ebp),%edx
c01039af:	89 d0                	mov    %edx,%eax
c01039b1:	c1 e0 02             	shl    $0x2,%eax
c01039b4:	01 d0                	add    %edx,%eax
c01039b6:	c1 e0 02             	shl    $0x2,%eax
c01039b9:	89 c2                	mov    %eax,%edx
c01039bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01039be:	01 d0                	add    %edx,%eax
c01039c0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01039c3:	0f 85 46 ff ff ff    	jne    c010390f <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01039c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01039cc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01039cf:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01039d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01039d5:	83 c0 04             	add    $0x4,%eax
c01039d8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01039df:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01039e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01039e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01039e8:	0f ab 10             	bts    %edx,(%eax)
c01039eb:	c7 45 cc a4 d0 11 c0 	movl   $0xc011d0a4,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01039f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01039f5:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01039f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01039fb:	e9 08 01 00 00       	jmp    c0103b08 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0103a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a03:	83 e8 0c             	sub    $0xc,%eax
c0103a06:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a0c:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103a0f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103a12:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103a15:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0103a18:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a1b:	8b 50 08             	mov    0x8(%eax),%edx
c0103a1e:	89 d0                	mov    %edx,%eax
c0103a20:	c1 e0 02             	shl    $0x2,%eax
c0103a23:	01 d0                	add    %edx,%eax
c0103a25:	c1 e0 02             	shl    $0x2,%eax
c0103a28:	89 c2                	mov    %eax,%edx
c0103a2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a2d:	01 d0                	add    %edx,%eax
c0103a2f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a32:	75 5a                	jne    c0103a8e <default_free_pages+0x1bd>
            base->property += p->property;
c0103a34:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a37:	8b 50 08             	mov    0x8(%eax),%edx
c0103a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a3d:	8b 40 08             	mov    0x8(%eax),%eax
c0103a40:	01 c2                	add    %eax,%edx
c0103a42:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a45:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0103a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a4b:	83 c0 04             	add    $0x4,%eax
c0103a4e:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0103a55:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103a58:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103a5b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103a5e:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0103a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a64:	83 c0 0c             	add    $0xc,%eax
c0103a67:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103a6a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103a6d:	8b 40 04             	mov    0x4(%eax),%eax
c0103a70:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103a73:	8b 12                	mov    (%edx),%edx
c0103a75:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0103a78:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103a7b:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103a7e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103a81:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103a84:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103a87:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103a8a:	89 10                	mov    %edx,(%eax)
c0103a8c:	eb 7a                	jmp    c0103b08 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0103a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a91:	8b 50 08             	mov    0x8(%eax),%edx
c0103a94:	89 d0                	mov    %edx,%eax
c0103a96:	c1 e0 02             	shl    $0x2,%eax
c0103a99:	01 d0                	add    %edx,%eax
c0103a9b:	c1 e0 02             	shl    $0x2,%eax
c0103a9e:	89 c2                	mov    %eax,%edx
c0103aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aa3:	01 d0                	add    %edx,%eax
c0103aa5:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103aa8:	75 5e                	jne    c0103b08 <default_free_pages+0x237>
            p->property += base->property;
c0103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aad:	8b 50 08             	mov    0x8(%eax),%edx
c0103ab0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ab3:	8b 40 08             	mov    0x8(%eax),%eax
c0103ab6:	01 c2                	add    %eax,%edx
c0103ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103abb:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0103abe:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ac1:	83 c0 04             	add    $0x4,%eax
c0103ac4:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0103acb:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103ace:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103ad1:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103ad4:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0103ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ada:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103add:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ae0:	83 c0 0c             	add    $0xc,%eax
c0103ae3:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103ae6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103ae9:	8b 40 04             	mov    0x4(%eax),%eax
c0103aec:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103aef:	8b 12                	mov    (%edx),%edx
c0103af1:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0103af4:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103af7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103afa:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103afd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103b00:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103b03:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103b06:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0103b08:	81 7d f0 a4 d0 11 c0 	cmpl   $0xc011d0a4,-0x10(%ebp)
c0103b0f:	0f 85 eb fe ff ff    	jne    c0103a00 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0103b15:	8b 15 ac d0 11 c0    	mov    0xc011d0ac,%edx
c0103b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b1e:	01 d0                	add    %edx,%eax
c0103b20:	a3 ac d0 11 c0       	mov    %eax,0xc011d0ac
    list_add(&free_list, &(base->page_link));
c0103b25:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b28:	83 c0 0c             	add    $0xc,%eax
c0103b2b:	c7 45 9c a4 d0 11 c0 	movl   $0xc011d0a4,-0x64(%ebp)
c0103b32:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103b35:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103b38:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0103b3b:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103b3e:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103b41:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103b44:	8b 40 04             	mov    0x4(%eax),%eax
c0103b47:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103b4a:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103b4d:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103b50:	89 55 88             	mov    %edx,-0x78(%ebp)
c0103b53:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103b56:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103b59:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103b5c:	89 10                	mov    %edx,(%eax)
c0103b5e:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103b61:	8b 10                	mov    (%eax),%edx
c0103b63:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103b66:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103b69:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103b6c:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103b6f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103b72:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103b75:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103b78:	89 10                	mov    %edx,(%eax)
}
c0103b7a:	c9                   	leave  
c0103b7b:	c3                   	ret    

c0103b7c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103b7c:	55                   	push   %ebp
c0103b7d:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103b7f:	a1 ac d0 11 c0       	mov    0xc011d0ac,%eax
}
c0103b84:	5d                   	pop    %ebp
c0103b85:	c3                   	ret    

c0103b86 <basic_check>:

static void
basic_check(void) {
c0103b86:	55                   	push   %ebp
c0103b87:	89 e5                	mov    %esp,%ebp
c0103b89:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b96:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103b9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ba6:	e8 db 0e 00 00       	call   c0104a86 <alloc_pages>
c0103bab:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103bae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103bb2:	75 24                	jne    c0103bd8 <basic_check+0x52>
c0103bb4:	c7 44 24 0c 75 75 10 	movl   $0xc0107575,0xc(%esp)
c0103bbb:	c0 
c0103bbc:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103bc3:	c0 
c0103bc4:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0103bcb:	00 
c0103bcc:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103bd3:	e8 40 d0 ff ff       	call   c0100c18 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103bd8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103bdf:	e8 a2 0e 00 00       	call   c0104a86 <alloc_pages>
c0103be4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103be7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103beb:	75 24                	jne    c0103c11 <basic_check+0x8b>
c0103bed:	c7 44 24 0c 91 75 10 	movl   $0xc0107591,0xc(%esp)
c0103bf4:	c0 
c0103bf5:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103bfc:	c0 
c0103bfd:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0103c04:	00 
c0103c05:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103c0c:	e8 07 d0 ff ff       	call   c0100c18 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103c11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c18:	e8 69 0e 00 00       	call   c0104a86 <alloc_pages>
c0103c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103c24:	75 24                	jne    c0103c4a <basic_check+0xc4>
c0103c26:	c7 44 24 0c ad 75 10 	movl   $0xc01075ad,0xc(%esp)
c0103c2d:	c0 
c0103c2e:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103c35:	c0 
c0103c36:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0103c3d:	00 
c0103c3e:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103c45:	e8 ce cf ff ff       	call   c0100c18 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103c4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c4d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103c50:	74 10                	je     c0103c62 <basic_check+0xdc>
c0103c52:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c55:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103c58:	74 08                	je     c0103c62 <basic_check+0xdc>
c0103c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c5d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103c60:	75 24                	jne    c0103c86 <basic_check+0x100>
c0103c62:	c7 44 24 0c cc 75 10 	movl   $0xc01075cc,0xc(%esp)
c0103c69:	c0 
c0103c6a:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103c71:	c0 
c0103c72:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
c0103c79:	00 
c0103c7a:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103c81:	e8 92 cf ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103c86:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c89:	89 04 24             	mov    %eax,(%esp)
c0103c8c:	e8 31 f9 ff ff       	call   c01035c2 <page_ref>
c0103c91:	85 c0                	test   %eax,%eax
c0103c93:	75 1e                	jne    c0103cb3 <basic_check+0x12d>
c0103c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c98:	89 04 24             	mov    %eax,(%esp)
c0103c9b:	e8 22 f9 ff ff       	call   c01035c2 <page_ref>
c0103ca0:	85 c0                	test   %eax,%eax
c0103ca2:	75 0f                	jne    c0103cb3 <basic_check+0x12d>
c0103ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ca7:	89 04 24             	mov    %eax,(%esp)
c0103caa:	e8 13 f9 ff ff       	call   c01035c2 <page_ref>
c0103caf:	85 c0                	test   %eax,%eax
c0103cb1:	74 24                	je     c0103cd7 <basic_check+0x151>
c0103cb3:	c7 44 24 0c f0 75 10 	movl   $0xc01075f0,0xc(%esp)
c0103cba:	c0 
c0103cbb:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103cc2:	c0 
c0103cc3:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0103cca:	00 
c0103ccb:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103cd2:	e8 41 cf ff ff       	call   c0100c18 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103cd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cda:	89 04 24             	mov    %eax,(%esp)
c0103cdd:	e8 ca f8 ff ff       	call   c01035ac <page2pa>
c0103ce2:	8b 15 20 cf 11 c0    	mov    0xc011cf20,%edx
c0103ce8:	c1 e2 0c             	shl    $0xc,%edx
c0103ceb:	39 d0                	cmp    %edx,%eax
c0103ced:	72 24                	jb     c0103d13 <basic_check+0x18d>
c0103cef:	c7 44 24 0c 2c 76 10 	movl   $0xc010762c,0xc(%esp)
c0103cf6:	c0 
c0103cf7:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103cfe:	c0 
c0103cff:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c0103d06:	00 
c0103d07:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103d0e:	e8 05 cf ff ff       	call   c0100c18 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d16:	89 04 24             	mov    %eax,(%esp)
c0103d19:	e8 8e f8 ff ff       	call   c01035ac <page2pa>
c0103d1e:	8b 15 20 cf 11 c0    	mov    0xc011cf20,%edx
c0103d24:	c1 e2 0c             	shl    $0xc,%edx
c0103d27:	39 d0                	cmp    %edx,%eax
c0103d29:	72 24                	jb     c0103d4f <basic_check+0x1c9>
c0103d2b:	c7 44 24 0c 49 76 10 	movl   $0xc0107649,0xc(%esp)
c0103d32:	c0 
c0103d33:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103d3a:	c0 
c0103d3b:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0103d42:	00 
c0103d43:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103d4a:	e8 c9 ce ff ff       	call   c0100c18 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d52:	89 04 24             	mov    %eax,(%esp)
c0103d55:	e8 52 f8 ff ff       	call   c01035ac <page2pa>
c0103d5a:	8b 15 20 cf 11 c0    	mov    0xc011cf20,%edx
c0103d60:	c1 e2 0c             	shl    $0xc,%edx
c0103d63:	39 d0                	cmp    %edx,%eax
c0103d65:	72 24                	jb     c0103d8b <basic_check+0x205>
c0103d67:	c7 44 24 0c 66 76 10 	movl   $0xc0107666,0xc(%esp)
c0103d6e:	c0 
c0103d6f:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103d76:	c0 
c0103d77:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0103d7e:	00 
c0103d7f:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103d86:	e8 8d ce ff ff       	call   c0100c18 <__panic>

    list_entry_t free_list_store = free_list;
c0103d8b:	a1 a4 d0 11 c0       	mov    0xc011d0a4,%eax
c0103d90:	8b 15 a8 d0 11 c0    	mov    0xc011d0a8,%edx
c0103d96:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103d99:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103d9c:	c7 45 e0 a4 d0 11 c0 	movl   $0xc011d0a4,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103da3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103da6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103da9:	89 50 04             	mov    %edx,0x4(%eax)
c0103dac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103daf:	8b 50 04             	mov    0x4(%eax),%edx
c0103db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103db5:	89 10                	mov    %edx,(%eax)
c0103db7:	c7 45 dc a4 d0 11 c0 	movl   $0xc011d0a4,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103dbe:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103dc1:	8b 40 04             	mov    0x4(%eax),%eax
c0103dc4:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103dc7:	0f 94 c0             	sete   %al
c0103dca:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103dcd:	85 c0                	test   %eax,%eax
c0103dcf:	75 24                	jne    c0103df5 <basic_check+0x26f>
c0103dd1:	c7 44 24 0c 83 76 10 	movl   $0xc0107683,0xc(%esp)
c0103dd8:	c0 
c0103dd9:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103de0:	c0 
c0103de1:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0103de8:	00 
c0103de9:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103df0:	e8 23 ce ff ff       	call   c0100c18 <__panic>

    unsigned int nr_free_store = nr_free;
c0103df5:	a1 ac d0 11 c0       	mov    0xc011d0ac,%eax
c0103dfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103dfd:	c7 05 ac d0 11 c0 00 	movl   $0x0,0xc011d0ac
c0103e04:	00 00 00 

    assert(alloc_page() == NULL);
c0103e07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e0e:	e8 73 0c 00 00       	call   c0104a86 <alloc_pages>
c0103e13:	85 c0                	test   %eax,%eax
c0103e15:	74 24                	je     c0103e3b <basic_check+0x2b5>
c0103e17:	c7 44 24 0c 9a 76 10 	movl   $0xc010769a,0xc(%esp)
c0103e1e:	c0 
c0103e1f:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103e26:	c0 
c0103e27:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103e2e:	00 
c0103e2f:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103e36:	e8 dd cd ff ff       	call   c0100c18 <__panic>

    free_page(p0);
c0103e3b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e42:	00 
c0103e43:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e46:	89 04 24             	mov    %eax,(%esp)
c0103e49:	e8 70 0c 00 00       	call   c0104abe <free_pages>
    free_page(p1);
c0103e4e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e55:	00 
c0103e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e59:	89 04 24             	mov    %eax,(%esp)
c0103e5c:	e8 5d 0c 00 00       	call   c0104abe <free_pages>
    free_page(p2);
c0103e61:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e68:	00 
c0103e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e6c:	89 04 24             	mov    %eax,(%esp)
c0103e6f:	e8 4a 0c 00 00       	call   c0104abe <free_pages>
    assert(nr_free == 3);
c0103e74:	a1 ac d0 11 c0       	mov    0xc011d0ac,%eax
c0103e79:	83 f8 03             	cmp    $0x3,%eax
c0103e7c:	74 24                	je     c0103ea2 <basic_check+0x31c>
c0103e7e:	c7 44 24 0c af 76 10 	movl   $0xc01076af,0xc(%esp)
c0103e85:	c0 
c0103e86:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103e8d:	c0 
c0103e8e:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0103e95:	00 
c0103e96:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103e9d:	e8 76 cd ff ff       	call   c0100c18 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103ea2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ea9:	e8 d8 0b 00 00       	call   c0104a86 <alloc_pages>
c0103eae:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103eb1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103eb5:	75 24                	jne    c0103edb <basic_check+0x355>
c0103eb7:	c7 44 24 0c 75 75 10 	movl   $0xc0107575,0xc(%esp)
c0103ebe:	c0 
c0103ebf:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103ec6:	c0 
c0103ec7:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0103ece:	00 
c0103ecf:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103ed6:	e8 3d cd ff ff       	call   c0100c18 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103edb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ee2:	e8 9f 0b 00 00       	call   c0104a86 <alloc_pages>
c0103ee7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103eea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103eee:	75 24                	jne    c0103f14 <basic_check+0x38e>
c0103ef0:	c7 44 24 0c 91 75 10 	movl   $0xc0107591,0xc(%esp)
c0103ef7:	c0 
c0103ef8:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103eff:	c0 
c0103f00:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0103f07:	00 
c0103f08:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103f0f:	e8 04 cd ff ff       	call   c0100c18 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103f14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f1b:	e8 66 0b 00 00       	call   c0104a86 <alloc_pages>
c0103f20:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103f23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103f27:	75 24                	jne    c0103f4d <basic_check+0x3c7>
c0103f29:	c7 44 24 0c ad 75 10 	movl   $0xc01075ad,0xc(%esp)
c0103f30:	c0 
c0103f31:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103f38:	c0 
c0103f39:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0103f40:	00 
c0103f41:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103f48:	e8 cb cc ff ff       	call   c0100c18 <__panic>

    assert(alloc_page() == NULL);
c0103f4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f54:	e8 2d 0b 00 00       	call   c0104a86 <alloc_pages>
c0103f59:	85 c0                	test   %eax,%eax
c0103f5b:	74 24                	je     c0103f81 <basic_check+0x3fb>
c0103f5d:	c7 44 24 0c 9a 76 10 	movl   $0xc010769a,0xc(%esp)
c0103f64:	c0 
c0103f65:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103f6c:	c0 
c0103f6d:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103f74:	00 
c0103f75:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103f7c:	e8 97 cc ff ff       	call   c0100c18 <__panic>

    free_page(p0);
c0103f81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f88:	00 
c0103f89:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f8c:	89 04 24             	mov    %eax,(%esp)
c0103f8f:	e8 2a 0b 00 00       	call   c0104abe <free_pages>
c0103f94:	c7 45 d8 a4 d0 11 c0 	movl   $0xc011d0a4,-0x28(%ebp)
c0103f9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103f9e:	8b 40 04             	mov    0x4(%eax),%eax
c0103fa1:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103fa4:	0f 94 c0             	sete   %al
c0103fa7:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103faa:	85 c0                	test   %eax,%eax
c0103fac:	74 24                	je     c0103fd2 <basic_check+0x44c>
c0103fae:	c7 44 24 0c bc 76 10 	movl   $0xc01076bc,0xc(%esp)
c0103fb5:	c0 
c0103fb6:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103fbd:	c0 
c0103fbe:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0103fc5:	00 
c0103fc6:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0103fcd:	e8 46 cc ff ff       	call   c0100c18 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103fd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fd9:	e8 a8 0a 00 00       	call   c0104a86 <alloc_pages>
c0103fde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103fe1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103fe4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103fe7:	74 24                	je     c010400d <basic_check+0x487>
c0103fe9:	c7 44 24 0c d4 76 10 	movl   $0xc01076d4,0xc(%esp)
c0103ff0:	c0 
c0103ff1:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0103ff8:	c0 
c0103ff9:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0104000:	00 
c0104001:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0104008:	e8 0b cc ff ff       	call   c0100c18 <__panic>
    assert(alloc_page() == NULL);
c010400d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104014:	e8 6d 0a 00 00       	call   c0104a86 <alloc_pages>
c0104019:	85 c0                	test   %eax,%eax
c010401b:	74 24                	je     c0104041 <basic_check+0x4bb>
c010401d:	c7 44 24 0c 9a 76 10 	movl   $0xc010769a,0xc(%esp)
c0104024:	c0 
c0104025:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c010402c:	c0 
c010402d:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0104034:	00 
c0104035:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c010403c:	e8 d7 cb ff ff       	call   c0100c18 <__panic>

    assert(nr_free == 0);
c0104041:	a1 ac d0 11 c0       	mov    0xc011d0ac,%eax
c0104046:	85 c0                	test   %eax,%eax
c0104048:	74 24                	je     c010406e <basic_check+0x4e8>
c010404a:	c7 44 24 0c ed 76 10 	movl   $0xc01076ed,0xc(%esp)
c0104051:	c0 
c0104052:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0104059:	c0 
c010405a:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0104061:	00 
c0104062:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0104069:	e8 aa cb ff ff       	call   c0100c18 <__panic>
    free_list = free_list_store;
c010406e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104071:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104074:	a3 a4 d0 11 c0       	mov    %eax,0xc011d0a4
c0104079:	89 15 a8 d0 11 c0    	mov    %edx,0xc011d0a8
    nr_free = nr_free_store;
c010407f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104082:	a3 ac d0 11 c0       	mov    %eax,0xc011d0ac

    free_page(p);
c0104087:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010408e:	00 
c010408f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104092:	89 04 24             	mov    %eax,(%esp)
c0104095:	e8 24 0a 00 00       	call   c0104abe <free_pages>
    free_page(p1);
c010409a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01040a1:	00 
c01040a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040a5:	89 04 24             	mov    %eax,(%esp)
c01040a8:	e8 11 0a 00 00       	call   c0104abe <free_pages>
    free_page(p2);
c01040ad:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01040b4:	00 
c01040b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040b8:	89 04 24             	mov    %eax,(%esp)
c01040bb:	e8 fe 09 00 00       	call   c0104abe <free_pages>
}
c01040c0:	c9                   	leave  
c01040c1:	c3                   	ret    

c01040c2 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01040c2:	55                   	push   %ebp
c01040c3:	89 e5                	mov    %esp,%ebp
c01040c5:	53                   	push   %ebx
c01040c6:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c01040cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01040d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01040da:	c7 45 ec a4 d0 11 c0 	movl   $0xc011d0a4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01040e1:	eb 6b                	jmp    c010414e <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c01040e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01040e6:	83 e8 0c             	sub    $0xc,%eax
c01040e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c01040ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040ef:	83 c0 04             	add    $0x4,%eax
c01040f2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01040f9:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01040fc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01040ff:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104102:	0f a3 10             	bt     %edx,(%eax)
c0104105:	19 c0                	sbb    %eax,%eax
c0104107:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c010410a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010410e:	0f 95 c0             	setne  %al
c0104111:	0f b6 c0             	movzbl %al,%eax
c0104114:	85 c0                	test   %eax,%eax
c0104116:	75 24                	jne    c010413c <default_check+0x7a>
c0104118:	c7 44 24 0c fa 76 10 	movl   $0xc01076fa,0xc(%esp)
c010411f:	c0 
c0104120:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0104127:	c0 
c0104128:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c010412f:	00 
c0104130:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0104137:	e8 dc ca ff ff       	call   c0100c18 <__panic>
        count ++, total += p->property;
c010413c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104140:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104143:	8b 50 08             	mov    0x8(%eax),%edx
c0104146:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104149:	01 d0                	add    %edx,%eax
c010414b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010414e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104151:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104154:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104157:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010415a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010415d:	81 7d ec a4 d0 11 c0 	cmpl   $0xc011d0a4,-0x14(%ebp)
c0104164:	0f 85 79 ff ff ff    	jne    c01040e3 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c010416a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c010416d:	e8 7e 09 00 00       	call   c0104af0 <nr_free_pages>
c0104172:	39 c3                	cmp    %eax,%ebx
c0104174:	74 24                	je     c010419a <default_check+0xd8>
c0104176:	c7 44 24 0c 0a 77 10 	movl   $0xc010770a,0xc(%esp)
c010417d:	c0 
c010417e:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0104185:	c0 
c0104186:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c010418d:	00 
c010418e:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0104195:	e8 7e ca ff ff       	call   c0100c18 <__panic>

    basic_check();
c010419a:	e8 e7 f9 ff ff       	call   c0103b86 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010419f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01041a6:	e8 db 08 00 00       	call   c0104a86 <alloc_pages>
c01041ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c01041ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01041b2:	75 24                	jne    c01041d8 <default_check+0x116>
c01041b4:	c7 44 24 0c 23 77 10 	movl   $0xc0107723,0xc(%esp)
c01041bb:	c0 
c01041bc:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c01041c3:	c0 
c01041c4:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c01041cb:	00 
c01041cc:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c01041d3:	e8 40 ca ff ff       	call   c0100c18 <__panic>
    assert(!PageProperty(p0));
c01041d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041db:	83 c0 04             	add    $0x4,%eax
c01041de:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01041e5:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01041e8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01041eb:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01041ee:	0f a3 10             	bt     %edx,(%eax)
c01041f1:	19 c0                	sbb    %eax,%eax
c01041f3:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01041f6:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01041fa:	0f 95 c0             	setne  %al
c01041fd:	0f b6 c0             	movzbl %al,%eax
c0104200:	85 c0                	test   %eax,%eax
c0104202:	74 24                	je     c0104228 <default_check+0x166>
c0104204:	c7 44 24 0c 2e 77 10 	movl   $0xc010772e,0xc(%esp)
c010420b:	c0 
c010420c:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0104213:	c0 
c0104214:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c010421b:	00 
c010421c:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0104223:	e8 f0 c9 ff ff       	call   c0100c18 <__panic>

    list_entry_t free_list_store = free_list;
c0104228:	a1 a4 d0 11 c0       	mov    0xc011d0a4,%eax
c010422d:	8b 15 a8 d0 11 c0    	mov    0xc011d0a8,%edx
c0104233:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104236:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104239:	c7 45 b4 a4 d0 11 c0 	movl   $0xc011d0a4,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104240:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104243:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104246:	89 50 04             	mov    %edx,0x4(%eax)
c0104249:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010424c:	8b 50 04             	mov    0x4(%eax),%edx
c010424f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104252:	89 10                	mov    %edx,(%eax)
c0104254:	c7 45 b0 a4 d0 11 c0 	movl   $0xc011d0a4,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010425b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010425e:	8b 40 04             	mov    0x4(%eax),%eax
c0104261:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0104264:	0f 94 c0             	sete   %al
c0104267:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010426a:	85 c0                	test   %eax,%eax
c010426c:	75 24                	jne    c0104292 <default_check+0x1d0>
c010426e:	c7 44 24 0c 83 76 10 	movl   $0xc0107683,0xc(%esp)
c0104275:	c0 
c0104276:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c010427d:	c0 
c010427e:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0104285:	00 
c0104286:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c010428d:	e8 86 c9 ff ff       	call   c0100c18 <__panic>
    assert(alloc_page() == NULL);
c0104292:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104299:	e8 e8 07 00 00       	call   c0104a86 <alloc_pages>
c010429e:	85 c0                	test   %eax,%eax
c01042a0:	74 24                	je     c01042c6 <default_check+0x204>
c01042a2:	c7 44 24 0c 9a 76 10 	movl   $0xc010769a,0xc(%esp)
c01042a9:	c0 
c01042aa:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c01042b1:	c0 
c01042b2:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c01042b9:	00 
c01042ba:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c01042c1:	e8 52 c9 ff ff       	call   c0100c18 <__panic>

    unsigned int nr_free_store = nr_free;
c01042c6:	a1 ac d0 11 c0       	mov    0xc011d0ac,%eax
c01042cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01042ce:	c7 05 ac d0 11 c0 00 	movl   $0x0,0xc011d0ac
c01042d5:	00 00 00 

    free_pages(p0 + 2, 3);
c01042d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042db:	83 c0 28             	add    $0x28,%eax
c01042de:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01042e5:	00 
c01042e6:	89 04 24             	mov    %eax,(%esp)
c01042e9:	e8 d0 07 00 00       	call   c0104abe <free_pages>
    assert(alloc_pages(4) == NULL);
c01042ee:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01042f5:	e8 8c 07 00 00       	call   c0104a86 <alloc_pages>
c01042fa:	85 c0                	test   %eax,%eax
c01042fc:	74 24                	je     c0104322 <default_check+0x260>
c01042fe:	c7 44 24 0c 40 77 10 	movl   $0xc0107740,0xc(%esp)
c0104305:	c0 
c0104306:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c010430d:	c0 
c010430e:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0104315:	00 
c0104316:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c010431d:	e8 f6 c8 ff ff       	call   c0100c18 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104322:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104325:	83 c0 28             	add    $0x28,%eax
c0104328:	83 c0 04             	add    $0x4,%eax
c010432b:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104332:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104335:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104338:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010433b:	0f a3 10             	bt     %edx,(%eax)
c010433e:	19 c0                	sbb    %eax,%eax
c0104340:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104343:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104347:	0f 95 c0             	setne  %al
c010434a:	0f b6 c0             	movzbl %al,%eax
c010434d:	85 c0                	test   %eax,%eax
c010434f:	74 0e                	je     c010435f <default_check+0x29d>
c0104351:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104354:	83 c0 28             	add    $0x28,%eax
c0104357:	8b 40 08             	mov    0x8(%eax),%eax
c010435a:	83 f8 03             	cmp    $0x3,%eax
c010435d:	74 24                	je     c0104383 <default_check+0x2c1>
c010435f:	c7 44 24 0c 58 77 10 	movl   $0xc0107758,0xc(%esp)
c0104366:	c0 
c0104367:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c010436e:	c0 
c010436f:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0104376:	00 
c0104377:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c010437e:	e8 95 c8 ff ff       	call   c0100c18 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104383:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010438a:	e8 f7 06 00 00       	call   c0104a86 <alloc_pages>
c010438f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104392:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104396:	75 24                	jne    c01043bc <default_check+0x2fa>
c0104398:	c7 44 24 0c 84 77 10 	movl   $0xc0107784,0xc(%esp)
c010439f:	c0 
c01043a0:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c01043a7:	c0 
c01043a8:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01043af:	00 
c01043b0:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c01043b7:	e8 5c c8 ff ff       	call   c0100c18 <__panic>
    assert(alloc_page() == NULL);
c01043bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01043c3:	e8 be 06 00 00       	call   c0104a86 <alloc_pages>
c01043c8:	85 c0                	test   %eax,%eax
c01043ca:	74 24                	je     c01043f0 <default_check+0x32e>
c01043cc:	c7 44 24 0c 9a 76 10 	movl   $0xc010769a,0xc(%esp)
c01043d3:	c0 
c01043d4:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c01043db:	c0 
c01043dc:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01043e3:	00 
c01043e4:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c01043eb:	e8 28 c8 ff ff       	call   c0100c18 <__panic>
    assert(p0 + 2 == p1);
c01043f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043f3:	83 c0 28             	add    $0x28,%eax
c01043f6:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01043f9:	74 24                	je     c010441f <default_check+0x35d>
c01043fb:	c7 44 24 0c a2 77 10 	movl   $0xc01077a2,0xc(%esp)
c0104402:	c0 
c0104403:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c010440a:	c0 
c010440b:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104412:	00 
c0104413:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c010441a:	e8 f9 c7 ff ff       	call   c0100c18 <__panic>

    p2 = p0 + 1;
c010441f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104422:	83 c0 14             	add    $0x14,%eax
c0104425:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0104428:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010442f:	00 
c0104430:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104433:	89 04 24             	mov    %eax,(%esp)
c0104436:	e8 83 06 00 00       	call   c0104abe <free_pages>
    free_pages(p1, 3);
c010443b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104442:	00 
c0104443:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104446:	89 04 24             	mov    %eax,(%esp)
c0104449:	e8 70 06 00 00       	call   c0104abe <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010444e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104451:	83 c0 04             	add    $0x4,%eax
c0104454:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010445b:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010445e:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104461:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104464:	0f a3 10             	bt     %edx,(%eax)
c0104467:	19 c0                	sbb    %eax,%eax
c0104469:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010446c:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104470:	0f 95 c0             	setne  %al
c0104473:	0f b6 c0             	movzbl %al,%eax
c0104476:	85 c0                	test   %eax,%eax
c0104478:	74 0b                	je     c0104485 <default_check+0x3c3>
c010447a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010447d:	8b 40 08             	mov    0x8(%eax),%eax
c0104480:	83 f8 01             	cmp    $0x1,%eax
c0104483:	74 24                	je     c01044a9 <default_check+0x3e7>
c0104485:	c7 44 24 0c b0 77 10 	movl   $0xc01077b0,0xc(%esp)
c010448c:	c0 
c010448d:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0104494:	c0 
c0104495:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c010449c:	00 
c010449d:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c01044a4:	e8 6f c7 ff ff       	call   c0100c18 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01044a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01044ac:	83 c0 04             	add    $0x4,%eax
c01044af:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01044b6:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01044b9:	8b 45 90             	mov    -0x70(%ebp),%eax
c01044bc:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01044bf:	0f a3 10             	bt     %edx,(%eax)
c01044c2:	19 c0                	sbb    %eax,%eax
c01044c4:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01044c7:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01044cb:	0f 95 c0             	setne  %al
c01044ce:	0f b6 c0             	movzbl %al,%eax
c01044d1:	85 c0                	test   %eax,%eax
c01044d3:	74 0b                	je     c01044e0 <default_check+0x41e>
c01044d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01044d8:	8b 40 08             	mov    0x8(%eax),%eax
c01044db:	83 f8 03             	cmp    $0x3,%eax
c01044de:	74 24                	je     c0104504 <default_check+0x442>
c01044e0:	c7 44 24 0c d8 77 10 	movl   $0xc01077d8,0xc(%esp)
c01044e7:	c0 
c01044e8:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c01044ef:	c0 
c01044f0:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01044f7:	00 
c01044f8:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c01044ff:	e8 14 c7 ff ff       	call   c0100c18 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104504:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010450b:	e8 76 05 00 00       	call   c0104a86 <alloc_pages>
c0104510:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104513:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104516:	83 e8 14             	sub    $0x14,%eax
c0104519:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010451c:	74 24                	je     c0104542 <default_check+0x480>
c010451e:	c7 44 24 0c fe 77 10 	movl   $0xc01077fe,0xc(%esp)
c0104525:	c0 
c0104526:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c010452d:	c0 
c010452e:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0104535:	00 
c0104536:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c010453d:	e8 d6 c6 ff ff       	call   c0100c18 <__panic>
    free_page(p0);
c0104542:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104549:	00 
c010454a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010454d:	89 04 24             	mov    %eax,(%esp)
c0104550:	e8 69 05 00 00       	call   c0104abe <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104555:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010455c:	e8 25 05 00 00       	call   c0104a86 <alloc_pages>
c0104561:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104564:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104567:	83 c0 14             	add    $0x14,%eax
c010456a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010456d:	74 24                	je     c0104593 <default_check+0x4d1>
c010456f:	c7 44 24 0c 1c 78 10 	movl   $0xc010781c,0xc(%esp)
c0104576:	c0 
c0104577:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c010457e:	c0 
c010457f:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0104586:	00 
c0104587:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c010458e:	e8 85 c6 ff ff       	call   c0100c18 <__panic>

    free_pages(p0, 2);
c0104593:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010459a:	00 
c010459b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010459e:	89 04 24             	mov    %eax,(%esp)
c01045a1:	e8 18 05 00 00       	call   c0104abe <free_pages>
    free_page(p2);
c01045a6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01045ad:	00 
c01045ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01045b1:	89 04 24             	mov    %eax,(%esp)
c01045b4:	e8 05 05 00 00       	call   c0104abe <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01045b9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01045c0:	e8 c1 04 00 00       	call   c0104a86 <alloc_pages>
c01045c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01045c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01045cc:	75 24                	jne    c01045f2 <default_check+0x530>
c01045ce:	c7 44 24 0c 3c 78 10 	movl   $0xc010783c,0xc(%esp)
c01045d5:	c0 
c01045d6:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c01045dd:	c0 
c01045de:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c01045e5:	00 
c01045e6:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c01045ed:	e8 26 c6 ff ff       	call   c0100c18 <__panic>
    assert(alloc_page() == NULL);
c01045f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01045f9:	e8 88 04 00 00       	call   c0104a86 <alloc_pages>
c01045fe:	85 c0                	test   %eax,%eax
c0104600:	74 24                	je     c0104626 <default_check+0x564>
c0104602:	c7 44 24 0c 9a 76 10 	movl   $0xc010769a,0xc(%esp)
c0104609:	c0 
c010460a:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0104611:	c0 
c0104612:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c0104619:	00 
c010461a:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0104621:	e8 f2 c5 ff ff       	call   c0100c18 <__panic>

    assert(nr_free == 0);
c0104626:	a1 ac d0 11 c0       	mov    0xc011d0ac,%eax
c010462b:	85 c0                	test   %eax,%eax
c010462d:	74 24                	je     c0104653 <default_check+0x591>
c010462f:	c7 44 24 0c ed 76 10 	movl   $0xc01076ed,0xc(%esp)
c0104636:	c0 
c0104637:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c010463e:	c0 
c010463f:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0104646:	00 
c0104647:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c010464e:	e8 c5 c5 ff ff       	call   c0100c18 <__panic>
    nr_free = nr_free_store;
c0104653:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104656:	a3 ac d0 11 c0       	mov    %eax,0xc011d0ac

    free_list = free_list_store;
c010465b:	8b 45 80             	mov    -0x80(%ebp),%eax
c010465e:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104661:	a3 a4 d0 11 c0       	mov    %eax,0xc011d0a4
c0104666:	89 15 a8 d0 11 c0    	mov    %edx,0xc011d0a8
    free_pages(p0, 5);
c010466c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104673:	00 
c0104674:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104677:	89 04 24             	mov    %eax,(%esp)
c010467a:	e8 3f 04 00 00       	call   c0104abe <free_pages>

    le = &free_list;
c010467f:	c7 45 ec a4 d0 11 c0 	movl   $0xc011d0a4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104686:	eb 5b                	jmp    c01046e3 <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
c0104688:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010468b:	8b 40 04             	mov    0x4(%eax),%eax
c010468e:	8b 00                	mov    (%eax),%eax
c0104690:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104693:	75 0d                	jne    c01046a2 <default_check+0x5e0>
c0104695:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104698:	8b 00                	mov    (%eax),%eax
c010469a:	8b 40 04             	mov    0x4(%eax),%eax
c010469d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01046a0:	74 24                	je     c01046c6 <default_check+0x604>
c01046a2:	c7 44 24 0c 5c 78 10 	movl   $0xc010785c,0xc(%esp)
c01046a9:	c0 
c01046aa:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c01046b1:	c0 
c01046b2:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c01046b9:	00 
c01046ba:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c01046c1:	e8 52 c5 ff ff       	call   c0100c18 <__panic>
        struct Page *p = le2page(le, page_link);
c01046c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046c9:	83 e8 0c             	sub    $0xc,%eax
c01046cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01046cf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01046d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01046d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01046d9:	8b 40 08             	mov    0x8(%eax),%eax
c01046dc:	29 c2                	sub    %eax,%edx
c01046de:	89 d0                	mov    %edx,%eax
c01046e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046e6:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01046e9:	8b 45 88             	mov    -0x78(%ebp),%eax
c01046ec:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01046ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01046f2:	81 7d ec a4 d0 11 c0 	cmpl   $0xc011d0a4,-0x14(%ebp)
c01046f9:	75 8d                	jne    c0104688 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01046fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046ff:	74 24                	je     c0104725 <default_check+0x663>
c0104701:	c7 44 24 0c 89 78 10 	movl   $0xc0107889,0xc(%esp)
c0104708:	c0 
c0104709:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c0104710:	c0 
c0104711:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c0104718:	00 
c0104719:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0104720:	e8 f3 c4 ff ff       	call   c0100c18 <__panic>
    assert(total == 0);
c0104725:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104729:	74 24                	je     c010474f <default_check+0x68d>
c010472b:	c7 44 24 0c 94 78 10 	movl   $0xc0107894,0xc(%esp)
c0104732:	c0 
c0104733:	c7 44 24 08 12 75 10 	movl   $0xc0107512,0x8(%esp)
c010473a:	c0 
c010473b:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0104742:	00 
c0104743:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c010474a:	e8 c9 c4 ff ff       	call   c0100c18 <__panic>
}
c010474f:	81 c4 94 00 00 00    	add    $0x94,%esp
c0104755:	5b                   	pop    %ebx
c0104756:	5d                   	pop    %ebp
c0104757:	c3                   	ret    

c0104758 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104758:	55                   	push   %ebp
c0104759:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010475b:	8b 55 08             	mov    0x8(%ebp),%edx
c010475e:	a1 b8 d0 11 c0       	mov    0xc011d0b8,%eax
c0104763:	29 c2                	sub    %eax,%edx
c0104765:	89 d0                	mov    %edx,%eax
c0104767:	c1 f8 02             	sar    $0x2,%eax
c010476a:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0104770:	5d                   	pop    %ebp
c0104771:	c3                   	ret    

c0104772 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104772:	55                   	push   %ebp
c0104773:	89 e5                	mov    %esp,%ebp
c0104775:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104778:	8b 45 08             	mov    0x8(%ebp),%eax
c010477b:	89 04 24             	mov    %eax,(%esp)
c010477e:	e8 d5 ff ff ff       	call   c0104758 <page2ppn>
c0104783:	c1 e0 0c             	shl    $0xc,%eax
}
c0104786:	c9                   	leave  
c0104787:	c3                   	ret    

c0104788 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104788:	55                   	push   %ebp
c0104789:	89 e5                	mov    %esp,%ebp
c010478b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010478e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104791:	c1 e8 0c             	shr    $0xc,%eax
c0104794:	89 c2                	mov    %eax,%edx
c0104796:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c010479b:	39 c2                	cmp    %eax,%edx
c010479d:	72 1c                	jb     c01047bb <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010479f:	c7 44 24 08 d0 78 10 	movl   $0xc01078d0,0x8(%esp)
c01047a6:	c0 
c01047a7:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c01047ae:	00 
c01047af:	c7 04 24 ef 78 10 c0 	movl   $0xc01078ef,(%esp)
c01047b6:	e8 5d c4 ff ff       	call   c0100c18 <__panic>
    }
    return &pages[PPN(pa)];
c01047bb:	8b 0d b8 d0 11 c0    	mov    0xc011d0b8,%ecx
c01047c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01047c4:	c1 e8 0c             	shr    $0xc,%eax
c01047c7:	89 c2                	mov    %eax,%edx
c01047c9:	89 d0                	mov    %edx,%eax
c01047cb:	c1 e0 02             	shl    $0x2,%eax
c01047ce:	01 d0                	add    %edx,%eax
c01047d0:	c1 e0 02             	shl    $0x2,%eax
c01047d3:	01 c8                	add    %ecx,%eax
}
c01047d5:	c9                   	leave  
c01047d6:	c3                   	ret    

c01047d7 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01047d7:	55                   	push   %ebp
c01047d8:	89 e5                	mov    %esp,%ebp
c01047da:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01047dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01047e0:	89 04 24             	mov    %eax,(%esp)
c01047e3:	e8 8a ff ff ff       	call   c0104772 <page2pa>
c01047e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01047eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047ee:	c1 e8 0c             	shr    $0xc,%eax
c01047f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047f4:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c01047f9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01047fc:	72 23                	jb     c0104821 <page2kva+0x4a>
c01047fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104801:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104805:	c7 44 24 08 00 79 10 	movl   $0xc0107900,0x8(%esp)
c010480c:	c0 
c010480d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0104814:	00 
c0104815:	c7 04 24 ef 78 10 c0 	movl   $0xc01078ef,(%esp)
c010481c:	e8 f7 c3 ff ff       	call   c0100c18 <__panic>
c0104821:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104824:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104829:	c9                   	leave  
c010482a:	c3                   	ret    

c010482b <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c010482b:	55                   	push   %ebp
c010482c:	89 e5                	mov    %esp,%ebp
c010482e:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104831:	8b 45 08             	mov    0x8(%ebp),%eax
c0104834:	83 e0 01             	and    $0x1,%eax
c0104837:	85 c0                	test   %eax,%eax
c0104839:	75 1c                	jne    c0104857 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010483b:	c7 44 24 08 24 79 10 	movl   $0xc0107924,0x8(%esp)
c0104842:	c0 
c0104843:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c010484a:	00 
c010484b:	c7 04 24 ef 78 10 c0 	movl   $0xc01078ef,(%esp)
c0104852:	e8 c1 c3 ff ff       	call   c0100c18 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0104857:	8b 45 08             	mov    0x8(%ebp),%eax
c010485a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010485f:	89 04 24             	mov    %eax,(%esp)
c0104862:	e8 21 ff ff ff       	call   c0104788 <pa2page>
}
c0104867:	c9                   	leave  
c0104868:	c3                   	ret    

c0104869 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0104869:	55                   	push   %ebp
c010486a:	89 e5                	mov    %esp,%ebp
c010486c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010486f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104872:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104877:	89 04 24             	mov    %eax,(%esp)
c010487a:	e8 09 ff ff ff       	call   c0104788 <pa2page>
}
c010487f:	c9                   	leave  
c0104880:	c3                   	ret    

c0104881 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0104881:	55                   	push   %ebp
c0104882:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104884:	8b 45 08             	mov    0x8(%ebp),%eax
c0104887:	8b 00                	mov    (%eax),%eax
}
c0104889:	5d                   	pop    %ebp
c010488a:	c3                   	ret    

c010488b <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010488b:	55                   	push   %ebp
c010488c:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010488e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104891:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104894:	89 10                	mov    %edx,(%eax)
}
c0104896:	5d                   	pop    %ebp
c0104897:	c3                   	ret    

c0104898 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104898:	55                   	push   %ebp
c0104899:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010489b:	8b 45 08             	mov    0x8(%ebp),%eax
c010489e:	8b 00                	mov    (%eax),%eax
c01048a0:	8d 50 01             	lea    0x1(%eax),%edx
c01048a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01048a6:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01048a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01048ab:	8b 00                	mov    (%eax),%eax
}
c01048ad:	5d                   	pop    %ebp
c01048ae:	c3                   	ret    

c01048af <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01048af:	55                   	push   %ebp
c01048b0:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01048b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01048b5:	8b 00                	mov    (%eax),%eax
c01048b7:	8d 50 ff             	lea    -0x1(%eax),%edx
c01048ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01048bd:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01048bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01048c2:	8b 00                	mov    (%eax),%eax
}
c01048c4:	5d                   	pop    %ebp
c01048c5:	c3                   	ret    

c01048c6 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01048c6:	55                   	push   %ebp
c01048c7:	89 e5                	mov    %esp,%ebp
c01048c9:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01048cc:	9c                   	pushf  
c01048cd:	58                   	pop    %eax
c01048ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01048d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01048d4:	25 00 02 00 00       	and    $0x200,%eax
c01048d9:	85 c0                	test   %eax,%eax
c01048db:	74 0c                	je     c01048e9 <__intr_save+0x23>
        intr_disable();
c01048dd:	e8 2a cd ff ff       	call   c010160c <intr_disable>
        return 1;
c01048e2:	b8 01 00 00 00       	mov    $0x1,%eax
c01048e7:	eb 05                	jmp    c01048ee <__intr_save+0x28>
    }
    return 0;
c01048e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01048ee:	c9                   	leave  
c01048ef:	c3                   	ret    

c01048f0 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01048f0:	55                   	push   %ebp
c01048f1:	89 e5                	mov    %esp,%ebp
c01048f3:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01048f6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01048fa:	74 05                	je     c0104901 <__intr_restore+0x11>
        intr_enable();
c01048fc:	e8 05 cd ff ff       	call   c0101606 <intr_enable>
    }
}
c0104901:	c9                   	leave  
c0104902:	c3                   	ret    

c0104903 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104903:	55                   	push   %ebp
c0104904:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104906:	8b 45 08             	mov    0x8(%ebp),%eax
c0104909:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c010490c:	b8 23 00 00 00       	mov    $0x23,%eax
c0104911:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0104913:	b8 23 00 00 00       	mov    $0x23,%eax
c0104918:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c010491a:	b8 10 00 00 00       	mov    $0x10,%eax
c010491f:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104921:	b8 10 00 00 00       	mov    $0x10,%eax
c0104926:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104928:	b8 10 00 00 00       	mov    $0x10,%eax
c010492d:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c010492f:	ea 36 49 10 c0 08 00 	ljmp   $0x8,$0xc0104936
}
c0104936:	5d                   	pop    %ebp
c0104937:	c3                   	ret    

c0104938 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104938:	55                   	push   %ebp
c0104939:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c010493b:	8b 45 08             	mov    0x8(%ebp),%eax
c010493e:	a3 44 cf 11 c0       	mov    %eax,0xc011cf44
}
c0104943:	5d                   	pop    %ebp
c0104944:	c3                   	ret    

c0104945 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104945:	55                   	push   %ebp
c0104946:	89 e5                	mov    %esp,%ebp
c0104948:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c010494b:	b8 00 90 11 c0       	mov    $0xc0119000,%eax
c0104950:	89 04 24             	mov    %eax,(%esp)
c0104953:	e8 e0 ff ff ff       	call   c0104938 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104958:	66 c7 05 48 cf 11 c0 	movw   $0x10,0xc011cf48
c010495f:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104961:	66 c7 05 28 9a 11 c0 	movw   $0x68,0xc0119a28
c0104968:	68 00 
c010496a:	b8 40 cf 11 c0       	mov    $0xc011cf40,%eax
c010496f:	66 a3 2a 9a 11 c0    	mov    %ax,0xc0119a2a
c0104975:	b8 40 cf 11 c0       	mov    $0xc011cf40,%eax
c010497a:	c1 e8 10             	shr    $0x10,%eax
c010497d:	a2 2c 9a 11 c0       	mov    %al,0xc0119a2c
c0104982:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0104989:	83 e0 f0             	and    $0xfffffff0,%eax
c010498c:	83 c8 09             	or     $0x9,%eax
c010498f:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0104994:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c010499b:	83 e0 ef             	and    $0xffffffef,%eax
c010499e:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c01049a3:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c01049aa:	83 e0 9f             	and    $0xffffff9f,%eax
c01049ad:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c01049b2:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c01049b9:	83 c8 80             	or     $0xffffff80,%eax
c01049bc:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c01049c1:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c01049c8:	83 e0 f0             	and    $0xfffffff0,%eax
c01049cb:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c01049d0:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c01049d7:	83 e0 ef             	and    $0xffffffef,%eax
c01049da:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c01049df:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c01049e6:	83 e0 df             	and    $0xffffffdf,%eax
c01049e9:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c01049ee:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c01049f5:	83 c8 40             	or     $0x40,%eax
c01049f8:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c01049fd:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0104a04:	83 e0 7f             	and    $0x7f,%eax
c0104a07:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0104a0c:	b8 40 cf 11 c0       	mov    $0xc011cf40,%eax
c0104a11:	c1 e8 18             	shr    $0x18,%eax
c0104a14:	a2 2f 9a 11 c0       	mov    %al,0xc0119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104a19:	c7 04 24 30 9a 11 c0 	movl   $0xc0119a30,(%esp)
c0104a20:	e8 de fe ff ff       	call   c0104903 <lgdt>
c0104a25:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0104a2b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0104a2f:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0104a32:	c9                   	leave  
c0104a33:	c3                   	ret    

c0104a34 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0104a34:	55                   	push   %ebp
c0104a35:	89 e5                	mov    %esp,%ebp
c0104a37:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &buddy_pmm_manager;
c0104a3a:	c7 05 b0 d0 11 c0 f0 	movl   $0xc01074f0,0xc011d0b0
c0104a41:	74 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0104a44:	a1 b0 d0 11 c0       	mov    0xc011d0b0,%eax
c0104a49:	8b 00                	mov    (%eax),%eax
c0104a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a4f:	c7 04 24 50 79 10 c0 	movl   $0xc0107950,(%esp)
c0104a56:	e8 ed b8 ff ff       	call   c0100348 <cprintf>
    pmm_manager->init();
c0104a5b:	a1 b0 d0 11 c0       	mov    0xc011d0b0,%eax
c0104a60:	8b 40 04             	mov    0x4(%eax),%eax
c0104a63:	ff d0                	call   *%eax
}
c0104a65:	c9                   	leave  
c0104a66:	c3                   	ret    

c0104a67 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0104a67:	55                   	push   %ebp
c0104a68:	89 e5                	mov    %esp,%ebp
c0104a6a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0104a6d:	a1 b0 d0 11 c0       	mov    0xc011d0b0,%eax
c0104a72:	8b 40 08             	mov    0x8(%eax),%eax
c0104a75:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104a78:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a7c:	8b 55 08             	mov    0x8(%ebp),%edx
c0104a7f:	89 14 24             	mov    %edx,(%esp)
c0104a82:	ff d0                	call   *%eax
}
c0104a84:	c9                   	leave  
c0104a85:	c3                   	ret    

c0104a86 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0104a86:	55                   	push   %ebp
c0104a87:	89 e5                	mov    %esp,%ebp
c0104a89:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0104a8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0104a93:	e8 2e fe ff ff       	call   c01048c6 <__intr_save>
c0104a98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0104a9b:	a1 b0 d0 11 c0       	mov    0xc011d0b0,%eax
c0104aa0:	8b 40 0c             	mov    0xc(%eax),%eax
c0104aa3:	8b 55 08             	mov    0x8(%ebp),%edx
c0104aa6:	89 14 24             	mov    %edx,(%esp)
c0104aa9:	ff d0                	call   *%eax
c0104aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0104aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ab1:	89 04 24             	mov    %eax,(%esp)
c0104ab4:	e8 37 fe ff ff       	call   c01048f0 <__intr_restore>
    return page;
c0104ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104abc:	c9                   	leave  
c0104abd:	c3                   	ret    

c0104abe <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0104abe:	55                   	push   %ebp
c0104abf:	89 e5                	mov    %esp,%ebp
c0104ac1:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0104ac4:	e8 fd fd ff ff       	call   c01048c6 <__intr_save>
c0104ac9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0104acc:	a1 b0 d0 11 c0       	mov    0xc011d0b0,%eax
c0104ad1:	8b 40 10             	mov    0x10(%eax),%eax
c0104ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104ad7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104adb:	8b 55 08             	mov    0x8(%ebp),%edx
c0104ade:	89 14 24             	mov    %edx,(%esp)
c0104ae1:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0104ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ae6:	89 04 24             	mov    %eax,(%esp)
c0104ae9:	e8 02 fe ff ff       	call   c01048f0 <__intr_restore>
}
c0104aee:	c9                   	leave  
c0104aef:	c3                   	ret    

c0104af0 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0104af0:	55                   	push   %ebp
c0104af1:	89 e5                	mov    %esp,%ebp
c0104af3:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0104af6:	e8 cb fd ff ff       	call   c01048c6 <__intr_save>
c0104afb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0104afe:	a1 b0 d0 11 c0       	mov    0xc011d0b0,%eax
c0104b03:	8b 40 14             	mov    0x14(%eax),%eax
c0104b06:	ff d0                	call   *%eax
c0104b08:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0104b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b0e:	89 04 24             	mov    %eax,(%esp)
c0104b11:	e8 da fd ff ff       	call   c01048f0 <__intr_restore>
    return ret;
c0104b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104b19:	c9                   	leave  
c0104b1a:	c3                   	ret    

c0104b1b <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104b1b:	55                   	push   %ebp
c0104b1c:	89 e5                	mov    %esp,%ebp
c0104b1e:	57                   	push   %edi
c0104b1f:	56                   	push   %esi
c0104b20:	53                   	push   %ebx
c0104b21:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104b27:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0104b2e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104b35:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0104b3c:	c7 04 24 67 79 10 c0 	movl   $0xc0107967,(%esp)
c0104b43:	e8 00 b8 ff ff       	call   c0100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104b48:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104b4f:	e9 15 01 00 00       	jmp    c0104c69 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104b54:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104b57:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b5a:	89 d0                	mov    %edx,%eax
c0104b5c:	c1 e0 02             	shl    $0x2,%eax
c0104b5f:	01 d0                	add    %edx,%eax
c0104b61:	c1 e0 02             	shl    $0x2,%eax
c0104b64:	01 c8                	add    %ecx,%eax
c0104b66:	8b 50 08             	mov    0x8(%eax),%edx
c0104b69:	8b 40 04             	mov    0x4(%eax),%eax
c0104b6c:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104b6f:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0104b72:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104b75:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b78:	89 d0                	mov    %edx,%eax
c0104b7a:	c1 e0 02             	shl    $0x2,%eax
c0104b7d:	01 d0                	add    %edx,%eax
c0104b7f:	c1 e0 02             	shl    $0x2,%eax
c0104b82:	01 c8                	add    %ecx,%eax
c0104b84:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104b87:	8b 58 10             	mov    0x10(%eax),%ebx
c0104b8a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104b8d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104b90:	01 c8                	add    %ecx,%eax
c0104b92:	11 da                	adc    %ebx,%edx
c0104b94:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0104b97:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104b9a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104b9d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ba0:	89 d0                	mov    %edx,%eax
c0104ba2:	c1 e0 02             	shl    $0x2,%eax
c0104ba5:	01 d0                	add    %edx,%eax
c0104ba7:	c1 e0 02             	shl    $0x2,%eax
c0104baa:	01 c8                	add    %ecx,%eax
c0104bac:	83 c0 14             	add    $0x14,%eax
c0104baf:	8b 00                	mov    (%eax),%eax
c0104bb1:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104bb7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104bba:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104bbd:	83 c0 ff             	add    $0xffffffff,%eax
c0104bc0:	83 d2 ff             	adc    $0xffffffff,%edx
c0104bc3:	89 c6                	mov    %eax,%esi
c0104bc5:	89 d7                	mov    %edx,%edi
c0104bc7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104bca:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104bcd:	89 d0                	mov    %edx,%eax
c0104bcf:	c1 e0 02             	shl    $0x2,%eax
c0104bd2:	01 d0                	add    %edx,%eax
c0104bd4:	c1 e0 02             	shl    $0x2,%eax
c0104bd7:	01 c8                	add    %ecx,%eax
c0104bd9:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104bdc:	8b 58 10             	mov    0x10(%eax),%ebx
c0104bdf:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104be5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104be9:	89 74 24 14          	mov    %esi,0x14(%esp)
c0104bed:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0104bf1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104bf4:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104bf7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104bfb:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104bff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104c03:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104c07:	c7 04 24 74 79 10 c0 	movl   $0xc0107974,(%esp)
c0104c0e:	e8 35 b7 ff ff       	call   c0100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104c13:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c16:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c19:	89 d0                	mov    %edx,%eax
c0104c1b:	c1 e0 02             	shl    $0x2,%eax
c0104c1e:	01 d0                	add    %edx,%eax
c0104c20:	c1 e0 02             	shl    $0x2,%eax
c0104c23:	01 c8                	add    %ecx,%eax
c0104c25:	83 c0 14             	add    $0x14,%eax
c0104c28:	8b 00                	mov    (%eax),%eax
c0104c2a:	83 f8 01             	cmp    $0x1,%eax
c0104c2d:	75 36                	jne    c0104c65 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0104c2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104c32:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104c35:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0104c38:	77 2b                	ja     c0104c65 <page_init+0x14a>
c0104c3a:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0104c3d:	72 05                	jb     c0104c44 <page_init+0x129>
c0104c3f:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0104c42:	73 21                	jae    c0104c65 <page_init+0x14a>
c0104c44:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104c48:	77 1b                	ja     c0104c65 <page_init+0x14a>
c0104c4a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104c4e:	72 09                	jb     c0104c59 <page_init+0x13e>
c0104c50:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0104c57:	77 0c                	ja     c0104c65 <page_init+0x14a>
                maxpa = end;
c0104c59:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104c5c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104c5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104c62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104c65:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104c69:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104c6c:	8b 00                	mov    (%eax),%eax
c0104c6e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104c71:	0f 8f dd fe ff ff    	jg     c0104b54 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104c77:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104c7b:	72 1d                	jb     c0104c9a <page_init+0x17f>
c0104c7d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104c81:	77 09                	ja     c0104c8c <page_init+0x171>
c0104c83:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0104c8a:	76 0e                	jbe    c0104c9a <page_init+0x17f>
        maxpa = KMEMSIZE;
c0104c8c:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104c93:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }
    extern char end[];

    npage = maxpa / PGSIZE;
c0104c9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104c9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104ca0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104ca4:	c1 ea 0c             	shr    $0xc,%edx
c0104ca7:	a3 20 cf 11 c0       	mov    %eax,0xc011cf20
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0104cac:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0104cb3:	b8 bc d0 11 c0       	mov    $0xc011d0bc,%eax
c0104cb8:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104cbb:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104cbe:	01 d0                	add    %edx,%eax
c0104cc0:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104cc3:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104cc6:	ba 00 00 00 00       	mov    $0x0,%edx
c0104ccb:	f7 75 ac             	divl   -0x54(%ebp)
c0104cce:	89 d0                	mov    %edx,%eax
c0104cd0:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104cd3:	29 c2                	sub    %eax,%edx
c0104cd5:	89 d0                	mov    %edx,%eax
c0104cd7:	a3 b8 d0 11 c0       	mov    %eax,0xc011d0b8
    for (i = 0; i < npage; i ++) {
c0104cdc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104ce3:	eb 2f                	jmp    c0104d14 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0104ce5:	8b 0d b8 d0 11 c0    	mov    0xc011d0b8,%ecx
c0104ceb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104cee:	89 d0                	mov    %edx,%eax
c0104cf0:	c1 e0 02             	shl    $0x2,%eax
c0104cf3:	01 d0                	add    %edx,%eax
c0104cf5:	c1 e0 02             	shl    $0x2,%eax
c0104cf8:	01 c8                	add    %ecx,%eax
c0104cfa:	83 c0 04             	add    $0x4,%eax
c0104cfd:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0104d04:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104d07:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104d0a:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104d0d:	0f ab 10             	bts    %edx,(%eax)
    }
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
    for (i = 0; i < npage; i ++) {
c0104d10:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104d14:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104d17:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c0104d1c:	39 c2                	cmp    %eax,%edx
c0104d1e:	72 c5                	jb     c0104ce5 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104d20:	8b 15 20 cf 11 c0    	mov    0xc011cf20,%edx
c0104d26:	89 d0                	mov    %edx,%eax
c0104d28:	c1 e0 02             	shl    $0x2,%eax
c0104d2b:	01 d0                	add    %edx,%eax
c0104d2d:	c1 e0 02             	shl    $0x2,%eax
c0104d30:	89 c2                	mov    %eax,%edx
c0104d32:	a1 b8 d0 11 c0       	mov    0xc011d0b8,%eax
c0104d37:	01 d0                	add    %edx,%eax
c0104d39:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0104d3c:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0104d43:	77 23                	ja     c0104d68 <page_init+0x24d>
c0104d45:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104d48:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104d4c:	c7 44 24 08 a4 79 10 	movl   $0xc01079a4,0x8(%esp)
c0104d53:	c0 
c0104d54:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0104d5b:	00 
c0104d5c:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0104d63:	e8 b0 be ff ff       	call   c0100c18 <__panic>
c0104d68:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104d6b:	05 00 00 00 40       	add    $0x40000000,%eax
c0104d70:	89 45 a0             	mov    %eax,-0x60(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0104d73:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104d7a:	e9 74 01 00 00       	jmp    c0104ef3 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104d7f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104d82:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104d85:	89 d0                	mov    %edx,%eax
c0104d87:	c1 e0 02             	shl    $0x2,%eax
c0104d8a:	01 d0                	add    %edx,%eax
c0104d8c:	c1 e0 02             	shl    $0x2,%eax
c0104d8f:	01 c8                	add    %ecx,%eax
c0104d91:	8b 50 08             	mov    0x8(%eax),%edx
c0104d94:	8b 40 04             	mov    0x4(%eax),%eax
c0104d97:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104d9a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104d9d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104da0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104da3:	89 d0                	mov    %edx,%eax
c0104da5:	c1 e0 02             	shl    $0x2,%eax
c0104da8:	01 d0                	add    %edx,%eax
c0104daa:	c1 e0 02             	shl    $0x2,%eax
c0104dad:	01 c8                	add    %ecx,%eax
c0104daf:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104db2:	8b 58 10             	mov    0x10(%eax),%ebx
c0104db5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104db8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104dbb:	01 c8                	add    %ecx,%eax
c0104dbd:	11 da                	adc    %ebx,%edx
c0104dbf:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104dc2:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104dc5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104dc8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104dcb:	89 d0                	mov    %edx,%eax
c0104dcd:	c1 e0 02             	shl    $0x2,%eax
c0104dd0:	01 d0                	add    %edx,%eax
c0104dd2:	c1 e0 02             	shl    $0x2,%eax
c0104dd5:	01 c8                	add    %ecx,%eax
c0104dd7:	83 c0 14             	add    $0x14,%eax
c0104dda:	8b 00                	mov    (%eax),%eax
c0104ddc:	83 f8 01             	cmp    $0x1,%eax
c0104ddf:	0f 85 0a 01 00 00    	jne    c0104eef <page_init+0x3d4>
            if (begin < freemem) {
c0104de5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104de8:	ba 00 00 00 00       	mov    $0x0,%edx
c0104ded:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104df0:	72 17                	jb     c0104e09 <page_init+0x2ee>
c0104df2:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104df5:	77 05                	ja     c0104dfc <page_init+0x2e1>
c0104df7:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0104dfa:	76 0d                	jbe    c0104e09 <page_init+0x2ee>
                begin = freemem;
c0104dfc:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104dff:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104e02:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104e09:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104e0d:	72 1d                	jb     c0104e2c <page_init+0x311>
c0104e0f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104e13:	77 09                	ja     c0104e1e <page_init+0x303>
c0104e15:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0104e1c:	76 0e                	jbe    c0104e2c <page_init+0x311>
                end = KMEMSIZE;
c0104e1e:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104e25:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104e2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104e2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104e32:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104e35:	0f 87 b4 00 00 00    	ja     c0104eef <page_init+0x3d4>
c0104e3b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104e3e:	72 09                	jb     c0104e49 <page_init+0x32e>
c0104e40:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104e43:	0f 83 a6 00 00 00    	jae    c0104eef <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c0104e49:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0104e50:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104e53:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104e56:	01 d0                	add    %edx,%eax
c0104e58:	83 e8 01             	sub    $0x1,%eax
c0104e5b:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104e5e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104e61:	ba 00 00 00 00       	mov    $0x0,%edx
c0104e66:	f7 75 9c             	divl   -0x64(%ebp)
c0104e69:	89 d0                	mov    %edx,%eax
c0104e6b:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104e6e:	29 c2                	sub    %eax,%edx
c0104e70:	89 d0                	mov    %edx,%eax
c0104e72:	ba 00 00 00 00       	mov    $0x0,%edx
c0104e77:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104e7a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104e7d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104e80:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104e83:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104e86:	ba 00 00 00 00       	mov    $0x0,%edx
c0104e8b:	89 c7                	mov    %eax,%edi
c0104e8d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104e93:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104e96:	89 d0                	mov    %edx,%eax
c0104e98:	83 e0 00             	and    $0x0,%eax
c0104e9b:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104e9e:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104ea1:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104ea4:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104ea7:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104eaa:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104ead:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104eb0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104eb3:	77 3a                	ja     c0104eef <page_init+0x3d4>
c0104eb5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104eb8:	72 05                	jb     c0104ebf <page_init+0x3a4>
c0104eba:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104ebd:	73 30                	jae    c0104eef <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104ebf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0104ec2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0104ec5:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104ec8:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104ecb:	29 c8                	sub    %ecx,%eax
c0104ecd:	19 da                	sbb    %ebx,%edx
c0104ecf:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104ed3:	c1 ea 0c             	shr    $0xc,%edx
c0104ed6:	89 c3                	mov    %eax,%ebx
c0104ed8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104edb:	89 04 24             	mov    %eax,(%esp)
c0104ede:	e8 a5 f8 ff ff       	call   c0104788 <pa2page>
c0104ee3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104ee7:	89 04 24             	mov    %eax,(%esp)
c0104eea:	e8 78 fb ff ff       	call   c0104a67 <init_memmap>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
    for (i = 0; i < npage; i ++) {
        SetPageReserved(pages + i);
    }
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
    for (i = 0; i < memmap->nr_map; i ++) {
c0104eef:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104ef3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104ef6:	8b 00                	mov    (%eax),%eax
c0104ef8:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104efb:	0f 8f 7e fe ff ff    	jg     c0104d7f <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0104f01:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104f07:	5b                   	pop    %ebx
c0104f08:	5e                   	pop    %esi
c0104f09:	5f                   	pop    %edi
c0104f0a:	5d                   	pop    %ebp
c0104f0b:	c3                   	ret    

c0104f0c <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104f0c:	55                   	push   %ebp
c0104f0d:	89 e5                	mov    %esp,%ebp
c0104f0f:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104f12:	8b 45 14             	mov    0x14(%ebp),%eax
c0104f15:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104f18:	31 d0                	xor    %edx,%eax
c0104f1a:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104f1f:	85 c0                	test   %eax,%eax
c0104f21:	74 24                	je     c0104f47 <boot_map_segment+0x3b>
c0104f23:	c7 44 24 0c d6 79 10 	movl   $0xc01079d6,0xc(%esp)
c0104f2a:	c0 
c0104f2b:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0104f32:	c0 
c0104f33:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c0104f3a:	00 
c0104f3b:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0104f42:	e8 d1 bc ff ff       	call   c0100c18 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104f47:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f51:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104f56:	89 c2                	mov    %eax,%edx
c0104f58:	8b 45 10             	mov    0x10(%ebp),%eax
c0104f5b:	01 c2                	add    %eax,%edx
c0104f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f60:	01 d0                	add    %edx,%eax
c0104f62:	83 e8 01             	sub    $0x1,%eax
c0104f65:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104f68:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f6b:	ba 00 00 00 00       	mov    $0x0,%edx
c0104f70:	f7 75 f0             	divl   -0x10(%ebp)
c0104f73:	89 d0                	mov    %edx,%eax
c0104f75:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104f78:	29 c2                	sub    %eax,%edx
c0104f7a:	89 d0                	mov    %edx,%eax
c0104f7c:	c1 e8 0c             	shr    $0xc,%eax
c0104f7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104f82:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f85:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104f88:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f90:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104f93:	8b 45 14             	mov    0x14(%ebp),%eax
c0104f96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104f99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f9c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104fa1:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104fa4:	eb 6b                	jmp    c0105011 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104fa6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104fad:	00 
c0104fae:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104fb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fb8:	89 04 24             	mov    %eax,(%esp)
c0104fbb:	e8 82 01 00 00       	call   c0105142 <get_pte>
c0104fc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104fc3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104fc7:	75 24                	jne    c0104fed <boot_map_segment+0xe1>
c0104fc9:	c7 44 24 0c 02 7a 10 	movl   $0xc0107a02,0xc(%esp)
c0104fd0:	c0 
c0104fd1:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0104fd8:	c0 
c0104fd9:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0104fe0:	00 
c0104fe1:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0104fe8:	e8 2b bc ff ff       	call   c0100c18 <__panic>
        *ptep = pa | PTE_P | perm;
c0104fed:	8b 45 18             	mov    0x18(%ebp),%eax
c0104ff0:	8b 55 14             	mov    0x14(%ebp),%edx
c0104ff3:	09 d0                	or     %edx,%eax
c0104ff5:	83 c8 01             	or     $0x1,%eax
c0104ff8:	89 c2                	mov    %eax,%edx
c0104ffa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ffd:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104fff:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105003:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010500a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0105011:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105015:	75 8f                	jne    c0104fa6 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0105017:	c9                   	leave  
c0105018:	c3                   	ret    

c0105019 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0105019:	55                   	push   %ebp
c010501a:	89 e5                	mov    %esp,%ebp
c010501c:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010501f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105026:	e8 5b fa ff ff       	call   c0104a86 <alloc_pages>
c010502b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010502e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105032:	75 1c                	jne    c0105050 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0105034:	c7 44 24 08 0f 7a 10 	movl   $0xc0107a0f,0x8(%esp)
c010503b:	c0 
c010503c:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0105043:	00 
c0105044:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c010504b:	e8 c8 bb ff ff       	call   c0100c18 <__panic>
    }
    return page2kva(p);
c0105050:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105053:	89 04 24             	mov    %eax,(%esp)
c0105056:	e8 7c f7 ff ff       	call   c01047d7 <page2kva>
}
c010505b:	c9                   	leave  
c010505c:	c3                   	ret    

c010505d <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010505d:	55                   	push   %ebp
c010505e:	89 e5                	mov    %esp,%ebp
c0105060:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0105063:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105068:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010506b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105072:	77 23                	ja     c0105097 <pmm_init+0x3a>
c0105074:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105077:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010507b:	c7 44 24 08 a4 79 10 	movl   $0xc01079a4,0x8(%esp)
c0105082:	c0 
c0105083:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c010508a:	00 
c010508b:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105092:	e8 81 bb ff ff       	call   c0100c18 <__panic>
c0105097:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010509a:	05 00 00 00 40       	add    $0x40000000,%eax
c010509f:	a3 b4 d0 11 c0       	mov    %eax,0xc011d0b4
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01050a4:	e8 8b f9 ff ff       	call   c0104a34 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01050a9:	e8 6d fa ff ff       	call   c0104b1b <page_init>
    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01050ae:	e8 db 03 00 00       	call   c010548e <check_alloc_page>

    check_pgdir();
c01050b3:	e8 f4 03 00 00       	call   c01054ac <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01050b8:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01050bd:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01050c3:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01050c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01050cb:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01050d2:	77 23                	ja     c01050f7 <pmm_init+0x9a>
c01050d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01050db:	c7 44 24 08 a4 79 10 	movl   $0xc01079a4,0x8(%esp)
c01050e2:	c0 
c01050e3:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c01050ea:	00 
c01050eb:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01050f2:	e8 21 bb ff ff       	call   c0100c18 <__panic>
c01050f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050fa:	05 00 00 00 40       	add    $0x40000000,%eax
c01050ff:	83 c8 03             	or     $0x3,%eax
c0105102:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0105104:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105109:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0105110:	00 
c0105111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105118:	00 
c0105119:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0105120:	38 
c0105121:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0105128:	c0 
c0105129:	89 04 24             	mov    %eax,(%esp)
c010512c:	e8 db fd ff ff       	call   c0104f0c <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0105131:	e8 0f f8 ff ff       	call   c0104945 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0105136:	e8 0c 0a 00 00       	call   c0105b47 <check_boot_pgdir>

    print_pgdir();
c010513b:	e8 94 0e 00 00       	call   c0105fd4 <print_pgdir>

}
c0105140:	c9                   	leave  
c0105141:	c3                   	ret    

c0105142 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0105142:	55                   	push   %ebp
c0105143:	89 e5                	mov    %esp,%ebp
c0105145:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0105148:	8b 45 0c             	mov    0xc(%ebp),%eax
c010514b:	c1 e8 16             	shr    $0x16,%eax
c010514e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105155:	8b 45 08             	mov    0x8(%ebp),%eax
c0105158:	01 d0                	add    %edx,%eax
c010515a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c010515d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105160:	8b 00                	mov    (%eax),%eax
c0105162:	83 e0 01             	and    $0x1,%eax
c0105165:	85 c0                	test   %eax,%eax
c0105167:	0f 85 af 00 00 00    	jne    c010521c <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c010516d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105171:	74 15                	je     c0105188 <get_pte+0x46>
c0105173:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010517a:	e8 07 f9 ff ff       	call   c0104a86 <alloc_pages>
c010517f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105182:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105186:	75 0a                	jne    c0105192 <get_pte+0x50>
            return NULL;
c0105188:	b8 00 00 00 00       	mov    $0x0,%eax
c010518d:	e9 e6 00 00 00       	jmp    c0105278 <get_pte+0x136>
        }
        set_page_ref(page, 1);
c0105192:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105199:	00 
c010519a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010519d:	89 04 24             	mov    %eax,(%esp)
c01051a0:	e8 e6 f6 ff ff       	call   c010488b <set_page_ref>
        uintptr_t pa = page2pa(page);
c01051a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051a8:	89 04 24             	mov    %eax,(%esp)
c01051ab:	e8 c2 f5 ff ff       	call   c0104772 <page2pa>
c01051b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c01051b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01051b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051bc:	c1 e8 0c             	shr    $0xc,%eax
c01051bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01051c2:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c01051c7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01051ca:	72 23                	jb     c01051ef <get_pte+0xad>
c01051cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01051d3:	c7 44 24 08 00 79 10 	movl   $0xc0107900,0x8(%esp)
c01051da:	c0 
c01051db:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
c01051e2:	00 
c01051e3:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01051ea:	e8 29 ba ff ff       	call   c0100c18 <__panic>
c01051ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051f2:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01051f7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01051fe:	00 
c01051ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105206:	00 
c0105207:	89 04 24             	mov    %eax,(%esp)
c010520a:	e8 e3 18 00 00       	call   c0106af2 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c010520f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105212:	83 c8 07             	or     $0x7,%eax
c0105215:	89 c2                	mov    %eax,%edx
c0105217:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010521a:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010521c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010521f:	8b 00                	mov    (%eax),%eax
c0105221:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105226:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105229:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010522c:	c1 e8 0c             	shr    $0xc,%eax
c010522f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105232:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c0105237:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010523a:	72 23                	jb     c010525f <get_pte+0x11d>
c010523c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010523f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105243:	c7 44 24 08 00 79 10 	movl   $0xc0107900,0x8(%esp)
c010524a:	c0 
c010524b:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
c0105252:	00 
c0105253:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c010525a:	e8 b9 b9 ff ff       	call   c0100c18 <__panic>
c010525f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105262:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105267:	8b 55 0c             	mov    0xc(%ebp),%edx
c010526a:	c1 ea 0c             	shr    $0xc,%edx
c010526d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0105273:	c1 e2 02             	shl    $0x2,%edx
c0105276:	01 d0                	add    %edx,%eax
}
c0105278:	c9                   	leave  
c0105279:	c3                   	ret    

c010527a <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010527a:	55                   	push   %ebp
c010527b:	89 e5                	mov    %esp,%ebp
c010527d:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105280:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105287:	00 
c0105288:	8b 45 0c             	mov    0xc(%ebp),%eax
c010528b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010528f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105292:	89 04 24             	mov    %eax,(%esp)
c0105295:	e8 a8 fe ff ff       	call   c0105142 <get_pte>
c010529a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010529d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01052a1:	74 08                	je     c01052ab <get_page+0x31>
        *ptep_store = ptep;
c01052a3:	8b 45 10             	mov    0x10(%ebp),%eax
c01052a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01052a9:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01052ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01052af:	74 1b                	je     c01052cc <get_page+0x52>
c01052b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052b4:	8b 00                	mov    (%eax),%eax
c01052b6:	83 e0 01             	and    $0x1,%eax
c01052b9:	85 c0                	test   %eax,%eax
c01052bb:	74 0f                	je     c01052cc <get_page+0x52>
        return pte2page(*ptep);
c01052bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052c0:	8b 00                	mov    (%eax),%eax
c01052c2:	89 04 24             	mov    %eax,(%esp)
c01052c5:	e8 61 f5 ff ff       	call   c010482b <pte2page>
c01052ca:	eb 05                	jmp    c01052d1 <get_page+0x57>
    }
    return NULL;
c01052cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01052d1:	c9                   	leave  
c01052d2:	c3                   	ret    

c01052d3 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01052d3:	55                   	push   %ebp
c01052d4:	89 e5                	mov    %esp,%ebp
c01052d6:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c01052d9:	8b 45 10             	mov    0x10(%ebp),%eax
c01052dc:	8b 00                	mov    (%eax),%eax
c01052de:	83 e0 01             	and    $0x1,%eax
c01052e1:	85 c0                	test   %eax,%eax
c01052e3:	74 4d                	je     c0105332 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c01052e5:	8b 45 10             	mov    0x10(%ebp),%eax
c01052e8:	8b 00                	mov    (%eax),%eax
c01052ea:	89 04 24             	mov    %eax,(%esp)
c01052ed:	e8 39 f5 ff ff       	call   c010482b <pte2page>
c01052f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c01052f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052f8:	89 04 24             	mov    %eax,(%esp)
c01052fb:	e8 af f5 ff ff       	call   c01048af <page_ref_dec>
c0105300:	85 c0                	test   %eax,%eax
c0105302:	75 13                	jne    c0105317 <page_remove_pte+0x44>
            free_page(page);
c0105304:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010530b:	00 
c010530c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010530f:	89 04 24             	mov    %eax,(%esp)
c0105312:	e8 a7 f7 ff ff       	call   c0104abe <free_pages>
        }
        *ptep = 0;
c0105317:	8b 45 10             	mov    0x10(%ebp),%eax
c010531a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0105320:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105323:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105327:	8b 45 08             	mov    0x8(%ebp),%eax
c010532a:	89 04 24             	mov    %eax,(%esp)
c010532d:	e8 ff 00 00 00       	call   c0105431 <tlb_invalidate>
    }
}
c0105332:	c9                   	leave  
c0105333:	c3                   	ret    

c0105334 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105334:	55                   	push   %ebp
c0105335:	89 e5                	mov    %esp,%ebp
c0105337:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010533a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105341:	00 
c0105342:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105345:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105349:	8b 45 08             	mov    0x8(%ebp),%eax
c010534c:	89 04 24             	mov    %eax,(%esp)
c010534f:	e8 ee fd ff ff       	call   c0105142 <get_pte>
c0105354:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105357:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010535b:	74 19                	je     c0105376 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010535d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105360:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105364:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105367:	89 44 24 04          	mov    %eax,0x4(%esp)
c010536b:	8b 45 08             	mov    0x8(%ebp),%eax
c010536e:	89 04 24             	mov    %eax,(%esp)
c0105371:	e8 5d ff ff ff       	call   c01052d3 <page_remove_pte>
    }
}
c0105376:	c9                   	leave  
c0105377:	c3                   	ret    

c0105378 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105378:	55                   	push   %ebp
c0105379:	89 e5                	mov    %esp,%ebp
c010537b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010537e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105385:	00 
c0105386:	8b 45 10             	mov    0x10(%ebp),%eax
c0105389:	89 44 24 04          	mov    %eax,0x4(%esp)
c010538d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105390:	89 04 24             	mov    %eax,(%esp)
c0105393:	e8 aa fd ff ff       	call   c0105142 <get_pte>
c0105398:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c010539b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010539f:	75 0a                	jne    c01053ab <page_insert+0x33>
        return -E_NO_MEM;
c01053a1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01053a6:	e9 84 00 00 00       	jmp    c010542f <page_insert+0xb7>
    }
    page_ref_inc(page);
c01053ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053ae:	89 04 24             	mov    %eax,(%esp)
c01053b1:	e8 e2 f4 ff ff       	call   c0104898 <page_ref_inc>
    if (*ptep & PTE_P) {
c01053b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053b9:	8b 00                	mov    (%eax),%eax
c01053bb:	83 e0 01             	and    $0x1,%eax
c01053be:	85 c0                	test   %eax,%eax
c01053c0:	74 3e                	je     c0105400 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01053c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053c5:	8b 00                	mov    (%eax),%eax
c01053c7:	89 04 24             	mov    %eax,(%esp)
c01053ca:	e8 5c f4 ff ff       	call   c010482b <pte2page>
c01053cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01053d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053d5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01053d8:	75 0d                	jne    c01053e7 <page_insert+0x6f>
            page_ref_dec(page);
c01053da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053dd:	89 04 24             	mov    %eax,(%esp)
c01053e0:	e8 ca f4 ff ff       	call   c01048af <page_ref_dec>
c01053e5:	eb 19                	jmp    c0105400 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01053e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053ea:	89 44 24 08          	mov    %eax,0x8(%esp)
c01053ee:	8b 45 10             	mov    0x10(%ebp),%eax
c01053f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01053f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01053f8:	89 04 24             	mov    %eax,(%esp)
c01053fb:	e8 d3 fe ff ff       	call   c01052d3 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105400:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105403:	89 04 24             	mov    %eax,(%esp)
c0105406:	e8 67 f3 ff ff       	call   c0104772 <page2pa>
c010540b:	0b 45 14             	or     0x14(%ebp),%eax
c010540e:	83 c8 01             	or     $0x1,%eax
c0105411:	89 c2                	mov    %eax,%edx
c0105413:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105416:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0105418:	8b 45 10             	mov    0x10(%ebp),%eax
c010541b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010541f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105422:	89 04 24             	mov    %eax,(%esp)
c0105425:	e8 07 00 00 00       	call   c0105431 <tlb_invalidate>
    return 0;
c010542a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010542f:	c9                   	leave  
c0105430:	c3                   	ret    

c0105431 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105431:	55                   	push   %ebp
c0105432:	89 e5                	mov    %esp,%ebp
c0105434:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0105437:	0f 20 d8             	mov    %cr3,%eax
c010543a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010543d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0105440:	89 c2                	mov    %eax,%edx
c0105442:	8b 45 08             	mov    0x8(%ebp),%eax
c0105445:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105448:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010544f:	77 23                	ja     c0105474 <tlb_invalidate+0x43>
c0105451:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105454:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105458:	c7 44 24 08 a4 79 10 	movl   $0xc01079a4,0x8(%esp)
c010545f:	c0 
c0105460:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
c0105467:	00 
c0105468:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c010546f:	e8 a4 b7 ff ff       	call   c0100c18 <__panic>
c0105474:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105477:	05 00 00 00 40       	add    $0x40000000,%eax
c010547c:	39 c2                	cmp    %eax,%edx
c010547e:	75 0c                	jne    c010548c <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0105480:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105483:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105486:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105489:	0f 01 38             	invlpg (%eax)
    }
}
c010548c:	c9                   	leave  
c010548d:	c3                   	ret    

c010548e <check_alloc_page>:

static void
check_alloc_page(void) {
c010548e:	55                   	push   %ebp
c010548f:	89 e5                	mov    %esp,%ebp
c0105491:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0105494:	a1 b0 d0 11 c0       	mov    0xc011d0b0,%eax
c0105499:	8b 40 18             	mov    0x18(%eax),%eax
c010549c:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010549e:	c7 04 24 28 7a 10 c0 	movl   $0xc0107a28,(%esp)
c01054a5:	e8 9e ae ff ff       	call   c0100348 <cprintf>
}
c01054aa:	c9                   	leave  
c01054ab:	c3                   	ret    

c01054ac <check_pgdir>:

static void
check_pgdir(void) {
c01054ac:	55                   	push   %ebp
c01054ad:	89 e5                	mov    %esp,%ebp
c01054af:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01054b2:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c01054b7:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01054bc:	76 24                	jbe    c01054e2 <check_pgdir+0x36>
c01054be:	c7 44 24 0c 47 7a 10 	movl   $0xc0107a47,0xc(%esp)
c01054c5:	c0 
c01054c6:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c01054cd:	c0 
c01054ce:	c7 44 24 04 e0 01 00 	movl   $0x1e0,0x4(%esp)
c01054d5:	00 
c01054d6:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01054dd:	e8 36 b7 ff ff       	call   c0100c18 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01054e2:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01054e7:	85 c0                	test   %eax,%eax
c01054e9:	74 0e                	je     c01054f9 <check_pgdir+0x4d>
c01054eb:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01054f0:	25 ff 0f 00 00       	and    $0xfff,%eax
c01054f5:	85 c0                	test   %eax,%eax
c01054f7:	74 24                	je     c010551d <check_pgdir+0x71>
c01054f9:	c7 44 24 0c 64 7a 10 	movl   $0xc0107a64,0xc(%esp)
c0105500:	c0 
c0105501:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105508:	c0 
c0105509:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c0105510:	00 
c0105511:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105518:	e8 fb b6 ff ff       	call   c0100c18 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010551d:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105522:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105529:	00 
c010552a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105531:	00 
c0105532:	89 04 24             	mov    %eax,(%esp)
c0105535:	e8 40 fd ff ff       	call   c010527a <get_page>
c010553a:	85 c0                	test   %eax,%eax
c010553c:	74 24                	je     c0105562 <check_pgdir+0xb6>
c010553e:	c7 44 24 0c 9c 7a 10 	movl   $0xc0107a9c,0xc(%esp)
c0105545:	c0 
c0105546:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c010554d:	c0 
c010554e:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c0105555:	00 
c0105556:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c010555d:	e8 b6 b6 ff ff       	call   c0100c18 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0105562:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105569:	e8 18 f5 ff ff       	call   c0104a86 <alloc_pages>
c010556e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0105571:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105576:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010557d:	00 
c010557e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105585:	00 
c0105586:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105589:	89 54 24 04          	mov    %edx,0x4(%esp)
c010558d:	89 04 24             	mov    %eax,(%esp)
c0105590:	e8 e3 fd ff ff       	call   c0105378 <page_insert>
c0105595:	85 c0                	test   %eax,%eax
c0105597:	74 24                	je     c01055bd <check_pgdir+0x111>
c0105599:	c7 44 24 0c c4 7a 10 	movl   $0xc0107ac4,0xc(%esp)
c01055a0:	c0 
c01055a1:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c01055a8:	c0 
c01055a9:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c01055b0:	00 
c01055b1:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01055b8:	e8 5b b6 ff ff       	call   c0100c18 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01055bd:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01055c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01055c9:	00 
c01055ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01055d1:	00 
c01055d2:	89 04 24             	mov    %eax,(%esp)
c01055d5:	e8 68 fb ff ff       	call   c0105142 <get_pte>
c01055da:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01055dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01055e1:	75 24                	jne    c0105607 <check_pgdir+0x15b>
c01055e3:	c7 44 24 0c f0 7a 10 	movl   $0xc0107af0,0xc(%esp)
c01055ea:	c0 
c01055eb:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c01055f2:	c0 
c01055f3:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c01055fa:	00 
c01055fb:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105602:	e8 11 b6 ff ff       	call   c0100c18 <__panic>
    assert(pte2page(*ptep) == p1);
c0105607:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010560a:	8b 00                	mov    (%eax),%eax
c010560c:	89 04 24             	mov    %eax,(%esp)
c010560f:	e8 17 f2 ff ff       	call   c010482b <pte2page>
c0105614:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105617:	74 24                	je     c010563d <check_pgdir+0x191>
c0105619:	c7 44 24 0c 1d 7b 10 	movl   $0xc0107b1d,0xc(%esp)
c0105620:	c0 
c0105621:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105628:	c0 
c0105629:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0105630:	00 
c0105631:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105638:	e8 db b5 ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p1) == 1);
c010563d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105640:	89 04 24             	mov    %eax,(%esp)
c0105643:	e8 39 f2 ff ff       	call   c0104881 <page_ref>
c0105648:	83 f8 01             	cmp    $0x1,%eax
c010564b:	74 24                	je     c0105671 <check_pgdir+0x1c5>
c010564d:	c7 44 24 0c 33 7b 10 	movl   $0xc0107b33,0xc(%esp)
c0105654:	c0 
c0105655:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c010565c:	c0 
c010565d:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0105664:	00 
c0105665:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c010566c:	e8 a7 b5 ff ff       	call   c0100c18 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0105671:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105676:	8b 00                	mov    (%eax),%eax
c0105678:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010567d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105680:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105683:	c1 e8 0c             	shr    $0xc,%eax
c0105686:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105689:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c010568e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105691:	72 23                	jb     c01056b6 <check_pgdir+0x20a>
c0105693:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105696:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010569a:	c7 44 24 08 00 79 10 	movl   $0xc0107900,0x8(%esp)
c01056a1:	c0 
c01056a2:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c01056a9:	00 
c01056aa:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01056b1:	e8 62 b5 ff ff       	call   c0100c18 <__panic>
c01056b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056b9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01056be:	83 c0 04             	add    $0x4,%eax
c01056c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01056c4:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01056c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01056d0:	00 
c01056d1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01056d8:	00 
c01056d9:	89 04 24             	mov    %eax,(%esp)
c01056dc:	e8 61 fa ff ff       	call   c0105142 <get_pte>
c01056e1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01056e4:	74 24                	je     c010570a <check_pgdir+0x25e>
c01056e6:	c7 44 24 0c 48 7b 10 	movl   $0xc0107b48,0xc(%esp)
c01056ed:	c0 
c01056ee:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c01056f5:	c0 
c01056f6:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c01056fd:	00 
c01056fe:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105705:	e8 0e b5 ff ff       	call   c0100c18 <__panic>

    p2 = alloc_page();
c010570a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105711:	e8 70 f3 ff ff       	call   c0104a86 <alloc_pages>
c0105716:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0105719:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010571e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0105725:	00 
c0105726:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010572d:	00 
c010572e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105731:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105735:	89 04 24             	mov    %eax,(%esp)
c0105738:	e8 3b fc ff ff       	call   c0105378 <page_insert>
c010573d:	85 c0                	test   %eax,%eax
c010573f:	74 24                	je     c0105765 <check_pgdir+0x2b9>
c0105741:	c7 44 24 0c 70 7b 10 	movl   $0xc0107b70,0xc(%esp)
c0105748:	c0 
c0105749:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105750:	c0 
c0105751:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0105758:	00 
c0105759:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105760:	e8 b3 b4 ff ff       	call   c0100c18 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105765:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010576a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105771:	00 
c0105772:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105779:	00 
c010577a:	89 04 24             	mov    %eax,(%esp)
c010577d:	e8 c0 f9 ff ff       	call   c0105142 <get_pte>
c0105782:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105785:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105789:	75 24                	jne    c01057af <check_pgdir+0x303>
c010578b:	c7 44 24 0c a8 7b 10 	movl   $0xc0107ba8,0xc(%esp)
c0105792:	c0 
c0105793:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c010579a:	c0 
c010579b:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c01057a2:	00 
c01057a3:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01057aa:	e8 69 b4 ff ff       	call   c0100c18 <__panic>
    assert(*ptep & PTE_U);
c01057af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057b2:	8b 00                	mov    (%eax),%eax
c01057b4:	83 e0 04             	and    $0x4,%eax
c01057b7:	85 c0                	test   %eax,%eax
c01057b9:	75 24                	jne    c01057df <check_pgdir+0x333>
c01057bb:	c7 44 24 0c d8 7b 10 	movl   $0xc0107bd8,0xc(%esp)
c01057c2:	c0 
c01057c3:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c01057ca:	c0 
c01057cb:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c01057d2:	00 
c01057d3:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01057da:	e8 39 b4 ff ff       	call   c0100c18 <__panic>
    assert(*ptep & PTE_W);
c01057df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057e2:	8b 00                	mov    (%eax),%eax
c01057e4:	83 e0 02             	and    $0x2,%eax
c01057e7:	85 c0                	test   %eax,%eax
c01057e9:	75 24                	jne    c010580f <check_pgdir+0x363>
c01057eb:	c7 44 24 0c e6 7b 10 	movl   $0xc0107be6,0xc(%esp)
c01057f2:	c0 
c01057f3:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c01057fa:	c0 
c01057fb:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0105802:	00 
c0105803:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c010580a:	e8 09 b4 ff ff       	call   c0100c18 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010580f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105814:	8b 00                	mov    (%eax),%eax
c0105816:	83 e0 04             	and    $0x4,%eax
c0105819:	85 c0                	test   %eax,%eax
c010581b:	75 24                	jne    c0105841 <check_pgdir+0x395>
c010581d:	c7 44 24 0c f4 7b 10 	movl   $0xc0107bf4,0xc(%esp)
c0105824:	c0 
c0105825:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c010582c:	c0 
c010582d:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0105834:	00 
c0105835:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c010583c:	e8 d7 b3 ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p2) == 1);
c0105841:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105844:	89 04 24             	mov    %eax,(%esp)
c0105847:	e8 35 f0 ff ff       	call   c0104881 <page_ref>
c010584c:	83 f8 01             	cmp    $0x1,%eax
c010584f:	74 24                	je     c0105875 <check_pgdir+0x3c9>
c0105851:	c7 44 24 0c 0a 7c 10 	movl   $0xc0107c0a,0xc(%esp)
c0105858:	c0 
c0105859:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105860:	c0 
c0105861:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0105868:	00 
c0105869:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105870:	e8 a3 b3 ff ff       	call   c0100c18 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0105875:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010587a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105881:	00 
c0105882:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105889:	00 
c010588a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010588d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105891:	89 04 24             	mov    %eax,(%esp)
c0105894:	e8 df fa ff ff       	call   c0105378 <page_insert>
c0105899:	85 c0                	test   %eax,%eax
c010589b:	74 24                	je     c01058c1 <check_pgdir+0x415>
c010589d:	c7 44 24 0c 1c 7c 10 	movl   $0xc0107c1c,0xc(%esp)
c01058a4:	c0 
c01058a5:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c01058ac:	c0 
c01058ad:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c01058b4:	00 
c01058b5:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01058bc:	e8 57 b3 ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p1) == 2);
c01058c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058c4:	89 04 24             	mov    %eax,(%esp)
c01058c7:	e8 b5 ef ff ff       	call   c0104881 <page_ref>
c01058cc:	83 f8 02             	cmp    $0x2,%eax
c01058cf:	74 24                	je     c01058f5 <check_pgdir+0x449>
c01058d1:	c7 44 24 0c 48 7c 10 	movl   $0xc0107c48,0xc(%esp)
c01058d8:	c0 
c01058d9:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c01058e0:	c0 
c01058e1:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c01058e8:	00 
c01058e9:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01058f0:	e8 23 b3 ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p2) == 0);
c01058f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058f8:	89 04 24             	mov    %eax,(%esp)
c01058fb:	e8 81 ef ff ff       	call   c0104881 <page_ref>
c0105900:	85 c0                	test   %eax,%eax
c0105902:	74 24                	je     c0105928 <check_pgdir+0x47c>
c0105904:	c7 44 24 0c 5a 7c 10 	movl   $0xc0107c5a,0xc(%esp)
c010590b:	c0 
c010590c:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105913:	c0 
c0105914:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c010591b:	00 
c010591c:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105923:	e8 f0 b2 ff ff       	call   c0100c18 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105928:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010592d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105934:	00 
c0105935:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010593c:	00 
c010593d:	89 04 24             	mov    %eax,(%esp)
c0105940:	e8 fd f7 ff ff       	call   c0105142 <get_pte>
c0105945:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105948:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010594c:	75 24                	jne    c0105972 <check_pgdir+0x4c6>
c010594e:	c7 44 24 0c a8 7b 10 	movl   $0xc0107ba8,0xc(%esp)
c0105955:	c0 
c0105956:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c010595d:	c0 
c010595e:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0105965:	00 
c0105966:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c010596d:	e8 a6 b2 ff ff       	call   c0100c18 <__panic>
    assert(pte2page(*ptep) == p1);
c0105972:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105975:	8b 00                	mov    (%eax),%eax
c0105977:	89 04 24             	mov    %eax,(%esp)
c010597a:	e8 ac ee ff ff       	call   c010482b <pte2page>
c010597f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105982:	74 24                	je     c01059a8 <check_pgdir+0x4fc>
c0105984:	c7 44 24 0c 1d 7b 10 	movl   $0xc0107b1d,0xc(%esp)
c010598b:	c0 
c010598c:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105993:	c0 
c0105994:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c010599b:	00 
c010599c:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01059a3:	e8 70 b2 ff ff       	call   c0100c18 <__panic>
    assert((*ptep & PTE_U) == 0);
c01059a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059ab:	8b 00                	mov    (%eax),%eax
c01059ad:	83 e0 04             	and    $0x4,%eax
c01059b0:	85 c0                	test   %eax,%eax
c01059b2:	74 24                	je     c01059d8 <check_pgdir+0x52c>
c01059b4:	c7 44 24 0c 6c 7c 10 	movl   $0xc0107c6c,0xc(%esp)
c01059bb:	c0 
c01059bc:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c01059c3:	c0 
c01059c4:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c01059cb:	00 
c01059cc:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c01059d3:	e8 40 b2 ff ff       	call   c0100c18 <__panic>

    page_remove(boot_pgdir, 0x0);
c01059d8:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01059dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01059e4:	00 
c01059e5:	89 04 24             	mov    %eax,(%esp)
c01059e8:	e8 47 f9 ff ff       	call   c0105334 <page_remove>
    assert(page_ref(p1) == 1);
c01059ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059f0:	89 04 24             	mov    %eax,(%esp)
c01059f3:	e8 89 ee ff ff       	call   c0104881 <page_ref>
c01059f8:	83 f8 01             	cmp    $0x1,%eax
c01059fb:	74 24                	je     c0105a21 <check_pgdir+0x575>
c01059fd:	c7 44 24 0c 33 7b 10 	movl   $0xc0107b33,0xc(%esp)
c0105a04:	c0 
c0105a05:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105a0c:	c0 
c0105a0d:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0105a14:	00 
c0105a15:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105a1c:	e8 f7 b1 ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p2) == 0);
c0105a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a24:	89 04 24             	mov    %eax,(%esp)
c0105a27:	e8 55 ee ff ff       	call   c0104881 <page_ref>
c0105a2c:	85 c0                	test   %eax,%eax
c0105a2e:	74 24                	je     c0105a54 <check_pgdir+0x5a8>
c0105a30:	c7 44 24 0c 5a 7c 10 	movl   $0xc0107c5a,0xc(%esp)
c0105a37:	c0 
c0105a38:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105a3f:	c0 
c0105a40:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0105a47:	00 
c0105a48:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105a4f:	e8 c4 b1 ff ff       	call   c0100c18 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0105a54:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105a59:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105a60:	00 
c0105a61:	89 04 24             	mov    %eax,(%esp)
c0105a64:	e8 cb f8 ff ff       	call   c0105334 <page_remove>
    assert(page_ref(p1) == 0);
c0105a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a6c:	89 04 24             	mov    %eax,(%esp)
c0105a6f:	e8 0d ee ff ff       	call   c0104881 <page_ref>
c0105a74:	85 c0                	test   %eax,%eax
c0105a76:	74 24                	je     c0105a9c <check_pgdir+0x5f0>
c0105a78:	c7 44 24 0c 81 7c 10 	movl   $0xc0107c81,0xc(%esp)
c0105a7f:	c0 
c0105a80:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105a87:	c0 
c0105a88:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0105a8f:	00 
c0105a90:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105a97:	e8 7c b1 ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p2) == 0);
c0105a9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a9f:	89 04 24             	mov    %eax,(%esp)
c0105aa2:	e8 da ed ff ff       	call   c0104881 <page_ref>
c0105aa7:	85 c0                	test   %eax,%eax
c0105aa9:	74 24                	je     c0105acf <check_pgdir+0x623>
c0105aab:	c7 44 24 0c 5a 7c 10 	movl   $0xc0107c5a,0xc(%esp)
c0105ab2:	c0 
c0105ab3:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105aba:	c0 
c0105abb:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0105ac2:	00 
c0105ac3:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105aca:	e8 49 b1 ff ff       	call   c0100c18 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0105acf:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105ad4:	8b 00                	mov    (%eax),%eax
c0105ad6:	89 04 24             	mov    %eax,(%esp)
c0105ad9:	e8 8b ed ff ff       	call   c0104869 <pde2page>
c0105ade:	89 04 24             	mov    %eax,(%esp)
c0105ae1:	e8 9b ed ff ff       	call   c0104881 <page_ref>
c0105ae6:	83 f8 01             	cmp    $0x1,%eax
c0105ae9:	74 24                	je     c0105b0f <check_pgdir+0x663>
c0105aeb:	c7 44 24 0c 94 7c 10 	movl   $0xc0107c94,0xc(%esp)
c0105af2:	c0 
c0105af3:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105afa:	c0 
c0105afb:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0105b02:	00 
c0105b03:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105b0a:	e8 09 b1 ff ff       	call   c0100c18 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0105b0f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105b14:	8b 00                	mov    (%eax),%eax
c0105b16:	89 04 24             	mov    %eax,(%esp)
c0105b19:	e8 4b ed ff ff       	call   c0104869 <pde2page>
c0105b1e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b25:	00 
c0105b26:	89 04 24             	mov    %eax,(%esp)
c0105b29:	e8 90 ef ff ff       	call   c0104abe <free_pages>
    boot_pgdir[0] = 0;
c0105b2e:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105b33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0105b39:	c7 04 24 bb 7c 10 c0 	movl   $0xc0107cbb,(%esp)
c0105b40:	e8 03 a8 ff ff       	call   c0100348 <cprintf>
}
c0105b45:	c9                   	leave  
c0105b46:	c3                   	ret    

c0105b47 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0105b47:	55                   	push   %ebp
c0105b48:	89 e5                	mov    %esp,%ebp
c0105b4a:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105b4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105b54:	e9 ca 00 00 00       	jmp    c0105c23 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0105b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b62:	c1 e8 0c             	shr    $0xc,%eax
c0105b65:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105b68:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c0105b6d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105b70:	72 23                	jb     c0105b95 <check_boot_pgdir+0x4e>
c0105b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b75:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105b79:	c7 44 24 08 00 79 10 	movl   $0xc0107900,0x8(%esp)
c0105b80:	c0 
c0105b81:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0105b88:	00 
c0105b89:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105b90:	e8 83 b0 ff ff       	call   c0100c18 <__panic>
c0105b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b98:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105b9d:	89 c2                	mov    %eax,%edx
c0105b9f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105ba4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105bab:	00 
c0105bac:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105bb0:	89 04 24             	mov    %eax,(%esp)
c0105bb3:	e8 8a f5 ff ff       	call   c0105142 <get_pte>
c0105bb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105bbb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105bbf:	75 24                	jne    c0105be5 <check_boot_pgdir+0x9e>
c0105bc1:	c7 44 24 0c d8 7c 10 	movl   $0xc0107cd8,0xc(%esp)
c0105bc8:	c0 
c0105bc9:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105bd0:	c0 
c0105bd1:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0105bd8:	00 
c0105bd9:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105be0:	e8 33 b0 ff ff       	call   c0100c18 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105be5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105be8:	8b 00                	mov    (%eax),%eax
c0105bea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105bef:	89 c2                	mov    %eax,%edx
c0105bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bf4:	39 c2                	cmp    %eax,%edx
c0105bf6:	74 24                	je     c0105c1c <check_boot_pgdir+0xd5>
c0105bf8:	c7 44 24 0c 15 7d 10 	movl   $0xc0107d15,0xc(%esp)
c0105bff:	c0 
c0105c00:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105c07:	c0 
c0105c08:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0105c0f:	00 
c0105c10:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105c17:	e8 fc af ff ff       	call   c0100c18 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105c1c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0105c23:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c26:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c0105c2b:	39 c2                	cmp    %eax,%edx
c0105c2d:	0f 82 26 ff ff ff    	jb     c0105b59 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0105c33:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105c38:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105c3d:	8b 00                	mov    (%eax),%eax
c0105c3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105c44:	89 c2                	mov    %eax,%edx
c0105c46:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105c4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105c4e:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0105c55:	77 23                	ja     c0105c7a <check_boot_pgdir+0x133>
c0105c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105c5e:	c7 44 24 08 a4 79 10 	movl   $0xc01079a4,0x8(%esp)
c0105c65:	c0 
c0105c66:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0105c6d:	00 
c0105c6e:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105c75:	e8 9e af ff ff       	call   c0100c18 <__panic>
c0105c7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c7d:	05 00 00 00 40       	add    $0x40000000,%eax
c0105c82:	39 c2                	cmp    %eax,%edx
c0105c84:	74 24                	je     c0105caa <check_boot_pgdir+0x163>
c0105c86:	c7 44 24 0c 2c 7d 10 	movl   $0xc0107d2c,0xc(%esp)
c0105c8d:	c0 
c0105c8e:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105c95:	c0 
c0105c96:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0105c9d:	00 
c0105c9e:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105ca5:	e8 6e af ff ff       	call   c0100c18 <__panic>

    assert(boot_pgdir[0] == 0);
c0105caa:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105caf:	8b 00                	mov    (%eax),%eax
c0105cb1:	85 c0                	test   %eax,%eax
c0105cb3:	74 24                	je     c0105cd9 <check_boot_pgdir+0x192>
c0105cb5:	c7 44 24 0c 60 7d 10 	movl   $0xc0107d60,0xc(%esp)
c0105cbc:	c0 
c0105cbd:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105cc4:	c0 
c0105cc5:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0105ccc:	00 
c0105ccd:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105cd4:	e8 3f af ff ff       	call   c0100c18 <__panic>

    struct Page *p;
    p = alloc_page();
c0105cd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105ce0:	e8 a1 ed ff ff       	call   c0104a86 <alloc_pages>
c0105ce5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105ce8:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105ced:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105cf4:	00 
c0105cf5:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105cfc:	00 
c0105cfd:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105d00:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d04:	89 04 24             	mov    %eax,(%esp)
c0105d07:	e8 6c f6 ff ff       	call   c0105378 <page_insert>
c0105d0c:	85 c0                	test   %eax,%eax
c0105d0e:	74 24                	je     c0105d34 <check_boot_pgdir+0x1ed>
c0105d10:	c7 44 24 0c 74 7d 10 	movl   $0xc0107d74,0xc(%esp)
c0105d17:	c0 
c0105d18:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105d1f:	c0 
c0105d20:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0105d27:	00 
c0105d28:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105d2f:	e8 e4 ae ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p) == 1);
c0105d34:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d37:	89 04 24             	mov    %eax,(%esp)
c0105d3a:	e8 42 eb ff ff       	call   c0104881 <page_ref>
c0105d3f:	83 f8 01             	cmp    $0x1,%eax
c0105d42:	74 24                	je     c0105d68 <check_boot_pgdir+0x221>
c0105d44:	c7 44 24 0c a2 7d 10 	movl   $0xc0107da2,0xc(%esp)
c0105d4b:	c0 
c0105d4c:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105d53:	c0 
c0105d54:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0105d5b:	00 
c0105d5c:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105d63:	e8 b0 ae ff ff       	call   c0100c18 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105d68:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105d6d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105d74:	00 
c0105d75:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105d7c:	00 
c0105d7d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105d80:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d84:	89 04 24             	mov    %eax,(%esp)
c0105d87:	e8 ec f5 ff ff       	call   c0105378 <page_insert>
c0105d8c:	85 c0                	test   %eax,%eax
c0105d8e:	74 24                	je     c0105db4 <check_boot_pgdir+0x26d>
c0105d90:	c7 44 24 0c b4 7d 10 	movl   $0xc0107db4,0xc(%esp)
c0105d97:	c0 
c0105d98:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105d9f:	c0 
c0105da0:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0105da7:	00 
c0105da8:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105daf:	e8 64 ae ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p) == 2);
c0105db4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105db7:	89 04 24             	mov    %eax,(%esp)
c0105dba:	e8 c2 ea ff ff       	call   c0104881 <page_ref>
c0105dbf:	83 f8 02             	cmp    $0x2,%eax
c0105dc2:	74 24                	je     c0105de8 <check_boot_pgdir+0x2a1>
c0105dc4:	c7 44 24 0c eb 7d 10 	movl   $0xc0107deb,0xc(%esp)
c0105dcb:	c0 
c0105dcc:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105dd3:	c0 
c0105dd4:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0105ddb:	00 
c0105ddc:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105de3:	e8 30 ae ff ff       	call   c0100c18 <__panic>

    const char *str = "ucore: Hello world!!";
c0105de8:	c7 45 dc fc 7d 10 c0 	movl   $0xc0107dfc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0105def:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105df2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105df6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105dfd:	e8 19 0a 00 00       	call   c010681b <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105e02:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105e09:	00 
c0105e0a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105e11:	e8 7e 0a 00 00       	call   c0106894 <strcmp>
c0105e16:	85 c0                	test   %eax,%eax
c0105e18:	74 24                	je     c0105e3e <check_boot_pgdir+0x2f7>
c0105e1a:	c7 44 24 0c 14 7e 10 	movl   $0xc0107e14,0xc(%esp)
c0105e21:	c0 
c0105e22:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105e29:	c0 
c0105e2a:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0105e31:	00 
c0105e32:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105e39:	e8 da ad ff ff       	call   c0100c18 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105e3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e41:	89 04 24             	mov    %eax,(%esp)
c0105e44:	e8 8e e9 ff ff       	call   c01047d7 <page2kva>
c0105e49:	05 00 01 00 00       	add    $0x100,%eax
c0105e4e:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105e51:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105e58:	e8 66 09 00 00       	call   c01067c3 <strlen>
c0105e5d:	85 c0                	test   %eax,%eax
c0105e5f:	74 24                	je     c0105e85 <check_boot_pgdir+0x33e>
c0105e61:	c7 44 24 0c 4c 7e 10 	movl   $0xc0107e4c,0xc(%esp)
c0105e68:	c0 
c0105e69:	c7 44 24 08 ed 79 10 	movl   $0xc01079ed,0x8(%esp)
c0105e70:	c0 
c0105e71:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0105e78:	00 
c0105e79:	c7 04 24 c8 79 10 c0 	movl   $0xc01079c8,(%esp)
c0105e80:	e8 93 ad ff ff       	call   c0100c18 <__panic>

    free_page(p);
c0105e85:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105e8c:	00 
c0105e8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e90:	89 04 24             	mov    %eax,(%esp)
c0105e93:	e8 26 ec ff ff       	call   c0104abe <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105e98:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105e9d:	8b 00                	mov    (%eax),%eax
c0105e9f:	89 04 24             	mov    %eax,(%esp)
c0105ea2:	e8 c2 e9 ff ff       	call   c0104869 <pde2page>
c0105ea7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105eae:	00 
c0105eaf:	89 04 24             	mov    %eax,(%esp)
c0105eb2:	e8 07 ec ff ff       	call   c0104abe <free_pages>
    boot_pgdir[0] = 0;
c0105eb7:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105ebc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105ec2:	c7 04 24 70 7e 10 c0 	movl   $0xc0107e70,(%esp)
c0105ec9:	e8 7a a4 ff ff       	call   c0100348 <cprintf>
}
c0105ece:	c9                   	leave  
c0105ecf:	c3                   	ret    

c0105ed0 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105ed0:	55                   	push   %ebp
c0105ed1:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105ed3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed6:	83 e0 04             	and    $0x4,%eax
c0105ed9:	85 c0                	test   %eax,%eax
c0105edb:	74 07                	je     c0105ee4 <perm2str+0x14>
c0105edd:	b8 75 00 00 00       	mov    $0x75,%eax
c0105ee2:	eb 05                	jmp    c0105ee9 <perm2str+0x19>
c0105ee4:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105ee9:	a2 a8 cf 11 c0       	mov    %al,0xc011cfa8
    str[1] = 'r';
c0105eee:	c6 05 a9 cf 11 c0 72 	movb   $0x72,0xc011cfa9
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105ef5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ef8:	83 e0 02             	and    $0x2,%eax
c0105efb:	85 c0                	test   %eax,%eax
c0105efd:	74 07                	je     c0105f06 <perm2str+0x36>
c0105eff:	b8 77 00 00 00       	mov    $0x77,%eax
c0105f04:	eb 05                	jmp    c0105f0b <perm2str+0x3b>
c0105f06:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105f0b:	a2 aa cf 11 c0       	mov    %al,0xc011cfaa
    str[3] = '\0';
c0105f10:	c6 05 ab cf 11 c0 00 	movb   $0x0,0xc011cfab
    return str;
c0105f17:	b8 a8 cf 11 c0       	mov    $0xc011cfa8,%eax
}
c0105f1c:	5d                   	pop    %ebp
c0105f1d:	c3                   	ret    

c0105f1e <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105f1e:	55                   	push   %ebp
c0105f1f:	89 e5                	mov    %esp,%ebp
c0105f21:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105f24:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f27:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f2a:	72 0a                	jb     c0105f36 <get_pgtable_items+0x18>
        return 0;
c0105f2c:	b8 00 00 00 00       	mov    $0x0,%eax
c0105f31:	e9 9c 00 00 00       	jmp    c0105fd2 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105f36:	eb 04                	jmp    c0105f3c <get_pgtable_items+0x1e>
        start ++;
c0105f38:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105f3c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f3f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f42:	73 18                	jae    c0105f5c <get_pgtable_items+0x3e>
c0105f44:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105f4e:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f51:	01 d0                	add    %edx,%eax
c0105f53:	8b 00                	mov    (%eax),%eax
c0105f55:	83 e0 01             	and    $0x1,%eax
c0105f58:	85 c0                	test   %eax,%eax
c0105f5a:	74 dc                	je     c0105f38 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0105f5c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f5f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f62:	73 69                	jae    c0105fcd <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0105f64:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105f68:	74 08                	je     c0105f72 <get_pgtable_items+0x54>
            *left_store = start;
c0105f6a:	8b 45 18             	mov    0x18(%ebp),%eax
c0105f6d:	8b 55 10             	mov    0x10(%ebp),%edx
c0105f70:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105f72:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f75:	8d 50 01             	lea    0x1(%eax),%edx
c0105f78:	89 55 10             	mov    %edx,0x10(%ebp)
c0105f7b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105f82:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f85:	01 d0                	add    %edx,%eax
c0105f87:	8b 00                	mov    (%eax),%eax
c0105f89:	83 e0 07             	and    $0x7,%eax
c0105f8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105f8f:	eb 04                	jmp    c0105f95 <get_pgtable_items+0x77>
            start ++;
c0105f91:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105f95:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f98:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f9b:	73 1d                	jae    c0105fba <get_pgtable_items+0x9c>
c0105f9d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fa0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105fa7:	8b 45 14             	mov    0x14(%ebp),%eax
c0105faa:	01 d0                	add    %edx,%eax
c0105fac:	8b 00                	mov    (%eax),%eax
c0105fae:	83 e0 07             	and    $0x7,%eax
c0105fb1:	89 c2                	mov    %eax,%edx
c0105fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fb6:	39 c2                	cmp    %eax,%edx
c0105fb8:	74 d7                	je     c0105f91 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0105fba:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105fbe:	74 08                	je     c0105fc8 <get_pgtable_items+0xaa>
            *right_store = start;
c0105fc0:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105fc3:	8b 55 10             	mov    0x10(%ebp),%edx
c0105fc6:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105fc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fcb:	eb 05                	jmp    c0105fd2 <get_pgtable_items+0xb4>
    }
    return 0;
c0105fcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105fd2:	c9                   	leave  
c0105fd3:	c3                   	ret    

c0105fd4 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105fd4:	55                   	push   %ebp
c0105fd5:	89 e5                	mov    %esp,%ebp
c0105fd7:	57                   	push   %edi
c0105fd8:	56                   	push   %esi
c0105fd9:	53                   	push   %ebx
c0105fda:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105fdd:	c7 04 24 90 7e 10 c0 	movl   $0xc0107e90,(%esp)
c0105fe4:	e8 5f a3 ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
c0105fe9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105ff0:	e9 fa 00 00 00       	jmp    c01060ef <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105ff5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ff8:	89 04 24             	mov    %eax,(%esp)
c0105ffb:	e8 d0 fe ff ff       	call   c0105ed0 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106000:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106003:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106006:	29 d1                	sub    %edx,%ecx
c0106008:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010600a:	89 d6                	mov    %edx,%esi
c010600c:	c1 e6 16             	shl    $0x16,%esi
c010600f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106012:	89 d3                	mov    %edx,%ebx
c0106014:	c1 e3 16             	shl    $0x16,%ebx
c0106017:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010601a:	89 d1                	mov    %edx,%ecx
c010601c:	c1 e1 16             	shl    $0x16,%ecx
c010601f:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0106022:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106025:	29 d7                	sub    %edx,%edi
c0106027:	89 fa                	mov    %edi,%edx
c0106029:	89 44 24 14          	mov    %eax,0x14(%esp)
c010602d:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106031:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106035:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106039:	89 54 24 04          	mov    %edx,0x4(%esp)
c010603d:	c7 04 24 c1 7e 10 c0 	movl   $0xc0107ec1,(%esp)
c0106044:	e8 ff a2 ff ff       	call   c0100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0106049:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010604c:	c1 e0 0a             	shl    $0xa,%eax
c010604f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106052:	eb 54                	jmp    c01060a8 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106057:	89 04 24             	mov    %eax,(%esp)
c010605a:	e8 71 fe ff ff       	call   c0105ed0 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c010605f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0106062:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106065:	29 d1                	sub    %edx,%ecx
c0106067:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106069:	89 d6                	mov    %edx,%esi
c010606b:	c1 e6 0c             	shl    $0xc,%esi
c010606e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106071:	89 d3                	mov    %edx,%ebx
c0106073:	c1 e3 0c             	shl    $0xc,%ebx
c0106076:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106079:	c1 e2 0c             	shl    $0xc,%edx
c010607c:	89 d1                	mov    %edx,%ecx
c010607e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0106081:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106084:	29 d7                	sub    %edx,%edi
c0106086:	89 fa                	mov    %edi,%edx
c0106088:	89 44 24 14          	mov    %eax,0x14(%esp)
c010608c:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106090:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106094:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106098:	89 54 24 04          	mov    %edx,0x4(%esp)
c010609c:	c7 04 24 e0 7e 10 c0 	movl   $0xc0107ee0,(%esp)
c01060a3:	e8 a0 a2 ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01060a8:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c01060ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01060b0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01060b3:	89 ce                	mov    %ecx,%esi
c01060b5:	c1 e6 0a             	shl    $0xa,%esi
c01060b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01060bb:	89 cb                	mov    %ecx,%ebx
c01060bd:	c1 e3 0a             	shl    $0xa,%ebx
c01060c0:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c01060c3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01060c7:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c01060ca:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01060ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01060d2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060d6:	89 74 24 04          	mov    %esi,0x4(%esp)
c01060da:	89 1c 24             	mov    %ebx,(%esp)
c01060dd:	e8 3c fe ff ff       	call   c0105f1e <get_pgtable_items>
c01060e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01060e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01060e9:	0f 85 65 ff ff ff    	jne    c0106054 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01060ef:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c01060f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01060f7:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c01060fa:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01060fe:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0106101:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106105:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106109:	89 44 24 08          	mov    %eax,0x8(%esp)
c010610d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0106114:	00 
c0106115:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010611c:	e8 fd fd ff ff       	call   c0105f1e <get_pgtable_items>
c0106121:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106124:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106128:	0f 85 c7 fe ff ff    	jne    c0105ff5 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c010612e:	c7 04 24 04 7f 10 c0 	movl   $0xc0107f04,(%esp)
c0106135:	e8 0e a2 ff ff       	call   c0100348 <cprintf>
}
c010613a:	83 c4 4c             	add    $0x4c,%esp
c010613d:	5b                   	pop    %ebx
c010613e:	5e                   	pop    %esi
c010613f:	5f                   	pop    %edi
c0106140:	5d                   	pop    %ebp
c0106141:	c3                   	ret    

c0106142 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0106142:	55                   	push   %ebp
c0106143:	89 e5                	mov    %esp,%ebp
c0106145:	83 ec 58             	sub    $0x58,%esp
c0106148:	8b 45 10             	mov    0x10(%ebp),%eax
c010614b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010614e:	8b 45 14             	mov    0x14(%ebp),%eax
c0106151:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0106154:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106157:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010615a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010615d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0106160:	8b 45 18             	mov    0x18(%ebp),%eax
c0106163:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106166:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106169:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010616c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010616f:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0106172:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106175:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106178:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010617c:	74 1c                	je     c010619a <printnum+0x58>
c010617e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106181:	ba 00 00 00 00       	mov    $0x0,%edx
c0106186:	f7 75 e4             	divl   -0x1c(%ebp)
c0106189:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010618c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010618f:	ba 00 00 00 00       	mov    $0x0,%edx
c0106194:	f7 75 e4             	divl   -0x1c(%ebp)
c0106197:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010619a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010619d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01061a0:	f7 75 e4             	divl   -0x1c(%ebp)
c01061a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01061a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01061a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01061ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01061af:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01061b2:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01061b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01061b8:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01061bb:	8b 45 18             	mov    0x18(%ebp),%eax
c01061be:	ba 00 00 00 00       	mov    $0x0,%edx
c01061c3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01061c6:	77 56                	ja     c010621e <printnum+0xdc>
c01061c8:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01061cb:	72 05                	jb     c01061d2 <printnum+0x90>
c01061cd:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01061d0:	77 4c                	ja     c010621e <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01061d2:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01061d5:	8d 50 ff             	lea    -0x1(%eax),%edx
c01061d8:	8b 45 20             	mov    0x20(%ebp),%eax
c01061db:	89 44 24 18          	mov    %eax,0x18(%esp)
c01061df:	89 54 24 14          	mov    %edx,0x14(%esp)
c01061e3:	8b 45 18             	mov    0x18(%ebp),%eax
c01061e6:	89 44 24 10          	mov    %eax,0x10(%esp)
c01061ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01061ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01061f0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01061f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01061f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0106202:	89 04 24             	mov    %eax,(%esp)
c0106205:	e8 38 ff ff ff       	call   c0106142 <printnum>
c010620a:	eb 1c                	jmp    c0106228 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010620c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010620f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106213:	8b 45 20             	mov    0x20(%ebp),%eax
c0106216:	89 04 24             	mov    %eax,(%esp)
c0106219:	8b 45 08             	mov    0x8(%ebp),%eax
c010621c:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010621e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0106222:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106226:	7f e4                	jg     c010620c <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0106228:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010622b:	05 b8 7f 10 c0       	add    $0xc0107fb8,%eax
c0106230:	0f b6 00             	movzbl (%eax),%eax
c0106233:	0f be c0             	movsbl %al,%eax
c0106236:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106239:	89 54 24 04          	mov    %edx,0x4(%esp)
c010623d:	89 04 24             	mov    %eax,(%esp)
c0106240:	8b 45 08             	mov    0x8(%ebp),%eax
c0106243:	ff d0                	call   *%eax
}
c0106245:	c9                   	leave  
c0106246:	c3                   	ret    

c0106247 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0106247:	55                   	push   %ebp
c0106248:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010624a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010624e:	7e 14                	jle    c0106264 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0106250:	8b 45 08             	mov    0x8(%ebp),%eax
c0106253:	8b 00                	mov    (%eax),%eax
c0106255:	8d 48 08             	lea    0x8(%eax),%ecx
c0106258:	8b 55 08             	mov    0x8(%ebp),%edx
c010625b:	89 0a                	mov    %ecx,(%edx)
c010625d:	8b 50 04             	mov    0x4(%eax),%edx
c0106260:	8b 00                	mov    (%eax),%eax
c0106262:	eb 30                	jmp    c0106294 <getuint+0x4d>
    }
    else if (lflag) {
c0106264:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106268:	74 16                	je     c0106280 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010626a:	8b 45 08             	mov    0x8(%ebp),%eax
c010626d:	8b 00                	mov    (%eax),%eax
c010626f:	8d 48 04             	lea    0x4(%eax),%ecx
c0106272:	8b 55 08             	mov    0x8(%ebp),%edx
c0106275:	89 0a                	mov    %ecx,(%edx)
c0106277:	8b 00                	mov    (%eax),%eax
c0106279:	ba 00 00 00 00       	mov    $0x0,%edx
c010627e:	eb 14                	jmp    c0106294 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0106280:	8b 45 08             	mov    0x8(%ebp),%eax
c0106283:	8b 00                	mov    (%eax),%eax
c0106285:	8d 48 04             	lea    0x4(%eax),%ecx
c0106288:	8b 55 08             	mov    0x8(%ebp),%edx
c010628b:	89 0a                	mov    %ecx,(%edx)
c010628d:	8b 00                	mov    (%eax),%eax
c010628f:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0106294:	5d                   	pop    %ebp
c0106295:	c3                   	ret    

c0106296 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0106296:	55                   	push   %ebp
c0106297:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0106299:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010629d:	7e 14                	jle    c01062b3 <getint+0x1d>
        return va_arg(*ap, long long);
c010629f:	8b 45 08             	mov    0x8(%ebp),%eax
c01062a2:	8b 00                	mov    (%eax),%eax
c01062a4:	8d 48 08             	lea    0x8(%eax),%ecx
c01062a7:	8b 55 08             	mov    0x8(%ebp),%edx
c01062aa:	89 0a                	mov    %ecx,(%edx)
c01062ac:	8b 50 04             	mov    0x4(%eax),%edx
c01062af:	8b 00                	mov    (%eax),%eax
c01062b1:	eb 28                	jmp    c01062db <getint+0x45>
    }
    else if (lflag) {
c01062b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01062b7:	74 12                	je     c01062cb <getint+0x35>
        return va_arg(*ap, long);
c01062b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01062bc:	8b 00                	mov    (%eax),%eax
c01062be:	8d 48 04             	lea    0x4(%eax),%ecx
c01062c1:	8b 55 08             	mov    0x8(%ebp),%edx
c01062c4:	89 0a                	mov    %ecx,(%edx)
c01062c6:	8b 00                	mov    (%eax),%eax
c01062c8:	99                   	cltd   
c01062c9:	eb 10                	jmp    c01062db <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01062cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01062ce:	8b 00                	mov    (%eax),%eax
c01062d0:	8d 48 04             	lea    0x4(%eax),%ecx
c01062d3:	8b 55 08             	mov    0x8(%ebp),%edx
c01062d6:	89 0a                	mov    %ecx,(%edx)
c01062d8:	8b 00                	mov    (%eax),%eax
c01062da:	99                   	cltd   
    }
}
c01062db:	5d                   	pop    %ebp
c01062dc:	c3                   	ret    

c01062dd <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01062dd:	55                   	push   %ebp
c01062de:	89 e5                	mov    %esp,%ebp
c01062e0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01062e3:	8d 45 14             	lea    0x14(%ebp),%eax
c01062e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01062e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01062f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01062f3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01062f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0106301:	89 04 24             	mov    %eax,(%esp)
c0106304:	e8 02 00 00 00       	call   c010630b <vprintfmt>
    va_end(ap);
}
c0106309:	c9                   	leave  
c010630a:	c3                   	ret    

c010630b <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010630b:	55                   	push   %ebp
c010630c:	89 e5                	mov    %esp,%ebp
c010630e:	56                   	push   %esi
c010630f:	53                   	push   %ebx
c0106310:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0106313:	eb 18                	jmp    c010632d <vprintfmt+0x22>
            if (ch == '\0') {
c0106315:	85 db                	test   %ebx,%ebx
c0106317:	75 05                	jne    c010631e <vprintfmt+0x13>
                return;
c0106319:	e9 d1 03 00 00       	jmp    c01066ef <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010631e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106321:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106325:	89 1c 24             	mov    %ebx,(%esp)
c0106328:	8b 45 08             	mov    0x8(%ebp),%eax
c010632b:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010632d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106330:	8d 50 01             	lea    0x1(%eax),%edx
c0106333:	89 55 10             	mov    %edx,0x10(%ebp)
c0106336:	0f b6 00             	movzbl (%eax),%eax
c0106339:	0f b6 d8             	movzbl %al,%ebx
c010633c:	83 fb 25             	cmp    $0x25,%ebx
c010633f:	75 d4                	jne    c0106315 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0106341:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0106345:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010634c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010634f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0106352:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106359:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010635c:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010635f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106362:	8d 50 01             	lea    0x1(%eax),%edx
c0106365:	89 55 10             	mov    %edx,0x10(%ebp)
c0106368:	0f b6 00             	movzbl (%eax),%eax
c010636b:	0f b6 d8             	movzbl %al,%ebx
c010636e:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0106371:	83 f8 55             	cmp    $0x55,%eax
c0106374:	0f 87 44 03 00 00    	ja     c01066be <vprintfmt+0x3b3>
c010637a:	8b 04 85 dc 7f 10 c0 	mov    -0x3fef8024(,%eax,4),%eax
c0106381:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0106383:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0106387:	eb d6                	jmp    c010635f <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0106389:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010638d:	eb d0                	jmp    c010635f <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010638f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0106396:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106399:	89 d0                	mov    %edx,%eax
c010639b:	c1 e0 02             	shl    $0x2,%eax
c010639e:	01 d0                	add    %edx,%eax
c01063a0:	01 c0                	add    %eax,%eax
c01063a2:	01 d8                	add    %ebx,%eax
c01063a4:	83 e8 30             	sub    $0x30,%eax
c01063a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01063aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01063ad:	0f b6 00             	movzbl (%eax),%eax
c01063b0:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01063b3:	83 fb 2f             	cmp    $0x2f,%ebx
c01063b6:	7e 0b                	jle    c01063c3 <vprintfmt+0xb8>
c01063b8:	83 fb 39             	cmp    $0x39,%ebx
c01063bb:	7f 06                	jg     c01063c3 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01063bd:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c01063c1:	eb d3                	jmp    c0106396 <vprintfmt+0x8b>
            goto process_precision;
c01063c3:	eb 33                	jmp    c01063f8 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c01063c5:	8b 45 14             	mov    0x14(%ebp),%eax
c01063c8:	8d 50 04             	lea    0x4(%eax),%edx
c01063cb:	89 55 14             	mov    %edx,0x14(%ebp)
c01063ce:	8b 00                	mov    (%eax),%eax
c01063d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01063d3:	eb 23                	jmp    c01063f8 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c01063d5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01063d9:	79 0c                	jns    c01063e7 <vprintfmt+0xdc>
                width = 0;
c01063db:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01063e2:	e9 78 ff ff ff       	jmp    c010635f <vprintfmt+0x54>
c01063e7:	e9 73 ff ff ff       	jmp    c010635f <vprintfmt+0x54>

        case '#':
            altflag = 1;
c01063ec:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01063f3:	e9 67 ff ff ff       	jmp    c010635f <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c01063f8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01063fc:	79 12                	jns    c0106410 <vprintfmt+0x105>
                width = precision, precision = -1;
c01063fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106401:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106404:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010640b:	e9 4f ff ff ff       	jmp    c010635f <vprintfmt+0x54>
c0106410:	e9 4a ff ff ff       	jmp    c010635f <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0106415:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0106419:	e9 41 ff ff ff       	jmp    c010635f <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010641e:	8b 45 14             	mov    0x14(%ebp),%eax
c0106421:	8d 50 04             	lea    0x4(%eax),%edx
c0106424:	89 55 14             	mov    %edx,0x14(%ebp)
c0106427:	8b 00                	mov    (%eax),%eax
c0106429:	8b 55 0c             	mov    0xc(%ebp),%edx
c010642c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106430:	89 04 24             	mov    %eax,(%esp)
c0106433:	8b 45 08             	mov    0x8(%ebp),%eax
c0106436:	ff d0                	call   *%eax
            break;
c0106438:	e9 ac 02 00 00       	jmp    c01066e9 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010643d:	8b 45 14             	mov    0x14(%ebp),%eax
c0106440:	8d 50 04             	lea    0x4(%eax),%edx
c0106443:	89 55 14             	mov    %edx,0x14(%ebp)
c0106446:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0106448:	85 db                	test   %ebx,%ebx
c010644a:	79 02                	jns    c010644e <vprintfmt+0x143>
                err = -err;
c010644c:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010644e:	83 fb 06             	cmp    $0x6,%ebx
c0106451:	7f 0b                	jg     c010645e <vprintfmt+0x153>
c0106453:	8b 34 9d 9c 7f 10 c0 	mov    -0x3fef8064(,%ebx,4),%esi
c010645a:	85 f6                	test   %esi,%esi
c010645c:	75 23                	jne    c0106481 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010645e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106462:	c7 44 24 08 c9 7f 10 	movl   $0xc0107fc9,0x8(%esp)
c0106469:	c0 
c010646a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010646d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106471:	8b 45 08             	mov    0x8(%ebp),%eax
c0106474:	89 04 24             	mov    %eax,(%esp)
c0106477:	e8 61 fe ff ff       	call   c01062dd <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010647c:	e9 68 02 00 00       	jmp    c01066e9 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0106481:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106485:	c7 44 24 08 d2 7f 10 	movl   $0xc0107fd2,0x8(%esp)
c010648c:	c0 
c010648d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106490:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106494:	8b 45 08             	mov    0x8(%ebp),%eax
c0106497:	89 04 24             	mov    %eax,(%esp)
c010649a:	e8 3e fe ff ff       	call   c01062dd <printfmt>
            }
            break;
c010649f:	e9 45 02 00 00       	jmp    c01066e9 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01064a4:	8b 45 14             	mov    0x14(%ebp),%eax
c01064a7:	8d 50 04             	lea    0x4(%eax),%edx
c01064aa:	89 55 14             	mov    %edx,0x14(%ebp)
c01064ad:	8b 30                	mov    (%eax),%esi
c01064af:	85 f6                	test   %esi,%esi
c01064b1:	75 05                	jne    c01064b8 <vprintfmt+0x1ad>
                p = "(null)";
c01064b3:	be d5 7f 10 c0       	mov    $0xc0107fd5,%esi
            }
            if (width > 0 && padc != '-') {
c01064b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01064bc:	7e 3e                	jle    c01064fc <vprintfmt+0x1f1>
c01064be:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01064c2:	74 38                	je     c01064fc <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01064c4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c01064c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01064ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01064ce:	89 34 24             	mov    %esi,(%esp)
c01064d1:	e8 15 03 00 00       	call   c01067eb <strnlen>
c01064d6:	29 c3                	sub    %eax,%ebx
c01064d8:	89 d8                	mov    %ebx,%eax
c01064da:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01064dd:	eb 17                	jmp    c01064f6 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c01064df:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01064e3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01064e6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01064ea:	89 04 24             	mov    %eax,(%esp)
c01064ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01064f0:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c01064f2:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01064f6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01064fa:	7f e3                	jg     c01064df <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01064fc:	eb 38                	jmp    c0106536 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c01064fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106502:	74 1f                	je     c0106523 <vprintfmt+0x218>
c0106504:	83 fb 1f             	cmp    $0x1f,%ebx
c0106507:	7e 05                	jle    c010650e <vprintfmt+0x203>
c0106509:	83 fb 7e             	cmp    $0x7e,%ebx
c010650c:	7e 15                	jle    c0106523 <vprintfmt+0x218>
                    putch('?', putdat);
c010650e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106511:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106515:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010651c:	8b 45 08             	mov    0x8(%ebp),%eax
c010651f:	ff d0                	call   *%eax
c0106521:	eb 0f                	jmp    c0106532 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0106523:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106526:	89 44 24 04          	mov    %eax,0x4(%esp)
c010652a:	89 1c 24             	mov    %ebx,(%esp)
c010652d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106530:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106532:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0106536:	89 f0                	mov    %esi,%eax
c0106538:	8d 70 01             	lea    0x1(%eax),%esi
c010653b:	0f b6 00             	movzbl (%eax),%eax
c010653e:	0f be d8             	movsbl %al,%ebx
c0106541:	85 db                	test   %ebx,%ebx
c0106543:	74 10                	je     c0106555 <vprintfmt+0x24a>
c0106545:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106549:	78 b3                	js     c01064fe <vprintfmt+0x1f3>
c010654b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010654f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106553:	79 a9                	jns    c01064fe <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0106555:	eb 17                	jmp    c010656e <vprintfmt+0x263>
                putch(' ', putdat);
c0106557:	8b 45 0c             	mov    0xc(%ebp),%eax
c010655a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010655e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0106565:	8b 45 08             	mov    0x8(%ebp),%eax
c0106568:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010656a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010656e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106572:	7f e3                	jg     c0106557 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c0106574:	e9 70 01 00 00       	jmp    c01066e9 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0106579:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010657c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106580:	8d 45 14             	lea    0x14(%ebp),%eax
c0106583:	89 04 24             	mov    %eax,(%esp)
c0106586:	e8 0b fd ff ff       	call   c0106296 <getint>
c010658b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010658e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0106591:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106594:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106597:	85 d2                	test   %edx,%edx
c0106599:	79 26                	jns    c01065c1 <vprintfmt+0x2b6>
                putch('-', putdat);
c010659b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010659e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01065a2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01065a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01065ac:	ff d0                	call   *%eax
                num = -(long long)num;
c01065ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01065b4:	f7 d8                	neg    %eax
c01065b6:	83 d2 00             	adc    $0x0,%edx
c01065b9:	f7 da                	neg    %edx
c01065bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01065be:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01065c1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01065c8:	e9 a8 00 00 00       	jmp    c0106675 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01065cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01065d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01065d4:	8d 45 14             	lea    0x14(%ebp),%eax
c01065d7:	89 04 24             	mov    %eax,(%esp)
c01065da:	e8 68 fc ff ff       	call   c0106247 <getuint>
c01065df:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01065e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01065e5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01065ec:	e9 84 00 00 00       	jmp    c0106675 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01065f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01065f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01065f8:	8d 45 14             	lea    0x14(%ebp),%eax
c01065fb:	89 04 24             	mov    %eax,(%esp)
c01065fe:	e8 44 fc ff ff       	call   c0106247 <getuint>
c0106603:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106606:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0106609:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0106610:	eb 63                	jmp    c0106675 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0106612:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106615:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106619:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0106620:	8b 45 08             	mov    0x8(%ebp),%eax
c0106623:	ff d0                	call   *%eax
            putch('x', putdat);
c0106625:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106628:	89 44 24 04          	mov    %eax,0x4(%esp)
c010662c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0106633:	8b 45 08             	mov    0x8(%ebp),%eax
c0106636:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0106638:	8b 45 14             	mov    0x14(%ebp),%eax
c010663b:	8d 50 04             	lea    0x4(%eax),%edx
c010663e:	89 55 14             	mov    %edx,0x14(%ebp)
c0106641:	8b 00                	mov    (%eax),%eax
c0106643:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106646:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010664d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0106654:	eb 1f                	jmp    c0106675 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0106656:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106659:	89 44 24 04          	mov    %eax,0x4(%esp)
c010665d:	8d 45 14             	lea    0x14(%ebp),%eax
c0106660:	89 04 24             	mov    %eax,(%esp)
c0106663:	e8 df fb ff ff       	call   c0106247 <getuint>
c0106668:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010666b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010666e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0106675:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0106679:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010667c:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106680:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106683:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106687:	89 44 24 10          	mov    %eax,0x10(%esp)
c010668b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010668e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106691:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106695:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106699:	8b 45 0c             	mov    0xc(%ebp),%eax
c010669c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01066a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01066a3:	89 04 24             	mov    %eax,(%esp)
c01066a6:	e8 97 fa ff ff       	call   c0106142 <printnum>
            break;
c01066ab:	eb 3c                	jmp    c01066e9 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01066ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01066b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01066b4:	89 1c 24             	mov    %ebx,(%esp)
c01066b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01066ba:	ff d0                	call   *%eax
            break;
c01066bc:	eb 2b                	jmp    c01066e9 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01066be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01066c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01066c5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01066cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01066cf:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01066d1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01066d5:	eb 04                	jmp    c01066db <vprintfmt+0x3d0>
c01066d7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01066db:	8b 45 10             	mov    0x10(%ebp),%eax
c01066de:	83 e8 01             	sub    $0x1,%eax
c01066e1:	0f b6 00             	movzbl (%eax),%eax
c01066e4:	3c 25                	cmp    $0x25,%al
c01066e6:	75 ef                	jne    c01066d7 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c01066e8:	90                   	nop
        }
    }
c01066e9:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01066ea:	e9 3e fc ff ff       	jmp    c010632d <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c01066ef:	83 c4 40             	add    $0x40,%esp
c01066f2:	5b                   	pop    %ebx
c01066f3:	5e                   	pop    %esi
c01066f4:	5d                   	pop    %ebp
c01066f5:	c3                   	ret    

c01066f6 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01066f6:	55                   	push   %ebp
c01066f7:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01066f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01066fc:	8b 40 08             	mov    0x8(%eax),%eax
c01066ff:	8d 50 01             	lea    0x1(%eax),%edx
c0106702:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106705:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106708:	8b 45 0c             	mov    0xc(%ebp),%eax
c010670b:	8b 10                	mov    (%eax),%edx
c010670d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106710:	8b 40 04             	mov    0x4(%eax),%eax
c0106713:	39 c2                	cmp    %eax,%edx
c0106715:	73 12                	jae    c0106729 <sprintputch+0x33>
        *b->buf ++ = ch;
c0106717:	8b 45 0c             	mov    0xc(%ebp),%eax
c010671a:	8b 00                	mov    (%eax),%eax
c010671c:	8d 48 01             	lea    0x1(%eax),%ecx
c010671f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106722:	89 0a                	mov    %ecx,(%edx)
c0106724:	8b 55 08             	mov    0x8(%ebp),%edx
c0106727:	88 10                	mov    %dl,(%eax)
    }
}
c0106729:	5d                   	pop    %ebp
c010672a:	c3                   	ret    

c010672b <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010672b:	55                   	push   %ebp
c010672c:	89 e5                	mov    %esp,%ebp
c010672e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106731:	8d 45 14             	lea    0x14(%ebp),%eax
c0106734:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106737:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010673a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010673e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106741:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106745:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106748:	89 44 24 04          	mov    %eax,0x4(%esp)
c010674c:	8b 45 08             	mov    0x8(%ebp),%eax
c010674f:	89 04 24             	mov    %eax,(%esp)
c0106752:	e8 08 00 00 00       	call   c010675f <vsnprintf>
c0106757:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010675a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010675d:	c9                   	leave  
c010675e:	c3                   	ret    

c010675f <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010675f:	55                   	push   %ebp
c0106760:	89 e5                	mov    %esp,%ebp
c0106762:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106765:	8b 45 08             	mov    0x8(%ebp),%eax
c0106768:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010676b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010676e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106771:	8b 45 08             	mov    0x8(%ebp),%eax
c0106774:	01 d0                	add    %edx,%eax
c0106776:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106779:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106780:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106784:	74 0a                	je     c0106790 <vsnprintf+0x31>
c0106786:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106789:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010678c:	39 c2                	cmp    %eax,%edx
c010678e:	76 07                	jbe    c0106797 <vsnprintf+0x38>
        return -E_INVAL;
c0106790:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0106795:	eb 2a                	jmp    c01067c1 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0106797:	8b 45 14             	mov    0x14(%ebp),%eax
c010679a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010679e:	8b 45 10             	mov    0x10(%ebp),%eax
c01067a1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01067a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01067a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01067ac:	c7 04 24 f6 66 10 c0 	movl   $0xc01066f6,(%esp)
c01067b3:	e8 53 fb ff ff       	call   c010630b <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01067b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01067bb:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01067be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01067c1:	c9                   	leave  
c01067c2:	c3                   	ret    

c01067c3 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01067c3:	55                   	push   %ebp
c01067c4:	89 e5                	mov    %esp,%ebp
c01067c6:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01067c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01067d0:	eb 04                	jmp    c01067d6 <strlen+0x13>
        cnt ++;
c01067d2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c01067d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01067d9:	8d 50 01             	lea    0x1(%eax),%edx
c01067dc:	89 55 08             	mov    %edx,0x8(%ebp)
c01067df:	0f b6 00             	movzbl (%eax),%eax
c01067e2:	84 c0                	test   %al,%al
c01067e4:	75 ec                	jne    c01067d2 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c01067e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01067e9:	c9                   	leave  
c01067ea:	c3                   	ret    

c01067eb <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01067eb:	55                   	push   %ebp
c01067ec:	89 e5                	mov    %esp,%ebp
c01067ee:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01067f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01067f8:	eb 04                	jmp    c01067fe <strnlen+0x13>
        cnt ++;
c01067fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c01067fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106801:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106804:	73 10                	jae    c0106816 <strnlen+0x2b>
c0106806:	8b 45 08             	mov    0x8(%ebp),%eax
c0106809:	8d 50 01             	lea    0x1(%eax),%edx
c010680c:	89 55 08             	mov    %edx,0x8(%ebp)
c010680f:	0f b6 00             	movzbl (%eax),%eax
c0106812:	84 c0                	test   %al,%al
c0106814:	75 e4                	jne    c01067fa <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0106816:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106819:	c9                   	leave  
c010681a:	c3                   	ret    

c010681b <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010681b:	55                   	push   %ebp
c010681c:	89 e5                	mov    %esp,%ebp
c010681e:	57                   	push   %edi
c010681f:	56                   	push   %esi
c0106820:	83 ec 20             	sub    $0x20,%esp
c0106823:	8b 45 08             	mov    0x8(%ebp),%eax
c0106826:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106829:	8b 45 0c             	mov    0xc(%ebp),%eax
c010682c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010682f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106832:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106835:	89 d1                	mov    %edx,%ecx
c0106837:	89 c2                	mov    %eax,%edx
c0106839:	89 ce                	mov    %ecx,%esi
c010683b:	89 d7                	mov    %edx,%edi
c010683d:	ac                   	lods   %ds:(%esi),%al
c010683e:	aa                   	stos   %al,%es:(%edi)
c010683f:	84 c0                	test   %al,%al
c0106841:	75 fa                	jne    c010683d <strcpy+0x22>
c0106843:	89 fa                	mov    %edi,%edx
c0106845:	89 f1                	mov    %esi,%ecx
c0106847:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010684a:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010684d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0106850:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0106853:	83 c4 20             	add    $0x20,%esp
c0106856:	5e                   	pop    %esi
c0106857:	5f                   	pop    %edi
c0106858:	5d                   	pop    %ebp
c0106859:	c3                   	ret    

c010685a <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010685a:	55                   	push   %ebp
c010685b:	89 e5                	mov    %esp,%ebp
c010685d:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0106860:	8b 45 08             	mov    0x8(%ebp),%eax
c0106863:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0106866:	eb 21                	jmp    c0106889 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0106868:	8b 45 0c             	mov    0xc(%ebp),%eax
c010686b:	0f b6 10             	movzbl (%eax),%edx
c010686e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106871:	88 10                	mov    %dl,(%eax)
c0106873:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106876:	0f b6 00             	movzbl (%eax),%eax
c0106879:	84 c0                	test   %al,%al
c010687b:	74 04                	je     c0106881 <strncpy+0x27>
            src ++;
c010687d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0106881:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0106885:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0106889:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010688d:	75 d9                	jne    c0106868 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010688f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106892:	c9                   	leave  
c0106893:	c3                   	ret    

c0106894 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0106894:	55                   	push   %ebp
c0106895:	89 e5                	mov    %esp,%ebp
c0106897:	57                   	push   %edi
c0106898:	56                   	push   %esi
c0106899:	83 ec 20             	sub    $0x20,%esp
c010689c:	8b 45 08             	mov    0x8(%ebp),%eax
c010689f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01068a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c01068a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01068ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068ae:	89 d1                	mov    %edx,%ecx
c01068b0:	89 c2                	mov    %eax,%edx
c01068b2:	89 ce                	mov    %ecx,%esi
c01068b4:	89 d7                	mov    %edx,%edi
c01068b6:	ac                   	lods   %ds:(%esi),%al
c01068b7:	ae                   	scas   %es:(%edi),%al
c01068b8:	75 08                	jne    c01068c2 <strcmp+0x2e>
c01068ba:	84 c0                	test   %al,%al
c01068bc:	75 f8                	jne    c01068b6 <strcmp+0x22>
c01068be:	31 c0                	xor    %eax,%eax
c01068c0:	eb 04                	jmp    c01068c6 <strcmp+0x32>
c01068c2:	19 c0                	sbb    %eax,%eax
c01068c4:	0c 01                	or     $0x1,%al
c01068c6:	89 fa                	mov    %edi,%edx
c01068c8:	89 f1                	mov    %esi,%ecx
c01068ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01068cd:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01068d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c01068d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01068d6:	83 c4 20             	add    $0x20,%esp
c01068d9:	5e                   	pop    %esi
c01068da:	5f                   	pop    %edi
c01068db:	5d                   	pop    %ebp
c01068dc:	c3                   	ret    

c01068dd <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01068dd:	55                   	push   %ebp
c01068de:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01068e0:	eb 0c                	jmp    c01068ee <strncmp+0x11>
        n --, s1 ++, s2 ++;
c01068e2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01068e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01068ea:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01068ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01068f2:	74 1a                	je     c010690e <strncmp+0x31>
c01068f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01068f7:	0f b6 00             	movzbl (%eax),%eax
c01068fa:	84 c0                	test   %al,%al
c01068fc:	74 10                	je     c010690e <strncmp+0x31>
c01068fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0106901:	0f b6 10             	movzbl (%eax),%edx
c0106904:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106907:	0f b6 00             	movzbl (%eax),%eax
c010690a:	38 c2                	cmp    %al,%dl
c010690c:	74 d4                	je     c01068e2 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010690e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106912:	74 18                	je     c010692c <strncmp+0x4f>
c0106914:	8b 45 08             	mov    0x8(%ebp),%eax
c0106917:	0f b6 00             	movzbl (%eax),%eax
c010691a:	0f b6 d0             	movzbl %al,%edx
c010691d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106920:	0f b6 00             	movzbl (%eax),%eax
c0106923:	0f b6 c0             	movzbl %al,%eax
c0106926:	29 c2                	sub    %eax,%edx
c0106928:	89 d0                	mov    %edx,%eax
c010692a:	eb 05                	jmp    c0106931 <strncmp+0x54>
c010692c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106931:	5d                   	pop    %ebp
c0106932:	c3                   	ret    

c0106933 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0106933:	55                   	push   %ebp
c0106934:	89 e5                	mov    %esp,%ebp
c0106936:	83 ec 04             	sub    $0x4,%esp
c0106939:	8b 45 0c             	mov    0xc(%ebp),%eax
c010693c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010693f:	eb 14                	jmp    c0106955 <strchr+0x22>
        if (*s == c) {
c0106941:	8b 45 08             	mov    0x8(%ebp),%eax
c0106944:	0f b6 00             	movzbl (%eax),%eax
c0106947:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010694a:	75 05                	jne    c0106951 <strchr+0x1e>
            return (char *)s;
c010694c:	8b 45 08             	mov    0x8(%ebp),%eax
c010694f:	eb 13                	jmp    c0106964 <strchr+0x31>
        }
        s ++;
c0106951:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0106955:	8b 45 08             	mov    0x8(%ebp),%eax
c0106958:	0f b6 00             	movzbl (%eax),%eax
c010695b:	84 c0                	test   %al,%al
c010695d:	75 e2                	jne    c0106941 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010695f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106964:	c9                   	leave  
c0106965:	c3                   	ret    

c0106966 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0106966:	55                   	push   %ebp
c0106967:	89 e5                	mov    %esp,%ebp
c0106969:	83 ec 04             	sub    $0x4,%esp
c010696c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010696f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0106972:	eb 11                	jmp    c0106985 <strfind+0x1f>
        if (*s == c) {
c0106974:	8b 45 08             	mov    0x8(%ebp),%eax
c0106977:	0f b6 00             	movzbl (%eax),%eax
c010697a:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010697d:	75 02                	jne    c0106981 <strfind+0x1b>
            break;
c010697f:	eb 0e                	jmp    c010698f <strfind+0x29>
        }
        s ++;
c0106981:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0106985:	8b 45 08             	mov    0x8(%ebp),%eax
c0106988:	0f b6 00             	movzbl (%eax),%eax
c010698b:	84 c0                	test   %al,%al
c010698d:	75 e5                	jne    c0106974 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c010698f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106992:	c9                   	leave  
c0106993:	c3                   	ret    

c0106994 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0106994:	55                   	push   %ebp
c0106995:	89 e5                	mov    %esp,%ebp
c0106997:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010699a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01069a1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01069a8:	eb 04                	jmp    c01069ae <strtol+0x1a>
        s ++;
c01069aa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01069ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01069b1:	0f b6 00             	movzbl (%eax),%eax
c01069b4:	3c 20                	cmp    $0x20,%al
c01069b6:	74 f2                	je     c01069aa <strtol+0x16>
c01069b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01069bb:	0f b6 00             	movzbl (%eax),%eax
c01069be:	3c 09                	cmp    $0x9,%al
c01069c0:	74 e8                	je     c01069aa <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c01069c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01069c5:	0f b6 00             	movzbl (%eax),%eax
c01069c8:	3c 2b                	cmp    $0x2b,%al
c01069ca:	75 06                	jne    c01069d2 <strtol+0x3e>
        s ++;
c01069cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01069d0:	eb 15                	jmp    c01069e7 <strtol+0x53>
    }
    else if (*s == '-') {
c01069d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01069d5:	0f b6 00             	movzbl (%eax),%eax
c01069d8:	3c 2d                	cmp    $0x2d,%al
c01069da:	75 0b                	jne    c01069e7 <strtol+0x53>
        s ++, neg = 1;
c01069dc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01069e0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01069e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01069eb:	74 06                	je     c01069f3 <strtol+0x5f>
c01069ed:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01069f1:	75 24                	jne    c0106a17 <strtol+0x83>
c01069f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01069f6:	0f b6 00             	movzbl (%eax),%eax
c01069f9:	3c 30                	cmp    $0x30,%al
c01069fb:	75 1a                	jne    c0106a17 <strtol+0x83>
c01069fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a00:	83 c0 01             	add    $0x1,%eax
c0106a03:	0f b6 00             	movzbl (%eax),%eax
c0106a06:	3c 78                	cmp    $0x78,%al
c0106a08:	75 0d                	jne    c0106a17 <strtol+0x83>
        s += 2, base = 16;
c0106a0a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0106a0e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0106a15:	eb 2a                	jmp    c0106a41 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0106a17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106a1b:	75 17                	jne    c0106a34 <strtol+0xa0>
c0106a1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a20:	0f b6 00             	movzbl (%eax),%eax
c0106a23:	3c 30                	cmp    $0x30,%al
c0106a25:	75 0d                	jne    c0106a34 <strtol+0xa0>
        s ++, base = 8;
c0106a27:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0106a2b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0106a32:	eb 0d                	jmp    c0106a41 <strtol+0xad>
    }
    else if (base == 0) {
c0106a34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106a38:	75 07                	jne    c0106a41 <strtol+0xad>
        base = 10;
c0106a3a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0106a41:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a44:	0f b6 00             	movzbl (%eax),%eax
c0106a47:	3c 2f                	cmp    $0x2f,%al
c0106a49:	7e 1b                	jle    c0106a66 <strtol+0xd2>
c0106a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a4e:	0f b6 00             	movzbl (%eax),%eax
c0106a51:	3c 39                	cmp    $0x39,%al
c0106a53:	7f 11                	jg     c0106a66 <strtol+0xd2>
            dig = *s - '0';
c0106a55:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a58:	0f b6 00             	movzbl (%eax),%eax
c0106a5b:	0f be c0             	movsbl %al,%eax
c0106a5e:	83 e8 30             	sub    $0x30,%eax
c0106a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106a64:	eb 48                	jmp    c0106aae <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0106a66:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a69:	0f b6 00             	movzbl (%eax),%eax
c0106a6c:	3c 60                	cmp    $0x60,%al
c0106a6e:	7e 1b                	jle    c0106a8b <strtol+0xf7>
c0106a70:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a73:	0f b6 00             	movzbl (%eax),%eax
c0106a76:	3c 7a                	cmp    $0x7a,%al
c0106a78:	7f 11                	jg     c0106a8b <strtol+0xf7>
            dig = *s - 'a' + 10;
c0106a7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a7d:	0f b6 00             	movzbl (%eax),%eax
c0106a80:	0f be c0             	movsbl %al,%eax
c0106a83:	83 e8 57             	sub    $0x57,%eax
c0106a86:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106a89:	eb 23                	jmp    c0106aae <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0106a8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a8e:	0f b6 00             	movzbl (%eax),%eax
c0106a91:	3c 40                	cmp    $0x40,%al
c0106a93:	7e 3d                	jle    c0106ad2 <strtol+0x13e>
c0106a95:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a98:	0f b6 00             	movzbl (%eax),%eax
c0106a9b:	3c 5a                	cmp    $0x5a,%al
c0106a9d:	7f 33                	jg     c0106ad2 <strtol+0x13e>
            dig = *s - 'A' + 10;
c0106a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106aa2:	0f b6 00             	movzbl (%eax),%eax
c0106aa5:	0f be c0             	movsbl %al,%eax
c0106aa8:	83 e8 37             	sub    $0x37,%eax
c0106aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0106aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ab1:	3b 45 10             	cmp    0x10(%ebp),%eax
c0106ab4:	7c 02                	jl     c0106ab8 <strtol+0x124>
            break;
c0106ab6:	eb 1a                	jmp    c0106ad2 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0106ab8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0106abc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106abf:	0f af 45 10          	imul   0x10(%ebp),%eax
c0106ac3:	89 c2                	mov    %eax,%edx
c0106ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ac8:	01 d0                	add    %edx,%eax
c0106aca:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0106acd:	e9 6f ff ff ff       	jmp    c0106a41 <strtol+0xad>

    if (endptr) {
c0106ad2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106ad6:	74 08                	je     c0106ae0 <strtol+0x14c>
        *endptr = (char *) s;
c0106ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106adb:	8b 55 08             	mov    0x8(%ebp),%edx
c0106ade:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0106ae0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0106ae4:	74 07                	je     c0106aed <strtol+0x159>
c0106ae6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106ae9:	f7 d8                	neg    %eax
c0106aeb:	eb 03                	jmp    c0106af0 <strtol+0x15c>
c0106aed:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0106af0:	c9                   	leave  
c0106af1:	c3                   	ret    

c0106af2 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0106af2:	55                   	push   %ebp
c0106af3:	89 e5                	mov    %esp,%ebp
c0106af5:	57                   	push   %edi
c0106af6:	83 ec 24             	sub    $0x24,%esp
c0106af9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106afc:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0106aff:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0106b03:	8b 55 08             	mov    0x8(%ebp),%edx
c0106b06:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0106b09:	88 45 f7             	mov    %al,-0x9(%ebp)
c0106b0c:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0106b12:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0106b15:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0106b19:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0106b1c:	89 d7                	mov    %edx,%edi
c0106b1e:	f3 aa                	rep stos %al,%es:(%edi)
c0106b20:	89 fa                	mov    %edi,%edx
c0106b22:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0106b25:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0106b28:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0106b2b:	83 c4 24             	add    $0x24,%esp
c0106b2e:	5f                   	pop    %edi
c0106b2f:	5d                   	pop    %ebp
c0106b30:	c3                   	ret    

c0106b31 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0106b31:	55                   	push   %ebp
c0106b32:	89 e5                	mov    %esp,%ebp
c0106b34:	57                   	push   %edi
c0106b35:	56                   	push   %esi
c0106b36:	53                   	push   %ebx
c0106b37:	83 ec 30             	sub    $0x30,%esp
c0106b3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b40:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b43:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106b46:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b49:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0106b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b4f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106b52:	73 42                	jae    c0106b96 <memmove+0x65>
c0106b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106b5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106b60:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b63:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106b66:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106b69:	c1 e8 02             	shr    $0x2,%eax
c0106b6c:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0106b6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106b71:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b74:	89 d7                	mov    %edx,%edi
c0106b76:	89 c6                	mov    %eax,%esi
c0106b78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106b7a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106b7d:	83 e1 03             	and    $0x3,%ecx
c0106b80:	74 02                	je     c0106b84 <memmove+0x53>
c0106b82:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106b84:	89 f0                	mov    %esi,%eax
c0106b86:	89 fa                	mov    %edi,%edx
c0106b88:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0106b8b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0106b91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b94:	eb 36                	jmp    c0106bcc <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106b96:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b99:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106b9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b9f:	01 c2                	add    %eax,%edx
c0106ba1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ba4:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106baa:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0106bad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106bb0:	89 c1                	mov    %eax,%ecx
c0106bb2:	89 d8                	mov    %ebx,%eax
c0106bb4:	89 d6                	mov    %edx,%esi
c0106bb6:	89 c7                	mov    %eax,%edi
c0106bb8:	fd                   	std    
c0106bb9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106bbb:	fc                   	cld    
c0106bbc:	89 f8                	mov    %edi,%eax
c0106bbe:	89 f2                	mov    %esi,%edx
c0106bc0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0106bc3:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106bc6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0106bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0106bcc:	83 c4 30             	add    $0x30,%esp
c0106bcf:	5b                   	pop    %ebx
c0106bd0:	5e                   	pop    %esi
c0106bd1:	5f                   	pop    %edi
c0106bd2:	5d                   	pop    %ebp
c0106bd3:	c3                   	ret    

c0106bd4 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0106bd4:	55                   	push   %ebp
c0106bd5:	89 e5                	mov    %esp,%ebp
c0106bd7:	57                   	push   %edi
c0106bd8:	56                   	push   %esi
c0106bd9:	83 ec 20             	sub    $0x20,%esp
c0106bdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106be2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106be5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106be8:	8b 45 10             	mov    0x10(%ebp),%eax
c0106beb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106bee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bf1:	c1 e8 02             	shr    $0x2,%eax
c0106bf4:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0106bf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106bfc:	89 d7                	mov    %edx,%edi
c0106bfe:	89 c6                	mov    %eax,%esi
c0106c00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106c02:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0106c05:	83 e1 03             	and    $0x3,%ecx
c0106c08:	74 02                	je     c0106c0c <memcpy+0x38>
c0106c0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106c0c:	89 f0                	mov    %esi,%eax
c0106c0e:	89 fa                	mov    %edi,%edx
c0106c10:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106c13:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106c16:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0106c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0106c1c:	83 c4 20             	add    $0x20,%esp
c0106c1f:	5e                   	pop    %esi
c0106c20:	5f                   	pop    %edi
c0106c21:	5d                   	pop    %ebp
c0106c22:	c3                   	ret    

c0106c23 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0106c23:	55                   	push   %ebp
c0106c24:	89 e5                	mov    %esp,%ebp
c0106c26:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0106c29:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c2c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0106c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c32:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0106c35:	eb 30                	jmp    c0106c67 <memcmp+0x44>
        if (*s1 != *s2) {
c0106c37:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c3a:	0f b6 10             	movzbl (%eax),%edx
c0106c3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106c40:	0f b6 00             	movzbl (%eax),%eax
c0106c43:	38 c2                	cmp    %al,%dl
c0106c45:	74 18                	je     c0106c5f <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0106c47:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c4a:	0f b6 00             	movzbl (%eax),%eax
c0106c4d:	0f b6 d0             	movzbl %al,%edx
c0106c50:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106c53:	0f b6 00             	movzbl (%eax),%eax
c0106c56:	0f b6 c0             	movzbl %al,%eax
c0106c59:	29 c2                	sub    %eax,%edx
c0106c5b:	89 d0                	mov    %edx,%eax
c0106c5d:	eb 1a                	jmp    c0106c79 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0106c5f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0106c63:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0106c67:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c6a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106c6d:	89 55 10             	mov    %edx,0x10(%ebp)
c0106c70:	85 c0                	test   %eax,%eax
c0106c72:	75 c3                	jne    c0106c37 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0106c74:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106c79:	c9                   	leave  
c0106c7a:	c3                   	ret    
