(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

MODULE M2PP;

(* Modula-2 Preprocessor Driver *)

IMPORT ProgramArgs, ArgParser, Infile, Outfile;

FROM Infile IMPORT InfileT; (* alias for Infile.Infile *)
FROM Outfile IMPORT OutfileT; (* alias for Outfile.Outfile *)

VAR
  infileName,
  outfileName : StringT;
  infile : InfileT;
  outfile : OutfileT;
  inStatus : Infile.Status;
  outStatus : Outfile.Status;
  

BEGIN
  (* if verbose mode, print banner *)

  (* check if program argument file is present *)
  IF fileExists(ProgramArgs.Filename) THEN
    ProgramArgs.Open
  ELSE (* query user and write file *)
    ProgramArgs.Query
  END; (* IF *)
  
  ArgParser.parseArgs();
  ProgramArgs.Close;
  
  (* TO DO : verify result *)
  
  infileName := ArgParser.sourceFile();
  outfileName := ArgParser.targetFile();
  
  IF outfileName = NIL THEN
    (* generate outfile name from infile name *)
  END; (* IF *)
  
  Infile.Open(infile, inStatus);
  
  (* TO DO : handle status *)
  
  Outfile.Open(outfile, outStatus);
  
  (* TO DO : handle status *)
  
  Preprocessor.Expand(infile, outfile);
  
  (* if verbose mode, print summary *)
END M2PP.