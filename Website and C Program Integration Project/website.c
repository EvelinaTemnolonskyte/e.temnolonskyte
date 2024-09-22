#include <stdio.h>
#include <stdlib.h>
#include "htmlok.h"

#define CAPACITY 9999

int main()
{
    printf("Hello and welcome to this website generator! \nThis program generates a website called \"Christmas recipes\" and there are few default recipes already.\n");
    printf("You can always add recipes by Yourself! Be creative!\n\n");
    char filename[CAPACITY] = "website.html";
    char background[CAPACITY] = "https://images.pexels.com/photos/1303085/pexels-photo-1303085.jpeg";
    char title[CAPACITY] = "recipes";

    FILE* file = fopen(filename, "a+");

    htmlStr(filename);
    htmlTtlBack(filename, title, background);

    htmlText(filename);
    htmlTitlePlus(filename, "CHRISTMAS RECIPES");

    htmlToBox(filename, "Easy Christmas pudding", "A classic light, spiced Christmas pudding - so simple you don't even need any kitchen scales! Takes minutes to make in a microwave!", "https://www.christinascucina.com/wp-content/uploads/2016/12/fullsizeoutput_38f4-1024x751.jpeg");
    htmlToBox(filename, "Gingerbread mince pies", "Combine two very traditional Christmas bakes - gingerbread and mince pies - to create a brilliant modern classic. Top with mini gingerbread people!", "https://www.allrecipes.com/thmb/hRwRpwDL_BHXRaiGPtQMpaP8tO4=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/230238-gingerbread-men-cookies-ddmfs-4x3-1-d291bf57fa9244d98238eac7df53f13d.jpg");
    htmlToBox(filename, "Easy Christmas turkey", "The turkey is cooked high and fast like a chicken, giving it extra crispy skin. It needs longer to rest so the meat can relax and stay succulent!", "https://realfood.tesco.com/media/images/RFO-1400x919-Turkey-23c727e2-8533-44fa-9084-34e4b4038cdd-0-1400x919.jpg");
    htmlToBox(filename, "Easy butter chicken", "Fancy a healthy version of your favourite Friday night curry? Try our easy butter chicken – the meat can be marinaded the day before so you can get ahead on your prep!", "https://images.immediate.co.uk/production/volatile/sites/30/2020/08/butter-chicken-cf6f9e2.jpg?quality=90&webp=true&resize=440,400");
    htmlToBox(filename, "Easy gooey brownies", "Know the secret to gooey brownies? Don’t overcook them, and dot through caramel or chocolates filled with liquid caramel or ganache to help add moisture!", "https://images-gmi-pmc.edge-generalmills.com/7d7380b9-b97b-48e3-81f8-b03c9dcb5cb8.jpg");

    int ok = 0;
    int choice;
    char recipeTitle[CAPACITY];
    char text[CAPACITY];
    char veryImportant[CAPACITY];
    char image[CAPACITY];
    char ch;
    int i;

    do{
      printf("Do you want to add one more recipe? If yes, enter a number. If no, enter 0 or anything you want:\n");
      scanf("%d", &choice);
      if(choice != 0){
            i=0;
            while((ch=getchar())!='\n')
            {
                veryImportant[i] = ch;
                i++;
            }
            veryImportant[i]='\0';
            printf("Enter the title of your recipe\n");
            i=0;
            while((ch=getchar())!='\n')
            {
                recipeTitle[i] = ch;
                i++;
            }
            recipeTitle[i]='\0';
            printf("Enter the description of your recipe\n");

            i=0;
            while((ch=getchar())!='\n')
            {
                text[i] = ch;
                i++;
            }
            text[i]='\0';
            printf("Enter the link of the image\n");
            i=0;
            while((ch=getchar())!='\n')
            {
                image[i] = ch;
                i++;
            }
            image[i]='\0';
            htmlToBox(filename, recipeTitle, text, image);
        }
        else
        	ok = 1;

    } while(ok != 1);

    htmlDivStyle(filename);
    htmlBody(filename);
    htmlContainer(filename);
    htmlBox(filename);
    htmlStyleBody(filename);
    htmlEnd(filename);

   return 0;
}
