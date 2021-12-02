#include "userprog/syscall.h"
#include <stdio.h>
#include <syscall-nr.h>
#include "threads/interrupt.h"
#include "threads/vaddr.h"
#include "threads/malloc.h"
#include "devices/shutdown.h"
#include "devices/input.h"
#include "process.h"
#include "filesys/file.h"
#include "filesys/filesys.h"
#include "threads/synch.h"

void fetch_argument(struct intr_frame *f, int choose, void *args);
void fetch_argument_1(struct intr_frame *f, int choose, void *args);
struct child_element* get_child(tid_t tid,struct list *current_list);
static void syscall_handler (struct intr_frame *);
int write (int fd, const void *buffer_, unsigned size);
tid_t exec (const char *cmdline);
void exit (int status);


void
syscall_init (void)
{
    intr_register_int (0x30, 3, INTR_ON, syscall_handler, "syscall");
    lock_init(&file_lock);
}

void halt (void)
{
    shutdown_power_off();
}

void check (const void *pointer)
{
    if (!is_user_vaddr(pointer))
    {
        exit(-1);
    }

    void *check = pagedir_get_page(thread_current()->pagedir, pointer);
    if (check == NULL)
    {
        exit(-1);
    }
}

void fetch_argument (struct intr_frame *f, int choose, void *args)
{
    int argv = *((int*) args);		// first argument
    args = args+ 4;
    int argv_1 = *((int*) args);	// second argument
    args = args+ 4;
    int argv_2 = *((int*) args);	// third argument
    args = args+ 4;

    check((const void*) argv_1);
    void * temp = ((void*) argv_1)+ argv_2 ;
    check((const void*) temp);
    if (choose == SYS_WRITE)
    {
    	//call write function
        f->eax = write (argv,(void *) argv_1,(unsigned) argv_2);
    }
}


void fetch_argument_1(struct intr_frame *f, int choose, void *args)
{
    int argv = *((int*) args);
    args += 4;

    if (choose == SYS_EXEC)
    {
        check((const void*) argv);
        f -> eax = exec((const char *)argv);
    }
    else if (choose == SYS_EXIT)
    {
        exit(argv);
    }
}


static void
syscall_handler (struct intr_frame *f )
{
	int n;
    n = 0;
    // call check
    check((const void*) f -> esp);
    void *args = f -> esp;
    n = *( (int *) f -> esp);
    args=args+4;
    check((const void*) args);
    switch(n)
    {
    case SYS_HALT:                  	// Halt the operating system. 
        halt();
        break;
    case SYS_EXIT:                   // end the process. 
        fetch_argument_1(f, SYS_EXIT,args);
        break;
    case SYS_EXEC:                   // Start  process. 
        fetch_argument_1(f, SYS_EXEC,args);
        break;
    case SYS_WRITE:                  // Write  
        fetch_argument(f, SYS_WRITE,args);
        break;
    default:
        exit(-1);
        break;
    }
}



void exit (int status)
{
    struct thread *cur = thread_current();
    printf ("%s: exit(%d)\n", cur -> name, status);

    struct child_element *child = get_child(cur->tid, &cur -> parent -> child_list);
    child -> exit_status = status;
    if (status != -1)
    {
    	child -> cur_status = HAD_EXITED;
    }
    else
    {
        child -> cur_status = WAS_KILLED;
    }

    thread_exit();
}

tid_t
exec (const char *cmd_line)
{
    struct thread* parent = thread_current();
    tid_t pid = -1;
    pid = process_execute(cmd_line);

    struct child_element *child = get_child(pid,&parent -> child_list);
    sema_down(&child-> real_child -> sema_exec);
    if(!child -> loaded_success)
    {
        //loading failed 
        return -1;
    }
    return pid;
}

int write (int fd, const void *buffer_, unsigned size)
{
    uint8_t * buffer = (uint8_t *) buffer_;
    int value;
    value = -1;
    if (fd == 1)
    {
        putbuf( (char *)buffer, size);
        return (int)size;
    }
    else
    {
    	printf("Writing in another file\n");
    }
    return value;
}

void close_all(struct list *current_list)
{
    struct list_elem *e;
    while(!list_empty(current_list))
    {
        e = list_pop_front(current_list);
        struct fd_element *fd_elem = list_entry (e, struct fd_element, element);
        file_close(fd_elem->myfile);
        list_remove(e);
        free(fd_elem);
    }
}

struct child_element*
get_child(tid_t tid, struct list *current_list)
{
    struct list_elem* e;
    for (e = list_begin (current_list); e != list_end (current_list); e = list_next (e))
    {
        struct child_element *child = list_entry (e, struct child_element, child_elem);
        if(child -> child_pid == tid)
        {
            return child;
        }
    }
}
