(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE Dictionary;

(* Key/Value Dictionary *)

IMPORT String;
FROM SYSTEM IMPORT TSIZE;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM String IMPORT StringT; (* alias for String.String *)


TYPE Node = POINTER TO NodeDescriptor;

TYPE NodeDescriptor = RECORD
  level : CARDINAL;
  key   : Key;
  value : Value;
  left,
  right : Node
END; (* NodeDescriptor *)


TYPE Cache = RECORD
  key   : Key;
  value : Value
END; (* Cache *)


TYPE Tree = RECORD;
  entries    : CARDINAL;
  root       : Node;
  lastSearch : Cache;
  lastStatus : Status
END; (* Tree *)


VAR
  dictionary : Tree;
  prevNode,
  candidate,
  bottom     : Node;
    

(* Introspection *)

(* ---------------------------------------------------------------------------
 * function Dictionary.count()
 * ---------------------------------------------------------------------------
 * Returns the number of key/value pairs in the global dictionary.
 * Does not set dictionary status.
 * ------------------------------------------------------------------------ *)

PROCEDURE count ( ) : CARDINAL;

BEGIN
  RETURN dictionary.entries
END count;


(* ---------------------------------------------------------------------------
 * function Dictionary.status()
 * ---------------------------------------------------------------------------
 * Returns the status of the last operation on the global dictionary.
 * Does not set dictionary status.
 * ------------------------------------------------------------------------ *)

PROCEDURE status ( ) : Status;

BEGIN
  RETURN dictionary.lastStatus
END status;


(* Lookup Operations *)

(* ---------------------------------------------------------------------------
 * function Dictionary.isPresent(key)
 * ---------------------------------------------------------------------------
 * Returns TRUE if key is present in the global dictionary, else FALSE.
 * Fails and returns NIL if key is NIL.  Sets dictionary status.
 * ------------------------------------------------------------------------ *)

PROCEDURE isPresent ( key : Key ) : BOOLEAN;

VAR
  value : Value;

BEGIN
  (* bail out if key is NIL *)
  IF key = NilKey THEN
    dictionary.lastStatus := NilNotPermitted;
    RETURN FALSE
  END; (* IF *)
  
  (* return TRUE if key matches last searched key *)
  IF (dictionary.lastSearch.key # NilKey) AND
     (key = dictionary.lastSearch.key) THEN
    dictionary.lastStatus := Success;
    RETURN TRUE
  END; (* IF *)
  
  (* search key *)
  value := lookup(dictionary.root, key, dictionary.lastStatus);
  
  (* update cache if entry found *)
  IF value # NilValue THEN
    dictionary.lastSearch.key := key;
    dictionary.lastSearch.value := value;
  END; (* IF *)
  
  RETURN (dictionary.lastStatus = Success)
END isPresent;


(* ---------------------------------------------------------------------------
 * function Dictionary.valueForKey(key)
 * ---------------------------------------------------------------------------
 * Returns the value stored for key in the global dictionary, or NIL if no key 
 * is present in the dictionary. Fails if key is NIL. Sets dictionary status.
 * ------------------------------------------------------------------------ *)

PROCEDURE valueForKey ( key : Key ) : Value;

VAR
  value : Value;
  
BEGIN
  (* bail out if key is NIL *)
  IF key = NilKey THEN
    dictionary.lastStatus := NilNotPermitted;
    RETURN NilKey
  END; (* IF *)
  
  (* return cached value if key matches last searched key *)
  IF (dictionary.lastSearch.key # NilKey) AND
     (key = dictionary.lastSearch.key) THEN
    dictionary.lastStatus := Success;
    RETURN dictionary.lastSearch.value
  END; (* IF *)
  
  (* search key *)
  value := lookup(dictionary.root, key, dictionary.lastStatus);
  
  (* update cache if entry found *)
  IF value # NilKey THEN
    dictionary.lastSearch.key := key;
    dictionary.lastSearch.value := value
  END; (* IF *)
  
  RETURN value
END valueForKey;


(* Insert Operations *)

(* ---------------------------------------------------------------------------
 * procedure Dictionary.StoreValueForKey(key, value)
 * ---------------------------------------------------------------------------
 * Stores value for key in the global dictionary.  Fails if key or value or
 * both are NIL.  Sets dictionary status.
 * ------------------------------------------------------------------------ *)

PROCEDURE StoreValueForKey ( key : Key; value : Value );

VAR
  newRoot : Node;
  
BEGIN
  (* bail out if key or value or both are NIL *)
  IF (key = NilKey) OR (value = NilValue) THEN
    dictionary.lastStatus := NilNotPermitted;
    RETURN
  END; (* IF *)
  
  (* insert new entry *)
  newRoot := insert(dictionary.root, key, value, dictionary.lastStatus);
  
  (* replace dictionary root, update counter *)
  IF dictionary.lastStatus = Success THEN
    dictionary.root := newRoot;
    dictionary.entries := dictionary.entries + 1
  END (* IF *)
END StoreValueForKey;


(* ---------------------------------------------------------------------------
 * procedure Dictionary.StoreArrayForKey(key, array)
 * ---------------------------------------------------------------------------
 * Obtains an interned string for array, then stores the string as value for
 * key in the global dictionary.  Fails if key is NIL or if array produces a
 * NIL string.  Sets dictionary status.
 * ------------------------------------------------------------------------ *)

PROCEDURE StoreArrayForKey
  ( key : Key; VAR (* CONST *) array : ARRAY OF CHAR );

VAR
  value : Value;

BEGIN
  (* bail out if key is NIL *)
  IF key = NilKey THEN
    dictionary.lastStatus := NilNotPermitted;
    RETURN
  END; (* IF *)
  
  (* check key before getting interned string for value *)  
  IF lookup(dictionary.root, key, dictionary.lastStatus) = NilValue THEN
    value := String.forArray(array);
    
    IF value = NilValue THEN
      dictionary.lastStatus := NilNotPermitted;
      RETURN
      
    ELSE (* all clear *)
      StoreValueForKey(value, key)
    END (* IF *)
  END (* IF *)
END StoreArrayForKey;


(* Removal Operations *)

(* ---------------------------------------------------------------------------
 * procedure Dictionary.RemoveKey(key)
 * ---------------------------------------------------------------------------
 * Removes key and its value from the global dictionary.  Fails if key is NIL
 * or if key is not present in the dictionary.  Sets dictionary status.
 * ------------------------------------------------------------------------ *)

PROCEDURE RemoveKey ( key : Key );

VAR
  newRoot : Node;
  
BEGIN
  (* bail out if key is NIL *)
  IF key = NilKey THEN
    dictionary.lastStatus := NilNotPermitted;
    RETURN
  END; (* IF *)
  
  (* remove *)
  newRoot := remove(dictionary.root, key, dictionary.lastStatus);
  
  IF dictionary.lastStatus = Success THEN
    dictionary.root := newRoot;
    dictionary.entries := dictionary.entries - 1;
    
    (* clear cache if removed key is in cache *)
    IF key = dictionary.lastSearch.key THEN
      dictionary.lastSearch.key := NilKey;
      dictionary.lastSearch.value := NilValue
    END (* IF *)
  END (* IF *)
END RemoveKey;


(* Iteration *)

(* ---------------------------------------------------------------------------
 * procedure Dictionary.WithKeyValuePairsDo(p)
 * ---------------------------------------------------------------------------
 * Iterates over all key/value pairs in the global dictionary in key order
 * and calls calls visitor procedure p for each pair, passing key and value.
 * Keys are ordered in ASCII collation order.  Sets dictionary status.
 * ------------------------------------------------------------------------ *)

PROCEDURE WithKeyValuePairsDo ( p : VisitorProc );

BEGIN
  IF p = NILPROC THEN
    dictionary.lastStatus := NilNotPermitted;
    RETURN
  END; (* IF *)
  
  Traverse(dictionary.root, p);
  dictionary.lastStatus := Success
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
 * private function lookup(node, key, status)
 * ---------------------------------------------------------------------------
 * Looks up key in the subtree whose root is thisNode.  Returns its value if
 * key is found, otherwise returns NIL.  Passes status back in status.
 * ------------------------------------------------------------------------ *)

PROCEDURE lookup ( thisNode : Node; key : Key; VAR status : Status ) : Value;

VAR
  searchKey : String.Comparison;
  
BEGIN
  (* set sentinel's key to search key *)
  bottom^.key := key;
    
  (* compare search key and key of current node *)
  searchKey := String.comparison(key, thisNode^.key);
  
  (* search until key is found or bottom of tree is reached *)
  WHILE searchKey # String.Equal DO
        
    (* move down left if key is less than key of current node *)
    IF searchKey = String.Less THEN (* key < thisNode^.key *)
      thisNode := thisNode^.left
      
    (* move down right if key is greater than key of current node *)
    ELSE (* key > thisNode^.key *)
      thisNode := thisNode^.right
    END; (* IF *)
    
    (* compare search key and key of current node *)
    searchKey := String.comparison(key, thisNode^.key)
  END; (* WHILE *)
  
  (* restore sentinel's key *)
  bottom^.key := NilKey;
  
  (* check whether or not bottom has been reached *)
  IF thisNode # bottom THEN
    status := Success;
    RETURN thisNode^.value
    
  ELSE (* bottom reached -- key not found *)
    status := EntryNotFound;
    RETURN NilKey
  END (* IF *)
END lookup;


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
  IF node^.level = node^.right^.right^.level THEN
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
    key,
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
    CASE String.comparison(key, node^.key) OF
    (* key already exists *)
      String.Equal :
        status := KeyAlreadyPresent;
        RETURN NIL
    
    (* key < node^.key *)
    | String.Less :
        (* recursive insert left *)
        node := insert(node^.left, key, value, status)
        
    (* key > node^.key *)
    | String.Greater :
        (* recursive insert right *)
        node := insert(node^.right, key, value, status)
    END (* CASE *)
  END; (* IF *)
  
  (* bail out if allocation failed *)
  IF status = AllocationFailed THEN
    RETURN NIL
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
  (* exit when bottom reached *)
  IF node = bottom THEN
    status := EntryNotFound;
    RETURN NIL;
  END; (* IF *)
  
  (* move down recursively until key is found or bottom is reached *)
  prevNode := node;
  
  (* move down left if search key is less than that of current node *)
  IF String.comparison(key, node^.key) = String.Less THEN
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
    
    DEALLOCATE(prevNode, TSIZE(NodeDescriptor));
    status := Success
    
  (* rebalance on the way back up *)
  ELSIF
    (node^.level - 1 > node^.left^.level) OR
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
 * private procedure Traverse(node, visit)
 * ---------------------------------------------------------------------------
 * Recursively traverses the tree whose root node is node, in-order and calls
 * the passed in visitor procedure for each node, passing its key and value.
 * ------------------------------------------------------------------------ *)

PROCEDURE Traverse ( node : Node; visit : VisitorProc );
  
BEGIN
  (* exit when bottom reached *)
  IF node = bottom THEN
    RETURN
  END; (* IF *)
  
  (* traverse left subtree *)
  Traverse(node^.left, visit);
  
  (* call visitor proc passing key and value *)
  visit(node^.key, node^.value);
  
  (* traverse right subtree *)
  Traverse(node^.right, visit)
END Traverse;


BEGIN  
  (* init helper nodes *)
  prevNode := NIL;
  candidate := NIL;
  
  (* init sentinel node *)
  ALLOCATE(bottom, TSIZE(NodeDescriptor));
  (* bottom^ := { 0, NIL, NIL, bottom, bottom } *)
  bottom^.level := 0;
  bottom^.key := NilKey;
  bottom^.value := NilValue;
  bottom^.left := bottom;
  bottom^.right := bottom;

  (* init dictionary *)
  (* dictionary := { 0, bottom, NIL, NIL, Success } *)
  dictionary.entries := 0;
  dictionary.root := bottom;
  dictionary.lastSearch.key := NilKey;
  dictionary.lastSearch.value := NilValue;
  dictionary.lastStatus := Success;
END Dictionary.