#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/stat.h>

#define CONFIG_FILE "/data/adb/modules/scm/config/config.env"
#define COUNT_FILE "/data/adb/modules/scm/config/count.env"
#define LOG_FILE "/data/adb/modules/scm/config/log.txt"
#define SWITCH "/sys/class/power_supply/battery/input_suspend"

time_t last_mod_time = 0;

void log_and_print(const char *message) {
    FILE *log_file = fopen(LOG_FILE, "a");
    if (log_file != NULL) {
        fprintf(log_file, "%s\n", message);
        fclose(log_file);
    } else {
        perror("无法打开日志文件");
        printf("无法打开日志文件: %s\n", LOG_FILE);
    }
    printf("%s\n", message);
}

void clear_log_file() {
    FILE *log_file = fopen(LOG_FILE, "w");
    if (log_file != NULL) {
        fclose(log_file);
    } else {
        perror("无法清空日志文件");
        printf("无法清空日志文件: %s\n", LOG_FILE);
    }
}

void read_config(const char *config_file, int *start, int *stop, int *stop_current, int *Trickle, int *main_switch, int *stoptime, int *debug) {
    FILE *file = fopen(config_file, "r");
    if (file == NULL) {
        perror("无法打开配置文件");
        return;
    }

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        char key[256], value[256];
        if (sscanf(line, "%[^=]=%s", key, value) == 2) {
            if (strcmp(key, "start") == 0) *start = atoi(value);
            else if (strcmp(key, "stop") == 0) *stop = atoi(value);
            else if (strcmp(key, "stop_current") == 0) *stop_current = atoi(value);
            else if (strcmp(key, "Trickle") == 0) *Trickle = (strcmp(value, "true") == 0);
            else if (strcmp(key, "main_switch") == 0) *main_switch = atoi(value);
            else if (strcmp(key, "stoptime") == 0) *stoptime = atoi(value);
            else if (strcmp(key, "debug") == 0) *debug = (strcmp(value, "true") == 0);
        }
    }
    fclose(file);
}

void update_count_file(const char *count_file, const char *key, int increment) {
    FILE *file = fopen(count_file, "r+");
    if (file == NULL) {
        perror("无法打开计数文件");
        return;
    }

    char line[256];
    long pos = 0;
    int found = 0;
    while (fgets(line, sizeof(line), file)) {
        char key_in_file[256];
        char value_str[256];
        if (sscanf(line, "%[^=]=%s", key_in_file, value_str) == 2) {
            if (strcmp(key_in_file, key) == 0) {
                int current_value = atoi(value_str);
                fseek(file, pos, SEEK_SET);
                fprintf(file, "%s=%d\n", key, current_value + increment);
                found = 1;
                break;
            }
        }
        pos = ftell(file);
    }

    if (!found) {
        fseek(file, 0, SEEK_END);
        fprintf(file, "%s=%d\n", key, increment);
    }

    fclose(file);
}

void read_count_file(const char *count_file, const char *key, int *value) {
    FILE *file = fopen(count_file, "r");
    if (file == NULL) {
        perror("无法打开计数文件");
        *value = 0;
        return;
    }

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        char key_in_file[256];
        char value_str[256];
        if (sscanf(line, "%[^=]=%s", key_in_file, value_str) == 2) {
            if (strcmp(key_in_file, key) == 0) {
                *value = atoi(value_str);
                fclose(file);
                return;
            }
        }
    }

    *value = 0;
    fclose(file);
}

void check_and_reload_config(const char *config_file, int *start, int *stop, int *stop_current, int *Trickle, int *main_switch, int *stoptime, int *debug) {
    struct stat file_stat;
    if (stat(config_file, &file_stat) == 0) {
        if (file_stat.st_mtime != last_mod_time) {
            last_mod_time = file_stat.st_mtime;
            read_config(config_file, start, stop, stop_current, Trickle, main_switch, stoptime, debug);

            time_t now;
            struct tm *tm_info;
            char log_msg[512];
            char timestamp[64];

            time(&now);
            tm_info = localtime(&now);
            strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", tm_info);

            snprintf(log_msg, sizeof(log_msg),
                "%s [配置] 配置文件已更新\n"
                "%s [配置] 已重新加载配置",
                timestamp, timestamp);

            log_and_print(log_msg);
        }
    } else {
        perror("无法获取配置文件状态");
    }
}

int main() {
    int start = 0, stop = 0, stop_current = 0, Trickle = 0, main_switch = 0, stoptime = 10, debug = 0;
    int current = 0, level = 0;
    int was_stopped = 0;

    clear_log_file(); // 清空日志文件

    read_config(CONFIG_FILE, &start, &stop, &stop_current, &Trickle, &main_switch, &stoptime, &debug);

    // 保存配置文件的最后修改时间
    struct stat file_stat;
    if (stat(CONFIG_FILE, &file_stat) == 0) {
        last_mod_time = file_stat.st_mtime;
    } else {
        perror("无法获取配置文件状态");
    }

    // 日志记录配置初始化
    time_t now;
    struct tm *tm_info;
    char log_msg[512];
    char timestamp[64];

    time(&now);
    tm_info = localtime(&now);
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", tm_info);

    snprintf(log_msg, sizeof(log_msg),
             "%s [配置] 已开启定量停充\n"
             "%s [配置] 停止电量：%d%%\n"
             "%s [配置] 恢复电量：%d%%\n"
             "%s [配置] 停充电流：%dµA\n"
             "%s [配置] 完全充满：%s\n"
             "%s [配置] 调试日志：%s",
             timestamp, timestamp, stop, timestamp, start, timestamp, stop_current, timestamp, Trickle ? "true" : "false", timestamp, debug ? "true" : "false");

    log_and_print(log_msg);

    while (1) {
        check_and_reload_config(CONFIG_FILE, &start, &stop, &stop_current, &Trickle, &main_switch, &stoptime, &debug);

        if (main_switch != 1) {
            snprintf(log_msg, sizeof(log_msg), "%s 主开关已关闭，程序终止", timestamp);
            log_and_print(log_msg);
            break;
        }

        FILE *switch_file = fopen(SWITCH, "w");
        if (switch_file == NULL) {
            perror("无法打开充电开关文件");
            sleep(stoptime);
            continue;
        }

        // 获取电量和电流
        FILE *current_file = fopen("/sys/class/power_supply/battery/current_now", "r");
        if (current_file == NULL) {
            perror("无法读取电流文件");
            fclose(switch_file);
            sleep(stoptime);
            continue;
        }
        fscanf(current_file, "%d", &current);
        current = abs(current);
        fclose(current_file);

        FILE *level_file = popen("dumpsys battery | grep level | awk '{print $NF}'", "r");
        if (level_file == NULL) {
            perror("无法读取电量");
            fclose(switch_file);
            sleep(stoptime);
            continue;
        }
        fscanf(level_file, "%d", &level);
        pclose(level_file);

        time(&now);
        tm_info = localtime(&now);
        strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", tm_info);

        // 恢复充电逻辑
        if (level == start && was_stopped) {
            fprintf(switch_file, "0");
            snprintf(log_msg, sizeof(log_msg), "%s [信息] 电量: %d | 电流: %d | 已恢复充电", timestamp, level, current);
            log_and_print(log_msg);
            update_count_file(COUNT_FILE, "start_count", 1);
            was_stopped = 0;
        }

        // 停止充电逻辑
        if (Trickle) {
            if (level == stop && current <= stop_current && !was_stopped) {
                fprintf(switch_file, "1");
                snprintf(log_msg, sizeof(log_msg), "%s [信息] 电量: %d | 电流: %d | 已停止充电", timestamp, level, current);
                log_and_print(log_msg);
                update_count_file(COUNT_FILE, "stop_count", 1); 
                was_stopped = 1;
            }
        } else {
            if (level == stop && !was_stopped) {
                fprintf(switch_file, "1");
                snprintf(log_msg, sizeof(log_msg), "%s [信息] 电量: %d | 电流: %d | 已停止充电", timestamp, level, current);
                log_and_print(log_msg);
                update_count_file(COUNT_FILE, "stop_count", 1);
                was_stopped = 1; 
            }
        }

        // 调试信息
        int start_count, stop_count;
        read_count_file(COUNT_FILE, "start_count", &start_count);
        read_count_file(COUNT_FILE, "stop_count", &stop_count);
        if (debug == 1) {
            snprintf(log_msg, sizeof(log_msg), "%s [调试] 电量: %d | 电流: %d | 状态 %d", timestamp, level, current, was_stopped);
            log_and_print(log_msg);
            snprintf(log_msg, sizeof(log_msg), "%s [调试] start_count: %d | stop_count: %d", timestamp, start_count, stop_count);
            log_and_print(log_msg);
        }
        fclose(switch_file);
        sleep(stoptime); // 休眠时间，等同于脚本中的 $stoptime
    }

    return 0;
}
