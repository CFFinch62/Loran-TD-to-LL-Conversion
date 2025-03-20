

/*a collection of useful numerical techniques*/
#include "stdafx.h"
#include "mutils.h"


#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif


 
/*compute the vector mean of a collection of vectors*/ 
 
void VectorMean(matrix input, double *output, int vector_length, int no_of_vectors)
{ 
double *tmp_vector; 
 int l_index;
 int v_index; 
 
tmp_vector = (double*)malloc(sizeof(double) * vector_length); 
 
for(l_index=0;l_index< vector_length; ++l_index) 
  tmp_vector[l_index]=0; 
 
for(l_index=0;l_index < vector_length; ++l_index) 
  for(v_index=0; v_index< no_of_vectors; ++v_index) 
    tmp_vector[l_index] +=input[v_index][l_index]; 
 
for(l_index=0;l_index< vector_length;++l_index) 
{ 
  tmp_vector[l_index]/=no_of_vectors; 
  output[l_index] = tmp_vector[l_index]; 
} 
 
free(tmp_vector); 
} 
 
 
/*compute the covariance matrix of a collection of vectors*/ 
 
void covariance_matrix(matrix input, matrix output, int vector_length, int no_of_vectors) 
{ 
 int v_index;  /*for each vector in the input collection*/ 
 int l_index; 
 int t_index;
matrix scalarofmeans; 
matrix tempscalar; 
 
double *mean_vector; 
 
mean_vector = (double*)malloc(sizeof(double) * vector_length); 

scalarofmeans = (matrix)malloc(sizeof(double*) * vector_length);

for(l_index=0;l_index<vector_length;++l_index)
  scalarofmeans[l_index]=(double*)malloc(sizeof(double) * vector_length);

tempscalar = (matrix)malloc(sizeof(double*) * vector_length);
for(l_index=0;l_index<vector_length;++l_index)
  tempscalar[l_index]=(double*)malloc(sizeof(double) * vector_length);

VectorMean(input,mean_vector,vector_length,no_of_vectors);
OuterProduct(mean_vector,mean_vector,vector_length,vector_length,scalarofmeans);

for(v_index=0;v_index<no_of_vectors;++v_index)
  {
   OuterProduct(input[v_index], input[v_index],vector_length ,vector_length,tempscalar);
   for(t_index=0;t_index<vector_length; ++t_index)
     for(l_index=0;l_index<vector_length;++l_index)
       output[t_index][l_index]+=tempscalar[t_index][l_index];
  }

   for(t_index=0;t_index<vector_length; ++t_index)
     for(l_index=0;l_index<vector_length;++l_index)
       output[t_index][l_index]= (output[t_index][l_index]/no_of_vectors)-scalarofmeans[t_index][l_index];

for(l_index=0;l_index<vector_length;++l_index)
  free (tempscalar[l_index]); //=(double*)malloc(sizeof(double) * vector_length);

free(tempscalar);

for(l_index=0;l_index<vector_length;++l_index)
  free( scalarofmeans[l_index]); //=(double*)malloc(sizeof(double) * vector_length);

free(scalarofmeans);

free(mean_vector);
}


void AutoCorrelationMatrix(matrix input, matrix output, int i_rows, int i_columns)
{
matrix tran;
int index;

tran = (double**)malloc(i_columns*sizeof(double*));

for(index=0;index<i_columns;++index)
	tran[index] = (double*)malloc(sizeof(double)*i_rows);

ResetMatrix(tran,i_columns,i_rows);

Transpose(input,tran,i_rows,i_columns);

MatrixMultiply(tran,input,output,i_rows,i_columns,i_rows);

MatrixByScalar(output,1/(double)i_rows,i_columns,i_columns);

for(index=0;index<i_columns;++index)
	free(tran[index]); // = (double*)malloc(sizeof(double)*i_rows);

free(tran);
}
 
 
void OuterProduct(vector vector_one, vector vector_two, int length_one, int length_two, matrix output)
{
 int index_one;
 int index_two;

for(index_one = 0;index_one<length_one;++index_one)
  for(index_two = 0;index_two<length_two;++index_two)
      output[index_one][index_two] = vector_one[index_one]*vector_two[index_two];

}
 
double InnerProduct(vector vector_one, vector vector_two, int length)
{
 int index;
double sum=0;

for(index=0;index<length;++index)
  sum += vector_one[index]*vector_two[index];

return sum;
} 
 
double spherical_arc_distance(vector vector1, vector vector2, int initlength) 
{ 
vector temp1;
vector temp2; 
double output; 
int length = initlength; 
 
if((temp1 = (double*)malloc(sizeof(double) * length))==NULL)
	{
	printf("Not enough memory\n");
	exit(1);
	}

if((temp2 = (double*)malloc(sizeof(double) * length))==NULL) 
	{ 
	printf("Not enough memory\n"); 
	exit(1); 
	} 
 
 
CopyVector(vector1,temp1,length); 
CopyVector(vector2,temp2,length);
 
EucNormalise(temp1,length); 
EucNormalise(temp2,length);
 
output = 1-InnerProduct(temp1,temp2,length);
 
free(temp1); /*de-allocate memory*/ 
free(temp2); 
 
return output; /*return 0 if very close*/ 
		/*1 if far away*/ 
 
} 
 
 
void householder(matrix input, int dimension) /*matrix is symmetrical*/
{
int k; 
int i; 
double q; 
double s,rsq,temp=0; 
int j; 
int l;
double *v; 
double *u; 
double *z; 
double prod=0; 
 
 
 
q=0; 
printf("Tri-diagonalising matrix...please wait\n"); 
 
v = (double*)malloc(sizeof(double) * dimension); 
u= (double*)malloc(sizeof(double) * dimension); 
z= (double*)malloc(sizeof(double) * dimension); 
 
 
 
for(j=0;j<dimension;++j) 
	{ 
	v[j]=0; 
	u[j]=0; 
	z[j]=0; 
	} 
 
 
for(k=0;k<=dimension-3;++k) 
	{
	i=dimension-k; 
	 
	for(j=0;j<=i-2;++j) 
		q = q + (input[i-1][j]*input[i-1][j]);	 
 
	q=sqrt(q); 
	 
 
	if(input[i-1][i-2]==0) 
		s=q; 
	else 
		s = q*input[i-1][i-2]/absolute(input[i-1][i-2]); 
	 
 
	rsq = (q*q + s*input[i-1][i-2]); 
	 
	if(rsq != 0) 
	{ 
	v[i-1]=0; 
	 
	v[i-2] = input[i-1][i-2] + s; 
 
	if(i>2) 
		{ 
		for(j=0;j<=i-3;++j) 
			v[j] = input[i-1][j]; 
 
		} 
	 
 
	for(j=0;j<=i-1;++j) 
		{ 
		for(l=0;l<=i-2;++l) 
			temp+=input[j][l]*v[l]; 
		u[j] = (1/rsq)*temp;
		temp=0; 
		} 

		 
	for(j=0;j<=i-2;++j) 
		prod += v[j]*u[j]; 
	 
	for(j=0;j<=i-1;++j) 
		z[j] = u[j] -((prod/(2*rsq))*v[j]); 
 
 
	for(l=1;l<=i-2;++l) 
		{ 
		for(j=0;j<=l-1;++j) 
			{ 
			input[l][j] = input[l][j] - v[l]*z[j] - v[j]*z[l]; 
			input[j][l] = input[l][j]; 
			} 
		input[l][l] = input[l][l] - 2*v[l]*z[l]; 
		}	 
	 
 
 
		input[0][0] = input[0][0] - 2*v[0]*z[0]; 
		for(j=0;j<=i-3;++j) 
			{ 
			input[i-1][j] = 0; 
			input[j][i-1] =0; 
			} 
 
		 
		input[i-1][i-2] = input[i-1][i-2] - v[i-2]*z[i-1]; 
 
		input[i-2][i-1] = input[i-1][i-2]; 
 
	}	 
	q=0; 
	prod=0;
	} 

free(z);
free(v);
free(u);

printf("\n");

PrintMatrix(input,dimension,dimension);

printf("\n");  
 
 
} 
 
 
void ql(matrix input, int dimension, long int iterations, double limit) 
{ 
 
double *b,*a,*d; 
 int k; 
 int i; 
 int j; 
double shift; 
double lambda,lambda1,lambda2; 
double mu1,mu2; 
double x,y,z,s; 
double *r,*t,*u,*v,*w,*p,*q; 
 
printf("Computing eigenvalues...please wait\n"); 
 
b=(double*)malloc(sizeof(double) * dimension); 
a=(double*)malloc(sizeof(double) * dimension); 
d=(double*)malloc(sizeof(double) * dimension); 
r=(double*)malloc(sizeof(double) * dimension); 
t=(double*)malloc(sizeof(double) * dimension); 
u=(double*)malloc(sizeof(double) * dimension); 
v=(double*)malloc(sizeof(double) * dimension); 
w=(double*)malloc(sizeof(double) * dimension); 
p=(double*)malloc(sizeof(double) * dimension); 
q=(double*)malloc(sizeof(double) * dimension); 

for(j=0;j<dimension;++j) 
	a[j]=input[j][j]; 

b[0]=0; /*just to be safe*/ 
 
for(j=1;j<dimension;++j) 
	b[j]=input[j-1][j]; 
 
 
k=1; 
shift=0; 
 
while(k<=iterations) 
	{ 
	   
	  printf("."); 
	   
	  if(absolute(b[1])<limit) 
		{ 
		lambda = a[0] + shift; 
		printf("%e\n",lambda); 
		dimension--; 
		a[0]=a[1]; 
		for(j=1;j<dimension;++j) 
			{ 
			a[j]=a[j+1]; 
			b[j]=b[j+1]; 
			} 
		} 
 
	for(j=2;j<=dimension-2;++j) 
			if(absolute(b[j])<limit) 
				{ 
				printf("Split into \n"); 
				for(i=0;i<=j-1;++i) 
					printf("%e ",a[i]); 
				printf("\n"); 
				for(i=1;i<=j-1;++i)
					printf("%e ",b[i]); 
 
				printf("and \n");
				for(i=j;i<=dimension-1;++i) 
					printf("%e ",a[i]); 
				for(i=j+1;j<=dimension-1;++i) 
					printf("%e ",b[i]); 
				printf(" &d",shift); 
 
				exit(0);				 
				} 
	 
	if(absolute(b[dimension-1])<limit) 
		{ 
		lambda = a[dimension-1]+shift; 
		printf("%e\n",lambda); 
		dimension--; 
		} 
 
	/*compute shift*/ 
 
 
	x=-(a[1]+a[0]); 
	y=(a[1]*a[0] - b[1]*b[1]); 
	z=sqrt((x*x-4*y)); 
 
	if(x>0) 
		{ 
		mu1 = -(2*y)/(x+z); 
		mu2 = -(x+z)/2; 
		}	 
	else 
		{ 
		mu1 = (z-x)/2; 
		mu2 = 2*y/(z-x); 
		} 
 
	if(dimension==2)
		{ 
		lambda1 = mu1+shift; 
		lambda2 = mu2+shift;
		printf("%e\n %e\n", lambda1, lambda2); 
		exit(0); 
		} 
	 
	if(absolute(mu2-a[0]) >= absolute(mu1-a[0])) 
		s=mu1; 
	else 
		s=mu2; 
 
	shift+=s; 
	 
/*perform shift*/ 
 
 
	for(j=0;j<dimension;++j) 
		d[j] = a[j]-s;   
 
/*compute l to the k*/ 
 
	p[dimension-1]=d[dimension-1]; 
	q[dimension-1]=b[dimension-1]; 
	 
	for(j=dimension-1;j>=1;--j) 
		{ 
		r[j] = sqrt((p[j]*p[j]) + (b[j]*b[j])); 
		t[j-1]=p[j]/r[j]; 
		u[j-1]=b[j]/r[j]; 
		v[j]=t[j-1]*q[j]+u[j-1]*d[j-1]; 
		p[j-1]=t[j-1]*d[j-1]-u[j-1]*q[j]; 
		if(j!=1) 
			{ 
			w[j] = u[j] =b[j-1]; 
			q[j-1] = t[j-1]*b[j-1]; 
			} 
		}
 
	r[0] = p[0]; 
	a[dimension-1] = u[dimension-2]*v[dimension-1] + t[dimension-2]*r[dimension-1];
	b[dimension-1] = u[dimension-2]*r[dimension-2]; 
		 
 
	for(j=dimension-2;j>=1;--j) 
		{ 
		a[j] = u[j-1]*v[j] + t[j-1]*t[j]*r[j]; 
		b[j] = u[j-1]*r[j-1]; 
		} 
 
	a[0] = t[0]*p[0]; 
	k++; 
	} 
 
printf("\nMaximum number of iterations exceeded\n"); 
free(b); 
free(a); 
free(d); 
free(r); 
free(t); 
free(u); 
free(v); 
free(w); 
free(p); 
free(q); 
 
 
} 
 
 
 
 
 
void jacobi(matrix input, int dimension, int iterations, double limit) 
{ 
int i,j,k,its=0;
matrix p; /*rotation matrix*/ 
matrix p_Transpose; 
double el1,el2;
double b,c;
double error;

/*allocate room for p*/
 
p = (matrix)malloc(sizeof(double*) * dimension); 
p_Transpose = (matrix)malloc(sizeof(double*) * dimension); 
 
for(i=0;i<dimension;++i) 
	{ 
	p[i] = (double*)malloc(sizeof(double) * dimension); 
	p_Transpose[i] = (double*)malloc(sizeof(double) * dimension); 
	} 
	 
 
/*p = (matrix)malloc(sizeof(double*) * dimension); 
	for(j=0;j<dimension;++j) 
		p[j] = (double*)malloc(sizeof(double) * dimension);
*/ 
 
 
ResetMatrix(p,dimension,dimension);
ResetMatrix(p_Transpose, dimension,dimension); 
	 
 
do 
{ 
for(j=0;j<dimension;++j) 
for(k=0;k<j;++k) 
		{ 
		printf("J= %d K= %d \n",j,k); 
		el1 = input[j][j];
		el2 = input[k][k]; 
		if(el1 != el2) 
			{
			c = 2* input[j][k] * sign(input[j][j] - input[k][k]); 
			b = absolute(el1 - el2); 
			p[k][k] = sqrt(0.5 * (1 + (b/sqrt(c*c + b*b))));
			p[j][j] = p[k][k]; 
			p[j][k] = c/(2*p[j][j] * sqrt(c*c + b*b)); 
			p[k][j] = -p[j][k]; 
			} 
	        else 
			{ 
			p[k][k] = sqrt(2)/2; 
			p[j][j] = p[k][k];
			p[k][j] = sqrt(2)/2; 
			p[j][k] = -p[k][j]; 
			} 
		} 
 
error =0; 
for(i=0;i<dimension;++i) 
	for(j=0;j<dimension;++j) 
		{ 
		if(i!=j) 
			error += absolute(input[i][j]); 
		} 
 

Transpose(p,p_Transpose,dimension,dimension); 
MatrixMultiply(p,input,p,dimension,dimension,dimension);
MatrixMultiply(p,p_Transpose,p,dimension,dimension,dimension);
CopyMatrix(p,input,dimension,dimension); 
 
 
its++; 
printf("its: %d\n",its); 
}while(its<iterations && error >=limit); 
 
printf("Finished\n"); 
 
for(i=0;i<dimension;++i) 
	{ 
	free(p[i]); // = (double*)malloc(sizeof(double) * dimension); 
	free(p_Transpose[i]); // = (double*)malloc(sizeof(double) * dimension); 
	} 

free(p);
free(p_Transpose);
 
}
 
 
 
 
void Transpose(matrix one, matrix two, int dimensionone, int dimensiontwo)
{
 
int i,j; 
for(i=0;i<dimensionone;++i)
	for(j=0;j<dimensiontwo;++j)
		two[j][i] = one[i][j];

}

void MatrixMultiply(matrix one, matrix two, matrix answer, int rows1, int columns1, int columns2)
{
int i,l,k;

ResetMatrix(answer, rows1, columns2);

for(k=0;k<rows1;++k)
for(l=0;l<columns2;++l)
	for(i=0;i<columns1;++i)
		answer[k][l] += one[k][i] * two[i][l];
}


void ResetMatrix(matrix one,int dimensionone, int dimensiontwo)
{
int i,j;

for(i=0;i<dimensionone;++i)
	for(j=0;j<dimensiontwo;++j)
		one[i][j] = 0;
 
} 
 
 
void CopyMatrix(matrix one, matrix two, int dimensionone, int dimensiontwo)
{
int i,j; 
 
for(i=0;i<dimensionone;++i) 
	for(j=0;j<dimensiontwo;++j) 
		two[i][j] = one[i][j]; 
} 
 

void CopyVector(vector one, vector two, int length) 
{
int j; 
 
for(j=0;j<length;++j) 
	two[j] = one[j]; 
} 
 

int sign(double x) 
{ 
if(x<0) 
	return -1; 
else
	return 1; 
} 

 
 
 
double sufficiently_small(void) 
{ 
	return 5E-6; 
} 

double absolute(double one)
{
if(one<0)
	return -one;
else
	return one;
}



void PrintMatrix(matrix input, int rows, int columns)
{
 int r_index;
 int c_index;

for(r_index=0;r_index<rows;++r_index)
  {
for(c_index=0;c_index<columns;++c_index)
    printf("%e ",input[r_index][c_index]);
    printf("\n");

 }
}


void PrintVector(vector input, int length) 
{ 
 int index; 
 
for(index=0;index<length;++index)
  printf("%e ", input[index]); 
 
printf("\n"); 
 
 
} 
 
void ResetVector(vector input, int length) 
{
 int i;

for(i=0;i<length;++i)
	input[i] = 0;

}


void EucNormalise(double *one, int length)
{
		int index;
		double sum=0;

		for(index=0;index<length;++index)
			sum+=(one[index]*one[index]);

		sum = sqrt(sum);

		for(index=0;index<length;++index)
			one[index] = one[index]/sum;

}


void matrix_randomise(matrix one, int dimensionone, int dimensiontwo, double lower, double upper)
{
 int i,j;
int stime;
long ltime;
ltime = time(NULL);

stime = ltime/2;

srand(stime);  /*SET SEED FOR RANDOMISATION OF WEIGHTS*/


for(i=0;i<dimensionone;++i)
	for(j=0;j<dimensiontwo;++j)
		one[i][j] = (double)LongNfrom(lower,upper)/100;
 

} 

long LongNfrom(long lower, long upper)
{
long tmp_store;
long nb;

nb=upper-lower;
tmp_store=(rand()%nb)+lower;

return tmp_store;
}


double FloatNfrom(long lower, long upper)
{
double tmp_store;
long nb;

nb=upper-lower;
tmp_store=(rand()%nb)+lower;

return tmp_store;
}

void VectorAdd(vector one, vector two, vector answer, int length)
{

 int i;

for(i=0;i<length;++i)
	answer[i] = one[i] + two[i];

} 
 
void VectorSubtract(vector one, vector two, vector answer, int length) 
{ 
 
int i; 
 
for(i=0;i<length;++i) 
	answer[i] = one[i] - two[i]; 
 
} 
 

void VectorByScalar(vector one, double scalar, vector answer, int length)
{ 
int i;
 
for(i=0;i<length;++i)
	answer[i] = scalar*one[i];
 
 
 
} 
 
double VectorNorm(vector one, int length) 
{ 
int i;
double sum=0; 
 
for(i=0;i<length;++i) 
	sum += one[i]*one[i]; 
 
sum = sqrt(sum);
 
return sum;	 
} 

 
void difference(double *one,int length) 
	{ 
	double temp;
	int index; 
	 
	for(index=0;index<length-1;++index) 
		{ 
		temp=one[index+1]-one[index]; 
		one[index]=temp;
		} 
	one[length-1]=0; 
	} 
 
 
void SwapRows(matrix input, int row1, int row2, int rowdim)
{ 
double temp;
int index; 
 
for(index=0;index<rowdim;++index) 
	{ 
	temp = input[row2][index]; 
	input[row2][index] = input[row1][index];
	input[row1][index] = temp;
	}

}

 
void ReplaceRow(vector input, vector rowvector, int dimension)
{

int index;
for(index=0;index<dimension;++index)
	{
	input[index] = rowvector[index];
   }

}

void GetIdentityMatrix(matrix identity, int size)
{
 int i;
 int j;

for(i=0;i<size;++i)
	for(j=0;j<size;++j)
		{
		if(i==j)
			identity[i][j]=1;
		else
			identity[i][j] =0;
		}

}


void MatrixByScalar(matrix input, double scalar, int rows, int columns)
{

 int i; 
 int j; 
 
for(i=0;i<rows;++i) 
	for(j=0;j<columns;++j) 
		input[i][j]*=scalar; 
 
} 
 
 
void MatrixAdd(matrix one, matrix two, matrix answer,int rows, int columns)
{

 int i;
 int j;

for(i=0;i<rows;++i)
	for(j=0;j<columns;++j)
		answer[i][j] = one[i][j] + two[i][j];
}

void MatrixSubtract(matrix one, matrix two, matrix answer,int rows, int columns)
{
int i;
int j;

for(i=0;i<rows;++i)
	for(j=0;j<columns;++j)
		answer[i][j] = one[i][j] - two[i][j];
}



void MatrixByVector(matrix input1, vector input2, vector answer, int rows, int columns)
{
 int i;
 int j;

ResetVector(answer,rows);

for(i=0;i<rows;++i)
	for(j=0;j<columns;++j)
		answer[i]+=input1[i][j]*input2[j];

}


void CrossProduct(vector one, vector two, int lengthone, int lengthtwo, matrix answer)
{
 int i;
 int j;

for(i=0; i<lengthone;++i)
	for(j=0; j<lengthtwo;++j)
		answer[i][j] = one[i]*two[j];

} 
 

void NegateVector(vector input, int length)
{
 int index;

for(index=0;index<length;++index)
	input[index] = -input[index];
}


void AugmentMatrix(matrix aug, matrix one, vector b, int rows, int columns)
{
 int r_index;
 int c_index;

for(r_index=0;r_index<rows;++r_index)
	{
	for(c_index=0;c_index<columns-1;++c_index)
		aug[r_index][c_index] = one[r_index][c_index];

	aug[r_index][columns-1]=b[r_index];

	}

}

void AugmentMatrix2(matrix aug, matrix one, matrix two, int rows, int columns)
{
 int r_index;
 int c_index;

for(r_index=0;r_index<rows;++r_index)
	{
	for(c_index=0;c_index<columns;++c_index)
   	{
		aug[r_index][c_index] = one[r_index][c_index];
      }

   for(c_index=columns;c_index<2*columns;++c_index)
   	{
		aug[r_index][c_index]=two[r_index][c_index-columns];
      }

	}

}





void GaussianElim(matrix left, vector right, int equations, vector solution)
{

/*n equations in n unknowns*/
matrix aug;
vector temp,temp2;
int i,p,j,n;
double m;
int q=-1;
double sum=0;

n=equations;

temp = (double*)malloc((equations+1) *sizeof(double));
temp2= (double*)malloc((equations+1) * sizeof(double));
aug = (matrix)malloc(equations * sizeof(double*));
for(i=0;i<equations;++i)
	aug[i] = (double*)malloc((equations+1) * sizeof(double));

AugmentMatrix(aug, left, right, equations, equations+1);


for(i=0;i<n-1;++i)
	{

	for(p=n-1;p>=i;--p)
		{
		if(aug[p][i]!=0)
			q=p;
		}

	p=q;

	if(p==(-1))
		{
		printf("No unique solution exists\n");
		exit(0);
		}

	if(p!=i)
		SwapRows(aug,p,i,n+1);

	for(j=i+1;j<n;++j)
		{
		m = aug[j][i]/aug[i][i];
		VectorByScalar(aug[i],m,temp,n+1);
		VectorSubtract(aug[j],temp,temp2,n+1);
		ReplaceRow(aug[j],temp2,n+1);
		}

	}

	/* OK upto now*/

	if(aug[n-1][n-1]==0)
		{
		printf("No unique solution exists\n");

		exit(0);
		}

	solution[n-1] = aug[n-1][n]/aug[n-1][n-1];

	for(i=n-2;i>=0;--i) 
		{ 
		for(j=i+1;j<n;++j) 
			sum+=aug[i][j]*solution[j]; 
 
		solution[i] = (aug[i][n] - sum)/aug[i][i]; 
 
		sum=0; 
		} 
 
 
/*print_vector(solution,equations);*/ 
 
for(i=0;i<equations;++i)
	free(aug[i]); // = (double*)malloc((equations+1) * sizeof(double));

free(aug);
free(temp); 
free(temp2); 
}
 

 
double get_max_value(vector input, int length) 
{ 
double temp=0; 
int index; 
 
for(index=0;index<length;++index) 
	{ 
	if(input[index]>temp)
		temp=input[index]; 
	} 
 
return temp; 
}

/*
double rectangular_rule(double (*function) (), double lower_limit, double upper_limit, double no_of_subs) 
{
double subinterval,integral=0,input;

subinterval = (upper_limit-lower_limit)/no_of_subs;
input = lower_limit;


while(input<=upper_limit)
	{
	integral+=subinterval*(*function)(input);
	input+=subinterval;
	}

return(integral);

}

*/
 
 
double round(double one) 
{
double two,round;
 
two = ceil(one); 
 
	if((two-one) > 0.5) 
		{ 
		round = floor(one); 
		} 
	else 
		round = ceil(one); 
return round; 
 
} 


 
void randomise() 
{ 
int stime; 
long ltime; 
ltime = time(NULL); 
 
stime = ltime/2;  
 
srand(stime);  /*SET SEED FOR RANDOMISATION OF WEIGHTS*/ 
 
} 

 
void set_matrix_elements(matrix input, int rows, int columns, double value) 
{
int r_index,c_index; 
 
 
for(r_index=0;r_index<rows;++r_index) 
	for(c_index=0;c_index<columns;++c_index) 
		input[r_index][c_index] = value; 
 
}
 
void set_matrix_elements_int(intmatrix input, int rows, int columns, int value)
{
int r_index,c_index; 
 

for(r_index=0;r_index<rows;++r_index) 
	for(c_index=0;c_index<columns;++c_index) 
		input[r_index][c_index] = value; 
 
}

void bubble_sort(double *array, int length)
{
int a,b;
double temp;

for(a=1;a<length;++a)
	for(b=length-1; b>=a;--b)
	{
	if(array[b-1] > array[b])
		{
		temp = array[b-1];
		array[b-1] = array[b];
		array[b]=temp;
		}
	}

}

double vector_element_sum(double *array, int length)
{ 
 
int index; 
double sum=0;
 
for(index=0;index<length;++index) 
	sum+=array[index]; 
 
return sum; 
 
}
 
 
double vector_element_sumsq(double *array, int length)
{ 
 
int index; 
double sum=0;
 
for(index=0;index<length;++index) 
	sum+=(array[index]*array[index]); 
 
return sum; 
 
}
 
 
double frobenius(double** array, int dim1, int dim2)
{ 
 
int x,y; 
double sum=0; 
 
for(y=0;y<dim1;++y) 
	for(x=0;x<dim2;++x) 
		sum += array[y][x]*array[y][x];
 
return sqrt(sum); 

}


double MatrixTrace(matrix input, int n) /*sum of diagonal entries*/
{
int i;
double sum=0;


for(i=0;i<n;++i)
	{
      sum+=input[i][i];
   }

return(sum);
}

double Pling(double x)
{
double output=1;
double i;

for(i=1;i<=x;++i)
	{
	output = output*i;
   }

return(output);

}

double LegendrePoly(long order, double x)
{
double sum=0;
double test;
double n_bracket;
double i;
double n;

test = order%2;

n=order;

if(test!=0)
	n_bracket = (n-1)/2;
else
	n_bracket = n/2;


for(i =0 ; i<=n_bracket;++i)
	{
   sum += ( pow(-1,i) * Pling(2*n - 2*i) * pow(x,n-2*i) )/ (Pling(i)*Pling(n-2*i)*Pling(n-i));
   }

sum = sum*(1/pow(2,n));
return(sum);

}


int InvertDiagonalMatrix(matrix input, int size )
{
int i;

for(i=0;i<size;++i)
	{
   if(input[i][i]!=0)
   	{
	   input[i][i] = 1.0/input[i][i];
      }
   else
   	{
      return 0;
      }
   }

return(1);

}

int InvertMatrix(matrix input, int size )
{
matrix identity;
matrix aug;
vector temp;
 vector temp2;
int i,p,j,n,k,t;
double m;
int q=-1;

n=2*size;

identity = (matrix)malloc(sizeof(vector) * size);
aug = (matrix)malloc(sizeof(vector) * size);
temp = (vector)malloc(sizeof(double)*2*size);
temp2 = (vector)malloc(sizeof(double)*2*size);

for(i=0;i<size;++i)
	{
	identity[i]  = (vector)malloc(sizeof(double) * size);
   aug[i] = (vector)malloc(sizeof(double) * 2*size);
   }

GetIdentityMatrix(identity,size);

AugmentMatrix2(aug,input,identity,size,size);

/*elimination process*/

for(i=0;i<(n-size-1);++i) /*for each equation (row)*/
	{

	for(p=(n-size)-1;p>=i;--p) /* smallest integer with i<=p<=n and api !=0*/
		{
		if(aug[p][i]!=0)
			q=p;
		}

	p=q;

	if(p==(-1))
		{
		printf("No unique solution exists\n");

for(i=0;i<size;++i)
	{
	free(identity[i]); // = (vector)malloc(sizeof(double) * size);
   free(aug[i]); //= (vector)malloc(sizeof(double) * 2*size);
   }

      free(identity);
		free(aug);
		free(temp);
		free(temp2);
		return(2);
		}

	if(p!=i)
		SwapRows(aug,p,i,n);

     if(aug[i][i]==0)
      	{
         printf("No inverse\n");
		printf("No unique solution exists\n");

for(i=0;i<size;++i)
	{
	free(identity[i]); // = (vector)malloc(sizeof(double) * size);
   free(aug[i]); //= (vector)malloc(sizeof(double) * 2*size);
   }

         free(identity);
 			free(aug);
			free(temp);
			free(temp2);

         return(0);
         }

	for(j=i+1;j<(n-size);++j)
		{
		m = aug[j][i]/aug[i][i];
		VectorByScalar(aug[i],m,temp,n);
		VectorSubtract(aug[j],temp,temp2,n);

		ReplaceRow(aug[j],temp2,n);
		}
	}

for(i=0;i<(n-size);++i) /*for each equation (row)*/
	{
      if(aug[i][i]==0)
      	{
         printf("No inverse\n");
         return(0);
         }

  	for(k=i-1;k>=0;--k)
		{
		m = aug[k][i]/aug[i][i];
		VectorByScalar(aug[i],m,temp,n);
		VectorSubtract(aug[k],temp,temp2,n);

		ReplaceRow(aug[k],temp2,n);
		}
	}

if(aug[size-1][size-1]==0)
	{
   printf("No unique solution exists\n");
		printf("No unique solution exists\n");

for(i=0;i<size;++i)
	{
	free(identity[i]); // = (vector)malloc(sizeof(double) * size);
   free(aug[i]); //= (vector)malloc(sizeof(double) * 2*size);
   }

   free(identity);
	free(aug);
   free(temp);
	free(temp2);
   return(2);
   }

for(j=0;j<size;++j)
   for(i=0;i<size;++i)
		{
      input[j][i] = aug[j][i+size]/aug[j][j];  /*inverse is in the input*/
	   }

		printf("No unique solution exists\n");

for(i=0;i<size;++i)
	{
	free(identity[i]); // = (vector)malloc(sizeof(double) * size);
   free(aug[i]); //= (vector)malloc(sizeof(double) * 2*size);
   }

free(identity);
free(aug);
free(temp);
free(temp2);
return(1); /*inverse OK*/
}



void EnterMatrix(matrix input,int rows,int columns)
{
int i;
int j;
double num;

for(j=0;j<rows;++j)
	{
	printf("Enter row %d:\n",j+1);

   for(i=0;i<columns;++i)
   	{
	   scanf("%lf",&num);
      input[j][i]=num;
      }
   }
}


void SaveMatrix(FILE *out, matrix input, int rows, int columns)
{
int i,j;

for(j=0;j<rows;++j)
	{
   for(i=0;i<columns;++i)
   	{
      fprintf(out,"%lf ", input[j][i]);
      }
   fprintf(out,"\n");
   }
}

void SaveVector(FILE *out, vector input, int dim)
{
int j;

for(j=0;j<dim;++j)
	{
   fprintf(out,"%lf\n", input[j]);
   }

}