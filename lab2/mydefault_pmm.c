#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>
/*
ff倾向于优先利用内存中低地址部分的空闲分区，从而保留了高址部分的大空闲区.其缺点是低址部分不断被划分，会留下许多难以利用的、很小的空闲分区，而每次查找又都是从低址部分开始，会增加查找可用空闲分区时的开销。
*/


/*
first-fit算法最坏情况下需要遍历整个链表，而且找到的块并非最适合的，因此可以改用平衡二叉树来维护空闲内存块，提高查找效率
但课本上也说best-fit最终的效果还不如ff（会产生很多更小的空闲块，难以利用），所以也许还需要想其他方法
*/


free_area_t free_area; //结构free_area_t用来管理空闲内存块

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) 
{
    list_init(&free_list);//初始化一个空链表  {elm->prev = elm->next = &free_list;}
    nr_free = 0;//总空闲内存块数量为0
}


//对最初一整块未被占用的物理内存空间中每页对应Page结构进行初始化
static void
default_init_memmap(struct Page *base, size_t n) 
{
    assert(n > 0);//断言函数，判断n是否大于0（若表达式结果为假，则终止程序，反馈错误）
    struct Page *p = base;
    //初始化n块物理页
    for (; p != base + n; p ++) 
    {
        assert(PageReserved(p));//检查此页是否为保留页
        p->flags = p->property = 0;//将标志位清0，连续空页个数清0
        set_page_ref(p, 0);//将引用此物理页的虚拟页的个数清0
    }

    //base 空闲块的第一个page，property记录连续空闲块数
    base->property = n;
    SetPageProperty(base);

    nr_free += n;//更新空闲页总数
    list_add_before(&free_list, &(base->page_link));//加入空闲链表
}



//分配指定页数的连续空闲物理空间，并且将第一页Page指针作为结果返回
static struct Page *
default_alloc_pages(size_t n)
{
    assert(n > 0);
    if (n > nr_free) 
        return NULL;//总的空闲物理页数目是否够分

    struct Page *page = NULL;
    list_entry_t *le = &free_list;//空闲链表的头部

    while ((le = list_next(le)) != &free_list) //遍历整个空闲链表(双向循环链表)
    {
        struct Page *p = le2page(le, page_link);//将list入口转换为page入口
        if (p->property >= n) 
        {
            page = p;
            break;
        }//选择第一个满足条件的空闲内存块来分配
    }
    if (page != NULL)
    {
        if (page->property > n) //页块大小大于所需大小，分割页块
        {
            struct Page *p = page + n;//定位到分裂出来的新的小空闲块的第一个页
            p->property = page->property - n;//更新新的空闲块大小信息
            SetPageProperty(p);
            list_add_after(&(page->page_link), &(p->page_link));//将新空闲块插入空闲块列表中
        }
        list_del(&(page->page_link)); //删除空闲链表中原先空闲块
        nr_free -= n;//更新总空闲物理页的数量
        ClearPageProperty(page);//将分配出去的内存页标记为非空闲
    }
    return page;
/*
一开始理解错了，觉得这里该用循环把分配出去的n页全ClearPageProperty，于是make grade结果报了错误.
而实际上memlayout.h里对PG_property的定义解释说，此位为1表示空闲内存块的首页，此位为0表示不是空闲块或不是首页，也就是说只有块的第一页才需要关注这一位.
*/
}



/*
释放指定的某一物理页开始的若干连续页，并且完成ff算法中需要的信息维护.
*/
static void
default_free_pages(struct Page *base, size_t n) 
{
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) 
    {
        assert(!PageReserved(p) && !PageProperty(p));//判断物理页是否真的被占用，防释放未占用的页
        p->flags = 0;
        set_page_ref(p, 0);
    }

    base->property = n;//空闲块大小
    SetPageProperty(base);//标记空闲块的第一页
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) 
    {
        p = le2page(le, page_link);
        le = list_next(le);
        if (base + base->property == p) //如果是高位，则向高地址合并
        {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        else if (p + p->property == base) //如果是低位，则向低地址合并
        {
            p->property += base->property;
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;// 更新空闲物理页总量

    /*le = list_next(&free_list);
    while (le != &free_list) 
    {
        p = le2page(le, page_link);
        if (base + base->property <= p) 
        {
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }*/

    list_add_before(le, &(base->page_link));
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
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

    unsigned int nr_free_store = nr_free;
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
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
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

    unsigned int nr_free_store = nr_free;
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
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}

const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

