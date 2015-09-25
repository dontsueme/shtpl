/* 
 *  Author: Stefan Giermair (zstegi@gmail.com)
 *  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
 *  This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
 */

//TODO: meaningful error messages

static Regex regex1 = null;
static Regex regex2 = null;
static Regex regex3 = null;
static Regex regex4 = null;
static Regex regex5 = null;
static Regex regex6 = null;
static Regex regex7 = null;
static bool ass = false;
static bool opt = false;

static StringBuilder sb = null;

void addCache(string str) {
  sb.append("\n");
  sb.append(str);
}

void printCache() {
  if (sb.len > 0) {
    sb.erase(0,1); // remove leading \n
    stdout.printf("printf \"%%s\\n\" \"%s\"\n", sb.str);
    sb.erase();
  }
}

string replaceWithEnvVar(string str) throws GLib.Error {
  string new_str = str;
  var regex = new Regex("\\$[\\{]{0,1}[_0-9a-zA-Z]*[\\}]{0,1}");
  MatchInfo mi;
  for (regex.match(str, 0, out mi); mi.matches(); mi.next()) {
    string match = mi.fetch(0).substring(1).replace("{", "").replace("}", "");
    string env = GLib.Environment.get_variable(match);
    new_str = new_str.replace(mi.fetch(0), env != null ? env : "");
  }
  return new_str;
}

long get_uchar_count(string str) {
#if VALA_0_11
  return str.char_count();
#else
  return str.length;
#endif
}

void shtpl(string _file, bool raw = false, bool raw_text = false) throws GLib.Error {
  File file = File.new_for_path(_file);
  var dis = new DataInputStream(file.read());
  string line;
  while ((line = dis.read_line(null)) != null) {
    if (!raw && !raw_text && line.has_prefix("#%")) {
      if (line.has_prefix("#%include")) {
        string nfile = replaceWithEnvVar(line.substring(9).strip());
        try {
          shtpl(nfile);
        } catch (Error e) {
          stderr.printf("%s: Line '%s': File '%s'\n", e.message, line, nfile);
        }
      } else if (line.has_prefix("#%incraw")) {
        string nfile = replaceWithEnvVar(line.substring(8).strip());
        try {
          shtpl(nfile, true);
        } catch (Error e) {
          stderr.printf("%s: Line '%s': File '%s'\n", e.message, line, nfile);
        }
      } else if (line.has_prefix("#%raw")) {
        raw_text = true;
      } else {
        if (opt)
          printCache();
        stdout.printf("%s\n", line.substring(2));
      }
      continue;
    } else if (raw_text && line.has_prefix("#%end raw")) {
      raw_text = false;
      continue;
    }

    line = regex2.replace(regex1.replace(line, -1, 0, "\\\\\\\\"), -1, 0, "\\\\\"");
    if (raw || raw_text) {
      line = regex4.replace(regex3.replace(line, -1, 0, "\\\\$"), -1, 0, "\\\\`");
    } else {
      line = regex7.replace(regex5.replace(line, -1, 0, "\\\\$"), -1, 0, "\\\\$[");
      if (!ass) {
        line = regex4.replace(regex6.replace(line, -1, 0, "\\\\$("), -1, 0, "\\\\`");
      }
    }

    if ( !raw && !raw_text && line.has_suffix("#slurp")) {
      if (opt)
        printCache();
      stdout.printf("printf \"%%s\" \"%s\"\n", line.substring(0, get_uchar_count(line)-6));
    } else {
      if (opt)
        addCache(line);
      else
        stdout.printf("printf \"%%s\\n\" \"%s\"\n", line);
    }
  }
}

void print_help() {
  stderr.puts("""
  shtpl (%s) - shell templating system (vala implementation)

  Syntax:
  #%% shell-command
  #%%# comment
  #%%include file
  #%%raw
  #%%end raw
  #%%incraw file (include raw file)
  #slurp        (removes trailing newline)
  %%$            (masks $)

  Options:
  -ass/--allow-subshell: does not mask $(, ´
  -o  /--optimize      : minimize printf usage

  Example usage:
  sh -c "$( shtpl [Options...] template )"
  shtpl [Options...] template | ( . /dev/stdin )

""".printf(VERSION));
  Process.exit(1);
}


int main (string[] args) {

  GLib.Intl.setlocale(LocaleCategory.ALL, "");

  int i = 1;
  foreach(string arg in args) {
    if (arg == "-h" || arg == "--help") {
      print_help();
    } else if (arg == "-ass" || arg == "--allow-subshell") {
      ass = true;
      i++;
    } else if (arg == "-o" || arg == "--optimize") {
      opt = true;
      i++;
    }
  }

  try {
    regex1 = new Regex("\\\\");
    regex2 = new Regex("\\\"");
    regex3 = new Regex("\\$");
    regex4 = new Regex("`");
    regex5 = new Regex("%\\$");
    regex6 = new Regex("\\$\\(");
    regex7 = new Regex("\\$\\[");

    if (opt)
      sb = new StringBuilder();

    shtpl(args[i]);

    if (opt)
      printCache();
  } catch (Error e) {
    stderr.printf("%s\n", e.message);
    return 1;
  }

  return 0;
}
