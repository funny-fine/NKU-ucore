#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>

/*  In the First Fit algorithm, the allocator keeps a list of free blocks
 * (known as the free list). Once receiving a allocation request for memory,
 * it scans along the list for the first block that is large enough to satisfy
 * the request. If the chosen block is significantly larger than requested, it
 * is usually splitted, and the remainder will be added unsignedo the list as
 * another free block.
 *  Please refer to Page 196~198, Section 8.2 of Yan Wei Min's Chinese book
 * "Data Structure -- C programming language".
*/
// LAB2 EXERCISE 1: YOUR CODE
// you should rewrite functions: `buddy_init`, `buddy_init_memmap`,
// `buddy_alloc_pages`, `buddy_free_pages`.
/*
 * Details of FFMA
 * (1) Preparation:
 *  In order to implement the First-Fit Memory Allocation (FFMA), we should
 * manage the free memory blocks using a list. The struct `free_area_t` is used
 * for the management of free memory blocks.
 *  First, you should get familiar with the struct `list` in list.h. Struct
 * `list` is a simple doubly linked list implementation. You should know how to
 * USE `list_init`, `list_add`(`list_add_after`), `list_add_before`, `list_del`,
 * `list_next`, `list_prev`.
 *  There's a tricky method that is to transform a general `list` struct to a
 * special struct (such as struct `page`), using the following MACROs: `le2page`
 * (in memlayout.h), (and in future labs: `le2vma` (in vmm.h), `le2proc` (in
 * proc.h), etc).
 * (2) `buddy_init`:
 *  You can reuse the demo `buddy_init` function to initialize the `free_list`
 * and set `nr_free` to 0. `free_list` is used to record the free memory blocks.
 * `nr_free` is the total number of the free memory blocks.
 * (3) `buddy_init_memmap`:
 *  CALL GRAPH: `kern_init` --> `pmm_init` --> `page_init` --> `init_memmap` -->
 * `pmm_manager` --> `init_memmap`.
 *  This function is used to initialize a free block (with parameter `addr_base`,
 * `page_number`). In order to initialize a free block, firstly, you should
 * initialize each page (defined in memlayout.h) in this free block. This
 * procedure includes:
 *  - Setting the bit `PG_property` of `p->flags`, which means this page is
 * valid. P.S. In function `pmm_init` (in pmm.c), the bit `PG_reserved` of
 * `p->flags` is already set.
 *  - If this page is free and is not the first page of a free block,
 * `p->property` should be set to 0.
 *  - If this page is free and is the first page of a free block, `p->property`
 * should be set to be the total number of pages in the block.
 *  - `p->ref` should be 0, because now `p` is free and has no reference.
 *  After that, We can use `p->page_link` to link this page unsignedo `free_list`.
 * (e.g.: `list_add_before(&free_list, &(p->page_link));` )
 *  Finally, we should update the sum of the free memory blocks: `nr_free += n`.
 * (4) `buddy_alloc_pages`:
 *  Search for the first free block (block size >= n) in the free list and reszie
 * the block found, returning the address of this block as the address required by
 * `malloc`.
 *  (4.1)
 *      So you should search the free list like this:
 *          list_entry_t le = &free_list;
 *          while((le=list_next(le)) != &free_list) {
 *          ...
 *      (4.1.1)
 *          In the while loop, get the struct `page` and check if `p->property`
 *      (recording the num of free pages in this block) >= n.
 *              struct Page *p = le2page(le, page_link);
 *              if(p->property >= n){ ...
 *      (4.1.2)
 *          If we find this `p`, it means we've found a free block with its size
 *      >= n, whose first `n` pages can be malloced. Some flag bits of this page
 *      should be set as the following: `PG_reserved = 1`, `PG_property = 0`.
 *      Then, unlink the pages from `free_list`.
 *          (4.1.2.1)
 *              If `p->property > n`, we should re-calculate number of the rest
 *          pages of this free block. (e.g.: `le2page(le,page_link))->property
 *          = p->property - n;`)
 *          (4.1.3)
 *              Re-caluclate `nr_free` (number of the the rest of all free block).
 *          (4.1.4)
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
 * (5) `buddy_free_pages`:
 *  re-link the pages unsignedo the free list, and may merge small free blocks unsignedo
 * the big ones.
 *  (5.1)
 *      According to the base address of the withdrawed blocks, search the free
 *  list for its correct position (with address from low to high), and insert
 *  the pages. (May use `list_next`, `le2page`, `list_add_before`)
 *  (5.2)
 *      Reset the fields of the pages, such as `p->ref` and `p->flags` (PageProperty)
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
#define left 0 
#define right 1
#define buddy_type_size 19
free_area_t free_area_list[buddy_type_size];
static unsigned unsigned buddy_type[buddy_type_size];
#define free_list(n) (free_area_list[n].free_list)
#define nr_free(n) (free_area_list[n].nr_free)

static void
buddy_init(void) {
    unsigned i=0;
    buddy_type[0]=1;
    for(;i<buddy_type_size;i++){
        list_init(&(free_list(i)));  
        nr_free(i) = 0;
        if(i!=0){
            buddy_type[i]=buddy_type[i-1]<<1; 
        }
    }
}
static size_t find_list(size_t n){
    assert(n > 0);
    size_t i=0;
    for(;i<n;i++){
        if(buddy_type[i]>=n)
        return i;
    }
    return -1;
}
static void
buddy_init_memmap(struct Page *base,size_t n) {
    assert(n > 0);
    struct Page *p = base;
    size_t n=get_size(buddy_type_size-1);
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    SetPageProperty(base);
    unsigned index_type;
    assert(n>0);
    while( (index_type=find_list(n)) >= 0 ){  
        nr_free(index_type)=1;  
        list_add_before(&(free_list(index_type)),&(base->page_link));
        base->property = buddy_type[index_type]; 
        n -= buddy_type[index_type];     
    }
}

static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if(n>buddy_type[buddy_type_size-1]){
        return NULL;
    }
    struct Page *page = NULL;
    size_t index=find_list(n);
    list_entry_t *le = &free_list(index);
    size_t i=index;
    while(le==NULL){
        le=&free_list(++i);
    } 
    page=le;
    if(page!=NULL){
        if (n<buddy_type[index]&&n>buddy_type[index]/2) { 
            list_del(&(page->page_link));
            nr_free(index) -=1;
        }
        else {
            size_t i=index;
            while(n<get_size(i)/2){
                struct  Page *p=page+get_size(i)/2;
                p->property = page->property/2;
                page->property=page->property/2;
                nr_free(i)-=1;
                list_add_before(&free_list(i),&(p->page_link));
                list_add_before(&free_list(i),&(page->page_link));
                nr_free(i)+=2;
                i--;   
            }
            list_del(&(page->page_link));
            nr_free(i) -=1;
        } 
    ClearPageProperty(page);
    }
    return page;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++){ 
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    unsigned page_count=p->property;
    unsigned index  = buddy_get_alloc_type(p->property);
    unsigned number = get_page_index(p); 
    SetPageProperty(base);   
    if(index+1==buddy_type_size){
        ClearPageProperty(p);
        p->property=buddy_type[index];
        list_add_before(&(free_list(index)), &(p->page_link));
        return ;
    }
    unsigned f;
    if(number%buddy_type[index+1]==0){
        f=left;
    }else{
        f=right;
    }
    list_entry_t *le = &(free_list(index));
    struct Page *temp=NULL;
    ClearPageProperty(p);
    list_del(&(p->page_link));
    while(index+1!= buddy_type_size ){   
        if(f==left){
            temp=p+ (p->property);
            if(temp->ref!=0){
                break;
            }else{
                list_del(&(temp->page_link));
                index++;
                p->property = buddy_type[index];
            }
        }else{
            temp=p-(p->property);
            if(temp->ref!=0){
                break;
            }else{
                list_del(&(temp->page_link));
                p=temp;
                index++;
                p->property = buddy_type[index];
            }
        }
    }
    list_add_before(&(free_list(index)), &(p->page_link));
    nr_free(index) +=1;
}

static size_t
buddy_nr_free_pages(void) {
     size_t count=0;
    unsigned i=0;
    size_t temp;
    for(;i<buddy_type_size;i++){
        count+= ( nr_free(i) * buddy_type[i] );
    }
    return count;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned unsigned nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, buddy_check functions!
static void
buddy_check(void) {
    unsigned count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned unsigned nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
