// // Insertion Sort
// #include <stdint.h>
// extern unsigned int array_size;
// extern short array_addr;
// extern short _test_start;


// // const short* array = &array_addr;
// // short* dest = &_test_start;

// int main() {
// 	unsigned int i,j;

//     for(i=0;i<array_size-1;i=i+1){
//         int swap=1;
//         for(j=0;j<array_size-1-i;j++){
//             if((&array_addr)[j+1]<(&array_addr)[j]){
//                 swap = 0;
//                 (&array_addr)[j+1] ^= (&array_addr)[j];
//                 (&array_addr)[j] ^= (&array_addr)[j+1];
//                 (&array_addr)[j+1] ^= (&array_addr)[j];
//             }
//         if(swap) break;
//         }
//     }

//     for(i=0;i<array_size;i++){
//         (&_test_start)[i] = (&array_addr)[i];
//     }
//     return 0;
// }

// #include <stdint.h>

// extern unsigned int array_size;
// extern short array_addr;
// extern short _test_start;

// // const short* array = &array_addr;
// // short* dest = &_test_start;

// int main() {
//     unsigned int i, j;
//     short key;

//     for (i = 1; i < array_size; i++) {
//         key = (&array_addr)[i];
//         j = i - 1;

//         while (j >= 0 && (&array_addr)[j] > key) {
//             (&array_addr)[j + 1] = (&array_addr)[j];
//             j = j - 1;
//         }

//         (&array_addr)[j + 1] = key;
//     }

//     for (i = 0; i < array_size; i++) {
//         (&_test_start)[i] = (&array_addr)[i];
//     }

//     return 0;
// }

extern unsigned int array_size;
extern short array_addr;
extern short _test_start;
int main(void)
{

  int i, j, key;

  for (i = 1; i < array_size; i++)
  {
    key = (&array_addr)[i];
    j = i - 1;

    while (j >= 0 && (&array_addr)[j] > key)
    {
      (&array_addr)[j + 1] = (&array_addr)[j];
      j = j - 1;
    }

    (&array_addr)[j + 1] = key;
  }

  for (i = 0; i < array_size; i++)
  {
    (&_test_start)[i] = (&array_addr)[i];
  }

  return 0;
}