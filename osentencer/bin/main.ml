(* open Osentencer *)
module Json = Yojson.Basic.Util
module JB = Yojson.Basic

let (%) = Batteries.((%))

let normalizer dump =
  let firstPosition = BatString.index dump '[' in
  let lastPosition = BatString.rindex dump ']' in
  BatString.slice ~first:firstPosition ~last:(lastPosition +1) dump

let translate txt = snd @@ BatUnix.run_and_read @@ "trans es:ru -dump \"" ^ txt ^ "\""

let o_json_string j = Json.to_option Json.to_string j

let filter_target a = match o_json_string (List.hd a) with
  | None -> None
  | Some _ -> Some (List.rev @@ Json.filter_string a)

let formatTranslation str =
  let json = JB.from_string str in
  let fst_arr = Json.index 0 json in
  let arr_arr = Json.filter_list @@ Json.to_list fst_arr in
  let ls2 = BatList.filter_map filter_target arr_arr in
  List.fold_right (fun s acc -> (String.concat "\n" s) ^ "\n" ^ acc) ls2 String.empty

let () =
  let sources = BatFile.lines_of "content/sample-ninos.txt" in
  let targets = BatEnum.map (formatTranslation % normalizer % translate) sources in
  BatFile.write_lines "content/om_result_ninos.txt" @@ BatEnum.enum targets








(* let hd_opt ls = try Some (List.hd ls) with Failure _ -> None *)
  (* | element -> Some element *)


(* let foldTranslation txt = txt *)


(* let translator txt =
    let dump = Unix.execvp "trans" [|"es:ru"; "-dump"; txt|]
in foldTranslation (normalizer dump) *)

