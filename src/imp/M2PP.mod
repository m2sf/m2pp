(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

MODULE M2PP;

(* Modula-2 Preprocessor Driver *)

IMPORT ProgramArgs, ArgParser, Infile, Outfile, Preprocessor;
FROM FileSystemAdapter IMPORT fileExists, DeleteFile;

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


PROCEDURE Usage;

BEGIN
  Console.WriteChars("Usage:\n");
  Console.WriteChars("$ m2pp infoRequest\n"); Console.WriteChars("or\n");
  Console.WriteChars("$ m2pp expansionOption+ diagnosticOption*\n\n");
  Console.WriteChars("infoRequest:\n");
  Console.WriteChars(" --help, -h          : print help\n");
  Console.WriteChars(" --version, -V       : print version\n");
  Console.WriteChars(" --license           : print license info\n\n");
  Console.WriteChars("expansionOption:\n");
  Console.WriteChars(" --outfile path      : define outfile\n");
  Console.WriteChars(" --dict (key=value)+ : define key/value pairs\n");
  Console.WriteChars(" --tabwidth 0..8     : set tab width\n");
  Console.WriteChars(" --newline mode      : set newline mode\n\n");
  Console.WriteChars("mode:\n");
  Console.WriteChars(" cr | lf | crlf\n\n");
  Console.WriteChars("diagnosticOption:\n");
  Console.WriteChars(" --verbose, -v       : verbose output\n");
  Console.WriteChars(" --show-settings     : print all settings\n")
END Usage;


BEGIN  (* M2PP *)
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