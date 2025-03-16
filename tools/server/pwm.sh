$ cat /sys/class/hwmon/hwmon0/pwm?

$ ls /sys/class/hwmon/hwmon0/pwm1*
/sys/class/hwmon/hwmon0/pwm1
/sys/class/hwmon/hwmon0/pwm1_auto_point1_pwm
/sys/class/hwmon/hwmon0/pwm1_auto_point1_temp
ys/class/hwmon/hwmon0/pwm1_auto_point2_pwm
/sys/class/hwmon/hwmon0/pwm1_auto_point2_temp
/sys/class/hwmon/hwmon0/pwm1_auto_point3_pwm
/sys/class/hwmon/hwmon0/pwm1_auto_point3_temp
/sys/class/hwmon/hwmono/pwm1_auto_point4_pwm
/sys/class/hwmon/hwmon0/pwm1_auto_point4_temp
/sys/class/hwmon/hwmon0/pwm1_auto_point5_pwm
/sys/class/hwmon/hwmon0/pwm1_auto_point5_temp
/sys/class/hwmon/hwmon0/pwm1_crit_temp_tolerance
/sys/class/hwmon/hwmon0/pwm1_enable
/sys/class/hwmon/hwmon0/pwm1_floor
/sys/class/hwmon/hwmon0/pwm1_mode
/sys/class/hwmon/hwmon0/pwm1_start
/sys/class/hwmon/hwmon0/pwm1_step_down_time
/sys/class/hwmon/hwmon0/pwm1_step_up_time
/sys/class/hwmon/hwmon0/pwm1_stop_time
/sys/class/hwmon/hwmon0/pwm1_target_temp
/sys/class/hwmon/hwmon0/pwm1_temp_sel

/sys/class/hwmon/hwmon0/pwm1_temp_tolerance
/sys/class/hwmon/hwmon0/pwm1_weight_duty_base
/sys/class/hwmon/hwmon0/pwm1_weight_duty_step
/sys/class/hwmon/hwmon0/pwm1_weight_temp_sel
/sys/class/hwmon/hwmon0/pwm1_weight_temp_step
/sys/class/hwmon/hwmon0/pwm1_weight_temp_step_base
/sys/class/hwmon/hwmon0/pwm1_weight_temp_step_tol

$ cat /sys/class/hwmon/hwmon0/pwm1_mode
1
$ cat /sys/class/hwmon/hwmon0/pwm1_enable
5
$ echo 1 | udo tee /sys/class/hwmon/hwmon0/pwm1_enable
1
$ echo 255 | sudo tee /sys/class/hwmon/hwmon0/pwm1
255
$ echo 127 | sudo tee /sys/class/hwmon/hwmon0/pwm1
127
