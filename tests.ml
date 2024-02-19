(* tests.ml *)

(* Assuming Compiler and PC modules are in compiler.ml and pc.ml respectively *)
#use "compiler.ml";;
#use "pc.ml";;
(* open Compiler;; *)
open Reader;;
open Tag_Parser;;
open Printf;;
open Semantic_Analysis;;
(* test_nt_vector: unit -> unit *)
(* Tests the nt_vector nonterminal *)
(* Prints "Test passed" for each successful test *)
(* Prints "Test failed (No match)" for each failed test *)
(* Prints "Test failed (Error occurred)" for each test that raised an error *)
(* Itay: We should add more tests fot the nt_list and more *)
(* let test_nt_vector () =
  let test_cases = [
    "#(1 2 3)"; 
    "#(a b c)"; 
    "#((1 2) (3 4) (5 6))"; 
    "#()"; 
    "#(1 #(a b) \"string\")";
    "#(#() #() #())";  (* Empty Vectors Inside Vectors *)
    "#(1 #t \"hello\" 'symbol)";  (* Mixed Type Elements *)
    "#(#(#(1) #(2 3)) #(4 5) #(6))";  (* Deeply Nested Vectors *)
    "#(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)";  (* Large Vector *)
    "#(\"!@#$%^&*()\" \"<>,.?/:;\")";  (* Vectors with Special Characters *)
    "#(1 2";  (* Incorrectly Formatted Vectors *)
  ] in
  List.iter (fun test_case ->
    try
      let result = (read test_case 0).found in
      Printf.printf "Test passed: %s -> %s\n" test_case (string_of_sexpr result)
    with
    | PC.X_no_match -> Printf.printf "Test failed (No match): %s\n" test_case
    | _ -> Printf.printf "Test failed (Error occurred): %s\n" test_case
  ) test_cases;;
let test_nt_proper_list () =
  let test_cases = [
    "(1 2 3)"; 
    "(a b c)"; 
    "((1 2) (3 4) (5 6))"; 
    "()"; 
    "(1 (a b) \"string\")";
    "((() () ()) () ())";  (* Empty Lists Inside Lists *)
    "(1 #t \"hello\" 'symbol)";  (* Mixed Type Elements *)
    "(((1) (2 3)) (4 5) (6))";  (* Deeply Nested Lists *)
    "(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)";  (* Large List *)
    "(\"!@#$%^&*()\" \"<>,.?/:;\")";  (* Lists with Special Characters *)
    "(1 2";  (* Incorrectly Formatted Lists *)
  ] in
  List.iter (fun test_case ->
    try
      let result = (Reader.nt_sexpr test_case 0).found in
      Printf.printf "Test passed: %s -> %s\n" test_case (string_of_sexpr result)
    with
    | PC.X_no_match -> Printf.printf "Test failed (No match): %s\n" test_case
    | _ -> Printf.printf "Test failed (Error occurred): %s\n" test_case
  ) test_cases;; *)
(* test_nt_list: unit -> unit *)
(* Tests the nt_list nonterminal *)
(* Prints "Test passed" for each successful test *)
(* Prints "Test failed (No match)" for each failed test *)
(* Prints "Test failed (Error occurred)" for each test that raised an error *)
(* Itay: We should add more tests fot the nt_list and more *)
(* let test_nt_improper_list () =
  let test_cases = [
    "(1 . 2)"; 
    "(a . b)"; 
    "((1 . 2) (3 . 4) (5 . 6))"; 
    "(1 . (a . \"string\"))";
    "((() . ()) . ())";  (* Empty Lists Inside Lists *)
    "(1 . #t)";  (* Mixed Type Elements *)
    "(((1) . (2 3)) . (4 5))";  (* Deeply Nested Lists *)
    "(1 . 2 3 4 5 6 7 8 9 10 11 12 13 14 15)";  (* Large List *)
    "(\"!@#$%^&*()\" . \"<>,.?/:;\")";  (* Lists with Special Characters *)
    "(1 . 2";  (* Incorrectly Formatted Lists *)
  ] in
  List.iter (fun test_case ->
    try
      let result = (Reader.nt_sexpr test_case 0).found in
      Printf.printf "Test passed: %s -> %s\n" test_case (string_of_sexpr result)
    with
    | PC.X_no_match -> Printf.printf "Test failed (No match): %s\n" test_case
    | _ -> Printf.printf "Test failed (Error occurred): %s\n" test_case
  ) test_cases;; *)
(* test_nt_list: unit -> unit *)
(* Tests the nt_list nonterminal *)
(* Prints "Test passed" for each successful test *)
(* Prints "Test failed (No match)" for each failed test *)
(* Prints "Test failed (Error occurred)" for each test that raised an error *)
(* Itay: We should add more tests fot the nt_list and more *)
exception X_syntax of string;;

(* test_macro_expand_cond: unit -> unit *)
(* Tests the macro_expand_cond_ribs function *)
(* Prints "Test passed" for each successful test *)
(* Prints "Test failed (No match)" for each failed test *)
(* Prints "Test failed (Error occurred)" for each test that raised an error *)
(* test_macro_expand_cond: unit -> unit *)
(* Tests the transformation of cond expressions *)
(* let test_macro_expand_cond () =
  let test_cases = [
    (* Test case format: (cond expression, expected transformed expression) *)
    ("(cond ((> 3 2) 'greater) (else 'equal))", "(if (> 3 2) 'greater 'equal)");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else 'equal))", "(if (> 3 3) 'greater (if (< 3 3) 'less 'equal))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less))", "(if (> 3 3) 'greater (if (< 3 3) 'less #f))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else))", "(if (> 3 3) 'greater (if (< 3 3) 'less #f))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else #f))", "(if (> 3 3) 'greater (if (< 3 3) 'less #f))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else 3))", "(if (> 3 3) 'greater (if (< 3 3) 'less 3))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else (+ 1 2)))", "(if (> 3 3) 'greater (if (< 3 3) 'less (+ 1 2)))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else (+ 1 2) (+ 3 4)))", "(if (> 3 3) 'greater (if (< 3 3) 'less (+ 1 2) (+ 3 4)))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else (+ 1 2) (+ 3 4) (+ 5 6)))", "(if (> 3 3) 'greater (if (< 3 3) 'less (+ 1 2) (+ 3 4) (+ 5 6)))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less))", "(if (> 3 3) 'greater (if (< 3 3) 'less #f))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else))", "(if (> 3 3) 'greater (if (< 3 3) 'less #f))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else (+ 1 2) (+ 3 4)))", "(if (> 3 3) 'greater (if (< 3 3) 'less (begin (+ 1 2) (+ 3 4))))");
    ("(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else (+ 1 2) (+ 3 4) (+ 5 6)))", "(if (> 3 3) 'greater (if (< 3 3) 'less (begin (+ 1 2) (+ 3 4) (+ 5 6))))");
        
      (* Add more test cases as needed *)
  ] in
  List.iter (fun (cond_expr, expected_expr) ->
    try
      let parsed_expr = Tag_Parser.tag_parse (read cond_expr) in
      let expected_parsed_expr = Tag_Parser.tag_parse (read expected_expr) in
      let string_of_parsed_expr = string_of_expr parsed_expr in
      let string_of_expected_parsed_expr = string_of_expr expected_parsed_expr in
      if parsed_expr = expected_parsed_expr
      then Printf.printf "Test passed: %s\n" cond_expr
      else Printf.printf "Test failed: this is the parse cond: %s\n this is the expected one: %s\n" string_of_parsed_expr string_of_expected_parsed_expr
    with
    | X_syntax msg -> Printf.printf "Test raised X_syntax: %s - %s\n" cond_expr msg
    | e -> Printf.printf "Test raised an unknown exception: %s - %s\n" cond_expr (Printexc.to_string e)
  ) test_cases;;
let test_read () =
  let test_cases = [
    (* Test case format: (input
        expression, expected transformed sexpression) *)
        ("(1 2 3)", "ScmPair(ScmNumber(1) ScmPair(ScmNumber(2) ScmPair(ScmNumber(3) ScmNill)))");
  ] in
  List.iter (fun (input_expr, expected_sexpr) ->
    try
      let parsed_expr = Reader.read_sexpr input_expr in
      let string_of_parsed_expr = string_of_sexpr parsed_expr in
      if string_of_parsed_expr = expected_sexpr
      then Printf.printf "Test passed: %s\n" input_expr
      else Printf.printf "Test failed: this is the parse cond: %s\n this is the expected one: %s\n" string_of_parsed_expr expected_sexpr
    with
    | X_syntax msg -> Printf.printf "Test raised X_syntax: %s - %s\n" input_expr msg
    | e -> Printf.printf "Test raised an unknown exception: %s - %s\n" input_expr (Printexc.to_string e)
  ) test_cases;; *)

let test_tail_call_anntotate () =
  let test_cases = [
    (* Test case format: (input
        expression, expected transformed sexpression) *)
        ("(define (f x) (if (= x 0) 1 (* x (f (- x 1)))))");
  ] in
  List.iter (fun (input_expr) ->
    try
      let sexpr = read input_expr in
      let parsed_expr = tag_parse sexpr in
      let annotated_lexicaly = annotate_lexical_address parsed_expr in
      let annotated_tail = annotate_tail_calls annotated_lexicaly in
      printf "this is the annotated tail: %s\n" (string_of_expr' annotated_tail);
    with
    | X_syntax msg -> printf "Test raised X_syntax: %s - %s\n" input_expr msg
    | e -> printf "Test raised an unknown exception: %s - %s\n" input_expr (Printexc.to_string e)
  ) test_cases;;


let () =
  (* test_nt_vector (); *)
  (* test_nt_proper_list (); *)
  (* test_nt_improper_list (); *)
  (* test_read(); *)
  (* test_macro_expand_cond (); *)
  (* Add more test function calls as needed *)
  test_tail_call_anntotate ();;
