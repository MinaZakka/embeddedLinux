#include <stdio.h>
#include "myMathShared.h"

int main()
{
    int addition = sum(2,3);
    int diff = sub(5,3);
    int md = mod(13,7);
    int product = mul(2,3);
    int division = div(10,5);

    printf("%d\n", addition);
    printf("%d\n", diff);
    printf("%d\n", md);
    printf("%d\n", product);
    printf("%d\n", division);
}
