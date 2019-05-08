typedef enum { typeCon, typeChar, typeFloat, typeBool, typeId, typeOpr } nodeEnum;
typedef enum { t_int, t_float, t_string, t_bool } dataTypeEnum;
typedef enum { 



UMIN,
PLSPLS,
MINMIN,
MIN,
PLS,
DIV,
MUL,

/******** RETURNS BOOL ********/ 
/*####### CAST OPS BOOL #######*/
NOT,
OR,
AND,
/*####### CAST OPS BOOL #######*/

/*####### CAST OPS INT OR FLOAT #######*/
LT,
GT,
GTEQ,
LTEQ,
EQEQ,
NTEQ,
/*####### CAST OPS INT OR FLOAT #######*/
/******** BOOL ********/ 

/******** ASSIGN ********/ 
EQ,
PLSEQ,
MINEQ,
DIVEQ,
MULEQ
/******** ASSIGN ********/ 

 } operationTypeEnum;

/* constants */
typedef struct {
	int value; /* value of constant */
} conNodeType;

typedef struct {
	char* value; /* value of constant */
} charNodeType;

typedef struct {
	float value; /* value of constant */
} floatNodeType;

/* identifiers */
typedef struct {
	char * var_name;	/* subscript to sym array */
} idNodeType;

/* boolean */
typedef struct {
	bool value;
} boolNodeType;
/* operators */
typedef struct {
	int type;	/* operator */
	int nops;	/* number of operands */
	struct nodeTypeTag **op;	/* operands */
	dataTypeEnum eval; /* this should have the evaluated type of the expression */
} oprNodeType;
typedef struct nodeTypeTag {
	nodeEnum type;	/* type of node */
	int constant;
	union {
		conNodeType con;	/* constants */
		charNodeType con_char;
		floatNodeType flo;
		boolNodeType boolean;
		idNodeType id;		/* identifiers */
		oprNodeType opr;	/* operators */
	};

} nodeType;

extern int sym[26];
