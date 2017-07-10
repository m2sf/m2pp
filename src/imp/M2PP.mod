(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

MODULE M2PP;

(* Modula-2 Preprocessor Driver *)

IMPORT ProgramArgs, ArgParser, Infile, Outfile, Preprocessor;

FROM Infile IMPORT InfileT; (* alias for Infile.Infile *)
FROM Outfile IMPORT OutfileT; (* alias for Outfile.Outfile *)


CONST
  ProgTitle = "M2PP - Modula-2 Preprocessor";
  Version   = "Version 0.1";
  Copyright = "Copyright (c) 2017 Modula-2 Software Foundation";
  License   = "Licensed under the LGPL license version 2.1";

VAR
  infileName,
  outfileName : StringT;
  infile : InfileT;
  outfile : OutfileT;
  inStatus : Infile.Status;
  outStatus : Outfile.Status;
  argStatus : ArgParser.Status;


BEGIN  
  (* check if program argument file is present *)
  IF fileExists(ProgramArgs.Filename) THEN
    ProgramArgs.Open
  ELSE (* query user and write file *)
    ProgramArgs.Query
  END; (* IF *)
  
  argStatus := ArgParser.parseArgs();
  ProgramArgs.Close;
  
  CASE argStatus OF
    Success :
      (* print banner *)
      Console.WriteChars(ProgTitle); Console.WriteChars(", ");
      Console.WriteChars(Version);   Console.WriteLn;
      Console.WriteChars(Copyright); Console.WriteLn;
      
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
      
  | HelpRequested :
      (* TO DO : print help *)
      
  | VersionRequested :
      Console.WriteChars(Version); WriteLn
  
  | LicenseRequested :
      Console.WriteChars(License); WriteLn
      
  | ErrorsEncountered :
      (* TO DO : print help *)
  END (* CASE *)
END M2PP.