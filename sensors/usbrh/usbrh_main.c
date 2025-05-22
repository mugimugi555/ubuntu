// USBRH on Linux/libusb JSON/CSV モード切替版（JSON デフォルト）
// Original Author: Briareos <briareos@dd.iij4u.or.jp>
// Modified by: [Your Name] - JSON Default, CSV Optional
// License: GPLv2

#include <stdio.h>
#include <usb.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#define USBRH_VENDOR  0x1774
#define USBRH_PRODUCT 0x1001

#define d1 -40.00
#define d2 0.01
#define c1 -4
#define c2 0.0405
#define c3 -0.0000028
#define t1 0.01
#define t2 0.00008

double convert_temp(int in) {
    return d1 + d2 * in;
}

double convert_humidity(int in) {
    double tmp = c1 + c2 * in + c3 * (in * in);
    return ((t1 - 25) * (t1 + t2 * in)) + tmp;
}

struct usb_device *searchdevice(unsigned int vendor, unsigned int product, int num) {
    struct usb_bus *bus;
    struct usb_device *dev;
    int count = 0;

    for (bus = usb_get_busses(); bus; bus = bus->next) {
        for (dev = bus->devices; dev; dev = dev->next) {
            if (dev->descriptor.idVendor == vendor && dev->descriptor.idProduct == product) {
                count++;
                if (count == num) return dev;
            }
        }
    }
    return NULL;
}

void usage() {
    puts("USBRH on Linux\nusage: usbrh [-j|-c -o output.csv]\n"
         "  -j : JSON output (default)\n"
         "  -c : CSV output (appends to file)\n"
         "  -o : output CSV file name\n");
}

int main(int argc, char *argv[]) {
    struct usb_device *dev = NULL;
    usb_dev_handle *dh = NULL;
    char buff[8], output_file[256] = "";
    int rc, opt, iTemperature, iHumidity, DeviceNum = 1;
    double temperature = 0, humidity = 0;
    int flag_json = 1, flag_csv = 0;

    while ((opt = getopt(argc, argv, "jco:")) != -1) {
        switch (opt) {
            case 'j': flag_json = 1; flag_csv = 0; break;
            case 'c': flag_csv = 1; flag_json = 0; break;
            case 'o': strncpy(output_file, optarg, sizeof(output_file)); break;
            default: usage(); exit(0);
        }
    }

    usb_init();
    usb_find_busses();
    usb_find_devices();

    dev = searchdevice(USBRH_VENDOR, USBRH_PRODUCT, DeviceNum);
    if (!dev) { puts("USBRH not found"); exit(1); }

    dh = usb_open(dev);
    if (!dh) { puts("usb_open error"); exit(2); }

    if ((rc = usb_set_configuration(dh, dev->config->bConfigurationValue)) < 0) {
        usb_detach_kernel_driver_np(dh, dev->config->interface->altsetting->bInterfaceNumber);
        if ((rc = usb_set_configuration(dh, dev->config->bConfigurationValue)) < 0) {
            printf("usb_set_configuration error: %s\n", usb_strerror());
            usb_close(dh); exit(3);
        }
    }

    if ((rc = usb_claim_interface(dh, dev->config->interface->altsetting->bInterfaceNumber)) < 0) {
        usb_detach_kernel_driver_np(dh, dev->config->interface->altsetting->bInterfaceNumber);
        if ((rc = usb_claim_interface(dh, dev->config->interface->altsetting->bInterfaceNumber)) < 0) {
            puts("usb_claim_interface error"); usb_close(dh); exit(4);
        }
    }

    rc = usb_control_msg(dh, USB_ENDPOINT_OUT + USB_TYPE_CLASS + USB_RECIP_INTERFACE,
                         0x09, 0x02 << 8, 0, buff, 7, 5000);

    if (rc >= 0) {
        usleep(100000);
        rc = usb_bulk_read(dh, 1, buff, 7, 5000);
        iTemperature = buff[2] << 8 | (buff[3] & 0xff);
        iHumidity = buff[0] << 8 | (buff[1] & 0xff);
        temperature = convert_temp(iTemperature);
        humidity = convert_humidity(iHumidity);
    }

    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    char timebuf[64];
    strftime(timebuf, sizeof(timebuf), "%Y-%m-%dT%H:%M:%S%z", t);

    if (flag_json) {
        printf("{\n  \"timestamp\": \"%s\",\n  \"temperature\": %.2f,\n  \"humidity\": %.2f\n}\n", timebuf, temperature, humidity);
    } else if (flag_csv) {
        FILE *fp = stdout;
        if (strlen(output_file) > 0) fp = fopen(output_file, "a");
        if (fp) {
            fprintf(fp, "%s,%.2f,%.2f\n", timebuf, temperature, humidity);
            if (fp != stdout) fclose(fp);
        }
    }

    usb_release_interface(dh, dev->config->interface->altsetting->bInterfaceNumber);
    usb_reset(dh);
    usb_close(dh);
    return 0;
}
