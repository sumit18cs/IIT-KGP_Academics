// Name:- Avijit Mandal
// Roll:- 18CS30010
// Name:- Sumit Kumar Yadav	
// Roll No:- 18CS30042
// Compilers Assignment 5

// code to check if a character is vowel or not

int isVowel(char c){
	int x=0;
	if(c=='a'){
		x=1;
	}
	else if(c=='e'){
		x=1;
	}
	else if(c=='i'){
		x=1;
	}
	else if(c=='o'){
		x=1;
	}
	else if(c=='u'){
		x=1;
	}
	else{
		x=0;
	}
	return (x);
}

int main(){

	char c = 'a';
	char d = 'd';
	char e= 'z';
	if(isVowel(c)){
		printf("%c is a Vowel\n",c);
	}
	else{
		printf("%c is a not a Vowel\n",c);
	}

	if(isVowel(d)){
		printf("%c is a Vowel\n",d);
	}
	else{ 
		printf("%c is a not a Vowel\n",d);	
	}
	if(isVowel(e)){
		printf("%c is a Vowel\n",d);
	}
	else{ 
		printf("%c is a not a Vowel\n",d);	
	}
	return 0;
}
