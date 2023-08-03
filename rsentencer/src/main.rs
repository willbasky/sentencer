mod util;

use util::*;

use std::fs::read_to_string;

use serde_json::Value;


fn main() {
  let config_str =
    read_to_string("content.toml").unwrap();
  // println!("{:?}",&config_str);

  let conf: Config = toml::from_str(&config_str).unwrap();
  println!("{:?}",conf);

  let input_path = format!("{}/{}", conf.directory, conf.input);

  let source_lines = read_lines(&input_path);

  // for source in source_lines {
  //   let dump = runEsRu(&source);
  // }
  let dump = runEsRu(&source_lines[0]);
  let dump_normalized = normalaizer(&dump);
  println!("dump:\n{}", &dump);
  println!("dump normal:\n{}", &dump_normalized);

  let v: Value = serde_json::from_str(&dump_normalized).unwrap();
  println!("value:\n{}", &v[0]);

  let v_iter = v[0].as_array().unwrap();

  let mut flat_res: Vec<(String, String)> = Vec::new();
  for arr in v_iter {
    let source = &arr[1];
    let target = &arr[0];
    if target.is_string() && source.is_string() {
      let s = source.as_str().unwrap().to_string();
      let t = target.as_str().unwrap().to_string();
      flat_res.push((s,t))
    }
  }
  println!("{:?}", flat_res)

}



