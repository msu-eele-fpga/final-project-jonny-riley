/****************************************
** Timer.c, reaction time driver, EELE467 final
** Riley Holmes, Jonny Hughes
** 12/11/24
*****************************************/



#include <linux/module.h>
#include <linux/types.h>
#include <linux/platform_device.h>
#include <linux/miscdevice.h>
#include <linux/mod_devicetable.h>
#include <linux/mutex.h>
#include <linux/io.h>
#include <linux/fs.h>
#include <linux/kstrtox.h>

#define START_OFFSET 0x00;
#define TIME_OUT_OFFSET 0x04;

/**
* struct timer_dev - Private led patterns device struct.
* @base_addr: Pointer to the component's base address
* @start: Address of the timer start register
* @time_out: Address of the time_out register
* @miscdev: miscdevice used to create a character device
* @lock: mutex used to prevent concurrent writes to memory
* An timer_dev struct gets created for each led patterns component.
*/
struct timer_dev {
    void __iomem *base_addr;
    void __iomem *start;
    void __iomem *time_out;
    struct miscdevice miscdev;
    struct mutex lock;
};

/**
* start_show() - Return the start value to user-space via sysfs.
* @dev: Device structure for the timer component. This
* device struct is embedded in the timer' platform
* device struct.
* @attr: Unused.
* @buf: Buffer that gets returned to user-space.
* Return: The number of bytes read.
*/
static ssize_t start_show(struct device *dev,
    struct device_attribute *attr, char *buf)
{
    u32 start;
    struct timer_dev *priv = dev_get_drvdata(dev);

    start = ioread32(priv->start);

    return scnprintf(buf, PAGE_SIZE, "%u\n", start);
}


/**
* start_store() - Store the start value.
* @dev: Device structure for the timer component. This
* device struct is embedded in the timer' platform
* device struct.
* @attr: Unused.
* @buf: Buffer that contains the start value being written.
* @size: The number of bytes being written.
* Return: The number of bytes stored.
*/
static ssize_t start_store(struct device *dev,
    struct device_attribute *attr, const char *buf, size_t size)
{
    u32 start;
    int ret;
    struct timer_dev *priv = dev_get_drvdata(dev);

    // Parse the string we received as a u32
    // See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289
    ret = kstrtou32(buf, 0, &start);
    if (ret < 0) {
        return ret;
    }

    iowrite32(start, priv->start);

    // Write was successful, so we return the number of bytes we wrote.
    return size;
}


/**
* time_out_show() - Return the time_out value to user-space via sysfs.
* @dev: Device structure for the timer component. This
* device struct is embedded in the timer' platform
* device struct.
* @attr: Unused.
* @buf: Buffer that gets returned to user-space.
* Return: The number of bytes read.
*/
static ssize_t time_out_show(struct device *dev,
    struct device_attribute *attr, char *buf)
{
    u32 time_out;
    struct timer_dev *priv = dev_get_drvdata(dev);
    
    time_out = ioread32(priv->time_out);

    return scnprintf(buf, PAGE_SIZE, "%u\n", time_out);
}

/**
* time_out_store() - Store the time_out value.
* @dev: Device structure for the timer component. This
* device struct is embedded in the timer' platform
* device struct.
* @attr: Unused.
* @buf: Buffer that contains the time_out value being written.
* @size: The number of bytes being written.
* Return: The number of bytes stored.
*/
static ssize_t time_out_store(struct device *dev,
    struct device_attribute *attr, const char *buf, size_t size)
{
    u32 time_out;
    int ret;
    struct timer_dev *priv = dev_get_drvdata(dev);

    ret = kstrtou32(buf, 0, &time_out);
    if (ret < 0) {
    // kstrtou32 returned an error
        return ret;
    }

    iowrite32(time_out, priv->time_out);

    // Write was successful, so we return the number of bytes we wrote.
    return size;
}

// Define sysfs attributes
static DEVICE_ATTR_RW(start);
static DEVICE_ATTR_RW(time_out);

// Create an attribute group so the device core can
// export the attributes for us.
static struct attribute *timer_attrs[] = {
    &dev_attr_start.attr,
    &dev_attr_time_out.attr,
    NULL,
};
ATTRIBUTE_GROUPS(timer);


/**
* timer_read() - Read method for the timer char device
* @file: Pointer to the char device file struct.
* @buf: User-space buffer to read the value into.
* @count: The number of bytes being requested.
* @offset: The byte offset in the file being read from.
*
* Return: On success, the number of bytes written is returned and the
* offset @offset is advanced by this number. On error, a negative error
* value is returned.
*/
static ssize_t timer_read(struct file *file, char __user *buf,
                                size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;
    int SPAN = 16;
    /*
    * Get the device's private data from the file struct's private_data
    * field. The private_data field is equal to the miscdev field in the
    * timer_dev struct. container_of returns the
    * timer_dev struct that contains the miscdev in private_data.
    */
    struct timer_dev *priv = container_of(file->private_data,
    struct timer_dev, miscdev);
    // Check file offset to make sure we are reading from a valid location.
    if (*offset < 0) {
        // We can't read from a negative file position.
        return -EINVAL;
    }
    if (*offset >= SPAN) {
        // We can't read from a position past the end of our device.
        return 0;
    }
    if ((*offset % 0x4) != 0) {
        // Prevent unaligned access.
        pr_warn("timer_read: unaligned access\n");
        return -EFAULT;
    }

    val = ioread32(priv->base_addr + *offset);

    // Copy the value to userspace.
    ret = copy_to_user(buf, &val, sizeof(val));
    if (ret == sizeof(val)) {
        pr_warn("timer_read: nothing copied\n");
        return -EFAULT;
    }

    // Increment the file offset by the number of bytes we read.
    *offset = *offset + sizeof(val);
    return sizeof(val);
}

/**
* timer_write() - Write method for the timer char device
* @file: Pointer to the char device file struct.
* @buf: User-space buffer to read the value from.
* @count: The number of bytes being written.
* @offset: The byte offset in the file being written to.
*
* Return: On success, the number of bytes written is returned and the
* offset @offset is advanced by this number. On error, a negative error
* value is returned.
*/
static ssize_t timer_write(struct file *file, const char __user *buf,
                                    size_t count, loff_t *offset)
    {
    int SPAN = 16;
    size_t ret;
    u32 val;

    struct timer_dev *priv = container_of(file->private_data,
    struct timer_dev, miscdev);

    if (*offset < 0) {
        return -EINVAL;
    }
        if (*offset >= SPAN) {
        return 0;
    }
    if ((*offset % 0x4) != 0) {
        pr_warn("timer_write: unaligned access\n");
        return -EFAULT;
    }

    mutex_lock(&priv->lock);
    // Get the value from userspace.
    ret = copy_from_user(&val, buf, sizeof(val));
    if (ret != sizeof(val)) {
        iowrite32(val, priv->base_addr + *offset);

        // Increment the file offset by the number of bytes we wrote.
        *offset = *offset + sizeof(val);

        // Return the number of bytes we wrote.
        ret = sizeof(val);
    }
    else {
        pr_warn("timer_write: nothing copied from user space\n");
        ret = -EFAULT;
    }

    mutex_unlock(&priv->lock);
    return ret;
}




/**
* timer_fops - File operations supported by the
*
timer driver
* @owner: The timer driver owns the file operations; this
* ensures that the driver can't be removed while the
* character device is still in use.
* @read: The read function.
* @write: The write function.
* @llseek: We use the kernel's default_llseek() function; this allows
* users to change what position they are writing/reading to/from.
*/
static const struct file_operations timer_fops = {
    .owner = THIS_MODULE,
    .read = timer_read,
    .write = timer_write,
    .llseek = default_llseek,
};

static int timer_probe(struct platform_device *pdev)
{
    struct timer_dev *priv;  
    size_t ret;

    /*
    * Allocate kernel memory for the led patterns device and set it to 0.
    * GFP_KERNEL specifies that we are allocating normal kernel RAM;
    * see the kmalloc documentation for more info. The allocated memory
    * is automatically freed when the device is removed.
    */
    priv = devm_kzalloc(&pdev->dev, sizeof(struct timer_dev),
                        GFP_KERNEL);
    if (!priv) {
        pr_err("Failed to allocate memory\n");
        return -ENOMEM;
    }
    /*
    * Request and remap the device's memory region. Requesting the region
    * make sure nobody else can use that memory. The memory is remapped
    * into the kernel's virtual address space because we don't have access
    * to physical memory locations.
    */
    priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
    if (IS_ERR(priv->base_addr)) {
        pr_err("Failed to request/remap platform device resource\n");
        return PTR_ERR(priv->base_addr);
    }

    // Set the memory addresses for each register.
    priv->start = priv->base_addr + START_OFFSET;
    priv->time_out = priv->base_addr + TIME_OUT_OFFSET;

    // Initialize the misc device parameters
    priv->miscdev.minor = MISC_DYNAMIC_MINOR;
    priv->miscdev.name = "timer";
    priv->miscdev.fops = &timer_fops;
    priv->miscdev.parent = &pdev->dev;

    // Register the misc device; this creates a char dev at /dev/timer
    ret = misc_register(&priv->miscdev);
    if (ret) {
        pr_err("Failed to register misc device");
        return ret;
    }

    /* Attach the led patterns's private data to the platform device's struct.
    * This is so we can access our state container in the other functions.
    */
    platform_set_drvdata(pdev, priv);
    pr_info("timer_probe successful\n");
    return 0;
}


static int timer_remove(struct platform_device *pdev)
{
    // Get the led patterns's private data from the platform device.
    struct timer_dev *priv = platform_get_drvdata(pdev);

    // Deregister the misc device and remove the /dev/timer file.
    misc_deregister(&priv->miscdev);
    pr_info("timer_remove successful\n");
    return 0;
}

static const struct of_device_id timer_of_match[] = {
    { .compatible = "adsd,timer", },
    { }
};
MODULE_DEVICE_TABLE(of, timer_of_match);


/*
* struct timer_driver - Platform driver struct for the timer driver
* @probe: Function that's called when a device is found
* @remove: Function that's called when a device is removed
* @driver.owner: Which module owns this driver
* @driver.name: Name of the timer driver
* @driver.of_match_table: Device tree match table
*/
static struct platform_driver timer_driver = {
    .probe = timer_probe,
    .remove = timer_remove,
    .driver = {
        .owner = THIS_MODULE,
        .name = "timer",
        .of_match_table = timer_of_match,
        .dev_groups = timer_groups,
    },
};

module_platform_driver(timer_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Jonathon Hughes Riley Holmes");
MODULE_DESCRIPTION("timer driver");





