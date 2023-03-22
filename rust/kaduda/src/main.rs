use std::{env, path::PathBuf};
use include_dir::{include_dir, Dir, File};
use std::path::Path;

fn main() {
    let args: Vec<String> = env::args().collect();
    let command = &args[1];
    let command2 = &args[2];
    let mut v  = Vec::new();

    static PROJECT_DIR: Dir<'_> = include_dir!("$CARGO_MANIFEST_DIR/src/my_log");

    for entry in PROJECT_DIR.files() {
        v.push(entry);
    }

    if command == "show"{
        let var2 = show_command(&command2, &mut v);
        println!("{}", var2.display());
        println!("sdfs");
        let lib_rs =  PROJECT_DIR.get_file(var2).unwrap();
        let content = lib_rs.contents_utf8().unwrap();
        output(content);
    }
}

fn show_command<'a>(command_name: &str, file_name: &'a mut [&File]) -> &'a Path {
    for entry in file_name {
        let path = Path::new(command_name);
        let new_path = path.with_extension("txt");

        if new_path == entry.path(){
            return entry.path();
        }
    }
    return Path::new("");
}


fn output(output_info: &str){
    println!("=====================================\n");
    println!("{output_info}");
    println!("\n=====================================");
}
