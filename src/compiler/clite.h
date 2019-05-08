typedef enum { typeCon, typeChar, typeFloat, typeId, typeOpr } nodeEnum;
typedef enum { t_int, t_float, t_string } dataTypeEnum;

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
/* operators */
typedef struct {
	int oper;	/* operator */
	int nops;	/* number of operands */
	struct nodeTypeTag **op;	/* operands */
} oprNodeType;
typedef struct nodeTypeTag {
	nodeEnum type;	/* type of node */
	int constant;
	union {
		conNodeType con;	/* constants */
		charNodeType con_char;
		floatNodeType flo;
		idNodeType id;		/* identifiers */
		oprNodeType opr;	/* operators */
	};
	//TODO: Find out if we need to add another type (no val) for expressions which doesn't evaluate to anything
	//dataTypeEnum eval; /* this should have the evaluated type of the expression */
} nodeType;

extern int sym[26];
