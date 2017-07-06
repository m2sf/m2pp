(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE Dictionary;

(* Key/Value Dictionary *)

IMPORT String;

FROM String IMPORT StringT; (* alias for String.String *)


TYPE Tree = RECORD;
  entries : CARDINAL;
  root    : Node
END; (* Tree *)


TYPE Node = POINTER TO NodeDescriptor;

TYPE NodeDescriptor = RECORD
  level : CARDINAL;
  key   : Key;
  value : StringT;
  left,
  right : Node
END; (* NodeDescriptor *)


CONST MaxKeyLength = 32;

TYPE Key = ARRAY [0..MaxKeyLength] OF CHAR;


VAR
  dictionary : Tree;
  prevNode,
  candidate,
  bottom     : Node;
  
  lastStatus : Status;
  

(* Introspection *)

PROCEDURE count ( ) : CARDINAL;
(* Returns the number of entries in the global dictionary. *)

BEGIN
  RETURN dictionary.entries
END count;


(* Lookup Operations *)

PROCEDURE isPresent ( VAR (* CONST *) key : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if a value is stored for key in the global dictionary. *)

BEGIN
  (* TO DO *)
END isPresent;


PROCEDURE stringForKey ( VAR (* CONST *) key : ARRAY OF CHAR ) : StringT;
(* Returns the string value stored for key, if key is present in the global
   dictionary. Returns NIL if key is not present in the global dictionary. *)

BEGIN
  RETURN valueForKey(key, lastStatus)
END stringForKey;


(* Insert Operations *)

PROCEDURE StoreArrayForKey
  ( VAR (* CONST *) key : ARRAY OF CHAR; VAR array : ARRAY OF CHAR );
(* Obtains an interned string for array,
   then stores the string for key in the global dictionary. *)

BEGIN
  (* TO DO *)
END StoreArrayForKey;


PROCEDURE StoreStringForKey
  ( VAR (* CONST *) key : ARRAY OF CHAR; string : StringT );
(* Stores string for key in the global dictionary. *)

BEGIN
  StoreEntry(key, string, lastStatus)
END StoreStringForKey;


(* Removal Operations *)

PROCEDURE RemoveKey ( VAR (* CONST *) key : ARRAY OF CHAR );
(* Removes key and its value in the global dictionary. *)

BEGIN
  RemoveEntry(key, lastStatus)
END RemoveKey;


(* Iteration *)

PROCEDURE WithKeyValuePairsDo ( p : IterBodyProc );

BEGIN
  (* TO DO *)
END WithKeyValuePairsDo;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* ---------------------------------------------------------------------------
 * AA Tree Implementation
 * ---------------------------------------------------------------------------
 * Reference documents:
 * (1) AA Trees -- http://user.it.uu.se/~arnea/ps/simp.pdf
 * (2) Sentinel Search -- http://user.it.uu.se/~arnea/ps/searchproc.pdf
 * ------------------------------------------------------------------------ *)

(* ---------------------------------------------------------------------------
 * private procedure StoreEntry(key, value, status)
 * ---------------------------------------------------------------------------
 * Stores value for key in dictionary.  Fails if NIL is passed in for value
 * or if zero is passed in for key.  Passes status back in status.
 * ------------------------------------------------------------------------ *)

PROCEDURE StoreEntry ( key : Key; value : StringT; VAR status : Status );

VAR
  newRoot : Node;
  
BEGIN
  (* bail out if value is NIL *)
  IF value = NIL THEN
    status := InvalidValue;
    RETURN
  END; (* IF *)
  
  (* insert new entry *)
  newRoot := insert(dictionary.root, key, value, status);
  
  IF status = Success THEN
    dictionary.root := newRoot;
    dictionary.entries := dictionary.entries + 1
  END (* IF *)
END StoreEntry;


(* ---------------------------------------------------------------------------
 * private function valueForKey(key, status)
 * ---------------------------------------------------------------------------
 * Returns the value for key in dictionary.  Returns NIL if no entry is stored
 * for key in dictionary.  Passes status back in status.
 * ------------------------------------------------------------------------ *)

PROCEDURE valueForKey ( key : Key; VAR status : Status ) : StringT;

VAR
  thisNode : Node;
  
BEGIN
  (* set sentinel's key to search key *)
  bottom^.key := key;
  
  (* start at the root *)
  thisNode := dictionary.root;
  
  (* search until key is found or bottom of tree is reached *)
  WHILE key # thisNode^.key DO
    (* move down left if key is less than key of current node *)
    IF key < this^.key THEN
      thisNode := thisNode^.left
      
    (* move down right if key is greater than key of current node *)
    ELSIF key > this^.key THEN
      thisNode := thisNode^.right
    END (* IF *)
  END; (* WHILE *)
  
  (* restore sentinel's key *)
  bottom^.key := 0;
  
  (* check whether or not bottom has been reached *)
  IF thisNode # bottom THEN
    status := Success;
    RETURN thisNode^.value
  ELSE (* bottom reached -- key not found *)
    status := EntryNotFound;
    RETURN NIL
  END (* IF *)
END valueForKey;


(* ---------------------------------------------------------------------------
 * private procedure RemoveEntry(key, status)
 * ---------------------------------------------------------------------------
 * Removes the key/value pair for key from dictionary.  Fails if no entry is
 * stored for key in dictionary.  Passes status back in status.
 * ------------------------------------------------------------------------ *)

PROCEDURE RemoveEntry ( key : Key; VAR status : Status );

VAR
  newRoot : Node;
  
BEGIN
  (* remove entry *)
  newRoot := remove(dictionary.root, key, status);
  
  IF status = Success THEN
    dictionary.root := newRoot;
    dictionary.entries := dictionary.entries - 1
  END (* IF *)
END RemoveEntry;


(* ---------------------------------------------------------------------------
 * private function skew(node)
 * ---------------------------------------------------------------------------
 * Rotates node to the right if its left child has the same level as node.
 * Returns the new root node.  Node must not be NIL.
 * ------------------------------------------------------------------------ *)

PROCEDURE skew ( node : Node ) : Node;

VAR
  tempNode : Node;
  
BEGIN
  (* rotate right if left child has same level *)
  IF node^.level = node^.left^.level THEN
    tempNode := node;
    node := node^.left;
    tempNode^.left := node^.right;
    node^.right := tempNode
  END; (* IF *)
  
  RETURN node
END skew;


(* ---------------------------------------------------------------------------
 * private function split(node)
 * ---------------------------------------------------------------------------
 * Rotates node to the left and promotes the level of its right child to
 * become its new parent if node has two consecutive right children with the
 * same level as node.  Returns the new root node.  Node must not be NIL.
 * ------------------------------------------------------------------------ *)

PROCEDURE split ( node : Node ) : Node;

VAR
  tempNode : Node;
  
BEGIN
  (* rotate left if there are two right children on same level *)
  IF node^level = node^.right^.right^.level THEN
    tempNode := node;
    node := node^.right;
    tempNode^.right := node^.left;
    node^.right := tempNode;
    node^.level := node^.level + 1
  END; (* IF *)
  
  RETURN node
END split;


(* ---------------------------------------------------------------------------
 * private function insert(node, key, value, status)
 * ---------------------------------------------------------------------------
 * Recursively inserts  a new entry for <key> with <value> into the tree whose
 * root node is <node>.  Returns the new root node  of the resulting tree.  If
 * allocation fails  or  if a node with the same key already exists,  then  NO
 * entry will be inserted and NIL is returned.
 * ------------------------------------------------------------------------ *)

PROCEDURE insert
  ( node       : Node;
    key        : ARRAY OF CHAR;
    value      : StringT;
    VAR status : Status ) : Node;

VAR
  newNode : Node;
  
BEGIN
  IF node = bottom THEN
    (* allocate new node *)
    ALLOCATE(newNode, TSIZE(NodeDescriptor));
    
    (* bail out if allocation failed *)
    IF newNode = NIL THEN
      status := AllocationFailed;
      RETURN NIL
    END; (* IF *)
    
    (* init new node *)
    newNode^.level := 1;
    newNode^.key := key;
    newNode^.value := value;
    newNode^.left := bottom;
    newNode^.right := bottom;
    
    (* link it to the tree *)
    node := newNode
  
  ELSE
    CASE keyComparison(key, node^.key) OF
      (* key already exists *)
      Equal :
        status := KeyAlreadyPresent;
        RETURN NIL
    
    (* key < node^.key *)
    | Less :
        (* recursive insert left *)
        node := insert(node^.left, key, value, status);
        
        (* bail out if allocation failed *)
        IF status = AllocationFailed THEN
          RETURN NIL
        END (* IF *)
        
    (* key > node^.key *)
    | Greater :
        (* recursive insert right *)
        node := insert(node^.right, key, value, status);
        
        (* bail out if allocation failed *)
        IF status = AllocationFailed THEN
          RETURN NIL
        END (* IF *)
    END (* CASE *)
  END; (* IF *)
  
  (* rebalance the tree *)
  node := skew(node);
  node := split(node);
  
  status := Success;
  RETURN node
END insert;


(* ---------------------------------------------------------------------------
 * private function remove(node, key, status)
 * ---------------------------------------------------------------------------
 * Recursively searches the tree  whose root node is <node>  for a node  whose
 * key is <key> and if found,  removes that node  and rebalances the resulting
 * tree,  then  returns  the new root  of the resulting tree.  If no node with
 * <key> exists,  then NIL is returned.
 * ------------------------------------------------------------------------ *)

PROCEDURE remove ( node : Node; key : Key; VAR status : Status ) : Node;

BEGIN
  (* bail out if bottom has been reached *)
  IF node = bottom THEN
    status := EntryNotFound;
    RETURN NIL;
  END; (* IF *)
  
  (* move down recursively until key is found or bottom is reached *)
  prevNode := node;
  
  (* move down left if search key is less than that of current node *)
  IF key < mode^.key THEN
    node := remove(node^.left, key, status)
    
  (* move down right if search key is not less than that of current node *)
  ELSE
    candidate := node;
    node := remove(node^.right, key, status)
  END; (* IF *)
  
  (* remove entry *)
  IF (node = prevNode) AND
     (candidate # bottom) AND
     (candidate^.key = key) THEN
     
    candidate^.key := node^.key;
    candidate := bottom;
    node := node^.right;
    
    DEALLOCATE(prevNode);
    status := Success
    
  (* rebalance on the way back up *)
  ELSIF
    (node^.level - 1 > node^.left) OR
    (node^.level -1 < node^.right^.level) THEN
    
    node^.level := node^.level - 1;
    IF node^.level < node^.right^.level THEN
      node^.right^.level := node^.level
    END; (* IF *)
    
    node := skew(node);
    node := skew(node^.right);
    node := skew(node^.right^.right);
    node := split(node);
    node := split(node^.right)
  END; (* IF *)
  
  RETURN node
END remove;


(* ---------------------------------------------------------------------------
 * private procedure RemoveAll(node)
 * ---------------------------------------------------------------------------
 * Recursively  removes  all nodes  from the tree  whose root node  is <node>.
 * NIL must not be passed in for <node>.
 * ------------------------------------------------------------------------ *)

PROCEDURE RemoveAll ( node : Node );

BEGIN
  (* bail out if already at the bottom *)
  IF node = bottom THEN
    RETURN
  END; (* IF *)
  
  (* remove the left subtree *)
  RemoveAll(node^left);
  
  (* remove the right subtree *)
  RemoveAll(node^.right);
  
  (* deallocate the node *)
  DEALLOCATE(node)
END RemoveAll;


(* ---------------------------------------------------------------------------
 * private function keyComparison(left, right)
 * ---------------------------------------------------------------------------
 * Compares keys left and right using ASCII collation order and returns Equal
 * if the keys match, Less if left < right, or Greater if left > right.
 * ------------------------------------------------------------------------ *)

TYPE Comparison = (Equal, Less, Greater);

PROCEDURE keyComparison
  ( VAR (* CONST *) left, right : ARRAY OF CHAR) : Comparison;

BEGIN
  (* TO DO *)
END keyComparison;


BEGIN  
  (* init helper nodes *)
  prevNode := NIL;
  candidate := NIL;
  
  (* init bottom node *)
  ALLOCATE(bottom, TSIZE(NodeDescriptor));
  bottom^.level := 0;
  bottom^.key := 0;
  bottom^.value := NIL;
  bottom^.left := bottom;
  bottom^.right := bottom;

  (* init dictionary *)
  dictionary.entries := 0;
  dictionary.root := bottom
END Dictionary.