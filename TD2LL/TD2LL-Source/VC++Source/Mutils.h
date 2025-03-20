#if !defined _MUTILSH
#define _MUTILSH

#include "stdafx.h"
#include <math.h>

typedef double** matrix;
typedef double* vector;
typedef int ** intmatrix;
#define SMALL 1E-5

                                                    

/*a collection of useful numerical techniques*/

void pca(double *input, double *output, int length); /*provisional arguments*/

/*compute the vector mean of a collection of vectors*/

void VectorMean(matrix input, vector output, int vector_length, int no_of_vectors);

/*compute the covariance matrix of a collection of vectors*/

void covariance_matrix(matrix input, matrix output, int vector_length, int no_of_vectors);

void OuterProduct(vector vector_one, vector vector_two, int length_one, int length_two, matrix output);

double InnerProduct(vector vector_one, vector vector_two, int length);

void eigen(matrix initmatrix, int rows, int columns);

void householder(matrix input, int dimension);

void ql(matrix input, int dimension,long int iterations,double limit);

int sign(double x);

void jacobi(matrix input, int dimension, int iterations, double limit);

double absolute(double input);

void ResetMatrix(matrix one, int dimensionone, int dimensiontwo);

void MatrixMultiply(matrix one, matrix two, matrix answer, int rows1  ,int columns1, int columns2);

void CopyMatrix(matrix one, matrix two, int dimensionone, int dimensiontwo);

void Transpose(matrix one, matrix two, int dimensionone, int dimensiontwo);

double sufficiently_small(void); /*returns a sufficiently small value*/

void PrintMatrix(matrix input, int rows, int columns);

void PrintVector(vector input, int length);

void ResetVector(vector one, int dimension);

void EucNormalise(vector one, int length);

void MatrixRandomise(matrix one, int dimensionone, int dimensiontwo, double lower, double upper);

long LongNfrom(long lower, long upper);

double FloatNfrom(long lower, long upper);

void VectorAdd(vector one, vector two, vector answer, int length);

void VectorSubtract(vector one, vector two, vector answer, int length);

void VectorByScalar( vector one, double scalar, vector answer, int length);

double VectorNorm( vector one, int length);

void CopyVector(vector one, vector two, int length);

void Difference(double *one,int length);

void SwapRows(matrix input, int row1, int row2, int dimension);

void ReplaceRow(vector input, vector rowvector, int dimension);

void GetIdentityMatrix(matrix identity, int size);

void MatrixByScalar(matrix input, double scalar, int rows, int columns);

void MatrixAdd(matrix one, matrix two, matrix answer, int rows, int columns);

void AllocateVector(vector input, int length);

void AllocateMatrix( matrix input, int rows, int columns);

void MatrixByVector(matrix input1, vector input2, vector answer, int rows, int columns);

void CrossProduct(vector one, vector two, int lengthone, int lengthtwo, matrix answer);

void AugmentMatrix(matrix aug, matrix one, vector b, int row, int columns);

void AugmentMatrix2(matrix aug, matrix one, matrix two, int row, int columns);

void negate_vector(vector input, int length);

void GaussianElim(matrix left, vector right, int equations, vector solution);

double spherical_arc_distance(vector vector1, vector vector2, int length);

double get_max_value(vector input, int length);

double rectangular_rule(double (*function) (), double lower_limit, double upper_limit, double no_of_subs); /*NUMERICAL INTEGRATION METHOD*/

double round(double one);

void randomise();

void set_matrix_elements(matrix input, int rows, int columns, double value);

void set_matrix_elements_int(intmatrix input, int rows, int columns, int value);

void bubble_sort(double *array, int length);

double vector_element_sum(double *array, int length);

double vector_element_sumsq(double *array, int length);

double frobenius(double** array, int dim1, int dim2);

void AutoCorrelationMatrix(matrix input, matrix output, int i_rows, int i_columns);
double MatrixTrace(matrix input, int n); /*sum of diagonal entries*/
double Pling(double x);
void ReplaceRow(vector input, vector rowvector, int dimension);

int InvertMatrix(matrix input, int size );

int InvertDiagonalMatrix(matrix input, int size);

void EnterMatrix(matrix input,int rows,int columns);
void SaveMatrix(FILE *out, matrix input, int rows, int columns);
void SaveVector(FILE *out, vector input, int dim);


#endif