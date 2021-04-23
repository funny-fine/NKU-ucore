//直到建立虚拟地址空间之前, 地址的访问都是按照在 bootasm.S 设置的段映射关系,且在 bootloader 中elf 加载时做了变换,否则无法执行如此高地址的代码.
#include <mmu.h>
#include <memlayout.h>

#define REALLOC(x) (x - KERNBASE)
/*内核入口目标: 作为内核入口点, 建立好 boot 阶段的映射关系,把虚拟内存 [0, 4M)和[KERNBASE, KERNBASE+4M)都映射到物理内存[0, 4M)上.
  原因: 
   0) bootloader 建立的是临时的偏移式分段虚拟地址(bootmain.c, 几处& 0xFFFFFF),现在转化为由 MMU 管理的真正的地址翻译,
   1) 高地址映射:内核运行期地址, 起始于 KERNBASE.
   2) 低地址映射: 在 movl %eax, %cr0 之后还有几个指令需要执行,如果不映射的话就访问不到了.

   
*/
.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
//两级页表已经由__boot_pgdir配置,现在将其物理地址赋给到 cr3
    movl $REALLOC(__boot_pgdir), %eax
    movl %eax, %cr3

    # enable paging  //使能 paging
    movl %cr0, %eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
    andl $~(CR0_TS | CR0_EM), %eax
    movl %eax, %cr0

    # update eip
    # now, eip = 0x1.....
    //执行下面这条指令时,虽然访问的仍然是处于[0,4MB)的空间,但已经是虚拟地址了,会经过页表的查找.如果不把[0,4MB)->[0,4MB),则这几条指令无法执行.
    leal next, %eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
next:
    //jmp 过来之后,取消虚拟地址 0 ~ 4M 的映射,即将 __boot_pgdir 置零.
    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
    movl %eax, __boot_pgdir

    # set ebp, esp
    movl $0x0, %ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
    # now kernel stack is ready , call the first C function
    call kern_init

# should never get here
spin:
    jmp spin

.data
.align PGSIZE
    .globl bootstack
bootstack:
    .space KSTACKSIZE
    .globl bootstacktop
bootstacktop:

# kernel builtin pgdir
# an initial page directory (Page Directory Table, PDT)
# These page directory table and page table can be reused!

//内核内置一级页表.
//每个一级页表对应 1024 个二级页表,即 4MB
//我们只需要映射两块,把对虚拟内存 [0,4M)和[KERNBASE, KERNBASE+4M)都映射到物理内存[0,4M)上,所以只需 2 个一级页表项.
//第一个页表项的上限是KERNBASE,共占用 768 个 entry,共 3072Byte<PAGESIZE,加上第二个页表项,再加上对齐,也没超过1 个 PAGESIZE.

//实际 nm 输出
//c0158000 d __boot_pt1
//c0157c00 d __second_PDE
//c0157000 D __boot_pgdir
//一级页表共占用 0x1000Byte=4KB
.section .data.pgdir
.align PGSIZE
__boot_pgdir:
.globl __boot_pgdir
    # map va 0 ~ 4M to pa 0 ~ 4M (temporary)
    //第一个一级页表项,把虚拟地址 0 ~ 4M 临时映射到 0 ~ 4M,
    .long REALLOC(__boot_pt1) + (PTE_P | PTE_U | PTE_W)
    //从 0 到KERNBASE,中间间隔了 KERNBASE/4M = 3072/4=768 项,共 768*4B = 3072Byte,不到一个 PAGESIZE.
    //为何最后还要<<2 ?每个页表项占用 1 个long,是 32bit,从 byte 到 long 需要*4,即<<2
    .space (KERNBASE >> PGSHIFT >> 10 << 2) - (. - __boot_pgdir) # pad to PDE of KERNBASE
    # map va KERNBASE + (0 ~ 4M) to pa 0 ~ 4M
    //第二个一级页表项,把虚拟地址 KERNBASE + (0 ~ 4M) 映射到物理地址 0 ~ 4M
    .long REALLOC(__boot_pt1) + (PTE_P | PTE_U | PTE_W)
    .space PGSIZE - (. - __boot_pgdir) # pad to PGSIZE

.set i, 0
__boot_pt1:
.rept 1024
    .long i * PGSIZE + (PTE_P | PTE_W)
    .set i, i + 1
.endr

