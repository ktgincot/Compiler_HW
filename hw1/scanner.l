%{

#include <stdio.h>
#include <string.h>

int lineNum = 1;
int pragmaSource = 1;
int pragmaToken = 1;
char currentLine[256];
char *tokenType;

void printToken();
void newLine();

%}

/* Definitions */

KEYWORDS	("void"|"int"|"double"|"bool"|"char"|"null"|"for"|"while"|"do"|"if"|"else"|"switch"|"return"|"break"|"continue"|"const"|"true"|"false"|"struct"|"case"|"default"|"fclose"|"clearerr"|"feof"|"ferror"|"fflush"|"fgetpos"|"fopen"|"fread"|"freopen"|"fseek"|"fsetpos"|"ftell"|"fwrite"|"remove"|"rename"|"rewind"|"setbuf"|"setvbuf"|"tmpfile"|"tmpnam"|"fprintf"|"printf"|"sprintf"|"vfprintf"|"vprintf"|"vsprintf"|"fscanf"|"scanf"|"sscanf"|"fgetc"|"fgets"|"fputc"|"fputs"|"getc"|"getchar"|"gets"|"putc"|"putchar"|"puts"|"ungetc"|"perror")
IDENTIFIER	([_a-zA-Z][_a-zA-Z0-9]*)
OPERATOR	([\+\-\*\/\%\<\>=!]|"++"|"--"|"<="|">="|"=="|"!="|"&&"|"||")
PUNC_CHAR	([:;,.\[\]\{\}\(\)])
INTEGER		(([1-9]+[0-9]*)|[0])
DOUBLE		((([1-9]+[0-9]*)|[0])?"."[0-9]+)
CHARACTER	(("'\\n'"|"'\\t'")|('[^']'))
SCI_NOTATION	((([1-9][0-9]*)|(([0]?|[1-9][0-9]*)("."[0-9]*)))[eE][\+\-]?[1-9][0-9]*)
STRING		(\"[^\"\n]*\")
SINGLE_COMMENT	(\/\/.*)

SOURCE_ON	("#pragma source on\n")
SOURCE_OFF	("#pragma source off\n")
TOKEN_ON	("#pragma token on\n")
TOKEN_OFF	("#pragma token off\n")

%x		COMMENT
%x		SINGLE_COMMENT

%%

[\n]		{ newLine(); }
[ \t\r]+	{ strcat(currentLine, yytext); }
{KEYWORDS}	{ tokenType = "key"; printToken(); }
{IDENTIFIER}	{ tokenType = "id"; printToken(); }
{OPERATOR}	{ tokenType = "op"; printToken(); }
{PUNC_CHAR}	{ tokenType = "punc"; printToken(); }
{INTEGER}	{ tokenType = "integer"; printToken(); }
{DOUBLE}	{ tokenType = "double"; printToken(); } 
{CHARACTER}	{ tokenType = "char"; printToken(); }
{SCI_NOTATION}	{ tokenType = "sci"; printToken(); }
{STRING}	{ tokenType = "string"; printToken(); }

{SOURCE_ON}	{ tokenType = "pragmaSourceOn"; pragmaSource = 1; newLine(); }
{SOURCE_OFF}	{ tokenType = "pragmaSourceOff"; pragmaSource = 0; newLine();}
{TOKEN_ON}	{ tokenType = "pragmaToken"; pragmaToken = 1; newLine(); }
{TOKEN_OFF}	{ tokenType = "pragmaToken"; pragmaToken = 0; newLine(); }


{SINGLE_COMMENT}	{ strcat(currentLine, yytext); }
"/*"			{ strcat(currentLine, yytext); BEGIN COMMENT; }
<COMMENT>"*/"		{ strcat(currentLine, yytext); BEGIN INITIAL; }
<COMMENT>\n		{ newLine(); }
<COMMENT>.		{ strcat(currentLine, yytext); }

%%

int main (int argc, char* argv[]) {
	yylex();
	return 0;
}

int yywrap() {
	return 1;
}

void printToken() {
	strcat(currentLine, yytext);
	if (pragmaToken == 1) {
		if (tokenType == "string") printf("#%s:%.*s\n", tokenType, yyleng-2, yytext+1);
		else printf("#%s:%s\n", tokenType, yytext);
	}
}

void newLine() {
	if (tokenType == "pragmaSourceOn" || tokenType == "pragmaToken") {
		printf("%d:%s", lineNum, yytext);
	} else if (pragmaSource == 1) printf("%d:%s\n", lineNum, currentLine);
	memset(currentLine, 0, sizeof(currentLine)); 
	lineNum++;
}
