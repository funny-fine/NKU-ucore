#include <defs.h>
#include <x86.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <list.h>


list_entry_t pra_list_head;
static int
_ec_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
     return 0;
}
static int
_ec_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    list_add(head, entry);
   // struct Page *pg = le2page(entry, pra_page_link);
   // pte_t *pte = get_pte(mm -> pgdir, pg -> pra_vaddr, 0);
   // *pte &= ~PTE_D;
    return 0;
}

static int
_ec_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
     assert(head != NULL);
     assert(in_tick==0);

     list_entry_t *le = head->prev;
     assert(head!=le);

     while(1)
     {
     	struct Page *p = le2page(le, pra_page_link);
     	pte_t *ptep=get_pte(mm->pgdir,p->pra_vaddr,0);
     	if(!(*ptep&PTE_A)&&!(*ptep&PTE_D))//未被访问，未被修改
     	{
     		list_del(le);
     		assert(p !=NULL);
     		*ptr_page = p;
     		return 0;
     	}

     	if(!(*ptep&PTE_A)&& (*ptep&PTE_D))//未被访问，已被修改
     	{
     		*ptep &=~PTE_D;
     	}

     	if(*ptep&PTE_A)//已被访问
     	{
     		*ptep &=~PTE_A;
     	}
	le=le->prev;
     }
}


static int
_ec_check_swap(void) {
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    cprintf("abcd四页的写操作消息此处省略,4次缺页。\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);

    cprintf("write Virt Page e in ec_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);

    cprintf("write Virt Page b in ec_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    cprintf("write Virt Page a in ec_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);

    cprintf("write Virt Page b in ec_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==6);
    cprintf("write Virt Page c in ec_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==7);

    cprintf("write Virt Page d in ec_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==8);
    cprintf("write Virt Page b in ec_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==9);
    cprintf("write Virt Page e in ec_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==10);

//检测一下最后内存中的页是不是这四页
    cprintf("write Virt Page c in ec_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==10);
    cprintf("write Virt Page d in ec_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==10);
    cprintf("write Virt Page b in ec_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==10);
    cprintf("write Virt Page e in ec_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==10);
    return 0;
}


static int
_ec_init(void)
{
    return 0;
}

static int
_ec_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_ec_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_ec =
{
     .name            = "ec swap manager",
     .init            = &_ec_init,
     .init_mm         = &_ec_init_mm,
     .tick_event      = &_ec_tick_event,
     .map_swappable   = &_ec_map_swappable,
     .set_unswappable = &_ec_set_unswappable,
     .swap_out_victim = &_ec_swap_out_victim,
     .check_swap      = &_ec_check_swap,
};
