/*
    Evelina Temnolonskyte's, VU Software engineering 1 course 4.2 group student's,
    program, which is created for finding the most frequent integer number for n inputed numbers,
     where n - is the quantity of numbers, which will be entered by user. The program can detect the incorrect input
     and tell about it and give one more try.
*/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#define CAPACITY 1000

void mostFrequent(int *numbers, int counter1)
{
    int maxcount = 0;
    int elementHavingMaxFreq;
    int elements = 0;
    int elementHavingMaxFreqArray[CAPACITY];

    for (int i = 0; i < counter1; ++i) {

        int counter2 = 0;

        for (int j = 0; j < counter1; ++j) {
            if (numbers[i] == numbers[j])
                counter2++;
        }

        if ((i == 0)&&(counter2 > maxcount)) {
            maxcount = counter2;
            elementHavingMaxFreq = numbers[i];
        }

         if (counter2 == maxcount) {
                elementHavingMaxFreqArray[0] = elementHavingMaxFreq;
                elementHavingMaxFreqArray[++elements] = numbers[i];

    }
        if((i!=0)&&(counter2 > maxcount)){
            maxcount = counter2;
            elementHavingMaxFreq = numbers[i];
            memset(elementHavingMaxFreqArray, 0, sizeof (elementHavingMaxFreqArray));
            elements = 0;
        }
}

     for (int  i = 0; i < elements ; i++)
    {
        for (int j = i + 1; j < elements ; j++)
        {
            if ( elementHavingMaxFreqArray[i] == elementHavingMaxFreqArray[j])
            {
                for ( int k = j; k < elements - 1; k++)
                {
                    elementHavingMaxFreqArray[k] = elementHavingMaxFreqArray[k + 1];
                }
                elements--;
                j--;
            }
        }
    }

    for (int i = 0; i < elements  ; ++i){
    printf("The most frequent number is: %d  \n" , elementHavingMaxFreqArray[i]);
    }
}

int Validation(int numberForCheck){
    int ok = 0;
    while(ok != 1){
        printf("\n");
        printf(" How many numbers will be in your sequence? : ");

        if((scanf("%d", & numberForCheck) == 1) && (getchar() == '\n')){

         if ((numberForCheck > 0)){
            printf ("Number was entered successfully \n");
            printf ("\n");
            ok++;
         }
         else{
             printf ("Incorrect input. Please, enter integer bigger than 0!: ");
         }

    }else {
         printf ("Incorrect input. Please, enter integer bigger than 0!: ");
         while(getchar() != '\n')
            ;
    }}

    return numberForCheck;
}

int main()
{
    int n;                              //n - quantity of numbers
    int number, numbers[CAPACITY];
    int ok = 0 ;
    int i = 0;
    int counter1 = 1;
    printf(" This program will find the number of sequence, which output most frequent number from the sequence\n ");

    int numberQuantity = Validation(n);

    while ( i < numberQuantity){
        printf("Enter %d number : ", counter1);
        if((scanf("%d", &number) == 1) && (getchar() == '\n')){
         printf ("Number was entered successfully \n");
         printf ("\n");
         numbers[i] = number;
         ok++;
         i++;
         counter1++;


    }else {
         printf ("Incorrect input. Please, enter integer!  \n");
         while(getchar() != '\n')
            ;
    }}

    mostFrequent(numbers, counter1);

    return 0;
}
