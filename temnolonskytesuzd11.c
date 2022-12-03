#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFER_SIZE 1024
#define LINE_MAX_SIZE 256


FILE* getInputFile() {
    FILE *file;
    char input[] = " ";


    do {
        printf("Enter input file name: ");
        scanf("%s", &input);
        file = fopen(input, "r");
    } while(file == NULL);

    return file;
}

void getContentBlockFromFile(FILE *input_file, char *buffer) {
    fread(buffer, sizeof(char), BUFFER_SIZE - 1, input_file);
    buffer[BUFFER_SIZE - 1] = '\0';
}

char* findLongestWord(char *buffer, char *destination) {
    char temp[LINE_MAX_SIZE] = " ";
    char end_of_line = ' ';

    int max = 0;
    do {
        while (*buffer == '\n') {
            ++buffer;
        }


        sscanf(buffer, "%255[!-~]%c", &temp, &end_of_line);

        if (strlen(temp) > max) {
            max = strlen(temp);
            strcpy(destination, temp);
        }


        buffer += strlen(temp) + 1;

        if (strlen(temp) == LINE_MAX_SIZE - 1) {
            sscanf(buffer, "%[^\n]", temp);
            buffer += strlen(temp);
            break;
        }


        if (*buffer == '\0') {
            break;
        }
    } while (end_of_line != '\n');

    return buffer;
}

int main(int argc, char *argv[]) {
    FILE *input = NULL;
    FILE *output = NULL;

    char *buffer;
    buffer = (char *)calloc(BUFFER_SIZE, sizeof(char));

    if (argc >= 1) {
        input = fopen(argv[1], "r");

        if (input == NULL) {
            input = getInputFile();
        }

        if (argc >= 3) {
            printf("Result is in the %s\n", argv[2]);
            output = fopen(argv[2], "w");
        }
    }

    while (!feof(input)) {
        getContentBlockFromFile(input, buffer);
        int line_counter = 1;
        char longest_word[LINE_MAX_SIZE];


        while (strlen(buffer) > 0) {

            buffer = findLongestWord(buffer, longest_word);

            longest_word[strlen(longest_word)] = '\0';

            if (output == NULL) {
                printf("Line %d: ", line_counter);
                fwrite(longest_word, strlen(longest_word), 1, stdout);
                printf("\n");
            } else {
                fprintf(output, "Line %d: ", line_counter);
                fwrite(longest_word, strlen(longest_word), 1, output);
                fprintf(output, "\n");
            }

            ++line_counter;
        }
    }

    fclose(input);

    if(output != NULL) {
        fclose(output);
    }

    free(buffer);
    return 0;
}

