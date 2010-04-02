#!/bin/sh

# make sure we are in the directory containing this script
SCRIPTDIR=`dirname $0`
cd $SCRIPTDIR
PATH="${PATH}:/bin:/sbin"

#
# HOSTCC vs. CC - if a conftest needs to build and execute a test
# binary, like get_uname, then $HOSTCC needs to be used for this
# conftest in order for the host/build system to be able to execute
# it in X-compile environments.
# In all other cases, $CC should be used to minimize the risk of
# false failures due to conflicts with architecture specific header
# files.
#
CC="$1"
HOSTCC="$2"
ISYSTEM=`$CC -print-file-name=include 2> /dev/null`
SOURCES=$3
HEADERS=$SOURCES/include
OUTPUT=$4
XEN_PRESENT=1

test_xen() {
    #
    # Determine if the target kernel is a Xen kernel. It used to be
    # sufficient to check for CONFIG_XEN, but the introduction of
    # modular para-virtualization (CONFIG_PARAVIRT, etc.) and
    # Xen guest support, it is no longer possible to determine the
    # target environment at build time. Therefore, if both
    # CONFIG_XEN and CONFIG_PARAVIRT are present, text_xen() treats
    # the kernel as a stand-alone kernel.
    #
    FILE="generated/autoconf.h"

    if [ -f $HEADERS/$FILE -o -f $OUTPUT/include/$FILE ]; then
        #
        # We are looking at a configured source tree; verify
        # that it's not a Xen kernel.
        #
	echo "#include <generated/autoconf.h>
        #if defined(CONFIG_XEN) && !defined(CONFIG_PARAVIRT)
        #error CONFIG_XEN defined!
        #endif
        " > conftest$$.c

        $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
        rm -f conftest$$.c

        if [ -f conftest$$.o ]; then
            rm -f conftest$$.o
            XEN_PRESENT=0
        fi
    else
        CONFIG=$HEADERS/../.config
        if [ -f $CONFIG ]; then
            if [ -z "$(grep "^CONFIG_XEN=y" $CONFIG)" ]; then
                XEN_PRESENT="0"
                return
            fi
            if [ -n "$(grep "^CONFIG_PARAVIRT=y" $CONFIG)" ]; then
                XEN_PRESENT="0"
            fi
        fi
    fi
}

build_cflags() {
    ARCH=`uname -m | sed -e 's/i.86/i386/'`

    BASE_CFLAGS="-D__KERNEL__ \
-DKBUILD_BASENAME=\"#conftest$$\" -DKBUILD_MODNAME=\"#conftest$$\" \
-nostdinc -isystem $ISYSTEM"

    if [ "$OUTPUT" != "$SOURCES" ]; then
        OUTPUT_CFLAGS="-I$OUTPUT/include2 -I$OUTPUT/include"
    fi

    CFLAGS="$CFLAGS $OUTPUT_CFLAGS -I$HEADERS"

    test_xen

    if [ "$OUTPUT" != "$SOURCES" ]; then
        MACH_CFLAGS="-I$HEADERS/asm-$ARCH/mach-default"
        if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]; then
            MACH_CFLAGS="$MACH_CFLAGS -I$HEADERS/asm-x86/mach-default"
            MACH_CFLAGS="$MACH_CFLAGS -I$SOURCES/arch/x86/include/asm/mach-default"
        fi
        if [ "$XEN_PRESENT" != "0" ]; then
            MACH_CFLAGS="-I$HEADERS/asm-$ARCH/mach-xen $MACH_CFLAGS"
        fi
    else
        MACH_CFLAGS="-I$HEADERS/asm/mach-default"
        if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]; then
            MACH_CFLAGS="$MACH_CFLAGS -I$HEADERS/asm-x86/mach-default"
            MACH_CFLAGS="$MACH_CFLAGS -I$SOURCES/arch/x86/include/asm/mach-default"
        fi
        if [ "$XEN_PRESENT" != "0" ]; then
            MACH_CFLAGS="-I$HEADERS/asm/mach-xen $MACH_CFLAGS"
        fi
    fi

    CFLAGS="$BASE_CFLAGS $MACH_CFLAGS $OUTPUT_CFLAGS -I$HEADERS"

    if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]; then
        CFLAGS="$CFLAGS -I$SOURCES/arch/x86/include"
    fi
    if [ -n "$BUILD_PARAMS" ]; then
        CFLAGS="$CFLAGS -D$BUILD_PARAMS"
    fi
}

CONFTEST_PREAMBLE="#include <linux/version.h>                                                 
    #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,33)                                          
    #include <generated/autoconf.h>                                                           
    #else                                                                                     
    #include <linux/autoconf.h>                                                               
    #endif                                 
    #if defined(CONFIG_XEN) && \
        defined(CONFIG_XEN_INTERFACE_VERSION) &&  !defined(__XEN_INTERFACE_VERSION__)
    #define __XEN_INTERFACE_VERSION__ CONFIG_XEN_INTERFACE_VERSION
    #endif"

compile_test() {
    case "$1" in
        remap_page_range)
            #
            # Determine if the remap_page_range() function is present
            # and how many arguments it takes.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/mm.h>
            void conftest_remap_page_range(void) {
                remap_page_range();
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#undef NV_REMAP_PAGE_RANGE_PRESENT" >> conftest.h
                rm -f conftest$$.o
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/mm.h>
            int conftest_remap_page_range(void) {
                pgprot_t pgprot = __pgprot(0);
                return remap_page_range(NULL, 0L, 0L, 0L, pgprot);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_REMAP_PAGE_RANGE_PRESENT" >> conftest.h
                echo "#define NV_REMAP_PAGE_RANGE_ARGUMENT_COUNT 5" >> conftest.h
                rm -f conftest$$.o
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/mm.h>
            int conftest_remap_page_range(void) {
                pgprot_t pgprot = __pgprot(0);
                return remap_page_range(0L, 0L, 0L, pgprot);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_REMAP_PAGE_RANGE_PRESENT" >> conftest.h
                echo "#define NV_REMAP_PAGE_RANGE_ARGUMENT_COUNT 4" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#error remap_page_range() conftest failed!" >> conftest.h
                return
            fi
        ;;

        set_pages_uc)
            #
            # Determine if the set_pages_uc() function is present.
            #
            echo "$CONFTEST_PREAMBLE
            #include <asm/cacheflush.h>
            void conftest_set_pages_uc(void) {
                set_pages_uc();
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#undef NV_SET_PAGES_UC_PRESENT" >> conftest.h
                return
            else
                echo "#ifdef NV_CHANGE_PAGE_ATTR_PRESENT" >> conftest.h
                echo "#undef NV_CHANGE_PAGE_ATTR_PRESENT" >> conftest.h
                echo "#endif"                             >> conftest.h
                echo "#define NV_SET_PAGES_UC_PRESENT"    >> conftest.h
                return
            fi
        ;;

        change_page_attr)
            #
            # Determine if the change_page_attr() function is
            # present.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/version.h>
            #include <linux/utsname.h>
            #include <linux/mm.h>
            #if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 0)
              #include <asm/cacheflush.h>
            #endif
            void conftest_change_page_attr(void) {
                change_page_attr();
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#undef NV_CHANGE_PAGE_ATTR_PRESENT" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#ifndef NV_SET_PAGES_UC_PRESENT"     >> conftest.h
                echo "#define NV_CHANGE_PAGE_ATTR_PRESENT" >> conftest.h
                echo "#endif"                              >> conftest.h
                return
            fi
        ;;

        pci_get_class)
            #
            # Determine if the pci_get_class() function is
            # present.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/pci.h>
            void conftest_pci_get_class(void) {
                pci_get_class();
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#undef NV_PCI_GET_CLASS_PRESENT" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#define NV_PCI_GET_CLASS_PRESENT" >> conftest.h
                return
            fi
        ;;

        remap_pfn_range)
            #
            # Determine if the remap_pfn_range() function is
            # present.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/mm.h>
            void conftest_remap_pfn_range(void) {
                remap_pfn_range();
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#undef NV_REMAP_PFN_RANGE_PRESENT" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#define NV_REMAP_PFN_RANGE_PRESENT" >> conftest.h
                return
            fi
        ;;

        signal_struct)
            #
            # Determine if the 'signal_struct' structure has an
            # 'rlim' member.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/sched.h>
            int conftest_signal_struct(void) {
                return offsetof(struct signal_struct, rlim);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_SIGNAL_STRUCT_HAS_RLIM" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#undef NV_SIGNAL_STRUCT_HAS_RLIM" >> conftest.h
                return
            fi
        ;;

        agp_backend_acquire)
            #
            # Determine if the agp_backend_acquire() function is
            # present and how many arguments it takes.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/types.h>
            #include <linux/agp_backend.h>
            typedef struct agp_bridge_data agp_bridge_data;
            agp_bridge_data *conftest_agp_backend_acquire(struct pci_dev *dev) {
                return agp_backend_acquire(dev, 0L);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#undef NV_AGP_BACKEND_ACQUIRE_PRESENT" >> conftest.h
                rm -f conftest$$.o
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/types.h>
            #include <linux/agp_backend.h>
            typedef struct agp_bridge_data agp_bridge_data;
            agp_bridge_data *conftest_agp_backend_acquire(struct pci_dev *dev) {
                return agp_backend_acquire(dev);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_AGP_BACKEND_ACQUIRE_PRESENT" >> conftest.h
                echo "#define NV_AGP_BACKEND_ACQUIRE_ARGUMENT_COUNT 1" >> conftest.h
                rm -f conftest$$.o
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/types.h>
            #include <linux/agp_backend.h>
            typedef struct agp_bridge_data agp_bridge_data;
            agp_bridge_data *conftest_agp_backend_acquire(void) {
                return agp_backend_acquire();
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_AGP_BACKEND_ACQUIRE_PRESENT" >> conftest.h
                echo "#define NV_AGP_BACKEND_ACQUIRE_ARGUMENT_COUNT 0" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#error agp_backend_acquire() conftest failed!" >> conftest.h
                return
            fi
        ;;

        vmap)
            #
            # Determine if the vmap() function is present and how
            # many arguments it takes.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/vmalloc.h>
            void conftest_vmap(void) {
                vmap();
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#undef NV_VMAP_PRESENT" >> conftest.h
                rm -f conftest$$.o
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/vmalloc.h>
            void *conftest_vmap(struct page **pages, int count) {
                return vmap(pages, count);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_VMAP_PRESENT" >> conftest.h
                echo "#define NV_VMAP_ARGUMENT_COUNT 2" >> conftest.h
                rm -f conftest$$.o
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/vmalloc.h>
            #include <linux/mm.h>
            void *conftest_vmap(struct page **pages, int count) {
                return vmap(pages, count, 0, PAGE_KERNEL);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_VMAP_PRESENT" >> conftest.h
                echo "#define NV_VMAP_ARGUMENT_COUNT 4" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#error vmap() conftest failed!" >> conftest.h
                return
            fi
        ;;

        i2c_adapter)
            #
            # Determine if the 'i2c_adapter' structure has inc_use()
            # and client_register() members.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/i2c.h>
            int conftest_i2c_adapter(void) {
                return offsetof(struct i2c_adapter, inc_use);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_I2C_ADAPTER_HAS_INC_USE" >> conftest.h
                rm -f conftest$$.o
            else
                echo "#undef NV_I2C_ADAPTER_HAS_INC_USE" >> conftest.h
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/i2c.h>
            int conftest_i2c_adapter(void) {
                return offsetof(struct i2c_adapter, client_register);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_I2C_ADAPTER_HAS_CLIENT_REGISTER" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#undef NV_I2C_ADAPTER_HAS_CLIENT_REGISTER" >> conftest.h
                return
            fi
        ;;

        pm_message_t)
            #
            # Determine if the 'pm_message_t' data type is present
            # and if it as an 'event' member.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/pm.h>
            void conftest_pm_message_t(pm_message_t state) {
                pm_message_t *p = &state;
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_PM_MESSAGE_T_PRESENT" >> conftest.h
                rm -f conftest$$.o
            else
                echo "#undef NV_PM_MESSAGE_T_PRESENT" >> conftest.h
                echo "#undef NV_PM_MESSAGE_T_HAS_EVENT" >> conftest.h
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/pm.h>  
            int conftest_pm_message_t(void) {
                return offsetof(pm_message_t, event);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_PM_MESSAGE_T_HAS_EVENT" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#undef NV_PM_MESSAGE_T_HAS_EVENT" >> conftest.h
                return
            fi
        ;;

        pci_choose_state)
            #
            # Determine if the pci_choose_state() function is
            # present.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/pci.h>
            void conftest_pci_choose_state(void) {
                pci_choose_state();
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#undef NV_PCI_CHOOSE_STATE_PRESENT" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#define NV_PCI_CHOOSE_STATE_PRESENT" >> conftest.h
                return
            fi
        ;;

        vm_insert_page)
            #
            # Determine if the vm_insert_page() function is
            # present.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/mm.h>
            void conftest_vm_insert_page(void) {
                vm_insert_page();
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#undef NV_VM_INSERT_PAGE_PRESENT" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#define NV_VM_INSERT_PAGE_PRESENT" >> conftest.h
                return
            fi
        ;;

        irq_handler_t)
            #
            # Determine if the 'irq_handler_t' type is present and
            # if it takes a 'struct ptregs *' argument.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/interrupt.h>
            irq_handler_t conftest_isr;
            " > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ ! -f conftest$$.o ]; then
                echo "#undef NV_IRQ_HANDLER_T_PRESENT" >> conftest.h
                rm -f conftest$$.o
                return
            fi

            rm -f conftest$$.o

            echo "$CONFTEST_PREAMBLE
            #include <linux/interrupt.h>
            irq_handler_t conftest_isr;
            int conftest_irq_handler_t(int irq, void *arg) {
                return conftest_isr(irq, arg);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_IRQ_HANDLER_T_PRESENT" >> conftest.h
                echo "#define NV_IRQ_HANDLER_T_ARGUMENT_COUNT 2" >> conftest.h
                rm -f conftest$$.o
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/interrupt.h>
            irq_handler_t conftest_isr;
            int conftest_irq_handler_t(int irq, void *arg, struct pt_regs *regs) {
                return conftest_isr(irq, arg, regs);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_IRQ_HANDLER_T_PRESENT" >> conftest.h
                echo "#define NV_IRQ_HANDLER_T_ARGUMENT_COUNT 3" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#error irq_handler_t() conftest failed!" >> conftest.h
                return
            fi
        ;;

        acpi_device_ops)
            #
            # Determine if the 'acpi_device_ops' structure has
            # a match() member.
            #
            echo "$CONFTEST_PREAMBLE
            #include <acpi/acpi_bus.h>
            int conftest_acpi_device_ops(void) {
                return offsetof(struct acpi_device_ops, match);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#define NV_ACPI_DEVICE_OPS_HAS_MATCH" >> conftest.h
                return
            else
                echo "#undef NV_ACPI_DEVICE_OPS_HAS_MATCH" >> conftest.h
                return
            fi
        ;;

        acpi_device_id)
            #
            # Determine if the 'acpi_device_id' structure has 
            # a 'driver_data' member.
            #
            echo "$CONFTEST_PREAMBLE
            #include <acpi/acpi_drivers.h>
            int conftest_acpi_device_id(void) {
                return offsetof(struct acpi_device_id, driver_data);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_ACPI_DEVICE_ID_HAS_DRIVER_DATA" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#undef NV_ACPI_DEVICE_ID_HAS_DRIVER_DATA" >> conftest.h
                return
            fi
        ;;

        acquire_console_sem)
            #
            # Determine if the acquire_console_sem() function
            # is present.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/console.h>
            void conftest_acquire_console_sem(void) {
                acquire_console_sem(NULL);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#undef NV_ACQUIRE_CONSOLE_SEM_PRESENT" >> conftest.h
                return
            else
                echo "#define NV_ACQUIRE_CONSOLE_SEM_PRESENT" >> conftest.h
                return
            fi
        ;;

        kmem_cache_create)
            #
            # Determine if the kmem_cache_create() function is
            # present and how many arguments it takes.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/slab.h>
            void conftest_kmem_cache_create(void) {
                kmem_cache_create();
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#undef NV_KMEM_CACHE_CREATE_PRESENT" >> conftest.h
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/slab.h>
            void conftest_kmem_cache_create(void) {
                kmem_cache_create(NULL, 0, 0, 0L, NULL, NULL);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#define NV_KMEM_CACHE_CREATE_PRESENT" >> conftest.h
                echo "#define NV_KMEM_CACHE_CREATE_ARGUMENT_COUNT 6 " >> conftest.h
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/slab.h>
            void conftest_kmem_cache_create(void) {
                kmem_cache_create(NULL, 0, 0, 0L, NULL);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#define NV_KMEM_CACHE_CREATE_PRESENT" >> conftest.h
                echo "#define NV_KMEM_CACHE_CREATE_ARGUMENT_COUNT 5 " >> conftest.h
                return
            else
                echo "#error kmem_cache_create() conftest failed!" >> conftest.h
            fi
        ;;

        smp_call_function)
            #
            # Determine if the smp_call_function() function is
            # present and how many arguments it takes.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/smp.h>
            void conftest_smp_call_function(void) {
            #ifdef CONFIG_SMP
                smp_call_function();
            #endif
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#undef NV_SMP_CALL_FUNCTION_PRESENT" >> conftest.h
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/smp.h>
            void conftest_smp_call_function(void) {
                smp_call_function(NULL, NULL, 0, 0);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#define NV_SMP_CALL_FUNCTION_PRESENT" >> conftest.h
                echo "#define NV_SMP_CALL_FUNCTION_ARGUMENT_COUNT 4 " >> conftest.h
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/smp.h>
            void conftest_smp_call_function(void) {
                smp_call_function(NULL, NULL, 0);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#define NV_SMP_CALL_FUNCTION_PRESENT" >> conftest.h
                echo "#define NV_SMP_CALL_FUNCTION_ARGUMENT_COUNT 3 " >> conftest.h
                return
            else
                echo "#error smp_call_function() conftest failed!" >> conftest.h
            fi
        ;;

        on_each_cpu)
            #
            # Determine if the on_each_cpu() function is present
            # and how many arguments it takes.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/smp.h>
            void conftest_on_each_cpu(void) {
            #ifdef CONFIG_SMP
                on_each_cpu();
            #endif
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#undef NV_ON_EACH_CPU_PRESENT" >> conftest.h
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/smp.h>
            void conftest_on_each_cpu(void) {
                on_each_cpu(NULL, NULL, 0, 0);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#define NV_ON_EACH_CPU_PRESENT" >> conftest.h
                echo "#define NV_ON_EACH_CPU_ARGUMENT_COUNT 4 " >> conftest.h
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <linux/smp.h>
            void conftest_on_each_cpu(void) {
                on_each_cpu(NULL, NULL, 0);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#define NV_ON_EACH_CPU_PRESENT" >> conftest.h
                echo "#define NV_ON_EACH_CPU_ARGUMENT_COUNT 3 " >> conftest.h
                return
            else
                echo "#error on_each_cpu() conftest failed!" >> conftest.h
            fi
        ;;

        acpi_evaluate_integer)
            #
            # Determine if the acpi_evaluate_integer() function is
            # present and the type of its 'data' argument.
            #

            echo "$CONFTEST_PREAMBLE
            #include <acpi/acpi_bus.h>
            acpi_status acpi_evaluate_integer(acpi_handle h, acpi_string s,
                struct acpi_object_list *l, unsigned long long *d) {
                return AE_OK;
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#define NV_ACPI_EVALUATE_INTEGER_PRESENT" >> conftest.h
                echo "typedef unsigned long long nv_acpi_integer_t;" >> conftest.h
                return
            fi

            echo "$CONFTEST_PREAMBLE
            #include <acpi/acpi_bus.h>
            acpi_status acpi_evaluate_integer(acpi_handle h, acpi_string s,
                struct acpi_object_list *l, unsigned long *d) {
                return AE_OK;
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#define NV_ACPI_EVALUATE_INTEGER_PRESENT" >> conftest.h
                echo "typedef unsigned long nv_acpi_integer_t;" >> conftest.h
                return
            else
                #
                # We can't report a compile test failure here because
                # this is a catch-all for both kernels that don't
                # have acpi_evaluate_integer() and kernels that have
                # broken header files that make it impossible to
                # tell if the function is present.
                #
                echo "#undef NV_ACPI_EVALUATE_INTEGER_PRESENT" >> conftest.h
                echo "typedef unsigned long nv_acpi_integer_t;" >> conftest.h
            fi
        ;;

        ioremap_wc)
            #
            # Determine if the ioremap_wc() function is present.
            #
            echo "$CONFTEST_PREAMBLE
            #include <asm/io.h>
            void conftest_ioremap_wc(void) {
                ioremap_wc(NULL);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                echo "#undef NV_IOREMAP_WC_PRESENT" >> conftest.h
                return
            else
                echo "#define NV_IOREMAP_WC_PRESENT" >> conftest.h
                return
            fi
        ;;

        proc_dir_entry)
            #
            # Determine if the 'proc_dir_entry' structure has 
            # an 'owner' member.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/proc_fs.h>
            int conftest_proc_dir_entry(void) {
                return offsetof(struct proc_dir_entry, owner);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_PROC_DIR_ENTRY_HAS_OWNER" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#undef NV_PROC_DIR_ENTRY_HAS_OWNER" >> conftest.h
                return
            fi
        ;;

        agp_memory)
            #
            # Determine if the 'agp_memory' structure has
            # a 'pages' member.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/types.h>
            #include <linux/agp_backend.h>
            int conftest_agp_memory(void) {
                return offsetof(struct agp_memory, pages);
            }" > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                echo "#define NV_AGP_MEMORY_HAS_PAGES" >> conftest.h
                rm -f conftest$$.o
                return
            else
                echo "#undef NV_AGP_MEMORY_HAS_PAGES" >> conftest.h
                return
            fi
        ;;

    esac
}

build_cflags

case "$5" in
    cc_sanity_check)
        #
        # Check if the selected compiler can create executables
        # in the current environment.
        #
        VERBOSE=$6

        echo "#include <stdio.h>
        int main(int argc, char *argv[]) {
            return 0;
        }" > conftest$$.c

        $HOSTCC -o conftest$$ conftest$$.c > /dev/null 2>&1
        rm -f conftest$$.c

        if [ ! -x conftest$$ ]; then
            if [ "$VERBOSE" = "full_output" ]; then
                echo "";
            fi
            if [ "$CC" != "cc" ]; then
                echo "The C compiler '$CC' does not appear to be able to"
                echo "create executables.  Please make sure you have "
                echo "your Linux distribution's libc development package"
                echo "installed and that '$CC' is a valid C compiler";
                echo "name."
            else
                echo "The C compiler '$CC' does not appear to be able to"
                echo "create executables.  Please make sure you have "
                echo "your Linux distribution's gcc and libc development"
                echo "packages installed."
            fi
            if [ "$VERBOSE" = "full_output" ]; then
                echo "";
                echo "*** Failed CC sanity check. Bailing out! ***";
                echo "";
            fi
            exit 1
        else
            rm conftest$$
            exit 0
        fi
    ;;

    cc_version_check)
        #
        # Verify that the same compiler is used for the kernel and kernel
        # module.
        #
        VERBOSE=$6
        
        if [ -n "$IGNORE_CC_MISMATCH" -o -n "$SYSSRC" -o -n "$SYSINCLUDE" ]; then
          #
          # The user chose to disable the CC version test (which may or
          # may not be wise) or is building the module for a kernel not
          # currently running, which renders the test meaningless.
          #
          exit 0
        fi

        rm -f gcc-version-check
        $CC gcc-version-check.c -o gcc-version-check > /dev/null 2>&1
        if [ ! -f gcc-version-check ]; then
            if [ "$CC" != "cc" ]; then
                MSG="Could not compile 'gcc-version-check.c'.  Please be "
                MSG="$MSG sure you have your Linux distribution's libc "
                MSG="$MSG development package installed and that '$CC' "
                MSG="$MSG is a valid C compiler name."
            else
                MSG="Could not compile 'gcc-version-check.c'.  Please be "
                MSG="$MSG sure you have your Linux distribution's gcc "
                MSG="$MSG and libc development packages installed."
            fi
            RET=1
        else
            PROC_VERSION="/proc/version"
            if [ -f $PROC_VERSION ]; then
                MSG=`./gcc-version-check "$(cat $PROC_VERSION)"`
                RET=$?
            else
                MSG="$PROC_VERSION does not exist."
                RET=1
            fi
            rm -f gcc-version-check
        fi

        if [ "$RET" != "0" ]; then
            #
            # The gcc version check failed
            #
            
            if [ "$VERBOSE" = "full_output" ]; then
                echo "";
                echo "gcc-version-check failed:";
                echo "";
                echo "$MSG" | fmt -w 52
                echo "";
                echo "If you know what you are doing and want to override";
                echo "the gcc version check, you can do so by setting the";
                echo "IGNORE_CC_MISMATCH environment variable to \"1\".";
                echo "";
                echo "In any other case, set the CC environment variable";
                echo "to the name of the compiler that was used to compile";
                echo "the kernel.";
                echo ""
                echo "*** Failed CC version check. Bailing out! ***";
                echo "";
            else
                echo "$MSG";
            fi
            exit 1;
        else
            exit 0
        fi
    ;;

    kernel_patch_level)
        #
        # Determine the kernel's major patch level; this is only done if we
        # aren't told by KBUILD.
        #
        MAKEFILE=$HEADERS/../Makefile

        if [ -f $MAKEFILE ]; then
            PATCHLEVEL=$(grep "^PATCHLEVEL =" $MAKEFILE | cut -d " " -f 3)

            if [ -z "$PATCHLEVEL" ]; then
                exit 1
            else
                echo $PATCHLEVEL
                exit 0
            fi
        fi
    ;;

    suser_sanity_check)
        #
        # Determine the caller's user id to determine if we have sufficient
        # privileges for the requested operation.
        #
        if [ $(id -ur) != 0 ]; then
            echo "";
            echo "Please run \"make install\" as root.";
            echo "";
            echo "*** Failed super-user sanity check. Bailing out! ***";
            exit 1
        else
            exit 0
        fi
    ;;

    rmmod_sanity_check)
        #
        # Make sure that any currently loaded NVIDIA kernel module can be
        # unloaded.
        #
        MODULE="nvidia"

        if [ -n "$SYSSRC" -o -n "$SYSINCLUDE" ]; then
          #
          # Don't attempt to remove the kernel module if we're not
          # building against the running kernel.
          #
          exit 0
        fi

        if lsmod | grep -wq $MODULE; then
          rmmod $MODULE > /dev/null 2>&1
        fi

        if lsmod | grep -wq $MODULE; then
            #
            # The NVIDIA kernel module is still loaded, most likely because
            # it is busy.
            #
            echo "";
            echo "Unable to remove existing NVIDIA kernel module.";
            echo "Please be sure you have exited X before attempting";
            echo "to install the NVIDIA kernel module.";
            echo "";
            echo "*** Failed rmmod sanity check. Bailing out! ***";
            exit 1
        else
            exit 0
        fi
    ;;

    select_makefile)
        #
        # Select which Makefile to use based on the version of the
        # kernel we are building against: use the kbuild Makefile for
        # 2.6 and newer kernels, and the old Makefile for kernels older
        # than 2.6.
        #
        rm -f Makefile
        RET=1
        VERBOSE=$6
        FILE="linux/version.h"
        SELECTED_MAKEFILE=

        if [ -f $HEADERS/$FILE -o -f $OUTPUT/include/$FILE ]; then
            #
            # We are either looking at a configured kernel source
            # tree or at headers shipped for a specific kernel.
            # Determine the kernel version using a compile check.
            #
            echo "$CONFTEST_PREAMBLE
            #include <linux/version.h>
            #include <linux/utsname.h>
            int main() {
              if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)) {
                return 0;
              } else {
                return 1;
              }
            }" > conftest$$.c

            $HOSTCC $CFLAGS -o conftest$$ conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$ ]; then
                ./conftest$$ > /dev/null 2>&1
                if [ $? = "0" ]; then
                    SELECTED_MFILE=Makefile.kbuild
                else
                    SELECTED_MFILE=Makefile.nvidia
                fi
                rm -f conftest$$
                RET=0
            fi
        else
            MAKEFILE=$HEADERS/../Makefile
            CONFIG=$HEADERS/../.config

            if [ -f $MAKEFILE -a -f $CONFIG ]; then
                #
                # This source tree is not configured, but includes
                # a Makefile and a .config file. If this is a 2.6
                # kernel older than 2.6.6, that's all we require to
                # build the module.
                #
                PATCHLEVEL=$(grep "^PATCHLEVEL =" $MAKEFILE | cut -d " " -f 3)
                SUBLEVEL=$(grep "^SUBLEVEL =" $MAKEFILE | cut -d " " -f 3)

                if [ -n "$PATCHLEVEL" -a $PATCHLEVEL -ge 6 \
                        -a -n "$SUBLEVEL" -a $SUBLEVEL -le 5 ]; then
                    SELECTED_MFILE=Makefile.kbuild
                    RET=0
                fi
            fi
        fi

        if [ "$RET" = "0" ]; then
            # Use rmlite Makefile instead of .kbuild if available
            if [ "$SELECTED_MFILE" = "Makefile.kbuild" -a -f Makefile.rmlite ]; then
                SELECTED_MFILE=Makefile.rmlite
            fi
            ln -s $SELECTED_MFILE Makefile
        else
            echo "If you are using a Linux 2.4 kernel, please make sure";
            echo "you either have configured kernel sources matching your";
            echo "kernel or the correct set of kernel headers installed";
            echo "on your system.";
            echo "";
            echo "If you are using a Linux 2.6 kernel, please make sure";
            echo "you have configured kernel sources matching your kernel";
            echo "installed on your system. If you specified a separate";
            echo "output directory using either the \"KBUILD_OUTPUT\" or";
            echo "the \"O\" KBUILD parameter, make sure to specify this";
            echo "directory with the SYSOUT environment variable or with";
            echo "the equivalent nvidia-installer command line option.";
            echo "";
            echo "Depending on where and how the kernel sources (or the";
            echo "kernel headers) were installed, you may need to specify";
            echo "their location with the SYSSRC environment variable or";
            echo "the equivalent nvidia-installer command line option.";
            echo "";
            if [ "$VERBOSE" = "full_output" ]; then
                echo "*** Unable to determine the target kernel version. ***";
                echo "";
            fi
        fi
#        exit $RET
    ;;

    get_uname)
        #
        # Print UTS_RELEASE from the kernel sources, if the kernel header
        # file ../linux/version.h exists. If it doesn't exist, but a
        # Makefile is found, extract PATCHLEVEL and SUBLEVEL and use them
        # to build the kernel release name.
        #
        # If neither source file is found or if an error occurred, return
        # the output of `uname -r`.
        #
        RET=1
        FILE="linux/version.h"

        if [ -f $HEADERS/$FILE -o -f $OUTPUT/include/$FILE ]; then
            #
            # We are either looking at a configured kernel source
            # tree or at headers shipped for a specific kernel.
            # Determine the kernel version using a compile check.
            #
            FILE="generated/utsrelease.h"
            if [ -f $HEADERS/$FILE -o -f $OUTPUT/include/$FILE ]; then
                echo "$CONFTEST_PREAMBLE
                #include <generated/utsrelease.h>
                int main() {
                    printf(\"%s\", UTS_RELEASE);
                    return 0;
                }" > conftest$$.c
            else
                echo "$CONFTEST_PREAMBLE
                #include <linux/version.h>
                int main() {
                    printf(\"%s\", UTS_RELEASE);
                    return 0;
                }" > conftest$$.c
            fi

            $HOSTCC $CFLAGS -o conftest$$ conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$ ]; then
                ./conftest$$; echo
                rm -f conftest$$
                RET=0
            fi
        else
            MAKEFILE=$HEADERS/../Makefile

            if [ -f $MAKEFILE ]; then
                #
                # This source tree is not configured, but includes
                # the top-level Makefile.
                #
                PATCHLEVEL=$(grep "^PATCHLEVEL =" $MAKEFILE | cut -d " " -f 3)
                SUBLEVEL=$(grep "^SUBLEVEL =" $MAKEFILE | cut -d " " -f 3)

                if [ -n "$PATCHLEVEL" -a -n "$SUBLEVEL" ]; then
                    echo 2.$PATCHLEVEL.$SUBLEVEL
                    RET=0
                fi
            fi
        fi

        if [ "$RET" != "0" ]; then
            uname -r
            exit 1
        else
            exit 0
        fi
    ;;

    rivafb_sanity_check)
        #
        # Check if the kernel was compiled with rivafb support. If so, then
        # exit, since the driver no longer works with rivafb.
        #
        RET=1
        VERBOSE=$6
        FILE="generated/autoconf.h"

        if [ -f $HEADERS/$FILE -o -f $OUTPUT/include/$FILE ]; then
            #
            # We are looking at a configured source tree; verify
            # that its configuration doesn't include rivafb using
            # a compile check.
            #
            echo "$CONFTEST_PREAMBLE
            #ifdef CONFIG_FB_RIVA
            #error CONFIG_FB_RIVA defined!
            #endif
            " > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                RET=0
            fi
        else
            CONFIG=$HEADERS/../.config
            if [ -f $CONFIG ]; then
                if [ -z "$(grep "^CONFIG_FB_RIVA=y" $CONFIG)" ]; then
                    RET=0
                fi
            fi
        fi

        if [ "$RET" != "0" ]; then
            echo "Your kernel was configured to include rivafb support!";
            echo "";
            echo "The rivafb driver conflicts with the NVIDIA driver, please";
            echo "reconfigure your kernel and *disable* rivafb support, then";
            echo "try installing the NVIDIA kernel module again.";
            echo "";
            if [ "$VERBOSE" = "full_output" ]; then
                echo "*** Failed rivafb sanity check. Bailing out! ***";
                echo "";
            fi
            exit 1
        else
            exit 0
        fi
    ;;

    nvidiafb_sanity_check)
        #
        # Check if the kernel was compiled with nvidiafb support. If so, then
        # exit, since the driver doesn't work with nvidiafb.
        #
        RET=1
        VERBOSE=$6
        FILE="generated/autoconf.h"
        if [ -f $HEADERS/$FILE -o -f $OUTPUT/include/$FILE ]; then
            #
            # We are looking at a configured source tree; verify
            # that its configuration doesn't include nvidiafb using
            # a compile check.
            #
            echo "$CONFTEST_PREAMBLE
            #ifdef CONFIG_FB_NVIDIA
            #error CONFIG_FB_NVIDIA defined!
            #endif
            " > conftest$$.c

            $CC $CFLAGS -c conftest$$.c > /dev/null 2>&1
            rm -f conftest$$.c

            if [ -f conftest$$.o ]; then
                rm -f conftest$$.o
                RET=0
            fi
        else
            CONFIG=$HEADERS/../.config
            if [ -f $CONFIG ]; then
                if [ -z "$(grep "^CONFIG_FB_NVIDIA=y" $CONFIG)" ]; then
                    RET=0
                fi
            fi
        fi

        if [ "$RET" != "0" ]; then
            echo "Your kernel was configured to include nvidiafb support!";
            echo "";
            echo "The nvidiafb driver conflicts with the NVIDIA driver, please";
            echo "reconfigure your kernel and *disable* nvidiafb support, then";
            echo "try installing the NVIDIA kernel module again.";
            echo "";
            if [ "$VERBOSE" = "full_output" ]; then
                echo "*** Failed nvidiafb sanity check. Bailing out! ***";
                echo "";
            fi
            exit 1
        else
            exit 0
        fi
    ;;

    xen_sanity_check)
        #
        # Check if the target kernel is a Xen kernel. If so, then exit, since
        # the driver doesn't currently work with Xen.
        #
        VERBOSE=$6

        if [ -n "$IGNORE_XEN_PRESENCE" ]; then
            exit 0
        fi

        if [ "$XEN_PRESENT" != "0" ]; then
            echo "The kernel you are installing for is a Xen kernel!";
            echo "";
            echo "The NVIDIA driver does not currently work on Xen kernels. If ";
            echo "you are using a stock distribution kernel, please install ";
            echo "a variant of this kernel without Xen support; if this is a ";
            echo "custom kernel, please install a standard Linux kernel.  Then ";
            echo "try installing the NVIDIA kernel module again.";
            echo "";
            if [ "$VERBOSE" = "full_output" ]; then
                echo "*** Failed Xen sanity check. Bailing out! ***";
                echo "";
            fi
            exit 1
        else
            exit 0
        fi
    ;;

    patch_check)
        #
        # Check for any "official" patches that may have been applied and
        # construct a description table for reporting purposes.
        #
        PATCHES=""

        for PATCH in patch-*.h; do
            if [ -f $PATCH ]; then
                echo "#include \"$PATCH\"" >> patches.h
                PATCHES="$PATCHES "`echo $PATCH | sed -s 's/patch-\(.*\)\.h/\1/'`
            fi
        done

        echo "static struct {
                const char *short_description;
                const char *description;
              } __nv_patches[] = {" >> patches.h
            for i in $PATCHES; do
                echo "{ \"$i\", NV_PATCH_${i}_DESCRIPTION }," >> patches.h
            done
        echo "{ NULL, NULL } };" >> patches.h

        exit 0
    ;;

    compile_tests)
        #
        # Run a series of compile tests to determine the set of interfaces
        # and features available in the target kernel.
        #
        FILES="linux/semaphore.h"
        shift 5

        rm -f conftest.h
        for i in $*; do compile_test $i; done

        for FILE in $FILES; do
            FILE_DEFINE=NV_`echo $FILE | tr '/.' '_' | tr 'a-z' 'A-Z'`_PRESENT
            if [ -f $HEADERS/$FILE -o -f $OUTPUT/include/$FILE ]; then
                echo "#define $FILE_DEFINE" >> conftest.h
            else
                echo "#undef $FILE_DEFINE" >> conftest.h
            fi
        done

        if [ -n "$SHOW_COMPILE_TEST_RESULTS" -a -f conftest.h ]; then
            cat conftest.h
        fi

        exit 0
    ;;

esac
