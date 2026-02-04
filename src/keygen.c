#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/sha.h>

/**
 * [Portfolio Note] 
 * This module demonstrates hardware-bound key derivation. 
 * In production, it retrieves unique IDs from CPU registers or SD CID.
 * For demonstration, it uses standard Linux system identifiers.
 */

void get_system_id(char *buffer, const char *path) {
    FILE *fp = fopen(path, "r");
    if (fp == NULL) {
        // Fallback for environments without the specific device tree
        strncpy(buffer, "VIRTUAL_HARDWARE_ID_001", 30);
        return;
    }
    if (fgets(buffer, 64, fp) == NULL) {
        strncpy(buffer, "EMPTY_ID_FALLBACK", 30);
    }
    fclose(fp);
    buffer[strcspn(buffer, "\n")] = 0; // Remove newline
}

int main() {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    char cpu_serial[64] = {0};
    char machine_id[64] = {0};
    char combined_seed[256] = {0};
    char final_key_str[65] = {0};

    // 1. Fetch Hardware Identifiers (Demonstration paths)
    get_system_id(cpu_serial, "/proc/device-tree/serial-number");
    get_system_id(machine_id, "/etc/machine-id");

    // 2. Combine seeds with a salt to create a unique fingerprint
    snprintf(combined_seed, sizeof(combined_seed), "%s:%s:SECURE-DEPLOY-SALT", cpu_serial, machine_id);

    // 3. Generate SHA-256 Hash
    SHA256((unsigned char*)combined_seed, strlen(combined_seed), hash);

    // 4. Convert Hash to Hex String
    for (int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        sprintf(&final_key_str[i * 2], "%02x", hash[i]);
    }

    // 5. CRITICAL: Save to key.txt for use by cryptsetup and unlocker
    FILE *key_file = fopen("key.txt", "w");
    if (key_file == NULL) {
        perror("Failed to create key.txt");
        return 1;
    }
    fprintf(key_file, "%s", final_key_str);
    fclose(key_file);

    printf("🔐 Hardware-bound key successfully saved to key.txt\n");

    return 0;
}
