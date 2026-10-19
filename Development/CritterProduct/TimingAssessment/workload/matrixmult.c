#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SIZE 1000

void generateRandomMatrix(int matrix[SIZE][SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            matrix[i][j] = rand() % 100; // Random numbers between 0 and 99
        }
    }
}

void multiplyMatrices(int mat1[SIZE][SIZE], int mat2[SIZE][SIZE], int result[SIZE][SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            result[i][j] = 0;
            for (int k = 0; k < SIZE; k++) {
                result[i][j] += mat1[i][k] * mat2[k][j];
            }
        }
    }
}

int main() {
    static int mat1[SIZE][SIZE];
    static int mat2[SIZE][SIZE];
    static int result[SIZE][SIZE];

    srand(time(NULL));
    generateRandomMatrix(mat1);
    generateRandomMatrix(mat2);
    printf("Multiplying matrices...\n");
    multiplyMatrices(mat1, mat2, result);
    printf("Multiplication complete.\n");
    return 0;
}
